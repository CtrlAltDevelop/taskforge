"""Capacity, time off, holidays and the workload grid. Every query is scoped to the workspace.

Anyone in the workspace sees their own row. Seeing other people's numbers needs ``workload.view``;
changing anybody's capacity or the holidays needs ``workload.manage``. A person may add and remove
their own time off. The grid counts open tasks of projects the caller can open; where a task's
estimate lands is decided by ``allocation`` (one rule). Results are cached for a few seconds and
dropped whenever a task, capacity, time off or holiday changes (see ``receivers``).
"""

import hashlib
import uuid
from collections import defaultdict
from collections.abc import Iterable
from dataclasses import dataclass, field, replace
from datetime import date
from decimal import Decimal, InvalidOperation
from typing import Any, Final

from django.core.cache import cache
from django.db import transaction
from django.db.models import Q
from django.utils import timezone

from infrastructure.audit import recorder
from infrastructure.common.errors import ApiError
from infrastructure.common.responses import ResponseTitle
from infrastructure.projects.models import Project
from infrastructure.tasks.models import Task
from infrastructure.workflows.models import Category
from infrastructure.workload import allocation
from infrastructure.workload.models import (
    DEFAULT_DAYS,
    DEFAULT_HOURS,
    AssigneeEstimate,
    Holiday,
    MemberCapacity,
    TimeOff,
    TimeOffKind,
)
from infrastructure.workspaces import access
from infrastructure.workspaces.models import MemberStatus, Workspace, WorkspaceMember

VIEW_ALL: Final = "workload.view"
MANAGE: Final = "workload.manage"
VIEW: Final = "workspace.view"
MAX_RANGE_DAYS: Final = 400
MAX_TASKS: Final = 5000
MAX_LISTED: Final = 200
CACHE_SECONDS: Final = 20
OPEN: Final = (Category.NOT_STARTED, Category.ACTIVE)
NO_ESTIMATE: Final = "no_estimate"
NO_DATES: Final = "no_dates"


def invalid(message: str) -> ApiError:
    return ApiError(message, status=400, title=ResponseTitle.VALIDATION_ERROR)


def not_found() -> ApiError:
    return ApiError("Not found.", status=404, title=ResponseTitle.NOT_FOUND)


def _uuid(raw: Any) -> uuid.UUID:
    try:
        return uuid.UUID(str(raw))
    except ValueError:
        raise not_found() from None


def _date(raw: Any, name: str) -> date:
    try:
        return date.fromisoformat(str(raw))
    except ValueError:
        raise invalid(f"{name} is a date like 2026-01-31.") from None


def _text(raw: Any, name: str, limit: int, *, required: bool = False) -> str:
    value = str(raw or "").strip()
    if required and not value:
        raise invalid(f"{name} is required.")
    if len(value) > limit:
        raise invalid(f"{name} is longer than {limit} characters.")
    return value


def _member(workspace: Workspace, user_id: Any) -> WorkspaceMember:
    row = (
        WorkspaceMember.objects.filter(
            workspace=workspace, user_id=_uuid(user_id), status=MemberStatus.ACTIVE
        )
        .select_related("user")
        .first()
    )
    if row is None:
        raise not_found()
    return row


def can_see_all(actor: Any, workspace: Workspace) -> bool:
    return access.can(actor, VIEW_ALL, workspace).allowed


# ----------------------------------------------------------------------------- caching


def _version_key(workspace_id: Any) -> str:
    return f"workload:version:{workspace_id}"


def invalidate(workspace_id: Any) -> None:
    """Make every cached grid of the workspace stale."""
    key = _version_key(workspace_id)
    try:
        cache.incr(key)
    except ValueError:
        cache.set(key, 1, None)


def _cache_key(workspace: Workspace, actor: Any, parts: Iterable[Any]) -> str:
    version = cache.get(_version_key(workspace.pk), 0)
    digest = hashlib.sha1("|".join(map(str, parts)).encode(), usedforsecurity=False).hexdigest()
    return f"workload:{workspace.pk}:{version}:{actor.pk}:{digest}"


# ----------------------------------------------------------------------------- capacity


@dataclass(frozen=True, slots=True)
class CapacityView:
    user_id: str
    hours_per_day: Decimal
    working_days: list[int]
    is_set: bool


def _capacity_view(user_id: Any, row: MemberCapacity | None) -> CapacityView:
    if row is None:
        return CapacityView(str(user_id), Decimal(DEFAULT_HOURS), list(DEFAULT_DAYS), False)
    return CapacityView(str(user_id), row.hours_per_day, sorted(row.working_days), True)


def get_capacity(actor: Any, workspace: Workspace, user_id: str = "") -> list[CapacityView]:
    """One person's capacity (``user_id``) or everybody's (empty; needs ``workload.view``)."""
    access.require(actor, VIEW, workspace)
    if user_id:
        target = _member(workspace, user_id).user_id
        if target != actor.pk:
            access.require(actor, VIEW_ALL, workspace)
        row = MemberCapacity.objects.filter(workspace=workspace, user_id=target).first()
        return [_capacity_view(target, row)]
    if not can_see_all(actor, workspace):
        row = MemberCapacity.objects.filter(workspace=workspace, user=actor).first()
        return [_capacity_view(actor.pk, row)]
    rows = {c.user_id: c for c in MemberCapacity.objects.filter(workspace=workspace)}
    ids = WorkspaceMember.objects.filter(workspace=workspace, status=MemberStatus.ACTIVE)
    return [_capacity_view(u, rows.get(u)) for u in ids.values_list("user_id", flat=True)]


def _hours(raw: Any) -> Decimal:
    try:
        value = Decimal(str(raw).strip())
    except (InvalidOperation, ValueError):
        raise invalid("Hours per day must be a number.") from None
    if not value.is_finite() or not Decimal(0) <= value <= Decimal(24):
        raise invalid("Hours per day is between 0 and 24.")
    return value.quantize(Decimal("0.01"))


def _weekdays(raw: Iterable[Any]) -> list[int]:
    days = sorted({int(d) for d in raw if str(d).lstrip("-").isdigit()})
    if any(d < 0 or d > 6 for d in days):
        raise invalid("Working days are 0 (Monday) to 6 (Sunday).")
    return days


def set_capacity(
    actor: Any, workspace: Workspace, user_id: str, hours_per_day: Any, working_days: list[Any]
) -> CapacityView:
    access.require(actor, MANAGE, workspace)
    member = _member(workspace, user_id)
    hours, days = _hours(hours_per_day), _weekdays(working_days)
    with transaction.atomic():
        row, _ = MemberCapacity.objects.update_or_create(
            workspace=workspace,
            user=member.user,
            defaults={"hours_per_day": hours, "working_days": days, "updated_at": timezone.now()},
        )
        recorder.record(
            workspace_id=workspace.pk,
            action="workload.capacity.set",
            target_type="member_capacity",
            target_id=row.pk,
            changes={"user_id": str(member.user_id), "hours_per_day": str(hours), "days": days},
            actor=actor,
        )
        transaction.on_commit(lambda: invalidate(workspace.pk))
    return _capacity_view(member.user_id, row)


# ----------------------------------------------------------------------------- time off


def _time_off_scope(actor: Any, workspace: Workspace, user_id: str) -> Any:
    access.require(actor, VIEW, workspace)
    rows = TimeOff.objects.filter(workspace=workspace)
    if user_id:
        target = _member(workspace, user_id).user_id
        if target != actor.pk:
            access.require(actor, VIEW_ALL, workspace)
        return rows.filter(user_id=target)
    return rows if can_see_all(actor, workspace) else rows.filter(user=actor)


def list_time_off(
    actor: Any, workspace: Workspace, user_id: str, range_start: str, range_end: str
) -> list[TimeOff]:
    rows = _time_off_scope(actor, workspace, user_id)
    if range_start:
        rows = rows.filter(end_date__gte=_date(range_start, "Range start"))
    if range_end:
        rows = rows.filter(start_date__lte=_date(range_end, "Range end"))
    return list(rows[:1000])


def _time_off_fields(start: str, end: str, kind: str, note: str) -> dict[str, Any]:
    first, last = _date(start, "Start"), _date(end or start, "End")
    if last < first:
        raise invalid("Time off cannot end before it starts.")
    if (last - first).days > 366:
        raise invalid("Time off is at most a year long.")
    kind = kind or TimeOffKind.OTHER
    if kind not in TimeOffKind.ALL:
        raise invalid("Unknown kind of time off.")
    return {
        "start_date": first,
        "end_date": last,
        "kind": kind,
        "note": _text(note, "Note", 300),
    }


def _may_edit_time_off(actor: Any, workspace: Workspace, owner_id: Any) -> None:
    if owner_id != actor.pk:
        access.require(actor, MANAGE, workspace)


def _audit(
    workspace: Workspace, actor: Any, action: str, target_type: str, target: Any, **ch: Any
) -> None:
    recorder.record(
        workspace_id=workspace.pk,
        action=action,
        target_type=target_type,
        target_id=target,
        changes={k: str(v) for k, v in ch.items()},
        actor=actor,
    )
    transaction.on_commit(lambda: invalidate(workspace.pk))


def create_time_off(
    actor: Any, workspace: Workspace, user_id: str, start: str, end: str, kind: str, note: str
) -> TimeOff:
    access.require(actor, VIEW, workspace)
    member = _member(workspace, user_id or str(actor.pk))
    _may_edit_time_off(actor, workspace, member.user_id)
    fields = _time_off_fields(start, end, kind, note)
    with transaction.atomic():
        row = TimeOff.objects.create(
            workspace=workspace, user=member.user, created_by=actor, **fields
        )
        _audit(
            workspace, actor, "workload.time_off.create", "time_off", row.pk,
            user_id=member.user_id, start=row.start_date, end=row.end_date,
        )  # fmt: skip
    return row


def _time_off(workspace: Workspace, time_off_id: str) -> TimeOff:
    row = TimeOff.objects.filter(workspace=workspace, pk=_uuid(time_off_id)).first()
    if row is None:
        raise not_found()
    return row


def update_time_off(
    actor: Any, workspace: Workspace, time_off_id: str, start: str, end: str, kind: str, note: str
) -> TimeOff:
    access.require(actor, VIEW, workspace)
    row = _time_off(workspace, time_off_id)
    _may_edit_time_off(actor, workspace, row.user_id)
    fields = _time_off_fields(start, end, kind, note)
    with transaction.atomic():
        for name, value in fields.items():
            setattr(row, name, value)
        row.save()
        _audit(
            workspace, actor, "workload.time_off.update", "time_off", row.pk,
            start=row.start_date, end=row.end_date,
        )  # fmt: skip
    return row


def delete_time_off(actor: Any, workspace: Workspace, time_off_id: str) -> None:
    access.require(actor, VIEW, workspace)
    row = _time_off(workspace, time_off_id)
    _may_edit_time_off(actor, workspace, row.user_id)
    with transaction.atomic():
        row.delete()
        _audit(workspace, actor, "workload.time_off.delete", "time_off", time_off_id)


# ----------------------------------------------------------------------------- holidays


def list_holidays(
    actor: Any, workspace: Workspace, range_start: str = "", range_end: str = ""
) -> list[Holiday]:
    access.require(actor, VIEW, workspace)
    rows = Holiday.objects.filter(workspace=workspace)
    if range_start:
        rows = rows.filter(date__gte=_date(range_start, "Range start"))
    if range_end:
        rows = rows.filter(date__lte=_date(range_end, "Range end"))
    return list(rows[:2000])


def create_holiday(actor: Any, workspace: Workspace, day: str, name: str) -> Holiday:
    access.require(actor, MANAGE, workspace)
    when, label = _date(day, "Date"), _text(name, "Name", 120, required=True)
    with transaction.atomic():
        if Holiday.objects.filter(workspace=workspace, date=when).exists():
            raise ApiError("That day is already a holiday.", 409, title=ResponseTitle.CONFLICT)
        row = Holiday.objects.create(workspace=workspace, date=when, name=label)
        _audit(
            workspace, actor, "workload.holiday.create", "holiday", row.pk, date=when, name=label
        )
    return row


def update_holiday(
    actor: Any, workspace: Workspace, holiday_id: str, day: str, name: str
) -> Holiday:
    access.require(actor, MANAGE, workspace)
    when, label = _date(day, "Date"), _text(name, "Name", 120, required=True)
    with transaction.atomic():
        row = (
            Holiday.objects.select_for_update()
            .filter(workspace=workspace, pk=_uuid(holiday_id))
            .first()
        )
        if row is None:
            raise not_found()
        clash = Holiday.objects.filter(workspace=workspace, date=when).exclude(pk=row.pk)
        if clash.exists():
            raise ApiError("That day is already a holiday.", 409, title=ResponseTitle.CONFLICT)
        row.date, row.name = when, label
        row.save()
        _audit(
            workspace, actor, "workload.holiday.update", "holiday", row.pk, date=when, name=label
        )
    return row


def delete_holiday(actor: Any, workspace: Workspace, holiday_id: str) -> None:
    access.require(actor, MANAGE, workspace)
    with transaction.atomic():
        row = Holiday.objects.filter(workspace=workspace, pk=_uuid(holiday_id)).first()
        if row is None:
            raise not_found()
        row.delete()
        _audit(workspace, actor, "workload.holiday.delete", "holiday", holiday_id)


# ----------------------------------------------------------------------------- estimates


def set_assignee_estimate(
    actor: Any, workspace: Workspace, task_id: str, user_id: str, estimate_sec: int
) -> None:
    """Give one assignee an estimate of their own for a task (0 removes it)."""
    access.require(actor, "task.update", workspace)
    visible = Project.objects.visible_to(actor, workspace)
    task = Task.objects.filter(
        workspace=workspace, pk=_uuid(task_id), project__in=visible, deleted_at__isnull=True
    ).first()
    if task is None:
        raise not_found()
    member = _member(workspace, user_id)
    if not task.assignees.filter(user=member.user).exists():
        raise invalid("That person is not assigned to the task.")
    if estimate_sec < 0 or estimate_sec > 3_600_000:
        raise invalid("The estimate is out of range.")
    with transaction.atomic():
        if estimate_sec == 0:
            AssigneeEstimate.objects.filter(task=task, user=member.user).delete()
        else:
            AssigneeEstimate.objects.update_or_create(
                task=task, user=member.user, defaults={"estimate_sec": estimate_sec}
            )
        _audit(
            workspace, actor, "workload.estimate.set", "task", task.pk,
            user_id=member.user_id, estimate_sec=estimate_sec,
        )  # fmt: skip
    return None


# ----------------------------------------------------------------------------- the grid


@dataclass(frozen=True, slots=True)
class Contribution:
    task_id: str
    seconds: int
    warning: bool


@dataclass(frozen=True, slots=True)
class DayCell:
    day: date
    load_sec: int
    capacity_sec: int
    over: bool
    contributions: list[Contribution]


@dataclass(frozen=True, slots=True)
class OffRange:
    start: date
    end: date
    kind: str


@dataclass(frozen=True, slots=True)
class PersonLoad:
    user_id: str
    capacity: CapacityView
    time_off: list[OffRange]
    days: list[DayCell]
    total_load_sec: int


@dataclass(frozen=True, slots=True)
class TaskRow:
    task_id: str
    project_id: str
    display_id: str
    title: str
    version: int
    start_date: str
    due_date: str
    estimate_sec: int
    assignee_ids: list[str]
    own_sec: dict[str, int]
    reason: str = ""


@dataclass(frozen=True, slots=True)
class Workload:
    range_start: date
    range_end: date
    can_see_all: bool
    people: list[PersonLoad]
    tasks: list[TaskRow]
    unestimated: list[TaskRow]
    holidays: list[date]
    truncated: bool = False
    warnings: list[str] = field(default_factory=list)


class PersonCalendar:
    """Whether and how much a person works on a day: their weekdays less holidays, time off."""

    def __init__(
        self, capacity: CapacityView, holidays: frozenset[date], off: list[OffRange]
    ) -> None:
        self.days = frozenset(capacity.working_days)
        self.holidays = holidays
        self.off = off
        self.seconds = int(capacity.hours_per_day * 3600)

    def is_working(self, day: date) -> bool:
        if day in self.holidays or day.weekday() not in self.days:
            return False
        return not any(o.start <= day <= o.end for o in self.off)

    def capacity_sec(self, day: date) -> int:
        return self.seconds if self.is_working(day) else 0


def _range(range_start: str, range_end: str) -> tuple[date, date]:
    first, last = _date(range_start, "Range start"), _date(range_end, "Range end")
    if last < first:
        raise invalid("The range ends before it starts.")
    if (last - first).days >= MAX_RANGE_DAYS:
        raise invalid(f"The range is at most {MAX_RANGE_DAYS} days.")
    return first, last


def _uuids(raw: Iterable[Any]) -> list[uuid.UUID]:
    return [_uuid(r) for r in raw]


def _overlapping(first: date, last: date) -> Q:
    ends = Q(due_date__gte=first) | Q(due_date__isnull=True, start_date__gte=first)
    begins = Q(start_date__lte=last) | Q(start_date__isnull=True, due_date__lte=last)
    return ends & begins


def _task_rows(
    actor: Any, workspace: Workspace, first: date, last: date, project_ids: list[uuid.UUID]
) -> tuple[list[Task], list[Task], bool]:
    """The open assigned tasks inside the range, and those without dates (listed, not placed)."""
    projects = Project.objects.visible_to(actor, workspace).filter(archived_at__isnull=True)
    if project_ids:
        projects = projects.filter(pk__in=project_ids)
    base = (
        Task.objects.filter(
            workspace=workspace,
            project__in=projects,
            deleted_at__isnull=True,
            is_sample=False,
            status__category__in=OPEN,
            assignees__isnull=False,
        )
        .select_related("project")
        .prefetch_related("assignees", "assignee_estimates")
        .distinct()
    )
    dated = list(base.filter(_overlapping(first, last)).order_by("due_date", "number")[:MAX_TASKS])
    undated = list(
        base.filter(start_date__isnull=True, due_date__isnull=True).order_by("number")[:MAX_LISTED]
    )
    return dated, undated, len(dated) >= MAX_TASKS


def _row(task: Task, reason: str = "") -> TaskRow:
    return TaskRow(
        task_id=str(task.pk),
        project_id=str(task.project_id),
        display_id=task.display_id,
        title=task.title,
        version=task.version,
        start_date=task.start_date.isoformat() if task.start_date else "",
        due_date=task.due_date.isoformat() if task.due_date else "",
        estimate_sec=task.estimate_sec or 0,
        assignee_ids=[str(a.user_id) for a in task.assignees.all()],
        own_sec={str(e.user_id): e.estimate_sec for e in task.assignee_estimates.all()},
        reason=reason,
    )


def _calendars(
    workspace: Workspace, members: list[Any], holidays: frozenset[date]
) -> tuple[dict[str, PersonCalendar], dict[str, CapacityView], dict[str, list[OffRange]]]:
    caps = {c.user_id: c for c in MemberCapacity.objects.filter(workspace=workspace)}
    off: dict[str, list[OffRange]] = defaultdict(list)
    for row in TimeOff.objects.filter(workspace=workspace, user_id__in=members):
        off[str(row.user_id)].append(OffRange(row.start_date, row.end_date, row.kind))
    views = {str(u): _capacity_view(u, caps.get(u)) for u in members}
    cals = {u: PersonCalendar(views[u], holidays, off[u]) for u in views}
    return cals, views, off


def compute(
    actor: Any,
    workspace: Workspace,
    range_start: str,
    range_end: str,
    project_ids: list[str] | None = None,
    user_ids: list[str] | None = None,
) -> Workload:
    """The grid for ``[range_start, range_end]``: one row per shown person, sparse day cells (only
    days with load), the tasks behind them and the open tasks that cannot be placed."""
    access.require(actor, VIEW, workspace)
    first, last = _range(range_start, range_end)
    see_all = can_see_all(actor, workspace)
    projects = _uuids(project_ids or [])
    wanted = _uuids(user_ids or [])
    key = _cache_key(
        workspace, actor, [first, last, sorted(map(str, projects)), sorted(map(str, wanted))]
    )
    hit = cache.get(key)
    if hit is not None:
        return hit
    result = _compute(actor, workspace, first, last, see_all, projects, wanted)
    cache.set(key, result, CACHE_SECONDS)
    return result


def _shown(actor: Any, workspace: Workspace, see_all: bool, wanted: list[uuid.UUID]) -> list[Any]:
    if not see_all:
        return [actor.pk]
    rows = WorkspaceMember.objects.filter(workspace=workspace, status=MemberStatus.ACTIVE)
    if wanted:
        rows = rows.filter(user_id__in=wanted)
    return list(rows.order_by("user__email").values_list("user_id", flat=True))


def _compute(
    actor: Any,
    workspace: Workspace,
    first: date,
    last: date,
    see_all: bool,
    projects: list[uuid.UUID],
    wanted: list[uuid.UUID],
) -> Workload:
    shown = _shown(actor, workspace, see_all, wanted)
    shown_ids = {str(u) for u in shown}
    holiday_days = list(Holiday.objects.filter(workspace=workspace).values_list("date", flat=True))
    holidays = frozenset(holiday_days)
    cals, views, off = _calendars(workspace, shown, holidays)
    dated, undated, truncated = _task_rows(actor, workspace, first, last, projects)
    cells: dict[str, dict[date, list[Contribution]]] = {u: defaultdict(list) for u in shown_ids}
    placed: dict[str, TaskRow] = {}
    unestimated: list[TaskRow] = []
    for task in dated:
        row = _row(task)
        mine = [a for a in row.assignee_ids if a in shown_ids]
        if not mine:
            continue
        if not row.estimate_sec and not row.own_sec:
            unestimated.append(replace(row, reason=NO_ESTIMATE))
            continue
        shares = allocation.split_estimate(row.estimate_sec, row.assignee_ids, row.own_sec)
        for person in mine:
            spread = allocation.spread(
                shares.get(person, 0), task.start_date, task.due_date, cals[person].is_working
            )
            for day, seconds in spread.days.items():
                if first <= day <= last:
                    cells[person][day].append(Contribution(row.task_id, seconds, spread.warning))
                    placed[row.task_id] = row
    for task in undated:
        row = _row(task)
        if any(a in shown_ids for a in row.assignee_ids):
            unestimated.append(replace(row, reason=NO_DATES))
    people = [_person(u, views[u], off[u], cells[u], cals[u]) for u in map(str, shown)]
    return Workload(
        range_start=first,
        range_end=last,
        can_see_all=see_all,
        people=people,
        tasks=list(placed.values()),
        unestimated=unestimated[:MAX_LISTED],
        holidays=sorted(d for d in holiday_days if first <= d <= last),
        truncated=truncated,
    )


def _person(
    user_id: str,
    capacity: CapacityView,
    off: list[OffRange],
    cells: dict[date, list[Contribution]],
    cal: PersonCalendar,
) -> PersonLoad:
    days = []
    for day in sorted(cells):
        load = sum(c.seconds for c in cells[day])
        cap = cal.capacity_sec(day)
        days.append(DayCell(day, load, cap, load > cap, cells[day]))
    return PersonLoad(user_id, capacity, off, days, sum(d.load_sec for d in days))
