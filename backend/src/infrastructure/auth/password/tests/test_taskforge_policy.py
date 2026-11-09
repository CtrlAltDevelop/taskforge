"""TaskForge's password and sign-in policy (phase 01)."""

from django.test import Client

SIGNUP = "/api/v1/auth/password/signup"
LOGIN = "/api/v1/auth/password/login"


def _signup(client: Client, password: str, identifier: str = "zoe@example.com") -> int:
    return client.post(
        SIGNUP,
        {"identifier": identifier, "password": password, "email": identifier},
        content_type="application/json",
    ).status_code


def test_a_nine_character_password_is_refused(db: None) -> None:
    assert _signup(Client(), "Xq7-mnbvc") == 400


def test_a_ten_character_password_is_accepted(db: None) -> None:
    assert _signup(Client(), "Xq7-mnbvcz") == 200


def test_the_sixth_login_attempt_in_the_window_is_rate_limited(db: None) -> None:
    client = Client()
    _signup(client, "Xq7-mnbvcz")
    attempts = [
        client.post(
            LOGIN,
            {"identifier": "zoe@example.com", "password": "wrong-password"},
            content_type="application/json",
        ).status_code
        for _ in range(6)
    ]

    assert attempts == [401, 401, 401, 401, 401, 429]


def test_token_lifetimes_are_fifteen_minutes_and_thirty_days() -> None:
    from django.conf import settings

    assert settings.AUTH_ACCESS_TOKEN_TTL_SECONDS == 15 * 60
    assert settings.AUTH_REFRESH_TOKEN_TTL_SECONDS == 30 * 24 * 3600


def test_signing_out_one_device_leaves_the_others_signed_in(db: None) -> None:
    refresh = "/api/v1/auth/token/refresh"
    logout = "/api/v1/auth/password/logout"
    laptop, phone = Client(), Client()
    _signup(laptop, "Xq7-mnbvcz")
    laptop_creds = laptop.post(
        LOGIN,
        {"identifier": "zoe@example.com", "password": "Xq7-mnbvcz"},
        content_type="application/json",
    ).json()["data"]["credentials"]
    phone_creds = phone.post(
        LOGIN,
        {"identifier": "zoe@example.com", "password": "Xq7-mnbvcz"},
        content_type="application/json",
    ).json()["data"]["credentials"]

    laptop.post(logout, {"token": laptop_creds["refresh_token"]}, content_type="application/json")

    def refreshes(client: Client, creds: dict[str, str]) -> int:
        return client.post(
            refresh, {"refresh_token": creds["refresh_token"]}, content_type="application/json"
        ).status_code

    assert refreshes(laptop, laptop_creds) == 401
    assert refreshes(phone, phone_creds) == 200


def _login_from(client: Client, password: str, ip: str) -> int:
    return client.post(
        LOGIN,
        {"identifier": "zoe@example.com", "password": password},
        content_type="application/json",
        REMOTE_ADDR=ip,
    ).status_code


def test_successful_sign_ins_are_never_counted_against_the_limit(db: None) -> None:
    client = Client()
    _signup(client, "Xq7-mnbvcz")

    statuses = [_login_from(client, "Xq7-mnbvcz", "10.0.0.1") for _ in range(8)]

    assert statuses == [200] * 8


def test_a_lockout_from_one_address_does_not_block_the_owner_elsewhere(db: None) -> None:
    client = Client()
    _signup(client, "Xq7-mnbvcz")
    attacker = [_login_from(client, "guess-guess-1", "203.0.113.9") for _ in range(6)]

    assert attacker == [401] * 5 + [429]
    assert _login_from(client, "Xq7-mnbvcz", "198.51.100.7") == 200


def test_the_owner_who_just_signed_in_clears_their_own_failures(db: None) -> None:
    client = Client()
    _signup(client, "Xq7-mnbvcz")
    for _ in range(4):
        _login_from(client, "typo-typo-typo", "10.0.0.1")

    assert _login_from(client, "Xq7-mnbvcz", "10.0.0.1") == 200
    assert [_login_from(client, "typo-typo-typo", "10.0.0.1") for _ in range(5)] == [401] * 5


def test_guessing_from_many_addresses_hits_an_account_wide_ceiling(db: None) -> None:
    client = Client()
    _signup(client, "Xq7-mnbvcz")
    for n in range(20):
        _login_from(client, "guess-guess-1", f"192.0.2.{n + 1}")

    assert _login_from(client, "Xq7-mnbvcz", "198.51.100.200") == 429
