"""``attachment_changed``: ``attachment_id``, ``task_id``, ``project_id``, ``workspace_id`` (str)
and ``action`` (``added`` or ``deleted``), sent through ``transaction.on_commit``. The live feed
turns it into ``attachment.added|deleted`` events whose entity is the *task*."""

from typing import Any

from django.db import transaction
from django.dispatch import Signal

attachment_changed = Signal()


def announce(attachment: Any, action: str) -> None:
    from infrastructure.attachments.models import Attachment

    payload = {
        "attachment_id": str(attachment.pk),
        "task_id": str(attachment.task_id),
        "project_id": str(attachment.task.project_id),
        "workspace_id": str(attachment.workspace_id),
        "action": action,
    }
    transaction.on_commit(lambda: attachment_changed.send(sender=Attachment, **payload))
