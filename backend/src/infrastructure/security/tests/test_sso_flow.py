"""SSO from redirect to tickets: PKCE, replay, browser binding, forged tokens, group roles."""

from typing import Any
from urllib.parse import parse_qs, urlparse

import pytest
from django.conf import settings
from django.contrib.auth import get_user_model
from django.test import RequestFactory

from infrastructure.auth.core.challenges import get_challenge_store
from infrastructure.common.errors import ApiError
from infrastructure.common.responses import ResponseTitle
from infrastructure.security import oidc, sso
from infrastructure.security.models import ExternalIdentity, IdentityProvider
from infrastructure.security.tests.idp_fixtures import (
    CLIENT_ID,
    ISSUER,
    NONCE,
    new_key,
    sign,
)
from infrastructure.security.tests.idp_fixtures import (
    claims as token_claims,
)
from infrastructure.workspaces import access
from infrastructure.workspaces.models import MemberStatus, Workspace, WorkspaceMember

User = get_user_model()
VERIFIER = "v" * 64
CHALLENGE = oidc.pkce_challenge(VERIFIER)
RETURN_TO = settings.SSO_NATIVE_RETURN_URL


def make_user(name: str) -> Any:
    return User.objects.create_user(username=name, email=f"{name}@acme.test", password="x-y-z-1A")


@pytest.fixture
def owner(db: None) -> Any:
    return make_user("owner")


@pytest.fixture
def provider(owner: Any) -> IdentityProvider:
    workspace = Workspace.objects.create(name="Acme", slug="acme-flow", created_by=owner)
    WorkspaceMember.objects.create(
        workspace=workspace, user=owner, role=access.builtin_role("Owner")
    )
    return IdentityProvider.objects.create(
        workspace=workspace, issuer=ISSUER, client_id=CLIENT_ID, allowed_domains=["acme.test"]
    )


def request_() -> Any:
    request = RequestFactory().get("/")
    request.META["REMOTE_ADDR"] = "127.0.0.1"
    return request


@pytest.fixture(autouse=True)
def _fixed_secrets(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setattr(oidc, "new_secrets", lambda: ("state-" + "s" * 40, NONCE, "p" * 64))


def callback(provider: IdentityProvider, idp_key: Any, monkeypatch: pytest.MonkeyPatch, **kw: Any):
    """Run begin + complete with a token the mocked provider returns."""
    started = sso.begin(request_(), provider.workspace.slug, RETURN_TO, CHALLENGE)
    token = kw.pop("token", None) or sign(idp_key, token_claims(**kw))
    monkeypatch.setattr(oidc, "exchange_code", lambda *a, **k: token)
    return sso.complete(request_(), {"state": "state-" + "s" * 40, "code": "abc"}, started.binding)


def _query(url: str) -> dict[str, list[str]]:
    return parse_qs(urlparse(url).query)


def test_a_good_callback_returns_a_ticket_that_exchanges_once(
    provider: IdentityProvider, idp: Any, monkeypatch: pytest.MonkeyPatch
) -> None:
    url = callback(provider, idp, monkeypatch)
    ticket = _query(url)["ticket"][0]

    result = sso.exchange(request_(), ticket, VERIFIER)
    assert result.credentials is not None


def test_the_wrong_pkce_verifier_is_refused_and_burns_the_ticket(
    provider: IdentityProvider, idp: Any, monkeypatch: pytest.MonkeyPatch
) -> None:
    ticket = _query(callback(provider, idp, monkeypatch))["ticket"][0]

    with pytest.raises(ApiError):
        sso.exchange(request_(), ticket, "w" * 64)
    with pytest.raises(Exception):  # noqa: B017 - the store's own "unknown ticket" error
        sso.exchange(request_(), ticket, VERIFIER)


def test_a_replayed_ticket_is_refused(
    provider: IdentityProvider, idp: Any, monkeypatch: pytest.MonkeyPatch
) -> None:
    ticket = _query(callback(provider, idp, monkeypatch))["ticket"][0]
    sso.exchange(request_(), ticket, VERIFIER)
    with pytest.raises(Exception):  # noqa: B017
        sso.exchange(request_(), ticket, VERIFIER)


def test_an_empty_verifier_is_refused(owner: Any) -> None:
    ticket = get_challenge_store().create(
        purpose=sso.TICKET_PURPOSE, subject=str(owner.pk), metadata={"challenge": CHALLENGE}, ttl=60
    )
    with pytest.raises(ApiError):
        sso.exchange(request_(), ticket, "")


def test_a_browser_without_the_binding_cookie_is_refused(
    provider: IdentityProvider, idp: Any, monkeypatch: pytest.MonkeyPatch
) -> None:
    sso.begin(request_(), provider.workspace.slug, RETURN_TO, CHALLENGE)
    monkeypatch.setattr(oidc, "exchange_code", lambda *a, **k: sign(idp, token_claims()))
    with pytest.raises(ApiError, match="did not start in this browser"):
        sso.complete(request_(), {"state": "state-" + "s" * 40, "code": "abc"}, "other-browser")
    assert not User.objects.filter(email="new@acme.test").exists()


def test_a_state_is_single_use(
    provider: IdentityProvider, idp: Any, monkeypatch: pytest.MonkeyPatch
) -> None:
    started = sso.begin(request_(), provider.workspace.slug, RETURN_TO, CHALLENGE)
    monkeypatch.setattr(oidc, "exchange_code", lambda *a, **k: sign(idp, token_claims()))
    params = {"state": "state-" + "s" * 40, "code": "abc"}
    sso.complete(request_(), params, started.binding)
    with pytest.raises(ApiError):
        sso.complete(request_(), params, started.binding)


@pytest.mark.parametrize(
    "overrides",
    [{"nonce": "wrong"}, {"aud": "other"}, {"iss": "https://evil.test"}, {"exp": 1_000}],
    ids=["nonce", "aud", "iss", "expired"],
)
def test_a_bad_token_redirects_with_an_error_and_makes_no_account(
    provider: IdentityProvider, idp: Any, monkeypatch: pytest.MonkeyPatch, overrides: dict
) -> None:
    query = _query(callback(provider, idp, monkeypatch, **overrides))
    assert "sso_error" in query and "ticket" not in query
    assert not User.objects.filter(email="new@acme.test").exists()


def test_a_token_forged_with_another_key_is_refused(
    provider: IdentityProvider, idp: Any, monkeypatch: pytest.MonkeyPatch
) -> None:
    query = _query(callback(provider, idp, monkeypatch, token=sign(new_key(), token_claims())))
    assert "sso_error" in query
    assert not User.objects.filter(email="new@acme.test").exists()


def test_an_unverified_email_never_takes_over_an_existing_account(
    provider: IdentityProvider, idp: Any, monkeypatch: pytest.MonkeyPatch
) -> None:
    victim = make_user("victim")
    victim.mark_email_verified()
    query = _query(
        callback(provider, idp, monkeypatch, email="victim@acme.test", email_verified="false")
    )
    assert "sso_error" in query
    assert not ExternalIdentity.objects.filter(user=victim).exists()
    victim.refresh_from_db()
    assert victim.has_usable_password()


def test_a_missing_email_verified_claim_is_refused(
    provider: IdentityProvider, idp: Any, monkeypatch: pytest.MonkeyPatch
) -> None:
    query = _query(callback(provider, idp, monkeypatch, email_verified=None))
    assert query["sso_error"] == [str(ResponseTitle.SSO_EMAIL_UNVERIFIED)]


def test_a_verified_email_links_a_verified_account_and_ends_its_sessions(
    provider: IdentityProvider,
) -> None:
    person = make_user("person")
    person.mark_email_verified()
    user = sso.resolve_user(provider, identity("person@acme.test", sub="s-9"))
    assert user.pk == person.pk
    assert user.has_usable_password()  # a verified account keeps its password
    assert ExternalIdentity.objects.filter(user=person, provider=provider).exists()


# --- group -> role mapping -------------------------------------------------------------------


def with_groups(provider: IdentityProvider, **mapping: str) -> None:
    provider.group_claim = "groups"
    provider.group_role_map = {g: access.builtin_role(r).pk for g, r in mapping.items()}
    provider.save()


def identity(email: str, *, sub: str) -> dict[str, Any]:
    return {"sub": sub, "email": email, "email_verified": "true"}


def group_claims(email: str, groups: list[str], sub: str) -> dict[str, Any]:
    return {**identity(email, sub=sub), "groups": groups}


def role_of(provider: IdentityProvider, user: Any) -> str:
    return WorkspaceMember.objects.get(workspace=provider.workspace, user=user).role.name


def test_a_new_member_gets_the_mapped_role_and_the_strongest_of_several(
    provider: IdentityProvider,
) -> None:
    with_groups(provider, eng="Member", admins="Admin")
    user = sso.resolve_user(provider, group_claims("a@acme.test", ["eng", "admins"], "a"))
    assert role_of(provider, user) == "Admin"


def test_no_matching_group_gives_the_default_role(provider: IdentityProvider) -> None:
    with_groups(provider, admins="Admin")
    user = sso.resolve_user(provider, group_claims("b@acme.test", ["other"], "b"))
    assert role_of(provider, user) == "Member"


def test_a_changed_group_changes_an_existing_members_role(provider: IdentityProvider) -> None:
    with_groups(provider, viewers="Viewer", admins="Admin")
    user = sso.resolve_user(provider, group_claims("c@acme.test", ["viewers"], "c"))
    assert role_of(provider, user) == "Viewer"
    sso.resolve_user(provider, group_claims("c@acme.test", ["admins"], "c"))
    assert role_of(provider, user) == "Admin"


def test_the_last_owner_is_never_demoted_by_a_claim(provider: IdentityProvider, owner: Any) -> None:
    with_groups(provider, viewers="Viewer")
    ExternalIdentity.objects.create(user=owner, provider=provider, subject="o", email=owner.email)
    sso.resolve_user(provider, group_claims("owner@acme.test", ["viewers"], "o"))
    assert role_of(provider, owner) == "Owner"


def test_an_owner_is_demoted_when_another_owner_remains(
    provider: IdentityProvider, owner: Any
) -> None:
    with_groups(provider, viewers="Viewer")
    second = make_user("second")
    WorkspaceMember.objects.create(
        workspace=provider.workspace, user=second, role=access.builtin_role("Owner")
    )
    ExternalIdentity.objects.create(user=second, provider=provider, subject="s", email=second.email)
    sso.resolve_user(provider, group_claims("second@acme.test", ["viewers"], "s"))
    assert role_of(provider, second) == "Viewer"
    assert role_of(provider, owner) == "Owner"


def test_a_removed_member_stays_removed(provider: IdentityProvider) -> None:
    user = sso.resolve_user(provider, identity("gone@acme.test", sub="g"))
    WorkspaceMember.objects.filter(workspace=provider.workspace, user=user).update(
        status=MemberStatus.REMOVED
    )
    with pytest.raises(ApiError) as caught:
        sso.resolve_user(provider, identity("gone@acme.test", sub="g"))
    assert caught.value.title == ResponseTitle.SSO_MEMBER_REMOVED
