"""Finding tasks by a custom field's value. Phase 14's query language builds on this; every
lookup hits an index of ``FieldValue`` (``field`` + one typed column; multi-select: GIN)."""

from typing import Any, Final

from django.db import connection
from django.db.models import QuerySet

from infrastructure.customfields import types
from infrastructure.customfields.models import FieldDefinition, FieldType, FieldValue
from infrastructure.tasks.models import Task

OPERATORS: Final = {"eq": "", "gt": "__gt", "gte": "__gte", "lt": "__lt", "lte": "__lte"}
ORDERED: Final = frozenset({FieldType.NUMBER, FieldType.MONEY, FieldType.DATE})


def value_rows(field: FieldDefinition, operator: str, raw: str) -> QuerySet[FieldValue]:
    """The ``FieldValue`` rows of ``field`` whose value is ``operator`` ``raw``: ``eq`` for any
    type, ``gt gte lt lte`` for number, money and date, ``has`` for a multi-select option."""
    if operator == "has":
        if field.type != FieldType.MULTISELECT:
            raise types.invalid("'has' works on multi-select fields.")
        if raw not in types.option_ids(field.options):
            raise types.invalid("That option does not exist on this field.")
        rows = FieldValue.objects.filter(field=field)
        if connection.features.supports_json_field_contains:  # PostgreSQL: the GIN index
            return rows.filter(value_json__contains=[raw])
        return rows.filter(value_json__icontains=f'"{raw}"')  # option ids are hex: no false hits
    if operator not in OPERATORS or (operator != "eq" and field.type not in ORDERED):
        raise types.invalid(f"A {field.type} field cannot be filtered with {operator!r}.")
    stored = types.clean_value(field.type, field.options, raw, lambda user: user)
    column, probe = _column(field, stored)
    return FieldValue.objects.filter(field=field, **{column + OPERATORS[operator]: probe})


def _column(field: FieldDefinition, stored: types.Stored) -> tuple[str, Any]:
    if field.type == FieldType.MULTISELECT:
        return "value_json", stored.json
    if stored.day is not None:
        return "value_date", stored.day
    if stored.number is not None:
        return "value_number", stored.number
    return "value_text", stored.text


def tasks_with_value(field: FieldDefinition, operator: str, raw: str) -> QuerySet[Task]:
    """Live tasks of the field's project matching the filter."""
    rows = value_rows(field, operator, raw).values("task_id")
    return Task.objects.filter(project=field.project_id, deleted_at__isnull=True, pk__in=rows)
