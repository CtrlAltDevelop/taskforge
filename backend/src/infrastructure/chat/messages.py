"""Messages in a space: the rules. Reading needs a space the caller can see; writing needs
``chat.post``, being in the space and a space that is not archived. The author edits within
``CHAT_EDIT_WINDOW_HOURS``; the author or a workspace Owner/Admin deletes, which leaves a
placeholder (replies keep their place). Replies go one level deep. The body is rebuilt by the
comments' sanitizer, so a message and a comment are the same document."""

import uuid
from dataclasses import dataclass
from datetime import timedelta
from typing import Any, Final

from django.conf import settings
from django.db import IntegrityError, transaction
from django.db.models import Q
from django.utils import timezone

from infrastructure.chat import access
from infrastructure.chat.models import DM, ChatMember, ChatMessage, ChatReaction, ChatSpace
from infrastructure.chat.services import FORMER_MEMBER, invalid
from infrastructure.chat.signals import announce, announce_notice
from infrastructure.comments import body as bodies
from infrastructure.comments import mentions
from infrastructure.comments.models import group_reactions
from infrastructure.comments.services import emoji_token, parse_cursor
from infrastructure.common.errors import ApiError
from infrastructure.common.responses import ResponseTitle
from infrastructure.projects import members as project_members
from infrastructure.sync import mutations
from infrastructure.workspaces import access as workspace_access
from infrastructure.workspaces.models import MemberStatus, Workspace, WorkspaceMember

PAGE_DEFAULT: Final = 50
PAGE_MAX: Final = 200
MAX_EMOJIS: Final = 30


@dataclass(frozen=True, slots=True)
class Page:
    """Messages oldest first; ``cursor`` is what to pass as ``before`` for the ones earlier."""

    messages: list[ChatMessage]
    cursor: str


def _readable(actor: Any, workspace: Workspace, space_id: str) -> ChatSpace:
    workspace_access.require(actor, access.READ, workspace)
    return access.space_for(actor, workspace, space_id)


def _message(space: ChatSpace, message_id: str, *, lock: bool = False) -> ChatMessage:
    try:
        pk = uuid.UUID(str(message_id))
    except ValueError:
        raise _gone_row() from None
    rows = ChatMessage.objects.filter(pk=pk, space=space)
    found = (rows.select_for_update(of=("self",)) if lock else rows).first()
    if found is None:
        raise _gone_row()
    return found


def _gone_row() -> ApiError:
    return ApiError("No such message.", status=404)


def present(space: ChatSpace, messages: list[ChatMessage]) -> list[ChatMessage]:
    """Attach ``reaction_map`` ({emoji: [user ids]}) and ``author_name`` ("Former member" once the
    author left the workspace) to each message."""
    ids = [m.pk for m in messages]
    reacted = group_reactions(
        ChatReaction.objects.filter(message_id__in=ids)
        .order_by("at", "id")
        .values_list("message_id", "emoji", "user_id")
    )
    authors = {m.author_id for m in messages}
    active = set(
        WorkspaceMember.objects.filter(
            workspace_id=space.workspace_id, user_id__in=authors, status=MemberStatus.ACTIVE
        ).values_list("user_id", flat=True)
    )
    from django.contrib.auth import get_user_model

    users = {
        u.pk: u for u in get_user_model().objects.filter(pk__in=authors).select_related("profile")
    }
    for m in messages:
        m.reaction_map = reacted.get(m.pk, {})
        m.author_name = (
            mentions.display_name(users[m.author_id]) if m.author_id in active else FORMER_MEMBER
        )
    return messages


def list_page(
    actor: Any,
    workspace: Workspace,
    space_id: str,
    *,
    before: str = "",
    limit: int = PAGE_DEFAULT,
    thread_id: str = "",
) -> Page:
    """The newest ``limit`` messages of the space (replies included, each with its
    ``parent_id``), or the ones before ``before``; ``thread_id`` lists one thread instead."""
    space = _readable(actor, workspace, space_id)
    size = max(1, min(limit or PAGE_DEFAULT, PAGE_MAX))
    rows = ChatMessage.objects.filter(space=space).order_by("-created_at", "-id")
    if thread_id:
        root = _message(space, thread_id)
        rows = rows.filter(Q(parent=root) | Q(pk=root.pk))
    mark = parse_cursor(before)
    if mark is not None:
        stamp, ident = mark
        rows = rows.filter(Q(created_at__lt=stamp) | Q(created_at=stamp, id__lt=ident))
    found = list(rows[: size + 1])
    more = len(found) > size
    page = list(reversed(found[:size]))
    cursor = f"{page[0].created_at.isoformat()}|{page[0].pk}" if more and page else ""
    return Page(present(space, page), cursor)


# -- mentions ---------------------------------------------------------------------------------


def _resolve_mentions(
    actor: Any, space: ChatSpace, ids: list[uuid.UUID], *, grant_access: bool
) -> list[Any]:
    """The people to record as mentioned; the ones who cannot see the space are refused
    (``MENTION_NO_ACCESS``, ``data.users``), unless the caller manages the space and
    ``grant_access`` adds them."""
    from django.contrib.auth import get_user_model

    if not ids:
        return []
    outside = [u for u in ids if u not in access.readers(space)]
    if outside:
        in_workspace = access.holders(space.workspace) & set(outside)
        grantable = grant_access and _may_grant(actor, space)
        refused = [u for u in outside if not (grantable and u in in_workspace)]
        if refused:
            raise ApiError(
                "Somebody mentioned cannot see this space.",
                title=ResponseTitle.MENTION_NO_ACCESS,
                data={"users": ",".join(str(u) for u in refused)},
            )
        for user_id in outside:
            _grant(space, user_id)
    return list(get_user_model().objects.filter(pk__in=ids).select_related("profile"))


def _may_grant(actor: Any, space: ChatSpace) -> bool:
    if space.kind == DM or space.is_default:
        return False
    if space.project_id is not None:
        return workspace_access.can(actor, "project.member.manage", space.project).allowed
    return access.manages(actor, space)


def _grant(space: ChatSpace, user_id: Any) -> None:
    if space.project_id is not None:
        project_members.grant(space.workspace, space.project, user_id)
    ChatMember.objects.get_or_create(space=space, user_id=user_id)


def _labelled(document: dict[str, Any], people: list[Any]) -> dict[str, Any]:
    labels = {str(u.pk): mentions.display_name(u) for u in people}
    labels.update({"channel": "channel", "here": "here"})
    return bodies.relabel(document, labels)


def _strongest(flags: frozenset[str]) -> str:
    return "channel" if "channel" in flags else ("here" if flags else "")


# -- sending ----------------------------------------------------------------------------------


def _rate_limit(actor: Any, space: ChatSpace) -> None:
    recent = ChatMessage.objects.filter(
        space=space, author=actor, created_at__gte=timezone.now() - timedelta(minutes=1)
    ).count()
    if recent >= settings.CHAT_SENDS_PER_MINUTE:
        raise ApiError(
            "You are sending too fast here.", status=429, title=ResponseTitle.CHAT_RATE_LIMITED
        )


def _clean(body: str) -> bodies.Cleaned:
    return bodies.clean(body, allow_broadcast=True, max_bytes=settings.CHAT_MAX_MESSAGE_KB * 1024)


def _check_broadcast(space: ChatSpace, flags: frozenset[str], confirm: bool) -> None:
    if not flags:
        return
    if space.kind == DM:
        raise invalid("@channel and @here are for channels and groups.")
    count = len(access.members(space))
    if count > settings.CHAT_BROADCAST_CONFIRM_ABOVE and not confirm:
        raise ApiError(
            f"This notifies {count} people. Confirm to send.",
            status=409,
            title=ResponseTitle.CHAT_BROADCAST_CONFIRM,
            data={"member_count": str(count)},
        )


def _chosen_id(raw: str) -> uuid.UUID:
    if not raw:
        return uuid.uuid4()
    try:
        return uuid.UUID(str(raw))
    except ValueError:
        raise invalid("The message id must be a UUID.") from None


def _parent(space: ChatSpace, parent_id: str) -> ChatMessage | None:
    if not parent_id:
        return None
    parent = _message(space, parent_id)
    if parent.parent_id is not None:
        raise invalid("Replies go one level deep: reply to the message above.")
    return parent


def send(
    actor: Any,
    workspace: Workspace,
    space_id: str,
    body: str,
    *,
    parent_id: str = "",
    client_id: str = "",
    client_mutation_id: str = "",
    confirm_broadcast: bool = False,
    grant_access: bool = False,
) -> ChatMessage:
    """Write a message (or, with ``parent_id``, a reply to a top-level one). ``client_id`` is the
    id an offline client chose: sending it again returns the message already made."""

    def apply() -> ChatMessage:
        return _send(
            actor,
            workspace,
            space_id,
            body,
            parent_id=parent_id,
            client_id=client_id,
            confirm_broadcast=confirm_broadcast,
            grant_access=grant_access,
        )

    def current(found: Any) -> ChatMessage:
        space = _readable(actor, workspace, space_id)
        return present(space, [_message(space, str(found.entity_id))])[0]

    return mutations.once(
        actor,
        workspace,
        client_mutation_id,
        "chat.send",
        apply,
        entity=lambda m: ("chat", m.pk),
        current=current,
    )


def _send(
    actor: Any,
    workspace: Workspace,
    space_id: str,
    body: str,
    *,
    parent_id: str,
    client_id: str,
    confirm_broadcast: bool,
    grant_access: bool,
) -> ChatMessage:
    try:
        with transaction.atomic():
            space = _readable(actor, workspace, space_id)
            chosen = _chosen_id(client_id)
            again = ChatMessage.objects.filter(pk=chosen).first()
            if again is not None:
                if again.space_id == space.pk and again.author_id == actor.pk:
                    return present(space, [again])[0]
                raise invalid("The message id must be a new UUID.")
            access.require_post(actor, space)
            _rate_limit(actor, space)
            cleaned = _clean(body)
            _check_broadcast(space, cleaned.broadcasts, confirm_broadcast)
            parent = _parent(space, parent_id)
            people = _resolve_mentions(actor, space, cleaned.mention_ids, grant_access=grant_access)
            message = ChatMessage.objects.create(
                id=chosen,
                space=space,
                workspace=workspace,
                author=actor,
                parent=parent,
                body=_labelled(cleaned.document, people),
            )
            announce(space, "message.created", version=message.version)
            announce_notice(
                message,
                [u.pk for u in people if u.pk != actor.pk],
                _strongest(cleaned.broadcasts),
                created=True,
            )
    except IntegrityError:
        raise invalid("The message id must be a new UUID.") from None
    return present(space, [message])[0]


# -- edit, delete, react ----------------------------------------------------------------------


def _window_open(message: ChatMessage) -> bool:
    hours = settings.CHAT_EDIT_WINDOW_HOURS
    return hours <= 0 or timezone.now() - message.created_at <= timedelta(hours=hours)


def edit(
    actor: Any,
    workspace: Workspace,
    space_id: str,
    message_id: str,
    expected_version: int,
    body: str,
    *,
    grant_access: bool = False,
    confirm_broadcast: bool = False,
) -> ChatMessage:
    """Replace the body (author only, within the window, on its current version). People newly
    mentioned (and a newly written @channel) are told once."""
    with transaction.atomic():
        space = _readable(actor, workspace, space_id)
        message = _message(space, message_id, lock=True)
        access.require_post(actor, space)
        if message.author_id != actor.pk:
            raise workspace_access.PermissionDenied(
                access.POST, "", "Only the author can edit a message."
            )
        if message.is_deleted or not _window_open(message):
            raise ApiError("That message can no longer be edited.", title=ResponseTitle.CHAT_LOCKED)
        if message.version != expected_version:
            raise ApiError(
                "Someone changed this message first.",
                status=409,
                title=ResponseTitle.VERSION_CONFLICT,
                data={"version": str(message.version)},
            )
        before = bodies.mentions_of(message.body, allow_broadcast=True)
        cleaned = _clean(body)
        fresh_flags = cleaned.broadcasts - before.broadcasts
        _check_broadcast(space, fresh_flags, confirm_broadcast)
        people = _resolve_mentions(actor, space, cleaned.mention_ids, grant_access=grant_access)
        message.body = _labelled(cleaned.document, people)
        message.version += 1
        message.edited_at = timezone.now()
        message.save(update_fields=["body", "version", "edited_at"])
        fresh = [u.pk for u in people if u.pk != actor.pk and u.pk not in before.mention_ids]
        announce(space, "message.updated", version=message.version)
        announce_notice(message, fresh, _strongest(fresh_flags), created=False)
    return present(space, [message])[0]


def delete(actor: Any, workspace: Workspace, space_id: str, message_id: str) -> ChatMessage:
    """Remove a message: its author, or a workspace Owner/Admin. It stays as "removed"."""
    with transaction.atomic():
        space = _readable(actor, workspace, space_id)
        message = _message(space, message_id, lock=True)
        if message.author_id != actor.pk:
            if not access.is_admin(actor, workspace):
                raise workspace_access.PermissionDenied(
                    access.MANAGE, "", "Only the author or an admin can remove a message."
                )
        elif access.read_only(space, actor.pk):
            raise ApiError(
                "This space is read-only.", status=409, title=ResponseTitle.CHAT_READ_ONLY
            )
        if message.is_deleted:
            return present(space, [message])[0]
        message.body = {}
        message.deleted_at = timezone.now()
        message.version += 1
        message.save(update_fields=["body", "deleted_at", "version"])
        ChatReaction.objects.filter(message=message).delete()
        announce(space, "message.deleted", version=message.version)
    return present(space, [message])[0]


def react(
    actor: Any, workspace: Workspace, space_id: str, message_id: str, emoji: str, on: bool
) -> ChatMessage:
    """Give (``on``) or take back ``emoji``: setting, not toggling, so a repeat ends the same."""
    token = emoji_token(emoji)
    with transaction.atomic():
        space = _readable(actor, workspace, space_id)
        message = _message(space, message_id, lock=True)
        access.require_post(actor, space)
        if message.is_deleted:
            raise ApiError("That message was removed.", title=ResponseTitle.CHAT_LOCKED)
        mine = ChatReaction.objects.filter(message=message, user=actor, emoji=token)
        if on and not mine.exists():
            kinds = set(
                ChatReaction.objects.filter(message=message).values_list("emoji", flat=True)
            )
            if token not in kinds and len(kinds) >= MAX_EMOJIS:
                raise invalid(f"A message holds at most {MAX_EMOJIS} different reactions.")
            ChatReaction.objects.bulk_create(
                [ChatReaction(message=message, user=actor, emoji=token)], ignore_conflicts=True
            )
            announce(space, "message.updated", version=message.version)
        elif not on and mine.exists():
            mine.delete()
            announce(space, "message.updated", version=message.version)
    return present(space, [message])[0]
