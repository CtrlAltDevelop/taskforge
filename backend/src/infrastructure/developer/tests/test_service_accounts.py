"""Service accounts: a workspace-owned identity with a role, whose tokens are not a person's."""

import json
from typing import Any

import pytest
from django.core.cache import cache
from django.test import Client

from infrastructure.audit.models import AuditEntry
from infrastructure.common.errors import ApiError
from infrastructure.developer import service_accounts as accounts
from infrastructure.developer import services, tokens
from infrastructure.developer.models import ApiToken
from infrastructure.projects.tests import conftest as project_fixtures
from infrastructure.tasks.models import Task
from infrastructure.workspaces import roles
from infrastructure.workspaces.access import PermissionDenied, builtin_role

make_user = project_fixtures.make_user
add_member = project_fixtures.add_member
_commit_hooks_run_now = project_fixtures._commit_hooks_run_now
team = project_fixtures.team


@pytest.fixture
def project(team: Any) -> Any:
    return team.create(team.owner, "WEB")


def _role(name: str) -> str:
    return str(builtin_role(name).pk)


def _bot(team: Any, role: str = "Member", name: str = "CI bot") -> Any:
    return accounts.create_account(team.admin, team.ws, name, _role(role))


def _post_task(team: Any, project: Any, secret: str) -> Any:
    return Client().post(
        f"/api/v1/workspaces/{team.ws.pk}/projects/{project.pk}/tasks",
        data=json.dumps({"title": "From a bot"}),
        content_type="application/json",
        HTTP_AUTHORIZATION=f"Bearer {secret}",
    )


# ---- making and listing ---------------------------------------------------------------------


def test_an_admin_makes_a_service_account_with_a_role(team: Any) -> None:
    view = _bot(team)

    assert view.account.name == "CI bot" and view.role.name == "Member" and view.active
    assert accounts.list_accounts(team.owner, team.ws)[0].account.pk == view.account.pk
    user = view.account.user
    assert not user.has_usable_password() and user.email is None and user.is_active


def test_an_ordinary_member_may_not_manage_service_accounts(team: Any) -> None:
    with pytest.raises(PermissionDenied):
        accounts.create_account(team.member, team.ws, "x", _role("Member"))
    with pytest.raises(PermissionDenied):
        accounts.list_accounts(team.member, team.ws)


def test_a_service_account_cannot_be_an_owner(team: Any) -> None:
    with pytest.raises(ApiError) as refused:
        accounts.create_account(team.owner, team.ws, "x", _role("Owner"))
    assert refused.value.status == 400


def test_nobody_hands_out_more_than_they_hold(team: Any) -> None:
    # A role that may only manage webhooks cannot make a bot that may do more.
    role = roles.create_role(team.ws, team.owner, "Integrations", ["webhook.manage"])
    from infrastructure.workspaces import members

    members.set_role(team.ws, team.owner, str(team.viewer.pk), str(role.role.pk))
    with pytest.raises(PermissionDenied):
        accounts.create_account(team.viewer, team.ws, "x", _role("Admin"))


def test_two_accounts_cannot_share_a_name_but_a_deleted_one_frees_it(team: Any) -> None:
    first = _bot(team)
    with pytest.raises(ApiError):
        _bot(team, name="ci BOT")
    accounts.delete_account(team.admin, team.ws, str(first.account.pk))
    assert _bot(team).account.pk != first.account.pk


def test_the_number_of_accounts_is_capped(team: Any, settings: Any) -> None:
    settings.DEVELOPER_MAX_SERVICE_ACCOUNTS = 1
    _bot(team)
    with pytest.raises(ApiError):
        _bot(team, name="second")


def test_an_account_is_the_workspaces_own_not_another_tenants(team: Any) -> None:
    view = _bot(team)
    with pytest.raises(ApiError) as hidden:
        accounts.delete_account(team.outsider, team.other_ws, str(view.account.pk))
    assert hidden.value.status == 404


# ---- tokens ---------------------------------------------------------------------------------


def test_a_service_token_acts_as_the_account_with_role_and_scopes(team: Any, project: Any) -> None:
    view = _bot(team, "Member")
    issued = accounts.create_token(
        team.admin, team.ws, str(view.account.pk), "deploy", ["tasks:write"]
    )

    response = _post_task(team, project, issued.secret)

    assert response.status_code == 201, response.content
    assert Task.objects.get().created_by_id == view.account.user_id


def test_the_role_caps_the_token_so_a_viewer_bot_cannot_write(team: Any, project: Any) -> None:
    view = _bot(team, "Viewer")
    issued = accounts.create_token(team.admin, team.ws, str(view.account.pk), "ro", ["tasks:write"])

    response = _post_task(team, project, issued.secret)

    assert response.status_code == 403
    assert Task.objects.count() == 0


def test_the_secret_is_shown_once_and_only_its_hash_is_kept(team: Any) -> None:
    view = _bot(team)
    issued = accounts.create_token(team.admin, team.ws, str(view.account.pk), "t", ["tasks:read"])

    row = ApiToken.objects.get(pk=issued.token.pk)

    assert issued.secret.startswith("tf_") and row.hash == tokens.digest(issued.secret)
    assert issued.secret not in json.dumps([row.hash, row.prefix, row.name])
    listed = accounts.list_tokens(team.admin, team.ws, str(view.account.pk))
    assert [t.pk for t in listed] == [row.pk]


def test_service_tokens_stay_out_of_a_persons_own_list(team: Any) -> None:
    view = _bot(team)
    accounts.create_token(team.admin, team.ws, str(view.account.pk), "t", ["tasks:read"])
    mine = services.create_token(team.admin, team.ws, "mine", ["tasks:read"])

    assert [t.pk for t in services.list_tokens(team.admin, team.ws)] == [mine.token.pk]


def test_a_service_account_cannot_manage_tokens_or_webhooks(team: Any) -> None:
    view = _bot(team)
    issued = accounts.create_token(team.admin, team.ws, str(view.account.pk), "t", ["tasks:read"])
    bot = tokens.authenticate(issued.secret)

    with pytest.raises(ApiError) as refused:
        services.create_token(bot, team.ws, "more", ["tasks:read"])
    assert refused.value.status == 403


def test_only_those_who_manage_may_make_or_revoke_a_service_token(team: Any) -> None:
    view = _bot(team)
    issued = accounts.create_token(team.admin, team.ws, str(view.account.pk), "t", ["tasks:read"])

    with pytest.raises(PermissionDenied):
        accounts.create_token(team.member, team.ws, str(view.account.pk), "x", ["tasks:read"])
    with pytest.raises(ApiError) as hidden:
        services.revoke_token(team.member, team.ws, str(issued.token.pk))
    assert hidden.value.status == 404
    assert services.revoke_token(team.owner, team.ws, str(issued.token.pk)).revoked_at
    assert tokens.authenticate(issued.secret) is None


def test_a_persons_own_revoke_still_works_and_is_still_theirs_alone(team: Any) -> None:
    mine = services.create_token(team.member, team.ws, "mine", ["tasks:read"])
    with pytest.raises(ApiError):
        services.revoke_token(team.viewer, team.ws, str(mine.token.pk))
    assert services.revoke_token(team.member, team.ws, str(mine.token.pk)).revoked_at


def test_a_token_is_for_one_account_per_the_limit(team: Any, settings: Any) -> None:
    settings.DEVELOPER_MAX_TOKENS = 1
    view = _bot(team)
    accounts.create_token(team.admin, team.ws, str(view.account.pk), "a", ["tasks:read"])
    with pytest.raises(ApiError):
        accounts.create_token(team.admin, team.ws, str(view.account.pk), "b", ["tasks:read"])


# ---- role, delete, policy -------------------------------------------------------------------


def test_changing_the_role_changes_what_the_token_may_do(team: Any, project: Any) -> None:
    view = _bot(team, "Member")
    issued = accounts.create_token(team.admin, team.ws, str(view.account.pk), "t", ["tasks:write"])
    assert _post_task(team, project, issued.secret).status_code == 201

    accounts.set_role(team.admin, team.ws, str(view.account.pk), _role("Viewer"))

    assert _post_task(team, project, issued.secret).status_code == 403


def test_deleting_an_account_ends_its_tokens_and_membership(team: Any, project: Any) -> None:
    view = _bot(team)
    issued = accounts.create_token(team.admin, team.ws, str(view.account.pk), "t", ["tasks:write"])

    accounts.delete_account(team.admin, team.ws, str(view.account.pk))
    cache.clear()

    assert _post_task(team, project, issued.secret).status_code == 401
    assert accounts.list_accounts(team.admin, team.ws) == []
    view.account.user.refresh_from_db()
    assert not view.account.user.is_active


def test_required_two_factor_does_not_lock_a_bot_out(team: Any) -> None:
    from datetime import timedelta

    from django.utils import timezone

    from infrastructure.security import policy
    from infrastructure.security.models import SecurityPolicy

    SecurityPolicy.objects.create(
        workspace=team.ws, require_2fa=True, enforced_from=timezone.now() - timedelta(days=1)
    )
    cache.clear()
    view = _bot(team)

    assert policy.is_blocked(team.member, team.ws)
    assert not policy.is_blocked(view.account.user, team.ws)


def test_the_audit_log_names_the_account_and_never_the_secret(team: Any) -> None:
    view = _bot(team)
    issued = accounts.create_token(team.admin, team.ws, str(view.account.pk), "t", ["tasks:read"])
    accounts.set_role(team.admin, team.ws, str(view.account.pk), _role("Viewer"))
    services.revoke_token(team.admin, team.ws, str(issued.token.pk))
    accounts.delete_account(team.admin, team.ws, str(view.account.pk))

    actions = list(AuditEntry.objects.values_list("action", flat=True))

    for expected in (
        "serviceaccount.created",
        "serviceaccount.role_changed",
        "serviceaccount.deleted",
        "token.created",
        "token.revoked",
    ):
        assert expected in actions
    everything = json.dumps(list(AuditEntry.objects.values_list("changes", flat=True)))
    assert issued.secret not in everything and issued.token.hash not in everything
    created = AuditEntry.objects.get(action="token.created")
    assert created.changes["service_account"] == "CI bot"
