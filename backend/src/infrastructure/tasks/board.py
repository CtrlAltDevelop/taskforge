"""The board: a project's top-level tasks as cards in columns.

Columns come from one field (``group_by``: status, priority, assignee or a select field), and may
be split into swimlanes by assignee. ``get`` answers the whole board in one call (every column
with its count and its first cards); ``list_column`` pages one column further. Cards of a column
are in rank order (``Task.position``), so a drop only changes the dropped task: ``move_card``
changes its field when the column differs (through ``services``, so the workflow, blockers and
permissions apply exactly as for an edit) and gives it a rank between its new neighbours.

Subtasks are not cards: a parent's card shows their progress.
"""

import uuid
from dataclasses import dataclass, field
from typing import Any, Final

from django.db import transaction
from django.db.models import Count

from infrastructure.common.errors import ApiError
from infrastructure.filters import query as filter_query
from infrastructure.projects.models import Project
from infrastructure.tasks import listing, rank, services, tree
from infrastructure.tasks.models import Priority, Task, TaskAssignee
from infrastructure.tasks.signals import announce
from infrastructure.workflows.models import Status
from infrastructure.workspaces.models import Workspace

PAGE: Final = 30
REBALANCE_AT: Final = 24  # a rank longer than this makes the server respace the project
NO_VALUE: Final = "No value"
UNASSIGNED: Final = "Unassigned"
LANE_KEYS: Final = ("", "assignee")
UUID_AXES: Final = ("status", "assignee")


@dataclass(frozen=True, slots=True)
class Column:
    """``key`` is what a card in it holds (a status id, a priority, a user id, an option id; ``""``
    for tasks with no value). ``name`` is empty for people, which the client names itself."""

    key: str
    name: str
    count: int
    tasks: list[Task] = field(default_factory=list)
    cursor: str = ""


@dataclass(frozen=True, slots=True)
class Lane:
    key: str
    columns: list[Column]


def _axis_of(project: Project, group_by: str) -> tuple[listing.Group, str]:
    group = listing.group_of(project, group_by)  # refuses what cannot be a column
    return group, group_by


def _choices(project: Project, group_by: str) -> list[tuple[str, str]]:
    """The columns that exist whether or not they hold a card, in order (people come from the
    cards, see ``_axis``)."""
    if group_by == "status":
        statuses = Status.objects.filter(project=project).order_by("position", "name")
        return [(str(s.pk), s.name) for s in statuses]
    if group_by == "priority":
        return [(p, Priority(p).label) for p in listing.PRIORITY_ORDER]
    if group_by == "assignee":
        return []
    definition = listing.field_of(project, group_by.removeprefix(listing.FIELD_PREFIX))
    return [(o["id"], o["label"]) for o in definition.options]


def _axis(project: Project, group_by: str, present: set[str]) -> list[tuple[str, str]]:
    choices = _choices(project, group_by)
    if group_by in ("status", "priority"):
        return choices
    if group_by == "assignee":
        people = sorted(k for k in present if k)
        return [(k, "") for k in people] + [("", UNASSIGNED)]
    return [*choices, ("", NO_VALUE)]


def _where(rows: Any, name: str, group: listing.Group, group_by: str, key: str) -> Any:
    rows = rows.annotate(**{name: group.ident})
    if key == "":
        return rows.filter(**{f"{name}__isnull": True})
    if group_by in UUID_AXES:
        try:
            uuid.UUID(key)
        except ValueError:
            return rows.none()
    return rows.filter(**{name: key})


def _tally(
    rows: Any, col: tuple[listing.Group, str], lane: tuple[listing.Group, str] | None
) -> dict[tuple[str, str], int]:
    """Live top-level tasks per ``(lane key, column key)``."""
    annotations = {"_c": col[0].ident, **({"_l": lane[0].ident} if lane else {})}
    names = ("_l", "_c") if lane else ("_c",)
    found = rows.annotate(**annotations).order_by().values(*names).annotate(_n=Count("pk"))
    return {
        (
            listing.ident(r["_l"], True) if lane else "",
            listing.ident(r["_c"], col[1] == "assignee"),
        ): r["_n"]
        for r in found
    }


def _cell(
    project: Project,
    col: tuple[listing.Group, str],
    column: str,
    lane: tuple[listing.Group, str] | None,
    lane_key: str,
    extra: Any = None,
) -> Any:
    rows = _where(services.live_rows(project, extra=extra), "_c", col[0], col[1], column)
    if lane is not None:
        rows = _where(rows, "_l", lane[0], lane[1], lane_key)
    return listing.plan(project, (), "").order(rows)


def _lane(swimlane: str, project: Project) -> tuple[listing.Group, str] | None:
    if swimlane not in LANE_KEYS:
        raise ApiError(f"Cannot split a board into lanes by {swimlane!r}.")
    return _axis_of(project, swimlane) if swimlane else None


def get(
    actor: Any,
    workspace: Workspace,
    project_id: str,
    *,
    group_by: str = "status",
    swimlane: str = "",
    limit: int = PAGE,
    filter_ast: str = "",
    today: str = "",
) -> list[Lane]:
    """Every lane (one, with key ``""``, when there is no swimlane) with its columns, their
    counts and their first ``limit`` cards."""
    project = services.project_for_view(actor, workspace, project_id)
    col = _axis_of(project, group_by)
    lane = _lane(swimlane, project)
    extra = filter_query.prepare(project, filter_ast, today, actor).where
    tally = filter_query.guarded(
        lambda: _tally(services.live_rows(project, extra=extra), col, lane), extra
    )
    columns = _axis(project, group_by, {c for _, c in tally})
    lanes = _axis(project, "assignee", {k for k, _ in tally}) if lane else [("", "")]
    plan = listing.plan(project, (), "")
    result = []
    for lane_key, _ in lanes:
        built = []
        for key, name in columns:
            count = tally.get((lane_key, key), 0)
            cards: list[Task] = []
            cursor = ""
            if count:
                cards, more = services.fetch_page(
                    actor, workspace, _cell(project, col, key, lane, lane_key, extra), limit, extra
                )
                cursor = plan.cursor_of(cards[-1]) if more else ""
            built.append(Column(key, name, count, cards, cursor))
        result.append(Lane(lane_key, built))
    return result


def list_column(
    actor: Any,
    workspace: Workspace,
    project_id: str,
    *,
    group_by: str,
    column: str,
    lane: str = "",
    swimlane: str = "",
    cursor: str = "",
    limit: int = PAGE,
    filter_ast: str = "",
    today: str = "",
) -> tuple[list[Task], str]:
    """One page of a column (of one lane's cell, with ``swimlane``) after ``cursor``, and the
    cursor of the next page (``""`` at the end)."""
    project = services.project_for_view(actor, workspace, project_id)
    col = _axis_of(project, group_by)
    lane_axis = _lane(swimlane, project)
    plan = listing.plan(project, (), "")
    extra = filter_query.prepare(project, filter_ast, today, actor).where
    rows = _cell(project, col, column, lane_axis, lane, extra)
    if cursor:
        rows = plan.after(rows, cursor)
    cards, more = services.fetch_page(actor, workspace, rows, limit, extra)
    return cards, plan.cursor_of(cards[-1]) if more else ""


# ------------------------------------------------------------------------------- moving a card


def _key_of(project: Project, group: listing.Group, group_by: str, task: Task) -> str:
    row = (
        Task.objects.filter(pk=task.pk).annotate(_c=group.ident).values_list("_c", flat=True).get()
    )
    return listing.ident(row, group_by == "assignee")


def _changes(group_by: str, column: str, task: Task) -> dict[str, Any]:
    if group_by == "status":
        return {"status": column}
    if group_by == "priority":
        return {"priority": column}
    if group_by == "assignee":
        # The card sits under its first assignee: swap that one, keep the others.
        people = [
            str(u)
            for u in TaskAssignee.objects.filter(task=task)
            .order_by("id")
            .values_list("user_id", flat=True)
        ]
        rest = [p for p in people[1:] if p != column]
        return {"assignee_ids": [*([column] if column else []), *rest]}
    return {"field_values": {group_by.removeprefix(listing.FIELD_PREFIX): column}}


def _neighbour(project: Project, task: Task, task_id: str) -> Task | None:
    """The top-level task to drop next to (``None`` for none, or for the dropped card itself)."""
    if not task_id or task_id == str(task.pk):
        return None
    found = Task.objects.filter(
        project=project, pk__in=services.valid_uuids([task_id]), parent__isnull=True
    ).first()
    if found is None:
        raise services.not_found()
    return found


def _siblings(project: Project, task: Task) -> Any:
    return Task.objects.filter(project=project, parent__isnull=True).exclude(pk=task.pk)


def _rank_for(project: Project, task: Task, after: Task | None, before: Task | None) -> str:
    """A rank for ``task`` right after ``after`` and right before ``before`` (either may be
    missing: then it sits next to the one given, or last). Neighbours that no longer sort in
    that order (someone else moved a card meanwhile) fall back to "right after ``after``"."""
    siblings = _siblings(project, task).order_by("position")
    low = after.position if after else None
    high = before.position if before else None
    if low is not None and high is not None and low >= high:
        high = None
    if low is None and high is None:
        last = siblings.values_list("position", flat=True).last()
        return rank.after(last)
    if low is not None and high is None:
        high = siblings.filter(position__gt=low).values_list("position", flat=True).first()
    if low is None and high is not None:
        low = siblings.filter(position__lt=high).values_list("position", flat=True).last()
    chosen = rank.between(low, high)
    while _siblings(project, task).filter(position=chosen).exists():  # two drops, one gap
        chosen = rank.between(chosen, high)
    return chosen


def move_card(
    actor: Any,
    workspace: Workspace,
    project_id: str,
    task_id: str,
    *,
    group_by: str,
    column: str,
    expected_version: int,
    before_id: str = "",
    after_id: str = "",
    with_subtasks: bool = False,
    override_blocked: bool = False,
) -> Task:
    """Drop ``task_id`` in ``column`` (of a board grouped by ``group_by``), right after
    ``after_id`` and before ``before_id`` (neither: last). A different column changes the
    task's field like any edit (``expected_version`` is checked then; the workflow, blockers and
    permissions apply, a refusal changes nothing); a drop inside its own column only changes its
    place, which never conflicts. A subtask is not a card: it is moved from the task screen."""
    with transaction.atomic():
        project = services.lock_for_write(actor, workspace, project_id, "task.update")
        task = services.load_task(project, task_id, lock=True)
        if task.parent_id is not None:
            raise ApiError("Only a top-level task can be moved on the board.")
        group, _ = _axis_of(project, group_by)
        after = _neighbour(project, task, after_id)
        before = _neighbour(project, task, before_id)
        same_column = column == _key_of(project, group, group_by, task)
        if same_column and after is None and before is None and task_id in (after_id, before_id):
            return services.present(task, actor, workspace)  # dropped back on itself
        if not same_column:
            changes = _changes(group_by, column, task)
            if group_by == "status":
                services.move(
                    actor,
                    workspace,
                    project_id,
                    task_id,
                    expected_version,
                    column,
                    with_subtasks=with_subtasks,
                    override_blocked=override_blocked,
                )
            else:
                services.update(
                    actor,
                    workspace,
                    project_id,
                    task_id,
                    expected_version,
                    changes,
                    override_blocked=override_blocked,
                )
            task = services.load_task(project, task_id, lock=True)
        tree.reposition(task, _rank_for(project, task, after, before))
        if len(task.position) > REBALANCE_AT:
            tree.rebalance(project.pk)
        announce(task, "moved")
    return services.present(task, actor, workspace)
