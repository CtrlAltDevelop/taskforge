"""Goals over gRPC: ``GoalController``, ``KeyResultController``, ``CheckInController``. The rules
are in ``infrastructure.goals.services``.

``Update`` calls name what they change in ``changed`` (goal: name, description, owner_id,
parent_id, folder_id, private, period_start, period_end, status_override, weight,
contributor_ids; key result: name, start_value, target_value, weight, filter_text, task_ids,
position) and carry ``expected_version`` (a stale one is ABORTED). Every call that changes a goal
answers with the whole goal, progress included.
"""

from typing import Any

from asgiref.sync import sync_to_async
from django_socio_grpc import generics
from django_socio_grpc.decorators import grpc_action

from infrastructure.common.errors import ApiError
from infrastructure.common.grpc.errors import action, require_caller
from infrastructure.common.identity import grpc_caller
from infrastructure.goals import services
from infrastructure.goals.grpc.serializers import (
    CheckIn,
    Contribution,
    Folder,
    Goal,
)
from infrastructure.workspaces.scoping import require_workspace

WS = [{"name": "workspace_id", "type": "string"}]
GOAL = [*WS, {"name": "goal_id", "type": "string"}]
KR = [*WS, {"name": "kr_id", "type": "string"}]
CHANGED = [
    {"name": "changed", "cardinality": "repeated", "type": "string"},
    {"name": "expected_version", "type": "int32"},
]
GOAL_FIELDS = [
    {"name": "name", "type": "string"},
    {"name": "description", "type": "string"},
    {"name": "owner_id", "type": "string"},
    {"name": "parent_id", "type": "string"},
    {"name": "folder_id", "type": "string"},
    {"name": "private", "type": "bool"},
    {"name": "period_start", "type": "string"},
    {"name": "period_end", "type": "string"},
    {"name": "status_override", "type": "string"},
    {"name": "weight", "type": "string"},
    {"name": "contributor_ids", "cardinality": "repeated", "type": "string"},
]
KR_FIELDS = [
    {"name": "name", "type": "string"},
    {"name": "start_value", "type": "string"},
    {"name": "target_value", "type": "string"},
    {"name": "weight", "type": "string"},
    {"name": "filter_text", "type": "string"},
    {"name": "task_ids", "cardinality": "repeated", "type": "string"},
    {"name": "position", "type": "int32"},
]
GOAL_ANSWER = [{"name": "goal", "type": Goal}]


def _pb() -> Any:
    from infrastructure.goals.grpc import goals_pb2

    return goals_pb2


def _num(value: Any) -> str:
    return format(value.normalize(), "f")


def _iso(value: Any) -> str:
    return value.isoformat() if value else ""


def kr_message(view: services.KrView) -> Any:
    kr = view.kr
    return _pb().KeyResult(
        id=str(kr.pk),
        goal_id=str(kr.goal_id),
        name=kr.name,
        type=kr.type,
        start_value=_num(kr.start_value),
        target_value=_num(kr.target_value),
        current_value=_num(kr.current_value),
        filter_text=kr.filter_text,
        task_ids=view.task_ids,
        weight=_num(kr.weight),
        linked_done=kr.linked_done,
        linked_total=kr.linked_total,
        progress=view.progress,
        position=kr.position,
        version=kr.version,
    )


def goal_message(view: services.GoalView) -> Any:
    goal = view.goal
    return _pb().Goal(
        id=str(goal.pk),
        workspace_id=str(goal.workspace_id),
        parent_id=str(goal.parent_id or ""),
        folder_id=str(goal.folder_id or ""),
        name=goal.name,
        description=goal.description,
        owner_id=str(goal.owner_id or ""),
        private=goal.private,
        period_start=_iso(goal.period_start),
        period_end=_iso(goal.period_end),
        status_override=goal.status_override,
        status=view.status,
        status_hint=view.hint,
        weight=_num(goal.weight),
        progress=view.progress,
        version=goal.version,
        can_edit=view.can_edit,
        can_check_in=view.can_check_in,
        contributor_ids=view.contributor_ids,
        child_ids=view.child_ids,
        key_results=[kr_message(k) for k in view.krs],
        created_at=_iso(goal.created_at),
    )


def check_in_message(row: Any) -> Any:
    return _pb().CheckIn(
        id=str(row.pk),
        kr_id=str(row.kr_id),
        user_id=str(row.user_id or ""),
        value=_num(row.value),
        previous_value=_num(row.previous_value),
        progress=row.progress,
        note=row.note,
        at=_iso(row.at),
    )


def _answer(view: services.GoalView) -> Any:
    return _pb().GoalAnswer(goal=goal_message(view))


async def _scope(request: Any, context: Any) -> tuple[Any, Any]:
    user = require_caller(await grpc_caller(context))
    return user, await sync_to_async(require_workspace)(user, request.workspace_id)


def _changes(request: Any, allowed: frozenset[str]) -> dict[str, Any]:
    changes: dict[str, Any] = {}
    for name in request.changed:
        if name not in allowed:
            raise ApiError(f"Cannot change {name}.", status=400)
        value = getattr(request, name)
        changes[name] = list(value) if name in ("contributor_ids", "task_ids") else value
    return changes


class GoalService(generics.GenericService):
    @grpc_action(
        request=WS,
        request_name="GoalListRequest",
        response=[
            {"name": "goals", "cardinality": "repeated", "type": Goal},
            {"name": "folders", "cardinality": "repeated", "type": Folder},
        ],
        response_name="GoalList",
    )
    @action
    async def List(self, request: Any, context: Any) -> Any:
        """Every goal the caller may see, with its progress, and the folders."""
        user, workspace = await _scope(request, context)

        def run() -> Any:
            pb = _pb()
            return pb.GoalList(
                goals=[goal_message(v) for v in services.list_goals(user, workspace)],
                folders=[
                    pb.Folder(id=str(f.pk), name=f.name, position=f.position)
                    for f in services.folders(user, workspace)
                ],
            )

        return await sync_to_async(run)()

    @grpc_action(
        request=GOAL,
        request_name="GoalGetRequest",
        response=GOAL_ANSWER,
        response_name="GoalAnswer",
    )
    @action
    async def Get(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)
        return await sync_to_async(
            lambda: _answer(services.get(user, workspace, request.goal_id))
        )()

    @grpc_action(
        request=[*WS, *GOAL_FIELDS],
        request_name="GoalCreateRequest",
        response=GOAL_ANSWER,
        response_name="GoalAnswer",
    )
    @action
    async def Create(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)

        def run() -> Any:
            view = services.create(
                user,
                workspace,
                request.name,
                request.period_start,
                request.period_end,
                description=request.description,
                owner_id=request.owner_id,
                parent_id=request.parent_id,
                folder_id=request.folder_id,
                private=request.private,
                weight=request.weight or "1",
                contributor_ids=list(request.contributor_ids),
            )
            return _answer(view)

        return await sync_to_async(run)()

    @grpc_action(
        request=[*GOAL, *CHANGED, *GOAL_FIELDS],
        request_name="GoalUpdateRequest",
        response=GOAL_ANSWER,
        response_name="GoalAnswer",
    )
    @action
    async def Update(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)

        def run() -> Any:
            changes = _changes(request, services.GOAL_EDITABLE)
            view = services.update(
                user, workspace, request.goal_id, request.expected_version, **changes
            )
            return _answer(view)

        return await sync_to_async(run)()

    @grpc_action(
        request=GOAL,
        request_name="GoalDeleteRequest",
        response=[{"name": "id", "type": "string"}],
        response_name="GoalDeleted",
    )
    @action
    async def Delete(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)

        def run() -> Any:
            services.delete(user, workspace, request.goal_id)
            return _pb().GoalDeleted(id=request.goal_id)

        return await sync_to_async(run)()

    @grpc_action(
        request=[*WS, {"name": "folder_id", "type": "string"}, {"name": "name", "type": "string"}],
        request_name="FolderSaveRequest",
        response=[{"name": "folder", "type": Folder}],
        response_name="FolderAnswer",
    )
    @action
    async def SaveFolder(self, request: Any, context: Any) -> Any:
        """Create a folder (empty ``folder_id``) or rename one. Needs ``goal.manage``."""
        user, workspace = await _scope(request, context)

        def run() -> Any:
            f = services.save_folder(user, workspace, request.folder_id, request.name)
            return _pb().FolderAnswer(
                folder=_pb().Folder(id=str(f.pk), name=f.name, position=f.position)
            )

        return await sync_to_async(run)()

    @grpc_action(
        request=[*WS, {"name": "folder_id", "type": "string"}],
        request_name="FolderDeleteRequest",
        response=[{"name": "id", "type": "string"}],
        response_name="FolderDeleted",
    )
    @action
    async def DeleteFolder(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)

        def run() -> Any:
            services.delete_folder(user, workspace, request.folder_id)
            return _pb().FolderDeleted(id=request.folder_id)

        return await sync_to_async(run)()


class KeyResultService(generics.GenericService):
    @grpc_action(
        request=[
            *GOAL,
            {"name": "type", "type": "string"},
            {"name": "current_value", "type": "string"},
            *KR_FIELDS,
        ],
        request_name="KeyResultCreateRequest",
        response=GOAL_ANSWER,
        response_name="GoalAnswer",
    )
    @action
    async def Create(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)

        def run() -> Any:
            view = services.create_kr(
                user,
                workspace,
                request.goal_id,
                request.name,
                request.type,
                start_value=request.start_value or "0",
                target_value=request.target_value or "100",
                current_value=request.current_value or "0",
                weight=request.weight or "1",
                filter_text=request.filter_text,
                task_ids=list(request.task_ids),
            )
            return _answer(view)

        return await sync_to_async(run)()

    @grpc_action(
        request=[*KR, *CHANGED, *KR_FIELDS],
        request_name="KeyResultUpdateRequest",
        response=GOAL_ANSWER,
        response_name="GoalAnswer",
    )
    @action
    async def Update(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)

        def run() -> Any:
            changes = _changes(request, services.KR_EDITABLE)
            view = services.update_kr(
                user, workspace, request.kr_id, request.expected_version, **changes
            )
            return _answer(view)

        return await sync_to_async(run)()

    @grpc_action(
        request=KR,
        request_name="KeyResultDeleteRequest",
        response=GOAL_ANSWER,
        response_name="GoalAnswer",
    )
    @action
    async def Delete(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)
        return await sync_to_async(
            lambda: _answer(services.delete_kr(user, workspace, request.kr_id))
        )()

    @grpc_action(
        request=[*WS, {"name": "task_id", "type": "string"}],
        request_name="ForTaskRequest",
        response=[{"name": "contributions", "cardinality": "repeated", "type": Contribution}],
        response_name="ForTaskList",
    )
    @action
    async def ForTask(self, request: Any, context: Any) -> Any:
        """The key results (of goals the caller may see) that count this task."""
        user, workspace = await _scope(request, context)

        def run() -> Any:
            rows = services.for_task(user, workspace, request.task_id)
            return _pb().ForTaskList(
                contributions=[
                    _pb().Contribution(
                        goal_id=r.goal_id, goal_name=r.goal_name, kr_id=r.kr_id, kr_name=r.kr_name
                    )
                    for r in rows
                ]
            )

        return await sync_to_async(run)()


class CheckInService(generics.GenericService):
    @grpc_action(
        request=[
            *KR,
            {"name": "value", "type": "string"},
            {"name": "note", "type": "string"},
        ],
        request_name="CheckInAddRequest",
        response=[
            {"name": "check_in", "type": CheckIn},
            {"name": "goal", "type": Goal},
        ],
        response_name="CheckInAnswer",
    )
    @action
    async def Add(self, request: Any, context: Any) -> Any:
        """Record a reading and a note. A linked key result ignores ``value`` (its tasks say)."""
        user, workspace = await _scope(request, context)

        def run() -> Any:
            entry, view = services.add_check_in(
                user, workspace, request.kr_id, request.value, request.note
            )
            return _pb().CheckInAnswer(check_in=check_in_message(entry), goal=goal_message(view))

        return await sync_to_async(run)()

    @grpc_action(
        request=[*KR, {"name": "limit", "type": "int32"}],
        request_name="CheckInListRequest",
        response=[{"name": "check_ins", "cardinality": "repeated", "type": CheckIn}],
        response_name="CheckInList",
    )
    @action
    async def List(self, request: Any, context: Any) -> Any:
        """Newest first (at most 100)."""
        user, workspace = await _scope(request, context)

        def run() -> Any:
            rows = services.list_check_ins(user, workspace, request.kr_id, request.limit)
            return _pb().CheckInList(check_ins=[check_in_message(r) for r in rows])

        return await sync_to_async(run)()


GRPC_SERVICES = [GoalService, KeyResultService, CheckInService]
