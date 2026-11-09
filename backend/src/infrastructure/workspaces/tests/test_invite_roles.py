"""A role on an invitation: validation, escalation, and what accept assigns."""

from typing import Any

import pytest
from django.db.models import Q

from infrastructure.common.errors import ApiError
from infrastructure.workspaces import access, invitations, members, roles, services
from infrastructure.workspaces.models import Invitation, Role, WorkspaceMember

LIMITED = ["workspace.view", "member.view"]


@pytest.fixture
def team(alice: Any, make_user: Any, add_member: Any) -> tuple[Any, dict[str, Any]]:
    workspace = services.create(alice, "Acme", "acme")
    users = {"Owner": alice}
    for role in ("Admin", "Member"):
        users[role] = make_user(role.lower())
        add_member(workspace, users[role], role)
    return workspace, users


def _rid(workspace: Any, name: str) -> str:
    q = Q(workspace=workspace) | Q(workspace__isnull=True)
    return str(Role.objects.filter(q, name=name).get().pk)


def _role_of(workspace: Any, user: Any) -> str:
    return WorkspaceMember.objects.get(workspace=workspace, user=user).role.name


def test_no_role_means_member(team: Any, make_user: Any) -> None:
    workspace, users = team
    made = invitations.create_invitations(workspace, users["Admin"], ["new@example.com"]).created[0]

    assert made.invitation.role is None
    assert invitations.accept(made.token, make_user("new")).role.name == "Member"


def test_email_invite_carries_its_role_to_accept(team: Any, make_user: Any) -> None:
    workspace, users = team
    made = invitations.create_invitations(
        workspace, users["Admin"], ["new@example.com"], _rid(workspace, "Viewer")
    ).created[0]

    assert made.invitation.role.name == "Viewer"
    assert invitations.accept(made.token, make_user("new")).role.name == "Viewer"


def test_link_invite_carries_its_role_to_every_joiner(team: Any, make_user: Any) -> None:
    workspace, users = team
    custom = roles.create_role(workspace, users["Owner"], "Auditor", LIMITED).role
    link = invitations.create_link(workspace, users["Admin"], role_id=str(custom.pk))

    first, second = make_user("one"), make_user("two")
    invitations.accept(link.token, first)
    invitations.accept(link.token, second)

    assert [_role_of(workspace, u) for u in (first, second)] == ["Auditor", "Auditor"]


def test_owner_can_invite_as_owner_but_admin_cannot(team: Any, make_user: Any) -> None:
    workspace, users = team
    owner_id = _rid(workspace, "Owner")

    with pytest.raises(access.PermissionDenied):
        invitations.create_invitations(workspace, users["Admin"], ["x@example.com"], owner_id)
    with pytest.raises(access.PermissionDenied):
        invitations.create_link(workspace, users["Admin"], role_id=owner_id)
    made = invitations.create_link(workspace, users["Owner"], role_id=owner_id)

    assert invitations.accept(made.token, make_user("co")).role.name == "Owner"
    assert Invitation.objects.filter(workspace=workspace).count() == 1  # refusals created nothing


def test_inviter_must_hold_every_key_of_a_custom_role(team: Any) -> None:
    workspace, users = team
    # Admin lacks nothing an Admin-grantable role holds, so give a role Admin cannot grant:
    owner_only = next(
        k
        for k in access.role_keys(Role.objects.get(name="Owner", workspace=None))
        if k not in access.role_keys(Role.objects.get(name="Admin", workspace=None))
    )
    role = roles.create_role(workspace, users["Owner"], "Deleter", [owner_only]).role

    with pytest.raises(access.PermissionDenied) as refusal:
        invitations.create_link(workspace, users["Admin"], role_id=str(role.pk))
    assert refusal.value.data is not None and refusal.value.data["permission"] == owner_only


def test_a_role_of_another_workspace_or_junk_is_not_found(
    team: Any, make_user: Any, add_member: Any
) -> None:
    workspace, users = team
    other = services.create(make_user("eve"), "Other", "other")
    foreign = roles.create_role(other, other.created_by, "Spy", LIMITED).role

    for bad in (str(foreign.pk), "999999", "abc"):
        with pytest.raises(ApiError) as refusal:
            invitations.create_link(workspace, users["Owner"], role_id=bad)
        assert refusal.value.status == 404
        with pytest.raises(ApiError) as refusal:
            invitations.create_invitations(workspace, users["Owner"], ["a@example.com"], bad)
        assert refusal.value.status == 404


def test_role_deleted_before_accept_falls_back_to_member(team: Any, make_user: Any) -> None:
    workspace, users = team
    role = roles.create_role(workspace, users["Owner"], "Temp", LIMITED).role
    link = invitations.create_link(workspace, users["Owner"], role_id=str(role.pk))

    roles.delete_role(workspace, users["Owner"], str(role.pk))

    assert Invitation.objects.get(workspace=workspace).role is None
    assert invitations.accept(link.token, make_user("late")).role.name == "Member"


def test_resend_keeps_the_role(team: Any, make_user: Any) -> None:
    workspace, users = team
    made = invitations.create_invitations(
        workspace, users["Admin"], ["new@example.com"], _rid(workspace, "Viewer")
    ).created[0]

    again = invitations.resend(workspace, users["Admin"], str(made.invitation.pk))

    assert invitations.accept(again.token, make_user("new")).role.name == "Viewer"


def test_returning_removed_member_gets_the_invited_role(team: Any, make_user: Any) -> None:
    workspace, users = team
    bob = make_user("bob")
    first = invitations.create_invitations(workspace, users["Owner"], ["bob@example.com"]).created[
        0
    ]
    invitations.accept(first.token, bob)
    members.set_role(workspace, users["Owner"], str(bob.pk), _rid(workspace, "Admin"))
    members.remove(workspace, users["Owner"], str(bob.pk))

    again = invitations.create_invitations(
        workspace, users["Owner"], ["bob@example.com"], _rid(workspace, "Viewer")
    ).created[0]

    assert invitations.accept(again.token, bob).role.name == "Viewer"
