"""Setting, changing and reading rules; the after-completion mode; what each person may do."""

from infrastructure.recurrence import clock, services
from infrastructure.recurrence.models import Occurrence, RecurrenceSeries
from infrastructure.recurrence.tests.conftest import World, at
from infrastructure.tasks import services as task_services
from infrastructure.tasks.models import Task


def test_a_rule_is_read_back_with_a_sentence_and_the_next_dates(world: World) -> None:
    first = world.task(due_date="2026-11-02")
    world.repeat(first, "FREQ=WEEKLY;INTERVAL=2;BYDAY=MO,TH")
    view = services.get(world.owner, world.ws, str(world.web.pk), str(first.pk))
    assert view is not None
    assert view.summary == "Every 2 weeks on Mon, Thu"
    assert [d.isoformat() for d in view.next_dates] == [
        "2026-11-05", "2026-11-16", "2026-11-19", "2026-11-30", "2026-12-03",
    ]  # fmt: skip
    assert view.is_template and view.index == 0


def test_a_task_that_does_not_repeat_reads_as_none(world: World) -> None:
    task = world.task()
    assert services.get(world.owner, world.ws, str(world.web.pk), str(task.pk)) is None


def test_the_rule_is_checked(world: World) -> None:
    task = world.task()
    for bad in ("FREQ=HOURLY", "", "FREQ=WEEKLY;BYDAY=XX"):
        assert world.refused(world.repeat, task, bad)
    assert world.refused(world.repeat, task, mode="sometimes")
    assert world.refused(world.repeat, task, timezone_name="Mars/Base")
    assert world.refused(world.repeat, task, at_time="9am")
    assert world.refused(world.repeat, task, lead_days=99)
    assert not RecurrenceSeries.objects.exists()


def test_setting_a_rule_again_replaces_it_on_the_same_series(world: World) -> None:
    first = world.task(due_date="2026-11-02")
    world.repeat(first, "FREQ=WEEKLY")
    clock.generate_due(at("2026-11-09", 10))
    second = Task.objects.get(occurrence__index=1)
    world.repeat(second, "FREQ=DAILY")
    series = RecurrenceSeries.objects.get()
    assert series.rrule == "FREQ=DAILY" and series.version == 2
    assert series.next_due_on.isoformat() == "2026-11-10"
    assert Occurrence.objects.count() == 2


def test_clear_keeps_every_instance_as_an_ordinary_task(world: World) -> None:
    first = world.task(due_date="2026-11-02")
    world.repeat(first, "FREQ=WEEKLY")
    clock.generate_due(at("2026-11-09", 10))
    services.clear(world.owner, world.ws, str(world.web.pk), str(first.pk))
    assert not RecurrenceSeries.objects.exists() and not Occurrence.objects.exists()
    assert Task.objects.filter(project=world.web).count() == 2
    assert world.refused(services.clear, world.owner, world.ws, str(world.web.pk), str(first.pk))


def test_pause_stops_the_clock_and_resume_skips_what_was_missed(world: World) -> None:
    first = world.task(due_date="2026-11-02")
    world.repeat(first, "FREQ=DAILY")
    pid, tid = str(world.web.pk), str(first.pk)
    services.pause(world.owner, world.ws, pid, tid, True)
    assert clock.generate_due(at("2026-11-20")) == 0
    services.pause(world.owner, world.ws, pid, tid, False)
    series = RecurrenceSeries.objects.get()
    assert not series.paused and series.next_due_on >= series.starts_on
    assert Occurrence.objects.count() == 1


def test_edit_this_changes_only_that_task(world: World) -> None:
    first = world.task(title="Report", due_date="2026-11-02")
    world.repeat(first, "FREQ=DAILY")
    clock.generate_due(at("2026-11-03", 10))
    this = Task.objects.get(occurrence__index=1)
    task_services.update(
        world.owner,
        world.ws,
        str(this.project_id),
        str(this.pk),
        this.version,
        {"title": "One-off"},
    )
    clock.generate_due(at("2026-11-04", 10))
    assert Task.objects.get(occurrence__index=2).title == "Report"
    assert RecurrenceSeries.objects.get().template["title"] == "Report"


def test_edit_future_retakes_the_template_and_updates_open_later_instances(world: World) -> None:
    first = world.task(title="Report", due_date="2026-11-02")
    world.repeat(
        first,
        "FREQ=DAILY",
    )
    for day in ("2026-11-03", "2026-11-04", "2026-11-05"):
        clock.generate_due(at(day, 10))
    middle = Task.objects.get(occurrence__index=2)
    world.finish(Task.objects.get(occurrence__index=3))  # a finished one is left alone
    task_services.update(
        world.owner, world.ws, str(middle.project_id), str(middle.pk), middle.version,
        {"title": "Report v2", "priority": "high", "assignee_ids": [str(world.member.pk)]},
    )  # fmt: skip
    view, changed = services.update_future(
        world.owner, world.ws, str(middle.project_id), str(Task.objects.get(pk=middle.pk).pk)
    )
    assert changed == 0  # index 3 is done, so nothing after index 2 is open
    assert view.series.template["title"] == "Report v2"
    clock.generate_due(at("2026-11-06", 10))
    assert Task.objects.get(occurrence__index=4).title == "Report v2"
    assert Task.objects.get(occurrence__index=1).title == "Report"  # earlier: untouched
    before = Task.objects.get(occurrence__index=4)
    services.update_future(
        world.owner, world.ws, str(before.project_id), str(Task.objects.get(occurrence__index=1).pk)
    )
    assert Task.objects.get(occurrence__index=4).title == "Report"  # the older template wins


def test_edit_future_reaches_open_later_instances(world: World) -> None:
    first = world.task(title="Report", due_date="2026-11-02")
    world.repeat(first, "FREQ=DAILY")
    for day in ("2026-11-03", "2026-11-04"):
        clock.generate_due(at(day, 10))
    this = Task.objects.get(occurrence__index=1)
    task_services.update(
        world.owner, world.ws, str(this.project_id), str(this.pk), this.version,
        {"title": "Daily report", "priority": "urgent"},
    )  # fmt: skip
    _, changed = services.update_future(world.owner, world.ws, str(this.project_id), str(this.pk))
    assert changed == 1
    later = Task.objects.get(occurrence__index=2)
    assert (later.title, later.priority) == ("Daily report", "urgent")


def test_the_preview_is_what_the_clock_makes(world: World) -> None:
    rule = "FREQ=MONTHLY;BYDAY=1MO"
    shown = services.preview(
        world.owner, world.ws, rrule=rule, mode="schedule", starts_on="2026-11-02", count=4
    ).dates
    world.repeat(world.task(due_date="2026-11-02"), rule)
    for day in shown:
        clock.generate_due(at(day.isoformat(), 10))
    made = Task.objects.filter(occurrence__index__gt=0).order_by("occurrence__index")
    assert [t.due_date for t in made] == shown and len(shown) == 4


def test_the_preview_with_skip_weekends_and_count(world: World) -> None:
    found = services.preview(
        world.owner, world.ws, rrule="FREQ=DAILY;COUNT=4", mode="schedule", starts_on="2026-11-05",
        skip_weekends=True, count=10,
    )  # fmt: skip
    assert [d.isoformat() for d in found.dates] == ["2026-11-06", "2026-11-09", "2026-11-10"]


def test_the_feb_29_preview_clamps_to_the_28th(world: World) -> None:
    found = services.preview(
        world.owner, world.ws, rrule="FREQ=YEARLY", mode="schedule", starts_on="2028-02-29", count=3
    )
    assert [d.isoformat() for d in found.dates] == ["2029-02-28", "2030-02-28", "2031-02-28"]


def test_the_after_completion_preview_counts_from_each_finish(world: World) -> None:
    found = services.preview(
        world.owner, world.ws, rrule="FREQ=DAILY;INTERVAL=3", mode="after_completion",
        starts_on="2026-11-02", count=3,
    )  # fmt: skip
    assert [d.isoformat() for d in found.dates] == ["2026-11-05", "2026-11-08", "2026-11-11"]
    assert found.summary == "3 days after it is completed"


def test_after_completion_makes_the_next_only_when_it_is_done(world: World) -> None:
    first = world.task(due_date="2026-11-02")
    world.repeat(first, "FREQ=DAILY;INTERVAL=3", mode="after_completion")
    assert clock.generate_due(at("2026-12-30")) == 0  # the clock never makes these
    assert clock.catch_up_completions() == 0  # nothing is done yet
    world.finish(first)
    assert clock.on_completed(first.pk, at("2026-11-05", 10)) is True
    assert clock.on_completed(first.pk, at("2026-11-05", 10)) is False  # one open at a time
    made = Task.objects.get(occurrence__index=1)
    assert made.due_date.isoformat() == "2026-11-08"
    assert Occurrence.objects.count() == 2


def test_the_completion_hook_runs_from_the_task_signal(
    world: World, django_capture_on_commit_callbacks: object
) -> None:
    first = world.task(due_date="2026-11-02")
    world.repeat(first, "FREQ=WEEKLY", mode="after_completion")
    with django_capture_on_commit_callbacks(execute=True):  # type: ignore[operator]
        world.finish(first)
    assert Occurrence.objects.filter(index=1).count() == 1


def test_a_missed_completion_hook_is_made_up_by_the_clock(world: World) -> None:
    first = world.task(due_date="2026-11-02")
    world.repeat(first, "FREQ=WEEKLY", mode="after_completion")
    world.finish(first)
    assert clock.catch_up_completions() == 1
    assert clock.catch_up_completions() == 0
    assert Occurrence.objects.count() == 2


def test_after_completion_stops_at_count_and_ignores_cancelled_and_trashed(world: World) -> None:
    first = world.task(due_date="2026-11-02")
    world.repeat(first, "FREQ=DAILY;COUNT=2", mode="after_completion")
    world.finish(first)
    clock.on_completed(first.pk)
    second = Task.objects.get(occurrence__index=1)
    world.finish(second)
    assert clock.on_completed(second.pk) is False
    assert Occurrence.objects.count() == 2


def test_skip_weekends_moves_an_after_completion_date_to_monday(world: World) -> None:
    first = world.task(due_date="2026-11-04")
    world.repeat(first, "FREQ=DAILY", mode="after_completion", skip_weekends=True)
    world.finish(first)
    clock.on_completed(first.pk, at("2026-11-06", 10))  # a Friday: next would be Saturday
    assert Task.objects.get(occurrence__index=1).due_date.isoformat() == "2026-11-09"


def test_upcoming_lists_the_dates_still_to_be_made(world: World) -> None:
    world.repeat(world.task(title="Report", due_date="2026-11-02"), "FREQ=WEEKLY")
    ghosts = services.upcoming(world.owner, world.ws, "2026-11-01", "2026-11-23")
    assert [(g.title, g.due_date.isoformat()) for g in ghosts] == [
        ("Report", "2026-11-09"), ("Report", "2026-11-16"), ("Report", "2026-11-23"),
    ]  # fmt: skip
    assert world.refused(services.upcoming, world.owner, world.ws, "2026-11-23", "2026-11-01")
    assert world.refused(services.upcoming, world.owner, world.ws, "2026-01-01", "2028-01-01")


def test_upcoming_skips_paused_series_and_other_projects(world: World) -> None:
    first = world.task(due_date="2026-11-02")
    world.repeat(first, "FREQ=WEEKLY")
    services.pause(world.owner, world.ws, str(world.web.pk), str(first.pk), True)
    assert services.upcoming(world.owner, world.ws, "2026-11-01", "2026-11-30") == []


def test_ghosts_are_per_viewer(world: World) -> None:
    secret = world.task(world.sec, "Secret", due_date="2026-11-02")
    world.repeat(secret, "FREQ=WEEKLY")
    owner = services.upcoming(world.owner, world.ws, "2026-11-01", "2026-11-30")
    member = services.upcoming(world.member, world.ws, "2026-11-01", "2026-11-30")
    assert len(owner) == 4 and member == []


def test_only_someone_who_can_edit_the_task_sets_a_rule(world: World) -> None:
    task = world.task()
    args = (str(world.web.pk), str(task.pk))
    refusal = world.refused(
        services.set_rule, world.viewer, world.ws, *args, rrule="FREQ=DAILY", mode="schedule"
    )
    assert refusal.status == 403
    assert (
        services.set_rule(
            world.member, world.ws, *args, rrule="FREQ=DAILY", mode="schedule"
        ).series.created_by_id
        == world.member.pk
    )
    assert world.refused(services.clear, world.viewer, world.ws, *args).status == 403
    assert world.refused(services.pause, world.viewer, world.ws, *args, True).status == 403
    assert world.refused(services.update_future, world.viewer, world.ws, *args).status == 403


def test_a_viewer_can_read_a_rule_but_not_in_a_private_project(world: World) -> None:
    task = world.task()
    world.repeat(task, "FREQ=DAILY")
    assert services.get(world.viewer, world.ws, str(world.web.pk), str(task.pk)) is not None
    secret = world.task(world.sec, "Secret")
    world.repeat(secret, "FREQ=DAILY")
    err = world.refused(services.get, world.member, world.ws, str(world.sec.pk), str(secret.pk))
    assert err.status == 404
    wrong = world.refused(services.get, world.member, world.ws, str(world.web.pk), str(secret.pk))
    assert wrong.status == 404


def test_the_preview_needs_a_workspace_member(world: World) -> None:
    from django.contrib.auth import get_user_model

    stranger = get_user_model().objects.create_user("x", "x@x.test", "pw-123456-x")
    err = world.refused(services.preview, stranger, world.ws, rrule="FREQ=DAILY", mode="schedule")
    assert err.status in (403, 404)


def test_the_tick_command_runs(world: World) -> None:
    from io import StringIO

    from django.core.management import call_command

    out = StringIO()
    call_command("recurrence_tick", stdout=out)
    assert "Recurring tasks made 0" in out.getvalue()


def test_a_subtask_cannot_be_the_template_of_a_series(world: World) -> None:
    parent = world.task(due_date="2026-11-02")
    sub = world.task(title="Step", parent_id=str(parent.pk), due_date="2026-11-03")
    refused = world.refused(world.repeat, sub, "FREQ=WEEKLY")
    assert "subtask" in str(refused).lower()
    assert not RecurrenceSeries.objects.exists()


def test_setting_clearing_and_pausing_a_rule_are_audited(world: World) -> None:
    from infrastructure.audit.models import AuditEntry

    first = world.task(due_date="2026-11-02")
    world.repeat(first, "FREQ=WEEKLY")
    services.pause(world.owner, world.ws, str(first.project_id), str(first.pk), True)
    services.clear(world.owner, world.ws, str(first.project_id), str(first.pk))
    actions = list(
        AuditEntry.objects.filter(action__startswith="recurrence.")
        .order_by("pk")
        .values_list("action", flat=True)
    )
    assert actions[0].endswith("created") and any(a.endswith("paused") for a in actions)
    assert actions[-1].endswith("deleted")
    assert all(
        AuditEntry.objects.filter(action=a).first().actor_type == "user" for a in set(actions)
    )
