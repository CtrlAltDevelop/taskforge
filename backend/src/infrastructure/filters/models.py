"""A saved filter: a name and the AST of a TFQL query (see ``language``)."""

import uuid

from django.conf import settings as django_settings
from django.db import models
from django.db.models import Q
from django.db.models.functions import Lower
from django.utils import timezone

from infrastructure.projects.models import Project
from infrastructure.workspaces.models import Workspace


class Visibility(models.TextChoices):
    PRIVATE = "private"  # only its owner
    PROJECT = "project"  # everyone who can open its project
    WORKSPACE = "workspace"  # everyone in the workspace (no project: built-in fields only)


class SavedFilter(models.Model):
    """``ast`` holds field and value *ids* (so a rename never breaks it); the text is rendered from
    it. ``owner`` made it, also when it is shared. ``version`` is the optimistic lock of a save."""

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    workspace = models.ForeignKey(Workspace, on_delete=models.CASCADE, related_name="+")
    project = models.ForeignKey(
        Project, null=True, blank=True, on_delete=models.CASCADE, related_name="saved_filters"
    )
    owner = models.ForeignKey(
        django_settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="+"
    )
    name = models.CharField(max_length=60)
    ast = models.JSONField(default=dict)
    visibility = models.CharField(
        max_length=10, choices=Visibility.choices, default=Visibility.PRIVATE
    )
    version = models.PositiveIntegerField(default=1)
    created_at = models.DateTimeField(default=timezone.now)
    updated_at = models.DateTimeField(default=timezone.now)

    class Meta:
        constraints = [
            models.UniqueConstraint(
                Lower("name"),
                "owner",
                "project",
                condition=Q(visibility="private") & Q(project__isnull=False),
                name="saved_filter_private_project_name_unique",
            ),
            models.UniqueConstraint(
                Lower("name"),
                "owner",
                "workspace",
                condition=Q(visibility="private") & Q(project__isnull=True),
                name="saved_filter_private_workspace_name_unique",
            ),
            models.UniqueConstraint(
                Lower("name"),
                "project",
                condition=Q(visibility="project"),
                name="saved_filter_project_name_unique",
            ),
            models.UniqueConstraint(
                Lower("name"),
                "workspace",
                condition=Q(visibility="workspace"),
                name="saved_filter_workspace_name_unique",
            ),
            models.CheckConstraint(
                condition=~Q(visibility="project", project__isnull=True)
                & ~Q(visibility="workspace", project__isnull=False),
                name="saved_filter_visibility_matches_scope",
            ),
        ]
        indexes = [models.Index(fields=["workspace", "project"], name="saved_filter_scope_idx")]

    def __str__(self) -> str:
        return self.name
