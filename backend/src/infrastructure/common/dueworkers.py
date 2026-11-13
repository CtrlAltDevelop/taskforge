"""A registry of due-work callables: the one code path for delayed work.

Delayed work (webhook retries, debounced progress, ...) is stored in the database with a due time
and drained by a function registered here. `manage.py tick` (`make tick`, used in debug) and the
Celery beat task `infrastructure.common.tick` (production) both call `run_all()`, so debug and
production behave the same. Each callable takes no arguments and is safe to run often.

    from infrastructure.common import dueworkers
    dueworkers.register("webhooks.retry", retry_due_deliveries)   # in an AppConfig.ready()
"""

import logging
from collections.abc import Callable
from typing import Any

logger = logging.getLogger(__name__)

DueWorker = Callable[[], Any]

_workers: dict[str, DueWorker] = {}


def register(name: str, fn: DueWorker) -> None:
    """Add (or replace, so a reloaded module does not duplicate) the worker called `name`."""
    _workers[name] = fn


def names() -> list[str]:
    return list(_workers)


def run_all() -> dict[str, Any]:
    """Run every worker; one that raises is logged and does not stop the others.

    Returns each worker's result, or the exception it raised, by name.
    """
    results: dict[str, Any] = {}
    for name, fn in list(_workers.items()):
        try:
            results[name] = fn()
        except Exception as exc:
            logger.exception("Due worker %s failed", name)
            results[name] = exc
    return results
