"""Phase 42: the system messages of a task's chat ("@Sara changed priority to High").

Written from the one "what changed" source (``audit.changes.updated`` for task fields, the task
service for assignees and subtasks) inside the changing transaction. Several changes by the same
actor to the same field within ``COALESCE_SECONDS`` become one message, unless a user message sits
between them. Only ids and raw values are stored; the client words the sentence.
"""

from datetime import timedelta
from typing import Any, Final

from django.utils import timezone

from infrastructure.audit import context
from infrastructure.comments.models import SYSTEM, Comment
from infrastructure.comments.signals import announce

COALESCE_SECONDS: Final = 300
# Audit field name -> the field name a message carries. Custom fields are never written (a
# restricted field's values must not reach people who may not see them).
FIELDS: Final = {
    "title": "title",
    "status_id": "status_id",
    "priority": "priority",
    "start_date": "start_date",
    "due_date": "due_date",
    "estimate_sec": "estimate_sec",
    "project_id": "project_id",
}


def _plain(value: Any) -> Any:
    if value is None or isinstance(value, (str, int, float, bool, list)):
        return value
    return str(value)


def _actor() -> tuple[str, str]:
    from infrastructure.sync.actor import current_actor

    kind = context.current_actor_type() or "user"
    who = context.current_actor_id() or (current_actor() if kind == "user" else "")
    return kind, who


def _user_id(actor_type: str, actor_id: str) -> str | None:
    """The author row for a person acting; ``None`` for an automation or a vanished user."""
    if actor_type != "user" or not actor_id:
        return None
    from django.contrib.auth import get_user_model

    return actor_id if get_user_model().objects.filter(pk=actor_id).exists() else None


def record(task: Any, field: str, before: Any, after: Any) -> Comment | None:
    """Write (or extend) the message for one field change; returns it."""
    before, after = _plain(before), _plain(after)
    if before == after:
        return None
    actor_type, actor_id = _actor()
    last = Comment.objects.filter(task=task).order_by("-created_at", "-id").first()
    if (
        last is not None
        and last.kind == SYSTEM
        and last.event
        and last.event["field"] == field
        and last.event["actor_type"] == actor_type
        and last.event["actor_id"] == actor_id
        and timezone.now() - last.created_at <= timedelta(seconds=COALESCE_SECONDS)
    ):
        event = {**last.event, "to": after}
        if event["from"] == event["to"]:
            last.delete()
            return None
        last.event = event
        last.version += 1
        last.save(update_fields=["event", "version"])
        announce(last, "updated")
        return last
    message = Comment.objects.create(
        workspace_id=task.workspace_id,
        task=task,
        author_id=_user_id(actor_type, actor_id),
        kind=SYSTEM,
        body={},
        event={
            "actor_type": actor_type,
            "actor_id": actor_id,
            "field": field,
            "from": before,
            "to": after,
        },
    )
    announce(message, "created")
    return message


def from_task_change(task: Any, changed: dict[str, list[Any]]) -> None:
    """``changed`` is the audit's ``{field: [before, after]}`` of a task row."""
    if "deleted_at" in changed:
        return
    for name, (before, after) in changed.items():
        if name in FIELDS:
            record(task, FIELDS[name], before, after)
