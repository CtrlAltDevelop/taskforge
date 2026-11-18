"""Home.Summary: counts, scoping, cache, query count, recent, week, pins."""

import uuid
from datetime import UTC, date, datetime, timedelta
from typing import Any

import pytest
from django.core.cache import cache
from django.db import connection
from django.test.utils import CaptureQueriesContext

from infrastructure.common.errors import ApiError
from infrastructure.dashboards import services as dashboards
from infrastructure.home import summary
from infrastructure.home.models import RecentItem
from infrastructure.home.tests.conftest import Category, World
from infrastructure.tasks.models import Task
from infrastructure.timetracking.models import TimeEntry

TODAY = date(2026, 11, 18)  # a Wednesday


def read(world: World, user: Any, day: date = TODAY, offset: int = 0) -> summary.Summary:
    return summary.summary(user, world.ws, day, offset)


def due(days: int) -> str:
    return (TODAY + timedelta(days=days)).isoformat()


def test_counts_and_lists_cover_only_open_tasks_assigned_to_the_viewer(world: World) -> None:
    world.task(world.web, "overdue", world.member, due_date=due(-3))
    world.task(world.web, "today", world.member, due_date=due(0))
    world.task(world.web, "later", world.member, due_date=due(5))
    active = world.task(world.web, "working", world.member)
    world.move(active, Category.ACTIVE)
    finished = world.task(world.web, "finished", world.member, due_date=due(-1))
    world.move(finished, Category.DONE)
    world.task(world.web, "theirs", world.owner, due_date=due(0))

    got = read(world, world.member)

    assert (got.today_count, got.overdue_count, got.in_progress_count) == (1, 1, 1)
    assert [i.title for i in got.due_items] == ["overdue", "today"]
    assert [i.title for i in got.in_progress_items] == ["working"]
    assert got.due_items[0].project_key == "WEB" and got.due_items[0].due_date == due(-3)


def test_sample_tasks_are_left_out(world: World) -> None:
    sample = world.task(world.web, "sample", world.member, due_date=due(0))
    Task.objects.filter(pk=sample.pk).update(is_sample=True)

    got = read(world, world.member)

    assert got.today_count == 0 and got.due_items == []


def test_a_private_project_never_leaks_into_counts_items_or_recent(world: World) -> None:
    secret = world.task(world.sec, "secret", world.member, due_date=due(-1))
    world.move(secret, Category.ACTIVE)
    RecentItem.objects.create(user=world.member, workspace=world.ws, task=secret)

    got = read(world, world.member)

    assert (got.today_count, got.overdue_count, got.in_progress_count) == (0, 0, 0)
    assert got.due_items == [] and got.in_progress_items == [] and got.recent == []
    assert read(world, world.owner, offset=1).overdue_count == 0  # not assigned to the owner


def test_private_project_assigned_to_a_member_counts_for_them_once_they_belong(
    world: World,
) -> None:
    from infrastructure.projects import members

    world.task(world.sec, "secret", world.member, due_date=due(0))
    members.add_member(world.owner, world.ws, str(world.sec.pk), str(world.member.pk))

    assert read(world, world.member).today_count == 1


def test_an_archived_project_is_not_counted(world: World) -> None:
    world.task(world.web, "old", world.member, due_date=due(0))
    type(world.web).objects.filter(pk=world.web.pk).update(archived_at=datetime.now(UTC))

    assert read(world, world.member).today_count == 0


def test_the_answer_is_cached_per_viewer_and_workspace(world: World) -> None:
    task = world.task(world.web, "a", world.member, due_date=due(0))
    first = read(world, world.member)
    Task.objects.filter(pk=task.pk).update(due_date=due(5))  # a write that sends no signal

    assert read(world, world.member).today_count == first.today_count == 1  # within 30 s
    assert read(world, world.owner).today_count == 0  # another viewer: another key
    assert read(world, world.member, offset=60).today_count == 0  # another key: recomputed
    cache.clear()
    assert read(world, world.member).today_count == 0


def test_query_count_does_not_grow_with_the_data(world: World) -> None:
    def queries() -> int:
        cache.clear()
        with CaptureQueriesContext(connection) as seen:
            read(world, world.member)
        return len(seen)

    one = world.task(world.web, "one", world.member, due_date=due(0))
    RecentItem.objects.create(user=world.member, task=one, workspace=world.ws)
    small = queries()
    for n in range(25):
        task = world.task(world.web, f"t{n}", world.member, due_date=due(-n))
        RecentItem.objects.get_or_create(user=world.member, task=task, workspace=world.ws)
    assert queries() == small


def test_recent_lists_what_was_opened_newest_first_and_trims(world: World) -> None:
    tasks = [world.task(world.web, f"t{n}") for n in range(summary.RECENT_KEEP + 3)]
    for task in tasks:
        summary.record_recent(world.member, world.ws, str(task.pk))
    summary.record_recent(world.member, world.ws, str(tasks[-3].pk))  # opened again

    got = read(world, world.member).recent

    assert [i.title for i in got][:2] == [tasks[-3].title, tasks[-1].title]
    assert len(got) == summary.RECENT_SHOWN
    kept = RecentItem.objects.filter(user=world.member, workspace=world.ws).count()
    assert kept == summary.RECENT_KEEP


def test_recent_hides_a_deleted_task_and_refuses_one_the_viewer_cannot_open(world: World) -> None:
    secret = world.task(world.sec, "secret")
    with pytest.raises(ApiError) as hidden:
        summary.record_recent(world.member, world.ws, str(secret.pk))
    assert hidden.value.status == 404
    with pytest.raises(ApiError):
        summary.record_recent(world.member, world.ws, "not-a-uuid")
    task = world.task(world.web, "gone")
    summary.record_recent(world.member, world.ws, str(task.pk))
    Task.objects.filter(pk=task.pk).update(deleted_at=datetime.now(UTC))

    assert read(world, world.member).recent == []


def test_week_sums_logged_time_per_day_in_the_viewers_zone(world: World) -> None:
    task = world.task(world.web, "timed")
    monday = datetime(2026, 11, 16, tzinfo=UTC)
    for start, seconds in (
        (monday + timedelta(hours=9), 3600),
        (monday + timedelta(hours=10), 1800),
        (monday + timedelta(days=2, hours=9), 600),
    ):
        TimeEntry.objects.create(
            workspace=world.ws,
            task=task,
            user=world.member,
            started_at=start,
            ended_at=start + timedelta(seconds=seconds),
            duration_sec=seconds,
            source="manual",
        )
    TimeEntry.objects.create(  # someone else's
        workspace=world.ws,
        task=task,
        user=world.owner,
        started_at=monday + timedelta(hours=9),
        ended_at=monday + timedelta(hours=10),
        duration_sec=3600,
        source="manual",
    )

    week = read(world, world.member).week

    assert [d.date for d in week][0] == "2026-11-16" and len(week) == 7
    assert [d.seconds for d in week] == [5400, 0, 600, 0, 0, 0, 0]


def test_pinned_dashboards_are_the_viewers_and_only_while_visible(world: World) -> None:
    mine = dashboards.save(
        world.owner,
        world.ws,
        "",
        name="Mine",
        visibility="personal",
        project_id="",
        widgets=[],
        layout=[],
    ).dashboard
    shared = dashboards.save(
        world.owner,
        world.ws,
        "",
        name="Shared",
        visibility="workspace",
        project_id="",
        widgets=[],
        layout=[],
    ).dashboard
    with pytest.raises(ApiError) as hidden:  # a personal dashboard of someone else
        summary.pin_dashboard(world.member, world.ws, str(mine.pk), True)
    assert hidden.value.status == 404
    with pytest.raises(ApiError):
        summary.pin_dashboard(world.member, world.ws, str(uuid.uuid4()), True)

    summary.pin_dashboard(world.member, world.ws, str(shared.pk), True)
    summary.pin_dashboard(world.member, world.ws, str(shared.pk), True)  # safe to repeat
    assert [p.name for p in read(world, world.member).pinned_dashboards] == ["Shared"]  # at once
    assert read(world, world.owner, offset=1).pinned_dashboards == []

    dashboards.save(
        world.owner,
        world.ws,
        str(shared.pk),
        name="Shared",
        visibility="personal",
        project_id="",
        widgets=[],
        layout=[],
        expected_version=shared.version,
    )
    cache.clear()
    assert read(world, world.member).pinned_dashboards == []
    summary.pin_dashboard(world.owner, world.ws, str(shared.pk), True)
    summary.pin_dashboard(world.owner, world.ws, str(shared.pk), False)
    assert read(world, world.owner).pinned_dashboards == []


def test_bad_inputs_are_refused(world: World) -> None:
    with pytest.raises(ApiError):
        summary.parse_day("yesterday")
    with pytest.raises(ApiError):
        summary.clean_offset(24 * 60)
    assert summary.parse_day("") is not None


def test_unread_chat_counts_visible_spaces_only(world: World) -> None:
    from infrastructure.chat.models import ChatMember, ChatMessage, ChatSpace

    def talk(space: Any, text: str) -> None:
        ChatMember.objects.update_or_create(space=space, user=world.member)
        ChatMessage.objects.create(
            space=space,
            workspace=world.ws,
            author=world.owner,
            body={"text": text},
            created_at=datetime.now(UTC) + timedelta(minutes=1),
        )

    # A project's channel exists from the project's creation; the private one is not the member's.
    talk(ChatSpace.objects.get(project=world.web), "open")
    talk(ChatSpace.objects.get(project=world.sec), "hidden")

    assert read(world, world.member).unread_chat == 1


def test_a_status_change_shows_on_home_at_once(world: World) -> None:
    from infrastructure.sync.actor import set_actor
    from infrastructure.tasks import services as task_services
    from infrastructure.workflows.models import Status

    task = world.task(world.web, "a", world.member, due_date=due(0))
    assert read(world, world.member).in_progress_count == 0  # cached now
    set_actor(world.owner)
    active = Status.objects.filter(project=world.web, category=Category.ACTIVE).first()
    task_services.update(
        world.owner,
        world.ws,
        str(world.web.pk),
        str(task.pk),
        task.version,
        {"status": str(active.pk)},
    )

    assert read(world, world.member).in_progress_count == 1  # no cache.clear(): assignee refreshed
    assert read(world, world.owner).in_progress_count == 0


def test_assigning_a_task_shows_on_the_new_assignees_home_at_once(world: World) -> None:
    from infrastructure.tasks.models import TaskAssignee

    task = world.task(world.web, "a", due_date=due(0))
    assert read(world, world.member).today_count == 0
    TaskAssignee.objects.create(task=task, user=world.member)
    assert read(world, world.member).today_count == 1
    TaskAssignee.objects.filter(task=task).delete()
    assert read(world, world.member).today_count == 0


def _other_workspace(world: World) -> tuple[Any, Any, Any]:
    from infrastructure.dashboards import services as dash
    from infrastructure.projects import services as project_services
    from infrastructure.workspaces import services as workspace_services

    other = workspace_services.create(world.owner, "Other", "other")
    project = project_services.create(world.owner, other, "Zed", "ZED").project
    task = world.task_in(other, project, "b-task", world.owner, due_date=due(0))
    board = dash.save(
        world.owner,
        other,
        "",
        name="B board",
        visibility="workspace",
        project_id="",
        widgets=[],
        layout=[],
    ).dashboard
    return other, task, board


def test_nothing_of_another_workspace_leaks_in_either_direction(world: World) -> None:
    other, theirs, board = _other_workspace(world)
    mine = world.task(world.web, "a-task", world.owner, due_date=due(0))
    TimeEntry.objects.create(
        workspace=other,
        task=theirs,
        user=world.owner,
        source="manual",
        started_at=datetime(2026, 11, 16, 9, tzinfo=UTC),
        ended_at=datetime(2026, 11, 16, 10, tzinfo=UTC),
        duration_sec=3600,
    )

    with pytest.raises(ApiError) as recent:
        summary.record_recent(world.owner, world.ws, str(theirs.pk))
    with pytest.raises(ApiError) as pin:
        summary.pin_dashboard(world.owner, world.ws, str(board.pk), True)
    here = read(world, world.owner)
    there = summary.summary(world.owner, other, TODAY, 0)

    assert recent.value.status == 404 and pin.value.status == 404
    assert [i.title for i in here.due_items] == [mine.title]
    assert [i.title for i in there.due_items] == ["b-task"]
    assert sum(d.seconds for d in here.week) == 0 and sum(d.seconds for d in there.week) == 3600
    assert here.pinned_dashboards == []
