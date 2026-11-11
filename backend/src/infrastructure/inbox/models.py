"""Notifications: what a person is told, how they asked to be told, and what they watch."""

import uuid
from datetime import time

from django.conf import settings as django_settings
from django.db import models
from django.utils import timezone

from infrastructure.tasks.models import Task
from infrastructure.workspaces.models import Workspace


class Notification(models.Model):
    """One thing that happened that ``user`` should know about. ``dedupe_key`` makes the same event
    unable to create two (unique per user). A burst of the same kind on the same task is folded
    into one row: ``count`` rises and ``payload`` keeps the first ``from`` and the latest ``to``.
    ``in_inbox`` is false when the person turned the inbox off for this kind but wants it by push or
    email; such a row is delivered and never listed."""

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(
        django_settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="+"
    )
    workspace = models.ForeignKey(Workspace, on_delete=models.CASCADE, related_name="+")
    type = models.CharField(max_length=32)
    task = models.ForeignKey(
        Task, null=True, blank=True, on_delete=models.CASCADE, related_name="+"
    )
    project_id = models.UUIDField(null=True, blank=True)  # to drop it once access is lost
    actor = models.ForeignKey(
        django_settings.AUTH_USER_MODEL,
        null=True,
        blank=True,
        on_delete=models.SET_NULL,
        related_name="+",
    )
    payload = models.JSONField(default=dict, blank=True)
    dedupe_key = models.CharField(max_length=200)  # of the event that made it
    last_key = models.CharField(max_length=200, blank=True)  # of the latest event folded into it
    count = models.PositiveIntegerField(default=1)
    in_inbox = models.BooleanField(default=True)
    created_at = models.DateTimeField(default=timezone.now)
    updated_at = models.DateTimeField(default=timezone.now)
    read_at = models.DateTimeField(null=True, blank=True)
    snoozed_until = models.DateTimeField(null=True, blank=True)
    archived_at = models.DateTimeField(null=True, blank=True)

    class Meta:
        constraints = [
            models.UniqueConstraint(fields=["user", "dedupe_key"], name="inbox_dedupe_unique")
        ]
        indexes = [
            models.Index(fields=["user", "workspace", "-updated_at"], name="inbox_user_ws_idx"),
        ]

    def __str__(self) -> str:
        return f"{self.type} for {self.user_id}"


class EmailMode(models.TextChoices):
    OFF = "off"
    INSTANT = "instant"
    DIGEST = "digest"


class NotificationPref(models.Model):
    """One person's choice of channels for one kind of event (across every workspace)."""

    user = models.ForeignKey(
        django_settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="+"
    )
    event_type = models.CharField(max_length=32)
    inbox = models.BooleanField(default=True)
    push = models.BooleanField(default=False)
    email_mode = models.CharField(max_length=8, choices=EmailMode.choices, default=EmailMode.OFF)

    class Meta:
        constraints = [
            models.UniqueConstraint(fields=["user", "event_type"], name="inbox_pref_unique")
        ]

    def __str__(self) -> str:
        return f"{self.user_id} {self.event_type}"


class InboxSettings(models.Model):
    """When a person may be disturbed: a time zone, quiet hours (push and email wait for them to
    end; the inbox never waits) and the local hour the daily digest goes out."""

    user = models.OneToOneField(
        django_settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="+"
    )
    timezone = models.CharField(max_length=64, default="UTC")
    quiet_start = models.TimeField(null=True, blank=True)
    quiet_end = models.TimeField(null=True, blank=True)
    digest_hour = models.PositiveSmallIntegerField(default=8)

    def __str__(self) -> str:
        return f"settings of {self.user_id}"

    @property
    def quiet(self) -> tuple[time, time] | None:
        if self.quiet_start is None or self.quiet_end is None:
            return None
        return self.quiet_start, self.quiet_end


class Watcher(models.Model):
    """Somebody who hears about a task's changes."""

    task = models.ForeignKey(Task, on_delete=models.CASCADE, related_name="watchers")
    user = models.ForeignKey(
        django_settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="+"
    )
    created_at = models.DateTimeField(default=timezone.now)

    class Meta:
        constraints = [models.UniqueConstraint(fields=["task", "user"], name="inbox_watch_unique")]

    def __str__(self) -> str:
        return f"{self.user_id} watches {self.task_id}"


class PushDevice(models.Model):
    """A phone, browser or computer that can be pushed to (``token`` is its provider token)."""

    user = models.ForeignKey(
        django_settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="+"
    )
    platform = models.CharField(max_length=16)  # ios, android, web, desktop
    token = models.CharField(max_length=512, unique=True)
    created_at = models.DateTimeField(default=timezone.now)
    last_seen_at = models.DateTimeField(default=timezone.now)

    def __str__(self) -> str:
        return f"{self.platform} of {self.user_id}"


class Channel(models.TextChoices):
    PUSH = "push"
    EMAIL = "email"
    DIGEST = "digest"


class DeliveryStatus(models.TextChoices):
    PENDING = "pending"
    SENDING = "sending"  # claimed by a worker; a crashed one's claim is released after a while
    SENT = "sent"
    SKIPPED = "skipped"  # the person lost access, turned it off or has nowhere to send it
    FAILED = "failed"


class Delivery(models.Model):
    """A push or email owed for a notification. ``due_at`` is now, the end of quiet hours, or the
    next digest time; ``deliver_due`` sends what is due."""

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    notification = models.ForeignKey(
        Notification, on_delete=models.CASCADE, related_name="deliveries"
    )
    channel = models.CharField(max_length=8, choices=Channel.choices)
    status = models.CharField(
        max_length=8, choices=DeliveryStatus.choices, default=DeliveryStatus.PENDING
    )
    due_at = models.DateTimeField(db_index=True)
    sent_at = models.DateTimeField(null=True, blank=True)
    claimed_at = models.DateTimeField(null=True, blank=True)
    attempts = models.PositiveSmallIntegerField(default=0)

    def __str__(self) -> str:
        return f"{self.channel} {self.status} for {self.notification_id}"
