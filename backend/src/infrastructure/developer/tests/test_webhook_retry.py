"""Webhook retry state: backoff, the due worker, giving up and redelivery. No network."""

from datetime import datetime, timedelta
from types import SimpleNamespace
from typing import Any

import pytest
from django.contrib.auth import get_user_model
from django.utils import timezone

from infrastructure.audit.models import AuditEntry
from infrastructure.common import dueworkers
from infrastructure.developer import delivery, outbound
from infrastructure.developer.models import DeliveryStatus, Webhook, WebhookDelivery
from infrastructure.workspaces.models import Workspace

START = timezone.make_aware(datetime(2026, 6, 1, 12, 0, 0))


class Net:
    """A stand-in for the outbound HTTP call: answers in turn, remembers who it was asked for."""

    def __init__(self, *answers: Any) -> None:
        self.answers = list(answers)
        self.urls: list[str] = []

    def post(self, url: str, body: bytes, headers: dict[str, str]) -> outbound.Response:
        self.urls.append(url)
        answer = self.answers.pop(0) if len(self.answers) > 1 else self.answers[0]
        if isinstance(answer, Exception):
            raise answer
        return outbound.Response(status=answer, snippet="", duration_ms=1)


@pytest.fixture
def clock(monkeypatch: pytest.MonkeyPatch) -> list[datetime]:
    now = [START]
    monkeypatch.setattr(delivery, "timezone", SimpleNamespace(now=lambda: now[0]))
    return now


@pytest.fixture
def net(monkeypatch: pytest.MonkeyPatch) -> Net:
    fake = Net(500)
    monkeypatch.setattr(delivery.outbound, "post", fake.post)
    return fake


@pytest.fixture
def hook(db: None) -> Webhook:
    user = get_user_model().objects.create_user(
        username="dev", email="dev@example.com", password="corr3ct-horse-battery"
    )
    workspace = Workspace.objects.create(name="W", slug="w-hooks", created_by=user)
    return Webhook.objects.create(
        workspace=workspace, url="https://example.com/hook", secret="s", events=["task.create"]
    )


def _row(hook: Webhook, **extra: Any) -> WebhookDelivery:
    fields: dict[str, Any] = {
        "webhook": hook,
        "workspace_id": hook.workspace_id,
        "event": "task.create",
        "event_id": "evt_1",
        "payload": {"id": "evt_1"},
        "status": DeliveryStatus.PENDING,
        "next_retry_at": START,
        "created_at": START,
    }
    return WebhookDelivery.objects.create(**{**fields, **extra})


def test_a_failure_schedules_the_next_try_with_exponential_backoff(
    hook: Webhook, clock: list[datetime], net: Net
) -> None:
    row = _row(hook)
    for attempt, wait in ((1, 60), (2, 120), (3, 240)):
        delivery.attempt(row.pk)
        row.refresh_from_db()
        assert (row.status, row.attempt) == (DeliveryStatus.FAILED, attempt)
        assert row.next_retry_at == clock[0] + timedelta(seconds=wait)
        assert row.error == "The receiver answered 500."
        clock[0] = row.next_retry_at


def test_a_network_error_is_a_failure_too(hook: Webhook, clock: list[datetime], net: Net) -> None:
    net.answers = [TimeoutError("slow")]
    row = _row(hook)
    delivery.attempt(row.pk)
    row.refresh_from_db()
    assert row.status == DeliveryStatus.FAILED and row.error == "slow"
    assert row.next_retry_at == START + timedelta(seconds=60)


def test_the_due_worker_picks_only_what_is_due(
    hook: Webhook, clock: list[datetime], net: Net
) -> None:
    net.answers = [200]
    due = _row(hook, event_id="due")
    failed_due = _row(hook, event_id="again", status=DeliveryStatus.FAILED, attempt=1)
    later = _row(hook, event_id="later", next_retry_at=START + timedelta(minutes=5))
    done = _row(hook, event_id="done", status=DeliveryStatus.DELIVERED, next_retry_at=None)
    gave_up = _row(hook, event_id="up", status=DeliveryStatus.GAVE_UP, next_retry_at=None)

    assert delivery.retry_due() == 2
    for row, status in (
        (due, DeliveryStatus.DELIVERED),
        (failed_due, DeliveryStatus.DELIVERED),
        (later, DeliveryStatus.PENDING),
        (done, DeliveryStatus.DELIVERED),
        (gave_up, DeliveryStatus.GAVE_UP),
    ):
        row.refresh_from_db()
        assert row.status == status
    later.refresh_from_db()
    assert later.attempt == 0
    assert len(net.urls) == 2


def test_a_claimed_delivery_is_not_sent_twice(
    hook: Webhook, clock: list[datetime], net: Net
) -> None:
    _row(hook)
    assert delivery.retry_due() == 1
    assert delivery.retry_due() == 0  # not due again until its backoff has passed
    clock[0] = START + timedelta(seconds=61)
    assert delivery.retry_due() == 1


def test_the_worker_is_registered_for_the_tick() -> None:
    assert "webhooks.retry" in dueworkers.names()


def test_after_24_hours_of_failures_it_gives_up_and_switches_the_webhook_off(
    hook: Webhook, clock: list[datetime], net: Net
) -> None:
    row = _row(hook, created_at=START - timedelta(hours=24), attempt=11, status="failed")
    before = AuditEntry.objects.filter(action="webhook.disabled").count()
    delivery.attempt(row.pk)
    row.refresh_from_db()
    hook.refresh_from_db()
    assert row.status == DeliveryStatus.GAVE_UP and row.next_retry_at is None
    assert hook.active is False
    assert hook.disabled_reason == "Switched off after 24 hours of failed deliveries."
    assert AuditEntry.objects.filter(action="webhook.disabled").count() == before + 1
    assert delivery.retry_due() == 0


def test_a_webhook_that_delivered_since_is_not_switched_off(
    hook: Webhook, clock: list[datetime], net: Net
) -> None:
    _row(
        hook,
        event_id="ok",
        status=DeliveryStatus.DELIVERED,
        next_retry_at=None,
        created_at=START - timedelta(hours=2),
        at=START - timedelta(hours=1),
    )
    row = _row(hook, created_at=START - timedelta(hours=24), attempt=11, status="failed")
    delivery.attempt(row.pk)
    row.refresh_from_db()
    hook.refresh_from_db()
    assert row.status == DeliveryStatus.GAVE_UP
    assert hook.active is True and hook.disabled_reason == ""


def test_a_failed_ping_is_not_retried(hook: Webhook, clock: list[datetime], net: Net) -> None:
    row = delivery.ping(hook)
    assert row.status == DeliveryStatus.GAVE_UP and row.next_retry_at is None
    hook.refresh_from_db()
    assert hook.active is True  # a test event never switches the webhook off


def test_redelivery_succeeds_as_a_new_row_with_the_same_event_id(
    hook: Webhook, clock: list[datetime], net: Net
) -> None:
    original = _row(hook)
    delivery.attempt(original.pk)
    net.answers = [204]
    clock[0] = START + timedelta(seconds=5)
    again = delivery.redeliver(original)
    original.refresh_from_db()
    assert again.pk != original.pk and again.resend_of_id == original.pk
    assert again.event_id == original.event_id
    assert again.status == DeliveryStatus.DELIVERED and again.next_retry_at is None
    assert original.status == DeliveryStatus.FAILED  # the history is left as it was


def test_a_delivery_to_a_switched_off_webhook_is_given_up(
    hook: Webhook, clock: list[datetime], net: Net
) -> None:
    Webhook.objects.filter(pk=hook.pk).update(active=False)
    row = _row(hook)
    delivery.attempt(row.pk)
    row.refresh_from_db()
    assert row.status == DeliveryStatus.GAVE_UP and net.urls == []
