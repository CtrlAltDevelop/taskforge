"""The WebSocket half of phase 00's three pings: send ``ping``, get ``pong``."""

import asyncio
import json
from typing import Any

from asgiref.testing import ApplicationCommunicator

from config.sockets import websocket_application


async def _connect(
    path: str, headers: list[tuple[bytes, bytes]] | None = None
) -> ApplicationCommunicator:
    scope = {"type": "websocket", "path": path, "headers": headers or [], "subprotocols": []}
    communicator = ApplicationCommunicator(websocket_application, scope)
    await communicator.send_input({"type": "websocket.connect"})
    return communicator


async def _send(communicator: ApplicationCommunicator, payload: dict[str, Any]) -> None:
    await communicator.send_input({"type": "websocket.receive", "text": json.dumps(payload)})


async def _answers_pong() -> None:
    communicator = await _connect("/ws/ping/")
    assert (await communicator.receive_output())["type"] == "websocket.accept"

    await _send(communicator, {"type": "ping"})
    reply = await communicator.receive_output()

    assert json.loads(reply["text"]) == {"type": "pong"}
    # One round trip per connection: the server hangs up after answering.
    assert (await communicator.receive_output())["type"] == "websocket.close"


async def _reports_bad_frames_then_closes() -> None:
    communicator = await _connect("/ws/ping/")
    await communicator.receive_output()

    await communicator.send_input({"type": "websocket.receive", "text": "not json"})
    reply = json.loads((await communicator.receive_output())["text"])

    assert reply["type"] == "error"
    assert (await communicator.receive_output())["type"] == "websocket.close"


def test_ping_socket_answers_pong_without_any_credential() -> None:
    asyncio.run(_answers_pong())


def test_ping_socket_reports_bad_frames_then_closes() -> None:
    asyncio.run(_reports_bad_frames_then_closes())


async def _handshake_code(origin: bytes) -> dict[str, Any]:
    communicator = await _connect("/ws/ping/", [(b"origin", origin)])
    return await communicator.receive_output()


def test_ping_socket_refuses_a_foreign_browser_origin() -> None:
    output = asyncio.run(_handshake_code(b"https://evil.example"))

    assert output == {"type": "websocket.close", "code": 4403}


def test_ping_socket_accepts_a_localhost_origin(settings: Any) -> None:
    # The origin check follows ALLOWED_HOSTS when nothing names origins; CI sets neither.
    settings.WEBSOCKET_ALLOWED_ORIGINS = []
    settings.ALLOWED_HOSTS = ["localhost"]
    output = asyncio.run(_handshake_code(b"http://localhost"))

    assert output["type"] == "websocket.accept"
