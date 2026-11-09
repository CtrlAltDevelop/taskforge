"""Roles and permission checks over gRPC.

``Role.List`` returns every role the workspace can use plus the full permission
registry grouped by area, so the matrix screen needs one call. ``Role.Update``
replaces name and permission list together; ``expected_version`` is the optimistic lock
(stale -> ABORTED ``VERSION_CONFLICT``, nothing changes). ``Role.Delete`` takes ``reassign_to``
(required when the role still has members). ``Permission.Check`` answers many keys
at once and names the caller's role; the UI uses it to hide buttons (cosmetic: the
server enforces every call). Unknown keys come back ``allowed=false``.
"""

from typing import Any

from asgiref.sync import sync_to_async
from django_socio_grpc import generics
from django_socio_grpc.decorators import grpc_action

from infrastructure.common.grpc.errors import action, require_caller
from infrastructure.common.identity import grpc_caller
from infrastructure.workspaces import access, roles
from infrastructure.workspaces.grpc.serializers import PermissionAnswer, PermissionArea, Role
from infrastructure.workspaces.registry import areas
from infrastructure.workspaces.scoping import require_workspace

WS = {"name": "workspace_id", "type": "string"}
PERMISSIONS = {"name": "permissions", "type": "string", "cardinality": "repeated"}


def _role(view: roles.RoleView) -> Any:
    from infrastructure.workspaces.grpc import workspaces_pb2 as pb

    return pb.Role(
        id=str(view.role.pk),
        name=view.role.name,
        is_builtin=view.role.is_builtin,
        permissions=view.permissions,
        member_count=view.member_count,
        version=view.role.version,
    )


def _registry() -> list[Any]:
    from infrastructure.workspaces.grpc import workspaces_pb2 as pb

    return [
        pb.PermissionArea(
            area=area, permissions=[pb.PermissionInfo(key=p.key, label=p.label) for p in perms]
        )
        for area, perms in areas()
    ]


async def _scope(request: Any, context: Any) -> tuple[Any, Any]:
    user = require_caller(await grpc_caller(context))
    workspace = await sync_to_async(require_workspace)(user, request.workspace_id)
    return user, workspace


class RoleService(generics.GenericService):
    @grpc_action(
        request=[WS],
        request_name="RoleListRequest",
        response=[
            {"name": "roles", "cardinality": "repeated", "type": Role},
            {"name": "registry", "cardinality": "repeated", "type": PermissionArea},
        ],
        response_name="RoleList",
    )
    @action
    async def List(self, request: Any, context: Any) -> Any:
        from infrastructure.workspaces.grpc import workspaces_pb2 as pb

        user, workspace = await _scope(request, context)
        rows = await sync_to_async(lambda: [_role(v) for v in roles.list_roles(workspace, user)])()
        return pb.RoleList(roles=rows, registry=_registry())

    @grpc_action(
        request=[WS, {"name": "name", "type": "string"}, PERMISSIONS],
        request_name="RoleCreateRequest",
        response=Role,
        response_name="Role",
    )
    @action
    async def Create(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)
        return await sync_to_async(
            lambda: _role(roles.create_role(workspace, user, request.name, request.permissions))
        )()

    @grpc_action(
        request=[
            WS,
            {"name": "id", "type": "string"},
            {"name": "name", "type": "string"},
            PERMISSIONS,
            {"name": "expected_version", "type": "int32"},
        ],
        request_name="RoleUpdateRequest",
        response=Role,
        response_name="Role",
    )
    @action
    async def Update(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)
        return await sync_to_async(
            lambda: _role(
                roles.update_role(
                    workspace,
                    user,
                    request.id,
                    request.expected_version,
                    request.name,
                    request.permissions,
                )
            )
        )()

    @grpc_action(
        request=[WS, {"name": "id", "type": "string"}, {"name": "reassign_to", "type": "string"}],
        request_name="RoleDeleteRequest",
        response=[],
        response_name="RoleEmpty",
    )
    @action
    async def Delete(self, request: Any, context: Any) -> Any:
        from infrastructure.workspaces.grpc import workspaces_pb2 as pb

        user, workspace = await _scope(request, context)
        await sync_to_async(roles.delete_role)(workspace, user, request.id, request.reassign_to)
        return pb.RoleEmpty()


class PermissionService(generics.GenericService):
    @grpc_action(
        request=[WS, {"name": "keys", "type": "string", "cardinality": "repeated"}],
        request_name="PermissionCheckRequest",
        response=[
            {"name": "answers", "cardinality": "repeated", "type": PermissionAnswer},
            {"name": "role_id", "type": "string"},
            {"name": "role_name", "type": "string"},
        ],
        response_name="PermissionCheckResponse",
    )
    @action
    async def Check(self, request: Any, context: Any) -> Any:
        from infrastructure.workspaces.grpc import workspaces_pb2 as pb

        user, workspace = await _scope(request, context)

        def run() -> Any:
            grant, answers = access.check(user, workspace, list(request.keys))
            return pb.PermissionCheckResponse(
                answers=[pb.PermissionAnswer(key=k, allowed=v) for k, v in answers.items()],
                role_id=str(grant.role.pk),
                role_name=grant.role.name,
            )

        return await sync_to_async(run)()
