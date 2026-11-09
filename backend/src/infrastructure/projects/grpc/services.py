"""Projects over gRPC (``ProjectController``). Adapters resolve the caller and workspace
(``workspace_id`` in the body, membership checked by ``require_workspace``) and render what
``infrastructure.projects`` decides.

Permissions: List/Get/ListMembers/Favorite need only workspace membership (``workspace.view``);
Create ``project.create``; Update and SetFeatures ``project.update``; Archive/Restore
``project.archive``; AddMember/RemoveMember ``project.member.manage``; ListPrivate
``project.view_private``. A project the caller may not see is NOT_FOUND, like a missing one.
Refusals: ALREADY_EXISTS KEY_TAKEN / KEY_LOCKED / PROJECT_ARCHIVED / LAST_MEMBER (409),
ABORTED VERSION_CONFLICT, INVALID_ARGUMENT for validation, PERMISSION_DENIED_REASON with the
``x-error-*-bin`` trailers for a missing key.
"""

from typing import Any

from asgiref.sync import sync_to_async
from django_socio_grpc import generics
from django_socio_grpc.decorators import grpc_action

from infrastructure.common.grpc.errors import action, require_caller
from infrastructure.common.identity import grpc_caller
from infrastructure.projects import members, services
from infrastructure.projects.features import FEATURES
from infrastructure.projects.grpc.serializers import FeatureInfo, Project, ProjectMember
from infrastructure.projects.models import ProjectMember as MemberRow
from infrastructure.workspaces.scoping import require_workspace

WS = {"name": "workspace_id", "type": "string"}
PROJECT_ID = {"name": "project_id", "type": "string"}
VERSION = {"name": "expected_version", "type": "int32"}
OPTIONAL_TEXT = ("name", "key", "description", "icon", "color", "visibility")


def _pb() -> Any:
    from infrastructure.projects.grpc import projects_pb2

    return projects_pb2


def _message(view: services.ProjectView) -> Any:
    pb, p = _pb(), view.project
    shown = view.can_open  # else: the admin list, which must not reveal the contents
    enabled = services.enabled_features(p)
    return pb.Project(
        id=str(p.pk),
        workspace_id=str(p.workspace_id),
        name=p.name,
        key=p.key,
        description=p.description if shown else "",
        icon=p.icon,
        color=p.color,
        visibility=p.visibility,
        archived_at=p.archived_at.isoformat() if p.archived_at else "",
        version=p.version,
        task_counter=p.task_counter if shown else 0,
        features=[pb.Feature(key=f.key, enabled=f.key in enabled) for f in FEATURES]
        if shown
        else [],
        is_favorite=view.is_favorite,
        member_count=view.member_count,
        is_member=view.is_member,
        can_open=view.can_open,
        created_by=str(p.created_by_id) if shown else "",
    )


def _member(row: MemberRow) -> Any:
    return _pb().ProjectMember(
        user_id=str(row.user_id),
        display_name=row.user.get_full_name(),
        email=row.user.email or "",
        added_at=row.added_at.isoformat(),
    )


async def _scope(request: Any, context: Any) -> tuple[Any, Any]:
    user = require_caller(await grpc_caller(context))
    workspace = await sync_to_async(require_workspace)(user, request.workspace_id)
    return user, workspace


async def _one(request: Any, context: Any, call: Any) -> Any:
    """Resolve the scope, run ``call(user, workspace) -> ProjectView`` and render it."""
    user, workspace = await _scope(request, context)
    return await sync_to_async(lambda: _message(call(user, workspace)))()


class ProjectService(generics.GenericService):
    @grpc_action(
        request=[WS, {"name": "include_archived", "type": "bool"}],
        request_name="ProjectListRequest",
        response=[
            {"name": "projects", "cardinality": "repeated", "type": Project},
            {"name": "feature_info", "cardinality": "repeated", "type": FeatureInfo},
        ],
        response_name="ProjectList",
    )
    @action
    async def List(self, request: Any, context: Any) -> Any:
        pb = _pb()
        user, workspace = await _scope(request, context)

        def run() -> Any:
            found = services.list_projects(user, workspace, request.include_archived)
            return pb.ProjectList(
                projects=[_message(v) for v in found],
                feature_info=[
                    pb.FeatureInfo(key=f.key, label=f.label, description=f.description)
                    for f in FEATURES
                ],
            )

        return await sync_to_async(run)()

    @grpc_action(
        request=[WS, {"name": "id", "type": "string"}],
        request_name="ProjectGetRequest",
        response=Project,
        response_name="Project",
    )
    @action
    async def Get(self, request: Any, context: Any) -> Any:
        return await _one(request, context, lambda u, w: services.get(u, w, request.id))

    @grpc_action(
        request=[
            WS,
            {"name": "name", "type": "string"},
            {"name": "key", "type": "string"},
            {"name": "description", "type": "string"},
            {"name": "icon", "type": "string"},
            {"name": "color", "type": "string"},
            {"name": "visibility", "type": "string"},
        ],
        request_name="ProjectCreateRequest",
        response=Project,
        response_name="Project",
    )
    @action
    async def Create(self, request: Any, context: Any) -> Any:
        return await _one(
            request,
            context,
            lambda u, w: services.create(
                u,
                w,
                request.name,
                request.key,
                request.description,
                request.icon,
                request.color,
                request.visibility or "open",
            ),
        )

    @grpc_action(
        request=[
            WS,
            {"name": "id", "type": "string"},
            VERSION,
            *({"name": n, "type": "string", "cardinality": "optional"} for n in OPTIONAL_TEXT),
        ],
        request_name="ProjectUpdateRequest",
        response=Project,
        response_name="Project",
    )
    @action
    async def Update(self, request: Any, context: Any) -> Any:
        sent = {n: getattr(request, n) for n in OPTIONAL_TEXT if request.HasField(n)}
        return await _one(
            request,
            context,
            lambda u, w: services.update(u, w, request.id, request.expected_version, **sent),
        )

    @grpc_action(
        request=[WS, {"name": "id", "type": "string"}, VERSION],
        request_name="ProjectArchiveRequest",
        response=Project,
        response_name="Project",
    )
    @action
    async def Archive(self, request: Any, context: Any) -> Any:
        return await _one(
            request,
            context,
            lambda u, w: services.archive(u, w, request.id, request.expected_version),
        )

    @grpc_action(
        request=[WS, {"name": "id", "type": "string"}, VERSION],
        request_name="ProjectRestoreRequest",
        response=Project,
        response_name="Project",
    )
    @action
    async def Restore(self, request: Any, context: Any) -> Any:
        return await _one(
            request,
            context,
            lambda u, w: services.restore(u, w, request.id, request.expected_version),
        )

    @grpc_action(
        request=[
            WS,
            PROJECT_ID,
            {"name": "enabled_keys", "type": "string", "cardinality": "repeated"},
            VERSION,
        ],
        request_name="ProjectSetFeaturesRequest",
        response=Project,
        response_name="Project",
    )
    @action
    async def SetFeatures(self, request: Any, context: Any) -> Any:
        return await _one(
            request,
            context,
            lambda u, w: services.set_features(
                u, w, request.project_id, list(request.enabled_keys), request.expected_version
            ),
        )

    @grpc_action(
        request=[WS, PROJECT_ID, {"name": "favorite", "type": "bool"}],
        request_name="ProjectFavoriteRequest",
        response=Project,
        response_name="Project",
    )
    @action
    async def Favorite(self, request: Any, context: Any) -> Any:
        return await _one(
            request,
            context,
            lambda u, w: services.favorite(u, w, request.project_id, request.favorite),
        )

    @grpc_action(
        request=[WS, PROJECT_ID],
        request_name="ProjectListMembersRequest",
        response=[{"name": "members", "cardinality": "repeated", "type": ProjectMember}],
        response_name="ProjectMemberList",
    )
    @action
    async def ListMembers(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)
        rows = await sync_to_async(
            lambda: [_member(r) for r in members.list_members(user, workspace, request.project_id)]
        )()
        return _pb().ProjectMemberList(members=rows)

    @grpc_action(
        request=[WS, PROJECT_ID, {"name": "user_id", "type": "string"}],
        request_name="ProjectAddMemberRequest",
        response=ProjectMember,
        response_name="ProjectMember",
    )
    @action
    async def AddMember(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)
        return await sync_to_async(
            lambda: _member(
                members.add_member(user, workspace, request.project_id, request.user_id)
            )
        )()

    @grpc_action(
        request=[WS, PROJECT_ID, {"name": "user_id", "type": "string"}],
        request_name="ProjectRemoveMemberRequest",
        response=[],
        response_name="ProjectEmpty",
    )
    @action
    async def RemoveMember(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)
        await sync_to_async(members.remove_member)(
            user, workspace, request.project_id, request.user_id
        )
        return _pb().ProjectEmpty()

    @grpc_action(
        request=[WS],
        request_name="ProjectListPrivateRequest",
        response=[{"name": "projects", "cardinality": "repeated", "type": Project}],
        response_name="PrivateProjectList",
    )
    @action
    async def ListPrivate(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)
        rows = await sync_to_async(
            lambda: [_message(v) for v in members.list_private(user, workspace)]
        )()
        return _pb().PrivateProjectList(projects=rows)


GRPC_SERVICES = [ProjectService]
