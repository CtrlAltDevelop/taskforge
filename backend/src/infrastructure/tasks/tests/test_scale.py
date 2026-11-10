"""A 10,000-task project: the first page is fast and a page costs the same however big the
project is. (Wall-clock bound is generous; the query-count bound is the real guard.)"""

import time
import uuid
from typing import Any

import pytest

from infrastructure.tasks import rank, services, tree
from infrastructure.tasks.models import Task
from infrastructure.workflows import services as workflows

pytestmark = pytest.mark.django_db

TOTAL = 10_000
FIRST_PAGE_BUDGET_SECONDS = 0.5


def _seed(team: Any, project: Any) -> None:
    position = None
    rows = []
    status = workflows.default_status(project)
    for number in range(1, TOTAL + 1):
        position = rank.after(position)
        task_id = uuid.uuid4()
        rows.append(
            Task(
                id=task_id,
                workspace=team.ws,
                project=project,
                number=number,
                title=f"Task {number}",
                status=status,
                created_by=team.owner,
                position=position,
                path=f"{task_id}/",
                tree_key=f"{position}{tree.SEP}",
            )
        )
    Task.objects.bulk_create(rows, batch_size=1000)


def test_first_page_of_a_ten_thousand_task_project_is_fast_and_bounded(
    team: Any, project: Any, django_assert_max_num_queries: Any
) -> None:
    _seed(team, project)
    pid = str(project.pk)

    started = time.perf_counter()
    with django_assert_max_num_queries(8):
        page, cursor = services.list_page(team.viewer, team.ws, pid)
    elapsed = time.perf_counter() - started

    assert len(page) == services.PAGE_DEFAULT and cursor
    assert elapsed < FIRST_PAGE_BUDGET_SECONDS


def test_walking_every_page_visits_each_task_once(team: Any, project: Any) -> None:
    _seed(team, project)
    seen = 0
    cursor = ""
    last_number = 0
    while True:
        page, cursor = services.list_page(
            team.viewer, team.ws, str(project.pk), cursor=cursor, limit=services.PAGE_MAX
        )
        assert len(page) <= services.PAGE_MAX
        for task in page:
            assert task.number > last_number
            last_number = task.number
        seen += len(page)
        if not cursor:
            break
    assert seen == TOTAL


ROOTS = 50
CHILDREN = 99  # per root: 50 * (1 + 99) = 5,000 tasks in a two-level tree


def _seed_tree(team: Any, project: Any) -> None:
    status = workflows.default_status(project)
    position = None
    number = 0
    rows = []
    for _ in range(ROOTS):
        position = rank.after(position)
        number += 1
        root = Task(
            id=uuid.uuid4(),
            workspace=team.ws,
            project=project,
            number=number,
            title=f"Root {number}",
            status=status,
            created_by=team.owner,
            position=position,
            path="",
            tree_key="",
            progress_total=CHILDREN,
        )
        root.path, root.tree_key = f"{root.id}/", f"{position}{tree.SEP}"
        rows.append(root)
        child_position = None
        for _ in range(CHILDREN):
            child_position = rank.after(child_position)
            number += 1
            child = Task(
                id=uuid.uuid4(),
                workspace=team.ws,
                project=project,
                number=number,
                title=f"Child {number}",
                status=status,
                created_by=team.owner,
                position=child_position,
                parent=root,
                depth=1,
            )
            child.path = f"{root.path}{child.id}/"
            child.tree_key = f"{root.tree_key}{child_position}{tree.SEP}"
            rows.append(child)
    Task.objects.bulk_create(rows, batch_size=1000)


def test_a_five_thousand_task_tree_lists_fast_and_in_tree_order(
    team: Any, project: Any, django_assert_max_num_queries: Any
) -> None:
    _seed_tree(team, project)
    pid = str(project.pk)

    started = time.perf_counter()
    with django_assert_max_num_queries(8):
        first, cursor = services.list_page(team.viewer, team.ws, pid, include_subtasks=True)
    elapsed = time.perf_counter() - started
    assert len(first) == services.PAGE_DEFAULT and cursor
    assert elapsed < FIRST_PAGE_BUDGET_SECONDS

    seen: list[Task] = list(first)
    while cursor:
        page, cursor = services.list_page(
            team.viewer, team.ws, pid, include_subtasks=True, cursor=cursor, limit=services.PAGE_MAX
        )
        seen += page
    assert len(seen) == ROOTS * (CHILDREN + 1)
    index = {t.pk: i for i, t in enumerate(seen)}
    assert all(t.parent_id is None or index[t.parent_id] < index[t.pk] for t in seen)
    # Each root is immediately followed by all of its own children before the next root.
    assert [t.depth for t in seen[: CHILDREN + 2]] == [0] + [1] * CHILDREN + [0]


def test_a_top_level_list_of_the_tree_returns_only_the_roots(team: Any, project: Any) -> None:
    _seed_tree(team, project)

    top, _ = services.list_page(team.viewer, team.ws, str(project.pk), limit=services.PAGE_MAX)

    assert len(top) == ROOTS and all(t.depth == 0 for t in top)
