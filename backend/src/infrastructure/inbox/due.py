"""Tasks that are due soon: a scan (``manage.py inbox_tick``) tells each assignee once per due date.

A due date is a calendar date everywhere, so "soon" is measured in UTC dates: today through
``INBOX_DUE_SOON_DAYS`` days ahead (and anything overdue that was never mentioned).
# ponytail: UTC dates, so someone far from UTC may hear a few hours early or late; per-zone dates
# when anyone asks.
"""

from datetime import datetime, timedelta

from django.conf import settings
from django.utils import timezone

from infrastructure.inbox import kinds, notify
from infrastructure.tasks import tree
from infrastructure.tasks.models import Task

SCAN_BACK_DAYS = 7  # a task overdue for longer was missed once and is not told about every minute


def scan_due_soon(now: datetime | None = None) -> int:
    """Notify the assignees of tasks due soon (not finished, project not archived). Idempotent: the
    same due date is told once. Returns how many notifications were made."""
    today = (now or timezone.now()).date()
    horizon = today + timedelta(days=settings.INBOX_DUE_SOON_DAYS)
    tasks = (
        Task.objects.filter(
            deleted_at__isnull=True,
            due_date__isnull=False,
            due_date__lte=horizon,
            due_date__gte=today - timedelta(days=SCAN_BACK_DAYS),
            project__archived_at__isnull=True,
            workspace__deleted_at__isnull=True,
        )
        .exclude(status__category__in=tree.FINAL)
        .select_related("project", "workspace")
        .prefetch_related("assignees")
    )
    made = 0
    for task in tasks:
        made += len(
            notify.notify(
                kind=kinds.DUE_SOON,
                recipients=[a.user_id for a in task.assignees.all()],
                workspace=task.workspace,
                project=task.project,
                task=task,
                actor_id=None,
                payload={
                    "title": task.title,
                    "key": task.display_id,
                    "due_date": task.due_date.isoformat(),
                },
                dedupe=f"due:{task.pk}:{task.due_date}",
                fold=False,
            )
        )
    return made
