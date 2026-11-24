"""DPoP verification matrix. Tests run with the mode ``required`` (the suite default is ``off``)."""

import base64
import json
import time
import uuid
from types import SimpleNamespace
from typing import Any

import jwt
import pytest
from cryptography.hazmat.primitives.asymmetric import ec
from django.test import override_settings

from infrastructure.auth.core import dpop
from infrastructure.auth.core.dpop import DpopError, Reason

METHOD, URL = "POST", "https://api.example.test/api/v1/things"


@pytest.fixture(autouse=True)
def _required_mode(settings: Any) -> None:
    settings.DPOP_MODE = "required"
    settings.DPOP_NONCE_ENABLED = False


class Key:
    def __init__(self) -> None:
        self.private = ec.generate_private_key(ec.SECP256R1())
        numbers = self.private.public_key().public_numbers()

        def enc(n: int) -> str:
            return base64.urlsafe_b64encode(n.to_bytes(32, "big")).rstrip(b"=").decode()

        self.jwk = {"kty": "EC", "crv": "P-256", "x": enc(numbers.x), "y": enc(numbers.y)}
        self.jkt = dpop.thumbprint(self.jwk)

    def proof(self, *, headers: dict[str, Any] | None = None, **claims: Any) -> str:
        body: dict[str, Any] = {
            "jti": uuid.uuid4().hex,
            "htm": METHOD,
            "htu": URL,
            "iat": int(time.time()),
            **claims,
        }
        body = {k: v for k, v in body.items() if v is not None}
        head = {"typ": "dpop+jwt", "jwk": self.jwk, **(headers or {})}
        return jwt.encode(body, self.private, algorithm="ES256", headers=head)


def verify(proof: str, **kw: Any) -> dpop.VerifiedProof:
    return dpop.verify_proof(proof, method=METHOD, url=URL, **kw)


def reason_of(proof: str, **kw: Any) -> Reason:
    with pytest.raises(DpopError) as caught:
        verify(proof, **kw)
    return caught.value.reason


def test_valid_proof_yields_the_thumbprint() -> None:
    key = Key()
    assert verify(key.proof()).jkt == key.jkt


def test_query_string_is_ignored_in_htu() -> None:
    assert verify(Key().proof(htu=URL + "?a=1#frag"))


@pytest.mark.parametrize(
    ("claims", "expected"),
    [
        ({"htm": "GET"}, Reason.METHOD_MISMATCH),
        ({"htu": "https://evil.test/api/v1/things"}, Reason.URL_MISMATCH),
        ({"iat": 1}, Reason.IAT_STALE),
        ({"iat": 4_000_000_000}, Reason.IAT_FUTURE),  # year 2096: not relative to collection time,
        ({"iat": "now"}, Reason.BAD_CLAIM),
        ({"jti": ""}, Reason.BAD_CLAIM),
        ({"jti": "x" * 500}, Reason.BAD_CLAIM),
        ({"htm": 5}, Reason.BAD_CLAIM),
        ({"jti": None}, Reason.MISSING_CLAIM),
        ({"htu": None}, Reason.MISSING_CLAIM),
        ({"iat": None}, Reason.MISSING_CLAIM),
    ],
)
def test_each_wrong_claim_is_refused(claims: dict[str, Any], expected: Reason) -> None:
    assert reason_of(Key().proof(**claims)) == expected


def test_header_failures() -> None:
    key = Key()
    assert reason_of("") == Reason.PROOF_MISSING
    assert reason_of("not.a.jwt") == Reason.PROOF_MALFORMED
    assert reason_of(key.proof(headers={"typ": "JWT"})) == Reason.BAD_TYP
    assert reason_of(key.proof(headers={"jwk": {**key.jwk, "d": "x"}})) == Reason.PRIVATE_JWK
    assert reason_of(key.proof(headers={"jwk": {**key.jwk, "kty": "RSA"}})) == Reason.BAD_JWK
    assert reason_of(key.proof(headers={"jwk": None})) == Reason.BAD_JWK
    assert reason_of("a" * 5000) == Reason.PROOF_TOO_LARGE


def test_none_and_hs256_algorithms_are_refused() -> None:
    body = {"jti": "1", "htm": METHOD, "htu": URL, "iat": int(time.time())}
    hs = jwt.encode(body, "k" * 40, algorithm="HS256", headers={"typ": "dpop+jwt"})
    assert reason_of(hs) == Reason.BAD_ALG
    raw = ".".join(
        base64.urlsafe_b64encode(json.dumps(part).encode()).rstrip(b"=").decode()
        for part in ({"alg": "none", "typ": "dpop+jwt"}, body)
    )
    assert reason_of(raw + ".") in {Reason.BAD_ALG, Reason.PROOF_MALFORMED}


def test_signature_by_another_key_is_refused() -> None:
    claimed, signer = Key(), Key()
    head = {"typ": "dpop+jwt", "jwk": claimed.jwk}
    body = {"jti": "1", "htm": METHOD, "htu": URL, "iat": int(time.time())}
    proof = jwt.encode(body, signer.private, algorithm="ES256", headers=head)
    assert reason_of(proof) == Reason.BAD_SIGNATURE


def test_replay_is_refused_the_second_time() -> None:
    proof = Key().proof()
    verify(proof)
    assert reason_of(proof) == Reason.REPLAY


def test_ath_must_match_the_access_token() -> None:
    key = Key()
    ok = key.proof(ath=dpop.access_token_hash("tok"))
    assert verify(ok, access_token="tok", require_ath=True)
    assert reason_of(key.proof(), access_token="tok", require_ath=True) == Reason.ATH_MISSING
    wrong = key.proof(ath=dpop.access_token_hash("other"))
    assert reason_of(wrong, access_token="tok", require_ath=True) == Reason.ATH_MISMATCH


@override_settings(DPOP_NONCE_ENABLED=True)
def test_nonce_missing_and_stale_and_valid() -> None:
    key = Key()
    assert reason_of(key.proof()) == Reason.NONCE_MISSING
    assert reason_of(key.proof(nonce="stale")) == Reason.NONCE_STALE
    assert verify(key.proof(nonce=dpop.current_nonce()))


def _request(proof: str = "", auth_scheme: str = "DPoP") -> Any:
    meta = {"HTTP_AUTHORIZATION": f"{auth_scheme} tok"}
    if proof:
        meta["HTTP_DPOP"] = proof
    return SimpleNamespace(META=meta, path="/api/v1/things", method=METHOD)


def test_unbound_session_refused_in_required_mode() -> None:
    with pytest.raises(DpopError) as caught:
        dpop.authorize(_request(), "tok", bound_jkt="", session_id="s")
    assert caught.value.reason == Reason.UNBOUND_SESSION


def test_bound_token_cannot_be_used_as_bearer() -> None:
    with pytest.raises(DpopError) as caught:
        dpop.authorize(_request(auth_scheme="Bearer"), "tok", bound_jkt="abc", session_id="s")
    assert caught.value.reason == Reason.BEARER_NOT_ALLOWED


def test_refresh_requires_the_bound_key() -> None:
    with pytest.raises(DpopError) as caught:
        dpop.verify_refresh(_request(), "")
    assert caught.value.reason == Reason.UNBOUND_SESSION
    with override_settings(DPOP_MODE="off"):
        dpop.verify_refresh(_request(), "whatever")


def test_mode_off_skips_everything() -> None:
    with override_settings(DPOP_MODE="off"):
        dpop.authorize(_request(), "tok", bound_jkt="abc", session_id="s")
        assert dpop.signin_binding(_request()) == ""
