"""Goals (objectives), their key results, the tasks a key result counts and its check-ins."""

import uuid
from typing import Final

from django.conf import settings as django_settings
from django.db import models
from django.utils import timezone

from infrastructure.tasks.models import Task
from infrastructure.workspaces.models import Workspace


class KrType:
    NUMBER: Final = "number"
    PERCENTAGE: Final = "percentage"
    BOOLEAN: Final = "boolean"
    LINKED: Final = "linked"
    CHOICES: Final = (
        (NUMBER, "Number"),
        (PERCENTAGE, "Percentage"),
        (BOOLEAN, "True/false"),
        (LINKED, "Linked tasks"),
    )
    ALL: Final = frozenset({NUMBER, PERCENTAGE, BOOLEAN, LINKED})


class GoalStatus:
    ON_TRACK: Final = "on_track"
    AT_RISK: Final = "at_risk"
    OFF_TRACK: Final = "off_track"
    CHOICES: Final = (
        (ON_TRACK, "On track"),
        (AT_RISK, "At risk"),
        (OFF_TRACK, "Off track"),
    )
    ALL: Final = frozenset({ON_TRACK, AT_RISK, OFF_TRACK})


class GoalFolder(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    workspace = models.ForeignKey(Workspace, on_delete=models.CASCADE, related_name="+")
    name = models.CharField(max_length=80)
    position = models.PositiveIntegerField(default=0)
    created_at = models.DateTimeField(default=timezone.now)

    class Meta:
        ordering = ["position", "name"]

    def __str__(self) -> str:
        return self.name


class Goal(models.Model):
    """An objective. ``parent`` nests it under a bigger goal (its progress rolls up there with
    ``weight``). ``private`` hides it from members other than the owner, contributors and those
    who hold ``goal.manage``. ``status_override`` replaces the computed at-risk hint."""

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    workspace = models.ForeignKey(Workspace, on_delete=models.CASCADE, related_name="+")
    parent = models.ForeignKey(
        "self", null=True, blank=True, on_delete=models.SET_NULL, related_name="children"
    )
    folder = models.ForeignKey(
        GoalFolder, null=True, blank=True, on_delete=models.SET_NULL, related_name="goals"
    )
    name = models.CharField(max_length=160)
    description = models.CharField(max_length=2000, blank=True)
    owner = models.ForeignKey(
        django_settings.AUTH_USER_MODEL, null=True, on_delete=models.SET_NULL, related_name="+"
    )
    created_by = models.ForeignKey(
        django_settings.AUTH_USER_MODEL, null=True, on_delete=models.SET_NULL, related_name="+"
    )
    private = models.BooleanField(default=False)
    period_start = models.DateField()
    period_end = models.DateField()
    status_override = models.CharField(max_length=10, blank=True, choices=GoalStatus.CHOICES)
    weight = models.DecimalField(max_digits=8, decimal_places=2, default=1)
    version = models.PositiveIntegerField(default=1)
    created_at = models.DateTimeField(default=timezone.now)
    updated_at = models.DateTimeField(default=timezone.now)

    class Meta:
        indexes = [models.Index(fields=["workspace", "period_end"], name="goal_ws_end_idx")]
        ordering = ["period_end", "name"]

    def __str__(self) -> str:
        return self.name


class GoalContributor(models.Model):
    goal = models.ForeignKey(Goal, on_delete=models.CASCADE, related_name="contributors")
    user = models.ForeignKey(
        django_settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="+"
    )

    class Meta:
        constraints = [
            models.UniqueConstraint(fields=["goal", "user"], name="goal_contributor_unique")
        ]

    def __str__(self) -> str:
        return f"{self.goal_id}:{self.user_id}"


class KeyResult(models.Model):
    """One measurable result. number/percentage/boolean keep ``current_value`` (set by check-ins);
    ``linked`` counts tasks: those in ``KeyResultTask`` plus those matching the TFQL filter
    (``filter_text`` / ``filter_ast``), kept in ``linked_done`` / ``linked_total``."""

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    goal = models.ForeignKey(Goal, on_delete=models.CASCADE, related_name="key_results")
    name = models.CharField(max_length=160)
    type = models.CharField(max_length=10, choices=KrType.CHOICES)
    start_value = models.DecimalField(max_digits=18, decimal_places=4, default=0)
    target_value = models.DecimalField(max_digits=18, decimal_places=4, default=100)
    current_value = models.DecimalField(max_digits=18, decimal_places=4, default=0)
    filter_text = models.CharField(max_length=2000, blank=True)
    filter_ast = models.JSONField(null=True, blank=True)
    weight = models.DecimalField(max_digits=8, decimal_places=2, default=1)
    linked_done = models.PositiveIntegerField(default=0)
    linked_total = models.PositiveIntegerField(default=0)
    position = models.PositiveIntegerField(default=0)
    version = models.PositiveIntegerField(default=1)
    created_at = models.DateTimeField(default=timezone.now)
    updated_at = models.DateTimeField(default=timezone.now)

    class Meta:
        ordering = ["position", "created_at"]

    def __str__(self) -> str:
        return self.name


class KeyResultTask(models.Model):
    kr = models.ForeignKey(KeyResult, on_delete=models.CASCADE, related_name="picked")
    task = models.ForeignKey(Task, on_delete=models.CASCADE, related_name="+")

    class Meta:
        constraints = [models.UniqueConstraint(fields=["kr", "task"], name="kr_task_unique")]
        indexes = [models.Index(fields=["task"], name="krtask_task_idx")]

    def __str__(self) -> str:
        return f"{self.kr_id}:{self.task_id}"


class CheckIn(models.Model):
    """One reading of a key result. ``user`` is empty for the readings the system takes when a
    linked key result's tasks change. ``progress`` is the key result's progress (0-1) then."""

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    kr = models.ForeignKey(KeyResult, on_delete=models.CASCADE, related_name="check_ins")
    user = models.ForeignKey(
        django_settings.AUTH_USER_MODEL, null=True, on_delete=models.SET_NULL, related_name="+"
    )
    value = models.DecimalField(max_digits=18, decimal_places=4)
    previous_value = models.DecimalField(max_digits=18, decimal_places=4, default=0)
    progress = models.FloatField(default=0)
    note = models.CharField(max_length=2000, blank=True)
    at = models.DateTimeField(default=timezone.now)

    class Meta:
        ordering = ["-at", "-id"]
        indexes = [models.Index(fields=["kr", "-at"], name="checkin_kr_at_idx")]

    def __str__(self) -> str:
        return f"{self.kr_id}@{self.at:%Y-%m-%d}"


class ProgressDirty(models.Model):
    """A linked key result to recount once ``due_at`` has passed (the debounce of task events)."""

    kr = models.OneToOneField(KeyResult, on_delete=models.CASCADE, related_name="+")
    due_at = models.DateTimeField(db_index=True)

    def __str__(self) -> str:
        return str(self.kr_id)
