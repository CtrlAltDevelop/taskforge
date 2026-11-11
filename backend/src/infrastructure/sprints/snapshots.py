"""The daily snapshot: each active sprint's remaining and scope at the end of every local day
(the workspace's midnight). There is no scheduler, so ``manage.py sprint_snapshots`` (run by
``make tick``) writes the days that closed since the last run, and a day it missed is back-filled
from the state then current: ``backfilled`` says so, and its scope is exact (rebuilt from the
scope events), only its remaining count is as of the late run."""

from dataclasses import dataclass
from datetime import date, datetime, timedelta
from decimal import Decimal
from typing import Final

from django.db.models import Sum
from django.utils import timezone

from infrastructure.sprints import clock, tally
from infrastructure.sprints.models import ScopeEvent, Snapshot, Sprint, State

GRACE: Final = timedelta(hours=1)  # a run this soon after midnight is on time, not a back-fill
MAX_CATCH_UP_DAYS: Final = 400


@dataclass(frozen=True, slots=True)
class Scope:
    points: Decimal
    tasks: int


def scope_until(sprint: Sprint, moment: datetime | None) -> Scope:
    """The baseline plus every after-start change made before ``moment`` (None: all of them)."""
    events = ScopeEvent.objects.filter(sprint=sprint, after_start=True)
    if moment is not None:
        events = events.filter(at__lte=moment)
    sums = events.aggregate(p=Sum("delta_points"), t=Sum("delta_tasks"))
    return Scope(
        sprint.baseline_points + (sums["p"] or tally.ZERO),
        sprint.baseline_tasks + (sums["t"] or 0),
    )


def _write(sprint: Sprint, day: date, zone_end: datetime, counts: tally.Tally, back: bool) -> None:
    scope = scope_until(sprint, zone_end)
    Snapshot.objects.update_or_create(
        sprint=sprint,
        date=day,
        defaults={
            "remaining_points": counts.open_points,
            "remaining_tasks": counts.open_tasks,
            "scope_points": scope.points,
            "scope_tasks": scope.tasks,
            "backfilled": back,
        },
    )


def first_day(sprint: Sprint) -> date:
    assert sprint.started_at is not None
    zone = clock.zone_of(sprint.workspace)
    return max(sprint.start_date, clock.local_date(zone, sprint.started_at))


def catch_up(sprint: Sprint, now: datetime) -> int:
    """Write the missing snapshots of the days that closed before today; returns how many."""
    zone = clock.zone_of(sprint.workspace)
    last = clock.local_date(zone, now) - timedelta(days=1)
    first = first_day(sprint)
    if last < first:
        return 0
    have = set(Snapshot.objects.filter(sprint=sprint).values_list("date", flat=True))
    counts = tally.tally(sprint)
    written = 0
    day = max(first, last - timedelta(days=MAX_CATCH_UP_DAYS))
    while day <= last:
        if day not in have:
            end = clock.day_end(zone, day)
            _write(sprint, day, end, counts, now > end + GRACE)
            written += 1
        day += timedelta(days=1)
    return written


def close(sprint: Sprint, now: datetime) -> None:
    """When a sprint is completed: back-fill, then today's point as the sprint stands."""
    catch_up(sprint, now)
    zone = clock.zone_of(sprint.workspace)
    today = clock.local_date(zone, now)
    if today >= first_day(sprint):
        _write(sprint, today, now, tally.tally(sprint), False)


def take_all(now: datetime | None = None) -> int:
    """The scheduled job: catch up every active sprint. Returns the snapshots written."""
    now = now or timezone.now()
    rows = Sprint.objects.filter(
        state=State.ACTIVE,
        workspace__deleted_at__isnull=True,
        project__archived_at__isnull=True,
    ).select_related("workspace__created_by")
    return sum(catch_up(s, now) for s in rows)
