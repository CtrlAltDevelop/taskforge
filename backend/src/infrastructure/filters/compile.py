"""A filter's AST as an ORM query. Values only ever travel as query parameters: the AST holds
ids, numbers and dates that ``language.canonical`` has already checked, and text is matched with
``iexact`` / ``icontains``, so nothing a person types is run as SQL.

Not-equal and "not in" include tasks that have no value at all. Dates compare as calendar days
(``created`` and ``updated`` by their UTC day); ``today`` and relative dates count from the
``today`` given (a client passes its own, so "today" is the viewer's day).
"""

import calendar
from datetime import date, timedelta
from decimal import Decimal
from typing import Any, Final

from django.db import connection
from django.db.models import Exists, OuterRef, Q

from infrastructure.customfields.models import FieldValue
from infrastructure.filters.language import CUSTOM_PREFIX, Catalogue
from infrastructure.tasks.models import LinkType, TaskAssignee, TaskLink
from infrastructure.tasks.tree import FINAL

NEGATED: Final = {"ne": "eq", "not_in": "in", "not_contains": "contains", "not_empty": "empty"}
DATE_COLUMNS: Final = {"due": "due_date", "start": "start_date"}
DAY_COLUMNS: Final = {"created": "created_at__date", "updated": "updated_at__date"}
LOOKUPS: Final = {"lt": "__lt", "lte": "__lte", "gt": "__gt", "gte": "__gte", "eq": ""}


def _shift(day: date, n: int, unit: str) -> date:
    try:
        return _move(day, n, unit)
    except (OverflowError, ValueError):  # past the calendar's ends: stop at them
        return date.max if n > 0 else date.min


def _move(day: date, n: int, unit: str) -> date:
    if unit == "d":
        return day + timedelta(days=n)
    if unit == "w":
        return day + timedelta(weeks=n)
    months = n if unit == "m" else 12 * n
    index = day.year * 12 + (day.month - 1) + months
    year, month = divmod(index, 12)
    last = calendar.monthrange(year, month + 1)[1]
    return date(year, month + 1, min(day.day, last))


class _Context:
    def __init__(self, cat: Catalogue, today: date, actor: Any) -> None:
        self.cat, self.today, self.actor = cat, today, actor

    def day(self, value: dict[str, Any]) -> date:
        if value["k"] == "rel":
            return _shift(self.today, int(value["n"]), str(value["u"]))
        return date.fromisoformat(str(value["v"]))

    def user_id(self, value: dict[str, Any]) -> Any:
        return self.actor.pk if value["k"] == "me" else value["v"]


def _positive_task(ctx: _Context, ref: str, op: str, values: list[dict[str, Any]]) -> Q:
    """A condition on a task's own columns (``op`` is never a negated one)."""
    first = values[0] if values else {}
    if ref == "title":
        if op == "empty":
            return Q(title="")
        texts = [str(v["v"]) for v in values]
        if op == "contains":
            return Q(title__icontains=texts[0])
        return _any(Q(title__iexact=t) for t in texts)
    if ref == "status":
        return Q(status_id__in=[v["v"] for v in values])
    if ref == "category":
        return Q(status__category__in=[v["v"] for v in values])
    if ref == "priority":
        return Q(priority__in=[v["v"] for v in values])
    if ref == "assignee":
        rows = TaskAssignee.objects.filter(task=OuterRef("pk"))
        if op == "empty":
            return ~Q(Exists(rows))
        return Q(Exists(rows.filter(user_id__in=[ctx.user_id(v) for v in values])))
    if ref in DATE_COLUMNS or ref in DAY_COLUMNS:
        column = DATE_COLUMNS.get(ref) or DAY_COLUMNS[ref]
        if op == "empty":
            return Q(**{f"{column}__isnull": True})
        return Q(**{column + LOOKUPS[op]: ctx.day(first)})
    if ref == "blocked":
        open_blockers = TaskLink.objects.filter(type=LinkType.BLOCKS, to_task_id=OuterRef("pk"))
        open_blockers = open_blockers.filter(from_task__deleted_at__isnull=True).exclude(
            from_task__status__category__in=FINAL
        )
        wanted = Q(Exists(open_blockers))
        return wanted if first["v"] else ~wanted
    if ref == "id":
        return Q(number__in=[int(v["v"]) for v in values])
    if ref == "sprint":
        return Q(pk__in=[])  # sprints arrive with phase 22: nothing is in "the current sprint" yet
    raise ValueError(ref)


def _any(parts: Any) -> Q:
    combined = Q()
    for part in parts:
        combined |= part
    return combined


def _custom_rows(ctx: _Context, ref: str) -> Any:
    definition = ctx.cat.definitions[ref]
    return FieldValue.objects.filter(task=OuterRef("pk"), field=definition), definition


def _positive_custom(
    ctx: _Context, ref: str, kind: str, op: str, values: list[dict[str, Any]]
) -> Q:
    rows, _ = _custom_rows(ctx, ref)
    first = values[0] if values else {}
    if op == "empty":
        present = {
            "text": Q(~Q(value_text="")),
            "select": Q(~Q(value_text="")),
            "user": Q(~Q(value_text="")),
            "number": Q(value_number__isnull=False),
            "date": Q(value_date__isnull=False),
            "multiselect": Q(value_json__isnull=False) & ~Q(value_json=[]),
        }[kind]
        return ~Q(Exists(rows.filter(present)))
    if kind == "text":
        if op == "contains":
            return Q(Exists(rows.filter(value_text__icontains=str(first["v"]))))
        return Q(Exists(rows.filter(_any(Q(value_text__iexact=str(v["v"])) for v in values))))
    if kind == "number":
        return Q(Exists(rows.filter(**{"value_number" + LOOKUPS[op]: Decimal(str(first["v"]))})))
    if kind == "date":
        return Q(Exists(rows.filter(**{"value_date" + LOOKUPS[op]: ctx.day(first)})))
    if kind == "select":
        return Q(Exists(rows.filter(value_text__in=[v["v"] for v in values])))
    if kind == "user":
        return Q(Exists(rows.filter(value_text__in=[str(ctx.user_id(v)) for v in values])))
    if kind == "multiselect":
        return Q(Exists(rows.filter(_any(_has(v["v"]) for v in values))))
    if kind == "bool":
        ticked = Q(Exists(rows.filter(value_number=1)))
        return ticked if first["v"] else ~ticked  # a box nobody touched has no row: unticked
    raise ValueError(kind)


def _has(option_id: str) -> Q:
    if connection.features.supports_json_field_contains:  # PostgreSQL: the GIN index
        return Q(value_json__contains=[option_id])
    return Q(value_json__icontains=f'"{option_id}"')  # option ids are hex: no false hits


def _cmp(ctx: _Context, node: dict[str, Any]) -> Q:
    ref, op, values = str(node["field"]), str(node["cmp"]), list(node["values"])
    spec = ctx.cat.by_ref(ref)
    positive = NEGATED.get(op, op)
    if ref.startswith(CUSTOM_PREFIX):
        # eq on a multi-select is "has": the same as a one-value "in"
        found = _positive_custom(
            ctx,
            ref,
            spec.kind,
            "in"
            if positive == "eq" and spec.kind in ("multiselect", "select", "user")
            else positive,
            values,
        )
    else:
        found = _positive_task(
            ctx,
            ref,
            "in"
            if positive == "eq"
            and ref in ("status", "category", "priority", "assignee", "id", "title")
            else positive,
            values,
        )
    return ~found if op in NEGATED else found


def _node(ctx: _Context, node: dict[str, Any]) -> Q:
    kind = node["op"]
    if kind == "cmp":
        return _cmp(ctx, node)
    if kind == "not":
        return ~_node(ctx, node["arg"])
    parts = [_node(ctx, child) for child in node["args"]]
    combined = parts[0]
    for part in parts[1:]:
        combined = combined & part if kind == "and" else combined | part
    return combined


def where(ast: dict[str, Any], cat: Catalogue, today: date, actor: Any) -> Q:
    """The AST's condition as a ``Q`` on tasks (an empty ``Q`` for no condition)."""
    if ast.get("where") is None:
        return Q()
    return _node(_Context(cat, today, actor), ast["where"])


def order(ast: dict[str, Any], cat: Catalogue) -> list[tuple[str, bool]]:
    """The AST's ORDER BY as ``(sort key, descending)`` for ``tasks.listing``."""
    return [
        (cat.by_ref(str(o["field"])).sort_key, bool(o.get("desc"))) for o in ast.get("order", [])
    ]
