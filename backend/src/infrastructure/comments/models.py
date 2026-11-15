"""Comments on a task: one level of replies, mentions, reactions and the history of edits."""

import uuid
from typing import Any

from django.conf import settings as django_settings
from django.db import models
from django.utils import timezone

from infrastructure.tasks.models import Task
from infrastructure.workspaces.models import Workspace


USER = "user"
SYSTEM = "system"


class Comment(models.Model):
    """``body`` is the shared rich-text document, rebuilt by ``body.clean`` (never as sent).
    ``deleted_at`` is a soft delete: the row stays so replies keep their place, and its body is
    emptied. ``version`` counts edits, starting at 1."""

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    workspace = models.ForeignKey(Workspace, on_delete=models.CASCADE, related_name="+")
    task = models.ForeignKey(Task, on_delete=models.CASCADE, related_name="comments")
    # Null for a system message made by an automation, form, import or the system itself.
    author = models.ForeignKey(
        django_settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name="+",
        null=True,
        blank=True,
    )
    kind = models.CharField(max_length=6, default="user")  # "user" | "system" (phase 42)
    # System messages only: {actor_type, actor_id, field, from, to}; ids and raw values.
    event = models.JSONField(null=True, blank=True)
    parent = models.ForeignKey(
        "self", null=True, blank=True, on_delete=models.CASCADE, related_name="replies"
    )
    body = models.JSONField(default=dict)
    created_at = models.DateTimeField(default=timezone.now)
    edited_at = models.DateTimeField(null=True, blank=True)
    deleted_at = models.DateTimeField(null=True, blank=True)
    pinned = models.BooleanField(default=False)
    version = models.PositiveIntegerField(default=1)

    class Meta:
        indexes = [models.Index(fields=["task", "created_at", "id"], name="comment_task_time_idx")]

    def __str__(self) -> str:
        return f"comment {self.pk} on {self.task_id}"

    @property
    def is_system(self) -> bool:
        return self.kind == SYSTEM

    @property
    def is_deleted(self) -> bool:
        return self.deleted_at is not None


class CommentRevision(models.Model):
    """The body a comment had before an edit replaced it, newest edit last."""

    comment = models.ForeignKey(Comment, on_delete=models.CASCADE, related_name="revisions")
    body = models.JSONField(default=dict)
    at = models.DateTimeField(default=timezone.now)

    class Meta:
        ordering = ["at", "id"]

    def __str__(self) -> str:
        return f"revision of {self.comment_id} at {self.at}"


class CommentMention(models.Model):
    """The people the current version of a comment mentions."""

    comment = models.ForeignKey(Comment, on_delete=models.CASCADE, related_name="mentions")
    user = models.ForeignKey(
        django_settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="+"
    )

    class Meta:
        constraints = [
            models.UniqueConstraint(fields=["comment", "user"], name="comment_mention_unique")
        ]

    def __str__(self) -> str:
        return f"{self.user_id} in {self.comment_id}"


class CommentReaction(models.Model):
    comment = models.ForeignKey(Comment, on_delete=models.CASCADE, related_name="reactions")
    user = models.ForeignKey(
        django_settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="+"
    )
    emoji = models.CharField(max_length=16)
    at = models.DateTimeField(default=timezone.now)

    class Meta:
        constraints = [
            models.UniqueConstraint(
                fields=["comment", "user", "emoji"], name="comment_reaction_unique"
            )
        ]
        indexes = [models.Index(fields=["comment"], name="comment_reaction_idx")]

    def __str__(self) -> str:
        return f"{self.emoji} by {self.user_id} on {self.comment_id}"


def reaction_summary(comment: Any) -> dict[str, list[str]]:
    """``{emoji: [user ids]}`` for a comment whose reactions were prefetched."""
    out: dict[str, list[str]] = {}
    for r in comment.reactions.all():
        out.setdefault(r.emoji, []).append(str(r.user_id))
    return out
