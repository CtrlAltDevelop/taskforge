"""Sending events to webhooks: queue, try, back off, give up.

``dispatch`` writes one ``WebhookDelivery`` per subscribed webhook (``next_retry_at`` = now) and
hands each to the ``deliver`` task (inline in debug). A failed try sets ``next_retry_at`` to the
next point of an exponential backoff; the due worker ``retry_due`` (``make tick`` / beat) sends
what is due. After ``RETRY_WINDOW`` of failing the delivery is given up and, unless something was
delivered since, the webhook is switched off with a reason the screen shows.
"""

import http.client
import json
import logging
import secrets
from datetime import timedelta
from typing import Any, Final

from django.db.models import Q
from django.utils import timezone

from infrastructure.audit import recorder
from infrastructure.developer import events, outbound, signing
from infrastructure.developer.models import DeliveryStatus, Webhook, WebhookDelivery

logger = logging.getLogger(__name__)

RETRY_WINDOW: Final = timedelta(hours=24)
FIRST_DELAY_SECONDS: Final = 60
MAX_DELAY_SECONDS: Final = 6 * 3600
LEASE: Final = timedelta(minutes=2)  # a claimed delivery is not claimed again for this long
BATCH: Final = 100
SYSTEM_ACTOR: Final = "system"


def backoff(attempt: int) -> timedelta:
    """The wait after the ``attempt``-th failed try: 1 min, 2, 4, ... capped at 6 hours."""
    return timedelta(seconds=min(FIRST_DELAY_SECONDS * 2 ** max(attempt - 1, 0), MAX_DELAY_SECONDS))


def envelope(webhook: Webhook, event: str, event_id: str, data: dict[str, Any]) -> dict[str, Any]:
    return {
        "id": event_id,
        "type": event,
        "created_at": timezone.now().isoformat(),
        "workspace_id": str(webhook.workspace_id),
        "project_id": str(webhook.project_id) if webhook.project_id else None,
        "data": data,
    }


def dispatch(
    workspace_id: Any, project_id: Any, event: str, identity: str, data: dict[str, Any]
) -> int:
    """Queue ``event`` for every active webhook subscribed to it; returns how many."""
    hooks = Webhook.objects.filter(workspace_id=workspace_id, active=True).filter(
        Q(project__isnull=True) | Q(project_id=project_id)
    )
    event_id = events.event_id(identity)
    queued = 0
    for hook in hooks:
        if event not in hook.events:
            continue
        body = envelope(hook, event, event_id, data)
        body["project_id"] = str(project_id) if project_id else None
        row = WebhookDelivery.objects.create(
            webhook=hook,
            workspace_id=workspace_id,
            event=event,
            event_id=event_id,
            payload=body,
            status=DeliveryStatus.PENDING,
            next_retry_at=timezone.now(),
        )
        _hand_over(row.pk)
        queued += 1
    return queued


def _hand_over(delivery_id: Any) -> None:
    from infrastructure.developer.tasks import deliver

    try:
        deliver.delay(str(delivery_id))
    except Exception:  # noqa: BLE001 -- a broker outage must not lose the row: retry_due finds it
        logger.exception("could not queue webhook delivery %s", delivery_id)


def _claim(delivery_id: Any) -> WebhookDelivery | None:
    """Take a due delivery for one sender, or ``None`` if another one has it or it is not due."""
    now = timezone.now()
    taken = WebhookDelivery.objects.filter(
        pk=delivery_id,
        status__in=(DeliveryStatus.PENDING, DeliveryStatus.FAILED),
        next_retry_at__lte=now,
    ).update(next_retry_at=now + LEASE)
    if not taken:
        return None
    return WebhookDelivery.objects.select_related("webhook").get(pk=delivery_id)


def _headers(delivery: WebhookDelivery, body: bytes) -> dict[str, str]:
    stamp = int(timezone.now().timestamp())
    return {
        "Content-Type": "application/json",
        "User-Agent": "TaskForge-Webhooks/1",
        "X-TaskForge-Event": delivery.event,
        "X-TaskForge-Event-Id": delivery.event_id,
        "X-TaskForge-Delivery": str(delivery.pk),
        signing.TIMESTAMP_HEADER: str(stamp),
        signing.SIGNATURE_HEADER: signing.sign(delivery.webhook.secret, stamp, body),
    }


def attempt(delivery_id: Any, *, retry: bool = True) -> WebhookDelivery | None:
    """Try one delivery now (if it is due and nobody else has it); schedule what comes next."""
    delivery = _claim(delivery_id)
    if delivery is None:
        return None
    hook = delivery.webhook
    if not hook.active and delivery.event != events.PING:
        _finish(delivery, DeliveryStatus.GAVE_UP, error="The webhook is switched off.")
        return delivery
    body = json.dumps(delivery.payload, separators=(",", ":"), sort_keys=True).encode()
    headers = _headers(delivery, body)
    delivery.attempt += 1
    delivery.request_headers = headers
    delivery.at = timezone.now()
    try:
        answer = outbound.post(hook.url, body, headers)
    except (outbound.UnsafeUrl, OSError, TimeoutError, http.client.HTTPException) as error:
        delivery.error = str(error)[:300]
        _failed(delivery, retry)
        return delivery
    delivery.status_code = answer.status
    delivery.response_snippet = answer.snippet
    delivery.duration_ms = answer.duration_ms
    delivery.error = ""
    if 200 <= answer.status < 300:
        _finish(delivery, DeliveryStatus.DELIVERED)
    else:
        delivery.error = f"The receiver answered {answer.status}."
        _failed(delivery, retry)
    return delivery


def _finish(delivery: WebhookDelivery, status: str, *, error: str = "") -> None:
    delivery.status = status
    delivery.next_retry_at = None
    if error:
        delivery.error = error
    delivery.save()


def _failed(delivery: WebhookDelivery, retry: bool) -> None:
    wait = backoff(delivery.attempt)
    if retry and timezone.now() + wait <= delivery.created_at + RETRY_WINDOW:
        delivery.status = DeliveryStatus.FAILED
        delivery.next_retry_at = timezone.now() + wait
        delivery.save()
        return
    _finish(delivery, DeliveryStatus.GAVE_UP)
    if retry:
        _maybe_disable(delivery)


def _maybe_disable(delivery: WebhookDelivery) -> None:
    hook = delivery.webhook
    alive = WebhookDelivery.objects.filter(
        webhook=hook, status=DeliveryStatus.DELIVERED, at__gte=delivery.created_at
    ).exists()
    if alive or not hook.active:
        return
    reason = "Switched off after 24 hours of failed deliveries."
    Webhook.objects.filter(pk=hook.pk).update(active=False, disabled_reason=reason)
    recorder.record(
        workspace_id=hook.workspace_id,
        action="webhook.disabled",
        target_type="webhook",
        target_id=hook.pk,
        project_id=hook.project_id,
        changes={"name": hook.name, "reason": reason},
        actor_type="system",
    )


def retry_due() -> int:
    """The due worker: send every delivery whose time has come; returns how many were tried."""
    ids = list(
        WebhookDelivery.objects.filter(
            status__in=(DeliveryStatus.PENDING, DeliveryStatus.FAILED),
            next_retry_at__lte=timezone.now(),
        )
        .order_by("next_retry_at")
        .values_list("pk", flat=True)[:BATCH]
    )
    return sum(1 for pk in ids if attempt(pk) is not None)


def redeliver(delivery: WebhookDelivery) -> WebhookDelivery:
    """Send a delivery again: a new row (same event id) tried at once, retried like any other."""
    row = WebhookDelivery.objects.create(
        webhook=delivery.webhook,
        workspace_id=delivery.workspace_id,
        event=delivery.event,
        event_id=delivery.event_id,
        payload=delivery.payload,
        status=DeliveryStatus.PENDING,
        next_retry_at=timezone.now(),
        resend_of=delivery,
    )
    return attempt(row.pk) or row


def ping(hook: Webhook) -> WebhookDelivery:
    """A test event, sent now, once (a failed test is not retried)."""
    body = envelope(
        hook, events.PING, events.event_id(f"ping:{hook.pk}:{secrets.token_hex(6)}"), {"ping": True}
    )
    row = WebhookDelivery.objects.create(
        webhook=hook,
        workspace_id=hook.workspace_id,
        event=events.PING,
        event_id=body["id"],
        payload=body,
        status=DeliveryStatus.PENDING,
        next_retry_at=timezone.now(),
    )
    return attempt(row.pk, retry=False) or row
