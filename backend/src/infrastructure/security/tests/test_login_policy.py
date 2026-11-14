"""Sign-in policy: SSO-only workspaces, the 2FA grace period, trusted devices."""

from datetime import timedelta
from typing import Any

import pytest
from django.contrib.auth import get_user_model
from django.core.cache import cache
from django.test import RequestFactory
from django.utils import timezone

from infrastructure.auth.core.flows import complete_login
from infrastructure.auth.password.services import password_service
from infrastructure.auth.twofactor import services as factor_services
from infrastructure.auth.twofactor.models import SecondFactor
from infrastructure.common.errors import ApiError
from infrastructure.common.responses import ResponseTitle
from infrastructure.security import devices, login_policy, policy
from infrastructure.security.models import ExternalIdentity, IdentityProvider, SecurityPolicy
from infrastructure.workspaces import access
from infrastructure.workspaces.models import Workspace, WorkspaceMember

User = get_user_model()


def make_user(name: str) -> Any:
    return User.objects.create_user(username=name, email=f"{name}@acme.test", password="x-y-z-1A")


def request_(**meta: str) -> Any:
    request = RequestFactory().post("/")
    request.META["REMOTE_ADDR"] = "127.0.0.1"
    request.META.update(meta)
    return request


@pytest.fixture
def workspace(db: None) -> Workspace:
    owner = make_user("owner")
    workspace = Workspace.objects.create(name="Acme", slug="acme-pol", created_by=owner)
    WorkspaceMember.objects.create(
        workspace=workspace, user=owner, role=access.builtin_role("Owner")
    )
    return workspace


@pytest.fixture
def member(workspace: Workspace) -> Any:
    user = make_user("member")
    WorkspaceMember.objects.create(
        workspace=workspace, user=user, role=access.builtin_role("Member")
    )
    return user


def enforce_sso(workspace: Workspace) -> IdentityProvider:
    return IdentityProvider.objects.create(
        workspace=workspace, issuer="https://idp.test", client_id="cid", enforce_sso=True
    )


# --- enforce_sso ---------------------------------------------------------------------------


def test_enforce_sso_refuses_a_password_login_for_a_member(
    workspace: Workspace, member: Any
) -> None:
    enforce_sso(workspace)
    with pytest.raises(ApiError) as caught:
        login_policy.check_first_factor(member, "password")
    assert caught.value.title == ResponseTitle.SSO_REQUIRED


def test_enforce_sso_lets_the_owner_in_by_password(workspace: Workspace) -> None:
    enforce_sso(workspace)
    owner = User.objects.get(username="owner")
    login_policy.check_first_factor(owner, "password")


def test_enforce_sso_lets_an_sso_login_through(workspace: Workspace, member: Any) -> None:
    enforce_sso(workspace)
    login_policy.check_first_factor(member, "sso")


def test_enforce_sso_is_ignored_when_the_provider_is_disabled(
    workspace: Workspace, member: Any
) -> None:
    provider = enforce_sso(workspace)
    IdentityProvider.objects.filter(pk=provider.pk).update(enabled=False)
    login_policy.check_first_factor(member, "password")


def test_complete_login_refuses_a_password_login_in_an_sso_only_workspace(
    workspace: Workspace, member: Any
) -> None:
    enforce_sso(workspace)
    with pytest.raises(ApiError):
        complete_login(request_(), member, method="password")


# --- policy.check and the grace period -----------------------------------------------------


def set_policy(workspace: Workspace, *, enforced_from: Any) -> None:
    SecurityPolicy.objects.update_or_create(
        workspace=workspace, defaults={"require_2fa": True, "enforced_from": enforced_from}
    )
    cache.delete(policy._cache_key(workspace.pk))


def test_nothing_is_enforced_during_the_grace_period(workspace: Workspace, member: Any) -> None:
    set_policy(workspace, enforced_from=timezone.now() + timedelta(days=3))
    policy.check(member, workspace)


def test_a_member_without_2fa_is_blocked_after_the_grace_period(
    workspace: Workspace, member: Any
) -> None:
    set_policy(workspace, enforced_from=timezone.now() - timedelta(minutes=1))
    with pytest.raises(ApiError) as caught:
        policy.check(member, workspace)
    assert caught.value.title == ResponseTitle.TWO_FACTOR_REQUIRED


def test_a_member_covered_by_sso_is_not_blocked(workspace: Workspace, member: Any) -> None:
    provider = enforce_sso(workspace)
    ExternalIdentity.objects.create(user=member, provider=provider, subject="m", email=member.email)
    set_policy(workspace, enforced_from=timezone.now() - timedelta(minutes=1))
    policy.check(member, workspace)


def test_a_member_with_totp_is_not_blocked(
    workspace: Workspace, member: Any, monkeypatch: pytest.MonkeyPatch
) -> None:
    _, _, _ = factor_services.begin_totp(member)
    SecondFactor.objects.get(user=member).confirm()
    set_policy(workspace, enforced_from=timezone.now() - timedelta(minutes=1))
    policy.check(member, workspace)


# --- trusted devices -----------------------------------------------------------------------


@pytest.fixture
def enrolled(member: Any) -> Any:
    factor_services.begin_totp(member)
    SecondFactor.objects.get(user=member).confirm()
    return member


def test_without_a_trusted_device_a_second_factor_is_asked(enrolled: Any) -> None:
    assert complete_login(request_(), enrolled, method="password").requires_second_factor


def test_a_trusted_device_skips_the_second_factor(enrolled: Any) -> None:
    token = devices.trust(request_(), enrolled, "laptop")
    result = complete_login(request_(HTTP_X_TRUSTED_DEVICE=token), enrolled, method="password")
    assert result.credentials is not None


def test_another_users_trusted_device_does_not_skip(enrolled: Any, workspace: Workspace) -> None:
    token = devices.trust(request_(), User.objects.get(username="owner"), "laptop")
    result = complete_login(request_(HTTP_X_TRUSTED_DEVICE=token), enrolled, method="password")
    assert result.requires_second_factor


def test_an_expired_or_revoked_device_does_not_skip(enrolled: Any) -> None:
    token = devices.trust(request_(), enrolled, "laptop")
    devices.revoke(enrolled)
    result = complete_login(request_(HTTP_X_TRUSTED_DEVICE=token), enrolled, method="password")
    assert result.requires_second_factor


def test_a_password_change_revokes_trusted_devices(enrolled: Any) -> None:
    token = devices.trust(request_(), enrolled, "laptop")
    assert devices.is_trusted(request_(HTTP_X_TRUSTED_DEVICE=token), enrolled)

    password_service.change(
        request_(), enrolled, current_password="x-y-z-1A", new_password="Brand-new-pw-9z!"
    )

    assert devices.active(enrolled) == []
    assert not devices.is_trusted(request_(HTTP_X_TRUSTED_DEVICE=token), enrolled)
