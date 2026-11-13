"""API tokens, webhooks and the log of what was sent to them."""

import uuid

from django.conf import settings as django_settings
from django.db import models
from django.utils import timezone

from infrastructure.projects.models import Project
from infrastructure.workspaces.models import Workspace


class ApiToken(models.Model):
    """A personal access token for one workspace. Only ``prefix`` (shown in lists, used to find
    the row) and ``hash`` (SHA-256 of the secret) are stored; the secret itself is shown once."""

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    workspace = models.ForeignKey(Workspace, on_delete=models.CASCADE, related_name="+")
    owner = models.ForeignKey(
        django_settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="+"
    )
    name = models.CharField(max_length=80)
    prefix = models.CharField(max_length=16, unique=True)
    hash = models.CharField(max_length=64)
    scopes = models.JSONField(default=list)
    expires_at = models.DateTimeField(null=True, blank=True)
    last_used_at = models.DateTimeField(null=True, blank=True)
    revoked_at = models.DateTimeField(null=True, blank=True)
    created_at = models.DateTimeField(default=timezone.now)

    class Meta:
        indexes = [models.Index(fields=["workspace", "owner"], name="apitoken_ws_owner_idx")]

    def __str__(self) -> str:
        return f"{self.name} ({self.prefix})"

    @property
    def is_active(self) -> bool:
        return self.revoked_at is None and (
            self.expires_at is None or self.expires_at > timezone.now()
        )


class Webhook(models.Model):
    """A URL that is sent a signed POST for each subscribed event. ``project`` narrows it to one
    project's events. ``secret`` signs the payloads; it is shown on creation and on request to
    people who may manage webhooks (the receiver needs it)."""

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    workspace = models.ForeignKey(Workspace, on_delete=models.CASCADE, related_name="+")
    project = models.ForeignKey(
        Project, null=True, blank=True, on_delete=models.CASCADE, related_name="+"
    )
    created_by = models.ForeignKey(
        django_settings.AUTH_USER_MODEL, null=True, on_delete=models.SET_NULL, related_name="+"
    )
    name = models.CharField(max_length=80, blank=True)
    url = models.CharField(max_length=2000)
    secret = models.CharField(max_length=80)
    events = models.JSONField(default=list)
    active = models.BooleanField(default=True)
    disabled_reason = models.CharField(max_length=200, blank=True)
    version = models.PositiveIntegerField(default=1)
    created_at = models.DateTimeField(default=timezone.now)

    def __str__(self) -> str:
        return f"{self.name or self.url}"


class DeliveryStatus:
    PENDING = "pending"  # waiting for its first try or a retry (``next_retry_at``)
    DELIVERED = "delivered"
    FAILED = "failed"  # tried, will try again
    GAVE_UP = "gave_up"  # out of retries
    CHOICES = tuple((s, s.title()) for s in (PENDING, DELIVERED, FAILED, GAVE_UP))


class WebhookDelivery(models.Model):
    """One event for one webhook and its attempts. ``event_id`` is the same on every retry and
    resend (receivers dedupe on it); ``attempt`` counts tries; ``request_headers`` never holds the
    secret. A resend of a finished delivery makes a new row with ``resend_of`` set."""

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    webhook = models.ForeignKey(Webhook, on_delete=models.CASCADE, related_name="deliveries")
    workspace = models.ForeignKey(Workspace, on_delete=models.CASCADE, related_name="+")
    event = models.CharField(max_length=60)
    event_id = models.CharField(max_length=120)
    payload = models.JSONField(default=dict)
    status = models.CharField(max_length=10, choices=DeliveryStatus.CHOICES)
    status_code = models.PositiveSmallIntegerField(null=True, blank=True)
    response_snippet = models.CharField(max_length=2000, blank=True)
    error = models.CharField(max_length=300, blank=True)
    request_headers = models.JSONField(default=dict)
    attempt = models.PositiveSmallIntegerField(default=0)
    next_retry_at = models.DateTimeField(null=True, blank=True)
    resend_of = models.ForeignKey(
        "self", null=True, blank=True, on_delete=models.SET_NULL, related_name="+"
    )
    created_at = models.DateTimeField(default=timezone.now)
    at = models.DateTimeField(null=True, blank=True)  # the last try
    duration_ms = models.PositiveIntegerField(default=0)

    class Meta:
        indexes = [
            models.Index(fields=["webhook", "-created_at"], name="whdelivery_hook_time_idx"),
            models.Index(fields=["status", "next_retry_at"], name="whdelivery_due_idx"),
        ]

    def __str__(self) -> str:
        return f"{self.event} {self.status}"
