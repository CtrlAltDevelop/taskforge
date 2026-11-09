"""Workspace logo upload. Everything else about workspaces is gRPC.

Needs workspace.update. A non-member and a missing id both get the same 403; a member
without the permission gets the reason in the envelope data.
"""

from uuid import UUID

from django.http import HttpRequest
from ninja import File, Form, Router, UploadedFile

from infrastructure.auth.core.sessions import api_auth
from infrastructure.common.errors import ApiError
from infrastructure.common.responses import ResponseTitle
from infrastructure.workspaces import services
from infrastructure.workspaces.rest.schemas import WorkspaceOut

router = Router()

UPLOAD_OVERHEAD_BYTES = 64 * 1024  # multipart framing around the file in CONTENT_LENGTH
LOGO_TOO_BIG = "The logo must be a PNG, JPEG or WebP image of at most 2 MB."


@router.post(
    "/{workspace_id}/logo",
    response=WorkspaceOut,
    auth=api_auth,
    summary="Upload the workspace logo (PNG, JPEG or WebP, up to 2 MB)",
)
def upload_logo(
    request: HttpRequest,
    workspace_id: UUID,
    file: File[UploadedFile],
    expected_version: Form[int | None] = None,
) -> WorkspaceOut:
    declared = int(request.META.get("CONTENT_LENGTH") or 0)
    if max(declared, file.size or 0) > services.LOGO_MAX_BYTES + UPLOAD_OVERHEAD_BYTES:
        raise ApiError(LOGO_TOO_BIG, title=ResponseTitle.UPLOAD_INVALID)
    # Read one byte past the cap so a lying size still cannot slip through.
    content = file.read(services.LOGO_MAX_BYTES + 1)
    row = services.set_logo(request.user, str(workspace_id), content, expected_version)
    return WorkspaceOut(
        id=str(row.id),
        name=row.name,
        slug=row.slug,
        logo=row.logo.url if row.logo else "",
        version=row.version,
    )
