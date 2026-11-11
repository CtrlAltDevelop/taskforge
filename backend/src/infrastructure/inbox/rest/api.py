"""The unsubscribe link in every notification email: public, the signed token is the capability.

A GET only shows a page with a button (mail scanners and link previews fetch every link in an
email, and must not unsubscribe anybody); the POST from that button makes the change."""

from html import escape

from django.http import HttpRequest, HttpResponse
from ninja import Router

from infrastructure.common.errors import ApiError
from infrastructure.inbox import delivery, kinds
from infrastructure.inbox.models import EmailMode, NotificationPref

router = Router()

PAGE = (
    "<!doctype html><meta charset=utf-8><meta name=viewport content='width=device-width'>"
    "<title>Unsubscribe</title>"
    "<body style='font-family:sans-serif;max-width:32rem;margin:3rem auto'>"
    "<h1>Stop these emails?</h1><p>{what}</p>"
    "<form method=post><button type=submit>Yes, stop them</button></form></body>"
)
DONE = (
    "<!doctype html><meta charset=utf-8><title>Unsubscribed</title>"
    "<body style='font-family:sans-serif;max-width:32rem;margin:3rem auto'>"
    "<h1>Done</h1><p>{what} You can change this any time in the app's notification settings.</p>"
)


def _target(token: str) -> tuple[str, str]:
    found = delivery.read_unsubscribe_token(token)
    if found is None:
        raise ApiError("This unsubscribe link is not valid or has expired.", 403)
    return found


def _label(kind: str) -> str:
    if kind == "all":
        return "all notification emails"
    return f"emails about: {kinds.BY_KEY[kind].label.lower()}" if kind in kinds.BY_KEY else kind


@router.get("/unsubscribe", auth=None, summary="Confirm turning off a kind of email")
def unsubscribe_page(request: HttpRequest, token: str = "") -> HttpResponse:
    _, kind = _target(token)
    return HttpResponse(PAGE.format(what=escape(f"This turns off {_label(kind)}.")))


@router.post("/unsubscribe", auth=None, summary="Turn off a kind of email with the link in it")
def unsubscribe(request: HttpRequest, token: str = "") -> HttpResponse:
    """Emails of the kind in the link (or all of them, for a digest) are turned off. Doing it again
    changes nothing."""
    user_id, kind = _target(token)
    from django.contrib.auth import get_user_model

    if not get_user_model().objects.filter(pk=user_id).exists():
        raise ApiError("This unsubscribe link is not valid or has expired.", 403)
    every = [k.key for k in kinds.KINDS] if kind == "all" else [kind]
    for key in every:
        default = kinds.BY_KEY.get(key)
        if default is None:
            continue
        NotificationPref.objects.update_or_create(
            user_id=user_id,
            event_type=key,
            defaults={"email_mode": EmailMode.OFF},
            create_defaults={
                "inbox": default.inbox,
                "push": default.push,
                "email_mode": EmailMode.OFF,
            },
        )
    return HttpResponse(DONE.format(what=escape(f"You will no longer get {_label(kind)}.")))
