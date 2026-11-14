"""OpenID Connect, the parts a workspace's identity provider needs.

Discovery from the issuer, the authorization URL (state, nonce, PKCE S256), the code exchange,
and ID-token validation: signature through the provider's JWKS, ``iss``, ``aud``, ``exp``,
``iat``, ``sub`` and ``nonce``. Asymmetric algorithms only (``none`` and HMAC are refused).
"""

import base64
import hashlib
import ipaddress
import json
import secrets
import socket
from dataclasses import dataclass
from typing import Any
from urllib.parse import urlencode, urlparse

import httpx
import jwt
from django.conf import settings
from django.core.cache import cache

from infrastructure.oauth.core.tokens import hash_token

ALGORITHMS = ["RS256", "RS384", "RS512", "ES256", "ES384", "PS256", "PS384", "PS512"]
_DISCOVERY_SECONDS = 600


class OidcError(RuntimeError):
    """The provider, or what it sent, is not acceptable. The message is safe to show an admin."""


@dataclass(frozen=True, slots=True)
class Discovery:
    issuer: str
    authorization_endpoint: str
    token_endpoint: str
    jwks_uri: str


MAX_RESPONSE_BYTES = 256 * 1024
_JWKS_SECONDS = 300


def _loopback(host: str) -> bool:
    if host == "localhost" or host.endswith(".localhost"):
        return True
    try:
        return ipaddress.ip_address(host).is_loopback
    except ValueError:
        return False


def _forbidden_address(address: ipaddress.IPv4Address | ipaddress.IPv6Address) -> bool:
    """Private, loopback, link-local (cloud metadata), reserved, multicast or unspecified."""
    if isinstance(address, ipaddress.IPv6Address) and address.ipv4_mapped:
        address = address.ipv4_mapped
    return (
        address.is_private
        or address.is_loopback
        or address.is_link_local
        or address.is_reserved
        or address.is_multicast
        or address.is_unspecified
    )


def require_safe_url(url: str, what: str) -> None:
    """https to a public address; plain http only to localhost, and only when DEBUG is on."""
    parsed = urlparse(url)
    host = parsed.hostname
    if not host or parsed.username or parsed.password:
        raise OidcError(f"The {what} must be an https address.")
    if _loopback(host):
        if parsed.scheme == "http" and settings.DEBUG:
            return
        raise OidcError(f"The {what} must be a public https address.")
    if parsed.scheme != "https":
        raise OidcError(f"The {what} must be an https address.")
    try:
        literal = ipaddress.ip_address(host)
    except ValueError:
        return
    if _forbidden_address(literal):
        raise OidcError(f"The {what} must be a public address.")


def _resolves_publicly(host: str) -> bool:
    """False when any address the name points at is internal (blocks name-based SSRF)."""
    try:
        infos = socket.getaddrinfo(host, None, type=socket.SOCK_STREAM)
    except OSError:
        return False
    return all(_forbidden_address(ipaddress.ip_address(info[4][0])) is False for info in infos)


def _get_json(url: str) -> dict[str, Any]:
    """GET a JSON object: timeout, no redirects, and a cap on how much is read."""
    require_safe_url(url, "identity provider address")
    host = urlparse(url).hostname or ""
    if not _loopback(host) and not _resolves_publicly(host):
        raise OidcError("The identity provider address is not reachable publicly.")
    try:
        with (
            httpx.Client(
                timeout=settings.OAUTH_HTTP_TIMEOUT_SECONDS, follow_redirects=False
            ) as client,
            client.stream("GET", url, headers={"Accept": "application/json"}) as response,
        ):
            response.raise_for_status()
            chunks: list[bytes] = []
            size = 0
            for chunk in response.iter_bytes():
                size += len(chunk)
                if size > MAX_RESPONSE_BYTES:
                    raise OidcError("The identity provider's answer is too large.")
                chunks.append(chunk)
        body = json.loads(b"".join(chunks))
    except (httpx.HTTPError, ValueError) as error:
        raise OidcError("The identity provider could not be reached.") from error
    if not isinstance(body, dict):
        raise OidcError("The identity provider sent an unexpected answer.")
    return body


def discover(issuer: str, *, fresh: bool = False) -> Discovery:
    """Read ``/.well-known/openid-configuration`` and check it names the issuer asked for."""
    require_safe_url(issuer, "issuer")
    key = f"security:oidc:{hash_token(issuer)}"
    cached = None if fresh else cache.get(key)
    if cached is not None:
        return Discovery(**cached)
    document = _get_json(f"{issuer.rstrip('/')}/.well-known/openid-configuration")
    if str(document.get("issuer", "")).rstrip("/") != issuer.rstrip("/"):
        raise OidcError("The provider's issuer does not match the address given.")
    fields = {
        name: str(document.get(name, ""))
        for name in ("authorization_endpoint", "token_endpoint", "jwks_uri")
    }
    missing = [name for name, value in fields.items() if not value]
    if missing:
        raise OidcError(f"The provider's configuration lacks {', '.join(missing)}.")
    for name, value in fields.items():
        require_safe_url(value, name.replace("_", " "))
    result = Discovery(issuer=issuer.rstrip("/"), **fields)
    cache.set(
        key,
        {
            "issuer": result.issuer,
            "authorization_endpoint": result.authorization_endpoint,
            "token_endpoint": result.token_endpoint,
            "jwks_uri": result.jwks_uri,
        },
        _DISCOVERY_SECONDS,
    )
    return result


def pkce_challenge(verifier: str) -> str:
    digest = hashlib.sha256(verifier.encode()).digest()
    return base64.urlsafe_b64encode(digest).rstrip(b"=").decode()


def new_secrets() -> tuple[str, str, str]:
    """A fresh ``(state, nonce, code_verifier)``."""
    return secrets.token_urlsafe(48), secrets.token_urlsafe(48), secrets.token_urlsafe(64)


def authorization_url(
    discovery: Discovery,
    *,
    client_id: str,
    scopes: str,
    redirect_uri: str,
    state: str,
    nonce: str,
    verifier: str,
) -> str:
    scope = " ".join(dict.fromkeys(["openid", *scopes.split()]))
    query = urlencode(
        {
            "client_id": client_id,
            "response_type": "code",
            "redirect_uri": redirect_uri,
            "scope": scope,
            "state": state,
            "nonce": nonce,
            "code_challenge": pkce_challenge(verifier),
            "code_challenge_method": "S256",
        }
    )
    return f"{discovery.authorization_endpoint}?{query}"


def exchange_code(
    discovery: Discovery,
    *,
    client_id: str,
    client_secret: str,
    code: str,
    redirect_uri: str,
    verifier: str,
) -> str:
    """Trade the code for tokens and return the ID token."""
    payload = {
        "grant_type": "authorization_code",
        "client_id": client_id,
        "code": code,
        "redirect_uri": redirect_uri,
        "code_verifier": verifier,
    }
    if client_secret:
        payload["client_secret"] = client_secret
    try:
        response = httpx.post(
            discovery.token_endpoint,
            data=payload,
            headers={"Accept": "application/json"},
            timeout=settings.OAUTH_HTTP_TIMEOUT_SECONDS,
        )
        response.raise_for_status()
        body = response.json()
    except (httpx.HTTPError, ValueError) as error:
        raise OidcError("The identity provider refused the sign-in code.") from error
    id_token = str(body.get("id_token", "")) if isinstance(body, dict) else ""
    if not id_token:
        raise OidcError("The identity provider did not return an ID token.")
    return id_token


def _signing_key(discovery: Discovery, id_token: str) -> Any:
    """The JWKS key the token names, fetched safely; refetched once when the kid is new."""
    header = jwt.get_unverified_header(id_token)
    algorithm = header.get("alg")
    if algorithm not in ALGORITHMS:
        raise OidcError("The ID token is not valid.")
    kid = header.get("kid")
    cache_key = f"security:jwks:{hash_token(discovery.jwks_uri)}"
    for fresh in (False, True):
        document = None if fresh else cache.get(cache_key)
        if document is None:
            document = _get_json(discovery.jwks_uri)
            cache.set(cache_key, document, _JWKS_SECONDS)
        for entry in document.get("keys", []):
            if isinstance(entry, dict) and (kid is None or entry.get("kid") == kid):
                try:
                    return jwt.PyJWK.from_dict(entry).key
                except jwt.PyJWTError:
                    continue
    raise OidcError("The ID token is not valid.")


def validate_id_token(
    discovery: Discovery, *, id_token: str, client_id: str, nonce_hash: str
) -> dict[str, Any]:
    """Verify signature, issuer, audience, expiry and nonce; return the claims."""
    try:
        claims = jwt.decode(
            id_token,
            _signing_key(discovery, id_token),
            algorithms=ALGORITHMS,
            audience=client_id,
            issuer=[discovery.issuer, f"{discovery.issuer}/"],
            leeway=settings.OAUTH_CLOCK_SKEW_SECONDS,
            options={"require": ["iss", "sub", "aud", "exp", "iat"]},
        )
    except jwt.PyJWTError as error:
        raise OidcError("The ID token is not valid.") from error
    nonce = str(claims.get("nonce", ""))
    if not nonce or not secrets.compare_digest(hash_token(nonce), nonce_hash):
        raise OidcError("The ID token's nonce does not match this sign-in.")
    audience = claims.get("aud")
    if isinstance(audience, list) and len(audience) > 1 and claims.get("azp") != client_id:
        raise OidcError("The ID token was issued to another client.")
    return dict(claims)
