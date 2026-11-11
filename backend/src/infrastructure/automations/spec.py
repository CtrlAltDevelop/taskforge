"""What a rule is made of: the triggers and actions it may use, how they are checked when the rule
is saved, which events match a trigger, and which of the things a rule names no longer exist.

A trigger is ``{"type": ...}`` plus its options; an action is ``{"type": ...}`` plus its own. Text
an action writes may hold ``{title}``, ``{key}``, ``{status}``, ``{today}`` and ``{automation}``.
"""

import json
import uuid
from collections.abc import Iterable
from typing import Any, Final

from infrastructure.automations import safe_http
from infrastructure.common.errors import ApiError
from infrastructure.common.responses import ResponseTitle
from infrastructure.customfields import values as custom
from infrastructure.customfields.models import FieldDefinition, FieldType
from infrastructure.projects.models import Project
from infrastructure.tasks import services as tasks
from infrastructure.workflows.models import Status

TASK_CREATED: Final = "task_created"
STATUS_CHANGED: Final = "status_changed"
FIELD_CHANGED: Final = "field_changed"
ASSIGNED: Final = "assigned"
DUE_DATE_REACHED: Final = "due_date_reached"
COMMENT_ADDED: Final = "comment_added"
TRIGGERS: Final = (
    TASK_CREATED,
    STATUS_CHANGED,
    FIELD_CHANGED,
    ASSIGNED,
    DUE_DATE_REACHED,
    COMMENT_ADDED,
)

SET_FIELD: Final = "set_field"
SET_STATUS: Final = "set_status"
SET_ASSIGNEE: Final = "set_assignee"
ADD_COMMENT: Final = "add_comment"
CREATE_SUBTASK: Final = "create_subtask"
NOTIFY: Final = "notify"
WEBHOOK: Final = "webhook"
ACTIONS: Final = (
    SET_FIELD,
    SET_STATUS,
    SET_ASSIGNEE,
    ADD_COMMENT,
    CREATE_SUBTASK,
    NOTIFY,
    WEBHOOK,
)

CUSTOM_PREFIX: Final = "field:"
TODAY: Final = "{today}"
SETTABLE: Final = ("title", "priority", "start_date", "due_date", "due_time", "estimate_sec")
DATE_FIELDS: Final = ("start_date", "due_date")
RECIPIENT_WORDS: Final = ("assignees", "owner", "creator")
ASSIGN_MODES: Final = ("set", "add", "clear")
NAME_MAX: Final = 80
TEXT_MAX: Final = 2000
MAX_ACTIONS: Final = 10
MAX_RECIPIENTS: Final = 20
MAX_JSON_BYTES: Final = 20_000
MAX_DAYS_BEFORE: Final = 30


def bad(message: str) -> ApiError:
    return ApiError(message, status=400, title=ResponseTitle.VALIDATION_ERROR)


def _uuid(raw: Any, what: str) -> str:
    try:
        return str(uuid.UUID(str(raw)))
    except ValueError:
        raise bad(f"Choose {what}.") from None


def clean_name(value: str) -> str:
    name = value.strip()
    if not name or len(name) > NAME_MAX:
        raise bad(f"A rule name is 1 to {NAME_MAX} characters.")
    return name


def _only(raw: Any, allowed: Iterable[str], what: str) -> dict[str, Any]:
    if not isinstance(raw, dict):
        raise bad(f"A {what} must be an object.")
    extra = set(raw) - set(allowed)
    if extra:
        raise bad(f"A {what} of type {raw.get('type')!r} has no option {sorted(extra)[0]!r}.")
    return raw


def _custom_field(project: Project, field_id: str) -> FieldDefinition:
    found = FieldDefinition.objects.filter(
        project=project, pk=field_id, archived_at__isnull=True
    ).first()
    if found is None:
        raise bad("That custom field does not exist (or is archived).")
    return found


def _status(project: Project, raw: Any) -> str:
    pk = _uuid(raw, "a status of this project")
    if not Status.objects.filter(project=project, pk=pk).exists():
        raise bad("That status does not exist in this project.")
    return pk


def _member(project: Project, raw: Any) -> str:
    user = _uuid(raw, "a member")
    custom.user_check(project)(user)
    return user


def clean_trigger(project: Project, raw: Any) -> dict[str, Any]:
    kind = raw.get("type") if isinstance(raw, dict) else None
    if kind not in TRIGGERS:
        raise bad(f"The trigger must be one of: {', '.join(TRIGGERS)}.")
    if kind == STATUS_CHANGED:
        data = _only(raw, ("type", "to_status"), "trigger")
        found = {"to_status": _status(project, data["to_status"])} if data.get("to_status") else {}
        return {"type": kind, **found}
    if kind == FIELD_CHANGED:
        data = _only(raw, ("type", "field"), "trigger")
        name = str(data.get("field", ""))
        if name.startswith(CUSTOM_PREFIX):
            _custom_field(project, _uuid(name[len(CUSTOM_PREFIX) :], "a custom field"))
        elif name not in tasks.EDITABLE:
            raise bad("Choose a field to watch.")
        return {"type": kind, "field": name}
    if kind == ASSIGNED:
        data = _only(raw, ("type", "user_id"), "trigger")
        return {
            "type": kind,
            **({"user_id": _member(project, data["user_id"])} if data.get("user_id") else {}),
        }
    if kind == DUE_DATE_REACHED:
        data = _only(raw, ("type", "days_before"), "trigger")
        days = data.get("days_before", 0)
        if not isinstance(days, int) or isinstance(days, bool) or not 0 <= days <= MAX_DAYS_BEFORE:
            raise bad(f"days_before is a whole number from 0 to {MAX_DAYS_BEFORE}.")
        return {"type": kind, "days_before": days}
    _only(raw, ("type",), "trigger")
    return {"type": kind}


def _text(raw: Any, what: str, *, limit: int = TEXT_MAX) -> str:
    text = str(raw or "").strip()
    if not text or len(text) > limit:
        raise bad(f"{what} is 1 to {limit} characters.")
    return text


def _clean_set_field(project: Project, data: dict[str, Any]) -> dict[str, Any]:
    name, value = str(data.get("field", "")), str(data.get("value", ""))
    if name.startswith(CUSTOM_PREFIX):
        field_id = _uuid(name[len(CUSTOM_PREFIX) :], "a custom field")
        definition = _custom_field(project, field_id)
        if value == TODAY:
            if definition.type != FieldType.DATE:
                raise bad("{today} only fits a date field.")
        else:
            custom.prepare(project, {field_id: value})
        return {"type": SET_FIELD, "field": f"{CUSTOM_PREFIX}{field_id}", "value": value}
    if name not in SETTABLE:
        raise bad(f"Choose a field to set: {', '.join(SETTABLE)} or a custom field.")
    if value == TODAY:
        if name not in DATE_FIELDS:
            raise bad("{today} only fits a date.")
    else:
        tasks.SCALAR_FIELDS[name](value)
    return {"type": SET_FIELD, "field": name, "value": value}


def _clean_recipients(project: Project, raw: Any) -> list[str]:
    if not isinstance(raw, list) or not raw or len(raw) > MAX_RECIPIENTS:
        raise bad(f"Choose 1 to {MAX_RECIPIENTS} people to notify.")
    found = [item if item in RECIPIENT_WORDS else _member(project, item) for item in raw]
    return list(dict.fromkeys(found))


def _clean_assignee(project: Project, data: dict[str, Any]) -> dict[str, Any]:
    mode = data.get("mode", "set")
    if mode not in ASSIGN_MODES:
        raise bad(f"The assignee mode is one of: {', '.join(ASSIGN_MODES)}.")
    users = [_member(project, u) for u in data.get("user_ids") or []]
    if mode != "clear" and not users:
        raise bad("Choose who to assign.")
    return {"type": SET_ASSIGNEE, "mode": mode, "user_ids": [] if mode == "clear" else users}


def _clean_webhook(data: dict[str, Any]) -> dict[str, Any]:
    method = str(data.get("method") or "POST").upper()
    if method not in ("POST", "PUT"):
        raise bad("A webhook uses POST or PUT.")
    url = str(data.get("url", "")).strip()
    try:
        safe_http.check_static(url)
    except safe_http.UnsafeUrl as error:
        raise bad(str(error)) from None
    return {"type": WEBHOOK, "url": url, "method": method}


def clean_action(project: Project, raw: Any) -> dict[str, Any]:
    kind = raw.get("type") if isinstance(raw, dict) else None
    if kind not in ACTIONS:
        raise bad(f"An action must be one of: {', '.join(ACTIONS)}.")
    if kind == SET_FIELD:
        return _clean_set_field(project, _only(raw, ("type", "field", "value"), "action"))
    if kind == SET_STATUS:
        data = _only(raw, ("type", "status"), "action")
        return {"type": kind, "status": _status(project, data.get("status"))}
    if kind == SET_ASSIGNEE:
        return _clean_assignee(project, _only(raw, ("type", "mode", "user_ids"), "action"))
    if kind == ADD_COMMENT:
        data = _only(raw, ("type", "text"), "action")
        return {"type": kind, "text": _text(data.get("text"), "A comment")}
    if kind == CREATE_SUBTASK:
        data = _only(raw, ("type", "title"), "action")
        return {"type": kind, "title": _text(data.get("title"), "A title", limit=500)}
    if kind == NOTIFY:
        data = _only(raw, ("type", "to", "message"), "action")
        return {
            "type": kind,
            "to": _clean_recipients(project, data.get("to")),
            "message": _text(data.get("message"), "A message", limit=500),
        }
    return _clean_webhook(_only(raw, ("type", "url", "method"), "action"))


def clean_actions(project: Project, raw: Any) -> list[dict[str, Any]]:
    if not isinstance(raw, list) or not raw:
        raise bad("A rule needs at least one action.")
    if len(raw) > MAX_ACTIONS:
        raise bad(f"A rule has at most {MAX_ACTIONS} actions.")
    built = [clean_action(project, item) for item in raw]
    if len(json.dumps(built)) > MAX_JSON_BYTES:
        raise bad("This rule is too large.")
    return built


# ------------------------------------------------------------------------------------ matching


def matches(trigger: dict[str, Any], kind: str, data: dict[str, Any]) -> bool:
    """Whether an event of ``kind`` with ``data`` fires ``trigger``."""
    if trigger.get("type") != kind:
        return False
    if kind == STATUS_CHANGED:
        return not trigger.get("to_status") or trigger["to_status"] == data.get("to_status")
    if kind == FIELD_CHANGED:
        return trigger.get("field") in data.get("fields", [])
    if kind == ASSIGNED:
        return not trigger.get("user_id") or trigger["user_id"] in data.get("user_ids", [])
    return True


def explain_mismatch(trigger: dict[str, Any], kind: str) -> str:
    """Why an event did not fire the trigger, for the "why didn't this run" answer."""
    if trigger.get("type") != kind:
        return f"The rule waits for {trigger.get('type')}, not {kind}."
    return {
        STATUS_CHANGED: "The task moved to a different status than the one the rule waits for.",
        FIELD_CHANGED: "The field that changed is not the one the rule watches.",
        ASSIGNED: "That person was not assigned.",
    }.get(kind, "The event does not match.")


def render_text(text: str, *, title: str, key: str, status: str, today: str, rule: str) -> str:
    """``text`` with its ``{placeholders}`` filled (anything else is left as written)."""
    for token, value in (
        ("{title}", title),
        ("{key}", key),
        ("{status}", status),
        (TODAY, today),
        ("{automation}", rule),
    ):
        text = text.replace(token, value)
    return text


# ----------------------------------------------------------------------------------- dangling


def _field_ids(trigger: dict[str, Any], actions: list[dict[str, Any]]) -> set[str]:
    names = [trigger.get("field", "")] + [a.get("field", "") for a in actions]
    return {n[len(CUSTOM_PREFIX) :] for n in names if str(n).startswith(CUSTOM_PREFIX)}


def _user_ids(trigger: dict[str, Any], actions: list[dict[str, Any]]) -> set[str]:
    ids = {trigger["user_id"]} if trigger.get("user_id") else set()
    for action in actions:
        ids.update(action.get("user_ids", []))
        ids.update(r for r in action.get("to", []) if r not in RECIPIENT_WORDS)
    return ids


def dangling(project: Project, trigger: dict[str, Any], actions: list[dict[str, Any]]) -> list[str]:
    """What the rule names that is gone: a status, a custom field or a person who is no longer a
    member who can open the project. One sentence each; empty when the rule is whole."""
    wanted = {trigger["to_status"]} if trigger.get("to_status") else set()
    wanted.update(a["status"] for a in actions if a.get("type") == SET_STATUS)
    have = {str(p) for p in Status.objects.filter(project=project).values_list("pk", flat=True)}
    problems = [f"A status it uses ({s[:8]}) was deleted." for s in sorted(wanted - have)]
    live = {
        str(p)
        for p in FieldDefinition.objects.filter(
            project=project, archived_at__isnull=True
        ).values_list("pk", flat=True)
    }
    problems += [
        f"A custom field it uses ({f[:8]}) was deleted or archived."
        for f in sorted(_field_ids(trigger, actions) - live)
    ]
    check = custom.user_check(project)
    for user in sorted(_user_ids(trigger, actions)):
        try:
            check(user)
        except ApiError:
            problems.append(f"A person it names ({user[:8]}) can no longer open this project.")
    return problems


def task_value(task: Any, name: str) -> str:
    """The wire value of a task's editable field (``""`` when empty)."""
    if name.startswith(CUSTOM_PREFIX):
        return custom.current(task, name[len(CUSTOM_PREFIX) :])
    value = getattr(task, name)
    if value is None:
        return ""
    return str(value)[:5] if name == "due_time" else str(value)
