"""``workflow_changed``: sent through ``transaction.on_commit`` after every saved workflow (never
on rollback) with ``project_id``, ``workspace_id`` (str) and ``version`` (int). Phase 16 turns it
into a WebSocket event so open editors and task pickers refresh.
"""

from typing import Any

from django.db import transaction
from django.dispatch import Signal

workflow_changed = Signal()


def announce(project: Any, version: int) -> None:
    from infrastructure.workflows.models import Workflow

    payload = {
        "project_id": str(project.pk),
        "workspace_id": str(project.workspace_id),
        "version": version,
    }
    transaction.on_commit(lambda: workflow_changed.send(sender=Workflow, **payload))
