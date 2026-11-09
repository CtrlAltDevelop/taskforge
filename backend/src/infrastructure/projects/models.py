"""Projects, who belongs to a private one, and who starred which."""

import uuid
from typing import Any, Self

from django.conf import settings as django_settings
from django.db import models
from django.db.models import Exists, OuterRef, Q
from django.db.models.functions import Lower
from django.utils import timezone

from infrastructure.workspaces.models import MemberStatus, Workspace, WorkspaceMember


class Visibility(models.TextChoices):
    OPEN = "open"
    PRIVATE = "private"


class ProjectQuerySet(models.QuerySet["Project"]):
    def visible_to(self, user: Any, workspace: Workspace, *, as_admin: bool = False) -> Self:
        """THE entry point for reading a project on behalf of a person.

        Only active members of ``workspace`` get anything. They see its open projects and
        the private ones they are a ``ProjectMember`` of; every other private project is
        simply not there (so a lookup is a 404 and nothing leaks). ``as_admin`` also
        includes every private project: only for callers who already passed
        ``require(project.view_private / project.member.manage)``.
        """
        if user is None or not getattr(user, "is_authenticated", False):
            return self.none()
        active = WorkspaceMember.objects.filter(
            workspace_id=OuterRef("workspace_id"), user=user, status=MemberStatus.ACTIVE
        )
        rows = self.filter(Exists(active), workspace=workspace)
        if as_admin:
            return rows
        mine = ProjectMember.objects.filter(project_id=OuterRef("pk"), user=user)
        return rows.filter(Q(visibility=Visibility.OPEN) | Exists(mine))


class Project(models.Model):
    """``task_counter`` is the last task number handed out (phase 06 prefixes it with ``key``).

    ``settings["features"]`` holds the enabled feature keys. ``version`` is the optimistic lock.
    """

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    workspace = models.ForeignKey(Workspace, on_delete=models.CASCADE, related_name="projects")
    name = models.CharField(max_length=80)
    key = models.CharField(max_length=6)
    description = models.CharField(max_length=2000, blank=True)
    icon = models.CharField(max_length=32, blank=True)
    color = models.CharField(max_length=7, blank=True)
    visibility = models.CharField(
        max_length=10, choices=Visibility.choices, default=Visibility.OPEN
    )
    archived_at = models.DateTimeField(null=True, blank=True)
    settings = models.JSONField(default=dict, blank=True)
    task_counter = models.PositiveIntegerField(default=0)
    created_by = models.ForeignKey(
        django_settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="+"
    )
    created_at = models.DateTimeField(default=timezone.now)
    updated_at = models.DateTimeField(default=timezone.now)
    version = models.PositiveIntegerField(default=1)

    objects = ProjectQuerySet.as_manager()

    class Meta:
        constraints = [
            models.UniqueConstraint(Lower("key"), "workspace", name="project_key_unique")
        ]

    def __str__(self) -> str:
        return self.key


class ProjectMember(models.Model):
    project = models.ForeignKey(Project, on_delete=models.CASCADE, related_name="members")
    user = models.ForeignKey(
        django_settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name="project_memberships",
    )
    added_at = models.DateTimeField(default=timezone.now)

    class Meta:
        constraints = [
            models.UniqueConstraint(fields=["project", "user"], name="project_member_unique")
        ]

    def __str__(self) -> str:
        return f"{self.user_id} in {self.project_id}"


class ProjectFavorite(models.Model):
    user = models.ForeignKey(
        django_settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="project_favorites"
    )
    project = models.ForeignKey(Project, on_delete=models.CASCADE, related_name="favorites")

    class Meta:
        constraints = [
            models.UniqueConstraint(fields=["user", "project"], name="project_favorite_unique")
        ]

    def __str__(self) -> str:
        return f"{self.user_id} starred {self.project_id}"
