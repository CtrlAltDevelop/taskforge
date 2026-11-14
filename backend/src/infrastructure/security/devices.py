"""Trusted devices: skip the second factor on a device that has already passed it.

The client keeps the token this module mints (secure storage) and sends it as the
``X-Trusted-Device`` header on password sign-in. Only a digest is stored here. A device is
trusted per account, for ``SECURITY_TRUSTED_DEVICE_DAYS``, and every password change, 2FA
removal or "sign out everywhere" ends all of them.
"""

import secrets
from datetime import timedelta
from typing import Any

from django.conf import settings
from django.http import HttpRequest
from django.utils import timezone

from infrastructure.oauth.core.tokens import hash_token
from infrastructure.security.models import TrustedDevice

HEADER = "HTTP_X_TRUSTED_DEVICE"


def _token(request: HttpRequest) -> str:
    return request.META.get(HEADER, "").strip()


def is_trusted(request: HttpRequest, user: Any) -> bool:
    token = _token(request)
    if not token:
        return False
    device = TrustedDevice.objects.filter(user=user, token_hash=hash_token(token)).first()
    if device is None or not device.is_usable:
        return False
    TrustedDevice.objects.filter(pk=device.pk).update(last_used_at=timezone.now())
    return True


def trust(request: HttpRequest, user: Any, label: str = "") -> str:
    """Remember this device; returns the token to hand to the client exactly once."""
    token = secrets.token_urlsafe(48)
    TrustedDevice.objects.create(
        user=user,
        token_hash=hash_token(token),
        label=label[:120],
        ip_address=request.META.get("REMOTE_ADDR") or None,
        expires_at=timezone.now() + timedelta(days=settings.SECURITY_TRUSTED_DEVICE_DAYS),
    )
    return token


def revoke(user: Any, device_id: str | None = None) -> int:
    rows = TrustedDevice.objects.filter(user=user, revoked_at__isnull=True)
    if device_id:
        rows = rows.filter(pk=device_id)
    return rows.update(revoked_at=timezone.now())


def active(user: Any) -> list[TrustedDevice]:
    return list(
        TrustedDevice.objects.filter(
            user=user, revoked_at__isnull=True, expires_at__gt=timezone.now()
        )
    )
