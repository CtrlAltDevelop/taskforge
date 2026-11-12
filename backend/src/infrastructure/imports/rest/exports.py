"""Downloading an export with the signed link ``Exports.Status`` hands out.

The link needs no bearer (a browser download cannot send one) and is the token alone, which
expires in minutes. The file is streamed in blocks.
"""

from collections.abc import Iterator

from django.core.files.storage import default_storage
from django.http import HttpRequest, StreamingHttpResponse
from django.utils.http import content_disposition_header
from ninja import Router

from infrastructure.imports import exports

router = Router()
BLOCK = 64 * 1024


def _blocks(key: str) -> Iterator[bytes]:
    with default_storage.open(key, "rb") as handle:
        while chunk := handle.read(BLOCK):
            yield chunk


@router.get("/download", auth=None, summary="The export zip, with a signed token")
def download(request: HttpRequest, token: str = "") -> StreamingHttpResponse:
    job = exports.resolve_token(token)
    response = StreamingHttpResponse(_blocks(job.file_key), content_type="application/zip")
    response["Content-Length"] = str(job.file_size)
    response["Content-Disposition"] = content_disposition_header(True, job.filename)
    response["Cache-Control"] = "private, no-store"
    return response
