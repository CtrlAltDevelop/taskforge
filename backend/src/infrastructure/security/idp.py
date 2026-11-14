"""The workspace's identity provider: read, save, remove, test (``security.manage``).

The client secret is write-only: it is encrypted on the way in, never returned, and left
unchanged when a save sends an empty one.
"""

from dataclasses import dataclass
from typing import Any

from django.db import transaction

from infrastructure.audit import recorder
from infrastructure.auth.core.sessions import revoke_all_for_user
from infrastructure.common.errors import ApiError
from infrastructure.common.responses import ResponseTitle
from infrastructure.security import oidc, sso
from infrastructure.security.models import IdentityProvider
from infrastructure.workspaces import access, roles

PERMISSION = "security.manage"


def _invalid(message: str) -> ApiError:
    return ApiError(message, status=400, title=ResponseTitle.VALIDATION_ERROR)


def get(workspace: Any, actor: Any) -> IdentityProvider | None:
    access.require(actor, PERMISSION, workspace)
    return IdentityProvider.objects.filter(workspace=workspace).first()


@dataclass(frozen=True, slots=True)
class ProviderInput:
    name: str
    issuer: str
    client_id: str
    client_secret: str  # "" keeps the stored one
    scopes: str
    allowed_domains: list[str]
    group_claim: str
    group_role_map: dict[str, str]
    default_role_id: str
    auto_create_users: bool
    enabled: bool
    enforce_sso: bool
    expected_version: int


def _clean_domains(domains: list[str]) -> list[str]:
    cleaned = [d.strip().lower().lstrip("@") for d in domains if d.strip()]
    for domain in cleaned:
        if "." not in domain or " " in domain or "/" in domain:
            raise _invalid(f"'{domain}' is not a domain.")
    return list(dict.fromkeys(cleaned))


def save(workspace: Any, actor: Any, data: ProviderInput) -> IdentityProvider:
    issuer = data.issuer.strip().rstrip("/")
    try:
        oidc.require_safe_url(issuer, "issuer")
    except oidc.OidcError as error:
        raise _invalid(str(error)) from error
    if not data.client_id.strip():
        raise _invalid("A client id is required.")
    with transaction.atomic():
        access.require(actor, PERMISSION, workspace)
        row = IdentityProvider.objects.select_for_update().filter(workspace=workspace).first()
        if row is None:
            if not data.client_secret:
                raise _invalid("A client secret is required.")
            row = IdentityProvider(workspace=workspace)
        elif data.expected_version != row.version:
            raise ApiError(
                "The settings changed meanwhile.", status=409, title=ResponseTitle.VERSION_CONFLICT
            )
        else:
            row.version += 1
        role_map: dict[str, str] = {}
        for group, role_id in data.group_role_map.items():
            if group.strip():
                role_map[group.strip()] = str(roles.visible_role(workspace, role_id).pk)
        row.default_role = (
            roles.visible_role(workspace, data.default_role_id) if data.default_role_id else None
        )
        row.name = data.name.strip()[:80]
        row.issuer = issuer
        row.client_id = data.client_id.strip()
        if data.client_secret:
            row.set_client_secret(data.client_secret)
        row.scopes = " ".join(data.scopes.split()) or "openid email profile"
        row.allowed_domains = _clean_domains(data.allowed_domains)
        row.group_claim = data.group_claim.strip()[:64]
        row.group_role_map = role_map
        row.auto_create_users = data.auto_create_users
        row.enabled = data.enabled
        row.enforce_sso = data.enforce_sso
        row.save()
        recorder.record(
            workspace_id=workspace.pk,
            action="security.sso_configured",
            target_type="workspace",
            target_id=workspace.pk,
            actor=actor,
            changes={
                "issuer": row.issuer,
                "enabled": row.enabled,
                "enforce_sso": row.enforce_sso,
                "allowed_domains": row.allowed_domains,
            },
        )
    return row


def delete(workspace: Any, actor: Any) -> None:
    with transaction.atomic():
        access.require(actor, PERMISSION, workspace)
        row = IdentityProvider.objects.filter(workspace=workspace).first()
        if row is None:
            return
        # Identity change: whoever signed in through it starts over.
        for identity in row.identities.select_related("user"):
            revoke_all_for_user(identity.user, "identity_removed")
        row.delete()
        recorder.record(
            workspace_id=workspace.pk,
            action="security.sso_removed",
            target_type="workspace",
            target_id=workspace.pk,
            actor=actor,
        )


@dataclass(frozen=True, slots=True)
class ProviderCheck:
    ok: bool
    message: str
    redirect_uri: str
    authorization_endpoint: str = ""
    token_endpoint: str = ""
    jwks_uri: str = ""
    keys: int = 0


def check_provider(workspace: Any, actor: Any, redirect_uri: str) -> ProviderCheck:
    """Check what can be checked without a person: discovery, issuer match, endpoints, keys."""
    row = get(workspace, actor)
    if row is None:
        raise ApiError(
            "Single sign-on is not set up yet.", status=404, title=ResponseTitle.SSO_NOT_CONFIGURED
        )
    try:
        found = oidc.discover(row.issuer, fresh=True)
        keys = oidc._get_json(found.jwks_uri).get("keys")
        count = len(keys) if isinstance(keys, list) else 0
        if not count:
            raise oidc.OidcError("The provider publishes no signing keys.")
        if not row.client_secret():
            raise oidc.OidcError("No client secret is stored.")
    except oidc.OidcError as error:
        return ProviderCheck(False, str(error), redirect_uri)
    return ProviderCheck(
        True,
        "The provider answered and its configuration matches.",
        redirect_uri,
        found.authorization_endpoint,
        found.token_endpoint,
        found.jwks_uri,
        count,
    )


def redirect_uri_for(request: Any) -> str:
    return sso.callback_uri(request)
