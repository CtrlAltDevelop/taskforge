"""A project's workflow: its statuses, and the transitions allowed between them."""

import uuid

from django.db import models
from django.db.models import Q
from django.db.models.functions import Lower

from infrastructure.projects.models import Project
from infrastructure.workspaces.models import Role


class Category(models.TextChoices):
    """What a status means to reports and boards, whatever it is called."""

    NOT_STARTED = "not_started"
    ACTIVE = "active"
    DONE = "done"
    CANCELLED = "cancelled"


class Workflow(models.Model):
    """One per project. ``version`` is the optimistic lock of a whole-workflow save;
    ``restrict_transitions`` off means any status may move to any other;
    ``restrict_creation`` on means a new task can only start in the default status (it reaches
    the others by being moved), off (the default) means it may be created in any status."""

    project = models.OneToOneField(Project, on_delete=models.CASCADE, related_name="workflow")
    restrict_transitions = models.BooleanField(default=False)
    restrict_creation = models.BooleanField(default=False)
    version = models.PositiveIntegerField(default=1)

    def __str__(self) -> str:
        return f"workflow of {self.project_id}"


class Status(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    project = models.ForeignKey(Project, on_delete=models.CASCADE, related_name="statuses")
    name = models.CharField(max_length=40)
    color = models.CharField(max_length=7, blank=True)
    category = models.CharField(max_length=12, choices=Category.choices)
    position = models.PositiveIntegerField(default=0)
    is_default = models.BooleanField(default=False)

    class Meta:
        ordering = ["position", "name"]
        constraints = [
            models.UniqueConstraint(Lower("name"), "project", name="status_name_unique"),
            models.UniqueConstraint(
                "project",
                condition=Q(is_default=True),
                name="status_one_default_per_project",
            ),
        ]

    def __str__(self) -> str:
        return self.name


class Transition(models.Model):
    """An allowed move. Only consulted while the workflow restricts transitions.

    ``required_role`` set: only people holding exactly that role may make the move (if the role is
    deleted the condition is dropped with it, which relaxes the rule rather than blocking every
    move). ``require_assignee``: the task must have at least one assignee.
    """

    project = models.ForeignKey(Project, on_delete=models.CASCADE, related_name="transitions")
    from_status = models.ForeignKey(Status, on_delete=models.CASCADE, related_name="+")
    to_status = models.ForeignKey(Status, on_delete=models.CASCADE, related_name="+")
    required_role = models.ForeignKey(
        Role, null=True, blank=True, on_delete=models.SET_NULL, related_name="+"
    )
    require_assignee = models.BooleanField(default=False)

    class Meta:
        constraints = [
            models.UniqueConstraint(fields=["from_status", "to_status"], name="transition_unique")
        ]

    def __str__(self) -> str:
        return f"{self.from_status_id} -> {self.to_status_id}"
