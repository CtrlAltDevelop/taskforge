"""Watching a task: who hears about its comments and status changes."""

import uuid
from typing import Any

from infrastructure.inbox.models import Watcher
from infrastructure.tasks import services as task_services
from infrastructure.tasks.models import Task
from infrastructure.workspaces.models import Workspace


def _task(actor: Any, workspace: Workspace, project_id: str, task_id: str) -> Task:
    project = task_services.project_for_view(actor, workspace, project_id)
    try:
        pk = uuid.UUID(str(task_id))
    except ValueError:
        raise task_services.not_found() from None
    task = Task.objects.filter(project=project, pk=pk, deleted_at__isnull=True).first()
    if task is None:
        raise task_services.not_found()
    return task


def _state(task: Task, actor: Any) -> dict[str, Any]:
    rows = Watcher.objects.filter(task=task)
    return {"watching": rows.filter(user=actor).exists(), "watcher_count": rows.count()}


def state(actor: Any, workspace: Workspace, project_id: str, task_id: str) -> dict[str, Any]:
    return _state(_task(actor, workspace, project_id, task_id), actor)


def watch(
    actor: Any, workspace: Workspace, project_id: str, task_id: str, *, on: bool
) -> dict[str, Any]:
    """Start (``on``) or stop watching. Both are safe to repeat."""
    task = _task(actor, workspace, project_id, task_id)
    if on:
        Watcher.objects.get_or_create(task=task, user=actor)
    else:
        Watcher.objects.filter(task=task, user=actor).delete()
    return _state(task, actor)


def ensure(task_id: Any, user_ids: list[Any]) -> None:
    """Make these people watchers (assignees, creators and commenters watch by themselves)."""
    have = set(Watcher.objects.filter(task_id=task_id).values_list("user_id", flat=True))
    Watcher.objects.bulk_create(
        [Watcher(task_id=task_id, user_id=u) for u in dict.fromkeys(user_ids) if u not in have],
        ignore_conflicts=True,
    )


def watcher_ids(task_id: Any) -> list[Any]:
    return list(Watcher.objects.filter(task_id=task_id).values_list("user_id", flat=True))
