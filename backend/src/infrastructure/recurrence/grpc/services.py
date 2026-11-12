"""Repeat rules over gRPC: ``RecurrenceController``. Rules are in ``infrastructure.recurrence``.

``Get`` answers ``repeats = false`` for a task without a rule. ``Set`` makes a task repeat (or
replaces the rule of its series) and needs ``task.update``; ``Pause`` pauses and resumes;
``Clear`` stops the repeat and keeps every instance; ``UpdateFuture`` takes the task as the new
template and carries its title, description, priority and people to the open later instances
(editing "this task only" is the ordinary task update). ``Preview`` shows the sentence and the
next dates of a rule without saving it; ``Upcoming`` lists the dates still to be made in a range
for the calendar's ghost items. INVALID_ARGUMENT for a bad rule, NOT_FOUND for a task or project
the caller may not open, PERMISSION_DENIED without ``task.update`` for changes.
"""

from typing import Any

from asgiref.sync import sync_to_async
from django_socio_grpc import generics
from django_socio_grpc.decorators import grpc_action

from infrastructure.common.grpc.errors import action, require_caller
from infrastructure.common.identity import grpc_caller
from infrastructure.recurrence import services
from infrastructure.recurrence.grpc.serializers import Ghost, Series
from infrastructure.workspaces.scoping import require_workspace

WS = {"name": "workspace_id", "type": "string"}
TASK = [WS, {"name": "project_id", "type": "string"}, {"name": "task_id", "type": "string"}]
RULE = [
    {"name": "rrule", "type": "string"},
    {"name": "mode", "type": "string"},
    {"name": "timezone", "type": "string"},
    {"name": "skip_weekends", "type": "bool"},
    {"name": "ends_on", "type": "string"},
]


def _pb() -> Any:
    from infrastructure.recurrence.grpc import recurrence_pb2

    return recurrence_pb2


def _iso(value: Any) -> str:
    return value.isoformat() if value else ""


def series_message(view: services.View, task_id: str) -> Any:
    s = view.series
    return _pb().Series(
        id=str(s.pk),
        project_id=str(s.project_id),
        task_id=task_id,
        rrule=s.rrule,
        mode=s.mode,
        timezone=s.timezone,
        at_time=s.at_time.strftime("%H:%M"),
        lead_days=s.lead_days,
        starts_on=_iso(s.starts_on),
        ends_on=_iso(s.ends_on),
        skip_weekends=s.skip_weekends,
        paused=s.paused,
        pause_reason=s.pause_reason,
        summary=view.summary,
        next_due_on=_iso(s.next_due_on),
        next_run_at=_iso(s.next_run_at),
        next_dates=[d.isoformat() for d in view.next_dates],
        instance_count=view.instance_count,
        index=view.index,
        is_template=view.is_template,
        template_missing=s.template_task_id is None,
        owner_id=str(s.created_by_id),
        version=s.version,
    )


async def _scope(request: Any, context: Any) -> tuple[Any, Any]:
    user = require_caller(await grpc_caller(context))
    return user, await sync_to_async(require_workspace)(user, request.workspace_id)


class RecurrenceService(generics.GenericService):
    @grpc_action(
        request=TASK,
        request_name="RecurrenceGetRequest",
        response=[{"name": "repeats", "type": "bool"}, {"name": "series", "type": Series}],
        response_name="RecurrenceAnswer",
    )
    @action
    async def Get(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)

        def run() -> Any:
            view = services.get(user, workspace, request.project_id, request.task_id)
            if view is None:
                return _pb().RecurrenceAnswer(repeats=False)
            return _pb().RecurrenceAnswer(
                repeats=True, series=series_message(view, request.task_id)
            )

        return await sync_to_async(run)()

    @grpc_action(
        request=[
            *TASK,
            *RULE,
            {"name": "at_time", "type": "string"},
            {"name": "lead_days", "type": "int32"},
        ],
        request_name="RecurrenceSetRequest",
        response=[{"name": "series", "type": Series}],
        response_name="RecurrenceSeriesAnswer",
    )
    @action
    async def Set(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)

        def run() -> Any:
            view = services.set_rule(
                user,
                workspace,
                request.project_id,
                request.task_id,
                rrule=request.rrule,
                mode=request.mode,
                timezone_name=request.timezone,
                at_time=request.at_time or "09:00",
                lead_days=request.lead_days,
                ends_on=request.ends_on,
                skip_weekends=request.skip_weekends,
            )
            return _pb().RecurrenceSeriesAnswer(series=series_message(view, request.task_id))

        return await sync_to_async(run)()

    @grpc_action(
        request=TASK,
        request_name="RecurrenceClearRequest",
        response=[{"name": "task_id", "type": "string"}],
        response_name="RecurrenceCleared",
    )
    @action
    async def Clear(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)

        def run() -> Any:
            services.clear(user, workspace, request.project_id, request.task_id)
            return _pb().RecurrenceCleared(task_id=request.task_id)

        return await sync_to_async(run)()

    @grpc_action(
        request=[*TASK, {"name": "paused", "type": "bool"}],
        request_name="RecurrencePauseRequest",
        response=[{"name": "series", "type": Series}],
        response_name="RecurrenceSeriesAnswer",
    )
    @action
    async def Pause(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)

        def run() -> Any:
            view = services.pause(
                user, workspace, request.project_id, request.task_id, request.paused
            )
            return _pb().RecurrenceSeriesAnswer(series=series_message(view, request.task_id))

        return await sync_to_async(run)()

    @grpc_action(
        request=TASK,
        request_name="RecurrenceUpdateFutureRequest",
        response=[{"name": "series", "type": Series}, {"name": "changed", "type": "int32"}],
        response_name="RecurrenceFutureUpdated",
    )
    @action
    async def UpdateFuture(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)

        def run() -> Any:
            view, changed = services.update_future(
                user, workspace, request.project_id, request.task_id
            )
            return _pb().RecurrenceFutureUpdated(
                series=series_message(view, request.task_id), changed=changed
            )

        return await sync_to_async(run)()

    @grpc_action(
        request=[
            WS,
            *RULE,
            {"name": "starts_on", "type": "string"},
            {"name": "count", "type": "int32"},
            {"name": "after", "type": "string"},
        ],
        request_name="RecurrencePreviewRequest",
        response=[
            {"name": "summary", "type": "string"},
            {"name": "dates", "cardinality": "repeated", "type": "string"},
        ],
        response_name="RecurrencePreview",
    )
    @action
    async def Preview(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)

        def run() -> Any:
            shown = services.preview(
                user,
                workspace,
                rrule=request.rrule,
                mode=request.mode,
                starts_on=request.starts_on,
                after=request.after,
                count=request.count or services.NEXT_SHOWN,
                skip_weekends=request.skip_weekends,
                ends_on=request.ends_on,
                timezone_name=request.timezone,
            )
            return _pb().RecurrencePreview(
                summary=shown.summary, dates=[d.isoformat() for d in shown.dates]
            )

        return await sync_to_async(run)()

    @grpc_action(
        request=[
            WS,
            {"name": "project_id", "type": "string"},
            {"name": "start", "type": "string"},
            {"name": "end", "type": "string"},
        ],
        request_name="RecurrenceUpcomingRequest",
        response=[{"name": "ghosts", "cardinality": "repeated", "type": Ghost}],
        response_name="RecurrenceUpcoming",
    )
    @action
    async def Upcoming(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)

        def run() -> Any:
            found = services.upcoming(
                user, workspace, request.start, request.end, request.project_id
            )
            return _pb().RecurrenceUpcoming(
                ghosts=[
                    _pb().Ghost(
                        series_id=g.series_id,
                        project_id=g.project_id,
                        title=g.title,
                        due_date=g.due_date.isoformat(),
                    )
                    for g in found
                ]
            )

        return await sync_to_async(run)()


GRPC_SERVICES = [RecurrenceService]
