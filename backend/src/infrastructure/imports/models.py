"""An import in progress or done, what it made (for idempotency and undo), and the people it could
not match to a member."""

import uuid
from typing import Final

from django.conf import settings as django_settings
from django.db import models
from django.utils import timezone

from infrastructure.projects.models import Project
from infrastructure.tasks.models import Task
from infrastructure.workspaces.models import Workspace


class Status:
    FETCHING: Final = "fetching"  # a ClickUp fetch is writing the file (phase 41)
    UPLOADED: Final = "uploaded"  # the file is stored; nothing has been read for the mapping
    ANALYZED: Final = "analyzed"  # the file was read and a mapping proposed
    QUEUED: Final = "queued"
    RUNNING: Final = "running"
    DONE: Final = "done"
    FAILED: Final = "failed"  # stopped by an error; Start again resumes
    CANCELLED: Final = "cancelled"  # stopped by a person; Start again resumes
    UNDONE: Final = "undone"
    ACTIVE: Final = (QUEUED, RUNNING)
    FINISHED: Final = (DONE, FAILED, CANCELLED, UNDONE)
    CHOICES: Final = tuple(
        (s, s.title())
        for s in (FETCHING, UPLOADED, ANALYZED, QUEUED, RUNNING, DONE, FAILED, CANCELLED, UNDONE)
    )


class ImportJob(models.Model):
    """One import. ``mapping`` is what the person chose (see ``mapping.py``), ``analysis`` what the
    file said, ``stats`` what was made, ``error_report`` the rows that were not (at most
    ``MAX_PROBLEMS``). ``done`` of ``total`` counts issues. ``heartbeat_at`` moves while a run is
    alive; a run that stops moving is resumed by ``imports_tick``."""

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    workspace = models.ForeignKey(Workspace, on_delete=models.CASCADE, related_name="+")
    project = models.ForeignKey(
        Project, null=True, blank=True, on_delete=models.SET_NULL, related_name="+"
    )
    source = models.CharField(max_length=20)
    status = models.CharField(max_length=10, choices=Status.CHOICES, default=Status.UPLOADED)
    filename = models.CharField(max_length=255)
    file_key = models.CharField(max_length=512)
    file_size = models.BigIntegerField(default=0)
    member = models.CharField(max_length=512, blank=True)  # the file inside a zip
    mapping = models.JSONField(default=dict)
    analysis = models.JSONField(default=dict)
    stats = models.JSONField(default=dict)
    error_report = models.JSONField(default=list)
    error = models.CharField(max_length=500, blank=True)
    phase = models.CharField(max_length=20, blank=True)
    total = models.PositiveIntegerField(default=0)
    done = models.PositiveIntegerField(default=0)
    attempts = models.PositiveSmallIntegerField(default=0)
    created_by = models.ForeignKey(
        django_settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="+"
    )
    created_at = models.DateTimeField(default=timezone.now)
    started_at = models.DateTimeField(null=True, blank=True)
    finished_at = models.DateTimeField(null=True, blank=True)
    heartbeat_at = models.DateTimeField(null=True, blank=True)
    run_token = models.UUIDField(null=True, blank=True)  # whoever holds it owns the run
    version = models.PositiveIntegerField(default=1)

    class Meta:
        indexes = [models.Index(fields=["workspace", "-created_at"], name="importjob_ws_idx")]

    def __str__(self) -> str:
        return f"{self.source} import {self.pk} ({self.status})"


class ImportedRef(models.Model):
    """That source entity ``source_id`` of ``entity_type`` became (or is) row ``entity_id``.

    Unique per ``(workspace, family, entity_type, source_id)``: the same issue is never imported
    twice into one workspace, whichever job or file it came from. ``created`` is false for a row
    the import found already there (it is not removed by an undo). ``meta`` holds what the
    row cannot: the original key, author, and the attachments' manifest."""

    workspace = models.ForeignKey(Workspace, on_delete=models.CASCADE, related_name="+")
    job = models.ForeignKey(ImportJob, on_delete=models.CASCADE, related_name="refs")
    family = models.CharField(max_length=10)
    entity_type = models.CharField(max_length=10)  # task comment link sprint status field project
    source_id = models.CharField(max_length=300)
    entity_id = models.UUIDField()
    meta = models.JSONField(default=dict, blank=True)

    class Meta:
        constraints = [
            models.UniqueConstraint(
                fields=["workspace", "family", "entity_type", "source_id"],
                name="importedref_unique",
            )
        ]
        indexes = [models.Index(fields=["job", "entity_type"], name="importedref_job_idx")]

    def __str__(self) -> str:
        return f"{self.entity_type} {self.source_id} -> {self.entity_id}"


class PlaceholderUser(models.Model):
    """Someone a file names who is not (yet) a member. Their tasks wait on ``PlaceholderAssignment``
    until the person joins with the same email (or an admin claims it for them)."""

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    workspace = models.ForeignKey(Workspace, on_delete=models.CASCADE, related_name="+")
    key = models.CharField(max_length=254)  # the email, or the name, lower case
    name = models.CharField(max_length=200)
    source_email = models.CharField(max_length=254, blank=True)
    claimed_by = models.ForeignKey(
        django_settings.AUTH_USER_MODEL,
        null=True,
        blank=True,
        on_delete=models.SET_NULL,
        related_name="+",
    )
    created_at = models.DateTimeField(default=timezone.now)

    class Meta:
        constraints = [
            models.UniqueConstraint(fields=["workspace", "key"], name="placeholder_unique")
        ]

    def __str__(self) -> str:
        return self.name


class PlaceholderAssignment(models.Model):
    task = models.ForeignKey(Task, on_delete=models.CASCADE, related_name="+")
    placeholder = models.ForeignKey(
        PlaceholderUser, on_delete=models.CASCADE, related_name="assignments"
    )

    class Meta:
        constraints = [
            models.UniqueConstraint(
                fields=["task", "placeholder"], name="placeholder_assign_unique"
            )
        ]

    def __str__(self) -> str:
        return f"{self.task_id} -> {self.placeholder_id}"


class ExportJob(models.Model):
    """An export being built (or built): a project, or every project the person can open.
    ``file_key`` is the zip in storage until ``purge_old`` removes it (a day later)."""

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    workspace = models.ForeignKey(Workspace, on_delete=models.CASCADE, related_name="+")
    project = models.ForeignKey(
        Project, null=True, blank=True, on_delete=models.CASCADE, related_name="+"
    )
    scope = models.CharField(max_length=10)  # project | workspace
    status = models.CharField(max_length=8, default="queued")  # queued running done failed expired
    file_key = models.CharField(max_length=512, blank=True)
    file_size = models.BigIntegerField(default=0)
    filename = models.CharField(max_length=255, blank=True)
    stats = models.JSONField(default=dict)
    error = models.CharField(max_length=500, blank=True)
    created_by = models.ForeignKey(
        django_settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="+"
    )
    created_at = models.DateTimeField(default=timezone.now)
    finished_at = models.DateTimeField(null=True, blank=True)

    def __str__(self) -> str:
        return f"{self.scope} export {self.pk} ({self.status})"
