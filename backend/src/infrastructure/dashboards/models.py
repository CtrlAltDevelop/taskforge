"""A dashboard is a grid of widgets; a widget says which tasks, what to count and how to draw it."""

import uuid
from typing import Final

from django.conf import settings as django_settings
from django.db import models
from django.utils import timezone

from infrastructure.projects.models import Project
from infrastructure.workspaces.models import Workspace


class Visibility:
    PERSONAL: Final = "personal"  # the owner only
    PROJECT: Final = "project"  # whoever can open the project
    WORKSPACE: Final = "workspace"  # every member
    CHOICES: Final = (
        (PERSONAL, "Personal"),
        (PROJECT, "Project"),
        (WORKSPACE, "Workspace"),
    )


class Dashboard(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    workspace = models.ForeignKey(Workspace, on_delete=models.CASCADE, related_name="+")
    project = models.ForeignKey(
        Project, null=True, blank=True, on_delete=models.CASCADE, related_name="dashboards"
    )
    owner = models.ForeignKey(
        django_settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="+"
    )
    name = models.CharField(max_length=80)
    visibility = models.CharField(
        max_length=10, choices=Visibility.CHOICES, default=Visibility.PERSONAL
    )
    # [{"widget_id": ..., "x": 0, "y": 0, "w": 4, "h": 3}] on a 12-column grid.
    layout = models.JSONField(default=list, blank=True)
    version = models.PositiveIntegerField(default=1)
    created_at = models.DateTimeField(default=timezone.now)
    updated_at = models.DateTimeField(default=timezone.now)

    class Meta:
        indexes = [models.Index(fields=["workspace", "project"], name="dashboard_ws_project_idx")]

    def __str__(self) -> str:
        return self.name


class Widget(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    dashboard = models.ForeignKey(Dashboard, on_delete=models.CASCADE, related_name="widgets")
    type = models.CharField(max_length=12)  # number bar line pie table burndown workload
    title = models.CharField(max_length=80, blank=True)
    config = models.JSONField(default=dict, blank=True)  # see ``config.normalise``
    position = models.PositiveSmallIntegerField(default=0)
    version = models.PositiveIntegerField(default=1)  # bumps when the config changes (cache key)

    class Meta:
        ordering = ["position", "pk"]

    def __str__(self) -> str:
        return f"{self.type}:{self.title or self.pk}"
