"""Templates: a portable snapshot of a task tree or of a whole project."""

import uuid

from django.conf import settings as django_settings
from django.db import models
from django.utils import timezone

from infrastructure.workspaces.models import Workspace


class TemplateKind(models.TextChoices):
    TASK = "task"
    PROJECT = "project"


class TemplateVisibility(models.TextChoices):
    WORKSPACE = "workspace"
    PRIVATE = "private"


class Template(models.Model):
    """``content`` is the snapshot (see ``infrastructure.templates.content``): it names statuses,
    fields and parents by local keys, never by database ids of the project it came from, so it
    can be applied to any project. ``task_count`` is stored so the gallery never opens the
    content. A private template is visible to its creator only."""

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    workspace = models.ForeignKey(Workspace, on_delete=models.CASCADE, related_name="+")
    kind = models.CharField(max_length=8, choices=TemplateKind.choices)
    name = models.CharField(max_length=80)
    description = models.CharField(max_length=500, blank=True)
    content = models.JSONField(default=dict)
    task_count = models.PositiveIntegerField(default=0)
    visibility = models.CharField(
        max_length=10, choices=TemplateVisibility.choices, default=TemplateVisibility.WORKSPACE
    )
    created_by = models.ForeignKey(
        django_settings.AUTH_USER_MODEL, null=True, on_delete=models.SET_NULL, related_name="+"
    )
    version = models.PositiveIntegerField(default=1)
    created_at = models.DateTimeField(default=timezone.now)
    updated_at = models.DateTimeField(default=timezone.now)

    class Meta:
        indexes = [models.Index(fields=["workspace", "kind"], name="template_ws_kind_idx")]

    def __str__(self) -> str:
        return self.name
