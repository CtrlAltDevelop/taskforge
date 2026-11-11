"""The in-memory presence store (the Redis one has the same shape and is covered with a fake)."""

import time

import pytest

from infrastructure.sync import presence
from infrastructure.sync.presence import MemoryPresence, RedisPresence


def test_people_on_a_task_are_listed_by_id() -> None:
    store = MemoryPresence()
    store.touch("t1", "b", False)
    store.touch("t1", "a", True)

    assert store.who("t1") == [{"id": "a", "editing": True}, {"id": "b", "editing": False}]
    assert store.who("t2") == []


def test_only_a_change_is_worth_telling_the_others_about() -> None:
    store = MemoryPresence()

    assert store.touch("t", "a", False) is True  # arrived
    assert store.touch("t", "a", False) is False  # heartbeat
    assert store.touch("t", "a", True) is True  # started editing
    assert store.touch("t", "a", False) is True  # stopped


def test_leaving_removes_and_says_whether_they_were_there() -> None:
    store = MemoryPresence()
    store.touch("t", "a", False)

    assert store.leave("t", "a") is True
    assert store.leave("t", "a") is False
    assert store.who("t") == []


def test_a_person_who_stops_heartbeating_drops_out(monkeypatch: pytest.MonkeyPatch) -> None:
    store = MemoryPresence()
    store.touch("t", "a", False)
    now = time.monotonic()
    monkeypatch.setattr("infrastructure.sync.presence.time.monotonic", lambda: now + 46)

    assert store.who("t") == []
    assert store.touch("t", "a", False) is True  # back counts as arriving


def test_a_person_with_two_tabs_stays_until_the_last_one_leaves() -> None:
    store = MemoryPresence()
    store.touch("t", "a", False, "tab1")
    assert store.touch("t", "a", True, "tab2") is True  # started editing in the second
    assert store.who("t") == [{"id": "a", "editing": True}]

    assert store.leave("t", "a", "tab2") is True  # no longer editing
    assert store.who("t") == [{"id": "a", "editing": False}]
    assert store.leave("t", "a", "tab1") is True  # gone
    assert store.who("t") == []


def test_the_redis_store_behaves_the_same(monkeypatch: pytest.MonkeyPatch) -> None:
    import fakeredis

    store = RedisPresence(fakeredis.FakeRedis())

    assert store.touch("t", "a", False, "c1") is True
    assert store.touch("t", "a", False, "c1") is False
    assert store.touch("t", "a", True, "c1") is True
    store.touch("t", "b", False, "c2")
    assert store.who("t") == [{"id": "a", "editing": True}, {"id": "b", "editing": False}]
    assert store.touch("t", "a", False, "c3") is False  # a second connection changes nothing yet
    assert store.leave("t", "a", "c1") is True  # editing ended with it
    assert store.leave("t", "a", "c3") is True
    assert store.leave("t", "a", "c3") is False
    now = time.time()
    monkeypatch.setattr("infrastructure.sync.presence.time.time", lambda: now + 46)
    assert store.who("t") == []


def test_the_store_follows_the_broker() -> None:
    presence.reset_store()

    assert isinstance(presence.store(), MemoryPresence)
    presence.reset_store()
