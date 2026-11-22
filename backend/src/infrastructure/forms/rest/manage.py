"""Form logo upload: ``POST /api/v1/forms/{form_id}/logo``. Everything else about forms is gRPC.

Multipart ``file`` (PNG, JPEG or WebP, at most 2 MB, read from its bytes) and ``expected_version``;
the workspace is the ``X-Workspace`` header. Needs ``form.manage``; an API token is refused.
"""

from uuid import UUID

from django.http import HttpRequest
from ninja import File, Form, Router, Schema, UploadedFile

from infrastructure.auth.core.sessions import api_auth
from infrastructure.common.errors import ApiError
from infrastructure.common.responses import ResponseTitle
from infrastructure.forms import services
from infrastructure.workspaces.scoping import workspace_from_request
from infrastructure.workspaces.services import LOGO_MAX_BYTES

router = Router()

UPLOAD_OVERHEAD_BYTES = 64 * 1024  # multipart framing around the file in CONTENT_LENGTH
LOGO_TOO_BIG = "The logo must be a PNG, JPEG or WebP image of at most 2 MB."


class LogoOut(Schema):
    id: str
    logo_url: str
    version: int


@router.post(
    "/{form_id}/logo",
    response=LogoOut,
    auth=api_auth,
    summary="Upload the form's logo (PNG, JPEG or WebP, up to 2 MB)",
)
def upload_logo(
    request: HttpRequest,
    form_id: UUID,
    file: File[UploadedFile],
    expected_version: Form[int],
) -> LogoOut:
    workspace = workspace_from_request(request)
    declared = int(request.META.get("CONTENT_LENGTH") or 0)
    if max(declared, file.size or 0) > LOGO_MAX_BYTES + UPLOAD_OVERHEAD_BYTES:
        raise ApiError(LOGO_TOO_BIG, title=ResponseTitle.UPLOAD_INVALID)
    # Read one byte past the cap so a lying size still cannot slip through.
    content = file.read(LOGO_MAX_BYTES + 1)
    view = services.set_logo(request.user, workspace, str(form_id), content, expected_version)
    form = view.form
    return LogoOut(id=str(form.pk), logo_url=form.logo_src, version=form.version)
