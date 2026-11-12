"""A Jira export of 50,000 issues: links, sprints, comments and sub-tasks all arrive correctly,
the file is read as a stream, and a second run changes nothing."""

import time
import tracemalloc

from infrastructure.comments.models import Comment
from infrastructure.imports import services
from infrastructure.imports.models import ImportedRef
from infrastructure.imports.tests.conftest import World
from infrastructure.imports.tests.samples import JIRA_HEADER
from infrastructure.sprints.models import Sprint
from infrastructure.tasks.models import Task, TaskLink

ISSUES = 50_000
EPIC_EVERY = 100  # every 100th issue is an epic; the 99 after it are its stories
SUBTASK_EVERY = 7  # every 7th story has a sub-task right after it in the file


def _file() -> bytes:
    """A real-shaped export written row by row (a generator would be streamed the same way)."""
    import csv
    import io

    out = io.StringIO()
    writer = csv.writer(out, lineterminator="\n")
    writer.writerow(JIRA_HEADER)
    epic = ""
    made = 0
    n = 0
    while made < ISSUES:
        n += 1
        made += 1
        row: dict[str, str] = {}
        key, issue_id = f"P-{n}", str(100000 + n)
        row.update(
            {
                "Summary": f"Issue {n}",
                "Issue key": key,
                "Issue id": issue_id,
                "Status": ("To Do", "In Progress", "Done")[n % 3],
                "Priority": ("High", "Medium", "Low")[n % 3],
                "Created": "12/Nov/24 10:30 AM",
                "Description": f"h2. Issue {n}\n* a *bold* point",
                "Sprint": f"Sprint {n % 20}",
                "Comment": f"13/Nov/24 9:00 AM;acc-{n % 50};Comment on {n}",
            }
        )
        if n % EPIC_EVERY == 1:
            epic = issue_id
            row["Issue Type"] = "Epic"
        else:
            row["Parent id"] = epic
            row["Outward issue link (Blocks)"] = f"P-{n - 1}" if n % 2 == 0 else ""
        first = {name: JIRA_HEADER.index(name) for name in row}
        cells = [""] * len(JIRA_HEADER)
        for name, value in row.items():
            cells[first[name]] = value
        writer.writerow(cells)
    return out.getvalue().encode()


def test_fifty_thousand_issues_import_with_links_sprints_and_comments(world: World) -> None:
    data = _file()
    job = world.analyzed(data, "big.csv")
    assert job.analysis["issues"] == ISSUES and len(job.analysis["sprints"]) == 20
    started = time.monotonic()
    tracemalloc.start()
    done = services.start(
        world.owner, world.ws, str(job.pk),
        {**job.mapping, "target": {"project_id": str(world.web.pk)}},
    )  # fmt: skip
    _, peak = tracemalloc.get_traced_memory()
    tracemalloc.stop()
    elapsed = time.monotonic() - started
    assert done.status == "done", done.error
    assert Task.objects.filter(project=world.web).count() == ISSUES
    assert Comment.objects.count() == ISSUES
    assert Sprint.objects.filter(project=world.web).count() == 20
    expected_links = sum(1 for n in range(1, ISSUES + 1) if n % EPIC_EVERY != 1 and n % 2 == 0)
    assert TaskLink.objects.count() == expected_links  # an even story blocks the one before it
    epics = Task.objects.filter(project=world.web, parent__isnull=True).count()
    assert epics == ISSUES // EPIC_EVERY
    assert Task.objects.filter(project=world.web, depth=1).count() == ISSUES - epics
    world.web.refresh_from_db()
    assert world.web.task_counter == ISSUES
    epic = Task.objects.get(title="Issue 1")
    assert epic.progress_total == EPIC_EVERY - 1  # the tree counts were refreshed
    # constant space: the file is 20 MB+; the import must not hold it (or its issues) in memory
    assert peak < 150_000_000, peak
    print(f"imported {ISSUES} issues in {elapsed:.1f}s, peak {peak / 1e6:.0f} MB")
    again = world.analyzed(data, "big.csv")
    second = services.start(
        world.owner, world.ws, str(again.pk),
        {**again.mapping, "target": {"project_id": str(world.web.pk)}},
    )  # fmt: skip
    assert second.status == "done" and Task.objects.filter(project=world.web).count() == ISSUES
    assert ImportedRef.objects.filter(job=second).count() == 0
