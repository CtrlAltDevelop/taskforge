"""What search reads: a folded-text row per task and comment, and recent queries."""

import uuid

from django.conf import settings as django_settings
from django.db import models
from django.utils import timezone

from infrastructure.tasks.models import Task
from infrastructure.workspaces.models import Workspace


class Kind(models.TextChoices):
    TASK = "task"
    COMMENT = "comment"
    DOC = "doc"


class SearchEntry(models.Model):
    """The searchable text of one task (title, description), one comment or one doc (``doc`` set,
    ``task`` empty), folded (see ``fold``). ``ref_id`` is the task's, comment's or doc's id;
    ``task`` is the task it is on (for a task, itself), so access, status and assignment are
    always read from the live task and a move, a rename of the project or a workflow change needs
    no reindex. On PostgreSQL the migration adds a
    generated ``search_vector`` column and the GIN indexes beside this table; nothing in Python
    writes it."""

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    workspace = models.ForeignKey(Workspace, on_delete=models.CASCADE, related_name="+")
    task = models.ForeignKey(Task, null=True, on_delete=models.CASCADE, related_name="+")
    doc = models.ForeignKey("wikidocs.Doc", null=True, on_delete=models.CASCADE, related_name="+")
    kind = models.CharField(max_length=8, choices=Kind.choices)
    ref_id = models.UUIDField()
    title = models.CharField(max_length=500, blank=True)  # tasks only
    body = models.TextField(blank=True)
    updated_at = models.DateTimeField(default=timezone.now)

    class Meta:
        constraints = [
            models.UniqueConstraint(fields=["kind", "ref_id"], name="search_entry_unique")
        ]
        indexes = [models.Index(fields=["workspace", "kind", "-updated_at"], name="search_ws_idx")]

    def __str__(self) -> str:
        return f"{self.kind} {self.ref_id}"


class SearchHistory(models.Model):
    """A query the person chose a result for, newest first, at most ``HISTORY_LIMIT`` each."""

    user = models.ForeignKey(
        django_settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="+"
    )
    workspace = models.ForeignKey(Workspace, on_delete=models.CASCADE, related_name="+")
    query = models.CharField(max_length=200)
    at = models.DateTimeField(default=timezone.now)

    class Meta:
        constraints = [
            models.UniqueConstraint(
                fields=["user", "workspace", "query"], name="search_hist_unique"
            )
        ]
        indexes = [models.Index(fields=["user", "workspace", "-at"], name="search_hist_idx")]

    def __str__(self) -> str:
        return self.query
