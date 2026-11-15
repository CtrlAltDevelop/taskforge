"""Importing: upload a file, read it for a proposed mapping, dry-run, start, watch, cancel, undo.

Everything needs ``data.manage`` (Owner and Admin). A job belongs to one workspace; any id from
another workspace is a 404. The work itself is in ``engine`` (run later, in a background thread)
and ``undo``.
"""

import dataclasses
import uuid
from typing import IO, Any, Final

from django.conf import settings
from django.core.files.storage import default_storage
from django.db import transaction
from django.utils import timezone

from infrastructure.audit import recorder
from infrastructure.common.errors import ApiError
from infrastructure.imports import (
    clickup_api,
    clickup_fetch,
    dryrun,
    engine,
    files,
    parsers,
    queue,
    streams,
)
from infrastructure.imports import mapping as mapping_rules
from infrastructure.imports import scan as scanning
from infrastructure.imports import undo as undoing
from infrastructure.imports.models import ImportJob, Status
from infrastructure.imports.parsers import tabular
from infrastructure.projects.models import Project
from infrastructure.workspaces import access
from infrastructure.workspaces.models import Workspace

MANAGE: Final = "data.manage"
LIST_LIMIT: Final = 50
HEAD_BYTES: Final = 8192
MAX_LISTS: Final = 200


def not_found() -> ApiError:
    return ApiError("No such import.", status=404)


def job_of(actor: Any, workspace: Workspace, job_id: str) -> ImportJob:
    access.require(actor, MANAGE, workspace)
    try:
        pk = uuid.UUID(str(job_id))
    except ValueError:
        raise not_found() from None
    job = ImportJob.objects.filter(pk=pk, workspace=workspace).select_related("project").first()
    if job is None:
        raise not_found()
    return job


def detect(binary: IO[bytes]) -> str:
    """The source a file looks like, by its first bytes; ``csv`` when unsure."""
    text = binary.read(HEAD_BYTES).decode("utf-8-sig", errors="replace")
    if text.lstrip()[:1] in ("[", "{"):
        if '"taskforge-export"' in text:
            return "taskforge"
        if '"issues"' in text or '"fields"' in text:
            return "jira_json"
        return "clickup_json"
    first = text.splitlines()[0].lower() if text else ""
    if "issue key" in first or "issue id" in first:
        return "jira_csv"
    if "task id" in first and "task name" in first:
        return "clickup_csv"
    return "csv"


def upload(
    actor: Any, workspace: Workspace, stream: IO[bytes], filename: str, source: str = ""
) -> ImportJob:
    """Store ``stream`` (read in blocks, never whole) as a new job."""
    access.require(actor, MANAGE, workspace)
    if source and source not in parsers.SOURCES:
        raise ApiError("Unknown source.", status=400)
    key, size = files.store(workspace.pk, stream, filename)
    job = ImportJob(
        workspace=workspace,
        created_by=actor,
        filename=(filename or "upload")[:255],
        file_key=key,
        file_size=size,
        source=source or "csv",
    )
    try:
        if size > settings.IMPORTS_MAX_BYTES:
            raise ApiError("The file is larger than this server accepts.", status=413)
        if size == 0:
            raise ApiError("The file is empty.", status=422)
        raw = default_storage.open(key, "rb")
        try:
            names = streams.member_names(raw)
        finally:
            raw.close()
        if len(names) > 1 and not streams.default_member(names):
            # Several data files (a workspace export, say): the person says which one.
            job.source = source or ("taskforge" if any("tasks.json" in n for n in names) else "csv")
        else:
            binary, member = streams.open_binary(default_storage.open(key, "rb"))
            try:
                job.member = member
                job.source = source or detect(binary)
            finally:
                binary.close()
    except Exception:
        files.remove(job)
        raise
    job.save()
    _record(job, "import.uploaded", {"source": job.source, "filename": job.filename})
    return job


def _record(job: ImportJob, action: str, changes: dict[str, Any]) -> None:
    recorder.record(
        workspace_id=job.workspace_id,
        action=action,
        target_type="import",
        target_id=job.pk,
        project_id=job.project_id,
        changes=changes,
    )


def members_of(actor: Any, workspace: Workspace, job_id: str) -> list[str]:
    """The ``.csv`` / ``.json`` files inside an uploaded zip (empty for a plain file)."""
    job = job_of(actor, workspace, job_id)
    raw = default_storage.open(job.file_key, "rb")
    try:
        return streams.member_names(raw)
    finally:
        raw.close()


@dataclasses.dataclass(slots=True)
class Proposal:
    job: ImportJob
    header: list[str]


def _header_of(job: ImportJob) -> tuple[list[str], list[dict[str, str]]]:
    binary = files.open_job(job)
    try:
        return tabular.read_header(binary)
    finally:
        binary.close()


def analyze(
    actor: Any, workspace: Workspace, job_id: str, *, source: str = "", member: str = ""
) -> Proposal:
    """Read the file once and propose the mapping (statuses, people, columns, target)."""
    job = job_of(actor, workspace, job_id)
    if job.status in Status.ACTIVE:
        raise ApiError("This import is running.", status=409)
    if job.status in (Status.DONE, Status.UNDONE):
        raise ApiError("This import is finished.", status=409)
    if source:
        if source not in parsers.SOURCES:
            raise ApiError("Unknown source.", status=400)
        job.source = source
    if member:
        job.member = member
    if not job.member:
        names = members_of(actor, workspace, job_id)
        if len(names) > 1 and not streams.default_member(names):
            raise ApiError("Choose which file in the zip to import.", status=422)
    header, sample = _header_of(job) if parsers.is_csv(job.source) else ([], [])
    head = engine._header(job)
    binary = files.open_job(job)
    try:
        columns = tabular.propose(job.source, header) if header else None
        found = scanning.scan(job.source, binary, {"columns": columns} if columns else None, head)
    finally:
        binary.close()
    info = scanning.finish(found)
    info.columns, info.sample = header, sample or info.sample
    job.mapping = mapping_rules.propose(
        job.source, info, job.workspace, job.project, header or None, head
    )
    job.analysis = _analysis_json(info)
    job.status, job.total = Status.ANALYZED, info.issues
    job.version += 1
    job.save()
    return Proposal(job, header)


def _analysis_json(info: Any) -> dict[str, Any]:
    out = dataclasses.asdict(info)
    out["problems"] = out["problems"][:100]
    return out


def checked_mapping(
    actor: Any, workspace: Workspace, job: ImportJob, raw: dict[str, Any]
) -> dict[str, Any]:
    header = job.analysis.get("columns") or None
    return mapping_rules.check(actor, workspace, job.source, raw, header)


def dry_run(actor: Any, workspace: Workspace, job_id: str, raw: dict[str, Any]) -> dryrun.Report:
    job = job_of(actor, workspace, job_id)
    if job.status in Status.ACTIVE:
        raise ApiError("This import is running.", status=409)
    return dryrun.report(job, workspace, checked_mapping(actor, workspace, job, raw))


def start(actor: Any, workspace: Workspace, job_id: str, raw: dict[str, Any]) -> ImportJob:
    """Save the mapping and run the import in the background. Starting a failed or cancelled job
    again resumes it: what was made is skipped."""
    job = job_of(actor, workspace, job_id)
    cleaned = checked_mapping(actor, workspace, job, raw)
    target_id = cleaned["target"].get("project_id")
    if job.project_id and target_id and str(job.project_id) != target_id and job.refs.exists():
        raise ApiError(
            "This import already made tasks elsewhere: it cannot change project.", status=409
        )
    with transaction.atomic():
        job = ImportJob.objects.select_for_update().get(pk=job.pk)
        if job.status not in (Status.ANALYZED, Status.FAILED, Status.CANCELLED):
            raise ApiError("This import cannot be started now.", status=409)
        if "project_id" in cleaned["target"]:
            job.project = Project.objects.get(pk=cleaned["target"]["project_id"])
        job.mapping, job.status, job.finished_at, job.error = cleaned, Status.QUEUED, None, ""
        job.version += 1
        job.save()
    queue.run_later(engine.run_job, job.pk)
    return ImportJob.objects.get(pk=job.pk)


def cancel(actor: Any, workspace: Workspace, job_id: str) -> ImportJob:
    job = job_of(actor, workspace, job_id)
    stopped = ImportJob.objects.filter(
        pk=job.pk, status__in=(*Status.ACTIVE, Status.FETCHING)
    ).update(status=Status.CANCELLED)
    if stopped:
        _record(job, "import.cancelled", {"done": job.done, "total": job.total})
    return ImportJob.objects.get(pk=job.pk)


def get(actor: Any, workspace: Workspace, job_id: str) -> ImportJob:
    return job_of(actor, workspace, job_id)


def list_jobs(actor: Any, workspace: Workspace) -> list[ImportJob]:
    access.require(actor, MANAGE, workspace)
    return list(ImportJob.objects.filter(workspace=workspace).order_by("-created_at")[:LIST_LIMIT])


def undo(actor: Any, workspace: Workspace, job_id: str) -> tuple[ImportJob, dict[str, int]]:
    job = job_of(actor, workspace, job_id)
    if job.status in Status.ACTIVE:
        raise ApiError("Cancel the import first.", status=409)
    if job.status in (Status.UPLOADED, Status.ANALYZED, Status.UNDONE):
        raise ApiError("Nothing to undo.", status=409)
    gone = undoing.undo(job)
    job.refresh_from_db()
    job.status, job.finished_at, job.version = Status.UNDONE, timezone.now(), job.version + 1
    job.stats = {**job.stats, "undone": gone}
    job.save()
    return job, gone


def discard(actor: Any, workspace: Workspace, job_id: str) -> None:
    """Forget a job that made nothing (and its stored file)."""
    job = job_of(actor, workspace, job_id)
    if job.status in Status.ACTIVE or job.refs.exists():
        raise ApiError("This import has made data; undo it first.", status=409)
    _record(job, "import.discarded", {"filename": job.filename})
    files.remove(job)
    job.delete()


def clickup_lists(actor: Any, workspace: Workspace, token: str) -> list[dict[str, Any]]:
    """The ClickUp workspaces and lists this token can see (the token is not kept)."""
    access.require(actor, MANAGE, workspace)
    with clickup_api.make_client(token) as http:
        return clickup_api.workspaces_with_lists(http)


def clickup_fetch_start(
    actor: Any, workspace: Workspace, token: str, list_ids: list[str]
) -> ImportJob:
    """Pull the lists into a job's file in the background; the job is ``fetching`` until it is
    ``uploaded`` and the wizard goes on at Map."""
    access.require(actor, MANAGE, workspace)
    ids = list(dict.fromkeys(list_ids))
    if not ids or len(ids) > MAX_LISTS or not all(clickup_api.valid_id(i) for i in ids):
        raise ApiError("Choose between 1 and 200 ClickUp lists.", status=400)
    if not token.strip():
        raise ApiError("A ClickUp token is needed.", status=400)
    job = ImportJob.objects.create(
        workspace=workspace,
        created_by=actor,
        source="clickup_json",
        filename="ClickUp",
        status=Status.FETCHING,
        heartbeat_at=timezone.now(),
    )
    _record(job, "import.clickup_fetch", {"lists": len(ids)})
    queue.run_later(clickup_fetch.run, job.pk, token, ids)
    return ImportJob.objects.get(pk=job.pk)
