"""My work: assigned or watched tasks across the projects the viewer can open."""

import json
from typing import Any

import pytest

from infrastructure.common.errors import ApiError
from infrastructure.filters import language
from infrastructure.filters import services as filter_services
from infrastructure.filters.language import Catalogue
from infrastructure.home import mywork
from infrastructure.home.tests.conftest import Category, World
from infrastructure.inbox.models import Watcher


def titles(world: World, user: Any, **kw: Any) -> list[str]:
    rows, _ = mywork.my_work(user, world.ws, **kw)
    return [item.title for item, _, _ in rows]


def test_lists_assigned_and_watched_open_tasks_by_due_date(world: World) -> None:
    world.task(world.web, "later", world.member, due_date="2026-12-01")
    world.task(world.web, "soon", world.member, due_date="2026-11-20")
    world.task(world.web, "undated", world.member)
    watched = world.task(world.web, "watched", due_date="2026-11-25")
    Watcher.objects.create(task=watched, user=world.member)
    world.task(world.web, "not mine")
    finished = world.task(world.web, "finished", world.member)
    world.move(finished, Category.DONE)

    assert titles(world, world.member) == ["soon", "watched", "later", "undated"]
    assert titles(world, world.member, relation="assigned") == ["soon", "later", "undated"]
    assert titles(world, world.member, relation="watching") == ["watched"]
    assert "finished" in titles(world, world.member, include_done=True)
    rows, _ = mywork.my_work(world.member, world.ws)
    flags = {i.title: (a, w) for i, a, w in rows}
    assert flags["watched"] == (False, True) and flags["soon"][0] is True


def test_a_private_project_never_shows_up(world: World) -> None:
    secret = world.task(world.sec, "secret", world.member)
    Watcher.objects.create(task=secret, user=world.member)

    assert titles(world, world.member) == []
    assert titles(world, world.owner) == []  # assigned to nobody else


def test_pages_with_a_cursor(world: World) -> None:
    for n in range(5):
        world.task(world.web, f"t{n}", world.member, due_date=f"2026-12-0{n + 1}")

    first, cursor = mywork.my_work(world.member, world.ws, limit=2)
    second, cursor2 = mywork.my_work(world.member, world.ws, limit=2, cursor=cursor)
    last, cursor3 = mywork.my_work(world.member, world.ws, limit=2, cursor=cursor2)

    seen = [i.title for page in (first, second, last) for i, _, _ in page]
    assert seen == ["t0", "t1", "t2", "t3", "t4"] and cursor3 == ""


def test_the_toolbar_filter_narrows_the_list(world: World) -> None:
    world.task(world.web, "urgent one", world.member, priority="urgent")
    world.task(world.web, "calm one", world.member, priority="low")
    cat = Catalogue(None, world.ws)
    checked = filter_services.check(cat, "priority = urgent")
    ast = json.dumps(language.canonical(checked.ast, cat))

    assert titles(world, world.member, filter_ast=ast, today="2026-11-18") == ["urgent one"]


def test_bad_arguments_are_refused(world: World) -> None:
    with pytest.raises(ApiError):
        mywork.my_work(world.member, world.ws, relation="owned")
    with pytest.raises(ApiError):
        mywork.my_work(world.member, world.ws, cursor="x")
    with pytest.raises(ApiError):
        mywork.my_work(world.member, world.ws, cursor="-5")
    with pytest.raises(ApiError):
        mywork.my_work(world.member, world.ws, filter_ast="not json")


def test_my_work_never_includes_another_workspaces_tasks(world: World) -> None:
    from infrastructure.projects import services as project_services
    from infrastructure.workspaces import services as workspace_services

    other = workspace_services.create(world.owner, "Other", "other")
    project = project_services.create(world.owner, other, "Zed", "ZED").project
    world.task_in(other, project, "theirs", world.owner)
    Watcher.objects.create(
        task=world.task_in(other, project, "watched", world.owner), user=world.owner
    )
    world.task(world.web, "mine", world.owner)

    assert titles(world, world.owner) == ["mine"]
