"""Service accounts: workspace-owned identities for scripts and integrations.

An account is a user nobody can sign in as (no password, no email) with an ordinary membership,
which is where its role lives. Its tokens hold the role's permissions intersected with their
scopes, like a person's, so changing the role changes what every token of the account may do at
once. Managing accounts and their tokens needs ``webhook.manage`` (the integrations key), the
caller must hold every permission of the role they give (nobody hands out more than they have),
and an account is never an Owner (it would count as one when the last owner tries to leave).
Nothing here is reachable with an API token.
"""

import uuid
from dataclasses import dataclass
from typing import Any, Final

from django.conf import settings
from django.contrib.auth import get_user_model
from django.db import IntegrityError, transaction
from django.db.models import Count
from django.utils import timezone

from infrastructure.audit import changes as audit_changes
from infrastructure.common.errors import ApiError
from infrastructure.common.responses import ResponseTitle
from infrastructure.developer import services
from infrastructure.developer.models import ApiToken, ServiceAccount
from infrastructure.workspaces import access, roles
from infrastructure.workspaces.models import MemberStatus, Role, Workspace, WorkspaceMember
from infrastructure.workspaces.signals import announce_access

MANAGE: Final = services.MANAGE


@dataclass(frozen=True, slots=True)
class AccountView:
    account: ServiceAccount
    role: Role
    active: bool  # false once someone removed it from the workspace's members
    token_count: int


def is_service_account(user: Any) -> bool:
    return hasattr(user, "service_account")


def _gate(actor: Any, workspace: Workspace) -> access.Grant:
    services._by_person(actor)  # noqa: SLF001 -- the one rule, shared with tokens and webhooks
    return access.require(actor, MANAGE, workspace)


def _invalid(message: str) -> ApiError:
    return ApiError(message, title=ResponseTitle.VALIDATION_ERROR)


def _live(workspace: Workspace) -> Any:
    return ServiceAccount.objects.filter(workspace=workspace, deleted_at__isnull=True)


def _account(workspace: Workspace, account_id: str, *, lock: bool = False) -> ServiceAccount:
    try:
        pk = uuid.UUID(str(account_id))
    except ValueError:
        raise services._not_found() from None  # noqa: SLF001
    rows = _live(workspace).filter(pk=pk).select_related("user")
    account = (rows.select_for_update(of=("self",)) if lock else rows).first()
    if account is None:
        raise services._not_found()  # noqa: SLF001
    return account


def _member(account: ServiceAccount) -> WorkspaceMember | None:
    return (
        WorkspaceMember.objects.filter(workspace_id=account.workspace_id, user_id=account.user_id)
        .select_related("role")
        .first()
    )


def _view(account: ServiceAccount, tokens_alive: int | None = None) -> AccountView:
    member = _member(account)
    assert member is not None  # made together with the account, never deleted on its own
    count = (
        tokens_alive
        if tokens_alive is not None
        else ApiToken.objects.filter(owner_id=account.user_id, revoked_at__isnull=True).count()
    )
    return AccountView(account, member.role, member.status == MemberStatus.ACTIVE, count)


def list_accounts(actor: Any, workspace: Workspace) -> list[AccountView]:
    _gate(actor, workspace)
    rows = list(_live(workspace).select_related("user").order_by("created_at"))
    counts = dict(
        ApiToken.objects.filter(owner_id__in=[a.user_id for a in rows], revoked_at__isnull=True)
        .values("owner_id")
        .annotate(n=Count("pk"))
        .values_list("owner_id", "n")
    )
    return [_view(a, counts.get(a.user_id, 0)) for a in rows]


def _given_role(grant: access.Grant, workspace: Workspace, role_id: str) -> Role:
    role = roles.visible_role(workspace, role_id)
    if access.is_owner_role(role):
        raise _invalid("A service account cannot be an owner. Pick another role.")
    access.require_holds(grant, access.role_keys(role))
    return role


def _audit(
    workspace: Workspace, action: str, account: ServiceAccount, changes: dict[str, Any], actor: Any
) -> None:
    services._audit(workspace, action, "service_account", account.pk, changes, actor)  # noqa: SLF001


def create_account(actor: Any, workspace: Workspace, name: str, role_id: str) -> AccountView:
    cleaned = services._name(name)  # noqa: SLF001
    with transaction.atomic():
        access.lock(workspace)
        grant = _gate(actor, workspace)
        role = _given_role(grant, workspace, role_id)
        if _live(workspace).count() >= settings.DEVELOPER_MAX_SERVICE_ACCOUNTS:
            raise _invalid("This workspace has too many service accounts. Delete one first.")
        try:
            with transaction.atomic():
                user = get_user_model().objects.create_user(username=f"sa-{uuid.uuid4().hex[:16]}")
                account = ServiceAccount.objects.create(
                    workspace=workspace, user=user, name=cleaned, created_by=actor
                )
        except IntegrityError:
            raise _invalid("A service account with this name already exists.") from None
        _enrich_profile(user, cleaned)
        WorkspaceMember.objects.create(workspace=workspace, user=user, role=role, invited_by=actor)
        _audit(
            workspace,
            "serviceaccount.created",
            account,
            {"name": cleaned, "role": role.name},
            actor,
        )
    return _view(account, 0)


def _enrich_profile(user: Any, name: str) -> None:
    from infrastructure.accounts.profiles import enrich_profile

    enrich_profile(user, display_name=name)


def set_role(actor: Any, workspace: Workspace, account_id: str, role_id: str) -> AccountView:
    with transaction.atomic():
        access.lock(workspace)
        grant = _gate(actor, workspace)
        account = _account(workspace, account_id, lock=True)
        role = _given_role(grant, workspace, role_id)
        member = _member(account)
        if member is None or member.status != MemberStatus.ACTIVE:
            raise _invalid("This service account was removed from the workspace.")
        if member.role_id != role.pk:
            access.require_holds(grant, access.role_keys(member.role))
            before = member.role.name
            audit_changes.update_rows(WorkspaceMember.objects.filter(pk=member.pk), role=role)
            announce_access(workspace, account.user_id)
            _audit(
                workspace,
                "serviceaccount.role_changed",
                account,
                {"name": account.name, "role": [before, role.name]},
                actor,
            )
    return _view(account)


def delete_account(actor: Any, workspace: Workspace, account_id: str) -> None:
    """End the account: its tokens stop working, it leaves the members and cannot be used again.
    The row stays (soft delete) so the audit trail keeps pointing at something."""
    with transaction.atomic():
        access.lock(workspace)
        grant = _gate(actor, workspace)
        account = _account(workspace, account_id, lock=True)
        member = _member(account)
        if member is not None:
            access.require_holds(grant, access.role_keys(member.role))
            audit_changes.update_rows(
                WorkspaceMember.objects.filter(pk=member.pk),
                status=MemberStatus.REMOVED,
                removed_at=timezone.now(),
            )
        ApiToken.objects.filter(owner_id=account.user_id, revoked_at__isnull=True).update(
            revoked_at=timezone.now()
        )
        account.deleted_at = timezone.now()
        account.save(update_fields=["deleted_at"])
        get_user_model().objects.filter(pk=account.user_id).update(is_active=False)
        announce_access(workspace, account.user_id)
        _audit(workspace, "serviceaccount.deleted", account, {"name": account.name}, actor)


def list_tokens(actor: Any, workspace: Workspace, account_id: str) -> list[ApiToken]:
    _gate(actor, workspace)
    account = _account(workspace, account_id)
    return list(
        ApiToken.objects.filter(workspace=workspace, owner_id=account.user_id).order_by(
            "-created_at"
        )
    )


def create_token(
    actor: Any,
    workspace: Workspace,
    account_id: str,
    name: str,
    wanted_scopes: Any,
    expires_in_days: int = 0,
) -> services.Issued:
    _gate(actor, workspace)
    account = _account(workspace, account_id)
    member = _member(account)
    if member is None or member.status != MemberStatus.ACTIVE:
        raise _invalid("This service account was removed from the workspace.")
    return services.mint_token(
        actor,
        workspace,
        account.user,
        name,
        wanted_scopes,
        expires_in_days,
        service_account=account.name,
    )
