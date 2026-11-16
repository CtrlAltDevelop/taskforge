"""Chat spaces: the rules. Adapters only authenticate, call these and serialize.

Reading needs ``chat.read`` and a space the caller can see (see ``access``); anything else is a 404.
Creating a channel or group and opening a direct message needs ``chat.post``/``chat.manage``;
archiving and renaming is for the space's owner or a workspace Owner/Admin. ``#general`` and a
project's channel follow the workspace and the project (hooks at the bottom keep them in step);
read state and settings live in ``ChatMember`` rows.
"""

import uuid
from dataclasses import dataclass, field
from datetime import UTC, datetime
from typing import Any, Final

from django.contrib.auth import get_user_model
from django.db import IntegrityError, transaction
from django.db.models import Count, F, Max, Q
from django.utils import timezone

from infrastructure.audit import changes
from infrastructure.chat import access
from infrastructure.chat.models import (
    CHANNEL,
    DM,
    GROUP,
    OWNER,
    ChatMember,
    ChatMessage,
    ChatSpace,
)
from infrastructure.chat.signals import announce
from infrastructure.comments import mentions as comment_mentions
from infrastructure.comments.models import Comment
from infrastructure.common.errors import ApiError
from infrastructure.common.responses import ResponseTitle
from infrastructure.projects.models import Project
from infrastructure.tasks.models import Task
from infrastructure.workspaces import access as workspace_access
from infrastructure.workspaces.models import MemberStatus, Workspace, WorkspaceMember

NAME_MAX: Final = 80
GROUP_MIN: Final = 2
GROUP_MAX: Final = 100
TASK_CHATS_MAX: Final = 50
PICKER_LIMIT: Final = 20
FOREVER: Final = datetime(2100, 1, 1, tzinfo=UTC)
FORMER_MEMBER: Final = "Former member"


def invalid(message: str) -> ApiError:
    return ApiError(message, title=ResponseTitle.CHAT_INVALID)


@dataclass
class SpaceList:
    channels: list[ChatSpace] = field(default_factory=list)
    groups: list[ChatSpace] = field(default_factory=list)
    dms: list[ChatSpace] = field(default_factory=list)
    task_chats: list[dict[str, str]] = field(default_factory=list)


# -- names and people -------------------------------------------------------------------------


def _name(value: str) -> str:
    cleaned = " ".join(str(value).split()).lstrip("#")
    if not cleaned or len(cleaned) > NAME_MAX:
        raise invalid(f"A name is 1 to {NAME_MAX} characters.")
    if any(not ch.isprintable() for ch in cleaned):
        raise invalid("A name cannot hold control characters.")
    return cleaned


def _people(workspace: Workspace, raw_ids: list[str]) -> list[Any]:
    """Active members of the workspace holding ``chat.read``, or a refusal naming nobody twice."""
    ids: list[uuid.UUID] = []
    for raw in raw_ids:
        try:
            ident = uuid.UUID(str(raw))
        except ValueError:
            raise invalid("Unknown person.") from None
        if ident not in ids:
            ids.append(ident)
    allowed = access.holders(workspace) & set(ids)
    if len(allowed) != len(ids):
        raise invalid("Everyone added must be a member who can use chat.")
    return list(get_user_model().objects.filter(pk__in=ids).select_related("profile"))


def name_of(workspace: Workspace, user: Any) -> str:
    """The person's name, or "Former member" once they left the workspace."""
    active = WorkspaceMember.objects.filter(
        workspace=workspace, user=user, status=MemberStatus.ACTIVE
    ).exists()
    return comment_mentions.display_name(user) if active else FORMER_MEMBER


def _dm_key(a: Any, b: Any) -> str:
    return "_".join(sorted((str(a), str(b))))


# -- presenting -------------------------------------------------------------------------------


def present(actor: Any, spaces: list[ChatSpace]) -> list[ChatSpace]:
    """Attach what a client shows of each space for ``actor``: ``joined``, ``role``, settings,
    ``unread`` (messages by others after the caller's read mark), ``last_message_at``,
    ``member_count``, ``read_only`` and, for a direct message, the other person."""
    ids = [s.pk for s in spaces]
    rows = {m.space_id: m for m in ChatMember.objects.filter(space_id__in=ids, user=actor)}
    unread = dict(
        ChatMember.objects.filter(space_id__in=ids, user=actor)
        .annotate(
            n=Count(
                "space__messages",
                filter=Q(
                    space__messages__created_at__gt=F("last_read_at"),
                    space__messages__deleted_at__isnull=True,
                )
                & ~Q(space__messages__author=actor),
            )
        )
        .values_list("space_id", "n")
    )
    last = dict(
        ChatMessage.objects.filter(space_id__in=ids, deleted_at__isnull=True)
        .values("space_id")
        .annotate(at=Max("created_at"))
        .values_list("space_id", "at")
    )
    for s in spaces:
        row = rows.get(s.pk)
        s.joined = s.follows_workspace_or_project or row is not None
        s.my_role = row.role if row else ""
        s.my_row = row
        s.unread = unread.get(s.pk, 0)
        s.last_message_at = last.get(s.pk)
        s.member_count = len(access.members(s))
        s.read_only = access.read_only(s, actor.pk)
        s.peer_id = ""
        s.display_name = s.name
        if s.kind == DM:
            other = access.peer(s, actor.pk)
            s.peer_id = str(other or "")
            person = get_user_model().objects.filter(pk=other).select_related("profile").first()
            s.display_name = name_of(s.workspace, person) if person else FORMER_MEMBER
    return spaces


def _present_one(actor: Any, space: ChatSpace) -> ChatSpace:
    return present(actor, [space])[0]


# -- listing ----------------------------------------------------------------------------------


def _ensure_rows(actor: Any, spaces: list[ChatSpace]) -> None:
    """Rows for the derived spaces the caller has none in yet, read up to now (a new member does
    not meet years of unread)."""
    derived = [s for s in spaces if s.follows_workspace_or_project]
    have = set(
        ChatMember.objects.filter(space__in=derived, user=actor).values_list("space_id", flat=True)
    )
    ChatMember.objects.bulk_create(
        [ChatMember(space=s, user=actor) for s in derived if s.pk not in have],
        ignore_conflicts=True,
    )


def list_spaces(
    actor: Any, workspace: Workspace, *, query: str = "", include_archived: bool = False
) -> SpaceList:
    """The caller's spaces: every channel they can see, their groups and DMs, and the tasks they
    can open that have a chat. ``query`` filters by name (a DM by the other person's name)."""
    workspace_access.require(actor, access.READ, workspace)
    ensure_defaults(workspace)
    rows = access.visible_spaces(actor, workspace).select_related("workspace", "project")
    if not include_archived:
        rows = rows.filter(archived_at__isnull=True)
    found = list(rows.order_by("-is_default", "name", "created_at"))
    _ensure_rows(actor, found)
    present(actor, found)
    needle = query.strip().lower()
    if needle:
        found = [s for s in found if needle in s.display_name.lower()]
    out = SpaceList()
    for s in found:
        {CHANNEL: out.channels, GROUP: out.groups, DM: out.dms}[s.kind].append(s)
    out.dms.sort(key=lambda s: s.last_message_at or s.created_at, reverse=True)
    out.task_chats = _task_chats(actor, workspace, needle)
    return out


def _task_chats(actor: Any, workspace: Workspace, needle: str) -> list[dict[str, str]]:
    """Tasks the caller can open whose chat has a message, newest first (no unread counts)."""
    seen = Project.objects.visible_to(actor, workspace).values("pk")
    latest = (
        Comment.objects.filter(
            workspace=workspace,
            task__project__in=seen,
            task__deleted_at__isnull=True,
            deleted_at__isnull=True,
        )
        .values("task_id")
        .annotate(at=Max("created_at"))
        .order_by("-at")[: TASK_CHATS_MAX * 4 if needle else TASK_CHATS_MAX]
    )
    stamps = {row["task_id"]: row["at"] for row in latest}
    tasks = Task.objects.filter(pk__in=stamps).select_related("project")
    entries = [
        {
            "task_id": str(t.pk),
            "project_id": str(t.project_id),
            "display_id": t.display_id,
            "title": t.title,
            "last_message_at": stamps[t.pk].isoformat(),
        }
        for t in tasks
    ]
    if needle:
        entries = [e for e in entries if needle in f"{e['display_id']} {e['title']}".lower()]
    entries.sort(key=lambda e: e["last_message_at"], reverse=True)
    return entries[:TASK_CHATS_MAX]


def get(actor: Any, workspace: Workspace, space_id: str) -> ChatSpace:
    workspace_access.require(actor, access.READ, workspace)
    return _present_one(actor, access.space_for(actor, workspace, space_id))


# -- creating and changing --------------------------------------------------------------------


def create_space(
    actor: Any, workspace: Workspace, kind: str, name: str, member_ids: list[str]
) -> ChatSpace:
    """A channel (open to the workspace) or a private group (the caller plus ``member_ids``)."""
    workspace_access.require(actor, access.MANAGE, workspace)
    workspace_access.require(actor, access.POST, workspace)
    if kind not in (CHANNEL, GROUP):
        raise invalid("Create a channel or a group; a direct message opens by person.")
    cleaned = _name(name)
    with transaction.atomic():
        if kind == CHANNEL:
            clash = ChatSpace.objects.filter(
                workspace=workspace,
                kind=CHANNEL,
                project__isnull=True,
                archived_at__isnull=True,
                name__iexact=cleaned,
            )
            if clash.exists():
                raise ApiError("A channel with that name exists.", status=409)
        people = _people(workspace, member_ids)
        everyone = {actor.pk: actor, **{u.pk: u for u in people}}
        if kind == GROUP:
            if len(everyone) < GROUP_MIN:
                raise invalid("A group needs at least two people.")
            if len(everyone) > GROUP_MAX:
                raise invalid(f"A group holds at most {GROUP_MAX} people.")
        space = ChatSpace.objects.create(
            workspace=workspace, kind=kind, name=cleaned, created_by=actor
        )
        ChatMember.objects.create(space=space, user=actor, role=OWNER)
        if kind == GROUP:
            ChatMember.objects.bulk_create(
                [ChatMember(space=space, user=u) for u in people if u.pk != actor.pk]
            )
        announce(space, "space.updated")
    return _present_one(actor, space)


def _manageable(actor: Any, workspace: Workspace, space_id: str) -> ChatSpace:
    workspace_access.require(actor, access.READ, workspace)
    space = access.space_for(actor, workspace, space_id)
    return space


def update_space(
    actor: Any,
    workspace: Workspace,
    space_id: str,
    *,
    name: str = "",
    set_archived: bool = False,
    archived: bool = False,
) -> ChatSpace:
    """Rename and/or archive (or restore) a channel or group the caller owns, or any as a
    workspace Owner/Admin. A project's channel and ``#general`` follow their owners."""
    with transaction.atomic():
        space = _manageable(actor, workspace, space_id)
        space = ChatSpace.objects.select_for_update().select_related("workspace").get(pk=space.pk)
        if space.kind == DM or space.follows_workspace_or_project:
            raise invalid("This space is renamed and archived with its workspace or project.")
        if not access.manages(actor, space):
            raise workspace_access.PermissionDenied(
                access.MANAGE, "", "Only the owner or an admin can change this space."
            )
        changes: dict[str, Any] = {}
        if name:
            changes["name"] = _name(name)
        if set_archived and archived != space.is_archived:
            changes["archived_at"] = timezone.now() if archived else None
        if changes:
            ChatSpace.objects.filter(pk=space.pk).update(version=F("version") + 1, **changes)
            space.refresh_from_db()
            announce(space, "space.updated")
    return _present_one(actor, space)


def _rows_for_add(space: ChatSpace, people: list[Any]) -> list[Any]:
    have = set(ChatMember.objects.filter(space=space).values_list("user_id", flat=True))
    return [u for u in people if u.pk not in have]


def _require_open(space: ChatSpace) -> None:
    if space.is_archived:
        raise ApiError("This space is archived.", status=409, title=ResponseTitle.CHAT_READ_ONLY)


def join(actor: Any, workspace: Workspace, space_id: str) -> ChatSpace:
    """Join a channel (freely). ``#general`` and a project's channel already include you."""
    workspace_access.require(actor, access.POST, workspace)
    space = access.space_for(actor, workspace, space_id)
    if space.kind != CHANNEL:
        raise access.not_found()
    _require_open(space)
    if not space.follows_workspace_or_project:
        ChatMember.objects.get_or_create(space=space, user=actor)
        announce(space, "space.updated", users=[actor.pk])
    return _present_one(actor, space)


def leave(actor: Any, workspace: Workspace, space_id: str) -> None:
    """Leave a channel or group (the owner's role passes to the longest-standing member). The
    derived channels and direct messages cannot be left; mute them instead."""
    with transaction.atomic():
        workspace_access.require(actor, access.READ, workspace)
        space = access.space_for(actor, workspace, space_id)
        if space.kind == DM or space.follows_workspace_or_project:
            raise invalid("This space cannot be left; mute it instead.")
        row = ChatMember.objects.filter(space=space, user=actor).first()
        if row is None:
            return
        row.delete()
        _promote_if_ownerless(space)
        announce(space, "space.updated", users=[actor.pk])


def _promote_if_ownerless(space: ChatSpace) -> None:
    if ChatMember.objects.filter(space=space, role=OWNER).exists():
        return
    oldest = ChatMember.objects.filter(space=space).order_by("joined_at", "pk").first()
    if oldest is not None:
        ChatMember.objects.filter(pk=oldest.pk).update(role=OWNER)


def add_members(actor: Any, workspace: Workspace, space_id: str, user_ids: list[str]) -> ChatSpace:
    """Add people to a channel or group: any member of a group, anyone for a channel."""
    with transaction.atomic():
        workspace_access.require(actor, access.POST, workspace)
        space = access.space_for(actor, workspace, space_id)
        if space.kind == DM or space.follows_workspace_or_project:
            raise invalid("Who is in this space follows its workspace or project.")
        _require_open(space)
        if space.kind == GROUP and not access.is_member(actor.pk, space):
            raise access.not_found()
        fresh = _rows_for_add(space, _people(workspace, user_ids))
        if space.kind == GROUP and len(access.members(space)) + len(fresh) > GROUP_MAX:
            raise invalid(f"A group holds at most {GROUP_MAX} people.")
        added = [ChatMember(space=space, user=u) for u in fresh]
        ChatMember.objects.bulk_create(added)
        for row in added:
            changes.created(row)  # bulk_create sends no signal
        if fresh:
            announce(space, "space.updated", users=[u.pk for u in fresh])
    return _present_one(actor, space)


def remove_member(actor: Any, workspace: Workspace, space_id: str, user_id: str) -> None:
    """Take someone out of a channel or group: its owner or a workspace admin (yourself: leave)."""
    if str(user_id) == str(actor.pk):
        return leave(actor, workspace, space_id)
    with transaction.atomic():
        workspace_access.require(actor, access.READ, workspace)
        space = access.space_for(actor, workspace, space_id)
        if space.kind == DM or space.follows_workspace_or_project:
            raise invalid("Who is in this space follows its workspace or project.")
        if not access.manages(actor, space):
            raise workspace_access.PermissionDenied(
                access.MANAGE, "", "Only the owner or an admin can remove people."
            )
        try:
            target = uuid.UUID(str(user_id))
        except ValueError:
            raise access.not_found() from None
        row = ChatMember.objects.filter(space=space, user_id=target).first()
        if row is None:
            raise ApiError("No such member.", status=404)
        row.delete()
        _promote_if_ownerless(space)
        announce(space, "space.updated", users=[target])


def open_dm(actor: Any, workspace: Workspace, user_id: str) -> ChatSpace:
    """The direct message with ``user_id``, made on first use; the same space every time, even
    when two requests race (the unique pair key decides)."""
    workspace_access.require(actor, access.POST, workspace)
    [other] = _people(workspace, [user_id])
    if other.pk == actor.pk:
        raise invalid("You cannot message yourself.")
    key = _dm_key(actor.pk, other.pk)
    found = ChatSpace.objects.filter(workspace=workspace, dm_key=key).first()
    if found is None:
        try:
            with transaction.atomic():
                found = ChatSpace.objects.create(
                    workspace=workspace, kind=DM, dm_key=key, created_by=actor
                )
                ChatMember.objects.bulk_create(
                    [ChatMember(space=found, user=actor), ChatMember(space=found, user=other)]
                )
        except IntegrityError:
            found = ChatSpace.objects.get(workspace=workspace, dm_key=key)
    return _present_one(actor, found)


# -- read state and settings ------------------------------------------------------------------


def _my_row(actor: Any, space: ChatSpace) -> ChatMember:
    row, _ = ChatMember.objects.get_or_create(space=space, user=actor)
    return row


def _settings_space(actor: Any, workspace: Workspace, space_id: str) -> ChatSpace:
    workspace_access.require(actor, access.READ, workspace)
    space = access.space_for(actor, workspace, space_id)
    if not space.follows_workspace_or_project and not access.is_member(actor.pk, space):
        raise access.not_found()  # a stranger to a public channel has nothing to set
    return space


def mark_read(actor: Any, workspace: Workspace, space_id: str, message_id: str = "") -> ChatSpace:
    """Move the caller's read mark up to ``message_id`` (or now); it never moves back."""
    with transaction.atomic():
        space = _settings_space(actor, workspace, space_id)
        mark = timezone.now()
        if message_id:
            try:
                pk = uuid.UUID(str(message_id))
            except ValueError:
                raise access.not_found() from None
            found = (
                ChatMessage.objects.filter(pk=pk, space=space)
                .values_list("created_at", flat=True)
                .first()
            )
            if found is None:
                raise access.not_found()
            mark = found
        row = _my_row(actor, space)
        if mark > row.last_read_at:
            row.last_read_at = mark
            row.save(update_fields=["last_read_at"])
        announce(space, "read", only_user=actor.pk)
    return _present_one(actor, space)


def mute(
    actor: Any,
    workspace: Workspace,
    space_id: str,
    *,
    until: str = "",
    forever: bool = False,
    completely: bool = False,
) -> ChatSpace:
    """Silence pushes from a space until ``until`` (ISO time) or ``forever``; neither unmutes.
    ``completely`` also silences @mentions of the caller there."""
    stop: datetime | None = None
    if forever:
        stop = FOREVER
    elif until:
        try:
            stop = datetime.fromisoformat(until)
        except ValueError:
            raise invalid("Mute until a time like 2026-01-31T09:00:00Z.") from None
        if stop.tzinfo is None:
            stop = stop.replace(tzinfo=UTC)
        if stop <= timezone.now():
            stop = None
    with transaction.atomic():
        space = _settings_space(actor, workspace, space_id)
        row = _my_row(actor, space)
        row.muted_until = stop
        row.muted_completely = bool(completely and stop is not None)
        row.save(update_fields=["muted_until", "muted_completely"])
    return _present_one(actor, space)


def set_notify(actor: Any, workspace: Workspace, space_id: str, all_messages: bool) -> ChatSpace:
    """Ask to be notified of every message in a space (off by default)."""
    with transaction.atomic():
        space = _settings_space(actor, workspace, space_id)
        row = _my_row(actor, space)
        row.notify_all = all_messages
        row.save(update_fields=["notify_all"])
    return _present_one(actor, space)


def mentionable(
    actor: Any, workspace: Workspace, space_id: str, query: str = ""
) -> tuple[list[Any], int]:
    """People who can see the space and so may be mentioned, matching ``query``, and the member
    count (the client asks to confirm @channel above ``CHAT_BROADCAST_CONFIRM_ABOVE``)."""
    workspace_access.require(actor, access.READ, workspace)
    space = access.space_for(actor, workspace, space_id)
    users = get_user_model().objects.filter(pk__in=access.readers(space), is_active=True)
    needle = query.strip()
    if needle:
        users = users.filter(
            Q(profile__display_name__icontains=needle) | Q(email__icontains=needle)
        )
    found = list(users.select_related("profile").order_by("profile__display_name", "email"))
    return found[:PICKER_LIMIT], len(access.members(space))


# -- hooks from workspaces and projects (same transaction as the change) ----------------------


def _create_once(**fields: Any) -> ChatSpace:
    try:
        with transaction.atomic():
            return ChatSpace.objects.create(**fields)
    except IntegrityError:
        key = {k: v for k, v in fields.items() if k in ("project", "workspace", "is_default")}
        found = ChatSpace.objects.filter(**key).first()
        if found is None:
            raise
        return found


def ensure_general(workspace: Workspace) -> ChatSpace:
    found = ChatSpace.objects.filter(workspace=workspace, is_default=True).first()
    return found or _create_once(
        workspace=workspace,
        kind=CHANNEL,
        name="general",
        is_default=True,
        created_by=workspace.created_by if hasattr(workspace, "created_by") else None,
    )


def ensure_project_channel(project: Project) -> ChatSpace:
    found = ChatSpace.objects.filter(project=project).first()
    if found is not None:
        return found
    return _create_once(
        workspace_id=project.workspace_id,
        project=project,
        kind=CHANNEL,
        name=project.name,
        created_by_id=project.created_by_id,
        archived_at=project.archived_at,
    )


def ensure_defaults(workspace: Workspace) -> None:
    """#general and a channel for every project, for workspaces and projects made before chat."""
    ensure_general(workspace)
    missing = Project.objects.filter(workspace=workspace).exclude(
        pk__in=ChatSpace.objects.filter(workspace=workspace, project__isnull=False).values(
            "project_id"
        )
    )
    for project in missing:
        ensure_project_channel(project)


def workspace_created(workspace: Workspace) -> None:
    ensure_general(workspace)


def project_created(project: Project) -> None:
    ensure_project_channel(project)


def project_changed(project: Project) -> None:
    """A project was renamed, archived or restored: its channel follows."""
    space = ensure_project_channel(project)
    if space.name != project.name or space.archived_at != project.archived_at:
        ChatSpace.objects.filter(pk=space.pk).update(
            name=project.name, archived_at=project.archived_at, version=F("version") + 1
        )
        space.refresh_from_db()
        announce(space, "space.updated")


def project_member_added(project: Project, user_id: Any) -> None:
    space = ensure_project_channel(project)
    ChatMember.objects.get_or_create(space=space, user_id=user_id)
    announce(space, "space.updated", users=[user_id])


def project_member_removed(project: Project, user_id: Any) -> None:
    space = ChatSpace.objects.filter(project=project).first()
    if space is None:
        return
    ChatMember.objects.filter(space=space, user_id=user_id).delete()
    announce(space, "space.updated", users=[user_id])
