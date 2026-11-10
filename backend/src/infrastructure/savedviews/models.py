"""A saved layout of one of a project's views."""

import uuid

from django.conf import settings as django_settings
from django.db import models
from django.db.models import Q
from django.db.models.functions import Lower
from django.utils import timezone

from infrastructure.projects.models import Project
from infrastructure.workspaces.models import Workspace


class SavedView(models.Model):
    """``owner`` set: a personal layout only that person sees. ``owner`` empty and ``is_shared``:
    a layout every member who can open the project sees. ``config`` is validated by
    ``savedviews.config`` and is the same shape for every view ``kind`` that reuses this table
    (only ``list`` exists so far). ``version`` is the optimistic lock of a save."""

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    workspace = models.ForeignKey(Workspace, on_delete=models.CASCADE, related_name="+")
    project = models.ForeignKey(Project, on_delete=models.CASCADE, related_name="saved_views")
    owner = models.ForeignKey(
        django_settings.AUTH_USER_MODEL,
        null=True,
        blank=True,
        on_delete=models.CASCADE,
        related_name="+",
    )
    kind = models.CharField(max_length=12, default="list")
    name = models.CharField(max_length=60)
    config = models.JSONField(default=dict)
    is_shared = models.BooleanField(default=False)
    version = models.PositiveIntegerField(default=1)
    created_at = models.DateTimeField(default=timezone.now)
    updated_at = models.DateTimeField(default=timezone.now)

    class Meta:
        constraints = [
            models.UniqueConstraint(
                Lower("name"),
                "owner",
                "project",
                "kind",
                condition=Q(owner__isnull=False),
                name="saved_view_personal_name_unique",
            ),
            models.UniqueConstraint(
                Lower("name"),
                "project",
                "kind",
                condition=Q(is_shared=True),
                name="saved_view_shared_name_unique",
            ),
            models.CheckConstraint(
                condition=Q(is_shared=True, owner__isnull=True)
                | Q(is_shared=False, owner__isnull=False),
                name="saved_view_shared_has_no_owner",
            ),
        ]
        indexes = [models.Index(fields=["project", "kind"], name="saved_view_project_idx")]

    def __str__(self) -> str:
        return self.name
