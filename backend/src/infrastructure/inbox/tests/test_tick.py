from io import StringIO
from typing import Any

from django.core.management import call_command

from infrastructure.inbox.models import Notification
from infrastructure.inbox.tests.test_notify import assign


def test_the_tick_runs_everything_that_waits_for_the_clock(
    team: Any, project: Any, task: Any
) -> None:
    out = StringIO()
    assign(team, project, task, team.member)

    call_command("inbox_tick", stdout=out)

    assert "Woke 0, due soon 0, delivered" in out.getvalue()
    assert Notification.objects.count() == 1


def test_a_long_overdue_task_is_not_told_about_forever(team: Any, project: Any) -> None:
    from datetime import timedelta

    from django.utils import timezone

    from infrastructure.inbox import due
    from infrastructure.tasks import services as tasks

    old = timezone.now().date() - timedelta(days=60)
    tasks.create(
        team.owner,
        team.ws,
        str(project.pk),
        "Ancient",
        due_date=old.isoformat(),
        assignee_ids=[str(team.member.pk)],
    )
    Notification.objects.all().delete()

    assert due.scan_due_soon() == 0
