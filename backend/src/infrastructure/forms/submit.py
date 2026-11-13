"""A visitor's submission: the only write an anonymous caller can cause.

Order: the form must be live (else a generic 404), the per-form and per-IP limits count it, a
filled honeypot is answered with a believable reference and dropped, the CAPTCHA (when keys are
configured) must pass, then the answers are validated and one transaction creates the task (as
"Form: <name>", with the owner's permissions), keeps the files through the attachment pipeline and
records the submission. The visitor learns a reference code and nothing else: never a task id, and
no internal refusal text.
"""

import json
import logging
import secrets
import tempfile
from collections.abc import Mapping, Sequence
from contextlib import ExitStack
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any, Final

from django.conf import settings
from django.core.exceptions import ValidationError
from django.core.files.uploadedfile import UploadedFile
from django.core.validators import validate_email
from django.db import IntegrityError, transaction

from infrastructure.attachments import services as attachments
from infrastructure.audit import context as audit_context
from infrastructure.audit import recorder
from infrastructure.common.errors import ApiError
from infrastructure.common.responses import ResponseTitle
from infrastructure.customfields import values as custom
from infrastructure.forms import captcha, ratelimit, spec
from infrastructure.forms.models import Form, FormSubmission
from infrastructure.tasks import fields as task_fields
from infrastructure.tasks import services as tasks

logger = logging.getLogger(__name__)

REFERENCE_ALPHABET: Final = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
REFERENCE_LENGTH: Final = 8
EMAIL_MAX: Final = 254
TOKEN_MAX: Final = 64
PASS_THROUGH: Final = frozenset(
    {
        ResponseTitle.FIELD_INVALID,
        ResponseTitle.VALIDATION_ERROR,
        ResponseTitle.ATTACHMENT_REFUSED,
        ResponseTitle.ATTACHMENT_TOO_BIG,
    }
)


def not_found() -> ApiError:
    """The one answer for a form that is unknown, disabled or deleted."""
    return ApiError("Not found.", status=404, title=ResponseTitle.NOT_FOUND)


def unavailable() -> ApiError:
    return ApiError(
        "This form cannot take submissions right now. Try again later.",
        status=503,
        title=ResponseTitle.SERVICE_UNAVAILABLE,
    )


def new_reference() -> str:
    return "F-" + "".join(secrets.choice(REFERENCE_ALPHABET) for _ in range(REFERENCE_LENGTH))


def live_form(token: str) -> Form:
    """The enabled form with this secret token, or the generic 404."""
    if not token or len(token) > TOKEN_MAX:
        raise not_found()
    form = (
        Form.objects.filter(token=token, enabled=True)
        .select_related("project", "workspace", "owner")
        .first()
    )
    if form is None:
        raise not_found()
    return form


@dataclass(slots=True)
class Checked:
    title: str = ""
    description: str = ""
    field_values: dict[str, str] = field(default_factory=dict)
    uploads: list[tuple[str, UploadedFile]] = field(default_factory=list)
    email: str = ""


def _invalid(problems: Mapping[str, str]) -> ApiError:
    return ApiError(
        "Check the form and try again.",
        status=422,
        title=ResponseTitle.VALIDATION_ERROR,
        errors=list(problems.values()),
        data={"fields": json.dumps(problems)},
    )


def _clean_email(raw: str, required: bool, problems: dict[str, str]) -> str:
    email = raw.strip()
    if not email:
        if required:
            problems["email"] = "Enter your email address."
        return ""
    try:
        if len(email) > EMAIL_MAX:
            raise ValidationError("long")
        validate_email(email)
    except ValidationError:
        problems["email"] = "Enter a valid email address."
        return ""
    return email


def _check_files(
    form: Form, files: Mapping[str, Sequence[UploadedFile]], problems: dict[str, str]
) -> list[tuple[str, UploadedFile]]:
    file_fields = {f["id"]: f for f in form.fields if f["kind"] == spec.FILE}
    unknown = set(files) - set(file_fields)
    if unknown:
        raise _invalid({"files": "That file is not part of this form."})
    uploads: list[tuple[str, UploadedFile]] = []
    total = 0
    for fid, definition in file_fields.items():
        sent = list(files.get(fid, ()))
        if definition["required"] and not sent:
            problems[fid] = "Attach a file."
        if len(sent) > definition["max_files"]:
            problems[fid] = f"Attach at most {definition['max_files']} files."
            continue
        for item in sent:
            total += int(item.size or 0)
            if (item.size or 0) > settings.FORMS_MAX_FILE_BYTES:
                problems[fid] = "A file is too large."
            uploads.append((str(item.name or "file"), item))
    if len(uploads) > settings.FORMS_MAX_FILES or total > settings.FORMS_MAX_TOTAL_BYTES:
        problems["files"] = "Too many or too large files."
    return uploads


def check_answers(
    form: Form,
    answers: Mapping[str, Any],
    email: str,
    files: Mapping[str, Sequence[UploadedFile]],
) -> Checked:
    """The answers as the task needs them, or a 422 naming each field that is wrong."""
    problems: dict[str, str] = {}
    known = {f["id"] for f in form.fields}
    if set(answers) - known:
        raise _invalid({"answers": "An answer does not belong to this form."})
    out = Checked(email=_clean_email(email, form.require_email, problems))
    for definition in form.fields:
        fid, kind = definition["id"], definition["kind"]
        if kind == spec.FILE:
            continue
        raw = answers.get(fid, "")
        if not isinstance(raw, str) or len(raw) > settings.FORMS_MAX_ANSWER_CHARS:
            problems[fid] = "That answer is not valid."
            continue
        text = raw.strip()
        if definition["required"] and not text:
            problems[fid] = "This field is required."
        elif kind == spec.TITLE:
            _clean_title(text, fid, out, problems)
        elif kind == spec.DESCRIPTION:
            out.description = text
        elif text:
            out.field_values[definition["custom_field_id"]] = text
    out.uploads = _check_files(form, files, problems)
    if problems:
        raise _invalid(problems)
    _check_custom(form, out, problems)
    return out


def _clean_title(text: str, fid: str, out: Checked, problems: dict[str, str]) -> None:
    try:
        out.title = task_fields.clean_title(text)
    except ApiError as error:
        problems[fid] = str(error)


def _check_custom(form: Form, out: Checked, problems: dict[str, str]) -> None:
    """The same validation the app uses, so an answer is refused exactly as it would be there."""
    by_id = {f["custom_field_id"]: f["id"] for f in form.fields if f["kind"] == spec.CUSTOM}
    for key, value in out.field_values.items():
        try:
            custom.prepare(form.project, {key: value})
        except ApiError as error:
            if error.title != ResponseTitle.FIELD_INVALID:
                raise unavailable() from None
            problems[by_id.get(key, "answers")] = str(error)
    if problems:
        raise _invalid(problems)


def _document(text: str, footer: str) -> str:
    lines = [ln.strip() for ln in text.splitlines() if ln.strip()] if text else []
    paragraphs = [
        {"type": "paragraph", "content": [{"type": "text", "text": ln}]} for ln in [*lines, footer]
    ]
    return json.dumps({"type": "doc", "content": paragraphs})


def _spool(uploads: list[tuple[str, UploadedFile]], stack: ExitStack) -> list[tuple[str, Path]]:
    kept: list[tuple[str, Path]] = []
    for name, item in uploads:
        # Closed before use (Windows cannot reopen an open temporary file), removed on exit.
        with tempfile.NamedTemporaryFile(prefix="form-upload-", delete=False) as tmp:
            for chunk in item.chunks():
                tmp.write(chunk)
        path = Path(tmp.name)
        stack.callback(path.unlink, missing_ok=True)
        kept.append((name, path))
    return kept


def _create_task(form: Form, reference: str, checked: Checked) -> Any:
    defaults = form.defaults or {}
    footer = f"Submitted through the form “{form.name}”. Reference {reference}."
    return tasks.create(
        form.owner,
        form.workspace,
        str(form.project_id),
        checked.title,
        description=_document(checked.description, footer),
        status=str(defaults.get("status_id") or ""),
        priority=str(defaults.get("priority") or "none"),
        assignee_ids=list(defaults.get("assignee_ids", [])),
        field_values=checked.field_values,
    )


def _record(
    form: Form, checked: Checked, ip_hash: str, locale: str, task: Any, reference: str
) -> FormSubmission:
    submission = FormSubmission.objects.create(
        form=form,
        task=task,
        reference=reference,
        submitter_email=checked.email,
        ip_hash=ip_hash,
        locale=locale,
        wants_updates=bool(checked.email and form.notify_status),
    )
    recorder.record(
        workspace_id=form.workspace_id,
        action="form.submitted",
        target_type="form",
        target_id=form.pk,
        project_id=form.project_id,
        changes={"reference": reference},
    )
    return submission


def _store(form: Form, checked: Checked, ip_hash: str, locale: str) -> FormSubmission:
    for _attempt in range(5):
        reference = new_reference()
        try:
            with transaction.atomic(), audit_context.as_form(form.pk), ExitStack() as stack:
                spooled = _spool(checked.uploads, stack)
                task = _create_task(form, reference, checked)
                for name, path in spooled:
                    attachments.attach_local_file(
                        form.owner, task, name, path, max_bytes=settings.FORMS_MAX_FILE_BYTES
                    )
                submission = _record(form, checked, ip_hash, locale, task, reference)
                _after_commit(form, submission)
                return submission
        except IntegrityError:
            continue  # the reference collided: draw another
    raise unavailable()


def _after_commit(form: Form, submission: FormSubmission) -> None:
    if submission.submitter_email and form.send_confirmation:
        from infrastructure.forms.tasks import send_confirmation

        pk = str(submission.pk)

        def queue() -> None:
            try:
                send_confirmation.delay(pk)
            except Exception:  # noqa: BLE001 -- the submission is saved; the mail is best effort
                logger.exception("could not queue the confirmation email")

        transaction.on_commit(queue)


def submit(
    token: str,
    *,
    answers: Mapping[str, Any],
    email: str,
    honeypot: str,
    captcha_token: str,
    files: Mapping[str, Sequence[UploadedFile]],
    ip: str,
    locale: str,
) -> str:
    """Handle one visitor's submission; returns the reference code."""
    form = live_form(token)
    ip_hash = ratelimit.hash_ip(ip)
    ratelimit.check(form.pk, ip_hash)
    if honeypot.strip():
        return new_reference()  # a bot: believable answer, nothing kept
    verifier = captcha.configured()
    if verifier is not None and not verifier.verify(captcha_token, ip):
        raise ApiError(
            "Please complete the verification and try again.",
            status=400,
            title=ResponseTitle.BAD_REQUEST,
        )
    checked = check_answers(form, answers, email, files)
    if form.owner is None:
        raise unavailable()
    try:
        return _store(form, checked, ip_hash, locale).reference
    except ApiError as error:
        if error.title in PASS_THROUGH:
            raise
        logger.warning("form %s could not take a submission: %s", form.pk, error)
        raise unavailable() from None
