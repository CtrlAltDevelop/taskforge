"""The inbox over gRPC. ``InboxController`` (List, MarkRead, Snooze, Archive, UnreadCount) and
``WatcherController`` (Get, Add, Remove) are workspace-scoped; the preferences and devices are the
account's own (``account_services``). Rules and queries are in ``infrastructure.inbox``.

``List`` shows the caller's notifications in one workspace, newest activity first, with the page's
``cursor`` for ``before``; ``filter`` is ``all`` (default), ``unread``, ``mentions``, ``assigned``,
``snoozed`` or ``archived``. Snoozed and archived ones are left out of everything but their own
filter; one for a task the caller can no longer open is never shown. ``UnreadCount`` with no
workspace counts every workspace (the app icon badge).
"""

import json
from typing import Any

from asgiref.sync import sync_to_async
from django_socio_grpc import generics
from django_socio_grpc.decorators import grpc_action

from infrastructure.common.grpc.errors import action, require_caller
from infrastructure.common.identity import grpc_caller
from infrastructure.inbox import services, watchers
from infrastructure.inbox.grpc.account_services import DeviceService, PrefService
from infrastructure.inbox.grpc.serializers import Notification, WatchState
from infrastructure.inbox.models import Notification as NotificationRow
from infrastructure.workspaces.scoping import require_workspace

TASK = [
    {"name": "workspace_id", "type": "string"},
    {"name": "project_id", "type": "string"},
    {"name": "task_id", "type": "string"},
]


def _pb() -> Any:
    from infrastructure.inbox.grpc import inbox_pb2

    return inbox_pb2


def iso(value: Any) -> str:
    return value.isoformat() if value else ""


def message(row: NotificationRow) -> Any:
    actor = row.actor
    return _pb().Notification(
        id=str(row.pk),
        workspace_id=str(row.workspace_id),
        type=row.type,
        task_id=str(row.task_id or ""),
        project_id=str(row.project_id or ""),
        actor_id=str(row.actor_id or ""),
        actor_name=services.name_of(actor) if actor else "",
        payload=json.dumps(row.payload),
        count=row.count,
        created_at=iso(row.created_at),
        updated_at=iso(row.updated_at),
        read_at=iso(row.read_at),
        snoozed_until=iso(row.snoozed_until),
        archived_at=iso(row.archived_at),
    )


async def _scope(request: Any, context: Any) -> tuple[Any, Any]:
    user = require_caller(await grpc_caller(context))
    return user, await sync_to_async(require_workspace)(user, request.workspace_id)


class InboxService(generics.GenericService):
    @grpc_action(
        request=[
            {"name": "workspace_id", "type": "string"},
            {"name": "filter", "type": "string"},
            {"name": "before", "type": "string"},
            {"name": "page_size", "type": "int32"},
        ],
        request_name="InboxListRequest",
        response=[
            {"name": "notifications", "cardinality": "repeated", "type": Notification},
            {"name": "cursor", "type": "string"},
            {"name": "unread_count", "type": "int32"},
        ],
        response_name="InboxPage",
    )
    @action
    async def List(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)

        def read() -> Any:
            page = services.list_page(
                user,
                workspace,
                request.filter or "all",
                before=request.before,
                limit=request.page_size,
            )
            return _pb().InboxPage(
                notifications=[message(n) for n in page.notifications],
                cursor=page.cursor,
                unread_count=page.unread,
            )

        return await sync_to_async(read)()

    @grpc_action(
        request=[
            {"name": "workspace_id", "type": "string"},
            {"name": "ids", "cardinality": "repeated", "type": "string"},
            {"name": "all", "type": "bool"},
            {"name": "read", "type": "bool"},
        ],
        request_name="MarkReadRequest",
        response=[{"name": "count", "type": "int32"}],
        response_name="UnreadTotal",
    )
    @action
    async def MarkRead(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)
        return await sync_to_async(
            lambda: _pb().UnreadTotal(
                count=services.mark_read(
                    user, workspace, list(request.ids), all_=request.all, read=request.read
                )
            )
        )()

    @grpc_action(
        request=[
            {"name": "workspace_id", "type": "string"},
            {"name": "id", "type": "string"},
            {"name": "until", "type": "string"},
        ],
        request_name="SnoozeRequest",
        response=Notification,
        response_name="Notification",
    )
    @action
    async def Snooze(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)
        return await sync_to_async(
            lambda: message(services.snooze(user, workspace, request.id, request.until))
        )()

    @grpc_action(
        request=[
            {"name": "workspace_id", "type": "string"},
            {"name": "ids", "cardinality": "repeated", "type": "string"},
            {"name": "archived", "type": "bool"},
        ],
        request_name="ArchiveRequest",
        response=[{"name": "count", "type": "int32"}],
        response_name="UnreadTotal",
    )
    @action
    async def Archive(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)
        return await sync_to_async(
            lambda: _pb().UnreadTotal(
                count=services.archive(
                    user, workspace, list(request.ids), archived=request.archived
                )
            )
        )()

    @grpc_action(
        request=[{"name": "workspace_id", "type": "string"}],
        request_name="UnreadCountRequest",
        response=[{"name": "count", "type": "int32"}],
        response_name="UnreadTotal",
    )
    @action
    async def UnreadCount(self, request: Any, context: Any) -> Any:
        user = require_caller(await grpc_caller(context))

        def read() -> Any:
            workspace = (
                require_workspace(user, request.workspace_id) if request.workspace_id else None
            )
            return _pb().UnreadTotal(count=services.unread_count(user, workspace))

        return await sync_to_async(read)()


class WatcherService(generics.GenericService):
    @grpc_action(
        request=TASK,
        request_name="WatchGetRequest",
        response=WatchState,
        response_name="WatchState",
    )
    @action
    async def Get(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)
        return await sync_to_async(
            lambda: _pb().WatchState(
                **watchers.state(user, workspace, request.project_id, request.task_id)
            )
        )()

    @grpc_action(
        request=TASK,
        request_name="WatchAddRequest",
        response=WatchState,
        response_name="WatchState",
    )
    @action
    async def Add(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)
        return await sync_to_async(
            lambda: _pb().WatchState(
                **watchers.watch(user, workspace, request.project_id, request.task_id, on=True)
            )
        )()

    @grpc_action(
        request=TASK,
        request_name="WatchRemoveRequest",
        response=WatchState,
        response_name="WatchState",
    )
    @action
    async def Remove(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)
        return await sync_to_async(
            lambda: _pb().WatchState(
                **watchers.watch(user, workspace, request.project_id, request.task_id, on=False)
            )
        )()


GRPC_SERVICES = [InboxService, WatcherService, PrefService, DeviceService]
