"""Tell the person's other devices that their timer or entries changed: a ``timer.changed`` event
in their own room (it carries no content: they read the timer and the lists again)."""

from typing import Any

from django.db import transaction


def announce(user: Any, workspace: Any) -> None:
    def send() -> None:
        from infrastructure.sync import publish

        publish.record(
            entity_type="timer",
            entity_id=user.pk,
            workspace_id=workspace.pk,
            action="changed",
            user_id=str(user.pk),
        )

    transaction.on_commit(send)
