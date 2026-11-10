"""Sorting, grouping and keyset paging of the task list, on the service."""

from collections.abc import Sequence
from typing import Any

import pytest

from infrastructure.common.errors import ApiError
from infrastructure.customfields import services as fields
from infrastructure.tasks import services
from infrastructure.workflows import services as workflows
from infrastructure.workflows.models import Status

pytestmark = pytest.mark.django_db

Sort = Sequence[tuple[str, bool]]


def _status(project: Any, name: str) -> Any:
    workflows.ensure(project)
    return Status.objects.get(project=project, name=name)


def _make(team: Any, project: Any, title: str, **kw: Any) -> Any:
    return services.create(team.owner, team.ws, str(project.pk), title, **kw)


def _all(team: Any, project: Any, *, sort: Sort = (), group_by: str = "", size: int = 2) -> list:
    """Every page of the list, concatenated, as titles."""
    titles: list[str] = []
    cursor = ""
    while True:
        page, cursor = services.list_page(
            team.member,
            team.ws,
            str(project.pk),
            sort=sort,
            group_by=group_by,
            cursor=cursor,
            limit=size,
        )
        titles += [t.title for t in page]
        if not cursor:
            return titles


def test_sort_by_title_ascending_and_descending_page_without_gaps(team: Any, project: Any) -> None:
    for title in ("pear", "Apple", "fig", "banana", "Cherry"):
        _make(team, project, title)

    assert _all(team, project, sort=[("title", False)]) == [
        "Apple",
        "banana",
        "Cherry",
        "fig",
        "pear",
    ]
    assert _all(team, project, sort=[("title", True)]) == [
        "pear",
        "fig",
        "Cherry",
        "banana",
        "Apple",
    ]


def test_nulls_sort_last_in_both_directions_and_paging_crosses_the_boundary(
    team: Any, project: Any
) -> None:
    _make(team, project, "none-a")
    _make(team, project, "late", due_date="2026-12-01")
    _make(team, project, "none-b")
    _make(team, project, "early", due_date="2026-01-01")

    assert _all(team, project, sort=[("due_date", False)], size=1) == [
        "early",
        "late",
        "none-a",
        "none-b",
    ]
    assert _all(team, project, sort=[("due_date", True)], size=3) == [
        "late",
        "early",
        "none-a",
        "none-b",
    ]


def test_priority_sorts_by_urgency_not_alphabet(team: Any, project: Any) -> None:
    for title, priority in (("n", "normal"), ("u", "urgent"), ("l", "low"), ("h", "high")):
        _make(team, project, title, priority=priority)
    _make(team, project, "z")

    assert _all(team, project, sort=[("priority", False)]) == ["u", "h", "n", "l", "z"]
    assert _all(team, project, sort=[("priority", True)]) == ["z", "l", "n", "h", "u"]


def test_two_keys_break_ties_in_order(team: Any, project: Any) -> None:
    _make(team, project, "b", priority="high")
    _make(team, project, "a", priority="high")
    _make(team, project, "c", priority="low")

    assert _all(team, project, sort=[("priority", False), ("title", False)]) == ["a", "b", "c"]
    assert _all(team, project, sort=[("priority", False), ("title", True)]) == ["b", "a", "c"]


def test_a_number_field_sorts_as_a_number_with_empty_values_last(team: Any, project: Any) -> None:
    field = fields.create(team.owner, team.ws, str(project.pk), name="Pts", type="number")
    key = str(field.pk)
    for title, value in (("nine", "9"), ("ten", "10"), ("two", "2")):
        _make(team, project, title, field_values={key: value})
    _make(team, project, "empty")

    assert _all(team, project, sort=[(f"field:{key}", False)]) == ["two", "nine", "ten", "empty"]
    assert _all(team, project, sort=[(f"field:{key}", True)], size=1) == [
        "ten",
        "nine",
        "two",
        "empty",
    ]


def test_a_select_field_sorts_in_option_order(team: Any, project: Any) -> None:
    field = fields.create(
        team.owner,
        team.ws,
        str(project.pk),
        name="Kind",
        type="select",
        options=[{"label": "Zed"}, {"label": "Alpha"}],
    )
    ids = {o["label"]: o["id"] for o in field.options}
    _make(team, project, "a", field_values={str(field.pk): ids["Alpha"]})
    _make(team, project, "z", field_values={str(field.pk): ids["Zed"]})

    assert _all(team, project, sort=[(f"field:{field.pk}", False)]) == ["z", "a"]


def test_group_by_status_follows_workflow_order_then_task_order(team: Any, project: Any) -> None:
    done = _status(project, "Done")
    first = _make(team, project, "first")
    _make(team, project, "second")
    third = _make(team, project, "third")
    services.update(
        team.owner, team.ws, str(project.pk), str(first.pk), 1, {"status": str(done.pk)}
    )
    services.update(
        team.owner, team.ws, str(project.pk), str(third.pk), 1, {"status": str(done.pk)}
    )

    assert _all(team, project, group_by="status") == ["second", "first", "third"]


def test_group_by_assignee_puts_the_unassigned_last(team: Any, project: Any) -> None:
    _make(team, project, "mine", assignee_ids=[str(team.member.pk)])
    _make(team, project, "nobody")
    _make(team, project, "hers", assignee_ids=[str(team.owner.pk)])

    titles = _all(team, project, group_by="assignee")

    assert titles[-1] == "nobody"
    assert sorted(titles[:2]) == ["hers", "mine"]


def test_group_counts_match_what_the_groups_hold(team: Any, project: Any) -> None:
    done = _status(project, "Done")
    for title in ("a", "b", "c"):
        _make(team, project, title, priority="high" if title != "c" else "low")
    task = _make(team, project, "d")
    services.update(team.owner, team.ws, str(project.pk), str(task.pk), 1, {"status": str(done.pk)})

    by_status = services.group_counts(team.member, team.ws, str(project.pk), "status")
    by_priority = services.group_counts(team.member, team.ws, str(project.pk), "priority")

    todo = _status(project, "To do")
    assert by_status == [(str(todo.pk), 3), (str(done.pk), 1)]
    assert dict(by_priority) == {"high": 2, "low": 1, "none": 1}


def test_group_counts_ignore_trashed_tasks_and_follow_the_filter(team: Any, project: Any) -> None:
    keep = _make(team, project, "keep", assignee_ids=[str(team.member.pk)])
    gone = _make(team, project, "gone", assignee_ids=[str(team.member.pk)])
    _make(team, project, "other")
    services.delete(team.owner, team.ws, str(project.pk), str(gone.pk))

    everyone = services.group_counts(team.member, team.ws, str(project.pk), "assignee")
    mine = services.group_counts(
        team.member, team.ws, str(project.pk), "assignee", assignee_id=str(team.member.pk)
    )

    assert sorted(c for _, c in everyone) == [1, 1]
    assert mine == [(str(team.member.pk), 1)]
    assert keep.pk


def test_unknown_sort_and_group_keys_are_refused(team: Any, project: Any) -> None:
    for bad in (("nope", False), ("field:not-a-uuid", False)):
        with pytest.raises(ApiError):
            services.list_page(team.member, team.ws, str(project.pk), sort=[bad])
    with pytest.raises(ApiError):
        services.list_page(team.member, team.ws, str(project.pk), group_by="title")
    with pytest.raises(ApiError):
        services.group_counts(team.member, team.ws, str(project.pk), "title")


def test_sorting_by_a_foreign_or_multiselect_field_is_refused(team: Any, project: Any) -> None:
    other = team.create(team.owner, "API", name="Api")
    foreign = fields.create(team.owner, team.ws, str(other.pk), name="X", type="number")
    multi = fields.create(
        team.owner,
        team.ws,
        str(project.pk),
        name="Tags",
        type="multiselect",
        options=[{"label": "a"}],
    )

    for field in (foreign, multi):
        with pytest.raises(ApiError):
            services.list_page(
                team.member, team.ws, str(project.pk), sort=[(f"field:{field.pk}", False)]
            )


def test_a_layout_naming_a_field_archived_since_still_lists(team: Any, project: Any) -> None:
    _make(team, project, "a")
    old = fields.create(
        team.owner, team.ws, str(project.pk), name="Old", type="select", options=[{"label": "x"}]
    )
    fields.archive(team.owner, team.ws, str(project.pk), str(old.pk), old.version)
    name = f"field:{old.pk}"

    page, _ = services.list_page(
        team.member, team.ws, str(project.pk), sort=[(name, False)], group_by=name
    )

    assert [t.title for t in page] == ["a"]
    assert page[0].group_key == ""
    assert services.group_counts(team.member, team.ws, str(project.pk), name) == []


def test_a_cursor_from_another_sort_is_refused(team: Any, project: Any) -> None:
    for title in "abc":
        _make(team, project, title)
    _, cursor = services.list_page(
        team.member, team.ws, str(project.pk), sort=[("title", False)], limit=1
    )

    with pytest.raises(ApiError):
        services.list_page(team.member, team.ws, str(project.pk), cursor=cursor)
    with pytest.raises(ApiError):
        services.list_page(team.member, team.ws, str(project.pk), cursor="garbage")


def test_at_most_three_sort_keys(team: Any, project: Any) -> None:
    keys = [("title", False), ("priority", False), ("due_date", False), ("created_at", False)]
    with pytest.raises(ApiError):
        services.list_page(team.member, team.ws, str(project.pk), sort=keys)


def test_the_default_order_is_still_tree_order(team: Any, project: Any) -> None:
    parent = _make(team, project, "parent")
    _make(team, project, "later")
    services.create(team.owner, team.ws, str(project.pk), "child", parent_id=str(parent.pk))

    page, _ = services.list_page(team.member, team.ws, str(project.pk), include_subtasks=True)

    assert [t.title for t in page] == ["parent", "child", "later"]


def test_other_workspaces_and_hidden_projects_stay_hidden(team: Any, project: Any) -> None:
    with pytest.raises(ApiError):
        services.group_counts(team.outsider, team.ws, str(project.pk), "status")


def test_a_grouped_page_tells_each_task_its_group(team: Any, project: Any) -> None:
    _make(team, project, "mine", assignee_ids=[str(team.member.pk)], priority="high")
    _make(team, project, "nobody")

    by_assignee, _ = services.list_page(team.member, team.ws, str(project.pk), group_by="assignee")
    by_priority, _ = services.list_page(team.member, team.ws, str(project.pk), group_by="priority")
    plain, _ = services.list_page(team.member, team.ws, str(project.pk))

    assert {t.title: t.group_key for t in by_assignee} == {
        "mine": str(team.member.pk),
        "nobody": "",
    }
    assert {t.title: t.group_key for t in by_priority} == {"mine": "high", "nobody": "none"}
    assert {t.group_key for t in plain} == {""}
