"""The reusable workspace-scoped socket guard, driven by a tiny test-only handler.

Phase 16 mounts the real workspace socket; this proves what it will lean on.
"""

import asyncio
import json
from typing import Any

import pytest
from asgiref.testing import ApplicationCommunicator

from infrastructure.common.errors import ApiError
from infrastructure.workspaces import services
from infrastructure.workspaces.sockets import (
    FORBIDDEN_CLOSE_CODE,
    error_frame,
    socket_require,
    socket_workspace,
)

pytestmark = pytest.mark.django_db(transaction=True)


def _handler(user: Any) -> Any:
    """One frame ``{workspace_id, permission}`` in; ``ok`` or the error frame out."""

    async def application(scope: dict[str, Any], receive: Any, send: Any) -> None:
        await receive()
        await send({"type": "websocket.accept"})
        frame = json.loads((await receive())["text"])
        try:
            if frame.get("permission"):
                await socket_require(user, frame["permission"], frame["workspace_id"])
            else:
                await socket_workspace(user, frame["workspace_id"])
            reply = {"type": "ok"}
        except ApiError as refusal:
            reply = error_frame(refusal)
        await send({"type": "websocket.send", "text": json.dumps(reply)})
        if reply["type"] == "error" and reply["code"] == "forbidden":
            await send({"type": "websocket.close", "code": FORBIDDEN_CLOSE_CODE})

    return application


async def _ask(user: Any, workspace_id: str, permission: str | None) -> list[dict[str, Any]]:
    communicator = ApplicationCommunicator(_handler(user), {"type": "websocket"})
    await communicator.send_input({"type": "websocket.connect"})
    await communicator.receive_output()  # accept
    frame = {"workspace_id": workspace_id, "permission": permission}
    await communicator.send_input({"type": "websocket.receive", "text": json.dumps(frame)})
    out = [await communicator.receive_output()]
    if json.loads(out[0]["text"]).get("code") == "forbidden":
        out.append(await communicator.receive_output())
    return out


def ask(user: Any, workspace_id: str, permission: str | None = None) -> list[dict[str, Any]]:
    return asyncio.run(_ask(user, workspace_id, permission))


def _frame(out: list[dict[str, Any]]) -> dict[str, Any]:
    return json.loads(out[0]["text"])


def test_member_with_the_permission_gets_ok(alice: Any) -> None:
    workspace = services.create(alice, "Acme", "acme")

    assert _frame(ask(alice, str(workspace.id), "member.invite")) == {"type": "ok"}
    assert _frame(ask(alice, str(workspace.id))) == {"type": "ok"}


def test_member_lacking_the_permission_gets_the_reason_and_stays_connected(
    alice: Any, make_user: Any, add_member: Any
) -> None:
    workspace = services.create(alice, "Acme", "acme")
    viewer = make_user("vic")
    add_member(workspace, viewer, "Viewer")

    out = ask(viewer, str(workspace.id), "member.invite")

    assert _frame(out) == {
        "type": "error",
        "code": "permission_denied",
        "permission": "member.invite",
        "role": "Viewer",
        "hint": "missing: member.invite; your role: Viewer",
    }
    assert len(out) == 1  # no close frame: the socket stays usable


def test_non_members_and_unknown_ids_get_one_reasonless_forbidden_and_a_close(
    alice: Any, bob: Any
) -> None:
    workspace = services.create(alice, "Acme", "acme")

    for target in (str(workspace.id), "not-a-uuid", "00000000-0000-0000-0000-000000000000"):
        out = ask(bob, target, "member.invite")
        assert _frame(out) == {"type": "error", "code": "forbidden"}
        assert out[1] == {"type": "websocket.close", "code": FORBIDDEN_CLOSE_CODE}


def test_the_guard_is_awaitable_from_a_running_loop(alice: Any) -> None:
    workspace = services.create(alice, "Acme", "acme")

    async def run() -> Any:
        return await socket_workspace(alice, str(workspace.id))

    assert asyncio.run(run()) == workspace
