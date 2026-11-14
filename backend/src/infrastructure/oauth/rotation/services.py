"""Rotating a refresh token, and what to do when an old one comes back.

Rotation means a refresh token is spendable exactly once: redeeming it mints a
successor and retires the token that was presented. That turns a stolen refresh
token from a permanent foothold into a race, and the loser of that race tells us
a theft happened -- because the only way a spent token can be presented again is
if someone else kept a copy.

When that happens the whole family goes, not just the token. The thief and the
legitimate client are indistinguishable at that point, so the safe move is to
end the session and make both sign in again.
"""

import hmac
from datetime import timedelta
from typing import Any

from django.conf import settings
from django.db import transaction
from django.http import HttpRequest
from django.utils import timezone

from infrastructure.auth.core import dpop
from infrastructure.common.errors import ApiError
from infrastructure.common.responses import ResponseTitle
from infrastructure.oauth.core import jwt_tokens
from infrastructure.oauth.core.credentials import (
    IssuedCredentials,
    by_public_id,
    client_ip,
    sign_pair,
    token_model,
    user_agent,
)
from infrastructure.oauth.core.services import SessionList, SessionView, TokenModeService
from infrastructure.oauth.core.tokens import hash_token

MODE = "rotation"
FINGERPRINT_LENGTH = 16


def _fingerprint(digest: str) -> str:
    """Keep just enough of a digest to correlate reuse reports, never the whole one."""
    return digest[:FINGERPRINT_LENGTH]


def _record_reuse(request: HttpRequest, presented: Any) -> None:
    reuse_model = token_model(MODE, "RefreshTokenReuseEvent")
    reuse_model.objects.create(
        family=presented.family,
        refresh_token=presented,
        presented_fingerprint=_fingerprint(presented.token_hash),
        ip_address=client_ip(request),
        user_agent=user_agent(request),
    )
    presented.mark_reuse()


class _Reused(Exception):
    """Internal signal: the presented token had already been spent.

    Carried out of the locked block rather than reported from inside it, because
    reporting means raising, and an exception thrown mid-transaction would roll
    back the very audit row and family revocation that make the report matter.
    """

    def __init__(self, token: Any) -> None:
        super().__init__("refresh token reuse")
        self.token = token


def _issue_pair(
    request: HttpRequest, refresh_row: Any, refresh_handle: str, access_model: Any
) -> IssuedCredentials:
    """Mint an access token bound to [refresh_row] and sign the pair for the client."""
    family = refresh_row.family
    now = timezone.now()
    access_lifetime = timedelta(seconds=settings.AUTH_ACCESS_TOKEN_TTL_SECONDS)
    access_handle = jwt_tokens.new_handle()
    method = str(refresh_row.metadata.get("auth_method", ""))
    access_model.objects.create(
        user=refresh_row.user,
        family=family,
        issued_from=refresh_row,
        token_hash=hash_token(access_handle),
        expires_at=now + access_lifetime,
        issued_ip=client_ip(request),
        user_agent=user_agent(request),
        metadata={"auth_method": method},
    )
    return sign_pair(
        refresh_row.user,
        mode=MODE,
        session_id=str(family.id),
        methods=[method] if method else [],
        access_handle=access_handle,
        refresh_handle=refresh_handle,
        access_lifetime=access_lifetime,
        refresh_lifetime=family.expires_at - now,
        bind_jkt=family.dpop_jkt,
    )


def _is_retry_of_lost_request(presented: Any, request_id: str) -> bool:
    """Whether this replay is the *same request* whose response never arrived.

    The client's request id is a secret only it (and, in transit, TLS) has seen, so
    presenting it proves the replay is a retry rather than a thief holding a stolen
    copy of the spent token. It is honoured only while the successor it produced
    has never been used and the recovery window is open.
    """
    if not request_id or not presented.used_request_hash or presented.replaced_by_id is None:
        return False
    if not hmac.compare_digest(presented.used_request_hash, hash_token(request_id)):
        return False
    window = timedelta(seconds=settings.AUTH_REFRESH_RECOVERY_SECONDS)
    return timezone.now() - presented.used_at <= window


def _reissue(
    request: HttpRequest, presented: Any, refresh_model: Any, access_model: Any
) -> IssuedCredentials | None:
    """Give the lost successor a new secret, killing the copy lost in transit.

    Returns ``None`` when the successor has meanwhile been used, which means the
    client did get its answer and this replay is not a recovery after all.
    """
    successor = refresh_model.objects.select_for_update().get(pk=presented.replaced_by_id)
    if successor.used_at is not None or successor.revoked_at is not None:
        return None
    refresh_handle = jwt_tokens.new_handle()
    successor.token_hash = hash_token(refresh_handle)
    successor.issued_ip = client_ip(request)
    successor.user_agent = user_agent(request)
    successor.save(update_fields=["token_hash", "issued_ip", "user_agent"])
    access_model.objects.filter(issued_from=successor, revoked_at__isnull=True).update(
        revoked_at=timezone.now(), revocation_reason=access_model.RevocationReason.ROTATED
    )
    return _issue_pair(request, successor, refresh_handle, access_model)


def rotate(request: HttpRequest, refresh_token: str, request_id: str = "") -> IssuedCredentials:
    """Spend a refresh token and return its successor pair.

    Read and write happen under one row lock: two clients racing with the same
    token must not both walk away with a valid successor, which is exactly what
    an unlocked read-then-write would allow. The loser of that race is what
    surfaces as reuse.
    """
    try:
        handle = jwt_tokens.decode(refresh_token, token_type=jwt_tokens.REFRESH).handle
    except jwt_tokens.JwtError as error:
        raise ApiError(str(error), status=401, title=ResponseTitle.TOKEN_INVALID) from error
    refresh_model = token_model(MODE, "RotatingRefreshToken")
    access_model = token_model(MODE, "RotatingAccessToken")

    try:
        with transaction.atomic():
            presented = (
                refresh_model.objects.select_for_update()
                .select_related("family", "user")
                .filter(token_hash=hash_token(handle))
                .first()
            )
            if presented is None:
                raise ApiError(
                    "That refresh token is not valid.",
                    status=401,
                    title=ResponseTitle.TOKEN_INVALID,
                )
            # Phase 39: a bound session refreshes only with a proof from its own key. Checked
            # before anything is spent or revoked, so a thief holding the token alone can neither
            # use it nor burn it (a spent-token replay would otherwise end the family).
            dpop.verify_refresh(request, presented.family.dpop_jkt)
            if presented.used_at is not None:
                grace = timedelta(seconds=settings.AUTH_REFRESH_REUSE_GRACE_SECONDS)
                if presented.family.revoked_at is not None:
                    # Spent *and* ended: not a race and not fresh theft evidence.
                    raise ApiError(
                        "This session has ended. Sign in again.",
                        status=401,
                        title=ResponseTitle.SESSION_ENDED,
                    )
                if _is_retry_of_lost_request(presented, request_id):
                    recovered = _reissue(request, presented, refresh_model, access_model)
                    if recovered is not None:
                        return recovered
                if timezone.now() - presented.used_at <= grace:
                    # Two requests refreshed at once: the other one won. Keep the
                    # session; the client retries with the successor it was given.
                    raise ApiError(
                        "That refresh token was just spent. Retry with the newer one.",
                        status=409,
                        title=ResponseTitle.REFRESH_RACE,
                    )
                raise _Reused(presented)
            if presented.family.revoked_at is not None:
                raise ApiError(
                    "This session has ended. Sign in again.",
                    status=401,
                    title=ResponseTitle.SESSION_ENDED,
                )
            if not presented.is_active:
                raise ApiError(
                    "That refresh token has expired.", status=401, title=ResponseTitle.TOKEN_EXPIRED
                )

            family = presented.family
            refresh_handle = jwt_tokens.new_handle()
            successor = refresh_model.objects.create(
                user=presented.user,
                family=family,
                parent=presented,
                token_hash=hash_token(refresh_handle),
                rotation_index=presented.rotation_index + 1,
                expires_at=family.expires_at,
                issued_ip=client_ip(request),
                user_agent=user_agent(request),
                metadata={"auth_method": str(presented.metadata.get("auth_method", ""))},
            )
            presented.mark_used(
                successor, request_hash=hash_token(request_id) if request_id else ""
            )
            return _issue_pair(request, successor, refresh_handle, access_model)
    except _Reused as reuse:
        _record_reuse(request, reuse.token)
        raise ApiError(
            "This session has been ended for your security.",
            status=401,
            title=ResponseTitle.TOKEN_REUSED,
        ) from reuse


def live_families(user: Any) -> Any:
    """Return the account's families that have neither expired nor been revoked."""
    family_model = token_model(MODE, "TokenFamily")
    return (
        family_model.objects.filter(
            user=user,
            revoked_at__isnull=True,
            reuse_detected_at__isnull=True,
            expires_at__gt=timezone.now(),
        )
        .order_by("-created_at")
        .prefetch_related("refresh_tokens")
    )


def revoke_family(user: Any, family_id: str, reason: str = "logout") -> bool:
    """End one of the account's own sessions. Returns whether one was found."""
    family_model = token_model(MODE, "TokenFamily")
    family = by_public_id(
        family_model.objects.filter(user=user, revoked_at__isnull=True), family_id
    )
    if family is None:
        return False
    family.revoke(reason)
    return True


class RotationTokenService(TokenModeService):
    """The rotation mode, in the shape all three modes answer in."""

    mode = MODE

    def refresh(
        self, request: HttpRequest, *, refresh_token: str = "", request_id: str = ""
    ) -> IssuedCredentials:
        """Spend the presented refresh token and return its successor.

        Unlike the sliding mode there is a second token here, so an empty one is
        a refused request rather than an invitation to read the header.
        """
        if not refresh_token:
            raise ApiError(
                "A refresh token is required.", status=400, title=ResponseTitle.TOKEN_REQUIRED
            )
        return rotate(request, refresh_token, request_id)

    def sessions(self, user: Any) -> SessionList:
        return SessionList(
            mode=MODE,
            sessions=[
                SessionView(
                    session_id=str(family.id),
                    created_at=family.created_at.isoformat(),
                    last_used_at=(
                        family.last_rotated_at.isoformat() if family.last_rotated_at else ""
                    ),
                    expires_at=family.expires_at.isoformat(),
                    ip_address=family.issued_ip or "",
                    user_agent=family.user_agent,
                    auth_method=str(family.metadata.get("auth_method", "")),
                    dpop_jkt=family.dpop_jkt,
                )
                for family in live_families(user)
            ],
        )

    def revoke_session(self, user: Any, session_id: str) -> bool:
        return revoke_family(user, session_id)


token_service = RotationTokenService()
