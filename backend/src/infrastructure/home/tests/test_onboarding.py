"""The checklist, the starters and the sample tasks."""

from datetime import date
from typing import Any

import pytest
from django.contrib.auth import get_user_model
from django.db.models import Q

from infrastructure.audit.models import AuditEntry
from infrastructure.common.errors import ApiError
from infrastructure.dashboards import metrics
from infrastructure.home import onboarding
from infrastructure.home.models import UserOnboarding
from infrastructure.home.tests.conftest import World
from infrastructure.projects.models import Project
from infrastructure.sync.actor import set_actor
from infrastructure.tasks import services as task_services
from infrastructure.tasks.models import Task
from infrastructure.workspaces import invitations
from infrastructure.workspaces import services as workspace_services


def done(state: onboarding.State) -> list[str]:
    return [step for step, ok in state.steps if ok]


def test_a_fresh_checklist_is_visible_with_nothing_ticked(world: World) -> None:
    state = onboarding.get(world.member, world.ws)

    assert [s for s, _ in state.steps] == list(onboarding.STEPS)
    assert done(state) == [] and state.visible and not state.complete and not state.dismissed


def test_client_steps_tick_once_and_unknown_ones_are_refused(world: World) -> None:
    onboarding.complete_step(world.member, world.ws, "try_board")
    state = onboarding.complete_step(world.member, world.ws, "try_board")

    assert done(state) == ["try_board"]
    with pytest.raises(ApiError):
        onboarding.complete_step(world.member, world.ws, "dance")


def test_creating_a_task_and_inviting_someone_tick_by_themselves(world: World) -> None:
    task_services.create(world.member, world.ws, str(world.web.pk), "My first")
    assert done(onboarding.get(world.member, world.ws)) == ["create_task"]
    assert done(onboarding.get(world.viewer, world.ws)) == []  # ticks are personal

    invitations.create_invitations(world.ws, world.owner, ["new@x.test"])
    assert "invite_member" in done(onboarding.get(world.owner, world.ws))


def test_finishing_every_step_hides_the_card_for_good(world: World) -> None:
    for step in onboarding.STEPS:
        state = onboarding.complete_step(world.member, world.ws, step)

    assert state.complete and not state.visible
    assert not onboarding.get(world.member, world.ws).visible


def test_dismissing_hides_it_for_good_and_later_actions_do_not_bring_it_back(world: World) -> None:
    onboarding.dismiss(world.member, world.ws)
    onboarding.dismiss(world.member, world.ws)  # safe to repeat
    task_services.create(world.member, world.ws, str(world.web.pk), "Later")

    state = onboarding.get(world.member, world.ws)

    assert state.dismissed and not state.visible and done(state) == []


def test_a_new_workspace_starts_a_new_checklist(world: World) -> None:
    onboarding.dismiss(world.owner, world.ws)
    other = workspace_services.create(world.owner, "Second", "second")

    assert onboarding.get(world.owner, other).visible
    assert UserOnboarding.objects.filter(user=world.owner).count() == 2


def test_a_stranger_cannot_read_a_workspaces_checklist(world: World) -> None:
    stranger = get_user_model().objects.create_user("eve", "e@x.test", "pw-123456-x")

    with pytest.raises(ApiError):
        onboarding.get(stranger, world.ws)


@pytest.mark.parametrize("starter", ["software-team", "marketing", "bug-tracker"])
def test_a_starter_makes_a_project_of_sample_tasks(world: World, starter: str) -> None:
    result = onboarding.apply_starter(world.member, world.ws, starter)

    project = Project.objects.get(pk=result.project_id)
    samples = Task.objects.filter(project=project.pk)
    assert result.task_count > 0 and samples.count() == result.task_count
    assert all(t.is_sample for t in samples)
    assert project.workspace_id == world.ws.pk
    state = onboarding.get(world.member, world.ws)
    assert state.sample_project_id == result.project_id and state.sample_count == result.task_count
    assert done(state) == []  # the samples are not "a task you created"
    assert AuditEntry.objects.filter(action="onboarding.starter_applied", project=project.pk)


def test_blank_is_an_empty_project_with_a_name_and_a_derived_key(world: World) -> None:
    first = onboarding.apply_starter(world.member, world.ws, "blank", "Design Team")
    second = onboarding.apply_starter(world.member, world.ws, "blank", "Design Team")

    one, two = (Project.objects.get(pk=r.project_id) for r in (first, second))
    assert one.name == "Design Team" and one.key == "DESIGN" and two.key != one.key
    assert first.task_count == 0 and not Task.objects.filter(project=one).exists()
    assert onboarding.get(world.member, world.ws).sample_project_id == ""
    assert onboarding.apply_starter(world.member, world.ws, "blank").project_id


def test_a_starter_needs_project_create_and_a_known_name(world: World) -> None:
    with pytest.raises(ApiError) as refused:
        onboarding.apply_starter(world.viewer, world.ws, "marketing")
    assert refused.value.status == 403
    with pytest.raises(ApiError):
        onboarding.apply_starter(world.member, world.ws, "nonsense")


def test_a_failing_starter_leaves_nothing_behind(world: World) -> None:
    before = (Project.objects.count(), Task.objects.count())

    with pytest.raises(ApiError):  # WEB is taken
        onboarding.apply_starter(world.member, world.ws, "software-team", key="WEB")

    assert (Project.objects.count(), Task.objects.count()) == before
    assert not UserOnboarding.objects.filter(sample_project__isnull=False).exists()


def test_samples_are_out_of_dashboards_by_default(world: World) -> None:
    result = onboarding.apply_starter(world.owner, world.ws, "marketing")
    world.task(world.web, "real")
    scope = metrics.Scope(world.owner, world.ws, None, date(2026, 11, 18))

    ids = set(metrics.visible_tasks(scope, Q(), "all").values_list("project_id", flat=True))

    assert str(result.project_id) not in {str(i) for i in ids} and world.web.pk in ids


def test_delete_samples_removes_them_all_and_leaves_the_project_and_own_work(
    world: World,
) -> None:
    result = onboarding.apply_starter(world.owner, world.ws, "software-team")
    set_actor(world.owner)
    sample = Task.objects.filter(project_id=result.project_id).order_by("number").first()
    mine = task_services.create(
        world.owner, world.ws, result.project_id, "Mine", parent_id=str(sample.pk)
    )

    gone = onboarding.delete_samples(world.owner, world.ws)

    assert gone == result.task_count
    assert Project.objects.filter(pk=result.project_id).exists()
    live = Task.objects.filter(project_id=result.project_id, deleted_at__isnull=True)
    assert list(live.values_list("pk", flat=True)) == [mine.pk]
    assert live.get().parent_id is None  # promoted out of the sample
    state = onboarding.get(world.owner, world.ws)
    assert state.sample_count == 0
    assert onboarding.delete_samples(world.owner, world.ws) == 0  # nothing left, safe to repeat
    assert AuditEntry.objects.filter(action="onboarding.samples_deleted")


def test_delete_samples_without_a_sample_project_is_a_no_op(world: World) -> None:
    assert onboarding.delete_samples(world.member, world.ws) == 0


def test_one_persons_samples_are_not_anothers(world: World) -> None:
    onboarding.apply_starter(world.owner, world.ws, "marketing")

    assert onboarding.delete_samples(world.member, world.ws) == 0
    assert Task.objects.filter(is_sample=True, deleted_at__isnull=True).exists()


def test_receiver_failures_never_break_the_task(world: World, monkeypatch: Any) -> None:
    def boom(*args: Any) -> None:
        raise RuntimeError("no")

    monkeypatch.setattr(onboarding, "tick_for", boom)

    assert task_services.create(world.member, world.ws, str(world.web.pk), "Still made").pk


def test_samples_of_two_starters_all_go_in_one_action(world: World) -> None:
    first = onboarding.apply_starter(world.owner, world.ws, "software-team")
    second = onboarding.apply_starter(world.owner, world.ws, "marketing")

    assert onboarding.delete_samples(world.owner, world.ws) == first.task_count + second.task_count
    assert not Task.objects.filter(is_sample=True, deleted_at__isnull=True).exists()


def test_samples_in_an_archived_project_are_still_deleted_in_one_click(world: World) -> None:
    from infrastructure.projects import services as project_services

    made = onboarding.apply_starter(world.owner, world.ws, "software-team")
    other = onboarding.apply_starter(world.owner, world.ws, "marketing")
    view = project_services.get(world.owner, world.ws, made.project_id)
    project_services.archive(world.owner, world.ws, made.project_id, view.project.version)

    gone = onboarding.delete_samples(world.owner, world.ws)

    assert gone == made.task_count + other.task_count
    assert not Task.objects.filter(is_sample=True, deleted_at__isnull=True).exists()


def test_the_migration_dismisses_the_checklist_of_existing_members_only(world: World) -> None:
    import importlib

    from django.apps import apps

    from infrastructure.workspaces.models import WorkspaceMember

    migration = importlib.import_module(
        "infrastructure.home.migrations.0002_dismiss_for_existing_members"
    )
    UserOnboarding.objects.all().delete()

    migration.dismiss_for_members(apps, None)

    assert UserOnboarding.objects.count() == WorkspaceMember.objects.count()
    assert not onboarding.get(world.owner, world.ws).visible
    assert not onboarding.get(world.member, world.ws).visible
    migration.dismiss_for_members(apps, None)  # safe to run twice
    assert UserOnboarding.objects.count() == WorkspaceMember.objects.count()


def test_people_who_join_or_create_a_workspace_afterwards_get_a_visible_checklist(
    world: World,
) -> None:
    import importlib

    from django.apps import apps

    importlib.import_module(
        "infrastructure.home.migrations.0002_dismiss_for_existing_members"
    ).dismiss_for_members(apps, None)
    newcomer = get_user_model().objects.create_user("new", "n@x.test", "pw-123456-x")
    invitations.accept(invitations.create_link(world.ws, world.owner).token, newcomer)
    fresh = workspace_services.create(newcomer, "Fresh", "fresh")

    assert onboarding.get(newcomer, world.ws).visible
    assert onboarding.get(newcomer, fresh).visible
