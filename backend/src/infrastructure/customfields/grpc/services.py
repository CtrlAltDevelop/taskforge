"""Custom field definitions over gRPC (``FieldController``): List, Create, Update, Reorder,
Archive, Restore. Values travel on tasks (``TaskController``), not here.

Permissions: List needs workspace membership (``include_archived`` needs ``project.update``);
everything else needs ``project.update`` (a project's creator has it for their own project) on a
project that is not archived (ALREADY_EXISTS PROJECT_ARCHIVED). ``Update`` sends only the
attributes to change (``HasField``; options and hidden views with their ``set_*`` flag) plus
``expected_version`` (stale: ABORTED VERSION_CONFLICT) and ``remaps`` for removed options that
values still use (else FAILED_PRECONDITION OPTION_NEEDS_REMAP with ``x-error-options-bin``, a JSON
object option id -> number of values). INVALID_ARGUMENT FIELD_INVALID for a bad definition,
FIELD_LIMIT at 50 active fields, ALREADY_EXISTS FIELD_NAME_TAKEN. A value of a required field
missing on task create is INVALID_ARGUMENT FIELD_REQUIRED (``x-error-fields-bin``: JSON list of
field ids). Other refusals as in ``infrastructure.projects.grpc.services``.
"""

from typing import Any

from asgiref.sync import sync_to_async
from django_socio_grpc import generics
from django_socio_grpc.decorators import grpc_action

from infrastructure.common.grpc.errors import action, require_caller
from infrastructure.common.identity import grpc_caller
from infrastructure.customfields import services
from infrastructure.customfields.grpc.serializers import Field, FieldOption, OptionRemap
from infrastructure.customfields.models import FieldDefinition
from infrastructure.workspaces.scoping import require_workspace

IDS = [
    {"name": "workspace_id", "type": "string"},
    {"name": "project_id", "type": "string"},
]
ID = {"name": "id", "type": "string"}
VERSION = {"name": "expected_version", "type": "int32"}
OPTIONS = {"name": "options", "cardinality": "repeated", "type": FieldOption}
HIDDEN = {"name": "hidden_views", "cardinality": "repeated", "type": "string"}
LIST_RESPONSE = [{"name": "fields", "cardinality": "repeated", "type": Field}]
OPTIONAL = ("name", "type", "default")


def _pb() -> Any:
    from infrastructure.customfields.grpc import customfields_pb2

    return customfields_pb2


def _message(field: FieldDefinition) -> Any:
    pb = _pb()
    return pb.Field(
        id=str(field.pk),
        project_id=str(field.project_id),
        name=field.name,
        type=field.type,
        options=[
            pb.FieldOptionResponse(id=o["id"], label=o["label"], color=o["color"])
            for o in field.options
        ],
        required=field.required,
        default=field.default,
        hidden_views=list(field.hidden_views),
        position=field.position,
        version=field.version,
        archived_at=field.archived_at.isoformat() if field.archived_at else "",
    )


def _list(fields: list[FieldDefinition]) -> Any:
    return _pb().FieldList(fields=[_message(f) for f in fields])


def _options(request: Any) -> list[dict[str, str]]:
    return [{"id": o.id, "label": o.label, "color": o.color} for o in request.options]


async def _scope(request: Any, context: Any) -> tuple[Any, Any]:
    user = require_caller(await grpc_caller(context))
    return user, await sync_to_async(require_workspace)(user, request.workspace_id)


class FieldService(generics.GenericService):
    @grpc_action(
        request=[*IDS, {"name": "include_archived", "type": "bool"}],
        request_name="FieldListRequest",
        response=LIST_RESPONSE,
        response_name="FieldList",
    )
    @action
    async def List(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)
        return await sync_to_async(
            lambda: _list(
                services.list_fields(
                    user, workspace, request.project_id, include_archived=request.include_archived
                )
            )
        )()

    @grpc_action(
        request=[
            *IDS,
            {"name": "name", "type": "string"},
            {"name": "type", "type": "string"},
            OPTIONS,
            {"name": "required", "type": "bool"},
            {"name": "default", "type": "string"},
            HIDDEN,
        ],
        request_name="FieldCreateRequest",
        response=Field,
        response_name="Field",
    )
    @action
    async def Create(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)
        return await sync_to_async(
            lambda: _message(
                services.create(
                    user,
                    workspace,
                    request.project_id,
                    name=request.name,
                    type=request.type,
                    options=_options(request),
                    required=request.required,
                    default=request.default,
                    hidden_views=list(request.hidden_views),
                )
            )
        )()

    @grpc_action(
        request=[
            *IDS,
            ID,
            VERSION,
            *({"name": n, "type": "string", "cardinality": "optional"} for n in OPTIONAL),
            {"name": "required", "type": "bool", "cardinality": "optional"},
            {"name": "set_options", "type": "bool"},
            OPTIONS,
            {"name": "set_hidden_views", "type": "bool"},
            HIDDEN,
            {"name": "remaps", "cardinality": "repeated", "type": OptionRemap},
        ],
        request_name="FieldUpdateRequest",
        response=Field,
        response_name="Field",
    )
    @action
    async def Update(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)
        sent: dict[str, Any] = {
            n: getattr(request, n) for n in (*OPTIONAL, "required") if request.HasField(n)
        }
        if request.set_options:
            sent["options"] = _options(request)
        if request.set_hidden_views:
            sent["hidden_views"] = list(request.hidden_views)
        remap = {r.from_option: r.to_option for r in request.remaps}
        return await sync_to_async(
            lambda: _message(
                services.update(
                    user,
                    workspace,
                    request.project_id,
                    request.id,
                    request.expected_version,
                    sent,
                    remap,
                )
            )
        )()

    @grpc_action(
        request=[*IDS, {"name": "ids", "cardinality": "repeated", "type": "string"}],
        request_name="FieldReorderRequest",
        response=LIST_RESPONSE,
        response_name="FieldList",
    )
    @action
    async def Reorder(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)
        return await sync_to_async(
            lambda: _list(services.reorder(user, workspace, request.project_id, list(request.ids)))
        )()

    @grpc_action(
        request=[*IDS, ID, VERSION],
        request_name="FieldArchiveRequest",
        response=Field,
        response_name="Field",
    )
    @action
    async def Archive(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)
        return await sync_to_async(
            lambda: _message(
                services.archive(
                    user, workspace, request.project_id, request.id, request.expected_version
                )
            )
        )()

    @grpc_action(
        request=[*IDS, ID, VERSION],
        request_name="FieldRestoreRequest",
        response=Field,
        response_name="Field",
    )
    @action
    async def Restore(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)
        return await sync_to_async(
            lambda: _message(
                services.restore(
                    user, workspace, request.project_id, request.id, request.expected_version
                )
            )
        )()


GRPC_SERVICES = [FieldService]
