"""The inbox as a person uses it: list, filters, read, snooze, archive, counts."""

from datetime import timedelta
from typing import Any

import pytest
from django.utils import timezone

from infrastructure.common.errors import ApiError
from infrastructure.inbox import kinds, prefs, services, watchers
from infrastructure.inbox.models import Notification
from infrastructure.inbox.tests.test_notify import assign, inbox
from infrastructure.tasks import services as tasks


def seed(
    team: Any, project: Any, user: Any, n: int, kind: str = kinds.COMMENTED
) -> list[Notification]:
    task = tasks.create(team.owner, team.ws, str(project.pk), "T")
    base = timezone.now() - timedelta(hours=n)
    return [
        Notification.objects.create(
            user=user,
            workspace=team.ws,
            type=kind,
            task=task,
            project_id=project.pk,
            actor=team.owner,
            payload={"title": "T", "key": "WEB-1"},
            dedupe_key=f"seed-{i}-{kind}",
            created_at=base + timedelta(minutes=i),
            updated_at=base + timedelta(minutes=i),
        )
        for i in range(n)
    ]


def test_the_list_is_newest_activity_first_and_pages_without_gaps(team: Any, project: Any) -> None:
    rows = seed(team, project, team.member, 7)

    first = services.list_page(team.member, team.ws, "all", limit=3)
    second = services.list_page(team.member, team.ws, "all", before=first.cursor, limit=3)
    third = services.list_page(team.member, team.ws, "all", before=second.cursor, limit=3)

    seen = [n.pk for n in (*first.notifications, *second.notifications, *third.notifications)]
    assert seen == [r.pk for r in reversed(rows)]
    assert first.cursor and second.cursor and third.cursor == ""
    assert first.unread == 7


def test_filters_pick_unread_mentions_assigned_snoozed_and_archived(
    team: Any, project: Any
) -> None:
    [a, b] = seed(team, project, team.member, 2, kinds.MENTIONED)
    [c] = seed(team, project, team.member, 1, kinds.ASSIGNED)
    services.mark_read(team.member, team.ws, [str(a.pk)], all_=False, read=True)
    services.snooze(
        team.member, team.ws, str(c.pk), (timezone.now() + timedelta(hours=3)).isoformat()
    )
    services.archive(team.member, team.ws, [str(b.pk)], archived=True)

    def ids(name: str) -> set[Any]:
        return {n.pk for n in services.list_page(team.member, team.ws, name).notifications}

    assert ids("all") == {a.pk}
    assert ids("unread") == set()
    assert ids("mentions") == {a.pk}
    assert ids("assigned") == set()
    assert ids("snoozed") == {c.pk}
    assert ids("archived") == {b.pk}


def test_other_peoples_and_other_workspaces_notifications_are_invisible(
    team: Any, project: Any
) -> None:
    seed(team, project, team.owner, 2)

    assert services.list_page(team.member, team.ws, "all").notifications == []
    assert services.unread_count(team.member, None) == 0


def test_an_unknown_filter_or_cursor_is_refused(team: Any) -> None:
    with pytest.raises(ApiError):
        services.list_page(team.member, team.ws, "everything")
    with pytest.raises(ApiError):
        services.list_page(team.member, team.ws, "all", before="not-a-place")


def test_marking_read_and_unread_returns_what_is_unread_now(team: Any, project: Any) -> None:
    rows = seed(team, project, team.member, 3)

    assert services.mark_read(team.member, team.ws, [str(rows[0].pk)], all_=False, read=True) == 2
    assert services.mark_read(team.member, team.ws, [], all_=True, read=True) == 0
    assert services.mark_read(team.member, team.ws, [str(rows[1].pk)], all_=False, read=False) == 1


def test_you_cannot_touch_somebody_elses_notifications(team: Any, project: Any) -> None:
    [theirs] = seed(team, project, team.owner, 1)

    services.mark_read(team.member, team.ws, [str(theirs.pk)], all_=False, read=True)
    services.archive(team.member, team.ws, [str(theirs.pk)], archived=True)

    theirs.refresh_from_db()
    assert theirs.read_at is None and theirs.archived_at is None
    with pytest.raises(ApiError) as missing:
        services.snooze(
            team.member, team.ws, str(theirs.pk), (timezone.now() + timedelta(1)).isoformat()
        )
    assert missing.value.status == 404


def test_a_snoozed_notification_hides_then_comes_back_unread(team: Any, project: Any) -> None:
    [row] = seed(team, project, team.member, 1)
    services.mark_read(team.member, team.ws, [], all_=True, read=True)
    until = timezone.now() + timedelta(hours=2)

    services.snooze(team.member, team.ws, str(row.pk), until.isoformat())

    assert services.list_page(team.member, team.ws, "all").notifications == []
    assert services.unread_count(team.member, team.ws) == 0
    assert services.wake_snoozed(timezone.now()) == 0
    assert services.wake_snoozed(until + timedelta(minutes=1)) == 1
    [back] = services.list_page(team.member, team.ws, "unread").notifications
    assert back.pk == row.pk and back.snoozed_until is None


def test_snoozing_can_be_undone_and_rejects_the_past_and_a_bad_time(
    team: Any, project: Any
) -> None:
    [row] = seed(team, project, team.member, 1)
    services.snooze(
        team.member, team.ws, str(row.pk), (timezone.now() + timedelta(hours=2)).isoformat()
    )

    services.snooze(team.member, team.ws, str(row.pk), "")
    assert len(services.list_page(team.member, team.ws, "all").notifications) == 1
    for bad in (
        (timezone.now() - timedelta(1)).isoformat(),
        "tomorrow",
        "2030-01-01T10:00:00",
        (timezone.now() + timedelta(days=400)).isoformat(),
    ):
        with pytest.raises(ApiError):
            services.snooze(team.member, team.ws, str(row.pk), bad)


def test_archiving_can_be_undone(team: Any, project: Any) -> None:
    [row] = seed(team, project, team.member, 1)

    services.archive(team.member, team.ws, [str(row.pk)], archived=True)
    assert services.list_page(team.member, team.ws, "all").notifications == []
    services.archive(team.member, team.ws, [str(row.pk)], archived=False)
    assert len(services.list_page(team.member, team.ws, "all").notifications) == 1


def test_the_badge_counts_every_workspace_you_belong_to(team: Any, project: Any) -> None:
    from infrastructure.workspaces import services as workspaces

    seed(team, project, team.member, 2)
    other = workspaces.create(team.member, "Mine", "mine")
    other_project = (
        __import__("infrastructure.projects.services", fromlist=["x"])
        .create(team.member, other, "Side", "SID")
        .project
    )
    other_task = tasks.create(team.member, other, str(other_project.pk), "T")
    Notification.objects.create(
        user=team.member,
        workspace=other,
        type=kinds.ASSIGNED,
        task=other_task,
        project_id=other_project.pk,
        dedupe_key="x",
        payload={},
    )

    assert services.unread_count(team.member, team.ws) == 2
    assert services.unread_count(team.member, other) == 1
    assert services.unread_count(team.member, None) == 3


def test_changes_are_announced_to_the_persons_other_devices(
    team: Any, project: Any, broker: Any
) -> None:
    seed(team, project, team.member, 1)
    broker.sent.clear()

    services.mark_read(team.member, team.ws, [], all_=True, read=True)

    [event] = broker.events(f"user:{team.member.pk}")
    assert event["type"] == "notification.changed" and event["entity_id"] == str(team.member.pk)


def test_live_events_are_catch_up_material_only_for_their_person(
    team: Any, project: Any, task: Any
) -> None:
    from infrastructure.sync import services as sync_services

    assign(team, project, task, team.member)

    mine = sync_services.since(team.member, team.ws, 0)
    theirs = sync_services.since(team.viewer, team.ws, 0)

    assert "notification.new" in [e.event_type for e in mine.entries]
    assert "notification.new" not in [e.event_type for e in theirs.entries]
    assert inbox(team, team.member)


# -- watching ------------------------------------------------------------------------------------


def test_watching_is_a_switch_that_is_safe_to_repeat(team: Any, project: Any, task: Any) -> None:
    args = (team.member, team.ws, str(project.pk), str(task.pk))

    assert watchers.state(*args) == {"watching": False, "watcher_count": 1}  # the creator
    assert watchers.watch(*args, on=True) == {"watching": True, "watcher_count": 2}
    assert watchers.watch(*args, on=True)["watcher_count"] == 2
    assert watchers.watch(*args, on=False) == {"watching": False, "watcher_count": 1}
    assert watchers.watch(*args, on=False)["watcher_count"] == 1


def test_you_cannot_watch_what_you_cannot_open(team: Any) -> None:
    secret = team.create(team.owner, "SEC", visibility="private", name="Secret")
    hidden = tasks.create(team.owner, team.ws, str(secret.pk), "Hidden")

    with pytest.raises(ApiError):
        watchers.watch(team.member, team.ws, str(secret.pk), str(hidden.pk), on=True)
    with pytest.raises(ApiError):
        watchers.state(team.member, team.ws, str(secret.pk), "not-an-id")


def test_unwatching_stops_the_comments_and_status_changes(
    team: Any, project: Any, task: Any
) -> None:
    from infrastructure.comments import services as comments
    from infrastructure.comments.tests.conftest import say

    args = (team.owner, team.ws, str(project.pk), str(task.pk))
    watchers.watch(*args, on=False)  # the creator stops watching

    comments.create(team.member, team.ws, str(project.pk), str(task.pk), say("hi"))

    assert inbox(team, team.owner) == []
    assert prefs.effective(team.owner.pk, kinds.COMMENTED).inbox is True


def test_a_silly_page_size_is_clamped_not_a_crash(team: Any, project: Any) -> None:
    seed(team, project, team.member, 2)

    assert len(services.list_page(team.member, team.ws, "all", limit=-5).notifications) == 1
    assert len(services.list_page(team.member, team.ws, "all", limit=100000).notifications) == 2
