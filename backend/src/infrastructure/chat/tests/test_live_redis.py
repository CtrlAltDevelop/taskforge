"""Send in a chat, receive on another person's live subscription, through the Redis broker.

The server is fakeredis, so this covers the real publish and subscribe code paths without a
Redis process; the people are separate subscribers to their own user rooms, as sockets are.
"""

import asyncio
import threading
from concurrent.futures import ThreadPoolExecutor
from typing import Any

import fakeredis
import pytest

from apps.notifications.broadcast import RedisBroker
from infrastructure.chat import messages
from infrastructure.chat.tests.conftest import doc
from infrastructure.sync.publish import channel_of

pytestmark = pytest.mark.django_db
SETTLE = 0.3  # a reader joins its channel on its first pass (see the broker's own tests)


async def _next(subscription: Any, wait: float) -> dict[str, Any] | None:
    try:
        return await asyncio.wait_for(subscription.get(), timeout=wait)
    except TimeoutError:
        return None


def test_a_group_message_reaches_a_second_member_and_not_an_outsider(
    team: Any, group: Any, monkeypatch: pytest.MonkeyPatch
) -> None:
    server = fakeredis.FakeServer()
    broker = RedisBroker(
        client=fakeredis.FakeStrictRedis(server=server),
        async_client=fakeredis.aioredis.FakeRedis(server=server),
    )
    monkeypatch.setattr("infrastructure.sync.publish.get_broker", lambda: broker)
    member_room = channel_of(f"user:{team.pm.pk}")
    outsider_room = channel_of(f"user:{team.viewer.pk}")
    ready = threading.Event()

    async def listen() -> tuple[dict[str, Any] | None, dict[str, Any] | None]:
        member, outsider = broker.subscribe(), broker.subscribe()
        await member.add(member_room)
        await outsider.add(outsider_room)
        got = asyncio.ensure_future(_next(member, 8))
        missed = asyncio.ensure_future(_next(outsider, 2))
        await asyncio.sleep(SETTLE)
        ready.set()
        try:
            return await got, await missed
        finally:
            await member.close()
            await outsider.close()

    with ThreadPoolExecutor(max_workers=1) as pool:
        listening = pool.submit(asyncio.run, listen())
        assert ready.wait(10)
        messages.send(team.member, team.ws, str(group.pk), doc("hello"))
        received, nothing = listening.result(timeout=20)

    assert received is not None
    assert received["event"]["type"] == "chat.message.created"
    assert received["event"]["entity_id"] == str(group.pk)
    assert nothing is None
