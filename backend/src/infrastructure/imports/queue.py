"""Running an import away from the request: the one seam Celery will replace.

There is no Celery yet, so the work goes to a background thread per lane (one import at a time
per process: an import is bulk work and two at once only slow each other; exports have their
own). With ``IMPORTS_SYNC_RUN`` (tests) it runs on the spot.
"""

import logging
from collections.abc import Callable
from concurrent.futures import ThreadPoolExecutor
from typing import Any

from django.conf import settings

logger = logging.getLogger(__name__)
_pools: dict[str, ThreadPoolExecutor] = {}


def run_later(job: Callable[..., Any], *args: Any, lane: str = "imports") -> None:
    """Run ``job`` on the ``lane``'s own worker (an export never waits behind a long import)."""
    if getattr(settings, "IMPORTS_SYNC_RUN", False):
        job(*args)
        return
    if lane not in _pools:
        _pools[lane] = ThreadPoolExecutor(max_workers=1, thread_name_prefix=lane)
    _pools[lane].submit(_guarded, job, args)


def _guarded(job: Callable[..., Any], args: tuple[Any, ...]) -> None:
    try:
        job(*args)
    except Exception:  # noqa: BLE001 -- the job row holds the failure; the worker must not die
        logger.exception("import job failed")
