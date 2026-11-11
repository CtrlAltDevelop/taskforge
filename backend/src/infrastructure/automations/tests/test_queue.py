import threading
from datetime import timedelta
from typing import Any

import pytest
from django.test import override_settings
from django.utils import timezone

from infrastructure.automations import due, queue, spec
from infrastructure.automations.tests.conftest import *  # noqa: F403 -- fixtures


@pytest.fixture
def async_queue(monkeypatch: pytest.MonkeyPatch) -> Any:
    monkeypatch.setattr(queue, "_pools", {})
    monkeypatch.setattr(queue, "_queued_keys", set())
    monkeypatch.setattr(queue, "_pending_count", 0)
    with override_settings(AUTOMATIONS_SYNC_RUN=False):
        yield
    for pool in queue._pools.values():
        pool.shutdown(wait=True)


def test_lanes_split_webhooks_from_local_actions() -> None:
    assert queue.lane_for([{"type": spec.ADD_COMMENT}]) == "local"
    assert queue.lane_for([{"type": spec.ADD_COMMENT}, {"type": spec.WEBHOOK}]) == "webhook"


def test_a_full_queue_refuses_new_jobs_and_frees_room_when_they_finish(
    async_queue: Any, monkeypatch: pytest.MonkeyPatch
) -> None:
    monkeypatch.setattr(queue, "MAX_PENDING", 2)
    gate, ran = threading.Event(), threading.Event()

    def block() -> None:
        gate.wait(5)
        ran.set()

    assert queue.run_later(block, key="a") and queue.run_later(block, key="b")
    assert queue.run_later(block, key="c") is False
    gate.set()
    assert ran.wait(5)
    queue._pools["local"].shutdown(wait=True)
    assert queue.pending_count() == 0


def test_a_key_already_queued_is_not_queued_twice(async_queue: Any) -> None:
    gate = threading.Event()
    assert queue.run_later(gate.wait, 5, key="same")
    assert queue.run_later(gate.wait, 5, key="same") is False
    gate.set()


def test_slow_webhooks_do_not_take_the_local_threads(async_queue: Any) -> None:
    gate, done = threading.Event(), threading.Event()
    for _ in range(queue.LANE_SIZES["webhook"] + 2):
        queue.run_later(gate.wait, 5, lane="webhook")
    queue.run_later(done.set)
    assert done.wait(2), "a local job ran while every webhook thread was busy"
    gate.set()


def test_the_due_scan_does_not_requeue_what_is_waiting_and_honours_a_tick_cap(
    team: Any, web: Any, monkeypatch: pytest.MonkeyPatch
) -> None:
    from infrastructure.automations.tests.test_automations import (
        comment_action,
        make_rule,
        make_task,
    )

    make_rule(team, web, {"type": "due_date_reached", "days_before": 1}, [comment_action("due")])
    day = (timezone.now().date() + timedelta(days=1)).isoformat()
    for n in range(3):
        make_task(team, web, f"t{n}", due_date=day)
    taken: list[str | None] = []

    def refuse_repeats(_job: Any, *_a: Any, key: str | None = None, **_k: Any) -> bool:
        if key in taken:
            return False
        taken.append(key)
        return True

    monkeypatch.setattr(queue, "run_later", refuse_repeats)
    assert due.scan_due() == 3
    assert due.scan_due() == 0  # still waiting in the queue, so not queued again
    taken.clear()
    monkeypatch.setattr(due, "PER_TICK", 2)
    assert due.scan_due() == 2
