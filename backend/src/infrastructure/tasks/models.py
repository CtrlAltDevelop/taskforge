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
    # Not stored: the services set it on the tasks they return (see ``links.blocked_ids``).
    is_blocked = False
    blockers: tuple[str, ...] = ()  # "WEB-4 (In progress)" or "Restricted task", for the caller
    custom_values: dict[str, str] = {}  # custom field id -> wire value (see customfields.values)

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


class LinkType(models.TextChoices):
    """Stored once, ``from_task`` -> ``to_task``: "blocks", "duplicates" (``from_task`` is the
    duplicate) or "relates" (the pair is stored in id order so it has no mirror image)."""

    BLOCKS = "blocks"
    RELATES = "relates"
    DUPLICATES = "duplicates"


class TaskLink(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    workspace = models.ForeignKey(Workspace, on_delete=models.CASCADE, related_name="+")
    from_task = models.ForeignKey(Task, on_delete=models.CASCADE, related_name="links_out")
    to_task = models.ForeignKey(Task, on_delete=models.CASCADE, related_name="links_in")
    type = models.CharField(max_length=10, choices=LinkType.choices)
    created_by = models.ForeignKey(
        django_settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="+"
    )
    created_at = models.DateTimeField(default=timezone.now)

    class Meta:
        constraints = [
            models.UniqueConstraint(
                fields=["from_task", "to_task", "type"], name="task_link_unique"
            ),
            models.CheckConstraint(
                condition=~models.Q(from_task=models.F("to_task")), name="task_link_not_self"
            ),
        ]
        indexes = [models.Index(fields=["to_task", "type"], name="task_link_to_idx")]

    def __str__(self) -> str:
        return f"{self.from_task_id} {self.type} {self.to_task_id}"


class BlockOverride(models.Model):
    """The record an override leaves: who completed a blocked task anyway, and the open blockers."""

    task = models.ForeignKey(Task, on_delete=models.CASCADE, related_name="+")
    actor = models.ForeignKey(
        django_settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="+"
    )
    blockers = models.TextField()  # display ids, as they were, whoever could see them
    created_at = models.DateTimeField(default=timezone.now)

    def __str__(self) -> str:
        return f"{self.actor_id} overrode {self.blockers} on {self.task_id}"
