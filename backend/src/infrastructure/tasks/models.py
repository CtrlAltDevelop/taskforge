"""Tasks and who they are assigned to. A task's status is one of its project's workflow statuses."""

import uuid
from typing import Any

from django.conf import settings as django_settings
from django.db import models
from django.utils import timezone

from infrastructure.projects.models import Project
from infrastructure.workspaces.models import Workspace


class Priority(models.TextChoices):
    URGENT = "urgent"
    HIGH = "high"
    NORMAL = "normal"
    LOW = "low"
    NONE = "none"


class Task(models.Model):
    """``version`` is the whole-row counter; ``field_versions`` maps each field to the version
    that last changed it, which is how two people editing different fields never conflict."""

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    workspace = models.ForeignKey(Workspace, on_delete=models.CASCADE, related_name="+")
    project = models.ForeignKey(Project, on_delete=models.CASCADE, related_name="tasks")
    number = models.PositiveIntegerField()
    title = models.CharField(max_length=500)
    description = models.JSONField(default=dict, blank=True)
    status = models.ForeignKey("workflows.Status", on_delete=models.PROTECT, related_name="tasks")
    priority = models.CharField(max_length=8, choices=Priority.choices, default=Priority.NONE)
    start_date = models.DateField(null=True, blank=True)
    due_date = models.DateField(null=True, blank=True)
    created_by = models.ForeignKey(
        django_settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="+"
    )
    version = models.PositiveIntegerField(default=1)
    field_versions = models.JSONField(default=dict, blank=True)
    position = models.CharField(max_length=64)
    # Subtasks. ``path`` is the ids of every ancestor and the task itself, each followed by "/"
    # (so a subtree is ``path__startswith``); ``tree_key`` is the same chain of ``position``s,
    # each followed by "0", which sorts a parent immediately before its children in any collation;
    # ``progress_*`` count the live descendants (and the done ones), kept by the service.
    parent = models.ForeignKey(
        "self", null=True, blank=True, on_delete=models.CASCADE, related_name="children"
    )
    depth = models.PositiveSmallIntegerField(default=0)
    path = models.CharField(max_length=2048, default="")
    tree_key = models.CharField(max_length=2048, default="")
    progress_done = models.PositiveIntegerField(default=0)
    progress_total = models.PositiveIntegerField(default=0)
    created_at = models.DateTimeField(default=timezone.now)
    updated_at = models.DateTimeField(default=timezone.now)
    deleted_at = models.DateTimeField(null=True, blank=True)

    class Meta:
        constraints = [
            models.UniqueConstraint(fields=["project", "number"], name="task_number_unique")
        ]
        indexes = [
            models.Index(fields=["project", "status"], name="task_project_status_idx"),
            models.Index(fields=["project", "position", "number"], name="task_project_order_idx"),
            models.Index(fields=["due_date"], name="task_due_date_idx"),
            models.Index(fields=["project", "tree_key", "number"], name="task_project_tree_idx"),
            # varchar_pattern_ops (PostgreSQL; ignored elsewhere) lets ``path LIKE 'x%'`` use
            # the index whatever the database collation, which every subtree query relies on.
            models.Index(
                fields=["project", "path"],
                name="task_project_path_idx",
                opclasses=["uuid_ops", "varchar_pattern_ops"],
            ),
        ]

    def __str__(self) -> str:
        return self.display_id

    @property
    def display_id(self) -> str:
        return f"{self.project.key}-{self.number}"

    def assignee_ids(self) -> list[Any]:
        return [a.user_id for a in self.assignees.all()]


class TaskAssignee(models.Model):
    task = models.ForeignKey(Task, on_delete=models.CASCADE, related_name="assignees")
    user = models.ForeignKey(
        django_settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="task_assignments"
    )

    class Meta:
        constraints = [
            models.UniqueConstraint(fields=["task", "user"], name="task_assignee_unique")
        ]

    def __str__(self) -> str:
        return f"{self.user_id} on {self.task_id}"
