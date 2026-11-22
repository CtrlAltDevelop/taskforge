"""The public form endpoints: read a form by its secret token, submit it. No sign-in.

``GET  /api/public/forms/{token}``         the form's definition and nothing else.
``POST /api/public/forms/{token}/submit``  multipart: ``answers`` (JSON object field id -> text),
``email``, ``website`` (the honeypot: leave empty), ``captcha_token`` and files named by their
file field's id. The answer is a reference code only.

A form that is unknown, disabled or deleted is the same generic 404. Responses are never cached.
The routes are also mounted under ``/api/v1/public/forms`` by the API registry.
"""

import json
from typing import Any

from django.conf import settings
from django.http import HttpRequest
from ninja import Router, Schema

from infrastructure.common.errors import ApiError
from infrastructure.common.locales import pick_from_accept_language
from infrastructure.common.responses import ResponseTitle
from infrastructure.common.throttling import ScopedAnonThrottle
from infrastructure.forms import captcha, ratelimit, spec, submit

OVERHEAD_BYTES = 1024 * 1024  # what a multipart body may add to its files


class OptionOut(Schema):
    id: str
    label: str


class FieldOut(Schema):
    id: str
    kind: str
    label: str
    help: str
    required: bool
    type: str
    options: list[OptionOut]
    max_files: int


class CaptchaOut(Schema):
    provider: str
    site_key: str


class FormOut(Schema):
    name: str
    description: str
    brand_color: str
    logo_url: str
    require_email: bool
    offers_updates: bool
    honeypot_field: str
    fields: list[FieldOut]
    captcha: CaptchaOut | None
    max_files: int
    max_file_bytes: int


class SubmittedOut(Schema):
    reference: str


def _definition(token: str) -> dict[str, Any]:
    form = submit.live_form(token)
    verifier = captcha.configured()
    return {
        "name": form.name,
        "description": form.description,
        "brand_color": form.brand_color,
        "logo_url": form.logo_src,
        "require_email": form.require_email,
        "offers_updates": form.notify_status or form.send_confirmation,
        "honeypot_field": "website",
        "fields": spec.public_fields(form.fields, form.project),
        "captcha": {"provider": verifier.provider, "site_key": verifier.site_key}
        if verifier
        else None,
        "max_files": settings.FORMS_MAX_FILES,
        "max_file_bytes": settings.FORMS_MAX_FILE_BYTES,
    }


def _answers(request: HttpRequest) -> dict[str, Any]:
    try:
        parsed = json.loads(request.POST.get("answers", "") or "{}")
    except ValueError:
        parsed = None
    if not isinstance(parsed, dict):
        raise spec.invalid("The answers are not valid.")
    return parsed


def _too_big(request: HttpRequest) -> bool:
    try:
        length = int(request.META.get("CONTENT_LENGTH") or 0)
    except ValueError:
        return True
    return length > settings.FORMS_MAX_TOTAL_BYTES + OVERHEAD_BYTES


def build_router() -> Router:
    router = Router()

    @router.get(
        "/{token}",
        response=FormOut,
        auth=None,
        throttle=[ScopedAnonThrottle("anon")],
        summary="Read a public form (the definition only)",
    )
    def read_form(request: HttpRequest, token: str) -> dict[str, Any]:
        return _definition(token)

    @router.post(
        "/{token}/submit",
        response={201: SubmittedOut},
        auth=None,
        throttle=[ScopedAnonThrottle("anon")],
        summary="Submit a public form (multipart)",
    )
    def submit_form(request: HttpRequest, token: str) -> tuple[int, dict[str, str]]:
        if _too_big(request):
            raise ApiError(
                "That is too much to send at once.", 413, title=ResponseTitle.ATTACHMENT_TOO_BIG
            )
        reference = submit.submit(
            token,
            answers=_answers(request),
            email=request.POST.get("email", ""),
            honeypot=request.POST.get("website", ""),
            captcha_token=request.POST.get("captcha_token", ""),
            files={key: request.FILES.getlist(key) for key in request.FILES},
            ip=ratelimit.client_ip(request),
            locale=pick_from_accept_language(request.headers.get("Accept-Language", "")),
        )
        return 201, {"reference": reference}

    return router


router = build_router()
