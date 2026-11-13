"""Tell a submitter (who asked for it) when the task their form made changes status."""

import logging
from typing import Any

from infrastructure.forms.models import FormSubmission
from infrastructure.tasks.signals import task_activity

logger = logging.getLogger(__name__)


def _status_changed(sender: Any, **kw: Any) -> None:
    if kw["kind"] != "status_changed":
        return
    try:
        from infrastructure.forms.tasks import send_status

        rows = FormSubmission.objects.filter(
            task_id=kw["task_id"], wants_updates=True, form__notify_status=True
        ).values_list("pk", flat=True)
        for pk in rows:
            send_status.delay(str(pk), str(kw["data"].get("to_name", "")))
    except Exception:  # noqa: BLE001 -- the change is committed; the email is best effort
        logger.exception("could not queue the status email for a form submitter")


def connect() -> None:
    task_activity.connect(_status_changed, dispatch_uid="forms.status_changed")
