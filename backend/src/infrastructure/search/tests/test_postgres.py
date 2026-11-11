"""PostgreSQL only: typo tolerance and index use. Skipped on SQLite (run with
``DJANGO_DB_ENGINE=django.db.backends.postgresql``)."""

from typing import Any

import pytest
from django.db import connection

from infrastructure.search import matching, services
from infrastructure.search.models import SearchEntry
from infrastructure.search.tests.conftest import make_task

pytestmark = pytest.mark.skipif(connection.vendor != "postgresql", reason="needs PostgreSQL")


def test_a_typo_still_finds_the_word(team: Any) -> None:
    project = team.create(team.owner, "WEB")
    make_task(team, project, "Design the login page")

    page = services.query(team.member, team.ws, "desing", ["task"])

    assert [h.title for h in page.hits["task"]] == ["Design the login page"]


def test_the_indexes_are_used(team: Any) -> None:
    project = team.create(team.owner, "WEB")
    for n in range(300):
        make_task(team, project, f"Task number {n} about invoices")
    with matching.session(), connection.cursor() as cursor:
        cursor.execute("SET LOCAL enable_seqscan = off")
        cursor.execute(
            "EXPLAIN SELECT id FROM search_searchentry "
            "WHERE search_vector @@ to_tsquery('simple', 'invoic:*')"
        )
        plan = "\n".join(row[0] for row in cursor.fetchall())
        cursor.execute("EXPLAIN SELECT id FROM search_searchentry WHERE 'invoce' <% title")
        typo_plan = "\n".join(row[0] for row in cursor.fetchall())
    assert "search_vector_gin" in plan and "search_title_trgm" in typo_plan
    assert SearchEntry.objects.count() == 300
