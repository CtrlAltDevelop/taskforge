"""What a token may do. A token holds the owner's permissions *intersected* with its scopes.

Three places enforce it, so no door is left open:

* ``access.grant_of`` narrows the permission keys a token-authenticated caller holds to the keys
  the scopes allow (``allowed_keys``), so a write the scopes do not cover is refused by the same
  ``access.require`` every service already calls;
* the public REST API asks for the scope of each route (``require``);
* a gRPC call is checked against ``grpc_scope`` before it runs: only the workspace, project, task
  and comment services are open to a token, and any other service is refused.

A token never manages tokens or webhooks, so a leaked one cannot mint a longer-lived one.
"""

from typing import Any, Final

from infrastructure.common.errors import ApiError
from infrastructure.common.responses import ResponseTitle

READ_SCOPES: Final = (
    "workspaces:read",
    "projects:read",
    "tasks:read",
    "comments:read",
)
WRITE_SCOPES: Final = ("projects:write", "tasks:write", "comments:write")
SCOPES: Final = (*READ_SCOPES, *WRITE_SCOPES)

SCOPE_LABELS: Final = {
    "workspaces:read": "See the workspace",
    "projects:read": "Read projects",
    "projects:write": "Create and change projects",
    "tasks:read": "Read tasks",
    "tasks:write": "Create, change and delete tasks",
    "comments:read": "Read comments",
    "comments:write": "Write comments",
}

# Permission keys a write scope may use. Every read goes through ``workspace.view``, which any
# scope grants (the per-resource read scope is checked at the door).
_KEYS_BY_SCOPE: Final = {
    "projects:write": ("project.create", "project.update", "project.archive"),
    "tasks:write": ("task.create", "task.update", "task.delete"),
    "comments:write": ("comment.create",),
}

_GRPC_AREAS: Final = {
    "ProjectService": "projects",
    "TaskService": "tasks",
    "CommentService": "comments",
}
_GRPC_READ_ACTIONS: Final = frozenset(
    {
        "List",
        "ListChildren",
        "ListTrash",
        "ListDeleted",
        "ListMembers",
        "Get",
        "GroupCounts",
        "History",
        "Mentionable",
    }
)

TOKEN_ATTRIBUTE: Final = "api_token"


def token_of(user: Any) -> Any | None:
    """The API token a caller authenticated with, or ``None`` for a signed-in person."""
    return getattr(user, TOKEN_ATTRIBUTE, None)


def clean(raw: Any) -> list[str]:
    """The distinct known scopes of ``raw``, in catalog order; ``ApiError`` if none or unknown."""
    wanted = {str(s) for s in raw or ()}
    unknown = sorted(wanted - set(SCOPES))
    if unknown:
        raise ApiError(f"Unknown scope: {unknown[0]}.", title=ResponseTitle.VALIDATION_ERROR)
    if not wanted:
        raise ApiError("Pick at least one scope.", title=ResponseTitle.VALIDATION_ERROR)
    return [s for s in SCOPES if s in wanted]


def allowed_keys(scopes: list[str]) -> frozenset[str]:
    """The permission keys a token with ``scopes`` may use."""
    keys: set[str] = {"workspace.view"} if scopes else set()
    for scope in scopes:
        keys.update(_KEYS_BY_SCOPE.get(scope, ()))
    return frozenset(keys)


def refused(scope: str) -> ApiError:
    return ApiError(
        f"This token lacks the {scope} scope.",
        status=403,
        title=ResponseTitle.PERMISSION_DENIED_REASON,
        data={"permission": scope, "hint": f"missing scope: {scope}"},
    )


def require(user: Any, scope: str) -> None:
    """Refuse a token that lacks ``scope``. A signed-in person is not limited by scopes."""
    token = token_of(user)
    if token is not None and scope not in token.scopes:
        raise refused(scope)


def grpc_scope(service: str, action: str) -> str | None:
    """The scope a gRPC action needs from a token, or ``None`` when no token may call it."""
    if service == "WorkspaceService":
        return "workspaces:read" if action == "List" else None
    area = _GRPC_AREAS.get(service)
    if area is None:
        return None
    return f"{area}:{'read' if action in _GRPC_READ_ACTIONS else 'write'}"


def check_grpc(user: Any, service: str, action: str) -> None:
    """Refuse a token for an action its scopes do not cover (nothing else if it is a person)."""
    token = token_of(user)
    if token is None:
        return
    needed = grpc_scope(service, action)
    if needed is None:
        raise ApiError(
            "API tokens cannot call this method.",
            status=403,
            title=ResponseTitle.PERMISSION_DENIED_REASON,
            data={"hint": "not available to API tokens"},
        )
    require(user, needed)
