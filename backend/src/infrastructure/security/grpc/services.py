"""Security over gRPC: ``SecondFactorController`` (Status, Begin, Confirm, Disable,
RegenerateCodes, RevokeDevice), ``SecurityPolicyController`` (Get, Set) and ``SsoController``
(Get, Save, Delete, Test). The rules are in ``infrastructure.security``.

Signing in with a second factor, and single sign-on, are REST (browser redirects and a login that
has no bearer token yet): ``/auth/2fa/verify`` and ``/auth/sso/...``.

The workspace is resolved here with ``enforce=False``: a member blocked by the "require
two-factor" policy must still reach these calls, or they could never enrol.
"""

from typing import Any

from asgiref.sync import sync_to_async
from django_socio_grpc import generics
from django_socio_grpc.decorators import grpc_action

from infrastructure.common.grpc.errors import action, require_caller
from infrastructure.common.identity import grpc_caller
from infrastructure.security import devices as device_store
from infrastructure.security import idp, policy, twofactor
from infrastructure.security.grpc.serializers import Provider, RoleMapping, TrustedDevice
from infrastructure.security.models import IdentityProvider
from infrastructure.workspaces.scoping import require_workspace

WS = [{"name": "workspace_id", "type": "string"}]
CODE = [{"name": "code", "type": "string"}]


def _pb() -> Any:
    from infrastructure.security.grpc import security_pb2

    return security_pb2


def _iso(value: Any) -> str:
    return value.isoformat() if value else ""


async def _caller(context: Any) -> Any:
    return require_caller(await grpc_caller(context))


async def _scope(request: Any, context: Any, permission: str | None = None) -> tuple[Any, Any]:
    user = await _caller(context)
    workspace = await sync_to_async(require_workspace)(
        user, request.workspace_id, permission, enforce=False
    )
    return user, workspace


def device_message(row: Any) -> Any:
    return _pb().TrustedDevice(
        id=str(row.pk),
        label=row.label,
        created_at=_iso(row.created_at),
        last_used_at=_iso(row.last_used_at),
        expires_at=_iso(row.expires_at),
    )


def _status_message(user: Any) -> Any:
    state = twofactor.status(user)
    return _pb().SecondFactorStatus(
        enabled=state.enabled,
        unused_recovery_codes=state.unused_recovery_codes,
        trusted_devices=[device_message(d) for d in state.trusted_devices],
    )


class SecondFactorService(generics.GenericService):
    @grpc_action(
        request=[],
        request_name="SecondFactorStatusRequest",
        response=[
            {"name": "enabled", "type": "bool"},
            {"name": "unused_recovery_codes", "type": "int32"},
            {"name": "trusted_devices", "cardinality": "repeated", "type": TrustedDevice},
        ],
        response_name="SecondFactorStatus",
    )
    @action
    async def Status(self, request: Any, context: Any) -> Any:
        user = await _caller(context)
        return await sync_to_async(_status_message)(user)

    @grpc_action(
        request=[],
        request_name="SecondFactorBeginRequest",
        response=[{"name": "secret", "type": "string"}, {"name": "otpauth_uri", "type": "string"}],
        response_name="SecondFactorEnrolment",
    )
    @action
    async def Begin(self, request: Any, context: Any) -> Any:
        """A fresh authenticator secret and its ``otpauth://`` URI (for the QR code). Counts for
        nothing until ``Confirm`` proves a code."""
        user = await _caller(context)
        secret, uri = await sync_to_async(twofactor.begin)(user)
        return _pb().SecondFactorEnrolment(secret=secret, otpauth_uri=uri)

    @grpc_action(
        request=CODE,
        request_name="SecondFactorConfirmRequest",
        response=[{"name": "recovery_codes", "cardinality": "repeated", "type": "string"}],
        response_name="SecondFactorConfirmed",
    )
    @action
    async def Confirm(self, request: Any, context: Any) -> Any:
        """Turns 2FA on and returns the ten single-use recovery codes, in clear, once."""
        user = await _caller(context)
        codes = await sync_to_async(twofactor.confirm)(context.http_request, user, request.code)
        return _pb().SecondFactorConfirmed(recovery_codes=codes)

    @grpc_action(
        request=CODE,
        request_name="SecondFactorDisableRequest",
        response=[{"name": "enabled", "type": "bool"}],
        response_name="SecondFactorDisabled",
    )
    @action
    async def Disable(self, request: Any, context: Any) -> Any:
        """Needs a current authenticator code or an unused recovery code."""
        user = await _caller(context)
        await sync_to_async(twofactor.disable)(context.http_request, user, request.code)
        return _pb().SecondFactorDisabled(enabled=False)

    @grpc_action(
        request=CODE,
        request_name="SecondFactorRegenerateRequest",
        response=[{"name": "recovery_codes", "cardinality": "repeated", "type": "string"}],
        response_name="SecondFactorRegenerated",
    )
    @action
    async def RegenerateCodes(self, request: Any, context: Any) -> Any:
        """Replaces the recovery codes (the old ones stop working). Needs a current code."""
        user = await _caller(context)
        codes = await sync_to_async(twofactor.regenerate_codes)(
            context.http_request, user, request.code
        )
        return _pb().SecondFactorRegenerated(recovery_codes=codes)

    @grpc_action(
        request=[{"name": "device_id", "type": "string"}],
        request_name="RevokeDeviceRequest",
        response=[{"name": "revoked", "type": "int32"}],
        response_name="RevokeDeviceAnswer",
    )
    @action
    async def RevokeDevice(self, request: Any, context: Any) -> Any:
        """Forget one trusted device, or every one when ``device_id`` is empty."""
        user = await _caller(context)
        count = await sync_to_async(device_store.revoke)(user, request.device_id or None)
        return _pb().RevokeDeviceAnswer(revoked=count)


def _policy_message(user: Any, workspace: Any) -> Any:
    state = policy.policy_state(workspace)
    return _pb().PolicyAnswer(
        require_2fa=state.require_2fa,
        grace_days=state.grace_days,
        enforced_from=_iso(state.enforced_from),
        in_grace=state.in_grace,
        enrolled=policy.has_totp(user),
        blocked=policy.is_blocked(user, workspace),
        version=state.version,
    )


POLICY_RESPONSE = [
    {"name": "require_2fa", "type": "bool"},
    {"name": "grace_days", "type": "int32"},
    {"name": "enforced_from", "type": "string"},
    {"name": "in_grace", "type": "bool"},
    {"name": "enrolled", "type": "bool"},
    {"name": "blocked", "type": "bool"},
    {"name": "version", "type": "int32"},
]


class SecurityPolicyService(generics.GenericService):
    @grpc_action(
        request=WS,
        request_name="PolicyGetRequest",
        response=POLICY_RESPONSE,
        response_name="PolicyAnswer",
    )
    @action
    async def Get(self, request: Any, context: Any) -> Any:
        """The workspace's two-factor requirement and where the caller stands against it."""
        user, workspace = await _scope(request, context)
        return await sync_to_async(_policy_message)(user, workspace)

    @grpc_action(
        request=[
            *WS,
            {"name": "require_2fa", "type": "bool"},
            {"name": "grace_days", "type": "int32"},
            {"name": "expected_version", "type": "int32"},
        ],
        request_name="PolicySetRequest",
        response=POLICY_RESPONSE,
        response_name="PolicyAnswer",
    )
    @action
    async def Set(self, request: Any, context: Any) -> Any:
        """Needs ``security.manage``. Switching it on starts the grace period."""
        user, workspace = await _scope(request, context, "security.manage")

        def run() -> Any:
            policy.set_policy(
                workspace,
                user,
                require_2fa=request.require_2fa,
                grace_days=request.grace_days,
                expected_version=request.expected_version,
            )
            return _policy_message(user, workspace)

        return await sync_to_async(run)()


def _redirect_uri(context: Any) -> str:
    from infrastructure.security import sso

    return sso.callback_uri(context.http_request)


def provider_message(row: IdentityProvider | None, redirect_uri: str) -> Any:
    if row is None:
        return _pb().ProviderAnswer(
            provider=_pb().Provider(
                configured=False,
                redirect_uri=redirect_uri,
                scopes="openid email profile",
                group_claim="groups",
                auto_create_users=True,
                enabled=True,
            )
        )
    return _pb().ProviderAnswer(
        provider=_pb().Provider(
            configured=True,
            name=row.name,
            issuer=row.issuer,
            client_id=row.client_id,
            has_secret=bool(row.client_secret_encrypted),
            scopes=row.scopes,
            allowed_domains=list(row.allowed_domains or []),
            group_claim=row.group_claim,
            group_roles=[
                _pb().RoleMapping(group=g, role_id=str(r))
                for g, r in (row.group_role_map or {}).items()
            ],
            default_role_id=str(row.default_role_id or ""),
            auto_create_users=row.auto_create_users,
            enabled=row.enabled,
            enforce_sso=row.enforce_sso,
            version=row.version,
            redirect_uri=redirect_uri,
        )
    )


PROVIDER_ANSWER = [{"name": "provider", "type": Provider}]


class SsoService(generics.GenericService):
    @grpc_action(
        request=WS,
        request_name="SsoGetRequest",
        response=PROVIDER_ANSWER,
        response_name="ProviderAnswer",
    )
    @action
    async def Get(self, request: Any, context: Any) -> Any:
        """Needs ``security.manage``. ``provider.configured`` is false until first saved."""
        user, workspace = await _scope(request, context, "security.manage")
        redirect = _redirect_uri(context)
        return await sync_to_async(lambda: provider_message(idp.get(workspace, user), redirect))()

    @grpc_action(
        request=[
            *WS,
            {"name": "name", "type": "string"},
            {"name": "issuer", "type": "string"},
            {"name": "client_id", "type": "string"},
            {"name": "client_secret", "type": "string"},
            {"name": "scopes", "type": "string"},
            {"name": "allowed_domains", "cardinality": "repeated", "type": "string"},
            {"name": "group_claim", "type": "string"},
            {"name": "group_roles", "cardinality": "repeated", "type": RoleMapping},
            {"name": "default_role_id", "type": "string"},
            {"name": "auto_create_users", "type": "bool"},
            {"name": "enabled", "type": "bool"},
            {"name": "enforce_sso", "type": "bool"},
            {"name": "expected_version", "type": "int32"},
        ],
        request_name="SsoSaveRequest",
        response=PROVIDER_ANSWER,
        response_name="ProviderAnswer",
    )
    @action
    async def Save(self, request: Any, context: Any) -> Any:
        """Needs ``security.manage``. An empty ``client_secret`` keeps the stored one."""
        user, workspace = await _scope(request, context, "security.manage")
        redirect = _redirect_uri(context)

        def run() -> Any:
            row = idp.save(
                workspace,
                user,
                idp.ProviderInput(
                    name=request.name,
                    issuer=request.issuer,
                    client_id=request.client_id,
                    client_secret=request.client_secret,
                    scopes=request.scopes,
                    allowed_domains=list(request.allowed_domains),
                    group_claim=request.group_claim,
                    group_role_map={m.group: m.role_id for m in request.group_roles},
                    default_role_id=request.default_role_id,
                    auto_create_users=request.auto_create_users,
                    enabled=request.enabled,
                    enforce_sso=request.enforce_sso,
                    expected_version=request.expected_version,
                ),
            )
            return provider_message(row, redirect)

        return await sync_to_async(run)()

    @grpc_action(
        request=WS,
        request_name="SsoDeleteRequest",
        response=[{"name": "deleted", "type": "bool"}],
        response_name="SsoDeleted",
    )
    @action
    async def Delete(self, request: Any, context: Any) -> Any:
        """Needs ``security.manage``. People who signed in through it must sign in again."""
        user, workspace = await _scope(request, context, "security.manage")
        await sync_to_async(idp.delete)(workspace, user)
        return _pb().SsoDeleted(deleted=True)

    @grpc_action(
        request=WS,
        request_name="SsoTestRequest",
        response=[
            {"name": "ok", "type": "bool"},
            {"name": "message", "type": "string"},
            {"name": "redirect_uri", "type": "string"},
            {"name": "authorization_endpoint", "type": "string"},
            {"name": "token_endpoint", "type": "string"},
            {"name": "jwks_uri", "type": "string"},
            {"name": "keys", "type": "int32"},
        ],
        response_name="SsoTestAnswer",
    )
    @action
    async def Test(self, request: Any, context: Any) -> Any:
        """Needs ``security.manage``. Checks discovery, issuer, endpoints and signing keys."""
        user, workspace = await _scope(request, context, "security.manage")
        redirect = _redirect_uri(context)
        report = await sync_to_async(idp.check_provider)(workspace, user, redirect)
        return _pb().SsoTestAnswer(
            ok=report.ok,
            message=report.message,
            redirect_uri=report.redirect_uri,
            authorization_endpoint=report.authorization_endpoint,
            token_endpoint=report.token_endpoint,
            jwks_uri=report.jwks_uri,
            keys=report.keys,
        )


GRPC_SERVICES = [SecondFactorService, SecurityPolicyService, SsoService]
