"""My work: every task assigned to the viewer or watched by them, across the projects they can
open, with the shared toolbar's TFQL filter (the fields that mean the same in every project)."""

from typing import Any, Final

from django.db.models import Exists, F, OuterRef, Q

from infrastructure.common.errors import ApiError
from infrastructure.filters import query as filter_query
from infrastructure.home.summary import OPEN, Item, item_of, visible_project_ids
from infrastructure.inbox.models import Watcher
from infrastructure.tasks.models import Task, TaskAssignee
from infrastructure.workspaces import access
from infrastructure.workspaces.models import Workspace

RELATIONS: Final = ("", "assigned", "watching")
PAGE_DEFAULT: Final = 50
PAGE_MAX: Final = 100


def my_work(
    actor: Any,
    workspace: Workspace,
    *,
    relation: str = "",
    include_done: bool = False,
    filter_ast: str = "",
    today: str = "",
    cursor: str = "",
    limit: int = 0,
) -> tuple[list[tuple[Item, bool, bool]], str]:
    """``(item, assigned, watching)`` rows by due date (undated last) and the next cursor
    (``''`` at the end). ponytail: the cursor is an offset, so a list that changes between pages
    can repeat or skip a row; use keyset paging if My work grows long."""
    access.require(actor, "workspace.view", workspace)
    if relation not in RELATIONS:
        raise ApiError(f"The relation is one of {', '.join(repr(r) for r in RELATIONS)}.")
    try:
        offset = int(cursor or 0)
    except ValueError:
        offset = -1
    if offset < 0:
        raise ApiError("That is not a place in the list.")
    size = max(1, min(limit or PAGE_DEFAULT, PAGE_MAX))
    assigned = Exists(TaskAssignee.objects.filter(task=OuterRef("pk"), user=actor))
    watching = Exists(Watcher.objects.filter(task=OuterRef("pk"), user=actor))
    prepared = filter_query.prepare_workspace(workspace, filter_ast, today, actor)
    rows = Task.objects.filter(
        workspace=workspace,
        project__in=visible_project_ids(actor, workspace),
        deleted_at__isnull=True,
    ).annotate(is_assigned=assigned, is_watching=watching)
    rows = rows.filter(
        Q(is_assigned=True)
        if relation == "assigned"
        else Q(is_watching=True)
        if relation == "watching"
        else Q(is_assigned=True) | Q(is_watching=True)
    )
    if not include_done:
        rows = rows.filter(status__category__in=OPEN)
    if prepared.where:
        rows = rows.filter(prepared.where)
    ordered = rows.select_related("project", "status").order_by(
        F("due_date").asc(nulls_last=True), "project__key", "number"
    )
    found = filter_query.guarded(lambda: list(ordered[offset : offset + size + 1]), prepared.where)
    page = [(item_of(t), t.is_assigned, t.is_watching) for t in found[:size]]
    return page, str(offset + size) if len(found) > size else ""
