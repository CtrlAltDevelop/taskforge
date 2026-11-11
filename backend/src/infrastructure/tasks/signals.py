"""``task_changed``: the hook phase 16 turns into the ``task.created|updated|deleted`` events.

Sent through ``transaction.on_commit`` (never on rollback) with ``task_id``, ``project_id``,
``workspace_id`` (str), ``version`` (int) and ``action``: ``created updated deleted restored``
(and ``reparented``), plus ``linked`` / ``unlinked`` for both ends of a link added or removed (the
version is unchanged: the row did not change, its links and blocked state did).
"""

from typing import Any

from django.db import transaction
from django.dispatch import Signal

task_changed = Signal()
# What happened and to whom, for the notifications (phase 19). kwargs: ``task_id``, ``project_id``,
# ``workspace_id``, ``actor_id`` (str), ``version`` (int), ``kind`` (``created`` ``assigned``
# ``status_changed``) and ``data`` (``user_ids`` of the newly assigned; ``from_name``/``to_name``).
task_activity = Signal()


def announce(task: Any, action: str) -> None:
    from infrastructure.tasks.models import Task

    payload = {
        "task_id": str(task.pk),
        "project_id": str(task.project_id),
        "workspace_id": str(task.workspace_id),
        "version": task.version,
        "action": action,
    }
    transaction.on_commit(lambda: task_changed.send(sender=Task, **payload))


def announce_activity(task: Any, kind: str, actor: Any, **data: Any) -> None:
    from infrastructure.tasks.models import Task

    payload = {
        "task_id": str(task.pk),
        "project_id": str(task.project_id),
        "workspace_id": str(task.workspace_id),
        "actor_id": str(actor.pk),
        "version": task.version,
        "kind": kind,
        "data": data,
    }
    transaction.on_commit(lambda: task_activity.send(sender=Task, **payload))
