"""ClickUp JSON corners and the background lane."""

import io
import json
import threading
from typing import Any

from django.test import override_settings

from infrastructure.imports import queue
from infrastructure.imports.parsers import clickup_json
from infrastructure.imports.records import Problem, RIssue


def _parse(payload: Any) -> list[Any]:
    return list(clickup_json.parse(io.BytesIO(json.dumps(payload).encode())))


def test_a_bare_list_with_bad_entries_reports_them_and_keeps_the_rest() -> None:
    out = _parse(["nope", {"name": "no id"}, {"id": "1", "name": "Fine"}])
    assert [type(o) for o in out] == [Problem, Problem, RIssue]
    assert out[2].title == "Fine"


def test_dependencies_and_related_tasks_become_links() -> None:
    task = {
        "id": "a",
        "name": "A",
        "dependencies": [
            {"task_id": "a", "depends_on": "b"},  # a waits on b
            {"task_id": "c", "depends_on": "a"},  # c waits on a
            {"task_id": "x", "depends_on": "y"},  # not about a
            "junk",
        ],
        "linked_tasks": [{"task_id": "a", "link_id": "d"}, {"task_id": "e", "link_id": "a"}, 5],
    }
    (issue,) = _parse({"tasks": [task]})
    kinds = sorted((link.kind, link.target_id) for link in issue.links)
    assert kinds == [("blocked_by", "b"), ("blocks", "c"), ("relates", "d"), ("relates", "e")]


def test_comments_attachments_estimate_and_priority_are_read() -> None:
    task = {
        "id": "a",
        "name": "A",
        "markdown_description": "**hi**",
        "priority": {"priority": "high"},
        "time_estimate": 3600000,
        "points": 3,
        "parent": "p",
        "tags": [{"name": "x"}, "y"],
        "assignees": [{"username": "ann", "email": "ann@x.test"}, "junk"],
        "creator": {"id": 7},
        "comments": [{"id": 1, "comment_text": "c", "user": {"username": "ann"}}, "junk"],
        "attachments": [{"title": "f.txt", "size": 5, "url": "u"}, "junk"],
    }
    (issue,) = _parse([task])
    assert issue.body_format == "md" and issue.priority == "high" and issue.parent_id == "p"
    assert issue.estimate_sec == 3600 and issue.labels == ("x", "y")
    assert [c.body for c in issue.comments] == ["c"]
    assert [(a.filename, a.size) for a in issue.attachments] == [("f.txt", 5)]
    assert len(issue.assignees) == 1


def test_a_plain_task_has_no_extras() -> None:
    (issue,) = _parse([{"id": "a", "name": "A", "priority": "low", "description": "d"}])
    assert issue.priority == "low" and issue.body_format == "text" and not issue.links


def test_a_job_runs_on_its_lane_and_a_failing_one_does_not_kill_it() -> None:
    done = threading.Event()
    with override_settings(IMPORTS_SYNC_RUN=False):
        queue.run_later(lambda: 1 / 0, lane="test-lane")  # logged, worker survives
        queue.run_later(done.set, lane="test-lane")
        assert done.wait(5)


def test_checklists_and_custom_fields_are_kept_in_the_body() -> None:
    task = {
        "id": "a",
        "name": "A",
        "text_content": "Intro",
        "checklists": [
            {"name": "Ship", "items": [{"name": "Test", "resolved": True}, {"name": "Tag"}]}
        ],
        "custom_fields": [{"name": "Client", "value": "Acme"}, {"name": "Empty", "value": None}],
    }
    (issue,) = _parse({"tasks": [task]})
    assert issue.body_format == "md"
    assert issue.body == (
        "Intro\n\n**Ship**\n- [x] Test\n- [ ] Tag\n**Custom fields**\n- Client: Acme"
    )
