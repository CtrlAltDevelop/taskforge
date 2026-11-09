"""Who the WebSocket says you are (phase 01: identity on every transport).

The socket takes the same access token as REST and gRPC, and a bad token is an
error *frame*: the connection and the public feed stay up.
"""

import asyncio
from collections.abc import Coroutine
from typing import Any

import pytest

from apps.notifications.sockets import notifications_socket
from apps.notifications.tests.conftest import SocketClient, access_token

# The socket reads the database from another thread, so it needs real commits.
pytestmark = pytest.mark.django_db(transaction=True)


def _run(coroutine: Coroutine[Any, Any, Any]) -> Any:
    return asyncio.run(coroutine)


def test_whoami_names_the_account_a_token_authenticated_as(alice: Any) -> None:
    token = access_token(alice)

    async def scenario() -> dict[str, Any]:
        client = SocketClient(notifications_socket)
        await client.open()
        await client.next_frame()  # ready
        await client.command({"command": "authenticate", "token": token})
        frame = await client.command({"command": "whoami"})
        await client.close()
        return frame

    frame = _run(scenario())

    assert frame["type"] == "whoami"
    assert frame["user"]["username"] == "alice"


def test_a_bad_token_is_an_error_frame_and_the_connection_stays_open() -> None:
    async def scenario() -> tuple[dict[str, Any], dict[str, Any]]:
        client = SocketClient(notifications_socket)
        await client.open()
        await client.next_frame()  # ready
        refused = await client.command({"command": "authenticate", "token": "not-a-token"})
        still_open = await client.command({"command": "ping"})
        await client.close()
        return refused, still_open

    refused, still_open = _run(scenario())

    assert refused["type"] == "error"
    assert still_open["type"] != "error"
