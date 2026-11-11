"""The burndown of a sprint (read from snapshots, today live) and the velocity of the last six."""

from dataclasses import dataclass
from datetime import date, datetime, timedelta
from decimal import ROUND_HALF_UP, Decimal
from typing import Any, Final

from django.utils import timezone

from infrastructure.sprints import clock, services, snapshots, tally
from infrastructure.sprints.models import ScopeEvent, Snapshot, Sprint, State
from infrastructure.workspaces.models import Workspace

VELOCITY_SPRINTS: Final = 6
CENT: Final = Decimal("0.01")


@dataclass(frozen=True, slots=True)
class Day:
    date: date
    ideal_points: Decimal
    ideal_tasks: Decimal
    has_actual: bool = False
    live: bool = False  # today, read now rather than from a snapshot
    backfilled: bool = False
    remaining_points: Decimal = tally.ZERO
    remaining_tasks: int = 0
    scope_points: Decimal = tally.ZERO
    scope_tasks: int = 0


@dataclass(frozen=True, slots=True)
class ScopeStep:
    date: date
    points: Decimal
    tasks: int


@dataclass(frozen=True, slots=True)
class Velocity:
    sprint: Sprint
    committed_points: Decimal
    completed_points: Decimal


@dataclass(frozen=True, slots=True)
class Burndown:
    sprint: Sprint
    baseline_points: Decimal
    baseline_tasks: int
    days: list[Day]
    steps: list[ScopeStep]
    velocity: list[Velocity]
    average_velocity: Decimal


def _ideal(baseline: Decimal, index: int, count: int) -> Decimal:
    """What should remain at the end of day ``index`` (0-based) of ``count`` days."""
    left = max(count - (index + 1), 0)
    return (Decimal(baseline) * left / count).quantize(CENT, ROUND_HALF_UP)


def steps_of(sprint: Sprint, zone: Any) -> list[ScopeStep]:
    """After-start scope changes, summed per local day (a start in the future clamps to day one)."""
    found: dict[date, list[Any]] = {}
    for e in ScopeEvent.objects.filter(sprint=sprint, after_start=True).order_by("at", "pk"):
        day = max(clock.local_date(zone, e.at), sprint.start_date)
        bucket = found.setdefault(day, [tally.ZERO, 0])
        bucket[0] += e.delta_points
        bucket[1] += e.delta_tasks
    return [ScopeStep(d, p, t) for d, (p, t) in sorted(found.items()) if p or t]


def velocity(project_id: Any) -> list[Velocity]:
    """The last six completed sprints, oldest first."""
    rows = list(
        Sprint.objects.filter(project_id=project_id, state=State.COMPLETED).order_by(
            "-completed_at"
        )[:VELOCITY_SPRINTS]
    )
    return [Velocity(s, s.baseline_points, s.completed_points) for s in reversed(rows)]


def build(sprint: Sprint, now: datetime) -> Burndown:
    zone = clock.zone_of(sprint.workspace)
    today = clock.local_date(zone, now)
    n = (sprint.end_date - sprint.start_date).days + 1
    last = sprint.end_date
    if sprint.state == State.ACTIVE:
        last = max(last, today)
    elif sprint.completed_at is not None:
        last = max(last, clock.local_date(zone, sprint.completed_at))
    started_day = (
        clock.local_date(zone, sprint.started_at) if sprint.started_at is not None else None
    )
    stored = {s.date: s for s in Snapshot.objects.filter(sprint=sprint)}
    live = tally.tally(sprint) if sprint.state == State.ACTIVE else None
    days: list[Day] = []
    day = sprint.start_date
    while day <= last:
        i = (day - sprint.start_date).days
        base = {
            "date": day,
            "ideal_points": _ideal(sprint.baseline_points, i, n),
            "ideal_tasks": _ideal(Decimal(sprint.baseline_tasks), i, n),
        }
        snap = stored.get(day)
        if snap is not None:
            days.append(
                Day(
                    **base,
                    has_actual=True,
                    backfilled=snap.backfilled,
                    remaining_points=snap.remaining_points,
                    remaining_tasks=snap.remaining_tasks,
                    scope_points=snap.scope_points,
                    scope_tasks=snap.scope_tasks,
                )
            )
        elif live is not None and day == today:
            scope = snapshots.scope_until(sprint, None)
            days.append(
                Day(
                    **base,
                    has_actual=True,
                    live=True,
                    remaining_points=live.open_points,
                    remaining_tasks=live.open_tasks,
                    scope_points=scope.points,
                    scope_tasks=scope.tasks,
                )
            )
        elif sprint.state != State.PLANNED and started_day is not None and day < started_day:
            days.append(
                Day(
                    **base,
                    has_actual=True,
                    remaining_points=sprint.baseline_points,
                    remaining_tasks=sprint.baseline_tasks,
                    scope_points=sprint.baseline_points,
                    scope_tasks=sprint.baseline_tasks,
                )
            )
        else:
            days.append(Day(**base))
        day += timedelta(days=1)
    past = velocity(sprint.project_id)
    average = (
        (sum((v.completed_points for v in past), tally.ZERO) / len(past)).quantize(CENT)
        if past
        else tally.ZERO
    )
    return Burndown(
        sprint,
        sprint.baseline_points,
        sprint.baseline_tasks,
        days,
        steps_of(sprint, zone),
        past,
        average,
    )


def burndown(
    actor: Any,
    workspace: Workspace,
    project_id: str,
    sprint_id: str,
    now: datetime | None = None,
) -> Burndown:
    project = services._project(actor, workspace, project_id, services.VIEW)
    sprint = services._sprint(project, sprint_id)
    return build(sprint, now or timezone.now())
