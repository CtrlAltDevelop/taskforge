from collections.abc import Iterator
from pathlib import Path
from typing import Any

import pytest
from PIL import Image

from infrastructure.projects.tests import conftest as project_fixtures

make_user = project_fixtures.make_user
add_member = project_fixtures.add_member
_commit_hooks_run_now = project_fixtures._commit_hooks_run_now
team = project_fixtures.team

PNG = b"\x89PNG\r\n\x1a\n" + b"x" * 40


@pytest.fixture(autouse=True)
def storage(settings: Any, tmp_path: Path) -> Iterator[Path]:
    """Files go to a folder of the test; chunks are tiny so a file needs several."""
    settings.MEDIA_ROOT = str(tmp_path / "media")
    settings.ATTACHMENT_CHUNK_BYTES = 16
    settings.ATTACHMENT_MAX_BYTES = 1024
    settings.ATTACHMENT_WORKSPACE_QUOTA_BYTES = 0
    settings.ATTACHMENT_CLAMAV_ADDRESS = ""
    yield tmp_path / "media"


@pytest.fixture
def project(team: Any) -> Any:
    return team.create(team.owner, "WEB")


@pytest.fixture
def task(team: Any, project: Any) -> Any:
    from infrastructure.tasks import services as tasks

    return tasks.create(team.owner, team.ws, str(project.pk), "Fix login")


def real_png(width: int = 64, height: int = 48) -> bytes:
    import io

    out = io.BytesIO()
    Image.new("RGB", (width, height), "blue").save(out, "PNG")
    return out.getvalue()
