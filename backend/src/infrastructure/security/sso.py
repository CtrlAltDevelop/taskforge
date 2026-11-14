"""Single sign-on, from the first redirect to the same tokens a password login gets.

``begin`` records an attempt (state, nonce, PKCE verifier, a browser binding and the app's own
PKCE challenge) and returns the provider URL. ``complete`` settles the callback into an
account and a one-time ticket. ``exchange`` trades the ticket for credentials through
``complete_login`` -- the same function every sign-in ends in -- so tokens, audit and the rest
are unchanged.

Who an identity becomes, in order: a known ``ExternalIdentity``; else an existing account that
has the *provider-verified* email (never an unverified one); else a new account, when the
provider allows it. Unverified emails are refused outright.
"""

import secrets
from dataclasses import dataclass
from datetime import timedelta
from typing import Any
from urllib.parse import parse_qsl, urlencode, urlparse, urlunparse

from django.conf import settings
from django.contrib.auth import get_user_model
from django.db import transaction
from django.http import HttpRequest
from django.utils import timezone

from infrastructure.audit import recorder
from infrastructure.auth.core.challenges import get_challenge_store
from infrastructure.auth.core.flows import LoginResult, complete_login, consume_codeless
from infrastructure.auth.core.sessions import revoke_all_for_user
from infrastructure.common.errors import ApiError
from infrastructure.common.responses import ResponseTitle
from infrastructure.oauth.core.crypto import decrypt_secret, encrypt_secret
from infrastructure.oauth.core.tokens import hash_token
from infrastructure.security import devices, oidc
from infrastructure.security.login_policy import SSO_METHOD
from infrastructure.security.models import (
    ExternalIdentity,
    IdentityProvider,
    SsoAttempt,
)
from infrastructure.workspaces import access
from infrastructure.workspaces.models import MemberStatus, Role, Workspace, WorkspaceMember
from infrastructure.workspaces.registry import MEMBER, OWNER
from infrastructure.workspaces.signals import announce_access

TICKET_PURPOSE = "sso_exchange"
CALLBACK_PATH = "/api/v1/auth/sso/callback"
BINDING_COOKIE = "tf_sso_binding"
ERROR_PARAM = "sso_error"


def _fail(message: str, title: ResponseTitle = ResponseTitle.SSO_FAILED, status: int = 400) -> Any:
    return ApiError(message, status=status, title=title)


# --- return URLs ---------------------------------------------------------------------------


def return_url_allowed(url: str) -> bool:
    """Only the app's own addresses: the native deep link or `/sso/callback` of a web origin."""
    if url == settings.SSO_NATIVE_RETURN_URL:
        return True
    parsed = urlparse(url)
    if parsed.scheme not in ("http", "https") or not parsed.netloc:
        return False
    origin = f"{parsed.scheme}://{parsed.netloc}"
    return origin in settings.SSO_WEB_RETURN_ORIGINS and parsed.path == "/sso/callback"


def with_params(url: str, **params: str) -> str:
    parsed = urlparse(url)
    query = [*parse_qsl(parsed.query), *params.items()]
    return urlunparse(parsed._replace(query=urlencode(query)))


def callback_uri(request: HttpRequest) -> str:
    base = settings.SSO_CALLBACK_BASE_URL or request.build_absolute_uri("/").rstrip("/")
    return f"{base}{CALLBACK_PATH}"


# --- start ---------------------------------------------------------------------------------


@dataclass(frozen=True, slots=True)
class Started:
    authorization_url: str
    binding: str
    expires_in: int


def provider_for_slug(slug: str) -> IdentityProvider:
    provider = (
        IdentityProvider.objects.select_related("workspace")
        .filter(workspace__slug=slug, workspace__deleted_at__isnull=True, enabled=True)
        .first()
    )
    if provider is None or not provider.client_id:
        raise _fail(
            "Single sign-on is not set up for that workspace.",
            ResponseTitle.SSO_NOT_CONFIGURED,
            404,
        )
    return provider


def begin(request: HttpRequest, slug: str, return_to: str, client_challenge: str) -> Started:
    if not return_url_allowed(return_to):
        raise _fail("That return address is not allowed.")
    if len(client_challenge) < 32 or len(client_challenge) > 128:
        raise _fail("A code challenge is required.")
    provider = provider_for_slug(slug)
    try:
        discovery = oidc.discover(provider.issuer)
    except oidc.OidcError as error:
        raise _fail(str(error), ResponseTitle.SSO_FAILED, 503) from error
    state, nonce, verifier = oidc.new_secrets()
    binding = secrets.token_urlsafe(32)
    redirect_uri = callback_uri(request)
    ttl = settings.SSO_ATTEMPT_TTL_SECONDS
    SsoAttempt.objects.create(
        provider=provider,
        state_hash=hash_token(state),
        nonce_hash=hash_token(nonce),
        binding_hash=hash_token(binding),
        code_verifier_encrypted=encrypt_secret(verifier),
        client_challenge=client_challenge,
        redirect_uri=redirect_uri,
        return_to=return_to,
        ip_address=request.META.get("REMOTE_ADDR") or None,
        expires_at=timezone.now() + timedelta(seconds=ttl),
    )
    url = oidc.authorization_url(
        discovery,
        client_id=provider.client_id,
        scopes=provider.scopes,
        redirect_uri=redirect_uri,
        state=state,
        nonce=nonce,
        verifier=verifier,
    )
    return Started(url, binding, ttl)


# --- callback ------------------------------------------------------------------------------


def _consume(state: str) -> SsoAttempt:
    with transaction.atomic():
        attempt = (
            SsoAttempt.objects.select_for_update()
            .select_related("provider__workspace")
            .filter(state_hash=hash_token(state))
            .first()
        )
        if attempt is None or not attempt.is_active:
            raise _fail("This sign-in expired or was already used. Start again.")
        attempt.consumed_at = timezone.now()
        attempt.save(update_fields=["consumed_at"])
    return attempt


def complete(request: HttpRequest, params: dict[str, str], binding: str) -> str:
    """Settle the provider's redirect; returns where to send the browser next.

    A failure after the attempt is known is a redirect to the app with ``sso_error`` set; one
    before that (unknown state) raises, since there is nowhere trustworthy to send the person.
    """
    state = params.get("state", "")
    if not state:
        raise _fail("The sign-in is missing its state.")
    attempt = _consume(state)
    if not binding or not secrets.compare_digest(hash_token(binding), attempt.binding_hash):
        raise _fail("This sign-in did not start in this browser.")
    try:
        user = _settle(request, attempt, params)
    except (ApiError, oidc.OidcError) as error:
        title = error.title if isinstance(error, ApiError) else ResponseTitle.SSO_FAILED
        attempt.error = str(error)[:255]
        attempt.save(update_fields=["error"])
        return with_params(attempt.return_to, **{ERROR_PARAM: str(title)})
    ticket = get_challenge_store().create(
        purpose=TICKET_PURPOSE,
        subject=str(user.pk),
        metadata={"challenge": attempt.client_challenge, "workspace": str(attempt.provider.pk)},
        ttl=settings.SSO_TICKET_TTL_SECONDS,
    )
    return with_params(attempt.return_to, ticket=ticket)


def _settle(request: HttpRequest, attempt: SsoAttempt, params: dict[str, str]) -> Any:
    if params.get("error"):
        raise _fail("The identity provider refused the sign-in.")
    code = params.get("code", "")
    if not code:
        raise _fail("The identity provider sent no sign-in code.")
    provider = attempt.provider
    if not provider.enabled:
        raise _fail("Single sign-on is switched off.", ResponseTitle.SSO_NOT_CONFIGURED)
    discovery = oidc.discover(provider.issuer)
    verifier = decrypt_secret(attempt.code_verifier_encrypted)
    id_token = oidc.exchange_code(
        discovery,
        client_id=provider.client_id,
        client_secret=provider.client_secret(),
        code=code,
        redirect_uri=attempt.redirect_uri,
        verifier=verifier,
    )
    claims = oidc.validate_id_token(
        discovery, id_token=id_token, client_id=provider.client_id, nonce_hash=attempt.nonce_hash
    )
    return resolve_user(provider, claims)


# --- who the identity is ---------------------------------------------------------------------


def _verified(claims: dict[str, Any]) -> bool:
    return str(claims.get("email_verified", "")).lower() == "true"


def _domain_ok(provider: IdentityProvider, email: str) -> bool:
    allowed = [str(d).strip().lower().lstrip("@") for d in provider.allowed_domains or []]
    allowed = [d for d in allowed if d]
    return not allowed or email.rpartition("@")[2].lower() in allowed


def resolve_user(provider: IdentityProvider, claims: dict[str, Any]) -> Any:
    """The account this identity signs in as, creating or linking it when the rules allow."""
    subject = str(claims["sub"])[:255]
    email = str(claims.get("email", "")).strip().lower()
    with transaction.atomic():
        workspace = Workspace.objects.select_for_update().get(pk=provider.workspace_id)
        identity = (
            ExternalIdentity.objects.select_related("user")
            .filter(provider=provider, subject=subject)
            .first()
        )
        if email and not _domain_ok(provider, email):
            raise _fail(
                "That email domain may not sign in to this workspace.",
                ResponseTitle.SSO_DOMAIN_NOT_ALLOWED,
                403,
            )
        if identity is None:
            if not email or not _verified(claims):
                raise _fail(
                    "The identity provider did not confirm your email address.",
                    ResponseTitle.SSO_EMAIL_UNVERIFIED,
                    403,
                )
            user = _link_or_create(provider, subject, email, claims)
        else:
            user = identity.user
            ExternalIdentity.objects.filter(pk=identity.pk).update(
                last_login_at=timezone.now(), email=email[:254] or identity.email
            )
        if not user.is_active:
            raise _fail("This account is disabled.", ResponseTitle.ACCOUNT_DISABLED, 403)
        _sync_membership(workspace, provider, user, claims)
    return user


def _link_or_create(
    provider: IdentityProvider, subject: str, email: str, claims: dict[str, Any]
) -> Any:
    user_model = get_user_model()
    user = user_model._default_manager.filter(email__iexact=email).first()
    created = False
    if user is None:
        if not provider.auto_create_users:
            raise _fail("No account exists for this identity.", ResponseTitle.SSO_NO_ACCOUNT, 403)
        user = user_model._default_manager.create_user(username=email[:150], email=email)
        created = True
        name = str(claims.get("name", "")).strip()
        profile = getattr(user, "profile", None)
        if name and profile is not None and hasattr(profile, "fill_blanks"):
            profile.fill_blanks(display_name=name)
    elif user.email_verified_at is None:
        # Pre-hijack defence: an account made with this address but never verified may belong
        # to someone else. Take its password away and end whatever sessions it has.
        user.set_unusable_password()
        user.save(update_fields=["password"])
        revoke_all_for_user(user, "identity_linked")
        devices.revoke(user)
    if created or user.email_verified_at is None:
        user.mark_email_verified()
    ExternalIdentity.objects.create(
        user=user, provider=provider, subject=subject, email=email[:254]
    )
    if not created:
        revoke_all_for_user(user, "identity_linked")  # identity change ends older sessions
    return user


def _mapped_role(provider: IdentityProvider, workspace: Workspace, claims: dict[str, Any]) -> Any:
    """The role the group claim maps to (the strongest when several match), if any."""
    raw = claims.get(provider.group_claim) if provider.group_claim else None
    groups = {str(g) for g in raw} if isinstance(raw, list) else {str(raw)} if raw else set()
    best: Role | None = None
    best_size = -1
    for group, role_id in (provider.group_role_map or {}).items():
        if group not in groups:
            continue
        role = Role.objects.filter(pk=role_id).first() if str(role_id).isdigit() else None
        if role is None or (role.workspace_id not in (None, workspace.pk)):
            continue
        size = len(access.role_keys(role))
        if size > best_size:
            best, best_size = role, size
    return best


def _sync_membership(
    workspace: Workspace, provider: IdentityProvider, user: Any, claims: dict[str, Any]
) -> None:
    member = (
        WorkspaceMember.objects.select_related("role")
        .filter(workspace=workspace, user=user)
        .first()
    )
    mapped = _mapped_role(provider, workspace, claims)
    if member is None:
        role = mapped or provider.default_role or access.builtin_role(MEMBER)
        WorkspaceMember.objects.create(workspace=workspace, user=user, role=role)
        announce_access(workspace, user.pk)
        _audit(workspace, user, "security.sso_member_joined", {"role": role.name})
        return
    if member.status == MemberStatus.REMOVED:
        raise _fail("You were removed from this workspace.", ResponseTitle.SSO_MEMBER_REMOVED, 403)
    if mapped is None or mapped.pk == member.role_id:
        return
    if access.is_owner_role(member.role):
        owners = WorkspaceMember.objects.filter(
            workspace=workspace,
            status=MemberStatus.ACTIVE,
            role__is_builtin=True,
            role__name=OWNER,
        ).count()
        if owners <= 1:
            return  # never demote the last owner from a claim
    WorkspaceMember.objects.filter(pk=member.pk).update(role=mapped)
    announce_access(workspace, user.pk)
    revoke_all_for_user(user, "role_changed")
    _audit(
        workspace,
        user,
        "security.sso_role_changed",
        {"from": member.role.name, "to": mapped.name},
    )


def _audit(workspace: Workspace, user: Any, action: str, changes: dict[str, Any]) -> None:
    recorder.record(
        workspace_id=workspace.pk,
        action=action,
        target_type="user",
        target_id=user.pk,
        actor=user,
        changes=changes,
    )


# --- exchange --------------------------------------------------------------------------------


def exchange(request: HttpRequest, ticket: str, verifier: str) -> LoginResult:
    """Trade the one-time ticket (and the app's PKCE verifier) for the usual credentials."""
    challenge = consume_codeless(ticket, TICKET_PURPOSE)
    expected = str(challenge.metadata.get("challenge", ""))
    if not verifier or not secrets.compare_digest(oidc.pkce_challenge(verifier), expected):
        raise _fail("The sign-in does not belong to this app.")
    user = get_user_model()._default_manager.filter(pk=challenge.subject).first()
    if user is None:
        raise _fail("This sign-in is no longer valid.")
    return complete_login(request, user, method=SSO_METHOD)
