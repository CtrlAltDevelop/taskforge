"""Home and onboarding over gRPC: ``HomeController`` and ``OnboardingController``. The rules are
in ``infrastructure.home``.

``Home.Summary`` is the whole Home screen in one call (cached 30 s per viewer; ``today`` is the
viewer's date ``YYYY-MM-DD`` and ``utc_offset_minutes`` their zone, which fix "due today" and the
week). ``Home.MyWork`` lists tasks assigned to or watched by the viewer (``relation`` ``""``,
``assigned`` or ``watching``; ``filter_ast`` is a workspace-level TFQL AST; ``cursor`` is the
previous reply's). ``Home.RecordRecent`` notes a task the viewer opened; ``Home.PinDashboard`` pins
or unpins one. ``Onboarding.Get`` / ``CompleteStep`` / ``Dismiss`` answer the checklist,
``ApplyStarter`` makes a project from a starter (``software-team``, ``marketing``, ``bug-tracker``
or ``blank``) with sample tasks and ``DeleteSamples`` removes them. INVALID_ARGUMENT for a bad
request, NOT_FOUND for a task or dashboard the caller cannot open, PERMISSION_DENIED without
``project.create`` (ApplyStarter).
"""

import json
from typing import Any

from asgiref.sync import sync_to_async
from django_socio_grpc import generics
from django_socio_grpc.decorators import grpc_action

from infrastructure.common.grpc.errors import action, require_caller
from infrastructure.common.identity import grpc_caller
from infrastructure.home import mywork, onboarding, summary
from infrastructure.home.grpc.serializers import (
    HomeDay,
    HomeMention,
    HomePin,
    HomeTask,
    MyWorkTask,
    OnboardingStarter,
    OnboardingStep,
)
from infrastructure.workspaces.scoping import require_workspace

WS = {"name": "workspace_id", "type": "string"}
ONBOARDING = [
    {"name": "steps", "cardinality": "repeated", "type": OnboardingStep},
    {"name": "dismissed", "type": "bool"},
    {"name": "complete", "type": "bool"},
    {"name": "visible", "type": "bool"},
    {"name": "sample_project_id", "type": "string"},
    {"name": "sample_count", "type": "int32"},
    {"name": "starters", "cardinality": "repeated", "type": OnboardingStarter},
]


def _pb() -> Any:
    from infrastructure.home.grpc import home_pb2

    return home_pb2


def _task(item: summary.Item) -> Any:
    return _pb().HomeTask(**{k: getattr(item, k) for k in HomeTask().fields})


async def _scope(request: Any, context: Any) -> tuple[Any, Any]:
    user = require_caller(await grpc_caller(context))
    return user, await sync_to_async(require_workspace)(user, request.workspace_id)


def _summary(s: summary.Summary) -> Any:
    pb = _pb()
    return pb.HomeSummary(
        today_count=s.today_count,
        overdue_count=s.overdue_count,
        in_progress_count=s.in_progress_count,
        due_items=[_task(i) for i in s.due_items],
        in_progress_items=[_task(i) for i in s.in_progress_items],
        recent=[_task(i) for i in s.recent],
        mentions=[
            pb.HomeMention(
                id=m.id,
                type=m.type,
                task_id=m.task_id,
                actor_id=m.actor_id,
                created_at=m.created_at,
                read=m.read,
                payload_json=json.dumps(m.payload),
            )
            for m in s.mentions
        ],
        unread_notifications=s.unread_notifications,
        unread_chat=s.unread_chat,
        week=[pb.HomeDay(date=d.date, seconds=d.seconds) for d in s.week],
        pinned_dashboards=[
            pb.HomePin(dashboard_id=p.dashboard_id, name=p.name, project_id=p.project_id)
            for p in s.pinned_dashboards
        ],
        computed_at=s.computed_at,
    )


SUMMARY = [
    {"name": "today_count", "type": "int32"},
    {"name": "overdue_count", "type": "int32"},
    {"name": "in_progress_count", "type": "int32"},
    {"name": "due_items", "cardinality": "repeated", "type": HomeTask},
    {"name": "in_progress_items", "cardinality": "repeated", "type": HomeTask},
    {"name": "recent", "cardinality": "repeated", "type": HomeTask},
    {"name": "mentions", "cardinality": "repeated", "type": HomeMention},
    {"name": "unread_notifications", "type": "int32"},
    {"name": "unread_chat", "type": "int32"},
    {"name": "week", "cardinality": "repeated", "type": HomeDay},
    {"name": "pinned_dashboards", "cardinality": "repeated", "type": HomePin},
    {"name": "computed_at", "type": "string"},
]


class HomeService(generics.GenericService):
    @grpc_action(
        request=[
            WS,
            {"name": "today", "type": "string"},
            {"name": "utc_offset_minutes", "type": "int32"},
        ],
        request_name="HomeSummaryRequest",
        response=SUMMARY,
        response_name="HomeSummary",
    )
    @action
    async def Summary(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)

        def run() -> Any:
            day = summary.parse_day(request.today)
            offset = summary.clean_offset(request.utc_offset_minutes)
            return _summary(summary.summary(user, workspace, day, offset))

        return await sync_to_async(run)()

    @grpc_action(
        request=[
            WS,
            {"name": "relation", "type": "string"},
            {"name": "include_done", "type": "bool"},
            {"name": "filter_ast", "type": "string"},
            {"name": "today", "type": "string"},
            {"name": "cursor", "type": "string"},
            {"name": "limit", "type": "int32"},
        ],
        request_name="HomeMyWorkRequest",
        response=[
            {"name": "tasks", "cardinality": "repeated", "type": MyWorkTask},
            {"name": "next_cursor", "type": "string"},
        ],
        response_name="HomeMyWork",
    )
    @action
    async def MyWork(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)

        def run() -> Any:
            rows, cursor = mywork.my_work(
                user,
                workspace,
                relation=request.relation,
                include_done=request.include_done,
                filter_ast=request.filter_ast,
                today=request.today,
                cursor=request.cursor,
                limit=request.limit,
            )
            pb = _pb()
            return pb.HomeMyWork(
                tasks=[
                    pb.MyWorkTask(task=_task(item), assigned=assigned, watching=watching)
                    for item, assigned, watching in rows
                ],
                next_cursor=cursor,
            )

        return await sync_to_async(run)()

    @grpc_action(
        request=[WS, {"name": "task_id", "type": "string"}],
        request_name="HomeRecordRecentRequest",
        response=[],
        response_name="HomeRecorded",
    )
    @action
    async def RecordRecent(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)
        await sync_to_async(summary.record_recent)(user, workspace, request.task_id)
        return _pb().HomeRecorded()

    @grpc_action(
        request=[
            WS,
            {"name": "dashboard_id", "type": "string"},
            {"name": "pinned", "type": "bool"},
        ],
        request_name="HomePinDashboardRequest",
        response=[],
        response_name="HomePinned",
    )
    @action
    async def PinDashboard(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)
        await sync_to_async(summary.pin_dashboard)(
            user, workspace, request.dashboard_id, request.pinned
        )
        return _pb().HomePinned()


def _onboarding(state: onboarding.State) -> Any:
    pb = _pb()
    return pb.OnboardingState(
        steps=[pb.OnboardingStep(step=s, done=d) for s, d in state.steps],
        dismissed=state.dismissed,
        complete=state.complete,
        visible=state.visible,
        sample_project_id=state.sample_project_id,
        sample_count=state.sample_count,
        starters=[
            pb.OnboardingStarter(key=s.key, name=s.name, description=s.description)
            for s in onboarding.starters()
        ],
    )


class OnboardingService(generics.GenericService):
    @grpc_action(
        request=[WS],
        request_name="OnboardingGetRequest",
        response=ONBOARDING,
        response_name="OnboardingState",
    )
    @action
    async def Get(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)
        return _onboarding(await sync_to_async(onboarding.get)(user, workspace))

    @grpc_action(
        request=[WS, {"name": "step", "type": "string"}],
        request_name="OnboardingCompleteStepRequest",
        response=ONBOARDING,
        response_name="OnboardingState",
    )
    @action
    async def CompleteStep(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)
        state = await sync_to_async(onboarding.complete_step)(user, workspace, request.step)
        return _onboarding(state)

    @grpc_action(
        request=[WS],
        request_name="OnboardingDismissRequest",
        response=ONBOARDING,
        response_name="OnboardingState",
    )
    @action
    async def Dismiss(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)
        return _onboarding(await sync_to_async(onboarding.dismiss)(user, workspace))

    @grpc_action(
        request=[
            WS,
            {"name": "starter", "type": "string"},
            {"name": "name", "type": "string"},
            {"name": "key", "type": "string"},
        ],
        request_name="OnboardingApplyStarterRequest",
        response=[
            {"name": "project_id", "type": "string"},
            {"name": "task_count", "type": "int32"},
        ],
        response_name="OnboardingStarterApplied",
    )
    @action
    async def ApplyStarter(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)
        done = await sync_to_async(onboarding.apply_starter)(
            user, workspace, request.starter, request.name, request.key
        )
        return _pb().OnboardingStarterApplied(
            project_id=done.project_id, task_count=done.task_count
        )

    @grpc_action(
        request=[WS],
        request_name="OnboardingDeleteSamplesRequest",
        response=[{"name": "deleted", "type": "int32"}],
        response_name="OnboardingSamplesDeleted",
    )
    @action
    async def DeleteSamples(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)
        count = await sync_to_async(onboarding.delete_samples)(user, workspace)
        return _pb().OnboardingSamplesDeleted(deleted=count)


GRPC_SERVICES = [HomeService, OnboardingService]
