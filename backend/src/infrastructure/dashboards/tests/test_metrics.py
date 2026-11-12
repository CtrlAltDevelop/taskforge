"""The numbers: what is counted, for whom, and that a click lists exactly the counted tasks."""

import uuid
from datetime import UTC, datetime, timedelta
from decimal import Decimal
from typing import Any

import pytest
from django.core.cache import cache
from django.utils import timezone

from infrastructure.common.errors import ApiError
from infrastructure.dashboards import services
from infrastructure.dashboards.services import WidgetInput
from infrastructure.projects.models import ProjectMember
from infrastructure.tasks import services as task_services
from infrastructure.tasks.models import Task
from infrastructure.timetracking.models import TimeEntry
from infrastructure.workflows.models import Category, Status


@pytest.fixture(autouse=True)
def _fresh_cache(db: None) -> None:
    cache.clear()


def make(world: Any, kind: str, user: Any = None, **config: Any) -> Any:
    wid = str(uuid.uuid4())
    view = services.save(
        user or world.owner,
        world.ws,
        "",
        name=f"{kind} board",
        visibility="workspace",
        project_id="",
        widgets=[WidgetInput(wid, kind, kind, config)],
        layout=[],
    )
    return view.widgets[0]


def data(world: Any, w: Any, user: Any = None, **kw: Any) -> Any:
    return services.widget_data(user or world.owner, world.ws, str(w.pk), **kw).result


def seed(world: Any) -> None:
    web = world.web
    world.task(web, "a", priority="high", points=3)
    world.task(web, "b", priority="high", points=5)
    world.task(web, "c", priority="low", points=2)
    world.task(world.sec, "secret", priority="urgent", points=8)


def test_a_number_counts_the_tasks_the_viewer_may_see(world: Any) -> None:
    seed(world)
    w = make(world, "number")
    assert data(world, w, world.owner).total == 4
    assert data(world, w, world.member).total == 3  # the private project is not theirs


def test_two_people_with_different_access_see_different_numbers_on_one_dashboard(
    world: Any,
) -> None:
    seed(world)
    w = make(world, "pie", group_by="priority")
    mine = {b.key: b.value for b in data(world, w, world.owner).buckets}
    theirs = {b.key: b.value for b in data(world, w, world.member).buckets}
    assert mine == {"high": 2, "low": 1, "urgent": 1}
    assert theirs == {"high": 2, "low": 1}
    ProjectMember.objects.create(project=world.sec, user=world.member)
    cache.clear()
    assert {b.key for b in data(world, w, world.member).buckets} >= {"urgent"}


def test_a_cached_number_is_never_served_to_someone_else(world: Any) -> None:
    seed(world)
    w = make(world, "number")
    first = services.widget_data(world.owner, world.ws, str(w.pk))
    other = services.widget_data(world.member, world.ws, str(w.pk))
    again = services.widget_data(world.owner, world.ws, str(w.pk))
    assert (first.result.total, other.result.total) == (4, 3)
    assert again.cached and not other.cached
    world.task(world.web, "new")
    assert services.widget_data(world.owner, world.ws, str(w.pk)).result.total == 4  # a minute
    fresh = services.widget_data(world.owner, world.ws, str(w.pk), refresh=True)
    assert fresh.result.total == 5 and not fresh.cached


GROUPINGS: list[tuple[str, dict[str, Any]]] = [
    ("status", {}),
    ("category", {}),
    ("assignee", {}),
    ("priority", {}),
    ("project", {}),
    ("sprint", {}),
    ("created_day", {}),
    ("created_week", {}),
    ("due_week", {}),
]


@pytest.mark.parametrize(("group", "extra"), GROUPINGS)
def test_a_drill_down_lists_exactly_what_its_bucket_counted(
    world: Any, group: str, extra: dict[str, Any]
) -> None:
    web = world.web
    world.task(web, "a", priority="high", assignee_ids=[str(world.owner.pk)], due_date="2026-11-10")
    world.task(web, "b", priority="low", assignee_ids=[str(world.member.pk)])
    world.task(web, "c", assignee_ids=[str(world.owner.pk), str(world.member.pk)])
    world.task(world.sec, "d", due_date="2026-11-17")
    w = make(world, "bar", group_by=group, limit=50, range_days=730)
    result = data(world, w)
    assert result.buckets, group
    for bucket in result.buckets:
        tasks = services.drilldown(world.owner, world.ws, str(w.pk), bucket.key).tasks
        assert len(tasks) == bucket.value, (group, bucket.key)


def test_the_whole_number_and_its_drill_down_agree(world: Any) -> None:
    seed(world)
    w = make(world, "number", scope="open")
    n = data(world, w).total
    assert len(services.drilldown(world.owner, world.ws, str(w.pk)).tasks) == n == 4


def test_a_drill_down_is_the_viewers_own_tasks_only(world: Any) -> None:
    seed(world)
    w = make(world, "number")
    titles = {t.title for t in services.drilldown(world.member, world.ws, str(w.pk)).tasks}
    assert titles == {"a", "b", "c"}


def test_points_estimate_and_logged_measures(world: Any) -> None:
    web = world.web
    a = world.task(web, "a", points=3)
    b = world.task(web, "b", points=Decimal("1.5"))
    Task.objects.filter(pk=a.pk).update(estimate_sec=7200)
    Task.objects.filter(pk=b.pk).update(estimate_sec=3600)
    now = timezone.now()
    for task, secs in ((a, 1800), (a, 1800), (b, 900)):
        TimeEntry.objects.create(
            workspace=world.ws,
            task=task,
            user=world.owner,
            started_at=now - timedelta(hours=2),
            ended_at=now,
            duration_sec=secs,
        )
    assert data(world, make(world, "number", measure="points")).total == Decimal("4.50")
    assert data(world, make(world, "number", measure="estimate_hours")).total == Decimal("3.00")
    assert data(world, make(world, "number", measure="logged_hours")).total == Decimal("1.25")


def test_grouped_sums_add_up(world: Any) -> None:
    seed(world)
    w = make(world, "bar", group_by="priority", measure="points")
    buckets = {b.key: b.value for b in data(world, w).buckets}
    assert buckets == {"urgent": 8, "high": 8, "low": 2}
    assert data(world, w).total == 18


def test_a_workload_counts_open_tasks_per_person_and_the_unassigned(world: Any) -> None:
    web = world.web
    world.task(web, "a", assignee_ids=[str(world.owner.pk)])
    world.task(web, "b", assignee_ids=[str(world.owner.pk)])
    world.task(web, "c")
    done = Status.objects.filter(project=web, category=Category.DONE).first()
    finished = world.task(web, "d", assignee_ids=[str(world.member.pk)])
    task_services.move(
        world.owner, world.ws, str(web.pk), str(finished.pk), finished.version, str(done.pk)
    )
    buckets = {b.label: b.value for b in data(world, make(world, "workload")).buckets}
    assert buckets["Unassigned"] == 1
    assert buckets["owner"] == 2 and "member" not in buckets  # done work is not workload


def test_a_widget_filter_narrows_the_tasks(world: Any) -> None:
    seed(world)
    w = make(world, "number", source={"tfql": "priority = high"})
    assert data(world, w).total == 2
    bad = services.save(
        world.owner,
        world.ws,
        "",
        name="x",
        visibility="personal",
        project_id="",
        widgets=[
            WidgetInput(str(uuid.uuid4()), "number", "x", {"source": {"tfql": "priority = high"}})
        ],
        layout=[],
    )
    assert bad.widgets


def test_a_broken_filter_is_refused_when_the_number_is_asked_for(world: Any) -> None:
    w = make(world, "number", source={"tfql": "nonsense ??"})
    with pytest.raises(ApiError):
        data(world, w)


def test_a_saved_filter_can_be_the_source(world: Any) -> None:
    from infrastructure.filters import services as filter_services

    seed(world)
    saved, _ = filter_services.save(
        world.owner, world.ws, "", name="Highs", text="priority = high", visibility="workspace"
    )
    w = make(world, "number", source={"filter_id": str(saved.pk)})
    assert data(world, w).total == 2


def test_days_are_the_viewers_days(world: Any) -> None:
    task = world.task(world.web, "late")
    Task.objects.filter(pk=task.pk).update(created_at=datetime(2026, 11, 10, 23, 30, tzinfo=UTC))
    w = make(world, "line", group_by="created_day", range_days=730)
    utc = services.widget_data(
        world.owner, world.ws, str(w.pk), today="2026-11-12", offset_minutes=0
    )
    plus = services.widget_data(
        world.owner, world.ws, str(w.pk), today="2026-11-12", offset_minutes=60
    )
    assert [b.key for b in utc.result.buckets] == ["2026-11-10"]
    assert [b.key for b in plus.result.buckets] == ["2026-11-11"]
    drilled = services.drilldown(
        world.owner, world.ws, str(w.pk), "2026-11-11", offset_minutes=60
    ).tasks
    assert [t.title for t in drilled] == ["late"]


def test_the_cycle_time_is_read_from_the_history(world: Any) -> None:
    web = world.web
    t = world.task(web, "ship")
    done = Status.objects.filter(project=web, category=Category.DONE).first()
    task_services.move(world.owner, world.ws, str(web.pk), str(t.pk), t.version, str(done.pk))
    from infrastructure.audit.models import AuditEntry

    entry = AuditEntry.objects.get(action="task.status_changed", target_id=str(t.pk))
    created = entry.at - timedelta(days=3, hours=12)
    Task.objects.filter(pk=t.pk).update(created_at=created)
    world.task(web, "still open")
    w = make(world, "number", measure="cycle_days")
    assert data(world, w).total == Decimal("3.50")
    grouped = make(world, "bar", measure="cycle_days", group_by="priority")
    assert {b.key: b.value for b in data(world, grouped).buckets} == {"none": Decimal("3.50")}


def test_a_burndown_widget_reads_the_sprint(world: Any) -> None:
    from infrastructure.projects import services as project_services
    from infrastructure.sprints import services as sprint_services

    project_services.set_features(
        world.owner, world.ws, str(world.web.pk), ["sprints"], world.web.version
    )
    today = timezone.localdate()
    made = sprint_services.create(
        world.owner, world.ws, str(world.web.pk), "S1", "", today.isoformat(),
        (today + timedelta(days=6)).isoformat(),
    ).sprint  # fmt: skip
    task = world.task(world.web, "in sprint", points=5)
    sprint_services.add_tasks(
        world.owner, world.ws, str(world.web.pk), str(made.pk), [str(task.pk)]
    )
    sprint_services.start(world.owner, world.ws, str(world.web.pk), str(made.pk))
    w = make(world, "burndown", sprint_id=str(made.pk), project_id=str(world.web.pk))
    result = data(world, w)
    assert [s.name for s in result.series] == ["Remaining", "Ideal"]
    assert result.total == Decimal("5.00")
    assert [t.title for t in services.drilldown(world.owner, world.ws, str(w.pk)).tasks] == [
        "in sprint"
    ]


def test_buckets_are_capped_and_say_so(world: Any) -> None:
    for i in range(5):
        world.task(world.web, f"t{i}", assignee_ids=[])
    from infrastructure.workflows import services as workflow_services

    del workflow_services
    w = make(world, "bar", group_by="created_day", limit=1, range_days=730)
    assert len(data(world, w).buckets) == 1 and not data(world, w).truncated  # one day only


def test_export_is_csv_of_the_buckets(world: Any) -> None:
    seed(world)
    w = make(world, "bar", group_by="priority")
    text = services.export_csv(world.owner, world.ws, str(w.pk))
    lines = text.strip().splitlines()
    assert lines[0] == "key,label,value" and "high,High,2.00" in lines


def test_a_statement_timeout_is_the_friendly_too_heavy_error(world: Any, monkeypatch: Any) -> None:
    from django.db import OperationalError

    from infrastructure.common.responses import ResponseTitle
    from infrastructure.dashboards import metrics

    def slow(*_: Any, **__: Any) -> Any:
        raise OperationalError("canceling statement due to statement timeout")

    w = make(world, "number")  # no filter: the limit applies to it too
    monkeypatch.setattr(metrics, "_compute", slow)
    with pytest.raises(ApiError) as heavy:
        data(world, w)
    assert heavy.value.title is ResponseTitle.DASHBOARD_TOO_HEAVY
    assert "Narrow its filter" in str(heavy.value)


def test_a_drill_down_past_the_cap_says_it_is_cut_short(world: Any, monkeypatch: Any) -> None:
    for i in range(4):
        world.task(world.web, f"t{i}")
    w = make(world, "number")
    monkeypatch.setattr(services, "DRILL_MAX", 3)
    drilled = services.drilldown(world.owner, world.ws, str(w.pk))
    assert len(drilled.tasks) == 3 and drilled.truncated
    monkeypatch.setattr(services, "DRILL_MAX", 4)
    assert not services.drilldown(world.owner, world.ws, str(w.pk)).truncated


def test_a_line_widget_exports_its_series(world: Any) -> None:
    world.task(world.web, "a")
    w = make(world, "line", group_by="created_week", range_days=30)
    lines = services.export_csv(world.owner, world.ws, str(w.pk)).strip().splitlines()
    assert lines[0] == "series,x,value" and lines[1].startswith("count,")


def test_a_time_axis_keeps_its_newest_buckets_when_there_are_more_than_the_limit(
    world: Any,
) -> None:
    now = timezone.now()
    for weeks_ago in range(5):
        t = world.task(world.web, f"w{weeks_ago}")
        Task.objects.filter(pk=t.pk).update(created_at=now - timedelta(weeks=weeks_ago))
    w = make(world, "line", group_by="created_week", limit=2, range_days=60)
    result = data(world, w)
    keys = [b.key for b in result.buckets]
    assert len(keys) == 2 and result.truncated
    assert keys == sorted(keys)
    this_week = (now - timedelta(days=now.weekday())).date().isoformat()
    assert keys[-1] == this_week  # the current week is not what gets cut


def test_cycle_time_counts_a_move_made_together_with_another_edit(world: Any) -> None:
    from infrastructure.audit.models import AuditEntry

    web = world.web
    t = world.task(web, "ship")
    done = Status.objects.filter(project=web, category=Category.DONE).first()
    task_services.update(
        world.owner,
        world.ws,
        str(web.pk),
        str(t.pk),
        t.version,
        {"status": str(done.pk), "priority": "high"},
    )
    entry = AuditEntry.objects.get(target_id=str(t.pk), action="task.updated")
    assert "status_id" in entry.changes  # a status plus another field: not "status_changed"
    Task.objects.filter(pk=t.pk).update(created_at=entry.at - timedelta(days=2))
    w = make(world, "number", measure="cycle_days")
    assert data(world, w).total == Decimal("2.00")


@pytest.mark.parametrize(
    ("group", "bucket"),
    [
        ("status", "not-a-uuid"),
        ("project", "x"),
        ("category", "nonsense"),
        ("priority", "nonsense"),
        ("created_day", "none"),
        ("created_week", "yesterday"),
        ("due_week", "2026-99-99"),
        ("sprint", "x"),
        ("assignee", "x"),
    ],
)
def test_a_bucket_this_grouping_could_not_have_made_is_refused_not_a_crash(
    world: Any, group: str, bucket: str
) -> None:
    w = make(world, "bar", group_by=group)
    with pytest.raises(ApiError) as bad:
        services.drilldown(world.owner, world.ws, str(w.pk), bucket)
    assert bad.value.status == 400


def test_a_burndowns_drill_down_is_its_open_tasks_in_its_own_project(world: Any) -> None:
    from infrastructure.projects import services as project_services
    from infrastructure.sprints import services as sprint_services

    project_services.set_features(
        world.owner, world.ws, str(world.web.pk), ["sprints"], world.web.version
    )
    today = timezone.localdate()
    made = sprint_services.create(
        world.owner, world.ws, str(world.web.pk), "S1", "", today.isoformat(),
        (today + timedelta(days=6)).isoformat(),
    ).sprint  # fmt: skip
    open_task = world.task(world.web, "open", points=3)
    done_task = world.task(world.web, "finished", points=2)
    sprint_services.add_tasks(
        world.owner,
        world.ws,
        str(world.web.pk),
        str(made.pk),
        [str(open_task.pk), str(done_task.pk)],
    )
    sprint_services.start(world.owner, world.ws, str(world.web.pk), str(made.pk))
    done = Status.objects.filter(project=world.web, category=Category.DONE).first()
    task_services.move(
        world.owner, world.ws, str(world.web.pk), str(done_task.pk),
        Task.objects.get(pk=done_task.pk).version, str(done.pk),
    )  # fmt: skip
    # A dashboard filed under the other project still drills into the chart's own project.
    view = services.save(
        world.owner, world.ws, "", name="x", visibility="project", project_id=str(world.sec.pk),
        widgets=[WidgetInput(str(uuid.uuid4()), "burndown", "b",
                             {"sprint_id": str(made.pk), "project_id": str(world.web.pk)})],
        layout=[],
    )  # fmt: skip
    titles = [
        t.title for t in services.drilldown(world.owner, world.ws, str(view.widgets[0].pk)).tasks
    ]
    assert titles == ["open"]
