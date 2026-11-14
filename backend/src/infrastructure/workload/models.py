"""Capacity, time off, holidays and per-person estimates. Weekdays are 0 Monday ... 6 Sunday, the
same numbering as the timeline's working calendar."""

import uuid
from typing import Final

from django.conf import settings as django_settings
from django.db import models
from django.db.models import Q
from django.utils import timezone

from infrastructure.tasks.models import Task
from infrastructure.workspaces.models import Workspace

DEFAULT_HOURS: Final = 8
DEFAULT_DAYS: Final = (0, 1, 2, 3, 4)


class TimeOffKind:
    VACATION: Final = "vacation"
    SICK: Final = "sick"
    PERSONAL: Final = "personal"
    OTHER: Final = "other"
    CHOICES: Final = (
        (VACATION, "Vacation"),
        (SICK, "Sick leave"),
        (PERSONAL, "Personal"),
        (OTHER, "Other"),
    )
    ALL: Final = frozenset({VACATION, SICK, PERSONAL, OTHER})


class MemberCapacity(models.Model):
    """How much a person can take on: ``hours_per_day`` on each of ``working_days``. No row means
    "not set": the defaults (8 h, Monday to Friday) are used and the screen asks for real ones."""

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    workspace = models.ForeignKey(Workspace, on_delete=models.CASCADE, related_name="+")
    user = models.ForeignKey(
        django_settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="+"
    )
    hours_per_day = models.DecimalField(max_digits=4, decimal_places=2, default=DEFAULT_HOURS)
    working_days = models.JSONField(default=list)
    updated_at = models.DateTimeField(default=timezone.now)

    class Meta:
        constraints = [
            models.UniqueConstraint(fields=["workspace", "user"], name="capacity_user_unique"),
            models.CheckConstraint(
                condition=Q(hours_per_day__gte=0) & Q(hours_per_day__lte=24),
                name="capacity_hours_range",
            ),
        ]

    def __str__(self) -> str:
        return f"{self.user_id}: {self.hours_per_day} h"


class TimeOff(models.Model):
    """Days (first and last inclusive) a person is away; their capacity is zero on them."""

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    workspace = models.ForeignKey(Workspace, on_delete=models.CASCADE, related_name="+")
    user = models.ForeignKey(
        django_settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="+"
    )
    start_date = models.DateField()
    end_date = models.DateField()
    kind = models.CharField(max_length=10, choices=TimeOffKind.CHOICES, default=TimeOffKind.OTHER)
    note = models.CharField(max_length=300, blank=True)
    created_by = models.ForeignKey(
        django_settings.AUTH_USER_MODEL, null=True, on_delete=models.SET_NULL, related_name="+"
    )
    created_at = models.DateTimeField(default=timezone.now)

    class Meta:
        ordering = ["start_date", "created_at"]
        constraints = [
            models.CheckConstraint(
                condition=Q(end_date__gte=models.F("start_date")), name="timeoff_end_after_start"
            )
        ]
        indexes = [models.Index(fields=["workspace", "user", "start_date"], name="timeoff_idx")]

    def __str__(self) -> str:
        return f"{self.user_id} {self.start_date}..{self.end_date}"


class Holiday(models.Model):
    """A day nobody in the workspace works."""

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    workspace = models.ForeignKey(Workspace, on_delete=models.CASCADE, related_name="+")
    date = models.DateField()
    name = models.CharField(max_length=120)

    class Meta:
        ordering = ["date"]
        constraints = [
            models.UniqueConstraint(fields=["workspace", "date"], name="holiday_date_unique")
        ]

    def __str__(self) -> str:
        return f"{self.date} {self.name}"


class AssigneeEstimate(models.Model):
    """One assignee's own estimate for a task. When any exists, the task's estimate is no longer
    split equally: these people get theirs and the rest share what is left."""

    task = models.ForeignKey(Task, on_delete=models.CASCADE, related_name="assignee_estimates")
    user = models.ForeignKey(
        django_settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="+"
    )
    estimate_sec = models.PositiveIntegerField()

    class Meta:
        constraints = [
            models.UniqueConstraint(fields=["task", "user"], name="assignee_estimate_unique")
        ]

    def __str__(self) -> str:
        return f"{self.user_id} on {self.task_id}: {self.estimate_sec}s"
