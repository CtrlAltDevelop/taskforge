"""The audit log: one append-only row per change, written in the transaction of the change."""

from typing import Any, Final

from django.db import models
from django.utils import timezone


class ImmutableError(RuntimeError):
    """An audit row was asked to change or go away."""


class ActorType:
    USER: Final = "user"
    AUTOMATION: Final = "automation"
    SYSTEM: Final = "system"
    CHOICES: Final = ((USER, "User"), (AUTOMATION, "Automation"), (SYSTEM, "System"))


class AuditQuerySet(models.QuerySet["AuditEntry"]):
    """No bulk edit and no bulk delete: the log only grows."""

    def update(self, **kwargs: Any) -> int:
        raise ImmutableError("Audit entries cannot be changed.")

    def delete(self) -> tuple[int, dict[str, int]]:
        raise ImmutableError("Audit entries cannot be deleted.")

    def bulk_update(self, *args: Any, **kwargs: Any) -> int:
        raise ImmutableError("Audit entries cannot be changed.")


class AuditEntry(models.Model):
    """Who did what, to what, when. Ids are plain values (no foreign keys) so that deleting a
    workspace, project or person never has to touch the log. PostgreSQL also refuses UPDATE and
    DELETE on the table with a trigger (migration 0002), so not even the app's own role can."""

    workspace = models.UUIDField()
    actor = models.CharField(max_length=64, blank=True)  # a user id; empty for the system
    actor_type = models.CharField(max_length=12, choices=ActorType.CHOICES, default=ActorType.USER)
    action = models.CharField(max_length=80)  # task.status_changed, member.removed, ...
    target_type = models.CharField(max_length=40)
    target_id = models.CharField(max_length=64)
    project = models.UUIDField(null=True, blank=True)
    # {field: [before, after]} for an edit; {field: value} where a field has no "before".
    changes = models.JSONField(default=dict, blank=True)
    batch_id = models.UUIDField(null=True, blank=True)  # entries of one bulk operation
    ip = models.GenericIPAddressField(null=True, blank=True)
    user_agent = models.CharField(max_length=200, blank=True)
    at = models.DateTimeField(default=timezone.now)

    objects = AuditQuerySet.as_manager()

    class Meta:
        indexes = [
            models.Index(fields=["workspace", "at"], name="audit_ws_at_idx"),
            models.Index(fields=["workspace", "actor", "at"], name="audit_ws_actor_at_idx"),
            models.Index(fields=["target_type", "target_id"], name="audit_target_idx"),
            models.Index(fields=["batch_id"], name="audit_batch_idx"),
        ]

    def __str__(self) -> str:
        return f"{self.action} {self.target_type}:{self.target_id}"

    def save(self, *args: Any, **kwargs: Any) -> None:
        if not self._state.adding:
            raise ImmutableError("Audit entries cannot be changed.")
        super().save(*args, **kwargs)

    def delete(self, *args: Any, **kwargs: Any) -> tuple[int, dict[str, int]]:
        raise ImmutableError("Audit entries cannot be deleted.")
