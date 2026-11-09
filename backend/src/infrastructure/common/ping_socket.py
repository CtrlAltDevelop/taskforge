"""A credential-free WebSocket that answers one ``ping`` with ``pong``.

Phase 00 uses it to prove the WebSocket path (client -> proxy -> ASGI) works end
to end, the same way ``/health`` and ``HealthController`` prove REST and gRPC.
It carries no data and no identity, so it is mounted unconditionally -- which is
why each connection is a single round trip with an idle timeout: an anonymous
socket must not be able to hold a task open indefinitely.
"""

import asyncio
import json
from typing import Any, Final

IDLE_TIMEOUT_SECONDS: Final = 10
GOING_AWAY: Final = 1001


def _reply_to(event: dict[str, Any]) -> dict[str, str]:
    try:
        frame = json.loads(event.get("text") or "")
        if frame.get("type") == "ping":
            return {"type": "pong"}
        return {"type": "error", "detail": "unknown frame"}
    except (ValueError, AttributeError):
        return {"type": "error", "detail": "frames must be JSON objects"}


async def ping_socket(scope: dict[str, Any], receive: Any, send: Any) -> None:
    await receive()  # websocket.connect
    await send({"type": "websocket.accept"})
    try:
        event = await asyncio.wait_for(receive(), IDLE_TIMEOUT_SECONDS)
    except TimeoutError:
        await send({"type": "websocket.close", "code": GOING_AWAY})
        return
    if event["type"] == "websocket.disconnect":
        return
    await send({"type": "websocket.send", "text": json.dumps(_reply_to(event))})
    await send({"type": "websocket.close", "code": 1000})
