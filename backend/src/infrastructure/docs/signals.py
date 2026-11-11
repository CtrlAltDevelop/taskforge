"""Telling the rest of the system that a page changed.

``doc_changed`` (kwargs ``doc_id``, ``workspace_id``, ``project_id``, ``action``) feeds the search
index; ``announce`` writes the live-sync row: ``doc.created`` / ``doc.updated`` / ``doc.moved``.
Both are sent after the commit, and carry ids and a version only, never the page.
A page under a restriction is announced only to the people who may open it.
"""

from typing import Any

from django.db import transaction
from django.dispatch import Signal

doc_changed = Signal()


def announce(doc: Any, action: str, version: int) -> None:
    payload = {
        "entity_type": "doc",
        "entity_id": doc.pk,
        "workspace_id": doc.workspace_id,
        "project_id": doc.project_id,
        "version": version,
        "action": action,
    }
    signal = {
        "doc_id": str(doc.pk),
        "workspace_id": str(doc.workspace_id),
        "project_id": str(doc.project_id) if doc.project_id else "",
        "action": action,
    }

    def send() -> None:
        from infrastructure.docs import reach
        from infrastructure.sync import publish

        publish.record(**payload, users=reach.audience(doc))
        doc_changed.send(sender=None, **signal)

    transaction.on_commit(send)
