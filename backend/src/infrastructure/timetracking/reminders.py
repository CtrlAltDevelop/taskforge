"""A timer left running: its owner is told once, through the inbox (``manage.py inbox_tick``)."""

from datetime import datetime, timedelta

from django.conf import settings
from django.utils import timezone

from infrastructure.inbox import kinds, notify
from infrastructure.timetracking import services
from infrastructure.timetracking.models import TimeEntry


def remind_long_timers(now: datetime | None = None) -> int:
    """Notify the owner of each timer running for ``TIME_LONG_TIMER_HOURS`` or more. Idempotent: one
    reminder per entry. Returns how many were made."""
    now = now or timezone.now()
    hours = settings.TIME_LONG_TIMER_HOURS
    if hours <= 0:
        return 0
    running = TimeEntry.objects.filter(
        ended_at__isnull=True,
        started_at__lte=now - timedelta(hours=hours),
        task__deleted_at__isnull=True,
        task__project__archived_at__isnull=True,
    ).select_related("task__project", "workspace", "user")
    made = 0
    for entry in running:
        if not services.feature_on(entry.task.project):
            continue
        made += len(
            notify.notify(
                kind=kinds.TIMER_LONG,
                recipients=[entry.user_id],
                workspace=entry.workspace,
                project=entry.task.project,
                task=entry.task,
                actor_id=None,
                payload={
                    "title": entry.task.title,
                    "key": entry.task.display_id,
                    "hours": int((now - entry.started_at).total_seconds() // 3600),
                },
                dedupe=f"timer-long:{entry.pk}",
                fold=False,
            )
        )
    return made
