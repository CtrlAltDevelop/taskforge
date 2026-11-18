"""Phase 33 acceptance: linked key results follow their tasks (debounced), progress rolls up with
weights, ``goal.progress_changed`` is emitted and delivered, and goals respect owner/privacy."""

from datetime import timedelta
from decimal import Decimal
from typing import Any

import pytest
from django.utils import timezone

from infrastructure.common.errors import ApiError
from infrastructure.developer import delivery
from infrastructure.developer.models import Webhook, WebhookDelivery
from infrastructure.goals import recompute, services, tree
from infrastructure.goals.models import KeyResult, KeyResultTask, KrType, ProgressDirty
from infrastructure.goals.signals import goal_progress_changed
from infrastructure.goals.tasks import recompute_due
from infrastructure.projects.tests import conftest as project_fixtures
from infrastructure.tasks import services as task_services
from infrastructure.workflows.models import Status

make_user = project_fixtures.make_user
add_member = project_fixtures.add_member
_commit_hooks_run_now = project_fixtures._commit_hooks_run_now
team = project_fixtures.team

PERIOD = ("2026-01-01", "2026-12-31")


@pytest.fixture(autouse=True)
def _no_broker(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setattr(recompute_due, "apply_async", lambda *a, **k: None)
    monkeypatch.setattr(delivery, "_hand_over", lambda *a, **k: None)


@pytest.fixture
def project(team: Any) -> Any:
    return team.create(team.owner, "WEB")


def _goal(team: Any, name: str = "G", actor: Any = None, **extra: Any) -> Any:
    return services.create(actor or team.owner, team.ws, name, *PERIOD, **extra)


def _kr(team: Any, goal: Any, kind: str, name: str = "KR", **extra: Any) -> Any:
    view = services.create_kr(team.owner, team.ws, str(goal.goal.pk), name, kind, **extra)
    return KeyResult.objects.filter(goal_id=goal.goal.pk, name=name).get(), view


def _task(team: Any, project: Any, title: str = "T", **extra: Any) -> Any:
    return task_services.create(team.owner, team.ws, str(project.pk), title, **extra)


def _complete(team: Any, project: Any, task: Any) -> None:
    done = Status.objects.get(project=project, name="Done")
    task.refresh_from_db()
    task_services.update(
        team.owner, team.ws, str(project.pk), str(task.pk), task.version, {"status": str(done.pk)}
    )


def _drain() -> int:
    """Make everything queued due now, then run the drain."""
    ProgressDirty.objects.update(due_at=timezone.now() - timedelta(seconds=1))
    return recompute.process_due()


def test_completing_a_task_updates_a_filter_linked_key_result(team: Any, project: Any) -> None:
    kr, _ = _kr(team, _goal(team), KrType.LINKED, filter_text="priority = high")
    first = _task(team, project, "a", priority="high")
    _task(team, project, "b", priority="high")
    _task(team, project, "other", priority="low")  # not matched by the filter
    assert _drain() == 1
    kr.refresh_from_db()
    assert (kr.linked_done, kr.linked_total) == (0, 2)

    _complete(team, project, first)
    assert _drain() == 1
    kr.refresh_from_db()
    assert (kr.linked_done, kr.linked_total) == (1, 2)
    assert tree.kr_value(kr) == pytest.approx(0.5)


def test_completing_a_task_updates_a_hand_picked_key_result(team: Any, project: Any) -> None:
    a, b = _task(team, project, "a"), _task(team, project, "b")
    kr, _ = _kr(team, _goal(team), KrType.LINKED, task_ids=[str(a.pk), str(b.pk)])
    assert (kr.linked_done, kr.linked_total) == (0, 2)
    assert KeyResultTask.objects.filter(kr=kr).count() == 2
    _complete(team, project, a)
    assert _drain() == 1
    kr.refresh_from_db()
    assert (kr.linked_done, kr.linked_total) == (1, 2)


def test_events_inside_the_window_cost_one_recount(team: Any, project: Any) -> None:
    kr, _ = _kr(team, _goal(team), KrType.LINKED, filter_text="priority = high")
    task = _task(team, project, "a", priority="high")
    row = ProgressDirty.objects.get(kr=kr)
    assert row.due_at > timezone.now() + timedelta(seconds=recompute.debounce_seconds() - 5)
    assert recompute.process_due() == 0  # not due yet: nothing recounted
    kr.refresh_from_db()
    assert kr.linked_total == 0

    _complete(team, project, task)  # a second event while waiting
    _task(team, project, "b", priority="high")
    assert ProgressDirty.objects.filter(kr=kr).count() == 1
    assert ProgressDirty.objects.get(kr=kr).due_at == row.due_at  # the burst did not move it
    assert recompute.mark_dirty([kr.pk]) == 0

    assert _drain() == 1
    kr.refresh_from_db()
    assert (kr.linked_done, kr.linked_total) == (1, 2)
    assert not ProgressDirty.objects.exists()


def test_the_window_comes_from_settings(settings: Any) -> None:
    settings.GOALS_RECOMPUTE_DEBOUNCE_SECONDS = 3
    assert recompute.debounce_seconds() == 3


def test_a_deleted_linked_task_leaves_the_denominator(team: Any, project: Any) -> None:
    a, b = _task(team, project, "a"), _task(team, project, "b")
    kr, _ = _kr(team, _goal(team), KrType.LINKED, task_ids=[str(a.pk), str(b.pk)])
    _complete(team, project, a)
    task_services.delete(team.owner, team.ws, str(project.pk), str(b.pk))
    assert _drain() == 1
    kr.refresh_from_db()
    assert (kr.linked_done, kr.linked_total) == (1, 1)
    assert tree.kr_value(kr) == 1.0


def test_number_key_result_moves_up_and_down(team: Any) -> None:
    goal = _goal(team)
    kr, _ = _kr(team, goal, KrType.NUMBER, start_value=0, target_value=10)
    services.add_check_in(team.owner, team.ws, str(kr.pk), 8)
    kr.refresh_from_db()
    assert tree.kr_value(kr) == pytest.approx(0.8)
    services.add_check_in(team.owner, team.ws, str(kr.pk), 3)  # a decrease
    kr.refresh_from_db()
    assert tree.kr_value(kr) == pytest.approx(0.3)
    entries = list(services.list_check_ins(team.owner, team.ws, str(kr.pk)))
    assert [(e.previous_value, e.value) for e in entries] == [
        (Decimal(8), Decimal(3)),
        (Decimal(0), Decimal(8)),
    ]


def test_a_target_below_the_start_counts_down(team: Any) -> None:
    kr, _ = _kr(
        team, _goal(team), KrType.NUMBER, start_value=100, target_value=0, current_value=100
    )
    services.add_check_in(team.owner, team.ws, str(kr.pk), 25)
    kr.refresh_from_db()
    assert tree.kr_value(kr) == pytest.approx(0.75)


def test_nested_rollup_uses_weights(team: Any) -> None:
    parent = _goal(team, "Parent")
    big = _goal(team, "Big", parent_id=str(parent.goal.pk), weight=3)
    small = _goal(team, "Small", parent_id=str(parent.goal.pk), weight=1)
    kr_big, _ = _kr(team, big, KrType.PERCENTAGE, "kb", current_value=100)
    _kr(team, small, KrType.PERCENTAGE, "ks", current_value=0)
    # a key result of the parent itself counts like a child, by its own weight
    _kr(team, parent, KrType.PERCENTAGE, "kp", current_value=0, weight=4)

    loaded = tree.load(team.ws.pk)
    assert loaded.progress(big.goal.pk) == 1.0
    assert loaded.progress(small.goal.pk) == 0.0
    # (1.0*3 + 0.0*1 + 0.0*4) / (3 + 1 + 4)
    assert loaded.progress(parent.goal.pk) == pytest.approx(3 / 8)

    services.add_check_in(team.owner, team.ws, str(kr_big.pk), 50)
    assert tree.load(team.ws.pk).progress(parent.goal.pk) == pytest.approx(1.5 / 8)


def test_a_goal_without_anything_is_at_zero(team: Any) -> None:
    empty = _goal(team)
    assert tree.load(team.ws.pk).progress(empty.goal.pk) == 0.0


def test_progress_changed_is_emitted_with_the_numbers(team: Any, project: Any) -> None:
    seen: list[dict[str, Any]] = []

    def listen(sender: Any, **payload: Any) -> None:
        seen.append(payload)

    goal = _goal(team)
    task = _task(team, project, "a", priority="high")
    _kr(team, goal, KrType.LINKED, filter_text="priority = high")
    goal_progress_changed.connect(listen)
    try:
        _complete(team, project, task)
        assert _drain() == 1
    finally:
        goal_progress_changed.disconnect(listen)
    (event,) = seen
    assert event["goal_id"] == str(goal.goal.pk)
    assert event["workspace_id"] == str(team.ws.pk)
    assert (event["previous"], event["progress"]) == (0.0, 1.0)
    assert event["actor_id"] == ""  # the system recounted
    assert event["status"] == "on_track"


def test_progress_changed_reaches_the_webhook_receiver(team: Any) -> None:
    hook = Webhook.objects.create(
        workspace=team.ws, url="https://example.com/h", secret="s", events=["goal.progress_changed"]
    )
    other = Webhook.objects.create(
        workspace=team.ws, url="https://example.com/o", secret="s", events=["task.created"]
    )
    goal = _goal(team)
    kr, _ = _kr(team, goal, KrType.NUMBER, start_value=0, target_value=10)
    services.add_check_in(team.owner, team.ws, str(kr.pk), 5)
    (row,) = WebhookDelivery.objects.filter(webhook=hook)
    assert not WebhookDelivery.objects.filter(webhook=other).exists()
    assert row.event == "goal.progress_changed"
    body = row.payload["data"]["goal"]
    assert body["goal_id"] == str(goal.goal.pk)
    assert (body["previous"], body["progress"]) == (0.0, 0.5)
    assert body["actor_id"] == str(team.owner.pk)
    assert row.payload["type"] == "goal.progress_changed" and row.payload["project_id"] is None


def test_unchanged_progress_sends_nothing(team: Any) -> None:
    goal = _goal(team)
    kr, _ = _kr(team, goal, KrType.NUMBER, start_value=0, target_value=10, current_value=5)
    Webhook.objects.create(
        workspace=team.ws, url="https://example.com/h", secret="s", events=["goal.progress_changed"]
    )
    services.add_check_in(team.owner, team.ws, str(kr.pk), 5)
    assert WebhookDelivery.objects.count() == 0


def test_a_private_goal_is_invisible_to_a_plain_member(team: Any) -> None:
    secret = _goal(team, "Secret", private=True)
    gid = str(secret.goal.pk)
    assert [v.goal.name for v in services.list_goals(team.owner, team.ws)] == ["Secret"]
    assert [v.goal.name for v in services.list_goals(team.admin, team.ws)] == ["Secret"]
    assert services.list_goals(team.member, team.ws) == []
    with pytest.raises(ApiError) as caught:
        services.get(team.member, team.ws, gid)
    assert caught.value.status == 404  # the same answer as a goal that does not exist
    with pytest.raises(ApiError):
        services.update(team.member, team.ws, gid, 1, name="x")


def test_a_contributor_sees_a_private_goal(team: Any) -> None:
    goal = _goal(team, "Mine", private=True, contributor_ids=[str(team.member.pk)])
    assert [v.goal.name for v in services.list_goals(team.member, team.ws)] == ["Mine"]
    assert services.get(team.member, team.ws, str(goal.goal.pk)).can_edit is False


def test_only_the_owner_or_an_admin_may_edit(team: Any) -> None:
    gid = str(_goal(team, "Open").goal.pk)  # public, owned by the workspace owner
    for stranger in (team.member, team.viewer):
        with pytest.raises(ApiError) as caught:
            services.update(stranger, team.ws, gid, 1, name="hijacked")
        assert caught.value.status in (403, 404)
    with pytest.raises(ApiError):
        services.delete(team.member, team.ws, gid)
    with pytest.raises(ApiError):
        services.create_kr(team.member, team.ws, gid, "KR", KrType.BOOLEAN)

    services.update(team.admin, team.ws, gid, 1, name="by admin")  # holds goal.manage
    view = services.update(team.owner, team.ws, gid, 2, name="by owner")
    assert view.goal.name == "by owner"


def test_a_member_owner_edits_their_own_goal(team: Any) -> None:
    gid = str(_goal(team, "Mine", actor=team.member).goal.pk)
    view = services.update(team.member, team.ws, gid, 1, name="renamed")
    assert view.goal.name == "renamed" and view.can_edit is True


def test_sample_tasks_do_not_count_toward_a_linked_key_result(team: Any, project: Any) -> None:
    from infrastructure.tasks.models import Task

    real, sample = _task(team, project, "real"), _task(team, project, "sample")
    Task.objects.filter(pk=sample.pk).update(is_sample=True)
    kr, _ = _kr(team, _goal(team), KrType.LINKED, task_ids=[str(real.pk), str(sample.pk)])
    other, _ = _kr(team, _goal(team, "H"), KrType.LINKED, name="KR2", filter_text="priority = none")

    assert recompute.count_linked(kr) == (0, 1)
    assert recompute.count_linked(other) == (0, 1)
