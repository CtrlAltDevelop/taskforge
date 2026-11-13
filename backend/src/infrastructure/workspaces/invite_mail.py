"""Invitation email: a signal, sent after commit, handled on a small background pool.

``invitation_issued`` carries the raw token. It exists only in memory: in the signal
kwargs, in the queued job and in the email. It is never stored and never logged; a
failure logs the invitation and workspace ids only.

ponytail: in-process pool, so a queued email is lost if the process restarts, and every
worker process has its own pool. Move the receiver's job to the phase 19/24 worker
(durable, retried) when it exists; the signal and its payload stay as they are.
"""

import logging
import time
from concurrent.futures import ThreadPoolExecutor
from threading import Lock
from typing import Any, Final

from django.conf import settings
from django.dispatch import Signal, receiver

from infrastructure.auth.core.delivery import send_email
from infrastructure.common.messages import locale_for_email, tr

logger = logging.getLogger(__name__)

MAX_ATTEMPTS: Final = 3
POOL_WORKERS: Final = 4

# kwargs: invitation_id, workspace_id, workspace_name, inviter_name, email, token
invitation_issued = Signal()

_pool: ThreadPoolExecutor | None = None
_pool_lock = Lock()


def _executor() -> ThreadPoolExecutor:
    global _pool
    with _pool_lock:
        if _pool is None:
            _pool = ThreadPoolExecutor(POOL_WORKERS, thread_name_prefix="invite-mail")
        return _pool


def _send(
    invitation_id: str,
    workspace_id: str,
    workspace_name: str,
    inviter_name: str,
    email: str,
    token: str,
    locale: str = "en",
) -> None:
    url = settings.WORKSPACE_INVITE_URL.format(token=token)
    lang = locale
    names = {"inviter": inviter_name, "workspace": workspace_name}
    body = f"{tr('invite.body', lang, **names)}\n\n{tr('invite.join', lang, url=url)}\n"
    subject = tr("invite.subject", lang, **names)
    for attempt in range(1, MAX_ATTEMPTS + 1):
        try:
            send_email(email, subject, body)
            return
        except Exception as error:  # noqa: BLE001 - nothing may kill the worker thread
            # No exc_info and no message: neither may echo the link.
            logger.error(
                "Invitation %s (workspace %s) email attempt %d/%d failed: %s",
                invitation_id,
                workspace_id,
                attempt,
                MAX_ATTEMPTS,
                type(error).__name__,
            )
            if attempt < MAX_ATTEMPTS:
                time.sleep(settings.WORKSPACE_EMAIL_BACKOFF_SECONDS * attempt)
    logger.error(
        "Invitation %s (workspace %s) email not delivered; it stays pending, resend it",
        invitation_id,
        workspace_id,
    )


@receiver(invitation_issued, dispatch_uid="workspaces.invite_mail")
def deliver_invitation(sender: Any, signal: Any, **job: Any) -> None:
    """Hand the email to the pool, or run it inline when ``WORKSPACE_EMAIL_ASYNC`` is off."""
    job.setdefault("locale", locale_for_email(job.get("email", "")))
    if settings.WORKSPACE_EMAIL_ASYNC:
        _executor().submit(_send, **job)
    else:
        _send(**job)
