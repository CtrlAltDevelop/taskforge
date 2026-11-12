"""The work of ``manage.py recurrence_tick`` (``make tick``; there is no Celery yet), and the
completion hook of after-completion series.

Every step locks the series row and re-reads it, and an instance is unique per ``(series, index)``
and per ``(series, day)``, so running the clock twice, or from two machines, makes each instance
once. A series that cannot make its instance (the owner lost access, a required field has no
value) is paused with the reason, never retried in a loop."""

import logging
from datetime import date, datetime, timedelta
from typing import Final

from django.conf import settings
from django.db import IntegrityError, transaction
from django.db.models import Exists, OuterRef
from django.utils import timezone

from infrastructure.audit import context as audit_context
from infrastructure.common.errors import ApiError
from infrastructure.projects.models import Project
from infrastructure.recurrence import rules, schedule, template
from infrastructure.recurrence.models import Mode, Occurrence, RecurrenceSeries
from infrastructure.tasks import tree
from infrastructure.workflows.models import Category

logger = logging.getLogger(__name__)

PER_TICK: Final = 500  # series looked at in one run; the rest wait for the next
MISSED_SCAN: Final = 1000  # missed dates counted at most per series per run


def max_catchup() -> int:
    return max(1, int(getattr(settings, "RECURRENCE_MAX_CATCHUP", 1)))


def _pause(series: RecurrenceSeries, error: Exception) -> None:
    """Stop the series with the reason, keeping ``last_index`` as it now stands so a resume never
    numbers an instance twice. Recorded as the system's doing, not the person who happened to
    complete the task."""
    reason = str(error) if isinstance(error, ApiError) else "The next task could not be made."
    series.paused = True
    series.pause_reason = reason[:200]
    with audit_context.as_system():
        series.save(update_fields=["last_index", "paused", "pause_reason"])


def _locked(series_id: object) -> RecurrenceSeries:
    """The series row, locked after its project row: the order every task write uses, so the
    clock and a person saving a rule never wait for each other's lock."""
    project_id = RecurrenceSeries.objects.values_list("project_id", flat=True).get(pk=series_id)
    Project.objects.select_for_update().filter(pk=project_id).first()
    return (
        RecurrenceSeries.objects.select_for_update()
        .select_related("workspace", "created_by", "project")
        .get(pk=series_id)
    )


def _generate_one(series_id: object, now: datetime) -> int:
    with transaction.atomic():
        series = RecurrenceSeries.objects.filter(pk=series_id).first()
        if series is None:
            return 0
        series = _locked(series_id)
        due_at = series.next_run_at
        if series.paused or series.mode != Mode.SCHEDULE or due_at is None or due_at > now:
            return 0
        rule = schedule.parse_rule(series.rrule)
        missed: list[tuple[int, date]] = []
        index, day = series.last_index, series.next_due_on
        while day is not None and schedule.run_at(series, day) <= now and len(missed) < MISSED_SCAN:
            index += 1
            missed.append((index, day))
            day = schedule.following(series, rule, day, index)
        made, last_done = 0, series.last_index
        for number, due in missed[-max_catchup() :]:
            try:
                with transaction.atomic():
                    template.instantiate(series, due, number)
            except (ApiError, IntegrityError) as error:
                series.last_index = last_done
                _pause(series, error)
                return made
            made, last_done = made + 1, number
        series.last_index = index
        series.next_due_on = day
        series.next_run_at = schedule.run_at(series, day) if day else None
        series.save(update_fields=["last_index", "next_due_on", "next_run_at"])
        return made


def generate_due(now: datetime | None = None) -> int:
    """Make every instance that is due (schedule mode); returns how many were made."""
    moment = now or timezone.now()
    ids = list(
        RecurrenceSeries.objects.filter(
            paused=False, mode=Mode.SCHEDULE, next_run_at__lte=moment
        ).values_list("pk", flat=True)[:PER_TICK]
    )
    made = 0
    for series_id in ids:
        try:
            made += _generate_one(series_id, moment)
        except Exception:  # noqa: BLE001 -- one broken series must not stop the others
            logger.exception("recurrence: could not generate for series %s", series_id)
    return made


def _open_exists(series: RecurrenceSeries) -> bool:
    return (
        Occurrence.objects.filter(series=series, task__deleted_at__isnull=True)
        .exclude(task__status__category__in=tree.FINAL)
        .exists()
    )


def _continue(series_id: object, completed_on: date | None, now: datetime) -> bool:
    """Make the next instance of an after-completion series, if its newest one is done and none
    is open. ``completed_on`` is the day it was finished (None: read it from the task)."""
    with transaction.atomic():
        if not RecurrenceSeries.objects.filter(pk=series_id).exists():
            return False
        series = _locked(series_id)
        if series.paused or series.mode != Mode.AFTER_COMPLETION or _open_exists(series):
            return False
        latest = (
            Occurrence.objects.filter(series=series)
            .select_related("task__status")
            .order_by("-index")
            .first()
        )
        if latest is None or latest.task.deleted_at or latest.task.status.category != Category.DONE:
            return False
        rule = schedule.parse_rule(series.rrule)
        if schedule.is_last(rule, latest.index):
            return False
        finished = completed_on or schedule.today(series, latest.task.updated_at)
        due = rules.after_completion(rule, finished, skip_weekends=series.skip_weekends)
        if due is None or due <= latest.occurs_on:
            due = latest.occurs_on + timedelta(days=1)
        if (series.ends_on and due > series.ends_on) or (rule.until and due > rule.until):
            return False
        try:
            with transaction.atomic():
                template.instantiate(series, due, latest.index + 1)
        except (ApiError, IntegrityError) as error:
            _pause(series, error)
            return False
        series.last_index = latest.index + 1
        series.save(update_fields=["last_index"])
        return True


def on_completed(task_id: object, now: datetime | None = None) -> bool:
    """A task reached a done status: make the next instance of its after-completion series."""
    moment = now or timezone.now()
    row = Occurrence.objects.select_related("series").filter(task_id=task_id).first()
    if row is None or row.series.mode != Mode.AFTER_COMPLETION:
        return False
    return _continue(row.series_id, schedule.today(row.series, moment), moment)


def catch_up_completions(now: datetime | None = None) -> int:
    """The safety net for a completion whose hook never ran: an after-completion series whose
    newest instance is done and none open gets its next one. Returns how many were made."""
    moment = now or timezone.now()
    open_instances = Occurrence.objects.filter(
        series=OuterRef("pk"), task__deleted_at__isnull=True
    ).exclude(task__status__category__in=tree.FINAL)
    # ponytail: a series whose newest task was trashed is looked at every run; add a flag if many.
    ids = list(
        RecurrenceSeries.objects.filter(mode=Mode.AFTER_COMPLETION, paused=False)
        .annotate(has_open=Exists(open_instances))
        .filter(has_open=False)
        .values_list("pk", flat=True)[:PER_TICK]
    )
    made = 0
    for series_id in ids:
        try:
            made += _continue(series_id, None, moment)
        except Exception:  # noqa: BLE001 -- one broken series must not stop the others
            logger.exception("recurrence: could not continue series %s", series_id)
    return made
