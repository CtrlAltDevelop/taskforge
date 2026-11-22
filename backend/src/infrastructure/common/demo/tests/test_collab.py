"""The collab seed fills every collaboration area, for the right people."""

from pathlib import Path
from typing import Any

import pytest

from infrastructure.attachments.models import Attachment
from infrastructure.chat.models import ChatMessage, ChatSpace
from infrastructure.comments.models import Comment, CommentReaction
from infrastructure.common.demo import collab, core
from infrastructure.common.demo.base import Ctx
from infrastructure.docs.models import Doc, DocLink, DocRevision
from infrastructure.inbox.models import Notification, NotificationPref, Watcher

pytestmark = pytest.mark.django_db(transaction=True)


@pytest.fixture(autouse=True)
def _settings(settings: Any, tmp_path: Path) -> None:
    settings.DEBUG = True
    settings.INBOX_SYNC_DELIVERY = True
    settings.MEDIA_ROOT = tmp_path


def test_collab_seed_builds_every_area() -> None:
    ctx = Ctx()
    core.seed(ctx)
    collab.seed(ctx)

    live = Comment.objects.filter(workspace=ctx.ws)
    assert live.filter(parent__isnull=False).exists()  # replies
    assert (
        live.filter(deleted_at__isnull=False).exists()
        and live.filter(edited_at__isnull=False).exists()
    )
    assert CommentReaction.objects.count() >= 10
    assert Attachment.objects.filter(workspace=ctx.ws).count() >= 8
    assert Attachment.objects.filter(comment__isnull=False).exists()

    assert Doc.objects.filter(workspace=ctx.ws, parent__isnull=False).exists()
    assert DocRevision.objects.filter(doc__workspace=ctx.ws).count() >= 4
    assert DocLink.objects.count() >= 3
    assert Doc.objects.filter(workspace=ctx.ws, archived_at__isnull=False).exists()

    kinds = set(ChatSpace.objects.filter(workspace=ctx.ws).values_list("kind", flat=True))
    assert {"channel", "group", "dm"} <= kinds
    assert ChatMessage.objects.filter(space__workspace=ctx.ws).count() >= 20

    mine = Notification.objects.filter(workspace=ctx.ws)
    assert mine.values("type").distinct().count() >= 10
    assert mine.filter(user=ctx.owner).count() >= 5
    assert NotificationPref.objects.count() >= 5
    assert Watcher.objects.filter(user=ctx.users["viewer"]).count() == 4
