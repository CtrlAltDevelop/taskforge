"""Taking access away (or changing it) tells the person's sockets to check their rooms."""

from typing import Any

import pytest

from infrastructure.projects import members as project_members
from infrastructure.projects import services as projects
from infrastructure.workspaces import members, roles

pytestmark = pytest.mark.django_db


def _access(broker: Any) -> list[str]:
    return [p["room"] for _, p in broker.sent if p["event"]["type"] == "access.changed"]


def test_removing_a_member_tells_that_member(team: Any, broker: Any) -> None:
    members.remove(team.ws, team.owner, str(team.member.pk))

    assert _access(broker) == [f"user:{team.member.pk}"]


def test_leaving_tells_the_leaver(team: Any, broker: Any) -> None:
    members.leave(team.ws, team.member)

    assert _access(broker) == [f"user:{team.member.pk}"]


def test_a_new_role_for_a_member_tells_that_member(team: Any, broker: Any) -> None:
    viewer_role = roles.list_roles(team.ws, team.owner)
    target = next(v.role for v in viewer_role if v.role.name == "Viewer")

    members.set_role(team.ws, team.owner, str(team.member.pk), str(target.pk))

    assert _access(broker) == [f"user:{team.member.pk}"]


def test_a_member_given_the_role_they_already_have_changes_nothing(team: Any, broker: Any) -> None:
    current = next(v.role for v in roles.list_roles(team.ws, team.owner) if v.role.name == "Member")

    members.set_role(team.ws, team.owner, str(team.member.pk), str(current.pk))

    assert _access(broker) == []


def test_editing_a_roles_permissions_tells_the_workspace(team: Any, broker: Any) -> None:
    made = roles.create_role(team.ws, team.owner, "Reader", ["workspace.view"])

    roles.update_role(team.ws, team.owner, str(made.role.pk), made.role.version, name="Reader 2")

    assert _access(broker) == [f"ws:{team.ws.pk}"]


def test_a_project_member_added_or_removed_tells_that_person(team: Any, broker: Any) -> None:
    secret = team.create(team.pm, "SEC", visibility="private", name="Secret")
    broker.sent.clear()

    project_members.add_member(team.pm, team.ws, str(secret.pk), str(team.member.pk))
    project_members.remove_member(team.pm, team.ws, str(secret.pk), str(team.member.pk))

    assert _access(broker) == [f"user:{team.member.pk}", f"user:{team.member.pk}"]


def test_changing_a_projects_visibility_tells_the_workspace(
    team: Any, project: Any, broker: Any
) -> None:
    broker.sent.clear()

    projects.update(team.owner, team.ws, str(project.pk), project.version, visibility="private")

    assert _access(broker) == [f"ws:{team.ws.pk}"]


def test_the_access_hint_comes_before_the_project_update_when_visibility_changes(
    team: Any, project: Any, broker: Any
) -> None:
    broker.sent.clear()

    projects.update(team.owner, team.ws, str(project.pk), project.version, visibility="private")

    types = [p["event"]["type"] for _, p in broker.sent]
    assert types.index("access.changed") < types.index("project.updated")
