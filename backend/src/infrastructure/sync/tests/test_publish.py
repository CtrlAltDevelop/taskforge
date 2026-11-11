"""A committed change becomes a change-log row and an event in the right rooms."""

from typing import Any

import pytest

from infrastructure.sync import actor, publish
from infrastructure.sync.models import ChangeLog
from infrastructure.tasks import services as tasks

pytestmark = pytest.mark.django_db


def _make(team: Any, project: Any, title: str = "T") -> Any:
    return tasks.create(team.owner, team.ws, str(project.pk), title)


def test_a_new_task_is_logged_and_announced_to_its_project_and_workspace(
    team: Any, project: Any, broker: Any
) -> None:
    task = _make(team, project)

    [row] = ChangeLog.objects.filter(entity_type="task")
    assert (str(row.entity_id), row.version, row.action) == (str(task.pk), 1, "created")
    assert str(row.project) == str(project.pk) and row.workspace_id == team.ws.pk
    assert broker.rooms() == [f"proj:{project.pk}", f"ws:{team.ws.pk}"]
    event = broker.events()[0]
    assert event["type"] == "task.created" and event["cursor"] == row.pk
    assert event["entity_id"] == str(task.pk) and event["version"] == 1


def test_events_carry_ids_and_a_version_and_nothing_else(
    team: Any, project: Any, broker: Any
) -> None:
    _make(team, project, "Secret plan")

    assert set(broker.events()[0]) == {
        "type", "workspace", "project", "entity_id", "version", "actor", "origin", "ts", "cursor",
    }  # fmt: skip


def test_a_private_projects_events_stay_in_its_own_room(team: Any, broker: Any) -> None:
    secret = team.create(team.pm, "SEC", visibility="private", name="Secret")

    tasks.create(team.pm, team.ws, str(secret.pk), "hidden")

    task_rooms = [r for r in broker.rooms() if r.startswith("ws:")]
    assert task_rooms == [] and f"proj:{secret.pk}" in broker.rooms()


@pytest.mark.parametrize(
    ("action", "wanted"),
    [("created", "task.created"), ("deleted", "task.deleted"), ("linked", "task.updated"),
     ("restored", "task.updated"), ("reparented", "task.updated")],
)  # fmt: skip
def test_every_other_task_action_is_an_update(action: str, wanted: str) -> None:
    from infrastructure.sync.models import event_type

    assert event_type("task", action) == wanted


def test_project_workflow_and_field_changes_have_their_own_types() -> None:
    from infrastructure.sync.models import event_type

    assert event_type("project", "created") == "project.created"
    assert event_type("project", "archived") == "project.updated"
    assert event_type("workflow", "updated") == "workflow.updated"
    assert event_type("fields", "updated") == "fields.updated"
    assert event_type("access", "changed") == "access.changed"


def test_the_actor_is_whoever_the_request_was_for(team: Any, project: Any, broker: Any) -> None:
    actor.set_actor(team.member)
    try:
        _make(team, project)
    finally:
        actor.set_actor(None)

    assert broker.events()[0]["actor"] == str(team.member.pk)
    _make(team, project)
    assert broker.events()[-1]["actor"] == ""


def test_cursors_only_grow(team: Any, project: Any, broker: Any) -> None:
    _make(team, project)
    _make(team, project)

    cursors = [e["cursor"] for e in broker.events() if e["type"] == "task.created"]
    assert cursors == sorted(cursors) and len(set(cursors)) == 2


def test_a_project_change_is_announced_to_the_workspace_when_the_project_is_open(
    team: Any, project: Any, broker: Any
) -> None:
    broker.sent.clear()
    publish.record(
        entity_type="project", entity_id=project.pk, workspace_id=team.ws.pk,
        project_id=project.pk, version=3, action="archived",
    )  # fmt: skip

    assert broker.events()[0]["type"] == "project.updated"
    assert broker.rooms() == [f"proj:{project.pk}", f"ws:{team.ws.pk}"]


def test_an_access_change_goes_to_the_person_it_names(team: Any, broker: Any) -> None:
    publish.record(
        entity_type="access", entity_id=team.member.pk, workspace_id=team.ws.pk,
        action="changed", user_id=str(team.member.pk),
    )  # fmt: skip

    assert broker.rooms() == [f"user:{team.member.pk}"]


def test_an_access_change_for_everyone_goes_to_the_workspace(team: Any, broker: Any) -> None:
    publish.record(
        entity_type="access", entity_id=team.ws.pk, workspace_id=team.ws.pk, action="changed"
    )

    assert broker.rooms() == [f"ws:{team.ws.pk}"]


@pytest.mark.django_db(transaction=True)
def test_a_clients_own_id_travels_with_its_writes_through_the_grpc_caller(
    team: Any, project: Any, broker: Any, monkeypatch: pytest.MonkeyPatch
) -> None:
    import asyncio
    from types import SimpleNamespace

    from asgiref.sync import sync_to_async

    from infrastructure.common import identity

    monkeypatch.setattr(identity, "caller", lambda request: team.member)

    async def scenario() -> None:
        context = SimpleNamespace(http_request=SimpleNamespace(META={"x-client-id": "phone-1"}))
        assert await identity.grpc_caller(context) == team.member
        await sync_to_async(_make)(team, project)

    asyncio.run(scenario())

    event = broker.events()[0]
    from infrastructure.sync.actor import origin_tag

    assert event["origin"] == origin_tag(str(team.member.pk), "phone-1")
    assert event["actor"] == str(team.member.pk)


def test_a_broker_that_fails_does_not_fail_the_change_or_the_other_hooks(
    team: Any, project: Any, monkeypatch: pytest.MonkeyPatch
) -> None:
    class Down:
        def publish(self, channel: str, payload: Any) -> None:
            raise ConnectionError("redis is away")

    monkeypatch.setattr("infrastructure.sync.publish.get_broker", lambda: Down())

    task = _make(team, project)  # no exception reaches the caller

    assert ChangeLog.objects.filter(
        entity_id=task.pk, entity_type="task"
    ).exists()  # catch-up has it


def test_the_origin_is_a_tag_only_its_owner_can_reproduce() -> None:
    from infrastructure.sync.actor import origin_tag

    mine = origin_tag("user-1", "client-a")

    assert mine == origin_tag("user-1", "client-a")
    assert mine != origin_tag("user-2", "client-a")  # someone copying the header gets another tag
    assert mine != origin_tag("user-1", "client-b")
    assert "client-a" not in mine and origin_tag("user-1", "") == ""


def test_an_event_carries_the_tag_not_the_clients_own_id(
    team: Any, project: Any, broker: Any
) -> None:
    from infrastructure.sync.actor import origin_tag

    actor.set_actor(team.member, "phone-1")
    try:
        _make(team, project)
    finally:
        actor.set_actor(None, "")

    assert broker.events()[0]["origin"] == origin_tag(str(team.member.pk), "phone-1")


def test_a_comment_is_announced_as_a_change_to_its_tasks_comments(
    team: Any, project: Any, broker: Any
) -> None:
    from infrastructure.comments import services as comments
    from infrastructure.comments.tests.conftest import say

    task = _make(team, project)
    broker.sent.clear()

    made = comments.create(team.member, team.ws, str(project.pk), str(task.pk), say("hi"))
    comments.react(team.member, team.ws, str(project.pk), str(made.pk), "👍", True)
    comments.delete(team.member, team.ws, str(project.pk), str(made.pk))

    types = [
        (e["type"], e["entity_id"])
        for e in {e["cursor"]: e for e in broker.events()}.values()
        if e["type"].startswith("comment.")  # (the watchers' notifications are the inbox's own)
    ]
    assert types == [
        ("comment.created", str(task.pk)),
        ("comment.updated", str(task.pk)),
        ("comment.deleted", str(task.pk)),
    ]
    assert f"proj:{project.pk}" in broker.rooms()


def test_an_attachment_is_announced_as_a_change_to_its_tasks_files(
    team: Any, project: Any, broker: Any, tmp_path: Any, settings: Any
) -> None:
    from infrastructure.attachments import services as attachments

    settings.MEDIA_ROOT = str(tmp_path)
    settings.ATTACHMENT_MAX_BYTES = 1024
    settings.ATTACHMENT_WORKSPACE_QUOTA_BYTES = 0
    task = _make(team, project)
    broker.sent.clear()

    session = attachments.start_upload(
        team.member, team.ws, str(project.pk), str(task.pk), "a.txt", 5
    )
    attachments.put_chunk(team.member, str(session.pk), 0, b"hello")
    made = attachments.complete(team.member, str(session.pk))
    attachments.delete(team.member, team.ws, str(project.pk), str(made.pk))

    types = [
        (e["type"], e["entity_id"]) for e in {e["cursor"]: e for e in broker.events()}.values()
    ]
    assert types == [
        ("attachment.added", str(task.pk)),
        ("attachment.deleted", str(task.pk)),
    ]
    assert f"proj:{project.pk}" in broker.rooms()
