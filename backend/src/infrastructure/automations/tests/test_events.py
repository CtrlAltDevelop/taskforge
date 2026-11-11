"""Rule and run changes are announced as content-free hints on the project's room."""

from typing import Any

import pytest

from infrastructure.automations import services
from infrastructure.automations.models import AutomationRun
from infrastructure.automations.tests.conftest import (
    add_status,
    comment_action,
    drop_status,
    edit,
    make_rule,
    make_task,
    status_of,
)
from infrastructure.sync.models import ChangeLog

pytestmark = pytest.mark.django_db


def events(web: Any) -> list[tuple[str, Any, int]]:
    rows = ChangeLog.objects.filter(entity_type="automation").order_by("id")
    assert all(str(r.project) == str(web.pk) for r in rows)
    return [(r.event_type, r.entity_id, r.version) for r in rows]


def test_creating_changing_and_deleting_a_rule_are_announced(team: Any, web: Any) -> None:
    trigger = {"type": "task_created"}
    rule = make_rule(team, web, trigger, [comment_action()])
    args = (team.owner, team.ws, str(web.pk), str(rule.pk))
    services.update(*args, {"name": "Renamed"}, 1)
    services.toggle(*args, False)
    services.delete(*args)

    assert events(web) == [
        ("automation.created", rule.pk, 1),
        ("automation.updated", rule.pk, 2),
        ("automation.updated", rule.pk, 3),
        ("automation.deleted", rule.pk, 3),
    ]


def test_a_run_is_announced_with_its_id_and_nothing_else(team: Any, web: Any) -> None:
    rule = make_rule(team, web, {"type": "task_created"}, [comment_action("Secret text")])
    make_task(team, web)

    (run,) = AutomationRun.objects.filter(automation=rule)
    kinds = [e for e in events(web) if e[0] == "automation.run"]
    assert kinds == [("automation.run", run.pk, 0)]
    row = ChangeLog.objects.filter(entity_type="automation", action="run").get()
    wire = row.as_event()
    assert "Secret text" not in str(wire) and wire["project"] == str(web.pk)


def test_a_rule_switched_off_by_integrity_is_announced(team: Any, web: Any) -> None:
    review = add_status(team, web, "Review")
    rule = make_rule(
        team, web, {"type": "status_changed", "to_status": str(review.pk)}, [comment_action()]
    )
    before = len(events(web))

    drop_status(team, web, "Review")

    rule.refresh_from_db()
    assert not rule.enabled
    assert events(web)[before:] == [("automation.updated", rule.pk, rule.version)]


def test_a_rule_that_does_not_fire_announces_no_run(team: Any, web: Any) -> None:
    make_rule(
        team,
        web,
        {"type": "status_changed", "to_status": str(status_of(web, "Done").pk)},
        [comment_action()],
    )
    task = make_task(team, web)
    edit(team, web, task, title="New title")

    assert not [e for e in events(web) if e[0] == "automation.run"]
