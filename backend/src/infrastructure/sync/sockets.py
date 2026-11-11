"""The sync WebSocket (``/ws/sync``): live events for the rooms a person may listen to.

Plain ASGI like the notification socket (no Channels). Every frame is JSON with a ``type``.

Client to server: ``authenticate`` (``token``; must be the first frame, within ``AUTH_SECONDS``),
``subscribe`` / ``unsubscribe`` (``room``: ``ws:<id>``, ``proj:<id>`` or ``user:<id>``),
``presence`` (``task``, ``project``, ``state`` = ``viewing`` | ``editing`` | ``left``) and ``ping``.

Server to client: ``ready``, ``subscribed``, ``unsubscribed`` (``reason``: ``requested`` or
``access``), ``event`` (``room``, ``event``: see ``publish``), ``presence`` (``project``, ``task``,
``users``), ``pong`` and ``error``. A refused room is one uniform ``forbidden`` error naming no
reason, so room ids cannot be probed.

Access is checked when a room is joined, again when an ``access.changed`` hint arrives (a removal or
role change takes effect at once), on every connection every ``REVALIDATE_SECONDS``, and before a
project event is delivered if the room was last checked more than ``ROOM_FRESH_SECONDS`` ago.
Events are hints: ids and a version, never content. Clients trust ``version``, not arrival order.
"""

import asyncio
import json
import time
import uuid
from collections import deque
from typing import Any, Final

from asgiref.sync import sync_to_async

from apps.notifications.broadcast import Subscription, get_broker
from apps.notifications.identity import user_from_token, user_summary
from infrastructure.sync import presence, rooms, trimmer
from infrastructure.sync.actor import origin_tag
from infrastructure.sync.publish import channel_of, project_room
from infrastructure.tasks.models import Task

UNAUTHENTICATED: Final = 4401
AUTH_SECONDS: Final = 10
IDLE_SECONDS: Final = 120
REVALIDATE_SECONDS: Final = 60
ROOM_FRESH_SECONDS: Final = 5
MAX_ROOMS: Final = 50
MAX_FRAME_BYTES: Final = 16 * 1024
COMMANDS_PER_MINUTE: Final = 1200
SEEN_CURSORS: Final = 512
STATES: Final = ("viewing", "editing", "left")


class SyncSocket:
    def __init__(self, scope: dict[str, Any], receive: Any, send: Any) -> None:
        self._receive = receive
        self._send = send
        self._subscription: Subscription | None = None
        self._user: Any = None
        self._conn = uuid.uuid4().hex  # this connection, so two tabs of one person are two
        self._client_id = ""
        self._token = ""
        self._joined_channels: set[str] = set()  # a broker subscription cannot leave a channel
        self._rooms: dict[str, float] = {}  # room -> when its access was last checked
        self._seen: deque[int] = deque(maxlen=SEEN_CURSORS)
        self._watching: set[tuple[str, str]] = set()  # (project, task) this connection announced
        self._recent: list[float] = []
        self._last_heard = time.monotonic()
        self._revalidated = time.monotonic()

    # -- plumbing ---------------------------------------------------------

    async def _json(self, frame: dict[str, Any]) -> None:
        await self._send({"type": "websocket.send", "text": json.dumps(frame)})

    async def _error(self, code: str, **extra: Any) -> None:
        await self._json({"type": "error", "code": code, **extra})

    async def _close(self, code: int) -> None:
        await self._send({"type": "websocket.close", "code": code})

    # -- lifecycle --------------------------------------------------------

    async def run(self) -> None:
        message = await self._receive()
        if message["type"] != "websocket.connect":  # pragma: no cover - server contract
            return
        await self._send({"type": "websocket.accept"})
        trimmer.ensure_started()
        if not await self._authenticate():
            return
        self._subscription = get_broker().subscribe()
        try:
            await self._join(f"user:{self._user.pk}", check=False, settle=False)
            await self._json(
                {
                    "type": "ready",
                    "user": user_summary(self._user),
                    "origin": origin_tag(str(self._user.pk), self._client_id),
                }
            )
            await self._pump()
        finally:
            await self._subscription.close()
            await self._leave_presence()

    async def _authenticate(self) -> bool:
        """The first frame must be ``authenticate`` with a token that names an active account."""
        try:
            message = await asyncio.wait_for(self._receive(), AUTH_SECONDS)
        except TimeoutError:
            await self._close(UNAUTHENTICATED)
            return False
        if message["type"] != "websocket.receive":
            return False
        frame = self._parse(message)
        token = frame.get("token") if frame and frame.get("type") == "authenticate" else None
        user = await sync_to_async(user_from_token)(token) if isinstance(token, str) else None
        if user is None or not user.is_active:
            await self._error("unauthenticated")
            await self._close(UNAUTHENTICATED)
            return False
        client_id = frame.get("client_id") if frame else None
        self._client_id = client_id[:64] if isinstance(client_id, str) else ""
        self._user, self._token = user, str(token)
        return True

    def _parse(self, message: dict[str, Any]) -> dict[str, Any] | None:
        text = message.get("text")
        if text is None or len(text.encode()) > MAX_FRAME_BYTES:
            return None
        try:
            frame = json.loads(text)
        except ValueError:
            return None
        return frame if isinstance(frame, dict) else None

    async def _pump(self) -> None:
        assert self._subscription is not None
        from_client = asyncio.ensure_future(self._receive())
        from_broker = asyncio.ensure_future(self._subscription.get())
        try:
            while True:
                done, _ = await asyncio.wait(
                    {from_client, from_broker},
                    timeout=REVALIDATE_SECONDS,
                    return_when=asyncio.FIRST_COMPLETED,
                )
                if not await self._housekeeping():
                    return
                if from_broker in done:
                    await self._deliver(from_broker.result())
                    from_broker = asyncio.ensure_future(self._subscription.get())
                if from_client in done:
                    message = from_client.result()
                    if message["type"] == "websocket.disconnect":
                        return
                    self._last_heard = time.monotonic()
                    await self._handle(message)
                    from_client = asyncio.ensure_future(self._receive())
        finally:
            for task in (from_client, from_broker):
                task.cancel()

    async def _housekeeping(self) -> bool:
        """Close an idle connection or one whose account is gone; re-check rooms now and then."""
        now = time.monotonic()
        if now - self._last_heard > IDLE_SECONDS:
            await self._close(1001)
            return False
        if now - self._revalidated < REVALIDATE_SECONDS:
            return True
        self._revalidated = now
        user = await sync_to_async(user_from_token)(self._token)
        if user is None or user.pk != self._user.pk or not user.is_active:
            await self._error("unauthenticated")
            await self._close(UNAUTHENTICATED)
            return False
        await self._revalidate()
        return True

    # -- rooms ------------------------------------------------------------

    async def _join(self, room: str, *, check: bool = True, settle: bool = True) -> bool:
        if check and not await sync_to_async(rooms.may_join)(self._user, room):
            return False
        assert self._subscription is not None
        channel = channel_of(room)
        if channel not in self._joined_channels:
            await self._subscription.add(channel)
            self._joined_channels.add(channel)
            wait = getattr(self._subscription, "settle", None)
            if settle and wait is not None:
                await wait()  # really subscribed before the client is told, so nothing slips by
        self._rooms[room] = time.monotonic()
        return True

    async def _forget(self, room: str) -> None:
        """Leave a room and stop listening to its channel (it would otherwise keep arriving for
        as long as the connection lives)."""
        self._rooms.pop(room, None)
        channel = channel_of(room)
        if channel in self._joined_channels and self._subscription is not None:
            self._joined_channels.discard(channel)
            leave = getattr(self._subscription, "leave", None)
            if leave is not None:
                await leave(channel)

    async def _revalidate(self) -> None:
        for room in list(self._rooms):
            if room.startswith("user:"):
                continue
            if not await sync_to_async(rooms.may_join)(self._user, room):
                await self._forget(room)
                await self._json({"type": "unsubscribed", "room": room, "reason": "access"})
                await self._drop_presence(room)
            else:
                self._rooms[room] = time.monotonic()

    async def _deliver(self, frame: dict[str, Any]) -> None:
        room = frame.get("room")
        if room not in self._rooms:
            return
        event = frame.get("event")
        if isinstance(event, dict):
            if event.get("type") == "access.changed":
                await self._revalidate()
            elif room.startswith("proj:") and not await self._still_allowed(room):
                return
            cursor = event.get("cursor")
            if isinstance(cursor, int):
                if cursor in self._seen:
                    return  # the same change arrives by its project and by its workspace
                self._seen.append(cursor)
            await self._json({"type": "event", "room": room, "event": event})
        elif isinstance(frame.get("presence"), dict):
            if room.startswith("proj:") and not await self._still_allowed(room):
                return
            await self._json({"type": "presence", **frame["presence"]})

    async def _still_allowed(self, room: str) -> bool:
        if time.monotonic() - self._rooms[room] < ROOM_FRESH_SECONDS:
            return True
        if await sync_to_async(rooms.may_join)(self._user, room):
            self._rooms[room] = time.monotonic()
            return True
        await self._forget(room)
        await self._json({"type": "unsubscribed", "room": room, "reason": "access"})
        await self._drop_presence(room)
        return False

    # -- commands ---------------------------------------------------------

    def _over_limit(self) -> bool:
        now = time.monotonic()
        self._recent = [at for at in self._recent if now - at < 60]
        if len(self._recent) >= COMMANDS_PER_MINUTE:
            return True
        self._recent.append(now)
        return False

    async def _handle(self, message: dict[str, Any]) -> None:
        frame = self._parse(message)
        if frame is None:
            await self._error("bad_request")
            return
        if self._over_limit():
            await self._error("rate_limited")
            return
        kind = frame.get("type")
        if kind == "ping":
            await self._json({"type": "pong"})
        elif kind == "subscribe":
            await self._subscribe(frame)
        elif kind == "unsubscribe":
            await self._unsubscribe(frame)
        elif kind == "presence":
            await self._presence(frame)
        else:
            await self._error("unknown_command")

    async def _subscribe(self, frame: dict[str, Any]) -> None:
        room = frame.get("room")
        if not isinstance(room, str) or rooms.parse(room) is None:
            await self._error("bad_request", room=str(room))
            return
        if room not in self._rooms and len(self._rooms) >= MAX_ROOMS:
            await self._error("too_many_rooms", room=room)
            return
        if not await self._join(room):
            await self._error("forbidden", room=room)
            return
        await self._json({"type": "subscribed", "room": room})

    async def _unsubscribe(self, frame: dict[str, Any]) -> None:
        room = frame.get("room")
        if isinstance(room, str) and room in self._rooms and not room.startswith("user:"):
            await self._forget(room)
            await self._drop_presence(room)
            await self._json({"type": "unsubscribed", "room": room, "reason": "requested"})

    # -- presence ---------------------------------------------------------

    async def _presence(self, frame: dict[str, Any]) -> None:
        task, project, state = frame.get("task"), frame.get("project"), frame.get("state")
        room = project_room(project) if isinstance(project, str) else ""
        if (
            not isinstance(task, str)
            or state not in STATES
            or room not in self._rooms
            or not await sync_to_async(_task_in_project)(task, str(project))
        ):
            await self._error("bad_request")
            return
        uid = str(self._user.pk)
        store = presence.store()
        if state == "left":
            changed = await sync_to_async(store.leave)(task, uid, self._conn)
            self._watching.discard((str(project), task))
        else:
            changed = await sync_to_async(store.touch)(task, uid, state == "editing", self._conn)
            self._watching.add((str(project), task))
        if changed:
            await self._announce(str(project), task)
        elif state != "left":
            # Nothing changed for the others, but this client still gets the roster: on arriving,
            # and with every heartbeat, so a person who left (or whose connection died) while it
            # was away does not stay on its screen.
            await self._roster(str(project), task)

    async def _roster(self, project: str, task: str) -> None:
        users = await sync_to_async(presence.store().who)(task)
        await self._json({"type": "presence", "project": project, "task": task, "users": users})

    async def _announce(self, project: str, task: str) -> None:
        users = await sync_to_async(presence.store().who)(task)
        room = project_room(project)
        payload = {"room": room, "presence": {"project": project, "task": task, "users": users}}
        await sync_to_async(get_broker().publish)(channel_of(room), payload)

    async def _drop_presence(self, room: str) -> None:
        project = room.removeprefix("proj:")
        for watched in [w for w in self._watching if w[0] == project]:
            self._watching.discard(watched)
            changed = await sync_to_async(presence.store().leave)(
                watched[1], str(self._user.pk), self._conn
            )
            if changed:
                await self._announce(*watched)

    async def _leave_presence(self) -> None:
        for project, task in list(self._watching):
            self._watching.discard((project, task))
            if self._user is not None:
                changed = await sync_to_async(presence.store().leave)(
                    task, str(self._user.pk), self._conn
                )
                if changed:
                    await self._announce(project, task)


def _task_in_project(task_id: str, project_id: str) -> bool:
    try:
        return Task.objects.filter(
            pk=task_id, project_id=project_id, deleted_at__isnull=True
        ).exists()
    except (ValueError, TypeError):
        return False


async def sync_socket(scope: dict[str, Any], receive: Any, send: Any) -> None:
    await SyncSocket(scope, receive, send).run()
