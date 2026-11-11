"""Sprints over gRPC: ``SprintController`` and ``BacklogController``. Rules are in
``infrastructure.sprints``.

``List`` (optionally only some ``states``), ``Create``, ``Update`` (``fields`` names what to
change, as in the time controller), ``Start``, ``Complete`` (``carry_over`` is ``next`` or
``backlog``; ``next_sprint_id`` picks the planned sprint, else the earliest), ``AddTasks`` /
``RemoveTasks``, ``Tasks`` (a sprint's tasks), ``SetPoints`` (empty clears) and ``Burndown``.
``Backlog.List`` gives the open tasks in no sprint. ``warnings`` carry soft problems (overlapping
dates). INVALID_ARGUMENT for a bad value, a project with Sprints off, or a wrong state;
ALREADY_EXISTS when a second sprint is started.
"""

from datetime import datetime
from typing import Any

from asgiref.sync import sync_to_async
from django.utils import timezone
from django_socio_grpc import generics
from django_socio_grpc.decorators import grpc_action

from infrastructure.common.errors import ApiError
from infrastructure.common.grpc.errors import action, require_caller
from infrastructure.common.identity import grpc_caller
from infrastructure.sprints import burndown, services, tally
from infrastructure.sprints.grpc.serializers import (
    BurndownDay,
    ScopeChange,
    Sprint,
    SprintTask,
    VelocityItem,
)
from infrastructure.workspaces.scoping import require_workspace

WS = {"name": "workspace_id", "type": "string"}
PROJECT = [WS, {"name": "project_id", "type": "string"}]
SPRINT = [*PROJECT, {"name": "sprint_id", "type": "string"}]
WARNINGS = {"name": "warnings", "cardinality": "repeated", "type": "string"}
ANSWER = [{"name": "sprint", "type": Sprint}, WARNINGS]
CHANGED = [
    {"name": "sprint", "type": Sprint},
    {"name": "changed", "type": "int32"},
    {"name": "added_after_start", "type": "int32"},
]
TASK_IDS = {"name": "task_ids", "cardinality": "repeated", "type": "string"}
FIELDS = [
    {"name": "name", "type": "string"},
    {"name": "goal", "type": "string"},
    {"name": "start_date", "type": "string"},
    {"name": "end_date", "type": "string"},
    {"name": "capacity_points", "type": "string"},
    {"name": "capacity_sec", "type": "int32"},
]


def _pb() -> Any:
    from infrastructure.sprints.grpc import sprints_pb2

    return sprints_pb2


def iso(value: datetime | None) -> str:
    return value.isoformat() if value else ""


def num(value: Any) -> float:
    return float(value)


def sprint_message(sprint: Any, counts: tally.Tally | None = None) -> Any:
    c = counts or tally.tally(sprint)
    return _pb().Sprint(
        id=str(sprint.pk),
        workspace_id=str(sprint.workspace_id),
        project_id=str(sprint.project_id),
        name=sprint.name,
        goal=sprint.goal,
        start_date=sprint.start_date.isoformat(),
        end_date=sprint.end_date.isoformat(),
        state=sprint.state,
        started_at=iso(sprint.started_at),
        completed_at=iso(sprint.completed_at),
        baseline_points=num(sprint.baseline_points),
        baseline_tasks=sprint.baseline_tasks,
        completed_points=num(sprint.completed_points),
        completed_tasks=sprint.completed_tasks,
        unfinished_tasks=sprint.unfinished_tasks,
        version=sprint.version,
        task_count=c.tasks,
        points_total=num(c.points),
        open_tasks=c.open_tasks,
        open_points=num(c.open_points),
        done_tasks=c.done_tasks,
        done_points=num(c.done_points),
        estimate_sec_total=c.estimate_sec,
        capacity_points=num(sprint.capacity_points or 0),
        has_capacity_points=sprint.capacity_points is not None,
        capacity_sec=sprint.capacity_sec or 0,
        has_capacity_sec=sprint.capacity_sec is not None,
    )


def task_message(task: Any, late: bool = False) -> Any:
    return _pb().SprintTask(
        id=str(task.pk),
        project_id=str(task.project_id),
        key=f"{task.project.key}-{task.number}",
        title=task.title,
        status_id=str(task.status_id),
        status_name=task.status.name,
        status_category=task.status.category,
        priority=task.priority,
        points=num(task.points or 0),
        has_points=task.points is not None,
        estimate_sec=task.estimate_sec or 0,
        sprint_id=str(task.sprint_id or ""),
        version=task.version,
        position=task.position,
        late=late,
    )


async def _scope(request: Any, context: Any) -> tuple[Any, Any]:
    user = require_caller(await grpc_caller(context))
    return user, await sync_to_async(require_workspace)(user, request.workspace_id)


def _answer(out: services.Outcome) -> Any:
    return _pb().SprintAnswer(sprint=sprint_message(out.sprint), warnings=list(out.warnings))


def _changed(moved: services.Moved) -> Any:
    return _pb().SprintTasksChanged(
        sprint=sprint_message(moved.sprint), changed=moved.changed, added_after_start=moved.late
    )


def burndown_message(b: burndown.Burndown) -> Any:
    pb = _pb()
    return pb.BurndownAnswer(
        sprint=sprint_message(b.sprint),
        baseline_points=num(b.baseline_points),
        baseline_tasks=b.baseline_tasks,
        days=[
            pb.BurndownDay(
                date=d.date.isoformat(),
                ideal_points=num(d.ideal_points),
                ideal_tasks=num(d.ideal_tasks),
                has_actual=d.has_actual,
                live=d.live,
                backfilled=d.backfilled,
                remaining_points=num(d.remaining_points),
                remaining_tasks=d.remaining_tasks,
                scope_points=num(d.scope_points),
                scope_tasks=d.scope_tasks,
            )
            for d in b.days
        ],
        scope_changes=[
            pb.ScopeChange(date=s.date.isoformat(), points=num(s.points), tasks=s.tasks)
            for s in b.steps
        ],
        velocity=[
            pb.VelocityItem(
                sprint_id=str(v.sprint.pk),
                name=v.sprint.name,
                start_date=v.sprint.start_date.isoformat(),
                end_date=v.sprint.end_date.isoformat(),
                committed_points=num(v.committed_points),
                completed_points=num(v.completed_points),
                committed_tasks=v.sprint.baseline_tasks,
                completed_tasks=v.sprint.completed_tasks,
            )
            for v in b.velocity
        ],
        average_velocity=num(b.average_velocity),
        server_now=iso(timezone.now()),
    )


class SprintService(generics.GenericService):
    @grpc_action(
        request=[*PROJECT, {"name": "states", "cardinality": "repeated", "type": "string"}],
        request_name="SprintListRequest",
        response=[{"name": "sprints", "cardinality": "repeated", "type": Sprint}],
        response_name="SprintList",
    )
    @action
    async def List(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)

        def run() -> Any:
            rows = services.list_sprints(user, workspace, request.project_id, request.states)
            return _pb().SprintList(sprints=[sprint_message(r.sprint, r.counts) for r in rows])

        return await sync_to_async(run)()

    @grpc_action(
        request=[*PROJECT, *FIELDS],
        request_name="SprintCreateRequest",
        response=ANSWER,
        response_name="SprintAnswer",
    )
    @action
    async def Create(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)

        def run() -> Any:
            return _answer(
                services.create(
                    user,
                    workspace,
                    request.project_id,
                    request.name,
                    request.goal,
                    request.start_date,
                    request.end_date,
                    request.capacity_points,
                    request.capacity_sec,
                )
            )

        return await sync_to_async(run)()

    @grpc_action(
        request=[
            *SPRINT,
            {"name": "fields", "cardinality": "repeated", "type": "string"},
            {"name": "expected_version", "type": "int32"},
            *FIELDS,
        ],
        request_name="SprintUpdateRequest",
        response=ANSWER,
        response_name="SprintAnswer",
    )
    @action
    async def Update(self, request: Any, context: Any) -> Any:
        """``fields`` names what to change (any of name, goal, start_date, end_date,
        capacity_points, capacity_sec; an empty capacity clears it)."""
        user, workspace = await _scope(request, context)

        def run() -> Any:
            changes: dict[str, str] = {}
            for name in request.fields:
                if name not in services.EDITABLE:
                    raise ApiError(f"Cannot change {name}.", status=400)
                value = getattr(request, name)
                changes[name] = (str(value) if value else "") if name == "capacity_sec" else value
            return _answer(
                services.update(
                    user,
                    workspace,
                    request.project_id,
                    request.sprint_id,
                    changes,
                    request.expected_version,
                )
            )

        return await sync_to_async(run)()

    @grpc_action(
        request=SPRINT,
        request_name="SprintStartRequest",
        response=ANSWER,
        response_name="SprintAnswer",
    )
    @action
    async def Start(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)

        def run() -> Any:
            return _answer(services.start(user, workspace, request.project_id, request.sprint_id))

        return await sync_to_async(run)()

    @grpc_action(
        request=[
            *SPRINT,
            {"name": "carry_over", "type": "string"},
            {"name": "next_sprint_id", "type": "string"},
        ],
        request_name="SprintCompleteRequest",
        response=ANSWER,
        response_name="SprintAnswer",
    )
    @action
    async def Complete(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)

        def run() -> Any:
            return _answer(
                services.complete(
                    user,
                    workspace,
                    request.project_id,
                    request.sprint_id,
                    request.carry_over,
                    request.next_sprint_id,
                )
            )

        return await sync_to_async(run)()

    @grpc_action(
        request=[*SPRINT, TASK_IDS],
        request_name="SprintTasksChangeRequest",
        response=CHANGED,
        response_name="SprintTasksChanged",
    )
    @action
    async def AddTasks(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)

        def run() -> Any:
            return _changed(
                services.add_tasks(
                    user,
                    workspace,
                    request.project_id,
                    request.sprint_id,
                    list(request.task_ids),
                )
            )

        return await sync_to_async(run)()

    @grpc_action(
        request=[*SPRINT, TASK_IDS],
        request_name="SprintTasksChangeRequest",
        response=CHANGED,
        response_name="SprintTasksChanged",
    )
    @action
    async def RemoveTasks(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)

        def run() -> Any:
            return _changed(
                services.remove_tasks(
                    user,
                    workspace,
                    request.project_id,
                    request.sprint_id,
                    list(request.task_ids),
                )
            )

        return await sync_to_async(run)()

    @grpc_action(
        request=SPRINT,
        request_name="SprintTasksRequest",
        response=[{"name": "tasks", "cardinality": "repeated", "type": SprintTask}],
        response_name="SprintTaskList",
    )
    @action
    async def Tasks(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)

        def run() -> Any:
            rows = services.sprint_tasks(user, workspace, request.project_id, request.sprint_id)
            return _pb().SprintTaskList(tasks=[task_message(r.task, r.late) for r in rows])

        return await sync_to_async(run)()

    @grpc_action(
        request=[
            *PROJECT,
            {"name": "task_id", "type": "string"},
            {"name": "points", "type": "string"},
            {"name": "expected_version", "type": "int32"},
        ],
        request_name="PointsSetRequest",
        response=SprintTask,
        response_name="SprintTask",
    )
    @action
    async def SetPoints(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)

        def run() -> Any:
            task = services.set_points(
                user,
                workspace,
                request.project_id,
                request.task_id,
                request.points,
                request.expected_version,
            )
            return task_message(task)

        return await sync_to_async(run)()

    @grpc_action(
        request=SPRINT,
        request_name="BurndownRequest",
        response=[
            {"name": "sprint", "type": Sprint},
            {"name": "baseline_points", "type": "double"},
            {"name": "baseline_tasks", "type": "int32"},
            {"name": "days", "cardinality": "repeated", "type": BurndownDay},
            {"name": "scope_changes", "cardinality": "repeated", "type": ScopeChange},
            {"name": "velocity", "cardinality": "repeated", "type": VelocityItem},
            {"name": "average_velocity", "type": "double"},
            {"name": "server_now", "type": "string"},
        ],
        response_name="BurndownAnswer",
    )
    @action
    async def Burndown(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)

        def run() -> Any:
            built = burndown.burndown(user, workspace, request.project_id, request.sprint_id)
            return burndown_message(built)

        return await sync_to_async(run)()


class BacklogService(generics.GenericService):
    @grpc_action(
        request=[*PROJECT, {"name": "limit", "type": "int32"}],
        request_name="BacklogListRequest",
        response=[
            {"name": "tasks", "cardinality": "repeated", "type": SprintTask},
            {"name": "total", "type": "int32"},
        ],
        response_name="BacklogList",
    )
    @action
    async def List(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)

        def run() -> Any:
            rows, total = services.backlog(user, workspace, request.project_id, request.limit)
            return _pb().BacklogList(tasks=[task_message(t) for t in rows], total=total)

        return await sync_to_async(run)()


GRPC_SERVICES = [SprintService, BacklogService]
