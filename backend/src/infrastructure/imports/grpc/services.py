"""Importing and exporting over gRPC: ``ImportController`` and ``ExportController``. The rules are
in ``infrastructure.imports``; the file itself is uploaded over REST (``POST /imports/upload``).

``Import.Analyze`` reads the uploaded file and returns the proposed mapping (``mapping_json``) with
what the file holds (``analysis_json``); ``DryRun`` says what ``Start`` would do under a mapping;
``Start`` runs it in the background (starting a failed or cancelled job again resumes it);
``Progress`` streams the job until it ends; ``Cancel`` stops it; ``Undo`` removes exactly what it
made. ``Import.Get`` also carries the error report. Everything needs ``data.manage``; a job of
another workspace is NOT_FOUND. ``Export.Start`` builds a project's (or every visible project's)
zip; ``Status`` returns a signed ``download_path`` once it is done.
"""

import asyncio
import json
import time
from collections.abc import AsyncIterator
from typing import Any

from asgiref.sync import sync_to_async
from django_socio_grpc import generics
from django_socio_grpc.decorators import grpc_action

from infrastructure.common.errors import ApiError
from infrastructure.common.grpc.errors import action, require_caller, stream_action
from infrastructure.common.identity import grpc_caller
from infrastructure.imports import exports, placeholders, services
from infrastructure.imports.grpc.serializers import ExportJob, Job, Placeholder, Problem
from infrastructure.imports.models import ImportJob, Status
from infrastructure.workspaces.scoping import require_workspace

WS = {"name": "workspace_id", "type": "string"}
JOB = [WS, {"name": "job_id", "type": "string"}]
MAPPING = {"name": "mapping_json", "type": "string"}
POLL_SECONDS = 1.0
STREAM_LIMIT_SECONDS = 3600


def _pb() -> Any:
    from infrastructure.imports.grpc import imports_pb2

    return imports_pb2


def _iso(value: Any) -> str:
    return value.isoformat() if value else ""


def job_message(job: ImportJob) -> Any:
    return _pb().Job(
        id=str(job.pk),
        source=job.source,
        status=job.status,
        filename=job.filename,
        project_id=str(job.project_id or ""),
        total=job.total,
        done=job.done,
        phase=job.phase,
        error=job.error,
        stats_json=json.dumps(job.stats),
        problem_count=len(job.error_report),
        created_at=_iso(job.created_at),
        started_at=_iso(job.started_at),
        finished_at=_iso(job.finished_at),
        version=job.version,
    )


def _mapping(raw: str) -> dict[str, Any]:
    try:
        loaded = json.loads(raw)
    except (ValueError, RecursionError):
        raise ApiError("The mapping is not JSON.", status=400) from None
    if not isinstance(loaded, dict):
        raise ApiError("The mapping must be an object.", status=400)
    return loaded


def export_message(job: Any, path: str = "") -> Any:
    return _pb().ExportJob(
        id=str(job.pk),
        scope=job.scope,
        project_id=str(job.project_id or ""),
        status=job.status,
        filename=job.filename,
        size=job.file_size,
        stats_json=json.dumps(job.stats),
        error=job.error,
        download_path=path,
        created_at=_iso(job.created_at),
    )


async def _scope(request: Any, context: Any) -> tuple[Any, Any]:
    user = require_caller(await grpc_caller(context))
    return user, await sync_to_async(require_workspace)(user, request.workspace_id)


class ImportService(generics.GenericService):
    @grpc_action(
        request=[WS],
        request_name="ImportListRequest",
        response=[{"name": "jobs", "cardinality": "repeated", "type": Job}],
        response_name="ImportList",
    )
    @action
    async def List(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)

        def run() -> Any:
            rows = services.list_jobs(user, workspace)
            return _pb().ImportList(jobs=[job_message(j) for j in rows])

        return await sync_to_async(run)()

    @grpc_action(
        request=JOB,
        request_name="ImportGetRequest",
        response=[
            {"name": "job", "type": Job},
            {"name": "problems", "cardinality": "repeated", "type": Problem},
            {"name": "mapping_json", "type": "string"},
            {"name": "analysis_json", "type": "string"},
        ],
        response_name="ImportDetail",
    )
    @action
    async def Get(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)

        def run() -> Any:
            job = services.get(user, workspace, request.job_id)
            return _pb().ImportDetail(
                job=job_message(job),
                problems=[
                    _pb().Problem(line=p["line"], message=p["message"], level=p["level"])
                    for p in job.error_report[:500]
                ],
                mapping_json=json.dumps(job.mapping),
                analysis_json=json.dumps(job.analysis),
            )

        return await sync_to_async(run)()

    @grpc_action(
        request=[*JOB, {"name": "source", "type": "string"}, {"name": "member", "type": "string"}],
        request_name="ImportAnalyzeRequest",
        response=[
            {"name": "job", "type": Job},
            {"name": "mapping_json", "type": "string"},
            {"name": "analysis_json", "type": "string"},
            {"name": "members", "cardinality": "repeated", "type": "string"},
        ],
        response_name="ImportProposal",
    )
    @action
    async def Analyze(self, request: Any, context: Any) -> Any:
        """Reads the file (``source`` / ``member`` override what was detected) and proposes."""
        user, workspace = await _scope(request, context)

        def run() -> Any:
            found = services.analyze(
                user, workspace, request.job_id, source=request.source, member=request.member
            )
            return _pb().ImportProposal(
                job=job_message(found.job),
                mapping_json=json.dumps(found.job.mapping),
                analysis_json=json.dumps(found.job.analysis),
                members=services.members_of(user, workspace, request.job_id),
            )

        return await sync_to_async(run)()

    @grpc_action(
        request=[*JOB, MAPPING],
        request_name="ImportDryRunRequest",
        response=[
            {"name": "counts_json", "type": "string"},
            {"name": "warnings", "cardinality": "repeated", "type": Problem},
            {"name": "errors", "type": "int32"},
            {"name": "warning_total", "type": "int32"},
            {"name": "already_imported", "type": "int32"},
        ],
        response_name="ImportReport",
    )
    @action
    async def DryRun(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)

        def run() -> Any:
            report = services.dry_run(
                user, workspace, request.job_id, _mapping(request.mapping_json)
            )
            return _pb().ImportReport(
                counts_json=json.dumps(report.counts),
                warnings=[
                    _pb().Problem(line=w["line"], message=w["message"], level=w["level"])
                    for w in report.warnings
                ],
                errors=report.errors,
                warning_total=report.warning_total,
                already_imported=report.already_imported,
            )

        return await sync_to_async(run)()

    @grpc_action(
        request=[*JOB, MAPPING],
        request_name="ImportStartRequest",
        response=[{"name": "job", "type": Job}],
        response_name="ImportStarted",
    )
    @action
    async def Start(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)

        def run() -> Any:
            job = services.start(user, workspace, request.job_id, _mapping(request.mapping_json))
            return _pb().ImportStarted(job=job_message(job))

        return await sync_to_async(run)()

    @grpc_action(
        request=JOB,
        request_name="ImportProgressRequest",
        response=[{"name": "job", "type": Job}],
        response_name="ImportProgress",
        response_stream=True,
    )
    @stream_action
    async def Progress(self, request: Any, context: Any) -> AsyncIterator[Any]:
        """The job now, then again about every second while it runs; ends when it stops."""
        user, workspace = await _scope(request, context)
        started = time.monotonic()
        last: tuple[Any, ...] = ()
        while True:
            job = await sync_to_async(services.get)(user, workspace, request.job_id)
            seen = (job.status, job.done, job.total, job.phase)
            if seen != last:
                last = seen
                yield _pb().ImportProgress(job=job_message(job))
            if job.status not in Status.ACTIVE or time.monotonic() - started > STREAM_LIMIT_SECONDS:
                return
            await asyncio.sleep(POLL_SECONDS)

    @grpc_action(
        request=JOB,
        request_name="ImportCancelRequest",
        response=[{"name": "job", "type": Job}],
        response_name="ImportCancelled",
    )
    @action
    async def Cancel(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)

        def run() -> Any:
            return _pb().ImportCancelled(
                job=job_message(services.cancel(user, workspace, request.job_id))
            )

        return await sync_to_async(run)()

    @grpc_action(
        request=JOB,
        request_name="ImportUndoRequest",
        response=[{"name": "job", "type": Job}, {"name": "removed_json", "type": "string"}],
        response_name="ImportUndone",
    )
    @action
    async def Undo(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)

        def run() -> Any:
            job, gone = services.undo(user, workspace, request.job_id)
            return _pb().ImportUndone(job=job_message(job), removed_json=json.dumps(gone))

        return await sync_to_async(run)()

    @grpc_action(
        request=JOB,
        request_name="ImportDiscardRequest",
        response=[{"name": "job_id", "type": "string"}],
        response_name="ImportDiscarded",
    )
    @action
    async def Discard(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)

        def run() -> Any:
            services.discard(user, workspace, request.job_id)
            return _pb().ImportDiscarded(job_id=request.job_id)

        return await sync_to_async(run)()

    @grpc_action(
        request=[WS],
        request_name="PlaceholderListRequest",
        response=[{"name": "placeholders", "cardinality": "repeated", "type": Placeholder}],
        response_name="PlaceholderList",
    )
    @action
    async def ListPlaceholders(self, request: Any, context: Any) -> Any:
        """The people an import named who are not members yet, with their waiting tasks."""
        user, workspace = await _scope(request, context)

        def run() -> Any:
            rows = placeholders.list_unclaimed(user, workspace)
            counts = placeholders.task_counts([r.pk for r in rows])
            return _pb().PlaceholderList(
                placeholders=[
                    _pb().Placeholder(
                        id=str(r.pk), name=r.name, email=r.source_email, tasks=counts.get(r.pk, 0)
                    )
                    for r in rows
                ]
            )

        return await sync_to_async(run)()

    @grpc_action(
        request=[
            WS,
            {"name": "placeholder_id", "type": "string"},
            {"name": "user_id", "type": "string"},
        ],
        request_name="PlaceholderClaimRequest",
        response=[{"name": "assigned", "type": "int32"}],
        response_name="PlaceholderClaimed",
    )
    @action
    async def ClaimPlaceholder(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)

        def run() -> Any:
            n = placeholders.claim(user, workspace, request.placeholder_id, request.user_id)
            return _pb().PlaceholderClaimed(assigned=n)

        return await sync_to_async(run)()


class ExportService(generics.GenericService):
    @grpc_action(
        request=[WS, {"name": "project_id", "type": "string"}],
        request_name="ExportStartRequest",
        response=[{"name": "export", "type": ExportJob}],
        response_name="ExportStarted",
    )
    @action
    async def Start(self, request: Any, context: Any) -> Any:
        """One project, or (empty ``project_id``) every project the caller can open."""
        user, workspace = await _scope(request, context)

        def run() -> Any:
            job = exports.start(user, workspace, request.project_id)
            return _pb().ExportStarted(export=export_message(job, _path(user, workspace, job)))

        return await sync_to_async(run)()

    @grpc_action(
        request=[WS, {"name": "export_id", "type": "string"}],
        request_name="ExportStatusRequest",
        response=[{"name": "export", "type": ExportJob}],
        response_name="ExportStatus",
    )
    @action
    async def Status(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)

        def run() -> Any:
            job = exports.get(user, workspace, request.export_id)
            return _pb().ExportStatus(export=export_message(job, _path(user, workspace, job)))

        return await sync_to_async(run)()


def _path(user: Any, workspace: Any, job: Any) -> str:
    if job.status != "done":
        return ""
    return f"/exports/download?token={exports.link_token(user, workspace, str(job.pk))}"


GRPC_SERVICES = [ImportService, ExportService]
