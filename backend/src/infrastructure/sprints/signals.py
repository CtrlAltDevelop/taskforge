"""Tell the project's sockets that a sprint changed: ``sprint.created`` / ``sprint.updated``."""

from typing import Any

from django.db import transaction


def announce(sprint: Any, action: str) -> None:
    payload = {
        "entity_type": "sprint",
        "entity_id": sprint.pk,
        "workspace_id": sprint.workspace_id,
        "project_id": sprint.project_id,
        "version": sprint.version,
        "action": action,
    }

    def send() -> None:
        from infrastructure.sync import publish

        publish.record(**payload)

    transaction.on_commit(send)
