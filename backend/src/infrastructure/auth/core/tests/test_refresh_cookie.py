"""Web clients keep the refresh token in an HttpOnly cookie, out of reach of page script.

Opt-in per request with ``X-Refresh-Transport: cookie``; everything else (mobile,
desktop, curl) keeps getting the token in the JSON body exactly as before.
"""

from typing import Any

from django.test import Client

SIGNUP = "/api/v1/auth/password/signup"
LOGIN = "/api/v1/auth/password/login"
REFRESH = "/api/v1/auth/token/refresh"
LOGOUT = "/api/v1/auth/password/logout"
COOKIE = "tf_refresh"
WEB = {"HTTP_X_REFRESH_TRANSPORT": "cookie"}
PASSWORD = "Xq7-mnbvcz"


def _post(client: Client, path: str, body: dict[str, Any], **extra: Any) -> Any:
    return client.post(path, body, content_type="application/json", **extra)


def _signup(client: Client, **extra: Any) -> Any:
    return _post(
        client,
        SIGNUP,
        {"identifier": "zoe@example.com", "email": "zoe@example.com", "password": PASSWORD},
        **extra,
    )


def test_a_web_sign_up_puts_the_refresh_token_in_an_httponly_cookie(db: None) -> None:
    client = Client()

    response = _signup(client, **WEB)

    credentials = response.json()["data"]["credentials"]
    assert credentials["refresh_token"] == ""
    assert credentials["access_token"] != ""
    cookie = response.cookies[COOKIE]
    assert cookie.value != ""
    assert cookie["httponly"] is True
    assert cookie["samesite"] == "Strict"
    assert cookie["path"] == "/api/v1/auth/"


def test_without_the_header_the_refresh_token_stays_in_the_body(db: None) -> None:
    response = _signup(Client())

    assert response.json()["data"]["credentials"]["refresh_token"] != ""
    assert COOKIE not in response.cookies


def test_a_web_refresh_reads_the_cookie_and_rotates_it(db: None) -> None:
    client = Client()
    first = _signup(client, **WEB).cookies[COOKIE].value

    response = _post(client, REFRESH, {"refresh_token": ""}, **WEB)

    assert response.status_code == 200, response.content
    assert response.json()["data"]["refresh_token"] == ""
    assert response.cookies[COOKIE].value not in ("", first)


def test_the_cookie_is_ignored_without_the_opt_in_header(db: None) -> None:
    """A cross-site form cannot set a custom header, so it cannot spend the cookie."""
    client = Client()
    _signup(client, **WEB)

    response = _post(client, REFRESH, {"refresh_token": ""})

    assert response.status_code == 400
    assert response.json()["title"] == "TOKEN_REQUIRED"


def test_a_token_in_the_body_wins_over_the_cookie(db: None) -> None:
    client = Client()
    credentials = _signup(Client()).json()["data"]["credentials"]  # a mobile-style session
    _signup_cookie_owner = Client()
    _post(
        _signup_cookie_owner,
        SIGNUP,
        {"identifier": "ann@example.com", "email": "ann@example.com", "password": PASSWORD},
        **WEB,
    )
    client.cookies = _signup_cookie_owner.cookies  # a cookie belonging to a different account

    response = _post(client, REFRESH, {"refresh_token": credentials["refresh_token"]}, **WEB)

    assert response.status_code == 200
    assert response.json()["data"]["session_id"] == credentials["session_id"]


def test_a_web_sign_out_clears_the_cookie_and_ends_the_session(db: None) -> None:
    client = Client()
    _signup(client, **WEB)

    response = _post(client, LOGOUT, {"token": ""}, **WEB)

    assert response.status_code == 200
    assert response.cookies[COOKIE]["max-age"] == 0
    assert _post(client, REFRESH, {"refresh_token": ""}, **WEB).status_code in (400, 401)


def test_a_web_login_after_sign_up_also_uses_the_cookie(db: None) -> None:
    client = Client()
    _signup(Client())

    response = _post(client, LOGIN, {"identifier": "zoe@example.com", "password": PASSWORD}, **WEB)

    assert response.json()["data"]["credentials"]["refresh_token"] == ""
    assert response.cookies[COOKIE].value != ""
