"""Automations: a rule (when -> if -> then) and the record of each time it ran."""

import uuid

from django.conf import settings
from django.db import models
from django.db.models import Q
from django.utils import timezone

from infrastructure.projects.models import Project
from infrastructure.workspaces.models import Workspace


class Automation(models.Model):
    """One rule of one project. ``trigger`` is ``{"type": ..., ...}``, ``condition_ast`` a TFQL
    AST (``{}`` for none) and ``actions`` a list of ``{"type": ..., ...}``, all validated by
    ``infrastructure.automations.spec``. The rule runs with ``owner``'s permissions and never
    more. ``disabled_reason`` says why it was switched off by the system. ``version`` is bumped on
    every change."""

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    workspace = models.ForeignKey(Workspace, on_delete=models.CASCADE, related_name="+")
    project = models.ForeignKey(Project, on_delete=models.CASCADE, related_name="automations")
    name = models.CharField(max_length=80)
    enabled = models.BooleanField(default=True)
    trigger = models.JSONField(default=dict)
    condition_ast = models.JSONField(default=dict, blank=True)
    actions = models.JSONField(default=list)
    owner = models.ForeignKey(
        settings.AUTH_USER_MODEL, null=True, on_delete=models.SET_NULL, related_name="+"
    )
    disabled_reason = models.CharField(max_length=500, blank=True)
    version = models.PositiveIntegerField(default=1)
    created_at = models.DateTimeField(default=timezone.now)
    updated_at = models.DateTimeField(default=timezone.now)

    class Meta:
        indexes = [models.Index(fields=["project", "enabled"], name="automation_project_idx")]

    def __str__(self) -> str:
        return self.name

    @property
    def actor_label(self) -> str:
        return f"Automation: {self.name}"


class RunStatus(models.TextChoices):
    SUCCEEDED = "succeeded"
    FAILED = "failed"
    SKIPPED_CONDITION = "skipped_condition"
    SKIPPED_LOOP = "skipped_loop"
    SKIPPED_RATE = "skipped_rate"


class AutomationRun(models.Model):
    """One evaluation of a rule for one event on one task. ``event_key`` is the id of the event, so
    the same event can never run a rule twice (a retry finds this row). ``depth`` is how many
    automations in a row led here. ``input`` is the event and the task as the rule saw it,
    ``steps`` what each action did (or why it did not), ``explanation`` the plain reason a run did
    not do anything."""

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    automation = models.ForeignKey(Automation, on_delete=models.CASCADE, related_name="runs")
    workspace = models.ForeignKey(Workspace, on_delete=models.CASCADE, related_name="+")
    task = models.ForeignKey("tasks.Task", null=True, on_delete=models.SET_NULL, related_name="+")
    event_key = models.CharField(max_length=200)
    depth = models.PositiveSmallIntegerField(default=0)
    status = models.CharField(max_length=20, choices=RunStatus.choices)
    input = models.JSONField(default=dict)
    steps = models.JSONField(default=list)
    error = models.CharField(max_length=1000, blank=True)
    explanation = models.CharField(max_length=1000, blank=True)
    started_at = models.DateTimeField(default=timezone.now)
    finished_at = models.DateTimeField(null=True, blank=True)

    class Meta:
        constraints = [
            models.UniqueConstraint(
                fields=["automation", "task", "event_key"],
                condition=Q(task__isnull=False),
                name="automation_run_once_per_event",
            )
        ]
        indexes = [
            models.Index(fields=["automation", "-started_at"], name="automation_run_idx"),
            models.Index(fields=["started_at"], name="automation_run_time_idx"),
        ]

    def __str__(self) -> str:
        return f"{self.automation_id} {self.status}"
