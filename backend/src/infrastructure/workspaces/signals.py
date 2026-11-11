"""``access_changed``: who may see what changed (a member removed or given another role, a role's
permissions edited, a project's members or visibility changed).

Sent through ``transaction.on_commit`` with ``workspace_id`` (str) and ``user_id`` (str, ``""``
when it concerns everyone in the workspace, as a role edit does). The realtime socket re-checks
the rooms of the people it names, so access taken away stops live events at once.
"""

from typing import Any

from django.db import transaction
from django.dispatch import Signal

access_changed = Signal()


def announce_access(workspace: Any, user_id: Any = "") -> None:
    from infrastructure.workspaces.models import Workspace

    payload = {"workspace_id": str(workspace.pk), "user_id": str(user_id or "")}
    transaction.on_commit(lambda: access_changed.send(sender=Workspace, **payload))
