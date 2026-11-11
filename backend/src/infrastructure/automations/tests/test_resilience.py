"""Crashed runs are retried a few times; the clock command; the permission ceiling; paging."""

from datetime import timedelta
from io import StringIO
from typing import Any

import pytest
from django.core.management import call_command
from django.utils import timezone

from infrastructure.automations import due, engine, services
from infrastructure.automations.models import AutomationRun, RunStatus
from infrastructure.automations.tests.conftest import (
    comment_action,
    make_rule,
    make_task,
)
from infrastructure.comments.models import Comment
from infrastructure.common.errors import ApiError
from infrastructure.tasks import services as tasks
from infrastructure.workspaces import roles
from infrastructure.workspaces.models import WorkspaceMember


def _crash(monkeypatch: pytest.MonkeyPatch) -> None:
    def boom(*args: Any, **kwargs: Any) -> Any:
        raise RuntimeError("worker died")

    monkeypatch.setattr(engine, "evaluate", boom)


def _age(run: AutomationRun, minutes: int = 10) -> None:
    AutomationRun.objects.filter(pk=run.pk).update(
        started_at=timezone.now() - timedelta(minutes=minutes)
    )


def _only_run() -> AutomationRun:
    return AutomationRun.objects.get()


# ------------------------------------------------------------------------- crashed runs


def test_a_crashed_run_is_retried_in_place_and_does_its_work_once(
    team: Any, web: Any, monkeypatch: pytest.MonkeyPatch
) -> None:
    make_rule(team, web, {"type": "task_created"}, [comment_action("hi")])
    with monkeypatch.context() as patch:
        _crash(patch)
        make_task(team, web)
    crashed = _only_run()
    assert crashed.status == RunStatus.FAILED and crashed.finished_at is None
    assert not Comment.objects.exists()
    _age(crashed)

    assert due.retry_crashed() == 1

    run = _only_run()  # the same row: the (rule, task, event) constraint keeps it one
    assert run.pk == crashed.pk and run.attempts == 2
    assert run.status == RunStatus.SUCCEEDED and run.finished_at is not None
    assert Comment.objects.count() == 1
    assert due.retry_crashed() == 0
    assert Comment.objects.count() == 1


def test_a_run_that_died_before_finishing_is_retried_too(team: Any, web: Any) -> None:
    rule = make_rule(team, web, {"type": "task_created"}, [comment_action("hi")])
    task = make_task(team, web)
    AutomationRun.objects.all().delete()
    event = {"type": "task_created", "id": "task:x", "task_id": str(task.pk), "depth": 0}
    run = engine._begin(rule, task, event)  # noqa: SLF001 -- the process died right after this
    assert run is not None and run.error == engine.DID_NOT_FINISH
    _age(run)

    assert due.retry_crashed() == 1

    assert _only_run().status == RunStatus.SUCCEEDED


def test_a_recent_unfinished_run_is_left_alone(
    team: Any, web: Any, monkeypatch: pytest.MonkeyPatch
) -> None:
    make_rule(team, web, {"type": "task_created"}, [comment_action()])
    _crash(monkeypatch)
    make_task(team, web)

    assert due.retry_crashed() == 0
    assert _only_run().attempts == 1


def test_a_run_that_failed_a_step_is_not_retried(team: Any, web: Any) -> None:
    make_rule(
        team,
        web,
        {"type": "task_created"},
        [{"type": "webhook", "url": "http://example.invalid/x"}],
    )
    make_task(team, web)
    run = _only_run()
    assert run.status == RunStatus.FAILED and run.finished_at is not None
    _age(run)

    assert due.retry_crashed() == 0
    assert _only_run().attempts == 1


def test_retries_are_bounded_and_the_last_one_says_so(
    team: Any, web: Any, monkeypatch: pytest.MonkeyPatch
) -> None:
    make_rule(team, web, {"type": "task_created"}, [comment_action()])
    _crash(monkeypatch)
    make_task(team, web)

    for _ in range(engine.MAX_ATTEMPTS + 2):
        _age(_only_run())
        due.retry_crashed()

    run = _only_run()
    assert run.attempts == engine.MAX_ATTEMPTS
    assert run.status == RunStatus.FAILED and run.finished_at is not None
    assert f"{engine.MAX_ATTEMPTS} tries" in run.error
    assert not Comment.objects.exists()


def test_a_retry_for_a_switched_off_rule_or_deleted_task_fails_it_cleanly(
    team: Any, web: Any, monkeypatch: pytest.MonkeyPatch
) -> None:
    rule = make_rule(team, web, {"type": "task_created"}, [comment_action()])
    _crash(monkeypatch)
    make_task(team, web)
    monkeypatch.undo()
    services.toggle(team.owner, team.ws, str(web.pk), str(rule.pk), False)
    _age(_only_run())

    due.retry_crashed()

    run = _only_run()
    assert run.finished_at is not None and "switched off" in run.error
    assert not Comment.objects.exists()


def test_the_queue_refusing_a_retry_does_not_use_up_an_attempt(
    team: Any, web: Any, monkeypatch: pytest.MonkeyPatch
) -> None:
    from infrastructure.automations import queue

    make_rule(team, web, {"type": "task_created"}, [comment_action()])
    with monkeypatch.context() as patch:
        _crash(patch)
        make_task(team, web)
    _age(_only_run())
    monkeypatch.setattr(queue, "run_later", lambda *a, **k: False)

    assert due.retry_crashed() == 0
    assert _only_run().attempts == 1


# --------------------------------------------------------------------- the clock command


def test_the_tick_command_retries_crashed_runs_and_prunes_and_reports(
    team: Any, web: Any, monkeypatch: pytest.MonkeyPatch
) -> None:
    make_rule(team, web, {"type": "task_created"}, [comment_action()])
    with monkeypatch.context() as patch:
        _crash(patch)
        make_task(team, web)
    _age(_only_run())
    out = StringIO()

    call_command("automations_tick", stdout=out)

    assert "retried 1" in out.getvalue() and "queued 0" in out.getvalue()
    assert _only_run().status == RunStatus.SUCCEEDED


def test_the_tick_command_fires_due_rules_and_prunes_old_runs(team: Any, web: Any) -> None:
    rule = make_rule(
        team, web, {"type": "due_date_reached", "days_before": 0}, [comment_action("due")]
    )
    make_task(team, web, due_date=timezone.now().date().isoformat())
    old = AutomationRun.objects.create(
        automation=rule,
        workspace=team.ws,
        task=None,
        event_key="old",
        status=RunStatus.SUCCEEDED,
        started_at=timezone.now() - timedelta(days=60),
        finished_at=timezone.now() - timedelta(days=60),
    )
    out = StringIO()

    call_command("automations_tick", stdout=out)

    text = out.getvalue()
    assert "queued 1" in text and "pruned 1" in text
    assert not AutomationRun.objects.filter(pk=old.pk).exists()
    assert Comment.objects.count() == 1
    out2 = StringIO()
    call_command("automations_tick", stdout=out2)  # once per task and due date
    assert "queued 0" in out2.getvalue()


# ----------------------------------------------------------------- the permission ceiling


def test_an_owner_who_lost_task_update_keeps_the_rule_but_the_step_fails_with_the_reason(
    team: Any, web: Any
) -> None:
    role = roles.create_role(
        team.ws, team.owner, "Rule keeper", ["workspace.view", "automation.manage"]
    )
    WorkspaceMember.objects.filter(workspace=team.ws, user=team.admin).update(role_id=role.role.pk)
    rule = make_rule(
        team,
        web,
        {"type": "task_created"},
        [{"type": "set_field", "field": "priority", "value": "urgent"}],
        actor=team.admin,
    )
    assert engine.owner_problem(rule) == ""  # the owner still holds automation.manage

    task = make_task(team, web)

    run = AutomationRun.objects.get(automation=rule)
    assert run.status == RunStatus.FAILED and run.finished_at is not None
    assert "Step 1" in run.error and run.steps[0]["status"] == "failed"
    assert tasks.get(team.owner, team.ws, str(web.pk), str(task.pk)).priority == "none"


# ------------------------------------------------------------------------------- paging


def test_run_paging_is_stable_when_runs_share_a_start_time(team: Any, web: Any) -> None:
    rule = make_rule(team, web, {"type": "task_created"}, [comment_action()])
    for _ in range(5):
        make_task(team, web)
    same = timezone.now()
    AutomationRun.objects.update(started_at=same)

    seen: list[str] = []
    cursor = ""
    for _ in range(5):
        page = services.list_runs(
            team.owner, team.ws, str(web.pk), str(rule.pk), before=cursor, limit=2
        )
        if not page:
            break
        seen += [str(r.pk) for r in page]
        last = page[-1]
        cursor = f"{last.started_at.isoformat()}#{last.pk}"

    assert len(seen) == 5 and len(set(seen)) == 5


def test_a_plain_time_still_pages_and_a_bad_cursor_is_refused(team: Any, web: Any) -> None:
    make_rule(team, web, {"type": "task_created"}, [comment_action()])
    make_task(team, web)
    (run,) = AutomationRun.objects.all()
    later = (run.started_at + timedelta(seconds=1)).isoformat()

    assert len(services.list_runs(team.owner, team.ws, str(web.pk), before=later)) == 1
    for bad in ("nonsense", f"{run.started_at.isoformat()}#not-a-uuid"):
        with pytest.raises(ApiError):
            services.list_runs(team.owner, team.ws, str(web.pk), before=bad)
