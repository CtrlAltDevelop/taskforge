"""Finishing a sign-in that is waiting on a second factor.

Split from the enrolment routes next door because these two are the only ones a
caller reaches *without* a credential -- they are the last step of a login, not
something an account does to itself.
"""

from typing import Any

from django.http import HttpRequest
from ninja import Router

from infrastructure.auth.core.rest.schemas import (
    ChallengeOut,
    LoginOut,
    MessageOut,
    credentials_out,
)
from infrastructure.auth.twofactor.rest.schemas import ChallengeIn, VerifyIn
from infrastructure.auth.twofactor.services import SentCode, twofactor_service

router = Router()


def challenge_out(sent: SentCode) -> ChallengeOut:
    return ChallengeOut(
        ticket=sent.ticket,
        channel=sent.channel,
        destination=sent.destination,
        expires_in=sent.expires_in,
    )


@router.post(
    "/challenge",
    response={200: ChallengeOut, 400: MessageOut, 410: MessageOut, 429: MessageOut},
    auth=None,
    summary="Send a code for a pending sign-in",
)
def challenge(request: HttpRequest, payload: ChallengeIn) -> ChallengeOut:
    """Deliver an SMS or email code for a login that is waiting on a second factor."""
    return challenge_out(
        twofactor_service.challenge(
            request, login_ticket=payload.login_ticket, method=payload.method
        )
    )


@router.post(
    "/verify",
    response={200: LoginOut, 400: MessageOut, 403: MessageOut, 410: MessageOut, 429: MessageOut},
    auth=None,
    summary="Finish a sign-in with a second factor",
)
def verify(request: HttpRequest, payload: VerifyIn) -> LoginOut:
    """Check the second factor and, if it holds, issue the credential."""
    pending_user: Any = None
    if payload.remember_device:
        from infrastructure.auth.core.flows import resolve_pending_login

        pending_user, _ = resolve_pending_login(payload.login_ticket)
    credentials = twofactor_service.verify(
        request,
        login_ticket=payload.login_ticket,
        code=payload.code,
        method=payload.method,
    )
    token = ""
    if payload.remember_device:
        from infrastructure.security import devices

        token = devices.trust(request, pending_user, payload.device_label)
    return LoginOut(
        requires_second_factor=False,
        credentials=credentials_out(credentials),
        trusted_device_token=token,
    )
