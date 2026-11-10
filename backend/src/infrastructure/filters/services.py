"""Checking a query, suggesting what comes next, and saved filters.

Anyone who can open a project may validate and suggest for it and keep private filters there. A
filter shared with the project needs ``project.update`` (and a project that is not archived); one
shared with the workspace needs ``workspace.update``. A filter without a project can only use the
built-in fields that need no project (no status, no custom field).
"""

import json
import uuid
from dataclasses import dataclass
from typing import Any, Final

from django.db import IntegrityError, transaction
from django.db.models import Count, Q, QuerySet
from django.utils import timezone

from infrastructure.common.errors import ApiError
from infrastructure.common.responses import ResponseTitle
from infrastructure.filters import language, tfql
from infrastructure.filters.language import (
    KIND_OPS,
    SYMBOL_BY_OP,
    Catalogue,
    QueryError,
)
from infrastructure.filters.models import SavedFilter, Visibility
from infrastructure.projects import services as projects
from infrastructure.projects.models import Project
from infrastructure.tasks import services as task_services
from infrastructure.workspaces import access
from infrastructure.workspaces.models import Workspace

VIEW = "workspace.view"
MANAGE_PROJECT = "project.update"
MANAGE_WORKSPACE = "workspace.update"
MAX_PER_SCOPE: Final = 100
MAX_NAME: Final = 60
MAX_SUGGESTIONS: Final = 30


def not_found() -> ApiError:
    return ApiError("No such filter.", status=404)


def _catalogue(actor: Any, workspace: Workspace, project_id: str) -> Catalogue:
    if project_id:
        return Catalogue(task_services.project_for_view(actor, workspace, project_id))
    access.require(actor, VIEW, workspace)
    return Catalogue(None, workspace)


@dataclass(frozen=True, slots=True)
class Checked:
    """A query read: its ``ast`` and the ``tfql`` text it renders to, or its ``errors``."""

    ast: dict[str, Any] | None = None
    tfql: str = ""
    errors: tuple[QueryError, ...] = ()


def check(cat: Catalogue, text: str = "", ast: Any = None) -> Checked:
    """The AST and normal text of ``text`` (TFQL) or, when that is empty, of ``ast``."""
    try:
        found = (
            language.parse_text(text, cat)
            if (text.strip() or ast is None)
            else language.canonical(ast, cat)
        )
        return Checked(found, language.render(found, cat))
    except QueryError as error:
        return Checked(errors=(error,))


def validate(
    actor: Any, workspace: Workspace, project_id: str, text: str = "", ast_json: str = ""
) -> Checked:
    cat = _catalogue(actor, workspace, project_id)
    try:
        ast = json.loads(ast_json) if ast_json else None
    except (ValueError, RecursionError):
        return Checked(errors=(QueryError("The filter is not JSON.", 0, 1),))
    return check(cat, text, ast)


# -------------------------------------------------------------------------------- suggestions


@dataclass(frozen=True, slots=True)
class Suggestion:
    text: str  # what to put in
    kind: str  # field | operator | value | keyword
    start: int  # where in the query it replaces from (to the cursor)
    label: str = ""


def _quoted(text: str) -> str:
    return language._quote(text)


def _values_for(cat: Catalogue, spec: language.Field) -> list[str]:
    kind = spec.kind
    if kind == "status":
        return [language._word(s.name) for s in cat.statuses]
    if kind == "priority":
        return ["urgent", "high", "normal", "low", "none"]
    if kind == "category":
        return ["not_started", "active", "done", "cancelled"]
    if kind == "bool":
        return ["true", "false"]
    if kind in ("select", "multiselect"):
        return [language._word(label) for _, label in spec.options]
    if kind == "user":
        return ["me", *(language._word(u.username) for u in cat.users().values())]
    if kind in ("date", "datetime"):
        return ["today", "+7d", "-7d", "+1m", "-1m"]
    if kind == "sprint":
        return ["currentSprint()"]
    return []


def suggest(
    actor: Any, workspace: Workspace, project_id: str, partial: str, cursor: int
) -> list[Suggestion]:
    """What could come next at ``cursor`` in ``partial``: field names, then the operators that
    field takes, then its values, then AND / OR / ORDER BY. Only what starts like the word being
    typed."""
    cat = _catalogue(actor, workspace, project_id)
    cursor = max(0, min(cursor, len(partial)))
    before = partial[:cursor]
    word = ""
    start = cursor
    tail = before.rstrip()
    if tail == before:  # the cursor is inside or at the end of a word
        i = len(before)
        while i > 0 and (before[i - 1].isalnum() or before[i - 1] in '_"+-'):
            i -= 1
        word, start = before[i:], i
    context = _context(before[:start], cat)
    found = [*_candidates(context, cat)]
    prefix = word.strip('"').lower()
    out = [
        Suggestion(text, kind, start, label)
        for text, kind, label in found
        if text.strip('"').lower().startswith(prefix) and text.strip('"').lower() != prefix
    ]
    return out[:MAX_SUGGESTIONS]


def _context(before: str, cat: Catalogue) -> tuple[str, language.Field | None, str | None]:
    """(what is expected, the field being filtered, its operator) after ``before``."""
    try:
        tokens = [t for t in tfql.tokenize(before) if t.kind != "end"]
    except QueryError:
        return ("none", None, None)
    expect, current, op = "field", None, None
    i = 0
    while i < len(tokens):
        t = tokens[i]
        low = t.text.lower()
        if t.kind == "word" and low == "order":
            return ("order", None, None) if i + 1 >= len(tokens) else ("order_field", None, None)
        if expect == "field" and (
            t.kind == "string" or (t.kind == "word" and low not in tfql.KEYWORDS)
        ):
            try:
                current = cat.find(t)
            except QueryError:
                return ("none", None, None)
            expect, op = "operator", None
        elif expect == "operator":
            if t.kind == "symbol" and t.text in tfql.COMPARATORS:
                op, expect = t.text, "value"
            elif t.kind == "word" and low == "not":
                op = "not"  # NOT IN: wait for the IN
            elif t.kind == "word" and low == "in":
                op, expect = "in", "list"
            elif t.kind == "word" and low == "is":
                op, expect = "is", "empty"
        elif expect == "empty":
            if t.kind == "word" and low == "empty":
                expect = "connector"
            # IS [NOT] EMPTY: the NOT keeps us here
        elif expect in ("value", "list"):
            if t.kind == "symbol" and t.text == "(":
                expect = "list"
            elif t.kind == "symbol" and t.text == ")" or expect == "value" and t.kind != "symbol":
                expect = "connector"
        elif expect == "connector" and t.kind == "word" and low in ("and", "or", "not"):
            expect = "field"
        i += 1
    last = tokens[-1] if tokens else None
    if (
        last is not None
        and last.kind == "word"
        and last.text.lower() in ("and", "or", "not")
        and expect not in ("empty", "operator")  # IS NOT / NOT IN are not a new condition
    ):
        expect = "field"
    if tokens and tokens[-1].kind == "symbol" and tokens[-1].text in (",",):
        expect = "list"
    return (expect, current, op)


def _candidates(context: tuple[str, language.Field | None, str | None], cat: Catalogue) -> Any:
    expect, spec, _ = context
    if expect == "field" or expect == "order_field":
        for name in cat.field_names():
            builtin = name in cat.builtin
            yield (name if builtin else _quoted(name), "field", "built-in" if builtin else "custom")
        if expect == "field":
            yield ("NOT", "keyword", "")
    elif expect == "operator" and spec is not None:
        for op in KIND_OPS[spec.kind]:
            if op in SYMBOL_BY_OP:
                yield (SYMBOL_BY_OP[op], "operator", op)
        if any(o in KIND_OPS[spec.kind] for o in ("in", "empty")):
            yield ("IN", "operator", "in")
            yield ("IS EMPTY", "operator", "empty")
    elif expect in ("value", "list") and spec is not None:
        for value in _values_for(cat, spec):
            yield (value, "value", spec.name)
    elif expect == "empty":
        yield ("EMPTY", "keyword", "")
        yield ("NOT EMPTY", "keyword", "")
    elif expect == "order":
        yield ("BY", "keyword", "")
    elif expect == "connector":
        yield ("AND", "keyword", "")
        yield ("OR", "keyword", "")
        yield ("ORDER BY", "keyword", "")


# ----------------------------------------------------------------------------- saved filters


def _scope_project(actor: Any, workspace: Workspace, project_id: str) -> Project | None:
    if not project_id:
        access.require(actor, VIEW, workspace)
        return None
    return task_services.project_for_view(actor, workspace, project_id)


def _visible(workspace: Workspace, project: Project | None, actor: Any) -> QuerySet[SavedFilter]:
    mine = Q(visibility=Visibility.PRIVATE, owner=actor)
    shared = Q(visibility=Visibility.WORKSPACE, project__isnull=True)
    if project is not None:
        shared |= Q(visibility=Visibility.PROJECT, project=project)
        return SavedFilter.objects.filter(workspace=workspace).filter(
            (mine & Q(project=project)) | (mine & Q(project__isnull=True)) | shared
        )
    return SavedFilter.objects.filter(workspace=workspace, project__isnull=True).filter(
        mine | shared
    )


def list_filters(
    actor: Any, workspace: Workspace, project_id: str = ""
) -> list[tuple[SavedFilter, str]]:
    """The filters the caller may use in the project (or, with no project, at workspace level),
    shared ones first, each with its text rendered with today's names. One that no longer holds
    up (a field was removed) is listed with an empty text."""
    project = _scope_project(actor, workspace, project_id)
    cat = Catalogue(project, workspace)
    rows = sorted(
        _visible(workspace, project, actor),
        key=lambda f: (f.visibility == Visibility.PRIVATE, f.name.lower()),
    )
    return [(row, _text_of(row, cat)) for row in rows]


def _text_of(row: SavedFilter, cat: Catalogue) -> str:
    try:
        return language.render(row.ast, cat)
    except QueryError:
        return ""


def _name(raw: str) -> str:
    name = raw.strip()
    if not 1 <= len(name) <= MAX_NAME:
        raise ApiError(
            f"A filter's name is 1 to {MAX_NAME} characters.", title=ResponseTitle.FILTER_INVALID
        )
    return name


def _authorize(actor: Any, workspace: Workspace, project: Project | None, visibility: str) -> None:
    if visibility == Visibility.PRIVATE:
        return
    if visibility == Visibility.PROJECT:
        if project is None:
            raise ApiError(
                "A filter shared with a project needs one.", title=ResponseTitle.FILTER_INVALID
            )
        projects.authorize(actor, workspace, str(project.pk), MANAGE_PROJECT)
        projects.writable(project)
    elif visibility == Visibility.WORKSPACE:
        if project is not None:
            raise ApiError(
                "A filter for the whole workspace has no project.",
                title=ResponseTitle.FILTER_INVALID,
            )
        access.require(actor, MANAGE_WORKSPACE, workspace)
    else:
        raise ApiError(
            "A filter is private, project or workspace.", title=ResponseTitle.FILTER_INVALID
        )


def _room(workspace: Workspace, project: Project | None, visibility: str, actor: Any) -> None:
    scope = Q(workspace=workspace, project=project, visibility=visibility)
    if visibility == Visibility.PRIVATE:
        scope &= Q(owner=actor)
    if SavedFilter.objects.filter(scope).aggregate(n=Count("pk"))["n"] >= MAX_PER_SCOPE:
        raise ApiError(
            f"At most {MAX_PER_SCOPE} filters fit in one place.", title=ResponseTitle.FILTER_LIMIT
        )


def save(
    actor: Any,
    workspace: Workspace,
    project_id: str,
    *,
    name: str,
    text: str = "",
    ast_json: str = "",
    visibility: str = Visibility.PRIVATE,
    filter_id: str = "",
    expected_version: int = 0,
) -> tuple[SavedFilter, str]:
    """Create a filter, or save ``filter_id`` (then ``expected_version`` is required). The query
    is ``text`` (TFQL) or, when that is empty, ``ast_json``. Returns it with its rendered text."""
    cleaned = _name(name)
    project = _scope_project(actor, workspace, project_id)
    cat = Catalogue(project, workspace)
    checked = validate_catalogue(cat, text, ast_json)
    try:
        with transaction.atomic():
            row = _write(
                actor,
                workspace,
                project,
                filter_id,
                expected_version,
                cleaned,
                visibility,
                checked.ast,
            )
    except IntegrityError:
        raise _name_taken() from None
    return row, checked.tfql


def validate_catalogue(cat: Catalogue, text: str, ast_json: str) -> Checked:
    try:
        ast = json.loads(ast_json) if ast_json else None
    except (ValueError, RecursionError):
        raise ApiError("The filter is not JSON.", title=ResponseTitle.FILTER_INVALID) from None
    checked = check(cat, text, ast)
    if checked.errors:
        from infrastructure.filters.query import invalid

        raise invalid(checked.errors[0])
    return checked


def _name_taken() -> ApiError:
    return ApiError(
        "A filter with that name already exists here.",
        status=409,
        title=ResponseTitle.FILTER_NAME_TAKEN,
    )


def _write(
    actor: Any,
    workspace: Workspace,
    project: Project | None,
    filter_id: str,
    expected_version: int,
    name: str,
    visibility: str,
    ast: dict[str, Any] | None,
) -> SavedFilter:
    _authorize(actor, workspace, project, visibility)
    if filter_id:
        row = _load(workspace, project, actor, filter_id, lock=True)
        if row.project_id != (project.pk if project else None):
            raise not_found()  # a filter is changed where it lives
        _can_change(actor, workspace, project, row)
        if expected_version != row.version:
            raise ApiError(
                "Someone else changed this filter first; reload and retry.",
                status=409,
                title=ResponseTitle.VERSION_CONFLICT,
                data={"version": row.version},
            )
        if row.visibility != visibility:
            _room(workspace, project, visibility, actor)
        row.version += 1
    else:
        _room(workspace, project, visibility, actor)
        row = SavedFilter(workspace=workspace, project=project, owner=actor)
    row.name, row.visibility, row.ast = name, visibility, ast or {"where": None, "order": []}
    row.updated_at = timezone.now()
    row.save()
    return row


def _load(
    workspace: Workspace, project: Project | None, actor: Any, filter_id: str, *, lock: bool = False
) -> SavedFilter:
    try:
        pk = uuid.UUID(str(filter_id))
    except ValueError:
        raise not_found() from None
    rows = _visible(workspace, project, actor).filter(pk=pk)
    row = (rows.select_for_update(of=("self",)) if lock else rows).first()
    if row is None:
        raise not_found()
    return row


def _can_change(
    actor: Any, workspace: Workspace, project: Project | None, row: SavedFilter
) -> None:
    """A private filter is its owner's; a shared one is changed by whoever may manage that scope."""
    if row.visibility == Visibility.PRIVATE:
        return  # visible only to its owner, so this is the owner
    _authorize(actor, workspace, project, row.visibility)


def delete(actor: Any, workspace: Workspace, project_id: str, filter_id: str) -> SavedFilter:
    project = _scope_project(actor, workspace, project_id)
    with transaction.atomic():
        row = _load(workspace, project, actor, filter_id, lock=True)
        _can_change(actor, workspace, project, row)
        row.delete()
    return row
