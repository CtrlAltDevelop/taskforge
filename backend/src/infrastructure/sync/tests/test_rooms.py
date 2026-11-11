"""Who may join which room."""

from typing import Any

import pytest

from infrastructure.sync import rooms
from infrastructure.workspaces import members

pytestmark = pytest.mark.django_db


def test_a_member_may_join_the_workspace_and_an_open_project(team: Any, project: Any) -> None:
    assert rooms.may_join(team.viewer, f"ws:{team.ws.pk}")
    assert rooms.may_join(team.viewer, f"proj:{project.pk}")


def test_an_outsider_may_join_neither(team: Any, project: Any) -> None:
    assert not rooms.may_join(team.outsider, f"ws:{team.ws.pk}")
    assert not rooms.may_join(team.outsider, f"proj:{project.pk}")


def test_a_private_project_is_for_its_members_only(team: Any) -> None:
    secret = team.create(team.pm, "SEC", visibility="private", name="Secret")

    assert rooms.may_join(team.pm, f"proj:{secret.pk}")
    assert not rooms.may_join(team.member, f"proj:{secret.pk}")
    assert not rooms.may_join(team.viewer, f"proj:{secret.pk}")


def test_a_user_room_is_for_that_user_alone(team: Any) -> None:
    assert rooms.may_join(team.member, f"user:{team.member.pk}")
    assert not rooms.may_join(team.owner, f"user:{team.member.pk}")


def test_a_removed_member_may_no_longer_join(team: Any, project: Any) -> None:
    members.remove(team.ws, team.owner, str(team.member.pk))

    assert not rooms.may_join(team.member, f"ws:{team.ws.pk}")
    assert not rooms.may_join(team.member, f"proj:{project.pk}")


@pytest.mark.parametrize(
    "room", ["", "ws", "ws:", "ws:not-a-uuid", "task:00000000-0000-0000-0000-000000000000", "ws:1"]
)
def test_anything_else_is_not_a_room(team: Any, room: str) -> None:
    assert rooms.parse(room) is None
    assert not rooms.may_join(team.owner, room)


def test_a_project_that_does_not_exist_is_refused_like_any_other(team: Any) -> None:
    assert not rooms.may_join(team.owner, "proj:00000000-0000-0000-0000-000000000000")


def test_nobody_is_not_a_member() -> None:
    assert not rooms.may_join(None, "ws:00000000-0000-0000-0000-000000000000")
