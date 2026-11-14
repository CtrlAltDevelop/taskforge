"""Goals, key results and check-ins. Every query is scoped to the workspace.

Anyone who can see the workspace sees its goals, except private ones (visible to the owner,
contributors and holders of ``goal.manage``). Creating needs ``goal.create``; changing a goal,
its key results and its folder needs to be its owner or to hold ``goal.manage``. Contributors may
add check-ins. Progress is read from ``tree``; ``events.tracking`` reports what moved.
"""

import json
import uuid
from dataclasses import dataclass
from datetime import date
from decimal import Decimal, InvalidOperation
from typing import Any, Final

from django.db import transaction
from django.db.models import Q
from django.utils import timezone

from infrastructure.audit import recorder
from infrastructure.common.errors import ApiError
from infrastructure.common.responses import ResponseTitle
from infrastructure.filters import services as filter_services
from infrastructure.filters.language import Catalogue
from infrastructure.goals import recompute, tree
from infrastructure.goals.events import tracking
from infrastructure.goals.models import (
    CheckIn,
    Goal,
    GoalContributor,
    GoalFolder,
    GoalStatus,
    KeyResult,
    KeyResultTask,
    KrType,
)
from infrastructure.projects.models import Project
from infrastructure.tasks.models import Task
from infrastructure.workspaces import access
from infrastructure.workspaces.models import MemberStatus, Workspace, WorkspaceMember

CREATE: Final = "goal.create"
MANAGE: Final = "goal.manage"
VIEW: Final = "workspace.view"
MAX_DEPTH: Final = 5
MAX_PICKED: Final = 500
MAX_KRS: Final = 30
CHECKIN_PAGE: Final = 100
GOAL_EDITABLE: Final = frozenset(
    {
        "name",
        "description",
        "owner_id",
        "parent_id",
        "folder_id",
        "private",
        "period_start",
        "period_end",
        "status_override",
        "weight",
        "contributor_ids",
    }
)
KR_EDITABLE: Final = frozenset(
    {"name", "start_value", "target_value", "weight", "filter_text", "task_ids", "position"}
)


def invalid(message: str) -> ApiError:
    return ApiError(message, status=400, title=ResponseTitle.VALIDATION_ERROR)


def not_found() -> ApiError:
    return ApiError("Not found.", status=404, title=ResponseTitle.NOT_FOUND)


def conflict() -> ApiError:
    return ApiError("It changed since you opened it.", 409, title=ResponseTitle.VERSION_CONFLICT)


def _uuid(raw: Any) -> uuid.UUID:
    try:
        return uuid.UUID(str(raw))
    except ValueError:
        raise not_found() from None


def _decimal(raw: Any, name: str) -> Decimal:
    try:
        value = Decimal(str(raw).strip())
    except (InvalidOperation, ValueError):
        raise invalid(f"{name} must be a number.") from None
    if not value.is_finite() or abs(value) >= Decimal(10) ** 13:
        raise invalid(f"{name} is out of range.")
    return value.quantize(Decimal("0.0001"))


def _weight(raw: Any) -> Decimal:
    value = _decimal(raw, "Weight")
    if not Decimal("0") < value <= Decimal("1000"):
        raise invalid("Weight must be above 0 and at most 1000.")
    return value.quantize(Decimal("0.01"))


def _date(raw: Any, name: str) -> date:
    if isinstance(raw, date):
        return raw
    try:
        return date.fromisoformat(str(raw))
    except ValueError:
        raise invalid(f"{name} is a date like 2026-01-31.") from None


def _text(raw: Any, name: str, limit: int, *, required: bool = False) -> str:
    value = str(raw or "").strip()
    if required and not value:
        raise invalid(f"{name} is required.")
    if len(value) > limit:
        raise invalid(f"{name} is longer than {limit} characters.")
    return value


# ----------------------------------------------------------------------------- views


@dataclass(frozen=True, slots=True)
class KrView:
    kr: KeyResult
    progress: float
    task_ids: list[str]


@dataclass(frozen=True, slots=True)
class GoalView:
    goal: Goal
    progress: float
    status: str
    hint: str
    krs: list[KrView]
    contributor_ids: list[str]
    child_ids: list[str]
    can_edit: bool
    can_check_in: bool


def is_member(workspace: Workspace, user_id: Any) -> bool:
    return WorkspaceMember.objects.filter(
        workspace=workspace, user_id=user_id, status=MemberStatus.ACTIVE
    ).exists()


def _can_edit(actor: Any, workspace: Workspace, goal: Goal) -> bool:
    return goal.owner_id == actor.pk or access.can(actor, MANAGE, workspace).allowed


def _can_see(actor: Any, workspace: Workspace, goal: Goal, loaded: tree.Tree) -> bool:
    if not goal.private:
        return True
    return actor.pk in loaded.contributors.get(goal.pk, []) or _can_edit(actor, workspace, goal)


def _view(actor: Any, workspace: Workspace, goal: Goal, loaded: tree.Tree, picked: Any) -> GoalView:
    editable = _can_edit(actor, workspace, goal)
    contributors = loaded.contributors.get(goal.pk, [])
    return GoalView(
        goal=goal,
        progress=loaded.progress(goal.pk),
        status=loaded.status(goal),
        hint=loaded.hint(goal),
        krs=[
            KrView(kr, tree.kr_value(kr), [str(t) for t in picked.get(kr.pk, [])])
            for kr in loaded.krs.get(goal.pk, [])
        ],
        contributor_ids=[str(u) for u in contributors],
        child_ids=[str(c.pk) for c in loaded.children.get(goal.pk, [])],
        can_edit=editable,
        can_check_in=editable or actor.pk in contributors,
    )


def _picked(goal_ids: Any) -> dict[Any, list[Any]]:
    found: dict[Any, list[Any]] = {}
    for kr_id, task_id in KeyResultTask.objects.filter(kr__goal__in=goal_ids).values_list(
        "kr_id", "task_id"
    ):
        found.setdefault(kr_id, []).append(task_id)
    return found


def list_goals(actor: Any, workspace: Workspace) -> list[GoalView]:
    access.require(actor, VIEW, workspace)
    loaded = tree.load(workspace.pk)
    visible = [g for g in loaded.goals.values() if _can_see(actor, workspace, g, loaded)]
    picked = _picked([g.pk for g in visible])
    return [_view(actor, workspace, g, loaded, picked) for g in visible]


def _goal(workspace: Workspace, goal_id: str, *, lock: bool = False) -> Goal:
    rows = Goal.objects.filter(workspace=workspace, pk=_uuid(goal_id))
    goal = (rows.select_for_update(of=("self",)) if lock else rows).first()
    if goal is None:
        raise not_found()
    return goal


def _seen_goal(actor: Any, workspace: Workspace, goal_id: str, *, lock: bool = False) -> Goal:
    access.require(actor, VIEW, workspace)
    goal = _goal(workspace, goal_id, lock=lock)
    if goal.private and not _can_see(actor, workspace, goal, tree.load(workspace.pk)):
        raise not_found()
    return goal


def _editable_goal(actor: Any, workspace: Workspace, goal_id: str) -> Goal:
    goal = _seen_goal(actor, workspace, goal_id, lock=True)
    if not _can_edit(actor, workspace, goal):
        access.require(actor, MANAGE, workspace)
    return goal


def get(actor: Any, workspace: Workspace, goal_id: str) -> GoalView:
    goal = _seen_goal(actor, workspace, goal_id)
    return view_of(actor, workspace, goal.pk)


def view_of(actor: Any, workspace: Workspace, goal_pk: Any) -> GoalView:
    loaded = tree.load(workspace.pk)
    return _view(actor, workspace, loaded.goals[goal_pk], loaded, _picked([goal_pk]))


def _audit(goal: Goal, action: str, changes: dict[str, Any], actor: Any) -> None:
    recorder.record(
        workspace_id=goal.workspace_id,
        action=action,
        target_type="goal",
        target_id=goal.pk,
        changes=changes,
        actor=actor,
    )


# ----------------------------------------------------------------------------- goals


def _parent(workspace: Workspace, parent_id: str, goal: Goal | None) -> Goal | None:
    if not parent_id:
        return None
    parent = _goal(workspace, parent_id)
    depth, cursor = 1, parent
    while cursor is not None:
        if goal is not None and cursor.pk == goal.pk:
            raise invalid("A goal cannot sit under itself.")
        depth += 1
        cursor = cursor.parent
        if depth > MAX_DEPTH:
            raise invalid("Goals nest at most five levels deep.")
    return parent


def _folder(workspace: Workspace, folder_id: str) -> GoalFolder | None:
    if not folder_id:
        return None
    folder = GoalFolder.objects.filter(workspace=workspace, pk=_uuid(folder_id)).first()
    if folder is None:
        raise invalid("That folder does not exist.")
    return folder


def _member_ids(workspace: Workspace, raw: Any) -> list[uuid.UUID]:
    ids = list(dict.fromkeys(_uuid(r) for r in raw))
    ok = set(
        WorkspaceMember.objects.filter(
            workspace=workspace, user_id__in=ids, status=MemberStatus.ACTIVE
        ).values_list("user_id", flat=True)
    )
    if len(ok) != len(ids):
        raise invalid("Everyone you add must be a member of the workspace.")
    return ids


def _period(start: date, end: date) -> None:
    if end < start:
        raise invalid("The period must end on or after the day it starts.")


def create(
    actor: Any,
    workspace: Workspace,
    name: str,
    period_start: Any,
    period_end: Any,
    *,
    description: str = "",
    owner_id: str = "",
    parent_id: str = "",
    folder_id: str = "",
    private: bool = False,
    weight: Any = 1,
    contributor_ids: Any = (),
) -> GoalView:
    access.require(actor, CREATE, workspace)
    start, end = _date(period_start, "Period start"), _date(period_end, "Period end")
    _period(start, end)
    with transaction.atomic(), tracking(workspace.pk, actor.pk):
        parent = _parent(workspace, parent_id, None)
        owner = _member_ids(workspace, [owner_id or actor.pk])[0]
        goal = Goal.objects.create(
            workspace=workspace,
            parent=parent,
            folder=_folder(workspace, folder_id),
            name=_text(name, "Name", 160, required=True),
            description=_text(description, "Description", 2000),
            owner_id=owner,
            created_by=actor,
            private=bool(private),
            period_start=start,
            period_end=end,
            weight=_weight(weight),
        )
        for user_id in _member_ids(workspace, contributor_ids):
            GoalContributor.objects.create(goal=goal, user_id=user_id)
        _audit(goal, "goal.created", {"name": goal.name}, actor)
    return view_of(actor, workspace, goal.pk)


def _parse(workspace: Workspace, goal: Goal, key: str, raw: Any) -> tuple[str, Any]:
    """The model attribute ``key`` sets and the checked value (ids, so they compare directly)."""
    if key == "name":
        return key, _text(raw, "Name", 160, required=True)
    if key == "description":
        return key, _text(raw, "Description", 2000)
    if key == "owner_id":
        return key, _member_ids(workspace, [raw])[0]
    if key == "parent_id":
        parent = _parent(workspace, raw, goal)
        return key, parent.pk if parent else None
    if key == "folder_id":
        folder = _folder(workspace, raw)
        return key, folder.pk if folder else None
    if key == "private":
        return key, bool(raw)
    if key in ("period_start", "period_end"):
        return key, _date(raw, key)
    if key == "status_override":
        value = str(raw or "")
        if value and value not in GoalStatus.ALL:
            raise invalid("The status is on_track, at_risk or off_track.")
        return key, value
    return key, _weight(raw)


def _apply(workspace: Workspace, goal: Goal, changes: dict[str, Any]) -> dict[str, Any]:
    done: dict[str, Any] = {}
    for key, raw in changes.items():
        if key not in GOAL_EDITABLE:
            raise ApiError(f"Cannot change {key}.", status=400)
        if key == "contributor_ids":
            ids = _member_ids(workspace, raw)
            GoalContributor.objects.filter(goal=goal).exclude(user_id__in=ids).delete()
            for user_id in ids:
                GoalContributor.objects.get_or_create(goal=goal, user_id=user_id)
            done[key] = "changed"
            continue
        attr, value = _parse(workspace, goal, key, raw)
        current = getattr(goal, attr)
        if current != value:
            done[key] = str(value) if value is not None else ""
            setattr(goal, attr, value)
    _period(goal.period_start, goal.period_end)
    return done


def update(
    actor: Any, workspace: Workspace, goal_id: str, expected_version: int, **changes: Any
) -> GoalView:
    with transaction.atomic(), tracking(workspace.pk, actor.pk):
        goal = _editable_goal(actor, workspace, goal_id)
        if goal.version != expected_version:
            raise conflict()
        done = _apply(workspace, goal, changes)
        goal.version += 1
        goal.updated_at = timezone.now()
        goal.save()
        _audit(goal, "goal.updated", done, actor)
    return view_of(actor, workspace, goal.pk)


def delete(actor: Any, workspace: Workspace, goal_id: str) -> None:
    """Child goals move up to the deleted goal's parent."""
    with transaction.atomic(), tracking(workspace.pk, actor.pk):
        goal = _editable_goal(actor, workspace, goal_id)
        Goal.objects.filter(parent=goal).update(parent=goal.parent_id)
        _audit(goal, "goal.deleted", {"name": goal.name}, actor)
        goal.delete()


# ----------------------------------------------------------------------------- folders


def folders(actor: Any, workspace: Workspace) -> list[GoalFolder]:
    access.require(actor, VIEW, workspace)
    return list(GoalFolder.objects.filter(workspace=workspace))


def save_folder(actor: Any, workspace: Workspace, folder_id: str, name: str) -> GoalFolder:
    """Create (empty ``folder_id``) or rename a folder; needs ``goal.manage``."""
    access.require(actor, MANAGE, workspace)
    clean = _text(name, "Name", 80, required=True)
    if not folder_id:
        last = GoalFolder.objects.filter(workspace=workspace).count()
        return GoalFolder.objects.create(workspace=workspace, name=clean, position=last)
    folder = _folder(workspace, folder_id)
    assert folder is not None
    folder.name = clean
    folder.save(update_fields=["name"])
    return folder


def delete_folder(actor: Any, workspace: Workspace, folder_id: str) -> None:
    access.require(actor, MANAGE, workspace)
    folder = _folder(workspace, folder_id)
    if folder is not None:
        folder.delete()  # its goals stay, without a folder


# ----------------------------------------------------------------------------- key results


def _kr(
    actor: Any, workspace: Workspace, kr_id: str, *, edit: bool, lock: bool = False
) -> KeyResult:
    rows = KeyResult.objects.select_related("goal").filter(
        goal__workspace=workspace, pk=_uuid(kr_id)
    )
    kr = (rows.select_for_update(of=("self",)) if lock else rows).first()
    if kr is None:
        raise not_found()
    goal = _seen_goal(actor, workspace, str(kr.goal_id))
    if edit and not _can_edit(actor, workspace, goal):
        access.require(actor, MANAGE, workspace)
    return kr


def _filter(workspace: Workspace, text: str) -> tuple[str, Any]:
    clean = text.strip()
    if not clean:
        return "", None
    checked = filter_services.check(Catalogue(None, workspace), clean)
    if checked.errors or checked.ast is None:
        raise invalid(checked.errors[0].message if checked.errors else "The filter is invalid.")
    return checked.tfql, json.loads(json.dumps(checked.ast))


def _set_tasks(actor: Any, workspace: Workspace, kr: KeyResult, raw: Any) -> None:
    ids = list(dict.fromkeys(_uuid(r) for r in raw))
    if len(ids) > MAX_PICKED:
        raise invalid(f"A key result takes at most {MAX_PICKED} picked tasks.")
    visible = Project.objects.visible_to(actor, workspace)
    found = set(
        Task.objects.filter(
            pk__in=ids, workspace=workspace, deleted_at__isnull=True, project__in=visible
        ).values_list("pk", flat=True)
    )
    keep = set(KeyResultTask.objects.filter(kr=kr).values_list("task_id", flat=True))
    if (set(ids) - found) - keep:
        raise invalid("Some of those tasks do not exist or are not open to you.")
    KeyResultTask.objects.filter(kr=kr).exclude(task_id__in=ids).delete()
    for task_id in ids:
        KeyResultTask.objects.get_or_create(kr=kr, task_id=task_id)


def _scalars(kind: str, start: Any, target: Any, current: Any) -> tuple[Decimal, Decimal, Decimal]:
    if kind == KrType.PERCENTAGE:
        s, t = Decimal(0), Decimal(100)
    elif kind == KrType.BOOLEAN:
        s, t = Decimal(0), Decimal(1)
    elif kind == KrType.NUMBER:
        s, t = _decimal(start, "Start"), _decimal(target, "Target")
    else:
        s, t = Decimal(0), Decimal(0)
    return s, t, _reading(kind, current)


def _reading(kind: str, raw: Any) -> Decimal:
    value = _decimal(raw or 0, "Value")
    if kind == KrType.PERCENTAGE and not Decimal(0) <= value <= Decimal(100):
        raise invalid("A percentage is between 0 and 100.")
    if kind == KrType.BOOLEAN:
        return Decimal(1) if value >= 1 else Decimal(0)
    return value


def create_kr(
    actor: Any,
    workspace: Workspace,
    goal_id: str,
    name: str,
    kind: str,
    *,
    start_value: Any = 0,
    target_value: Any = 100,
    current_value: Any = 0,
    weight: Any = 1,
    filter_text: str = "",
    task_ids: Any = (),
) -> GoalView:
    if kind not in KrType.ALL:
        raise invalid("The type is number, percentage, boolean or linked.")
    with transaction.atomic(), tracking(workspace.pk, actor.pk):
        goal = _editable_goal(actor, workspace, goal_id)
        if goal.key_results.count() >= MAX_KRS:
            raise invalid("A goal takes at most 30 key results.")
        start, target, current = _scalars(kind, start_value, target_value, current_value)
        text, ast = _filter(workspace, filter_text) if kind == KrType.LINKED else ("", None)
        kr = KeyResult.objects.create(
            goal=goal,
            name=_text(name, "Name", 160, required=True),
            type=kind,
            start_value=start,
            target_value=target,
            current_value=current,
            filter_text=text,
            filter_ast=ast,
            weight=_weight(weight),
            position=goal.key_results.count(),
        )
        if kind == KrType.LINKED:
            _set_tasks(actor, workspace, kr, task_ids)
            kr.linked_done, kr.linked_total = recompute.count_linked(kr)
            kr.save(update_fields=["linked_done", "linked_total"])
        _audit(goal, "goal.kr_created", {"key_result": kr.name, "type": kind}, actor)
    return view_of(actor, workspace, goal.pk)


def update_kr(
    actor: Any, workspace: Workspace, kr_id: str, expected_version: int, **changes: Any
) -> GoalView:
    with transaction.atomic(), tracking(workspace.pk, actor.pk):
        kr = _kr(actor, workspace, kr_id, edit=True, lock=True)
        if kr.version != expected_version:
            raise conflict()
        done: dict[str, Any] = {}
        for key, raw in changes.items():
            if key not in KR_EDITABLE:
                raise ApiError(f"Cannot change {key}.", status=400)
            done[key] = "changed"
            if key == "name":
                kr.name = _text(raw, "Name", 160, required=True)
            elif key == "weight":
                kr.weight = _weight(raw)
            elif key == "position":
                kr.position = max(0, int(raw))
            elif key in ("start_value", "target_value"):
                if kr.type != KrType.NUMBER:
                    raise invalid("Only a number key result has a start and a target.")
                setattr(kr, key, _decimal(raw, key))
            elif kr.type != KrType.LINKED:
                raise invalid("Only a linked key result counts tasks.")
            elif key == "filter_text":
                kr.filter_text, kr.filter_ast = _filter(workspace, str(raw))
            else:
                _set_tasks(actor, workspace, kr, raw)
        if kr.type == KrType.LINKED:
            kr.linked_done, kr.linked_total = recompute.count_linked(kr)
        kr.version += 1
        kr.updated_at = timezone.now()
        kr.save()
        _audit(kr.goal, "goal.kr_updated", {"key_result": kr.name, **done}, actor)
    return view_of(actor, workspace, kr.goal_id)


def delete_kr(actor: Any, workspace: Workspace, kr_id: str) -> GoalView:
    with transaction.atomic(), tracking(workspace.pk, actor.pk):
        kr = _kr(actor, workspace, kr_id, edit=True, lock=True)
        _audit(kr.goal, "goal.kr_deleted", {"key_result": kr.name}, actor)
        kr.delete()
    return view_of(actor, workspace, kr.goal_id)


# ----------------------------------------------------------------------------- check-ins


def add_check_in(
    actor: Any, workspace: Workspace, kr_id: str, value: Any, note: str = ""
) -> tuple[CheckIn, GoalView]:
    """Record a reading. For a linked key result the value is the tasks' own count (the note is
    what is kept); for true/false 1 means true."""
    with transaction.atomic(), tracking(workspace.pk, actor.pk):
        kr = _kr(actor, workspace, kr_id, edit=False, lock=True)
        goal = kr.goal
        loaded = tree.load(workspace.pk)
        if not (
            _can_edit(actor, workspace, goal) or actor.pk in loaded.contributors.get(goal.pk, [])
        ):
            access.require(actor, MANAGE, workspace)
        previous = kr.current_value if kr.type != KrType.LINKED else Decimal(kr.linked_done)
        if kr.type == KrType.LINKED:
            recompute.recompute_kr(kr.pk)
            kr.refresh_from_db()
            reading = Decimal(kr.linked_done)
        else:
            reading = _reading(kr.type, value)
            kr.current_value = reading
            kr.version += 1
            kr.updated_at = timezone.now()
            kr.save(update_fields=["current_value", "version", "updated_at"])
        entry = CheckIn.objects.create(
            kr=kr,
            user=actor,
            value=reading,
            previous_value=previous,
            progress=tree.kr_value(kr),
            note=_text(note, "Note", 2000),
        )
        _audit(goal, "goal.checked_in", {"key_result": kr.name, "value": str(reading)}, actor)
    return entry, view_of(actor, workspace, goal.pk)


def list_check_ins(actor: Any, workspace: Workspace, kr_id: str, limit: int = 0) -> list[CheckIn]:
    kr = _kr(actor, workspace, kr_id, edit=False)
    size = min(limit or CHECKIN_PAGE, CHECKIN_PAGE)
    return list(CheckIn.objects.filter(kr=kr).order_by("-at", "-id")[:size])


# ----------------------------------------------------------------------------- task detail


@dataclass(frozen=True, slots=True)
class Contribution:
    goal_id: str
    goal_name: str
    kr_id: str
    kr_name: str


def for_task(actor: Any, workspace: Workspace, task_id: str) -> list[Contribution]:
    """The key results (of goals the caller may see) that count this task."""
    access.require(actor, VIEW, workspace)
    task = Task.objects.filter(
        pk=_uuid(task_id),
        workspace=workspace,
        project__in=Project.objects.visible_to(actor, workspace),
    ).first()
    if task is None:
        raise not_found()
    loaded = tree.load(workspace.pk)
    found: list[Contribution] = []
    candidates = KeyResult.objects.filter(
        Q(pk__in=KeyResultTask.objects.filter(task=task).values("kr_id"))
        | Q(type=KrType.LINKED, filter_ast__isnull=False),
        goal__workspace=workspace,
        type=KrType.LINKED,
    ).select_related("goal", "goal__workspace")
    for kr in candidates:
        goal = loaded.goals.get(kr.goal_id)
        if goal is None or not _can_see(actor, workspace, goal, loaded):
            continue
        counted = Task.objects.filter(pk=task.pk).filter(
            recompute.task_condition(kr, goal.owner or goal.created_by)
        )
        if counted.exists():
            found.append(Contribution(str(goal.pk), goal.name, str(kr.pk), kr.name))
    return found
