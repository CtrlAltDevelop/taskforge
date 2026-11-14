"""The workload grid against a hand-computed fixture, privacy, rules and cache invalidation.

Calendar used: Monday 2030-01-07 .. Sunday 2030-01-13, default capacity 8 h Monday to Friday.

Task A: Mon 7 -> Wed 9, 24 h, assigned to ``member``            -> 8 h on each of 7, 8, 9
Task B: Tue 8 -> Thu 10, 18 h, assigned to ``member`` and ``pm`` -> 9 h each, 3 h per day on 8, 9, 10
"""

# ruff: noqa: E501 - fixture data reads better on one line

from datetime import date
from typing import Any

import pytest

from infrastructure.common.errors import ApiError
from infrastructure.tasks import services as tasks
from infrastructure.tasks.models import Task
from infrastructure.workload import services
from infrastructure.workload.models import AssigneeEstimate

H = 3600
FIRST, LAST = "2030-01-07", "2030-01-13"


def day(n: int) -> date:
    return date(2030, 1, n)


def make_task(
    team: Any, project: Any, title: str, estimate_h: int, assignees: list[Any], **dates: str
) -> Any:
    task = tasks.create(
        team.owner,
        team.ws,
        str(project.pk),
        title,
        assignee_ids=[str(a.pk) for a in assignees],
        **dates,
    )
    Task.objects.filter(pk=task.pk).update(estimate_sec=estimate_h * H)
    return Task.objects.get(pk=task.pk)


@pytest.fixture
def grid(team: Any, project: Any) -> dict[str, Any]:
    a = make_task(
        team, project, "A", 24, [team.member], start_date="2030-01-07", due_date="2030-01-09"
    )
    b = make_task(
        team,
        project,
        "B",
        18,
        [team.member, team.pm],
        start_date="2030-01-08",
        due_date="2030-01-10",
    )
    return {"a": a, "b": b}


def cells(workload: Any, user: Any) -> dict[int, tuple[int, int]]:
    person = next(p for p in workload.people if p.user_id == str(user.pk))
    return {c.day.day: (c.load_sec, c.capacity_sec) for c in person.days}


def compute(team: Any, actor: Any = None, **kw: Any) -> Any:
    return services.compute(actor or team.owner, team.ws, FIRST, LAST, **kw)


# --- the hand-computed grid ----------------------------------------------------------------


def test_multi_day_multi_assignee_grid(team: Any, grid: Any) -> None:
    result = compute(team)
    # member: A 8 h on 7, 8, 9 plus B 3 h on 8, 9, 10
    assert cells(result, team.member) == {
        7: (8 * H, 8 * H),
        8: (11 * H, 8 * H),
        9: (11 * H, 8 * H),
        10: (3 * H, 8 * H),
    }
    # pm: only B's share
    assert cells(result, team.pm) == {8: (3 * H, 8 * H), 9: (3 * H, 8 * H), 10: (3 * H, 8 * H)}
    member = next(p for p in result.people if p.user_id == str(team.member.pk))
    assert member.total_load_sec == 33 * H  # 24 h + 9 h
    over = {c.day.day for c in member.days if c.over}
    assert over == {8, 9}
    assert {t.display_id for t in result.tasks} == {grid["a"].display_id, grid["b"].display_id}
    assert result.unestimated == []


def test_a_holiday_removes_the_day_and_moves_load_to_the_others(team: Any, grid: Any) -> None:
    services.create_holiday(team.owner, team.ws, "2030-01-09", "Founders day")
    result = compute(team)
    # A over 7, 8 -> 12 h each; B over 8, 10 -> 4.5 h each for each person
    assert cells(result, team.member) == {
        7: (12 * H, 8 * H),
        8: (12 * H + int(4.5 * H), 8 * H),
        10: (int(4.5 * H), 8 * H),
    }
    assert cells(result, team.pm) == {8: (int(4.5 * H), 8 * H), 10: (int(4.5 * H), 8 * H)}
    assert result.holidays == [day(9)]


def test_time_off_reduces_capacity_and_the_persons_working_days(team: Any, grid: Any) -> None:
    services.create_time_off(
        team.owner, team.ws, str(team.pm.pk), "2030-01-10", "2030-01-10", "vacation", ""
    )
    result = compute(team)
    # pm's B share (9 h) now lands on 8 and 9 only: 4.5 h each; capacity on the 10th is 0
    assert cells(result, team.pm) == {8: (int(4.5 * H), 8 * H), 9: (int(4.5 * H), 8 * H)}
    pm_row = next(p for p in result.people if p.user_id == str(team.pm.pk))
    assert [(o.start, o.end) for o in pm_row.time_off] == [(day(10), day(10))]
    # member is unaffected
    assert cells(result, team.member)[10] == (3 * H, 8 * H)


def test_time_off_covering_the_whole_task_puts_it_on_the_due_date_with_a_warning(
    team: Any, grid: Any
) -> None:
    services.create_time_off(
        team.owner, team.ws, str(team.member.pk), "2030-01-07", "2030-01-10", "sick", ""
    )
    result = compute(team)
    member = next(p for p in result.people if p.user_id == str(team.member.pk))
    assert {c.day.day: c.capacity_sec for c in member.days} == {9: 0, 10: 0}
    assert all(k.warning for c in member.days for k in c.contributions)


def test_capacity_hours_and_weekdays_change_the_grid(team: Any, grid: Any) -> None:
    services.set_capacity(team.owner, team.ws, str(team.member.pk), "4", [0, 2])  # Mon, Wed, 4 h
    result = compute(team)
    # A: 24 h on Mon 7 and Wed 9 -> 12 h each; B's member share (9 h) on Wed 9 only
    assert cells(result, team.member) == {7: (12 * H, 4 * H), 9: (12 * H + 9 * H, 4 * H)}


# --- privacy -------------------------------------------------------------------------------


def test_a_member_without_workload_view_sees_only_their_own_row(team: Any, grid: Any) -> None:
    result = compute(team, team.viewer, user_ids=[str(team.member.pk)])
    assert not result.can_see_all
    assert [p.user_id for p in result.people] == [str(team.viewer.pk)]
    assert result.tasks == [] and result.unestimated == []


def test_the_viewer_sees_their_own_assigned_tasks_only(team: Any, project: Any) -> None:
    make_task(
        team, project, "Mine", 8, [team.viewer], start_date="2030-01-07", due_date="2030-01-07"
    )
    make_task(
        team, project, "Theirs", 8, [team.member], start_date="2030-01-07", due_date="2030-01-07"
    )
    result = compute(team, team.viewer)
    assert [t.title for t in result.tasks] == ["Mine"]
    assert cells(result, team.viewer) == {7: (8 * H, 8 * H)}


def test_a_member_with_workload_view_sees_everyone(team: Any, grid: Any) -> None:
    result = compute(team, team.member)
    assert result.can_see_all
    assert {p.user_id for p in result.people} >= {str(team.member.pk), str(team.pm.pk)}


def test_other_peoples_capacity_and_time_off_need_the_view_permission(team: Any) -> None:
    with pytest.raises(ApiError) as caught:
        services.get_capacity(team.viewer, team.ws, str(team.member.pk))
    assert caught.value.status == 403
    assert [c.user_id for c in services.get_capacity(team.viewer, team.ws)] == [str(team.viewer.pk)]
    with pytest.raises(ApiError):
        services.list_time_off(team.viewer, team.ws, str(team.member.pk), FIRST, LAST)


# --- unestimated and undated ---------------------------------------------------------------


def test_unestimated_and_undated_tasks_are_listed_not_placed(team: Any, project: Any) -> None:
    make_task(
        team,
        project,
        "No estimate",
        0,
        [team.member],
        start_date="2030-01-08",
        due_date="2030-01-09",
    )
    make_task(team, project, "No dates", 5, [team.member])
    make_task(team, project, "Unassigned", 5, [], start_date="2030-01-08", due_date="2030-01-09")
    result = compute(team)
    assert {t.title: t.reason for t in result.unestimated} == {
        "No estimate": services.NO_ESTIMATE,
        "No dates": services.NO_DATES,
    }
    assert result.tasks == []
    assert all(not p.days for p in result.people)


def test_a_per_assignee_estimate_overrides_the_equal_split(team: Any, grid: Any) -> None:
    services.set_assignee_estimate(team.owner, team.ws, str(grid["b"].pk), str(team.pm.pk), 12 * H)
    result = compute(team)
    # pm 12 h over 3 days = 4 h; member gets the remaining 6 h = 2 h per day (+ A's 8 h)
    assert cells(result, team.pm) == {8: (4 * H, 8 * H), 9: (4 * H, 8 * H), 10: (4 * H, 8 * H)}
    assert cells(result, team.member)[10] == (2 * H, 8 * H)
    assert AssigneeEstimate.objects.filter(task=grid["b"]).count() == 1


# --- permission rules ----------------------------------------------------------------------


def test_only_managers_set_anybodys_capacity(team: Any) -> None:
    for actor in (team.member, team.viewer):
        with pytest.raises(ApiError) as caught:
            services.set_capacity(actor, team.ws, str(team.pm.pk), "6", [0, 1])
        assert caught.value.status == 403
    done = services.set_capacity(team.admin, team.ws, str(team.pm.pk), "6", [0, 1])
    assert str(done.hours_per_day) == "6.00" and done.working_days == [0, 1]


@pytest.mark.parametrize("hours", ["25", "-1", "abc"])
def test_capacity_hours_are_validated(team: Any, hours: str) -> None:
    with pytest.raises(ApiError) as caught:
        services.set_capacity(team.admin, team.ws, str(team.pm.pk), hours, [0])
    assert caught.value.status == 400


def test_a_person_manages_only_their_own_time_off(team: Any) -> None:
    own = services.create_time_off(
        team.member, team.ws, "", "2030-02-01", "2030-02-02", "vacation", ""
    )
    assert own.user_id == team.member.pk
    with pytest.raises(ApiError) as caught:
        services.create_time_off(
            team.member, team.ws, str(team.pm.pk), "2030-02-01", "2030-02-02", "other", ""
        )
    assert caught.value.status == 403
    theirs = services.create_time_off(
        team.admin, team.ws, str(team.pm.pk), "2030-02-01", "2030-02-02", "other", ""
    )
    with pytest.raises(ApiError):
        services.delete_time_off(team.member, team.ws, str(theirs.pk))
    with pytest.raises(ApiError):
        services.update_time_off(
            team.member, team.ws, str(theirs.pk), "2030-02-03", "2030-02-04", "other", ""
        )
    services.delete_time_off(team.member, team.ws, str(own.pk))
    services.delete_time_off(team.admin, team.ws, str(theirs.pk))


def test_time_off_ending_before_it_starts_is_refused(team: Any) -> None:
    with pytest.raises(ApiError):
        services.create_time_off(team.member, team.ws, "", "2030-02-05", "2030-02-01", "other", "")


def test_only_managers_edit_holidays_and_a_day_is_one_holiday(team: Any) -> None:
    with pytest.raises(ApiError) as caught:
        services.create_holiday(team.member, team.ws, "2030-12-25", "Xmas")
    assert caught.value.status == 403
    holiday = services.create_holiday(team.admin, team.ws, "2030-12-25", "Xmas")
    with pytest.raises(ApiError) as dup:
        services.create_holiday(team.admin, team.ws, "2030-12-25", "Again")
    assert dup.value.status == 409
    with pytest.raises(ApiError):
        services.delete_holiday(team.member, team.ws, str(holiday.pk))
    services.delete_holiday(team.admin, team.ws, str(holiday.pk))
    assert services.list_holidays(team.member, team.ws) == []


def test_an_outsider_has_no_access(team: Any) -> None:
    with pytest.raises(ApiError):
        services.compute(team.outsider, team.ws, FIRST, LAST)


# --- reassign persistence and cache --------------------------------------------------------


def test_reassigning_through_tasks_update_persists_and_drops_the_cached_grid(
    team: Any, grid: Any
) -> None:
    before = compute(team)
    assert cells(before, team.member)[7] == (8 * H, 8 * H)
    assert compute(team) is not None  # a second call is served from the cache

    task = grid["a"]
    tasks.update(
        team.owner, team.ws, str(task.project_id), str(task.pk), task.version,
        {"assignee_ids": [str(team.pm.pk)]},
    )  # fmt: skip

    stored = Task.objects.get(pk=task.pk)
    assert [str(a.user_id) for a in stored.assignees.all()] == [str(team.pm.pk)]
    after = compute(team)
    assert 7 not in cells(after, team.member)  # member no longer carries A
    assert cells(after, team.pm)[7] == (8 * H, 8 * H)
    assert cells(after, team.pm)[8] == (11 * H, 8 * H)


def test_a_capacity_change_drops_the_cached_grid(team: Any, grid: Any) -> None:
    assert cells(compute(team), team.member)[7] == (8 * H, 8 * H)
    services.set_capacity(team.owner, team.ws, str(team.member.pk), "6", [0, 1, 2, 3, 4])
    assert cells(compute(team), team.member)[7] == (8 * H, 6 * H)
