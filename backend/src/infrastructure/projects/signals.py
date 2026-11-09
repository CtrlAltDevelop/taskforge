"""``project_changed``: the hook phase 16 turns into the ``project.updated`` WebSocket event.

Sent through ``transaction.on_commit`` after every mutation (never on rollback) with
``project_id`` (str), ``workspace_id`` (str), ``version`` (int) and ``action``, one of
``created updated archived restored features member_added member_removed``.
Favorites are per-user preferences and send nothing.
"""

from typing import Any

from django.db import transaction
from django.dispatch import Signal

project_changed = Signal()


def announce(project: Any, action: str) -> None:
    from infrastructure.projects.models import Project

    payload = {
        "project_id": str(project.pk),
        "workspace_id": str(project.workspace_id),
        "version": project.version,
        "action": action,
    }
    transaction.on_commit(lambda: project_changed.send(sender=Project, **payload))
