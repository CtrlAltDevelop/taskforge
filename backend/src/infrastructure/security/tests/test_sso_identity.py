"""Who a verified identity may sign in as: the account-takeover rules of ``sso.resolve_user``."""

from typing import Any

import pytest
from django.contrib.auth import get_user_model

from infrastructure.common.errors import ApiError
from infrastructure.common.responses import ResponseTitle
from infrastructure.security import sso
from infrastructure.security.models import ExternalIdentity, IdentityProvider
from infrastructure.workspaces.models import MemberStatus, Workspace, WorkspaceMember

User = get_user_model()


@pytest.fixture
def provider(db: None) -> IdentityProvider:
    owner = User.objects.create_user(username="owner", email="owner@acme.test", password="x-y-z-1A")
    workspace = Workspace.objects.create(name="Acme", slug="acme-sso", created_by=owner)
    return IdentityProvider.objects.create(
        workspace=workspace,
        issuer="https://idp.test",
        client_id="cid",
        allowed_domains=["acme.test"],
    )


def claims(email: str = "new@acme.test", *, verified: str = "true", sub: str = "sub-1") -> Any:
    return {"sub": sub, "email": email, "email_verified": verified, "name": "New Person"}


def refusal(provider: IdentityProvider, payload: Any) -> ResponseTitle:
    with pytest.raises(ApiError) as caught:
        sso.resolve_user(provider, payload)
    return caught.value.title


def test_unverified_email_is_refused_for_a_new_identity(provider: IdentityProvider) -> None:
    assert refusal(provider, claims(verified="false")) == ResponseTitle.SSO_EMAIL_UNVERIFIED
    assert refusal(provider, claims(verified="")) == ResponseTitle.SSO_EMAIL_UNVERIFIED
    assert not User.objects.filter(email="new@acme.test").exists()


def test_domain_outside_the_allow_list_is_refused(provider: IdentityProvider) -> None:
    assert refusal(provider, claims("x@evil.test")) == ResponseTitle.SSO_DOMAIN_NOT_ALLOWED


def test_no_account_is_made_when_auto_create_is_off(provider: IdentityProvider) -> None:
    provider.auto_create_users = False
    provider.save()
    assert refusal(provider, claims()) == ResponseTitle.SSO_NO_ACCOUNT


def test_a_new_identity_creates_a_verified_member(provider: IdentityProvider) -> None:
    user = sso.resolve_user(provider, claims())
    assert user.email_verified_at is not None
    assert WorkspaceMember.objects.filter(workspace=provider.workspace, user=user).exists()
    again = sso.resolve_user(provider, claims())  # the same subject signs in as the same account
    assert again.pk == user.pk
    assert ExternalIdentity.objects.filter(provider=provider).count() == 1


def test_linking_an_unverified_account_takes_its_password_away(provider: IdentityProvider) -> None:
    squatter = User.objects.create_user(
        username="squat", email="victim@acme.test", password="attacker-pw-1A"
    )
    assert squatter.email_verified_at is None

    user = sso.resolve_user(provider, claims("victim@acme.test", sub="sub-victim"))

    assert user.pk == squatter.pk
    user.refresh_from_db()
    assert not user.has_usable_password()
    assert user.email_verified_at is not None


def test_a_removed_member_cannot_sign_back_in_through_sso(provider: IdentityProvider) -> None:
    user = sso.resolve_user(provider, claims())
    WorkspaceMember.objects.filter(workspace=provider.workspace, user=user).update(
        status=MemberStatus.REMOVED
    )
    assert refusal(provider, claims()) == ResponseTitle.SSO_MEMBER_REMOVED
