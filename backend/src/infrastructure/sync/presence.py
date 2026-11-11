"""Who is looking at a task right now.

An entry is a person and whether they are editing, kept for ``TTL_SECONDS`` and renewed by the
client's heartbeat, so a client that vanishes drops out by itself. Held in Redis when the project
runs the Redis broker (so every worker sees the same room) and in this process otherwise
(development and tests). Never in the database: it is only ever true for a moment.
"""

import threading
import time
from typing import Any, Final, Protocol

from apps.notifications.broadcast import RedisBroker, get_broker

TTL_SECONDS: Final = 45
KEY_PREFIX: Final = "presence:"


class PresenceStore(Protocol):
    def touch(self, task_id: str, user_id: str, editing: bool, conn: str = "") -> bool:
        """Record that ``user_id`` (on connection ``conn``: a person with two tabs open is on the
        task until the last one leaves) is on the task; True when that changed who is there or
        whether they edit (so the others need telling), False for a plain heartbeat."""
        ...

    def leave(self, task_id: str, user_id: str, conn: str = "") -> bool:
        """Remove that connection; True when it changed who is on the task (the person is gone
        only when their last connection is)."""
        ...

    def who(self, task_id: str) -> list[dict[str, Any]]:
        """``[{"id", "editing"}]`` of everyone still on the task, by id."""
        ...


def _roster(rows: dict[tuple[str, str], bool]) -> list[dict[str, Any]]:
    """One entry per person: editing when any of their connections is."""
    people: dict[str, bool] = {}
    for (user, _conn), editing in rows.items():
        people[user] = people.get(user, False) or editing
    return [{"id": u, "editing": e} for u, e in sorted(people.items())]


class MemoryPresence:
    def __init__(self) -> None:
        self._rows: dict[str, dict[tuple[str, str], tuple[float, bool]]] = {}
        self._lock = threading.Lock()

    def _live(self, task_id: str, now: float) -> dict[tuple[str, str], tuple[float, bool]]:
        rows = {k: v for k, v in self._rows.get(task_id, {}).items() if v[0] > now}
        if rows:
            self._rows[task_id] = rows
        else:
            self._rows.pop(task_id, None)
        return rows

    def _who(self, rows: dict[tuple[str, str], tuple[float, bool]]) -> list[dict[str, Any]]:
        return _roster({k: v[1] for k, v in rows.items()})

    def touch(self, task_id: str, user_id: str, editing: bool, conn: str = "") -> bool:
        now = time.monotonic()
        with self._lock:
            rows = self._live(task_id, now)
            before = self._who(rows)
            self._rows.setdefault(task_id, {})[(user_id, conn)] = (now + TTL_SECONDS, editing)
            return before != self._who(self._live(task_id, now))

    def leave(self, task_id: str, user_id: str, conn: str = "") -> bool:
        with self._lock:
            rows = self._live(task_id, time.monotonic())
            before = self._who(rows)
            rows.pop((user_id, conn), None)
            return before != self._who(rows)

    def who(self, task_id: str) -> list[dict[str, Any]]:
        with self._lock:
            return self._who(self._live(task_id, time.monotonic()))


class RedisPresence:
    """One hash per task, one field per person and connection: ``<expires at>:<0|1>``. Fields are
    independent, so people arriving together never overwrite each other."""

    def __init__(self, client: Any) -> None:
        self._client = client

    def _key(self, task_id: str) -> str:
        return f"{KEY_PREFIX}{task_id}"

    def _rows(self, task_id: str) -> dict[tuple[str, str], bool]:
        rows: dict[tuple[str, str], bool] = {}
        for field, raw in self._client.hgetall(self._key(task_id)).items():
            until, _, editing = raw.decode().partition(":")
            user, _, conn = field.decode().partition("|")
            if float(until) > time.time():
                rows[(user, conn)] = editing == "1"
        return rows

    def touch(self, task_id: str, user_id: str, editing: bool, conn: str = "") -> bool:
        before = _roster(self._rows(task_id))
        value = f"{time.time() + TTL_SECONDS}:{int(editing)}"
        self._client.hset(self._key(task_id), f"{user_id}|{conn}", value)
        self._client.expire(self._key(task_id), TTL_SECONDS * 2)
        return before != _roster(self._rows(task_id))

    def leave(self, task_id: str, user_id: str, conn: str = "") -> bool:
        before = _roster(self._rows(task_id))
        self._client.hdel(self._key(task_id), f"{user_id}|{conn}")
        return before != _roster(self._rows(task_id))

    def who(self, task_id: str) -> list[dict[str, Any]]:
        return _roster(self._rows(task_id))


_store: PresenceStore | None = None


def store() -> PresenceStore:
    """The store this process uses: Redis when the broker is Redis, else in memory."""
    global _store
    if _store is None:
        broker = get_broker()
        _store = (
            RedisPresence(broker.client()) if isinstance(broker, RedisBroker) else MemoryPresence()
        )
    return _store


def reset_store() -> None:
    global _store
    _store = None
