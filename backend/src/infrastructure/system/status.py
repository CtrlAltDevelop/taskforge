"""What an operator asks of a running deployment: is the queue alive, is due work piling up.

Every probe here is bounded (a short socket timeout) and reports ``unavailable`` rather than
raising, so a dead Redis makes the System page say so instead of failing it.
"""

import logging
from dataclasses import dataclass, field
from typing import Any

from django.conf import settings
from django.utils import timezone

logger = logging.getLogger(__name__)

PROBE_TIMEOUT_SECONDS = 2


@dataclass(frozen=True, slots=True)
class QueueHealth:
    redis: str  # ok | unavailable | not_configured
    broker: str  # ok | unavailable | in_memory
    eager: bool  # tasks run inline (debug): there is no worker to find
    workers: int  # Celery workers answering a ping; -1 when not asked or not applicable
    backlog: dict[str, int] = field(default_factory=dict)  # overdue due-work rows by kind

    @property
    def ok(self) -> bool:
        return self.redis != "unavailable" and self.broker != "unavailable"


def redis_state() -> str:
    url = getattr(settings, "REDIS_URL", "")
    if not url:
        return "not_configured"
    try:
        import redis

        client = redis.Redis.from_url(
            url,
            socket_connect_timeout=PROBE_TIMEOUT_SECONDS,
            socket_timeout=PROBE_TIMEOUT_SECONDS,
        )
        client.ping()
    except Exception:
        logger.warning("Redis ping failed", exc_info=True)
        return "unavailable"
    return "ok"


def broker_state() -> str:
    url = str(getattr(settings, "CELERY_BROKER_URL", "") or "")
    if not url or url.startswith("memory"):
        return "in_memory"
    try:
        from config.celery import app

        with app.connection_for_read() as connection:
            connection.ensure_connection(max_retries=1, timeout=PROBE_TIMEOUT_SECONDS)
    except Exception:
        logger.warning("Celery broker unreachable", exc_info=True)
        return "unavailable"
    return "ok"


def worker_count() -> int:
    """How many Celery workers answer a ping (about a second). -1 when tasks run inline."""
    if getattr(settings, "CELERY_TASK_ALWAYS_EAGER", False):
        return -1
    try:
        from config.celery import app

        replies = app.control.inspect(timeout=1).ping() or {}
    except Exception:
        logger.warning("Celery worker ping failed", exc_info=True)
        return 0
    return len(replies)


def due_backlog() -> dict[str, int]:
    """Rows whose time has come and that nothing has handled yet: a growing number means the
    ``tick`` (beat) is not running or a worker is behind."""
    now = timezone.now()
    counts: dict[str, int] = {}
    try:
        from infrastructure.developer.models import DeliveryStatus as WebhookStatus
        from infrastructure.developer.models import WebhookDelivery

        counts["webhook_retries"] = WebhookDelivery.objects.filter(
            status=WebhookStatus.PENDING, next_retry_at__lte=now
        ).count()
        from infrastructure.inbox.models import Delivery
        from infrastructure.inbox.models import DeliveryStatus as InboxStatus

        counts["notification_deliveries"] = Delivery.objects.filter(
            status=InboxStatus.PENDING, due_at__lte=now
        ).count()
        from infrastructure.recurrence.models import RecurrenceSeries

        counts["recurring_tasks"] = RecurrenceSeries.objects.filter(
            paused=False, next_run_at__lte=now
        ).count()
    except Exception:
        logger.warning("Could not count the due-work backlog", exc_info=True)
    return counts


def queue_health(*, with_workers: bool = False) -> QueueHealth:
    return QueueHealth(
        redis=redis_state(),
        broker=broker_state(),
        eager=bool(getattr(settings, "CELERY_TASK_ALWAYS_EAGER", False)),
        workers=worker_count() if with_workers else -1,
        backlog=due_backlog(),
    )


def system_summary() -> dict[str, Any]:
    from infrastructure.system.version import version_info

    health = queue_health(with_workers=True)
    from django.conf import settings

    from infrastructure.auth.core import device

    return {
        **version_info(),
        "queue": health,
        "collect_device_info": device.collection_enabled(),
        "device_pepper_set": bool(settings.DEVICE_FINGERPRINT_PEPPER),
    }
