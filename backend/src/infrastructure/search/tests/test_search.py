"""Search rules on the services: access, matching, operators, jump, history, index upkeep."""

from typing import Any

import pytest

from infrastructure.comments import services as comments
from infrastructure.comments.tests.conftest import say
from infrastructure.common.errors import ApiError
from infrastructure.search import index, services
from infrastructure.search.fold import fold, marks, snippet, terms
from infrastructure.search.models import SearchEntry, SearchHistory
from infrastructure.search.tests.conftest import make_task
from infrastructure.tasks import services as tasks


def find(team: Any, who: Any, text: str, *kinds: str, **kw: Any) -> services.Page:
    return services.query(who, team.ws, text, list(kinds), **kw)


def titles(page: services.Page, kind: str = "task") -> list[str]:
    return [h.title for h in page.hits[kind]]


@pytest.fixture
def web(team: Any) -> Any:
    return team.create(team.owner, "WEB")


def test_a_task_is_found_by_title_and_by_description(team: Any, web: Any) -> None:
    make_task(team, web, "Design the login page")
    make_task(team, web, "Billing", "the invoice layout needs a redesign")

    assert titles(find(team, team.member, "login")) == ["Design the login page"]
    assert titles(find(team, team.member, "invoice")) == ["Billing"]
    assert titles(find(team, team.member, "LOGIN page")) == ["Design the login page"]
    assert find(team, team.member, "nothing here").hits["task"] == []


def test_matches_are_highlighted_in_title_and_snippet(team: Any, web: Any) -> None:
    make_task(team, web, "Fix login", "users cannot login with a plus sign")

    [hit] = find(team, team.member, "login").hits["task"]

    assert hit.title_marks == [(4, 9)]
    start, end = hit.snippet_marks[0]
    assert hit.snippet[start:end] == "login"


def test_private_project_content_never_reaches_a_non_member(team: Any) -> None:
    private = team.create(team.owner, "SEC", visibility="private", name="Secret")
    make_task(team, private, "Zebra plan", "zebra secret")
    comments.create(
        team.owner, team.ws, str(private.pk), str(tasks_of(private)[0].pk), say("zebra comment")
    )

    for who in (team.member, team.viewer, team.admin):
        page = find(team, who, "zebra")
        assert all(not hits for hits in page.hits.values())
        assert find(team, who, "SEC-1").jump is None
    assert titles(find(team, team.owner, "zebra")) == ["Zebra plan"]


def tasks_of(project: Any) -> list[Any]:
    from infrastructure.tasks.models import Task

    return list(Task.objects.filter(project=project))


def test_another_workspace_is_never_searched(team: Any, web: Any) -> None:
    make_task(team, web, "Quokka")

    assert find(team, team.member, "quokka").hits["task"]
    with pytest.raises(ApiError):
        services.query(team.outsider, team.ws, "quokka", [])


def test_a_deleted_task_and_a_deleted_comment_disappear(team: Any, web: Any) -> None:
    task = make_task(team, web, "Walrus")
    comment = comments.create(team.owner, team.ws, str(web.pk), str(task.pk), say("walrus note"))
    assert find(team, team.member, "walrus", "comment").hits["comment"]

    comments.delete(team.owner, team.ws, str(web.pk), str(comment.pk))
    assert find(team, team.member, "walrus", "comment").hits["comment"] == []
    tasks.delete(team.owner, team.ws, str(web.pk), str(task.pk))
    assert find(team, team.member, "walrus").hits["task"] == []
    assert not SearchEntry.objects.exists()


def test_an_edit_updates_the_index_without_a_reindex(team: Any, web: Any) -> None:
    task = make_task(team, web, "Old name")
    tasks.update(
        team.owner, team.ws, str(web.pk), str(task.pk), task.version, {"title": "Fresh name"}
    )

    assert titles(find(team, team.member, "fresh")) == ["Fresh name"]
    assert find(team, team.member, "old").hits["task"] == []


def test_comments_are_found_with_their_task_and_author(team: Any, web: Any) -> None:
    task = make_task(team, web, "Cats")
    comments.create(team.member, team.ws, str(web.pk), str(task.pk), say("remember the aquarium"))

    [hit] = find(team, team.owner, "aquarium", "comment").hits["comment"]

    assert (hit.title, hit.key, hit.task_id) == ("Cats", "WEB-1", str(task.pk))
    assert hit.author and "aquarium" in hit.snippet


def test_operators_narrow_by_project_assignee_and_status(team: Any, web: Any) -> None:
    other = team.create(team.owner, "OPS", name="Operations")
    mine = make_task(team, web, "Deploy web")
    make_task(team, web, "Deploy docs")
    make_task(team, other, "Deploy ops")
    tasks.update(
        team.owner,
        team.ws,
        str(web.pk),
        str(mine.pk),
        mine.version,
        {"assignee_ids": [str(team.member.pk)]},
    )

    assert len(find(team, team.member, "deploy").hits["task"]) == 3
    assert titles(find(team, team.member, "deploy in:OPS")) == ["Deploy ops"]
    assert titles(find(team, team.member, "deploy in:oper")) == ["Deploy ops"]
    assert titles(find(team, team.member, "deploy assignee:me")) == ["Deploy web"]
    assert len(find(team, team.member, "deploy status:open").hits["task"]) == 3
    assert find(team, team.member, "deploy status:done").hits["task"] == []
    assert titles(find(team, team.member, "assignee:me")) == ["Deploy web"]


def test_my_tasks_rank_above_equal_matches(team: Any, web: Any) -> None:
    make_task(team, web, "Report one")
    second = make_task(team, web, "Report two")
    tasks.update(
        team.owner,
        team.ws,
        str(web.pk),
        str(second.pk),
        second.version,
        {"assignee_ids": [str(team.member.pk)]},
    )

    assert titles(find(team, team.member, "report"))[0] == "Report two"


def test_an_id_jumps_straight_to_the_task(team: Any, web: Any) -> None:
    make_task(team, web, "First")
    second = make_task(team, web, "Second")

    page = find(team, team.member, "web-2")

    assert page.jump is not None and page.jump.task_id == str(second.pk)
    assert find(team, team.member, "WEB-99").jump is None


def test_people_and_projects_are_found(team: Any, web: Any) -> None:
    assert [h.key for h in find(team, team.member, "web").hits["project"]] == ["WEB"]
    found = find(team, team.owner, team.member.username).hits["member"]
    assert [h.id for h in found] == [str(team.member.pk)]


def test_unknown_types_cursor_and_length_are_refused(team: Any) -> None:
    for call in (
        lambda: find(team, team.member, "x", "wiki"),
        lambda: find(team, team.member, "x", cursor="abc"),
        lambda: find(team, team.member, "x" * 201),
    ):
        with pytest.raises(ApiError):
            call()


def test_paging_walks_the_results_once(team: Any, web: Any) -> None:
    for n in range(5):
        make_task(team, web, f"Page item {n}")

    first = find(team, team.member, "page", "task", page_size=2)
    second = find(team, team.member, "page", "task", page_size=2, cursor=first.next_cursor)
    third = find(team, team.member, "page", "task", page_size=2, cursor=second.next_cursor)

    seen = titles(first) + titles(second) + titles(third)
    assert len(seen) == len(set(seen)) == 5 and third.next_cursor == ""


def test_the_rate_limit_applies_per_person(team: Any, web: Any, settings: Any) -> None:
    settings.SEARCH_RATE_PER_MINUTE = 2
    from django.core.cache import cache

    cache.clear()
    find(team, team.member, "a1")
    find(team, team.member, "a2")
    with pytest.raises(ApiError) as refused:
        find(team, team.member, "a3")
    assert refused.value.status == 429
    find(team, team.owner, "a1")


def test_persian_and_arabic_variants_find_each_other(team: Any, web: Any) -> None:
    make_task(team, web, "گزارش ۱۴۰۲ كتاب", "علي رفت")

    assert titles(find(team, team.member, "گزارش"))
    assert titles(find(team, team.member, "کتاب"))  # Persian kaf finds Arabic kaf
    assert titles(find(team, team.member, "1402"))  # ASCII digits find Persian digits
    assert titles(find(team, team.member, "علی"))  # Persian yeh finds Arabic yeh


def test_recent_searches_are_deduplicated_and_capped(team: Any) -> None:
    for n in range(25):
        services.remember(team.member, team.ws, f"query {n}")
    services.remember(team.member, team.ws, "query 24 ")
    services.remember(team.member, team.ws, "x")

    found = services.recent(team.member, team.ws)

    assert len(found) == services.HISTORY_LIMIT and found[0] == "query 24"
    assert services.recent(team.owner, team.ws) == []
    assert SearchHistory.objects.filter(user=team.member).count() == services.HISTORY_LIMIT


def test_reindex_rebuilds_everything(team: Any, web: Any) -> None:
    task = make_task(team, web, "Rebuild me")
    comments.create(team.owner, team.ws, str(web.pk), str(task.pk), say("and me"))
    SearchEntry.objects.all().delete()

    assert index.reindex() == 2
    assert titles(find(team, team.member, "rebuild")) == ["Rebuild me"]


def test_folding_keeps_length_and_positions() -> None:
    assert len(fold("İSTANBUL ǅ ß")) == len("İSTANBUL ǅ ß")
    assert terms("Re-run  the TEST, test!") == ["re", "run", "the", "test"]
    assert marks("a😀 test", ["test"]) == [(4, 8)]  # the emoji is two UTF-16 units
    text, spans = snippet("word " * 40 + "needle " + "tail " * 40, ["needle"])
    assert (
        text.startswith("…")
        and text.endswith("…")
        and spans
        and text[spans[0][0] : spans[0][1]] == "needle"
    )


def test_the_reindex_command_rebuilds_a_workspace(team: Any, web: Any) -> None:
    from io import StringIO

    from django.core.management import call_command

    make_task(team, web, "Command made")
    SearchEntry.objects.all().delete()
    out = StringIO()

    call_command("reindex", workspace=str(team.ws.pk), stdout=out)

    assert "Indexed 1 rows" in out.getvalue()


def test_a_restored_subtree_is_searchable_again(team: Any, web: Any) -> None:
    parent = make_task(team, web, "Parent plan")
    tasks.create(team.owner, team.ws, str(web.pk), "Kid errand", parent_id=str(parent.pk))
    tasks.delete(team.owner, team.ws, str(web.pk), str(parent.pk), "subtree")
    assert find(team, team.member, "errand").hits["task"] == []

    tasks.restore(team.owner, team.ws, str(web.pk), str(parent.pk))

    assert titles(find(team, team.member, "errand")) == ["Kid errand"]


def test_people_need_member_view(team: Any, web: Any) -> None:
    from infrastructure.workspaces.models import Role, RolePermission, WorkspaceMember

    role = Role.objects.create(workspace=team.ws, name="Narrow")
    RolePermission.objects.create(role=role, permission_key="workspace.view")
    WorkspaceMember.objects.filter(workspace=team.ws, user=team.viewer).update(role=role)

    assert find(team, team.viewer, team.owner.username).hits["member"] == []
    assert find(team, team.admin, team.owner.username).hits["member"]


def test_odd_cursors_are_refused(team: Any) -> None:
    for cursor in ("²", "99999999999999999999", "-1", "1.5"):
        with pytest.raises(ApiError):
            find(team, team.member, "x", cursor=cursor)


def test_active_projects_list_before_archived_ones(team: Any) -> None:
    from infrastructure.projects import services as projects

    old = team.create(team.owner, "OLD", name="Alpha old")
    team.create(team.owner, "NEW", name="Alpha new")
    projects.archive(team.owner, team.ws, str(old.pk), old.version)

    assert [h.key for h in find(team, team.member, "alpha").hits["project"]] == ["NEW", "OLD"]
