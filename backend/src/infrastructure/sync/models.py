"""The change log: one row per committed change, its id the cursor a client catches up from."""

import uuid
from typing import Any

from django.db import models
from django.utils import timezone

from infrastructure.workspaces.models import Workspace


class ChangeLog(models.Model):
    """What changed, never the content. Appended after the change commits and trimmed after
    ``RETENTION_DAYS``; ``id`` only grows, so ``id > cursor`` is "everything since"."""

    id = models.BigAutoField(primary_key=True)
    workspace = models.ForeignKey(Workspace, on_delete=models.CASCADE, related_name="+")
    project = models.UUIDField(null=True, blank=True)  # none for a workspace-level change
    entity_type = models.CharField(max_length=12)  # task, project, workflow, fields, access
    entity_id = models.UUIDField(default=uuid.uuid4)
    version = models.PositiveIntegerField(default=0)
    action = models.CharField(max_length=16)
    actor = models.CharField(max_length=36, blank=True)
    at = models.DateTimeField(default=timezone.now)

    class Meta:
        indexes = [
            models.Index(fields=["workspace", "id"], name="changelog_ws_id_idx"),
            models.Index(fields=["at"], name="changelog_at_idx"),
        ]

    def __str__(self) -> str:
        return f"{self.entity_type}.{self.action} {self.entity_id} v{self.version}"

    @property
    def event_type(self) -> str:
        return event_type(self.entity_type, self.action)

    def as_event(self) -> dict[str, Any]:
        """The wire form: a hint (ids and a version), never private content."""
        return {
            "type": self.event_type,
            "workspace": str(self.workspace_id),
            "project": str(self.project) if self.project else "",
            "entity_id": str(self.entity_id),
            "version": self.version,
            "actor": self.actor,
            "ts": self.at.isoformat(),
            "cursor": self.pk,
        }


def event_type(entity_type: str, action: str) -> str:
    """``task.created`` / ``task.updated`` / ``task.deleted`` (every other task action is an
    update), ``project.created`` / ``project.updated``, ``comment.created`` / ``comment.updated`` /
    ``comment.deleted`` (whose ``entity_id`` is the *task* the comments belong to),
    ``attachment.added`` / ``attachment.deleted`` (likewise the *task*),
    ``sprint.created`` / ``sprint.updated`` (entity: the sprint), ``doc.created`` /
    ``doc.updated`` / ``doc.moved`` (entity: the page; a hint only, never its content),
    ``automation.created`` / ``automation.updated`` / ``automation.deleted`` (entity: the rule) and
    ``automation.run`` (entity: the run; a hint, never its steps), ``workflow.updated``,
    ``fields.updated`` and ``access.changed``."""
    if entity_type == "access":
        return "access.changed"
    if entity_type == "chat":
        # chat.message.created|updated|deleted, chat.space.updated, chat.read (entity: the space)
        return f"chat.{action}"
    if entity_type == "timer":
        return "timer.changed"  # your own timer or entries changed (entity: you)
    if entity_type == "notification":
        return f"notification.{action}"  # notification.new | notification.changed (entity: you)
    if entity_type == "attachment":
        return f"attachment.{action}"  # attachment.added | attachment.deleted
    if entity_type == "doc":
        return f"doc.{action}" if action in ("created", "moved") else "doc.updated"
    if entity_type == "automation":
        return (
            f"automation.{action}"
            if action in ("created", "deleted", "run")
            else "automation.updated"
        )
    if entity_type in ("task", "comment", "sprint") and action in ("created", "deleted"):
        return f"{entity_type}.{action}"
    if entity_type == "project" and action == "created":
        return "project.created"
    return f"{entity_type}.updated"


class TrimMark(models.Model):
    """The highest change-log id ever trimmed: a client whose cursor is behind it missed entries
    that no longer exist and has to read the screen again instead of catching up."""

    id = models.PositiveSmallIntegerField(primary_key=True, default=1)
    upto = models.BigIntegerField(default=0)

    def __str__(self) -> str:
        return f"trimmed up to {self.upto}"


class AppliedMutation(models.Model):
    """A change a client made offline and sent later, remembered by the id the client gave it, so
    sending it again (a retry after a dropped answer, a replay after a crash) does nothing twice:
    the second call answers with the entity as it is now. Only changes that were applied are
    recorded; a refused one can be sent again."""

    workspace = models.ForeignKey(Workspace, on_delete=models.CASCADE, related_name="+")
    client_mutation_id = models.UUIDField()
    actor = models.CharField(max_length=36)
    rpc = models.CharField(max_length=40)
    entity_type = models.CharField(max_length=12)
    entity_id = models.UUIDField()
    created_at = models.DateTimeField(default=timezone.now)

    class Meta:
        constraints = [
            models.UniqueConstraint(
                fields=["workspace", "client_mutation_id"], name="applied_mutation_unique"
            )
        ]
        indexes = [models.Index(fields=["created_at"], name="applied_mutation_at_idx")]

    def __str__(self) -> str:
        return f"{self.rpc} {self.client_mutation_id}"
