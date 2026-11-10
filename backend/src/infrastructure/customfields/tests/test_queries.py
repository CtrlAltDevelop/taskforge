"""Filtering tasks by a field value: correct answers on every database, and (on PostgreSQL) an
index in the plan."""

from typing import Any

import pytest
from django.db import connection

from infrastructure.common.errors import ApiError
from infrastructure.customfields import queries, services
from infrastructure.tasks import services as tasks

pytestmark = pytest.mark.django_db


def _field(team: Any, project: Any, name: str, type: str, **kw: Any) -> Any:  # noqa: A002
    return services.create(team.owner, team.ws, str(project.pk), name=name, type=type, **kw)


def _make(team: Any, project: Any, title: str, **values: str) -> Any:
    return tasks.create(team.owner, team.ws, str(project.pk), title, field_values=values)


@pytest.fixture
def filled(team: Any, project: Any) -> dict[str, Any]:
    points = _field(team, project, "Points", "number")
    due = _field(team, project, "Ship", "date")
    budget = _field(team, project, "Budget", "money")
    done = _field(team, project, "Reviewed", "checkbox")
    kind = _field(team, project, "Kind", "select", options=[{"label": "Bug"}, {"label": "Feature"}])
    tags = _field(team, project, "Tags", "multiselect", options=[{"label": "a"}, {"label": "b"}])
    bug, feature = (o["id"] for o in kind.options)
    a, b = (o["id"] for o in tags.options)
    one = _make(
        team,
        project,
        "one",
        **{
            str(points.pk): "3",
            str(due.pk): "2026-12-01",
            str(budget.pk): "5 USD",
            str(done.pk): "true",
            str(kind.pk): bug,
            str(tags.pk): f"{a},{b}",
        },
    )
    two = _make(
        team,
        project,
        "two",
        **{
            str(points.pk): "8",
            str(due.pk): "2027-01-01",
            str(budget.pk): "50 USD",
            str(done.pk): "false",
            str(kind.pk): feature,
            str(tags.pk): b,
        },
    )
    _make(team, project, "none")
    return {
        "points": points,
        "due": due,
        "budget": budget,
        "done": done,
        "kind": kind,
        "tags": tags,
        "one": one,
        "two": two,
        "ids": {"bug": bug, "a": a, "b": b},
    }


def _titles(rows: Any) -> list[str]:
    return sorted(t.title for t in rows)


@pytest.mark.parametrize(
    ("name", "operator", "raw", "expected"),
    [
        ("points", "eq", "3", ["one"]),
        ("points", "gt", "3", ["two"]),
        ("points", "lte", "8", ["one", "two"]),
        ("due", "lt", "2027-01-01", ["one"]),
        ("budget", "gte", "10 USD", ["two"]),
        ("done", "eq", "true", ["one"]),
        ("done", "eq", "false", ["two"]),
    ],
)
def test_filter_by_value(
    filled: Any, name: str, operator: str, raw: str, expected: list[str]
) -> None:
    found = queries.tasks_with_value(filled[name], operator, raw)

    assert _titles(found) == expected


def test_select_and_multiselect_filters(filled: Any) -> None:
    assert _titles(queries.tasks_with_value(filled["kind"], "eq", filled["ids"]["bug"])) == ["one"]
    assert _titles(queries.tasks_with_value(filled["tags"], "has", filled["ids"]["b"])) == [
        "one",
        "two",
    ]
    assert _titles(queries.tasks_with_value(filled["tags"], "has", filled["ids"]["a"])) == ["one"]


def test_a_trashed_task_is_not_found_and_bad_filters_are_refused(
    team: Any, project: Any, filled: Any
) -> None:
    tasks.delete(team.owner, team.ws, str(project.pk), str(filled["one"].pk))

    assert _titles(queries.tasks_with_value(filled["points"], "gt", "0")) == ["two"]
    for field, operator, raw in (
        (filled["kind"], "gt", "x"),
        (filled["points"], "has", "1"),
        (filled["points"], "like", "1"),
        (filled["points"], "eq", "abc"),
    ):
        with pytest.raises(ApiError):
            queries.tasks_with_value(field, operator, raw)


@pytest.mark.skipif(connection.vendor != "postgresql", reason="needs PostgreSQL")
@pytest.mark.parametrize(
    ("name", "operator", "raw"),
    [
        ("points", "eq", "3"),
        ("points", "gt", "3"),
        ("due", "lt", "2027-01-01"),
        ("budget", "eq", "5 USD"),
        ("kind", "eq", "BUG"),
        ("tags", "has", "B"),
    ],
)
def test_filtering_uses_an_index(filled: Any, name: str, operator: str, raw: str) -> None:
    raw = filled["ids"].get(raw.lower(), raw)
    sql, params = (
        queries.value_rows(filled[name], operator, raw).values("task_id").query.sql_with_params()
    )
    with connection.cursor() as cursor:
        cursor.execute("SET LOCAL enable_seqscan = off")  # tiny tables: ask what *can* use an index
        cursor.execute("EXPLAIN " + sql, params)
        plan = "\n".join(row[0] for row in cursor.fetchall())

    assert "Index" in plan or "Bitmap" in plan, plan
    assert "Seq Scan" not in plan, plan
