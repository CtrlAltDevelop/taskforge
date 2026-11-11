"""A task that is deleted takes its running timers with it (they would otherwise run unseen)."""

from typing import Any

from django.utils import timezone

from infrastructure.tasks.signals import task_changed
from infrastructure.timetracking.models import TimeEntry
from infrastructure.timetracking.services import _stop_row
from infrastructure.timetracking.signals import announce


def on_task(sender: Any, task_id: str, action: str, **_: Any) -> None:
    if action != "deleted":
        return
    now = timezone.now().replace(microsecond=0)
    for entry in TimeEntry.objects.filter(task_id=task_id, ended_at__isnull=True).select_related(
        "user", "workspace"
    ):
        _stop_row(entry, now)
        announce(entry.user, entry.workspace)


def connect() -> None:
    task_changed.connect(on_task, dispatch_uid="timetracking.task")
