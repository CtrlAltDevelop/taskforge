"""A private project is invisible on EVERY query to everyone who is not in it.

Rows: open/private project x (owner, admin, member, viewer, project member, outsider).
Columns: list, get, update, favorite, features, members, numbering (+ archive, add/remove member).
"""

import re
from collections.abc import Callable
from pathlib import Path
from typing import Any

import pytest

from infrastructure.common.errors import ApiError
from infrastructure.projects import members, services
from infrastructure.workspaces import access

from .conftest import Team

Action = tuple[str, str, Callable[[Any, Team, str], Any]]  # name, permission, call
ACTIONS: tuple[Action, ...] = (
    ("get", "workspace.view", lambda u, t, p: services.get(u, t.ws, p)),
    ("favorite", "workspace.view", lambda u, t, p: services.favorite(u, t.ws, p, True)),
    ("members", "workspace.view", lambda u, t, p: members.list_members(u, t.ws, p)),
    ("update", "project.update", lambda u, t, p: services.update(u, t.ws, p, 1, name="Renamed")),
    (
        "features",
        "project.update",
        lambda u, t, p: services.set_features(u, t.ws, p, ["sprints"], 1),
    ),
    ("archive", "project.archive", lambda u, t, p: services.archive(u, t.ws, p, 1)),
    ("numbering", "", lambda u, t, p: services.number_task(u, t.ws, p)),
)
ROLES = ("owner", "admin", "member", "viewer")


@pytest.mark.parametrize("role", ROLES)
@pytest.mark.parametrize(("name", "permission", "call"), ACTIONS, ids=[a[0] for a in ACTIONS])
def test_non_members_of_a_private_project_are_refused_on_every_call(
    team: Team, role: str, name: str, permission: str, call: Any
) -> None:
    project_id = str(team.create(team.pm, "SEC", "private").pk)  # only ``pm`` is in it
    actor = getattr(team, role)
    holds = not permission or access.can(actor, permission, team.ws).allowed

    with pytest.raises(ApiError) as refusal:
        call(actor, team, project_id)

    assert refusal.value.status == (404 if holds else 403), f"{role} {name}"


@pytest.mark.parametrize(("name", "permission", "call"), ACTIONS, ids=[a[0] for a in ACTIONS])
def test_a_project_member_with_the_key_can_use_a_private_project(
    team: Team, name: str, permission: str, call: Any
) -> None:
    project_id = str(team.create(team.admin, "SEC", "private").pk)  # admin is the member

    call(team.admin, team, project_id)  # no refusal
    assert name


def test_a_project_member_without_the_key_still_cannot_write(team: Team) -> None:
    project_id = str(team.create(team.member, "SEC", "private").pk)
    members.add_member(team.member, team.ws, project_id, str(team.pm.pk))

    assert services.get(team.pm, team.ws, project_id)  # can see
    with pytest.raises(ApiError) as refusal:
        services.update(team.pm, team.ws, project_id, 1, name="x")
    assert refusal.value.status == 403


@pytest.mark.parametrize("role", [*ROLES, "outsider"])
def test_open_projects_are_visible_to_every_workspace_member(team: Team, role: str) -> None:
    project_id = str(team.create(team.owner, "WEB").pk)
    actor = getattr(team, role)

    if role == "outsider":
        with pytest.raises(ApiError) as refusal:
            services.get(actor, team.ws, project_id)
        assert refusal.value.status == 403
        return
    assert services.get(actor, team.ws, project_id).can_open
    assert [v.project.key for v in services.list_projects(actor, team.ws)] == ["WEB"]


def test_list_shows_private_projects_only_to_their_members(team: Team) -> None:
    team.create(team.owner, "WEB", name="Web")
    team.create(team.pm, "SEC", "private", name="Secret")

    def keys(user: Any) -> list[str]:
        return [v.project.key for v in services.list_projects(user, team.ws)]

    assert keys(team.pm) == ["SEC", "WEB"]  # by name: Secret, Web
    assert [keys(u) for u in (team.owner, team.admin, team.member, team.viewer)] == [["WEB"]] * 4


def test_a_private_project_hidden_from_lookup_is_the_same_error_as_a_missing_one(
    team: Team,
) -> None:
    hidden = str(team.create(team.member, "SEC", "private").pk)
    missing = "00000000-0000-0000-0000-000000000000"

    errors = []
    for project_id in (hidden, missing):
        with pytest.raises(ApiError) as refusal:
            services.get(team.owner, team.ws, project_id)
        errors.append((refusal.value.status, refusal.value.title, str(refusal.value)))

    assert errors[0] == errors[1]


def test_making_a_project_private_hides_it_from_others_at_once(team: Team) -> None:
    p = team.create(team.owner, "WEB")
    assert services.get(team.viewer, team.ws, str(p.pk))

    services.update(team.owner, team.ws, str(p.pk), 1, visibility="private")

    with pytest.raises(ApiError) as refusal:
        services.get(team.viewer, team.ws, str(p.pk))
    assert refusal.value.status == 404


def test_every_project_read_goes_through_visible_to() -> None:
    """Source guard: services must reach ``Project`` rows only via ``visible_to`` (or by the
    pk of a row it already loaded through it), so a new query cannot bypass visibility."""
    allowed = re.compile(
        r"Project\.objects\.(visible_to\(|create\(|filter\(pk=project\.pk|get\(pk=project\.pk"
        r"|values_list\(\"task_counter\")"
    )
    package = Path(__file__).parent.parent
    for module in ("services.py", "members.py"):
        for line in (package / module).read_text(encoding="utf-8").splitlines():
            if "Project.objects." in line and "``" not in line:
                assert allowed.search(line), f"{module}: {line.strip()}"
