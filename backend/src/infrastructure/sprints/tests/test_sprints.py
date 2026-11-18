"""Sprint rules on the services."""

from datetime import date, timedelta
from decimal import Decimal
from typing import Any

import pytest
from django.core.management import call_command
from django.db import IntegrityError, transaction

from infrastructure.accounts.models import Profile
from infrastructure.common.errors import ApiError
from infrastructure.filters import compile as compiler
from infrastructure.filters import language
from infrastructure.filters.language import Catalogue
from infrastructure.sprints import burndown, services, snapshots
from infrastructure.sprints.models import ScopeEvent, Snapshot, Sprint, State
from infrastructure.sprints.tests.conftest import (
    at,
    make_task,
    new_sprint,
    set_status,
    with_sprints,
)
from infrastructure.tasks import services as tasks
from infrastructure.tasks.models import Task
from infrastructure.workspaces import access
from infrastructure.workspaces.models import Workspace

DONE = "done"


def ids(*rows: Any) -> list[str]:
    return [str(r.pk) for r in rows]


def refresh(sprint: Any) -> Any:
    return Sprint.objects.get(pk=sprint.pk)


def start(team: Any, web: Any, sprint: Any, now: Any = None) -> Any:
    return services.start(team.owner, team.ws, str(web.pk), str(sprint.pk), now or at(2, 9)).sprint


def add(team: Any, web: Any, sprint: Any, *rows: Any, now: Any = None) -> Any:
    return services.add_tasks(team.owner, team.ws, str(web.pk), str(sprint.pk), ids(*rows), now)


def complete(
    team: Any, web: Any, sprint: Any, carry: str = "backlog", nxt: str = "", now: Any = None
) -> Any:
    return services.complete(
        team.owner, team.ws, str(web.pk), str(sprint.pk), carry, nxt, now or at(6)
    )


# -- state machine -----------------------------------------------------------------------------


def test_plan_start_complete_state_machine(team: Any, web: Any) -> None:
    sprint = new_sprint(team, web)
    assert sprint.state == State.PLANNED and sprint.started_at is None

    started = start(team, web, sprint)
    done = complete(team, web, sprint).sprint

    assert started.state == State.ACTIVE and started.started_at is not None
    assert done.state == State.COMPLETED and done.completed_at is not None
    with pytest.raises(ApiError, match="planned"):
        start(team, web, sprint)
    with pytest.raises(ApiError, match="active"):
        complete(team, web, sprint)
    with pytest.raises(ApiError, match="completed"):
        services.update(team.owner, team.ws, str(web.pk), str(sprint.pk), {"name": "x"})
    with pytest.raises(ApiError, match="completed"):
        add(team, web, sprint, make_task(team, web, "t"))


def test_only_one_active_sprint_per_project_service_and_database(team: Any, web: Any) -> None:
    first = new_sprint(team, web, "A")
    second = new_sprint(team, web, "B", "2026-11-09", "2026-11-13")
    start(team, web, first)

    with pytest.raises(ApiError) as refused:
        start(team, web, second)
    with pytest.raises(IntegrityError), transaction.atomic():
        Sprint.objects.filter(pk=second.pk).update(state=State.ACTIVE)

    assert refused.value.status == 409 and "A" in str(refused.value)


def test_update_rules_and_version_conflict(team: Any, web: Any) -> None:
    sprint = new_sprint(team, web)
    pid, sid = str(web.pk), str(sprint.pk)

    out = services.update(team.owner, team.ws, pid, sid, {"name": " New ", "goal": "Ship"})
    assert (out.sprint.name, out.sprint.goal, out.sprint.version) == ("New", "Ship", 2)
    with pytest.raises(ApiError) as stale:
        services.update(team.owner, team.ws, pid, sid, {"name": "x"}, expected_version=1)
    assert stale.value.status == 409
    bad_changes: tuple[dict[str, str], ...] = (
        {"end_date": "2026-11-01"},
        {"name": ""},
        {"nope": "x"},
        {"start_date": "soon"},
        {},
    )
    for bad in bad_changes:
        with pytest.raises(ApiError):
            services.update(team.owner, team.ws, pid, sid, bad)

    start(team, web, sprint)
    extended = services.update(team.owner, team.ws, pid, sid, {"end_date": "2026-11-10"})
    assert extended.sprint.end_date.isoformat() == "2026-11-10"
    with pytest.raises(ApiError, match="fixed"):
        services.update(team.owner, team.ws, pid, sid, {"start_date": "2026-11-01"})


def test_a_future_start_date_is_brought_to_today_on_start(team: Any, web: Any) -> None:
    sprint = new_sprint(team, web, start="2026-11-09", end="2026-11-13")

    started = start(team, web, sprint, at(2, 9))

    assert started.start_date.isoformat() == "2026-11-02"


def test_overlapping_dates_warn_but_are_allowed(team: Any, web: Any) -> None:
    new_sprint(team, web, "A", "2026-11-02", "2026-11-13")

    out = services.create(team.owner, team.ws, str(web.pk), "B", "", "2026-11-10", "2026-11-20")
    clear = services.create(team.owner, team.ws, str(web.pk), "C", "", "2026-11-21", "2026-11-27")

    assert len(out.warnings) == 1 and '"A"' in out.warnings[0]
    assert clear.warnings == ()


def test_validation_of_names_dates_states(team: Any, web: Any) -> None:
    pid = str(web.pk)
    for args in (
        ("", "", "2026-11-02", "2026-11-06"),
        ("x" * 81, "", "2026-11-02", "2026-11-06"),
        ("x", "g" * 501, "2026-11-02", "2026-11-06"),
        ("x", "", "2026-11-07", "2026-11-06"),
        ("x", "", "2026-11-02", "2028-11-06"),
        ("x", "", "bad", "2026-11-06"),
    ):
        with pytest.raises(ApiError):
            services.create(team.owner, team.ws, pid, *args)
    with pytest.raises(ApiError, match="Unknown"):
        services.list_sprints(team.owner, team.ws, pid, ["weird"])
    with pytest.raises(ApiError):
        services.start(team.owner, team.ws, pid, "not-a-uuid")


def test_list_orders_active_planned_completed_with_counts(team: Any, web: Any) -> None:
    a = new_sprint(team, web, "A")
    b = new_sprint(team, web, "B", "2026-11-16", "2026-11-20")
    new_sprint(team, web, "C", "2026-11-09", "2026-11-13")
    add(team, web, a, make_task(team, web, "t1", "3"), make_task(team, web, "t2", "2"))
    start(team, web, a)

    rows = services.list_sprints(team.owner, team.ws, str(web.pk))
    only = services.list_sprints(team.owner, team.ws, str(web.pk), ["planned"])

    assert [r.sprint.name for r in rows] == ["A", "C", "B"]
    assert (rows[0].counts.tasks, rows[0].counts.points) == (2, 5)
    assert [r.sprint.name for r in only] == ["C", "B"]
    assert services.get_view(team.owner, team.ws, str(web.pk), str(b.pk)).sprint.name == "B"


def test_sprints_feature_off_hides_everything(team: Any) -> None:
    plain = team.create(team.owner, "OFF")
    with pytest.raises(ApiError, match="switched off"):
        services.list_sprints(team.owner, team.ws, str(plain.pk))
    with pytest.raises(ApiError, match="switched off"):
        services.create(team.owner, team.ws, str(plain.pk), "x", "", "2026-11-02", "2026-11-03")
    with pytest.raises(ApiError, match="switched off"):
        services.set_points(team.owner, team.ws, str(plain.pk), "x", "1")


def test_viewer_may_read_but_not_manage(team: Any, web: Any) -> None:
    sprint = new_sprint(team, web)
    assert services.list_sprints(team.viewer, team.ws, str(web.pk))
    with pytest.raises(access.PermissionDenied):
        services.start(team.viewer, team.ws, str(web.pk), str(sprint.pk))
    assert services.create(team.member, team.ws, str(web.pk), "M", "", "2026-11-02", "2026-11-03")


# -- tasks in and out --------------------------------------------------------------------------


def test_add_remove_move_tasks_between_sprints(team: Any, web: Any) -> None:
    a = new_sprint(team, web, "A")
    b = new_sprint(team, web, "B", "2026-11-09", "2026-11-13")
    t = make_task(team, web, "t", "3")

    moved = add(team, web, a, t)
    again = add(team, web, a, t)
    add(team, web, b, t)
    removed = services.remove_tasks(team.owner, team.ws, str(web.pk), str(b.pk), ids(t))

    assert (moved.changed, moved.late, again.changed) == (1, 0, 0)
    assert removed.changed == 1 and Task.objects.get(pk=t.pk).sprint_id is None
    with pytest.raises(ApiError):
        services.remove_tasks(team.owner, team.ws, str(web.pk), str(b.pk), ids(t))
    with pytest.raises(ApiError):
        services.add_tasks(team.owner, team.ws, str(web.pk), str(a.pk), [])
    with pytest.raises(ApiError):
        services.add_tasks(team.owner, team.ws, str(web.pk), str(a.pk), ["nope"])


def test_tasks_of_another_project_cannot_be_added(team: Any, web: Any) -> None:
    other = with_sprints(team, team.create(team.owner, "API"))
    foreign = make_task(team, other, "foreign")
    sprint = new_sprint(team, web)

    with pytest.raises(ApiError) as refused:
        add(team, web, sprint, foreign)

    assert refused.value.status == 404


def test_a_task_finished_in_a_completed_sprint_cannot_be_added_again(team: Any, web: Any) -> None:
    a = new_sprint(team, web, "A")
    t = make_task(team, web, "t")
    add(team, web, a, t)
    start(team, web, a)
    set_status(team, web, t, DONE)
    complete(team, web, a)
    b = new_sprint(team, web, "B", "2026-11-09", "2026-11-13")

    with pytest.raises(ApiError, match="finished"):
        add(team, web, b, t)
    set_status(team, web, t, "active")  # reopened: it may come back
    assert add(team, web, b, t).changed == 1


def test_backlog_is_open_tasks_in_no_live_sprint(team: Any, web: Any) -> None:
    sprint = new_sprint(team, web)
    free, planned, finished = (make_task(team, web, n) for n in ("free", "planned", "finished"))
    add(team, web, sprint, planned)
    set_status(team, web, finished, DONE)

    rows, total = services.backlog(team.owner, team.ws, str(web.pk))
    limited, total2 = services.backlog(team.owner, team.ws, str(web.pk), limit=1)

    assert [t.pk for t in rows] == [free.pk] and total == 1
    assert len(limited) == 1 and total2 == 1


def test_sprint_tasks_flags_those_added_after_the_start(team: Any, web: Any) -> None:
    sprint = new_sprint(team, web)
    early, late = make_task(team, web, "early"), make_task(team, web, "late")
    add(team, web, sprint, early)
    start(team, web, sprint)
    moved = add(team, web, sprint, late, now=at(3))

    rows = services.sprint_tasks(team.owner, team.ws, str(web.pk), str(sprint.pk))

    assert moved.late == 1
    assert {r.task.title: r.late for r in rows} == {"early": False, "late": True}


# -- complete and carry-over -------------------------------------------------------------------


def _worked_sprint(team: Any, web: Any, name: str = "Work") -> tuple[Any, Any, Any, Any]:
    sprint = new_sprint(team, web, name)
    finished = make_task(team, web, "finished", "3")
    open_ = make_task(team, web, "open", "5")
    cancelled = make_task(team, web, "cancelled", "2")
    add(team, web, sprint, finished, open_, cancelled)
    start(team, web, sprint)
    set_status(team, web, finished, DONE)
    set_status(team, web, cancelled, "cancelled")
    return sprint, finished, open_, cancelled


def test_complete_counts_only_done_and_carries_the_rest_to_the_next_sprint(
    team: Any, web: Any
) -> None:
    sprint, finished, open_, cancelled = _worked_sprint(team, web)
    later = new_sprint(team, web, "Later", "2026-11-23", "2026-11-27")
    nxt = new_sprint(team, web, "Next", "2026-11-09", "2026-11-13")

    done = complete(team, web, sprint, "next").sprint

    assert (done.completed_points, done.completed_tasks, done.unfinished_tasks) == (3, 1, 1)
    assert Task.objects.get(pk=open_.pk).sprint_id == nxt.pk  # the earliest planned
    assert Task.objects.get(pk=finished.pk).sprint_id == sprint.pk
    assert Task.objects.get(pk=cancelled.pk).sprint_id == sprint.pk
    closing = Snapshot.objects.filter(sprint=sprint).order_by("date")
    assert closing.count() == 5 and closing.last().remaining_points == 5  # 2nd..6th, back-filled
    assert refresh(later).version == 1
    assert ScopeEvent.objects.filter(sprint=nxt, after_start=False).count() == 1


def test_carry_over_to_a_chosen_sprint_or_the_backlog(team: Any, web: Any) -> None:
    sprint, _, open_, _ = _worked_sprint(team, web)
    new_sprint(team, web, "Next", "2026-11-09", "2026-11-13")
    chosen = new_sprint(team, web, "Chosen", "2026-11-23", "2026-11-27")

    complete(team, web, sprint, "next", str(chosen.pk))
    assert Task.objects.get(pk=open_.pk).sprint_id == chosen.pk

    second, _, open_two, _ = _worked_sprint(team, web, "Second")
    complete(team, web, second, "backlog")
    assert Task.objects.get(pk=open_two.pk).sprint_id is None


def test_carry_over_errors_leave_the_sprint_active(team: Any, web: Any) -> None:
    sprint, *_ = _worked_sprint(team, web)

    with pytest.raises(ApiError, match="carry_over"):
        complete(team, web, sprint, "huh")
    with pytest.raises(ApiError, match="planned"):
        complete(team, web, sprint, "next", str(sprint.pk))
    with pytest.raises(ApiError, match="no planned sprint"):
        complete(team, web, sprint, "next")

    assert refresh(sprint).state == State.ACTIVE


# -- snapshots, burndown ------------------------------------------------------------------------


def _fixture(team: Any, web: Any, *, late: bool = True) -> tuple[Any, dict[str, Any]]:
    """Five days (2-6 Nov): A3 B2 C5 = 10 at the start; D4 added on the 3rd (scope 14)."""
    sprint = new_sprint(team, web)
    rows = {
        n: make_task(team, web, n, p) for n, p in (("A", "3"), ("B", "2"), ("C", "5"), ("D", "4"))
    }
    add(team, web, sprint, rows["A"], rows["B"], rows["C"])
    start(team, web, sprint, at(2, 9))
    set_status(team, web, rows["A"], DONE)
    if late:
        add(team, web, sprint, rows["D"], now=at(3, 10))
    return sprint, rows


def test_burndown_matches_the_hand_computed_fixture_with_a_scope_change(
    team: Any, web: Any
) -> None:
    sprint, rows = _fixture(team, web, late=False)
    assert snapshots.take_all(at(3, 0, 10)) == 1  # the 2nd closes: A done
    add(team, web, sprint, rows["D"], now=at(3, 10))  # scope grows mid-sprint
    set_status(team, web, rows["B"], DONE)
    assert snapshots.take_all(at(4, 0, 10)) == 1  # the 3rd closes: B done too

    out = burndown.build(refresh(sprint), at(4, 12))

    d2, d3, d4, d5, d6 = out.days
    assert [d.date.day for d in out.days] == [2, 3, 4, 5, 6]
    assert [float(d.ideal_points) for d in out.days] == [8, 6, 4, 2, 0]
    assert (out.baseline_points, out.baseline_tasks) == (10, 3)
    assert (d2.remaining_points, d2.scope_points, d2.remaining_tasks) == (7, 10, 2)
    assert d2.backfilled is False
    assert (d3.remaining_points, d3.scope_points, d3.remaining_tasks) == (9, 14, 2)  # C5 + D4
    assert d4.live and (d4.remaining_points, d4.scope_points) == (9, 14)
    assert not d5.has_actual and not d6.has_actual
    assert [(s.date.day, s.points, s.tasks) for s in out.steps] == [(3, 4, 1)]


def test_a_missed_midnight_is_back_filled_with_exact_scope(team: Any, web: Any) -> None:
    sprint, _ = _fixture(team, web)

    written = snapshots.take_all(at(5, 9))  # nobody ran the job on the 3rd or 4th

    rows = {s.date.day: s for s in Snapshot.objects.filter(sprint=sprint)}
    assert written == 3 and sorted(rows) == [2, 3, 4]
    assert all(r.backfilled for r in rows.values())
    assert (rows[2].scope_points, rows[3].scope_points, rows[4].scope_points) == (10, 14, 14)
    assert snapshots.take_all(at(5, 9)) == 0  # idempotent


def test_a_run_just_after_midnight_is_not_a_backfill(team: Any, web: Any) -> None:
    sprint, _ = _fixture(team, web)

    snapshots.take_all(at(3, 0, 5))

    assert Snapshot.objects.get(sprint=sprint).backfilled is False


def test_midnight_follows_the_workspace_owner_time_zone(team: Any, web: Any) -> None:
    Profile.objects.filter(user=team.owner).update(timezone="Asia/Tehran")  # UTC+3:30
    ws = Workspace.objects.get(pk=team.ws.pk)
    sprint = new_sprint(team, web)
    services.start(team.owner, ws, str(web.pk), str(sprint.pk), at(2, 8))

    # 20:00 UTC on the 2nd is 23:30 in Tehran: the day is open; at 21:00 UTC it has closed.
    assert snapshots.take_all(at(2, 20)) == 0
    assert snapshots.take_all(at(2, 21)) == 1
    assert Snapshot.objects.get(sprint=sprint).date.isoformat() == "2026-11-02"


def test_snapshot_job_skips_planned_and_completed_sprints(team: Any, web: Any) -> None:
    planned = new_sprint(team, web, "P")
    done = new_sprint(team, web, "D", "2026-11-09", "2026-11-13")
    start(team, web, done)
    complete(team, web, done, now=at(2, 10))

    assert snapshots.take_all(at(5, 9)) == 0
    assert not Snapshot.objects.filter(sprint=planned).exists()


@pytest.mark.django_db
def test_management_command_runs_the_job(team: Any, web: Any, capsys: Any) -> None:
    _fixture(team, web)

    call_command("sprint_snapshots")

    assert "written" in capsys.readouterr().out


def test_burndown_of_planned_and_completed_sprints(team: Any, web: Any) -> None:
    planned = new_sprint(team, web)
    assert all(not d.has_actual for d in burndown.build(planned, at(1)).days)

    sprint, rows = _fixture(team, web)
    set_status(team, web, rows["B"], DONE)
    complete(team, web, sprint, now=at(4, 15))
    out = burndown.burndown(team.owner, team.ws, str(web.pk), str(sprint.pk), at(9))

    assert out.days[-1].date.day == 6
    last = [d for d in out.days if d.has_actual][-1]
    assert last.date.day == 4 and (last.remaining_points, last.scope_points) == (9, 14)
    assert refresh(sprint).completed_points == 5  # A3 + B2


def test_scope_removal_points_change_and_deletion_move_the_scope(team: Any, web: Any) -> None:
    sprint, rows = _fixture(team, web)
    sid, pid = str(sprint.pk), str(web.pk)

    services.remove_tasks(team.owner, team.ws, pid, sid, ids(rows["C"]), at(3, 11))
    services.set_points(team.owner, team.ws, pid, str(rows["B"].pk), "6", now=at(3, 12))
    tasks.delete(team.owner, team.ws, pid, str(rows["D"].pk))
    out = burndown.build(refresh(sprint), at(3, 13))

    final = snapshots.scope_until(refresh(sprint), None)
    live = out.days[1]
    # 10 at the start; C (5) out; B 2 -> 6 (+4); D (4) added then deleted
    assert (final.points, final.tasks) == (10 - 5 + 4, 2)
    assert live.live and live.scope_points == final.points
    assert live.remaining_points == final.points - 3  # only A is done


def test_restoring_a_deleted_task_adds_it_back_to_the_scope(team: Any, web: Any) -> None:
    sprint, rows = _fixture(team, web)
    tasks.delete(team.owner, team.ws, str(web.pk), str(rows["D"].pk))
    tasks.restore(team.owner, team.ws, str(web.pk), str(rows["D"].pk))

    assert snapshots.scope_until(refresh(sprint), None).points == 14


def test_velocity_is_the_last_six_completed_sprints_oldest_first(team: Any, web: Any) -> None:
    for i in range(7):
        s = new_sprint(team, web, f"S{i}", f"2026-0{i + 1}-01", f"2026-0{i + 1}-14")
        Sprint.objects.filter(pk=s.pk).update(
            state=State.COMPLETED,
            completed_at=at(14, month=1) + timedelta(days=31 * i),
            baseline_points=10 + i,
            completed_points=8 + i,
        )
    active = new_sprint(team, web, "Now")

    out = burndown.build(active, at(2))

    assert [v.sprint.name for v in out.velocity] == [f"S{i}" for i in range(1, 7)]
    assert [float(v.completed_points) for v in out.velocity] == [9, 10, 11, 12, 13, 14]
    assert float(out.average_velocity) == 11.5


# -- points, filter, cross-tenant ----------------------------------------------------------------


def test_set_points_validates_and_clears(team: Any, web: Any) -> None:
    t = make_task(team, web, "t", "2.5")
    pid = str(web.pk)

    assert float(Task.objects.get(pk=t.pk).points) == 2.5
    cleared = services.set_points(team.owner, team.ws, pid, str(t.pk), "")
    assert cleared.points is None
    for bad in ("abc", "-1", "100000", "NaN"):
        with pytest.raises(ApiError):
            services.set_points(team.owner, team.ws, pid, str(t.pk), bad)


def test_tfql_current_sprint_finds_the_active_sprints_tasks(team: Any, web: Any) -> None:
    sprint = new_sprint(team, web)
    inside = make_task(team, web, "in")
    make_task(team, web, "out")
    add(team, web, sprint, inside)

    def find(text: str) -> list[str]:
        cat = Catalogue(web)
        ast = language.parse_text(text, cat)
        q = compiler.where(ast, cat, date(2026, 11, 2), team.member)
        return sorted(t.title for t in Task.objects.filter(project=web).filter(q))

    assert find("sprint = currentSprint()") == []  # planned is not current
    start(team, web, sprint)
    assert find("sprint = currentSprint()") == ["in"]
    assert find("sprint != currentSprint()") == ["out"]


def test_other_workspaces_cannot_reach_a_sprint(team: Any, web: Any) -> None:
    sprint = new_sprint(team, web)

    with pytest.raises((ApiError, access.PermissionDenied)):
        services.get_view(team.outsider, team.ws, str(web.pk), str(sprint.pk))
    with pytest.raises(ApiError) as wrong_ws:  # their own workspace, our project
        services.get_view(team.outsider, team.other_ws, str(web.pk), str(sprint.pk))
    other = with_sprints(team, team.create(team.owner, "API"))
    with pytest.raises(ApiError) as wrong_project:  # our sprint through another project
        services.get_view(team.owner, team.ws, str(other.pk), str(sprint.pk))

    assert wrong_ws.value.status == 404 and wrong_project.value.status == 404


def test_generic_task_update_refuses_points_so_scope_changes_are_never_missed(
    team: Any, web: Any
) -> None:
    t = make_task(team, web, "t", "2")
    with pytest.raises(ApiError):
        tasks.update(team.owner, team.ws, str(web.pk), str(t.pk), t.version, {"points": "9"})
    assert float(Task.objects.get(pk=t.pk).points) == 2


def test_baseline_leaves_out_tasks_already_done_at_the_start(team: Any, web: Any) -> None:
    sprint = new_sprint(team, web)
    done = make_task(team, web, "done", "3")
    todo = make_task(team, web, "todo", "5")
    set_status(team, web, done, "done")
    add(team, web, sprint, done, todo)

    started = start(team, web, sprint)

    assert (float(refresh(started).baseline_points), refresh(started).baseline_tasks) == (5, 1)


def test_capacity_is_kept_changed_and_cleared(team: Any, web: Any) -> None:
    pid = str(web.pk)
    made = services.create(
        team.owner, team.ws, pid, "S", "", "2026-11-02", "2026-11-06", "30.5", 144000
    ).sprint
    assert (made.capacity_points, made.capacity_sec) == (Decimal("30.50"), 144000)
    bare = new_sprint(team, web, "B", "2026-11-09", "2026-11-13")
    assert (bare.capacity_points, bare.capacity_sec) == (None, None)

    start(team, web, made)  # an active sprint may still change its capacity
    changed = services.update(
        team.owner, team.ws, pid, str(made.pk), {"capacity_points": "12", "capacity_sec": "7200"}
    ).sprint
    assert (changed.capacity_points, changed.capacity_sec) == (Decimal("12.00"), 7200)
    cleared = services.update(
        team.owner, team.ws, pid, str(made.pk), {"capacity_points": "", "capacity_sec": "0"}
    ).sprint
    assert (cleared.capacity_points, cleared.capacity_sec) == (None, None)
    assert refresh(made).capacity_points is None


def test_capacity_is_validated(team: Any, web: Any) -> None:
    sprint = new_sprint(team, web)
    for bad in ({"capacity_points": "-1"}, {"capacity_points": "x"}, {"capacity_sec": "-5"}):
        with pytest.raises(ApiError):
            services.update(team.owner, team.ws, str(web.pk), str(sprint.pk), bad)
    with pytest.raises(ApiError):
        services.create(
            team.owner, team.ws, str(web.pk), "S", "", "2026-11-02", "2026-11-06", "", 10**9
        )
    assert refresh(sprint).capacity_sec is None


def test_sample_tasks_are_left_out_of_the_sprint_numbers(team: Any, web: Any) -> None:
    from infrastructure.sprints import tally

    real, sample = make_task(team, web, "real", "3"), make_task(team, web, "sample", "5")
    sprint = new_sprint(team, web)
    add(team, web, sprint, real, sample)
    Task.objects.filter(pk=sample.pk).update(is_sample=True)

    counts = tally.tally(refresh(sprint))

    assert (counts.tasks, counts.points, counts.open_tasks) == (1, Decimal("3"), 1)
    started = start(team, web, sprint)
    assert started.baseline_points == Decimal("3") and started.baseline_tasks == 1
