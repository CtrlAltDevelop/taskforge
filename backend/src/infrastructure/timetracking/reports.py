"""Timesheets and totals, read from entries (never stored, so they cannot disagree with them)."""

import uuid
from dataclasses import dataclass, field
from datetime import date, datetime, time, timedelta
from datetime import timezone as timezone_
from typing import Any
from zoneinfo import ZoneInfo, ZoneInfoNotFoundError

from django.db.models import Q
from django.utils import timezone

from infrastructure.comments.mentions import display_name
from infrastructure.common.errors import ApiError
from infrastructure.common.responses import ResponseTitle
from infrastructure.timetracking import services
from infrastructure.timetracking.models import TimeEntry
from infrastructure.workspaces import access
from infrastructure.workspaces.models import MemberStatus, Workspace, WorkspaceMember

DAYS = 7


@dataclass(slots=True)
class SheetRow:
    task_id: str
    project_id: str
    key: str
    title: str
    seconds: list[int] = field(default_factory=lambda: [0] * DAYS)
    billable: int = 0

    @property
    def total(self) -> int:
        return sum(self.seconds)


@dataclass(slots=True)
class Sheet:
    user_id: str
    week_start: date
    rows: list[SheetRow]
    day_totals: list[int]

    @property
    def total(self) -> int:
        return sum(self.day_totals)


def _bad(message: str) -> ApiError:
    return ApiError(message, status=400, title=ResponseTitle.VALIDATION_ERROR)


def _zone(name: str, offset_minutes: int = 0) -> Any:
    """The named zone, or (no name) a fixed offset, for a device that cannot name its zone."""
    if not name and offset_minutes:
        if abs(offset_minutes) > 14 * 60:
            raise _bad("Unknown time zone.")
        return timezone_(timedelta(minutes=offset_minutes))
    try:
        return ZoneInfo(name or "UTC")
    except (ZoneInfoNotFoundError, ValueError):
        raise _bad("Unknown time zone.") from None


def _member(workspace: Workspace, user_id: str) -> Any:
    try:
        uuid.UUID(str(user_id))
    except ValueError:
        raise _bad("That person is not a member of this workspace.") from None
    member = (
        WorkspaceMember.objects.filter(
            workspace=workspace, user_id=user_id, status=MemberStatus.ACTIVE
        )
        .select_related("user__profile")
        .first()
    )
    if member is None:
        raise _bad("That person is not a member of this workspace.")
    return member.user


def day_bounds(week_start: date, zone: Any) -> list[datetime]:
    """The eight local midnights that bound the week's seven days (right even across DST)."""
    return [
        datetime.combine(week_start + timedelta(days=i), time.min, tzinfo=zone)
        for i in range(DAYS + 1)
    ]


def timesheet(
    actor: Any,
    workspace: Workspace,
    week_start: str,
    tz: str = "UTC",
    user_id: str = "",
    utc_offset_minutes: int = 0,
) -> Sheet:
    """Seconds per task per local day for seven days from ``week_start`` (a date; the caller picks
    which weekday a week starts on), for the caller or, with ``time.edit_others``, anyone."""
    access.require(actor, services.VIEW, workspace)
    try:
        first = date.fromisoformat(week_start)
    except ValueError:
        raise _bad("The week must start on a date (YYYY-MM-DD).") from None
    who = actor
    if user_id and str(user_id) != str(actor.pk):
        access.require(actor, services.OTHERS, workspace)
        who = _member(workspace, user_id)
    bounds = [
        b.astimezone(ZoneInfo("UTC")) for b in day_bounds(first, _zone(tz, utc_offset_minutes))
    ]
    now = timezone.now()
    enabled = services._visible_enabled(actor, workspace)
    entries = (
        TimeEntry.objects.filter(
            user=who,
            workspace=workspace,
            task__project_id__in=enabled,
            task__deleted_at__isnull=True,
            started_at__lt=bounds[-1],
        )
        .filter(Q(ended_at__isnull=True) | Q(ended_at__gt=bounds[0]))
        .select_related("task__project")
    )
    by_task: dict[Any, SheetRow] = {}
    for e in entries:
        end = e.ended_at or max(now, e.started_at)
        row = by_task.setdefault(
            e.task_id,
            SheetRow(
                str(e.task_id),
                str(e.task.project_id),
                f"{e.task.project.key}-{e.task.number}",
                e.task.title,
            ),
        )
        for i in range(DAYS):
            part = (min(end, bounds[i + 1]) - max(e.started_at, bounds[i])).total_seconds()
            if part > 0:
                row.seconds[i] += int(part)
                if e.billable:
                    row.billable += int(part)
    rows = sorted(by_task.values(), key=lambda r: (r.key.split("-")[0], int(r.key.split("-")[1])))
    return Sheet(str(who.pk), first, rows, [sum(r.seconds[i] for r in rows) for i in range(DAYS)])


@dataclass(frozen=True, slots=True)
class PersonTotal:
    user_id: str
    name: str
    seconds: int
    billable: int


def totals(
    actor: Any,
    workspace: Workspace,
    project_id: str,
    start: datetime,
    end: datetime,
) -> list[PersonTotal]:
    """Time logged in a project by entries that *started* in ``[start, end)``, per person. Without
    ``time.edit_others`` only the caller's own line."""
    access.require(actor, services.VIEW, workspace)
    if end <= start:
        raise _bad("The end must be after the start.")
    from infrastructure.projects import services as projects

    project = projects.load(actor, workspace, project_id)
    services._need_feature(project)
    rows = TimeEntry.objects.filter(
        task__project=project,
        task__deleted_at__isnull=True,
        started_at__gte=start,
        started_at__lt=end,
    ).select_related("user__profile")
    if not access.can(actor, services.OTHERS, workspace).allowed:
        rows = rows.filter(user=actor)
    now = timezone.now()
    out: dict[Any, list[Any]] = {}
    for e in rows:
        seconds = services.seconds_of(e, now)
        line = out.setdefault(e.user_id, [e.user, 0, 0])
        line[1] += seconds
        if e.billable:
            line[2] += seconds
    return sorted(
        (PersonTotal(str(u.pk), display_name(u), s, b) for u, s, b in out.values()),
        key=lambda t: (-t.seconds, t.name),
    )
