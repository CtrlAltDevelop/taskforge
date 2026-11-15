"""Phase 41: fetching from ClickUp's API with a token, then importing as a ``clickup_json`` file."""

import json
from collections.abc import Callable
from typing import Any

import httpx
import pytest

from infrastructure.comments.models import Comment
from infrastructure.common.errors import ApiError
from infrastructure.imports import clickup_api, services
from infrastructure.imports.models import ImportJob
from infrastructure.imports.tests.conftest import World
from infrastructure.tasks.models import Task

SECRET = "pk_secret_token_123"


def _task(n: str, **extra: Any) -> dict[str, Any]:
    return {"id": n, "name": f"Task {n}", "status": {"status": "open"}, **extra}


class FakeClickUp:
    """A tiny ClickUp: one workspace, one space with a folder list and a folderless list."""

    def __init__(self) -> None:
        self.calls: list[str] = []
        self.rate_limited = 1  # answer the first task page with 429 this many times
        self.pages = {
            "L1": [[_task("a"), _task("b", parent="a")], [_task("c")]],
            "L2": [[_task("a")]],
        }

    def handler(self, request: httpx.Request) -> httpx.Response:
        assert request.url.host == "api.clickup.com"
        path = request.url.path.removeprefix("/api/v2")
        self.calls.append(path)
        if request.headers.get("Authorization") != SECRET:
            return httpx.Response(401, json={"err": "Oauth token not found"})
        if path == "/team":
            return httpx.Response(200, json={"teams": [{"id": "9", "name": "Acme"}]})
        if path == "/team/9/space":
            return httpx.Response(200, json={"spaces": [{"id": "S", "name": "Eng"}]})
        if path == "/space/S/folder":
            return httpx.Response(200, json={"folders": [{"id": "F", "name": "Q4"}]})
        if path == "/folder/F/list":
            return httpx.Response(200, json={"lists": [{"id": "L1", "name": "Launch"}]})
        if path == "/space/S/list":
            return httpx.Response(200, json={"lists": [{"id": "L2", "name": "Loose"}]})
        if path.startswith("/list/") and path.endswith("/task"):
            if self.rate_limited:
                self.rate_limited -= 1
                return httpx.Response(429, headers={"Retry-After": "0"}, json={})
            page = int(request.url.params.get("page", "0"))
            pages = self.pages[path.split("/")[2]]
            return httpx.Response(
                200, json={"tasks": pages[page], "last_page": page == len(pages) - 1}
            )
        if path.startswith("/task/") and path.endswith("/comment"):
            who = {"username": "Dave", "email": "dave@x.test"}
            body = {
                "id": f"c-{path.split('/')[2]}",
                "comment_text": "hi",
                "user": who,
                "date": "1731401000000",
            }
            return httpx.Response(200, json={"comments": [body]})
        return httpx.Response(404, json={})


@pytest.fixture
def clickup(monkeypatch: pytest.MonkeyPatch) -> FakeClickUp:
    fake = FakeClickUp()
    monkeypatch.setattr(
        clickup_api,
        "make_client",
        lambda token: httpx.Client(
            transport=httpx.MockTransport(fake.handler),
            base_url=clickup_api.BASE,
            headers={"Authorization": token},
        ),
    )
    monkeypatch.setattr(clickup_api, "_sleep", lambda seconds: None)
    return fake


def test_lists_are_the_hierarchy_flattened(world: World, clickup: FakeClickUp) -> None:
    teams = services.clickup_lists(world.owner, world.ws, SECRET)
    (team,) = teams
    assert team["name"] == "Acme"
    paths = {(x["id"], x["path"]) for x in team["lists"]}
    assert paths == {("L1", "Eng › Q4 › Launch"), ("L2", "Eng › Loose")}


def test_a_bad_token_is_refused_without_echoing_it(world: World, clickup: FakeClickUp) -> None:
    with pytest.raises(ApiError) as err:
        services.clickup_lists(world.owner, world.ws, "wrong-token-xyz")
    assert err.value.status == 400 and "wrong-token-xyz" not in str(err.value)


def test_fetch_makes_an_importable_job_once_per_task(world: World, clickup: FakeClickUp) -> None:
    job = services.clickup_fetch_start(world.owner, world.ws, SECRET, ["L1", "L2"])
    job.refresh_from_db()
    assert job.status == "uploaded" and job.source == "clickup_json", job.error
    assert job.total == 3  # a, b, c: the task in both lists counts once
    assert clickup.rate_limited == 0  # the 429 was waited out
    job = services.analyze(world.owner, world.ws, str(job.pk)).job
    done = services.start(world.owner, world.ws, str(job.pk), {**job.mapping, **world.into_web()})
    assert done.status == "done", done.error
    assert Task.objects.filter(project=world.web).count() == 3
    assert Task.objects.get(title="Task b").parent.title == "Task a"
    assert Comment.objects.count() == 3


def test_the_token_is_stored_nowhere(world: World, clickup: FakeClickUp) -> None:
    job = services.clickup_fetch_start(world.owner, world.ws, SECRET, ["L1"])
    from infrastructure.audit.models import AuditEntry

    row = ImportJob.objects.values().get(pk=job.pk)
    assert SECRET not in json.dumps(row, default=str)
    assert SECRET not in json.dumps(list(AuditEntry.objects.values("changes")), default=str)


def test_a_failed_fetch_marks_the_job_failed(world: World, clickup: FakeClickUp) -> None:
    clickup.rate_limited = 99
    job = services.clickup_fetch_start(world.owner, world.ws, SECRET, ["L1"])
    job.refresh_from_db()
    assert job.status == "failed" and "rate" in job.error.lower() and SECRET not in job.error


@pytest.mark.parametrize("bad", ["", "L1/../../x", "a b", "L1?x=1"])
def test_list_ids_cannot_reach_other_urls(world: World, clickup: FakeClickUp, bad: str) -> None:
    with pytest.raises(ApiError) as err:
        services.clickup_fetch_start(world.owner, world.ws, SECRET, [bad])
    assert err.value.status == 400 and clickup.calls == []


def test_only_admins_may_fetch(world: World, clickup: FakeClickUp) -> None:
    for call in (
        lambda: services.clickup_lists(world.alice, world.ws, SECRET),
        lambda: services.clickup_fetch_start(world.alice, world.ws, SECRET, ["L1"]),
    ):
        with pytest.raises(ApiError) as err:
            call()
        assert err.value.status in (403, 404)
    assert clickup.calls == []


def test_a_fetch_that_was_cancelled_stops(
    world: World, clickup: FakeClickUp, monkeypatch: pytest.MonkeyPatch
) -> None:
    from infrastructure.imports import clickup_fetch

    original: Callable[..., Any] = clickup_api.task_pages

    def cancelling(http: Any, list_id: str) -> Any:
        ImportJob.objects.update(status="cancelled")
        yield from original(http, list_id)

    monkeypatch.setattr(clickup_fetch.clickup_api, "task_pages", cancelling)
    job = services.clickup_fetch_start(world.owner, world.ws, SECRET, ["L1"])
    job.refresh_from_db()
    assert job.status == "cancelled" and not job.file_key


def test_a_dead_fetch_is_failed_by_the_tick(world: World, clickup: FakeClickUp) -> None:
    from datetime import timedelta

    from django.utils import timezone

    from infrastructure.imports import engine

    job = ImportJob.objects.create(
        workspace=world.ws,
        created_by=world.owner,
        source="clickup_json",
        filename="ClickUp",
        status="fetching",
        heartbeat_at=timezone.now() - timedelta(hours=1),
    )
    engine.resume_stalled()
    job.refresh_from_db()
    assert job.status == "failed" and "fetch again" in job.error.lower()
