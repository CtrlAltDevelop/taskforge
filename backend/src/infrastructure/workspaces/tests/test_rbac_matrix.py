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

from infrastructure.attachments import services as attachment_services
from infrastructure.attachments.grpc import attachments_pb2 as apb
from infrastructure.attachments.grpc import attachments_pb2_grpc as astubs
from infrastructure.audit.grpc import audit_pb2 as adpb
from infrastructure.audit.grpc import audit_pb2_grpc as adstubs
from infrastructure.automations import services as automation_services
from infrastructure.automations.grpc import automations_pb2 as aupb
from infrastructure.automations.grpc import automations_pb2_grpc as austubs
from infrastructure.automations.models import AutomationRun
from infrastructure.comments import services as comment_services
from infrastructure.comments.grpc import comments_pb2 as cpb
from infrastructure.comments.grpc import comments_pb2_grpc as cstubs
from infrastructure.customfields import services as field_services
from infrastructure.customfields.grpc import customfields_pb2 as fpb
from infrastructure.customfields.grpc import customfields_pb2_grpc as fstubs
from infrastructure.docs import services as doc_services
from infrastructure.docs.grpc import wikidocs_pb2 as dpb
from infrastructure.docs.grpc import wikidocs_pb2_grpc as dstubs
from infrastructure.docs.models import DocRevision
from infrastructure.filters import services as filter_services
from infrastructure.filters.grpc import filters_pb2 as flpb
from infrastructure.filters.grpc import filters_pb2_grpc as flstubs
from infrastructure.inbox.grpc import inbox_pb2 as ipb
from infrastructure.inbox.grpc import inbox_pb2_grpc as istubs
from infrastructure.projects import members as project_members
from infrastructure.projects import services as project_services
from infrastructure.projects.grpc import projects_pb2 as ppb
from infrastructure.projects.grpc import projects_pb2_grpc as pstubs
from infrastructure.savedviews import services as view_services
from infrastructure.savedviews.grpc import savedviews_pb2 as vpb
from infrastructure.savedviews.grpc import savedviews_pb2_grpc as vstubs
from infrastructure.search.grpc import search_pb2 as qpb
from infrastructure.search.grpc import search_pb2_grpc as qstubs
from infrastructure.sprints import services as sprint_services
from infrastructure.sprints.grpc import sprints_pb2 as sppb
from infrastructure.sprints.grpc import sprints_pb2_grpc as spstubs
from infrastructure.sync.grpc import sync_pb2 as spb
from infrastructure.sync.grpc import sync_pb2_grpc as sstubs
from infrastructure.tasks import links as task_links
from infrastructure.tasks import services as task_services
from infrastructure.tasks.grpc import tasks_pb2 as tpb
from infrastructure.tasks.grpc import tasks_pb2_grpc as tstubs
from infrastructure.timetracking.grpc import timetracking_pb2 as mpb
from infrastructure.timetracking.grpc import timetracking_pb2_grpc as mstubs
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
    filter_id: str = ""  # a filter shared with the open project
    comment_id: str = ""  # a comment by the Owner on ``task_id``
    attachment_id: str = ""  # a file the Owner attached to ``task_id``
    sprint_id: str = ""  # a sprint of the open project (made by the sprint prepares)
    doc_id: str = ""  # a workspace page made by the Owner (the doc prepares)
    doc_revision: int = 0  # its first revision
    automation_id: str = ""  # a rule of the open project, made by the Owner
    automation_run_id: str = ""  # a run of it (the task was made after the rule)

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


def _make_comment(w: World) -> None:
    _make_two_tasks(w)
    owner = w.workspace.created_by
    made = comment_services.create(owner, w.workspace, w.project_id, w.task_id, _body())
    w.comment_id = str(made.pk)


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


def _make_shared_filter(w: World) -> None:
    saved, _ = filter_services.save(
        w.workspace.created_by,
        w.workspace,
        w.project_id,
        name="Team",
        text="priority = high",
        visibility="project",
    )
    w.filter_id = str(saved.pk)


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

QC = flstubs.QueryControllerStub
FLC = flstubs.FilterControllerStub
ENDPOINTS += (
    Endpoint(
        "QueryController.Validate",
        "workspace.view",
        _grpc(
            QC,
            "Validate",
            lambda w: flpb.QueryValidateRequest(
                workspace_id=w.ws, project_id=w.project_id, tfql="priority = high"
            ),
        ),
    ),
    Endpoint(
        "QueryController.Suggest",
        "workspace.view",
        _grpc(
            QC,
            "Suggest",
            lambda w: flpb.QuerySuggestRequest(
                workspace_id=w.ws, project_id=w.project_id, partial="pri", cursor=3
            ),
        ),
    ),
    Endpoint(
        "FilterController.List",
        "workspace.view",
        _grpc(
            FLC,
            "List",
            lambda w: flpb.FilterListRequest(workspace_id=w.ws, project_id=w.project_id),
        ),
    ),
    # A private filter needs only workspace.view; sharing one, or deleting a shared one, needs
    # project.update (the filters tests cover the private paths).
    Endpoint(
        "FilterController.Save",
        "project.update",
        _grpc(
            FLC,
            "Save",
            lambda w: flpb.FilterSaveRequest(
                workspace_id=w.ws,
                project_id=w.project_id,
                name="Shared",
                tfql="priority = high",
                visibility="project",
            ),
        ),
    ),
    Endpoint(
        "FilterController.Delete",
        "project.update",
        _grpc(
            FLC,
            "Delete",
            lambda w: flpb.FilterDeleteRequest(
                workspace_id=w.ws, project_id=w.project_id, id=w.filter_id
            ),
        ),
        _make_shared_filter,
    ),
)

CL = tstubs.CalendarControllerStub
ENDPOINTS += (
    Endpoint(
        "CalendarController.ListRange",
        "workspace.view",
        _grpc(
            CL,
            "ListRange",
            lambda w: tpb.CalendarRangeRequest(
                workspace_id=w.ws,
                project_id=w.project_id,
                range_start="2026-11-01",
                range_end="2026-11-30",
            ),
        ),
    ),
    Endpoint(
        "CalendarController.ListWorkspaceRange",
        "workspace.view",
        _grpc(
            CL,
            "ListWorkspaceRange",
            lambda w: tpb.CalendarWorkspaceRangeRequest(
                workspace_id=w.ws, range_start="2026-11-01", range_end="2026-11-30"
            ),
        ),
    ),
    Endpoint(
        "CalendarController.ListUnscheduled",
        "workspace.view",
        _grpc(
            CL,
            "ListUnscheduled",
            lambda w: tpb.CalendarTrayRequest(workspace_id=w.ws, project_id=w.project_id),
        ),
    ),
)

TL = tstubs.TimelineControllerStub


def _move(w: Any, **extra: Any) -> dict[str, Any]:
    return {
        "workspace_id": w.ws,
        "project_id": w.project_id,
        "task_id": w.task_id,
        "start_date": "2026-11-02",
        "due_date": "2026-11-04",
        **extra,
    }


ENDPOINTS += (
    Endpoint(
        "TimelineController.Get",
        "workspace.view",
        _grpc(
            TL,
            "Get",
            lambda w: tpb.TimelineGetRequest(
                workspace_id=w.ws,
                project_id=w.project_id,
                range_start="2026-11-01",
                range_end="2026-11-30",
            ),
        ),
    ),
    Endpoint(
        "TimelineController.CriticalPath",
        "workspace.view",
        _grpc(
            TL,
            "CriticalPath",
            lambda w: tpb.TimelineCriticalPathRequest(workspace_id=w.ws, project_id=w.project_id),
        ),
    ),
    Endpoint(
        "TimelineController.PreviewShift",
        "workspace.view",
        _grpc(TL, "PreviewShift", lambda w: tpb.TimelinePreviewRequest(**_move(w))),
        _make_two_tasks,
    ),
    Endpoint(
        "TimelineController.ApplyShift",
        "task.update",
        _grpc(TL, "ApplyShift", lambda w: tpb.TimelineApplyRequest(**_move(w, expected_version=1))),
        _make_two_tasks,
    ),
    Endpoint(
        "TimelineController.GetWorkingDays",
        "workspace.view",
        _grpc(TL, "GetWorkingDays", lambda w: tpb.TimelineWorkingDaysGetRequest(workspace_id=w.ws)),
    ),
    Endpoint(
        "TimelineController.SetWorkingDays",
        "workspace.update",
        _grpc(
            TL,
            "SetWorkingDays",
            lambda w: tpb.TimelineWorkingDaysSetRequest(workspace_id=w.ws, days=[0, 1, 2, 3, 4]),
        ),
    ),
)

SY = sstubs.SyncControllerStub
ENDPOINTS += (
    Endpoint(
        "SyncController.Since",
        "workspace.view",
        _grpc(SY, "Since", lambda w: spb.SyncSinceRequest(workspace_id=w.ws, cursor="0")),
    ),
    Endpoint(
        "SyncController.Head",
        "workspace.view",
        _grpc(SY, "Head", lambda w: spb.SyncHeadRequest(workspace_id=w.ws)),
    ),
)

CM = cstubs.CommentControllerStub


def _body() -> str:
    import json

    text = {"type": "text", "text": "hi"}
    return json.dumps({"type": "doc", "content": [{"type": "paragraph", "content": [text]}]})


def _one(w: World, **kw: Any) -> dict[str, Any]:
    return {"workspace_id": w.ws, "project_id": w.project_id, "id": w.comment_id, **kw}


ENDPOINTS += (
    Endpoint(
        "CommentController.Delete",
        "comment.moderate",  # an author may delete their own; anyone else needs to moderate
        _grpc(CM, "Delete", lambda w: cpb.CommentDeleteRequest(**_one(w))),
        _make_comment,
    ),
    Endpoint(
        "CommentController.React",
        "comment.create",
        _grpc(CM, "React", lambda w: cpb.CommentReactRequest(**_one(w, emoji="👍", on=True))),
        _make_comment,
    ),
    Endpoint(
        "CommentController.Pin",
        "task.update",  # or comment.moderate
        _grpc(CM, "Pin", lambda w: cpb.CommentPinRequest(**_one(w, pinned=True))),
        _make_comment,
    ),
    Endpoint(
        "CommentController.History",
        "workspace.view",
        _grpc(CM, "History", lambda w: cpb.CommentHistoryRequest(**_one(w))),
        _make_comment,
    ),
    Endpoint(
        "CommentController.ToSubtask",
        "task.create",
        _grpc(CM, "ToSubtask", lambda w: cpb.CommentToSubtaskRequest(**_one(w))),
        _make_comment,
    ),
    Endpoint(
        "CommentController.List",
        "workspace.view",
        _grpc(
            CM,
            "List",
            lambda w: cpb.CommentListRequest(
                workspace_id=w.ws, project_id=w.project_id, task_id=w.task_id
            ),
        ),
        _make_two_tasks,
    ),
    Endpoint(
        "CommentController.Mentionable",
        "workspace.view",
        _grpc(
            CM,
            "Mentionable",
            lambda w: cpb.CommentMentionableRequest(
                workspace_id=w.ws, project_id=w.project_id, task_id=w.task_id
            ),
        ),
        _make_two_tasks,
    ),
    Endpoint(
        "CommentController.Create",
        "comment.create",
        _grpc(
            CM,
            "Create",
            lambda w: cpb.CommentCreateRequest(
                workspace_id=w.ws, project_id=w.project_id, task_id=w.task_id, body=_body()
            ),
        ),
        _make_two_tasks,
    ),
)

AT = astubs.AttachmentControllerStub
SE = qstubs.SearchControllerStub
TI = mstubs.TimeControllerStub
IN = istubs.InboxControllerStub
WA = istubs.WatcherControllerStub


def _time_on(w: World) -> None:
    _make_two_tasks(w)
    current = project_services.get(w.workspace.created_by, w.workspace, w.project_id).project
    project_services.set_features(
        w.workspace.created_by, w.workspace, w.project_id, {"time_tracking"}, current.version
    )


def _sprint_on(w: World, *, started: bool = False, with_task: bool = False) -> None:
    _make_two_tasks(w)
    owner = w.workspace.created_by
    current = project_services.get(owner, w.workspace, w.project_id).project
    project_services.set_features(owner, w.workspace, w.project_id, {"sprints"}, current.version)
    made = sprint_services.create(
        owner, w.workspace, w.project_id, "S1", "", "2026-11-02", "2026-11-06"
    ).sprint
    w.sprint_id = str(made.pk)
    if with_task:
        sprint_services.add_tasks(owner, w.workspace, w.project_id, w.sprint_id, [w.task_id])
    if started:
        sprint_services.start(owner, w.workspace, w.project_id, w.sprint_id)


def _sprint_started(w: World) -> None:
    _sprint_on(w, started=True, with_task=True)


def _sprint_with_task(w: World) -> None:
    _sprint_on(w, with_task=True)


def _sprint_ref(w: World) -> dict[str, Any]:
    return {"workspace_id": w.ws, "project_id": w.project_id, "sprint_id": w.sprint_id}


def _task_ref(w: World) -> dict[str, Any]:
    return {"workspace_id": w.ws, "project_id": w.project_id, "task_id": w.task_id}


PS = spstubs.SprintControllerStub
PB = spstubs.BacklogControllerStub


def _project_ref(w: World) -> dict[str, Any]:
    return {"workspace_id": w.ws, "project_id": w.project_id}


ENDPOINTS += (
    Endpoint(
        "SprintController.List",
        "workspace.view",
        _grpc(PS, "List", lambda w: sppb.SprintListRequest(**_project_ref(w))),
        _sprint_on,
    ),
    Endpoint(
        "SprintController.Create",
        "sprint.manage",
        _grpc(
            PS,
            "Create",
            lambda w: sppb.SprintCreateRequest(
                **_project_ref(w), name="S2", start_date="2026-11-09", end_date="2026-11-13"
            ),
        ),
        _sprint_on,
    ),
    Endpoint(
        "SprintController.Update",
        "sprint.manage",
        _grpc(
            PS,
            "Update",
            lambda w: sppb.SprintUpdateRequest(**_sprint_ref(w), fields=["name"], name="N"),
        ),
        _sprint_on,
    ),
    Endpoint(
        "SprintController.Start",
        "sprint.manage",
        _grpc(PS, "Start", lambda w: sppb.SprintStartRequest(**_sprint_ref(w))),
        _sprint_on,
    ),
    Endpoint(
        "SprintController.Complete",
        "sprint.manage",
        _grpc(
            PS,
            "Complete",
            lambda w: sppb.SprintCompleteRequest(**_sprint_ref(w), carry_over="backlog"),
        ),
        _sprint_started,
    ),
    Endpoint(
        "SprintController.AddTasks",
        "sprint.manage",
        _grpc(
            PS,
            "AddTasks",
            lambda w: sppb.SprintTasksChangeRequest(**_sprint_ref(w), task_ids=[w.task_id]),
        ),
        _sprint_on,
    ),
    Endpoint(
        "SprintController.RemoveTasks",
        "sprint.manage",
        _grpc(
            PS,
            "RemoveTasks",
            lambda w: sppb.SprintTasksChangeRequest(**_sprint_ref(w), task_ids=[w.task_id]),
        ),
        _sprint_with_task,
    ),
    Endpoint(
        "SprintController.Tasks",
        "workspace.view",
        _grpc(PS, "Tasks", lambda w: sppb.SprintTasksRequest(**_sprint_ref(w))),
        _sprint_with_task,
    ),
    Endpoint(
        "SprintController.SetPoints",
        "task.update",
        _grpc(
            PS,
            "SetPoints",
            lambda w: sppb.PointsSetRequest(**_project_ref(w), task_id=w.task_id, points="3"),
        ),
        _sprint_on,
    ),
    Endpoint(
        "SprintController.Burndown",
        "workspace.view",
        _grpc(PS, "Burndown", lambda w: sppb.BurndownRequest(**_sprint_ref(w))),
        _sprint_started,
    ),
    Endpoint(
        "BacklogController.List",
        "workspace.view",
        _grpc(PB, "List", lambda w: sppb.BacklogListRequest(**_project_ref(w))),
        _sprint_on,
    ),
    Endpoint(
        "TimeController.Current",
        "workspace.view",
        _grpc(TI, "Current", lambda w: mpb.TimeCurrentRequest(workspace_id=w.ws)),
    ),
    Endpoint(
        "TimeController.Timesheet",
        "workspace.view",
        _grpc(
            TI,
            "Timesheet",
            lambda w: mpb.TimesheetRequest(workspace_id=w.ws, week_start="2026-11-02"),
        ),
    ),
    Endpoint(
        "TimeController.Start",
        "time.log",
        _grpc(TI, "Start", lambda w: mpb.TimeStartRequest(**_task_ref(w))),
        _time_on,
    ),
    Endpoint(
        "TimeController.CreateEntry",
        "time.log",
        _grpc(
            TI,
            "CreateEntry",
            lambda w: mpb.EntryCreateRequest(
                **_task_ref(w), started_at="2026-11-02T09:00:00+00:00", duration_sec=60
            ),
        ),
        _time_on,
    ),
    Endpoint(
        "TimeController.Entries",
        "workspace.view",
        _grpc(TI, "Entries", lambda w: mpb.EntriesRequest(**_task_ref(w))),
        _time_on,
    ),
    Endpoint(
        "TimeController.Summary",
        "workspace.view",
        _grpc(TI, "Summary", lambda w: mpb.TimeSummaryRequest(**_task_ref(w))),
        _time_on,
    ),
    Endpoint(
        "TimeController.SetEstimate",
        "task.update",
        _grpc(TI, "SetEstimate", lambda w: mpb.EstimateSetRequest(**_task_ref(w), estimate_sec=60)),
        _time_on,
    ),
    Endpoint(
        "TimeController.Totals",
        "workspace.view",
        _grpc(
            TI,
            "Totals",
            lambda w: mpb.TotalsRequest(
                workspace_id=w.ws,
                project_id=w.project_id,
                start="2026-11-01T00:00:00+00:00",
                end="2026-11-08T00:00:00+00:00",
            ),
        ),
        _time_on,
    ),
    Endpoint(
        "SearchController.Query",
        "workspace.view",
        _grpc(SE, "Query", lambda w: qpb.SearchQueryRequest(workspace_id=w.ws, text="x")),
    ),
    Endpoint(
        "SearchController.Remember",
        "workspace.view",
        _grpc(SE, "Remember", lambda w: qpb.SearchRememberRequest(workspace_id=w.ws, text="xx")),
    ),
    Endpoint(
        "SearchController.Recent",
        "workspace.view",
        _grpc(SE, "Recent", lambda w: qpb.SearchRecentRequest(workspace_id=w.ws)),
    ),
    Endpoint(
        "InboxController.List",
        "workspace.view",
        _grpc(IN, "List", lambda w: ipb.InboxListRequest(workspace_id=w.ws)),
    ),
    Endpoint(
        "InboxController.MarkRead",
        "workspace.view",
        _grpc(
            IN, "MarkRead", lambda w: ipb.MarkReadRequest(workspace_id=w.ws, all=True, read=True)
        ),
    ),
    Endpoint(
        "InboxController.UnreadCount",
        "workspace.view",
        _grpc(IN, "UnreadCount", lambda w: ipb.UnreadCountRequest(workspace_id=w.ws)),
    ),
    Endpoint(
        "InboxController.Archive",
        "workspace.view",
        _grpc(
            IN, "Archive", lambda w: ipb.ArchiveRequest(workspace_id=w.ws, ids=[], archived=True)
        ),
    ),
    Endpoint(
        "WatcherController.Get",
        "workspace.view",
        _grpc(WA, "Get", lambda w: ipb.WatchGetRequest(**_task_ref(w))),
        _make_two_tasks,
    ),
    Endpoint(
        "WatcherController.Add",
        "workspace.view",
        _grpc(WA, "Add", lambda w: ipb.WatchAddRequest(**_task_ref(w))),
        _make_two_tasks,
    ),
    Endpoint(
        "WatcherController.Remove",
        "workspace.view",
        _grpc(WA, "Remove", lambda w: ipb.WatchRemoveRequest(**_task_ref(w))),
        _make_two_tasks,
    ),
)


def _make_attachment(w: World) -> None:
    _make_two_tasks(w)
    owner = w.workspace.created_by
    session = attachment_services.start_upload(
        owner, w.workspace, w.project_id, w.task_id, "a.txt", 5
    )
    attachment_services.put_chunk(owner, str(session.pk), 0, b"hello")
    w.attachment_id = str(attachment_services.complete(owner, str(session.pk)).pk)


def _rest(method: str, path: Callable[[World], str], body: Callable[[World], Any] | None = None):  # type: ignore[no-untyped-def]
    def call(w: World, role: str, _: GrpcCall) -> Any:
        send = getattr(Client(), method)
        extra = {"HTTP_AUTHORIZATION": f"Bearer {w.tokens[role]}"}
        if body is None:
            response = send(path(w), **extra)
        else:
            response = send(path(w), body(w), content_type="application/json", **extra)
        if response.status_code >= 400:
            raise RestRefusal(response)
        return response

    return call


NO_ID = "00000000-0000-0000-0000-000000000000"  # REST wants a real UUID even where none is set up


def _upload_body(w: World) -> dict[str, Any]:
    return {
        "workspace_id": w.ws,
        "project_id": w.project_id,
        "task_id": w.task_id or NO_ID,
        "filename": "b.txt",
        "size": 5,
    }


ENDPOINTS += (
    Endpoint(
        "AttachmentController.Delete",
        "task.attachment_manage",  # the uploader may delete their own; anyone else needs this
        _grpc(
            AT,
            "Delete",
            lambda w: apb.AttachmentDeleteRequest(
                workspace_id=w.ws, project_id=w.project_id, id=w.attachment_id
            ),
        ),
        _make_attachment,
    ),
    Endpoint(
        "AttachmentController.List",
        "workspace.view",
        _grpc(
            AT,
            "List",
            lambda w: apb.AttachmentListRequest(
                workspace_id=w.ws, project_id=w.project_id, task_id=w.task_id
            ),
        ),
        _make_two_tasks,
    ),
    Endpoint(
        "AttachmentController.Usage",
        "workspace.view",
        _grpc(AT, "Usage", lambda w: apb.UsageRequest(workspace_id=w.ws)),
    ),
    Endpoint(
        "POST /uploads",
        "task.update",
        _rest("post", lambda w: "/api/v1/uploads", _upload_body),
        _make_two_tasks,
    ),
    Endpoint(
        "GET /files/{attachment_id}/link",
        "workspace.view",
        _rest("get", lambda w: f"/api/v1/files/{w.attachment_id or NO_ID}/link"),
        _make_attachment,
    ),
    Endpoint(
        "GET /files/{attachment_id}",
        "workspace.view",
        _rest("get", lambda w: f"/api/v1/files/{w.attachment_id or NO_ID}"),
        _make_attachment,
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


def _doc_on(w: World) -> None:
    _make_two_tasks(w)
    owner = w.workspace.created_by
    made = doc_services.create(owner, w.workspace, "", "", "Spec").doc
    w.doc_id = str(made.pk)
    first = DocRevision.objects.filter(doc=made).order_by("id").first()
    w.doc_revision = int(first.pk) if first else 0


def _doc_archived(w: World) -> None:
    _doc_on(w)
    doc_services.archive(w.workspace.created_by, w.workspace, w.doc_id)


def _doc_ref(w: World) -> dict[str, Any]:
    return {"workspace_id": w.ws, "doc_id": w.doc_id}


def _doc_task_ref(w: World) -> dict[str, Any]:
    return {
        "workspace_id": w.ws,
        "project_id": w.project_id,
        "task_id": w.task_id,
        "doc_id": w.doc_id,
    }


DC = dstubs.DocControllerStub


def _doc_endpoint(
    method: str,
    permission: str,
    request: Callable[[World], Any],
    prepare: Callable[[World], None] = _doc_on,
) -> Endpoint:
    return Endpoint(f"DocController.{method}", permission, _grpc(DC, method, request), prepare)


ENDPOINTS += (
    _doc_endpoint("Tree", "workspace.view", lambda w: dpb.DocTreeRequest(workspace_id=w.ws)),
    _doc_endpoint("Get", "workspace.view", lambda w: dpb.DocGetRequest(**_doc_ref(w))),
    _doc_endpoint(
        "Create", "doc.edit", lambda w: dpb.DocCreateRequest(workspace_id=w.ws, title="New")
    ),
    _doc_endpoint(
        "Update",
        "doc.edit",
        lambda w: dpb.DocUpdateRequest(
            **_doc_ref(w), expected_version=1, fields=["title"], title="Renamed"
        ),
    ),
    _doc_endpoint(
        "Move", "doc.edit", lambda w: dpb.DocMoveRequest(**_doc_ref(w), parent_id="", index=0)
    ),
    _doc_endpoint("Archive", "doc.edit", lambda w: dpb.DocArchiveRequest(**_doc_ref(w))),
    _doc_endpoint(
        "Restore", "doc.edit", lambda w: dpb.DocRestoreRequest(**_doc_ref(w)), _doc_archived
    ),
    _doc_endpoint(
        "SetAccess",
        "doc.manage",
        lambda w: dpb.DocSetAccessRequest(**_doc_ref(w), restricted=True),
    ),
    _doc_endpoint(
        "RevisionList", "workspace.view", lambda w: dpb.DocRevisionListRequest(**_doc_ref(w))
    ),
    _doc_endpoint(
        "RevisionGet",
        "workspace.view",
        lambda w: dpb.DocRevisionGetRequest(**_doc_ref(w), revision_id=w.doc_revision),
    ),
    _doc_endpoint(
        "RevisionRestore",
        "doc.edit",
        lambda w: dpb.DocRevisionRestoreRequest(
            **_doc_ref(w), revision_id=w.doc_revision, expected_version=1
        ),
    ),
    _doc_endpoint("Backlinks", "workspace.view", lambda w: dpb.DocBacklinksRequest(**_doc_ref(w))),
    _doc_endpoint(
        "ExportMarkdown", "workspace.view", lambda w: dpb.DocExportRequest(**_doc_ref(w))
    ),
    _doc_endpoint(
        "ForTask",
        "workspace.view",
        lambda w: dpb.DocForTaskRequest(
            workspace_id=w.ws, project_id=w.project_id, task_id=w.task_id
        ),
    ),
    _doc_endpoint("LinkTask", "doc.edit", lambda w: dpb.DocLinkTaskRequest(**_doc_task_ref(w))),
    _doc_endpoint("UnlinkTask", "doc.edit", lambda w: dpb.DocLinkTaskRequest(**_doc_task_ref(w))),
    _doc_endpoint(
        "TaskCards",
        "workspace.view",
        lambda w: dpb.DocTaskCardsRequest(workspace_id=w.ws, task_ids=[w.task_id]),
    ),
    _doc_endpoint(
        "Presence",
        "workspace.view",
        lambda w: dpb.DocPresenceRequest(**_doc_ref(w), state="viewing"),
    ),
)


def _automation_on(w: World) -> None:
    _make_two_tasks(w)
    owner = w.workspace.created_by
    made = automation_services.create(
        owner,
        w.workspace,
        w.project_id,
        "Rule",
        {"type": "task_created"},
        [{"type": "add_comment", "text": "hi"}],
    ).automation
    w.automation_id = str(made.pk)
    task_services.create(owner, w.workspace, w.project_id, "Fresh")
    run = AutomationRun.objects.filter(automation=made).first()
    w.automation_run_id = str(run.pk) if run else ""


def _automation_ref(w: World) -> dict[str, Any]:
    return {"workspace_id": w.ws, "project_id": w.project_id, "automation_id": w.automation_id}


AC = austubs.AutomationControllerStub
AR = austubs.AutomationRunControllerStub


def _automation_endpoint(
    stub: Any, name: str, method: str, permission: str, request: Callable[[World], Any]
) -> Endpoint:
    return Endpoint(f"{name}.{method}", permission, _grpc(stub, method, request), _automation_on)


ENDPOINTS += (
    _automation_endpoint(
        AC,
        "AutomationController",
        "List",
        "workspace.view",
        lambda w: aupb.AutomationListRequest(**_project_ref(w)),
    ),
    _automation_endpoint(
        AC,
        "AutomationController",
        "Create",
        "automation.manage",
        lambda w: aupb.AutomationCreateRequest(
            **_project_ref(w),
            name="New",
            trigger_json='{"type": "task_created"}',
            actions_json='[{"type": "add_comment", "text": "x"}]',
            enabled=True,
        ),
    ),
    _automation_endpoint(
        AC,
        "AutomationController",
        "Update",
        "automation.manage",
        lambda w: aupb.AutomationUpdateRequest(
            **_automation_ref(w), fields=["name"], expected_version=1, name="N"
        ),
    ),
    _automation_endpoint(
        AC,
        "AutomationController",
        "Delete",
        "automation.manage",
        lambda w: aupb.AutomationDeleteRequest(**_automation_ref(w)),
    ),
    _automation_endpoint(
        AC,
        "AutomationController",
        "Toggle",
        "automation.manage",
        lambda w: aupb.AutomationToggleRequest(**_automation_ref(w), enabled=False),
    ),
    _automation_endpoint(
        AC,
        "AutomationController",
        "DryRun",
        "automation.manage",
        lambda w: aupb.AutomationDryRunRequest(**_automation_ref(w), task_id=w.task_id),
    ),
    _automation_endpoint(
        AR,
        "AutomationRunController",
        "List",
        "workspace.view",
        lambda w: aupb.AutomationRunListRequest(**_project_ref(w)),
    ),
    _automation_endpoint(
        AR,
        "AutomationRunController",
        "Get",
        "workspace.view",
        lambda w: aupb.AutomationRunGetRequest(**_project_ref(w), run_id=w.automation_run_id),
    ),
)

# Handlers that need no workspace permission, and why.
AD = adstubs.AuditControllerStub
ADT = adstubs.ActivityControllerStub
ENDPOINTS += (
    Endpoint(
        "AuditController.List",
        "audit.view",
        _grpc(AD, "List", lambda w: adpb.AuditListRequest(workspace_id=w.ws)),
    ),
    Endpoint(
        "AuditController.Export",
        "audit.view",
        _grpc(AD, "Export", lambda w: adpb.AuditExportRequest(workspace_id=w.ws)),
    ),
    Endpoint(
        "ActivityController.ForTask",
        "workspace.view",
        _grpc(
            ADT,
            "ForTask",
            lambda w: adpb.ActivityForTaskRequest(
                workspace_id=w.ws, project_id=w.project_id, task_id=w.task_id
            ),
        ),
        _make_task,
    ),
)

EXEMPT = {
    "ShortcutController.Get": "personal, not workspace data: a caller reads only their own rows",
    "ShortcutController.Set": "personal, not workspace data: a caller writes only their own rows",
    "CommentController.Edit": "the author only: ownership, not the matrix (service tests)",
    "GET /uploads/{upload_id}": "the uploader only: ownership, not the matrix (service tests)",
    "PUT /uploads/{upload_id}/chunk/{n}": "the uploader only (service tests)",
    "POST /uploads/{upload_id}/complete": "the uploader only (service tests)",
    "DELETE /uploads/{upload_id}": "the uploader only (service tests)",
    "GET /files/{attachment_id}/raw": "the signed, short-lived token is the capability",
    "TimeController.Stop": "your own timer: ownership, not the matrix (time tests)",
    "TimeController.UpdateEntry": "your own entry, or time.edit_others (time tests)",
    "TimeController.DeleteEntry": "your own entry, or time.edit_others (time tests)",
    "InboxController.Snooze": "your own notification: ownership, not the matrix (inbox tests)",
    "GET /inbox/unsubscribe": "the signed token in the email is the capability",
    "POST /inbox/unsubscribe": "the signed token in the email is the capability",
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
        "infrastructure.inbox.grpc.account_services",
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
