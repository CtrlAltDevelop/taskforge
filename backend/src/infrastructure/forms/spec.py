"""What a form is made of: the rules for saving a definition and the public view of one.

A form's ``fields`` is an ordered list of ``{id, kind, label, help, required, custom_field_id,
max_files}``. ``kind`` is ``title`` (exactly one, always required), ``description`` (at most one),
``custom`` (a custom field of the target project, answered with the same wire value as in the app)
or ``file`` (an upload). Person-type custom fields are never offered: they would list members.
"""

import re
import uuid
from typing import Any, Final

from django.conf import settings

from infrastructure.common.errors import ApiError
from infrastructure.common.responses import ResponseTitle
from infrastructure.customfields.models import FieldDefinition, FieldType
from infrastructure.projects.models import Project

TITLE: Final = "title"
DESCRIPTION: Final = "description"
CUSTOM: Final = "custom"
FILE: Final = "file"
KINDS: Final = (TITLE, DESCRIPTION, CUSTOM, FILE)
MAX_FIELDS: Final = 40
LABEL_MAX: Final = 120
HELP_MAX: Final = 300
NAME_MAX: Final = 80
DESCRIPTION_MAX: Final = 500
ID_PATTERN: Final = re.compile(r"[A-Za-z0-9_-]{1,40}")
COLOR_PATTERN: Final = re.compile(r"#[0-9A-Fa-f]{6}")
LOGO_PATTERN: Final = re.compile(r"https?://[^\s<>\"']+", re.IGNORECASE)
PRIORITIES: Final = ("none", "low", "medium", "high", "urgent")
UNOFFERED_TYPES: Final = frozenset({FieldType.USER})


def invalid(message: str) -> ApiError:
    return ApiError(message, title=ResponseTitle.VALIDATION_ERROR)


def clean_name(raw: str) -> str:
    name = " ".join(raw.split())
    if not name or len(name) > NAME_MAX:
        raise invalid(f"A form name is 1-{NAME_MAX} characters.")
    return name


def clean_description(raw: str) -> str:
    text = raw.strip()
    if len(text) > DESCRIPTION_MAX:
        raise invalid(f"A form description is at most {DESCRIPTION_MAX} characters.")
    return text


def clean_color(raw: str) -> str:
    color = raw.strip()
    if color and not COLOR_PATTERN.fullmatch(color):
        raise invalid("The brand color must look like #1a73e8.")
    return color.lower()


def clean_logo_url(raw: str) -> str:
    url = raw.strip()
    if not url:
        return ""
    if len(url) > 500 or not LOGO_PATTERN.fullmatch(url):
        raise invalid("The logo must be a web address starting with http:// or https://.")
    return url


def _text(value: Any, limit: int, what: str) -> str:
    text = " ".join(str(value or "").split())
    if len(text) > limit:
        raise invalid(f"A field's {what} is at most {limit} characters.")
    return text


def _custom_fields(project: Project) -> dict[str, FieldDefinition]:
    rows = FieldDefinition.objects.filter(project=project, archived_at__isnull=True)
    return {str(f.pk): f for f in rows}


def _clean_one(raw: Any, project_fields: dict[str, FieldDefinition]) -> dict[str, Any]:
    if not isinstance(raw, dict):
        raise invalid("A form field is malformed.")
    kind = str(raw.get("kind", ""))
    if kind not in KINDS:
        raise invalid(f"A field's kind must be one of: {', '.join(KINDS)}.")
    field_id = str(raw.get("id", ""))
    if not ID_PATTERN.fullmatch(field_id):
        raise invalid("A field id is 1-40 letters, digits, dashes or underscores.")
    clean: dict[str, Any] = {
        "id": field_id,
        "kind": kind,
        "label": _text(raw.get("label"), LABEL_MAX, "label"),
        "help": _text(raw.get("help"), HELP_MAX, "help text"),
        "required": bool(raw.get("required")) or kind == TITLE,
        "custom_field_id": "",
        "max_files": 0,
    }
    if kind == CUSTOM:
        target = str(raw.get("custom_field_id", ""))
        found = project_fields.get(target)
        if found is None:
            raise invalid("A custom field of this form no longer exists in the project.")
        if found.type in UNOFFERED_TYPES:
            raise invalid("Person fields cannot be on a public form.")
        clean["custom_field_id"] = target
        clean["label"] = clean["label"] or found.name
    elif kind == FILE:
        count = int(raw.get("max_files") or 1)
        if not 1 <= count <= settings.FORMS_MAX_FILES:
            raise invalid(f"A file field takes 1-{settings.FORMS_MAX_FILES} files.")
        clean["max_files"] = count
    if not clean["label"]:
        raise invalid("Every field needs a label.")
    return clean


def clean_fields(raw: Any, project: Project) -> list[dict[str, Any]]:
    """The saved shape of a definition, or a 422 saying what is wrong."""
    if not isinstance(raw, list) or not raw:
        raise invalid("A form needs at least a title field.")
    if len(raw) > MAX_FIELDS:
        raise invalid(f"A form has at most {MAX_FIELDS} fields.")
    project_fields = _custom_fields(project)
    cleaned = [_clean_one(item, project_fields) for item in raw]
    ids = [f["id"] for f in cleaned]
    if len(set(ids)) != len(ids):
        raise invalid("Two fields share an id.")
    if sum(f["kind"] == TITLE for f in cleaned) != 1:
        raise invalid("A form has exactly one title field.")
    if sum(f["kind"] == DESCRIPTION for f in cleaned) > 1:
        raise invalid("A form has at most one description field.")
    customs = [f["custom_field_id"] for f in cleaned if f["kind"] == CUSTOM]
    if len(set(customs)) != len(customs):
        raise invalid("A custom field is on the form twice.")
    return cleaned


def uncovered_required(project: Project, fields: list[dict[str, Any]]) -> list[str]:
    """Names of required project fields (without a default) the form does not ask for: every
    submission would be refused for them."""
    asked = {f["custom_field_id"] for f in fields if f["kind"] == CUSTOM}
    return [
        f.name
        for f in _custom_fields(project).values()
        if f.required and not f.default and str(f.pk) not in asked
    ]


def clean_defaults(raw: dict[str, Any], project: Project) -> dict[str, Any]:
    from infrastructure.workflows.models import Status
    from infrastructure.workspaces.models import MemberStatus, WorkspaceMember

    status_id = str(raw.get("status_id", ""))
    if status_id:
        try:
            exists = Status.objects.filter(project=project, pk=uuid.UUID(status_id)).exists()
        except ValueError:
            exists = False
        if not exists:
            raise invalid("The default status is not a status of this project.")
    priority = str(raw.get("priority") or "none")
    if priority not in PRIORITIES:
        raise invalid(f"The default priority must be one of: {', '.join(PRIORITIES)}.")
    assignees: list[str] = []
    for item in raw.get("assignee_ids", []):
        try:
            pk = str(uuid.UUID(str(item)))
        except ValueError:
            raise invalid("A default assignee is not a member.") from None
        if pk not in assignees:
            assignees.append(pk)
    if assignees:
        members = WorkspaceMember.objects.filter(
            workspace_id=project.workspace_id, user_id__in=assignees, status=MemberStatus.ACTIVE
        ).count()
        if members != len(assignees):
            raise invalid("A default assignee is not a member of this workspace.")
    return {"status_id": status_id, "priority": priority, "assignee_ids": assignees}


def public_fields(fields: list[dict[str, Any]], project: Project) -> list[dict[str, Any]]:
    """What a visitor is told about each field (types and choices, nothing else of the project)."""
    project_fields = _custom_fields(project)
    out: list[dict[str, Any]] = []
    for field in fields:
        entry: dict[str, Any] = {
            "id": field["id"],
            "kind": field["kind"],
            "label": field["label"],
            "help": field["help"],
            "required": field["required"],
            "type": "",
            "options": [],
            "max_files": field.get("max_files", 0),
        }
        if field["kind"] == CUSTOM:
            found = project_fields.get(field["custom_field_id"])
            if found is None:
                continue  # archived since: the visitor is not asked
            entry["type"] = found.type
            entry["options"] = [
                {"id": str(o["id"]), "label": str(o["label"])} for o in (found.options or [])
            ]
        out.append(entry)
    return out
