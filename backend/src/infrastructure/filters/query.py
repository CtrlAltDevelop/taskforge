"""Applying a filter to a project's tasks: what the task services call.

The condition is added to the project's own live tasks, so a filter can only narrow what the
caller may already see (the project is loaded with ``visible_to`` first). A filter that does not
hold up is an ``ApiError`` (``FILTER_INVALID``) whose data says where (``position``, ``length``).
"""

import json
from collections.abc import Callable
from contextlib import contextmanager
from dataclasses import dataclass, field
from datetime import date
from typing import Any, Final

from django.db import OperationalError, connection, transaction
from django.db.models import Q

from infrastructure.common.errors import ApiError
from infrastructure.common.responses import ResponseTitle
from infrastructure.filters import compile as compiler
from infrastructure.filters import language
from infrastructure.filters.language import Catalogue, QueryError
from infrastructure.projects.models import Project
from infrastructure.workspaces.models import Workspace

STATEMENT_TIMEOUT_MS: Final = 5000


@dataclass(frozen=True, slots=True)
class Prepared:
    where: Q = field(default_factory=Q)
    order: list[tuple[str, bool]] = field(default_factory=list)


NOTHING = Prepared()


def invalid(error: QueryError) -> ApiError:
    return ApiError(
        error.message,
        title=ResponseTitle.FILTER_INVALID,
        data={"position": error.position, "length": error.length},
    )


def _today(raw: str) -> date:
    if not raw:
        return date.today()
    try:
        return date.fromisoformat(raw)
    except ValueError:
        raise ApiError(
            "today is a date like 2026-11-05.", title=ResponseTitle.FILTER_INVALID
        ) from None


def _prepare(
    make_catalogue: Callable[[], Catalogue], filter_ast: str, today: str, actor: Any
) -> Prepared:
    if not filter_ast:
        return NOTHING
    try:
        raw = json.loads(filter_ast)
    except (ValueError, RecursionError):
        raise ApiError("The filter is not JSON.", title=ResponseTitle.FILTER_INVALID) from None
    cat = make_catalogue()
    try:
        ast = language.canonical(raw, cat)
        return Prepared(compiler.where(ast, cat, _today(today), actor), compiler.order(ast, cat))
    except QueryError as error:
        raise invalid(error) from None
    except RecursionError:
        raise ApiError("The filter nests too deeply.", title=ResponseTitle.FILTER_INVALID) from None


def prepare(project: Project, filter_ast: str, today: str, actor: Any) -> Prepared:
    """The condition and ordering of ``filter_ast`` (a JSON AST; empty: no filter) for
    ``project``. ``today`` (``YYYY-MM-DD``, default the server's) is what relative dates count
    from."""
    return _prepare(lambda: Catalogue(project), filter_ast, today, actor)


def prepare_workspace(workspace: Workspace, filter_ast: str, today: str, actor: Any) -> Prepared:
    """The same for a filter over every project of ``workspace``: only the fields that mean the
    same in every project (no status, id, sprint or custom field)."""
    return _prepare(lambda: Catalogue(None, workspace), filter_ast, today, actor)


@contextmanager
def _time_limit() -> Any:
    """On PostgreSQL, a statement that runs longer than ``STATEMENT_TIMEOUT_MS`` is cancelled
    (``SET LOCAL``: only inside this transaction); elsewhere no limit."""
    if connection.vendor != "postgresql":
        yield
        return
    with transaction.atomic(), connection.cursor() as cursor:
        cursor.execute("SET LOCAL statement_timeout = %s", [STATEMENT_TIMEOUT_MS])
        yield


class StatementTimeout(Exception):  # noqa: N818 - a condition, not an error of the caller's making
    """A query ran past ``STATEMENT_TIMEOUT_MS`` (PostgreSQL cancelled it)."""


def timed[T](read: Callable[[], T]) -> T:
    """``read()`` (which must run its query to completion) under the time limit, whatever it
    asks. Running out of time is a ``StatementTimeout`` the caller words for its own users."""
    try:
        with _time_limit():
            return read()
    except OperationalError as error:
        if "statement timeout" not in str(error).lower():
            raise
        raise StatementTimeout from None


def guarded[T](read: Callable[[], T], where: Q) -> T:
    """``read()`` under the time limit when it is filtered by ``where``. A query that runs out of
    time is an ``ApiError`` asking for a narrower filter."""
    if not where:
        return read()
    try:
        return timed(read)
    except StatementTimeout:
        raise ApiError(
            "This filter takes too long to run. Narrow it down.",
            title=ResponseTitle.FILTER_INVALID,
        ) from None
