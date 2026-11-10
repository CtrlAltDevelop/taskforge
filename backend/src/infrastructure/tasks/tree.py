"""The shape of subtasks: where a task sits, moving a whole subtree, and keeping progress true.

A task has at most one parent in its own project; ``depth`` is how far down it is (0 at the top,
at most ``MAX_DEPTH``). Every task stores ``path`` (the ids of all its ancestors and itself) so a
subtree is one prefix query, and ``tree_key`` (the ``position`` of each ancestor and itself) so the
list can come back in tree order from one index. Everything here runs inside the caller's
transaction, under the project row lock that every task write already takes, so two writers never
rewrite or count the same subtree at once.
"""

import uuid
from collections.abc import Iterable
from typing import Final

from django.db.models import CharField, Count, F, Q, QuerySet, Value
from django.db.models.functions import Concat, Substr
from django.utils import timezone

from infrastructure.common.errors import ApiError
from infrastructure.tasks import rank
from infrastructure.tasks.models import Task
from infrastructure.workflows.models import Category

MAX_DEPTH: Final = 24
PATH_SEP: Final = "/"
# Sorts before every rank character (lowercase letters) in any database collation, which a "/"
# would not: collations that ignore punctuation would order "a/b" after "ab".
SEP: Final = "0"
FINAL: Final = (Category.DONE, Category.CANCELLED)


def ancestor_ids(task: Task) -> list[uuid.UUID]:
    """The ids above ``task``, from the top down (empty for a top-level task)."""
    return [uuid.UUID(part) for part in task.path.split(PATH_SEP)[:-2] if part]


def placement(parent: Task | None, task_id: uuid.UUID, position: str) -> tuple[int, str, str]:
    """``(depth, path, tree_key)`` of a task with ``position`` under ``parent`` (None: the top)."""
    if parent is None:
        return 0, f"{task_id}{PATH_SEP}", f"{position}{SEP}"
    return (
        parent.depth + 1,
        f"{parent.path}{task_id}{PATH_SEP}",
        f"{parent.tree_key}{position}{SEP}",
    )


def check_depth(depth: int) -> None:
    if depth > MAX_DEPTH:
        raise ApiError(f"Subtasks can be nested at most {MAX_DEPTH} levels deep.")


def subtree_depth(task: Task) -> int:
    """How many levels the subtree under ``task`` has below it (0 when it has no subtasks)."""
    deepest = (
        Task.objects.filter(project_id=task.project_id, path__startswith=task.path)
        .order_by("-depth")
        .values_list("depth", flat=True)
        .first()
    )
    return (deepest or task.depth) - task.depth


def descendants(task: Task, *, live_only: bool = True) -> QuerySet[Task]:
    """Everything under ``task`` (not itself), optionally only tasks that are not deleted."""
    rows = Task.objects.filter(project_id=task.project_id, path__startswith=task.path).exclude(
        pk=task.pk
    )
    return rows.filter(deleted_at__isnull=True) if live_only else rows


def open_subtasks(task: Task) -> int:
    """Live subtasks that are not finished (a finished one is done or cancelled)."""
    return descendants(task).exclude(status__category__in=FINAL).count()


def next_position(
    project_id: uuid.UUID, parent_id: uuid.UUID | None, *, skip: uuid.UUID | None = None
) -> str:
    """A rank after the last child of ``parent_id`` (the last top-level task for None)."""
    siblings = Task.objects.filter(project_id=project_id, parent_id=parent_id)
    if skip is not None:
        siblings = siblings.exclude(pk=skip)
    last = siblings.order_by("-position").values_list("position", flat=True).first()
    return rank.after(last)


BULK_RECOUNT_AT: Final = 8


def refresh_progress(ids: Iterable[uuid.UUID]) -> None:
    """Recount the live descendants (and done ones) of each task in ``ids``. A few tasks (a
    new subtask's ancestors) are counted one by one; many at once (a workflow save, a whole
    subtree finished) are counted in one pass over their projects' live tasks."""
    wanted = set(ids)
    if not wanted:
        return
    if len(wanted) > BULK_RECOUNT_AT:
        _recount_many(wanted)
        return
    for task in Task.objects.filter(pk__in=wanted):
        counts = descendants(task).aggregate(
            total=Count("pk"), done=Count("pk", filter=Q(status__category=Category.DONE))
        )
        Task.objects.filter(pk=task.pk).update(
            progress_total=counts["total"], progress_done=counts["done"]
        )


def _recount_many(wanted: set[uuid.UUID]) -> None:
    rows = list(Task.objects.filter(pk__in=wanted))
    for project_id in {r.project_id for r in rows}:
        total: dict[str, int] = {}
        done: dict[str, int] = {}
        live = Task.objects.filter(project_id=project_id, deleted_at__isnull=True)
        for path, category in live.values_list("path", "status__category"):
            for ancestor in path.split(PATH_SEP)[:-2]:
                total[ancestor] = total.get(ancestor, 0) + 1
                if category == Category.DONE:
                    done[ancestor] = done.get(ancestor, 0) + 1
        mine = [r for r in rows if r.project_id == project_id]
        for row in mine:
            row.progress_total = total.get(str(row.pk), 0)
            row.progress_done = done.get(str(row.pk), 0)
        Task.objects.bulk_update(mine, ["progress_total", "progress_done"], batch_size=500)


def refresh_project(project_id: uuid.UUID) -> None:
    """Recount every task of the project that has (or had) subtasks: after a workflow save may
    have changed which statuses are done."""
    ids = (
        Task.objects.filter(project_id=project_id)
        .filter(Q(progress_total__gt=0) | Q(children__isnull=False))
        .values_list("pk", flat=True)
    )
    refresh_progress(set(ids))


def refresh_above(task: Task) -> None:
    """Recount every ancestor of ``task`` (after it, or something under it, changed)."""
    refresh_progress(ancestor_ids(task))


def move_subtree(task: Task, new_parent: Task | None) -> list[uuid.UUID]:
    """Re-parent ``task`` with everything under it; returns the ids whose progress changed
    (the old and the new ancestors). The caller checks that the move is allowed (no cycle, depth,
    same project) and bumps the task's version. Deleted descendants move too, so a later restore
    finds them in place."""
    old_path, old_key, old_depth = task.path, task.tree_key, task.depth
    old_above = ancestor_ids(task)
    position = next_position(task.project_id, new_parent.pk if new_parent else None, skip=task.pk)
    depth, path, key = placement(new_parent, task.pk, position)
    Task.objects.filter(project_id=task.project_id, path__startswith=old_path).update(
        path=Concat(Value(path), Substr("path", len(old_path) + 1), output_field=CharField()),
        tree_key=Concat(Value(key), Substr("tree_key", len(old_key) + 1), output_field=CharField()),
        depth=F("depth") + (depth - old_depth),
    )
    Task.objects.filter(pk=task.pk).update(
        parent=new_parent, position=position, updated_at=timezone.now()
    )
    task.parent, task.position = new_parent, position
    task.depth, task.path, task.tree_key = depth, path, key
    new_above = ancestor_ids(task)
    return [*old_above, *new_above]
