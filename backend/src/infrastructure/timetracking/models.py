"""Logged time. The running timer is just an entry with no end, so it lives on the server."""

import uuid

from django.conf import settings as django_settings
from django.db import models
from django.db.models import Q
from django.utils import timezone

from infrastructure.tasks.models import Task
from infrastructure.workspaces.models import Workspace


class Source(models.TextChoices):
    TIMER = "timer"
    MANUAL = "manual"


class TimeEntry(models.Model):
    """Time ``user`` spent on ``task``. ``ended_at`` is empty while the timer runs; ``duration_sec``
    is then 0 and the elapsed time is read from the server clock. At most one entry per person is
    open (a database rule, so two devices starting at once cannot both win)."""

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    workspace = models.ForeignKey(Workspace, on_delete=models.CASCADE, related_name="+")
    task = models.ForeignKey(Task, on_delete=models.CASCADE, related_name="time_entries")
    user = models.ForeignKey(
        django_settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="+"
    )
    started_at = models.DateTimeField()
    ended_at = models.DateTimeField(null=True, blank=True)
    duration_sec = models.PositiveIntegerField(default=0)
    note = models.CharField(max_length=500, blank=True)
    billable = models.BooleanField(default=False)
    source = models.CharField(max_length=6, choices=Source.choices, default=Source.TIMER)
    created_at = models.DateTimeField(default=timezone.now)
    updated_at = models.DateTimeField(default=timezone.now)

    class Meta:
        constraints = [
            models.UniqueConstraint(
                fields=["user"], condition=Q(ended_at__isnull=True), name="time_one_open_per_user"
            ),
            models.CheckConstraint(
                condition=Q(ended_at__isnull=True) | Q(ended_at__gte=models.F("started_at")),
                name="time_end_after_start",
            ),
        ]
        indexes = [
            models.Index(fields=["user", "started_at"], name="time_user_start_idx"),
            models.Index(fields=["task", "started_at"], name="time_task_start_idx"),
        ]

    def __str__(self) -> str:
        return f"{self.user_id} on {self.task_id}"

    @property
    def is_running(self) -> bool:
        return self.ended_at is None
