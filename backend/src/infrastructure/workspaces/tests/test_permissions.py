"""Registry, seeding, ``can``/``require`` and the built-in grants."""

from typing import Any

import pytest
from django.db import connection
from django.db.migrations.executor import MigrationExecutor

from infrastructure.common.errors import ApiError
from infrastructure.common.responses import ResponseTitle
from infrastructure.workspaces import access, services
from infrastructure.workspaces.models import Role, RolePermission, WorkspaceMember
from infrastructure.workspaces.registry import (
    ALL_KEYS,
    BUILTIN_GRANTS,
    BUILTIN_ROLES,
    PERMISSIONS,
    areas,
)
from infrastructure.workspaces.seed import grant_to_builtins, migrated_grants


@pytest.fixture
def team(alice: Any, make_user: Any, add_member: Any) -> tuple[Any, dict[str, Any]]:
    workspace = services.create(alice, "Acme", "acme")
    users = {"Owner": alice}
    for role in ("Admin", "Member", "Viewer"):
        users[role] = make_user(role.lower())
        add_member(workspace, users[role], role)
    return workspace, users


def _granted(role: Role) -> set[str]:
    return set(RolePermission.objects.filter(role=role).values_list("permission_key", flat=True))


def test_registry_keys_are_unique_and_grouped_by_area() -> None:
    assert len(ALL_KEYS) == len(PERMISSIONS)
    assert [a for a, _ in areas()] == ["workspace", "member", "role"]
    assert all(k in ALL_KEYS for grants in BUILTIN_GRANTS.values() for k in grants)


def test_registry_grants_are_exactly_what_the_migrations_ship() -> None:
    """Adding a key to registry.py without a migration declaring it (ADDED_GRANTS) fails here."""
    assert migrated_grants() == BUILTIN_GRANTS


def test_owner_role_in_database_holds_every_registry_key(db: None) -> None:
    owner = access.builtin_role("Owner")

    assert _granted(owner) == set(ALL_KEYS)


@pytest.mark.parametrize("name", BUILTIN_ROLES)
def test_builtin_roles_in_database_match_the_registry(db: None, name: str) -> None:
    role = Role.objects.get(workspace=None, name=name)

    assert role.is_builtin and _granted(role) == set(BUILTIN_GRANTS[name])


def test_migration_helper_grants_a_new_key_to_named_builtins(db: None) -> None:
    grant_to_builtins(Role, RolePermission, "task.edit", ["Admin", "Member"])

    assert "task.edit" in _granted(access.builtin_role("Admin"))
    assert "task.edit" in _granted(access.builtin_role("Member"))
    assert "task.edit" not in _granted(access.builtin_role("Viewer"))


@pytest.mark.django_db(transaction=True)
def test_backfill_makes_the_creator_owner_and_everyone_else_member(make_user: Any) -> None:
    creator, joiner = make_user("zoe"), make_user("max")
    executor = MigrationExecutor(connection)
    executor.migrate([("workspaces", "0004_roles")])
    old = executor.loader.project_state([("workspaces", "0004_roles")]).apps
    workspace = old.get_model("workspaces", "Workspace").objects.create(
        name="Old", slug="old", created_by_id=creator.pk
    )
    members = old.get_model("workspaces", "WorkspaceMember").objects
    for user, status in ((creator, "active"), (joiner, "removed")):
        members.create(workspace_id=workspace.pk, user_id=user.pk, status=status)

    executor = MigrationExecutor(connection)
    executor.migrate(executor.loader.graph.leaf_nodes())

    roles = {
        m.user_id: m.role.name for m in WorkspaceMember.objects.filter(workspace_id=workspace.pk)
    }
    assert roles == {creator.pk: "Owner", joiner.pk: "Member"}


@pytest.mark.parametrize("role", BUILTIN_ROLES)
@pytest.mark.parametrize("permission", sorted(ALL_KEYS))
def test_can_follows_the_builtin_grants(team: Any, role: str, permission: str) -> None:
    workspace, users = team

    decision = access.can(users[role], permission, workspace)

    allowed = permission in BUILTIN_GRANTS[role]
    assert decision.allowed is allowed and decision.role == role
    assert decision.hint == ("" if allowed else f"missing: {permission}; your role: {role}")


def test_can_denies_outsiders_removed_members_and_nothing(team: Any, make_user: Any) -> None:
    workspace, users = team
    WorkspaceMember.objects.filter(user=users["Admin"]).update(status="removed")

    for actor, resource in (
        (make_user("eve"), workspace),
        (users["Admin"], workspace),
        (users["Owner"], None),
    ):
        decision = access.can(actor, "workspace.view", resource)
        assert (decision.allowed, decision.role, decision.hint) == (False, "", "")


def test_can_rejects_a_key_missing_from_the_registry(team: Any) -> None:
    workspace, users = team

    with pytest.raises(ValueError, match="registry"):
        access.can(users["Owner"], "task.edit", workspace)


def test_require_gives_members_the_reason_and_outsiders_nothing(team: Any, make_user: Any) -> None:
    workspace, users = team

    with pytest.raises(access.PermissionDenied) as denied:
        access.require(users["Viewer"], "workspace.update", workspace)
    with pytest.raises(ApiError) as outsider:
        access.require(make_user("eve"), "workspace.update", workspace)

    assert (
        denied.value.status == 403 and denied.value.title is ResponseTitle.PERMISSION_DENIED_REASON
    )
    assert denied.value.data == {
        "permission": "workspace.update",
        "role": "Viewer",
        "hint": "missing: workspace.update; your role: Viewer",
    }
    assert outsider.value.title is ResponseTitle.FORBIDDEN and outsider.value.data is None


def test_require_returns_the_grant_it_loaded(team: Any) -> None:
    workspace, users = team

    grant = access.require(users["Member"], "member.invite", workspace)

    assert grant.role.name == "Member" and grant.keys == BUILTIN_GRANTS["Member"]


def test_role_change_applies_on_the_very_next_check(team: Any) -> None:
    workspace, users = team
    assert not access.can(users["Viewer"], "member.invite", workspace).allowed

    WorkspaceMember.objects.filter(user=users["Viewer"]).update(role=access.builtin_role("Member"))

    assert access.can(users["Viewer"], "member.invite", workspace).allowed


def test_check_answers_many_keys_and_treats_unknown_ones_as_false(team: Any) -> None:
    workspace, users = team

    grant, answers = access.check(
        users["Viewer"], workspace, ["workspace.view", "role.manage", "nope"]
    )

    assert grant.role.name == "Viewer"
    assert answers == {"workspace.view": True, "role.manage": False, "nope": False}


def test_list_deleted_only_shows_workspaces_the_caller_may_restore(team: Any) -> None:
    workspace, users = team
    services.delete(users["Owner"], str(workspace.id), "Acme")

    assert [w.pk for w in services.list_deleted(users["Owner"])] == [workspace.pk]
    for role in ("Admin", "Member", "Viewer"):
        assert services.list_deleted(users[role]) == []


def test_creator_is_owner_and_workspace_owner_ids_reflect_roles(team: Any) -> None:
    workspace, users = team

    assert access.owner_workspace_ids(users["Owner"]) == {workspace.pk}
    assert access.owner_workspace_ids(users["Admin"]) == set()
