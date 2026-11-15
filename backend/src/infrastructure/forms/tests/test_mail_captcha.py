"""Submitter emails (locmem outbox), CAPTCHA with a mocked verifier, and the submit flood limit."""

import json
from typing import Any

import pytest
from django.test import Client

from infrastructure.auth.core import delivery
from infrastructure.forms import captcha, services
from infrastructure.forms import tasks as form_tasks
from infrastructure.forms.models import Form, FormSubmission
from infrastructure.projects.tests import conftest as project_fixtures
from infrastructure.tasks import services as task_services
from infrastructure.tasks.models import Task
from infrastructure.workflows.models import Status

make_user = project_fixtures.make_user
add_member = project_fixtures.add_member
_commit_hooks_run_now = project_fixtures._commit_hooks_run_now
team = project_fixtures.team

BASE = "/api/v1/public/forms"
FIELDS = [{"id": "t", "kind": "title", "label": "Title"}]


@pytest.fixture(autouse=True)
def _inline_celery(monkeypatch: pytest.MonkeyPatch) -> None:
    """Run the mail tasks at once, as the eager development setting does."""
    monkeypatch.setattr(form_tasks.send_confirmation, "delay", form_tasks.send_confirmation)
    monkeypatch.setattr(form_tasks.send_status, "delay", form_tasks.send_status)


@pytest.fixture
def form(team: Any) -> Form:
    project = team.create(team.owner, "WEB")
    view = services.create(
        team.owner, team.ws, str(project.pk), "Bug", fields=FIELDS, notify_status=True
    )
    return view.form


def _post(form: Form, lang: str = "en", **extra: Any) -> Any:
    data = {"answers": json.dumps({"t": "Broken login"}), "email": "visitor@example.com", **extra}
    return Client().post(f"{BASE}/{form.token}/submit", data, HTTP_ACCEPT_LANGUAGE=lang)


def _mails() -> list[Any]:
    return [m for m in delivery.outbox if m.channel == "email"]


def test_confirmation_email_is_sent_with_reference_only(form: Form, team: Any) -> None:
    reference = _post(form).json()["data"]["reference"]
    (mail,) = _mails()
    task = Task.objects.get()
    assert mail.destination == "visitor@example.com"
    assert reference in mail.subject and reference in mail.body
    assert "Broken login" in mail.body
    text = mail.subject + mail.body
    assert str(task.pk) not in text and task.display_id not in text
    assert str(team.ws.pk) not in text and "http" not in text and team.ws.slug not in text


def test_confirmation_is_in_the_visitors_language(form: Form) -> None:
    _post(form, lang="fa")
    (mail,) = _mails()
    assert "درخواست شما دریافت شد" in mail.subject
    assert "سپاسگزاریم" in mail.body


def test_no_email_when_none_given_or_confirmation_off(form: Form, team: Any) -> None:
    Client().post(f"{BASE}/{form.token}/submit", {"answers": json.dumps({"t": "x"})})
    assert _mails() == []
    services.update(team.owner, team.ws, str(form.pk), form.version, send_confirmation=False)
    _post(form)
    assert _mails() == []


def test_status_change_email_is_localized_and_leaks_nothing(form: Form, team: Any) -> None:
    _post(form, lang="ar")
    delivery.outbox.clear()
    task = Task.objects.get()
    done = Status.objects.get(project=task.project, name="Done")
    task_services.update(
        team.owner,
        team.ws,
        str(task.project_id),
        str(task.pk),
        task.version,
        {"status": str(done.pk)},
    )
    (mail,) = _mails()
    reference = FormSubmission.objects.get().reference
    assert reference in mail.subject and "Done" in mail.body
    assert "أصبحت حالة طلبك" in mail.body
    text = mail.subject + mail.body
    assert str(task.pk) not in text and str(team.ws.pk) not in text and "http" not in text


def test_status_email_needs_opt_in_on_both_sides(form: Form, team: Any) -> None:
    Client().post(f"{BASE}/{form.token}/submit", {"answers": json.dumps({"t": "x"})})
    task = Task.objects.get()
    done = Status.objects.get(project=task.project, name="Done")
    task_services.update(
        team.owner,
        team.ws,
        str(task.project_id),
        str(task.pk),
        task.version,
        {"status": str(done.pk)},
    )
    assert _mails() == []


class _Verifier:
    provider = "mock"
    site_key = "k"

    def __init__(self, ok: bool) -> None:
        self.ok = ok
        self.seen: list[str] = []

    def verify(self, token: str, remote_ip: str) -> bool:
        self.seen.append(token)
        return self.ok


@pytest.mark.parametrize("ok", [True, False])
def test_captcha_pass_and_fail(form: Form, monkeypatch: pytest.MonkeyPatch, ok: bool) -> None:
    verifier = _Verifier(ok)
    monkeypatch.setattr(captcha, "configured", lambda: verifier)
    response = _post(form, captcha_token="tok")
    assert verifier.seen == ["tok"]
    assert response.status_code == (201 if ok else 400)
    assert Task.objects.count() == (1 if ok else 0)


@pytest.mark.parametrize(
    ("site", "secret", "provider", "url"),
    [
        ("FORMS_TURNSTILE", "s", "turnstile", captcha.TURNSTILE_URL),
        ("FORMS_HCAPTCHA", "s", "hcaptcha", captcha.HCAPTCHA_URL),
    ],
)
def test_configured_provider_verifies_against_its_endpoint(
    settings: Any, monkeypatch: pytest.MonkeyPatch, site: str, secret: str, provider: str, url: str
) -> None:
    for prefix in ("FORMS_TURNSTILE", "FORMS_HCAPTCHA"):
        setattr(settings, f"{prefix}_SITE_KEY", "")
        setattr(settings, f"{prefix}_SECRET", "")
    setattr(settings, f"{site}_SITE_KEY", "site")
    setattr(settings, f"{site}_SECRET", secret)
    verifier = captcha.configured()
    assert verifier is not None and verifier.provider == provider
    calls: list[Any] = []

    class _Answer:
        def __init__(self, body: bytes) -> None:
            self.body = body

        def __enter__(self) -> "_Answer":
            return self

        def __exit__(self, *a: Any) -> None:
            return None

        def read(self, n: int) -> bytes:
            return self.body

    def fake(request: Any, timeout: float) -> _Answer:
        calls.append(request)
        return _Answer(b'{"success": true}' if len(calls) == 1 else b'{"success": false}')

    monkeypatch.setattr(captcha.urllib.request, "urlopen", fake)
    assert verifier.verify("good", "1.2.3.4") is True
    assert verifier.verify("bad", "1.2.3.4") is False
    assert calls[0].full_url == url
    assert verifier.verify("", "1.2.3.4") is False and len(calls) == 2  # no token: no call


def test_captcha_network_failure_fails_closed(
    settings: Any, monkeypatch: pytest.MonkeyPatch
) -> None:
    verifier = captcha.TurnstileVerifier("k", "s")

    def boom(request: Any, timeout: float) -> Any:
        raise OSError("down")

    monkeypatch.setattr(captcha.urllib.request, "urlopen", boom)
    assert verifier.verify("tok", "1.2.3.4") is False


def test_endpoint_flood_answers_429(form: Form, settings: Any) -> None:
    settings.FORMS_RATE_PER_FORM = ""
    settings.FORMS_RATE_PER_IP = "3/hour"
    codes = [_post(form).status_code for _ in range(5)]
    assert codes == [201, 201, 201, 429, 429]
    assert Task.objects.count() == 3
