"""Time budgets are written for a laptop on SQLite; this scales them for slower setups."""

import os

from django.db import connection
from django.db.models import Model

SLOW_FACTOR = 10


def budget(seconds: float) -> float:
    """``seconds`` as is on SQLite on a developer machine; x10 on PostgreSQL (a network round trip
    per query) or a shared CI runner (which sets ``CI``) where the same code runs several times
    slower."""
    slow = connection.vendor == "postgresql" or bool(os.environ.get("CI"))
    return seconds * SLOW_FACTOR if slow else seconds


def analyze(*models: type[Model]) -> None:
    """Refresh PostgreSQL's statistics after a bulk load: a fresh table has none until autovacuum
    gets to it, so the planner guesses and may pick a scan the real data would never get."""
    if connection.vendor != "postgresql":
        return
    with connection.cursor() as cursor:
        for model in models:
            cursor.execute(f"ANALYZE {connection.ops.quote_name(model._meta.db_table)}")
