"""Validate, suggest and saved filters on the service."""

import json
from typing import Any

import pytest

from infrastructure.common.errors import ApiError
from infrastructure.common.responses import ResponseTitle
from infrastructure.customfields import services as fields
from infrastructure.filters import services as filters
from infrastructure.filters.models import SavedFilter
from infrastructure.projects import services as projects
from infrastructure.workflows import services as workflows

pytestmark = pytest.mark.django_db


def _pid(project: Any) -> str:
    return str(project.pk)


def _save(team: Any, project: Any, who: Any = None, **kw: Any) -> Any:
    kw.setdefault("name", "Mine")
    kw.setdefault("text", "priority = high")
    return filters.save(who or team.member, team.ws, _pid(project) if project else "", **kw)[0]


def _names(team: Any, project: Any, who: Any) -> list[str]:
    return [f.name for f, _ in filters.list_filters(who, team.ws, _pid(project) if project else "")]


# ------------------------------------------------------------------------------- validate


def test_validate_gives_the_ast_and_the_normal_text(team: Any, project: Any) -> None:
    result = filters.validate(
        team.viewer, team.ws, _pid(project), "priority   =   HIGH and due<+7d"
    )

    assert not result.errors
    assert result.tfql == "priority = high AND due < +7d"
    assert result.ast is not None and result.ast["where"]["op"] == "and"


def test_validate_reports_where_a_query_is_wrong_and_does_not_raise(
    team: Any, project: Any
) -> None:
    result = filters.validate(team.viewer, team.ws, _pid(project), "priority = huge")

    [error] = result.errors
    assert (error.position, error.length) == (11, 4) and "huge" in error.message
    assert result.ast is None


def test_validate_takes_an_ast_too_and_checks_it(team: Any, project: Any) -> None:
    ast = filters.validate(team.viewer, team.ws, _pid(project), "priority = high").ast

    again = filters.validate(team.viewer, team.ws, _pid(project), "", json.dumps(ast))
    broken = filters.validate(team.viewer, team.ws, _pid(project), "", "{nope")
    unknown = filters.validate(team.viewer, team.ws, _pid(project), "", '{"where": {"op": "x"}}')

    assert again.tfql == "priority = high" and not again.errors
    assert broken.errors and unknown.errors


def test_validate_needs_a_project_the_caller_can_open(team: Any, project: Any) -> None:
    hidden = team.create(team.owner, "SEC", visibility="private", name="Secret")

    with pytest.raises(ApiError):
        filters.validate(team.member, team.ws, _pid(hidden), "priority = high")
    with pytest.raises(ApiError):
        filters.validate(team.outsider, team.ws, _pid(project), "priority = high")


def test_a_workspace_level_query_has_only_the_built_ins_that_need_no_project(
    team: Any,
) -> None:
    ok = filters.validate(team.viewer, team.ws, "", "priority = high AND assignee = me")
    status = filters.validate(team.viewer, team.ws, "", "status = Done")
    custom = filters.validate(team.viewer, team.ws, "", '"Points" > 3')

    assert not ok.errors and status.errors and custom.errors


# ------------------------------------------------------------------------------ suggestions


def _suggest(team: Any, project: Any, text: str, cursor: int | None = None) -> list[str]:
    at = len(text) if cursor is None else cursor
    return [s.text for s in filters.suggest(team.viewer, team.ws, _pid(project), text, at)]


def test_suggestions_walk_through_a_condition(team: Any, project: Any) -> None:
    workflows.ensure(project)
    fields.create(team.owner, team.ws, _pid(project), name="Points", type="number")

    assert {"status", "priority", "assignee", '"Points"'} <= set(_suggest(team, project, ""))
    assert _suggest(team, project, "st") == ["status", "start"]
    assert _suggest(team, project, "stat") == ["status"]
    assert "=" in _suggest(team, project, "status ") and "IN" in _suggest(team, project, "status ")
    assert "~" not in _suggest(team, project, "status ")  # a status is not text
    assert {"To do", "In progress", "Done"} <= {
        s.strip('"') for s in _suggest(team, project, "status = ")
    }
    assert _suggest(team, project, "status = Do") == ["Done"]
    assert {"AND", "OR", "ORDER BY"} <= set(_suggest(team, project, "status = Done "))
    assert "status" in _suggest(team, project, "status = Done AND ")
    assert "me" in _suggest(team, project, "assignee = ")
    assert {"urgent", "high"} <= set(_suggest(team, project, "priority in ("))
    assert "today" in _suggest(team, project, "due < ")
    assert {"true", "false"} == set(_suggest(team, project, "blocked = "))


def test_suggestions_know_the_operators_of_a_field(team: Any, project: Any) -> None:
    text_ops = _suggest(team, project, "title ")
    date_ops = _suggest(team, project, "due ")

    assert "~" in text_ops and "<" not in text_ops
    assert "<" in date_ops and "~" not in date_ops
    assert "IS EMPTY" in date_ops


def test_suggestions_offer_custom_options_and_people(team: Any, project: Any) -> None:
    fields.create(
        team.owner, team.ws, _pid(project), name="Env", type="select",
        options=[{"label": "dev"}, {"label": "prod x"}],
    )  # fmt: skip

    options = _suggest(team, project, "env = ")
    people = _suggest(team, project, "assignee = ")

    assert options == ["dev", '"prod x"']
    assert team.member.username in people


def test_suggestions_replace_the_word_being_typed(team: Any, project: Any) -> None:
    found = filters.suggest(team.viewer, team.ws, _pid(project), "priority = hi", 13)

    assert [(s.text, s.start) for s in found] == [("high", 11)]
    middle = filters.suggest(team.viewer, team.ws, _pid(project), "pri = high", 3)
    assert [(s.text, s.start) for s in middle] == [("priority", 0)]


def test_suggestions_follow_not_in_is_empty_and_order(team: Any, project: Any) -> None:
    workflows.ensure(project)

    assert {"To do", "Done"} <= {s.strip('"') for s in _suggest(team, project, "status not in (")}
    assert _suggest(team, project, "assignee is ") == ["EMPTY", "NOT EMPTY"]
    assert _suggest(team, project, "assignee is not ") == ["EMPTY", "NOT EMPTY"]
    assert "AND" in _suggest(team, project, "assignee is empty ")
    assert _suggest(team, project, "status = Done ORDER ") == ["BY"]
    assert "due" in _suggest(team, project, "status = Done ORDER BY ")


def test_suggestions_survive_garbage(team: Any, project: Any) -> None:
    for text in ('"unterminated', "((((", "status = = =", "ORDER", "a b c d", "\x00"):
        _suggest(team, project, text)  # no error


# ------------------------------------------------------------------------------ saved filters


def test_a_filter_round_trips_with_its_text_rendered_from_the_ast(team: Any, project: Any) -> None:
    saved, text = filters.save(
        team.member, team.ws, _pid(project), name="Hot", text="priority=high ORDER BY due"
    )

    [(row, shown)] = filters.list_filters(team.member, team.ws, _pid(project))

    assert row.pk == saved.pk and shown == text == "priority = high ORDER BY due"
    assert row.ast["where"]["op"] == "cmp"


def test_a_filter_survives_a_field_rename_and_follows_its_new_name(team: Any, project: Any) -> None:
    field = fields.create(team.owner, team.ws, _pid(project), name="Points", type="number")
    _save(team, project, text='"Points" > 3')

    fields.update(
        team.owner, team.ws, _pid(project), str(field.pk), field.version, {"name": "Effort"}
    )

    [(_, shown)] = filters.list_filters(team.member, team.ws, _pid(project))
    assert shown == '"Effort" > 3'


def test_a_filter_whose_field_was_removed_is_listed_but_empty(team: Any, project: Any) -> None:
    field = fields.create(team.owner, team.ws, _pid(project), name="Points", type="number")
    _save(team, project, text='"Points" > 3')
    fields.archive(team.owner, team.ws, _pid(project), str(field.pk), field.version)

    [(row, shown)] = filters.list_filters(team.member, team.ws, _pid(project))

    assert row.name == "Mine" and shown == ""


def test_an_invalid_filter_is_not_saved(team: Any, project: Any) -> None:
    with pytest.raises(ApiError) as caught:
        _save(team, project, text="priority = huge")

    assert caught.value.title is ResponseTitle.FILTER_INVALID
    assert caught.value.data == {"position": 11, "length": 4}
    assert not SavedFilter.objects.exists()


def test_a_name_is_unique_where_it_is_kept_and_limited_in_length(team: Any, project: Any) -> None:
    _save(team, project)

    with pytest.raises(ApiError) as taken:
        _save(team, project, name="mine")
    _save(team, project, who=team.admin, name="Mine")  # another person's own
    with pytest.raises(ApiError):
        _save(team, project, name=" ")
    with pytest.raises(ApiError):
        _save(team, project, name="x" * 61)

    assert taken.value.title is ResponseTitle.FILTER_NAME_TAKEN


def test_private_filters_are_the_owners_and_shared_ones_everyones(team: Any, project: Any) -> None:
    _save(team, project, name="mine")
    _save(team, project, who=team.admin, name="admin private")
    _save(team, project, who=team.admin, name="for all", visibility="project")

    assert _names(team, project, team.member) == ["for all", "mine"]
    assert _names(team, project, team.admin) == ["for all", "admin private"]
    assert _names(team, project, team.viewer) == ["for all"]


def test_sharing_needs_the_right_to_manage(team: Any, project: Any) -> None:
    with pytest.raises(ApiError) as denied:
        _save(team, project, visibility="project")  # a member does not manage the project
    projects.archive(team.owner, team.ws, _pid(project), project.version)
    with pytest.raises(ApiError) as archived:
        _save(team, project, who=team.admin, visibility="project", name="x")
    _save(team, project, name="private still works")  # a preference, even when archived

    assert denied.value.status == 403
    assert archived.value.title is ResponseTitle.PROJECT_ARCHIVED


def test_workspace_level_filters_need_workspace_rights_and_no_project(team: Any) -> None:
    with pytest.raises(ApiError):
        _save(team, None, visibility="workspace")  # a member may not
    shared = _save(team, None, who=team.admin, name="everyone", visibility="workspace")
    mine = _save(team, None, name="my own", text="assignee = me")

    assert _names(team, None, team.member) == ["everyone", "my own"]
    assert _names(team, None, team.viewer) == ["everyone"]
    assert shared.project_id is None and mine.project_id is None


def test_a_workspace_filter_shows_in_every_project_and_private_ones_too(
    team: Any, project: Any
) -> None:
    _save(team, None, who=team.admin, name="everyone", visibility="workspace")
    _save(team, None, name="my global", text="assignee = me")
    _save(team, project, name="my project one")

    assert _names(team, project, team.member) == ["everyone", "my global", "my project one"]
    assert _names(team, project, team.viewer) == ["everyone"]


def test_a_filter_is_replaced_with_its_version_and_a_stale_save_conflicts(
    team: Any, project: Any
) -> None:
    saved = _save(team, project)

    again, _ = filters.save(
        team.member, team.ws, _pid(project), name="Renamed", text="priority = low",
        filter_id=str(saved.pk), expected_version=1,
    )  # fmt: skip
    with pytest.raises(ApiError) as stale:
        filters.save(
            team.member, team.ws, _pid(project), name="x", text="priority = low",
            filter_id=str(saved.pk), expected_version=1,
        )  # fmt: skip

    assert (again.name, again.version) == ("Renamed", 2)
    assert stale.value.title is ResponseTitle.VERSION_CONFLICT


def test_delete_is_the_owners_for_private_and_the_managers_for_shared(
    team: Any, project: Any
) -> None:
    mine = _save(team, project)
    shared = _save(team, project, who=team.admin, name="all", visibility="project")

    with pytest.raises(ApiError):
        filters.delete(team.member, team.ws, _pid(project), str(shared.pk))
    with pytest.raises(ApiError) as other:
        filters.delete(team.admin, team.ws, _pid(project), str(mine.pk))  # not theirs: not found
    filters.delete(team.member, team.ws, _pid(project), str(mine.pk))
    filters.delete(team.admin, team.ws, _pid(project), str(shared.pk))

    assert other.value.status == 404 and not SavedFilter.objects.exists()


def test_a_place_holds_at_most_a_hundred(team: Any, project: Any, monkeypatch: Any) -> None:
    monkeypatch.setattr(filters, "MAX_PER_SCOPE", 3)
    for n in range(3):
        _save(team, project, name=f"f{n}")

    with pytest.raises(ApiError) as full:
        _save(team, project, name="one too many")

    assert full.value.title is ResponseTitle.FILTER_LIMIT


def test_strangers_see_and_change_nothing(team: Any, project: Any) -> None:
    saved = _save(team, project)

    with pytest.raises(ApiError):
        filters.list_filters(team.outsider, team.ws, _pid(project))
    with pytest.raises(ApiError):
        filters.delete(team.outsider, team.ws, _pid(project), str(saved.pk))
    with pytest.raises(ApiError):
        filters.delete(team.member, team.ws, _pid(project), "not-a-uuid")


def test_a_saved_filter_applies_to_the_list(team: Any, project: Any) -> None:
    from infrastructure.tasks import services

    services.create(team.owner, team.ws, _pid(project), "hot", priority="high")
    services.create(team.owner, team.ws, _pid(project), "cold")
    saved = _save(team, project)

    page, _ = services.list_page(
        team.member, team.ws, _pid(project), filter_ast=json.dumps(saved.ast)
    )

    assert [t.title for t in page] == ["hot"]


def test_a_workspace_private_filter_is_changed_where_it_lives(team: Any, project: Any) -> None:
    mine = _save(team, None, name="global", text="assignee = me")

    with pytest.raises(ApiError) as there:
        filters.save(
            team.member, team.ws, _pid(project), name="global", text="assignee = me",
            filter_id=str(mine.pk), expected_version=1,
        )  # fmt: skip
    again, _ = filters.save(
        team.member, team.ws, "", name="global", text="priority = low",
        filter_id=str(mine.pk), expected_version=1,
    )  # fmt: skip

    assert there.value.status == 404 and again.version == 2


def test_another_workspace_is_a_wall(team: Any, project: Any) -> None:
    from infrastructure.workspaces import services as workspace_services

    away = workspace_services.create(team.owner, "Away", "away")
    theirs = projects.create(team.owner, away, "Away", "AWY").project
    their_filter, _ = filters.save(
        team.owner, away, str(theirs.pk), name="theirs", text="priority = high"
    )
    mine = _save(team, project)

    # Workspace A's door with workspace B's project id.
    for call in (
        lambda: filters.validate(team.owner, team.ws, str(theirs.pk), "priority = high"),
        lambda: filters.list_filters(team.owner, team.ws, str(theirs.pk)),
        lambda: filters.save(team.owner, team.ws, str(theirs.pk), name="x", text=""),
        lambda: filters.suggest(team.owner, team.ws, str(theirs.pk), "p", 1),
    ):
        with pytest.raises(ApiError):
            call()
    # ... and workspace B's filter id through workspace A's project.
    with pytest.raises(ApiError):
        filters.delete(team.owner, team.ws, _pid(project), str(their_filter.pk))
    with pytest.raises(ApiError):
        filters.save(
            team.owner, team.ws, _pid(project), name="y", text="",
            filter_id=str(their_filter.pk), expected_version=1,
        )  # fmt: skip
    assert SavedFilter.objects.filter(pk=their_filter.pk, name="theirs").exists()
    assert mine.pk
