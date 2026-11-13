"""Intake forms over gRPC: ``FormController``. The rules are in ``infrastructure.forms.services``.

``Update`` names what it changes in ``changed`` (name, description, fields, defaults, enabled,
require_email, send_confirmation, notify_status, brand_color, logo_url, rotate_token) and carries
``expected_version`` (a stale one is ABORTED). ``form_fields`` is the whole ordered list of
questions; ``defaults`` is status_id, priority and assignee_ids. PERMISSION_DENIED without
``form.manage`` and for any caller that is an API token. ``Submissions`` pages newest first
(``before`` is the returned ``cursor``).
"""

from typing import Any

from asgiref.sync import sync_to_async
from django_socio_grpc import generics
from django_socio_grpc.decorators import grpc_action

from infrastructure.common.errors import ApiError
from infrastructure.common.grpc.errors import action, require_caller
from infrastructure.common.identity import grpc_caller
from infrastructure.forms import services
from infrastructure.forms.grpc.serializers import IntakeField, IntakeForm, IntakeSubmission
from infrastructure.workspaces.scoping import require_workspace

WS = [{"name": "workspace_id", "type": "string"}]
FORM = [*WS, {"name": "form_id", "type": "string"}]
CONTENT = [
    {"name": "name", "type": "string"},
    {"name": "description", "type": "string"},
    {"name": "form_fields", "cardinality": "repeated", "type": IntakeField},
    {"name": "status_id", "type": "string"},
    {"name": "priority", "type": "string"},
    {"name": "assignee_ids", "cardinality": "repeated", "type": "string"},
    {"name": "enabled", "type": "bool"},
    {"name": "require_email", "type": "bool"},
    {"name": "send_confirmation", "type": "bool"},
    {"name": "notify_status", "type": "bool"},
    {"name": "brand_color", "type": "string"},
    {"name": "logo_url", "type": "string"},
]
ANSWER = [{"name": "form", "type": IntakeForm}]


def _pb() -> Any:
    from infrastructure.forms.grpc import forms_pb2

    return forms_pb2


def _iso(value: Any) -> str:
    return value.isoformat() if value else ""


def field_message(item: dict[str, Any]) -> Any:
    return _pb().IntakeField(
        id=item["id"],
        kind=item["kind"],
        label=item["label"],
        help=item["help"],
        required=item["required"],
        custom_field_id=item["custom_field_id"],
        max_files=item["max_files"],
    )


def form_message(view: services.FormView) -> Any:
    form = view.form
    defaults = form.defaults or {}
    return _pb().IntakeForm(
        id=str(form.pk),
        workspace_id=str(form.workspace_id),
        project_id=str(form.project_id),
        name=form.name,
        description=form.description,
        token=form.token,
        form_fields=[field_message(f) for f in form.fields],
        status_id=str(defaults.get("status_id", "")),
        priority=str(defaults.get("priority", "none")),
        assignee_ids=[str(a) for a in defaults.get("assignee_ids", [])],
        enabled=form.enabled,
        require_email=form.require_email,
        send_confirmation=form.send_confirmation,
        notify_status=form.notify_status,
        brand_color=form.brand_color,
        logo_url=form.logo_url,
        version=form.version,
        submission_count=view.submission_count,
        problem=view.problem,
        owner_id=str(form.owner_id or ""),
        created_at=_iso(form.created_at),
        updated_at=_iso(form.updated_at),
    )


def submission_message(row: Any, project_id: str) -> Any:
    task = row.task
    return _pb().IntakeSubmission(
        id=str(row.pk),
        form_id=str(row.form_id),
        reference=row.reference,
        project_id=project_id,
        task_id=str(task.pk) if task else "",
        task_key=task.display_id if task else "",
        task_title=task.title if task else "",
        status_name=task.status.name if task else "",
        submitter_email=row.submitter_email,
        at=_iso(row.at),
    )


def _fields(request: Any) -> list[dict[str, Any]]:
    return [
        {
            "id": f.id,
            "kind": f.kind,
            "label": f.label,
            "help": f.help,
            "required": f.required,
            "custom_field_id": f.custom_field_id,
            "max_files": f.max_files,
        }
        for f in request.form_fields
    ]


def _defaults(request: Any) -> dict[str, Any]:
    return {
        "status_id": request.status_id,
        "priority": request.priority,
        "assignee_ids": list(request.assignee_ids),
    }


async def _scope(request: Any, context: Any) -> tuple[Any, Any]:
    user = require_caller(await grpc_caller(context))
    return user, await sync_to_async(require_workspace)(user, request.workspace_id)


def _answer(view: services.FormView) -> Any:
    return _pb().FormAnswer(form=form_message(view))


def _changes(request: Any) -> dict[str, Any]:
    changes: dict[str, Any] = {}
    for name in request.changed:
        if name not in services.EDITABLE:
            raise ApiError(f"Cannot change {name}.", status=400)
        match name:
            case "fields":
                changes[name] = _fields(request)
            case "defaults":
                changes[name] = _defaults(request)
            case _:
                changes[name] = getattr(request, name)
    return changes


class FormService(generics.GenericService):
    @grpc_action(
        request=[*WS, {"name": "project_id", "type": "string"}],
        request_name="FormListRequest",
        response=[{"name": "forms", "cardinality": "repeated", "type": IntakeForm}],
        response_name="FormList",
    )
    @action
    async def List(self, request: Any, context: Any) -> Any:
        """Every form of the workspace (of one project when ``project_id`` is set)."""
        user, workspace = await _scope(request, context)

        def run() -> Any:
            rows = services.list_forms(user, workspace, request.project_id)
            return _pb().FormList(forms=[form_message(v) for v in rows])

        return await sync_to_async(run)()

    @grpc_action(
        request=[*WS, {"name": "project_id", "type": "string"}, *CONTENT],
        request_name="FormCreateRequest",
        response=ANSWER,
        response_name="FormAnswer",
    )
    @action
    async def Create(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)

        def run() -> Any:
            view = services.create(
                user,
                workspace,
                request.project_id,
                request.name,
                fields=_fields(request),
                description=request.description,
                defaults=_defaults(request),
                enabled=request.enabled,
                require_email=request.require_email,
                send_confirmation=request.send_confirmation,
                notify_status=request.notify_status,
                brand_color=request.brand_color,
                logo_url=request.logo_url,
            )
            return _answer(view)

        return await sync_to_async(run)()

    @grpc_action(
        request=[
            *FORM,
            {"name": "changed", "cardinality": "repeated", "type": "string"},
            {"name": "expected_version", "type": "int32"},
            {"name": "rotate_token", "type": "bool"},
            *CONTENT,
        ],
        request_name="FormUpdateRequest",
        response=ANSWER,
        response_name="FormAnswer",
    )
    @action
    async def Update(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)

        def run() -> Any:
            view = services.update(
                user,
                workspace,
                request.form_id,
                request.expected_version,
                **_changes(request),
            )
            return _answer(view)

        return await sync_to_async(run)()

    @grpc_action(
        request=FORM,
        request_name="FormDeleteRequest",
        response=[{"name": "id", "type": "string"}],
        response_name="FormDeleted",
    )
    @action
    async def Delete(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)

        def run() -> Any:
            services.delete(user, workspace, request.form_id)
            return _pb().FormDeleted(id=request.form_id)

        return await sync_to_async(run)()

    @grpc_action(
        request=[*FORM, {"name": "before", "type": "string"}, {"name": "limit", "type": "int32"}],
        request_name="SubmissionsRequest",
        response=[
            {"name": "submissions", "cardinality": "repeated", "type": IntakeSubmission},
            {"name": "cursor", "type": "string"},
        ],
        response_name="SubmissionList",
    )
    @action
    async def Submissions(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)

        def run() -> Any:
            rows, cursor, project_id = services.submissions(
                user, workspace, request.form_id, before=request.before, limit=request.limit
            )
            return _pb().SubmissionList(
                submissions=[submission_message(r, project_id) for r in rows], cursor=cursor
            )

        return await sync_to_async(run)()


GRPC_SERVICES = [FormService]
