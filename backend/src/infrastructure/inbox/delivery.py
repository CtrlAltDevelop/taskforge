"""Push and email: planning what is owed, and sending what is due.

``plan`` writes a ``Delivery`` per channel the person asked for, due now, after their quiet hours,
or at their next digest time. ``deliver_due`` sends what is due: a push to each of the person's
devices, an email with an unsubscribe link, or one digest email grouping everything waiting for
them by project. Before sending it checks again that the person still has access and has not read
the notification meanwhile; otherwise the delivery is skipped. A failure is retried a few times a
few minutes apart.

There is no job queue in this project yet, so ``dispatch_soon`` runs ``deliver_due`` on a small
background pool right after a notification is made (or in the same thread with
``INBOX_SYNC_DELIVERY``), and ``manage.py inbox_tick`` (cron, every minute or so) sends what was
held for quiet hours or a digest and retries failures.
"""

import logging
from collections import defaultdict
from concurrent.futures import ThreadPoolExecutor
from datetime import datetime, timedelta
from threading import Lock
from typing import Any, Final

from django.conf import settings
from django.core import signing
from django.db import close_old_connections, transaction
from django.utils import timezone
from django.utils.module_loading import import_string

from infrastructure.comments import mentions
from infrastructure.common.messages import recipient_locale, tr
from infrastructure.inbox import kinds, prefs, push, render, schedule
from infrastructure.inbox.models import (
    Channel,
    Delivery,
    DeliveryStatus,
    EmailMode,
    Notification,
    PushDevice,
)

logger = logging.getLogger(__name__)

MAX_ATTEMPTS: Final = 3
RETRY_MINUTES: Final = 5
CLAIM_MINUTES: Final = 30
DIGEST_LINES: Final = 50
BATCH: Final = 100
UNSUBSCRIBE_SALT: Final = "inbox.unsubscribe"
_pool: ThreadPoolExecutor | None = None


_provider: Any = None
_provider_lock = Lock()


def push_provider() -> Any:
    """One provider for the whole process (it keeps its HTTP client and access token)."""
    global _provider
    with _provider_lock:
        if _provider is None:
            _provider = import_string(settings.INBOX_PUSH_PROVIDER)()
        return _provider


def unsubscribe_token(user_id: Any, kind: str) -> str:
    return signing.dumps({"u": str(user_id), "k": kind}, salt=UNSUBSCRIBE_SALT)


def read_unsubscribe_token(token: str) -> tuple[str, str] | None:
    try:
        payload = signing.loads(
            token, salt=UNSUBSCRIBE_SALT, max_age=settings.INBOX_UNSUBSCRIBE_DAYS * 86400
        )
        return str(payload["u"]), str(payload["k"])
    except (signing.BadSignature, KeyError, TypeError):
        return None


def plan(row: Notification, have: prefs.Effective) -> None:
    """Write the deliveries ``have`` (the person's choice for this kind) calls for."""
    now = timezone.now()
    person = prefs.settings_of(row.user)
    owed: list[tuple[str, datetime]] = []
    if have.push:
        owed.append((Channel.PUSH, schedule.release_time(now, person)))
    if have.email_mode == EmailMode.INSTANT:
        owed.append((Channel.EMAIL, schedule.release_time(now, person)))
    elif have.email_mode == EmailMode.DIGEST:
        owed.append(
            (Channel.DIGEST, schedule.release_time(schedule.next_digest(now, person), person))
        )
    Delivery.objects.bulk_create(
        [Delivery(notification=row, channel=channel, due_at=due) for channel, due in owed]
    )


def dispatch_soon() -> None:
    """Send what is due now, without making the request wait for a provider."""
    if settings.INBOX_SYNC_DELIVERY:
        deliver_due()
        return
    global _pool
    if _pool is None:
        _pool = ThreadPoolExecutor(2, thread_name_prefix="inbox-delivery")
    _pool.submit(_in_thread)


def _in_thread() -> None:
    try:
        deliver_due()
    except Exception:  # noqa: BLE001 -- a worker thread must not die
        logger.exception("inbox delivery failed")
    finally:
        close_old_connections()


# -- sending -------------------------------------------------------------------------------------


def _still_owed(row: Notification, channel: str) -> bool:
    """Still worth sending: not read or archived meanwhile, the person still has access, and has
    not turned this channel off since it was planned."""
    if row.read_at is not None or row.archived_at is not None:
        return False
    have = prefs.effective(row.user_id, row.type)
    if channel == Channel.PUSH and not have.push:
        return False
    if channel == Channel.EMAIL and have.email_mode != EmailMode.INSTANT:
        return False
    if channel == Channel.DIGEST and have.email_mode != EmailMode.DIGEST:
        return False
    if row.type in kinds.CHAT_KINDS:
        return _chat_owed(row)
    if row.task_id is None:
        return True
    if row.task.deleted_at is not None:
        return False
    from infrastructure.projects.models import Project

    project = Project.objects.filter(pk=row.project_id).first()
    return project is not None and row.user_id in mentions.can_see(row.workspace, project)


def _chat_owed(row: Notification) -> bool:
    """A chat push still owed: the person can still read the space and has not muted it
    completely."""
    from infrastructure.chat import access
    from infrastructure.chat.models import ChatMember, ChatSpace

    space = (
        ChatSpace.objects.select_related("workspace", "project")
        .filter(pk=row.payload.get("space_id"))
        .first()
    )
    if space is None or not access.can_read(row.user_id, space):
        return False
    mine = ChatMember.objects.filter(space=space, user_id=row.user_id).first()
    return not (mine is not None and mine.muted and mine.muted_completely)


def _data(row: Notification) -> dict[str, str]:
    return {
        "notification_id": str(row.pk),
        "workspace_id": str(row.workspace_id),
        "task_id": str(row.task_id or ""),
        "project_id": str(row.project_id or ""),
        "type": row.type,
    }


def _private(row: Notification) -> bool:
    from infrastructure.projects.models import Project, Visibility

    return Project.objects.filter(pk=row.project_id, visibility=Visibility.PRIVATE).exists()


def _push_words(row: Notification, actor_name: str) -> tuple[str, str]:
    """What a push says. A push crosses a third party's servers and shows on a lock screen, so for
    a private project it names only the task's key."""
    if row.task_id is not None and _private(row):
        lang = recipient_locale(row.user, row.workspace)
        return tr("notify.private.title", lang), render.clean(row.payload.get("key", ""))
    return render.render(row, actor_name)


def _send_push(row: Notification, actor_name: str) -> bool:
    devices = list(PushDevice.objects.filter(user_id=row.user_id))
    if not devices:
        return False
    title, body = _push_words(row, actor_name)
    provider = push_provider()
    reached = 0
    failure: Exception | None = None
    for device in devices:
        try:
            provider.send(device, title, body, _data(row))
            reached += 1
        except push.DeadToken:
            device.delete()
        except Exception as error:  # noqa: BLE001 -- one device failing must not repeat the others
            logger.warning("push to device %s failed: %s", device.pk, type(error).__name__)
            failure = error
    if failure is not None and reached == 0:
        raise failure  # nobody got it: the whole delivery is tried again
    return True


def _send_email(row: Notification, actor_name: str) -> bool:
    from infrastructure.auth.core.delivery import send_email

    email = row.user.email
    if not email:
        return False
    title, body = render.render(row, actor_name)
    link = settings.INBOX_UNSUBSCRIBE_URL.format(token=unsubscribe_token(row.user_id, row.type))
    stop = tr("email.stop", recipient_locale(row.user, row.workspace), link=link)
    send_email(email, title, f"{body}\n\n{stop}\n")
    return True


def _actor_name(row: Notification) -> str:
    return mentions.display_name(row.actor) if row.actor else ""


def _finish(item: Delivery, status: str) -> None:
    item.status = status
    item.sent_at = timezone.now() if status == DeliveryStatus.SENT else None
    item.claimed_at = None
    item.save(update_fields=["status", "sent_at", "claimed_at", "attempts", "due_at"])


def _retry(item: Delivery) -> None:
    if item.attempts >= MAX_ATTEMPTS:
        _finish(item, DeliveryStatus.FAILED)
        return
    item.status = DeliveryStatus.PENDING
    item.claimed_at = None
    item.due_at = timezone.now() + timedelta(minutes=RETRY_MINUTES)
    item.save(update_fields=["status", "claimed_at", "attempts", "due_at"])


def _claim(now: datetime, *, digest: bool, limit: int) -> list[Delivery]:
    """Take what is due, in a short transaction: the rows are marked ``sending`` so no other worker
    sends them, and the sending happens outside any transaction (a provider can be slow). Digests
    are claimed whole, every due row of a person together, so nobody gets two in a day."""
    with transaction.atomic():
        wanted = Delivery.objects.select_for_update(skip_locked=True, of=("self",)).filter(
            status=DeliveryStatus.PENDING, due_at__lte=now
        )
        if digest:
            wanted = wanted.filter(channel=Channel.DIGEST)
            people = list(
                wanted.order_by("due_at")
                .values_list("notification__user_id", flat=True)
                .distinct()[:limit]
            )
            ids = list(wanted.filter(notification__user_id__in=people).values_list("pk", flat=True))
        else:
            ids = list(
                wanted.exclude(channel=Channel.DIGEST)
                .order_by("due_at")
                .values_list("pk", flat=True)[:limit]
            )
        Delivery.objects.filter(pk__in=ids).update(
            status=DeliveryStatus.SENDING, claimed_at=timezone.now()
        )
    return list(
        Delivery.objects.filter(pk__in=ids).select_related(
            "notification__user",
            "notification__actor",
            "notification__workspace",
            "notification__task",
        )
    )


def release_stale_claims(now: datetime | None = None) -> int:
    """Give back deliveries whose worker died while sending (they are tried again)."""
    cutoff = (now or timezone.now()) - timedelta(minutes=CLAIM_MINUTES)
    return Delivery.objects.filter(status=DeliveryStatus.SENDING, claimed_at__lte=cutoff).update(
        status=DeliveryStatus.PENDING, claimed_at=None
    )


def _attempt(item: Delivery) -> None:
    row = item.notification
    item.attempts += 1
    if not _still_owed(row, item.channel):
        _finish(item, DeliveryStatus.SKIPPED)
        return
    try:
        sent = (
            _send_push(row, _actor_name(row))
            if item.channel == Channel.PUSH
            else _send_email(row, _actor_name(row))
        )
    except Exception:  # noqa: BLE001 -- a provider can fail in any way; it is retried
        logger.exception("could not deliver %s %s", item.channel, item.pk)
        _retry(item)
        return
    _finish(item, DeliveryStatus.SENT if sent else DeliveryStatus.SKIPPED)


def deliver_due(now: datetime | None = None) -> int:
    """Send every push and email that is due; returns how many deliveries were handled."""
    now = now or timezone.now()
    release_stale_claims(now)
    due = _claim(now, digest=False, limit=BATCH)
    for item in due:
        Delivery.objects.filter(pk=item.pk).update(claimed_at=timezone.now())  # still working
        _attempt(item)
    return len(due) + send_digests(now)


# -- the daily digest ----------------------------------------------------------------------------


def _digest_text(rows: list[Notification], lang: str = "en") -> str:
    by_project: dict[Any, list[Notification]] = defaultdict(list)
    for row in rows:
        by_project[row.project_id].append(row)
    from infrastructure.projects.models import Project

    names = dict(Project.objects.filter(pk__in=list(by_project)).values_list("pk", "name"))
    lines: list[str] = []
    shown = 0
    for project_id, items in by_project.items():
        lines.append(render.clean(names.get(project_id, tr("digest.other", lang))))
        for row in items:
            if shown >= DIGEST_LINES:
                break
            title, body = render.render(row, _actor_name(row), lang)
            lines.append(f"  - {title}: {body.splitlines()[0] if body else ''}")
            shown += 1
        lines.append("")
    if len(rows) > shown:
        lines.append(tr("digest.more", lang, n=len(rows) - shown) + "\n")
    return "\n".join(lines)


def send_digests(now: datetime) -> int:
    """One email per person with everything waiting for their digest. Returns deliveries handled."""
    due = _claim(now, digest=True, limit=BATCH)
    grouped: dict[Any, list[Delivery]] = defaultdict(list)
    for item in due:
        grouped[item.notification.user_id].append(item)
    for items in grouped.values():
        _send_digest(items)
    return len(due)


def _send_digest(items: list[Delivery]) -> None:
    from infrastructure.auth.core.delivery import send_email

    live = [i for i in items if _still_owed(i.notification, Channel.DIGEST)]
    for item in items:
        item.attempts += 1
    user = items[0].notification.user
    if live and user.email:
        try:
            link = settings.INBOX_UNSUBSCRIBE_URL.format(token=unsubscribe_token(user.pk, "all"))
            lang = recipient_locale(user, live[0].notification.workspace)
            text = _digest_text([i.notification for i in live], lang)
            stop = tr("email.stop", lang, link=link)
            send_email(user.email, tr("digest.subject", lang), f"{text}\n{stop}\n")
        except Exception:  # noqa: BLE001
            logger.exception("could not send the digest to %s", user.pk)
            for item in items:
                _retry(item)
            return
    live_ids = {i.pk for i in live}
    for item in items:
        _finish(item, DeliveryStatus.SENT if item.pk in live_ids else DeliveryStatus.SKIPPED)
