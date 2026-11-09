"""Create, update, archive, restore, favorites, features, counter, versions."""

from typing import Any

import pytest

from infrastructure.common.errors import ApiError
from infrastructure.common.responses import ResponseTitle
from infrastructure.projects import features, services
from infrastructure.projects.models import Project, ProjectMember
from infrastructure.workspaces.models import MemberStatus, WorkspaceMember

from .conftest import Team


def _refusal(call: Any, *args: Any, **kwargs: Any) -> ApiError:
    with pytest.raises(ApiError) as refusal:
        call(*args, **kwargs)
    return refusal.value


def test_create_stores_normalised_fields(team: Team) -> None:
    view = services.create(
        team.member, team.ws, " Web site ", "web", " About ", "🚀", "#abcdef", "open"
    )

    p = view.project
    assert (p.name, p.key, p.description, p.icon, p.color) == (
        "Web site",
        "WEB",
        "About",
        "🚀",
        "#ABCDEF",
    )
    assert (p.version, p.task_counter, p.archived_at, p.created_by) == (1, 0, None, team.member)
    assert p.settings == {}
    assert (view.member_count, view.is_member, view.can_open) == (0, False, True)


def test_create_private_adds_the_creator_as_member(team: Team) -> None:
    view = services.create(team.member, team.ws, "Secret", "SEC", visibility="private")

    assert (view.member_count, view.is_member) == (1, True)
    assert ProjectMember.objects.filter(project=view.project, user=team.member).exists()


def test_key_is_unique_per_workspace_ignoring_case(team: Team) -> None:
    team.create(team.owner, "WEB")

    refusal = _refusal(services.create, team.admin, team.ws, "Other", "web")

    assert (refusal.status, refusal.title) == (409, ResponseTitle.KEY_TAKEN)
    assert Project.objects.filter(workspace=team.ws).count() == 1


def test_key_can_be_reused_in_another_workspace(team: Team) -> None:
    team.create(team.owner, "WEB")

    other = services.create(team.outsider, team.other_ws, "Web", "WEB")

    assert other.project.key == "WEB"


def test_update_changes_fields_and_bumps_the_version(team: Team) -> None:
    p = team.create(team.owner, "WEB")

    view = services.update(
        team.admin, team.ws, str(p.pk), 1, name="Site", description="d", color="#000000", icon="x"
    )

    q = view.project
    assert (q.name, q.description, q.color, q.icon, q.version) == ("Site", "d", "#000000", "x", 2)


def test_update_with_a_stale_version_conflicts_and_changes_nothing(team: Team) -> None:
    p = team.create(team.owner, "WEB")
    services.update(team.owner, team.ws, str(p.pk), 1, name="One")

    refusal = _refusal(services.update, team.owner, team.ws, str(p.pk), 1, name="Two")

    assert refusal.title is ResponseTitle.VERSION_CONFLICT
    p.refresh_from_db()
    assert (p.name, p.version) == ("One", 2)


def test_update_to_a_taken_key_is_key_taken(team: Team) -> None:
    team.create(team.owner, "WEB")
    p = team.create(team.owner, "API", name="Api")

    refusal = _refusal(services.update, team.owner, team.ws, str(p.pk), 1, key="web")

    assert refusal.title is ResponseTitle.KEY_TAKEN
    p.refresh_from_db()
    assert (p.key, p.version) == ("API", 1)


def test_key_changes_while_no_task_exists_then_locks(team: Team) -> None:
    p = team.create(team.owner, "WEB")
    services.update(team.owner, team.ws, str(p.pk), 1, key="site")
    assert services.number_task(team.owner, team.ws, str(p.pk)) == 1

    refusal = _refusal(services.update, team.owner, team.ws, str(p.pk), 2, key="WEB")

    assert refusal.title is ResponseTitle.KEY_LOCKED
    p.refresh_from_db()
    assert p.key == "SITE"


def test_resending_the_same_key_after_tasks_exist_is_not_an_error(team: Team) -> None:
    p = team.create(team.owner, "WEB")
    services.number_task(team.owner, team.ws, str(p.pk))

    view = services.update(team.owner, team.ws, str(p.pk), 1, key="web", name="New")

    assert (view.project.key, view.project.name) == ("WEB", "New")


def test_update_that_changes_nothing_keeps_the_version(team: Team) -> None:
    p = team.create(team.owner, "WEB")

    view = services.update(team.owner, team.ws, str(p.pk), 1, name="Web")

    assert view.project.version == 1


def test_a_no_op_update_still_checks_the_version(team: Team) -> None:
    p = team.create(team.owner, "WEB")
    services.update(team.owner, team.ws, str(p.pk), 1, name="Web 2")

    refusal = _refusal(services.update, team.owner, team.ws, str(p.pk), 1, name="Web 2")

    assert refusal.title is ResponseTitle.VERSION_CONFLICT


def test_going_private_adds_the_actor_as_member(team: Team) -> None:
    p = team.create(team.owner, "WEB")

    view = services.update(team.admin, team.ws, str(p.pk), 1, visibility="private")

    assert (view.is_member, view.member_count) == (True, 1)


def test_archive_hides_from_list_and_blocks_every_mutation_but_restore(team: Team) -> None:
    p = team.create(team.owner, "WEB")
    pid = str(p.pk)
    archived = services.archive(team.owner, team.ws, pid, 1)
    assert archived.project.archived_at is not None and archived.project.version == 2

    assert services.list_projects(team.owner, team.ws) == []
    assert [v.project.pk for v in services.list_projects(team.owner, team.ws, True)] == [p.pk]
    blocked: list[Any] = [
        (services.update, (team.owner, team.ws, pid, 2), {"name": "x"}),
        (services.set_features, (team.owner, team.ws, pid, [], 2), {}),
        (services.archive, (team.owner, team.ws, pid, 2), {}),
        (services.favorite, (team.owner, team.ws, pid, True), {}),
        (services.number_task, (team.owner, team.ws, pid), {}),
    ]
    for call, args, kwargs in blocked:
        assert _refusal(call, *args, **kwargs).title is ResponseTitle.PROJECT_ARCHIVED, call

    restored = services.restore(team.owner, team.ws, pid, 2)
    assert (restored.project.archived_at, restored.project.version) == (None, 3)
    assert len(services.list_projects(team.owner, team.ws)) == 1
    assert services.update(team.owner, team.ws, pid, 3, name="ok").project.name == "ok"


def test_restore_of_an_active_project_is_a_no_op(team: Team) -> None:
    p = team.create(team.owner, "WEB")

    assert services.restore(team.owner, team.ws, str(p.pk), 1).project.version == 1


def test_archive_and_restore_check_the_version(team: Team) -> None:
    p = team.create(team.owner, "WEB")
    pid = str(p.pk)
    assert _refusal(services.archive, team.owner, team.ws, pid, 9).title is (
        ResponseTitle.VERSION_CONFLICT
    )
    services.archive(team.owner, team.ws, pid, 1)
    assert _refusal(services.restore, team.owner, team.ws, pid, 1).title is (
        ResponseTitle.VERSION_CONFLICT
    )


def test_features_default_off_persist_and_keep_registry_order(team: Team) -> None:
    p = team.create(team.owner, "WEB")
    assert services.enabled_features(p) == frozenset()

    view = services.set_features(team.owner, team.ws, str(p.pk), ["sprints", "subtasks"], 1)

    assert view.project.settings == {"features": ["subtasks", "sprints"]}
    assert view.project.version == 2
    again = services.get(team.owner, team.ws, str(p.pk))
    assert services.enabled_features(again.project) == {"subtasks", "sprints"}


def test_switching_a_feature_off_keeps_the_others(team: Team) -> None:
    p = team.create(team.owner, "WEB")
    services.set_features(team.owner, team.ws, str(p.pk), ["sprints", "subtasks"], 1)

    view = services.set_features(team.owner, team.ws, str(p.pk), ["sprints"], 2)

    assert services.enabled_features(view.project) == {"sprints"}


def test_unknown_features_are_refused(team: Team) -> None:
    p = team.create(team.owner, "WEB")

    refusal = _refusal(services.set_features, team.owner, team.ws, str(p.pk), ["magic"], 1)

    assert refusal.status == 400 and "magic" in str(refusal)
    p.refresh_from_db()
    assert p.version == 1


def test_the_feature_registry_has_a_label_and_description_for_each_key() -> None:
    assert [f.key for f in features.FEATURES] == [
        "subtasks",
        "dependencies",
        "custom_fields",
        "time_tracking",
        "sprints",
    ]
    assert all(f.label and f.description for f in features.FEATURES)


def test_favorites_come_first_then_by_name(team: Team) -> None:
    a = team.create(team.owner, "AAA", name="alpha")
    b = team.create(team.owner, "BBB", name="Beta")
    c = team.create(team.owner, "CCC", name="gamma")
    assert [v.project.key for v in services.list_projects(team.owner, team.ws)] == [
        "AAA",
        "BBB",
        "CCC",
    ]

    services.favorite(team.owner, team.ws, str(c.pk), True)
    services.favorite(team.owner, team.ws, str(b.pk), True)
    listed = services.list_projects(team.owner, team.ws)

    assert [(v.project.key, v.is_favorite) for v in listed] == [
        ("BBB", True),
        ("CCC", True),
        ("AAA", False),
    ]
    other = services.list_projects(team.admin, team.ws)
    assert not any(v.is_favorite for v in other)  # favorites are per user
    services.favorite(team.owner, team.ws, str(b.pk), False)
    assert [v.project.key for v in services.list_projects(team.owner, team.ws)][0] == "CCC"
    assert a  # keep the name used


def test_favoriting_twice_is_idempotent_and_unfavoriting_works_when_archived(team: Team) -> None:
    p = team.create(team.owner, "WEB")
    services.favorite(team.owner, team.ws, str(p.pk), True)
    services.favorite(team.owner, team.ws, str(p.pk), True)
    services.archive(team.owner, team.ws, str(p.pk), 1)

    view = services.favorite(team.owner, team.ws, str(p.pk), False)

    assert view.is_favorite is False


def test_task_numbers_are_sequential_per_project(team: Team) -> None:
    a, b = team.create(team.owner, "AAA"), team.create(team.owner, "BBB")

    taken = [services.number_task(team.owner, team.ws, str(a.pk)) for _ in range(3)]
    other = services.next_task_number(b)

    assert (taken, other) == ([1, 2, 3], 1)
    a.refresh_from_db()
    assert a.task_counter == 3 and a.version == 1  # numbering is not a project change


def test_a_viewer_cannot_use_the_write_calls(team: Team) -> None:
    p = team.create(team.owner, "WEB")
    pid = str(p.pk)
    for call, args in (
        (services.create, (team.viewer, team.ws, "x", "XX")),
        (services.update, (team.viewer, team.ws, pid, 1)),
        (services.archive, (team.viewer, team.ws, pid, 1)),
        (services.set_features, (team.viewer, team.ws, pid, [], 1)),
    ):
        assert _refusal(call, *args).title is ResponseTitle.PERMISSION_DENIED_REASON, call


def test_a_creator_manages_their_own_project_and_no_one_elses(team: Team) -> None:
    mine = team.create(team.member, "MINE")
    theirs = team.create(team.owner, "THEIRS")
    pid = str(mine.pk)

    assert services.update(team.member, team.ws, pid, 1, name="Mine 2").project.version == 2
    assert services.set_features(team.member, team.ws, pid, ["sprints"], 2).project.version == 3
    assert services.archive(team.member, team.ws, pid, 3).project.archived_at is not None
    assert services.restore(team.member, team.ws, pid, 4).project.archived_at is None
    for call, args in (
        (services.update, (team.member, team.ws, str(theirs.pk), 1)),
        (services.archive, (team.member, team.ws, str(theirs.pk), 1)),
        (services.update, (team.pm, team.ws, pid, 1)),  # another Member
    ):
        assert _refusal(call, *args).title is ResponseTitle.PERMISSION_DENIED_REASON


def test_the_creator_rule_needs_an_active_member_and_a_creator(team: Team) -> None:
    mine = team.create(team.member, "MINE")
    viewer_made = team.create(team.owner, "VW")
    Project.objects.filter(pk=viewer_made.pk).update(created_by=team.viewer)

    assert _refusal(services.update, team.viewer, team.ws, str(viewer_made.pk), 1).status == 403
    WorkspaceMember.objects.filter(user=team.member).update(status=MemberStatus.REMOVED)
    assert _refusal(services.update, team.member, team.ws, str(mine.pk), 1).status == 403


def test_ids_are_scoped_to_the_workspace(team: Team) -> None:
    foreign = services.create(team.outsider, team.other_ws, "Web", "WEB").project

    for call, args in (
        (services.get, (team.owner, team.ws, str(foreign.pk))),
        (services.update, (team.owner, team.ws, str(foreign.pk), 1)),
        (services.archive, (team.owner, team.ws, str(foreign.pk), 1)),
        (services.number_task, (team.owner, team.ws, str(foreign.pk))),
        (services.get, (team.owner, team.ws, "not-a-uuid")),
    ):
        assert _refusal(call, *args).status == 404, call


def test_non_members_of_the_workspace_see_nothing(team: Team) -> None:
    p = team.create(team.owner, "WEB")

    assert _refusal(services.list_projects, team.outsider, team.ws).status == 403
    assert _refusal(services.get, team.outsider, team.ws, str(p.pk)).status == 403
    assert list(Project.objects.visible_to(team.outsider, team.ws)) == []


def test_a_removed_workspace_member_loses_the_projects(team: Team) -> None:
    from infrastructure.workspaces import members

    p = services.create(team.member, team.ws, "Sec", "SEC", visibility="private").project
    members.remove(team.ws, team.owner, str(team.member.pk))

    assert list(Project.objects.visible_to(team.member, team.ws)) == []
    assert list(Project.objects.visible_to(team.owner, team.ws, as_admin=True)) == [p]
