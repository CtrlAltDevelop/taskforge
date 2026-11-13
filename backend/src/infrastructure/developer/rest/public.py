"""The public API: ``/api/v1/workspaces/...``, for scripts and integrations.

Send ``Authorization: Bearer tf_...`` (an API token) or a signed-in person's access token. A token
is tied to one workspace and holds the owner's permissions narrowed to its scopes: a route the
scopes do not cover answers 403 naming the missing scope. Every route goes through the same
services as the app, so permissions and workspace scoping are the same ones.
"""

import json
from typing import Any

from django.http import HttpRequest
from ninja import Router, Schema

from infrastructure.auth.core.sessions import JwtBearer
from infrastructure.comments import services as comments
from infrastructure.developer import events, scopes
from infrastructure.projects import services as projects
from infrastructure.tasks import services as tasks
from infrastructure.workspaces import services as workspaces
from infrastructure.workspaces.scoping import require_workspace

router = Router()


class PublicBearer(JwtBearer):
    """Accepts an API token as well as a person's access token."""

    allow_tokens = True
    openapi_name = "API token"
    openapi_description = (
        "An API token (tf_...) from Settings, Developer, or a person's access token."
    )


public_auth = PublicBearer()


class WorkspaceOut(Schema):
    id: str
    name: str
    slug: str
    version: int


class ProjectIn(Schema):
    name: str
    key: str
    description: str = ""


class ProjectOut(Schema):
    id: str
    workspace_id: str
    name: str
    key: str
    description: str
    visibility: str
    archived: bool
    version: int


class TaskIn(Schema):
    title: str
    status: str = ""
    priority: str = "none"
    start_date: str = ""
    due_date: str = ""
    assignee_ids: list[str] = []
    parent_id: str = ""


class TaskPatch(Schema):
    expected_version: int
    title: str | None = None
    status: str | None = None
    priority: str | None = None
    start_date: str | None = None
    due_date: str | None = None
    assignee_ids: list[str] | None = None


class TaskOut(Schema):
    id: str
    key: str
    project_id: str
    title: str
    status: dict[str, str]
    priority: str
    start_date: str | None
    due_date: str | None
    parent_id: str | None
    version: int
    created_at: str
    updated_at: str
    deleted: bool


class TaskPage(Schema):
    tasks: list[TaskOut]
    cursor: str


class CommentIn(Schema):
    text: str
    parent_id: str = ""


class CommentOut(Schema):
    id: str
    task_id: str
    author_id: str
    parent_id: str | None
    text: str
    version: int
    created_at: str
    deleted: bool


class CommentPage(Schema):
    comments: list[CommentOut]
    cursor: str


def _workspace(request: HttpRequest, workspace_id: str, scope: str) -> Any:
    scopes.require(request.user, scope)
    return require_workspace(request.user, workspace_id)


def _project_out(view: Any) -> ProjectOut:
    p = view.project
    return ProjectOut(
        id=str(p.pk),
        workspace_id=str(p.workspace_id),
        name=p.name,
        key=p.key,
        description=p.description,
        visibility=p.visibility,
        archived=p.archived_at is not None,
        version=p.version,
    )


def _task_out(task: Any) -> TaskOut:
    return TaskOut(**events.task_data(task))


def _comment_out(comment: Any) -> CommentOut:
    from infrastructure.comments.body import plain_text

    text = "" if comment.deleted_at else plain_text(comment.body)
    return CommentOut(**events.comment_data(comment, text))


@router.get("", response=list[WorkspaceOut], auth=public_auth, summary="Your workspace")
def list_workspaces(request: HttpRequest) -> list[WorkspaceOut]:
    scopes.require(request.user, "workspaces:read")
    token = scopes.token_of(request.user)
    rows = workspaces.list_mine(request.user)
    if token is not None:
        rows = [w for w in rows if w.pk == token.workspace_id]
    return [WorkspaceOut(id=str(w.pk), name=w.name, slug=w.slug, version=w.version) for w in rows]


@router.get(
    "/{workspace_id}/projects",
    response=list[ProjectOut],
    auth=public_auth,
    summary="List projects",
)
def list_projects(request: HttpRequest, workspace_id: str) -> list[ProjectOut]:
    workspace = _workspace(request, workspace_id, "projects:read")
    return [_project_out(v) for v in projects.list_projects(request.user, workspace)]


@router.post(
    "/{workspace_id}/projects",
    response={201: ProjectOut},
    auth=public_auth,
    summary="Create a project",
)
def create_project(
    request: HttpRequest, workspace_id: str, payload: ProjectIn
) -> tuple[int, ProjectOut]:
    workspace = _workspace(request, workspace_id, "projects:write")
    view = projects.create(
        request.user, workspace, payload.name, payload.key, description=payload.description
    )
    return 201, _project_out(view)


@router.get(
    "/{workspace_id}/projects/{project_id}/tasks",
    response=TaskPage,
    auth=public_auth,
    summary="List a project's tasks (a page; pass the cursor for the next)",
)
def list_tasks(
    request: HttpRequest,
    workspace_id: str,
    project_id: str,
    status: str = "",
    assignee_id: str = "",
    cursor: str = "",
    limit: int = 50,
) -> TaskPage:
    workspace = _workspace(request, workspace_id, "tasks:read")
    rows, after = tasks.list_page(
        request.user,
        workspace,
        project_id,
        status=status,
        assignee_id=assignee_id,
        cursor=cursor,
        limit=limit,
    )
    return TaskPage(tasks=[_task_out(t) for t in rows], cursor=after)


@router.post(
    "/{workspace_id}/projects/{project_id}/tasks",
    response={201: TaskOut},
    auth=public_auth,
    summary="Create a task",
)
def create_task(
    request: HttpRequest, workspace_id: str, project_id: str, payload: TaskIn
) -> tuple[int, TaskOut]:
    workspace = _workspace(request, workspace_id, "tasks:write")
    task = tasks.create(
        request.user,
        workspace,
        project_id,
        payload.title,
        status=payload.status,
        priority=payload.priority,
        start_date=payload.start_date,
        due_date=payload.due_date,
        assignee_ids=payload.assignee_ids,
        parent_id=payload.parent_id,
    )
    return 201, _task_out(task)


@router.get(
    "/{workspace_id}/projects/{project_id}/tasks/{task_id}",
    response=TaskOut,
    auth=public_auth,
    summary="Read a task",
)
def get_task(request: HttpRequest, workspace_id: str, project_id: str, task_id: str) -> TaskOut:
    workspace = _workspace(request, workspace_id, "tasks:read")
    return _task_out(tasks.get(request.user, workspace, project_id, task_id))


@router.patch(
    "/{workspace_id}/projects/{project_id}/tasks/{task_id}",
    response=TaskOut,
    auth=public_auth,
    summary="Change a task (send the version you read; a stale one is a 409)",
)
def update_task(
    request: HttpRequest, workspace_id: str, project_id: str, task_id: str, payload: TaskPatch
) -> TaskOut:
    workspace = _workspace(request, workspace_id, "tasks:write")
    changes = payload.model_dump(exclude_unset=True, exclude={"expected_version"})
    task = tasks.update(
        request.user, workspace, project_id, task_id, payload.expected_version, changes
    )
    return _task_out(task)


@router.delete(
    "/{workspace_id}/projects/{project_id}/tasks/{task_id}",
    response=TaskOut,
    auth=public_auth,
    summary="Delete a task (it can be restored in the app)",
)
def delete_task(
    request: HttpRequest, workspace_id: str, project_id: str, task_id: str, mode: str = ""
) -> TaskOut:
    workspace = _workspace(request, workspace_id, "tasks:write")
    return _task_out(tasks.delete(request.user, workspace, project_id, task_id, mode))


@router.get(
    "/{workspace_id}/projects/{project_id}/tasks/{task_id}/comments",
    response=CommentPage,
    auth=public_auth,
    summary="List a task's comments, oldest first (pass the cursor as before for earlier ones)",
)
def list_comments(
    request: HttpRequest,
    workspace_id: str,
    project_id: str,
    task_id: str,
    before: str = "",
    limit: int = 50,
) -> CommentPage:
    workspace = _workspace(request, workspace_id, "comments:read")
    page = comments.list_page(
        request.user, workspace, project_id, task_id, before=before, limit=limit
    )
    return CommentPage(comments=[_comment_out(c) for c in page.comments], cursor=page.cursor)


def _document(text: str) -> str:
    paragraphs = [
        {"type": "paragraph", "content": [{"type": "text", "text": line}]}
        for line in text.splitlines()
        if line.strip()
    ]
    return json.dumps({"type": "doc", "content": paragraphs}) if paragraphs else ""


@router.post(
    "/{workspace_id}/projects/{project_id}/tasks/{task_id}/comments",
    response={201: CommentOut},
    auth=public_auth,
    summary="Write a comment (plain text, one paragraph per line)",
)
def create_comment(
    request: HttpRequest,
    workspace_id: str,
    project_id: str,
    task_id: str,
    payload: CommentIn,
) -> tuple[int, CommentOut]:
    workspace = _workspace(request, workspace_id, "comments:write")
    comment = comments.create(
        request.user,
        workspace,
        project_id,
        task_id,
        _document(payload.text),
        parent_id=payload.parent_id,
    )
    return 201, _comment_out(comment)
