"""How the task list is ordered, grouped and paged.

A list is ordered by ``keys``: the group (if any), then the caller's sort keys, then ``tree_key``
(when the caller sorted nothing, so subtasks still follow their parent) and ``number``, which is
unique in a project and so makes the order total. Paging is keyset, never offset: the cursor holds
the key values of the last row sent and the next page asks for what sorts after them, so a page
costs the same however deep it is and a task edited meanwhile cannot make a row repeat or vanish
(it may move, which is what the list then shows).

Empty values sort last in both directions. Every key is a column, a join or a correlated subquery
over an indexed ``FieldValue`` row; nothing is sorted in Python.
"""

import base64
import binascii
import json
import uuid
from collections.abc import Callable, Sequence
from dataclasses import dataclass
from datetime import date, datetime
from decimal import Decimal, InvalidOperation
from typing import Any, Final

from django.db.models import Case, F, IntegerField, OuterRef, Q, QuerySet, Subquery, Value, When
from django.db.models.functions import Lower

from infrastructure.common.errors import ApiError
from infrastructure.customfields.models import FieldDefinition, FieldType, FieldValue
from infrastructure.projects.models import Project
from infrastructure.tasks.models import Priority, TaskAssignee

MAX_SORT: Final = 3
FIELD_PREFIX: Final = "field:"
SORT_KEYS: Final = (
    "title",
    "status",
    "priority",
    "start_date",
    "due_date",
    "created_at",
    "updated_at",
    "number",
)
GROUP_KEYS: Final = ("status", "assignee", "priority")
PRIORITY_ORDER: Final = (
    Priority.URGENT,
    Priority.HIGH,
    Priority.NORMAL,
    Priority.LOW,
    Priority.NONE,
)
_NUMERIC: Final = frozenset({FieldType.NUMBER, FieldType.MONEY, FieldType.CHECKBOX})
_TEXTUAL: Final = frozenset({FieldType.TEXT, FieldType.URL, FieldType.USER})

Load = Callable[[Any], Any]
_LOADERS: Final[dict[str, Load]] = {
    "str": str,
    "int": int,
    "num": lambda v: Decimal(str(v)),
    "date": date.fromisoformat,
    "dt": datetime.fromisoformat,
}


def refused(message: str) -> ApiError:
    return ApiError(message)


@dataclass(frozen=True, slots=True)
class Key:
    """One ordering column. ``expr`` is a model field name (used as is) or an expression
    (annotated); ``kind`` says how its value travels in a cursor."""

    expr: Any
    kind: str = "str"
    desc: bool = False


@dataclass(frozen=True, slots=True)
class Group:
    """What grouping by one thing means: the key that orders the groups and an expression whose
    value names a group (``""`` for the tasks that have none)."""

    order: Key
    ident: Any


def _rank(whens: Sequence[tuple[str, int]], column: str) -> Case:
    return Case(
        *(When(**{column: value}, then=Value(rank)) for value, rank in whens),
        output_field=IntegerField(),
    )


def _first_assignee() -> Subquery:
    return Subquery(
        TaskAssignee.objects.filter(task=OuterRef("pk")).order_by("id").values("user_id")[:1]
    )


def _field(project: Project, raw: str) -> FieldDefinition:
    try:
        pk = uuid.UUID(raw)
    except ValueError:
        raise refused("That custom field does not exist.") from None
    field = FieldDefinition.objects.filter(project=project, pk=pk, archived_at=None).first()
    if field is None:
        raise refused("That custom field does not exist.")
    return field


def _value(field: FieldDefinition, annotated: Any) -> Subquery:
    """The field's value on the outer task, as the column the type is stored in."""
    rows = FieldValue.objects.filter(task=OuterRef("pk"), field=field)
    return Subquery(rows.annotate(_v=annotated).values("_v")[:1])


def _field_key(field: FieldDefinition) -> Key:
    if field.type in _NUMERIC:
        return Key(_value(field, F("value_number")), "num")
    if field.type == FieldType.DATE:
        return Key(_value(field, F("value_date")), "date")
    if field.type in _TEXTUAL:
        return Key(_value(field, Lower("value_text")))
    if field.type == FieldType.SELECT:
        ranks = [(o["id"], i) for i, o in enumerate(field.options)]
        return Key(_value(field, _rank(ranks, "value_text")), "int")
    raise refused("A multi-select field cannot be sorted.")


def _sort_key(project: Project, name: str, desc: bool) -> Key:
    if name == "title":
        base = Key(Lower("title"))
    elif name == "status":
        base = Key(F("status__position"), "int")
    elif name == "priority":
        base = Key(_rank([(p, i) for i, p in enumerate(PRIORITY_ORDER)], "priority"), "int")
    elif name in ("start_date", "due_date"):
        base = Key(name, "date")
    elif name in ("created_at", "updated_at"):
        base = Key(name, "dt")
    elif name == "number":
        base = Key(name, "int")
    elif name.startswith(FIELD_PREFIX):
        base = _field_key(_field(project, name.removeprefix(FIELD_PREFIX)))
    else:
        raise refused(f"Cannot sort by {name!r}.")
    return Key(base.expr, base.kind, desc)


def group_of(project: Project, name: str) -> Group:
    if name == "status":
        return Group(Key(F("status__position"), "int"), F("status_id"))
    if name == "priority":
        order = _rank([(p, i) for i, p in enumerate(PRIORITY_ORDER)], "priority")
        return Group(Key(order, "int"), F("priority"))
    if name == "assignee":
        return Group(Key(_first_assignee()), _first_assignee())
    if name.startswith(FIELD_PREFIX):
        field = _field(project, name.removeprefix(FIELD_PREFIX))
        if field.type != FieldType.SELECT:
            raise refused("Tasks can be grouped by a select field only.")
        return Group(_field_key(field), _value(field, F("value_text")))
    raise refused(f"Cannot group by {name!r}.")


def _name(index: int, key: Key) -> str:
    return key.expr if isinstance(key.expr, str) else f"_k{index}"


def _dump(value: Any) -> Any:
    if value is None or isinstance(value, int):
        return value
    return value.isoformat() if isinstance(value, date | datetime) else str(value)


@dataclass(frozen=True, slots=True)
class Plan:
    keys: tuple[Key, ...]
    signature: str = ""  # the sort and grouping it was made for: a cursor only fits its own
    group: Group | None = None
    group_by: str = ""

    def order(self, rows: QuerySet[Any]) -> QuerySet[Any]:
        annotations = {
            _name(i, k): k.expr for i, k in enumerate(self.keys) if not isinstance(k.expr, str)
        }
        order = [
            F(_name(i, k)).desc(nulls_last=True) if k.desc else F(_name(i, k)).asc(nulls_last=True)
            for i, k in enumerate(self.keys)
        ]
        if self.group is not None:
            annotations["_gid"] = self.group.ident
        return rows.annotate(**annotations).order_by(*order, "number")

    def group_key_of(self, task: Any) -> str:
        """The id of the group ``task`` is listed under (``""``: the one for tasks with none)."""
        return _ident(getattr(task, "_gid", None), self.group_by == "assignee")

    def cursor_of(self, task: Any) -> str:
        values = [_dump(getattr(task, _name(i, k))) for i, k in enumerate(self.keys)]
        raw = json.dumps({"k": values, "n": task.number, "s": self.signature})
        return base64.urlsafe_b64encode(raw.encode()).decode()

    def _decode(self, cursor: str) -> tuple[list[Any], int]:
        try:
            body = json.loads(base64.urlsafe_b64decode(cursor.encode()))
            raw, number = body["k"], int(body["n"])
            if body["s"] != self.signature or len(raw) != len(self.keys):
                raise ValueError("another sort")
            values = [
                None if v is None else _LOADERS[k.kind](v)
                for v, k in zip(raw, self.keys, strict=True)
            ]
        except (ValueError, TypeError, KeyError, binascii.Error, InvalidOperation):
            raise refused("That cursor is not valid for this list.") from None
        return values, number

    def after(self, rows: QuerySet[Any], cursor: str) -> QuerySet[Any]:
        """``rows`` (already ordered) cut down to what sorts after ``cursor``."""
        values, number = self._decode(cursor)
        before_equal = Q()
        ahead = Q()
        for i, (key, value) in enumerate(zip(self.keys, values, strict=True)):
            name = _name(i, key)
            if value is not None:
                past = Q(**{f"{name}__lt" if key.desc else f"{name}__gt": value})
                ahead |= before_equal & (past | Q(**{f"{name}__isnull": True}))
            before_equal &= (
                Q(**{name: value}) if value is not None else Q(**{f"{name}__isnull": True})
            )
        return rows.filter(ahead | (before_equal & Q(number__gt=number)))


def archived(project: Project, name: str) -> bool:
    """Whether ``name`` is a custom field that has been archived since a layout chose it."""
    if not name.startswith(FIELD_PREFIX):
        return False
    try:
        pk = uuid.UUID(name.removeprefix(FIELD_PREFIX))
    except ValueError:
        return False
    gone = FieldDefinition.objects.filter(project=project, pk=pk, archived_at__isnull=False)
    return gone.exists()


def plan(project: Project, sort: Sequence[tuple[str, bool]], group_by: str) -> Plan:
    # A saved layout can name a field that was archived later: list as if it were not chosen.
    sort = [pair for pair in sort if not archived(project, pair[0])]
    group_by = "" if archived(project, group_by) else group_by
    if len(sort) > MAX_SORT:
        raise refused(f"Sort by at most {MAX_SORT} columns.")
    if len({name for name, _ in sort}) != len(sort):
        raise refused("Sort by each column once.")
    group = group_of(project, group_by) if group_by else None
    keys = [group.order] if group else []
    keys += [_sort_key(project, name, desc) for name, desc in sort]
    if not sort:
        keys.append(Key("tree_key"))
    signature = json.dumps([group_by, [list(pair) for pair in sort]])
    return Plan(tuple(keys), signature, group, group_by)


def _ident(value: Any, is_uuid: bool) -> str:
    if value is None:
        return ""
    if is_uuid:  # SQLite hands a subquery's uuid back as bare hex
        try:
            return str(uuid.UUID(str(value)))
        except ValueError:
            pass
    return str(value)


def counts(rows: QuerySet[Any], project: Project, group_by: str) -> list[tuple[str, int]]:
    """``(group id, tasks)`` in the order the groups appear in the list."""
    from django.db.models import Count

    group = group_of(project, group_by)
    found = (
        rows.annotate(_gid=group.ident, _gk=group.order.expr)
        .order_by(F("_gk").asc(nulls_last=True))
        .values("_gid", "_gk")
        .annotate(_n=Count("pk"))
    )
    return [(_ident(r["_gid"], group_by == "assignee"), r["_n"]) for r in found]
