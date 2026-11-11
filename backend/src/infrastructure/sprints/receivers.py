"""A task deleted from (or restored into) an active sprint is a scope change."""

from typing import Any

from django.utils import timezone

from infrastructure.sprints.models import EventKind, ScopeEvent, State
from infrastructure.tasks.models import Task
from infrastructure.tasks.signals import task_changed


def on_task(sender: Any, task_id: str, action: str, **_: Any) -> None:
    if action not in ("deleted", "restored"):
        return
    task = (
        Task.objects.filter(pk=task_id, sprint__state=State.ACTIVE).select_related("sprint").first()
    )
    if task is None:
        return
    sign = -1 if action == "deleted" else 1
    ScopeEvent.objects.create(
        sprint=task.sprint,
        task=task,
        kind=EventKind.REMOVED if sign < 0 else EventKind.ADDED,
        delta_points=sign * (task.points or 0),
        delta_tasks=sign,
        after_start=True,
        at=timezone.now(),
    )


def connect() -> None:
    task_changed.connect(on_task, dispatch_uid="sprints.task")
