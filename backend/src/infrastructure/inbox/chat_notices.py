"""Chat messages into notifications: who is told, with which kind, once per message version.

By priority a person gets one of: ``chat.mentioned`` (named), ``chat.channel_all`` (``@channel`` to
the space's members, ``@here`` to those who read it in the last ``HERE_MINUTES``), ``chat.dm`` (the
other person of a direct message) or ``chat.message`` (a space they asked to follow closely). A
plain message in a channel or group tells nobody else, and never its author. Muting a space
silences pushes, except for being named; muting it completely silences everything from it.
"""

from datetime import timedelta
from typing import Any, Final

from django.utils import timezone

from infrastructure.chat import access
from infrastructure.chat.models import DM, ChatMember, ChatMessage
from infrastructure.comments import body as comment_body
from infrastructure.inbox import kinds, notify, render

HERE_MINUTES: Final = 30


def _wanted(
    message: ChatMessage, kw: dict[str, Any], rows: dict[Any, ChatMember]
) -> dict[Any, str]:
    """``{user id: kind}`` of everyone this message version should notify, strongest kind each."""
    space = message.space
    plan: dict[Any, str] = {}
    for user_id in kw["mention_ids"]:
        plan[_uuid(user_id)] = kinds.CHAT_MENTIONED
    if kw["broadcast"]:
        pool = access.members(space)
        if kw["broadcast"] == "here":
            recent = timezone.now() - timedelta(minutes=HERE_MINUTES)
            pool = {u for u in pool if u in rows and rows[u].last_read_at >= recent}
        for user_id in pool:
            plan.setdefault(user_id, kinds.CHAT_CHANNEL_ALL)
    if kw["created"]:
        if space.kind == DM:
            for user_id in access.members(space):
                plan.setdefault(user_id, kinds.CHAT_DM)
        else:
            for user_id, row in rows.items():
                if row.notify_all:
                    plan.setdefault(user_id, kinds.CHAT_MESSAGE)
    return plan


def _uuid(raw: Any) -> Any:
    import uuid

    return uuid.UUID(str(raw))


def handle(**kw: Any) -> None:
    message = (
        ChatMessage.objects.select_related("space", "space__workspace", "space__project")
        .filter(pk=kw["message_id"], deleted_at__isnull=True)
        .first()
    )
    if message is None or message.version != kw["version"]:
        return
    space = message.space
    rows = {m.user_id: m for m in ChatMember.objects.filter(space=space)}
    plan = _wanted(message, kw, rows)
    author = message.author_id
    readers = access.readers(space)
    excerpt = render.excerpt(comment_body.plain_text(message.body, allow_broadcast=True))
    payload = {
        "space_id": str(space.pk),
        "space_name": space.name,
        "space_kind": space.kind,
        "message_id": str(message.pk),
        "excerpt": excerpt,
    }
    by_kind: dict[str, list[Any]] = {}
    quiet: set[Any] = set()
    for user_id, kind in plan.items():
        row = rows.get(user_id)
        if user_id == author or user_id not in readers:
            continue
        if row is not None and row.muted and row.muted_completely:
            continue
        if row is not None and row.muted and kind != kinds.CHAT_MENTIONED:
            quiet.add(user_id)
        by_kind.setdefault(kind, []).append(user_id)
    for kind, recipients in by_kind.items():
        notify.notify(
            kind=kind,
            recipients=recipients,
            workspace=space.workspace,
            project=space.project,
            task=None,
            actor_id=author,
            payload=payload,
            dedupe=f"chat:{message.pk}:{message.version}",
            fold=False,
            allowed=readers,
            quiet=quiet,
        )
