"""The catalog of events a webhook may subscribe to, and the payload each carries.

Event ids are idempotent: the same change gives the same id (``evt_`` + a hash of the change's
identity, e.g. ``task.created:<task>:<version>``), whichever webhook it is sent to and however
often it is retried or resent, so a receiver can drop one it has already handled.
"""

import hashlib
from dataclasses import dataclass
from typing import Any, Final

PING: Final = "webhook.ping"


@dataclass(frozen=True, slots=True)
class Event:
    key: str
    label: str


CATALOG: Final = (
    Event("task.created", "A task is created"),
    Event("task.updated", "A task is edited"),
    Event("task.status_changed", "A task changes status"),
    Event("task.assigned", "People are assigned to a task"),
    Event("task.deleted", "A task is deleted"),
    Event("comment.created", "A comment is added"),
    Event("comment.updated", "A comment is edited"),
    Event("comment.deleted", "A comment is deleted"),
)
KEYS: Final = tuple(e.key for e in CATALOG)


def event_id(identity: str) -> str:
    return "evt_" + hashlib.sha256(identity.encode()).hexdigest()[:32]


def task_data(task: Any) -> dict[str, Any]:
    return {
        "id": str(task.pk),
        "key": task.display_id,
        "project_id": str(task.project_id),
        "title": task.title,
        "status": {"id": str(task.status_id), "name": task.status.name},
        "priority": task.priority,
        "start_date": task.start_date.isoformat() if task.start_date else None,
        "due_date": task.due_date.isoformat() if task.due_date else None,
        "parent_id": str(task.parent_id) if task.parent_id else None,
        "version": task.version,
        "created_at": task.created_at.isoformat(),
        "updated_at": task.updated_at.isoformat(),
        "deleted": task.deleted_at is not None,
    }


def comment_data(comment: Any, text: str) -> dict[str, Any]:
    return {
        "id": str(comment.pk),
        "task_id": str(comment.task_id),
        "author_id": str(comment.author_id),
        "parent_id": str(comment.parent_id) if comment.parent_id else None,
        "text": text,
        "version": comment.version,
        "created_at": comment.created_at.isoformat(),
        "deleted": comment.deleted_at is not None,
    }
