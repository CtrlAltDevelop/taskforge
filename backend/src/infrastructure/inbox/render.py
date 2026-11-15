"""The words of a notification, for a push and an email (the app writes its own)."""

from typing import Any

from infrastructure.common.messages import recipient_locale, tr
from infrastructure.inbox import kinds

EXCERPT_MAX = 140


def excerpt(text: str) -> str:
    one = " ".join(text.split())
    return one if len(one) <= EXCERPT_MAX else one[: EXCERPT_MAX - 1] + "…"


def clean(text: Any) -> str:
    """One line: no newlines or control characters (they would forge lines in an email or break a
    header)."""
    return " ".join("".join(ch if ch.isprintable() else " " for ch in str(text)).split())


def subject_of(row: Any) -> str:
    """The task a notification is about, as ``WEB-12 Fix login``."""
    payload = row.payload
    return clean(f"{payload.get('key', '')} {payload.get('title', '')}")


def render(row: Any, actor_name: str, locale: str | None = None) -> tuple[str, str]:
    """``(title, body)`` in ``locale`` (default: the recipient's language)."""
    lang = locale or recipient_locale(getattr(row, "user", None), getattr(row, "workspace", None))
    payload = row.payload
    who = clean(actor_name) or tr("notify.someone", lang)
    if row.type in kinds.CHAT_KINDS:
        return _chat_words(row, who, lang)
    task = subject_of(row)
    more = tr("notify.more", lang, n=row.count - 1) if row.count > 1 else ""
    note = f"{task}\n{clean(payload.get('excerpt', ''))}".strip()
    match row.type:
        case kinds.ASSIGNED:
            return tr("notify.assigned.title", lang, who=who), task
        case kinds.MENTIONED:
            return tr("notify.mentioned.title", lang, who=who), note
        case kinds.COMMENTED:
            return tr("notify.commented.title", lang, who=who, more=more), note
        case kinds.STATUS_CHANGED:
            moved = clean(f"{payload.get('from', '')} → {payload.get('to', '')}")
            return (
                tr("notify.status_changed.title", lang, who=who, more=more),
                tr("notify.status_changed.body", lang, task=task, moved=moved),
            )
        case kinds.TASK_CHANGED:
            return tr("notify.task_changed.title", lang, who=who, more=more), task
        case kinds.DUE_SOON:
            date = clean(payload.get("due_date", ""))
            return (
                tr("notify.due_soon.title", lang),
                tr("notify.due_soon.body", lang, task=task, date=date),
            )
        case kinds.TIMER_LONG:
            return (
                tr("notify.timer_long.title", lang),
                tr("notify.timer_long.body", lang, task=task, hours=payload.get("hours", 0)),
            )
        case kinds.AUTOMATION:
            name = clean(payload.get("automation", ""))
            body = f"{task}\n{clean(payload.get('message', ''))}".strip()
            return tr("notify.automation.title", lang, name=name), body
        case kinds.AUTOMATION_DISABLED:
            name = clean(payload.get("automation", ""))
            return (
                tr("notify.automation_disabled.title", lang, name=name),
                clean(payload.get("reason", "")),
            )
    return tr("notify.fallback.title", lang), task


_CHAT_TITLES = {
    kinds.CHAT_MENTIONED: "notify.chat_mentioned.title",
    kinds.CHAT_DM: "notify.chat_dm.title",
    kinds.CHAT_CHANNEL_ALL: "notify.chat_channel_all.title",
    kinds.CHAT_MESSAGE: "notify.chat_message.title",
}


def _chat_words(row: Any, who: str, lang: str) -> tuple[str, str]:
    payload = row.payload
    space = clean(payload.get("space_name", ""))
    return tr(_CHAT_TITLES[row.type], lang, who=who, space=space), clean(payload.get("excerpt", ""))
