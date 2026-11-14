"""OIDC: URL safety, the guarded fetch, and the ID-token validation matrix."""

from typing import Any

import httpx
import jwt
import pytest
from django.core.cache import cache
from django.test import override_settings

from infrastructure.security import oidc
from infrastructure.security.tests.idp_fixtures import (
    CLIENT_ID,
    DISCOVERY,
    claims,
    new_key,
    nonce_hash,
    sign,
)

# --- require_safe_url ----------------------------------------------------------------------


@pytest.mark.parametrize(
    "url",
    [
        "http://idp.example.com",
        "ftp://idp.example.com",
        "https://127.0.0.1/",
        "https://10.0.0.5/",
        "https://192.168.1.1/",
        "https://172.16.0.9/",
        "https://169.254.169.254/latest/meta-data",
        "https://[::1]/",
        "https://[fe80::1]/",
        "https://[::ffff:169.254.169.254]/",
        "https://0.0.0.0/",
        "https://localhost/",
        "http://localhost:8080/realms/x",
        "http://127.0.0.1:8080/",
        "https://user:pw@idp.example.com/",
        "https:///nohost",
    ],
)
def test_unsafe_urls_are_refused(url: str) -> None:
    with pytest.raises(oidc.OidcError):
        oidc.require_safe_url(url, "issuer")


def test_public_https_is_accepted() -> None:
    oidc.require_safe_url("https://login.example.com/realms/x", "issuer")
    oidc.require_safe_url("https://8.8.8.8/", "issuer")


@override_settings(DEBUG=True)
def test_plain_http_localhost_is_allowed_only_in_debug() -> None:
    oidc.require_safe_url("http://localhost:8080/realms/x", "issuer")
    oidc.require_safe_url("http://127.0.0.1:8080/realms/x", "issuer")
    with pytest.raises(oidc.OidcError):
        oidc.require_safe_url("http://169.254.169.254/", "issuer")
    with pytest.raises(oidc.OidcError):
        oidc.require_safe_url("http://idp.example.com/", "issuer")


# --- the guarded fetch ---------------------------------------------------------------------


def _serve(handler: Any, monkeypatch: pytest.MonkeyPatch) -> None:
    real = httpx.Client

    def factory(**kwargs: Any) -> httpx.Client:
        assert kwargs["follow_redirects"] is False
        assert kwargs["timeout"]
        return real(transport=httpx.MockTransport(handler), **kwargs)

    monkeypatch.setattr(oidc.httpx, "Client", factory)
    monkeypatch.setattr(oidc, "_resolves_publicly", lambda host: True)


def test_fetch_returns_json_through_a_client_with_timeout_and_no_redirects(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    _serve(lambda request: httpx.Response(200, json={"keys": []}), monkeypatch)
    assert oidc._get_json("https://idp.test/jwks") == {"keys": []}


def test_a_redirect_is_not_followed(monkeypatch: pytest.MonkeyPatch) -> None:
    seen: list[str] = []

    def handler(request: httpx.Request) -> httpx.Response:
        seen.append(str(request.url))
        return httpx.Response(302, headers={"location": "http://169.254.169.254/"})

    _serve(handler, monkeypatch)
    with pytest.raises(oidc.OidcError):
        oidc._get_json("https://idp.test/jwks")
    assert seen == ["https://idp.test/jwks"]


def test_an_oversized_response_is_refused(monkeypatch: pytest.MonkeyPatch) -> None:
    big = b'{"keys": "' + b"a" * (oidc.MAX_RESPONSE_BYTES + 10) + b'"}'
    _serve(lambda request: httpx.Response(200, content=big), monkeypatch)
    with pytest.raises(oidc.OidcError, match="too large"):
        oidc._get_json("https://idp.test/jwks")


def test_a_non_object_answer_is_refused(monkeypatch: pytest.MonkeyPatch) -> None:
    _serve(lambda request: httpx.Response(200, json=[1, 2]), monkeypatch)
    with pytest.raises(oidc.OidcError):
        oidc._get_json("https://idp.test/jwks")


def test_a_name_that_resolves_to_an_internal_address_is_refused(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    monkeypatch.setattr(
        oidc.socket, "getaddrinfo", lambda *a, **k: [(2, 1, 6, "", ("10.1.2.3", 0))]
    )
    with pytest.raises(oidc.OidcError, match="publicly"):
        oidc._get_json("https://evil.example.com/jwks")


def test_a_literal_metadata_ip_is_refused_before_any_request() -> None:
    with pytest.raises(oidc.OidcError):
        oidc._get_json("https://169.254.169.254/latest")


# --- validate_id_token ---------------------------------------------------------------------


def validate(token: str, nonce: str = "nonce-value") -> dict[str, Any]:
    return oidc.validate_id_token(
        DISCOVERY, id_token=token, client_id=CLIENT_ID, nonce_hash=nonce_hash(nonce)
    )


def test_a_good_token_yields_its_claims(idp: Any) -> None:
    assert validate(sign(idp, claims()))["sub"] == "sub-1"


@pytest.mark.parametrize(
    "overrides",
    [
        {"iss": "https://evil.test"},
        {"aud": "someone-else"},
        {"nonce": "another-nonce"},
        {"nonce": None},
        {"exp": 1_000},
        {"sub": None},
        {"iat": None},
    ],
    ids=["iss", "aud", "nonce", "no-nonce", "expired", "no-sub", "no-iat"],
)
def test_bad_claims_are_refused(idp: Any, overrides: dict[str, Any]) -> None:
    with pytest.raises(oidc.OidcError):
        validate(sign(idp, claims(**overrides)))


def test_a_token_signed_by_another_key_is_refused(idp: Any) -> None:
    with pytest.raises(oidc.OidcError):
        validate(sign(new_key(), claims()))


def test_an_unknown_kid_is_refused(idp: Any) -> None:
    with pytest.raises(oidc.OidcError):
        validate(sign(idp, claims(), kid="rotated-away"))


def test_alg_none_is_refused(idp: Any) -> None:
    token = jwt.encode(claims(), None, algorithm="none", headers={"kid": "key-1"})
    with pytest.raises(oidc.OidcError):
        validate(token)


def test_hs256_is_refused(idp: Any) -> None:
    secret = "shared-secret-" * 4  # PyJWT refuses a key as secret; an attacker would hand-roll
    token = jwt.encode(claims(), secret, algorithm="HS256", headers={"kid": "key-1"})
    with pytest.raises(oidc.OidcError):
        validate(token)


def test_garbage_is_refused(idp: Any) -> None:
    with pytest.raises(oidc.OidcError):
        validate("not.a.jwt")


def test_a_token_for_two_audiences_needs_a_matching_azp(idp: Any) -> None:
    with pytest.raises(oidc.OidcError, match="another client"):
        validate(sign(idp, claims(aud=[CLIENT_ID, "other"], azp="other")))
    assert validate(sign(idp, claims(aud=[CLIENT_ID, "other"], azp=CLIENT_ID)))


def test_missing_email_verified_is_left_to_the_account_rules_to_refuse(idp: Any) -> None:
    # Validation does not judge the email; sso.resolve_user refuses an unconfirmed one.
    assert "email_verified" not in validate(sign(idp, claims(email_verified=None)))


def test_a_jwks_outage_is_a_refusal_not_a_crash(monkeypatch: pytest.MonkeyPatch, idp: Any) -> None:
    def down(url: str) -> Any:
        raise oidc.OidcError("The identity provider could not be reached.")

    monkeypatch.setattr(oidc, "_get_json", down)
    cache.clear()
    with pytest.raises(oidc.OidcError):
        validate(sign(idp, claims()))
