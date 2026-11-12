"""Saving and sharing dashboards, and who may see what."""

import uuid
from typing import Any

import pytest

from infrastructure.common.errors import ApiError
from infrastructure.dashboards import config as cfg
from infrastructure.dashboards import services
from infrastructure.dashboards.services import WidgetInput
from infrastructure.sync.actor import set_actor


def widget(kind: str = "number", **config: Any) -> WidgetInput:
    return WidgetInput(str(uuid.uuid4()), kind, f"A {kind}", config)


def save(world: Any, user: Any, *widgets: WidgetInput, **kw: Any) -> Any:
    args: dict[str, Any] = {
        "name": "Board",
        "visibility": "personal",
        "project_id": "",
        "widgets": widgets,
        "layout": [],
    }
    args.update(kw)
    dashboard_id = args.pop("dashboard_id", "")
    return services.save(user, world.ws, dashboard_id, **args)


def six_types(world: Any) -> list[WidgetInput]:
    sprint_id = str(uuid.uuid4())
    return [
        widget("number"),
        widget("bar", group_by="status"),
        widget("line", group_by="created_week"),
        widget("pie", group_by="priority"),
        widget("table", group_by="project"),
        widget("workload"),
    ] + [widget("burndown", sprint_id=sprint_id, project_id=str(world.web.pk))][:0]


def test_a_dashboard_of_six_widget_types_is_built_and_shared(world: Any) -> None:
    view = save(world, world.owner, *six_types(world), visibility="workspace", name="Team")
    assert [w.type for w in view.widgets] == ["number", "bar", "line", "pie", "table", "workload"]
    assert view.can_edit
    seen = services.get(world.member, world.ws, str(view.dashboard.pk))
    assert len(seen.widgets) == 6 and not seen.can_edit
    assert [c["widget_id"] for c in seen.dashboard.layout] == [str(w.pk) for w in seen.widgets]


def test_a_personal_dashboard_is_the_owners_alone(world: Any) -> None:
    view = save(world, world.owner, widget())
    with pytest.raises(ApiError) as hidden:
        services.get(world.member, world.ws, str(view.dashboard.pk))
    assert hidden.value.status == 404
    assert services.list_dashboards(world.member, world.ws) == []


def test_sharing_needs_the_manage_permission(world: Any) -> None:
    with pytest.raises(ApiError):
        save(world, world.member, widget(), visibility="workspace")
    mine = save(world, world.member, widget(), name="Mine")
    assert mine.can_edit


def test_a_project_dashboard_is_for_those_who_can_open_the_project(world: Any) -> None:
    view = save(world, world.owner, widget(), visibility="project", project_id=str(world.sec.pk))
    assert services.list_dashboards(world.member, world.ws) == []  # Sec is private
    assert [v.dashboard.pk for v in services.list_dashboards(world.owner, world.ws)] == [
        view.dashboard.pk
    ]
    open_one = save(
        world, world.owner, widget(), visibility="project", project_id=str(world.web.pk)
    )
    assert [v.dashboard.pk for v in services.list_dashboards(world.member, world.ws)] == [
        open_one.dashboard.pk
    ]


def test_only_the_owner_or_a_manager_changes_a_shared_dashboard(world: Any) -> None:
    view = save(world, world.owner, widget(), visibility="workspace")
    with pytest.raises(ApiError):
        save(
            world,
            world.member,
            widget(),
            visibility="workspace",
            dashboard_id=str(view.dashboard.pk),
            expected_version=1,
        )
    with pytest.raises(ApiError):
        services.delete(world.member, world.ws, str(view.dashboard.pk))
    services.delete(world.owner, world.ws, str(view.dashboard.pk))


def test_a_stale_version_is_a_conflict_and_a_save_bumps_it(world: Any) -> None:
    view = save(world, world.owner, widget())
    again = save(
        world, world.owner, widget(), dashboard_id=str(view.dashboard.pk), expected_version=1
    )
    assert again.dashboard.version == 2
    with pytest.raises(ApiError) as conflict:
        save(world, world.owner, widget(), dashboard_id=str(view.dashboard.pk), expected_version=1)
    assert conflict.value.status == 409


def test_at_most_twenty_widgets(world: Any) -> None:
    save(world, world.owner, *[widget() for _ in range(cfg.MAX_WIDGETS)])
    with pytest.raises(ApiError) as many:
        save(world, world.owner, *[widget() for _ in range(cfg.MAX_WIDGETS + 1)])
    assert "at most" in str(many.value)


@pytest.mark.parametrize(
    "bad",
    [
        widget("bar"),  # no grouping
        widget("line", group_by="status"),
        widget("pie", group_by="nonsense"),
        widget("number", measure="vibes"),
        widget("burndown"),  # no sprint
        widget("bar", group_by="assignee", measure="cycle_days"),
        widget("number", limit=999),
        WidgetInput(str(uuid.uuid4()), "heatmap", "x", {}),
        WidgetInput("not-a-uuid", "number", "x", {}),
    ],
)
def test_a_widget_that_makes_no_sense_is_refused(world: Any, bad: WidgetInput) -> None:
    with pytest.raises(ApiError):
        save(world, world.owner, bad)


def test_a_layout_must_fit_the_grid(world: Any) -> None:
    w = widget()
    with pytest.raises(ApiError):
        save(world, world.owner, w, layout=[{"widget_id": w.id, "x": 10, "y": 0, "w": 6, "h": 2}])
    ok = save(world, world.owner, w, layout=[{"widget_id": w.id, "x": 6, "y": 1, "w": 6, "h": 2}])
    assert ok.dashboard.layout[0]["x"] == 6


def test_widgets_are_replaced_by_id_and_a_changed_one_gets_a_new_version(world: Any) -> None:
    a, b = widget("number"), widget("bar", group_by="status")
    view = save(world, world.owner, a, b)
    changed = WidgetInput(a.id, "number", "Open", {"scope": "open"})
    after = save(
        world, world.owner, changed, dashboard_id=str(view.dashboard.pk), expected_version=1
    )
    assert [str(w.pk) for w in after.widgets] == [a.id]
    assert after.widgets[0].version == 2 and after.widgets[0].config["scope"] == "open"


def test_a_widget_id_cannot_be_taken_from_another_dashboard(world: Any) -> None:
    first = widget()
    save(world, world.owner, first)
    with pytest.raises(ApiError):
        save(world, world.owner, first, name="Other")


def test_templates_make_six_widgets_each(world: Any) -> None:
    mine = services.from_template(world.owner, world.ws, "my_work")
    overview = services.from_template(world.owner, world.ws, "project_overview", str(world.web.pk))
    assert len(mine.widgets) == len(overview.widgets) == 6
    with pytest.raises(ApiError):
        services.from_template(world.owner, world.ws, "project_overview")
    set_actor(world.owner)
    for w in [*mine.widgets, *overview.widgets]:
        services.widget_data(world.owner, world.ws, str(w.pk))


def test_changing_a_dashboard_must_say_which_version(world: Any) -> None:
    view = save(world, world.owner, widget())
    with pytest.raises(ApiError) as missing:
        save(world, world.owner, widget(), dashboard_id=str(view.dashboard.pk))
    assert "expected_version" in str(missing.value)


def test_a_workspace_dashboard_about_a_private_project_is_for_that_projects_people(
    world: Any,
) -> None:
    view = save(world, world.owner, widget(), visibility="workspace", project_id=str(world.sec.pk))
    assert services.list_dashboards(world.member, world.ws) == []  # not even its name
    with pytest.raises(ApiError):
        services.get(world.member, world.ws, str(view.dashboard.pk))
    assert [v.dashboard.pk for v in services.list_dashboards(world.owner, world.ws)] == [
        view.dashboard.pk
    ]


def test_a_manager_can_move_cards_on_a_dashboard_built_on_a_private_filter(world: Any) -> None:
    from infrastructure.filters import services as filter_services
    from infrastructure.workspaces import roles
    from infrastructure.workspaces.models import WorkspaceMember

    admin = world.member
    WorkspaceMember.objects.filter(workspace=world.ws, user=admin).update(
        role=roles.access.builtin_role("Admin")
    )
    private, _ = filter_services.save(
        world.owner, world.ws, "", name="Mine", text="priority = high", visibility="private"
    )
    w = WidgetInput(str(uuid.uuid4()), "number", "n", {"source": {"filter_id": str(private.pk)}})
    view = save(world, world.owner, w, visibility="workspace")
    moved = services.save(
        admin,
        world.ws,
        str(view.dashboard.pk),
        name="Board",
        visibility="workspace",
        project_id="",
        widgets=[w],
        layout=[{"widget_id": w.id, "x": 3, "y": 0, "w": 6, "h": 3}],
        expected_version=1,
    )
    assert moved.dashboard.layout[0]["x"] == 3


def test_an_owner_who_lost_the_manage_permission_can_still_save_their_shared_dashboard(
    world: Any,
) -> None:
    from infrastructure.workspaces import access
    from infrastructure.workspaces.models import WorkspaceMember

    view = save(world, world.owner, widget(), visibility="workspace")
    other = services.save(
        world.owner, world.ws, "", name="Other", visibility="workspace", project_id="",
        widgets=[widget()], layout=[],
    )  # fmt: skip
    WorkspaceMember.objects.filter(workspace=world.ws, user=world.owner).update(
        role=access.builtin_role("Member")
    )
    again = services.save(
        world.owner,
        world.ws,
        str(view.dashboard.pk),
        name="Renamed",
        visibility="workspace",
        project_id="",
        widgets=[widget()],
        layout=[],
        expected_version=1,
    )
    assert again.dashboard.name == "Renamed" and other.dashboard.pk
    with pytest.raises(ApiError):  # but widening who sees it is sharing
        services.save(
            world.owner,
            world.ws,
            str(again.dashboard.pk),
            name="Renamed",
            visibility="project",
            project_id=str(world.web.pk),
            widgets=[widget()],
            layout=[],
            expected_version=2,
        )


def test_a_dashboard_moved_to_another_project_is_not_served_the_old_numbers(world: Any) -> None:
    world.task(world.web, "w")
    world.task(world.sec, "s")
    w = widget("number")
    view = save(world, world.owner, w, visibility="project", project_id=str(world.web.pk))
    first = services.widget_data(world.owner, world.ws, str(view.widgets[0].pk)).result.total
    moved = services.save(
        world.owner, world.ws, str(view.dashboard.pk), name="Board", visibility="project",
        project_id=str(world.sec.pk), widgets=[w], layout=[], expected_version=1,
    )  # fmt: skip
    after = services.widget_data(world.owner, world.ws, str(moved.widgets[0].pk))
    assert (first, after.result.total) == (1, 1) and not after.cached  # recomputed, not replayed


def test_a_filter_too_long_to_keep_whole_is_refused(world: Any) -> None:
    with pytest.raises(ApiError):
        save(world, world.owner, widget("number", source={"tfql": "priority = high " * 200}))


def test_deleting_answers_the_real_id(world: Any) -> None:
    view = save(world, world.owner, widget())
    assert str(services.delete(world.owner, world.ws, str(view.dashboard.pk))) == str(
        view.dashboard.pk
    )
