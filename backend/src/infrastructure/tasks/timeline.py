"""The timeline: the workspace's working-day calendar, and (below) what the chart reads and does.

Dates are date-only values, as in ``calendar``. The scheduling rules themselves are in
``schedule``; this module loads data for them and checks who may do what.
"""

from collections.abc import Iterator, Sequence
from dataclasses import dataclass
from datetime import date
from typing import Any, Final

from django.db import transaction
from django.db.models import Q

from infrastructure.common.errors import ApiError
from infrastructure.common.responses import ResponseTitle
from infrastructure.projects.models import Project
from infrastructure.tasks import calendar, fields, links, schedule, services
from infrastructure.tasks.models import LinkType, Task, TaskLink, WorkingCalendarSetting
from infrastructure.tasks.schedule import Item, WorkingCalendar
from infrastructure.tasks.tree import FINAL
from infrastructure.workspaces import access
from infrastructure.workspaces.models import Workspace

VIEW: Final = "workspace.view"
MANAGE: Final = "workspace.update"
MAX_HOLIDAYS: Final = 400
EVERY_DAY: Final = list(range(7))


def working_calendar(workspace: Workspace) -> WorkingCalendar:
    setting = WorkingCalendarSetting.objects.filter(workspace=workspace).first()
    if setting is None:
        return WorkingCalendar()
    return WorkingCalendar(
        days=frozenset(setting.days),
        holidays=frozenset(date.fromisoformat(h) for h in setting.holidays),
    )


def get_working_days(actor: Any, workspace: Workspace) -> tuple[list[int], list[str]]:
    """The working weekdays (all seven when never set) and the holidays, both sorted."""
    access.require(actor, VIEW, workspace)
    setting = WorkingCalendarSetting.objects.filter(workspace=workspace).first()
    if setting is None:
        return list(EVERY_DAY), []
    return sorted(setting.days) or list(EVERY_DAY), sorted(setting.holidays)


def _weekdays(raw: list[Any]) -> list[int]:
    if any(type(n) is not int or not 0 <= n <= 6 for n in raw):
        raise ApiError("A working day is a weekday number from 0 (Monday) to 6 (Sunday).")
    return sorted(set(raw))


def _holidays(raw: list[Any]) -> list[str]:
    if len(raw) > MAX_HOLIDAYS:
        raise ApiError(f"At most {MAX_HOLIDAYS} holidays.")
    try:
        return sorted({date.fromisoformat(h).isoformat() for h in raw})
    except (TypeError, ValueError):
        raise ApiError("A holiday is a date like 2026-12-25.") from None


def set_working_days(
    actor: Any, workspace: Workspace, days: list[Any], holidays: list[Any]
) -> tuple[list[int], list[str]]:
    """Replace the calendar (needs ``workspace.update``). No weekday at all means every day."""
    access.require(actor, MANAGE, workspace)
    clean_days, clean_holidays = _weekdays(list(days)), _holidays(list(holidays))
    with transaction.atomic():
        WorkingCalendarSetting.objects.update_or_create(
            workspace=workspace, defaults={"days": clean_days, "holidays": clean_holidays}
        )
    return clean_days or list(EVERY_DAY), clean_holidays


# --- the chart's data ------------------------------------------------------------------------

MAX_DAYS: Final = 1100  # three years: a quarter-zoom chart of a long roadmap
MAX_CASCADE: Final = 2000


def iter_chunks(
    actor: Any,
    workspace: Workspace,
    project_id: str,
    first: str,
    last: str,
    *,
    include_done: bool = True,
    filter_ast: str = "",
    today: str = "",
) -> Iterator[tuple[list[Task], list[tuple[str, str]]]]:
    """The chart's read: the tasks on any day from ``first`` to ``last`` (see ``calendar``, but up
    to ``MAX_DAYS`` apart) in chunks, each with the blocking links that touch them as
    ``(blocker, dependent)``. A link whose other end is outside the range is listed with the end
    that is inside; each link is listed once."""
    sent: set[tuple[str, str]] = set()
    for chunk in calendar.iter_range(
        actor,
        workspace,
        project_id,
        first,
        last,
        include_done=include_done,
        filter_ast=filter_ast,
        today=today,
        max_days=MAX_DAYS,
    ):
        fresh = [p for p in links.blocking_pairs(actor, workspace, chunk) if p not in sent]
        sent.update(fresh)
        yield chunk, fresh


def _item(task: Task) -> Item:
    return Item(task.start_date, task.due_date)


def critical_path(actor: Any, workspace: Workspace, project_id: str) -> list[str]:
    """Ids of the longest chain of linked, open, scheduled tasks of the project (see
    ``schedule.critical_path``), first blocker first; empty when none are linked."""
    project = services.project_for_view(actor, workspace, project_id)
    rows = (
        services.live_rows(project, include_subtasks=True)
        .exclude(status__category__in=FINAL)
        .filter(Q(start_date__isnull=False) | Q(due_date__isnull=False))
    )
    items = {str(t.pk): _item(t) for t in rows}
    ids = [t for t in items]
    edges = [
        (str(a), str(b))
        for a, b in TaskLink.objects.filter(
            type=LinkType.BLOCKS, from_task_id__in=ids, to_task_id__in=ids
        ).values_list("from_task_id", "to_task_id")
    ]
    return schedule.critical_path(items, edges, working_calendar(workspace))


@dataclass(frozen=True, slots=True)
class Shift:
    """A task a move pushes: where it is and where it would go."""

    task: Task
    old: Item
    new: Item


def _target(start: str, due: str) -> Item:
    first, last = fields.clean_date(start), fields.clean_date(due)
    if first is None and last is None:
        raise ApiError("Give a start date, a due date or both.")
    if first and last and last < first:
        raise ApiError("The due date is before the start date.")
    return Item(first, last)


def _dependents(
    actor: Any, workspace: Workspace, moved: Task
) -> tuple[dict[str, Task], list[schedule.Edge]]:
    """``moved`` and every open task it blocks, through any chain, in projects ``actor`` can open,
    with the links between them."""
    visible = links.visible_projects(actor, workspace)
    found = {str(moved.pk): moved}
    edges: list[schedule.Edge] = []
    frontier = [moved.pk]
    while frontier:
        rows = (
            TaskLink.objects.filter(type=LinkType.BLOCKS, from_task_id__in=frontier)
            .filter(to_task__deleted_at__isnull=True, to_task__project__in=visible)
            .filter(to_task__project__archived_at__isnull=True)  # a move there is refused
            .exclude(to_task__status__category__in=FINAL)
            .select_related("to_task__project", "to_task__status")
        )
        frontier = []
        for link in rows:
            edges.append((str(link.from_task_id), str(link.to_task_id)))
            if str(link.to_task_id) not in found:
                found[str(link.to_task_id)] = link.to_task
                frontier.append(link.to_task_id)
        if len(found) > MAX_CASCADE:
            raise ApiError(f"That move reaches more than {MAX_CASCADE} tasks.")
    return found, edges


def preview_shift(
    actor: Any, workspace: Workspace, project_id: str, task_id: str, start: str, due: str
) -> list[Shift]:
    """The dependents that would move if the task took these dates (its new start and due, one
    or both). Only a dependent that would start before its blockers finish moves; the rest stay.
    Nothing is changed."""
    task = services.get(actor, workspace, project_id, task_id)
    target = _target(start, due)
    found, edges = _dependents(actor, workspace, task)
    items = {key: _item(t) for key, t in found.items()}
    moved = schedule.cascade(items, edges, str(task.pk), target, working_calendar(workspace))
    pushed = [key for key in moved if key != str(task.pk)]
    shown = {
        str(t.pk): t for t in services.present_many([found[k] for k in pushed], actor, workspace)
    }
    return [
        Shift(shown[key], items[key], moved[key])
        for key in sorted(pushed, key=lambda k: (shown[k].project_id, shown[k].number))
    ]


def _changes(old: Item, new: Item) -> dict[str, Any]:
    out: dict[str, Any] = {}
    if new.start != old.start:
        out["start_date"] = new.start.isoformat() if new.start else ""
    if new.due != old.due:
        out["due_date"] = new.due.isoformat() if new.due else ""
    return out


def apply_shift(
    actor: Any,
    workspace: Workspace,
    project_id: str,
    task_id: str,
    expected_version: int,
    start: str,
    due: str,
    expected_ids: Sequence[str],
) -> list[Task]:
    """Give the task its dates and push its dependents, all in one transaction: either every task
    moves or none does. The cascade is worked out again here and must be exactly the tasks the
    caller previewed (``expected_ids``), else nothing moves and the caller previews again. Each
    task is updated as an ordinary edit, so versions, events and permissions apply."""
    access.require(actor, "task.update", workspace)
    with transaction.atomic():
        shifts = preview_shift(actor, workspace, project_id, task_id, start, due)
        if {str(s.task.pk) for s in shifts} != {str(i) for i in expected_ids}:
            raise ApiError(
                "The schedule changed since you previewed it. Preview again.",
                status=409,
                title=ResponseTitle.VERSION_CONFLICT,
            )
        first = services.get(actor, workspace, project_id, task_id)
        own = _changes(_item(first), _target(start, due))
        if not own:
            return []
        # Every project the moves touch, locked in one fixed order, so two cascades that cross
        # in opposite directions wait for each other instead of deadlocking.
        touched = {first.project_id, *(s.task.project_id for s in shifts)}
        list(Project.objects.select_for_update().filter(pk__in=touched).order_by("pk"))
        moved = [services.update(actor, workspace, project_id, task_id, expected_version, own)]
        for shift in shifts:
            task = shift.task
            moved.append(
                services.update(
                    actor,
                    workspace,
                    str(task.project_id),
                    str(task.pk),
                    task.version,
                    _changes(shift.old, shift.new),
                )
            )
    return moved
