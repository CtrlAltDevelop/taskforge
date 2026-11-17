"""Phase 42: a change to a task writes a system message into its chat."""

from datetime import timedelta
from typing import Any

import pytest
from django.utils import timezone

from infrastructure.comments import services
from infrastructure.comments.models import Comment
from infrastructure.comments.tests.conftest import say
from infrastructure.common.errors import ApiError
from infrastructure.sync.actor import set_actor
from infrastructure.tasks import services as tasks
from infrastructure.workflows.models import Status

pytestmark = pytest.mark.django_db


def _system(task: Any) -> list[Comment]:
    return list(Comment.objects.filter(task=task, kind="system").order_by("created_at", "id"))


def _change(team: Any, project: Any, task: Any, who: Any = None, **changes: Any) -> Any:
    who = who or team.owner
    set_actor(who)
    fresh = tasks.get(who, team.ws, str(project.pk), str(task.pk))
    return tasks.update(who, team.ws, str(project.pk), str(task.pk), fresh.version, changes)


def test_priority_change_writes_one_message_with_actor_field_from_to(
    team: Any, project: Any, task: Any
) -> None:
    _change(team, project, task, priority="high")

    (msg,) = _system(task)
    assert msg.body == {}
    assert msg.event["field"] == "priority"
    assert (msg.event["from"], msg.event["to"]) == ("none", "high")
    assert (msg.event["actor_type"], msg.event["actor_id"]) == ("user", str(team.owner.pk))


@pytest.mark.parametrize(
    ("field", "value"),
    [("title", "New"), ("due_date", "2030-01-02"), ("start_date", "2030-01-01")],
)
def test_each_tracked_field_adds_a_message(
    team: Any, project: Any, task: Any, field: str, value: str
) -> None:
    _change(team, project, task, **{field: value})
    assert [m.event["field"] for m in _system(task)] == [field]


def test_status_change_adds_a_message(team: Any, project: Any, task: Any) -> None:
    target = Status.objects.filter(project=project).exclude(pk=task.status_id).first()
    _change(team, project, task, status=str(target.pk))
    assert [m.event["field"] for m in _system(task)] == ["status_id"]


def test_assignee_change_adds_a_message(team: Any, project: Any, task: Any) -> None:
    _change(team, project, task, assignee_ids=[str(team.member.pk)])
    (msg,) = _system(task)
    assert msg.event["field"] == "assignees"
    assert msg.event["to"] == [str(team.member.pk)]


def test_same_person_same_field_within_five_minutes_is_one_message(
    team: Any, project: Any, task: Any
) -> None:
    _change(team, project, task, priority="low")
    _change(team, project, task, priority="high")

    (msg,) = _system(task)
    assert (msg.event["from"], msg.event["to"]) == ("none", "high")


def test_coalescing_breaks_on_time_other_actor_and_user_message(
    team: Any, project: Any, task: Any
) -> None:
    _change(team, project, task, priority="low")
    _change(team, project, task, who=team.admin, priority="normal")
    assert len(_system(task)) == 2  # other actor

    _change(team, project, task, who=team.admin, priority="high")
    assert len(_system(task)) == 2  # merged again
    services.create(team.member, team.ws, str(project.pk), str(task.pk), say("why?"))
    _change(team, project, task, who=team.admin, priority="low")
    assert len(_system(task)) == 3  # user message between

    Comment.objects.filter(kind="system").update(created_at=timezone.now() - timedelta(minutes=6))
    Comment.objects.filter(kind="user").update(created_at=timezone.now() - timedelta(minutes=7))
    _change(team, project, task, who=team.admin, priority="high")
    assert len(_system(task)) == 4  # too old


def test_automation_actor_is_named_not_a_person(team: Any, project: Any, task: Any) -> None:
    from infrastructure.audit import context

    with context.as_automation("auto-1"):
        _change(team, project, task, priority="high")
    (msg,) = _system(task)
    assert (msg.event["actor_type"], msg.event["actor_id"]) == ("automation", "auto-1")


def test_system_messages_cannot_be_edited_deleted_reacted_or_replied_to(
    team: Any, project: Any, task: Any
) -> None:
    _change(team, project, task, priority="high")
    (msg,) = _system(task)
    pid, mid = str(project.pk), str(msg.pk)
    for call in (
        lambda: services.edit(team.owner, team.ws, pid, mid, 1, say("x")),
        lambda: services.delete(team.owner, team.ws, pid, mid),
        lambda: services.react(team.owner, team.ws, pid, mid, "👍", True),
        lambda: services.create(
            team.owner, team.ws, pid, str(task.pk), say("x"), parent_id=mid
        ),
    ):
        with pytest.raises(ApiError):
            call()


def test_list_returns_both_kinds_and_hides_from_outsiders(
    team: Any, project: Any, task: Any
) -> None:
    services.create(team.member, team.ws, str(project.pk), str(task.pk), say("hi"))
    _change(team, project, task, priority="high")
    page = services.list_page(team.viewer, team.ws, str(project.pk), str(task.pk))
    assert sorted(c.kind for c in page.comments) == ["system", "user"]
    with pytest.raises(ApiError):
        services.list_page(team.outsider, team.ws, str(project.pk), str(task.pk))


def test_a_change_notifies_assignee_once_never_the_actor_or_duplicates(
    team: Any, project: Any, task: Any
) -> None:
    from infrastructure.inbox.models import Notification

    _change(team, project, task, assignee_ids=[str(team.member.pk)])
    set_actor(team.owner)
    _change(team, project, task, priority="low")
    _change(team, project, task, priority="high")  # coalesced: no second notice

    mine = Notification.objects.filter(user=team.member, type="task.changed")
    assert mine.count() == 1
    assert not Notification.objects.filter(user=team.owner, type="task.changed").exists()
    # assignment keeps its own kind and is not announced twice as task.changed
    assert Notification.objects.filter(user=team.member, type="task.assigned").count() == 1


def test_fields_outside_the_tracked_list_write_nothing(team: Any, project: Any, task: Any) -> None:
    """Only the listed fields speak in the chat, so a custom field (which may be hidden from the
    reader) and long text never leak into a message."""
    from infrastructure.comments.system_messages import FIELDS

    assert not any(name.startswith(("cf_", "custom")) for name in FIELDS)
    _change(team, project, task, description=say("Long text"))
    assert _system(task) == []


class _Broker:
    def __init__(self) -> None:
        self.sent: list[tuple[str, dict[str, Any]]] = []

    def publish(self, channel: str, payload: dict[str, Any]) -> None:
        self.sent.append((channel, payload))


def test_live_events_of_a_private_task_chat_stay_in_its_project_room(
    team: Any, monkeypatch: pytest.MonkeyPatch
) -> None:
    broker = _Broker()
    monkeypatch.setattr("infrastructure.sync.publish.get_broker", lambda: broker)
    secret = team.create(team.pm, "SEC", visibility="private", name="Secret")
    task = tasks.create(team.pm, team.ws, str(secret.pk), "hidden")
    broker.sent.clear()

    services.create(team.pm, team.ws, str(secret.pk), str(task.pk), say("hi"))
    _change(team, secret, task, who=team.pm, priority="high")

    rooms = {p["room"] for _, p in broker.sent}
    assert rooms == {f"proj:{secret.pk}"}
    assert not any(r.startswith("ws:") for r in rooms)
