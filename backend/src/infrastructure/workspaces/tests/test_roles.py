"""Custom roles, role assignment, escalation, tenant isolation and last-owner rules."""

from typing import Any

import pytest
from django.db.models import Q

from infrastructure.common.errors import ApiError
from infrastructure.common.responses import ResponseTitle
from infrastructure.workspaces import access, invitations, members, roles, services
from infrastructure.workspaces.models import MemberStatus, Role, WorkspaceMember
from infrastructure.workspaces.registry import BUILTIN_GRANTS

# a superset of Member, so it may remove Members (nobody acts on a stronger role)
RECRUITER = ["workspace.view", "member.view", "member.invite", "member.remove", "role.view"]


@pytest.fixture
def team(alice: Any, make_user: Any, add_member: Any) -> tuple[Any, dict[str, Any]]:
    workspace = services.create(alice, "Acme", "acme")
    users = {"Owner": alice}
    for role in ("Admin", "Member", "Viewer"):
        users[role] = make_user(role.lower())
        add_member(workspace, users[role], role)
    return workspace, users


def _role_id(workspace: Any, name: str) -> str:
    return str(
        Role.objects.filter(Q(workspace=workspace) | Q(workspace__isnull=True), name=name).get().pk
    )


def _title(refusal: Any) -> Any:
    return refusal.value.title


def _denied(call: Any, *, missing: str | None = None) -> None:
    with pytest.raises(access.PermissionDenied) as refusal:
        call()
    if missing:
        assert refusal.value.data is not None and refusal.value.data["permission"] == missing


def test_list_shows_builtins_in_order_then_custom_with_counts(team: Any) -> None:
    workspace, users = team
    roles.create_role(workspace, users["Owner"], "Auditor", ["workspace.view"])

    listed = roles.list_roles(workspace, users["Viewer"])

    assert [v.role.name for v in listed] == ["Owner", "Admin", "Member", "Viewer", "Auditor"]
    assert [v.member_count for v in listed] == [1, 1, 1, 1, 0]
    assert set(listed[2].permissions) == BUILTIN_GRANTS["Member"]


def test_custom_role_works_end_to_end(team: Any, make_user: Any) -> None:
    workspace, users = team
    owner, viewer = users["Owner"], users["Viewer"]
    made = roles.create_role(workspace, owner, " Recruiter ", RECRUITER)
    assert made.role.name == "Recruiter" and not made.role.is_builtin
    members.set_role(workspace, owner, str(viewer.pk), str(made.role.pk))

    # exactly the checklist: can invite and remove...
    invitations.create_link(workspace, viewer)
    members.remove(workspace, viewer, str(users["Member"].pk))
    # ...but nothing else
    _denied(lambda: services.rename(viewer, str(workspace.id), "X", 1), missing="workspace.update")
    _denied(lambda: roles.create_role(workspace, viewer, "X", []), missing="role.manage")
    _denied(
        lambda: members.set_role(
            workspace, viewer, str(users["Admin"].pk), _role_id(workspace, "Viewer")
        ),
        missing="member.set_role",
    )

    # updating the role takes effect on the very next call
    roles.update_role(
        workspace, owner, str(made.role.pk), 1, permissions=[*RECRUITER, "workspace.update"]
    )
    assert services.rename(viewer, str(workspace.id), "Renamed", 1).name == "Renamed"
    roles.update_role(
        workspace, owner, str(made.role.pk), 2, name="Sourcer", permissions=["workspace.view"]
    )
    _denied(lambda: invitations.create_link(workspace, viewer), missing="member.invite")

    # delete with reassignment moves the member
    roles.delete_role(workspace, owner, str(made.role.pk), _role_id(workspace, "Viewer"))
    assert not Role.objects.filter(pk=made.role.pk).exists()
    assert WorkspaceMember.objects.get(user=viewer).role.name == "Viewer"


def test_role_names_are_unique_case_insensitively_and_cannot_shadow_builtins(team: Any) -> None:
    workspace, users = team
    owner = users["Owner"]
    roles.create_role(workspace, owner, "Auditor", [])

    for name in ("auditor", "AUDITOR", "admin", "OWNER"):
        with pytest.raises(ApiError) as refusal:
            roles.create_role(workspace, owner, name, [])
        assert _title(refusal) is ResponseTitle.ROLE_NAME_TAKEN and refusal.value.status == 409
    for bad_name in ("", "  ", "x" * 61):
        with pytest.raises(ApiError):
            roles.create_role(workspace, owner, bad_name, [])
    with pytest.raises(ApiError, match="Unknown permissions: task.edit"):
        roles.create_role(workspace, owner, "Other", ["task.edit"])


def test_two_workspaces_may_each_have_a_role_with_the_same_name(team: Any, make_user: Any) -> None:
    workspace, users = team
    other = services.create(make_user("zed"), "Other", "other")

    roles.create_role(workspace, users["Owner"], "Auditor", [])
    roles.create_role(other, other.created_by, "Auditor", [])

    assert Role.objects.filter(name="Auditor").count() == 2


def test_builtin_roles_cannot_be_edited_or_deleted(team: Any) -> None:
    workspace, users = team
    for call in (
        lambda: roles.update_role(
            workspace, users["Owner"], _role_id(workspace, "Admin"), 1, name="X"
        ),
        lambda: roles.delete_role(workspace, users["Owner"], _role_id(workspace, "Admin"), ""),
    ):
        with pytest.raises(ApiError) as refusal:
            call()
        assert _title(refusal) is ResponseTitle.ROLE_BUILTIN and refusal.value.status == 403


def test_viewer_and_member_cannot_manage_roles(team: Any) -> None:
    workspace, users = team
    for role in ("Viewer", "Member"):
        _denied(
            lambda r=role: roles.create_role(workspace, users[r], "X", []), missing="role.manage"
        )


def test_delete_needs_a_reassignment_while_the_role_has_members(team: Any) -> None:
    workspace, users = team
    owner = users["Owner"]
    made = roles.create_role(workspace, owner, "Temp", ["workspace.view"])
    members.set_role(workspace, owner, str(users["Viewer"].pk), str(made.role.pk))

    with pytest.raises(ApiError, match="Choose a role"):
        roles.delete_role(workspace, owner, str(made.role.pk), "")
    with pytest.raises(ApiError, match="different role"):
        roles.delete_role(workspace, owner, str(made.role.pk), str(made.role.pk))
    roles.delete_role(workspace, owner, str(made.role.pk), _role_id(workspace, "Member"))

    assert WorkspaceMember.objects.get(user=users["Viewer"]).role.name == "Member"


def test_a_role_without_members_deletes_without_a_target(team: Any) -> None:
    workspace, users = team
    made = roles.create_role(workspace, users["Owner"], "Empty", [])

    roles.delete_role(workspace, users["Owner"], str(made.role.pk))

    assert not Role.objects.filter(pk=made.role.pk).exists()


# --- escalation -------------------------------------------------------------------------


def test_member_cannot_promote_self(team: Any) -> None:
    workspace, users = team
    for target in ("Owner", "Admin"):
        _denied(
            lambda t=target: members.set_role(
                workspace, users["Member"], str(users["Member"].pk), _role_id(workspace, t)
            ),
            missing="member.set_role",
        )


def test_admin_cannot_make_an_owner_or_touch_one(team: Any) -> None:
    workspace, users = team
    admin, owner_role = users["Admin"], _role_id(workspace, "Owner")

    _denied(
        lambda: members.set_role(workspace, admin, str(admin.pk), owner_role),
        missing="workspace.delete",
    )
    _denied(
        lambda: members.set_role(workspace, admin, str(users["Member"].pk), owner_role),
        missing="workspace.delete",
    )
    _denied(
        lambda: members.set_role(
            workspace, admin, str(users["Owner"].pk), _role_id(workspace, "Viewer")
        ),
        missing="workspace.delete",
    )
    _denied(
        lambda: members.remove(workspace, admin, str(users["Owner"].pk)), missing="workspace.delete"
    )
    assert WorkspaceMember.objects.get(user=users["Owner"]).role.name == "Owner"


def test_admin_manages_lower_roles(team: Any) -> None:
    workspace, users = team

    moved = members.set_role(
        workspace, users["Admin"], str(users["Member"].pk), _role_id(workspace, "Viewer")
    )

    assert moved.role.name == "Viewer"


def test_nobody_hands_out_permissions_they_lack(team: Any) -> None:
    workspace, users = team
    owner, admin = users["Owner"], users["Admin"]
    strong = roles.create_role(workspace, owner, "Strong", ["workspace.view", "workspace.delete"])

    _denied(
        lambda: roles.create_role(workspace, admin, "Mine", ["workspace.delete"]),
        missing="workspace.delete",
    )
    _denied(
        lambda: roles.update_role(workspace, admin, str(strong.role.pk), 1, name="Hijack"),
        missing="workspace.delete",
    )
    _denied(
        lambda: members.set_role(workspace, admin, str(users["Member"].pk), str(strong.role.pk)),
        missing="workspace.delete",
    )
    # a custom role-manager cannot assign roles above their own checklist either
    manager = roles.create_role(
        workspace, owner, "Manager", ["member.view", "member.set_role", "role.view"]
    )
    members.set_role(workspace, owner, str(users["Viewer"].pk), str(manager.role.pk))
    _denied(
        lambda: members.set_role(
            workspace, users["Viewer"], str(users["Member"].pk), _role_id(workspace, "Admin")
        ),
    )


def test_deleting_a_role_cannot_launder_permissions_into_a_stronger_one(team: Any) -> None:
    workspace, users = team
    made = roles.create_role(workspace, users["Owner"], "Temp", [])
    members.set_role(workspace, users["Owner"], str(users["Viewer"].pk), str(made.role.pk))

    _denied(
        lambda: roles.delete_role(
            workspace, users["Admin"], str(made.role.pk), _role_id(workspace, "Owner")
        ),
        missing="workspace.delete",
    )


# --- tenant isolation -------------------------------------------------------------------


@pytest.fixture
def rival(make_user: Any) -> tuple[Any, Any, Any]:
    boss = make_user("boss")
    other = services.create(boss, "Rival", "rival")
    secret = roles.create_role(other, boss, "Secret", ["workspace.view"])
    return other, boss, secret


def test_role_ids_from_another_workspace_are_rejected(team: Any, rival: Any) -> None:
    workspace, users = team
    other, _, secret = rival
    foreign = str(secret.role.pk)
    mine = roles.create_role(workspace, users["Owner"], "Mine", [])

    calls = (
        lambda: members.set_role(workspace, users["Owner"], str(users["Viewer"].pk), foreign),
        lambda: roles.update_role(workspace, users["Owner"], foreign, 1, name="X"),
        lambda: roles.delete_role(workspace, users["Owner"], foreign, ""),
        lambda: roles.delete_role(workspace, users["Owner"], str(mine.role.pk), foreign),
    )
    members.set_role(workspace, users["Owner"], str(users["Viewer"].pk), str(mine.role.pk))
    for call in calls:
        with pytest.raises(ApiError) as refusal:
            call()
        assert refusal.value.status == 404
    assert "Secret" not in [v.role.name for v in roles.list_roles(workspace, users["Owner"])]


def test_admin_of_one_workspace_cannot_touch_anothers_roles_or_members(
    team: Any, rival: Any
) -> None:
    workspace, users = team
    other, boss, secret = rival
    admin = users["Admin"]

    for call in (
        lambda: roles.list_roles(other, admin),
        lambda: roles.create_role(other, admin, "X", []),
        lambda: roles.update_role(other, admin, str(secret.role.pk), 1, name="X"),
        lambda: roles.delete_role(other, admin, str(secret.role.pk), ""),
        lambda: members.list_members(other, admin),
        lambda: members.set_role(other, admin, str(boss.pk), _role_id(workspace, "Viewer")),
        lambda: members.remove(other, admin, str(boss.pk)),
    ):
        with pytest.raises(ApiError) as refusal:
            call()
        assert refusal.value.title is ResponseTitle.FORBIDDEN and refusal.value.data is None


def test_a_member_of_another_workspace_is_not_a_target_here(team: Any, rival: Any) -> None:
    workspace, users = team
    _, boss, _ = rival

    for call in (
        lambda: members.set_role(
            workspace, users["Owner"], str(boss.pk), _role_id(workspace, "Viewer")
        ),
        lambda: members.remove(workspace, users["Owner"], str(boss.pk)),
    ):
        with pytest.raises(ApiError) as refusal:
            call()
        assert refusal.value.status == 404


# --- last owner -------------------------------------------------------------------------


def test_the_last_owner_cannot_be_demoted_removed_or_leave(team: Any) -> None:
    workspace, users = team
    owner = users["Owner"]
    for call in (
        lambda: members.set_role(workspace, owner, str(owner.pk), _role_id(workspace, "Admin")),
        lambda: members.remove(workspace, owner, str(owner.pk)),
        lambda: members.leave(workspace, owner),
    ):
        with pytest.raises(ApiError) as refusal:
            call()
        assert _title(refusal) is ResponseTitle.OWNER_PROTECTED and refusal.value.status == 403
    assert WorkspaceMember.objects.get(user=owner).status == MemberStatus.ACTIVE


def test_with_two_owners_one_may_leave_but_never_the_last(
    team: Any, add_member: Any, make_user: Any
) -> None:
    workspace, users = team
    second = make_user("second")
    add_member(workspace, second, "Owner")

    members.leave(workspace, users["Owner"])

    with pytest.raises(ApiError) as refusal:
        members.leave(workspace, second)
    assert _title(refusal) is ResponseTitle.OWNER_PROTECTED


def test_ownership_transfer_then_old_owner_can_be_demoted_and_removed(team: Any) -> None:
    workspace, users = team
    old, new = users["Owner"], users["Admin"]

    members.set_role(workspace, old, str(new.pk), _role_id(workspace, "Owner"))
    members.set_role(workspace, new, str(old.pk), _role_id(workspace, "Admin"))
    members.remove(workspace, new, str(old.pk))

    assert access.can(new, "workspace.delete", workspace).allowed
    assert not access.can(old, "workspace.view", workspace).allowed


def test_one_owner_removes_the_other_but_not_when_it_would_leave_none(
    team: Any, add_member: Any, make_user: Any
) -> None:
    workspace, users = team
    second = make_user("second")
    add_member(workspace, second, "Owner")

    members.remove(workspace, users["Owner"], str(second.pk))

    with pytest.raises(ApiError) as refusal:
        members.remove(workspace, users["Owner"], str(users["Owner"].pk))
    assert _title(refusal) is ResponseTitle.OWNER_PROTECTED


def test_demoting_one_of_two_owners_is_fine(team: Any, add_member: Any, make_user: Any) -> None:
    workspace, users = team
    second = make_user("second")
    add_member(workspace, second, "Owner")

    moved = members.set_role(
        workspace, second, str(users["Owner"].pk), _role_id(workspace, "Member")
    )

    assert moved.role.name == "Member"


# --- invitations and role resets --------------------------------------------------------


def test_invited_people_join_as_member_and_a_returning_member_loses_their_old_role(
    team: Any, make_user: Any
) -> None:
    workspace, users = team
    newcomer = make_user("newbie")
    invitations.accept(invitations.create_link(workspace, users["Owner"]).token, newcomer)
    assert WorkspaceMember.objects.get(user=newcomer).role.name == "Member"

    members.remove(workspace, users["Owner"], str(users["Admin"].pk))
    invitations.accept(invitations.create_link(workspace, users["Owner"]).token, users["Admin"])

    assert WorkspaceMember.objects.get(user=users["Admin"]).role.name == "Member"


def test_viewer_cannot_use_any_invitation_service(team: Any) -> None:
    workspace, users = team
    viewer = users["Viewer"]

    for call in (
        lambda: invitations.create_invitations(workspace, viewer, ["a@example.com"]),
        lambda: invitations.create_link(workspace, viewer),
        lambda: invitations.list_pending(workspace, viewer),
        lambda: invitations.revoke(workspace, viewer, "00000000-0000-0000-0000-000000000000"),
        lambda: invitations.resend(workspace, viewer, "00000000-0000-0000-0000-000000000000"),
    ):
        _denied(call, missing="member.invite")


def test_new_role_starts_at_version_one_and_every_update_bumps_it(team: Any) -> None:
    workspace, users = team
    owner = users["Owner"]
    made = roles.create_role(workspace, owner, "Auditor", [])

    first = roles.update_role(workspace, owner, str(made.role.pk), 1, name="Auditor 2")
    second = roles.update_role(workspace, owner, str(made.role.pk), 2, permissions=["role.view"])

    assert (made.role.version, first.role.version, second.role.version) == (1, 2, 3)


def test_two_stale_updates_the_second_is_a_version_conflict_and_changes_nothing(
    team: Any,
) -> None:
    workspace, users = team
    owner = users["Owner"]
    made = roles.create_role(workspace, owner, "Auditor", ["workspace.view"])
    role_id = str(made.role.pk)

    roles.update_role(workspace, owner, role_id, 1, name="Winner", permissions=["role.view"])
    for stale in (
        lambda: roles.update_role(workspace, owner, role_id, 1, name="Loser"),
        lambda: roles.update_role(workspace, owner, role_id, 1, permissions=["member.view"]),
    ):
        with pytest.raises(ApiError) as refusal:
            stale()
        assert refusal.value.status == 409 and _title(refusal) is ResponseTitle.VERSION_CONFLICT

    row = Role.objects.get(pk=made.role.pk)
    assert (row.name, row.version) == ("Winner", 2)
    assert roles.view_of(workspace, row).permissions == ["role.view"]
