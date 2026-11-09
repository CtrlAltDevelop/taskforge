"""A 10,000-task project: the first page is fast and a page costs the same however big the
project is. (Wall-clock bound is generous; the query-count bound is the real guard.)"""

import time
from typing import Any

import pytest

from infrastructure.tasks import rank, services
from infrastructure.tasks.models import Task

pytestmark = pytest.mark.django_db

TOTAL = 10_000
FIRST_PAGE_BUDGET_SECONDS = 0.5


def _seed(team: Any, project: Any) -> None:
    position = None
    rows = []
    for number in range(1, TOTAL + 1):
        position = rank.after(position)
        rows.append(
            Task(
                workspace=team.ws,
                project=project,
                number=number,
                title=f"Task {number}",
                created_by=team.owner,
                position=position,
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
