"""A goal's owner and contributors hear when it is reached or starts slipping."""

from datetime import timedelta
from typing import Any

import pytest
from django.utils import timezone

from infrastructure.goals import services, tree
from infrastructure.goals.signals import goal_progress_changed
from infrastructure.inbox import kinds, render
from infrastructure.inbox.models import Notification
from infrastructure.projects.tests import conftest as project_fixtures

make_user = project_fixtures.make_user
add_member = project_fixtures.add_member
_commit_hooks_run_now = project_fixtures._commit_hooks_run_now
team = project_fixtures.team


@pytest.fixture(autouse=True)
def _inbox_sync(settings: Any) -> None:
    settings.INBOX_SYNC_DELIVERY = True


@pytest.fixture
def goal(team: Any) -> Any:
    today = timezone.localdate()
    view = services.create(
        team.owner,
        team.ws,
        "Ship 2.0",
        (today - timedelta(days=100)).isoformat(),
        (today + timedelta(days=100)).isoformat(),
        contributor_ids=[str(team.member.pk)],
    )
    return view.goal


def _moved(team: Any, goal: Any, previous: float, progress: float, status: str, actor: Any) -> None:
    goal_progress_changed.send(
        sender=tree.Tree,
        workspace_id=str(team.ws.pk),
        goal_id=str(goal.pk),
        previous=previous,
        progress=progress,
        status=status,
        actor_id=str(actor.pk) if actor else "",
    )


def _heard(kind: str) -> set[Any]:
    return set(Notification.objects.filter(type=kind).values_list("user_id", flat=True))


def test_reaching_100_percent_tells_the_owner_and_contributors_but_not_the_actor(
    team: Any, goal: Any
) -> None:
    _moved(team, goal, 0.8, 1.0, "on_track", actor=team.member)

    assert _heard(kinds.GOAL_REACHED) == {team.owner.pk}


def test_a_system_recount_reaching_100_percent_tells_everyone_involved(
    team: Any, goal: Any
) -> None:
    _moved(team, goal, 0.8, 1.0, "on_track", actor=None)

    assert _heard(kinds.GOAL_REACHED) == {team.owner.pk, team.member.pk}


def test_falling_behind_tells_them_once_and_names_the_status(team: Any, goal: Any) -> None:
    _moved(team, goal, 0.5, 0.1, "off_track", actor=None)
    _moved(team, goal, 0.1, 0.05, "off_track", actor=None)  # already off track: nothing new

    rows = Notification.objects.filter(type=kinds.GOAL_AT_RISK)
    assert {r.user_id for r in rows} == {team.owner.pk, team.member.pk}
    assert rows.count() == 2
    title, _ = render.render(rows[0], "", "en")
    assert "Ship 2.0" in title


def test_progress_that_stays_on_track_is_silent(team: Any, goal: Any) -> None:
    _moved(team, goal, 0.3, 0.5, "on_track", actor=None)

    assert not Notification.objects.exists()


def test_someone_who_left_the_workspace_is_not_told(team: Any, goal: Any) -> None:
    from infrastructure.workspaces import members

    members.remove(team.ws, team.owner, str(team.member.pk))

    _moved(team, goal, 0.8, 1.0, "on_track", actor=None)

    assert _heard(kinds.GOAL_REACHED) == {team.owner.pk}
