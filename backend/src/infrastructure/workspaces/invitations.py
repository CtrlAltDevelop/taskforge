"""Invitations: email invites and share links into a workspace.

Creating, listing, revoking and resending need ``member.invite``; accepting
needs only a signed-in account and gives the joiner the invitation's role (Member when it
carries none, or its role was deleted meanwhile). The inviter may only put a role on an
invitation if they hold every permission of it (the SetRole escalation rule).
The raw token exists in memory at creation (and in the email, sent after commit by
``invite_mail``) and nowhere else: the database holds its SHA-256.

A token the server does not know, and one whose workspace is deleted, are the same
404, so nothing can be probed.
"""

import hmac
import logging
import secrets
import uuid
from dataclasses import dataclass, field
from datetime import timedelta
from hashlib import sha256
from typing import Any, Final

from django.conf import settings
from django.core.exceptions import ValidationError
from django.core.validators import validate_email
from django.db import transaction
from django.db.models import F, Q
from django.utils import timezone

from infrastructure.auth.core.challenges import get_challenge_store
from infrastructure.common.errors import ApiError
from infrastructure.common.responses import ResponseTitle
from infrastructure.workspaces import access, roles
from infrastructure.workspaces.invite_mail import invitation_issued
from infrastructure.workspaces.models import (
    Invitation,
    MemberStatus,
    Role,
    Workspace,
    WorkspaceMember,
)
from infrastructure.workspaces.registry import MEMBER

logger = logging.getLogger(__name__)

MAX_EMAILS_PER_CALL: Final = 20
DEFAULT_EXPIRY: Final = timedelta(days=7)
MIN_LINK_EXPIRY_SECONDS: Final = 3600
MAX_LINK_EXPIRY_SECONDS: Final = 30 * 86400
MAX_LINK_USES: Final = 1000
MAX_PENDING_LISTED: Final = 200
EXPIRED_LISTED_FOR: Final = timedelta(days=30)
HOUR_SECONDS: Final = 3600
INVITE: Final = "member.invite"

VALID, EXPIRED, REVOKED, USED_UP = "valid", "expired", "revoked", "used_up"
_STATE_ERRORS: Final = {
    EXPIRED: ("This invitation has expired.", ResponseTitle.INVITE_EXPIRED),
    REVOKED: ("This invitation was revoked.", ResponseTitle.INVITE_REVOKED),
    USED_UP: ("This invitation has no uses left.", ResponseTitle.INVITE_USED_UP),
}


@dataclass(frozen=True, slots=True)
class Created:
    """An invitation plus its raw token, the only time the token is available."""

    invitation: Invitation
    token: str


@dataclass(frozen=True, slots=True)
class CreateResult:
    created: list[Created]
    skipped_emails: list[str] = field(default_factory=list)  # already active members


@dataclass(frozen=True, slots=True)
class Preview:
    workspace_name: str
    inviter_name: str
    email_bound: bool
    state: str


def hash_token(token: str) -> str:
    return sha256(token.encode()).hexdigest()


def state_of(invitation: Invitation) -> str:
    if invitation.revoked_at is not None:
        return REVOKED
    if invitation.expires_at <= timezone.now():
        return EXPIRED
    if invitation.max_uses and invitation.uses >= invitation.max_uses:
        return USED_UP
    return VALID


def _not_found() -> ApiError:
    return ApiError("No such invitation.", status=404)


def _new_token() -> tuple[str, str]:
    raw = secrets.token_urlsafe(32)
    return raw, hash_token(raw)


def _charge(workspace: Workspace, count: int) -> None:
    """Per-workspace hourly cap on invitations created or resent.

    ponytail: check-then-increment can overshoot by a concurrent call's worth.
    """
    limit = settings.WORKSPACE_INVITES_PER_HOUR
    store = get_challenge_store()
    key = f"workspace-invites:{workspace.pk}"
    if limit > 0 and store.count(key) + count > limit:
        raise ApiError(
            "Too many invitations sent from this workspace. Try again later.",
            status=429,
            title=ResponseTitle.RATE_LIMITED,
        )
    for _ in range(count):
        store.increment(key, HOUR_SECONDS)


def _clean_emails(emails: list[str]) -> list[str]:
    cleaned = list(dict.fromkeys(e.strip().lower() for e in emails if e.strip()))
    if not cleaned:
        raise ApiError("Give at least one email address.")
    if len(cleaned) > MAX_EMAILS_PER_CALL:
        raise ApiError(f"At most {MAX_EMAILS_PER_CALL} emails per request.")
    for email in cleaned:
        try:
            validate_email(email)
        except ValidationError:
            raise ApiError(f"{email!r} is not a valid email address.") from None
    return cleaned


def _announce(invitation: Invitation, token: str, inviter: Any) -> None:
    """Send ``invitation_issued`` once the surrounding transaction commits (never on rollback)."""
    payload = {
        "invitation_id": str(invitation.pk),
        "workspace_id": str(invitation.workspace_id),
        "workspace_name": invitation.workspace.name,
        "inviter_name": inviter.get_full_name(),
        "email": str(invitation.email),
        "token": token,
    }
    transaction.on_commit(lambda: invitation_issued.send(sender=Invitation, **payload))


def _invite_role(workspace: Workspace, grant: access.Grant, role_id: str) -> Role | None:
    """The invitation's role: "" is none (Member), else visible here and held by the inviter."""
    if not role_id:
        return None
    role = roles.visible_role(workspace, role_id)
    access.require_holds(grant, access.role_keys(role))
    return role


def create_invitations(
    workspace: Workspace, actor: Any, emails: list[str], role_id: str = ""
) -> CreateResult:
    """One single-use, email-bound invitation per address; a pending one is replaced."""
    grant = access.require(actor, INVITE, workspace)
    role = _invite_role(workspace, grant, role_id)
    cleaned = _clean_emails(emails)
    member_emails = set(
        WorkspaceMember.objects.filter(workspace=workspace, status=MemberStatus.ACTIVE)
        .exclude(user__email__isnull=True)
        .values_list("user__email", flat=True)
    )
    member_emails = {e.lower() for e in member_emails}
    skipped = [e for e in cleaned if e in member_emails]
    targets = [e for e in cleaned if e not in member_emails]
    _charge(workspace, len(targets))
    created: list[Created] = []
    now = timezone.now()
    with transaction.atomic():
        Invitation.objects.filter(
            workspace=workspace, email__in=targets, revoked_at__isnull=True, accepted_at=None
        ).update(revoked_at=now)
        for email in targets:
            raw, digest = _new_token()
            row = Invitation.objects.create(
                workspace=workspace,
                email=email,
                token_hash=digest,
                created_by=actor,
                role=role,
                expires_at=now + DEFAULT_EXPIRY,
                max_uses=1,
            )
            created.append(Created(row, raw))
            _announce(row, raw, actor)
    return CreateResult(created, skipped)


def create_link(
    workspace: Workspace, actor: Any, expires_in: int = 0, max_uses: int = 0, role_id: str = ""
) -> Created:
    """A shareable link. ``expires_in`` seconds (0 = 7 days); ``max_uses`` 0 = unlimited."""
    grant = access.require(actor, INVITE, workspace)
    role = _invite_role(workspace, grant, role_id)
    if expires_in == 0:
        lifetime = DEFAULT_EXPIRY
    elif MIN_LINK_EXPIRY_SECONDS <= expires_in <= MAX_LINK_EXPIRY_SECONDS:
        lifetime = timedelta(seconds=expires_in)
    else:
        raise ApiError("Link expiry must be between 1 hour and 30 days.")
    if not 0 <= max_uses <= MAX_LINK_USES:
        raise ApiError(f"Max uses must be 0 (unlimited) to {MAX_LINK_USES}.")
    _charge(workspace, 1)
    raw, digest = _new_token()
    row = Invitation.objects.create(
        workspace=workspace,
        token_hash=digest,
        created_by=actor,
        role=role,
        expires_at=timezone.now() + lifetime,
        max_uses=max_uses,
    )
    return Created(row, raw)


def list_pending(workspace: Workspace, actor: Any) -> list[Invitation]:
    """Newest first, at most 200: not revoked, not used up, not expired over 30 days ago.

    Recently expired ones stay so they can be resent.
    """
    access.require(actor, INVITE, workspace)
    rows = (
        Invitation.objects.filter(workspace=workspace, revoked_at__isnull=True)
        .filter(Q(max_uses=0) | Q(uses__lt=F("max_uses")))
        .filter(expires_at__gt=timezone.now() - EXPIRED_LISTED_FOR)
        .select_related("created_by__profile", "role")
        .order_by("-created_at")
    )
    return list(rows[:MAX_PENDING_LISTED])


def _owned(workspace: Workspace, invitation_id: str) -> Invitation:
    try:
        pk = uuid.UUID(str(invitation_id))
    except ValueError:
        raise _not_found() from None
    row = Invitation.objects.filter(pk=pk, workspace=workspace).first()
    if row is None:
        raise _not_found()
    return row


def revoke(workspace: Workspace, actor: Any, invitation_id: str) -> Invitation:
    access.require(actor, INVITE, workspace)
    row = _owned(workspace, invitation_id)
    if row.revoked_at is None:
        row.revoked_at = timezone.now()
        row.save(update_fields=["revoked_at"])
    return row


def resend(workspace: Workspace, actor: Any, invitation_id: str) -> Created:
    """New token and expiry for a pending email invitation; the old token dies."""
    access.require(actor, INVITE, workspace)
    row = _owned(workspace, invitation_id)
    if row.email is None:
        raise ApiError("Only email invitations can be resent.")
    if state_of(row) not in (VALID, EXPIRED):
        raise ApiError(
            "This invitation is no longer pending.",
            status=409,
            title=ResponseTitle.INVITE_NOT_PENDING,
        )
    _charge(workspace, 1)
    raw, digest = _new_token()
    row.token_hash = digest
    row.expires_at = timezone.now() + DEFAULT_EXPIRY
    with transaction.atomic():
        row.save(update_fields=["token_hash", "expires_at"])
        _announce(row, raw, actor)
    return Created(row, raw)


def _by_token(token: str) -> Invitation:
    digest = hash_token(token)
    row = (
        Invitation.objects.select_related("workspace", "created_by__profile")
        .filter(token_hash=digest, workspace__deleted_at__isnull=True)
        .first()
    )
    if row is None or not hmac.compare_digest(row.token_hash, digest):
        raise _not_found()
    return row


def preview(token: str) -> Preview:
    """Public. Names the workspace and inviter; never lists members or the bound email."""
    row = _by_token(token)
    return Preview(
        workspace_name=row.workspace.name,
        inviter_name=row.created_by.get_full_name(),
        email_bound=row.email is not None,
        state=state_of(row),
    )


def _email_matches(invitation: Invitation, actor: Any) -> bool:
    return bool(
        actor.email and invitation.email and actor.email.lower() == invitation.email.lower()
    )


def accept(token: str, actor: Any) -> WorkspaceMember:
    """Join the workspace. Idempotent: an active member gets their row back, uses untouched."""
    found = _by_token(token)
    with transaction.atomic():
        row = (
            Invitation.objects.select_for_update(of=("self",))  # role is a nullable join
            .select_related("workspace", "role")
            .get(pk=found.pk)
        )
        previous = WorkspaceMember.objects.filter(workspace=row.workspace, user=actor).first()
        if previous is not None and previous.status == MemberStatus.ACTIVE:
            return previous
        state = state_of(row)
        if state != VALID:
            message, title = _STATE_ERRORS[state]
            raise ApiError(message, status=410, title=title)
        if previous and previous.removed_at and row.created_at <= previous.removed_at:
            raise ApiError(
                "This invitation predates your removal from the workspace.",
                status=410,
                title=ResponseTitle.INVITE_BEFORE_REMOVAL,
            )
        if row.email is not None and not _email_matches(row, actor):
            raise ApiError(
                "This invitation is for a different email address.",
                status=403,
                title=ResponseTitle.INVITE_EMAIL_MISMATCH,
            )
        now = timezone.now()
        member, _ = WorkspaceMember.objects.update_or_create(
            workspace=row.workspace,
            user=actor,
            defaults={
                "status": MemberStatus.ACTIVE,
                "joined_at": now,
                "invited_by": row.created_by,
                "removed_at": None,
                # a returning member never keeps an old role
                "role": row.role or access.builtin_role(MEMBER),
            },
        )
        row.uses += 1
        row.accepted_at = row.accepted_at or now
        row.save(update_fields=["uses", "accepted_at"])
    return member


def decline(token: str, actor: Any) -> None:
    """The invited account turns an email invitation down (it is revoked). Links: no-op."""
    row = _by_token(token)
    if row.email is not None and _email_matches(row, actor) and row.revoked_at is None:
        row.revoked_at = timezone.now()
        row.save(update_fields=["revoked_at"])
