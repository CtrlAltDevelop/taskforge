"""Catching up: what a client that missed events is told, and trimming the log."""

from datetime import timedelta
from typing import Any

import pytest
from django.utils import timezone

from infrastructure.common.errors import ApiError
from infrastructure.sync import services
from infrastructure.sync.models import ChangeLog
from infrastructure.tasks import services as tasks

pytestmark = pytest.mark.django_db


def _make(team: Any, project: Any, title: str = "T", actor: Any = None) -> Any:
    return tasks.create(actor or team.owner, team.ws, str(project.pk), title)


def test_since_lists_what_happened_after_the_cursor_oldest_first(team: Any, project: Any) -> None:
    first = _make(team, project, "one")
    head = services.head(team.viewer, team.ws)
    second = _make(team, project, "two")
    tasks.update(team.owner, team.ws, str(project.pk), str(first.pk), 1, {"title": "uno"})

    found = services.since(team.viewer, team.ws, head)

    # the title change also writes a change message into the task's chat (phase 42)
    entries = [e for e in found.entries if e.event_type.startswith("task.")]
    assert [(e.event_type, str(e.entity_id)) for e in entries] == [
        ("task.created", str(second.pk)),
        ("task.updated", str(first.pk)),
    ]
    assert entries[0].pk < entries[1].pk
    assert found.latest == found.entries[-1].pk and not found.gap


def test_since_the_head_is_empty_and_nothing_is_lost_between(team: Any, project: Any) -> None:
    _make(team, project)

    assert services.since(team.viewer, team.ws, services.head(team.viewer, team.ws)).entries == []


def test_the_limit_cuts_the_page_and_the_cursor_continues_it(team: Any, project: Any) -> None:
    for n in range(5):
        _make(team, project, str(n))
    start = ChangeLog.objects.filter(workspace=team.ws).order_by("id").first().pk - 1

    page = services.since(team.viewer, team.ws, start, limit=3)
    rest = services.since(team.viewer, team.ws, page.latest, limit=3)

    assert len(page.entries) == 3 and page.more is True
    assert len(rest.entries) >= 2
    assert {e.pk for e in page.entries}.isdisjoint({e.pk for e in rest.entries})


def test_only_this_workspaces_changes_are_listed(team: Any, project: Any) -> None:
    _make(team, project)
    from infrastructure.projects import services as projects

    foreign = projects.create(team.outsider, team.other_ws, "Other", "OTH").project
    tasks.create(team.outsider, team.other_ws, str(foreign.pk), "theirs")

    found = services.since(team.viewer, team.ws, 0)

    assert {e.workspace_id for e in found.entries} == {team.ws.pk}


def test_a_private_projects_changes_are_left_out_for_those_who_cannot_open_it(
    team: Any, project: Any
) -> None:
    secret = team.create(team.pm, "SEC", visibility="private", name="Secret")
    tasks.create(team.pm, team.ws, str(secret.pk), "hidden")
    _make(team, project, "open")

    seen = services.since(team.member, team.ws, 0).entries
    pm_seen = services.since(team.pm, team.ws, 0).entries

    assert all(e.project != secret.pk for e in seen)
    assert any(e.project == secret.pk for e in pm_seen)


def test_an_outsider_may_not_catch_up_or_ask_for_the_head(team: Any) -> None:
    with pytest.raises(ApiError):
        services.since(team.outsider, team.ws, 0)
    with pytest.raises(ApiError):
        services.head(team.outsider, team.ws)


def test_a_cursor_behind_the_trimmed_part_is_a_gap(team: Any, project: Any) -> None:
    _make(team, project)
    old = ChangeLog.objects.filter(workspace=team.ws).order_by("id").last()
    ChangeLog.objects.filter(pk=old.pk).update(at=timezone.now() - timedelta(days=15))
    behind = old.pk - 1

    assert services.trim() == 1
    found = services.since(team.viewer, team.ws, behind)

    assert found.gap is True and found.entries == []
    assert found.latest == services.head(team.viewer, team.ws)


def test_a_cursor_at_or_after_the_trimmed_part_is_not_a_gap(team: Any, project: Any) -> None:
    _make(team, project)
    old = ChangeLog.objects.filter(workspace=team.ws).order_by("id").last()
    ChangeLog.objects.filter(pk=old.pk).update(at=timezone.now() - timedelta(days=15))
    services.trim()

    assert services.since(team.viewer, team.ws, old.pk).gap is False


def test_trim_keeps_the_recent_log(team: Any, project: Any) -> None:
    _make(team, project)

    assert services.trim() == 0
    assert ChangeLog.objects.filter(workspace=team.ws).exists()


def test_the_head_of_a_quiet_workspace_is_zero(team: Any) -> None:
    ChangeLog.objects.all().delete()

    assert services.head(team.viewer, team.ws) == 0


def test_a_hundred_changes_made_while_away_are_all_there_in_order(team: Any, project: Any) -> None:
    head = services.head(team.viewer, team.ws)
    made = [str(_make(team, project, str(n)).pk) for n in range(100)]

    page = services.since(team.viewer, team.ws, head, limit=5000)

    assert [str(e.entity_id) for e in page.entries] == made
    assert [e.pk for e in page.entries] == sorted(e.pk for e in page.entries)
    assert page.more is False and page.latest == page.entries[-1].pk


def test_the_trim_command_trims(team: Any, project: Any) -> None:
    from io import StringIO

    from django.core.management import call_command

    _make(team, project)
    ChangeLog.objects.update(at=timezone.now() - timedelta(days=20))
    out = StringIO()

    call_command("trim_changelog", stdout=out)

    assert out.getvalue().startswith("Trimmed 2 entries")
    assert ChangeLog.objects.count() == 0


def test_another_persons_access_change_is_not_listed_but_ones_for_everyone_and_for_you_are(
    team: Any, project: Any
) -> None:
    from infrastructure.sync import publish

    head = services.head(team.viewer, team.ws)
    publish.record(
        entity_type="access", entity_id=team.member.pk, workspace_id=team.ws.pk,
        action="changed", user_id=str(team.member.pk),
    )  # fmt: skip
    publish.record(
        entity_type="access", entity_id=team.viewer.pk, workspace_id=team.ws.pk,
        action="changed", user_id=str(team.viewer.pk),
    )  # fmt: skip
    publish.record(
        entity_type="access", entity_id=team.ws.pk, workspace_id=team.ws.pk, action="changed"
    )

    seen = services.since(team.viewer, team.ws, head).entries

    assert {str(e.entity_id) for e in seen} == {str(team.viewer.pk), str(team.ws.pk)}


@pytest.mark.django_db(transaction=True)
def test_the_trimmer_runs_in_the_background_and_trims(team: Any, project: Any) -> None:
    import asyncio

    from infrastructure.sync import trimmer

    _make(team, project)
    ChangeLog.objects.update(at=timezone.now() - timedelta(days=20))

    assert asyncio.run(trimmer.trim_once()) >= 1
    assert ChangeLog.objects.filter(at__lt=timezone.now() - timedelta(days=14)).count() == 0


def test_trimming_twice_at_once_does_not_trip_over_the_mark(team: Any, project: Any) -> None:
    _make(team, project)
    ChangeLog.objects.update(at=timezone.now() - timedelta(days=20))

    assert services.trim() >= 1
    assert services.trim() == 0


def test_the_gap_is_judged_on_the_cursor_the_client_holds_not_the_one_it_rereads_from(
    team: Any, project: Any
) -> None:
    for n in range(4):
        _make(team, project, str(n))
    rows = list(ChangeLog.objects.filter(workspace=team.ws).order_by("id"))
    ChangeLog.objects.filter(pk=rows[0].pk).update(at=timezone.now() - timedelta(days=20))
    services.trim()  # trimmed up to rows[0]
    held = rows[2].pk  # the client is past the trimmed part

    page = services.since(team.viewer, team.ws, held, overlap=50)

    assert page.gap is False  # re-reading 50 back reaches the trimmed part: still not a gap
    assert {e.pk for e in page.entries} >= {r.pk for r in rows[1:]}  # the overlap is read again


def test_a_client_that_never_synced_is_not_told_there_is_a_gap(team: Any, project: Any) -> None:
    _make(team, project)
    ChangeLog.objects.update(at=timezone.now() - timedelta(days=20))
    services.trim()

    assert services.since(team.viewer, team.ws, 0).gap is False
