"""Who may see a space, who is in it and who is told about it.

Every lookup is workspace-scoped first and membership-scoped second. A private group or a direct
message is visible only to the people with a row in it; ``#general`` to every active member of the
workspace; a project's channel to the people who can open the project; any other channel to every
active member (they join it to post). All of them need ``chat.read``, which guests do not hold.
Someone removed from the workspace is nobody here: their rows stay as history for the others.
"""

import uuid
from typing import Any

from django.db.models import Exists, OuterRef, Q, QuerySet

from infrastructure.chat.models import CHANNEL, DM, ChatMember, ChatSpace
from infrastructure.comments import mentions as comment_mentions
from infrastructure.common.errors import ApiError
from infrastructure.common.responses import ResponseTitle
from infrastructure.projects.models import Project
from infrastructure.workspaces import access
from infrastructure.workspaces.models import MemberStatus, Workspace, WorkspaceMember

READ = "chat.read"
POST = "chat.post"
MANAGE = "chat.manage"
ADMIN_ROLES = frozenset({"Owner", "Admin"})


def not_found() -> ApiError:
    return ApiError("No such space.", status=404)


def holders(workspace: Workspace, key: str = READ) -> set[Any]:
    """Ids of the active members whose role holds ``key``."""
    return set(
        WorkspaceMember.objects.filter(
            workspace=workspace,
            status=MemberStatus.ACTIVE,
            role__permissions__permission_key=key,
        ).values_list("user_id", flat=True)
    )


def visible_spaces(actor: Any, workspace: Workspace) -> QuerySet[ChatSpace]:
    """The spaces ``actor`` may read in ``workspace`` (the caller has checked ``chat.read``)."""
    mine = ChatMember.objects.filter(space_id=OuterRef("pk"), user=actor)
    seen_projects = Project.objects.visible_to(actor, workspace).values("pk")
    return ChatSpace.objects.filter(workspace=workspace).filter(
        Q(kind=CHANNEL, project__isnull=True)
        | Q(kind=CHANNEL, project__in=seen_projects)
        | (~Q(kind=CHANNEL) & Exists(mine))
    )


def space_for(actor: Any, workspace: Workspace, space_id: str) -> ChatSpace:
    """The space if ``actor`` may read it, else a 404 (never a hint that it exists)."""
    try:
        pk = uuid.UUID(str(space_id))
    except ValueError:
        raise not_found() from None
    space = visible_spaces(actor, workspace).filter(pk=pk).first()
    if space is None:
        raise not_found()
    return space


def _rows(space: ChatSpace) -> set[Any]:
    return set(ChatMember.objects.filter(space=space).values_list("user_id", flat=True))


def readers(space: ChatSpace) -> set[Any]:
    """Ids of the people who may read ``space``."""
    workspace = space.workspace
    active = set(
        WorkspaceMember.objects.filter(workspace=workspace, status=MemberStatus.ACTIVE).values_list(
            "user_id", flat=True
        )
    )
    if space.kind != CHANNEL:
        base = _rows(space) & active
    elif space.project_id is not None:
        base = comment_mentions.can_see(workspace, space.project)
    else:
        base = active
    return base & holders(workspace, READ)


def members(space: ChatSpace) -> set[Any]:
    """Ids of the people who are in ``space`` (a reader of a derived channel, else a row)."""
    if space.follows_workspace_or_project:
        return readers(space)
    return _rows(space) & readers(space)


def audience(space: ChatSpace) -> set[Any]:
    """Who is told live about what happens in ``space``: its members (and, for an open channel,
    the people who could join it)."""
    return readers(space)


def can_read(user_id: Any, space: ChatSpace) -> bool:
    return user_id in readers(space)


def is_member(user_id: Any, space: ChatSpace) -> bool:
    return user_id in members(space)


def is_admin(actor: Any, workspace: Workspace) -> bool:
    """A workspace Owner or Admin holding ``chat.manage``: moderates other people's spaces."""
    grant = access.grant_of(actor, workspace)
    return grant is not None and grant.role.name in ADMIN_ROLES and MANAGE in grant.keys


def manages(actor: Any, space: ChatSpace) -> bool:
    """May rename, archive and add or remove people: the space's owner holding ``chat.manage``,
    or a workspace Owner/Admin."""
    if is_admin(actor, space.workspace):
        return True
    grant = access.grant_of(actor, space.workspace)
    if grant is None or MANAGE not in grant.keys:
        return False
    return ChatMember.objects.filter(space=space, user=actor, role="owner").exists()


def peer(space: ChatSpace, user_id: Any) -> Any | None:
    """The other person of a direct message."""
    if space.kind != DM:
        return None
    others = [u for u in _rows(space) if u != user_id]
    return others[0] if others else None


def read_only(space: ChatSpace, user_id: Any) -> bool:
    """Archived, or a direct message whose other person left the workspace."""
    if space.is_archived:
        return True
    if space.kind == DM:
        other = peer(space, user_id)
        return other is None or other not in readers(space)
    return False


def require_post(actor: Any, space: ChatSpace) -> None:
    """Posting needs ``chat.post``, being in the space and a space that is not read-only."""
    access.require(actor, POST, space.workspace)
    if not is_member(actor.pk, space):
        raise ApiError("Join the channel to write in it.", status=403)
    if read_only(space, actor.pk):
        raise ApiError("This space is read-only.", status=409, title=ResponseTitle.CHAT_READ_ONLY)
