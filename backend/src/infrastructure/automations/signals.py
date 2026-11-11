"""Tell the project's sockets that a rule or a run changed: ``automation.created`` /
``automation.updated`` / ``automation.deleted`` (entity: the rule) and ``automation.run`` (entity:
the run). A hint only: ids and a version, never a rule's content or a run's steps."""

from typing import Any

from django.db import transaction


def _announce(
    entity_id: Any, workspace_id: Any, project_id: Any, version: int, action: str
) -> None:
    payload = {
        "entity_type": "automation",
        "entity_id": entity_id,
        "workspace_id": workspace_id,
        "project_id": project_id,
        "version": version,
        "action": action,
    }

    def send() -> None:
        from infrastructure.sync import publish

        publish.record(**payload)

    transaction.on_commit(send)


def announce(automation: Any, action: str) -> None:
    """``created``, ``updated`` or ``deleted`` (call before the row is deleted)."""
    _announce(
        automation.pk, automation.workspace_id, automation.project_id, automation.version, action
    )


def announce_run(run: Any) -> None:
    """A run finished: ``automation.run`` for the run's id (a run has no version)."""
    _announce(run.pk, run.workspace_id, run.automation.project_id, 0, "run")
