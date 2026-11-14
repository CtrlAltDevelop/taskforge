"""Workload over gRPC: ``CapacityController`` (Get, Set), ``TimeOffController`` (List, Create,
Update, Delete), ``HolidayController`` (List, Create, Update, Delete) and ``WorkloadController``
(Get, SetAssigneeEstimate). The rules are in ``infrastructure.workload.services``.

Reassigning a task or moving it in time is the existing ``Tasks.Update``. ``Workload.Get`` answers
for ``range_start``..``range_end`` (at most 400 days): a row per person with sparse day cells, the
tasks behind them, the open tasks that cannot be placed and the holidays in range. Without
``workload.view`` it only ever holds the caller's own row.
"""

from typing import Any

from asgiref.sync import sync_to_async
from django_socio_grpc import generics
from django_socio_grpc.decorators import grpc_action

from infrastructure.common.grpc.errors import action, require_caller
from infrastructure.common.identity import grpc_caller
from infrastructure.workload import services
from infrastructure.workload.grpc.serializers import (
    Capacity,
    Holiday,
    LoadTask,
    PersonLoad,
    TimeOff,
)
from infrastructure.workspaces.scoping import require_workspace

WS = [{"name": "workspace_id", "type": "string"}]
RANGE = [{"name": "range_start", "type": "string"}, {"name": "range_end", "type": "string"}]
OFF_FIELDS = [
    {"name": "start_date", "type": "string"},
    {"name": "end_date", "type": "string"},
    {"name": "kind", "type": "string"},
    {"name": "note", "type": "string"},
]


def _pb() -> Any:
    from infrastructure.workload.grpc import workload_pb2

    return workload_pb2


def _iso(value: Any) -> str:
    return value.isoformat()


def capacity_message(view: services.CapacityView) -> Any:
    return _pb().Capacity(
        user_id=view.user_id,
        hours_per_day=format(view.hours_per_day.normalize(), "f"),
        working_days=view.working_days,
        is_set=view.is_set,
    )


def time_off_message(row: Any) -> Any:
    return _pb().TimeOff(
        id=str(row.pk),
        user_id=str(row.user_id),
        start_date=_iso(row.start_date),
        end_date=_iso(row.end_date),
        kind=row.kind,
        note=row.note,
    )


def holiday_message(row: Any) -> Any:
    return _pb().Holiday(id=str(row.pk), date=_iso(row.date), name=row.name)


def person_message(p: services.PersonLoad) -> Any:
    pb = _pb()
    return pb.PersonLoad(
        user_id=p.user_id,
        capacity=capacity_message(p.capacity),
        time_off=[
            pb.OffRange(start_date=_iso(o.start), end_date=_iso(o.end), kind=o.kind)
            for o in p.time_off
        ],
        days=[
            pb.DayCell(
                date=_iso(d.day),
                load_sec=d.load_sec,
                capacity_sec=d.capacity_sec,
                over=d.over,
                contributions=[
                    pb.Contribution(task_id=c.task_id, seconds=c.seconds, warning=c.warning)
                    for c in d.contributions
                ],
            )
            for d in p.days
        ],
        total_load_sec=p.total_load_sec,
    )


def task_message(t: services.TaskRow) -> Any:
    return _pb().LoadTask(
        task_id=t.task_id,
        project_id=t.project_id,
        display_id=t.display_id,
        title=t.title,
        version=t.version,
        start_date=t.start_date,
        due_date=t.due_date,
        estimate_sec=t.estimate_sec,
        assignee_ids=t.assignee_ids,
        own=[_pb().AssigneeSeconds(user_id=u, seconds=s) for u, s in t.own_sec.items()],
        reason=t.reason,
    )


async def _scope(request: Any, context: Any) -> tuple[Any, Any]:
    user = require_caller(await grpc_caller(context))
    return user, await sync_to_async(require_workspace)(user, request.workspace_id)


class CapacityService(generics.GenericService):
    @grpc_action(
        request=[*WS, {"name": "user_id", "type": "string"}],
        request_name="CapacityGetRequest",
        response=[{"name": "capacities", "cardinality": "repeated", "type": Capacity}],
        response_name="CapacityList",
    )
    @action
    async def Get(self, request: Any, context: Any) -> Any:
        """One person's capacity, or everybody's when ``user_id`` is empty (needs
        ``workload.view``; without it only the caller's own comes back)."""
        user, workspace = await _scope(request, context)

        def run() -> Any:
            rows = services.get_capacity(user, workspace, request.user_id)
            return _pb().CapacityList(capacities=[capacity_message(r) for r in rows])

        return await sync_to_async(run)()

    @grpc_action(
        request=[
            *WS,
            {"name": "user_id", "type": "string"},
            {"name": "hours_per_day", "type": "string"},
            {"name": "working_days", "cardinality": "repeated", "type": "int32"},
        ],
        request_name="CapacitySetRequest",
        response=[{"name": "capacity", "type": Capacity}],
        response_name="CapacityAnswer",
    )
    @action
    async def Set(self, request: Any, context: Any) -> Any:
        """Needs ``workload.manage``."""
        user, workspace = await _scope(request, context)

        def run() -> Any:
            view = services.set_capacity(
                user, workspace, request.user_id, request.hours_per_day, list(request.working_days)
            )
            return _pb().CapacityAnswer(capacity=capacity_message(view))

        return await sync_to_async(run)()


class TimeOffService(generics.GenericService):
    @grpc_action(
        request=[*WS, {"name": "user_id", "type": "string"}, *RANGE],
        request_name="TimeOffListRequest",
        response=[{"name": "entries", "cardinality": "repeated", "type": TimeOff}],
        response_name="TimeOffList",
    )
    @action
    async def List(self, request: Any, context: Any) -> Any:
        """Time off overlapping the (optional) range; everybody's needs ``workload.view``."""
        user, workspace = await _scope(request, context)

        def run() -> Any:
            rows = services.list_time_off(
                user, workspace, request.user_id, request.range_start, request.range_end
            )
            return _pb().TimeOffList(entries=[time_off_message(r) for r in rows])

        return await sync_to_async(run)()

    @grpc_action(
        request=[*WS, {"name": "user_id", "type": "string"}, *OFF_FIELDS],
        request_name="TimeOffCreateRequest",
        response=[{"name": "entry", "type": TimeOff}],
        response_name="TimeOffAnswer",
    )
    @action
    async def Create(self, request: Any, context: Any) -> Any:
        """Empty ``user_id`` is the caller; for anyone else it needs ``workload.manage``."""
        user, workspace = await _scope(request, context)

        def run() -> Any:
            row = services.create_time_off(
                user,
                workspace,
                request.user_id,
                request.start_date,
                request.end_date,
                request.kind,
                request.note,
            )
            return _pb().TimeOffAnswer(entry=time_off_message(row))

        return await sync_to_async(run)()

    @grpc_action(
        request=[*WS, {"name": "time_off_id", "type": "string"}, *OFF_FIELDS],
        request_name="TimeOffUpdateRequest",
        response=[{"name": "entry", "type": TimeOff}],
        response_name="TimeOffAnswer",
    )
    @action
    async def Update(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)

        def run() -> Any:
            row = services.update_time_off(
                user,
                workspace,
                request.time_off_id,
                request.start_date,
                request.end_date,
                request.kind,
                request.note,
            )
            return _pb().TimeOffAnswer(entry=time_off_message(row))

        return await sync_to_async(run)()

    @grpc_action(
        request=[*WS, {"name": "time_off_id", "type": "string"}],
        request_name="TimeOffDeleteRequest",
        response=[{"name": "id", "type": "string"}],
        response_name="TimeOffDeleted",
    )
    @action
    async def Delete(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)

        def run() -> Any:
            services.delete_time_off(user, workspace, request.time_off_id)
            return _pb().TimeOffDeleted(id=request.time_off_id)

        return await sync_to_async(run)()


class HolidayService(generics.GenericService):
    @grpc_action(
        request=[*WS, *RANGE],
        request_name="HolidayListRequest",
        response=[{"name": "holidays", "cardinality": "repeated", "type": Holiday}],
        response_name="HolidayList",
    )
    @action
    async def List(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)

        def run() -> Any:
            rows = services.list_holidays(user, workspace, request.range_start, request.range_end)
            return _pb().HolidayList(holidays=[holiday_message(r) for r in rows])

        return await sync_to_async(run)()

    @grpc_action(
        request=[*WS, {"name": "date", "type": "string"}, {"name": "name", "type": "string"}],
        request_name="HolidayCreateRequest",
        response=[{"name": "holiday", "type": Holiday}],
        response_name="HolidayAnswer",
    )
    @action
    async def Create(self, request: Any, context: Any) -> Any:
        """Needs ``workload.manage``. One holiday per day (a second is ALREADY_EXISTS)."""
        user, workspace = await _scope(request, context)

        def run() -> Any:
            row = services.create_holiday(user, workspace, request.date, request.name)
            return _pb().HolidayAnswer(holiday=holiday_message(row))

        return await sync_to_async(run)()

    @grpc_action(
        request=[
            *WS,
            {"name": "holiday_id", "type": "string"},
            {"name": "date", "type": "string"},
            {"name": "name", "type": "string"},
        ],
        request_name="HolidayUpdateRequest",
        response=[{"name": "holiday", "type": Holiday}],
        response_name="HolidayAnswer",
    )
    @action
    async def Update(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)

        def run() -> Any:
            row = services.update_holiday(
                user, workspace, request.holiday_id, request.date, request.name
            )
            return _pb().HolidayAnswer(holiday=holiday_message(row))

        return await sync_to_async(run)()

    @grpc_action(
        request=[*WS, {"name": "holiday_id", "type": "string"}],
        request_name="HolidayDeleteRequest",
        response=[{"name": "id", "type": "string"}],
        response_name="HolidayDeleted",
    )
    @action
    async def Delete(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)

        def run() -> Any:
            services.delete_holiday(user, workspace, request.holiday_id)
            return _pb().HolidayDeleted(id=request.holiday_id)

        return await sync_to_async(run)()


class WorkloadService(generics.GenericService):
    @grpc_action(
        request=[
            *WS,
            *RANGE,
            {"name": "project_ids", "cardinality": "repeated", "type": "string"},
            {"name": "user_ids", "cardinality": "repeated", "type": "string"},
        ],
        request_name="WorkloadGetRequest",
        response=[
            {"name": "range_start", "type": "string"},
            {"name": "range_end", "type": "string"},
            {"name": "can_see_all", "type": "bool"},
            {"name": "people", "cardinality": "repeated", "type": PersonLoad},
            {"name": "tasks", "cardinality": "repeated", "type": LoadTask},
            {"name": "unestimated", "cardinality": "repeated", "type": LoadTask},
            {"name": "holidays", "cardinality": "repeated", "type": "string"},
            {"name": "truncated", "type": "bool"},
        ],
        response_name="WorkloadAnswer",
    )
    @action
    async def Get(self, request: Any, context: Any) -> Any:
        """Filter by ``project_ids`` and/or ``user_ids`` (a "team" is a chosen set of people)."""
        user, workspace = await _scope(request, context)

        def run() -> Any:
            w = services.compute(
                user,
                workspace,
                request.range_start,
                request.range_end,
                list(request.project_ids),
                list(request.user_ids),
            )
            return _pb().WorkloadAnswer(
                range_start=_iso(w.range_start),
                range_end=_iso(w.range_end),
                can_see_all=w.can_see_all,
                people=[person_message(p) for p in w.people],
                tasks=[task_message(t) for t in w.tasks],
                unestimated=[task_message(t) for t in w.unestimated],
                holidays=[_iso(d) for d in w.holidays],
                truncated=w.truncated,
            )

        return await sync_to_async(run)()

    @grpc_action(
        request=[
            *WS,
            {"name": "task_id", "type": "string"},
            {"name": "user_id", "type": "string"},
            {"name": "estimate_sec", "type": "int32"},
        ],
        request_name="AssigneeEstimateRequest",
        response=[{"name": "task_id", "type": "string"}],
        response_name="AssigneeEstimateAnswer",
    )
    @action
    async def SetAssigneeEstimate(self, request: Any, context: Any) -> Any:
        """One assignee's own estimate (0 removes it); needs ``task.update``."""
        user, workspace = await _scope(request, context)

        def run() -> Any:
            services.set_assignee_estimate(
                user, workspace, request.task_id, request.user_id, request.estimate_sec
            )
            return _pb().AssigneeEstimateAnswer(task_id=request.task_id)

        return await sync_to_async(run)()


GRPC_SERVICES = [CapacityService, TimeOffService, HolidayService, WorkloadService]
