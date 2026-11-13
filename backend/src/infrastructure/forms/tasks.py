from typing import Any

from celery import shared_task

from infrastructure.forms import mailer


@shared_task(name="infrastructure.forms.send_confirmation", ignore_result=True)
def send_confirmation(submission_id: str) -> None:
    mailer.confirm(submission_id)


@shared_task(name="infrastructure.forms.send_status", ignore_result=True)
def send_status(submission_id: str, status_name: str) -> Any:
    mailer.status_changed(submission_id, status_name)
