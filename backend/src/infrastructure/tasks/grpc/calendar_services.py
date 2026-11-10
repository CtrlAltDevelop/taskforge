"""The calendar over gRPC (``CalendarController``): ListRange, ListWorkspaceRange,
ListUnscheduled.

All need workspace membership; ``ListRange`` and ``ListUnscheduled`` also a project the caller can
open (a hidden or foreign project is NOT_FOUND). ``ListRange`` streams the tasks that fall on any
day from ``range_start`` to ``range_end`` (inclusive ``YYYY-MM-DD`` dates, at most 62 days apart;
INVALID_ARGUMENT otherwise), subtasks included, in chunks. ``ListWorkspaceRange`` is the same across
every non-archived project the caller can open, optionally narrowed by ``project_ids``. Dates carry
no time zone. ``ListUnscheduled`` pages the open tasks with no dates (the tray). A date is changed
with ``TaskController.Update``. Rules and queries are in ``infrastructure.tasks.calendar``; the
plumbing is shared with ``infrastructure.tasks.grpc.services``.
"""

from collections.abc import AsyncIterator
from typing import Any

from asgiref.sync import sync_to_async
from django_socio_grpc import generics
from django_socio_grpc.decorators import grpc_action

from infrastructure.common.grpc.errors import action, stream_action
from infrastructure.tasks import calendar
from infrastructure.tasks.grpc.serializers import Task
from infrastructure.tasks.grpc.services import FILTER, IDS, _message, _pb, _scope


def _next_chunk(chunks: Any) -> Any:
    """The next chunk of tasks as messages (None at the end), built where the ORM may be used."""
    chunk = next(chunks, None)
    return None if chunk is None else [_message(t) for t in chunk]


class CalendarService(generics.GenericService):
    @grpc_action(
        request=[
            *IDS,
            {"name": "range_start", "type": "string"},
            {"name": "range_end", "type": "string"},
            {"name": "include_done", "type": "bool"},
            *FILTER,
        ],
        request_name="CalendarRangeRequest",
        response=Task,
        response_name="Task",
        response_stream=True,
    )
    @stream_action
    async def ListRange(self, request: Any, context: Any) -> AsyncIterator[Any]:
        user, workspace = await _scope(request, context)
        chunks = calendar.iter_range(
            user,
            workspace,
            request.project_id,
            request.range_start,
            request.range_end,
            include_done=request.include_done,
            filter_ast=request.filter_ast,
            today=request.today,
        )
        while (chunk := await sync_to_async(_next_chunk)(chunks)) is not None:
            for message in chunk:
                yield message

    @grpc_action(
        request=[
            {"name": "workspace_id", "type": "string"},
            {"name": "range_start", "type": "string"},
            {"name": "range_end", "type": "string"},
            {"name": "include_done", "type": "bool"},
            {"name": "project_ids", "cardinality": "repeated", "type": "string"},
            *FILTER,
        ],
        request_name="CalendarWorkspaceRangeRequest",
        response=Task,
        response_name="Task",
        response_stream=True,
    )
    @stream_action
    async def ListWorkspaceRange(self, request: Any, context: Any) -> AsyncIterator[Any]:
        user, workspace = await _scope(request, context)
        chunks = calendar.iter_workspace_range(
            user,
            workspace,
            request.range_start,
            request.range_end,
            include_done=request.include_done,
            project_ids=list(request.project_ids),
            filter_ast=request.filter_ast,
            today=request.today,
        )
        while (chunk := await sync_to_async(_next_chunk)(chunks)) is not None:
            for message in chunk:
                yield message

    @grpc_action(
        request=[
            *IDS,
            {"name": "cursor", "type": "string"},
            {"name": "page_size", "type": "int32"},
        ],
        request_name="CalendarTrayRequest",
        response=[
            {"name": "tasks", "cardinality": "repeated", "type": Task},
            {"name": "cursor", "type": "string"},
        ],
        response_name="CalendarTray",
    )
    @action
    async def ListUnscheduled(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)

        def read() -> Any:
            tasks, cursor = calendar.list_unscheduled(
                user, workspace, request.project_id, request.cursor, request.page_size
            )
            return _pb().CalendarTray(tasks=[_message(t) for t in tasks], cursor=cursor)

        return await sync_to_async(read)()


GRPC_SERVICES = [CalendarService]
