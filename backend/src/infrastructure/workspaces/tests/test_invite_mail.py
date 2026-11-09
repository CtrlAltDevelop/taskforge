"""Invitation email: sent after commit, off the request, retried, never logging the token."""

import logging
import threading
from typing import Any

import pytest
from django.db import transaction

from infrastructure.auth.core import delivery
from infrastructure.auth.core.delivery import DeliveryError
from infrastructure.workspaces import invitations, invite_mail, services


@pytest.fixture(autouse=True)
def _commit_hooks_run_now() -> None:
    """Override the conftest shim: these tests need real on_commit semantics."""


@pytest.fixture(autouse=True)
def _clean_outbox() -> None:
    delivery.outbox.clear()


@pytest.fixture
def acme(alice: Any) -> Any:
    return services.create(alice, "Acme", "acme")


def test_nothing_is_sent_until_the_transaction_commits(
    acme: Any, alice: Any, django_capture_on_commit_callbacks: Any
) -> None:
    with django_capture_on_commit_callbacks(execute=False) as callbacks:
        invitations.create_invitations(acme, alice, ["bob@example.com"])
    assert delivery.outbox == [] and len(callbacks) == 1

    callbacks[0]()

    assert len(delivery.outbox) == 1


def test_a_rolled_back_transaction_sends_nothing(
    acme: Any, alice: Any, django_capture_on_commit_callbacks: Any
) -> None:
    with (
        django_capture_on_commit_callbacks(execute=True) as callbacks,
        pytest.raises(RuntimeError),
        transaction.atomic(),
    ):
        invitations.create_invitations(acme, alice, ["bob@example.com"])
        raise RuntimeError("boom")

    assert callbacks == [] and delivery.outbox == []


def test_the_signal_carries_the_job_and_nothing_else_is_persisted(
    acme: Any, alice: Any, django_capture_on_commit_callbacks: Any
) -> None:
    seen: list[dict[str, Any]] = []

    def spy(sender: Any, **kwargs: Any) -> None:
        seen.append(kwargs)

    invite_mail.invitation_issued.connect(spy, weak=False)
    try:
        with django_capture_on_commit_callbacks(execute=True):
            made = invitations.create_invitations(acme, alice, ["bob@example.com"]).created[0]
    finally:
        invite_mail.invitation_issued.disconnect(spy)

    (job,) = seen
    assert job["token"] == made.token and job["email"] == "bob@example.com"
    assert job["invitation_id"] == str(made.invitation.pk) and job["workspace_name"] == "Acme"
    assert made.token not in made.invitation.token_hash


def test_resend_sends_a_new_token(
    acme: Any, alice: Any, django_capture_on_commit_callbacks: Any
) -> None:
    with django_capture_on_commit_callbacks(execute=True):
        first = invitations.create_invitations(acme, alice, ["bob@example.com"]).created[0]
    with django_capture_on_commit_callbacks(execute=True):
        again = invitations.resend(acme, alice, str(first.invitation.pk))

    assert again.token != first.token
    assert len(delivery.outbox) == 2 and again.token in delivery.outbox[1].body


def _failing_send(calls: list[int], succeed_on: int | None = None) -> Any:
    def send(destination: str, subject: str, body: str) -> None:
        calls.append(1)
        if succeed_on is None or len(calls) < succeed_on:
            raise DeliveryError("smtp down " + body)

    return send


def test_a_failed_send_retries_then_logs_without_the_token(
    acme: Any,
    alice: Any,
    monkeypatch: pytest.MonkeyPatch,
    caplog: pytest.LogCaptureFixture,
    django_capture_on_commit_callbacks: Any,
) -> None:
    calls: list[int] = []
    monkeypatch.setattr(invite_mail, "send_email", _failing_send(calls))

    with caplog.at_level(logging.DEBUG), django_capture_on_commit_callbacks(execute=True):
        made = invitations.create_invitations(acme, alice, ["bob@example.com"]).created[0]

    assert len(calls) == invite_mail.MAX_ATTEMPTS
    assert str(made.invitation.pk) in caplog.text and str(acme.pk) in caplog.text
    assert "not delivered" in caplog.text
    assert made.token not in caplog.text and "bob@example.com" not in caplog.text
    made.invitation.refresh_from_db()
    assert made.invitation.revoked_at is None  # still pending, resendable


def test_a_transient_failure_is_retried_until_it_succeeds(
    acme: Any,
    alice: Any,
    monkeypatch: pytest.MonkeyPatch,
    django_capture_on_commit_callbacks: Any,
) -> None:
    calls: list[int] = []
    monkeypatch.setattr(invite_mail, "send_email", _failing_send(calls, succeed_on=3))

    with django_capture_on_commit_callbacks(execute=True):
        invitations.create_invitations(acme, alice, ["bob@example.com"])

    assert len(calls) == 3


def test_the_request_does_not_wait_for_smtp(
    acme: Any,
    alice: Any,
    settings: Any,
    monkeypatch: pytest.MonkeyPatch,
    django_capture_on_commit_callbacks: Any,
) -> None:
    settings.WORKSPACE_EMAIL_ASYNC = True
    release, started = threading.Event(), threading.Event()

    def slow_send(destination: str, subject: str, body: str) -> None:
        started.set()
        release.wait(5)

    monkeypatch.setattr(invite_mail, "send_email", slow_send)
    try:
        with django_capture_on_commit_callbacks(execute=True):
            invitations.create_invitations(acme, alice, ["bob@example.com"])
        # create_invitations returned although the send is still blocked
        assert started.wait(5) and not release.is_set()
    finally:
        release.set()
        invite_mail._executor().shutdown(wait=True)
        monkeypatch.setattr(invite_mail, "_pool", None)
