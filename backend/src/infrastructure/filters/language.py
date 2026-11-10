"""What a TFQL query means for one project: fields, values, the filter's AST and its text.

``resolve`` turns the parser's tree into the **AST** (a JSON-friendly dict) that is stored and
sent between client and server. The AST names fields by id (a custom field is ``cf:<uuid>``) and
values by id (a status id, a user id, an option id), so a rename never breaks a saved filter; the
text is re-rendered from it (``render``) with today's names. ``canonical`` takes an AST from
anywhere, writes it as text and reads it back, which both validates it (an unknown id is an error)
and gives its normal form: nothing from a client is trusted.

AST::

    {"where": node | None, "order": [{"field": ref, "desc": bool}]}
    node   := {"op": "and"|"or", "args": [node]} | {"op": "not", "arg": node}
            | {"op": "cmp", "field": ref, "cmp": cmp, "values": [value]}
    cmp    := eq ne lt lte gt gte contains not_contains in not_in empty not_empty
    value  := {"k": "text"|"id"|"num"|"date"|"bool"|"func", "v": ...} | {"k": "me"}
            | {"k": "rel", "n": int, "u": "d"|"w"|"m"|"y"}
"""

import re
from dataclasses import dataclass
from datetime import date
from decimal import Decimal, InvalidOperation
from typing import Any, Final

from django.contrib.auth import get_user_model

from infrastructure.customfields.models import FieldDefinition, FieldType
from infrastructure.filters import tfql
from infrastructure.filters.tfql import QueryError
from infrastructure.projects.models import Project
from infrastructure.tasks.models import Priority
from infrastructure.workflows.models import Category, Status
from infrastructure.workspaces.models import MemberStatus, WorkspaceMember

OPS_BY_SYMBOL: Final = {
    "=": "eq",
    "!=": "ne",
    "~": "contains",
    "!~": "not_contains",
    "<": "lt",
    "<=": "lte",
    ">": "gt",
    ">=": "gte",
    "in": "in",
    "not_in": "not_in",
    "empty": "empty",
    "not_empty": "not_empty",
}
SYMBOL_BY_OP: Final = {
    "eq": "=",
    "ne": "!=",
    "contains": "~",
    "not_contains": "!~",
    "lt": "<",
    "lte": "<=",
    "gt": ">",
    "gte": ">=",
}
EMPTINESS: Final = ("empty", "not_empty")
LISTS: Final = ("in", "not_in")
ORDERING: Final = ("lt", "lte", "gt", "gte")
KIND_OPS: Final = {
    "text": ("eq", "ne", "contains", "not_contains", *LISTS, *EMPTINESS),
    "status": ("eq", "ne", *LISTS),
    "category": ("eq", "ne", *LISTS),
    "priority": ("eq", "ne", *LISTS),
    "select": ("eq", "ne", *LISTS, *EMPTINESS),
    "multiselect": ("eq", "ne", *LISTS, *EMPTINESS),
    "user": ("eq", "ne", *LISTS, *EMPTINESS),
    "date": ("eq", "ne", *ORDERING, *EMPTINESS),
    "datetime": ("eq", "ne", *ORDERING),
    "number": ("eq", "ne", *ORDERING, *EMPTINESS),
    "bool": ("eq", "ne"),
    "id": ("eq", "ne", *LISTS),
    "sprint": ("eq", "ne"),
}
MAX_ORDER: Final = 3  # what a list can sort by (``tasks.listing.MAX_SORT``)
RELATIVE_UNITS: Final = ("d", "w", "m", "y")
MAX_RELATIVE: Final = {"d": 36500, "w": 5200, "m": 1200, "y": 100}  # about a century either way
BARE: Final = re.compile(r"[A-Za-z_][A-Za-z0-9_]*\Z")
RESERVED: Final = frozenset(tfql.KEYWORDS | {"me", "today", "true", "false", "null"})
CUSTOM_PREFIX: Final = "cf:"
CATEGORIES: Final = {value: value for value in Category.values}


@dataclass(frozen=True, slots=True)
class Field:
    ref: str  # a built-in's name, or cf:<uuid>
    name: str
    kind: str
    options: tuple[tuple[str, str], ...] = ()  # (id, label) of a select field
    sort_key: str = ""  # what ORDER BY sorts by ("" when it cannot be sorted)


BUILTINS: Final = (
    Field("title", "title", "text", sort_key="title"),
    Field("status", "status", "status", sort_key="status"),
    Field("category", "category", "category"),
    Field("priority", "priority", "priority", sort_key="priority"),
    Field("assignee", "assignee", "user"),
    Field("due", "due", "date", sort_key="due_date"),
    Field("start", "start", "date", sort_key="start_date"),
    Field("created", "created", "datetime", sort_key="created_at"),
    Field("updated", "updated", "datetime", sort_key="updated_at"),
    Field("blocked", "blocked", "bool"),
    Field("id", "id", "id", sort_key="number"),
    Field("sprint", "sprint", "sprint"),
)
_CUSTOM_KINDS: Final = {
    FieldType.TEXT: "text",
    FieldType.URL: "text",
    FieldType.NUMBER: "number",
    FieldType.MONEY: "number",
    FieldType.SELECT: "select",
    FieldType.MULTISELECT: "multiselect",
    FieldType.DATE: "date",
    FieldType.CHECKBOX: "bool",
    FieldType.USER: "user",
}


class Catalogue:
    """What a project's queries can name: its fields, statuses, options and people."""

    def __init__(self, project: Project | None) -> None:
        self.project = project
        self.builtin = {f.name: f for f in BUILTINS}
        self.custom: dict[str, Field] = {}
        self.definitions: dict[str, FieldDefinition] = {}
        self.statuses: list[Status] = []
        self._users: dict[str, Any] | None = None
        if project is None:
            return
        self.statuses = list(Status.objects.filter(project=project))
        for definition in FieldDefinition.objects.filter(project=project, archived_at__isnull=True):
            kind = _CUSTOM_KINDS[definition.type]
            options = tuple((o["id"], o["label"]) for o in definition.options)
            self.definitions[f"{CUSTOM_PREFIX}{definition.pk}"] = definition
            self.custom[definition.name.lower()] = Field(
                f"{CUSTOM_PREFIX}{definition.pk}",
                definition.name,
                kind,
                options,
                sort_key=f"field:{definition.pk}" if definition.type != "multiselect" else "",
            )

    # ------------------------------------------------------------------------ fields

    def find(self, token: tfql.Token) -> Field:
        name = token.text.lower()
        if token.kind == "string" and name in self.custom:
            return self.custom[name]
        if name in self.builtin:
            return self.builtin[name]
        if name in self.custom:
            return self.custom[name]
        raise QueryError(f"Unknown field {token.text!r}.", token.pos, token.length)

    def by_ref(self, ref: str) -> Field:
        if ref in self.builtin:
            return self.builtin[ref]
        for found in self.custom.values():
            if found.ref == ref:
                return found
        raise QueryError("That field no longer exists.", 0, 1)

    def field_names(self) -> list[str]:
        return [*self.builtin, *(f.name for f in self.custom.values())]

    # ------------------------------------------------------------------------ people

    def users(self) -> dict[str, Any]:
        """username (lower case) -> user, for the active members of the project's workspace."""
        if self._users is None:
            if self.project is None:
                self._users = {}
            else:
                active = WorkspaceMember.objects.filter(
                    workspace_id=self.project.workspace_id, status=MemberStatus.ACTIVE
                ).values_list("user_id", flat=True)
                found = get_user_model().objects.filter(pk__in=active)
                self._users = {u.username.lower(): u for u in found}
        return self._users

    def username_of(self, user_id: str) -> str | None:
        for user in self.users().values():
            if str(user.pk) == user_id:
                return str(user.username)
        return None


# ------------------------------------------------------------------------------- resolving


def _as_text(value: tfql.Value) -> str:
    return value.text


def _bad(value: tfql.Value, message: str) -> QueryError:
    return QueryError(message, value.pos, value.length)


def _pick(value: tfql.Value, choices: dict[str, str], what: str) -> str:
    found = choices.get(
        value.text.lower().replace(" ", "_") if what == "category" else value.text.lower()
    )
    if found is None:
        raise _bad(value, f"Unknown {what} {value.text!r}.")
    return found


def _date_value(value: tfql.Value) -> dict[str, Any]:
    if value.kind == "date":
        try:
            return {"k": "date", "v": date.fromisoformat(value.text).isoformat()}
        except ValueError:
            raise _bad(value, f"{value.text} is not a real date.") from None
    if value.kind == "rel":
        n, unit = int(value.text[:-1]), value.text[-1]
        if abs(n) > MAX_RELATIVE[unit]:
            raise _bad(value, f"A relative date reaches at most {MAX_RELATIVE[unit]}{unit}.")
        return {"k": "rel", "n": n, "u": unit}
    if value.kind == "word" and value.text.lower() == "today":
        return {"k": "rel", "n": 0, "u": "d"}
    raise _bad(value, "Expected a date (2026-11-05), a relative date (+7d, -2w) or today.")


def _number_value(value: tfql.Value) -> dict[str, Any]:
    if value.kind not in ("number", "string", "word"):
        raise _bad(value, "Expected a number.")
    try:
        number = Decimal(value.text)
    except InvalidOperation:
        raise _bad(value, f"{value.text!r} is not a number.") from None
    if not number.is_finite() or abs(number) > Decimal(10) ** 18:
        raise _bad(value, "That number is out of range.")
    return {"k": "num", "v": format(number.normalize(), "f")}


def _value(spec: Field, value: tfql.Value, cat: Catalogue) -> dict[str, Any]:
    kind = spec.kind
    if kind == "text":
        return {"k": "text", "v": _as_text(value)}
    if kind in ("date", "datetime"):
        return _date_value(value)
    if kind == "number":
        return _number_value(value)
    if kind == "bool":
        if value.kind == "word" and value.text.lower() in ("true", "false"):
            return {"k": "bool", "v": value.text.lower() == "true"}
        raise _bad(value, "Expected true or false.")
    if kind == "sprint":
        if value.kind == "func" and value.text.lower() == "currentsprint":
            return {"k": "func", "v": "currentSprint"}
        raise _bad(value, "A sprint is currentSprint() for now.")
    if kind == "status":
        names = {s.name.lower(): str(s.pk) for s in cat.statuses}
        return {"k": "id", "v": _pick(value, names, "status")}
    if kind == "category":
        return {"k": "id", "v": _pick(value, CATEGORIES, "category")}
    if kind == "priority":
        return {
            "k": "id",
            "v": _pick(value, {value: value for value in Priority.values}, "priority"),
        }
    if kind in ("select", "multiselect"):
        options = {label.lower(): oid for oid, label in spec.options}
        return {"k": "id", "v": _pick(value, options, f"option of {spec.name}")}
    if kind == "user":
        if value.kind == "word" and value.text.lower() == "me":
            return {"k": "me"}
        user = cat.users().get(value.text.lower())
        if user is None:
            raise _bad(value, f"Nobody is called {value.text!r}.")
        return {"k": "id", "v": str(user.pk)}
    if kind == "id":
        return _id_value(value, cat)
    raise _bad(value, "That value is not allowed here.")  # unreachable: every kind is above


def _id_value(value: tfql.Value, cat: Catalogue) -> dict[str, Any]:
    text = value.text
    key = cat.project.key if cat.project else ""
    if "-" in text:
        prefix, _, rest = text.rpartition("-")
        if prefix.lower() != key.lower():
            raise _bad(value, f"{text!r} is not a task of this project.")
        text = rest
    if not text.isdigit() or int(text) > 2**31:
        raise _bad(value, 'Expected a task number like 12, or a quoted id like "WEB-12".')
    return {"k": "num", "v": text}


def _cmp(node: tfql.Cmp, cat: Catalogue) -> dict[str, Any]:
    spec = cat.find(node.field)
    op = OPS_BY_SYMBOL[node.op]
    if op not in KIND_OPS[spec.kind]:
        shown = node.op if node.op in SYMBOL_BY_OP.values() else node.op.replace("_", " ").upper()
        raise QueryError(f"{spec.name} cannot be filtered with {shown}.", node.pos, node.length)
    values = [_value(spec, v, cat) for v in node.values]
    return {"op": "cmp", "field": spec.ref, "cmp": op, "values": values}


def _node(node: tfql.Node, cat: Catalogue) -> dict[str, Any]:
    if isinstance(node, tfql.Cmp):
        return _cmp(node, cat)
    if isinstance(node, tfql.Not):
        return {"op": "not", "arg": _node(node.arg, cat)}
    args: list[dict[str, Any]] = []
    for child in node.args:
        built = _node(child, cat)
        # a AND (b AND c) is a AND b AND c: one normal form for the same meaning
        args.extend(built["args"] if built["op"] == node.op else [built])
    return {"op": node.op, "args": args}


def resolve(query: tfql.Query, cat: Catalogue) -> dict[str, Any]:
    """The AST of a parsed query for ``cat``'s project, or a ``QueryError`` at the culprit."""
    order: list[dict[str, Any]] = []
    for item in query.order:
        spec = cat.find(item.field)
        if len(order) >= MAX_ORDER:
            raise QueryError(
                f"Order by at most {MAX_ORDER} fields.", item.field.pos, item.field.length
            )
        if any(o["field"] == spec.ref for o in order):
            raise QueryError(f"Order by {spec.name} once.", item.field.pos, item.field.length)
        if not spec.sort_key:
            raise QueryError(f"Cannot order by {spec.name}.", item.field.pos, item.field.length)
        order.append({"field": spec.ref, "desc": item.desc})
    where = None if query.where is None else _node(query.where, cat)
    return {"where": where, "order": order}


def parse_text(source: str, cat: Catalogue) -> dict[str, Any]:
    return resolve(tfql.parse(source), cat)


# --------------------------------------------------------------------------------- rendering


def _quote(text: str) -> str:
    return '"' + text.replace("\\", "\\\\").replace('"', '\\"') + '"'


def _word(text: str) -> str:
    return text if BARE.match(text) and text.lower() not in RESERVED else _quote(text)


def _field_text(spec: Field) -> str:
    if spec.ref.startswith(CUSTOM_PREFIX):
        return _quote(spec.name)
    return spec.name


def _value_text(spec: Field, value: dict[str, Any], cat: Catalogue) -> str:
    kind = value["k"]
    if kind == "text":
        return _quote(str(value["v"]))
    if kind == "date":
        return str(date.fromisoformat(str(value["v"])))
    if kind == "rel":
        n, unit = int(value["n"]), str(value["u"])
        if unit not in RELATIVE_UNITS or abs(n) > MAX_RELATIVE[unit]:
            raise QueryError("Unknown date unit.", 0, 1)
        return "today" if n == 0 else f"{n:+d}{unit}"
    if kind == "num":
        return format(Decimal(str(value["v"])), "f")
    if kind == "bool":
        return "true" if value["v"] else "false"
    if kind == "func":
        return "currentSprint()"
    if kind == "me":
        return "me"
    if kind != "id":
        raise QueryError("Unknown value.", 0, 1)
    ident = str(value["v"])
    if spec.kind == "status":
        found = next((s.name for s in cat.statuses if str(s.pk) == ident), None)
    elif spec.kind == "user":
        found = cat.username_of(ident)
    elif spec.kind in ("select", "multiselect"):
        found = dict(spec.options).get(ident)
    else:  # priority, category
        found = ident
    if found is None:
        raise QueryError("A value in this filter no longer exists.", 0, 1)
    return _word(found)


def _cmp_text(node: dict[str, Any], cat: Catalogue) -> str:
    spec = cat.by_ref(str(node["field"]))
    op = str(node["cmp"])
    name = _field_text(spec)
    values = [_value_text(spec, v, cat) for v in node["values"]]
    if op in EMPTINESS:
        return f"{name} IS {'NOT ' if op == 'not_empty' else ''}EMPTY"
    if op in LISTS:
        return f"{name} {'NOT ' if op == 'not_in' else ''}IN ({', '.join(values)})"
    return f"{name} {SYMBOL_BY_OP[op]} {values[0]}"


def _group_text(node: dict[str, Any], cat: Catalogue, parent: str | None) -> str:
    kind = node["op"]
    if kind == "cmp":
        return _cmp_text(node, cat)
    if kind == "not":
        arg = node["arg"]
        inner = _group_text(arg, cat, "not")
        return f"NOT {inner}" if arg["op"] in ("cmp", "not") else f"NOT ({inner})"
    joiner = f" {kind.upper()} "
    text = joiner.join(_group_text(child, cat, kind) for child in node["args"])
    return f"({text})" if parent is not None and parent != kind and parent != "not" else text


def render(ast: dict[str, Any], cat: Catalogue) -> str:
    """The AST as TFQL text with the project's current names."""
    try:
        parts = []
        if ast.get("where") is not None:
            parts.append(_group_text(ast["where"], cat, None))
        order = ast.get("order") or []
        if order:
            items = [
                f"{_field_text(cat.by_ref(str(o['field'])))}{' DESC' if o.get('desc') else ''}"
                for o in order
            ]
            parts.append("ORDER BY " + ", ".join(items))
        return " ".join(parts)
    except QueryError:
        raise
    except (
        KeyError,
        TypeError,
        AttributeError,
        ValueError,
        IndexError,
        InvalidOperation,
        RecursionError,
    ):
        raise QueryError("This filter is not valid.", 0, 1) from None


def canonical(ast: Any, cat: Catalogue) -> dict[str, Any]:
    """A client's AST checked and in normal form (via its text), or a ``QueryError``."""
    if not isinstance(ast, dict):
        raise QueryError("This filter is not valid.", 0, 1)
    return parse_text(render(ast, cat), cat)
