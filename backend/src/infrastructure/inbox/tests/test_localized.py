"""Notifications and mail are written in the recipient's language."""

from types import SimpleNamespace
from typing import Any

import pytest

from infrastructure.auth.core import delivery as mail
from infrastructure.common.locales import SUPPORTED_LOCALES
from infrastructure.common.messages import TEXT, recipient_locale, tr, tr_auth
from infrastructure.inbox import kinds, prefs, render
from infrastructure.inbox.tests.test_notify import assign


def _row(kind: str, **payload: Any) -> Any:
    base = {"key": "WEB-1", "title": "Fix login", "from": "a", "to": "b", "hours": 3,
            "due_date": "2026-01-02", "automation": "Auto", "reason": "r"}
    return SimpleNamespace(type=kind, payload={**base, **payload}, count=2, user=None, workspace=None)


def test_every_catalog_entry_has_all_four_languages() -> None:
    for key, entry in TEXT.items():
        assert set(entry) == set(SUPPORTED_LOCALES), key
        assert all(entry[lang].strip() for lang in SUPPORTED_LOCALES), key


def test_every_notification_kind_renders_in_every_language() -> None:
    for kind in kinds.BY_KEY:
        english = render.render(_row(kind), "Sara", "en")
        for lang in ("fa", "ar", "ps"):
            assert render.render(_row(kind), "Sara", lang)[0] != english[0], (kind, lang)


def test_english_output_is_unchanged() -> None:
    assert render.render(_row(kinds.COMMENTED), "Sara", "en")[0] == "Sara commented (+1 more)"
    assert render.render(_row(kinds.ASSIGNED), "", "en")[0] == "Someone assigned you a task"


def test_locale_fallback_order() -> None:
    user = SimpleNamespace(profile=SimpleNamespace(locale="fa-AF"))
    bare = SimpleNamespace(profile=SimpleNamespace(locale=""))
    ws = SimpleNamespace(default_locale="ar")
    assert recipient_locale(user, ws) == "fa"
    assert recipient_locale(bare, ws) == "ar"
    assert recipient_locale(bare, SimpleNamespace(default_locale="xx")) == "en"
    assert recipient_locale(SimpleNamespace(profile=SimpleNamespace(locale="de")), None) == "en"
    assert tr("notify.fallback.title", "de") == "Notification"
    assert tr_auth("something else", "fa") == "something else"


@pytest.mark.django_db
def test_a_persian_recipient_gets_persian_email_and_push(
    team: Any, project: Any, task: Any, push: Any
) -> None:
    from infrastructure.inbox.models import PushDevice

    team.member.profile.locale = "fa"
    team.member.profile.save()
    PushDevice.objects.create(user=team.member, platform="android", token="t1")
    prefs.set_pref(team.member, kinds.ASSIGNED, inbox=True, push=True, email_mode="instant")

    assign(team, project, task, team.member)

    [message] = [m for m in mail.outbox if m.destination == team.member.email]
    assert "به شما سپرد" in message.subject and "WEB-1 Fix login" in message.body
    assert "توقف این ایمیل‌ها" in message.body
    assert "به شما سپرد" in push.sent[0]["title"]


@pytest.mark.django_db
def test_workspace_default_applies_when_the_person_has_no_language(
    team: Any, project: Any, task: Any
) -> None:
    team.member.profile.locale = ""  # new accounts are saved as the default language; blank = unset
    team.member.profile.save()
    team.ws.default_locale = "ps"
    team.ws.save()
    prefs.set_pref(team.member, kinds.ASSIGNED, inbox=True, push=False, email_mode="instant")

    assign(team, project, task, team.member)

    [message] = [m for m in mail.outbox if m.destination == team.member.email]
    assert "وسپاره" in message.subject
