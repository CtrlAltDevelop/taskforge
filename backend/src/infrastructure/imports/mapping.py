"""What a person decides before an import runs, proposed for them, and checked before it is used.

``mapping`` is JSON::

    {"target":    {"project_id": "<uuid>"}  |  {"name": "...", "key": "ABC"},
     "columns":   {"title": "Summary", ...},          # CSV sources only
     "statuses":  {"<source status>": "id:<uuid>" | "new"},
     "priorities": {"<source priority>": "urgent|high|normal|low|none"},
     "users":     {"<person key>": "<user uuid>" | "placeholder" | "skip"},
     "labels":    true}

A status of ``new`` means: the project's status of that name, created when there is none.
"""

import re
import uuid
from typing import Any, Final

from django.contrib.auth import get_user_model

from infrastructure.common.errors import ApiError
from infrastructure.imports import parsers
from infrastructure.imports.parsers import tabular
from infrastructure.imports.records import Analysis
from infrastructure.projects import services as projects
from infrastructure.projects.models import Project
from infrastructure.tasks.models import Priority
from infrastructure.workflows.models import Category, Status
from infrastructure.workspaces.models import MemberStatus, Workspace, WorkspaceMember

PRIORITIES: Final = {
    "urgent": ("urgent", "highest", "blocker", "critical", "p0", "1"),
    "high": ("high", "major", "p1", "2"),
    "normal": ("normal", "medium", "default", "p2", "3"),
    "low": ("low", "minor", "lowest", "trivial", "p3", "4", "5"),
}
_DONE = re.compile(r"\b(done|closed|resolved|complete[d]?|finished|shipped|released|fixed)\b", re.I)
_CANCELLED = re.compile(
    r"\b(cancel+ed|won'?t|wontfix|rejected|abandoned|duplicate|obsolete)\b", re.I
)
_ACTIVE = re.compile(
    r"\b(progress|doing|review|testing|qa|started|active|development|blocked)\b", re.I
)
VALID_PRIORITIES: Final = frozenset(Priority.values)
MAX_LABEL_OPTIONS: Final = 100


def priority_of(text: str) -> str:
    low = text.strip().lower()
    for ours, names in PRIORITIES.items():
        if low in names:
            return ours
    return "none"


def category_of(status_name: str) -> str:
    if _CANCELLED.search(status_name):
        return Category.CANCELLED
    if _DONE.search(status_name):
        return Category.DONE
    if _ACTIVE.search(status_name):
        return Category.ACTIVE
    return Category.NOT_STARTED


def members(workspace: Workspace) -> list[Any]:
    ids = WorkspaceMember.objects.filter(
        workspace=workspace, status=MemberStatus.ACTIVE
    ).values_list("user_id", flat=True)
    return list(get_user_model().objects.filter(pk__in=list(ids)))


def match_user(key: str, name: str, people: list[Any]) -> str:
    """The member whose email or sign-in name is the person's (case-insensitive), else ``""``."""
    wanted = {key.lower(), name.strip().lower()}
    for user in people:
        if (user.email or "").lower() in wanted or user.username.lower() in wanted:
            return str(user.pk)
    return ""


def propose(
    job_source: str,
    analysis: Analysis,
    workspace: Workspace,
    project: Project | None,
    header: list[str] | None = None,
    head: dict[str, Any] | None = None,
) -> dict[str, Any]:
    """The mapping the wizard starts from."""
    existing = (
        {s.name.lower(): s for s in Status.objects.filter(project=project)} if project else {}
    )
    statuses = {
        name: (f"id:{existing[name.lower()].pk}" if name.lower() in existing else "new")
        for name in analysis.statuses
    }
    people = members(workspace)
    users = {
        key: match_user(key, name, people) or "placeholder" for key, name in analysis.people.items()
    }
    mapping: dict[str, Any] = {
        "target": {"project_id": str(project.pk)} if project else {"name": "", "key": ""},
        "statuses": statuses,
        "priorities": {name: priority_of(name) for name in analysis.priorities},
        "users": users,
        "labels": analysis.labels > 0,
    }
    if parsers.is_csv(job_source) and header is not None:
        mapping["columns"] = tabular.propose(job_source, header)
    if head and isinstance(head.get("project"), dict):
        mapping["target"] = {
            "name": str(head["project"].get("name", "")),
            "key": str(head["project"].get("key", "")),
        }
    return mapping


def _bad(message: str) -> ApiError:
    return ApiError(message, status=400)


def check(
    actor: Any, workspace: Workspace, source: str, raw: dict[str, Any], header: list[str] | None
) -> dict[str, Any]:
    """``raw`` as the mapping the engine may rely on: every part checked, nothing unknown kept."""
    if not isinstance(raw, dict):
        raise _bad("The mapping must be an object.")
    target = raw.get("target") or {}
    if not isinstance(target, dict):
        raise _bad("The target must be an object.")
    out: dict[str, Any] = {}
    if target.get("project_id"):
        try:
            pk = uuid.UUID(str(target["project_id"]))
        except ValueError:
            raise _bad("The target project is not valid.") from None
        try:
            target_project = projects.load(actor, workspace, str(pk))  # one the caller can open
            projects.writable(target_project)
        except ApiError:
            raise _bad("The target project does not exist, is archived, or is not yours.") from None
        out["target"] = {"project_id": str(pk)}
    else:
        name, key = str(target.get("name", "")).strip(), str(target.get("key", "")).strip()
        if not name or not key:
            raise _bad("Choose a project, or give a name and key for a new one.")
        out["target"] = {"name": name, "key": key}
    out["statuses"] = _statuses(raw.get("statuses"), out["target"])
    out["priorities"] = _choices(raw.get("priorities"), VALID_PRIORITIES, "priority")
    out["users"] = _users(workspace, raw.get("users"))
    out["labels"] = bool(raw.get("labels", False))
    if parsers.is_csv(source):
        out["columns"] = _columns(raw.get("columns"), header or [])
    return out


def _statuses(raw: Any, target: dict[str, Any]) -> dict[str, str]:
    if raw in (None, {}):
        return {}
    if not isinstance(raw, dict):
        raise _bad("The statuses must be an object.")
    out = {}
    for name, value in raw.items():
        value = str(value)
        if value == "new" or not value:
            out[str(name)] = "new"
        elif value.startswith("id:") and "project_id" in target:
            try:
                sid = uuid.UUID(value[3:])
            except ValueError:
                raise _bad(f"Status {name!r} is not valid.") from None
            if not Status.objects.filter(pk=sid, project_id=target["project_id"]).exists():
                raise _bad(f"Status {name!r} is not a status of the project.")
            out[str(name)] = f"id:{sid}"
        else:
            raise _bad(f"Status {name!r} must be a status of the project or 'new'.")
    return out


def _choices(raw: Any, allowed: frozenset[str], what: str) -> dict[str, str]:
    if raw in (None, {}):
        return {}
    if not isinstance(raw, dict) or any(str(v) not in allowed for v in raw.values()):
        raise _bad(f"Every {what} must map to one of: {', '.join(sorted(allowed))}.")
    return {str(k): str(v) for k, v in raw.items()}


def _users(workspace: Workspace, raw: Any) -> dict[str, str]:
    if raw in (None, {}):
        return {}
    if not isinstance(raw, dict):
        raise _bad("The people must be an object.")
    chosen = {str(k): str(v) for k, v in raw.items()}
    ids = {v for v in chosen.values() if v not in ("placeholder", "skip")}
    try:
        wanted = {uuid.UUID(v) for v in ids}
    except ValueError:
        raise _bad("A person is mapped to something that is not a member.") from None
    active = set(
        WorkspaceMember.objects.filter(
            workspace=workspace, user_id__in=wanted, status=MemberStatus.ACTIVE
        ).values_list("user_id", flat=True)
    )
    if wanted - active:
        raise _bad("A person is mapped to someone who is not a member of this workspace.")
    return chosen


def _columns(raw: Any, header: list[str]) -> dict[str, str]:
    if not isinstance(raw, dict):
        raise _bad("Map the columns first.")
    out = {}
    for field, name in raw.items():
        if field not in tabular.FIELDS:
            raise _bad(f"{field!r} is not a field an import can fill.")
        if name and name not in header:
            raise _bad(f"The file has no column {name!r}.")
        if name:
            out[str(field)] = str(name)
    if not out.get("title"):
        raise _bad("Map a column to the title.")
    return out
