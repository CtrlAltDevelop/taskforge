from typing import Any

import pytest

from infrastructure.projects.tests import conftest as project_fixtures
from infrastructure.tasks import services as tasks

make_user = project_fixtures.make_user
add_member = project_fixtures.add_member
_commit_hooks_run_now = project_fixtures._commit_hooks_run_now
team = project_fixtures.team


@pytest.fixture(autouse=True)
def no_throttle(settings: Any) -> None:
    settings.SEARCH_RATE_PER_MINUTE = 0


def doc(*words: str) -> str:
    import json

    return json.dumps(
        {
            "type": "doc",
            "content": [
                {"type": "paragraph", "content": [{"type": "text", "text": " ".join(words)}]}
            ],
        }
    )


def make_task(team: Any, project: Any, title: str, text: str = "", who: Any = None) -> Any:
    return tasks.create(
        who or team.owner,
        team.ws,
        str(project.pk),
        title,
        description=doc(text) if text else "",
    )
