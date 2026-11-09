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


class MemberStatus(models.TextChoices):
    ACTIVE = "active"
    REMOVED = "removed"


class WorkspaceMember(models.Model):
    """A user's membership. Roles arrive in phase 04.

    A removed member keeps their row (``status=removed``) so re-inviting them
    re-activates it instead of adding a duplicate. Only ``active`` rows count as
    membership anywhere.
    """

    workspace = models.ForeignKey(Workspace, on_delete=models.CASCADE, related_name="members")
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="workspace_memberships"
    )
    joined_at = models.DateTimeField(default=timezone.now)
    status = models.CharField(
        max_length=10, choices=MemberStatus.choices, default=MemberStatus.ACTIVE
    )
    invited_by = models.ForeignKey(
        settings.AUTH_USER_MODEL, null=True, blank=True, on_delete=models.SET_NULL, related_name="+"
    )
    removed_at = models.DateTimeField(null=True, blank=True)

    class Meta:
        constraints = [
            models.UniqueConstraint(fields=["workspace", "user"], name="workspace_member_unique")
        ]

    def __str__(self) -> str:
        return f"{self.user_id} in {self.workspace_id}"


class Invitation(models.Model):
    """A way into a workspace: bound to one email, or a link anyone holding it may use.

    Only the SHA-256 of the token is stored. ``max_uses`` 0 means unlimited (links
    only; an email invitation is single use).
    """

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    workspace = models.ForeignKey(Workspace, on_delete=models.CASCADE, related_name="invitations")
    email = models.EmailField(null=True, blank=True)
    token_hash = models.CharField(max_length=64, unique=True)
    created_by = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="+"
    )
    expires_at = models.DateTimeField()
    max_uses = models.PositiveIntegerField(default=0)
    uses = models.PositiveIntegerField(default=0)
    revoked_at = models.DateTimeField(null=True, blank=True)
    accepted_at = models.DateTimeField(null=True, blank=True)
    created_at = models.DateTimeField(default=timezone.now)

    def __str__(self) -> str:
        return f"invitation to {self.workspace_id}"
