"""Exporting: start, check on it, and fetch the zip through a short-lived signed link."""

import json
import tempfile
import uuid
import zipfile
from datetime import timedelta
from typing import Any, Final

from django.conf import settings
from django.core import signing
from django.core.files import File
from django.core.files.storage import default_storage
from django.utils import timezone

from infrastructure.audit import recorder
from infrastructure.common.errors import ApiError
from infrastructure.imports import export_data, queue
from infrastructure.imports.models import ExportJob
from infrastructure.projects import services as projects
from infrastructure.projects.models import Project
from infrastructure.workspaces import access
from infrastructure.workspaces.models import Workspace

MANAGE: Final = "data.manage"
LINK_SALT: Final = "imports.export"
KEEP_HOURS: Final = 24


def _not_found() -> ApiError:
    return ApiError("No such export.", status=404)


def start(actor: Any, workspace: Workspace, project_id: str = "") -> ExportJob:
    """Export one project (``project_id``) or every project the caller can open (empty)."""
    access.require(actor, MANAGE, workspace)
    project = projects.load(actor, workspace, project_id) if project_id else None
    job = ExportJob.objects.create(
        workspace=workspace,
        created_by=actor,
        project=project,
        scope="project" if project else "workspace",
    )
    queue.run_later(run, job.pk, lane="exports")
    return ExportJob.objects.get(pk=job.pk)


def run(job_id: Any) -> None:
    claimed = ExportJob.objects.filter(pk=job_id, status="queued").update(status="running")
    if not claimed:
        return
    job = ExportJob.objects.select_related("workspace", "created_by", "project").get(pk=job_id)
    try:
        _build(job)
    except Exception as error:  # noqa: BLE001 -- recorded on the job
        reason = str(error) if isinstance(error, ApiError) else "The export stopped on an error."
        ExportJob.objects.filter(pk=job_id).update(
            status="failed", error=reason[:500], finished_at=timezone.now()
        )
        raise


def _build(job: ExportJob) -> dict[str, int]:
    totals: dict[str, int] = {"projects": 0, "tasks": 0, "comments": 0, "attachments": 0}
    with tempfile.TemporaryFile() as raw:
        with zipfile.ZipFile(raw, "w", zipfile.ZIP_DEFLATED) as archive:
            if job.project:
                rows = [job.project]
                folder = False
            else:
                rows = list(
                    Project.objects.visible_to(job.created_by, job.workspace).order_by("key")
                )
                folder = True
                archive.writestr(
                    "workspace.json",
                    json.dumps(
                        {
                            "format": "taskforge-workspace-export",
                            "version": 1,
                            "name": job.workspace.name,
                        }
                    ),
                )
            for project in rows:
                counts = export_data.write_project(archive, project, project.key if folder else "")
                totals["projects"] += 1
                for name, n in counts.items():
                    totals[name] += n
        raw.seek(0)
        name = f"taskforge-{(job.project.key if job.project else job.workspace.slug)}.zip".lower()
        key = default_storage.save(
            f"exports/{job.workspace_id}/{uuid.uuid4().hex}-{name}", File(raw)
        )
        size = default_storage.size(key)
    ExportJob.objects.filter(pk=job.pk).update(
        status="done", file_key=key, file_size=size, filename=name, stats=totals,
        finished_at=timezone.now(),
    )  # fmt: skip
    recorder.record(
        workspace_id=job.workspace_id,
        action="export.created",
        target_type="export",
        target_id=job.pk,
        project_id=job.project_id,
        actor=job.created_by,
        changes={"scope": job.scope, **totals},
    )
    return totals


def get(actor: Any, workspace: Workspace, export_id: str) -> ExportJob:
    access.require(actor, MANAGE, workspace)
    try:
        pk = uuid.UUID(str(export_id))
    except ValueError:
        raise _not_found() from None
    job = ExportJob.objects.filter(pk=pk, workspace=workspace, created_by=actor).first()
    if job is None:
        raise _not_found()
    return job


def link_token(actor: Any, workspace: Workspace, export_id: str) -> str:
    """A signed token for the file of a finished export (valid ``EXPORT_LINK_TTL_SECONDS``)."""
    job = get(actor, workspace, export_id)
    if job.status != "done":
        raise ApiError("The export is not ready.", status=409)
    return signing.dumps({"e": str(job.pk)}, salt=LINK_SALT)


def resolve_token(token: str) -> ExportJob:
    try:
        payload = signing.loads(token, salt=LINK_SALT, max_age=settings.EXPORT_LINK_TTL_SECONDS)
    except signing.SignatureExpired:
        raise ApiError("This link has expired. Ask for a new one.", status=410) from None
    except signing.BadSignature:
        raise _not_found() from None
    job = (
        ExportJob.objects.filter(pk=payload.get("e"), status="done")
        .select_related("workspace", "created_by")
        .first()
    )
    if job is None or not default_storage.exists(job.file_key):
        raise _not_found()
    if not access.can(job.created_by, MANAGE, job.workspace).allowed:
        raise _not_found()  # whoever asked for it may no longer take it
    return job


def purge_old(now: Any = None) -> int:
    """Delete export files older than ``KEEP_HOURS`` (the row stays, marked expired)."""
    cutoff = (now or timezone.now()) - timedelta(hours=KEEP_HOURS)
    removed = 0
    for job in ExportJob.objects.filter(status="done", finished_at__lt=cutoff).exclude(file_key=""):
        if default_storage.exists(job.file_key):
            default_storage.delete(job.file_key)
        ExportJob.objects.filter(pk=job.pk).update(status="expired", file_key="")
        removed += 1
    return removed
