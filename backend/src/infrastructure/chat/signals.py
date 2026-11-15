"""Hooks other apps listen to, sent through ``transaction.on_commit`` (never on a rollback).

``chat_changed``: ``space_id``, ``workspace_id`` (str), ``version`` (int, the message's or the
space's), ``action`` (``message.created`` ``message.updated`` ``message.deleted`` ``space.updated``
``read``), ``users`` (str ids told too: people just removed from the space) and ``only_user``
(str, ``read`` only: nobody but that person's devices). The live feed turns it into
``chat.message.created|updated|deleted``, ``chat.space.updated`` and ``chat.read`` events for the
people who can read the space, and for nobody else.

``chat_notice``: ``message_id``, ``space_id``, ``workspace_id``, ``author_id``, ``version``,
``mention_ids`` (people newly mentioned by this version), ``broadcast`` (``""``, ``channel`` or
``here``, newly written) and ``created`` (a new message, not an edit). The inbox turns it into
notifications, once per message version.
"""

from typing import Any

from django.db import transaction
from django.dispatch import Signal

chat_changed = Signal()
chat_notice = Signal()


def announce(
    space: Any,
    action: str,
    *,
    version: int | None = None,
    users: list[Any] | None = None,
    only_user: Any = "",
) -> None:
    from infrastructure.chat.models import ChatSpace

    payload = {
        "space_id": str(space.pk),
        "workspace_id": str(space.workspace_id),
        "version": space.version if version is None else version,
        "action": action,
        "users": [str(u) for u in users or []],
        "only_user": str(only_user or ""),
    }
    transaction.on_commit(lambda: chat_changed.send(sender=ChatSpace, **payload))


def announce_notice(message: Any, mention_ids: list[Any], broadcast: str, *, created: bool) -> None:
    from infrastructure.chat.models import ChatMessage

    payload = {
        "message_id": str(message.pk),
        "space_id": str(message.space_id),
        "workspace_id": str(message.workspace_id),
        "author_id": str(message.author_id),
        "version": message.version,
        "mention_ids": [str(u) for u in mention_ids],
        "broadcast": broadcast,
        "created": created,
    }
    transaction.on_commit(lambda: chat_notice.send(sender=ChatMessage, **payload))
