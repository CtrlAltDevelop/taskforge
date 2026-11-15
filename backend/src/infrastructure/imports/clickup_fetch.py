"""Pull the chosen ClickUp lists into one ``{"tasks": [...]}`` file, then hand it to the importer.

Runs in the background lane. The token only lives in this call's arguments."""

import json
import logging
import tempfile
from typing import Any

from django.utils import timezone

from infrastructure.common.errors import ApiError
from infrastructure.imports import clickup_api, files
from infrastructure.imports.models import ImportJob
from infrastructure.imports.models import Status as JobStatus

logger = logging.getLogger(__name__)


class _Stopped(Exception):
    """A person cancelled the fetch."""


def _alive(job_id: Any, **fields: Any) -> None:
    """Heartbeat (and progress); stop when the job is no longer fetching."""
    if not ImportJob.objects.filter(pk=job_id, status=JobStatus.FETCHING).update(
        heartbeat_at=timezone.now(), **fields
    ):
        raise _Stopped


def _write(job_id: Any, token: str, list_ids: list[str], out: Any) -> int:
    seen: set[str] = set()
    out.write(b'{"tasks": [')
    with clickup_api.make_client(token) as http:
        for n, list_id in enumerate(list_ids, 1):
            _alive(job_id, phase=f"list {n}/{len(list_ids)}")
            for page in clickup_api.task_pages(http, list_id):
                for task in page:
                    if str(task["id"]) in seen:
                        continue
                    seen.add(str(task["id"]))
                    task["comments"] = clickup_api.comments(http, str(task["id"]))
                    out.write((b"," if len(seen) > 1 else b"") + json.dumps(task).encode())
                _alive(job_id, done=len(seen))
    out.write(b"]}")
    return len(seen)


def run(job_id: Any, token: str, list_ids: list[str]) -> None:
    job = ImportJob.objects.get(pk=job_id)
    try:
        with tempfile.TemporaryFile() as spool:
            count = _write(job_id, token, list_ids, spool)
            spool.seek(0)
            key, size = files.store(job.workspace_id, spool, "clickup.json")
    except _Stopped:
        return
    except ApiError as err:
        _fail(job_id, str(err))
        return
    except Exception:  # noqa: BLE001 -- the job row holds the failure
        logger.exception("clickup fetch failed")
        _fail(job_id, "The fetch failed; try again.")
        return
    done = ImportJob.objects.filter(pk=job_id, status=JobStatus.FETCHING).update(
        status=JobStatus.UPLOADED, file_key=key, file_size=size, total=count, done=count, phase=""
    )
    if not done:  # cancelled just now
        files.remove(ImportJob(file_key=key))


def _fail(job_id: Any, message: str) -> None:
    ImportJob.objects.filter(pk=job_id, status=JobStatus.FETCHING).update(
        status=JobStatus.FAILED, error=message[:500], finished_at=timezone.now()
    )
