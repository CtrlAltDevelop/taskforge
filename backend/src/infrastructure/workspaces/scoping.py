"""Find the workspace a call is about, or refuse it.

Every workspace-scoped endpoint in later phases starts here. The client names a
workspace with gRPC metadata ``x-workspace`` or REST header ``X-Workspace``; this
returns it only if the caller is a member and it is not deleted.

Usage::

    # gRPC (async service method)
    user = require_caller(await grpc_caller(context))
    workspace = await grpc_workspace(context, user)

    # REST (Ninja endpoint with auth=api_auth)
    workspace = workspace_from_request(request)

    # then scope EVERY query:  Task.objects.filter(workspace=workspace, ...)

A non-member, a deleted workspace, a malformed id and an id that does not exist
all raise the same 403 / PERMISSION_DENIED, so ids cannot be probed.
"""

import uuid
from typing import Any

from asgiref.sync import sync_to_async
from django.http import HttpRequest

from infrastructure.common.errors import ApiError
from infrastructure.common.responses import ResponseTitle
from infrastructure.workspaces.models import MemberStatus, Workspace

WORKSPACE_METADATA_KEY = "x-workspace"
WORKSPACE_META_KEY = "HTTP_X_WORKSPACE"


def _forbidden() -> ApiError:
    return ApiError("No access to that workspace.", status=403, title=ResponseTitle.FORBIDDEN)


def require_workspace(user: Any, raw_id: str | None) -> Workspace:
    """Return the live workspace ``raw_id`` if ``user`` is a member, else raise 403."""
    if user is None or not getattr(user, "is_authenticated", False):
        raise _forbidden()
    try:
        workspace_id = uuid.UUID(str(raw_id))
    except ValueError:
        raise _forbidden() from None
    workspace = Workspace.objects.filter(
        pk=workspace_id,
        deleted_at__isnull=True,
        members__user=user,
        members__status=MemberStatus.ACTIVE,
    ).first()
    if workspace is None:
        raise _forbidden()
    return workspace


def workspace_from_request(request: HttpRequest) -> Workspace:
    """REST: resolve ``X-Workspace`` for ``request.user``."""
    return require_workspace(request.user, request.META.get(WORKSPACE_META_KEY))


def _grpc_workspace(context: Any, user: Any) -> Workspace:
    request = getattr(context, "http_request", None)
    meta = request.META if request is not None else {}
    raw = meta.get(WORKSPACE_METADATA_KEY) or meta.get(WORKSPACE_META_KEY)
    return require_workspace(user, raw)


async def grpc_workspace(context: Any, user: Any) -> Workspace:
    """gRPC: resolve ``x-workspace`` metadata for ``user``."""
    return await sync_to_async(_grpc_workspace)(context, user)
