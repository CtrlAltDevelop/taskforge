"""Editing or deleting many tasks of one project at once.

The call as a whole is checked first (permission, project, the shape of the change): a mistake
there refuses everything and changes nothing. After that each task is its own transaction, so a
task that cannot take the change (blocked, not allowed by the workflow, already trashed, not in
this project) is reported by itself and never undoes or stops the rest. Results come one at a
time, in the order the work is done, which is what lets a client show progress.

A bulk edit is not an edit of a version the user was looking at, so it changes the task as it is
now (retrying if someone edits it in the very same moment) rather than answering a conflict.
"""

import uuid
from collections.abc import Iterator, Mapping, Sequence
from dataclasses import dataclass
from typing import Any, Final

from infrastructure.audit import context as audit_context
from infrastructure.common.errors import ApiError
from infrastructure.common.responses import ResponseTitle
from infrastructure.tasks import services, tree
from infrastructure.tasks.models import Task
from infrastructure.workspaces.models import Workspace

MAX_IDS: Final = 500
ATTEMPTS: Final = 3
CHANGEABLE: Final = ("status", "priority", "assignee_ids")


@dataclass(frozen=True, slots=True)
class Result:
    """What happened to one task: the task as it is now, or why it could not change."""

    task_id: str
    task: Task | None = None
    error: ApiError | None = None


def _ids(raw: Sequence[Any]) -> list[str]:
    ids = list(dict.fromkeys(str(i) for i in raw))
    if not 1 <= len(ids) <= MAX_IDS:
        raise ApiError(f"Choose between 1 and {MAX_IDS} tasks.")
    return ids


def _check(changes: Mapping[str, Any] | None, delete: str | None) -> None:
    if (not changes) == (delete is None):
        raise ApiError("Send either the fields to change or a delete mode, not both or neither.")
    unknown = set(changes or {}) - set(CHANGEABLE)
    if unknown:
        raise ApiError(f"A bulk edit cannot change {sorted(unknown)[0]}.")
    if delete is not None and delete not in services.DELETE_MODES:
        raise ApiError("The delete mode must be 'subtree' or 'promote'.")


def _depths(project_id: Any, ids: list[str]) -> dict[str, int]:
    rows = Task.objects.filter(project=project_id, pk__in=services.valid_uuids(ids))
    return {str(pk): depth for pk, depth in rows.values_list("pk", "depth")}


def _update_one(
    actor: Any, workspace: Workspace, project_id: str, task_id: str, changes: Mapping[str, Any]
) -> Task:
    for attempt in range(ATTEMPTS):
        version = (
            Task.objects.filter(
                project=project_id, pk__in=services.valid_uuids([task_id]), deleted_at=None
            )
            .values_list("version", flat=True)
            .first()
        )
        if version is None:
            raise services.not_found()
        try:
            return services.update(actor, workspace, project_id, task_id, version, dict(changes))
        except ApiError as error:
            if error.title is not ResponseTitle.VERSION_CONFLICT or attempt == ATTEMPTS - 1:
                raise
    raise services.not_found()  # unreachable: the last attempt returns or raises


def update_many(
    actor: Any,
    workspace: Workspace,
    project_id: str,
    ids: Sequence[Any],
    *,
    changes: Mapping[str, Any] | None = None,
    delete: str | None = None,
) -> Iterator[Result]:
    """Apply ``changes`` (``status``, ``priority``, ``assignee_ids``) to every task, or delete
    every task with ``delete`` as the mode (``""``, ``subtree`` or ``promote``; see
    ``services.delete``). Deleting goes top-down: a parent chosen together with all its live
    subtasks is deleted as one ``subtree`` batch (so restoring it brings them back), and those
    subtasks are then reported as deleted along with it."""
    task_ids = _ids(ids)
    _check(changes, delete)
    key = "task.delete" if delete is not None else "task.update"
    project = services.open_for_write(actor, workspace, project_id, key)
    if changes:
        services.check_changes(project, changes)
    swept: set[str] = set()
    if delete is not None:
        depth = _depths(project.pk, task_ids)
        task_ids.sort(key=lambda i: depth.get(i, 0))
    chosen = set(task_ids)
    batch_id = uuid.uuid4()  # the entries of this call share it; one entry per task
    for task_id in task_ids:
        try:
            with audit_context.batch(batch_id):
                if task_id in swept:
                    task = services.reload(actor, workspace, project_id, task_id)
                elif delete is not None:
                    inside = _chosen_below(project.pk, task_id, chosen)
                    task = services.delete(
                        actor, workspace, project_id, task_id, "subtree" if inside else delete
                    )
                    swept |= inside
                else:
                    task = _update_one(actor, workspace, project_id, task_id, changes or {})
        except ApiError as error:
            yield Result(task_id, error=error)
        else:
            yield Result(task_id, task=task)


def _chosen_below(project_id: Any, task_id: str, chosen: set[str]) -> set[str]:
    """The live subtasks of ``task_id`` when every one of them is also chosen (else none)."""
    task = Task.objects.filter(project=project_id, pk__in=services.valid_uuids([task_id])).first()
    if task is None:
        return set()
    below = {str(pk) for pk in tree.descendants(task).values_list("pk", flat=True)}
    return below if below <= chosen else set()
