"""Time budgets are written for a laptop on SQLite; this scales them for slower setups."""

import os

from django.db import connection

SLOW_FACTOR = 10


def budget(seconds: float) -> float:
    """``seconds`` as is on SQLite on a developer machine; x10 on PostgreSQL (a network round trip
    per query) or a shared CI runner (which sets ``CI``) where the same code runs several times
    slower."""
    slow = connection.vendor == "postgresql" or bool(os.environ.get("CI"))
    return seconds * SLOW_FACTOR if slow else seconds
