"""Files attached to a task (or to one of its comments) and the uploads that are still arriving."""

import uuid

from django.conf import settings as django_settings
from django.db import models
from django.utils import timezone

from infrastructure.tasks.models import Task
from infrastructure.workspaces.models import Workspace


class Attachment(models.Model):
    """A stored file. ``storage_key`` is derived from ``sha256`` (the same bytes are stored once,
    however many attachments point at them); this row is what carries the permissions. ``mime`` is
    what the content says it is, never what the client claimed. ``deleted_at`` is a soft delete."""

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    workspace = models.ForeignKey(Workspace, on_delete=models.CASCADE, related_name="+")
    task = models.ForeignKey(Task, on_delete=models.CASCADE, related_name="attachments")
    comment = models.ForeignKey(
        "comments.Comment",
        null=True,
        blank=True,
        on_delete=models.SET_NULL,
        related_name="attachments",
    )
    uploader = models.ForeignKey(
        django_settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="+"
    )
    filename = models.CharField(max_length=255)
    mime = models.CharField(max_length=100)
    size = models.BigIntegerField()
    storage_key = models.CharField(max_length=512)
    sha256 = models.CharField(max_length=64, db_index=True)
    thumb_key = models.CharField(max_length=512, blank=True)
    created_at = models.DateTimeField(default=timezone.now)
    deleted_at = models.DateTimeField(null=True, blank=True)

    class Meta:
        indexes = [models.Index(fields=["task", "created_at", "id"], name="attachment_task_idx")]

    def __str__(self) -> str:
        return f"{self.filename} ({self.pk})"

    @property
    def is_deleted(self) -> bool:
        return self.deleted_at is not None


class UploadSession(models.Model):
    """An upload in progress. The chunks wait in storage under ``attachments/tmp/<id>.<n>``;
    ``received`` lists the (zero-based) chunk numbers that arrived. Past ``expires_at`` it is
    orphaned and ``purge_uploads`` removes it."""

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    workspace = models.ForeignKey(Workspace, on_delete=models.CASCADE, related_name="+")
    task = models.ForeignKey(Task, on_delete=models.CASCADE, related_name="+")
    comment = models.ForeignKey(
        "comments.Comment", null=True, blank=True, on_delete=models.CASCADE, related_name="+"
    )
    uploader = models.ForeignKey(
        django_settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="+"
    )
    filename = models.CharField(max_length=255)
    expected_size = models.BigIntegerField()
    chunk_size = models.PositiveIntegerField()
    received = models.JSONField(default=list)
    created_at = models.DateTimeField(default=timezone.now)
    expires_at = models.DateTimeField(db_index=True)

    def __str__(self) -> str:
        return f"upload {self.pk} of {self.filename}"

    @property
    def chunk_count(self) -> int:
        return max(1, -(-self.expected_size // self.chunk_size))
