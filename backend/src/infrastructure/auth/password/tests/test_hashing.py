"""Passwords hash with Argon2; older PBKDF2 hashes still log in and are upgraded."""

from django.contrib.auth import get_user_model
from django.contrib.auth.hashers import make_password
from django.test import Client, override_settings

from config.settings.base import PASSWORD_HASHERS

SIGNUP = "/api/v1/auth/password/signup"
LOGIN = "/api/v1/auth/password/login"
PASSWORD = "Xq7-mnbvcz-secret"


def _post(path: str, body: dict[str, str]) -> int:
    return Client().post(path, body, content_type="application/json").status_code


@override_settings(PASSWORD_HASHERS=PASSWORD_HASHERS)
def test_a_new_password_is_stored_as_argon2(db: None) -> None:
    body = {"identifier": "zoe@example.com", "password": PASSWORD, "email": "zoe@example.com"}

    assert _post(SIGNUP, body) == 200

    assert get_user_model().objects.get(email="zoe@example.com").password.startswith("argon2$")


@override_settings(PASSWORD_HASHERS=PASSWORD_HASHERS)
def test_a_legacy_pbkdf2_hash_still_logs_in_and_is_upgraded_to_argon2(db: None) -> None:
    user = get_user_model().objects.create(username="old@example.com", email="old@example.com")
    user.password = make_password(PASSWORD, hasher="pbkdf2_sha256")
    user.save()
    assert user.password.startswith("pbkdf2_sha256$")

    status = _post(LOGIN, {"identifier": "old@example.com", "password": PASSWORD})

    user.refresh_from_db()
    assert status == 200 and user.password.startswith("argon2$")
