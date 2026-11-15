"""The sync socket, driven frame by frame against a real database (the consumer reaches the ORM
from another thread, and events are published once a change has really committed)."""

import asyncio
from collections.abc import Iterator
from typing import Any

import pytest
from asgiref.sync import sync_to_async

from apps.notifications.broadcast import reset_broker
from apps.notifications.tests.conftest import SocketClient, access_token
from infrastructure.sync import presence, sockets
from infrastructure.sync.sockets import sync_socket
from infrastructure.tasks import services as tasks
from infrastructure.workspaces import members

pytestmark = pytest.mark.django_db(transaction=True)


@pytest.fixture(autouse=True)
def _fresh() -> Iterator[None]:
    reset_broker()
    presence.reset_store()
    yield
    reset_broker()
    presence.reset_store()


def run(scenario: Any) -> Any:
    return asyncio.run(asyncio.wait_for(scenario, timeout=30))


async def connect(user: Any) -> SocketClient:
    client = SocketClient(sync_socket, path="/ws/sync")
    assert (await client.open())["type"] == "websocket.accept"
    token = await sync_to_async(access_token)(user)
    ready = await client.command({"type": "authenticate", "token": token})
    assert ready["type"] == "ready" and ready["user"]["id"] == str(user.pk)
    return client


async def nothing_more(client: SocketClient, wait: float = 0.3) -> None:
    with pytest.raises(TimeoutError):
        await client.next_frame(timeout=wait)


async def subscribe(client: SocketClient, room: str) -> dict[str, Any]:
    return await client.command({"type": "subscribe", "room": room})


async def make_task(team: Any, project: Any, title: str = "T", who: Any = None) -> Any:
    return await sync_to_async(tasks.create)(who or team.owner, team.ws, str(project.pk), title)


# -- authentication -----------------------------------------------------------------------------


def test_the_first_frame_has_to_authenticate(team: Any) -> None:
    async def scenario() -> tuple[dict[str, Any], dict[str, Any]]:
        client = SocketClient(sync_socket, path="/ws/sync")
        await client.open()
        await client.send({"type": "subscribe", "room": f"ws:{team.ws.pk}"})
        error = await client.next_frame()
        closing = await client.next_message()
        return error, closing

    error, closing = run(scenario())

    assert error == {"type": "error", "code": "unauthenticated"}
    assert closing == {"type": "websocket.close", "code": sockets.UNAUTHENTICATED}


def test_a_bad_token_is_refused_and_the_socket_closed(team: Any) -> None:
    async def scenario() -> tuple[dict[str, Any], dict[str, Any]]:
        client = SocketClient(sync_socket, path="/ws/sync")
        await client.open()
        await client.send({"type": "authenticate", "token": "not-a-token"})
        return await client.next_frame(), await client.next_message()

    error, closing = run(scenario())

    assert error["code"] == "unauthenticated" and closing["code"] == sockets.UNAUTHENTICATED


def test_silence_is_closed_after_the_deadline(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setattr(sockets, "AUTH_SECONDS", 0.1)

    async def scenario() -> dict[str, Any]:
        client = SocketClient(sync_socket, path="/ws/sync")
        await client.open()
        return await client.next_message()

    assert run(scenario())["code"] == sockets.UNAUTHENTICATED


def test_the_socket_is_mounted_beside_the_others() -> None:
    from config.sockets import websocket_routes

    assert ("/ws/sync", "infrastructure.sync.sockets.sync_socket") in websocket_routes()


# -- rooms and delivery -------------------------------------------------------------------------


def test_a_member_joins_the_workspace_and_project_rooms(team: Any, project: Any) -> None:
    async def scenario() -> list[dict[str, Any]]:
        client = await connect(team.viewer)
        got = [
            await subscribe(client, f"ws:{team.ws.pk}"),
            await subscribe(client, f"proj:{project.pk}"),
        ]
        await client.close()
        return got

    assert [f["type"] for f in run(scenario())] == ["subscribed", "subscribed"]


def test_a_refusal_is_one_uniform_error_for_every_reason(team: Any, project: Any) -> None:
    secret = team.create(team.pm, "SEC", visibility="private", name="Secret")
    missing = "proj:00000000-0000-0000-0000-000000000000"

    async def scenario() -> list[dict[str, Any]]:
        client = await connect(team.member)
        got = [
            await subscribe(client, f"proj:{secret.pk}"),  # private, not a member
            await subscribe(client, missing),  # does not exist
            await subscribe(client, f"user:{team.owner.pk}"),  # someone else's
        ]
        await client.close()
        return got

    errors = run(scenario())

    assert {e["code"] for e in errors} == {"forbidden"}
    assert all(set(e) == {"type", "code", "room"} for e in errors)  # no reason given


def test_an_outsider_cannot_join_a_workspace(team: Any) -> None:
    async def scenario() -> dict[str, Any]:
        client = await connect(team.outsider)
        got = await subscribe(client, f"ws:{team.ws.pk}")
        await client.close()
        return got

    assert run(scenario())["code"] == "forbidden"


def test_a_change_reaches_a_subscribed_client_in_well_under_a_second(
    team: Any, project: Any
) -> None:
    async def scenario() -> tuple[dict[str, Any], float, Any]:
        client = await connect(team.viewer)
        await subscribe(client, f"proj:{project.pk}")
        started = asyncio.get_running_loop().time()
        task = await make_task(team, project)
        frame = await client.next_frame(timeout=2)
        elapsed = asyncio.get_running_loop().time() - started
        await client.close()
        return frame, elapsed, task

    frame, elapsed, task = run(scenario())

    assert frame["type"] == "event" and frame["room"] == f"proj:{project.pk}"
    assert frame["event"]["type"] == "task.created" and frame["event"]["entity_id"] == str(task.pk)
    assert frame["event"]["version"] == 1 and isinstance(frame["event"]["cursor"], int)
    assert elapsed < 0.5


def test_a_change_announced_to_two_rooms_is_delivered_once(team: Any, project: Any) -> None:
    async def scenario() -> dict[str, Any]:
        client = await connect(team.viewer)
        await subscribe(client, f"proj:{project.pk}")
        await subscribe(client, f"ws:{team.ws.pk}")
        await make_task(team, project)
        first = await client.next_frame()
        await nothing_more(client)
        await client.close()
        return first

    assert run(scenario())["event"]["type"] == "task.created"


def test_a_private_projects_events_never_reach_a_non_member(team: Any) -> None:
    secret = team.create(team.pm, "SEC", visibility="private", name="Secret")

    async def scenario() -> None:
        client = await connect(team.member)
        await subscribe(client, f"ws:{team.ws.pk}")
        await make_task(team, secret, "hidden", who=team.pm)
        await nothing_more(client)
        await client.close()

    run(scenario())


def test_a_private_projects_events_reach_its_members(team: Any) -> None:
    secret = team.create(team.pm, "SEC", visibility="private", name="Secret")

    async def scenario() -> dict[str, Any]:
        client = await connect(team.pm)
        await subscribe(client, f"proj:{secret.pk}")
        await make_task(team, secret, "mine", who=team.pm)
        frame = await client.next_frame()
        await client.close()
        return frame

    assert run(scenario())["event"]["project"] == str(secret.pk)


def test_an_unsubscribed_room_goes_quiet(team: Any, project: Any) -> None:
    async def scenario() -> dict[str, Any]:
        client = await connect(team.viewer)
        await subscribe(client, f"proj:{project.pk}")
        gone = await client.command({"type": "unsubscribe", "room": f"proj:{project.pk}"})
        await make_task(team, project)
        await nothing_more(client)
        await client.close()
        return gone

    assert run(scenario()) == {
        "type": "unsubscribed",
        "room": f"proj:{project.pk}",
        "reason": "requested",
    }


def test_removed_from_the_workspace_a_connection_loses_its_rooms_at_once(
    team: Any, project: Any
) -> None:
    async def scenario() -> list[dict[str, Any]]:
        client = await connect(team.member)
        await subscribe(client, f"ws:{team.ws.pk}")
        await subscribe(client, f"proj:{project.pk}")
        await sync_to_async(members.remove)(team.ws, team.owner, str(team.member.pk))
        frames = [await client.next_frame(), await client.next_frame(), await client.next_frame()]
        await make_task(team, project, "after")
        await nothing_more(client)
        await client.close()
        return frames

    frames = run(scenario())

    dropped = {f["room"] for f in frames if f["type"] == "unsubscribed"}
    assert dropped == {f"ws:{team.ws.pk}", f"proj:{project.pk}"}
    assert all(f["reason"] == "access" for f in frames if f["type"] == "unsubscribed")
    assert [f["event"]["type"] for f in frames if f["type"] == "event"] == ["access.changed"]


def test_losing_a_private_project_drops_that_room_only(team: Any, project: Any) -> None:
    from infrastructure.projects import members as project_members

    secret = team.create(team.pm, "SEC", visibility="private", name="Secret")
    project_members.add_member(team.pm, team.ws, str(secret.pk), str(team.member.pk))

    async def scenario() -> list[dict[str, Any]]:
        client = await connect(team.member)
        await subscribe(client, f"proj:{secret.pk}")
        await subscribe(client, f"proj:{project.pk}")
        await sync_to_async(project_members.remove_member)(
            team.pm, team.ws, str(secret.pk), str(team.member.pk)
        )

        async def next_non_chat() -> dict[str, Any]:
            while True:  # the channel of the private project also tells the person (chat.*)
                frame = await client.next_frame()
                if not str(frame.get("event", {}).get("type", "")).startswith("chat."):
                    return frame

        frames = [await next_non_chat(), await next_non_chat()]
        await make_task(team, project, "still open")
        frames.append(await next_non_chat())
        await client.close()
        return frames

    frames = run(scenario())

    assert frames[0]["room"] == f"proj:{secret.pk}" and frames[0]["reason"] == "access"
    assert frames[1]["event"]["type"] == "access.changed"
    assert frames[2]["event"]["type"] == "task.created"


# -- the rest of the protocol -------------------------------------------------------------------


def test_ping_pong_and_refusals_that_keep_the_connection(team: Any) -> None:
    async def scenario() -> list[dict[str, Any]]:
        client = await connect(team.viewer)
        got = [await client.command({"type": "ping"}), await client.command({"type": "dance"})]
        await client.send_text("not json")
        got.append(await client.next_frame())
        await client.send_text("x" * (sockets.MAX_FRAME_BYTES + 1))
        got.append(await client.next_frame())
        got.append(await client.command({"type": "subscribe", "room": "nonsense"}))
        got.append(await client.command({"type": "ping"}))
        await client.close()
        return got

    got = run(scenario())

    assert [f["type"] if f["type"] != "error" else f["code"] for f in got] == [
        "pong", "unknown_command", "bad_request", "bad_request", "bad_request", "pong",
    ]  # fmt: skip


def test_a_connection_may_only_hold_so_many_rooms(
    team: Any, project: Any, monkeypatch: Any
) -> None:
    monkeypatch.setattr(sockets, "MAX_ROOMS", 2)  # its own user room counts

    async def scenario() -> list[str]:
        client = await connect(team.viewer)
        got = [
            (await subscribe(client, f"ws:{team.ws.pk}")).get("type", ""),
            (await subscribe(client, f"proj:{project.pk}")).get("code", ""),
        ]
        await client.close()
        return got

    assert run(scenario()) == ["subscribed", "too_many_rooms"]


# -- presence -----------------------------------------------------------------------------------


def test_people_on_a_task_see_each_other_and_the_editing_hint(team: Any, project: Any) -> None:
    async def scenario() -> list[dict[str, Any]]:
        task = await make_task(team, project)
        a, b = await connect(team.member), await connect(team.viewer)
        for client in (a, b):
            await subscribe(client, f"proj:{project.pk}")
        here = {"task": str(task.pk), "project": str(project.pk)}
        await a.send({"type": "presence", "state": "viewing", **here})
        got = [await a.next_frame(), await b.next_frame()]
        await b.send({"type": "presence", "state": "editing", **here})
        got += [await a.next_frame(), await b.next_frame()]
        await b.send({"type": "presence", "state": "viewing", **here})
        await b.send({"type": "presence", "state": "viewing", **here})  # a heartbeat: no frame
        got.append(await a.next_frame())
        await nothing_more(a)
        await a.close()
        await b.close()
        return got

    got = run(scenario())

    names = {str(team.member.pk): "member", str(team.viewer.pk): "viewer"}
    rosters = [[(names[u["id"]], u["editing"]) for u in f["users"]] for f in got]
    assert all(f["type"] == "presence" for f in got)
    assert rosters[0] == rosters[1] == [("member", False)]
    both = [("member", False), ("viewer", True)]
    assert {tuple(sorted(r)) for r in rosters[2:4]} == {tuple(sorted(both))}
    assert sorted(rosters[4]) == [("member", False), ("viewer", False)]


def test_closing_the_socket_leaves_the_task(team: Any, project: Any) -> None:
    async def scenario() -> dict[str, Any]:
        task = await make_task(team, project)
        a, b = await connect(team.member), await connect(team.viewer)
        for client in (a, b):
            await subscribe(client, f"proj:{project.pk}")
        await a.send(
            {
                "type": "presence",
                "state": "viewing",
                "task": str(task.pk),
                "project": str(project.pk),
            }
        )
        await a.next_frame()
        await b.next_frame()
        await a.close()
        left = await b.next_frame()
        await b.close()
        return left

    assert run(scenario())["users"] == []


def test_presence_needs_a_joined_room_and_a_task_of_that_project(team: Any, project: Any) -> None:
    other = team.create(team.owner, "OTH", name="Other")

    async def scenario() -> list[str]:
        task = await make_task(team, project)
        foreign = await make_task(team, other)
        client = await connect(team.member)
        got = []
        # not subscribed to the room
        await client.send(
            {
                "type": "presence",
                "state": "viewing",
                "task": str(task.pk),
                "project": str(project.pk),
            }
        )
        got.append((await client.next_frame())["code"])
        await subscribe(client, f"proj:{project.pk}")
        # a task of another project
        await client.send(
            {
                "type": "presence",
                "state": "viewing",
                "task": str(foreign.pk),
                "project": str(project.pk),
            }
        )
        got.append((await client.next_frame())["code"])
        # a state that is not one
        await client.send(
            {
                "type": "presence",
                "state": "dancing",
                "task": str(task.pk),
                "project": str(project.pk),
            }
        )
        got.append((await client.next_frame())["code"])
        await client.close()
        return got

    assert run(scenario()) == ["bad_request"] * 3


# -- delivery-time checks ----------------------------------------------------------------------


def test_access_revoked_behind_the_sockets_back_still_stops_private_events(
    team: Any, monkeypatch: pytest.MonkeyPatch
) -> None:
    from infrastructure.projects import members as project_members
    from infrastructure.projects.models import ProjectMember

    monkeypatch.setattr(sockets, "ROOM_FRESH_SECONDS", 0)  # check at every delivery
    secret = team.create(team.pm, "SEC", visibility="private", name="Secret")
    project_members.add_member(team.pm, team.ws, str(secret.pk), str(team.member.pk))

    async def scenario() -> list[dict[str, Any]]:
        client = await connect(team.member)
        await subscribe(client, f"proj:{secret.pk}")
        # removed in the database, with no hint sent (a migration, an admin edit)
        await sync_to_async(ProjectMember.objects.filter(project=secret, user=team.member).delete)()
        await make_task(team, secret, "hidden", who=team.pm)
        dropped = await client.next_frame()
        await nothing_more(client)
        await client.close()
        return [dropped]

    [dropped] = run(scenario())

    assert dropped == {"type": "unsubscribed", "room": f"proj:{secret.pk}", "reason": "access"}


def test_presence_is_checked_like_events(
    team: Any, project: Any, monkeypatch: pytest.MonkeyPatch
) -> None:
    from infrastructure.workspaces.models import MemberStatus, WorkspaceMember

    monkeypatch.setattr(sockets, "ROOM_FRESH_SECONDS", 0)

    async def scenario() -> list[dict[str, Any]]:
        task = await make_task(team, project)
        a, b = await connect(team.member), await connect(team.viewer)
        for client in (a, b):
            await subscribe(client, f"proj:{project.pk}")
        await sync_to_async(WorkspaceMember.objects.filter(user=team.viewer).update)(
            status=MemberStatus.REMOVED
        )
        here = {"task": str(task.pk), "project": str(project.pk)}
        await a.send({"type": "presence", "state": "viewing", **here})
        await a.next_frame()
        got = [await b.next_frame()]
        await nothing_more(b)
        await a.close()
        await b.close()
        return got

    [frame] = run(scenario())

    assert frame["type"] == "unsubscribed" and frame["reason"] == "access"


# -- origin, two tabs, rosters -------------------------------------------------------------------


def test_ready_tells_a_client_its_own_origin_tag(team: Any) -> None:
    from infrastructure.sync.actor import origin_tag

    async def scenario() -> dict[str, Any]:
        client = SocketClient(sync_socket, path="/ws/sync")
        await client.open()
        token = await sync_to_async(access_token)(team.member)
        ready = await client.command(
            {"type": "authenticate", "token": token, "client_id": "phone-1"}
        )
        await client.close()
        return ready

    assert run(scenario())["origin"] == origin_tag(str(team.member.pk), "phone-1")


def test_a_heartbeat_gets_the_roster_back_and_so_does_arriving(team: Any, project: Any) -> None:
    async def scenario() -> list[dict[str, Any]]:
        task = await make_task(team, project)
        a, b = await connect(team.member), await connect(team.viewer)
        for client in (a, b):
            await subscribe(client, f"proj:{project.pk}")
        here = {"task": str(task.pk), "project": str(project.pk), "state": "viewing"}
        await a.send({"type": "presence", **here})
        await a.next_frame()
        await b.next_frame()
        # b was told of a by the broadcast; a heartbeat from a changes nothing for anyone but
        # still returns the roster to a
        await a.send({"type": "presence", **here})
        got = [await a.next_frame()]
        await nothing_more(b)
        await a.close()
        await b.close()
        return got

    [frame] = run(scenario())

    assert frame["type"] == "presence" and [u["id"] for u in frame["users"]] == [
        str(team.member.pk)
    ]


def test_a_person_with_two_tabs_is_still_there_when_one_closes(team: Any, project: Any) -> None:
    async def scenario() -> list[dict[str, Any]]:
        task = await make_task(team, project)
        tab1, tab2, watcher = (
            await connect(team.member),
            await connect(team.member),
            await connect(team.viewer),
        )
        for client in (tab1, tab2, watcher):
            await subscribe(client, f"proj:{project.pk}")
        here = {"task": str(task.pk), "project": str(project.pk), "state": "viewing"}
        await tab1.send({"type": "presence", **here})
        await watcher.next_frame()
        await tab2.send({"type": "presence", **here})
        await tab2.next_frame()  # what tab 1 announced
        await tab2.next_frame()  # its own roster: its command has been processed
        await tab1.close()
        await nothing_more(watcher)  # still there: the second tab is
        await tab2.send({"type": "presence", **{**here, "state": "left"}})
        gone = await watcher.next_frame()
        await tab2.close()
        await watcher.close()
        return [gone]

    [gone] = run(scenario())

    assert gone["users"] == []
