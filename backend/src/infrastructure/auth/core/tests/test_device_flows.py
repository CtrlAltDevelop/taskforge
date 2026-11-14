"""Phase 40 end to end: sign-in flags, renaming, refresh, the switch, and what is never stored."""

import logging
from typing import Any

import pytest
from django.contrib.auth import get_user_model
from django.forms.models import model_to_dict
from django.test import Client, RequestFactory

from infrastructure.auth.core import device, dpop
from infrastructure.auth.core.models import KnownDevice
from infrastructure.auth.core.sessions import issue_credentials
from infrastructure.auth.core.tests.test_dpop import Key
from infrastructure.oauth.core.credentials import token_model

PHONE = "model=Pixel 8;os=android;osVersion=14;screen=1080x2400@2.75;locale=en-US;tz=Europe/Paris"
RAW_FRAGMENTS = ("1080x2400", "2.75", "Europe/Paris", "en-US", "screen=", "tz=")
SIGNIN_PATH = "/api/v1/auth/password/login"
SESSIONS = "/api/v1/auth/token/sessions"
REFRESH = "/api/v1/auth/token/refresh"

pytestmark = pytest.mark.django_db


@pytest.fixture(autouse=True)
def _collection_on(settings: Any) -> None:
    settings.COLLECT_DEVICE_INFO = True
    settings.DPOP_MODE = "off"
    settings.DPOP_NONCE_ENABLED = False


def make_user(name: str) -> Any:
    return get_user_model().objects.create_user(username=name, email=f"{name}@example.test")


@pytest.fixture
def alice() -> Any:
    return make_user("alice")


@pytest.fixture
def bob() -> Any:
    return make_user("bob")


def sign_in(user: Any, header: str | None = PHONE, key: Key | None = None) -> Any:
    extra: dict[str, str] = {}
    if header is not None:
        extra[device.REST_META_KEY] = header
    if key is not None:
        extra[dpop.HEADER_META] = key.proof(htm="POST", htu=f"{dpop.public_origin()}{SIGNIN_PATH}")
    request = RequestFactory().post(SIGNIN_PATH, **extra)
    return issue_credentials(request, user, method="password")


def family_of(credentials: Any) -> Any:
    return token_model("rotation", "TokenFamily").objects.get(pk=credentials.session_id)


def bearer(credentials: Any) -> dict[str, str]:
    return {"HTTP_AUTHORIZATION": f"Bearer {credentials.access_token}"}


def rename(client: Client, who: Any, session_id: str, name: str) -> Any:
    return client.patch(
        f"{SESSIONS}/{session_id}",
        {"name": name},
        content_type="application/json",
        **bearer(who),
    )


def refresh(client: Client, credentials: Any, header: str) -> Any:
    return client.post(
        REFRESH,
        {"refresh_token": credentials.refresh_token},
        content_type="application/json",
        **{device.REST_META_KEY: header},
    )


def test_a_user_cannot_rename_another_users_session(alice: Any, bob: Any) -> None:
    alices, bobs = sign_in(alice), sign_in(bob)
    before = family_of(alices).name

    crossed = rename(Client(), bobs, alices.session_id, "Mine now")

    assert crossed.status_code == 404
    family = family_of(alices)
    assert family.name == before
    assert family.name_edited is False


def test_a_user_can_rename_their_own_session(alice: Any) -> None:
    credentials = sign_in(alice)

    response = rename(Client(), credentials, credentials.session_id, "  Work   phone ")

    assert response.status_code == 200
    family = family_of(credentials)
    assert family.name == "Work phone"
    assert family.name_edited is True


def test_the_first_signin_is_a_new_device_and_the_second_is_not(alice: Any) -> None:
    first, second = sign_in(alice), sign_in(alice)

    assert family_of(first).metadata["device_flags"] == {"new_device": True}
    assert family_of(second).metadata["device_flags"] == {}
    assert device.view_fields(family_of(first), current=True)["new_device"] is True
    assert device.view_fields(family_of(second), current=True)["new_device"] is False
    assert KnownDevice.objects.filter(user=alice).count() == 1


def test_another_device_is_new_again(alice: Any) -> None:
    sign_in(alice)

    other = sign_in(alice, PHONE.replace("Pixel 8", "Pixel 9"))

    assert family_of(other).metadata["device_flags"] == {"new_device": True}
    assert KnownDevice.objects.filter(user=alice).count() == 2


def test_the_same_fingerprint_with_another_dpop_key_is_key_changed(
    alice: Any, settings: Any
) -> None:
    settings.DPOP_MODE = "optional"
    first_key, second_key = Key(), Key()

    sign_in(alice, key=first_key)
    changed = sign_in(alice, key=second_key)
    again = sign_in(alice, key=second_key)

    assert family_of(changed).metadata["device_flags"] == {"key_changed": True}
    assert device.view_fields(family_of(changed), current=True)["key_changed"] is True
    assert family_of(again).metadata["device_flags"] == {}
    assert KnownDevice.objects.get(user=alice).dpop_jkt == second_key.jkt


def test_the_same_key_twice_is_not_key_changed(alice: Any, settings: Any) -> None:
    settings.DPOP_MODE = "optional"
    key_a, key_b = Key(), Key()

    sign_in(alice, key=key_a)
    second = sign_in(alice, key=key_a)

    assert family_of(second).metadata["device_flags"] == {}
    assert key_b.jkt != key_a.jkt


def test_with_the_setting_off_nothing_is_stored_and_flags_are_false(
    alice: Any, settings: Any
) -> None:
    settings.COLLECT_DEVICE_INFO = False

    credentials = sign_in(alice)

    family = family_of(credentials)
    assert KnownDevice.objects.count() == 0
    assert family.device_fingerprint == ""
    assert family.device_label == ""
    assert family.metadata["device_flags"] == {}
    view = device.view_fields(family, current=True)
    assert view["new_device"] is False
    assert view["key_changed"] is False
    assert family.name  # named from the User-Agent instead


def test_without_a_pepper_nothing_is_stored_either(alice: Any, settings: Any) -> None:
    settings.DEVICE_FINGERPRINT_PEPPER = ""

    sign_in(alice)

    assert KnownDevice.objects.count() == 0


def test_flags_go_quiet_when_the_setting_is_switched_off_later(alice: Any, settings: Any) -> None:
    credentials = sign_in(alice)
    assert device.view_fields(family_of(credentials), current=True)["new_device"] is True

    settings.COLLECT_DEVICE_INFO = False

    assert device.view_fields(family_of(credentials), current=True)["new_device"] is False


def test_a_chosen_name_survives_a_refresh_that_updates_the_label(alice: Any) -> None:
    client = Client()
    credentials = sign_in(alice)
    rename(client, credentials, credentials.session_id, "Kitchen tablet")

    response = refresh(client, credentials, PHONE.replace("osVersion=14", "osVersion=15"))

    assert response.status_code == 200, response.content
    family = family_of(credentials)
    assert family.name == "Kitchen tablet"
    assert family.name_edited is True
    assert family.device_label == "Pixel 8 · Android 15"


def test_an_unedited_name_follows_the_device_label_on_refresh(alice: Any) -> None:
    client = Client()
    credentials = sign_in(alice)

    response = refresh(client, credentials, PHONE.replace("osVersion=14", "osVersion=15"))

    assert response.status_code == 200, response.content
    family = family_of(credentials)
    assert family.name == family.device_label == "Pixel 8 · Android 15"
    assert KnownDevice.objects.filter(user=alice).count() == 1  # same fingerprint


def _stored_text(credentials: Any, user: Any) -> str:
    rows = [model_to_dict(family_of(credentials))]
    rows += [model_to_dict(known) for known in KnownDevice.objects.filter(user=user)]
    return repr(rows)


def test_no_raw_header_value_reaches_the_database_or_the_logs(
    alice: Any, caplog: pytest.LogCaptureFixture
) -> None:
    caplog.set_level(logging.DEBUG)

    credentials = sign_in(alice)
    sign_in(alice, "model=Pix\x00el;os=android;screen=1080x2400@2.75")  # rejected: never logged
    refresh(Client(), credentials, PHONE)

    stored = _stored_text(credentials, alice)
    assert PHONE not in stored
    assert PHONE not in caplog.text
    for fragment in RAW_FRAGMENTS:
        assert fragment not in stored, fragment
        assert fragment not in caplog.text, fragment
