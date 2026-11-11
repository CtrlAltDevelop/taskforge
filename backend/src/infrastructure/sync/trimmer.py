"""Trims the change log from the socket server, so no scheduler has to be set up.

Started once per process by the first connection; runs a minute later and then every few hours,
off the request path. ``manage.py trim_changelog`` does the same by hand or from cron.
"""

import asyncio
import logging
from typing import Final

from asgiref.sync import sync_to_async

from infrastructure.sync import services

FIRST_AFTER: Final = 60
EVERY: Final = 6 * 60 * 60

log = logging.getLogger(__name__)
_task: asyncio.Task[None] | None = None


async def trim_once() -> int:
    return int(await sync_to_async(services.trim)())


async def _loop() -> None:
    await asyncio.sleep(FIRST_AFTER)
    while True:
        try:
            await trim_once()
        except Exception:
            log.exception("Could not trim the change log")
        await asyncio.sleep(EVERY)


def ensure_started() -> None:
    """Start the trimming loop on the running event loop if it is not already going."""
    global _task
    if _task is None or _task.done():
        _task = asyncio.get_running_loop().create_task(_loop())
