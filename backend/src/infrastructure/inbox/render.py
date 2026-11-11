"""The words of a notification, for a push and an email (the app writes its own)."""

from typing import Any

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


def render(row: Any, actor_name: str) -> tuple[str, str]:
    """``(title, body)``."""
    payload = row.payload
    who = clean(actor_name) or "Someone"
    task = subject_of(row)
    more = f" (+{row.count - 1} more)" if row.count > 1 else ""
    match row.type:
        case kinds.ASSIGNED:
            return f"{who} assigned you a task", task
        case kinds.MENTIONED:
            return f"{who} mentioned you", f"{task}\n{clean(payload.get('excerpt', ''))}".strip()
        case kinds.COMMENTED:
            return f"{who} commented{more}", f"{task}\n{clean(payload.get('excerpt', ''))}".strip()
        case kinds.STATUS_CHANGED:
            moved = clean(f"{payload.get('from', '')} → {payload.get('to', '')}")
            return f"{who} moved a task{more}", f"{task}: {moved}"
        case kinds.DUE_SOON:
            return "A task is due soon", f"{task} is due {clean(payload.get('due_date', ''))}"
        case kinds.TIMER_LONG:
            return "Your timer is still running", f"{task}: {payload.get('hours', 0)} h so far"
    return "Notification", task
