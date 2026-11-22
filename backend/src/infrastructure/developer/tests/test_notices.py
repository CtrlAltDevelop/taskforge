"""A webhook switched off after 24 hours of failures tells the people who manage webhooks."""

from datetime import timedelta
from typing import Any

import pytest

from infrastructure.developer import delivery
from infrastructure.developer.models import DeliveryStatus, Webhook, WebhookDelivery
from infrastructure.inbox import kinds
from infrastructure.inbox.models import Notification
from infrastructure.projects.tests import conftest as project_fixtures

make_user = project_fixtures.make_user
add_member = project_fixtures.add_member
_commit_hooks_run_now = project_fixtures._commit_hooks_run_now
team = project_fixtures.team


@pytest.fixture(autouse=True)
def _inbox_sync(settings: Any) -> None:
    settings.INBOX_SYNC_DELIVERY = True


def _failing_hook(team: Any) -> WebhookDelivery:
    hook = Webhook.objects.create(
        workspace=team.ws,
        name="CI",
        url="https://example.com/hook",
        secret="s",
        events=["task.create"],
    )
    return WebhookDelivery.objects.create(
        webhook=hook,
        workspace=team.ws,
        event="task.create",
        event_id="evt_1",
        payload={},
        status=DeliveryStatus.FAILED,
        attempt=11,
        created_at=delivery.timezone.now() - timedelta(hours=25),
    )


def test_switching_a_webhook_off_notifies_everyone_who_manages_webhooks(team: Any) -> None:
    row = _failing_hook(team)

    delivery._maybe_disable(row)

    told = Notification.objects.filter(type=kinds.WEBHOOK_DISABLED)
    assert {n.user_id for n in told} == {team.owner.pk, team.admin.pk}
    assert told[0].payload["webhook"] == "CI"
    assert "24 hours" in told[0].payload["reason"]
    assert told[0].project_id is None and told[0].task_id is None


def test_a_webhook_already_off_notifies_nobody(team: Any) -> None:
    row = _failing_hook(team)
    Webhook.objects.filter(pk=row.webhook_id).update(active=False)
    row.webhook.refresh_from_db()

    delivery._maybe_disable(row)

    assert not Notification.objects.filter(type=kinds.WEBHOOK_DISABLED).exists()


def test_the_notification_has_words_for_push_and_email(team: Any) -> None:
    from infrastructure.inbox import render

    delivery._maybe_disable(_failing_hook(team))
    note = Notification.objects.filter(type=kinds.WEBHOOK_DISABLED).first()

    title, body = render.render(note, "", "en")

    assert "CI" in title and "24 hours" in body
