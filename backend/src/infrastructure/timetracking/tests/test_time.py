"""Time tracking rules on the services."""

from datetime import UTC, datetime, timedelta
from typing import Any

import pytest
from django.db import IntegrityError, transaction
from django.utils import timezone

from infrastructure.common.errors import ApiError
from infrastructure.tasks import services as tasks
from infrastructure.timetracking import reminders, reports, services
from infrastructure.timetracking.models import TimeEntry
from infrastructure.timetracking.tests.conftest import with_time

HOUR = 3600


def ago(**kw: Any) -> datetime:
    return timezone.now() - timedelta(**kw)


def log(team: Any, web: Any, task: Any, who: Any, start: datetime, seconds: int, **kw: Any) -> Any:
    return services.create_entry(who, team.ws, str(web.pk), str(task.pk), start, seconds, **kw)


def test_start_runs_a_server_side_timer_and_stop_measures_it(
    team: Any, web: Any, task: Any
) -> None:
    started = services.start(team.member, team.ws, str(web.pk), str(task.pk))
    TimeEntry.objects.filter(pk=started.entry.pk).update(started_at=ago(minutes=90))

    current = services.current(team.member, team.ws)
    stopped = services.stop(team.member, team.ws)

    assert current is not None and current.pk == started.entry.pk
    assert 89 * 60 <= stopped.duration_sec <= 91 * 60 and stopped.ended_at is not None
    assert services.current(team.member, team.ws) is None


def test_starting_another_timer_stops_the_first_and_says_so(team: Any, web: Any, task: Any) -> None:
    other = tasks.create(team.owner, team.ws, str(web.pk), "Second")
    first = services.start(team.member, team.ws, str(web.pk), str(task.pk))

    second = services.start(team.member, team.ws, str(web.pk), str(other.pk))

    assert second.stopped is not None and second.stopped.pk == first.entry.pk
    assert second.stopped.ended_at is not None
    assert TimeEntry.objects.filter(user=team.member, ended_at__isnull=True).count() == 1


def test_the_database_allows_one_open_entry_per_person(team: Any, web: Any, task: Any) -> None:
    services.start(team.member, team.ws, str(web.pk), str(task.pk))

    with pytest.raises(IntegrityError), transaction.atomic():
        TimeEntry.objects.create(
            workspace=team.ws, task=task, user=team.member, started_at=timezone.now()
        )
    TimeEntry.objects.create(  # somebody else may run one
        workspace=team.ws, task=task, user=team.owner, started_at=timezone.now()
    )


def test_stop_with_no_timer_is_refused(team: Any, web: Any) -> None:
    with pytest.raises(ApiError):
        services.stop(team.member, team.ws)


def test_manual_entries_are_validated(team: Any, web: Any, task: Any) -> None:
    entry = log(
        team, web, task, team.member, ago(hours=3), 2 * HOUR, note=" review ", billable=True
    )
    assert (entry.duration_sec, entry.note, entry.billable, entry.source) == (
        2 * HOUR,
        "review",
        True,
        "manual",
    )
    assert entry.ended_at == entry.started_at + timedelta(hours=2)
    for start, seconds in (
        (ago(hours=3), 0),
        (ago(hours=3), 8 * 24 * HOUR),
        (timezone.now() + timedelta(hours=2), HOUR),
    ):
        with pytest.raises(ApiError):
            log(team, web, task, team.member, start, seconds)
    with pytest.raises(ApiError):
        log(team, web, task, team.member, ago(hours=3), HOUR, note="x" * 501)


def test_editing_and_deleting_own_entries_but_not_others(team: Any, web: Any, task: Any) -> None:
    mine = log(team, web, task, team.member, ago(hours=5), HOUR)
    theirs = log(team, web, task, team.owner, ago(hours=5), HOUR)

    changed = services.update_entry(
        team.member, team.ws, str(mine.pk), {"duration_sec": 2 * HOUR, "note": "more"}
    )
    assert (changed.duration_sec, changed.note) == (2 * HOUR, "more")
    assert changed.ended_at == changed.started_at + timedelta(hours=2)
    with pytest.raises(ApiError) as denied:
        services.update_entry(team.member, team.ws, str(theirs.pk), {"note": "x"})
    assert denied.value.status == 403
    with pytest.raises(ApiError):
        services.delete_entry(team.member, team.ws, str(theirs.pk))

    services.update_entry(team.admin, team.ws, str(mine.pk), {"billable": True})  # edit_others
    services.delete_entry(team.admin, team.ws, str(theirs.pk))
    services.delete_entry(team.member, team.ws, str(mine.pk))
    assert not TimeEntry.objects.exists()


def test_a_running_entry_only_takes_a_note(team: Any, web: Any, task: Any) -> None:
    running = services.start(team.member, team.ws, str(web.pk), str(task.pk)).entry

    services.update_entry(team.member, team.ws, str(running.pk), {"note": "on it"})
    with pytest.raises(ApiError):
        services.update_entry(team.member, team.ws, str(running.pk), {"duration_sec": 60})
    with pytest.raises(ApiError):
        services.update_entry(team.member, team.ws, str(running.pk), {"task": "x"})


def test_a_viewer_cannot_log_time(team: Any, web: Any, task: Any) -> None:
    with pytest.raises(ApiError) as denied:
        services.start(team.viewer, team.ws, str(web.pk), str(task.pk))
    assert denied.value.status == 403
    with pytest.raises(ApiError):
        log(team, web, task, team.viewer, ago(hours=2), HOUR)


def test_the_project_switch_gates_everything_and_keeps_the_data(team: Any) -> None:
    plain = team.create(team.owner, "OFF")
    off = tasks.create(team.owner, team.ws, str(plain.pk), "Quiet")

    with pytest.raises(ApiError):
        services.start(team.member, team.ws, str(plain.pk), str(off.pk))

    on = with_time(team, team.create(team.owner, "ON"))
    task = tasks.create(team.owner, team.ws, str(on.pk), "Loud")
    entry = log(team, on, task, team.member, ago(hours=4), HOUR)
    from infrastructure.projects import services as projects

    current = projects.get(team.owner, team.ws, str(on.pk)).project
    projects.set_features(team.owner, team.ws, str(on.pk), set(), current.version)

    with pytest.raises(ApiError):
        services.entries_for_task(team.member, team.ws, str(on.pk), str(task.pk))
    assert TimeEntry.objects.filter(pk=entry.pk).exists()  # kept
    assert reports.timesheet(team.member, team.ws, "2020-01-06").rows == []


def test_a_private_project_hides_time_from_non_members(team: Any) -> None:
    private = with_time(team, team.create(team.owner, "SEC", visibility="private"))
    task = tasks.create(team.owner, team.ws, str(private.pk), "Secret")
    with pytest.raises(ApiError):
        services.start(team.member, team.ws, str(private.pk), str(task.pk))
    with pytest.raises(ApiError):
        services.summary(team.member, team.ws, str(private.pk), str(task.pk))


def test_summary_adds_closed_and_running_time_and_the_estimate(
    team: Any, web: Any, task: Any
) -> None:
    log(team, web, task, team.member, ago(hours=9), HOUR, billable=True)
    log(team, web, task, team.owner, ago(hours=7), 2 * HOUR)
    run = services.start(team.admin, team.ws, str(web.pk), str(task.pk)).entry
    TimeEntry.objects.filter(pk=run.pk).update(started_at=ago(minutes=30))
    services.set_estimate(team.owner, team.ws, str(web.pk), str(task.pk), 8 * HOUR)

    got = services.summary(team.member, team.ws, str(web.pk), str(task.pk))

    assert got.estimate_sec == 8 * HOUR and got.running
    assert 3 * HOUR + 29 * 60 <= got.logged_sec <= 3 * HOUR + 31 * 60
    assert got.billable_sec == HOUR
    services.set_estimate(team.owner, team.ws, str(web.pk), str(task.pk), 0)
    assert services.summary(team.member, team.ws, str(web.pk), str(task.pk)).estimate_sec == 0
    with pytest.raises(ApiError):  # a viewer may not
        services.set_estimate(team.viewer, team.ws, str(web.pk), str(task.pk), HOUR)


def test_overlaps_and_long_entries_are_flagged(team: Any, web: Any, task: Any) -> None:
    a = log(team, web, task, team.member, ago(hours=10), 2 * HOUR)
    b = log(team, web, task, team.member, ago(hours=9), 2 * HOUR)
    long = log(team, web, task, team.owner, ago(days=3), 30 * HOUR)

    rows = {
        r.entry.pk: r.flags
        for r in services.entries_for_task(team.owner, team.ws, str(web.pk), str(task.pk))
    }

    assert rows[a.pk] == rows[b.pk] == ("overlap",)
    assert rows[long.pk] == ("long",)


def test_the_timesheet_totals_equal_the_entries(team: Any, web: Any, task: Any) -> None:
    other = tasks.create(team.owner, team.ws, str(web.pk), "Other")
    monday = datetime(2026, 11, 2, 9, tzinfo=UTC)
    log(team, web, task, team.member, monday, HOUR)
    log(team, web, task, team.member, monday + timedelta(days=2), 90 * 60, billable=True)
    log(team, web, other, team.member, monday + timedelta(days=2, hours=3), 30 * 60)
    log(team, web, task, team.owner, monday, 5 * HOUR)  # not theirs

    sheet = reports.timesheet(team.member, team.ws, "2026-11-02", "UTC")

    assert [r.key for r in sheet.rows] == ["WEB-1", "WEB-2"]
    assert sheet.rows[0].seconds == [HOUR, 0, 90 * 60, 0, 0, 0, 0]
    assert sheet.rows[0].billable == 90 * 60
    assert sheet.day_totals == [HOUR, 0, 2 * HOUR, 0, 0, 0, 0]
    assert sheet.total == sum(r.total for r in sheet.rows) == 3 * HOUR


def test_week_boundaries_follow_the_time_zone_and_split_entries(
    team: Any, web: Any, task: Any
) -> None:
    # 23:00-01:00 Tehran time (UTC+3:30 in Nov 2026... use a fixed-offset zone: Asia/Dubai, +4).
    start = datetime(2026, 11, 2, 19, 0, tzinfo=UTC)  # 23:00 Monday in Dubai
    log(team, web, task, team.member, start, 2 * HOUR)

    dubai = reports.timesheet(team.member, team.ws, "2026-11-02", "Asia/Dubai")
    utc = reports.timesheet(team.member, team.ws, "2026-11-02", "UTC")

    assert dubai.rows[0].seconds[:2] == [HOUR, HOUR]  # split at local midnight
    assert utc.rows[0].seconds[0] == 2 * HOUR
    previous = reports.timesheet(team.member, team.ws, "2026-10-26", "Asia/Dubai")
    assert previous.rows == []
    with pytest.raises(ApiError):
        reports.timesheet(team.member, team.ws, "2026-11-02", "Mars/Base")
    with pytest.raises(ApiError):
        reports.timesheet(team.member, team.ws, "not-a-date")


def test_a_dst_week_still_has_seven_whole_days(team: Any, web: Any, task: Any) -> None:
    # Europe/Paris falls back on Sunday 2026-10-25: that local day has 25 hours.
    bounds = [
        b.astimezone(UTC)
        for b in reports.day_bounds(datetime(2026, 10, 19).date(), reports.ZoneInfo("Europe/Paris"))
    ]
    lengths = [(bounds[i + 1] - bounds[i]).total_seconds() / HOUR for i in range(7)]
    assert lengths == [24, 24, 24, 24, 24, 24, 25]
    assert reports.timesheet(team.member, team.ws, "2026-10-19", "Europe/Paris").rows == []


def test_other_peoples_timesheets_need_edit_others(team: Any, web: Any, task: Any) -> None:
    log(team, web, task, team.member, datetime(2026, 11, 2, 9, tzinfo=UTC), HOUR)

    assert (
        reports.timesheet(team.admin, team.ws, "2026-11-02", "UTC", str(team.member.pk)).total
        == HOUR
    )
    with pytest.raises(ApiError):
        reports.timesheet(team.member, team.ws, "2026-11-02", "UTC", str(team.owner.pk))


def test_project_totals_per_person(team: Any, web: Any, task: Any) -> None:
    start = datetime(2026, 11, 2, 9, tzinfo=UTC)
    log(team, web, task, team.member, start, HOUR, billable=True)
    log(team, web, task, team.owner, start, 2 * HOUR)
    window = (start - timedelta(days=1), start + timedelta(days=1))

    everyone = reports.totals(team.admin, team.ws, str(web.pk), *window)
    own = reports.totals(team.member, team.ws, str(web.pk), *window)

    assert [(p.seconds, p.billable) for p in everyone] == [(2 * HOUR, 0), (HOUR, HOUR)]
    assert [p.user_id for p in own] == [str(team.member.pk)]
    with pytest.raises(ApiError):
        reports.totals(team.admin, team.ws, str(web.pk), window[1], window[0])


def test_a_long_running_timer_reminds_its_owner_once(team: Any, web: Any, task: Any) -> None:
    run = services.start(team.member, team.ws, str(web.pk), str(task.pk)).entry
    assert reminders.remind_long_timers() == 0
    TimeEntry.objects.filter(pk=run.pk).update(started_at=ago(hours=9))

    assert reminders.remind_long_timers() == 1
    assert reminders.remind_long_timers() == 0  # told once


def test_a_deleted_task_takes_its_entries_out_of_view(team: Any, web: Any, task: Any) -> None:
    log(team, web, task, team.member, ago(hours=3), HOUR)
    tasks.delete(team.owner, team.ws, str(web.pk), str(task.pk))

    with pytest.raises(ApiError):
        services.entries_for_task(team.member, team.ws, str(web.pk), str(task.pk))
    assert services.current(team.member, team.ws) is None


def test_a_timer_change_tells_only_the_owners_devices(
    team: Any, web: Any, task: Any, monkeypatch: pytest.MonkeyPatch
) -> None:
    sent: list[tuple[str, dict[str, Any]]] = []

    class Recorder:
        def publish(self, channel: str, payload: dict[str, Any]) -> None:
            sent.append((channel, payload))

    monkeypatch.setattr("infrastructure.sync.publish.get_broker", lambda: Recorder())

    services.start(team.member, team.ws, str(web.pk), str(task.pk))
    services.stop(team.member, team.ws)

    assert [p["event"]["type"] for _, p in sent] == ["timer.changed", "timer.changed"]
    assert {p["room"] for _, p in sent} == {f"user:{team.member.pk}"}
    assert all(p["event"]["entity_id"] == str(team.member.pk) for _, p in sent)


def test_a_second_workspace_cannot_reach_a_first_ones_time(team: Any, web: Any, task: Any) -> None:
    from infrastructure.workspaces import services as workspace_services

    entry = log(team, web, task, team.member, ago(hours=3), HOUR)
    other = workspace_services.create(team.outsider, "Elsewhere", "elsewhere")

    for call in (
        lambda: services.update_entry(team.outsider, other, str(entry.pk), {"note": "x"}),
        lambda: services.delete_entry(team.outsider, other, str(entry.pk)),
        lambda: services.start(team.outsider, other, str(web.pk), str(task.pk)),
        lambda: services.summary(team.outsider, team.ws, str(web.pk), str(task.pk)),
    ):
        with pytest.raises(ApiError):
            call()
    assert reports.timesheet(team.outsider, other, "2020-01-06").rows == []
    assert TimeEntry.objects.filter(pk=entry.pk).exists()


def test_a_timer_in_another_workspace_is_stopped_and_both_are_told(
    team: Any, web: Any, task: Any, monkeypatch: pytest.MonkeyPatch
) -> None:
    from infrastructure.timetracking import signals
    from infrastructure.workspaces import services as workspace_services
    from infrastructure.workspaces.tests.conftest import _commit_hooks_run_now  # noqa: F401

    told: list[Any] = []
    monkeypatch.setattr(services, "announce", lambda user, ws: told.append(ws.pk))
    monkeypatch.setattr(signals, "announce", lambda user, ws: None)
    services.start(team.member, team.ws, str(web.pk), str(task.pk))
    second = workspace_services.create(team.member, "Mine", "mine")
    from infrastructure.projects import services as projects
    from infrastructure.timetracking.tests.conftest import with_time

    project = with_time(
        type("T", (), {"owner": team.member, "ws": second})(),
        projects.create(team.member, second, "Mine", "MIN").project,
    )
    there = tasks.create(team.member, second, str(project.pk), "Over there")

    started = services.start(team.member, second, str(project.pk), str(there.pk))

    assert started.stopped is not None and started.stopped.workspace_id == team.ws.pk
    assert set(told) == {second.pk, team.ws.pk}
    assert TimeEntry.objects.filter(user=team.member, ended_at__isnull=True).count() == 1


def test_deleting_a_task_stops_its_running_timers(team: Any, web: Any, task: Any) -> None:
    services.start(team.member, team.ws, str(web.pk), str(task.pk))

    tasks.delete(team.owner, team.ws, str(web.pk), str(task.pk))

    assert not TimeEntry.objects.filter(ended_at__isnull=True).exists()


def test_an_archived_project_takes_no_new_time_but_keeps_the_old(
    team: Any, web: Any, task: Any
) -> None:
    from infrastructure.projects import services as projects

    log(team, web, task, team.member, ago(hours=3), HOUR)
    current = projects.get(team.owner, team.ws, str(web.pk)).project
    projects.archive(team.owner, team.ws, str(web.pk), current.version)

    with pytest.raises(ApiError):
        services.start(team.member, team.ws, str(web.pk), str(task.pk))
    with pytest.raises(ApiError):
        log(team, web, task, team.member, ago(hours=2), HOUR)


def test_editing_only_the_start_keeps_the_duration_even_if_it_is_odd(
    team: Any, web: Any, task: Any
) -> None:
    entry = log(team, web, task, team.member, ago(hours=5), HOUR)
    TimeEntry.objects.filter(pk=entry.pk).update(duration_sec=0, ended_at=entry.started_at)

    moved = services.update_entry(
        team.member, team.ws, str(entry.pk), {"started_at": entry.started_at - timedelta(hours=1)}
    )

    assert moved.duration_sec == 0


def test_estimates_can_be_guarded_by_a_version(team: Any, web: Any, task: Any) -> None:
    services.set_estimate(team.owner, team.ws, str(web.pk), str(task.pk), HOUR)

    with pytest.raises(ApiError) as stale:
        services.set_estimate(
            team.owner, team.ws, str(web.pk), str(task.pk), 2 * HOUR, expected_version=task.version
        )
    assert stale.value.status == 409
    fresh = tasks.get(team.owner, team.ws, str(web.pk), str(task.pk))
    services.set_estimate(
        team.owner, team.ws, str(web.pk), str(task.pk), 2 * HOUR, expected_version=fresh.version
    )
    assert services.summary(team.owner, team.ws, str(web.pk), str(task.pk)).estimate_sec == 2 * HOUR


def test_overlap_ignores_time_in_other_workspaces(team: Any, web: Any, task: Any) -> None:
    from infrastructure.workspaces import services as workspace_services

    mine = log(team, web, task, team.member, ago(hours=10), 2 * HOUR)
    other = workspace_services.create(team.member, "Mine", "mine")
    from infrastructure.projects import services as projects
    from infrastructure.timetracking.tests.conftest import with_time

    project = with_time(
        type("T", (), {"owner": team.member, "ws": other})(),
        projects.create(team.member, other, "Mine", "MIN").project,
    )
    there = tasks.create(team.member, other, str(project.pk), "Elsewhere")
    services.create_entry(team.member, other, str(project.pk), str(there.pk), ago(hours=9), HOUR)

    rows = services.entries_for_task(team.owner, team.ws, str(web.pk), str(task.pk))

    assert [r.flags for r in rows if r.entry.pk == mine.pk] == [()]


def test_a_bad_person_id_is_a_400_not_a_crash(team: Any, web: Any, task: Any) -> None:
    with pytest.raises(ApiError):
        reports.timesheet(team.admin, team.ws, "2026-11-02", "UTC", "not-a-uuid")


def test_a_device_that_cannot_name_its_zone_sends_an_offset(team: Any, web: Any, task: Any) -> None:
    log(team, web, task, team.member, datetime(2026, 11, 2, 19, tzinfo=UTC), 2 * HOUR)

    sheet = reports.timesheet(team.member, team.ws, "2026-11-02", "", "", 240)  # UTC+4

    assert sheet.rows[0].seconds[:2] == [HOUR, HOUR]
    with pytest.raises(ApiError):
        reports.timesheet(team.member, team.ws, "2026-11-02", "", "", 99999)


def test_a_lost_start_race_is_retried(
    team: Any, web: Any, task: Any, monkeypatch: pytest.MonkeyPatch
) -> None:
    real = TimeEntry.objects.create
    calls = {"n": 0}

    def flaky(**kw: Any) -> Any:
        calls["n"] += 1
        if calls["n"] == 1:
            raise IntegrityError("lost the race")
        return real(**kw)

    monkeypatch.setattr(TimeEntry.objects, "create", flaky)

    started = services.start(team.member, team.ws, str(web.pk), str(task.pk))

    assert calls["n"] == 2 and started.entry.is_running

    def always(**kw: Any) -> Any:
        raise IntegrityError("always")

    monkeypatch.setattr(TimeEntry.objects, "create", always)
    with pytest.raises(ApiError) as gave_up:
        services.start(team.member, team.ws, str(web.pk), str(task.pk))
    assert gave_up.value.status == 409


def test_sample_task_time_is_not_in_the_reports(team: Any, web: Any, task: Any) -> None:
    from infrastructure.tasks.models import Task

    sample = tasks.create(team.owner, team.ws, str(web.pk), "Sample")
    Task.objects.filter(pk=sample.pk).update(is_sample=True)
    started = datetime(2026, 11, 3, 9, tzinfo=UTC)
    log(team, web, task, team.member, started, HOUR)
    log(team, web, sample, team.member, started, 2 * HOUR)

    sheet = reports.timesheet(team.member, team.ws, "2026-11-02", "UTC")
    mine = reports.totals(
        team.member, team.ws, str(web.pk), started - timedelta(days=1), started + timedelta(days=1)
    )

    assert [r.title for r in sheet.rows] == [task.title] and sheet.total == HOUR
    assert [p.seconds for p in mine] == [HOUR]
