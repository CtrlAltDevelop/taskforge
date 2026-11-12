"""A repeat rule on a task (the series) and which task is which instance of it."""

import uuid
from typing import Final

from django.conf import settings as django_settings
from django.db import models

from infrastructure.projects.models import Project
from infrastructure.tasks.models import Task
from infrastructure.workspaces.models import Workspace


class Mode:
    SCHEDULE: Final = "schedule"  # on the calendar's rhythm, finished or not
    AFTER_COMPLETION: Final = "after_completion"  # when the last one is done
    CHOICES: Final = ((SCHEDULE, "Schedule"), (AFTER_COMPLETION, "After completion"))


class RecurrenceSeries(models.Model):
    """The rule, and what each new instance is made from.

    ``template`` is a snapshot of the task when the rule was set (or last re-taken with "edit
    future"): title, description, priority, people, field values, subtasks. New instances are made
    from it, so deleting the task the rule was set on never stops them. ``next_due_on`` is the date
    of the next instance and ``next_run_at`` the moment (UTC) it is made: ``lead_days`` ahead of
    that date. Both are empty once a series has ended, and in ``after_completion`` mode until
    the open instance is completed."""

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    workspace = models.ForeignKey(Workspace, on_delete=models.CASCADE, related_name="+")
    project = models.ForeignKey(Project, on_delete=models.CASCADE, related_name="recurrence")
    template_task = models.ForeignKey(
        Task, null=True, blank=True, on_delete=models.SET_NULL, related_name="+"
    )
    template = models.JSONField(default=dict)
    rrule = models.CharField(max_length=200)
    mode = models.CharField(max_length=20, choices=Mode.CHOICES, default=Mode.SCHEDULE)
    timezone = models.CharField(max_length=64, default="UTC")
    starts_on = models.DateField()
    at_time = models.TimeField(default="09:00")  # the local time of day an instance appears
    lead_days = models.PositiveSmallIntegerField(default=0)
    ends_on = models.DateField(null=True, blank=True)
    skip_weekends = models.BooleanField(default=False)
    paused = models.BooleanField(default=False)
    pause_reason = models.CharField(max_length=200, blank=True)  # why the system paused it
    next_due_on = models.DateField(null=True, blank=True)
    next_run_at = models.DateTimeField(null=True, blank=True)
    last_index = models.IntegerField(default=0)  # the number of the newest instance (0: the first)
    created_by = models.ForeignKey(
        django_settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="+"
    )
    version = models.PositiveIntegerField(default=1)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        indexes = [
            models.Index(fields=["paused", "next_run_at"], name="series_due_idx"),
            models.Index(fields=["workspace", "project"], name="series_project_idx"),
        ]

    def __str__(self) -> str:
        return f"{self.rrule} ({self.mode})"


class Occurrence(models.Model):
    """Task ``task`` is instance number ``index`` of ``series``, for the day ``occurs_on``. A
    series makes a day only once, which is what makes running the clock twice harmless."""

    task = models.OneToOneField(Task, on_delete=models.CASCADE, related_name="occurrence")
    series = models.ForeignKey(RecurrenceSeries, on_delete=models.CASCADE, related_name="instances")
    index = models.IntegerField()
    occurs_on = models.DateField()

    class Meta:
        constraints = [
            models.UniqueConstraint(fields=["series", "index"], name="occurrence_series_index"),
            models.UniqueConstraint(fields=["series", "occurs_on"], name="occurrence_series_day"),
        ]

    def __str__(self) -> str:
        return f"#{self.index} of {self.series_id} on {self.occurs_on}"
