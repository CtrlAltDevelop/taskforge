"""A small reader of ClickUp's REST API (v2). Only ``api.clickup.com`` is ever called, and the token
is held by the ``httpx`` client alone: it is not logged, stored or put in a message."""

import re
import time
from collections.abc import Iterator
from typing import Any, Final

import httpx

from infrastructure.common.errors import ApiError

BASE: Final = "https://api.clickup.com/api/v2"
TIMEOUT: Final = 30.0
MAX_TRIES: Final = 4
MAX_WAIT: Final = 65.0  # ClickUp's limit is per minute
ID_RE: Final = re.compile(r"^[A-Za-z0-9_-]{1,40}$")


def _sleep(seconds: float) -> None:
    time.sleep(seconds)


def make_client(token: str) -> httpx.Client:
    return httpx.Client(base_url=BASE, headers={"Authorization": token.strip()}, timeout=TIMEOUT)


def valid_id(value: str) -> bool:
    return bool(ID_RE.match(value or ""))


def _get(http: httpx.Client, path: str, **params: Any) -> dict[str, Any]:
    for attempt in range(MAX_TRIES):
        try:
            response = http.get(path, params=params or None)
        except httpx.HTTPError:
            raise ApiError("Could not reach ClickUp.", status=502) from None
        if response.status_code == 429 and attempt < MAX_TRIES - 1:
            try:
                wait = float(response.headers.get("Retry-After", "") or 5)
            except ValueError:
                wait = 5.0
            _sleep(min(max(wait, 0.0), MAX_WAIT))
            continue
        if response.status_code in (401, 403):
            raise ApiError("ClickUp rejected the token.", status=400)
        if response.status_code == 429:
            raise ApiError("ClickUp's rate limit was hit; try again in a minute.", status=429)
        if response.status_code != 200:
            raise ApiError(f"ClickUp answered {response.status_code}.", status=502)
        try:
            body = response.json()
        except ValueError:
            raise ApiError("ClickUp sent something unreadable.", status=502) from None
        return body if isinstance(body, dict) else {}
    raise ApiError("ClickUp's rate limit was hit; try again in a minute.", status=429)


def _items(body: dict[str, Any], key: str) -> list[dict[str, Any]]:
    return [x for x in body.get(key) or [] if isinstance(x, dict) and x.get("id")]


def workspaces_with_lists(http: httpx.Client) -> list[dict[str, Any]]:
    """Each ClickUp workspace with its lists flattened (``lists``: id, name, path)."""
    out = []
    for team in _items(_get(http, "/team"), "teams"):
        lists: list[dict[str, str]] = []
        for space in _items(_get(http, f"/team/{team['id']}/space", archived="false"), "spaces"):
            head = str(space.get("name", ""))
            for folder in _items(_get(http, f"/space/{space['id']}/folder"), "folders"):
                for item in _items(_get(http, f"/folder/{folder['id']}/list"), "lists"):
                    path = " › ".join(
                        [head, str(folder.get("name", "")), str(item.get("name", ""))]
                    )
                    lists.append(
                        {"id": str(item["id"]), "name": str(item.get("name", "")), "path": path}
                    )
            for item in _items(_get(http, f"/space/{space['id']}/list"), "lists"):
                lists.append(
                    {
                        "id": str(item["id"]),
                        "name": str(item.get("name", "")),
                        "path": f"{head} › {item.get('name', '')}",
                    }
                )
        out.append({"id": str(team["id"]), "name": str(team.get("name", "")), "lists": lists})
    return out


def task_pages(http: httpx.Client, list_id: str) -> Iterator[list[dict[str, Any]]]:
    """A list's tasks (closed ones and sub-tasks too), one page of up to 100 at a time."""
    page = 0
    while True:
        body = _get(
            http,
            f"/list/{list_id}/task",
            page=page,
            include_closed="true",
            subtasks="true",
            include_markdown_description="true",
        )
        tasks = _items(body, "tasks")
        if tasks:
            yield tasks
        if body.get("last_page") is not False or not tasks:
            return
        page += 1


def comments(http: httpx.Client, task_id: str) -> list[dict[str, Any]]:
    if not valid_id(task_id):
        return []
    return _items(_get(http, f"/task/{task_id}/comment"), "comments")
