"""Migration 0002 (views pinned as tabs): existing layouts keep working, unpinned and in order 0."""

from typing import Any

import pytest
from django.db import connection
from django.db.migrations.executor import MigrationExecutor

from infrastructure.savedviews import services
from infrastructure.savedviews.models import SavedView

TABLE = SavedView._meta.db_table
BEFORE = [("savedviews", "0001_initial")]
AFTER = [("savedviews", "0002_pinned_view_tabs")]


def _columns() -> set[str]:
    with connection.cursor() as cursor:
        return {c.name for c in connection.introspection.get_table_description(cursor, TABLE)}


def _migrate(targets: list[tuple[str, str]]) -> None:
    executor = MigrationExecutor(connection)
    executor.migrate(targets)


@pytest.mark.django_db(transaction=True)
def test_a_layout_saved_before_0002_is_not_a_tab_afterwards(team: Any, project: Any) -> None:
    view = services.save(
        team.member,
        team.ws,
        str(project.pk),
        name="Old",
        config={"columns": ["status"]},
    )
    try:
        _migrate(BEFORE)
        assert {"pinned_as_tab", "tab_order"}.isdisjoint(_columns())

        _migrate(AFTER)

        assert {"pinned_as_tab", "tab_order"} <= _columns()
        kept = SavedView.objects.get(pk=view.pk)
        assert (kept.pinned_as_tab, kept.tab_order) == (False, 0)
        assert kept.name == "Old"
    finally:
        _migrate(AFTER)
