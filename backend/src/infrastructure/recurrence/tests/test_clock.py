"""The clock: what is made, when, once, and what happens when it cannot."""

from infrastructure.recurrence import clock, schedule
from infrastructure.recurrence.models import Occurrence, RecurrenceSeries
from infrastructure.recurrence.tests.conftest import World, at
from infrastructure.tasks.models import Task
from infrastructure.workspaces.models import MemberStatus, WorkspaceMember


def dues(world: World) -> list[str]:
    rows = Task.objects.filter(project=world.web, occurrence__isnull=False)
    return sorted(t.due_date.isoformat() for t in rows)


def test_the_first_instance_is_made_on_the_next_rule_date(world: World) -> None:
    first = world.task(due_date="2026-11-02")  # a Monday
    view = world.repeat(first, "FREQ=WEEKLY;BYDAY=MO")
    assert view.series.next_due_on.isoformat() == "2026-11-09"
    assert clock.generate_due(at("2026-11-08")) == 0
    assert clock.generate_due(at("2026-11-09", 10)) == 1
    assert dues(world) == ["2026-11-02", "2026-11-09"]


def test_running_the_clock_twice_makes_no_duplicates(world: World) -> None:
    world.repeat(world.task(due_date="2026-11-02"), "FREQ=DAILY")
    assert clock.generate_due(at("2026-11-03", 10)) == 1
    assert clock.generate_due(at("2026-11-03", 10)) == 0
    assert Occurrence.objects.count() == 2
    assert Occurrence.objects.filter(index=1).count() == 1


def test_after_downtime_only_the_most_recent_missed_instance_is_made(world: World) -> None:
    world.repeat(world.task(due_date="2026-11-02"), "FREQ=DAILY")
    assert clock.generate_due(at("2026-11-10", 10)) == 1
    assert dues(world) == ["2026-11-02", "2026-11-10"]
    series = RecurrenceSeries.objects.get()
    assert series.next_due_on.isoformat() == "2026-11-11"
    assert series.last_index == 8  # the skipped days still count


def test_the_catch_up_cap_is_configurable(world: World, settings: object) -> None:
    settings.RECURRENCE_MAX_CATCHUP = 3  # type: ignore[attr-defined]
    world.repeat(world.task(due_date="2026-11-02"), "FREQ=DAILY")
    assert clock.generate_due(at("2026-11-10", 10)) == 3
    assert dues(world) == ["2026-11-02", "2026-11-08", "2026-11-09", "2026-11-10"]


def test_an_instance_copies_the_task_and_its_open_checklist(world: World) -> None:
    first = world.task(
        title="Close the books", due_date="2026-11-02", due_time="08:30", priority="high",
        assignee_ids=[str(world.member.pk)],
    )  # fmt: skip
    sub = world.task(title="Reconcile", parent_id=str(first.pk))
    world.finish(sub)
    world.repeat(first, "FREQ=WEEKLY")
    clock.generate_due(at("2026-11-09", 10))
    made = Task.objects.get(occurrence__index=1)
    assert (made.title, made.priority, made.due_time.strftime("%H:%M")) == (
        "Close the books", "high", "08:30",
    )  # fmt: skip
    assert [str(i) for i in made.assignee_ids()] == [str(world.member.pk)]
    child = Task.objects.get(parent=made)
    assert child.title == "Reconcile"
    assert child.status.category != "done"  # the checklist starts over


def test_deleting_the_template_task_does_not_stop_the_series(world: World) -> None:
    first = world.task(due_date="2026-11-02")
    world.repeat(first, "FREQ=WEEKLY")
    Task.objects.filter(pk=first.pk).delete()
    assert RecurrenceSeries.objects.get().template_task is None
    assert clock.generate_due(at("2026-11-09", 10)) == 1


def test_an_ended_series_stops_at_until_and_at_count(world: World) -> None:
    world.repeat(world.task(due_date="2026-11-02"), "FREQ=DAILY;COUNT=3")
    for day in ("2026-11-03", "2026-11-04", "2026-11-05", "2026-11-06"):
        clock.generate_due(at(day, 10))
    assert Occurrence.objects.count() == 3
    assert RecurrenceSeries.objects.get().next_run_at is None


def test_the_series_end_date_is_respected(world: World) -> None:
    world.repeat(world.task(due_date="2026-11-02"), "FREQ=DAILY", ends_on="2026-11-04")
    assert RecurrenceSeries.objects.get().next_due_on.isoformat() == "2026-11-03"
    assert clock.generate_due(at("2026-11-03", 10)) == 1
    assert clock.generate_due(at("2026-11-04", 10)) == 1
    assert clock.generate_due(at("2026-11-05", 10)) == 0
    assert dues(world) == ["2026-11-02", "2026-11-03", "2026-11-04"]


def test_lead_days_make_the_instance_ahead_of_its_due_date(world: World) -> None:
    world.repeat(world.task(due_date="2026-11-02"), "FREQ=WEEKLY", lead_days=2)
    assert clock.generate_due(at("2026-11-06")) == 0
    assert clock.generate_due(at("2026-11-07", 10)) == 1
    assert Task.objects.get(occurrence__index=1).due_date.isoformat() == "2026-11-09"


def test_the_wall_clock_survives_a_daylight_saving_change(world: World) -> None:
    first = world.task(due_date="2026-03-01")  # the US springs forward on 8 March
    world.repeat(first, "FREQ=WEEKLY", timezone_name="America/New_York", at_time="09:00")
    series = RecurrenceSeries.objects.get()
    before = schedule.run_at(series, series.starts_on)
    after = schedule.run_at(series, series.next_due_on.replace(day=15))
    assert (before.hour, after.hour) == (14, 13)  # 09:00 local both times


def test_a_series_that_cannot_make_its_instance_is_paused_with_the_reason(world: World) -> None:
    world.repeat(world.task(due_date="2026-11-02"), "FREQ=WEEKLY")
    world.web.archived_at = at("2026-11-05")
    world.web.save()
    assert clock.generate_due(at("2026-11-09", 10)) == 0
    series = RecurrenceSeries.objects.get()
    assert series.paused and series.pause_reason
    assert Occurrence.objects.count() == 1


def test_a_lost_assignee_is_dropped_not_fatal(world: World) -> None:
    first = world.task(due_date="2026-11-02", assignee_ids=[str(world.member.pk)])
    world.repeat(first, "FREQ=WEEKLY")
    WorkspaceMember.objects.filter(user=world.member).update(status=MemberStatus.REMOVED)
    assert clock.generate_due(at("2026-11-09", 10)) == 1
    assert list(Task.objects.get(occurrence__index=1).assignee_ids()) == []
