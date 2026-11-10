"""The board: columns with counts and lazy cards, moving a card, and stable ranks."""

from typing import Any

import pytest

from infrastructure.common.errors import ApiError
from infrastructure.common.responses import ResponseTitle
from infrastructure.customfields import services as fields
from infrastructure.tasks import board, rank, services
from infrastructure.tasks.models import Task
from infrastructure.workflows import services as workflows
from infrastructure.workflows.drafts import StatusDraft, TransitionDraft, WorkflowDraft
from infrastructure.workflows.models import Status

pytestmark = pytest.mark.django_db


def _ids(project: Any) -> dict[str, str]:
    workflows.ensure(project)
    return {s.name: str(s.pk) for s in Status.objects.filter(project=project)}


def _make(team: Any, project: Any, title: str, **kw: Any) -> Any:
    return services.create(team.owner, team.ws, str(project.pk), title, **kw)


def _lane(team: Any, project: Any, who: Any = None, **kw: Any) -> dict[str, Any]:
    [lane] = board.get(who or team.member, team.ws, str(project.pk), **kw)
    return {c.key: c for c in lane.columns}


def _titles(team: Any, project: Any, column: str, **kw: Any) -> list[str]:
    tasks, _ = board.list_column(
        team.member, team.ws, str(project.pk), group_by="status", column=column, **kw
    )
    return [t.title for t in tasks]


def _move(team: Any, project: Any, task: Any, column: str, **kw: Any) -> Any:
    kw.setdefault("group_by", "status")
    kw.setdefault("expected_version", task.version)
    return board.move_card(team.member, team.ws, str(project.pk), str(task.pk), column=column, **kw)


def test_columns_are_the_statuses_in_order_with_counts(team: Any, project: Any) -> None:
    ids = _ids(project)
    _make(team, project, "a")
    _make(team, project, "b", status=ids["Done"])

    [lane] = board.get(team.member, team.ws, str(project.pk))

    assert [(c.name, c.count) for c in lane.columns] == [
        ("To do", 1),
        ("In progress", 0),
        ("Done", 1),
    ]
    assert [t.title for t in lane.columns[0].tasks] == ["a"]


def test_cards_are_top_level_live_tasks_in_rank_order(team: Any, project: Any) -> None:
    first = _make(team, project, "first")
    _make(team, project, "second")
    _make(team, project, "child", parent_id=str(first.pk))
    gone = _make(team, project, "gone")
    services.delete(team.owner, team.ws, str(project.pk), str(gone.pk))

    todo = _lane(team, project)[_ids(project)["To do"]]

    assert todo.count == 2
    assert [t.title for t in todo.tasks] == ["first", "second"]


def test_a_column_loads_a_page_then_more(team: Any, project: Any) -> None:
    todo = _ids(project)["To do"]
    for n in range(5):
        _make(team, project, f"t{n}")

    column = _lane(team, project, limit=2)[todo]
    assert [t.title for t in column.tasks] == ["t0", "t1"] and column.cursor
    middle, cursor = board.list_column(
        team.member,
        team.ws,
        str(project.pk),
        group_by="status",
        column=todo,
        cursor=column.cursor,
        limit=2,
    )
    last, end = board.list_column(
        team.member,
        team.ws,
        str(project.pk),
        group_by="status",
        column=todo,
        cursor=cursor,
        limit=2,
    )

    assert [t.title for t in middle] == ["t2", "t3"]
    assert [t.title for t in last] == ["t4"] and end == ""


def test_priority_columns_come_in_urgency_order(team: Any, project: Any) -> None:
    _make(team, project, "x", priority="high")

    columns = board.get(team.member, team.ws, str(project.pk), group_by="priority")[0].columns

    assert [c.key for c in columns] == ["urgent", "high", "normal", "low", "none"]
    assert [c.count for c in columns] == [0, 1, 0, 0, 0]


def test_assignee_columns_are_the_people_with_cards_and_unassigned(team: Any, project: Any) -> None:
    _make(team, project, "mine", assignee_ids=[str(team.member.pk)])
    _make(team, project, "nobody")

    columns = board.get(team.member, team.ws, str(project.pk), group_by="assignee")[0].columns

    assert {c.key: c.count for c in columns} == {str(team.member.pk): 1, "": 1}
    assert columns[-1].key == ""  # the column of tasks with no value comes last


def test_select_field_columns_are_its_options_then_no_value(team: Any, project: Any) -> None:
    field = fields.create(
        team.owner,
        team.ws,
        str(project.pk),
        name="Env",
        type="select",
        options=[{"label": "dev"}, {"label": "prod"}],
    )
    dev, prod = (o["id"] for o in field.options)
    _make(team, project, "a", field_values={str(field.pk): prod})
    _make(team, project, "b")

    columns = board.get(team.member, team.ws, str(project.pk), group_by=f"field:{field.pk}")[
        0
    ].columns

    assert [(c.key, c.count) for c in columns] == [(dev, 0), (prod, 1), ("", 1)]
    assert [c.name for c in columns] == ["dev", "prod", "No value"]


def test_swimlanes_split_every_column_by_assignee(team: Any, project: Any) -> None:
    _make(team, project, "mine", assignee_ids=[str(team.member.pk)])
    _make(team, project, "nobody")

    lanes = board.get(team.member, team.ws, str(project.pk), swimlane="assignee")

    ids = _ids(project)
    todo = ids["To do"]
    by_lane = {lane.key: {c.key: c.count for c in lane.columns} for lane in lanes}
    everything_else = {ids["In progress"]: 0, ids["Done"]: 0}
    assert by_lane == {
        str(team.member.pk): {todo: 1, **everything_else},
        "": {todo: 1, **everything_else},
    }
    [mine] = [lane for lane in lanes if lane.key == str(team.member.pk)]
    tasks, _ = board.list_column(
        team.member,
        team.ws,
        str(project.pk),
        group_by="status",
        column=todo,
        lane=mine.key,
        swimlane="assignee",
    )
    assert [t.title for t in tasks] == ["mine"]


def test_unknown_grouping_and_columns_are_refused(team: Any, project: Any) -> None:
    with pytest.raises(ApiError):
        board.get(team.member, team.ws, str(project.pk), group_by="title")
    with pytest.raises(ApiError):
        board.get(team.member, team.ws, str(project.pk), swimlane="status")


def test_dropping_a_card_in_another_column_changes_its_status_and_place(
    team: Any, project: Any
) -> None:
    ids = _ids(project)
    a = _make(team, project, "a", status=ids["Done"])
    b = _make(team, project, "b", status=ids["Done"])
    mover = _make(team, project, "mover")

    moved = _move(team, project, mover, ids["Done"], after_id=str(a.pk), before_id=str(b.pk))

    assert moved.status.name == "Done"
    assert _titles(team, project, ids["Done"]) == ["a", "mover", "b"]
    assert _titles(team, project, ids["To do"]) == []


def test_dropping_at_the_top_and_at_the_bottom(team: Any, project: Any) -> None:
    todo = _ids(project)["To do"]
    a = _make(team, project, "a")
    b = _make(team, project, "b")
    c = _make(team, project, "c")

    _move(team, project, c, todo, before_id=str(a.pk))
    assert _titles(team, project, todo) == ["c", "a", "b"]

    _move(team, project, a, todo)  # nothing around it: the end
    assert _titles(team, project, todo) == ["c", "b", "a"]
    assert b.pk


def test_reordering_inside_a_column_never_conflicts(team: Any, project: Any) -> None:
    todo = _ids(project)["To do"]
    a = _make(team, project, "a")
    b = _make(team, project, "b")
    services.update(team.owner, team.ws, str(project.pk), str(a.pk), 1, {"title": "A"})

    _move(team, project, a, todo, after_id=str(b.pk), expected_version=1)  # stale on purpose

    assert _titles(team, project, todo) == ["b", "A"]


def test_a_refused_transition_leaves_the_card_where_it_was(team: Any, project: Any) -> None:
    ids = _ids(project)
    view = workflows.get(team.owner, team.ws, str(project.pk))
    draft = WorkflowDraft(
        statuses=tuple(
            StatusDraft(str(s.pk), s.name, s.color, s.category, s.is_default) for s in view.statuses
        ),
        transitions=(
            TransitionDraft(ids["To do"], ids["In progress"]),
            TransitionDraft(ids["In progress"], ids["Done"]),
        ),
        restrict=True,
    )
    workflows.update(team.admin, team.ws, str(project.pk), 1, draft, {})
    a = _make(team, project, "a")
    b = _make(team, project, "b")

    with pytest.raises(ApiError) as refused:
        _move(team, project, b, ids["Done"])

    assert refused.value.title is ResponseTitle.TRANSITION_NOT_ALLOWED
    assert _titles(team, project, ids["To do"]) == ["a", "b"]
    assert Task.objects.get(pk=b.pk).version == b.version
    assert a.pk


def test_dropping_in_a_priority_or_assignee_column_sets_that_field(team: Any, project: Any) -> None:
    task = _make(team, project, "t")

    by_priority = _move(team, project, task, "urgent", group_by="priority")
    by_person = _move(team, project, by_priority, str(team.member.pk), group_by="assignee")
    cleared = _move(team, project, by_person, "", group_by="assignee")

    assert by_priority.priority == "urgent"
    assert [str(a.user_id) for a in by_person.assignees.all()] == [str(team.member.pk)]
    assert list(cleared.assignees.all()) == []


def test_two_drags_into_the_same_gap_both_land_in_a_sane_order(team: Any, project: Any) -> None:
    todo = _ids(project)["To do"]
    a = _make(team, project, "a")
    b = _make(team, project, "b")
    x = _make(team, project, "x")
    y = _make(team, project, "y")

    _move(team, project, x, todo, after_id=str(a.pk), before_id=str(b.pk))
    _move(team, project, y, todo, after_id=str(a.pk), before_id=str(b.pk))

    titles = _titles(team, project, todo)
    assert titles[0] == "a" and titles[-1] == "b" and set(titles[1:3]) == {"x", "y"}
    positions = list(Task.objects.filter(project=project).values_list("position", flat=True))
    assert len(set(positions)) == len(positions)


def test_stale_neighbours_still_place_the_card(team: Any, project: Any) -> None:
    todo = _ids(project)["To do"]
    a = _make(team, project, "a")
    b = _make(team, project, "b")
    c = _make(team, project, "c")

    # The neighbours changed order since the person looked: "after c, before a".
    _move(team, project, b, todo, after_id=str(c.pk), before_id=str(a.pk))

    assert _titles(team, project, todo)[-1] == "b" or _titles(team, project, todo)[0] == "b"
    assert sorted(_titles(team, project, todo)) == ["a", "b", "c"]


def test_ranks_stay_short_because_the_server_rebalances(team: Any, project: Any) -> None:
    todo = _ids(project)["To do"]
    low = _make(team, project, "low")
    high = _make(team, project, "high")
    moving = [_make(team, project, f"m{n}") for n in range(4)]
    for task in moving * 8:  # always into the same shrinking gap
        task.refresh_from_db()
        _move(team, project, task, todo, after_id=str(low.pk), before_id=str(high.pk))

    positions = list(Task.objects.filter(project=project).values_list("position", flat=True))
    assert max(len(p) for p in positions) <= board.REBALANCE_AT
    titles = _titles(team, project, todo)
    assert titles[0] == "low" and titles[-1] == "high" and len(titles) == 6
    assert rank.ALPHABET  # ranks are still the fractional strings


def test_a_parent_takes_its_subtasks_along_in_tree_order(team: Any, project: Any) -> None:
    todo = _ids(project)["To do"]
    a = _make(team, project, "a")
    parent = _make(team, project, "parent")
    _make(team, project, "child", parent_id=str(parent.pk))

    _move(team, project, parent, todo, before_id=str(a.pk))

    page, _ = services.list_page(team.member, team.ws, str(project.pk), include_subtasks=True)
    assert [t.title for t in page] == ["parent", "child", "a"]


def test_viewers_cannot_move_and_strangers_see_nothing(team: Any, project: Any) -> None:
    task = _make(team, project, "t")
    todo = _ids(project)["To do"]

    with pytest.raises(ApiError):
        board.move_card(
            team.viewer,
            team.ws,
            str(project.pk),
            str(task.pk),
            group_by="status",
            column=todo,
            expected_version=1,
        )
    with pytest.raises(ApiError):
        board.get(team.outsider, team.ws, str(project.pk))
    assert board.get(team.viewer, team.ws, str(project.pk))  # read-only is fine


def test_a_neighbour_from_another_project_is_not_found(team: Any, project: Any) -> None:
    other = team.create(team.owner, "API", name="Api")
    foreign = services.create(team.owner, team.ws, str(other.pk), "foreign")
    task = _make(team, project, "t")

    with pytest.raises(ApiError) as missing:
        _move(team, project, task, _ids(project)["To do"], after_id=str(foreign.pk))

    assert missing.value.status == 404


def test_dropping_a_card_back_on_itself_changes_nothing(team: Any, project: Any) -> None:
    todo = _ids(project)["To do"]
    a = _make(team, project, "a")
    _make(team, project, "b")

    again = _move(team, project, a, todo, after_id=str(a.pk))

    assert again.version == a.version
    assert _titles(team, project, todo) == ["a", "b"]


def test_dropping_in_another_persons_column_keeps_the_other_assignees(
    team: Any, project: Any
) -> None:
    ann, bob = str(team.member.pk), str(team.admin.pk)
    task = _make(team, project, "t", assignee_ids=[ann, bob])

    moved = _move(team, project, task, str(team.owner.pk), group_by="assignee")

    assert {str(a.user_id) for a in moved.assignees.all()} == {str(team.owner.pk), bob}


def test_dropping_in_a_select_field_column_sets_the_option(team: Any, project: Any) -> None:
    field = fields.create(
        team.owner,
        team.ws,
        str(project.pk),
        name="Env",
        type="select",
        options=[{"label": "dev"}, {"label": "prod"}],
    )
    dev, prod = (o["id"] for o in field.options)
    task = _make(team, project, "t", field_values={str(field.pk): dev})

    _move(team, project, task, prod, group_by=f"field:{field.pk}")

    columns = board.get(team.member, team.ws, str(project.pk), group_by=f"field:{field.pk}")[0]
    assert {c.key: c.count for c in columns.columns} == {dev: 0, prod: 1, "": 0}


def test_a_subtask_is_not_a_card(team: Any, project: Any) -> None:
    parent = _make(team, project, "p")
    child = _make(team, project, "c", parent_id=str(parent.pk))

    with pytest.raises(ApiError):
        _move(team, project, child, _ids(project)["Done"])


def test_rebalancing_keeps_subtasks_under_their_parent(team: Any, project: Any) -> None:
    todo = _ids(project)["To do"]
    low = _make(team, project, "low")
    high = _make(team, project, "high")
    parent = _make(team, project, "parent")
    _make(team, project, "child", parent_id=str(parent.pk))
    others = [_make(team, project, f"m{n}") for n in range(3)]
    for task in [*others, parent] * 8:
        task.refresh_from_db()
        _move(team, project, task, todo, after_id=str(low.pk), before_id=str(high.pk))

    page, _ = services.list_page(team.member, team.ws, str(project.pk), include_subtasks=True)
    titles = [t.title for t in page]
    assert titles.index("child") == titles.index("parent") + 1
    assert titles[0] == "low" and titles[-1] == "high"
