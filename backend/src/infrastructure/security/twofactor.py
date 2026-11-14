"""A signed-in person's own two-factor settings, on top of the starter's ``auth_twofactor``.

The starter owns the secrets, the time-step replay rule and the recovery-code hashing. What is
added here is the order a person meets them in (enrol, confirm, receive ten recovery codes in
one go) and the *step-up*: turning 2FA off or replacing the recovery codes asks for a current
code (or a recovery code) first, so a stolen session alone cannot weaken the account.
"""

from dataclasses import dataclass
from typing import Any

from django.conf import settings
from django.http import HttpRequest

from infrastructure.auth.core.errors import AuthError
from infrastructure.auth.core.flows import enrolled_second_factors
from infrastructure.auth.core.sessions import revoke_all_for_user
from infrastructure.auth.core.throttling import (
    attempts_exhausted,
    clear_attempts,
    record_failed_attempt,
)
from infrastructure.auth.twofactor.models import SecondFactor, SecondFactorMethod
from infrastructure.auth.twofactor.services import (
    LOCKOUT_SCOPE,
    consume_recovery_code,
    twofactor_service,
    unused_recovery_codes,
    verify_totp,
)
from infrastructure.common.responses import ResponseTitle
from infrastructure.security import devices
from infrastructure.security.models import TrustedDevice


@dataclass(frozen=True, slots=True)
class Status:
    enabled: bool
    unused_recovery_codes: int
    trusted_devices: list[TrustedDevice]


def status(user: Any) -> Status:
    return Status(
        enabled=SecondFactorMethod.TOTP in enrolled_second_factors(user),
        unused_recovery_codes=unused_recovery_codes(user),
        trusted_devices=devices.active(user),
    )


def begin(user: Any) -> tuple[str, str]:
    enrolment = twofactor_service.start_totp(user)
    return enrolment.secret, enrolment.otpauth_uri


def confirm(request: HttpRequest, user: Any, code: str) -> list[str]:
    """Prove the app works, then hand out the ten recovery codes (shown once)."""
    _not_locked(user)
    try:
        twofactor_service.confirm_totp(request, user, code=code.strip())
    except AuthError:
        record_failed_attempt(
            LOCKOUT_SCOPE, str(user.pk), window=settings.SECURITY_MFA_LOCKOUT_SECONDS
        )
        raise
    return twofactor_service.generate_recovery_codes(request, user)


def _not_locked(user: Any) -> None:
    if attempts_exhausted(LOCKOUT_SCOPE, str(user.pk), limit=settings.SECURITY_MFA_MAX_FAILURES):
        raise AuthError(
            "Too many wrong codes. Wait a while before trying again.",
            status=429,
            title=ResponseTitle.SECOND_FACTOR_LOCKED,
        )


def step_up(user: Any, code: str) -> None:
    """Accept a current authenticator code or an unused recovery code, or refuse."""
    _not_locked(user)
    code = code.strip()
    factor = SecondFactor.objects.filter(
        user=user, method=SecondFactorMethod.TOTP, confirmed_at__isnull=False
    ).first()
    if factor is None:
        raise AuthError(
            "Two-factor authentication is not on.",
            status=400,
            title=ResponseTitle.SECOND_FACTOR_NOT_SET_UP,
        )
    if verify_totp(factor, code) or consume_recovery_code(user, code):
        clear_attempts(LOCKOUT_SCOPE, str(user.pk))
        return
    record_failed_attempt(LOCKOUT_SCOPE, str(user.pk), window=settings.SECURITY_MFA_LOCKOUT_SECONDS)
    raise AuthError("That code is not valid.", status=400, title=ResponseTitle.INVALID_CODE)


def disable(request: HttpRequest, user: Any, code: str) -> None:
    step_up(user, code)
    twofactor_service.remove(request, user, method=SecondFactorMethod.TOTP)
    if SecondFactor.objects.filter(user=user, method=SecondFactorMethod.RECOVERY).exists():
        twofactor_service.remove(request, user, method=SecondFactorMethod.RECOVERY)
    devices.revoke(user)


def regenerate_codes(request: HttpRequest, user: Any, code: str) -> list[str]:
    step_up(user, code)
    return twofactor_service.generate_recovery_codes(request, user)


def admin_disable(user: Any) -> int:
    """Locked-out recovery (the management command): drop every factor, device and session."""
    removed, _ = SecondFactor.objects.filter(user=user).delete()
    user.auth_recovery_codes.all().delete()
    devices.revoke(user)
    revoke_all_for_user(user, "second_factor_reset")
    return removed
