"""``fields_changed``: sent through ``transaction.on_commit`` after every saved, archived,
restored or reordered field definition (never on rollback) with ``project_id``, ``workspace_id``
(str) and ``version`` (int, ``0`` for a reorder). Phase 16 turns it into a WebSocket event so open
editors and task panels refresh."""

from typing import Any

from django.db import transaction
from django.dispatch import Signal

fields_changed = Signal()


def announce(project: Any, version: int = 0) -> None:
    from infrastructure.customfields.models import FieldDefinition

    payload = {
        "project_id": str(project.pk),
        "workspace_id": str(project.workspace_id),
        "version": version,
    }
    transaction.on_commit(lambda: fields_changed.send(sender=FieldDefinition, **payload))
