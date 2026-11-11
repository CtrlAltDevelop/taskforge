"""Running a rule later, away from the request that caused it: the one seam Celery will replace.

There is no Celery yet, so the work goes to a small thread pool, the way the inbox sends its pushes.
With ``AUTOMATIONS_SYNC_RUN`` (tests) it runs on the spot, but one job at a time: a job that
queues more jobs only appends them, so a chain of rules is a loop and not a deep call stack.
"""

import logging
import threading
from collections import deque
from collections.abc import Callable
from concurrent.futures import ThreadPoolExecutor
from typing import Any, Final

from django.conf import settings

from infrastructure.automations import spec

logger = logging.getLogger(__name__)
_local = threading.local()
_pools: dict[str, ThreadPoolExecutor] = {}
_pool_lock = threading.Lock()
_state_lock = threading.Lock()
_queued_keys: set[str] = set()
_pending_count = 0

MAX_PENDING: Final = (
    1000  # jobs waiting or running; over it a job is refused and the next tick retries
)
LANE_SIZES: Final = {"local": 2, "webhook": 4}  # slow webhooks cannot starve the local actions


def lane_for(actions: list[dict[str, Any]]) -> str:
    """``webhook`` for a rule that calls out (it may be slow), else ``local``."""
    return "webhook" if any(a.get("type") == spec.WEBHOOK for a in actions) else "local"


def pending_count() -> int:
    return _pending_count


def _release(key: str | None) -> None:
    global _pending_count
    with _state_lock:
        _pending_count = max(0, _pending_count - 1)
        if key is not None:
            _queued_keys.discard(key)


def _guarded(job: Callable[..., Any], args: tuple[Any, ...], key: str | None = None) -> None:
    try:
        job(*args)
    except Exception:  # noqa: BLE001 -- a worker must not die; the run record holds the failure
        logger.exception("automation job failed")
    finally:
        _release(key)


def _admit(key: str | None) -> bool:
    global _pending_count
    with _state_lock:
        if key is not None and key in _queued_keys:
            return False
        if _pending_count >= MAX_PENDING:
            logger.warning(
                "automation queue full (%s jobs): job refused, a later tick retries", MAX_PENDING
            )
            return False
        _pending_count += 1
        if key is not None:
            _queued_keys.add(key)
    return True


def _pool(lane: str) -> ThreadPoolExecutor:
    with _pool_lock:
        if lane not in _pools:
            _pools[lane] = ThreadPoolExecutor(
                LANE_SIZES[lane], thread_name_prefix=f"automations-{lane}"
            )
        return _pools[lane]


def run_later(
    job: Callable[..., Any], *args: Any, lane: str = "local", key: str | None = None
) -> bool:
    """Queue ``job``. ``False`` when it was not queued: the same ``key`` is already waiting, or
    the queue is full (the caller leaves it for the next tick)."""
    if not settings.AUTOMATIONS_SYNC_RUN:
        if not _admit(key):
            return False
        try:
            _pool(lane).submit(_guarded, job, args, key)
        except Exception:
            _release(key)
            raise
        return True
    pending: deque[tuple[Callable[..., Any], tuple[Any, ...]]] | None = getattr(
        _local, "pending", None
    )
    if pending is not None:
        pending.append((job, args))
        return True
    _local.pending = pending = deque([(job, args)])
    try:
        while pending:
            next_job, next_args = pending.popleft()
            _guarded(next_job, next_args)
    finally:
        _local.pending = None
    return True
