"""The top-level tenant container, and who belongs to it."""

import uuid

from django.conf import settings
from django.db import models
from django.db.models import Q
from django.db.models.functions import Lower
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
    default_locale = models.CharField(max_length=5, default="en")  # a new member's starting language
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


class Role(models.Model):
    """A named set of permission keys. ``workspace`` NULL means built-in (shared, read-only).

    Names are unique case-insensitively among the built-ins and, separately, within
    one workspace; the service also refuses a custom name equal to a built-in's.
    """

    workspace = models.ForeignKey(
        Workspace, null=True, blank=True, on_delete=models.CASCADE, related_name="roles"
    )
    name = models.CharField(max_length=60)
    is_builtin = models.BooleanField(default=False)
    version = models.PositiveIntegerField(default=1)  # optimistic lock (architecture section 6)

    class Meta:
        constraints = [
            models.UniqueConstraint(
                Lower("name"),
                "workspace",
                condition=Q(workspace__isnull=False),
                name="role_name_unique_per_workspace",
            ),
            models.UniqueConstraint(
                Lower("name"), condition=Q(workspace__isnull=True), name="role_builtin_name_unique"
            ),
        ]

    def __str__(self) -> str:
        return self.name


class RolePermission(models.Model):
    role = models.ForeignKey(Role, on_delete=models.CASCADE, related_name="permissions")
    permission_key = models.CharField(max_length=64)

    class Meta:
        constraints = [
            models.UniqueConstraint(
                fields=["role", "permission_key"], name="role_permission_unique"
            )
        ]

    def __str__(self) -> str:
        return f"{self.role_id}:{self.permission_key}"


class WorkspaceMember(models.Model):
    """A user's membership and role.

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
    # RESTRICT, not PROTECT: purging a workspace cascades to its roles AND its members in
    # one collection, which RESTRICT allows; deleting a role that still has members stays refused.
    role = models.ForeignKey(Role, on_delete=models.RESTRICT, related_name="members")

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
    # The role the joiner gets; NULL (never set, or the role was deleted) means Member.
    role = models.ForeignKey(
        "Role", null=True, blank=True, on_delete=models.SET_NULL, related_name="+"
    )
    max_uses = models.PositiveIntegerField(default=0)
    uses = models.PositiveIntegerField(default=0)
    revoked_at = models.DateTimeField(null=True, blank=True)
    accepted_at = models.DateTimeField(null=True, blank=True)
    created_at = models.DateTimeField(default=timezone.now)

    def __str__(self) -> str:
        return f"invitation to {self.workspace_id}"
