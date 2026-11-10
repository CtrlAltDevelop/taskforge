"""The calendar: tasks by their dates, for the range a screen shows.

Dates are date-only values (no time zone): a due date of 5 Nov is 5 Nov everywhere, so a range
is two calendar days and is compared as days, never shifted. A task with both dates covers every
day from start to due; with one date it sits on that day. ``list_unscheduled`` is the tray of
open tasks with neither date. Changing a date is an ordinary ``services.update``.
"""

from collections.abc import Iterator
from datetime import date, timedelta
from typing import Any, Final

from django.db.models import Q

from infrastructure.common.errors import ApiError
from infrastructure.tasks import links, services
from infrastructure.tasks.models import Task
from infrastructure.workflows.models import Category
from infrastructure.workspaces.models import Workspace

MAX_DAYS: Final = 62  # a month grid is 42 days; two months of slack for an agenda
CHUNK: Final = 500
TRAY_PAGE: Final = 50


def _day(raw: str, name: str) -> date:
    try:
        return date.fromisoformat(raw)
    except ValueError:
        raise ApiError(f"{name} is a date like 2026-11-05.") from None


def iter_range(
    actor: Any,
    workspace: Workspace,
    project_id: str,
    first: str,
    last: str,
    *,
    include_done: bool = True,
) -> Iterator[list[Task]]:
    """Live tasks (subtasks too) that fall on any day from ``first`` to ``last`` inclusive,
    in task-number order, in chunks of ``CHUNK`` (all of them: no cap, each chunk follows the last
    number seen, so a task edited meanwhile is never listed twice)."""
    start, end = _day(first, "from"), _day(last, "to")
    if end < start:
        raise ApiError("The range ends before it starts.")
    if (end - start) > timedelta(days=MAX_DAYS):
        raise ApiError(f"Ask for at most {MAX_DAYS} days at a time.")
    project = services.project_for_view(actor, workspace, project_id)
    rows = services.live_rows(project, include_subtasks=True).filter(
        Q(due_date__range=(start, end))
        | Q(start_date__range=(start, end))
        | Q(start_date__lte=end, due_date__gte=start)
    )
    if not include_done:
        rows = rows.exclude(status__category__in=(Category.DONE, Category.CANCELLED))
    rows = rows.order_by("number")
    after = 0
    while True:
        chunk, more = services.fetch_page(actor, workspace, rows.filter(number__gt=after), CHUNK)
        links.mark_schedule(chunk, actor, workspace)
        if chunk:
            yield chunk
        if not more:
            return
        after = chunk[-1].number


def list_range(
    actor: Any, workspace: Workspace, project_id: str, first: str, last: str, **kw: Any
) -> list[Task]:
    return [
        t for chunk in iter_range(actor, workspace, project_id, first, last, **kw) for t in chunk
    ]


def list_unscheduled(
    actor: Any, workspace: Workspace, project_id: str, cursor: str = "", limit: int = TRAY_PAGE
) -> tuple[list[Task], str]:
    """Open tasks (subtasks too) with no start and no due date, by number, a page after
    ``cursor`` (the last number seen) and the cursor of the next page (``""`` at the end)."""
    project = services.project_for_view(actor, workspace, project_id)
    rows = (
        services.live_rows(project, include_subtasks=True)
        .filter(start_date__isnull=True, due_date__isnull=True)
        .exclude(status__category__in=(Category.DONE, Category.CANCELLED))
        .order_by("number")
    )
    if cursor:
        try:
            rows = rows.filter(number__gt=int(cursor))
        except ValueError:
            raise ApiError("That cursor is not valid.") from None
    size = max(1, min(limit or TRAY_PAGE, TRAY_PAGE * 4))
    page, more = services.fetch_page(actor, workspace, rows, size)
    return page, str(page[-1].number) if more else ""
