"""The timeline over gRPC (``TimelineController``): Get, CriticalPath, PreviewShift, ApplyShift,
GetWorkingDays, SetWorkingDays.

All need workspace membership; the project ones also a project the caller can open (a hidden or
foreign project is NOT_FOUND). ``Get`` streams chunks of the tasks that fall on any day from
``range_start`` to ``range_end`` (inclusive ``YYYY-MM-DD``, at most 1100 days apart) with the
blocking links that touch them, each link once. ``CriticalPath`` names the longest chain of linked
open tasks of the project. ``PreviewShift`` says which dependents a move to the given dates would
push; ``ApplyShift`` makes the move and the pushes in one transaction and refuses (ABORTED) when
the cascade is no longer ``affected_ids``, the tasks previewed; it needs ``task.update``.
``SetWorkingDays`` needs ``workspace.update``. Rules and queries are in
``infrastructure.tasks.timeline`` and ``infrastructure.tasks.schedule``.
"""

from collections.abc import AsyncIterator
from typing import Any

from asgiref.sync import sync_to_async
from django_socio_grpc import generics
from django_socio_grpc.decorators import grpc_action

from infrastructure.common.grpc.errors import action, stream_action
from infrastructure.tasks import timeline
from infrastructure.tasks.grpc.serializers import Task, TimelineLink, TimelineShift
from infrastructure.tasks.grpc.services import FILTER, IDS, _message, _pb, _scope

MOVE = [
    *IDS,
    {"name": "task_id", "type": "string"},
    {"name": "start_date", "type": "string"},
    {"name": "due_date", "type": "string"},
]
WORKSPACE = {"name": "workspace_id", "type": "string"}
WORKING = [
    {"name": "days", "cardinality": "repeated", "type": "int32"},
    {"name": "holidays", "cardinality": "repeated", "type": "string"},
]


def _chunk(chunks: Any) -> Any:
    """The next chunk as a message (None at the end), built where the ORM may be used."""
    found = next(chunks, None)
    if found is None:
        return None
    tasks, pairs = found
    return _pb().TimelineChunk(
        tasks=[_message(t) for t in tasks],
        links=[_pb().TimelineLink(from_id=a, to_id=b) for a, b in pairs],
    )


def _day(value: Any) -> str:
    return value.isoformat() if value else ""


class TimelineService(generics.GenericService):
    @grpc_action(
        request=[
            *IDS,
            {"name": "range_start", "type": "string"},
            {"name": "range_end", "type": "string"},
            {"name": "include_done", "type": "bool"},
            *FILTER,
        ],
        request_name="TimelineGetRequest",
        response=[
            {"name": "tasks", "cardinality": "repeated", "type": Task},
            {"name": "links", "cardinality": "repeated", "type": TimelineLink},
        ],
        response_name="TimelineChunk",
        response_stream=True,
    )
    @stream_action
    async def Get(self, request: Any, context: Any) -> AsyncIterator[Any]:
        user, workspace = await _scope(request, context)
        chunks = timeline.iter_chunks(
            user,
            workspace,
            request.project_id,
            request.range_start,
            request.range_end,
            include_done=request.include_done,
            filter_ast=request.filter_ast,
            today=request.today,
        )
        while (message := await sync_to_async(_chunk)(chunks)) is not None:
            yield message

    @grpc_action(
        request=IDS,
        request_name="TimelineCriticalPathRequest",
        response=[{"name": "task_ids", "cardinality": "repeated", "type": "string"}],
        response_name="TimelineCriticalPath",
    )
    @action
    async def CriticalPath(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)
        ids = await sync_to_async(timeline.critical_path)(user, workspace, request.project_id)
        return _pb().TimelineCriticalPath(task_ids=ids)

    @grpc_action(
        request=MOVE,
        request_name="TimelinePreviewRequest",
        response=[{"name": "shifts", "cardinality": "repeated", "type": TimelineShift}],
        response_name="TimelineShifts",
    )
    @action
    async def PreviewShift(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)

        def read() -> Any:
            shifts = timeline.preview_shift(
                user, workspace, request.project_id, request.task_id,
                request.start_date, request.due_date,
            )  # fmt: skip
            return _pb().TimelineShifts(
                shifts=[
                    _pb().TimelineShift(
                        task=_message(s.task),
                        new_start=_day(s.new.start),
                        new_due=_day(s.new.due),
                    )
                    for s in shifts
                ]
            )

        return await sync_to_async(read)()

    @grpc_action(
        request=[
            *MOVE,
            {"name": "expected_version", "type": "int32"},
            {"name": "affected_ids", "cardinality": "repeated", "type": "string"},
        ],
        request_name="TimelineApplyRequest",
        response=[{"name": "tasks", "cardinality": "repeated", "type": Task}],
        response_name="TimelineApplied",
    )
    @action
    async def ApplyShift(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)

        def write() -> Any:
            moved = timeline.apply_shift(
                user, workspace, request.project_id, request.task_id, request.expected_version,
                request.start_date, request.due_date, list(request.affected_ids),
            )  # fmt: skip
            return _pb().TimelineApplied(tasks=[_message(t) for t in moved])

        return await sync_to_async(write)()

    @grpc_action(
        request=[WORKSPACE],
        request_name="TimelineWorkingDaysGetRequest",
        response=WORKING,
        response_name="TimelineWorkingDays",
    )
    @action
    async def GetWorkingDays(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)
        days, holidays = await sync_to_async(timeline.get_working_days)(user, workspace)
        return _pb().TimelineWorkingDays(days=days, holidays=holidays)

    @grpc_action(
        request=[WORKSPACE, *WORKING],
        request_name="TimelineWorkingDaysSetRequest",
        response=WORKING,
        response_name="TimelineWorkingDays",
    )
    @action
    async def SetWorkingDays(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)
        days, holidays = await sync_to_async(timeline.set_working_days)(
            user, workspace, list(request.days), list(request.holidays)
        )
        return _pb().TimelineWorkingDays(days=days, holidays=holidays)


GRPC_SERVICES = [TimelineService]
