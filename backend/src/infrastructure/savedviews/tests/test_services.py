"""Saved list layouts: who sees, saves, shares and deletes them, and what a layout may hold."""

from typing import Any

import pytest

from infrastructure.common.errors import ApiError
from infrastructure.common.responses import ResponseTitle
from infrastructure.customfields import services as fields
from infrastructure.projects import services as projects
from infrastructure.savedviews import services
from infrastructure.savedviews.models import SavedView
from infrastructure.workspaces import access

pytestmark = pytest.mark.django_db

CONFIG = {
    "columns": ["status", "due_date"],
    "widths": {"title": 320, "status": 120},
    "sort": [{"key": "due_date", "desc": True}],
    "group_by": "status",
}


def _save(team: Any, project: Any, who: Any = None, **kw: Any) -> SavedView:
    kw.setdefault("name", "Mine")
    kw.setdefault("config", CONFIG)
    return services.save(who or team.member, team.ws, str(project.pk), **kw)


def _names(team: Any, project: Any, who: Any) -> list[str]:
    return [v.name for v in services.list_views(who, team.ws, str(project.pk))]


def test_a_layout_round_trips(team: Any, project: Any) -> None:
    view = _save(team, project)

    [back] = services.list_views(team.member, team.ws, str(project.pk))

    assert back.pk == view.pk
    assert back.config == CONFIG
    assert back.owner_id == team.member.pk
    assert (back.is_shared, back.version, back.kind) == (False, 1, "list")


def test_an_empty_layout_is_the_default_and_fills_in_every_key(team: Any, project: Any) -> None:
    view = _save(team, project, config={})

    assert view.config == {"columns": [], "widths": {}, "sort": [], "group_by": ""}


def test_personal_layouts_are_private_and_shared_ones_are_seen_by_everyone(
    team: Any, project: Any
) -> None:
    _save(team, project, name="mine")
    _save(team, project, who=team.viewer, name="viewer's")  # a read-only role keeps a layout too
    _save(team, project, who=team.admin, name="team", shared=True)

    assert _names(team, project, team.member) == ["team", "mine"]
    assert _names(team, project, team.viewer) == ["team", "viewer's"]


def test_changing_a_layout_needs_the_current_version(team: Any, project: Any) -> None:
    view = _save(team, project)

    changed = _save(team, project, view_id=str(view.pk), expected_version=1, name="Renamed")
    with pytest.raises(ApiError) as stale:
        _save(team, project, view_id=str(view.pk), expected_version=1, name="Late")

    assert (changed.name, changed.version) == ("Renamed", 2)
    assert stale.value.title is ResponseTitle.VERSION_CONFLICT
    assert stale.value.data == {"version": 2}


def test_sharing_takes_the_manage_permission_and_makes_the_layout_ownerless(
    team: Any, project: Any
) -> None:
    with pytest.raises(access.PermissionDenied):
        _save(team, project, name="team", shared=True)

    view = _save(team, project, who=team.admin, name="team", shared=True)

    assert view.is_shared and view.owner_id is None


def test_an_admin_can_promote_their_own_layout(team: Any, project: Any) -> None:
    mine = _save(team, project, who=team.admin, name="Mine")

    shared = _save(
        team, project, who=team.admin, view_id=str(mine.pk), expected_version=1, shared=True
    )

    assert shared.pk == mine.pk and shared.is_shared and shared.owner_id is None
    assert _names(team, project, team.member) == ["Mine"]


def test_a_member_cannot_promote_or_edit_a_shared_layout(team: Any, project: Any) -> None:
    mine = _save(team, project)
    shared = _save(team, project, who=team.admin, name="team", shared=True)

    with pytest.raises(access.PermissionDenied):
        _save(team, project, view_id=str(mine.pk), expected_version=1, shared=True)
    with pytest.raises(access.PermissionDenied):
        _save(team, project, view_id=str(shared.pk), expected_version=1, name="hijack", shared=True)


def test_a_shared_layout_cannot_go_back_to_personal(team: Any, project: Any) -> None:
    shared = _save(team, project, who=team.admin, name="team", shared=True)

    with pytest.raises(ApiError):
        _save(team, project, who=team.admin, view_id=str(shared.pk), expected_version=1)


def test_names_are_unique_per_scope_ignoring_case(team: Any, project: Any) -> None:
    _save(team, project, name="Plan")

    with pytest.raises(ApiError) as clash:
        _save(team, project, name="plan")
    _save(team, project, who=team.viewer, name="Plan")  # someone else's own list
    _save(team, project, who=team.admin, name="Plan", shared=True)  # the shared scope

    assert clash.value.title is ResponseTitle.VIEW_NAME_TAKEN
    assert clash.value.status == 409


@pytest.mark.parametrize("name", ["", "   ", "x" * 61])
def test_a_name_is_one_to_sixty_characters(team: Any, project: Any, name: str) -> None:
    with pytest.raises(ApiError):
        _save(team, project, name=name)


def test_a_person_keeps_a_bounded_number_of_layouts(team: Any, project: Any) -> None:
    for i in range(services.MAX_PER_SCOPE):
        _save(team, project, name=f"v{i}")

    with pytest.raises(ApiError) as over:
        _save(team, project, name="one too many")

    assert over.value.title is ResponseTitle.VIEW_LIMIT


@pytest.mark.parametrize(
    "config",
    [
        {"columns": ["nope"]},
        {"columns": ["status", "status"]},
        {"columns": ["field:not-a-uuid"]},
        {"columns": "status"},
        {"widths": {"status": 5}},
        {"widths": {"status": 5000}},
        {"widths": {"nope": 100}},
        {"widths": {"status": "wide"}},
        {"sort": [{"key": "nope", "desc": False}]},
        {"sort": [{"key": "title"}] * 4},
        {"sort": [{"key": "title", "desc": "yes"}]},
        {"sort": [{"key": "title", "desc": False}, {"key": "title", "desc": True}]},
        {"sort": ["title"]},
        {"group_by": "title"},
        {"group_by": 3},
        {"other": 1},
    ],
)
def test_a_layout_that_means_nothing_is_refused(team: Any, project: Any, config: Any) -> None:
    with pytest.raises(ApiError) as bad:
        _save(team, project, config=config)

    assert bad.value.title is ResponseTitle.VIEW_INVALID


def test_a_layout_may_name_custom_fields(team: Any, project: Any) -> None:
    field = fields.create(team.owner, team.ws, str(project.pk), name="Pts", type="number")
    key = f"field:{field.pk}"

    view = _save(team, project, config={"columns": [key], "sort": [{"key": key, "desc": False}]})

    assert view.config["columns"] == [key]


def test_only_the_owner_sees_and_deletes_a_personal_layout(team: Any, project: Any) -> None:
    view = _save(team, project)

    with pytest.raises(ApiError) as hidden:
        services.delete(team.viewer, team.ws, str(project.pk), str(view.pk))
    services.delete(team.member, team.ws, str(project.pk), str(view.pk))

    assert hidden.value.status == 404
    assert not SavedView.objects.exists()


def test_deleting_a_shared_layout_takes_the_manage_permission(team: Any, project: Any) -> None:
    shared = _save(team, project, who=team.admin, name="team", shared=True)

    with pytest.raises(access.PermissionDenied):
        services.delete(team.member, team.ws, str(project.pk), str(shared.pk))
    services.delete(team.admin, team.ws, str(project.pk), str(shared.pk))

    assert not SavedView.objects.exists()


def test_an_archived_project_keeps_personal_layouts_but_freezes_shared_ones(
    team: Any, project: Any
) -> None:
    shared = _save(team, project, who=team.admin, name="team", shared=True)
    projects.archive(team.owner, team.ws, str(project.pk), project.version)

    mine = _save(team, project, name="still mine")
    with pytest.raises(ApiError) as frozen:
        _save(team, project, who=team.admin, name="another", shared=True)

    with pytest.raises(ApiError) as undeletable:
        services.delete(team.admin, team.ws, str(project.pk), str(shared.pk))
    services.delete(team.member, team.ws, str(project.pk), str(mine.pk))  # personal: still fine

    assert frozen.value.title is ResponseTitle.PROJECT_ARCHIVED
    assert undeletable.value.title is ResponseTitle.PROJECT_ARCHIVED
    assert services.list_views(team.member, team.ws, str(project.pk))[0].pk == shared.pk


def test_other_workspaces_and_private_projects_are_closed(team: Any, project: Any) -> None:
    hidden = team.create(team.owner, "SEC", visibility="private", name="Secret")
    _save(team, project)

    with pytest.raises(ApiError):
        services.list_views(team.outsider, team.ws, str(project.pk))
    with pytest.raises(ApiError):
        _save(team, hidden, who=team.member)
    with pytest.raises(ApiError):
        services.list_views(team.member, team.ws, str(hidden.pk))


def test_a_view_of_another_project_is_not_found(team: Any, project: Any) -> None:
    other = team.create(team.owner, "API", name="Api")
    view = _save(team, other)

    with pytest.raises(ApiError) as missing:
        services.delete(team.member, team.ws, str(project.pk), str(view.pk))

    assert missing.value.status == 404


def test_the_unknown_view_id_is_not_found(team: Any, project: Any) -> None:
    for bad in ("nope", "00000000-0000-0000-0000-000000000000"):
        with pytest.raises(ApiError) as missing:
            services.delete(team.member, team.ws, str(project.pk), bad)
        assert missing.value.status == 404


def test_a_layout_is_pinned_as_a_tab_and_keeps_its_order(team: Any, project: Any) -> None:
    first = _save(team, project, name="a", pinned_as_tab=True, tab_order=2)
    second = _save(team, project, name="b", pinned_as_tab=True, tab_order=1)
    plain = _save(team, project, name="c")

    back = {v.pk: v for v in services.list_views(team.member, team.ws, str(project.pk))}

    assert (back[first.pk].pinned_as_tab, back[first.pk].tab_order) == (True, 2)
    assert (back[second.pk].pinned_as_tab, back[second.pk].tab_order) == (True, 1)
    assert (back[plain.pk].pinned_as_tab, back[plain.pk].tab_order) == (False, 0)


def test_unpinning_saves_with_the_current_version(team: Any, project: Any) -> None:
    view = _save(team, project, pinned_as_tab=True, tab_order=1)

    again = _save(team, project, view_id=str(view.pk), expected_version=1, pinned_as_tab=False)

    assert (again.pinned_as_tab, again.tab_order, again.version) == (False, 0, 2)


def test_pinning_a_shared_layout_takes_the_manage_permission(team: Any, project: Any) -> None:
    with pytest.raises(ApiError):
        _save(team, project, shared=True, pinned_as_tab=True)  # a member may not share
    shared = _save(team, project, who=team.admin, shared=True, pinned_as_tab=True, tab_order=1)

    assert [v.pk for v in services.list_views(team.viewer, team.ws, str(project.pk))] == [shared.pk]
    assert shared.pinned_as_tab is True


def test_a_pinned_personal_tab_is_private_to_its_owner(team: Any, project: Any) -> None:
    _save(team, project, pinned_as_tab=True, tab_order=1)

    assert _names(team, project, team.viewer) == []
    with pytest.raises(ApiError):
        services.list_views(team.outsider, team.ws, str(project.pk))


def test_a_tab_position_is_bounded(team: Any, project: Any) -> None:
    with pytest.raises(ApiError):
        _save(team, project, pinned_as_tab=True, tab_order=100000)
