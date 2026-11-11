"""From an event to a notification: who is told, how often, over which channel."""

from datetime import timedelta
from typing import Any

from django.utils import timezone

from infrastructure.auth.core import delivery as mail
from infrastructure.comments import services as comments
from infrastructure.comments.tests.conftest import ping, say
from infrastructure.inbox import kinds, prefs, services
from infrastructure.inbox.models import Delivery, Notification, PushDevice
from infrastructure.tasks import services as tasks


def assign(team: Any, project: Any, task: Any, *who: Any, by: Any = None) -> Any:
    current = tasks.get(by or team.owner, team.ws, str(project.pk), str(task.pk))
    return tasks.update(
        by or team.owner,
        team.ws,
        str(project.pk),
        str(task.pk),
        current.version,
        {"assignee_ids": [str(u.pk) for u in who]},
    )


def inbox(team: Any, user: Any, filter_: str = "all") -> list[Notification]:
    return services.list_page(user, team.ws, filter_).notifications


def statuses(team: Any, project: Any) -> list[Any]:
    from infrastructure.workflows.models import Status

    return list(Status.objects.filter(project=project).order_by("position", "name"))


def move_to(team: Any, project: Any, task: Any, status: Any, by: Any = None) -> None:
    who = by or team.owner
    current = tasks.get(who, team.ws, str(project.pk), str(task.pk))
    tasks.update(
        who, team.ws, str(project.pk), str(task.pk), current.version, {"status": str(status.pk)}
    )


# -- assigning -----------------------------------------------------------------------------------


def test_assigning_tells_the_assignee_in_the_inbox_and_by_push(
    team: Any, project: Any, task: Any, push: Any, broker: Any
) -> None:
    prefs.register_device(team.member, "android", "phone-1")

    assign(team, project, task, team.member)

    [got] = inbox(team, team.member)
    assert got.type == kinds.ASSIGNED and got.actor_id == team.owner.pk
    assert got.payload == {"title": "Fix login", "key": "WEB-1"}
    [sent] = push.sent
    assert sent["token"] == "phone-1" and sent["data"]["type"] == kinds.ASSIGNED
    assert "assigned you" in sent["title"]
    mine = [e for e in broker.events(f"user:{team.member.pk}") if e["type"] == "notification.new"]
    assert len(mine) == 1 and mine[0]["entity_id"] == str(team.member.pk)


def test_nobody_hears_about_what_they_did_themselves(
    team: Any, project: Any, task: Any, push: Any
) -> None:
    prefs.register_device(team.member, "android", "phone-1")

    assign(team, project, task, team.member, by=team.member)

    assert inbox(team, team.member) == [] and push.sent == []


def test_a_person_who_was_already_assigned_is_not_told_again(
    team: Any, project: Any, task: Any
) -> None:
    assign(team, project, task, team.member)
    assign(team, project, task, team.member, team.admin)

    assert len(inbox(team, team.member)) == 1 and len(inbox(team, team.admin)) == 1


def test_a_task_created_with_assignees_tells_them(team: Any, project: Any) -> None:
    tasks.create(team.owner, team.ws, str(project.pk), "New", assignee_ids=[str(team.member.pk)])

    assert [n.type for n in inbox(team, team.member)] == [kinds.ASSIGNED]


def test_assigning_makes_the_assignee_and_the_creator_watchers(
    team: Any, project: Any, task: Any
) -> None:
    from infrastructure.inbox import watchers

    assign(team, project, task, team.member)

    assert set(watchers.watcher_ids(task.pk)) == {team.owner.pk, team.member.pk}


# -- bursts and repeats --------------------------------------------------------------------------


def test_ten_rapid_status_changes_are_one_notification(
    team: Any, project: Any, task: Any, push: Any
) -> None:
    from infrastructure.inbox import watchers

    watchers.ensure(task.pk, [team.member.pk])
    prefs.set_pref(team.member, kinds.STATUS_CHANGED, inbox=True, push=True, email_mode="off")
    prefs.register_device(team.member, "ios", "phone-1")
    a, b, *_ = statuses(team, project)
    for n in range(10):
        move_to(team, project, task, b if n % 2 == 0 else a)

    [got] = inbox(team, team.member)
    assert got.count == 10 and got.payload["from"] == a.name and got.payload["to"] == a.name
    assert len(push.sent) == 1  # told once, not ten times


def test_a_change_after_the_window_is_a_new_notification(
    team: Any, project: Any, task: Any
) -> None:
    from infrastructure.inbox import watchers

    watchers.ensure(task.pk, [team.member.pk])
    a, b, *_ = statuses(team, project)
    move_to(team, project, task, b)
    Notification.objects.update(updated_at=timezone.now() - timedelta(minutes=5))
    move_to(team, project, task, a)

    assert len(inbox(team, team.member)) == 2


def test_a_read_notification_is_not_folded_into(team: Any, project: Any, task: Any) -> None:
    from infrastructure.inbox import watchers

    watchers.ensure(task.pk, [team.member.pk])
    a, b, *_ = statuses(team, project)
    move_to(team, project, task, b)
    services.mark_read(team.member, team.ws, [], all_=True, read=True)
    move_to(team, project, task, a)

    assert len(inbox(team, team.member)) == 2


def test_the_same_event_delivered_twice_makes_one_notification(
    team: Any, project: Any, task: Any
) -> None:
    from infrastructure.inbox import receivers
    from infrastructure.tasks.signals import task_activity

    event = {
        "task_id": str(task.pk),
        "project_id": str(project.pk),
        "workspace_id": str(team.ws.pk),
        "actor_id": str(team.owner.pk),
        "version": 7,
        "kind": "assigned",
        "data": {"user_ids": [str(team.member.pk)]},
    }

    receivers._activity(task_activity, **event)
    receivers._activity(task_activity, **event)

    assert len(inbox(team, team.member)) == 1


# -- access --------------------------------------------------------------------------------------


def test_somebody_who_cannot_open_the_project_is_not_notified(
    team: Any, project: Any, task: Any
) -> None:
    from infrastructure.inbox import notify

    secret = team.create(team.owner, "SEC", visibility="private", name="Secret")
    hidden = tasks.create(team.owner, team.ws, str(secret.pk), "Hidden")

    made = notify.notify(
        kind=kinds.ASSIGNED,
        recipients=[team.member.pk],
        workspace=team.ws,
        project=secret,
        task=hidden,
        actor_id=team.owner.pk,
        payload={},
        dedupe="x",
    )

    assert made == [] and inbox(team, team.member) == []


def test_what_you_can_no_longer_open_disappears_from_the_inbox_and_the_count(
    team: Any, project: Any, task: Any
) -> None:
    from infrastructure.projects import services as projects

    assign(team, project, task, team.member)
    assert services.unread_count(team.member, team.ws) == 1

    projects.update(team.owner, team.ws, str(project.pk), project.version, visibility="private")

    assert inbox(team, team.member) == [] and services.unread_count(team.member, team.ws) == 0
    assert services.unread_count(team.member, None) == 0


def test_a_push_for_somebody_who_lost_access_is_skipped(
    team: Any, project: Any, task: Any, push: Any
) -> None:
    from infrastructure.inbox import delivery
    from infrastructure.projects import services as projects

    prefs.register_device(team.member, "android", "phone-1")
    prefs.set_settings(
        team.member, timezone="UTC", quiet_start="00:00", quiet_end="23:59", digest_hour=8
    )  # held back, so there is time to lose access
    assign(team, project, task, team.member)
    projects.update(team.owner, team.ws, str(project.pk), project.version, visibility="private")

    delivery.deliver_due(timezone.now() + timedelta(days=1))

    assert push.sent == []
    assert Delivery.objects.get().status == "skipped"


# -- choices -------------------------------------------------------------------------------------


def test_with_the_inbox_off_a_push_still_goes_but_nothing_is_listed(
    team: Any, project: Any, task: Any, push: Any
) -> None:
    prefs.set_pref(team.member, kinds.ASSIGNED, inbox=False, push=True, email_mode="off")
    prefs.register_device(team.member, "android", "phone-1")

    assign(team, project, task, team.member)

    assert inbox(team, team.member) == [] and len(push.sent) == 1
    assert services.unread_count(team.member, team.ws) == 0


def test_with_every_channel_off_nothing_is_made(team: Any, project: Any, task: Any) -> None:
    prefs.set_pref(team.member, kinds.ASSIGNED, inbox=False, push=False, email_mode="off")

    assign(team, project, task, team.member)

    assert Notification.objects.filter(user=team.member).count() == 0


def test_the_defaults_are_quiet_a_status_change_does_not_push(
    team: Any, project: Any, task: Any, push: Any
) -> None:
    from infrastructure.inbox import watchers

    watchers.ensure(task.pk, [team.member.pk])
    prefs.register_device(team.member, "android", "phone-1")
    _, b, *_ = statuses(team, project)

    move_to(team, project, task, b)

    assert len(inbox(team, team.member)) == 1 and push.sent == []


# -- quiet hours, email, digests -----------------------------------------------------------------


def test_quiet_hours_hold_the_push_until_they_end_but_not_the_inbox(
    team: Any, project: Any, task: Any, push: Any
) -> None:
    from infrastructure.inbox import delivery

    prefs.register_device(team.member, "android", "phone-1")
    now = timezone.now()
    start = (now - timedelta(hours=1)).strftime("%H:%M")
    end = (now + timedelta(hours=2)).strftime("%H:%M")
    prefs.set_settings(team.member, timezone="UTC", quiet_start=start, quiet_end=end, digest_hour=8)

    assign(team, project, task, team.member)

    assert len(inbox(team, team.member)) == 1 and push.sent == []
    held = Delivery.objects.get()
    assert held.status == "pending" and held.due_at > now + timedelta(hours=1)
    delivery.deliver_due(now + timedelta(hours=1))
    assert push.sent == []
    delivery.deliver_due(held.due_at + timedelta(minutes=1))
    assert len(push.sent) == 1


def test_an_instant_email_has_the_words_and_an_unsubscribe_link(
    team: Any, project: Any, task: Any
) -> None:
    prefs.set_pref(team.member, kinds.ASSIGNED, inbox=True, push=False, email_mode="instant")

    assign(team, project, task, team.member)

    [message] = [m for m in mail.outbox if m.destination == team.member.email]
    assert "assigned you" in message.subject and "WEB-1 Fix login" in message.body
    assert "unsubscribe?token=" in message.body


def test_the_unsubscribe_link_turns_that_kind_off_and_keeps_working(
    team: Any, project: Any, task: Any
) -> None:
    from django.test import Client

    prefs.set_pref(team.member, kinds.ASSIGNED, inbox=True, push=True, email_mode="instant")
    assign(team, project, task, team.member)
    body = next(m.body for m in mail.outbox if m.destination == team.member.email)
    link = body[body.index("http") :].split()[0]
    path = link.replace("http://localhost:8010", "")

    def mode() -> str:
        return {r["event_type"]: r for r in prefs.get(team.member)["prefs"]}[kinds.ASSIGNED][
            "email_mode"
        ]

    page = Client().get(path)  # a mail scanner fetching the link changes nothing
    assert page.status_code == 200 and b"<form" in page.content and mode() == "instant"
    for _ in range(2):  # the button: and again changes nothing more
        assert Client().post(path).status_code == 200
    row = {r["event_type"]: r for r in prefs.get(team.member)["prefs"]}[kinds.ASSIGNED]
    assert row["email_mode"] == "off" and row["push"] is True and row["inbox"] is True
    assert Client().get("/api/v1/inbox/unsubscribe?token=forged").status_code == 403
    assert Client().post("/api/v1/inbox/unsubscribe?token=forged").status_code == 403


def test_a_digest_goes_out_once_a_day_with_everything_grouped_by_project(
    team: Any, project: Any
) -> None:
    from infrastructure.inbox import delivery

    prefs.set_pref(team.member, kinds.ASSIGNED, inbox=True, push=False, email_mode="digest")
    other = team.create(team.owner, "OPS", name="Ops")
    first = tasks.create(team.owner, team.ws, str(project.pk), "One")
    second = tasks.create(team.owner, team.ws, str(other.pk), "Two")
    assign(team, project, first, team.member)
    assign(team, other, second, team.member)
    assert [
        m for m in mail.outbox if m.destination == team.member.email
    ] == []  # held for the digest

    soon = timezone.now() + timedelta(days=1, hours=1)
    delivery.deliver_due(soon)
    delivery.deliver_due(soon + timedelta(minutes=5))  # the tick runs again

    digests = [m for m in mail.outbox if m.destination == team.member.email]
    assert len(digests) == 1
    assert "Web" in digests[0].body and "Ops" in digests[0].body
    assert "WEB-1" in digests[0].body and "OPS-1" in digests[0].body


def test_a_notification_read_before_its_digest_is_left_out(
    team: Any, project: Any, task: Any
) -> None:
    from infrastructure.inbox import delivery

    prefs.set_pref(team.member, kinds.ASSIGNED, inbox=True, push=False, email_mode="digest")
    assign(team, project, task, team.member)
    services.mark_read(team.member, team.ws, [], all_=True, read=True)

    delivery.deliver_due(timezone.now() + timedelta(days=2))

    assert [m for m in mail.outbox if m.destination == team.member.email] == []
    assert Delivery.objects.get().status == "skipped"


# -- delivery failures ---------------------------------------------------------------------------


def test_a_failing_provider_is_retried_then_given_up_on(
    team: Any, project: Any, task: Any, push: Any
) -> None:
    from infrastructure.inbox import delivery

    prefs.register_device(team.member, "android", "phone-1")
    push.fail = True
    assign(team, project, task, team.member)
    assert Delivery.objects.get().status == "pending"

    later = timezone.now()
    for _ in range(3):
        later += timedelta(minutes=10)
        delivery.deliver_due(later)

    item = Delivery.objects.get()
    assert item.status == "failed" and item.attempts == 3 and push.sent == []


def test_a_dead_token_is_forgotten(team: Any, project: Any, task: Any, monkeypatch: Any) -> None:
    from infrastructure.inbox import push as push_module

    class Dead:
        def send(self, *args: Any) -> None:
            raise push_module.DeadToken("x")

    monkeypatch.setattr("infrastructure.inbox.delivery.push_provider", lambda: Dead())
    prefs.register_device(team.member, "android", "old-token")

    assign(team, project, task, team.member)

    assert PushDevice.objects.count() == 0


def test_no_device_means_the_push_is_skipped(team: Any, project: Any, task: Any, push: Any) -> None:
    assign(team, project, task, team.member)

    assert Delivery.objects.get().status == "skipped"


# -- mentions and comments -----------------------------------------------------------------------


def test_a_mention_tells_the_person_with_the_words(
    team: Any, project: Any, task: Any, push: Any
) -> None:
    prefs.register_device(team.viewer, "ios", "v-phone")

    comments.create(
        team.member, team.ws, str(project.pk), str(task.pk), say("look ", ping(team.viewer, "x"))
    )

    [got] = inbox(team, team.viewer, "mentions")
    assert got.type == kinds.MENTIONED and got.payload["excerpt"].startswith("look")
    assert got.actor_id == team.member.pk and len(push.sent) == 1


def test_a_comment_tells_the_watchers_but_not_its_author_nor_the_mentioned(
    team: Any, project: Any, task: Any
) -> None:
    from infrastructure.inbox import watchers

    watchers.ensure(task.pk, [team.member.pk, team.viewer.pk, team.admin.pk])

    comments.create(
        team.member, team.ws, str(project.pk), str(task.pk), say("hi ", ping(team.viewer, "x"))
    )

    assert [n.type for n in inbox(team, team.owner)] == [kinds.COMMENTED]  # creator watches
    assert [n.type for n in inbox(team, team.admin)] == [kinds.COMMENTED]
    assert [n.type for n in inbox(team, team.viewer)] == [kinds.MENTIONED]  # not told twice
    assert inbox(team, team.member) == []


def test_commenting_makes_you_a_watcher(team: Any, project: Any, task: Any) -> None:
    from infrastructure.inbox import watchers

    comments.create(team.member, team.ws, str(project.pk), str(task.pk), say("first"))

    assert team.member.pk in watchers.watcher_ids(task.pk)


# -- due soon ------------------------------------------------------------------------------------


def test_due_soon_tells_assignees_once_and_skips_finished_tasks(
    team: Any, project: Any, task: Any
) -> None:
    from infrastructure.inbox import due
    from infrastructure.workflows.models import Category, Status

    today = timezone.now().date()
    soon = tasks.create(
        team.owner,
        team.ws,
        str(project.pk),
        "Soon",
        due_date=(today + timedelta(days=1)).isoformat(),
        assignee_ids=[str(team.member.pk)],
    )
    far = tasks.create(
        team.owner,
        team.ws,
        str(project.pk),
        "Far",
        due_date=(today + timedelta(days=30)).isoformat(),
        assignee_ids=[str(team.member.pk)],
    )
    finished = tasks.create(
        team.owner,
        team.ws,
        str(project.pk),
        "Done",
        due_date=today.isoformat(),
        assignee_ids=[str(team.member.pk)],
    )
    done = Status.objects.filter(project=project, category=Category.DONE).first()
    from infrastructure.tasks.models import Task

    Task.objects.filter(pk=finished.pk).update(status=done)
    Notification.objects.all().delete()

    assert due.scan_due_soon() == 1
    assert due.scan_due_soon() == 0  # told once for this due date

    [got] = inbox(team, team.member)
    assert got.type == kinds.DUE_SOON and got.payload["key"] == "WEB-2"
    assert soon.pk and far.pk


def test_an_old_unsubscribe_link_no_longer_works(team: Any, settings: Any) -> None:
    from django.test import Client

    from infrastructure.inbox import delivery

    token = delivery.unsubscribe_token(team.member.pk, kinds.ASSIGNED)
    settings.INBOX_UNSUBSCRIBE_DAYS = -1

    assert Client().post(f"/api/v1/inbox/unsubscribe?token={token}").status_code == 403


def test_an_unsubscribe_for_a_deleted_person_is_refused_not_a_crash(team: Any) -> None:
    from django.test import Client

    from infrastructure.inbox import delivery

    token = delivery.unsubscribe_token("00000000-0000-0000-0000-000000000000", "all")

    assert Client().post(f"/api/v1/inbox/unsubscribe?token={token}").status_code == 403


def test_turning_a_channel_off_cancels_what_was_already_held(
    team: Any, project: Any, task: Any, push: Any
) -> None:
    from infrastructure.inbox import delivery

    prefs.register_device(team.member, "android", "phone-1")
    prefs.set_pref(team.member, kinds.ASSIGNED, inbox=True, push=True, email_mode="digest")
    prefs.set_settings(
        team.member, timezone="UTC", quiet_start="00:00", quiet_end="23:59", digest_hour=8
    )
    assign(team, project, task, team.member)
    prefs.set_pref(team.member, kinds.ASSIGNED, inbox=True, push=False, email_mode="off")

    delivery.deliver_due(timezone.now() + timedelta(days=2))

    assert push.sent == [] and [m for m in mail.outbox if m.destination == team.member.email] == []
    assert {d.status for d in Delivery.objects.all()} == {"skipped"}


def test_a_push_about_a_private_project_names_only_the_task_key(team: Any, push: Any) -> None:
    secret = team.create(team.owner, "SEC", visibility="private", name="Secret")
    from infrastructure.projects import members as project_members

    project_members.add_member(team.owner, team.ws, str(secret.pk), str(team.member.pk))
    hidden = tasks.create(team.owner, team.ws, str(secret.pk), "Merger plans")
    prefs.register_device(team.member, "ios", "phone-1")

    assign(team, secret, hidden, team.member)

    [sent] = push.sent
    assert "Merger" not in sent["title"] + sent["body"] and sent["body"] == "SEC-1"


def test_a_push_in_an_open_project_says_what_happened(
    team: Any, project: Any, task: Any, push: Any
) -> None:
    prefs.register_device(team.member, "ios", "phone-1")

    assign(team, project, task, team.member)

    assert "Fix login" in push.sent[0]["body"]


def test_a_claimed_delivery_is_not_sent_twice_and_a_dead_workers_claim_is_released(
    team: Any, project: Any, task: Any, push: Any
) -> None:
    from infrastructure.inbox import delivery

    prefs.register_device(team.member, "android", "phone-1")
    prefs.set_settings(
        team.member, timezone="UTC", quiet_start="00:00", quiet_end="23:59", digest_hour=8
    )
    assign(team, project, task, team.member)
    later = timezone.now() + timedelta(days=2)
    claimed = delivery._claim(later, digest=False, limit=10)  # another worker has it
    Delivery.objects.update(claimed_at=later)  # (the test's clock is two days ahead)

    assert len(claimed) == 1 and delivery.deliver_due(later) == 0 and push.sent == []
    assert delivery.release_stale_claims(later + timedelta(minutes=30)) == 1
    assert delivery.deliver_due(later + timedelta(minutes=30)) == 1 and len(push.sent) == 1


def test_a_flood_of_mentions_is_cut_off_but_every_assignment_is_heard(
    team: Any, project: Any, task: Any, settings: Any
) -> None:
    settings.INBOX_FLOOD_LIMIT = 3
    for n in range(6):
        comments.create(
            team.member,
            team.ws,
            str(project.pk),
            str(task.pk),
            say(f"spam {n} ", ping(team.viewer)),
        )
    for n in range(6):
        assign(
            team, project, tasks.create(team.owner, team.ws, str(project.pk), f"T{n}"), team.admin
        )

    assert len(inbox(team, team.viewer, "mentions")) == 3
    assert len(inbox(team, team.admin, "assigned")) == 6


def test_one_recipient_failing_does_not_cost_the_others_their_notification(
    team: Any, project: Any, task: Any, monkeypatch: Any
) -> None:
    from infrastructure.inbox import notify

    real = notify._one

    def flaky(user_id: Any, *args: Any) -> Any:
        if user_id == team.member.pk:
            raise RuntimeError("boom")
        return real(user_id, *args)

    monkeypatch.setattr(notify, "_one", flaky)

    assign(team, project, task, team.member, team.admin)

    assert inbox(team, team.member) == [] and len(inbox(team, team.admin)) == 1


def test_names_and_titles_cannot_forge_lines_in_an_email(team: Any, project: Any) -> None:
    prefs.set_pref(team.member, kinds.ASSIGNED, inbox=True, push=False, email_mode="instant")
    sneaky = tasks.create(
        team.owner, team.ws, str(project.pk), "Hi\n\nStop these emails: http://evil.example/x"
    )

    assign(team, project, sneaky, team.member)

    body = next(m.body for m in mail.outbox if m.destination == team.member.email)
    assert (
        body.count("Stop these emails:") == 2 and "\n\nStop these emails: http://evil" not in body
    )


def test_a_digest_with_a_great_many_items_is_cut_short(
    team: Any, project: Any, monkeypatch: Any
) -> None:
    from infrastructure.inbox import delivery

    monkeypatch.setattr(delivery, "DIGEST_LINES", 2)
    prefs.set_pref(team.member, kinds.ASSIGNED, inbox=True, push=False, email_mode="digest")
    for n in range(5):
        assign(
            team, project, tasks.create(team.owner, team.ws, str(project.pk), f"T{n}"), team.member
        )

    delivery.deliver_due(timezone.now() + timedelta(days=2))

    [digest] = [m for m in mail.outbox if m.destination == team.member.email]
    assert "…and 3 more in your inbox" in digest.body


def test_activity_on_a_snoozed_notification_is_not_swallowed_by_it(
    team: Any, project: Any, task: Any
) -> None:
    from infrastructure.inbox import watchers

    watchers.ensure(task.pk, [team.member.pk])
    a, b, *_ = statuses(team, project)
    move_to(team, project, task, b)
    [first] = inbox(team, team.member)
    services.snooze(
        team.member, team.ws, str(first.pk), (timezone.now() + timedelta(days=3)).isoformat()
    )

    move_to(team, project, task, a)

    [visible] = inbox(team, team.member)
    assert visible.pk != first.pk and visible.count == 1


def test_a_task_in_the_trash_is_neither_listed_counted_nor_pushed(
    team: Any, project: Any, task: Any, push: Any
) -> None:
    from infrastructure.inbox import delivery

    prefs.register_device(team.member, "android", "phone-1")
    prefs.set_settings(
        team.member, timezone="UTC", quiet_start="00:00", quiet_end="23:59", digest_hour=8
    )
    assign(team, project, task, team.member)
    tasks.delete(team.owner, team.ws, str(project.pk), str(task.pk), "subtree")

    assert inbox(team, team.member) == [] and services.unread_count(team.member, team.ws) == 0
    delivery.deliver_due(timezone.now() + timedelta(days=2))
    assert push.sent == []


def test_a_bulk_assignment_tells_everyone_assigned(team: Any, project: Any) -> None:
    from infrastructure.tasks import bulk

    ids = [str(tasks.create(team.owner, team.ws, str(project.pk), f"T{n}").pk) for n in range(4)]

    list(
        bulk.update_many(
            team.owner,
            team.ws,
            str(project.pk),
            ids,
            changes={"assignee_ids": [str(team.member.pk)]},
        )
    )

    assert len(inbox(team, team.member, "assigned")) == 4


def test_moving_a_task_with_its_subtasks_tells_the_watchers_of_each(
    team: Any, project: Any
) -> None:
    from infrastructure.inbox import watchers

    parent = tasks.create(team.owner, team.ws, str(project.pk), "Parent")
    child = tasks.create(team.owner, team.ws, str(project.pk), "Child", parent_id=str(parent.pk))
    watchers.ensure(child.pk, [team.member.pk])
    done = next(s for s in statuses(team, project) if s.category == "done")

    tasks.move(
        team.owner,
        team.ws,
        str(project.pk),
        str(parent.pk),
        parent.version,
        str(done.pk),
        with_subtasks=True,
    )

    [got] = inbox(team, team.member)
    assert got.task_id == child.pk and got.payload["to"] == done.name


def test_one_dead_device_among_several_does_not_repeat_the_push_to_the_others(
    team: Any, project: Any, task: Any, monkeypatch: Any
) -> None:
    sent: list[str] = []

    class Mixed:
        def send(self, device: Any, *args: Any) -> None:
            if device.token == "bad":
                raise RuntimeError("503")
            sent.append(device.token)

    monkeypatch.setattr("infrastructure.inbox.delivery.push_provider", lambda: Mixed())
    prefs.register_device(team.member, "android", "good")
    prefs.register_device(team.member, "web", "bad")

    assign(team, project, task, team.member)

    assert sent == ["good"] and Delivery.objects.get().status == "sent"


def test_a_digest_is_never_split_into_two_emails_however_many_people_are_due(
    team: Any, project: Any, monkeypatch: Any
) -> None:
    from infrastructure.inbox import delivery

    monkeypatch.setattr(delivery, "BATCH", 1)  # one person per claim
    for user in (team.member, team.admin):
        prefs.set_pref(user, kinds.ASSIGNED, inbox=True, push=False, email_mode="digest")
    for n in range(3):
        for user in (team.member, team.admin):
            assign(team, project, tasks.create(team.owner, team.ws, str(project.pk), f"T{n}"), user)

    delivery.deliver_due(timezone.now() + timedelta(days=2))
    delivery.deliver_due(timezone.now() + timedelta(days=2))

    sent = [m.destination for m in mail.outbox if m.subject.startswith("Your daily")]
    assert sorted(sent) == sorted([team.member.email, team.admin.email])


def test_a_digest_waits_for_the_end_of_quiet_hours(team: Any, project: Any, task: Any) -> None:
    prefs.set_pref(team.member, kinds.ASSIGNED, inbox=True, push=False, email_mode="digest")
    prefs.set_settings(
        team.member, timezone="UTC", quiet_start="06:00", quiet_end="11:00", digest_hour=8
    )

    assign(team, project, task, team.member)

    due = Delivery.objects.get().due_at
    assert due.hour == 11 and due.minute == 0
