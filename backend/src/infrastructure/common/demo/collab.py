"""Collaboration demo: comments, attachments, docs, chat, watchers and the inbox.

Reads ``ctx`` as core filled it; leaves ``ctx.extra["comments"]`` (key -> Comment),
``ctx.extra["docs"]`` and ``ctx.extra["chat"]`` for later modules.
"""

from infrastructure.common.demo import (
    collab_chat,
    collab_comments,
    collab_docs,
    collab_files,
    collab_inbox,
)
from infrastructure.common.demo.base import Ctx


def seed(ctx: Ctx) -> None:
    collab_comments.create_comments(ctx)
    collab_files.create_attachments(ctx)
    collab_docs.create_docs(ctx)
    collab_chat.create_chat(ctx)
    collab_inbox.create_watchers(ctx)
    collab_inbox.create_preferences(ctx)  # before the extras, so they follow the chosen channels
    collab_inbox.create_notifications(ctx)
