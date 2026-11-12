"""The audit log over gRPC: ``AuditController`` (admin), ``ActivityController`` (a task's history).

``Audit.List`` filters by actor, action (exact, or a prefix ending in ``.``), target, project and
a time window; newest first; ``before`` is the id of the last entry of the previous page and
``next_before`` (0 at the end) the id to send for the next one. ``Audit.Export`` streams the same
filtered log as CSV text, a chunk per message. Both need ``audit.view``. ``Activity.ForTask`` needs
only that the caller can open the task; ``labels`` names the ids (statuses, people, sprints, tasks)
that the entries mention. INVALID_ARGUMENT for a malformed filter, PERMISSION_DENIED without
``audit.view``, NOT_FOUND for a task the caller cannot open. There is no write RPC: the log only
grows through the changes it describes.
"""

import json
from collections.abc import AsyncIterator, Iterator
from typing import Any

from asgiref.sync import sync_to_async
from django_socio_grpc import generics
from django_socio_grpc.decorators import grpc_action

from infrastructure.audit import services
from infrastructure.audit.grpc.serializers import AuditEntry, Label
from infrastructure.audit.labels import label_ids, name_of
from infrastructure.common.grpc.errors import action, require_caller, stream_action
from infrastructure.common.identity import grpc_caller
from infrastructure.workspaces.scoping import require_workspace

WS = {"name": "workspace_id", "type": "string"}
FILTERS = [
    {"name": n, "type": "string"}
    for n in ("actor", "action", "target_type", "target_id", "project_id", "since", "until")
]
PAGING = [{"name": "before", "type": "int64"}, {"name": "limit", "type": "int32"}]
PAGE = [
    {"name": "entries", "cardinality": "repeated", "type": AuditEntry},
    {"name": "labels", "cardinality": "repeated", "type": Label},
    {"name": "next_before", "type": "int64"},
]


def _pb() -> Any:
    from infrastructure.audit.grpc import audit_pb2

    return audit_pb2


def _iso(value: Any) -> str:
    return value.isoformat() if value else ""


def _filters(request: Any) -> services.Filters:
    return services.Filters(
        actor=request.actor,
        action=request.action,
        target_type=request.target_type,
        target_id=request.target_id,
        project_id=request.project_id,
        since=request.since,
        until=request.until,
    )


def _page_message(workspace: Any, page: services.Page, *, reader: Any = None) -> Any:
    """``reader`` marks a task's history (not the admin log): the address and agent of whoever made
    a change are for admins only, and ids of tasks the reader cannot open stay unnamed."""
    names = label_ids(workspace, page.entries, reader=reader)
    pb = _pb()
    return pb.AuditPage(
        entries=[
            pb.AuditEntry(
                id=e.pk,
                at=_iso(e.at),
                actor=e.actor,
                actor_name=name_of(names, e.actor),
                actor_type=e.actor_type,
                action=e.action,
                target_type=e.target_type,
                target_id=e.target_id,
                project_id=str(e.project or ""),
                batch_id=str(e.batch_id or ""),
                ip="" if reader is not None else str(e.ip or ""),
                user_agent="" if reader is not None else e.user_agent,
                changes_json=json.dumps(e.changes),
            )
            for e in page.entries
        ],
        labels=[pb.Label(id=i, name=n) for i, n in sorted(names.items())],
        next_before=page.next_before,
    )


async def _scope(request: Any, context: Any) -> tuple[Any, Any]:
    user = require_caller(await grpc_caller(context))
    return user, await sync_to_async(require_workspace)(user, request.workspace_id)


def _next_chunk(chunks: Iterator[str]) -> str | None:
    return next(chunks, None)


class AuditService(generics.GenericService):
    @grpc_action(
        request=[WS, *FILTERS, *PAGING],
        request_name="AuditListRequest",
        response=PAGE,
        response_name="AuditPage",
    )
    @action
    async def List(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)

        def run() -> Any:
            page = services.list_entries(
                user, workspace, _filters(request), before=request.before, limit=request.limit
            )
            return _page_message(workspace, page)

        return await sync_to_async(run)()

    @grpc_action(
        request=[WS, *FILTERS],
        request_name="AuditExportRequest",
        response=[{"name": "csv", "type": "string"}],
        response_name="AuditExportChunk",
        response_stream=True,
    )
    @stream_action
    async def Export(self, request: Any, context: Any) -> AsyncIterator[Any]:
        user, workspace = await _scope(request, context)
        chunks: Iterator[str] = await sync_to_async(services.export_csv)(
            user, workspace, _filters(request)
        )
        while (text := await sync_to_async(_next_chunk)(chunks)) is not None:
            yield _pb().AuditExportChunk(csv=text)


class ActivityService(generics.GenericService):
    @grpc_action(
        request=[
            WS,
            {"name": "project_id", "type": "string"},
            {"name": "task_id", "type": "string"},
            *PAGING,
        ],
        request_name="ActivityForTaskRequest",
        response=PAGE,
        response_name="AuditPage",
    )
    @action
    async def ForTask(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)

        def run() -> Any:
            page = services.activity_for_task(
                user,
                workspace,
                request.project_id,
                request.task_id,
                before=request.before,
                limit=request.limit,
            )
            return _page_message(workspace, page, reader=user)

        return await sync_to_async(run)()


GRPC_SERVICES = [AuditService, ActivityService]
