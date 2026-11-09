"""Guards for workspace-scoped WebSockets (phase 16 mounts the socket that uses them).

A workspace socket resolves its workspace and permission through these two
coroutines (they run the ORM in a thread, like the gRPC adapters) and renders a
refusal with :func:`error_frame`. No workspace-scoped socket exists yet; the
tests drive a test-only handler.

Frames and what the socket does next:

* ``{"type": "error", "code": "permission_denied", "permission", "role", "hint"}``:
  a member lacks a key. Send it and keep the connection open; the user may do other things.
* ``{"type": "error", "code": "forbidden"}``: not a member, workspace deleted, unknown or
  malformed id -- one uniform answer with no reason, so ids cannot be probed. Send it, then
  close with :data:`FORBIDDEN_CLOSE_CODE`.
* ``{"type": "error", "code": "error", "detail": ...}``: any other refusal.
"""

from typing import Any, Final

from asgiref.sync import sync_to_async

from infrastructure.common.errors import ApiError
from infrastructure.workspaces import access
from infrastructure.workspaces.models import Workspace
from infrastructure.workspaces.scoping import require_workspace

# 4000-4999 is the application range; 4403 is taken by an origin refusal (config.sockets).
FORBIDDEN_CLOSE_CODE: Final = 4405


async def socket_workspace(user: Any, raw_id: str | None) -> Workspace:
    """The live workspace ``raw_id`` if ``user`` is a member holding ``workspace.view``."""
    return await sync_to_async(require_workspace)(user, raw_id, "workspace.view")


async def socket_require(user: Any, permission: str, workspace_id: str | None) -> Workspace:
    """Like :func:`socket_workspace`, and ``user`` must also hold ``permission`` there."""

    def check() -> Workspace:
        workspace = require_workspace(user, workspace_id)
        access.require(user, permission, workspace)
        return workspace

    return await sync_to_async(check)()


def error_frame(error: ApiError) -> dict[str, Any]:
    """The socket error frame for a refusal raised by the guards above."""
    if isinstance(error, access.PermissionDenied):
        return {"type": "error", "code": "permission_denied", **(error.data or {})}
    if error.status == 403:
        return {"type": "error", "code": "forbidden"}
    return {"type": "error", "code": "error", "detail": str(error)}
