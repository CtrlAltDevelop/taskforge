"""The top-level tenant container, and who belongs to it."""

import uuid

from django.conf import settings
from django.db import models
from django.utils import timezone


class Workspace(models.Model):
    """A company or team. Everything else in TaskForge belongs to exactly one.

    ``deleted_at`` is a soft delete: the row keeps holding its slug until
    ``purge_expired`` removes it. ``version`` is the optimistic lock every
    update checks (docs/01-architecture.md section 6).
    """

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    name = models.CharField(max_length=80)
    slug = models.CharField(max_length=40, unique=True)
    logo = models.FileField(upload_to="workspaces/logos", blank=True)
    created_by = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="created_workspaces"
    )
    created_at = models.DateTimeField(default=timezone.now)
    deleted_at = models.DateTimeField(null=True, blank=True)
    version = models.PositiveIntegerField(default=1)

    def __str__(self) -> str:
        return self.slug


class WorkspaceMember(models.Model):
    """A user's membership. Roles arrive in phase 04."""

    workspace = models.ForeignKey(Workspace, on_delete=models.CASCADE, related_name="members")
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="workspace_memberships"
    )
    joined_at = models.DateTimeField(default=timezone.now)

    class Meta:
        constraints = [
            models.UniqueConstraint(fields=["workspace", "user"], name="workspace_member_unique")
        ]

    def __str__(self) -> str:
        return f"{self.user_id} in {self.workspace_id}"
