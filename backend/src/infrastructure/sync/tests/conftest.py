from typing import Any

import pytest

from infrastructure.projects.tests import conftest as project_fixtures

make_user = project_fixtures.make_user
add_member = project_fixtures.add_member
_commit_hooks_run_now = project_fixtures._commit_hooks_run_now
team = project_fixtures.team


@pytest.fixture
def project(team: Any) -> Any:
    return team.create(team.owner, "WEB")


class Recorder:
    """A broker that remembers what was published to it."""

    def __init__(self) -> None:
        self.sent: list[tuple[str, dict[str, Any]]] = []

    def publish(self, channel: str, payload: dict[str, Any]) -> None:
        self.sent.append((channel, payload))

    def rooms(self) -> list[str]:
        return [p["room"] for _, p in self.sent]

    def events(self) -> list[dict[str, Any]]:
        return [p["event"] for _, p in self.sent]


@pytest.fixture
def broker(monkeypatch: pytest.MonkeyPatch) -> Recorder:
    recorder = Recorder()
    monkeypatch.setattr("infrastructure.sync.publish.get_broker", lambda: recorder)
    return recorder
