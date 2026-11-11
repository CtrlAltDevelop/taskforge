"""Who may listen to a room. Checked when a connection joins and again whenever access may have
changed, because a room's name is not a secret: the check is the only thing keeping a private
project's events from someone who is not in it."""

import uuid
from typing import Any, Final

from infrastructure.common.errors import ApiError
from infrastructure.projects.models import Project
from infrastructure.workspaces.scoping import require_workspace

KINDS: Final = ("ws", "proj", "user")


def parse(room: str) -> tuple[str, uuid.UUID] | None:
    """``("proj", <uuid>)`` for ``proj:<uuid>``, or ``None`` for anything that is not a room."""
    kind, _, raw = str(room).partition(":")
    if kind not in KINDS:
        return None
    try:
        return kind, uuid.UUID(raw)
    except ValueError:
        return None


def may_join(user: Any, room: str) -> bool:
    """Whether ``user`` may listen to ``room``: their own ``user:`` room; a workspace they are a
    member of (with ``workspace.view``); a project they can open in such a workspace."""
    parsed = parse(room)
    if parsed is None or user is None:
        return False
    kind, pk = parsed
    if kind == "user":
        return str(pk) == str(user.pk)
    try:
        if kind == "ws":
            require_workspace(user, str(pk), "workspace.view")
            return True
        workspace_id = Project.objects.filter(pk=pk).values_list("workspace_id", flat=True).first()
        if workspace_id is None:
            return False
        workspace = require_workspace(user, str(workspace_id), "workspace.view")
    except ApiError:
        return False
    return Project.objects.visible_to(user, workspace).filter(pk=pk).exists()
