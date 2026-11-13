"""The two one-way emails a submitter may get: a confirmation and (optionally) status changes.

Written in the language of the visitor's browser, through the same ``tr`` helper and mail backend
as the rest of the app (console in DEBUG). The email carries the reference code, never a link into
the workspace or a task id.
"""

import logging
from typing import Any

from infrastructure.auth.core.delivery import DeliveryError, send_email
from infrastructure.common.messages import tr
from infrastructure.forms.models import FormSubmission

logger = logging.getLogger(__name__)


def _submission(submission_id: Any) -> FormSubmission | None:
    return FormSubmission.objects.filter(pk=submission_id).select_related("form", "task").first()


def _deliver(row: FormSubmission, subject: str, body: str) -> bool:
    try:
        send_email(row.submitter_email, subject, body)
    except DeliveryError:
        logger.warning("form email %s could not be delivered", row.reference)
        return False
    return True


def confirm(submission_id: Any) -> bool:
    row = _submission(submission_id)
    if row is None or not row.submitter_email or row.task is None:
        return False
    values = {"reference": row.reference, "title": row.task.title, "form": row.form.name}
    return _deliver(
        row,
        tr("forms.confirm.subject", row.locale, **values),
        tr("forms.confirm.body", row.locale, **values),
    )


def status_changed(submission_id: Any, status_name: str) -> bool:
    row = _submission(submission_id)
    if row is None or not row.wants_updates or row.task is None or not row.form.notify_status:
        return False
    values = {"reference": row.reference, "title": row.task.title, "status": status_name}
    return _deliver(
        row,
        tr("forms.status.subject", row.locale, **values),
        tr("forms.status.body", row.locale, **values),
    )
