"""Hooks other apps listen to, sent through ``transaction.on_commit`` (never on a rollback).

``comment_changed``: ``comment_id``, ``task_id``, ``project_id``, ``workspace_id`` (str),
``version`` (int) and ``action`` (``created`` ``updated`` ``deleted`` ``pinned`` ``reacted``). The
live feed turns it into ``comment.created|updated|deleted`` events.

``user_mentioned``: ``comment_id``, ``task_id``, ``project_id``, ``workspace_id``, ``user_id`` (the
person mentioned), ``author_id`` and ``version``. Sent once per person per version of a comment: on
creation for everyone it mentions, on an edit only for people it newly mentions. Phase 19 (the
notifications) listens to it.
"""

from typing import Any

from django.db import transaction
from django.dispatch import Signal

comment_changed = Signal()
user_mentioned = Signal()


def announce(comment: Any, action: str) -> None:
    from infrastructure.comments.models import Comment

    payload = {
        "comment_id": str(comment.pk),
        "task_id": str(comment.task_id),
        "project_id": str(comment.task.project_id),
        "workspace_id": str(comment.workspace_id),
        "version": comment.version,
        "action": action,
    }
    transaction.on_commit(lambda: comment_changed.send(sender=Comment, **payload))


def announce_mentions(comment: Any, user_ids: list[Any]) -> None:
    from infrastructure.comments.models import Comment

    base = {
        "comment_id": str(comment.pk),
        "task_id": str(comment.task_id),
        "project_id": str(comment.task.project_id),
        "workspace_id": str(comment.workspace_id),
        "author_id": str(comment.author_id),
        "version": comment.version,
    }
    for user_id in user_ids:
        payload = {**base, "user_id": str(user_id)}
        transaction.on_commit(lambda p=payload: user_mentioned.send(sender=Comment, **p))
