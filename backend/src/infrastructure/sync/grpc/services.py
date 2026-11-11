"""Catching up after a gap, over gRPC (``SyncController``): Since, Head.

Both need workspace membership. ``Since(workspace_id, cursor, limit)`` streams the changes after
``cursor`` (a decimal string; empty or ``0`` is "from the start of the log") that the caller may
see, oldest first, at most ``limit`` (default 1000, at most 5000) of the log; the last entry's
cursor continues the read. A cursor older than the log still holds answers with one ``sync.gap``
entry whose cursor is the current head: read the screens again and listen from there. A full
page ends with one ``sync.more`` entry whose cursor continues the read. ``Head``
answers with that current cursor (``"0"`` for a quiet workspace). Rules are in
``infrastructure.sync.services``; the live feed is the ``/ws/sync`` socket.
"""

from collections.abc import AsyncIterator
from typing import Any

from asgiref.sync import sync_to_async
from django_socio_grpc import generics
from django_socio_grpc.decorators import grpc_action

from infrastructure.common.errors import ApiError
from infrastructure.common.grpc.errors import action, require_caller, stream_action
from infrastructure.common.identity import grpc_caller
from infrastructure.sync import services
from infrastructure.sync.grpc.serializers import SyncEntry
from infrastructure.sync.models import ChangeLog
from infrastructure.workspaces.scoping import require_workspace


def _pb() -> Any:
    from infrastructure.sync.grpc import sync_pb2

    return sync_pb2


def _entry(row: ChangeLog) -> Any:
    event = row.as_event()
    return _pb().SyncEntry(
        cursor=str(row.pk),
        type=event["type"],
        project_id=event["project"],
        entity_id=event["entity_id"],
        version=row.version,
        actor=row.actor,
        at=event["ts"],
    )


def _cursor(raw: str) -> int:
    try:
        return int(raw or 0)
    except ValueError:
        raise ApiError("A cursor is a number.") from None


async def _scope(request: Any, context: Any) -> tuple[Any, Any]:
    user = require_caller(await grpc_caller(context))
    return user, await sync_to_async(require_workspace)(user, request.workspace_id)


class SyncService(generics.GenericService):
    @grpc_action(
        request=[
            {"name": "workspace_id", "type": "string"},
            {"name": "cursor", "type": "string"},
            {"name": "limit", "type": "int32"},
            {"name": "overlap", "type": "int32"},
        ],
        request_name="SyncSinceRequest",
        response=SyncEntry,
        response_name="SyncEntry",
        response_stream=True,
    )
    @stream_action
    async def Since(self, request: Any, context: Any) -> AsyncIterator[Any]:
        user, workspace = await _scope(request, context)

        def read() -> list[Any]:
            page = services.since(
                user, workspace, _cursor(request.cursor), request.limit, request.overlap
            )
            if page.gap:
                return [
                    _pb().SyncEntry(
                        cursor=str(page.latest), type="sync.gap", project_id="", entity_id=""
                    )
                ]
            found = [_entry(r) for r in page.entries]
            if page.more:  # the log goes on past this page: ask again from this cursor
                found.append(
                    _pb().SyncEntry(
                        cursor=str(page.latest), type="sync.more", project_id="", entity_id=""
                    )
                )
            return found

        for message in await sync_to_async(read)():
            yield message

    @grpc_action(
        request=[{"name": "workspace_id", "type": "string"}],
        request_name="SyncHeadRequest",
        response=[{"name": "cursor", "type": "string"}],
        response_name="SyncHead",
    )
    @action
    async def Head(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)
        cursor = await sync_to_async(services.head)(user, workspace)
        return _pb().SyncHead(cursor=str(cursor))


GRPC_SERVICES = [SyncService]
