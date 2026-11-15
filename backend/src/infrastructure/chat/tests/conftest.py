import json
from typing import Any

import pytest

from infrastructure.chat import services
from infrastructure.inbox.tests import conftest as inbox_fixtures

make_user = inbox_fixtures.make_user
add_member = inbox_fixtures.add_member
_commit_hooks_run_now = inbox_fixtures._commit_hooks_run_now
team = inbox_fixtures.team
inbox_settings = inbox_fixtures.inbox_settings
broker = inbox_fixtures.broker
push = inbox_fixtures.push


def doc(*parts: Any) -> str:
    """A body: one paragraph of text and mention nodes."""
    nodes = [{"type": "text", "text": p} if isinstance(p, str) else p for p in parts]
    return json.dumps({"type": "doc", "content": [{"type": "paragraph", "content": nodes}]})


def ping(user: Any) -> dict[str, Any]:
    return {"type": "mention", "attrs": {"id": str(user.pk), "label": "x"}}


def everyone(word: str = "channel") -> dict[str, Any]:
    return {"type": "mention", "attrs": {"id": word, "label": word}}


@pytest.fixture
def general(team: Any) -> Any:
    return services.ensure_general(team.ws)


@pytest.fixture
def group(team: Any) -> Any:
    """A private group of owner, member and pm."""
    return services.create_space(
        team.owner, team.ws, "group", "Secret", [str(team.member.pk), str(team.pm.pk)]
    )
