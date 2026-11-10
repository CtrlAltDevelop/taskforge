"""The TFQL grammar: what reads, what does not, and where the error points. No database."""

import pytest

from infrastructure.filters import tfql
from infrastructure.filters.tfql import QueryError

VALID = [
    "",
    "   ",
    "status = Active",
    "status != Active",
    "status = 'x'" if False else 'status = "In review"',
    'status in (Active, "In review")',
    "status not in (Done)",
    "status NOT IN (Done, Cancelled)",
    "priority = high",
    "assignee = me",
    "assignee is empty",
    "assignee IS NOT EMPTY",
    "assignee in (me, zoe)",
    "due < +7d",
    "due <= -2w",
    "due >= 2026-11-05",
    "due > today",
    "due = +1m",
    "start < +1y",
    "created >= -30d",
    'title ~ "fix"',
    'title !~ "wip"',
    "title = bug",
    '"Story points" > 3',
    '"Story points" >= 3.5',
    '"Story points" < -1',
    "blocked = true",
    "blocked = false",
    "id = 12",
    'id in ("WEB-1", 2)',
    "sprint = currentSprint()",
    "a = 1 AND b = 2",
    "a = 1 and b = 2",
    "a = 1 OR b = 2",
    "a = 1 AND b = 2 OR c = 3",
    "a = 1 OR b = 2 AND c = 3",
    "(a = 1 OR b = 2) AND c = 3",
    "NOT a = 1",
    "NOT (a = 1 OR b = 2)",
    "NOT NOT a = 1",
    "((a = 1))",
    "a = 1 AND (b = 2 AND (c = 3))",
    "ORDER BY priority",
    "ORDER BY priority DESC",
    "ORDER BY priority DESC, due ASC, title",
    "a = 1 ORDER BY due",
    'a = "x" ORDER BY "Story points" DESC',
    r'title = "she said \"hi\""',
    r'title = "back\\slash"',
    'title = "SELECT * FROM x; --"',
    'title = "\'; DROP TABLE tasks; --"',
]

BAD = [
    ("status =", "Expected a value.", 8),
    ("= 1", "Expected a field name.", 0),
    ("status 1", "Expected an operator", 7),
    ("status in", "Expected '('.", 9),
    ("status in ()", "Expected a value.", 11),
    ("status in (a", "Expected ')'.", 12),
    ("status in (a,)", "Expected a value.", 13),
    ("status in a", "Expected '('.", 10),
    ("status not 1", "Expected IN after NOT.", 11),
    ("status is 1", "Expected EMPTY.", 10),
    ("status is not", "Expected EMPTY.", 13),
    ("a = 1 AND", "Expected a field name.", 9),
    ("a = 1 OR", "Expected a field name.", 8),
    ("AND a = 1", "Expected a field name.", 0),
    ("a = 1 b = 2", "Unexpected text after the query.", 6),
    ("(a = 1", "Expected ')'.", 6),
    ("a = 1)", "Unexpected text after the query.", 5),
    ("()", "Expected a field name.", 1),
    ('a = "x', "This string is never closed.", 4),
    ("a ? 1", "Unexpected character '?'.", 2),
    ("a = 1 ORDER", "Expected BY after ORDER.", 11),
    ("a = 1 ORDER BY", "Expected a field name.", 14),
    ("a = 1 ORDER BY b,", "Expected a field name.", 17),
    ("a = 1 ORDER BY b c", "Unexpected text after the query.", 17),
    ("ORDER x", "Expected BY after ORDER.", 6),
    ("a = and", "Expected a value.", 4),
    ("a = f(", "Expected ')'.", 6),
    ("a = f(1)", "Expected ')'.", 6),
    ("NOT", "Expected a field name.", 3),
    ("a $ 1", "Unexpected character '$'.", 2),
    ("a = @x", "Unexpected character '@'.", 4),
]


@pytest.mark.parametrize("source", VALID)
def test_a_valid_query_reads(source: str) -> None:
    assert isinstance(tfql.parse(source), tfql.Query)


@pytest.mark.parametrize(("source", "message", "position"), BAD)
def test_an_invalid_query_points_at_the_problem(source: str, message: str, position: int) -> None:
    with pytest.raises(QueryError) as caught:
        tfql.parse(source)

    assert caught.value.message.startswith(message.rstrip("."))
    assert caught.value.position == position
    assert caught.value.length >= 1


def test_and_binds_tighter_than_or() -> None:
    tree = tfql.parse("a = 1 OR b = 2 AND c = 3").where

    assert isinstance(tree, tfql.Group) and tree.op == "or"
    assert isinstance(tree.args[1], tfql.Group) and tree.args[1].op == "and"


def test_keywords_ignore_case_and_strings_keep_it() -> None:
    query = tfql.parse('A = "MiXed" aNd b iS eMpTy Order By a DeSc')

    assert query.order[0].desc is True
    assert isinstance(query.where, tfql.Group)
    assert query.where.args[0].values[0].text == "MiXed"  # type: ignore[union-attr]


def test_a_string_unescapes_quotes_and_backslashes() -> None:
    value = tfql.parse(r'a = "x\"y\\z"').where.values[0]  # type: ignore[union-attr]

    assert value.text == 'x"y\\z' and value.kind == "string"


def test_limits_stop_abuse() -> None:
    with pytest.raises(QueryError):
        tfql.parse("a = 1 " * 400)
    with pytest.raises(QueryError):
        tfql.parse("(" * 20 + "a = 1" + ")" * 20)
    with pytest.raises(QueryError):
        tfql.parse("NOT " * 20 + "a = 1")
    with pytest.raises(QueryError):
        tfql.parse(" AND ".join(f"a = {i}" for i in range(60)))
    with pytest.raises(QueryError):
        tfql.parse("a in (" + ",".join(str(i) for i in range(150)) + ")")
    tfql.parse("(" * 7 + "a = 1" + ")" * 7)  # within the depth limit


def test_positions_count_characters() -> None:
    with pytest.raises(QueryError) as caught:
        tfql.parse('title = "é" AND ? = 1')

    assert caught.value.position == 16
