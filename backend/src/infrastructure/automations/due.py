"""The "due date reached" trigger, and run-history pruning: the work of ``manage.py
automations_tick`` (``make tick`` runs it every minute; there is no Celery yet).

A rule with ``days_before`` N fires on the task's due date minus N days. Each (rule, task, due
date) fires once, because the event id carries the due date and a run is unique per event.
"""

from datetime import date, timedelta
from typing import Any, Final

from django.utils import timezone

from infrastructure.automations import engine, queue, spec
from infrastructure.automations.models import Automation, AutomationRun
from infrastructure.tasks import tree
from infrastructure.tasks.models import Task

SCAN_BACK_DAYS: Final = 7  # overdue for longer than this was missed once; not fired every minute
PER_RULE: Final = 500
PER_TICK: Final = 2000  # runs queued by one scan, across all rules; the rest wait for the next tick
RETENTION_DAYS: Final = 30
KEEP_PER_RULE: Final = 500


def scan_due(today: date | None = None) -> int:
    """Queue the due-date rules whose day has come; returns how many runs were queued."""
    day = today or timezone.now().date()
    queued = 0
    rules = Automation.objects.filter(enabled=True, trigger__type=spec.DUE_DATE_REACHED)
    for rule in rules:
        before = int(rule.trigger.get("days_before", 0))
        candidates = (
            Task.objects.filter(
                project_id=rule.project_id,
                workspace_id=rule.workspace_id,
                deleted_at__isnull=True,
                due_date__isnull=False,
                due_date__lte=day + timedelta(days=before),
                due_date__gte=day - timedelta(days=SCAN_BACK_DAYS),
                project__archived_at__isnull=True,
            )
            .exclude(status__category__in=tree.FINAL)
            .order_by("due_date")[:PER_RULE]
        )
        done = set(
            AutomationRun.objects.filter(automation=rule, event_key__startswith="due:").values_list(
                "event_key", flat=True
            )
        )
        for task in candidates:
            key = f"due:{task.pk}:{task.due_date.isoformat()}:{before}"
            if key in done:
                continue
            event: dict[str, Any] = {
                "type": spec.DUE_DATE_REACHED,
                "id": key,
                "task_id": str(task.pk),
                "depth": 0,
                "data": {"due_date": task.due_date.isoformat()},
            }
            if queued >= PER_TICK:
                return queued
            accepted = queue.run_later(
                engine.execute,
                str(rule.pk),
                event,
                lane=queue.lane_for(rule.actions),
                key=f"{rule.pk}:{key}",
            )
            if not accepted:  # already waiting, or the queue is full: try again next tick
                continue
            queued += 1
    return queued


def prune_runs(now: Any = None) -> int:
    """Delete runs older than ``RETENTION_DAYS``, and all but the newest ``KEEP_PER_RULE`` of
    each rule. Returns how many were deleted."""
    cutoff = (now or timezone.now()) - timedelta(days=RETENTION_DAYS)
    removed = AutomationRun.objects.filter(started_at__lt=cutoff).delete()[0]
    for rule_id in AutomationRun.objects.values_list("automation_id", flat=True).distinct():
        stale = list(
            AutomationRun.objects.filter(automation_id=rule_id)
            .order_by("-started_at")
            .values_list("pk", flat=True)[KEEP_PER_RULE:]
        )
        if stale:
            removed += AutomationRun.objects.filter(pk__in=stale).delete()[0]
    return removed


def retry_crashed(now: Any = None) -> int:
    """Run again the runs that crashed (never finished, quiet for ``RETRY_AFTER``), at most
    ``MAX_ATTEMPTS`` times in all; then the failure is recorded for good. A run that failed a
    step finished, so it is never touched. The run row is reused, so the (rule, task, event)
    constraint keeps it one run. Returns how many were queued."""
    moment = now or timezone.now()
    stale = AutomationRun.objects.filter(
        finished_at__isnull=True, started_at__lt=moment - engine.RETRY_AFTER
    )
    stale.filter(attempts__gte=engine.MAX_ATTEMPTS).update(
        finished_at=moment,
        error=f"The run did not finish after {engine.MAX_ATTEMPTS} tries.",
    )
    queued = 0
    for run in stale.select_related("automation")[:PER_TICK]:
        claimed = AutomationRun.objects.filter(
            pk=run.pk, finished_at__isnull=True, attempts=run.attempts
        ).update(attempts=run.attempts + 1, started_at=moment)
        if not claimed:
            continue
        accepted = queue.run_later(
            engine.resume,
            str(run.pk),
            lane=queue.lane_for(run.automation.actions),
            key=f"retry:{run.pk}:{run.attempts + 1}",
        )
        if not accepted:  # the queue is full: give the attempt back, try again later
            AutomationRun.objects.filter(pk=run.pk).update(attempts=run.attempts)
            continue
        queued += 1
    return queued
