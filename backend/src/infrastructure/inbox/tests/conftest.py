from collections.abc import Iterator
from typing import Any

import pytest

from infrastructure.auth.core import delivery as mail
from infrastructure.inbox import delivery
from infrastructure.projects.tests import conftest as project_fixtures

make_user = project_fixtures.make_user
add_member = project_fixtures.add_member
_commit_hooks_run_now = project_fixtures._commit_hooks_run_now
team = project_fixtures.team


class FakePush:
    """Records every push instead of sending it; ``fail`` makes the next send raise."""

    def __init__(self) -> None:
        self.sent: list[dict[str, Any]] = []
        self.fail = False

    def send(self, device: Any, title: str, body: str, data: dict[str, str]) -> None:
        if self.fail:
            raise RuntimeError("provider down")
        self.sent.append({"token": device.token, "title": title, "body": body, "data": data})


@pytest.fixture(autouse=True)
def inbox_settings(settings: Any) -> Iterator[None]:
    settings.INBOX_SYNC_DELIVERY = True  # deliver in the same thread so a test can look
    settings.INBOX_COALESCE_SECONDS = 60
    mail.outbox.clear()
    yield
    mail.outbox.clear()


class Recorder:
    """A broker that remembers what was published to it."""

    def __init__(self) -> None:
        self.sent: list[tuple[str, dict[str, Any]]] = []

    def publish(self, channel: str, payload: dict[str, Any]) -> None:
        self.sent.append((channel, payload))

    def events(self, room: str = "") -> list[dict[str, Any]]:
        return [p["event"] for _, p in self.sent if not room or p["room"] == room]


@pytest.fixture
def broker(monkeypatch: pytest.MonkeyPatch) -> Recorder:
    recorder = Recorder()
    monkeypatch.setattr("infrastructure.sync.publish.get_broker", lambda: recorder)
    return recorder


@pytest.fixture
def push(monkeypatch: pytest.MonkeyPatch) -> Iterator[FakePush]:
    fake = FakePush()
    monkeypatch.setattr(delivery, "push_provider", lambda: fake)
    yield fake


@pytest.fixture
def project(team: Any) -> Any:
    return team.create(team.owner, "WEB")


@pytest.fixture
def task(team: Any, project: Any) -> Any:
    from infrastructure.tasks import services as tasks

    return tasks.create(team.owner, team.ws, str(project.pk), "Fix login")
