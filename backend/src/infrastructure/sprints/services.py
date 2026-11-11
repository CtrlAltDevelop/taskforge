"""Sprints: plan, start, complete, and move tasks in and out.

Seeing sprints and the backlog needs ``workspace.view``; every change needs ``sprint.manage``; both
need the project to be visible and to have *Sprints* switched on (off keeps the data but hides it).
A project has at most one active sprint. Start fixes the baseline scope; what is added or removed
after it is recorded as a scope change (the steps of the burndown). Complete counts only tasks in a
*Done* status as finished: the others go to the next planned sprint or back to the backlog (a
cancelled task is neither: it stays in the sprint, counted as nothing).
"""

import uuid
from collections.abc import Iterable, Sequence
from dataclasses import dataclass, field
from datetime import date, datetime
from decimal import Decimal
from typing import Any, Final

from django.db import IntegrityError, transaction
from django.utils import timezone

from infrastructure.common.errors import ApiError
from infrastructure.common.responses import ResponseTitle
from infrastructure.projects import services as projects
from infrastructure.projects.models import Project
from infrastructure.sprints import clock, snapshots, tally
from infrastructure.sprints.models import EventKind, ScopeEvent, Sprint, State
from infrastructure.sprints.signals import announce
from infrastructure.tasks import fields
from infrastructure.tasks import services as tasks
from infrastructure.tasks.models import Task
from infrastructure.tasks.signals import announce as announce_task
from infrastructure.workflows.models import Category
from infrastructure.workspaces import access
from infrastructure.workspaces.models import Workspace

VIEW = "workspace.view"
MANAGE = "sprint.manage"
FEATURE = "sprints"
NAME_MAX: Final = 80
GOAL_MAX: Final = 500
MAX_DAYS: Final = 366
BACKLOG_DEFAULT: Final = 200
BACKLOG_MAX: Final = 500
SPRINT_TASKS_MAX: Final = 1000
CARRY_NEXT: Final = "next"
CARRY_BACKLOG: Final = "backlog"
LIVE = (State.PLANNED, State.ACTIVE)
CAPACITY_SEC_MAX: Final = 100_000 * 3600
EDITABLE: Final = ("name", "goal", "start_date", "end_date", "capacity_points", "capacity_sec")


def _bad(message: str) -> ApiError:
    return ApiError(message, status=400, title=ResponseTitle.VALIDATION_ERROR)


def not_found() -> ApiError:
    return ApiError("No such sprint.", status=404)


@dataclass(frozen=True, slots=True)
class Outcome:
    """A sprint after a change, with what the caller should be told about it."""

    sprint: Sprint
    warnings: tuple[str, ...] = ()


@dataclass(frozen=True, slots=True)
class SprintView:
    sprint: Sprint
    counts: tally.Tally


@dataclass(frozen=True, slots=True)
class TaskRow:
    task: Task
    late: bool  # added after the sprint started


@dataclass(slots=True)
class Moved:
    sprint: Sprint
    changed: int
    late: int  # how many of them are scope changes (the sprint is active)
    warnings: list[str] = field(default_factory=list)


def feature_on(project: Project) -> bool:
    return FEATURE in projects.enabled_features(project)


def _project(
    actor: Any, workspace: Workspace, project_id: str, key: str, *, lock: bool = False
) -> Project:
    """The visible project with *Sprints* on; for a change also open for writing."""
    access.require(actor, VIEW, workspace)
    if key != VIEW:
        access.require(actor, key, workspace)
    project = projects.load(actor, workspace, project_id, lock=lock)
    if not feature_on(project):
        raise _bad("Sprints are switched off for this project.")
    if key != VIEW:
        projects.writable(project)
    return project


def _sprint(project: Project, sprint_id: str, *, lock: bool = False) -> Sprint:
    try:
        pk = uuid.UUID(str(sprint_id))
    except ValueError:
        raise not_found() from None
    rows = Sprint.objects.filter(pk=pk, project=project)
    row = (rows.select_for_update() if lock else rows).first()
    if row is None:
        raise not_found()
    return row


# -- validation ------------------------------------------------------------------------------


def _name(value: str) -> str:
    name = value.strip()
    if not name or len(name) > NAME_MAX:
        raise _bad(f"A sprint name is 1 to {NAME_MAX} characters.")
    return name


def _goal(value: str) -> str:
    goal = value.strip()
    if len(goal) > GOAL_MAX:
        raise _bad(f"A sprint goal is at most {GOAL_MAX} characters.")
    return goal


def _capacity_points(value: str) -> Decimal | None:
    return fields.clean_points(value.strip())


def _capacity_sec(value: str | int) -> int | None:
    """Seconds of work the team can take on; empty (or 0) means none was set."""
    text = str(value).strip()
    if text in ("", "0"):
        return None
    try:
        seconds = int(text)
    except ValueError:
        raise _bad("The capacity in hours must be a number.") from None
    if not 0 < seconds <= CAPACITY_SEC_MAX:
        raise _bad("The capacity in hours must be between 0 and 100000 hours.")
    return seconds


def _day(value: str, label: str) -> date:
    try:
        return date.fromisoformat(value)
    except ValueError:
        raise _bad(f"The {label} must be a date like 2026-11-30.") from None


def _check_range(start: date, end: date) -> None:
    if end < start:
        raise _bad("A sprint cannot end before it starts.")
    if (end - start).days >= MAX_DAYS:
        raise _bad(f"A sprint is at most {MAX_DAYS} days long.")


def _overlaps(project: Project, start: date, end: date, *, exclude: Any = None) -> list[str]:
    rows = Sprint.objects.filter(
        project=project, state__in=LIVE, start_date__lte=end, end_date__gte=start
    )
    if exclude is not None:
        rows = rows.exclude(pk=exclude)
    return [f'These dates overlap "{s.name}".' for s in rows.order_by("start_date", "created_at")]


def _bump(sprint: Sprint, now: datetime, **changes: Any) -> None:
    for name, value in changes.items():
        setattr(sprint, name, value)
    sprint.version += 1
    sprint.updated_at = now
    sprint.save()


# -- reading ---------------------------------------------------------------------------------


def _order(sprint: Sprint) -> tuple[int, int, datetime]:
    """Active first, then planned by start, then completed with the latest first."""
    if sprint.state == State.ACTIVE:
        return (0, 0, sprint.created_at)
    if sprint.state == State.PLANNED:
        return (1, sprint.start_date.toordinal(), sprint.created_at)
    return (2, -sprint.start_date.toordinal(), sprint.created_at)


def list_sprints(
    actor: Any, workspace: Workspace, project_id: str, states: Iterable[str] = ()
) -> list[SprintView]:
    """The project's sprints (optionally only those in ``states``), with their live counts."""
    project = _project(actor, workspace, project_id, VIEW)
    wanted = {s for s in states if s}
    unknown = wanted - set(State.values)
    if unknown:
        raise _bad(f"Unknown sprint state: {sorted(unknown)[0]}.")
    rows = Sprint.objects.filter(project=project)
    if wanted:
        rows = rows.filter(state__in=wanted)
    found = sorted(rows, key=_order)
    counts = tally.tallies([s.pk for s in found])
    return [SprintView(s, counts[s.pk]) for s in found]


def get_view(actor: Any, workspace: Workspace, project_id: str, sprint_id: str) -> SprintView:
    project = _project(actor, workspace, project_id, VIEW)
    sprint = _sprint(project, sprint_id)
    return SprintView(sprint, tally.tally(sprint))


def _late_ids(sprint: Sprint) -> set[Any]:
    return set(
        ScopeEvent.objects.filter(
            sprint=sprint, after_start=True, kind=EventKind.ADDED, task__sprint=sprint
        ).values_list("task_id", flat=True)
    )


def sprint_tasks(
    actor: Any, workspace: Workspace, project_id: str, sprint_id: str
) -> list[TaskRow]:
    project = _project(actor, workspace, project_id, VIEW)
    sprint = _sprint(project, sprint_id)
    late = _late_ids(sprint)
    rows = (
        tally.members(sprint)
        .select_related("project", "status")
        .order_by("position", "number")[:SPRINT_TASKS_MAX]
    )
    return [TaskRow(t, t.pk in late) for t in rows]


def backlog(
    actor: Any, workspace: Workspace, project_id: str, limit: int = 0
) -> tuple[list[Task], int]:
    """Open top-level tasks that are in no planned or active sprint (a task reopened after its
    sprint finished is back here), in board order, and how many there are in all."""
    project = _project(actor, workspace, project_id, VIEW)
    size = min(limit, BACKLOG_MAX) if limit > 0 else BACKLOG_DEFAULT
    rows = (
        tasks.live_rows(project)
        .filter(status__category__in=tally.OPEN)
        .exclude(sprint__state__in=LIVE)
    )
    page = list(rows.select_related("project", "status").order_by("position", "number")[:size])
    return page, rows.count()


# -- plan ------------------------------------------------------------------------------------


def create(
    actor: Any,
    workspace: Workspace,
    project_id: str,
    name: str,
    goal: str,
    start_date: str,
    end_date: str,
    capacity_points: str = "",
    capacity_sec: str | int = "",
) -> Outcome:
    start, end = _day(start_date, "start date"), _day(end_date, "end date")
    _check_range(start, end)
    clean_name, clean_goal = _name(name), _goal(goal)
    points_capacity, sec_capacity = _capacity_points(capacity_points), _capacity_sec(capacity_sec)
    with transaction.atomic():
        project = _project(actor, workspace, project_id, MANAGE, lock=True)
        now = timezone.now()
        sprint = Sprint.objects.create(
            workspace=workspace,
            project=project,
            name=clean_name,
            goal=clean_goal,
            start_date=start,
            end_date=end,
            capacity_points=points_capacity,
            capacity_sec=sec_capacity,
            created_at=now,
            updated_at=now,
        )
        announce(sprint, "created")
        warnings = _overlaps(project, start, end, exclude=sprint.pk)
    return Outcome(sprint, tuple(warnings))


def update(
    actor: Any,
    workspace: Workspace,
    project_id: str,
    sprint_id: str,
    changes: dict[str, str],
    expected_version: int = 0,
) -> Outcome:
    """Change name, goal, dates, capacity. A planned sprint takes all; an active one cannot move
    its start (its baseline is fixed) but may be renamed and extended; a completed one is history.
    With ``expected_version`` the change is refused (409) if the sprint changed since."""
    unknown = set(changes) - set(EDITABLE)
    if unknown:
        raise _bad(f"Cannot change {sorted(unknown)[0]}.")
    if not changes:
        raise _bad("Send at least one field to change.")
    with transaction.atomic():
        project = _project(actor, workspace, project_id, MANAGE, lock=True)
        sprint = _sprint(project, sprint_id, lock=True)
        if sprint.state == State.COMPLETED:
            raise _bad("A completed sprint cannot be changed.")
        if expected_version and expected_version != sprint.version:
            raise ApiError(
                "The sprint changed since you read it.",
                status=409,
                title=ResponseTitle.VERSION_CONFLICT,
            )
        values: dict[str, Any] = {}
        if "name" in changes:
            values["name"] = _name(changes["name"])
        if "goal" in changes:
            values["goal"] = _goal(changes["goal"])
        if "start_date" in changes:
            values["start_date"] = _day(changes["start_date"], "start date")
            if sprint.state == State.ACTIVE and values["start_date"] != sprint.start_date:
                raise _bad("An active sprint's start date is fixed.")
        if "end_date" in changes:
            values["end_date"] = _day(changes["end_date"], "end date")
        if "capacity_points" in changes:
            values["capacity_points"] = _capacity_points(changes["capacity_points"])
        if "capacity_sec" in changes:
            values["capacity_sec"] = _capacity_sec(changes["capacity_sec"])
        start = values.get("start_date", sprint.start_date)
        end = values.get("end_date", sprint.end_date)
        _check_range(start, end)
        _bump(sprint, timezone.now(), **values)
        announce(sprint, "updated")
        warnings = _overlaps(project, start, end, exclude=sprint.pk)
    return Outcome(sprint, tuple(warnings))


# -- start and complete ----------------------------------------------------------------------


def start(
    actor: Any, workspace: Workspace, project_id: str, sprint_id: str, now: datetime | None = None
) -> Outcome:
    """Make a planned sprint the project's active one and fix its baseline scope. One active
    sprint per project: starting a second is refused (409). A start date still ahead is brought
    to today."""
    now = now or timezone.now()
    with transaction.atomic():
        project = _project(actor, workspace, project_id, MANAGE, lock=True)
        sprint = _sprint(project, sprint_id, lock=True)
        if sprint.state != State.PLANNED:
            raise _bad("Only a planned sprint can be started.")
        running = Sprint.objects.filter(project=project, state=State.ACTIVE).first()
        if running is not None:
            raise ApiError(f'"{running.name}" is already active. Complete it first.', status=409)
        today = clock.local_date(clock.zone_of(workspace), now)
        counts = tally.tally(sprint)
        changes: dict[str, Any] = {
            "state": State.ACTIVE,
            "started_at": now,
            "baseline_points": counts.open_points,
            "baseline_tasks": counts.open_tasks,
        }
        if sprint.start_date > today:
            changes["start_date"] = today
        try:
            with transaction.atomic():
                _bump(sprint, now, **changes)
        except IntegrityError:  # another request started one between the check and the write
            raise ApiError("Another sprint is already active.", status=409) from None
        announce(sprint, "updated")
    return Outcome(sprint)


def _next_planned(project: Project, sprint: Sprint, next_sprint_id: str) -> Sprint:
    if next_sprint_id:
        target = _sprint(project, next_sprint_id, lock=True)
        if target.pk == sprint.pk or target.state != State.PLANNED:
            raise _bad("Tasks can only move on to a planned sprint.")
        return target
    target = (
        Sprint.objects.select_for_update()
        .filter(project=project, state=State.PLANNED)
        .order_by("start_date", "created_at")
        .first()
    )
    if target is None:
        raise _bad("There is no planned sprint to move the unfinished tasks to. Plan one first.")
    return target


def complete(
    actor: Any,
    workspace: Workspace,
    project_id: str,
    sprint_id: str,
    carry_over: str,
    next_sprint_id: str = "",
    now: datetime | None = None,
) -> Outcome:
    """Finish the active sprint. Tasks in a *Done* status are finished (and stay in it, for
    velocity); the other open ones go to ``carry_over`` = ``next`` (the planned sprint named, else
    the earliest) or ``backlog``."""
    if carry_over not in (CARRY_NEXT, CARRY_BACKLOG):
        raise _bad(f"carry_over is {CARRY_NEXT} or {CARRY_BACKLOG}.")
    now = now or timezone.now()
    with transaction.atomic():
        project = _project(actor, workspace, project_id, MANAGE, lock=True)
        sprint = _sprint(project, sprint_id, lock=True)
        if sprint.state != State.ACTIVE:
            raise _bad("Only an active sprint can be completed.")
        target = (
            _next_planned(project, sprint, next_sprint_id) if carry_over == CARRY_NEXT else None
        )
        snapshots.close(sprint, now)  # the last day's point, with the unfinished tasks still in
        counts = tally.tally(sprint)
        leaving = list(
            tally.members(sprint)
            .filter(status__category__in=tally.OPEN)
            .select_for_update(of=("self",))
        )
        for task in leaving:
            _set_sprint(task, target, now)
            if target is not None:
                _event(target, task, EventKind.ADDED, now)
        _bump(
            sprint,
            now,
            state=State.COMPLETED,
            completed_at=now,
            completed_points=counts.done_points,
            completed_tasks=counts.done_tasks,
            unfinished_tasks=len(leaving),
        )
        announce(sprint, "updated")
        if target is not None:
            _bump(target, now)
            announce(target, "updated")
    return Outcome(sprint)


# -- tasks in and out ------------------------------------------------------------------------


def _set_sprint(task: Task, sprint: Sprint | None, now: datetime) -> None:
    task.sprint = sprint
    task.version += 1
    task.field_versions = {**task.field_versions, "sprint": task.version}
    task.updated_at = now
    task.save(update_fields=["sprint", "version", "field_versions", "updated_at"])
    announce_task(task, "updated")


def _event(
    sprint: Sprint, task: Task, kind: str, now: datetime, delta: Decimal | None = None
) -> None:
    points = task.points or tally.ZERO
    sign = -1 if kind == EventKind.REMOVED else 1
    ScopeEvent.objects.create(
        sprint=sprint,
        task=task,
        kind=kind,
        delta_points=delta if delta is not None else sign * points,
        delta_tasks=0 if kind == EventKind.POINTS else sign,
        after_start=sprint.state == State.ACTIVE,
        at=now,
    )


def _ids(raw: Sequence[str]) -> list[uuid.UUID]:
    if not raw:
        raise _bad("Name at least one task.")
    found = tasks.valid_uuids(raw)
    if len(found) != len(raw):
        raise tasks.not_found()
    return list(dict.fromkeys(found))


def add_tasks(
    actor: Any,
    workspace: Workspace,
    project_id: str,
    sprint_id: str,
    task_ids: Sequence[str],
    now: datetime | None = None,
) -> Moved:
    """Put tasks of the project into a planned or active sprint (leaving the sprint they were in).
    Into an active sprint they are a scope change, flagged as added after the start."""
    now = now or timezone.now()
    wanted = _ids(task_ids)
    with transaction.atomic():
        project = _project(actor, workspace, project_id, MANAGE, lock=True)
        sprint = _sprint(project, sprint_id, lock=True)
        if sprint.state == State.COMPLETED:
            raise _bad("A completed sprint cannot take tasks.")
        rows = list(
            Task.objects.select_for_update(of=("self",))
            .filter(pk__in=wanted, project=project, deleted_at__isnull=True)
            .select_related("sprint", "status", "project")
        )
        if len(rows) != len(wanted):
            raise tasks.not_found()
        for t in rows:
            if (
                t.sprint is not None
                and t.sprint.state == State.COMPLETED
                and t.status.category == Category.DONE
            ):
                raise _bad(f"{t.display_id} was finished in {t.sprint.name}.")
        changed = 0
        for t in (r for r in rows if r.sprint_id != sprint.pk):
            previous = t.sprint
            if previous is not None and previous.state in LIVE:
                _event(previous, t, EventKind.REMOVED, now)
                _bump(previous, now)
                announce(previous, "updated")
            _set_sprint(t, sprint, now)
            _event(sprint, t, EventKind.ADDED, now)
            changed += 1
        if changed:
            _bump(sprint, now)
            announce(sprint, "updated")
        late = changed if sprint.state == State.ACTIVE else 0
    return Moved(sprint, changed, late)


def remove_tasks(
    actor: Any,
    workspace: Workspace,
    project_id: str,
    sprint_id: str,
    task_ids: Sequence[str],
    now: datetime | None = None,
) -> Moved:
    """Send tasks of a planned or active sprint back to the backlog (from an active one it is a
    scope change)."""
    now = now or timezone.now()
    wanted = _ids(task_ids)
    with transaction.atomic():
        project = _project(actor, workspace, project_id, MANAGE, lock=True)
        sprint = _sprint(project, sprint_id, lock=True)
        if sprint.state == State.COMPLETED:
            raise _bad("A completed sprint cannot lose tasks.")
        rows = list(
            Task.objects.select_for_update(of=("self",))
            .filter(pk__in=wanted, project=project, sprint=sprint)
            .select_related("status", "project")
        )
        if len(rows) != len(wanted):
            raise tasks.not_found()
        for t in rows:
            _set_sprint(t, None, now)
            if t.deleted_at is None:
                _event(sprint, t, EventKind.REMOVED, now)
        if rows:
            _bump(sprint, now)
            announce(sprint, "updated")
        late = len(rows) if sprint.state == State.ACTIVE else 0
    return Moved(sprint, len(rows), late)


def set_points(
    actor: Any,
    workspace: Workspace,
    project_id: str,
    task_id: str,
    points: str,
    expected_version: int = 0,
    now: datetime | None = None,
) -> Task:
    """Set (or with an empty value clear) a task's story points. Needs ``task.update``. In an
    active sprint the change is a scope change."""
    now = now or timezone.now()
    new = fields.clean_points(points.strip())
    with transaction.atomic():
        project = tasks.open_for_write(actor, workspace, project_id, "task.update")
        if not feature_on(project):
            raise _bad("Sprints are switched off for this project.")
        current = tasks.load_task(project, task_id, lock=True)
        was = current.points or tally.ZERO
        changed = tasks.update(
            actor,
            workspace,
            project_id,
            task_id,
            expected_version or current.version,
            {"points": points.strip()},
            allow_points=True,
        )
        delta = (new or tally.ZERO) - was
        sprint = Sprint.objects.filter(pk=changed.sprint_id, state=State.ACTIVE).first()
        if sprint is not None and delta:
            _event(sprint, changed, EventKind.POINTS, now, delta)
    return changed
