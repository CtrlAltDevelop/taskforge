"""A mocked identity provider: a locally generated RSA key, its JWKS and a token minter."""

import json
import time
from typing import Any

import jwt
import pytest
from cryptography.hazmat.primitives.asymmetric import rsa
from django.core.cache import cache
from jwt.algorithms import RSAAlgorithm

from infrastructure.oauth.core.tokens import hash_token
from infrastructure.security import oidc

ISSUER = "https://idp.test"
CLIENT_ID = "cid"
NONCE = "nonce-value"
KID = "key-1"

DISCOVERY = oidc.Discovery(
    issuer=ISSUER,
    authorization_endpoint=f"{ISSUER}/auth",
    token_endpoint=f"{ISSUER}/token",
    jwks_uri=f"{ISSUER}/jwks",
)


def new_key() -> rsa.RSAPrivateKey:
    return rsa.generate_private_key(public_exponent=65537, key_size=2048)


def jwks_for(key: rsa.RSAPrivateKey, kid: str = KID) -> dict[str, Any]:
    entry = json.loads(RSAAlgorithm.to_jwk(key.public_key()))
    return {"keys": [{**entry, "kid": kid, "use": "sig", "alg": "RS256"}]}


def claims(**overrides: Any) -> dict[str, Any]:
    now = int(time.time())
    base: dict[str, Any] = {
        "iss": ISSUER,
        "aud": CLIENT_ID,
        "sub": "sub-1",
        "iat": now,
        "exp": now + 300,
        "nonce": NONCE,
        "email": "new@acme.test",
        "email_verified": "true",
    }
    base.update(overrides)
    return {k: v for k, v in base.items() if v is not None}


def sign(key: rsa.RSAPrivateKey, payload: dict[str, Any], *, kid: str = KID) -> str:
    return jwt.encode(payload, key, algorithm="RS256", headers={"kid": kid})


def nonce_hash(nonce: str = NONCE) -> str:
    return hash_token(nonce)


@pytest.fixture(scope="session")
def idp_key() -> rsa.RSAPrivateKey:
    return new_key()


@pytest.fixture
def idp(monkeypatch: pytest.MonkeyPatch, idp_key: rsa.RSAPrivateKey) -> rsa.RSAPrivateKey:
    """The provider answers JWKS requests with ``idp_key``'s public half and discovery works."""
    cache.clear()
    jwks = jwks_for(idp_key)
    monkeypatch.setattr(oidc, "_get_json", lambda url: jwks)
    monkeypatch.setattr(oidc, "discover", lambda issuer, fresh=False: DISCOVERY)
    return idp_key
