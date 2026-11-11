"""Reading a file: ask for a short-lived signed link, then fetch the bytes with it.

``/link`` and ``/{id}`` check the caller (bearer) can open the task; ``/raw`` takes no bearer so an
``<img>`` or a video player can use it, and is protected by the token alone, which expires in
minutes. Risky types are always served as downloads.
"""

from collections.abc import Iterator
from datetime import timedelta
from typing import Any
from uuid import UUID

from django.conf import settings
from django.core.files.storage import default_storage
from django.http import (
    FileResponse,
    HttpRequest,
    HttpResponse,
    HttpResponseRedirect,
    StreamingHttpResponse,
)
from django.utils import timezone
from django.utils.http import content_disposition_header
from ninja import Router

from infrastructure.attachments import services, sniff
from infrastructure.attachments.models import Attachment
from infrastructure.attachments.rest.schemas import LinkOut
from infrastructure.auth.core.sessions import api_auth
from infrastructure.common.errors import ApiError

router = Router()
BLOCK = 64 * 1024


def _raw_url(request: HttpRequest, attachment_id: UUID, token: str) -> str:
    base = request.path.rsplit("/", 2)[0]  # .../files
    return request.build_absolute_uri(f"{base}/{attachment_id}/raw?token={token}")


def _token(request: HttpRequest, attachment_id: UUID, thumb: bool) -> str:
    workspace = services.workspace_of(request.user, str(attachment_id))
    return services.link_token(request.user, workspace, attachment_id, thumb=thumb)


@router.get(
    "/{attachment_id}/link",
    response=LinkOut,
    auth=api_auth,
    summary="A signed link to the file (or its thumbnail), valid for a short while",
)
def link(request: HttpRequest, attachment_id: UUID, thumb: bool = False) -> LinkOut:
    token = _token(request, attachment_id, thumb)
    expires = timezone.now() + timedelta(seconds=settings.ATTACHMENT_LINK_TTL_SECONDS)
    return LinkOut(url=_raw_url(request, attachment_id, token), expires_at=expires.isoformat())


@router.get(
    "/{attachment_id}",
    auth=api_auth,
    summary="Redirect to a signed link to the file",
    response={302: None},
)
def download(request: HttpRequest, attachment_id: UUID) -> HttpResponseRedirect:
    token = _token(request, attachment_id, False)
    return HttpResponseRedirect(_raw_url(request, attachment_id, token))


UNSATISFIABLE = (-1, -1)


def _range(header: str, size: int) -> tuple[int, int] | None:
    """The (first, last) byte of a single ``bytes=a-b`` range. ``None`` when the header is not one
    we serve (another unit, several ranges, not a range): it is ignored and the whole file goes
    out, as RFC 9110 says. ``UNSATISFIABLE`` for a well-formed range outside the file (416)."""
    unit, _, spec = header.partition("=")
    first, dash, last = spec.partition("-")
    if unit.strip() != "bytes" or not dash or "," in spec:
        return None
    try:
        if first == "":
            length = int(last)
            if length <= 0:
                return UNSATISFIABLE
            return (max(size - length, 0), size - 1)
        start = int(first)
        end = int(last) if last else size - 1
    except ValueError:
        return None
    end = min(end, size - 1)
    return (start, end) if 0 <= start <= end else UNSATISFIABLE


def _slice(handle: Any, first: int, last: int) -> Iterator[bytes]:
    with handle:
        handle.seek(first)
        left = last - first + 1
        while left > 0 and (block := handle.read(min(BLOCK, left))):
            left -= len(block)
            yield block


def _serve(request: HttpRequest, attachment: Attachment, thumb: bool) -> HttpResponse:
    key = attachment.thumb_key if thumb else attachment.storage_key
    mime = "image/jpeg" if thumb else attachment.mime
    inline = thumb or sniff.Sniffed(mime).inline
    try:
        size = default_storage.size(key)
        handle = default_storage.open(key)
    except OSError:
        raise ApiError("No such file.", 404) from None
    wanted = request.headers.get("Range")
    span = _range(wanted, size) if wanted else None
    if span == UNSATISFIABLE:
        handle.close()
        response: HttpResponse = HttpResponse(status=416)
        response["Content-Range"] = f"bytes */{size}"
        return response
    if span is None:
        response = FileResponse(handle, content_type=mime)
        response["Content-Length"] = str(size)
    else:
        response = StreamingHttpResponse(_slice(handle, *span), status=206, content_type=mime)
        response["Content-Range"] = f"bytes {span[0]}-{span[1]}/{size}"
        response["Content-Length"] = str(span[1] - span[0] + 1)
    name = f"thumb-{attachment.filename}.jpg" if thumb else attachment.filename
    response["Content-Disposition"] = content_disposition_header(not inline, name)
    response["Accept-Ranges"] = "bytes"
    response["X-Content-Type-Options"] = "nosniff"
    # A PDF viewer does not run inside a sandbox, so a PDF gets the policy without it.
    response["Content-Security-Policy"] = (
        "default-src 'none'" if mime == "application/pdf" else "default-src 'none'; sandbox"
    )
    response["Referrer-Policy"] = "no-referrer"  # the token is in the URL
    response["Cache-Control"] = "private, max-age=60"
    return response


@router.get("/{attachment_id}/raw", auth=None, summary="The bytes, with a signed token")
def raw(request: HttpRequest, attachment_id: UUID, token: str = "") -> HttpResponse:
    attachment, thumb = services.resolve_token(token)
    if attachment.pk != attachment_id:
        raise ApiError("This link is not valid.", 403)
    return _serve(request, attachment, thumb)
