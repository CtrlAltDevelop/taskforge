"""DPoP (RFC 9449): proof that a request comes from the key its session was bound to.

One verifier for every transport, so REST, gRPC and the WebSocket cannot drift apart: the Ninja
auth class, the gRPC caller and the socket's ``authenticate`` message all end in
:func:`authorize` through ``sessions.resolve_request_user``. What each transport adds is only how it
reaches the three facts a proof is about: the method, the URL (always the configured public origin
plus the path, never ``Host``) and the proof itself.

* ``off`` ignores proofs and binds nothing. ``optional`` accepts a plain bearer from a session that
  was never bound (logged once per session); a *bound* token always needs its proof.
  ``required`` rejects every bearer that is not backed by a proof from the session's key.
* A proof is ES256 only, carries its public key in the header and is signed over ``htm``, ``htu``,
  ``iat``, a unique ``jti`` and, on resource calls, ``ath`` (the SHA-256 of the exact access token).
  It is checked with PyJWT; nothing here parses or verifies a signature by hand.
* ``cnf.jkt`` in the access token and ``dpop_jkt`` on the session row name the bound key (RFC 7638
  thumbprint). Sign-in, sign-up, MFA verify and refresh accept a proof without ``ath`` and bind or
  check the session.
* Every rejection has its own :class:`Reason`, logged with only the thumbprint prefix and ``jti``.
  The proof itself is never logged and never travels in a URL.
"""

import base64
import contextlib
import hashlib
import hmac
import json
import logging
import time
from collections.abc import Callable
from dataclasses import dataclass
from enum import StrEnum
from typing import Any, Final

import jwt
from django.conf import settings
from django.core.cache import cache
from django.http import HttpRequest, HttpResponse
from django.utils.http import http_date

from infrastructure.common.errors import ApiError
from infrastructure.common.public_routes import is_public_api_path
from infrastructure.common.responses import ResponseTitle

logger = logging.getLogger(__name__)

OFF: Final = "off"
OPTIONAL: Final = "optional"
REQUIRED: Final = "required"

ALGORITHM: Final = "ES256"
PROOF_TYPE: Final = "dpop+jwt"
SCHEME: Final = "dpop"
HEADER_META: Final = "HTTP_DPOP"
GRPC_META: Final = "dpop"
# Where a transport that has no Django request of its own says what the proof is about.
METHOD_META: Final = "TF_DPOP_HTM"
URL_META: Final = "TF_DPOP_HTU"
# Set by a socket for re-checks of a connection whose proof it already verified (a proof is
# single-use). Uppercase, so no header or gRPC metadata key (always lowercase) can forge it.
VERIFIED_META: Final = "TF_DPOP_VERIFIED"
NONCE_HEADER: Final = "DPoP-Nonce"

ERROR_PROOF: Final = "invalid_dpop_proof"
ERROR_TOKEN: Final = "invalid_token"
ERROR_NONCE: Final = "use_dpop_nonce"

_PRIVATE_JWK_MEMBERS: Final = frozenset({"d", "p", "q", "dp", "dq", "qi", "oth", "k"})
_MAX_PROOF_BYTES: Final = 4096
_MAX_JTI: Final = 128
_REPLAY_PREFIX: Final = "dpop:"
_FAILURE_SCOPE: Final = "dpop:key"
_PROOF_ATTR: Final = "_tf_dpop_proof"


class Reason(StrEnum):
    """Why a proof or a binding was refused: the internal, loggable half of the answer."""

    PROOF_MISSING = "proof_missing"
    PROOF_MALFORMED = "proof_malformed"
    PROOF_TOO_LARGE = "proof_too_large"
    BAD_TYP = "bad_typ"
    BAD_ALG = "bad_alg"
    BAD_JWK = "bad_jwk"
    PRIVATE_JWK = "private_jwk"
    BAD_SIGNATURE = "bad_signature"
    MISSING_CLAIM = "missing_claim"
    BAD_CLAIM = "bad_claim"
    METHOD_MISMATCH = "method_mismatch"
    URL_MISMATCH = "url_mismatch"
    IAT_STALE = "iat_stale"
    IAT_FUTURE = "iat_future"
    REPLAY = "replay"
    ATH_MISSING = "ath_missing"
    ATH_MISMATCH = "ath_mismatch"
    NONCE_MISSING = "nonce_missing"
    NONCE_STALE = "nonce_stale"
    KEY_MISMATCH = "key_mismatch"
    UNBOUND_SESSION = "unbound_session"
    BEARER_NOT_ALLOWED = "bearer_not_allowed"


class DpopError(ApiError):
    """A refusal that carries the RFC 9449 error, the reason, and what a client needs to retry."""

    def __init__(
        self,
        reason: Reason,
        message: str,
        *,
        error: str = ERROR_PROOF,
        nonce: str = "",
        clock: bool = False,
        status: int = 401,
    ) -> None:
        data: dict[str, Any] = {"error": error, "reason": reason.value}
        if nonce:
            data["nonce"] = nonce
        if clock:
            data["clock"] = int(time.time())
        super().__init__(message, status, title=ResponseTitle.TOKEN_INVALID, data=data)
        self.reason = reason
        self.error = error
        self.nonce = nonce
        self.clock = clock

    def challenge(self) -> str:
        """The ``WWW-Authenticate`` value (RFC 9449 section 7.1)."""
        description = str(self).replace('"', "'")
        return f'DPoP error="{self.error}", error_description="{description}", algs="{ALGORITHM}"'

    def apply_headers(self, response: HttpResponse) -> None:
        response["WWW-Authenticate"] = self.challenge()
        # The client adjusts its clock offset from this and retries once (stale or future iat).
        response["Date"] = http_date()
        if self.nonce:
            response[NONCE_HEADER] = self.nonce


@dataclass(frozen=True, slots=True)
class VerifiedProof:
    jkt: str
    jti: str
    claims: dict[str, Any]


# --- Configuration ---------------------------------------------------------------------------


def mode() -> str:
    return str(settings.DPOP_MODE)


def enabled() -> bool:
    return mode() != OFF


def nonce_enabled() -> bool:
    return bool(settings.DPOP_NONCE_ENABLED) and enabled()


def public_origin() -> str:
    return str(settings.DPOP_PUBLIC_ORIGIN).rstrip("/")


def socket_url(path: str) -> str:
    """The URL a client signs for a WebSocket: the public origin with a ``ws``/``wss`` scheme."""
    origin = public_origin()
    scheme, _, rest = origin.partition("://")
    return f"{'wss' if scheme == 'https' else 'ws'}://{rest}{path}"


# --- Server nonce ----------------------------------------------------------------------------


def _nonce_for(window: int) -> str:
    secret = str(settings.DPOP_NONCE_SECRET).encode()
    digest = hmac.new(secret, f"dpop-nonce:{window}".encode(), hashlib.sha256).digest()
    return _b64(digest)[:32]


def _nonce_window(now: float | None = None) -> int:
    return int((time.time() if now is None else now) // settings.DPOP_NONCE_ROTATION_SECONDS)


def current_nonce() -> str:
    """The nonce to hand out now: derived from a secret and the time window, so every worker
    agrees without shared state and the current and previous window are both accepted."""
    return _nonce_for(_nonce_window()) if nonce_enabled() else ""


def _nonce_valid(nonce: str) -> bool:
    window = _nonce_window()
    return any(hmac.compare_digest(nonce, _nonce_for(w)) for w in (window, window - 1))


class DpopNonceMiddleware:
    """Hands every response the current nonce, so a client always holds a usable one."""

    def __init__(self, get_response: Callable[[HttpRequest], HttpResponse]) -> None:
        self.get_response = get_response

    def __call__(self, request: HttpRequest) -> HttpResponse:
        response = self.get_response(request)
        if nonce_enabled() and NONCE_HEADER not in response:
            response[NONCE_HEADER] = current_nonce()
        return response


# --- Encoding helpers ------------------------------------------------------------------------


def _b64(data: bytes) -> str:
    return base64.urlsafe_b64encode(data).rstrip(b"=").decode()


def thumbprint(jwk: dict[str, Any]) -> str:
    """RFC 7638 thumbprint of an EC public JWK (base64url SHA-256)."""
    canonical = json.dumps(
        {"crv": jwk["crv"], "kty": jwk["kty"], "x": jwk["x"], "y": jwk["y"]},
        separators=(",", ":"),
        sort_keys=True,
    )
    return _b64(hashlib.sha256(canonical.encode()).digest())


def access_token_hash(token: str) -> str:
    return _b64(hashlib.sha256(token.encode()).digest())


def _log(reason: Reason, jkt: str = "", jti: str = "") -> None:
    logger.warning(
        "dpop rejected reason=%s jkt=%s jti=%s", reason.value, jkt[:8], jti[:_MAX_JTI].strip()
    )


def _reject(reason: Reason, message: str, *, jkt: str = "", jti: str = "", **kw: Any) -> DpopError:
    _log(reason, jkt, jti)
    return DpopError(reason, message, **kw)


# --- Proof verification ----------------------------------------------------------------------


def _public_key(header: dict[str, Any]) -> tuple[Any, dict[str, Any]]:
    jwk = header.get("jwk")
    if not isinstance(jwk, dict):
        raise _reject(Reason.BAD_JWK, "The proof carries no public key.")
    if _PRIVATE_JWK_MEMBERS & jwk.keys():
        raise _reject(Reason.PRIVATE_JWK, "The proof's key must be a public key.")
    if jwk.get("kty") != "EC" or jwk.get("crv") != "P-256":
        raise _reject(Reason.BAD_JWK, "The proof's key must be an EC P-256 key.")
    if not isinstance(jwk.get("x"), str) or not isinstance(jwk.get("y"), str):
        raise _reject(Reason.BAD_JWK, "The proof's key is incomplete.")
    public = {name: jwk[name] for name in ("kty", "crv", "x", "y")}
    try:
        key = jwt.PyJWK.from_dict(public, algorithm=ALGORITHM).key
    except (jwt.PyJWTError, ValueError, TypeError, KeyError) as error:
        raise _reject(Reason.BAD_JWK, "The proof's key is not valid.") from error
    return key, public


def _decode(proof: str) -> tuple[dict[str, Any], dict[str, Any], str]:
    if len(proof.encode()) > _MAX_PROOF_BYTES:
        raise _reject(Reason.PROOF_TOO_LARGE, "The proof is too large.")
    try:
        header = jwt.get_unverified_header(proof)
    except jwt.PyJWTError as error:
        raise _reject(Reason.PROOF_MALFORMED, "The proof is not a JWT.") from error
    if str(header.get("typ", "")).lower() != PROOF_TYPE:
        raise _reject(Reason.BAD_TYP, "The proof must have typ dpop+jwt.")
    if header.get("alg") != ALGORITHM:
        raise _reject(Reason.BAD_ALG, "Only ES256 proofs are accepted.")
    key, public = _public_key(header)
    jkt = thumbprint(public)
    try:
        claims = jwt.decode(
            proof,
            key,
            algorithms=[ALGORITHM],
            options={
                "verify_exp": False,
                "verify_nbf": False,
                "verify_iat": False,
                "verify_aud": False,
                "verify_iss": False,
                "require": ["jti", "htm", "htu", "iat"],
            },
        )
    except jwt.InvalidSignatureError as error:
        raise _reject(Reason.BAD_SIGNATURE, "The proof's signature is wrong.", jkt=jkt) from error
    except jwt.MissingRequiredClaimError as error:
        raise _reject(Reason.MISSING_CLAIM, "The proof lacks a required claim.", jkt=jkt) from error
    except jwt.PyJWTError as error:
        raise _reject(Reason.PROOF_MALFORMED, "The proof could not be read.", jkt=jkt) from error
    return claims, public, jkt


def _check_claims(
    claims: dict[str, Any], jkt: str, *, method: str, url: str, token: str, require_ath: bool
) -> str:
    jti = claims["jti"]
    if not isinstance(jti, str) or not jti or len(jti) > _MAX_JTI:
        raise _reject(Reason.BAD_CLAIM, "The proof's jti is not valid.", jkt=jkt)
    claimed_url = claims["htu"]
    if not isinstance(claims["htm"], str) or not isinstance(claimed_url, str):
        raise _reject(Reason.BAD_CLAIM, "The proof's htm or htu is not valid.", jkt=jkt, jti=jti)
    if claims["htm"] != method:
        raise _reject(Reason.METHOD_MISMATCH, "The proof is for another method.", jkt=jkt, jti=jti)
    if claimed_url.split("#", 1)[0].split("?", 1)[0] != url:
        raise _reject(Reason.URL_MISMATCH, "The proof is for another URL.", jkt=jkt, jti=jti)
    iat = claims["iat"]
    if isinstance(iat, bool) or not isinstance(iat, int | float):
        raise _reject(Reason.BAD_CLAIM, "The proof's iat is not a number.", jkt=jkt, jti=jti)
    skew = time.time() - float(iat)
    window = settings.DPOP_IAT_WINDOW_SECONDS
    if skew > window:
        raise _reject(Reason.IAT_STALE, "The proof is too old.", jkt=jkt, jti=jti, clock=True)
    if skew < -window:
        raise _reject(
            Reason.IAT_FUTURE, "The proof is dated in the future.", jkt=jkt, jti=jti, clock=True
        )
    if token and require_ath:
        ath = claims.get("ath")
        if not isinstance(ath, str) or not ath:
            raise _reject(Reason.ATH_MISSING, "The proof lacks ath.", jkt=jkt, jti=jti)
        if not hmac.compare_digest(ath, access_token_hash(token)):
            raise _reject(Reason.ATH_MISMATCH, "The proof is for another token.", jkt=jkt, jti=jti)
    return jti


def _check_nonce(claims: dict[str, Any], jkt: str, jti: str) -> None:
    if not nonce_enabled():
        return
    nonce = claims.get("nonce")
    if not isinstance(nonce, str) or not nonce:
        raise _reject(
            Reason.NONCE_MISSING,
            "The server requires a nonce.",
            jkt=jkt,
            jti=jti,
            error=ERROR_NONCE,
            nonce=current_nonce(),
        )
    if not _nonce_valid(nonce):
        raise _reject(
            Reason.NONCE_STALE,
            "The nonce is stale.",
            jkt=jkt,
            jti=jti,
            error=ERROR_NONCE,
            nonce=current_nonce(),
        )


def _remember(jkt: str, jti: str) -> None:
    """Spend the ``jti``: the shared cache (LocMem in debug, Redis in production) makes a replay
    fail on any worker. Held for as long as the freshness window could still accept the proof."""
    key = f"{_REPLAY_PREFIX}{jkt}:{hashlib.sha256(jti.encode()).hexdigest()[:32]}"
    if not cache.add(key, 1, timeout=2 * settings.DPOP_IAT_WINDOW_SECONDS + 5):
        raise _reject(Reason.REPLAY, "This proof was already used.", jkt=jkt, jti=jti)


def verify_proof(
    proof: str, *, method: str, url: str, access_token: str = "", require_ath: bool = False
) -> VerifiedProof:
    """Check one proof end to end, spending its ``jti``. Raises :class:`DpopError`."""
    if not proof:
        raise _reject(Reason.PROOF_MISSING, "A DPoP proof is required.")
    claims, _public, jkt = _decode(proof)
    jti = _check_claims(
        claims, jkt, method=method, url=url, token=access_token, require_ath=require_ath
    )
    _check_nonce(claims, jkt, jti)
    _remember(jkt, jti)
    return VerifiedProof(jkt=jkt, jti=jti, claims=claims)


# --- What a request says ---------------------------------------------------------------------


def _meta(request: Any, *names: str) -> str:
    meta = getattr(request, "META", {})
    for name in names:
        value = meta.get(name)
        if value:
            return str(value)
    return ""


def proof_of(request: Any) -> str:
    return _meta(request, HEADER_META, GRPC_META)


def scheme_of(request: Any) -> str:
    return _meta(request, "HTTP_AUTHORIZATION").partition(" ")[0].lower()


def expected_call(request: Any) -> tuple[str, str]:
    """The method and URL a proof on this request must name."""
    method = _meta(request, METHOD_META) or str(getattr(request, "method", "") or "")
    url = _meta(request, URL_META) or f"{public_origin()}{getattr(request, 'path', '')}"
    return method, url


def _verify_request(request: Any, *, token: str = "", require_ath: bool = False) -> VerifiedProof:
    method, url = expected_call(request)
    return verify_proof(
        proof_of(request), method=method, url=url, access_token=token, require_ath=require_ath
    )


# --- Enforcement -----------------------------------------------------------------------------


def _warn_once(session_id: str) -> None:
    if cache.add(f"dpop:optional:{session_id}", 1, timeout=24 * 3600):
        logger.warning("dpop: session %s uses a plain bearer token (mode optional)", session_id)


def _key_failure(request: Any, user_id: str, jkt: str) -> None:
    """A token used with another key is a failed sign-in signal for the phase 01 limiter."""
    from infrastructure.auth.core.identities import user_by_id
    from infrastructure.auth.core.throttling import (
        attempts_exhausted,
        record_failed_attempt,
    )

    window = settings.DPOP_KEY_FAILURE_WINDOW_SECONDS
    record_failed_attempt(_FAILURE_SCOPE, user_id, window=window)
    user = user_by_id(user_id)
    if user is not None:
        _count_as_login_failure(request, user)
    if attempts_exhausted(_FAILURE_SCOPE, user_id, limit=settings.DPOP_MAX_KEY_FAILURES):
        raise ApiError(
            "Too many attempts. Try again later.", status=429, title=ResponseTitle.RATE_LIMITED
        )


def _count_as_login_failure(request: Any, user: Any) -> None:
    from infrastructure.auth.core.flows import record_event
    from infrastructure.auth.core.models import AuthEventType
    from infrastructure.auth.core.throttling import record_failed_attempt
    from infrastructure.common.app_labels import app_installed

    login_name = str(user.get_username()).lower()
    if app_installed("auth_password"):
        from infrastructure.auth.password import services as password

        record_failed_attempt(
            password.ACCOUNT_SCOPE, login_name, window=password.LOGIN_ATTEMPT_WINDOW_SECONDS
        )
    record_event(request, AuthEventType.LOGIN_FAILED, user=user, method="dpop")


def authorize(
    request: Any, token: str, *, bound_jkt: str, session_id: str, user_id: str = ""
) -> None:
    """Decide whether this access token may be used by this request. Raises :class:`DpopError`.

    ``bound_jkt`` is the thumbprint in the token's ``cnf`` claim (empty for a session issued
    before binding existed or while the mode was ``off``).
    """
    policy = mode()
    if policy == OFF:
        return
    path = str(getattr(request, "path", ""))
    if not bound_jkt:
        if policy == REQUIRED and not (path and is_public_api_path(path)):
            raise _reject(
                Reason.UNBOUND_SESSION,
                "This session predates key binding. Sign in again.",
                error=ERROR_TOKEN,
            )
        if policy == OPTIONAL:
            _warn_once(session_id)
        return
    if scheme_of(request) != SCHEME:
        raise _reject(
            Reason.BEARER_NOT_ALLOWED,
            "This token is bound to a key and must be sent with a DPoP proof.",
            error=ERROR_TOKEN,
        )
    if _meta(request, VERIFIED_META):
        return
    proof = _verify_request(request, token=token, require_ath=True)
    if not hmac.compare_digest(proof.jkt, bound_jkt):
        _log(Reason.KEY_MISMATCH, proof.jkt, proof.jti)
        _key_failure(request, user_id, proof.jkt)
        raise DpopError(
            Reason.KEY_MISMATCH,
            "This token belongs to another key. Sign in again on this device.",
            error=ERROR_TOKEN,
        )


def signin_binding(request: Any) -> str:
    """The thumbprint to bind a session being issued to, or ``""`` when nothing is bound.

    Verified once per request (the proof's ``jti`` is spent by the first check) and remembered, so
    ``complete_login`` can fail early and ``issue_credentials`` can use the same answer.
    """
    if not enabled():
        return ""
    cached = getattr(request, _PROOF_ATTR, None)
    if cached is not None:
        return str(cached)
    if not proof_of(request):
        if mode() == REQUIRED:
            raise _reject(Reason.PROOF_MISSING, "A DPoP proof is required to sign in.")
        jkt = ""
    else:
        jkt = _verify_request(request).jkt
    with contextlib.suppress(AttributeError):  # a request object that refuses attributes
        setattr(request, _PROOF_ATTR, jkt)
    return jkt


def verify_refresh(request: Any, bound_jkt: str) -> None:
    """A bound session refreshes only with a proof from its own key; an unbound one not at all in
    ``required`` mode. Checked before anything is spent, so a thief cannot burn the token."""
    policy = mode()
    if policy == OFF:
        return
    if not bound_jkt:
        if policy == REQUIRED:
            raise _reject(
                Reason.UNBOUND_SESSION,
                "This session predates key binding. Sign in again.",
                error=ERROR_TOKEN,
            )
        return
    proof = _verify_request(request)
    if not hmac.compare_digest(proof.jkt, bound_jkt):
        _log(Reason.KEY_MISMATCH, proof.jkt, proof.jti)
        raise DpopError(
            Reason.KEY_MISMATCH,
            "This session belongs to another key. Sign in again on this device.",
            error=ERROR_TOKEN,
        )
