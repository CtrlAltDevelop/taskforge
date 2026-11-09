"""Members and invitations over gRPC.

Every call except Accept/Decline names its workspace in the request body
(``workspace_id``) and is checked with the scoping helper, so a non-member, a
removed member and an unknown id all get the same PERMISSION_DENIED. Accept and
Decline need only a signed-in caller; the token is the capability.

Permissions: Member.List needs member.view, Remove member.remove, SetRole member.set_role,
Invitation.Create/CreateLink/List/Revoke/Resend member.invite (Create/CreateLink may carry
a role_id: visible in the workspace, else NOT_FOUND, and every key of it held by the
caller); Leave, Accept and Decline need none. A member lacking one gets PERMISSION_DENIED
with detail
"PERMISSION_DENIED_REASON: missing: x; your role: Y" (and x-error-*-bin trailers).
Refusals: expired/revoked/used-up invitations are NOT_FOUND with title
INVITE_EXPIRED / INVITE_REVOKED / INVITE_USED_UP; a wrong email is
PERMISSION_DENIED INVITE_EMAIL_MISMATCH; owner protection is PERMISSION_DENIED
OWNER_PROTECTED; INVITE_BEFORE_REMOVAL (410 -> NOT_FOUND) refuses an
invitation created before the caller was removed; invitation quota is RESOURCE_EXHAUSTED.
"""

from typing import Any

from asgiref.sync import sync_to_async
from django_socio_grpc import generics
from django_socio_grpc.decorators import grpc_action

from infrastructure.common.grpc.errors import action, require_caller
from infrastructure.common.identity import grpc_caller
from infrastructure.workspaces import access, invitations, members
from infrastructure.workspaces.grpc.serializers import Invitation, Member, Workspace
from infrastructure.workspaces.grpc.services import workspace_message
from infrastructure.workspaces.models import Invitation as InvitationRow
from infrastructure.workspaces.models import WorkspaceMember
from infrastructure.workspaces.scoping import require_workspace

WS = {"name": "workspace_id", "type": "string"}


def _member(row: WorkspaceMember) -> Any:
    from infrastructure.workspaces.grpc import workspaces_pb2 as pb

    return pb.Member(
        user_id=str(row.user_id),
        display_name=row.user.get_full_name(),
        email=row.user.email or "",
        joined_at=row.joined_at.isoformat(),
        is_owner=access.is_owner_role(row.role),
        status=row.status,
        role_id=str(row.role_id),
        role_name=row.role.name,
    )


def _invitation(row: InvitationRow, token: str = "") -> Any:
    from infrastructure.workspaces.grpc import workspaces_pb2 as pb

    return pb.Invitation(
        id=str(row.id),
        workspace_id=str(row.workspace_id),
        email=row.email or "",
        is_link=row.email is None,
        created_by=str(row.created_by_id),
        created_by_name=row.created_by.get_full_name(),
        created_at=row.created_at.isoformat(),
        expires_at=row.expires_at.isoformat(),
        max_uses=row.max_uses,
        uses=row.uses,
        state=invitations.state_of(row),
        token=token if row.email is None else "",  # email tokens travel only by email
        role_id=str(row.role_id or ""),
        role_name=row.role.name if row.role else "",
    )


async def _scope(request: Any, context: Any) -> tuple[Any, Any]:
    user = require_caller(await grpc_caller(context))
    workspace = await sync_to_async(require_workspace)(user, request.workspace_id)
    return user, workspace


class MemberService(generics.GenericService):
    @grpc_action(
        request=[WS],
        request_name="MemberListRequest",
        response=[{"name": "members", "cardinality": "repeated", "type": Member}],
        response_name="MemberList",
    )
    @action
    async def List(self, request: Any, context: Any) -> Any:
        from infrastructure.workspaces.grpc import workspaces_pb2 as pb

        user, workspace = await _scope(request, context)
        rows = await sync_to_async(
            lambda: [_member(r) for r in members.list_members(workspace, user)]
        )()
        return pb.MemberList(members=rows)

    @grpc_action(
        request=[WS, {"name": "user_id", "type": "string"}],
        request_name="MemberRemoveRequest",
        response=[],
        response_name="MemberEmpty",
    )
    @action
    async def Remove(self, request: Any, context: Any) -> Any:
        from infrastructure.workspaces.grpc import workspaces_pb2 as pb

        user, workspace = await _scope(request, context)
        await sync_to_async(members.remove)(workspace, user, request.user_id)
        return pb.MemberEmpty()

    @grpc_action(
        request=[WS, {"name": "user_id", "type": "string"}, {"name": "role_id", "type": "string"}],
        request_name="MemberSetRoleRequest",
        response=Member,
        response_name="Member",
    )
    @action
    async def SetRole(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)

        def run() -> Any:
            return _member(members.set_role(workspace, user, request.user_id, request.role_id))

        return await sync_to_async(run)()

    @grpc_action(
        request=[WS],
        request_name="MemberLeaveRequest",
        response=[],
        response_name="MemberEmpty",
    )
    @action
    async def Leave(self, request: Any, context: Any) -> Any:
        from infrastructure.workspaces.grpc import workspaces_pb2 as pb

        user, workspace = await _scope(request, context)
        await sync_to_async(members.leave)(workspace, user)
        return pb.MemberEmpty()


class InvitationService(generics.GenericService):
    @grpc_action(
        request=[
            WS,
            {"name": "emails", "type": "string", "cardinality": "repeated"},
            {"name": "role_id", "type": "string"},  # "" = Member
        ],
        request_name="InvitationCreateRequest",
        response=[
            {"name": "invitations", "cardinality": "repeated", "type": Invitation},
            {"name": "skipped_emails", "type": "string", "cardinality": "repeated"},
            {"name": "undelivered_emails", "type": "string", "cardinality": "repeated"},
        ],
        response_name="InvitationCreateResponse",
    )
    @action
    async def Create(self, request: Any, context: Any) -> Any:
        from infrastructure.workspaces.grpc import workspaces_pb2 as pb

        user, workspace = await _scope(request, context)

        def run() -> Any:
            result = invitations.create_invitations(
                workspace, user, list(request.emails), request.role_id
            )
            return pb.InvitationCreateResponse(
                invitations=[_invitation(c.invitation, c.token) for c in result.created],
                skipped_emails=result.skipped_emails,
                # Always empty: email is sent after commit on a background pool
                # (invite_mail.py), so failure is unknown here; it is logged and the invite
                # stays pending and resendable. Kept to spare clients a contract change.
            )

        return await sync_to_async(run)()

    @grpc_action(
        request=[
            WS,
            {"name": "expires_in", "type": "int32"},
            {"name": "max_uses", "type": "int32"},
            {"name": "role_id", "type": "string"},  # "" = Member
        ],
        request_name="InvitationCreateLinkRequest",
        response=Invitation,
        response_name="Invitation",
    )
    @action
    async def CreateLink(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)

        def run() -> Any:
            made = invitations.create_link(
                workspace, user, request.expires_in, request.max_uses, request.role_id
            )
            return _invitation(made.invitation, made.token)

        return await sync_to_async(run)()

    @grpc_action(
        request=[WS],
        request_name="InvitationListRequest",
        response=[{"name": "invitations", "cardinality": "repeated", "type": Invitation}],
        response_name="InvitationList",
    )
    @action
    async def List(self, request: Any, context: Any) -> Any:
        from infrastructure.workspaces.grpc import workspaces_pb2 as pb

        user, workspace = await _scope(request, context)
        rows = await sync_to_async(
            lambda: [_invitation(r) for r in invitations.list_pending(workspace, user)]
        )()
        return pb.InvitationList(invitations=rows)

    @grpc_action(
        request=[WS, {"name": "id", "type": "string"}],
        request_name="InvitationRevokeRequest",
        response=Invitation,
        response_name="Invitation",
    )
    @action
    async def Revoke(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)
        row = await sync_to_async(invitations.revoke)(workspace, user, request.id)
        return await sync_to_async(_invitation)(row)

    @grpc_action(
        request=[WS, {"name": "id", "type": "string"}],
        request_name="InvitationResendRequest",
        response=Invitation,
        response_name="Invitation",
    )
    @action
    async def Resend(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)
        made = await sync_to_async(invitations.resend)(workspace, user, request.id)
        return await sync_to_async(_invitation)(made.invitation, made.token)

    @grpc_action(
        request=[{"name": "token", "type": "string"}],
        request_name="InvitationAcceptRequest",
        response=Workspace,
        response_name="Workspace",
    )
    @action
    async def Accept(self, request: Any, context: Any) -> Any:
        user = require_caller(await grpc_caller(context))

        def run() -> Any:
            member = invitations.accept(request.token, user)
            return workspace_message(member.workspace, access.is_owner_role(member.role))

        return await sync_to_async(run)()

    @grpc_action(
        request=[{"name": "token", "type": "string"}],
        request_name="InvitationDeclineRequest",
        response=[],
        response_name="InvitationEmpty",
    )
    @action
    async def Decline(self, request: Any, context: Any) -> Any:
        from infrastructure.workspaces.grpc import workspaces_pb2 as pb

        user = require_caller(await grpc_caller(context))
        await sync_to_async(invitations.decline)(request.token, user)
        return pb.InvitationEmpty()


GRPC_SERVICES = [MemberService, InvitationService]
