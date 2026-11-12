"""Optional retention: entries older than ``AUDIT_RETENTION_DAYS`` go (0, the default, keeps all).

The log is append-only everywhere else. Purging is the one exception and it is deliberate: the
model and queryset guards have a single bypass (``AuditQuerySet.purge_before``), and on PostgreSQL
the immutability trigger (migration 0003) lets a DELETE through only inside a transaction that set
``audit.purging`` first, which this module does and nothing else does. UPDATE stays refused.
"""

from datetime import datetime, timedelta
from typing import Any

from django.conf import settings
from django.db import connection, transaction
from django.utils import timezone

from infrastructure.audit.models import AuditEntry


def purge(now: datetime | None = None, days: int | None = None) -> int:
    """Delete entries older than the retention; returns how many (0 when retention is off)."""
    keep = settings.AUDIT_RETENTION_DAYS if days is None else days
    if keep <= 0:
        return 0
    cutoff = (now or timezone.now()) - timedelta(days=keep)
    with transaction.atomic():
        _allow_delete(connection)
        return AuditEntry.objects.purge_before(cutoff)


def _allow_delete(conn: Any) -> None:
    if conn.vendor == "postgresql":
        with conn.cursor() as cursor:
            cursor.execute("SET LOCAL audit.purging = 'on'")  # gone at the end of the transaction
