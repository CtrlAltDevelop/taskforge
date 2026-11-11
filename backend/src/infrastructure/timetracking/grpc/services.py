"""Time tracking over gRPC: ``TimeController``. Rules are in ``infrastructure.timetracking``.

``Start`` runs a timer on a task (stopping the caller's other one, which comes back as
``stopped``); ``Stop`` and ``Current`` act on the caller's timer in the workspace and
``server_now`` is the clock every elapsed time is measured against. ``CreateEntry``/``UpdateEntry``/
``DeleteEntry`` manage entries (somebody else's need ``time.edit_others``); ``Entries`` lists a
task's, ``Summary`` gives its estimate and totals, ``SetEstimate`` changes the estimate (0 clears).
``Timesheet`` is seven days from ``week_start`` in ``timezone``; ``Totals`` is per person for a
project. INVALID_ARGUMENT for a bad value, a project with time tracking off, or no running timer.
"""

from datetime import datetime
from typing import Any

from asgiref.sync import sync_to_async
from django.utils import timezone
from django_socio_grpc import generics
from django_socio_grpc.decorators import grpc_action

from infrastructure.comments.mentions import display_name
from infrastructure.common.errors import ApiError
from infrastructure.common.grpc.errors import action, require_caller
from infrastructure.common.identity import grpc_caller
from infrastructure.timetracking import reports, services
from infrastructure.timetracking.grpc.serializers import Entry, PersonTotal, SheetRow
from infrastructure.timetracking.models import TimeEntry
from infrastructure.workspaces import access
from infrastructure.workspaces.scoping import require_workspace

WS = {"name": "workspace_id", "type": "string"}
TASK = [
    WS,
    {"name": "project_id", "type": "string"},
    {"name": "task_id", "type": "string"},
]


def _pb() -> Any:
    from infrastructure.timetracking.grpc import timetracking_pb2

    return timetracking_pb2


def iso(value: Any) -> str:
    return value.isoformat() if value else ""


def parse_time(raw: str, name: str) -> datetime:
    try:
        value = datetime.fromisoformat(raw)
    except ValueError:
        raise ApiError(f"{name} must be an ISO 8601 time with an offset.", status=400) from None
    if value.tzinfo is None:
        raise ApiError(f"{name} must include an offset (for example +00:00).", status=400)
    return value


def entry_message(row: services.Row) -> Any:
    e, t = row.entry, row.task
    return _pb().Entry(
        id=str(e.pk),
        workspace_id=str(e.workspace_id),
        task_id=str(e.task_id),
        project_id=str(t.project_id),
        key=f"{t.project.key}-{t.number}",
        title=t.title,
        user_id=str(e.user_id),
        user_name=display_name(e.user),
        started_at=iso(e.started_at),
        ended_at=iso(e.ended_at),
        duration_sec=row.seconds,
        note=e.note,
        billable=e.billable,
        source=e.source,
        flags=list(row.flags),
    )


def one(entry: TimeEntry) -> Any:
    """The message for a single entry whose task, project and user are loaded."""
    return entry_message(services.rows_of([entry], timezone.now())[0])


async def _scope(request: Any, context: Any) -> tuple[Any, Any]:
    user = require_caller(await grpc_caller(context))
    return user, await sync_to_async(require_workspace)(user, request.workspace_id)


ENTRY_FIELDS = [
    {"name": "started_at", "type": "string"},
    {"name": "duration_sec", "type": "int32"},
    {"name": "note", "type": "string"},
    {"name": "billable", "type": "bool"},
]


class TimeService(generics.GenericService):
    @grpc_action(
        request=[*TASK, {"name": "note", "type": "string"}],
        request_name="TimeStartRequest",
        response=[
            {"name": "entry", "type": Entry},
            {"name": "stopped", "type": Entry},
            {"name": "server_now", "type": "string"},
        ],
        response_name="TimerStarted",
    )
    @action
    async def Start(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)

        def run() -> Any:
            started = services.start(
                user, workspace, request.project_id, request.task_id, request.note
            )
            return _pb().TimerStarted(
                entry=one(started.entry),
                # Another workspace's timer is stopped too, but nothing of it is sent here.
                stopped=(
                    one(started.stopped)
                    if started.stopped and started.stopped.workspace_id == workspace.pk
                    else None
                ),
                server_now=iso(timezone.now()),
            )

        return await sync_to_async(run)()

    @grpc_action(
        request=[WS],
        request_name="TimeStopRequest",
        response=[
            {"name": "entry", "type": Entry},
            {"name": "server_now", "type": "string"},
        ],
        response_name="TimerStopped",
    )
    @action
    async def Stop(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)

        def run() -> Any:
            stopped = services.stop(user, workspace)
            return _pb().TimerStopped(entry=one(stopped), server_now=iso(timezone.now()))

        return await sync_to_async(run)()

    @grpc_action(
        request=[WS],
        request_name="TimeCurrentRequest",
        response=[
            {"name": "running", "type": "bool"},
            {"name": "entry", "type": Entry},
            {"name": "server_now", "type": "string"},
        ],
        response_name="TimerState",
    )
    @action
    async def Current(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)

        def run() -> Any:
            found = services.current(user, workspace)
            return _pb().TimerState(
                running=found is not None,
                entry=one(found) if found else None,
                server_now=iso(timezone.now()),
            )

        return await sync_to_async(run)()

    @grpc_action(
        request=[*TASK, *ENTRY_FIELDS, {"name": "for_user_id", "type": "string"}],
        request_name="EntryCreateRequest",
        response=Entry,
        response_name="Entry",
    )
    @action
    async def CreateEntry(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)

        def run() -> Any:
            who = None
            if request.for_user_id and request.for_user_id != str(user.pk):
                access.require(user, services.OTHERS, workspace)
                who = reports._member(workspace, request.for_user_id)
            made = services.create_entry(
                user,
                workspace,
                request.project_id,
                request.task_id,
                parse_time(request.started_at, "started_at"),
                request.duration_sec,
                request.note,
                request.billable,
                for_user=who,
            )
            return one(made)

        return await sync_to_async(run)()

    @grpc_action(
        request=[
            WS,
            {"name": "id", "type": "string"},
            {"name": "fields", "cardinality": "repeated", "type": "string"},
            *ENTRY_FIELDS,
        ],
        request_name="EntryUpdateRequest",
        response=Entry,
        response_name="Entry",
    )
    @action
    async def UpdateEntry(self, request: Any, context: Any) -> Any:
        """``fields`` names what to change (any of started_at, duration_sec, note, billable): an
        unset value and a cleared one look alike on the wire."""
        user, workspace = await _scope(request, context)

        def run() -> Any:
            changes: dict[str, Any] = {}
            for name in request.fields:
                if name == "started_at":
                    changes[name] = parse_time(request.started_at, "started_at")
                elif name in ("duration_sec", "note", "billable"):
                    changes[name] = getattr(request, name)
                else:
                    raise ApiError(f"Cannot change {name}.", status=400)
            changed = services.update_entry(user, workspace, request.id, changes)
            return one(changed)

        return await sync_to_async(run)()

    @grpc_action(
        request=[WS, {"name": "id", "type": "string"}],
        request_name="EntryDeleteRequest",
        response=[{"name": "ok", "type": "bool"}],
        response_name="EntryDeleted",
    )
    @action
    async def DeleteEntry(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)
        await sync_to_async(services.delete_entry)(user, workspace, request.id)
        return _pb().EntryDeleted(ok=True)

    @grpc_action(
        request=TASK,
        request_name="EntriesRequest",
        response=[{"name": "entries", "cardinality": "repeated", "type": Entry}],
        response_name="EntryList",
    )
    @action
    async def Entries(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)

        def run() -> Any:
            rows = services.entries_for_task(user, workspace, request.project_id, request.task_id)
            return _pb().EntryList(entries=[entry_message(r) for r in rows])

        return await sync_to_async(run)()

    @grpc_action(
        request=TASK,
        request_name="TimeSummaryRequest",
        response=[
            {"name": "estimate_sec", "type": "int32"},
            {"name": "logged_sec", "type": "int32"},
            {"name": "billable_sec", "type": "int32"},
            {"name": "running", "type": "bool"},
        ],
        response_name="TimeSummary",
    )
    @action
    async def Summary(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)

        def run() -> Any:
            s = services.summary(user, workspace, request.project_id, request.task_id)
            return _pb().TimeSummary(
                estimate_sec=s.estimate_sec,
                logged_sec=s.logged_sec,
                billable_sec=s.billable_sec,
                running=s.running,
            )

        return await sync_to_async(run)()

    @grpc_action(
        request=[
            *TASK,
            {"name": "estimate_sec", "type": "int32"},
            {"name": "expected_version", "type": "int32"},
        ],
        request_name="EstimateSetRequest",
        response=[{"name": "estimate_sec", "type": "int32"}],
        response_name="EstimateSet",
    )
    @action
    async def SetEstimate(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)

        def run() -> Any:
            task = services.set_estimate(
                user,
                workspace,
                request.project_id,
                request.task_id,
                request.estimate_sec,
                request.expected_version,
            )
            return _pb().EstimateSet(estimate_sec=task.estimate_sec or 0)

        return await sync_to_async(run)()

    @grpc_action(
        request=[
            WS,
            {"name": "week_start", "type": "string"},
            {"name": "timezone", "type": "string"},
            {"name": "user_id", "type": "string"},
            {"name": "utc_offset_minutes", "type": "int32"},
        ],
        request_name="TimesheetRequest",
        response=[
            {"name": "user_id", "type": "string"},
            {"name": "week_start", "type": "string"},
            {"name": "rows", "cardinality": "repeated", "type": SheetRow},
            {"name": "day_totals", "cardinality": "repeated", "type": "int32"},
            {"name": "total", "type": "int32"},
        ],
        response_name="TimesheetAnswer",
    )
    @action
    async def Timesheet(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)

        def run() -> Any:
            sheet = reports.timesheet(
                user,
                workspace,
                request.week_start,
                request.timezone,
                request.user_id,
                request.utc_offset_minutes,
            )
            return _pb().TimesheetAnswer(
                user_id=sheet.user_id,
                week_start=sheet.week_start.isoformat(),
                rows=[
                    _pb().SheetRow(
                        task_id=r.task_id,
                        project_id=r.project_id,
                        key=r.key,
                        title=r.title,
                        seconds=r.seconds,
                        total=r.total,
                        billable=r.billable,
                    )
                    for r in sheet.rows
                ],
                day_totals=sheet.day_totals,
                total=sheet.total,
            )

        return await sync_to_async(run)()

    @grpc_action(
        request=[
            WS,
            {"name": "project_id", "type": "string"},
            {"name": "start", "type": "string"},
            {"name": "end", "type": "string"},
        ],
        request_name="TotalsRequest",
        response=[{"name": "people", "cardinality": "repeated", "type": PersonTotal}],
        response_name="TotalsAnswer",
    )
    @action
    async def Totals(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)

        def run() -> Any:
            lines = reports.totals(
                user,
                workspace,
                request.project_id,
                parse_time(request.start, "start"),
                parse_time(request.end, "end"),
            )
            return _pb().TotalsAnswer(
                people=[
                    _pb().PersonTotal(
                        user_id=p.user_id, name=p.name, seconds=p.seconds, billable=p.billable
                    )
                    for p in lines
                ]
            )

        return await sync_to_async(run)()


GRPC_SERVICES = [TimeService]
