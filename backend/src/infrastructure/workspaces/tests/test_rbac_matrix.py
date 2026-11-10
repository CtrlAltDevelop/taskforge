"""Every workspace-scoped endpoint x every built-in role, on gRPC and REST.

The table is checked against the real handler list: a new endpoint that is in
neither ``ENDPOINTS`` nor ``EXEMPT`` (and is not in ``ACCOUNT_LEVEL_MODULES``) fails
``test_every_handler_is_classified``. Expected outcomes come from the registry,
not from hand-written booleans.
"""

from collections.abc import Callable
from dataclasses import dataclass, field
from typing import Any

import grpc
import pytest
from django.contrib.auth import get_user_model
from django.core.files.uploadedfile import SimpleUploadedFile
from django.test import Client
from google.protobuf.empty_pb2 import Empty

from infrastructure.customfields import services as field_services
from infrastructure.customfields.grpc import customfields_pb2 as fpb
from infrastructure.customfields.grpc import customfields_pb2_grpc as fstubs
from infrastructure.projects import members as project_members
from infrastructure.projects import services as project_services
from infrastructure.projects.grpc import projects_pb2 as ppb
from infrastructure.projects.grpc import projects_pb2_grpc as pstubs
from infrastructure.savedviews import services as view_services
from infrastructure.savedviews.grpc import savedviews_pb2 as vpb
from infrastructure.savedviews.grpc import savedviews_pb2_grpc as vstubs
from infrastructure.tasks import links as task_links
from infrastructure.tasks import services as task_services
from infrastructure.tasks.grpc import tasks_pb2 as tpb
from infrastructure.tasks.grpc import tasks_pb2_grpc as tstubs
from infrastructure.workflows import services as workflow_services
from infrastructure.workflows.grpc import workflows_pb2 as wpb
from infrastructure.workflows.grpc import workflows_pb2_grpc as wstubs
from infrastructure.workspaces import access, invitations, roles, services
from infrastructure.workspaces.grpc import workspaces_pb2 as pb
from infrastructure.workspaces.grpc import workspaces_pb2_grpc as stubs
from infrastructure.workspaces.models import Role, WorkspaceMember
from infrastructure.workspaces.registry import ALL_KEYS, BUILTIN_GRANTS, BUILTIN_ROLES

from .test_grpc import _token

GrpcCall = Callable[..., Any]
PNG = b"\x89PNG\r\n\x1a\n" + b"0" * 32
LOGO_ROUTE = "POST /workspaces/{workspace_id}/logo"


@dataclass
class World:
    """One fresh workspace with a user per built-in role, a target member and sample data."""

    workspace: Any
    tokens: dict[str, str]
    target: Any
    custom_role_id: str
    invitation_id: str
    project_id: str  # an open project
    private_id: str  # a private project the Owner belongs to
    role_ids: dict[str, str] = field(default_factory=dict)
    task_id: str = ""  # set by the prepare of the task endpoints that need one
    other_task_id: str = ""  # a second task, for the link endpoints
    link_id: str = ""  # a link from ``task_id`` to ``other_task_id``
    field_id: str = ""  # a custom field of the open project
    view_id: str = ""  # a saved layout shared with the open project

    @property
    def ws(self) -> str:
        return str(self.workspace.id)


@dataclass(frozen=True)
class Endpoint:
    name: str
    permission: str
    call: Callable[[World, str, GrpcCall], Any]
    prepare: Callable[[World], None] | None = None
    filtered: bool = False  # lists only what the caller may see instead of refusing


def _grpc(stub: Any, method: str, build: Callable[[World], Any]) -> Callable[..., Any]:
    return lambda w, role, call: call(stub, method, build(w), token=w.tokens[role])


def _logo(w: World, role: str, _: GrpcCall) -> Any:
    response = Client().post(
        f"/api/v1/workspaces/{w.ws}/logo",
        {"file": SimpleUploadedFile("logo.png", PNG, content_type="image/png")},
        HTTP_AUTHORIZATION=f"Bearer {w.tokens[role]}",
    )
    if response.status_code != 200:
        raise RestRefusal(response)
    return response


class RestRefusal(Exception):
    def __init__(self, response: Any) -> None:
        super().__init__(response.status_code)
        self.response = response


def _archive_project(w: World) -> None:
    project_services.archive(w.workspace.created_by, w.workspace, w.project_id, 1)


def _add_target_to_private(w: World) -> None:
    project_members.add_member(w.workspace.created_by, w.workspace, w.private_id, str(w.target.pk))


def _make_task(w: World) -> None:
    owner = w.workspace.created_by
    w.task_id = str(task_services.create(owner, w.workspace, w.project_id, "Seed").pk)


def _make_two_tasks(w: World) -> None:
    _make_task(w)
    owner = w.workspace.created_by
    w.other_task_id = str(task_services.create(owner, w.workspace, w.project_id, "Other").pk)


def _make_link(w: World) -> None:
    _make_two_tasks(w)
    owner = w.workspace.created_by
    link = task_links.add(owner, w.workspace, w.task_id, w.other_task_id, "relates")
    w.link_id = str(link.pk)


def _make_field(w: World) -> None:
    w.field_id = str(
        field_services.create(
            w.workspace.created_by, w.workspace, w.project_id, name="Env", type="text"
        ).pk
    )


def _make_archived_field(w: World) -> None:
    _make_field(w)
    field_services.archive(w.workspace.created_by, w.workspace, w.project_id, w.field_id, 1)


def _make_shared_view(w: World) -> None:
    w.view_id = str(
        view_services.save(
            w.workspace.created_by, w.workspace, w.project_id, name="Team", config={}, shared=True
        ).pk
    )


def _make_deleted_task(w: World) -> None:
    _make_task(w)
    task_services.delete(w.workspace.created_by, w.workspace, w.project_id, w.task_id)


def _soft_delete(w: World) -> None:
    services.delete(w.workspace.created_by, w.ws, "Acme")


W, M, INV, R = (
    stubs.WorkspaceControllerStub,
    stubs.MemberControllerStub,
    stubs.InvitationControllerStub,
    stubs.RoleControllerStub,
)
ENDPOINTS: tuple[Endpoint, ...] = (
    Endpoint(
        "WorkspaceController.Update",
        "workspace.update",
        _grpc(
            W,
            "Update",
            lambda w: pb.WorkspaceUpdateRequest(id=w.ws, expected_version=1, name="New"),
        ),
    ),
    Endpoint(
        "WorkspaceController.Delete",
        "workspace.delete",
        _grpc(W, "Delete", lambda w: pb.WorkspaceDeleteRequest(id=w.ws, confirmation="Acme")),
    ),
    Endpoint(
        "WorkspaceController.Restore",
        "workspace.delete",
        _grpc(W, "Restore", lambda w: pb.WorkspaceRestoreRequest(id=w.ws)),
        prepare=_soft_delete,
    ),
    Endpoint(
        "WorkspaceController.ListDeleted",
        "workspace.delete",
        _grpc(W, "ListDeleted", lambda w: Empty()),
        prepare=_soft_delete,
        filtered=True,
    ),
    Endpoint(LOGO_ROUTE, "workspace.update", _logo),
    Endpoint(
        "MemberController.List",
        "member.view",
        _grpc(M, "List", lambda w: pb.MemberListRequest(workspace_id=w.ws)),
    ),
    Endpoint(
        "MemberController.Remove",
        "member.remove",
        _grpc(
            M,
            "Remove",
            lambda w: pb.MemberRemoveRequest(workspace_id=w.ws, user_id=str(w.target.pk)),
        ),
    ),
    Endpoint(
        "MemberController.SetRole",
        "member.set_role",
        _grpc(
            M,
            "SetRole",
            lambda w: pb.MemberSetRoleRequest(
                workspace_id=w.ws, user_id=str(w.target.pk), role_id=w.role_ids["Viewer"]
            ),
        ),
    ),
    Endpoint(
        "InvitationController.Create",
        "member.invite",
        _grpc(
            INV,
            "Create",
            lambda w: pb.InvitationCreateRequest(workspace_id=w.ws, emails=["new@example.com"]),
        ),
    ),
    Endpoint(
        "InvitationController.CreateLink",
        "member.invite",
        _grpc(INV, "CreateLink", lambda w: pb.InvitationCreateLinkRequest(workspace_id=w.ws)),
    ),
    Endpoint(
        "InvitationController.List",
        "member.invite",
        _grpc(INV, "List", lambda w: pb.InvitationListRequest(workspace_id=w.ws)),
    ),
    Endpoint(
        "InvitationController.Revoke",
        "member.invite",
        _grpc(
            INV,
            "Revoke",
            lambda w: pb.InvitationRevokeRequest(workspace_id=w.ws, id=w.invitation_id),
        ),
    ),
    Endpoint(
        "InvitationController.Resend",
        "member.invite",
        _grpc(
            INV,
            "Resend",
            lambda w: pb.InvitationResendRequest(workspace_id=w.ws, id=w.invitation_id),
        ),
    ),
    Endpoint(
        "RoleController.List",
        "role.view",
        _grpc(R, "List", lambda w: pb.RoleListRequest(workspace_id=w.ws)),
    ),
    Endpoint(
        "RoleController.Create",
        "role.manage",
        _grpc(
            R,
            "Create",
            lambda w: pb.RoleCreateRequest(
                workspace_id=w.ws, name="Fresh", permissions=["workspace.view"]
            ),
        ),
    ),
    Endpoint(
        "RoleController.Update",
        "role.manage",
        _grpc(
            R,
            "Update",
            lambda w: pb.RoleUpdateRequest(
                workspace_id=w.ws,
                id=w.custom_role_id,
                name="Renamed",
                permissions=["workspace.view"],
                expected_version=1,
            ),
        ),
    ),
    Endpoint(
        "RoleController.Delete",
        "role.manage",
        _grpc(
            R,
            "Delete",
            lambda w: pb.RoleDeleteRequest(
                workspace_id=w.ws, id=w.custom_role_id, reassign_to=w.role_ids["Member"]
            ),
        ),
    ),
)

PR = pstubs.ProjectControllerStub
_PROJECT_CALLS = (  # (rpc, permission, request builder, prepare)
    ("List", "workspace.view", lambda w: ppb.ProjectListRequest(workspace_id=w.ws), None),
    (
        "Get",
        "workspace.view",
        lambda w: ppb.ProjectGetRequest(workspace_id=w.ws, id=w.project_id),
        None,
    ),
    (
        "Create",
        "project.create",
        lambda w: ppb.ProjectCreateRequest(workspace_id=w.ws, name="New", key="NEW"),
        None,
    ),
    (
        "Update",
        "project.update",
        lambda w: ppb.ProjectUpdateRequest(
            workspace_id=w.ws, id=w.project_id, expected_version=1, name="Renamed"
        ),
        None,
    ),
    (
        "SetFeatures",
        "project.update",
        lambda w: ppb.ProjectSetFeaturesRequest(
            workspace_id=w.ws, project_id=w.project_id, enabled_keys=["sprints"], expected_version=1
        ),
        None,
    ),
    (
        "Archive",
        "project.archive",
        lambda w: ppb.ProjectArchiveRequest(workspace_id=w.ws, id=w.project_id, expected_version=1),
        None,
    ),
    (
        "Restore",
        "project.archive",
        lambda w: ppb.ProjectRestoreRequest(workspace_id=w.ws, id=w.project_id, expected_version=2),
        _archive_project,
    ),
    (
        "Favorite",
        "workspace.view",
        lambda w: ppb.ProjectFavoriteRequest(
            workspace_id=w.ws, project_id=w.project_id, favorite=True
        ),
        None,
    ),
    (
        "ListMembers",
        "workspace.view",
        lambda w: ppb.ProjectListMembersRequest(workspace_id=w.ws, project_id=w.project_id),
        None,
    ),
    (
        "AddMember",
        "project.member.manage",
        lambda w: ppb.ProjectAddMemberRequest(
            workspace_id=w.ws, project_id=w.private_id, user_id=str(w.target.pk)
        ),
        None,
    ),
    (
        "RemoveMember",
        "project.member.manage",
        lambda w: ppb.ProjectRemoveMemberRequest(
            workspace_id=w.ws, project_id=w.private_id, user_id=str(w.target.pk)
        ),
        _add_target_to_private,
    ),
    (
        "ListPrivate",
        "project.view_private",
        lambda w: ppb.ProjectListPrivateRequest(workspace_id=w.ws),
        None,
    ),
)
ENDPOINTS += tuple(
    Endpoint(f"ProjectController.{rpc}", permission, _grpc(PR, rpc, build), prepare=prepare)
    for rpc, permission, build, prepare in _PROJECT_CALLS
)

TK = tstubs.TaskControllerStub


def _task_request(message: Any, **extra: Any) -> Callable[[World], Any]:
    return lambda w: message(workspace_id=w.ws, project_id=w.project_id, id=w.task_id, **extra)


_TASK_CALLS = (  # (rpc, permission, request builder, prepare)
    ("Get", "workspace.view", _task_request(tpb.TaskGetRequest), _make_task),
    (
        "List",
        "workspace.view",
        lambda w: tpb.TaskListRequest(workspace_id=w.ws, project_id=w.project_id),
        None,
    ),
    (
        "Create",
        "task.create",
        lambda w: tpb.TaskCreateRequest(workspace_id=w.ws, project_id=w.project_id, title="New"),
        None,
    ),
    (
        "Update",
        "task.update",
        _task_request(tpb.TaskUpdateRequest, expected_version=1, title="Renamed"),
        _make_task,
    ),
    ("Delete", "task.delete", _task_request(tpb.TaskDeleteRequest), _make_task),
    ("Restore", "task.delete", _task_request(tpb.TaskRestoreRequest), _make_deleted_task),
    (
        "SetParent",
        "task.update",
        _task_request(tpb.TaskSetParentRequest, expected_version=1, parent_id=""),
        _make_task,
    ),
    ("ListChildren", "workspace.view", _task_request(tpb.TaskListChildrenRequest), _make_task),
    (
        "GroupCounts",
        "workspace.view",
        lambda w: tpb.TaskGroupCountsRequest(
            workspace_id=w.ws, project_id=w.project_id, group_by="status"
        ),
        None,
    ),
    (
        "BulkUpdate",
        "task.update",
        lambda w: tpb.TaskBulkUpdateRequest(
            workspace_id=w.ws, project_id=w.project_id, ids=[w.task_id], priority="low"
        ),
        _make_task,
    ),
    (
        "ListTrash",
        "task.delete",
        lambda w: tpb.TaskListTrashRequest(workspace_id=w.ws, project_id=w.project_id),
        None,
    ),
)
ENDPOINTS += tuple(
    Endpoint(f"TaskController.{rpc}", permission, _grpc(TK, rpc, build), prepare=prepare)
    for rpc, permission, build, prepare in _TASK_CALLS
)

BD = tstubs.BoardControllerStub
ENDPOINTS += (
    Endpoint(
        "BoardController.Get",
        "workspace.view",
        _grpc(
            BD,
            "Get",
            lambda w: tpb.BoardGetRequest(workspace_id=w.ws, project_id=w.project_id),
        ),
    ),
    Endpoint(
        "BoardController.ListColumn",
        "workspace.view",
        _grpc(
            BD,
            "ListColumn",
            lambda w: tpb.BoardListColumnRequest(
                workspace_id=w.ws, project_id=w.project_id, group_by="priority", column="none"
            ),
        ),
    ),
    Endpoint(
        "BoardController.Move",
        "task.update",
        _grpc(
            BD,
            "Move",
            lambda w: tpb.BoardMoveRequest(
                workspace_id=w.ws,
                project_id=w.project_id,
                id=w.task_id,
                expected_version=1,
                group_by="priority",
                column="high",
            ),
        ),
        _make_task,
    ),
)

LK = tstubs.LinkControllerStub
ENDPOINTS += (
    Endpoint(
        "LinkController.Add",
        "task.update",
        _grpc(
            LK,
            "Add",
            lambda w: tpb.LinkAddRequest(
                workspace_id=w.ws, task_id=w.task_id, other_task_id=w.other_task_id, kind="relates"
            ),
        ),
        _make_two_tasks,
    ),
    Endpoint(
        "LinkController.Remove",
        "task.update",
        _grpc(
            LK,
            "Remove",
            lambda w: tpb.LinkRemoveRequest(workspace_id=w.ws, task_id=w.task_id, id=w.link_id),
        ),
        _make_link,
    ),
    Endpoint(
        "LinkController.SearchTasks",
        "workspace.view",
        _grpc(LK, "SearchTasks", lambda w: tpb.LinkSearchTasksRequest(workspace_id=w.ws, query="")),
    ),
    Endpoint(
        "LinkController.ListForTask",
        "workspace.view",
        _grpc(
            LK,
            "ListForTask",
            lambda w: tpb.LinkListForTaskRequest(workspace_id=w.ws, task_id=w.task_id),
        ),
        _make_task,
    ),
)

WF = wstubs.WorkflowControllerStub


def _workflow_fields(w: World) -> dict[str, Any]:
    """The project's current workflow, re-sent unchanged (so the call is valid for any role)."""
    view = workflow_services.get(w.workspace.created_by, w.workspace, w.project_id)
    return {
        "workspace_id": w.ws,
        "project_id": w.project_id,
        "restrict_transitions": view.workflow.restrict_transitions,
        "restrict_creation": view.workflow.restrict_creation,
        "statuses": [
            wpb.StatusInput(
                key=str(s.pk),
                name=s.name,
                color=s.color,
                category=s.category,
                is_default=s.is_default,
            )
            for s in view.statuses
        ],
    }


def _workflow_get(w: World) -> Any:
    return wpb.WorkflowGetRequest(workspace_id=w.ws, project_id=w.project_id)


def _workflow_update(w: World) -> Any:
    version = workflow_services.get(w.workspace.created_by, w.workspace, w.project_id)
    return wpb.WorkflowUpdateRequest(
        expected_version=version.workflow.version, **_workflow_fields(w)
    )


def _workflow_validate(w: World) -> Any:
    return wpb.WorkflowValidateRequest(**_workflow_fields(w))


def _move_request(w: World) -> Any:
    """Move a task to its own status (a valid no-op for every role that may move at all)."""
    status, version = "", 1
    if w.task_id:  # the outsider check builds requests for a world with no task
        task = task_services.get(w.workspace.created_by, w.workspace, w.project_id, w.task_id)
        status, version = str(task.status_id), task.version
    return tpb.TaskMoveRequest(
        workspace_id=w.ws,
        project_id=w.project_id,
        id=w.task_id,
        expected_version=version,
        status=status,
    )


ENDPOINTS += (
    Endpoint("WorkflowController.Get", "workspace.view", _grpc(WF, "Get", _workflow_get)),
    Endpoint("WorkflowController.Update", "project.update", _grpc(WF, "Update", _workflow_update)),
    Endpoint(
        "WorkflowController.Validate", "project.update", _grpc(WF, "Validate", _workflow_validate)
    ),
    Endpoint("TaskController.Move", "task.update", _grpc(TK, "Move", _move_request), _make_task),
)

VC = vstubs.ViewControllerStub
ENDPOINTS += (
    Endpoint(
        "ViewController.List",
        "workspace.view",
        _grpc(
            VC,
            "List",
            lambda w: vpb.ViewListRequest(workspace_id=w.ws, project_id=w.project_id),
        ),
    ),
    # Saving or deleting a layout shared with the project needs project.update (a personal one
    # needs only workspace.view; see the savedviews tests).
    Endpoint(
        "ViewController.Save",
        "project.update",
        _grpc(
            VC,
            "Save",
            lambda w: vpb.ViewSaveRequest(
                workspace_id=w.ws, project_id=w.project_id, name="Shared", shared=True
            ),
        ),
    ),
    Endpoint(
        "ViewController.Delete",
        "project.update",
        _grpc(
            VC,
            "Delete",
            lambda w: vpb.ViewDeleteRequest(
                workspace_id=w.ws, project_id=w.project_id, id=w.view_id
            ),
        ),
        _make_shared_view,
    ),
)

FC = fstubs.FieldControllerStub


def _field_request(message: Any, version: int = 1, **extra: Any) -> Callable[[World], Any]:
    return lambda w: message(
        workspace_id=w.ws, project_id=w.project_id, id=w.field_id, expected_version=version, **extra
    )


ENDPOINTS += (
    Endpoint(
        "FieldController.List",
        "workspace.view",
        _grpc(
            FC,
            "List",
            lambda w: fpb.FieldListRequest(workspace_id=w.ws, project_id=w.project_id),
        ),
    ),
    Endpoint(
        "FieldController.Create",
        "project.update",
        _grpc(
            FC,
            "Create",
            lambda w: fpb.FieldCreateRequest(
                workspace_id=w.ws, project_id=w.project_id, name="Env", type="text"
            ),
        ),
    ),
    Endpoint(
        "FieldController.Update",
        "project.update",
        _grpc(FC, "Update", _field_request(fpb.FieldUpdateRequest, required=False)),
        _make_field,
    ),
    Endpoint(
        "FieldController.Reorder",
        "project.update",
        _grpc(
            FC,
            "Reorder",
            lambda w: fpb.FieldReorderRequest(
                workspace_id=w.ws, project_id=w.project_id, ids=[w.field_id]
            ),
        ),
        _make_field,
    ),
    Endpoint(
        "FieldController.Archive",
        "project.update",
        _grpc(FC, "Archive", _field_request(fpb.FieldArchiveRequest)),
        _make_field,
    ),
    Endpoint(
        "FieldController.Restore",
        "project.update",
        _grpc(FC, "Restore", _field_request(fpb.FieldRestoreRequest, version=2)),
        _make_archived_field,
    ),
)

# Handlers that need no workspace permission, and why.
EXEMPT = {
    "WorkspaceController.List": "account-level: the caller's own workspaces",
    "WorkspaceController.Create": "account-level: anyone signed in may start a workspace",
    "MemberController.Leave": "self-service (last-owner protection still applies)",
    "InvitationController.Accept": "token is the capability",
    "InvitationController.Decline": "token is the capability",
    "PermissionController.Check": "membership only: answers about the caller's own grants",
    "POST /invites/preview": "public, token-based",
    "POST /invites/accept": "token is the capability",
}
# Account-level or platform handler modules (exact names): can() does not apply. A new
# workspace-scoped handler under infrastructure.common or apps must NOT be added here.
ACCOUNT_LEVEL_MODULES = frozenset(
    {
        "infrastructure.accounts.grpc.services",
        "infrastructure.accounts.rest.api",
        "infrastructure.auth.email_code.grpc.services",
        "infrastructure.auth.email_code.rest.login",
        "infrastructure.auth.magic_link.grpc.services",
        "infrastructure.auth.magic_link.rest.login",
        "infrastructure.auth.password.grpc.services",
        "infrastructure.auth.sms_code.grpc.services",
        "infrastructure.auth.sms_code.rest.login",
        "infrastructure.auth.twofactor.grpc.services",
        "infrastructure.common.grpc.services",
        "infrastructure.common.rest.api",
        "infrastructure.oauth.apple.grpc.services",
        "infrastructure.oauth.apple.rest.login",
        "infrastructure.oauth.github.grpc.services",
        "infrastructure.oauth.github.rest.login",
        "infrastructure.oauth.google.grpc.services",
        "infrastructure.oauth.google.rest.login",
        "infrastructure.oauth.microsoft.grpc.services",
        "infrastructure.oauth.microsoft.rest.login",
        "infrastructure.oauth.rotation.grpc.services",
        "infrastructure.oauth.rotation.rest.api",
        "infrastructure.oauth.session.grpc.services",
        "infrastructure.oauth.sliding.grpc.services",
        "infrastructure.auth.password.rest.api",
        "infrastructure.auth.password.rest.login",
        "infrastructure.auth.twofactor.rest.api",
        "infrastructure.auth.twofactor.rest.login",
        "infrastructure.oauth.core.rest.exchange",
        "infrastructure.oauth.core.rest.tokens",
        "apps.wallet.rest.hooks",
        "apps.club.grpc.services",
        "apps.club.rest.v1",
        "apps.cms.grpc.services",
        "apps.cms.rest.v1",
        "apps.notifications.grpc.services",
        "apps.notifications.rest.v1",
        "apps.shop.grpc.services",
        "apps.shop.rest.v1",
        "apps.support.grpc.services",
        "apps.support.rest.v1",
        "apps.wallet.grpc.services",
        "apps.wallet.rest.v1",
    }
)


@pytest.fixture(autouse=True)
def _media(tmp_path: Any, settings: Any) -> None:
    settings.MEDIA_ROOT = tmp_path


@pytest.fixture
def people(transactional_db: None, make_user: Any) -> dict[str, Any]:
    """Signed-up users with tokens, one per built-in role, plus a target member."""
    tokens = {name: _token(name.lower()) for name in BUILTIN_ROLES}
    users = {name: get_user_model().objects.get(username=name.lower()) for name in BUILTIN_ROLES}
    users["Target"] = make_user("target")
    return {"users": users, "tokens": tokens}


def _world(people: dict[str, Any], n: int) -> World:
    users = people["users"]
    workspace = services.create(users["Owner"], "Acme", f"acme-{n}")
    ids = {r.name: str(r.pk) for r in Role.objects.filter(workspace=None)}
    for name in ("Admin", "Member", "Viewer"):
        WorkspaceMember.objects.create(
            workspace=workspace, user=users[name], role=access.builtin_role(name)
        )
    WorkspaceMember.objects.create(
        workspace=workspace, user=users["Target"], role=access.builtin_role("Member")
    )
    custom = roles.create_role(workspace, users["Owner"], "Temp", ["workspace.view"])
    invite = invitations.create_invitations(
        workspace, users["Owner"], ["pending@example.com"]
    ).created[0]
    owner = users["Owner"]
    open_project = project_services.create(owner, workspace, "Web", "WEB").project
    private = project_services.create(owner, workspace, "Sec", "SEC", visibility="private").project
    return World(
        workspace,
        people["tokens"],
        users["Target"],
        str(custom.role.pk),
        str(invite.invitation.pk),
        str(open_project.pk),
        str(private.pk),
        ids,
    )


def _expect_denied(refusal: BaseException, endpoint: Endpoint, role: str) -> None:
    hint = f"missing: {endpoint.permission}; your role: {role}"
    if isinstance(refusal, RestRefusal):
        body = refusal.response.json()
        assert refusal.response.status_code == 403
        assert body["title"] == "PERMISSION_DENIED_REASON"
        assert body["data"] == {"permission": endpoint.permission, "role": role, "hint": hint}
        return
    assert isinstance(refusal, grpc.aio.AioRpcError)
    assert refusal.code() is grpc.StatusCode.PERMISSION_DENIED
    assert refusal.details() == f"PERMISSION_DENIED_REASON: {hint}"
    trailers = {k: v for k, v in refusal.trailing_metadata()}
    assert trailers["x-error-permission-bin"] == endpoint.permission.encode()
    assert trailers["x-error-role-bin"] == role.encode()
    assert trailers["x-error-hint-bin"] == hint.encode()


@pytest.mark.parametrize("endpoint", ENDPOINTS, ids=lambda e: e.name)
def test_endpoint_follows_the_permission_matrix_for_every_builtin_role(
    endpoint: Endpoint, people: dict[str, Any], grpc_call: GrpcCall
) -> None:
    for n, role in enumerate(BUILTIN_ROLES):
        world = _world(people, n)
        if endpoint.prepare:
            endpoint.prepare(world)
        allowed = endpoint.permission in BUILTIN_GRANTS[role]

        if allowed or endpoint.filtered:
            result = endpoint.call(world, role, grpc_call)
            if endpoint.filtered:
                assert bool(result.workspaces) is allowed, f"{endpoint.name} as {role}"
            continue
        with pytest.raises((grpc.aio.AioRpcError, RestRefusal)) as refusal:
            endpoint.call(world, role, grpc_call)
        _expect_denied(refusal.value, endpoint, role)


def test_viewer_holds_no_write_permission() -> None:
    assert all(key.endswith(".view") for key in BUILTIN_GRANTS["Viewer"])


def test_every_endpoint_uses_a_registry_key() -> None:
    assert {e.permission for e in ENDPOINTS} <= ALL_KEYS


def _grpc_handlers() -> set[str]:
    from config.grpc import grpc_app_services

    found: set[str] = set()
    for _, services_ in grpc_app_services(serving=False):
        for service in services_:
            if service.__module__ in ACCOUNT_LEVEL_MODULES:
                continue
            for method in service.__dict__.get("_decorated_grpc_action_registry", {}):
                found.add(f"{service.get_controller_name()}.{method}")  # type: ignore[attr-defined]
    return found


def _rest_handlers() -> set[str]:
    from config.api import apis

    found: set[str] = set()
    for prefix, router in apis["v1"]._routers:
        for path, view in router.path_operations.items():
            for operation in view.operations:
                if operation.view_func.__module__ in ACCOUNT_LEVEL_MODULES:
                    continue
                found.update(f"{m} {prefix}{path}" for m in operation.methods)
    return found


def test_every_handler_is_classified() -> None:
    """A new workspace-scoped RPC or route must join ``ENDPOINTS`` (or ``EXEMPT`` with a reason)."""
    handlers = _grpc_handlers() | _rest_handlers()
    known = {e.name for e in ENDPOINTS} | set(EXEMPT)

    assert handlers - known == set(), "add these to ENDPOINTS (or EXEMPT with a reason)"
    assert known - handlers == set(), "stale entries in the matrix"


def test_outsiders_get_the_same_reasonless_denial_on_every_endpoint(
    people: dict[str, Any], grpc_call: GrpcCall, make_user: Any
) -> None:
    world = _world(people, 0)
    world.tokens = {**world.tokens, "Owner": _token("eve")}  # a stranger with the Owner slot
    for endpoint in ENDPOINTS:
        if endpoint.filtered:
            continue
        with pytest.raises((grpc.aio.AioRpcError, RestRefusal)) as refusal:
            endpoint.call(world, "Owner", grpc_call)
        error = refusal.value
        if isinstance(error, RestRefusal):
            assert error.response.status_code == 403 and error.response.json()["data"] is None
        else:
            assert error.code() is grpc.StatusCode.PERMISSION_DENIED
            assert error.details().startswith("FORBIDDEN:"), endpoint.name
            assert not [k for k, _ in error.trailing_metadata() if k.startswith("x-error")]
