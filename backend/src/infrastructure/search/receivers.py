"""Task and comment changes keep the index current (they fire after the commit)."""

from typing import Any

from infrastructure.comments.signals import comment_changed
from infrastructure.search import index
from infrastructure.search.models import Kind
from infrastructure.tasks.signals import task_changed

TASK_WRITES = {"created", "updated", "restored", "reparented"}
COMMENT_WRITES = {"created", "updated"}


def on_task(sender: Any, task_id: str, action: str, **_: Any) -> None:
    if action in TASK_WRITES:
        index.put_task(task_id)
    elif action == "deleted":
        index.drop(Kind.TASK, task_id)


def on_comment(sender: Any, comment_id: str, action: str, **_: Any) -> None:
    if action in COMMENT_WRITES:
        index.put_comment(comment_id)
    elif action == "deleted":
        index.drop(Kind.COMMENT, comment_id)


def connect() -> None:
    task_changed.connect(on_task, dispatch_uid="search.task")
    comment_changed.connect(on_comment, dispatch_uid="search.comment")
