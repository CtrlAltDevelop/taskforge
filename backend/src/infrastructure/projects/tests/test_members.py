"""Members of private projects and the admin list."""

from typing import Any

import pytest

from infrastructure.common.errors import ApiError
from infrastructure.common.responses import ResponseTitle
from infrastructure.projects import members, services
from infrastructure.projects.models import ProjectMember
from infrastructure.workspaces.models import MemberStatus, WorkspaceMember

from .conftest import Team


def _refusal(call: Any, *args: Any) -> ApiError:
    with pytest.raises(ApiError) as refusal:
        call(*args)
    return refusal.value


def _private(team: Team, creator: Any = None, key: str = "SEC") -> str:
    return str(team.create(creator or team.member, key, "private").pk)


def test_an_admin_joins_a_private_project_by_adding_themselves_then_opens_it(team: Team) -> None:
    pid = _private(team)
    assert _refusal(services.get, team.admin, team.ws, pid).status == 404

    row = members.add_member(team.admin, team.ws, pid, str(team.admin.pk))

    assert row.user_id == team.admin.pk
    assert services.get(team.admin, team.ws, pid).is_member


def test_admin_list_shows_private_projects_without_contents(team: Team) -> None:
    pid = _private(team)
    team.create(team.admin, "OWN", "private")
    team.create(team.owner, "WEB")  # open: not listed

    listed = {v.project.key: v for v in members.list_private(team.owner, team.ws)}

    assert set(listed) == {"SEC", "OWN"}
    assert (listed["SEC"].can_open, listed["SEC"].member_count) == (False, 1)
    assert str(listed["SEC"].project.pk) == pid
    assert members.list_private(team.admin, team.ws)[0].can_open in (True, False)
    mine = {v.project.key: v.can_open for v in members.list_private(team.admin, team.ws)}
    assert mine == {"SEC": False, "OWN": True}


def test_admin_list_needs_the_key(team: Team) -> None:
    assert _refusal(members.list_private, team.member, team.ws).status == 403
    assert _refusal(members.list_private, team.viewer, team.ws).status == 403


def test_an_archived_private_project_stays_recoverable_by_another_admin(team: Team) -> None:
    pid = _private(team, team.admin)
    services.archive(team.admin, team.ws, pid, 1)
    WorkspaceMember.objects.filter(user=team.admin).update(status=MemberStatus.REMOVED)

    (listed,) = members.list_private(team.owner, team.ws)
    assert (str(listed.project.pk), listed.can_open) == (pid, False)
    assert listed.project.archived_at is not None

    restored = services.restore(team.owner, team.ws, pid, listed.project.version)
    assert restored.project.archived_at is None and restored.can_open is False
    members.add_member(team.owner, team.ws, pid, "")
    assert services.get(team.owner, team.ws, pid).is_member


def test_an_empty_user_id_adds_the_caller(team: Team) -> None:
    pid = _private(team)

    row = members.add_member(team.admin, team.ws, pid, "")

    assert row.user_id == team.admin.pk
    assert _refusal(members.add_member, team.admin, team.ws, pid, "not-a-uuid").status == 404


def test_members_must_be_active_members_of_the_workspace(team: Team) -> None:
    pid = _private(team, team.admin)

    assert (
        _refusal(members.add_member, team.owner, team.ws, pid, str(team.outsider.pk)).status == 404
    )
    assert _refusal(members.add_member, team.owner, team.ws, pid, "nope").status == 404
    assert not ProjectMember.objects.filter(user=team.outsider).exists()


def test_adding_twice_is_idempotent(team: Team) -> None:
    pid = _private(team, team.admin)

    members.add_member(team.owner, team.ws, pid, str(team.viewer.pk))
    members.add_member(team.owner, team.ws, pid, str(team.viewer.pk))

    assert ProjectMember.objects.filter(user=team.viewer).count() == 1


def test_open_projects_have_no_members_to_manage(team: Team) -> None:
    p = team.create(team.owner, "WEB")

    assert (
        _refusal(members.add_member, team.owner, team.ws, str(p.pk), str(team.viewer.pk)).status
        == 400
    )


def test_the_last_member_cannot_be_removed(team: Team) -> None:
    pid = _private(team, team.admin)
    members.add_member(team.owner, team.ws, pid, str(team.viewer.pk))

    members.remove_member(team.owner, team.ws, pid, str(team.admin.pk))
    refusal = _refusal(members.remove_member, team.owner, team.ws, pid, str(team.viewer.pk))

    assert refusal.title is ResponseTitle.LAST_MEMBER
    assert [r.user_id for r in members.list_members(team.viewer, team.ws, pid)] == [team.viewer.pk]


def test_a_member_who_left_the_workspace_does_not_count(team: Team) -> None:
    from infrastructure.workspaces import members as workspace_members

    pid = _private(team, team.member)
    members.add_member(team.owner, team.ws, pid, str(team.viewer.pk))
    workspace_members.remove(team.ws, team.owner, str(team.member.pk))

    refusal = _refusal(members.remove_member, team.owner, team.ws, pid, str(team.viewer.pk))

    assert refusal.title is ResponseTitle.LAST_MEMBER
    assert [r.user_id for r in members.list_members(team.viewer, team.ws, pid)] == [team.viewer.pk]


def test_removing_someone_who_is_not_a_member_is_not_found(team: Team) -> None:
    pid = _private(team, team.admin)

    assert (
        _refusal(members.remove_member, team.owner, team.ws, pid, str(team.viewer.pk)).status == 404
    )


def test_member_management_needs_the_key(team: Team) -> None:
    pid = _private(team, team.member)
    members.add_member(team.member, team.ws, pid, str(team.pm.pk))

    for call in (members.add_member, members.remove_member):
        refusal = _refusal(call, team.pm, team.ws, pid, str(team.pm.pk))
        assert refusal.title is ResponseTitle.PERMISSION_DENIED_REASON


def test_member_calls_cannot_reach_another_workspace(team: Team) -> None:
    from infrastructure.projects.models import Project

    foreign = Project.objects.create(
        workspace=team.other_ws, name="F", key="FOR", visibility="private", created_by=team.outsider
    )

    assert (
        _refusal(
            members.add_member, team.owner, team.ws, str(foreign.pk), str(team.admin.pk)
        ).status
        == 404
    )
    assert _refusal(members.list_members, team.owner, team.ws, str(foreign.pk)).status == 404


def test_archived_private_projects_refuse_member_changes(team: Team) -> None:
    pid = _private(team, team.admin)
    services.archive(team.admin, team.ws, pid, 1)

    refusal = _refusal(members.add_member, team.owner, team.ws, pid, str(team.viewer.pk))

    assert refusal.title is ResponseTitle.PROJECT_ARCHIVED


def test_a_creator_manages_their_own_private_project_members(team: Team) -> None:
    pid = _private(team, team.member)

    members.add_member(team.member, team.ws, pid, str(team.viewer.pk))
    members.remove_member(team.member, team.ws, pid, str(team.viewer.pk))

    assert _refusal(members.list_private, team.member, team.ws).status == 403  # no view_private
