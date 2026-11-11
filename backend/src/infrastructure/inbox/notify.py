"""Turning an event into notifications for the right people.

``notify`` is the one door. For each candidate recipient it: leaves out the actor, anyone who is not
an active member who can open the project (so access lost is never notified), and anyone who turned
every channel off for this kind; makes the event idempotent (``dedupe`` is unique per person);
folds a burst of the same kind on the same task into one notification (``count``) instead of ten;
plans the push and email the person asked for, outside their quiet hours; and tells their open
apps.
"""

import logging
import uuid
from collections.abc import Iterable
from datetime import timedelta
from typing import Any

from django.conf import settings
from django.db import IntegrityError, transaction
from django.db.models import Q
from django.utils import timezone

from infrastructure.comments import mentions
from infrastructure.inbox import delivery, kinds, prefs
from infrastructure.inbox.models import EmailMode, Notification
from infrastructure.sync import publish

logger = logging.getLogger(__name__)

# A person who may assign (bulk, thirty tasks at once) must be heard; it is mentions that can flood.
NEVER_FLOODED = frozenset({kinds.ASSIGNED, kinds.DUE_SOON, kinds.TIMER_LONG})


def _announce(user_id: Any, workspace_id: Any, action: str) -> None:
    """Tell the person's open apps (``user:<id>``): a hint, they read the inbox again."""
    publish.record(
        entity_type="notification",
        entity_id=user_id,
        workspace_id=workspace_id,
        user_id=str(user_id),
        action=action,
    )


def announce_changed(user_id: Any, workspace_id: Any) -> None:
    """After the person (or the tick) changed what they have read, snoozed or archived."""
    _announce(user_id, workspace_id, "changed")


def _merge(old: dict[str, Any], new: dict[str, Any]) -> dict[str, Any]:
    """The first ``from`` is kept (a status moved A→B→C reads A→C); the rest is the latest."""
    merged = {**old, **new}
    if "from" in old:
        merged["from"] = old["from"]
    return merged


def _fold(
    user_id: Any, kind: str, task: Any, key: str, payload: dict[str, Any], in_inbox: bool
) -> Notification | None:
    """The recent unread notification of this kind on this task, brought up to date; ``None`` if
    there is none to fold into."""
    window = timezone.now() - timedelta(seconds=settings.INBOX_COALESCE_SECONDS)
    row = (
        Notification.objects.select_for_update()
        .filter(
            user_id=user_id,
            type=kind,
            task=task,
            read_at__isnull=True,
            archived_at__isnull=True,
            in_inbox=in_inbox,
            updated_at__gte=window,
        )
        .filter(Q(snoozed_until__isnull=True) | Q(snoozed_until__lte=timezone.now()))
        .order_by("-updated_at")
        .first()
    )
    if row is None:
        return None
    if key in (row.dedupe_key, row.last_key):
        return row  # the same event again
    row.count += 1
    row.payload = _merge(row.payload, payload)
    row.last_key = key
    row.updated_at = timezone.now()
    row.save(update_fields=["count", "payload", "last_key", "updated_at"])
    return row


def notify(
    *,
    kind: str,
    recipients: Iterable[Any],
    workspace: Any,
    project: Any,
    task: Any,
    actor_id: Any,
    payload: dict[str, Any],
    dedupe: str,
    fold: bool = True,
) -> list[Notification]:
    """Create (or fold into) a notification of ``kind`` for each of ``recipients`` (user ids)."""
    candidates = [
        u for u in dict.fromkeys(uuid.UUID(str(r)) for r in recipients) if str(u) != str(actor_id)
    ]
    if not candidates:
        return []
    allowed = mentions.can_see(workspace, project)
    chosen = prefs.effective_many([u for u in candidates if u in allowed], kind)
    made: list[Notification] = []
    for user_id, have in chosen.items():
        if not (have.inbox or have.push or have.email_mode != EmailMode.OFF):
            continue
        try:
            row = _one(
                user_id, kind, workspace, project, task, actor_id, payload, dedupe, have, fold
            )
        except Exception:  # noqa: BLE001 -- one person's failure must not cost the rest theirs
            logger.exception("could not notify %s of %s", user_id, kind)
            continue
        if row is not None:
            made.append(row)
    return made


def _flooding(user_id: Any, kind: str, actor_id: Any) -> bool:
    """Whether ``actor_id`` has already sent this person this kind too many times just now."""
    if actor_id is None or kind in NEVER_FLOODED:
        return False
    recent = timezone.now() - timedelta(minutes=10)
    return (
        Notification.objects.filter(
            user_id=user_id, type=kind, actor_id=actor_id, created_at__gte=recent
        ).count()
        >= settings.INBOX_FLOOD_LIMIT
    )


def _one(
    user_id: Any,
    kind: str,
    workspace: Any,
    project: Any,
    task: Any,
    actor_id: Any,
    payload: dict[str, Any],
    dedupe: str,
    have: prefs.Effective,
    fold: bool,
) -> Notification | None:
    key = f"{dedupe}:{user_id}"
    row: Notification | None = None
    try:
        with transaction.atomic():
            if Notification.objects.filter(user_id=user_id, dedupe_key=key).exists():
                return None  # this very event, delivered twice
            # ponytail: two events at the very same moment can both miss the row to fold into and
            # make two notifications (and SQLite does not lock rows); a per-(person, task, kind)
            # advisory lock on PostgreSQL closes it if it is ever seen.
            folded = _fold(user_id, kind, task, key, payload, have.inbox) if fold else None
            if folded is None:
                if _flooding(user_id, kind, actor_id):
                    return None
                row = Notification.objects.create(
                    user_id=user_id,
                    workspace=workspace,
                    type=kind,
                    task=task,
                    project_id=project.pk,
                    actor_id=actor_id,
                    payload=payload,
                    dedupe_key=key,
                    last_key=key,
                    in_inbox=have.inbox,
                )
                delivery.plan(row, have)
    except IntegrityError:
        return None  # a parallel delivery of the same event won
    # Told only after the change committed (the block above is the outermost transaction).
    _announce(user_id, workspace.pk, "new" if row is not None else "changed")
    if row is not None:
        delivery.dispatch_soon()
    return row
