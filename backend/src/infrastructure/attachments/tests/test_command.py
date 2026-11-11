from datetime import timedelta
from io import StringIO
from typing import Any

from django.core.management import call_command
from django.utils import timezone

from infrastructure.attachments import services
from infrastructure.attachments.models import UploadSession


def test_the_command_purges_expired_uploads_and_says_how_many(
    team: Any, project: Any, task: Any
) -> None:
    session = services.start_upload(
        team.member, team.ws, str(project.pk), str(task.pk), "a.bin", 40
    )
    UploadSession.objects.update(expires_at=timezone.now() - timedelta(hours=1))
    out = StringIO()

    call_command("purge_uploads", stdout=out)

    assert "Purged 1 uploads" in out.getvalue()
    assert not UploadSession.objects.filter(pk=session.pk).exists()
