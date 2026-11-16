from datetime import timedelta
from typing import Any

import pytest
from django.utils import timezone

from infrastructure.automations import due, engine, integrity, services, spec
from infrastructure.automations.models import Automation, AutomationRun, RunStatus
from infrastructure.automations.tests.conftest import (
    add_status,
    comment_action,
    date_field,
    drop_status,
    edit,
    make_rule,
    make_task,
    status_of,
)
from infrastructure.comments.models import Comment
from infrastructure.common.errors import ApiError
from infrastructure.customfields import values as custom
from infrastructure.inbox.models import Notification
from infrastructure.tasks import services as tasks
from infrastructure.workspaces import members
from infrastructure.workspaces.access import PermissionDenied, builtin_role
from infrastructure.workspaces.models import WorkspaceMember


def to_status(project: Any, name: str) -> dict[str, Any]:
    return {"type": "status_changed", "to_status": str(status_of(project, name).pk)}


def runs(rule: Any) -> list[AutomationRun]:
    return list(AutomationRun.objects.filter(automation=rule).order_by("started_at"))


# ---------------------------------------------------------------- the headline behaviours


def test_status_to_done_sets_the_completion_date_and_notifies_the_assignee(
    team: Any, web: Any
) -> None:
    done_on = date_field(team, web)
    rule = make_rule(
        team,
        web,
        to_status(web, "Done"),
        [
            {"type": "set_field", "field": f"field:{done_on.pk}", "value": "{today}"},
            {"type": "notify", "to": ["assignees"], "message": "{key} is done"},
        ],
    )
    task = make_task(team, web, assignee_ids=[str(team.member.pk)])

    edit(team, web, task, status=str(status_of(web, "Done").pk))

    fresh = tasks.get(team.owner, team.ws, str(web.pk), str(task.pk))
    assert custom.current(fresh, str(done_on.pk)) == timezone.now().date().isoformat()
    note = Notification.objects.get(user=team.member, type="automation.notice")
    assert note.payload["message"] == "WEB-1 is done" and note.payload["automation"] == "Rule"
    (run,) = runs(rule)
    assert run.status == RunStatus.SUCCEEDED
    assert [s["status"] for s in run.steps] == ["ok", "ok"]
    assert run.input["task"]["key"] == "WEB-1"


def test_a_rule_that_triggers_itself_stops_at_the_chain_limit(team: Any, web: Any) -> None:
    rule = make_rule(
        team,
        web,
        {"type": "field_changed", "field": "priority"},
        [{"type": "set_field", "field": "priority", "value": "high"}],
    )
    task = make_task(team, web)

    edit(team, web, task, priority="low")

    found = runs(rule)
    assert [r.status for r in found] == [RunStatus.SUCCEEDED] * 5 + [RunStatus.SKIPPED_LOOP]
    assert [r.depth for r in found] == [0, 1, 2, 3, 4, 5]
    assert "loop" in found[-1].explanation


def test_two_rules_that_trigger_each_other_terminate(team: Any, web: Any) -> None:
    a = make_rule(
        team,
        web,
        {"type": "field_changed", "field": "priority"},
        [{"type": "set_field", "field": "start_date", "value": "{today}"}],
        name="A",
    )
    b = make_rule(
        team,
        web,
        {"type": "field_changed", "field": "start_date"},
        [{"type": "set_field", "field": "priority", "value": "urgent"}],
        name="B",
    )
    task = make_task(team, web)

    edit(team, web, task, priority="low")

    total = AutomationRun.objects.filter(automation__in=[a, b])
    assert total.filter(status=RunStatus.SKIPPED_LOOP).count() == 1
    assert total.count() == 6


def test_a_dry_run_shows_the_exact_changes_and_applies_nothing(team: Any, web: Any) -> None:
    task = make_task(team, web, "Fix")
    rule = make_rule(
        team,
        web,
        {"type": "task_created"},
        [
            {"type": "set_field", "field": "priority", "value": "urgent"},
            {"type": "set_status", "status": str(status_of(web, "In progress").pk)},
            comment_action("hi {title}"),
            {"type": "create_subtask", "title": "Follow up"},
            {"type": "notify", "to": ["owner"], "message": "x"},
        ],
    )
    before = tasks.get(team.owner, team.ws, str(web.pk), str(task.pk))

    out = services.dry_run(team.owner, team.ws, str(web.pk), str(rule.pk), str(task.pk))

    assert out.would_run and out.status == RunStatus.SUCCEEDED
    assert out.steps[0]["changes"] == [{"field": "priority", "from": "none", "to": "urgent"}]
    assert out.steps[1]["changes"] == [{"field": "status", "from": "To do", "to": "In progress"}]
    assert out.steps[2]["detail"] == "hi Fix"
    assert {s["status"] for s in out.steps} == {"planned"}
    after = tasks.get(team.owner, team.ws, str(web.pk), str(task.pk))
    assert (after.version, after.priority, after.status_id) == (
        before.version,
        before.priority,
        before.status_id,
    )
    assert not Comment.objects.filter(kind="user").exists() and not AutomationRun.objects.exists()
    assert tasks.list_children(team.owner, team.ws, str(web.pk), str(task.pk)) == []
    assert not Notification.objects.filter(type="automation.notice").exists()


def test_a_dry_run_says_what_would_fail_and_why_not_run(team: Any, web: Any) -> None:
    rule = make_rule(
        team, web, {"type": "task_created"}, [comment_action()], condition="priority = high"
    )
    task = make_task(team, web)

    out = services.dry_run(team.owner, team.ws, str(web.pk), str(rule.pk), str(task.pk))

    assert not out.would_run and out.status == RunStatus.SKIPPED_CONDITION
    assert "priority = high" in out.explanation.lower().replace('"', "")


def test_deleting_a_used_status_disables_the_rule_and_tells_the_owner(team: Any, web: Any) -> None:
    review = add_status(team, web, "Review")
    rule = make_rule(
        team, web, {"type": "status_changed", "to_status": str(review.pk)}, [comment_action()]
    )

    drop_status(team, web, "Review")

    rule.refresh_from_db()
    assert not rule.enabled and "status" in rule.disabled_reason
    note = Notification.objects.get(user=team.owner, type="automation.disabled")
    assert note.payload["automation"] == "Rule" and "status" in note.payload["reason"]
    with pytest.raises(ApiError, match="Fix the rule first"):
        services.toggle(team.owner, team.ws, str(web.pk), str(rule.pk), True)


def test_removing_a_named_assignee_disables_the_rule(team: Any, web: Any) -> None:
    rule = make_rule(
        team,
        web,
        {"type": "task_created"},
        [{"type": "set_assignee", "mode": "set", "user_ids": [str(team.member.pk)]}],
    )

    members.remove(team.ws, team.owner, str(team.member.pk))

    rule.refresh_from_db()
    assert not rule.enabled
    assert Notification.objects.filter(user=team.owner, type="automation.disabled").exists()


def test_archiving_a_used_custom_field_disables_the_rule(team: Any, web: Any) -> None:
    from infrastructure.customfields import services as fields

    field = date_field(team, web)
    rule = make_rule(
        team,
        web,
        {"type": "task_created"},
        [{"type": "set_field", "field": f"field:{field.pk}", "value": "{today}"}],
    )

    fields.archive(team.owner, team.ws, str(web.pk), str(field.pk), field.version)

    rule.refresh_from_db()
    assert not rule.enabled and "custom field" in rule.disabled_reason


def test_the_same_event_never_runs_a_rule_twice(team: Any, web: Any) -> None:
    rule = make_rule(
        team, web, {"type": "comment_added"}, [{"type": "create_subtask", "title": "S"}]
    )
    task = make_task(team, web)
    event = {"type": "comment_added", "id": "comment:1", "task_id": str(task.pk), "depth": 0}

    first = engine.execute(rule.pk, event)
    again = engine.execute(rule.pk, event)

    assert first is not None and again is None
    assert len(runs(rule)) == 1
    assert len(tasks.list_children(team.owner, team.ws, str(web.pk), str(task.pk))) == 1


def test_the_owner_losing_the_permission_fails_the_run_with_a_reason(team: Any, web: Any) -> None:
    rule = make_rule(
        team,
        web,
        {"type": "task_created"},
        [{"type": "set_field", "field": "priority", "value": "urgent"}],
        actor=team.admin,
    )
    WorkspaceMember.objects.filter(workspace=team.ws, user=team.admin).update(
        role=builtin_role("Viewer")
    )

    task = make_task(team, web)

    (run,) = runs(rule)
    assert run.status == RunStatus.FAILED and "automation.manage" in run.error
    assert tasks.get(team.owner, team.ws, str(web.pk), str(task.pk)).priority == "none"


def test_a_removed_owner_fails_the_run(team: Any, web: Any) -> None:
    rule = make_rule(team, web, {"type": "task_created"}, [comment_action()], actor=team.admin)
    members.remove(team.ws, team.owner, str(team.admin.pk))

    make_task(team, web)

    (run,) = runs(rule)
    assert run.status == RunStatus.FAILED and "no longer a member" in run.error
    assert not Comment.objects.filter(kind="user").exists()


def test_a_run_is_refused_when_the_project_is_archived(team: Any, web: Any) -> None:
    from infrastructure.projects import services as projects

    rule = make_rule(team, web, {"type": "task_created"}, [comment_action()], actor=team.admin)
    version = projects.get(team.owner, team.ws, str(web.pk)).project.version
    projects.archive(team.owner, team.ws, str(web.pk), version)

    assert "archived" in engine.owner_problem(Automation.objects.get(pk=rule.pk))


def test_editing_or_switching_on_a_rule_makes_the_editor_its_owner(team: Any, web: Any) -> None:
    rule = make_rule(team, web, {"type": "task_created"}, [comment_action()], actor=team.admin)

    updated = services.update(
        team.owner, team.ws, str(web.pk), str(rule.pk), {"name": "New"}, rule.version
    ).automation
    assert updated.owner_id == team.owner.pk and updated.version == rule.version + 1
    with pytest.raises(ApiError) as conflict:
        services.update(team.owner, team.ws, str(web.pk), str(rule.pk), {"name": "X"}, rule.version)
    assert conflict.value.status == 409

    services.toggle(team.owner, team.ws, str(web.pk), str(rule.pk), False)
    back = services.toggle(team.admin, team.ws, str(web.pk), str(rule.pk), True).automation
    assert back.enabled and back.owner_id == team.admin.pk


# ------------------------------------------------------------------ conditions and triggers


def test_a_tfql_condition_decides_whether_actions_run(team: Any, web: Any) -> None:
    rule = make_rule(
        team,
        web,
        {"type": "field_changed", "field": "title"},
        [comment_action("matched")],
        condition="priority = high AND title ~ Bug",
    )
    task = make_task(team, web, "Bug one")

    edit(team, web, task, title="Bug two")
    (skipped,) = runs(rule)
    assert skipped.status == RunStatus.SKIPPED_CONDITION
    assert "priority" in skipped.explanation and "title" not in skipped.explanation.split(":")[0]
    assert not Comment.objects.filter(kind="user").exists()

    edit(team, web, task, priority="high")
    edit(team, web, task, title="Bug three")
    assert runs(rule)[-1].status == RunStatus.SUCCEEDED
    assert Comment.objects.filter(kind="user").count() == 1


def test_a_condition_that_does_not_parse_is_refused(team: Any, web: Any) -> None:
    with pytest.raises(ApiError, match="condition"):
        make_rule(team, web, {"type": "task_created"}, [comment_action()], condition="nope = 1")


def test_each_trigger_fires_on_its_own_event_only(team: Any, web: Any) -> None:
    done = str(status_of(web, "Done").pk)
    created = make_rule(team, web, {"type": "task_created"}, [comment_action("c")], name="created")
    to_done = make_rule(
        team, web, {"type": "status_changed", "to_status": done}, [comment_action("d")], name="done"
    )
    any_status = make_rule(team, web, {"type": "status_changed"}, [comment_action("s")], name="any")
    prio = make_rule(
        team,
        web,
        {"type": "field_changed", "field": "priority"},
        [comment_action("p")],
        name="prio",
    )
    assigned = make_rule(
        team,
        web,
        {"type": "assigned", "user_id": str(team.member.pk)},
        [comment_action("a")],
        name="assigned",
    )
    commented = make_rule(
        team,
        web,
        {"type": "comment_added"},
        [{"type": "notify", "to": ["owner"], "message": "k"}],
        name="comment",
    )

    task = make_task(team, web)
    assert [len(runs(r)) for r in (created, to_done, any_status, prio, assigned)] == [1, 0, 0, 0, 0]

    edit(team, web, task, priority="low")
    assert len(runs(prio)) == 1 and len(runs(to_done)) == 0

    edit(team, web, task, assignee_ids=[str(team.viewer.pk)])
    assert len(runs(assigned)) == 0
    edit(team, web, task, assignee_ids=[str(team.member.pk)])
    assert len(runs(assigned)) == 1

    edit(team, web, task, status=str(status_of(web, "In progress").pk))
    assert (len(runs(any_status)), len(runs(to_done))) == (1, 0)
    edit(team, web, task, status=done)
    assert (len(runs(any_status)), len(runs(to_done))) == (2, 1)

    assert len(runs(commented)) >= 1  # the rules' own comments are comments too


def test_spec_matches_and_explains() -> None:
    assert spec.matches(
        {"type": "field_changed", "field": "due_date"}, "field_changed", {"fields": ["due_date"]}
    )
    assert not spec.matches(
        {"type": "field_changed", "field": "due_date"}, "field_changed", {"fields": ["title"]}
    )
    assert not spec.matches({"type": "task_created"}, "comment_added", {})
    assert "waits for" in spec.explain_mismatch({"type": "task_created"}, "comment_added")
    assert "different status" in spec.explain_mismatch({"type": "status_changed"}, "status_changed")


def test_due_date_rules_fire_once_per_task_and_due_date(team: Any, web: Any) -> None:
    rule = make_rule(
        team, web, {"type": "due_date_reached", "days_before": 1}, [comment_action("due")]
    )
    today = timezone.now().date()
    soon = make_task(team, web, "soon", due_date=(today + timedelta(days=1)).isoformat())
    make_task(team, web, "later", due_date=(today + timedelta(days=5)).isoformat())
    make_task(team, web, "none")

    assert due.scan_due() == 1
    assert due.scan_due() == 0
    (run,) = runs(rule)
    assert run.task_id == soon.pk and run.status == RunStatus.SUCCEEDED
    edit(team, web, soon, status=str(status_of(web, "Done").pk))
    assert due.scan_due() == 0


# ------------------------------------------------------------------------------- guards


def test_a_rule_that_runs_too_often_is_stopped(team: Any, web: Any) -> None:
    rule = make_rule(
        team, web, {"type": "comment_added"}, [{"type": "create_subtask", "title": "s"}]
    )
    task = make_task(team, web)
    for n in range(engine.RATE_PER_MINUTE):
        engine.execute(
            rule.pk, {"type": "comment_added", "id": f"c{n}", "task_id": str(task.pk), "depth": 0}
        )

    over = engine.execute(
        rule.pk, {"type": "comment_added", "id": "last", "task_id": str(task.pk), "depth": 0}
    )

    assert over is not None and over.status == RunStatus.SKIPPED_RATE


def test_a_failing_action_is_recorded_and_the_rest_is_not_run(team: Any, web: Any) -> None:
    rule = make_rule(
        team,
        web,
        {"type": "task_created"},
        [{"type": "webhook", "url": "http://example.invalid/x"}, comment_action()],
    )

    make_task(team, web)

    (run,) = runs(rule)
    assert run.status == RunStatus.FAILED and run.error.startswith("Step 1 (webhook)")
    assert [s["status"] for s in run.steps] == ["failed", "not_run"]
    assert not Comment.objects.filter(kind="user").exists()


def test_rules_have_limits(team: Any, web: Any) -> None:
    with pytest.raises(ApiError, match="at least one action"):
        make_rule(team, web, {"type": "task_created"}, [])
    with pytest.raises(ApiError, match="at most"):
        make_rule(team, web, {"type": "task_created"}, [comment_action()] * (spec.MAX_ACTIONS + 1))
    with pytest.raises(ApiError, match="trigger"):
        make_rule(team, web, {"type": "bogus"}, [comment_action()])
    with pytest.raises(ApiError, match="no option"):
        make_rule(team, web, {"type": "task_created", "x": 1}, [comment_action()])
    with pytest.raises(ApiError, match="status"):
        make_rule(team, web, {"type": "task_created"}, [{"type": "set_status", "status": "nope"}])
    with pytest.raises(ApiError, match="today"):
        make_rule(
            team,
            web,
            {"type": "task_created"},
            [{"type": "set_field", "field": "priority", "value": "{today}"}],
        )
    for n in range(services.MAX_PER_PROJECT):
        Automation.objects.create(
            workspace=team.ws,
            project=web,
            name=f"r{n}",
            trigger={"type": "task_created"},
            actions=[],
        )
    with pytest.raises(ApiError, match="at most"):
        make_rule(team, web, {"type": "task_created"}, [comment_action()])


def test_old_runs_are_pruned(team: Any, web: Any, monkeypatch: pytest.MonkeyPatch) -> None:
    rule = make_rule(team, web, {"type": "task_created"}, [comment_action()])
    task = make_task(team, web)
    old = AutomationRun.objects.create(
        automation=rule,
        workspace=team.ws,
        task=task,
        event_key="old",
        status="succeeded",
        started_at=timezone.now() - timedelta(days=due.RETENTION_DAYS + 1),
    )
    assert due.prune_runs() == 1
    assert not AutomationRun.objects.filter(pk=old.pk).exists()
    monkeypatch.setattr(due, "KEEP_PER_RULE", 0)
    assert due.prune_runs() == 1
    assert not AutomationRun.objects.exists()


def test_integrity_check_leaves_a_whole_rule_alone(team: Any, web: Any) -> None:
    rule = make_rule(team, web, {"type": "task_created"}, [comment_action()])
    assert integrity.check_project(web.pk) == 0
    rule.refresh_from_db()
    assert rule.enabled


# ------------------------------------------------------------------------ tenant isolation


def test_a_rule_never_touches_a_task_of_another_project(team: Any, web: Any, other: Any) -> None:
    rule = make_rule(team, web, {"type": "task_created"}, [comment_action()])
    foreign = make_task(team, other, "foreign")
    AutomationRun.objects.all().delete()
    Comment.objects.all().delete()

    got = engine.execute(
        rule.pk, {"type": "task_created", "id": "x", "task_id": str(foreign.pk), "depth": 0}
    )

    assert got is None and not AutomationRun.objects.exists() and not Comment.objects.filter(kind="user").exists()
    assert not AutomationRun.objects.filter(automation=rule).exists()


def test_rules_and_runs_are_invisible_across_projects_and_workspaces(
    team: Any, web: Any, other: Any
) -> None:
    rule = make_rule(team, web, {"type": "task_created"}, [comment_action()])
    make_task(team, web)
    run = runs(rule)[0]
    secret = team.create(team.pm, "SEC", visibility="private")

    for call in (
        lambda: services.get_view(team.owner, team.ws, str(other.pk), str(rule.pk)),
        lambda: services.toggle(team.owner, team.ws, str(other.pk), str(rule.pk), False),
        lambda: services.delete(team.owner, team.ws, str(other.pk), str(rule.pk)),
        lambda: services.get_run(team.owner, team.ws, str(other.pk), str(run.pk)),
        lambda: services.list_runs(team.owner, team.ws, str(other.pk), str(rule.pk)),
        lambda: services.dry_run(team.owner, team.ws, str(other.pk), str(rule.pk), "x"),
        lambda: services.list_automations(team.admin, team.ws, str(secret.pk)),
    ):
        with pytest.raises(ApiError) as refused:
            call()
        assert refused.value.status == 404
    assert services.list_automations(team.owner, team.ws, str(other.pk)) == []
    # a member of another workspace, using their own workspace with our project id, finds nothing
    with pytest.raises(ApiError) as foreign:
        services.list_automations(team.outsider, team.other_ws, str(web.pk))
    assert foreign.value.status == 404
    with pytest.raises(ApiError) as outsider:
        services.list_automations(team.outsider, team.ws, str(web.pk))
    assert outsider.value.status == 403


def test_only_those_with_the_permission_change_rules(team: Any, web: Any) -> None:
    rule = make_rule(team, web, {"type": "task_created"}, [comment_action()])
    for who in (team.member, team.viewer):
        with pytest.raises(PermissionDenied):
            make_rule(team, web, {"type": "task_created"}, [comment_action()], actor=who)
        with pytest.raises(PermissionDenied):
            services.toggle(who, team.ws, str(web.pk), str(rule.pk), False)
        with pytest.raises(PermissionDenied):
            services.dry_run(who, team.ws, str(web.pk), str(rule.pk), "x")
    # everyone who can open the project can read
    assert len(services.list_automations(team.viewer, team.ws, str(web.pk))) == 1
    assert len(services.list_runs(team.viewer, team.ws, str(web.pk))) == 0
    services.delete(team.admin, team.ws, str(web.pk), str(rule.pk))
    assert not Automation.objects.exists()


def test_run_listing_filters_and_pages(team: Any, web: Any) -> None:
    rule = make_rule(
        team, web, {"type": "task_created"}, [comment_action()], condition="priority = high"
    )
    for _ in range(3):
        make_task(team, web)

    every = services.list_runs(team.owner, team.ws, str(web.pk), str(rule.pk))
    assert len(every) == 3 and every[0].started_at >= every[-1].started_at
    assert len(services.list_runs(team.owner, team.ws, str(web.pk), limit=2)) == 2
    older = services.list_runs(
        team.owner, team.ws, str(web.pk), before=every[0].started_at.isoformat()
    )
    assert len(older) == 2
    assert services.list_runs(team.owner, team.ws, str(web.pk), status="failed") == []
    with pytest.raises(ApiError):
        services.list_runs(team.owner, team.ws, str(web.pk), status="bogus")
    one = services.get_run(team.owner, team.ws, str(web.pk), str(every[0].pk))
    assert one.explanation.startswith("The task does not meet")
    views = services.list_automations(team.owner, team.ws, str(web.pk))
    assert views[0].last_run_status == RunStatus.SKIPPED_CONDITION
    assert views[0].condition_tfql == "priority = high"


# ----------------------------------------------------------------------------- the actions


def test_the_other_actions_do_their_work_as_the_rule(team: Any, web: Any) -> None:
    rule = make_rule(
        team,
        web,
        {"type": "field_changed", "field": "priority"},
        [
            {"type": "set_assignee", "mode": "set", "user_ids": [str(team.member.pk)]},
            {"type": "set_status", "status": str(status_of(web, "In progress").pk)},
            comment_action("{key} -> {status}"),
            {"type": "create_subtask", "title": "Check {title}"},
            {"type": "notify", "to": [str(team.viewer.pk), "creator"], "message": "m"},
        ],
        name="Triage",
    )

    task = make_task(team, web, "Fix")

    edit(team, web, task, priority="low")

    fresh = tasks.get(team.owner, team.ws, str(web.pk), str(task.pk))
    assert [str(u) for u in fresh.assignee_ids()] == [str(team.member.pk)]
    assert fresh.status.name == "In progress"
    text = Comment.objects.get(kind="user").body["content"][0]["content"][0]["text"]
    assert text == "[Automation: Triage] WEB-1 -> In progress"
    (child,) = tasks.list_children(team.owner, team.ws, str(web.pk), str(task.pk))
    assert child.title == "Check Fix"
    assert Notification.objects.filter(type="automation.notice", user=team.viewer).exists()
    (run,) = runs(rule)
    assert run.status == RunStatus.SUCCEEDED and len(run.steps) == 5
