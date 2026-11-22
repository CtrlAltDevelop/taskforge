"""The goals widget: one bar per goal the viewer may see, each at its rolled-up progress."""

import uuid
from typing import Any

import pytest

from infrastructure.common.errors import ApiError
from infrastructure.dashboards import services
from infrastructure.dashboards.services import WidgetInput
from infrastructure.goals import services as goals


def _widget(**config: Any) -> WidgetInput:
    return WidgetInput(str(uuid.uuid4()), "goals", "Goals", config)


def _data(world: Any, user: Any, **config: Any) -> Any:
    view = services.save(
        world.owner,
        world.ws,
        "",
        name="D",
        visibility="workspace",
        project_id="",
        widgets=[_widget(**config)],
        layout=[],
    )
    return services.widget_data(user, world.ws, str(view.widgets[0].pk)).result


def _goal(world: Any, name: str, *, reading: int | None = None, **extra: Any) -> Any:
    view = goals.create(world.owner, world.ws, name, "2026-01-01", "2026-12-31", **extra)
    if reading is not None:
        made = goals.create_kr(
            world.owner, world.ws, str(view.goal.pk), "KR", "number", target_value=100
        )
        goals.add_check_in(world.owner, world.ws, str(made.krs[-1].kr.pk), reading)
    return view.goal


def test_each_top_level_goal_is_a_bucket_at_its_progress(world: Any) -> None:
    _goal(world, "Ship", reading=40)
    _goal(world, "Grow", reading=80)

    result = _data(world, world.member)

    assert {b.label: int(b.value) for b in result.buckets} == {"Ship": 40, "Grow": 80}
    assert int(result.total) == 60  # the weighted average of the two


def test_a_child_goal_is_not_listed_on_its_own(world: Any) -> None:
    parent = _goal(world, "Parent")
    _goal(world, "Child", reading=50, parent_id=str(parent.pk))

    result = _data(world, world.owner)

    assert [b.label for b in result.buckets] == ["Parent"]
    assert int(result.buckets[0].value) == 50  # rolled up from the child


def test_a_private_goal_is_not_counted_for_someone_who_cannot_see_it(world: Any) -> None:
    _goal(world, "Open", reading=100)
    _goal(world, "Secret", reading=0, private=True)

    seen_by_member = _data(world, world.member)
    seen_by_owner = _data(world, world.owner)

    assert [b.label for b in seen_by_member.buckets] == ["Open"]
    assert int(seen_by_member.total) == 100
    assert {b.label for b in seen_by_owner.buckets} == {"Open", "Secret"}


def test_scope_open_leaves_out_finished_goals(world: Any) -> None:
    _goal(world, "Done", reading=100)
    _goal(world, "Going", reading=10)

    result = _data(world, world.owner, scope="open")

    assert [b.label for b in result.buckets] == ["Going"]


def test_no_goals_is_an_empty_widget_not_an_error(world: Any) -> None:
    result = _data(world, world.owner)

    assert result.buckets == [] and int(result.total) == 0


def test_a_goals_widget_has_no_tasks_to_drill_into(world: Any) -> None:
    _goal(world, "Ship", reading=40)
    view = services.save(
        world.owner, world.ws, "", name="D", visibility="workspace", project_id="",
        widgets=[_widget()], layout=[],
    )  # fmt: skip

    drilled = services.drilldown(world.owner, world.ws, str(view.widgets[0].pk))

    assert drilled.tasks == []


def test_the_goals_widget_takes_no_grouping(world: Any) -> None:
    from infrastructure.dashboards import config as cfg

    assert cfg.normalise("goals", {"group_by": "status"})["group_by"] == ""
    with pytest.raises(ApiError):
        cfg.normalise("goals", {"scope": "nonsense"})
