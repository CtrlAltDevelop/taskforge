"""Boundaries: daylight saving and Feb 29 through the clock, preview parity, another workspace,
and the clock's failure branches."""

from datetime import UTC, datetime
from typing import Any

import pytest
from django.contrib.auth import get_user_model

from infrastructure.projects import services as project_services
from infrastructure.recurrence import clock, receivers, services
from infrastructure.recurrence.models import Occurrence, RecurrenceSeries
from infrastructure.recurrence.tests.conftest import World, at
from infrastructure.sync.actor import set_actor
from infrastructure.tasks import services as task_services
from infrastructure.tasks.models import Task
from infrastructure.workspaces import services as workspace_services
from infrastructure.workspaces.models import MemberStatus, WorkspaceMember


def utc(year: int, month: int, day: int, hour: int = 0, minute: int = 0) -> datetime:
    return datetime(year, month, day, hour, minute, tzinfo=UTC)


def test_spring_forward_keeps_nine_local(world: World) -> None:
    world.repeat(
        world.task(due_date="2026-03-01"),
        "FREQ=WEEKLY",
        timezone_name="America/New_York",
        at_time="09:00",
    )
    assert clock.generate_due(utc(2026, 3, 1 + 7, 12, 59)) == 0  # 08:59 EDT
    assert clock.generate_due(utc(2026, 3, 8, 13, 0)) == 1  # 09:00 EDT, not 09:00 EST (14:00)
    assert Task.objects.get(occurrence__index=1).due_date.isoformat() == "2026-03-08"


def test_fall_back_keeps_nine_local(world: World) -> None:
    world.repeat(
        world.task(due_date="2026-10-25"),
        "FREQ=WEEKLY",
        timezone_name="America/New_York",
        at_time="09:00",
    )
    assert clock.generate_due(utc(2026, 11, 1, 13, 59)) == 0  # 08:59 EST
    assert clock.generate_due(utc(2026, 11, 1, 14, 0)) == 1  # 09:00 EST
    assert Task.objects.get(occurrence__index=1).due_date.isoformat() == "2026-11-01"


def test_a_feb_29_task_repeats_yearly_on_the_28th_then_29th_again(world: World) -> None:
    world.repeat(world.task(due_date="2028-02-29"), "FREQ=YEARLY")
    assert clock.generate_due(at("2029-02-28", 10)) == 1
    assert Task.objects.get(occurrence__index=1).due_date.isoformat() == "2029-02-28"


CASES = [
    ("FREQ=DAILY", "2026-11-04", {"skip_weekends": True}),
    ("FREQ=DAILY;COUNT=4", "2026-11-02", {}),
    ("FREQ=MONTHLY;BYMONTHDAY=31", "2026-01-31", {}),
    ("FREQ=MONTHLY;BYDAY=-1FR", "2026-11-01", {}),
    ("FREQ=WEEKLY;INTERVAL=2;BYDAY=MO,TH", "2026-11-02", {}),
]


@pytest.mark.parametrize(("rule", "start", "extra"), CASES)
def test_the_preview_is_what_the_clock_makes(
    world: World, rule: str, start: str, extra: dict[str, Any]
) -> None:
    shown = services.preview(
        world.owner, world.ws, rrule=rule, mode="schedule", starts_on=start, count=6, **extra
    ).dates
    world.repeat(world.task(due_date=start), rule, **extra)
    for day in shown:
        clock.generate_due(at(day.isoformat(), 10))
    made = Task.objects.filter(occurrence__index__gt=0).order_by("occurrence__index")
    assert [t.due_date for t in made] == shown
    if "COUNT" in rule:
        assert clock.generate_due(at("2030-01-01")) == 0  # and nothing more
    assert shown


def test_the_after_completion_preview_is_what_completion_makes(world: World) -> None:
    rule = "FREQ=DAILY;INTERVAL=3"
    shown = services.preview(
        world.owner, world.ws, rrule=rule, mode="after_completion", starts_on="2026-11-02", count=3
    ).dates
    first = world.task(due_date="2026-11-02")
    world.repeat(first, rule, mode="after_completion")
    current = first
    for day in shown:
        world.finish(current)
        previous = Occurrence.objects.order_by("-index").first()
        clock.on_completed(current.pk, at(previous.occurs_on.isoformat(), 10))
        current = Task.objects.get(occurrence__index=Occurrence.objects.count() - 1)
        assert current.due_date == day


@pytest.fixture
def other(db: None) -> tuple[Any, Any, Any]:
    user = get_user_model().objects.create_user("zed", "z@x.test", "pw-123456-x")
    ws = workspace_services.create(user, "Other", "other")
    set_actor(user)
    project = project_services.create(user, ws, "Their", "THR").project
    return user, ws, project


def test_another_workspace_cannot_reach_a_series(world: World, other: Any) -> None:
    user, ws, project = other
    mine = world.task()
    world.repeat(mine, "FREQ=DAILY")
    args = (str(world.web.pk), str(mine.pk))  # my project and task, their workspace
    refusals = [
        world.refused(services.get, user, ws, *args),
        world.refused(services.set_rule, user, ws, *args, rrule="FREQ=DAILY", mode="schedule"),
        world.refused(services.clear, user, ws, *args),
        world.refused(services.pause, user, ws, *args, True),
        world.refused(services.update_future, user, ws, *args),
        world.refused(services.get, user, ws, str(project.pk), str(mine.pk)),
    ]
    assert {r.status for r in refusals} <= {403, 404}
    assert RecurrenceSeries.objects.count() == 1
    assert services.upcoming(user, ws, "2026-11-01", "2026-11-30") == []


def test_upcoming_stops_at_the_series_end_date(world: World) -> None:
    world.repeat(world.task(due_date="2026-11-02"), "FREQ=DAILY", ends_on="2026-11-05")
    ghosts = services.upcoming(world.owner, world.ws, "2026-11-01", "2026-11-30")
    assert [g.due_date.isoformat() for g in ghosts] == ["2026-11-03", "2026-11-04", "2026-11-05"]


def test_pause_and_update_future_need_a_series(world: World) -> None:
    task = world.task()
    args = (str(world.web.pk), str(task.pk))
    assert world.refused(services.pause, world.owner, world.ws, *args, True).status == 404
    assert world.refused(services.update_future, world.owner, world.ws, *args).status == 404


def test_after_completion_stops_at_the_end_date(world: World) -> None:
    first = world.task(due_date="2026-11-02")
    world.repeat(first, "FREQ=DAILY;INTERVAL=3", mode="after_completion", ends_on="2026-11-04")
    world.finish(first)
    assert clock.on_completed(first.pk, at("2026-11-02", 10)) is False  # 5 Nov is past it
    assert Occurrence.objects.count() == 1


def test_a_template_that_no_longer_works_pauses_the_series(world: World) -> None:
    first = world.task(due_date="2026-11-02")
    world.repeat(first, "FREQ=WEEKLY")
    RecurrenceSeries.objects.update(
        template={**RecurrenceSeries.objects.get().template, "title": ""}
    )
    assert clock.generate_due(at("2026-11-09", 10)) == 0
    series = RecurrenceSeries.objects.get()
    assert series.paused and series.pause_reason
    assert Occurrence.objects.count() == 1


def test_a_broken_template_pauses_an_after_completion_series(world: World) -> None:
    first = world.task(due_date="2026-11-02")
    world.repeat(first, "FREQ=WEEKLY", mode="after_completion")
    RecurrenceSeries.objects.update(
        template={**RecurrenceSeries.objects.get().template, "title": ""}
    )
    world.finish(first)
    assert clock.on_completed(first.pk) is False
    assert RecurrenceSeries.objects.get().paused


def test_one_broken_series_does_not_stop_the_others(
    world: World, monkeypatch: pytest.MonkeyPatch
) -> None:
    world.repeat(world.task(title="A", due_date="2026-11-02"), "FREQ=DAILY")
    world.repeat(world.task(title="B", due_date="2026-11-02"), "FREQ=DAILY")
    real = clock._generate_one
    calls: list[Any] = []

    def flaky(series_id: Any, now: datetime) -> int:
        calls.append(series_id)
        if len(calls) == 1:
            raise RuntimeError("boom")
        return real(series_id, now)

    monkeypatch.setattr(clock, "_generate_one", flaky)
    assert clock.generate_due(at("2026-11-03", 10)) == 1
    assert len(calls) == 2


def test_one_broken_continuation_does_not_stop_the_others(
    world: World, monkeypatch: pytest.MonkeyPatch
) -> None:
    for title in ("A", "B"):
        task = world.task(title=title, due_date="2026-11-02")
        world.repeat(task, "FREQ=DAILY", mode="after_completion")
        world.finish(task)
    real = clock._continue
    calls: list[Any] = []

    def flaky(series_id: Any, done: Any, now: datetime) -> bool:
        calls.append(series_id)
        if len(calls) == 1:
            raise RuntimeError("boom")
        return real(series_id, done, now)

    monkeypatch.setattr(clock, "_continue", flaky)
    assert clock.catch_up_completions() == 1


def test_the_completion_signal_never_raises(world: World, monkeypatch: pytest.MonkeyPatch) -> None:
    def boom(*_: Any, **__: Any) -> None:
        raise RuntimeError("boom")

    monkeypatch.setattr(clock, "on_completed", boom)
    receivers._activity(Task, kind="status_changed", task_id="x")
    receivers._activity(Task, kind="created", task_id="x")  # other kinds are ignored


def test_edit_future_keeps_going_when_a_person_left(world: World) -> None:
    first = world.task(title="Report", due_date="2026-11-02")
    world.repeat(first, "FREQ=DAILY")
    for day in ("2026-11-03", "2026-11-04"):
        clock.generate_due(at(day, 10))
    this = Task.objects.get(occurrence__index=1)
    task_services.update(
        world.owner, world.ws, str(this.project_id), str(this.pk), this.version,
        {"title": "Daily", "assignee_ids": [str(world.member.pk)]},
    )  # fmt: skip
    WorkspaceMember.objects.filter(user=world.member).update(status=MemberStatus.REMOVED)
    _, changed = services.update_future(world.owner, world.ws, str(this.project_id), str(this.pk))
    later = Task.objects.get(occurrence__index=2)
    assert changed == 1 and later.title == "Daily"
    assert list(later.assignee_ids()) == []


def test_monthly_from_the_30th_makes_one_instance_a_month(world: World) -> None:
    shown = services.preview(
        world.owner,
        world.ws,
        rrule="FREQ=MONTHLY",
        mode="schedule",
        starts_on="2026-01-30",
        count=4,
    ).dates
    assert [d.isoformat() for d in shown] == [
        "2026-02-28",
        "2026-03-30",
        "2026-04-30",
        "2026-05-30",
    ]


def test_a_failure_part_way_through_a_catch_up_keeps_the_numbers(
    world: World, settings: Any, monkeypatch: pytest.MonkeyPatch
) -> None:
    settings.RECURRENCE_MAX_CATCHUP = 3
    world.repeat(world.task(due_date="2026-11-02"), "FREQ=DAILY")
    from infrastructure.recurrence import template

    real = template.instantiate

    def second_fails(series: Any, due: Any, index: int) -> Any:
        if index == 2:
            raise services.ApiError("A required field has no value.")
        return real(series, due, index)

    monkeypatch.setattr(template, "instantiate", second_fails)
    assert clock.generate_due(at("2026-11-04", 10)) == 1  # index 1 made, index 2 fails
    series = RecurrenceSeries.objects.get()
    assert series.paused and series.last_index == 1
    monkeypatch.setattr(template, "instantiate", real)
    services.pause(world.owner, world.ws, str(world.web.pk), str(Task.objects.first().pk), False)
    assert clock.generate_due(at("2099-01-01", 10)) >= 1  # numbers carry on, no clash
    assert Occurrence.objects.filter(index__gt=1).exists()  # skipped days keep counting


def test_a_clash_pauses_the_series_instead_of_looping(
    world: World, monkeypatch: pytest.MonkeyPatch
) -> None:
    from django.db import IntegrityError

    from infrastructure.recurrence import template

    world.repeat(world.task(due_date="2026-11-02"), "FREQ=DAILY")

    def clash(*_: Any, **__: Any) -> Any:
        raise IntegrityError("duplicate")

    monkeypatch.setattr(template, "instantiate", clash)
    assert clock.generate_due(at("2026-11-03", 10)) == 0
    series = RecurrenceSeries.objects.get()
    assert series.paused and series.pause_reason
    assert clock.generate_due(at("2026-11-04", 10)) == 0  # not picked up again


def test_ghosts_are_cut_by_date_not_by_series_order(
    world: World, monkeypatch: pytest.MonkeyPatch
) -> None:
    monkeypatch.setattr(services, "GHOSTS_MAX", 100)
    for n in range(12):
        world.repeat(world.task(title=f"Daily {n}", due_date="2026-11-02"), "FREQ=DAILY")
    world.repeat(world.task(title="Weekly", due_date="2026-11-03"), "FREQ=WEEKLY")
    ghosts = services.upcoming(world.owner, world.ws, "2026-11-01", "2026-11-30")
    assert len(ghosts) == 100
    assert any(g.title == "Weekly" for g in ghosts)  # its first date, 10 Nov, is among the first


def test_the_preview_of_a_running_series_starts_after_its_latest_instance(world: World) -> None:
    first = world.task(due_date="2026-11-02")
    world.repeat(first, "FREQ=WEEKLY;BYDAY=MO")
    for day in ("2026-11-09", "2026-11-16"):
        clock.generate_due(at(day, 10))
    shown = services.preview(
        world.owner, world.ws, rrule="FREQ=WEEKLY;BYDAY=MO", mode="schedule",
        starts_on="2026-11-02", after="2026-11-16", count=2,
    ).dates  # fmt: skip
    assert [d.isoformat() for d in shown] == ["2026-11-23", "2026-11-30"]
    assert RecurrenceSeries.objects.get().next_due_on.isoformat() == "2026-11-23"


def test_a_system_pause_is_not_recorded_as_the_persons(world: World) -> None:
    from infrastructure.audit.models import AuditEntry

    first = world.task(due_date="2026-11-02")
    world.repeat(first, "FREQ=WEEKLY", mode="after_completion")
    RecurrenceSeries.objects.update(
        template={**RecurrenceSeries.objects.get().template, "title": ""}
    )
    world.finish(first)
    clock.on_completed(first.pk)
    entry = AuditEntry.objects.filter(action__startswith="recurrence.").order_by("-pk").first()
    assert entry is not None and entry.actor_type == "system"
