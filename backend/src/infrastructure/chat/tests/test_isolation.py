"""A private group or DM is invisible to everyone outside it: every call, and the live events."""

from collections.abc import Callable
from typing import Any

import pytest

from infrastructure.chat import messages, services
from infrastructure.chat.tests.conftest import doc
from infrastructure.common.errors import ApiError
from infrastructure.sync import services as sync

pytestmark = pytest.mark.django_db
MISSING = "3c4bd4f0-0000-4000-8000-000000000000"


@pytest.fixture
def dm(team: Any) -> Any:
    return services.open_dm(team.member, team.ws, str(team.pm.pk))


def calls(team: Any, space: Any, said: Any) -> dict[str, Callable[[Any], Any]]:
    ws, sid, mid = team.ws, str(space.pk), str(said.pk)
    return {
        "get": lambda u: services.get(u, ws, sid),
        "join": lambda u: services.join(u, ws, sid),
        "leave": lambda u: services.leave(u, ws, sid),
        "update": lambda u: services.update_space(u, ws, sid, name="x"),
        "add": lambda u: services.add_members(u, ws, sid, [str(u.pk)]),
        "remove": lambda u: services.remove_member(u, ws, sid, str(team.member.pk)),
        "mark_read": lambda u: services.mark_read(u, ws, sid),
        "mute": lambda u: services.mute(u, ws, sid, forever=True),
        "notify": lambda u: services.set_notify(u, ws, sid, True),
        "mentionable": lambda u: services.mentionable(u, ws, sid),
        "list": lambda u: messages.list_page(u, ws, sid),
        "send": lambda u: messages.send(u, ws, sid, doc("hi")),
        "edit": lambda u: messages.edit(u, ws, sid, mid, 1, doc("x")),
        "delete": lambda u: messages.delete(u, ws, sid, mid),
        "react": lambda u: messages.react(u, ws, sid, mid, "👍", True),
    }


@pytest.mark.parametrize("which", ["group", "dm"])
def test_every_call_on_a_space_you_are_not_in_is_not_found(
    which: str, team: Any, group: Any, dm: Any
) -> None:
    space = {"group": group, "dm": dm}[which]
    author = team.member
    said = messages.send(author, team.ws, str(space.pk), doc("secret"))
    # the owner is in the group, so only the admin is outside it
    outsiders = [team.admin] if which == "group" else [team.admin, team.owner]

    for name, call in calls(team, space, said).items():
        for stranger in outsiders:
            with pytest.raises(ApiError) as refused:
                call(stranger)
            assert refused.value.status == 404, name


def test_a_member_of_another_workspace_gets_a_uniform_refusal(team: Any, group: Any) -> None:
    said = messages.send(team.member, team.ws, str(group.pk), doc("secret"))

    for name, call in calls(team, group, said).items():
        with pytest.raises(ApiError) as refused:
            call(team.outsider)
        assert refused.value.status == 403, name


def test_a_guest_is_refused_everything(team: Any, group: Any) -> None:
    said = messages.send(team.member, team.ws, str(group.pk), doc("secret"))

    for name, call in calls(team, group, said).items():
        with pytest.raises(ApiError) as refused:
            call(team.viewer)
        assert refused.value.status == 403, name


def test_a_space_id_from_another_workspace_is_not_found(team: Any, make_user: Any) -> None:
    from infrastructure.workspaces import services as workspaces

    other = workspaces.create(team.outsider, "Other 2", "other-2")
    foreign = services.ensure_general(other)

    with pytest.raises(ApiError) as refused:
        services.get(team.owner, team.ws, str(foreign.pk))
    assert refused.value.status == 404
    with pytest.raises(ApiError):
        messages.list_page(team.owner, team.ws, "not-a-uuid")


def test_a_private_project_channel_is_for_its_members(team: Any) -> None:
    project = team.create(team.owner, "SEC", visibility="private", name="Secure")

    assert "Secure" in [s.name for s in services.list_spaces(team.owner, team.ws).channels]
    assert "Secure" not in [s.name for s in services.list_spaces(team.member, team.ws).channels]
    from infrastructure.chat.models import ChatSpace

    channel = ChatSpace.objects.get(project=project)
    with pytest.raises(ApiError):
        messages.list_page(team.member, team.ws, str(channel.pk))


def events(broker: Any, kind: str = "") -> list[tuple[str, dict[str, Any]]]:
    return [
        (p["room"], p["event"])
        for _, p in broker.sent
        if p["event"]["type"].startswith("chat.") and (not kind or p["event"]["type"] == kind)
    ]


def test_live_events_of_a_group_reach_its_members_only(team: Any, group: Any, broker: Any) -> None:
    sent = messages.send(team.member, team.ws, str(group.pk), doc("hello"))
    messages.edit(team.member, team.ws, str(group.pk), str(sent.pk), 1, doc("hello 2"))
    messages.delete(team.member, team.ws, str(group.pk), str(sent.pk))

    rooms = {room for room, _ in events(broker)}
    types = [e["type"] for _, e in events(broker) if e["entity_id"] == str(group.pk)]

    assert rooms == {f"user:{u.pk}" for u in (team.owner, team.member, team.pm)}
    assert {"chat.message.created", "chat.message.updated", "chat.message.deleted"} <= set(types)


def test_a_dm_event_reaches_its_two_people(team: Any, dm: Any, broker: Any) -> None:
    messages.send(team.member, team.ws, str(dm.pk), doc("psst"))

    assert {room for room, _ in events(broker, "chat.message.created")} == {
        f"user:{team.member.pk}",
        f"user:{team.pm.pk}",
    }


def test_a_general_message_reaches_members_with_chat_not_guests(
    team: Any, general: Any, broker: Any
) -> None:
    messages.send(team.member, team.ws, str(general.pk), doc("hi"))

    rooms = {room for room, _ in events(broker, "chat.message.created")}

    assert rooms == {f"user:{u.pk}" for u in (team.owner, team.admin, team.member, team.pm)}


def test_a_read_mark_tells_only_the_readers_own_devices(team: Any, group: Any, broker: Any) -> None:
    from infrastructure.sync.actor import set_actor

    set_actor(team.pm)
    services.mark_read(team.pm, team.ws, str(group.pk))

    [(room, event)] = events(broker, "chat.read")
    assert room == f"user:{team.pm.pk}" and event["entity_id"] == str(group.pk)


def test_someone_removed_from_a_group_hears_of_it_once(team: Any, group: Any, broker: Any) -> None:
    services.remove_member(team.owner, team.ws, str(group.pk), str(team.pm.pk))

    updated = events(broker, "chat.space.updated")

    assert f"user:{team.pm.pk}" in {room for room, _ in updated}


def test_catching_up_leaves_out_chat_of_spaces_you_cannot_read(
    team: Any, group: Any, general: Any
) -> None:
    messages.send(team.member, team.ws, str(group.pk), doc("secret"))
    messages.send(team.member, team.ws, str(general.pk), doc("public"))

    def seen(user: Any) -> set[str]:
        page = sync.since(user, team.ws, 0)
        return {e.entity_id.hex for e in page.entries if e.entity_type == "chat"}

    assert seen(team.pm) == {group.pk.hex, general.pk.hex}
    assert seen(team.admin) == {general.pk.hex}
