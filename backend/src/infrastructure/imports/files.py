"""Where an upload lives while it is read: the default storage, streamed in and out."""

import re
import uuid
from typing import IO, Any

from django.core.files.storage import default_storage

from infrastructure.imports import streams
from infrastructure.imports.models import ImportJob


def store(workspace_id: Any, upload: IO[bytes], filename: str) -> tuple[str, int]:
    """Save the stream under a fresh key and return ``(key, size)``; never reads it whole."""
    safe = re.sub(r"[^A-Za-z0-9._-]", "_", filename)[-80:] or "upload"
    key = f"imports/{workspace_id}/{uuid.uuid4().hex}-{safe}"
    saved = default_storage.save(key, upload)
    return saved, default_storage.size(saved)


def open_job(job: ImportJob) -> IO[bytes]:
    """The job's data stream: the stored file, or the one member of its zip."""
    raw = default_storage.open(job.file_key, "rb")
    try:
        binary, _ = streams.open_binary(raw, job.member)
    except Exception:
        raw.close()
        raise
    return binary


def remove(job: ImportJob) -> None:
    if job.file_key and default_storage.exists(job.file_key):
        default_storage.delete(job.file_key)
