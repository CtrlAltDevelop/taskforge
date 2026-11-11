"""Sprints: a time-boxed batch of a project's tasks, and the numbers its burndown is drawn from."""

import uuid

from django.db import models
from django.db.models import Q
from django.utils import timezone

from infrastructure.projects.models import Project
from infrastructure.workspaces.models import Workspace


class State(models.TextChoices):
    PLANNED = "planned"
    ACTIVE = "active"
    COMPLETED = "completed"


class Sprint(models.Model):
    """``planned`` -> ``active`` (Start) -> ``completed`` (Complete), never back. A project has at
    most one active sprint (a database rule). Start fixes the ``baseline_*`` scope; Complete fixes
    the ``completed_*`` / ``unfinished_tasks`` outcome that velocity is read from. ``version`` is
    bumped on every change, for the live-sync event."""

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    workspace = models.ForeignKey(Workspace, on_delete=models.CASCADE, related_name="+")
    project = models.ForeignKey(Project, on_delete=models.CASCADE, related_name="sprints")
    name = models.CharField(max_length=80)
    goal = models.CharField(max_length=500, blank=True)
    start_date = models.DateField()
    end_date = models.DateField()
    state = models.CharField(max_length=9, choices=State.choices, default=State.PLANNED)
    started_at = models.DateTimeField(null=True, blank=True)
    completed_at = models.DateTimeField(null=True, blank=True)
    baseline_points = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    baseline_tasks = models.PositiveIntegerField(default=0)
    completed_points = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    completed_tasks = models.PositiveIntegerField(default=0)
    unfinished_tasks = models.PositiveIntegerField(default=0)
    version = models.PositiveIntegerField(default=1)
    created_at = models.DateTimeField(default=timezone.now)
    updated_at = models.DateTimeField(default=timezone.now)

    class Meta:
        constraints = [
            models.UniqueConstraint(
                fields=["project"],
                condition=Q(state="active"),
                name="sprint_one_active_per_project",
            ),
            models.CheckConstraint(
                condition=Q(end_date__gte=models.F("start_date")), name="sprint_end_after_start"
            ),
        ]
        indexes = [models.Index(fields=["project", "state"], name="sprint_project_state_idx")]

    def __str__(self) -> str:
        return self.name


class EventKind(models.TextChoices):
    ADDED = "added"
    REMOVED = "removed"
    POINTS = "points"  # the points of a task in the sprint changed


class ScopeEvent(models.Model):
    """One change to what a sprint holds. ``after_start`` ones (made while it was active) are the
    scope changes a burndown shows as steps; the deltas are signed."""

    sprint = models.ForeignKey(Sprint, on_delete=models.CASCADE, related_name="events")
    task = models.ForeignKey("tasks.Task", on_delete=models.CASCADE, related_name="+")
    kind = models.CharField(max_length=7, choices=EventKind.choices)
    delta_points = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    delta_tasks = models.SmallIntegerField(default=0)
    after_start = models.BooleanField(default=False)
    at = models.DateTimeField(default=timezone.now)

    class Meta:
        indexes = [models.Index(fields=["sprint", "after_start", "at"], name="sprint_event_idx")]

    def __str__(self) -> str:
        return f"{self.kind} {self.task_id} in {self.sprint_id}"


class Snapshot(models.Model):
    """The sprint at the end of local day ``date`` (taken at the workspace's midnight). A day the
    job missed is back-filled later from the state then current (``backfilled``); the scope of such
    a day is still exact, it is rebuilt from the events."""

    sprint = models.ForeignKey(Sprint, on_delete=models.CASCADE, related_name="snapshots")
    date = models.DateField()
    remaining_points = models.DecimalField(max_digits=10, decimal_places=2)
    remaining_tasks = models.PositiveIntegerField()
    scope_points = models.DecimalField(max_digits=10, decimal_places=2)
    scope_tasks = models.PositiveIntegerField()
    backfilled = models.BooleanField(default=False)

    class Meta:
        constraints = [
            models.UniqueConstraint(fields=["sprint", "date"], name="sprint_snapshot_unique")
        ]

    def __str__(self) -> str:
        return f"{self.sprint_id} {self.date}"
