"""Uploading the file to import. The rest of importing is gRPC.

The file goes over REST because browsers send big files as multipart; it is copied to storage in
blocks, never held whole. Needs ``data.manage``.
"""

from typing import Any
from uuid import UUID

from django.conf import settings
from django.http import HttpRequest
from ninja import File, Form, Router, Schema, UploadedFile

from infrastructure.auth.core.sessions import api_auth
from infrastructure.common.errors import ApiError
from infrastructure.imports import services
from infrastructure.workspaces.scoping import require_workspace

router = Router()
OVERHEAD = 64 * 1024  # multipart framing around the file in CONTENT_LENGTH


class UploadOut(Schema):
    id: str
    source: str
    filename: str
    size: int
    member: str  # the file inside a zip that will be read ("": the person must pick one)
    members: list[str]  # the .csv / .json files inside a zip (several: the person picks one)


@router.post(
    "/upload",
    response=UploadOut,
    auth=api_auth,
    summary="Upload a Jira, ClickUp, CSV or TaskForge export to import (a file or a zip)",
)
def upload(
    request: HttpRequest,
    workspace_id: Form[UUID],
    file: File[UploadedFile],
    source: Form[str] = "",
) -> UploadOut:
    workspace = require_workspace(request.user, str(workspace_id))
    declared = int(request.META.get("CONTENT_LENGTH") or 0)
    if max(declared - OVERHEAD, file.size or 0) > settings.IMPORTS_MAX_BYTES:
        raise ApiError("The file is larger than this server accepts.", status=413)
    job = services.upload(request.user, workspace, file, file.name or "upload", source)
    return UploadOut(
        id=str(job.pk),
        source=job.source,
        filename=job.filename,
        size=job.file_size,
        member=job.member,
        members=services.members_of(request.user, workspace, str(job.pk)),
    )


class ClickUpListIn(Schema):
    workspace_id: UUID
    token: str


class ClickUpFetchIn(ClickUpListIn):
    list_ids: list[str]


class ClickUpFetchOut(Schema):
    id: str
    status: str


@router.post(
    "/clickup/lists",
    auth=api_auth,
    summary="The ClickUp workspaces and lists a personal API token can see (token not kept)",
)
def clickup_lists(request: HttpRequest, payload: ClickUpListIn) -> list[dict[str, Any]]:
    workspace = require_workspace(request.user, str(payload.workspace_id))
    return services.clickup_lists(request.user, workspace, payload.token)


@router.post(
    "/clickup/fetch",
    response=ClickUpFetchOut,
    auth=api_auth,
    summary="Fetch ClickUp lists in the background into an import job (watch it with gRPC Get)",
)
def clickup_fetch(request: HttpRequest, payload: ClickUpFetchIn) -> ClickUpFetchOut:
    workspace = require_workspace(request.user, str(payload.workspace_id))
    job = services.clickup_fetch_start(request.user, workspace, payload.token, payload.list_ids)
    return ClickUpFetchOut(id=str(job.pk), status=job.status)
