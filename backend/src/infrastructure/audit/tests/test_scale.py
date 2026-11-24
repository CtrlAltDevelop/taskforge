"""The filter the admin screen uses most (actor + date) stays on its index; and, on PostgreSQL,
the table refuses UPDATE and DELETE from any role."""

import time
import uuid
from datetime import timedelta
from types import SimpleNamespace
from typing import Any

import pytest
from django.db import connection
from django.utils import timezone

from infrastructure.audit import services
from infrastructure.audit.models import AuditEntry
from infrastructure.common.tests.perf import analyze

ROWS = 100_000
BUDGET_SECONDS = 0.3


@pytest.fixture
def big(db: None) -> Any:
    ws = SimpleNamespace(pk=uuid.uuid4())
    start = timezone.now() - timedelta(days=30)
    people = [str(uuid.uuid4()) for _ in range(20)]
    AuditEntry.objects.bulk_create(
        (
            AuditEntry(
                workspace=ws.pk,
                actor=people[i % 20],
                action="task.updated",
                target_type="task",
                target_id=str(i),
                at=start + timedelta(seconds=i * 25),
            )
            for i in range(ROWS)
        ),
        batch_size=5000,
    )
    analyze(AuditEntry)
    return ws, people, start


def test_actor_and_date_filter_uses_its_index_and_is_fast(big: Any) -> None:
    ws, people, start = big
    f = services.Filters(
        actor=people[3],
        since=(start + timedelta(days=10)).isoformat(),
        until=(start + timedelta(days=12)).isoformat(),
    )
    rows = services._filtered(ws, f).order_by("-pk")[:51]
    began = time.perf_counter()
    found = list(rows)
    elapsed = time.perf_counter() - began
    assert found, "the fixture should match some rows"
    assert elapsed < BUDGET_SECONDS, f"{elapsed:.3f}s over {ROWS} rows"
    assert "audit_ws" in rows.explain()  # one of the (workspace, ...) indexes, not a table scan


@pytest.mark.skipif(connection.vendor != "postgresql", reason="the trigger is PostgreSQL's")
def test_postgres_refuses_update_and_delete_even_to_raw_sql(big: Any) -> None:
    from django.db import DatabaseError, transaction

    with pytest.raises(DatabaseError), transaction.atomic(), connection.cursor() as cursor:
        cursor.execute("UPDATE audit_auditentry SET action = 'x'")
    with pytest.raises(DatabaseError), transaction.atomic(), connection.cursor() as cursor:
        cursor.execute("DELETE FROM audit_auditentry")
