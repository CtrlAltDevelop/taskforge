"""The board over gRPC (``BoardController``): Get, ListColumn, Move.

Get and ListColumn need workspace membership; Move needs ``task.update`` and obeys the workflow
(FAILED_PRECONDITION TRANSITION_NOT_ALLOWED, TASK_BLOCKED with the trailers of ``TaskController``)
when the card changes status. ``group_by`` is ``status`` (default), ``priority``, ``assignee`` or
``field:<select field id>``; ``swimlane`` is empty or ``assignee``. A refusal changes nothing.
Rules and ranks are in ``infrastructure.tasks.board``; the plumbing is shared with
``infrastructure.tasks.grpc.services``.
"""

from typing import Any

from asgiref.sync import sync_to_async
from django_socio_grpc import generics
from django_socio_grpc.decorators import grpc_action

from infrastructure.common.grpc.errors import action
from infrastructure.tasks import board
from infrastructure.tasks.grpc.serializers import BoardLane as BoardLaneSchema
from infrastructure.tasks.grpc.serializers import Task
from infrastructure.tasks.grpc.services import IDS, VERSION, _message, _one, _pb, _scope

GROUPING = [
    {"name": "group_by", "type": "string"},
    {"name": "swimlane", "type": "string"},
    {"name": "page_size", "type": "int32"},
]


def _column(column: board.Column) -> Any:
    return _pb().BoardColumn(
        key=column.key,
        name=column.name,
        count=column.count,
        tasks=[_message(t) for t in column.tasks],
        cursor=column.cursor,
    )


class BoardService(generics.GenericService):
    @grpc_action(
        request=[*IDS, *GROUPING],
        request_name="BoardGetRequest",
        response=[{"name": "lanes", "cardinality": "repeated", "type": BoardLaneSchema}],
        response_name="BoardView",
    )
    @action
    async def Get(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)
        return await sync_to_async(
            lambda: _pb().BoardView(
                lanes=[
                    _pb().BoardLane(key=lane.key, columns=[_column(c) for c in lane.columns])
                    for lane in board.get(
                        user,
                        workspace,
                        request.project_id,
                        group_by=request.group_by or "status",
                        swimlane=request.swimlane,
                        limit=request.page_size or board.PAGE,
                    )
                ]
            )
        )()

    @grpc_action(
        request=[
            *IDS,
            *GROUPING,
            {"name": "column", "type": "string"},
            {"name": "lane", "type": "string"},
            {"name": "cursor", "type": "string"},
        ],
        request_name="BoardListColumnRequest",
        response=[
            {"name": "tasks", "cardinality": "repeated", "type": Task},
            {"name": "cursor", "type": "string"},
        ],
        response_name="BoardPage",
    )
    @action
    async def ListColumn(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)

        def read() -> Any:
            tasks, cursor = board.list_column(
                user,
                workspace,
                request.project_id,
                group_by=request.group_by or "status",
                column=request.column,
                lane=request.lane,
                swimlane=request.swimlane,
                cursor=request.cursor,
                limit=request.page_size or board.PAGE,
            )
            return _pb().BoardPage(tasks=[_message(t) for t in tasks], cursor=cursor)

        return await sync_to_async(read)()

    @grpc_action(
        request=[
            *IDS,
            {"name": "id", "type": "string"},
            VERSION,
            {"name": "group_by", "type": "string"},
            {"name": "column", "type": "string"},
            {"name": "before_id", "type": "string"},
            {"name": "after_id", "type": "string"},
            {"name": "include_subtasks", "type": "bool"},
            {"name": "override_blocked", "type": "bool"},
        ],
        request_name="BoardMoveRequest",
        response=Task,
        response_name="Task",
    )
    @action
    async def Move(self, request: Any, context: Any) -> Any:
        return await _one(
            request,
            context,
            lambda u, w: board.move_card(
                u,
                w,
                request.project_id,
                request.id,
                group_by=request.group_by or "status",
                column=request.column,
                expected_version=request.expected_version,
                before_id=request.before_id,
                after_id=request.after_id,
                with_subtasks=request.include_subtasks,
                override_blocked=request.override_blocked,
            ),
        )


GRPC_SERVICES = [BoardService]
