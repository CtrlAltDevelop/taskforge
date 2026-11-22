"""Intake forms, the management side: list, create, update, delete, read submissions.

Everything needs ``form.manage`` in the workspace and a project the caller can open. The caller
becomes the form's *owner*: submissions create tasks with the owner's permissions (so a form can
never do what its owner could not), and the form says so when the owner has lost them. Nothing here
is reachable with an API token. Public submission lives in ``submit``.
"""

import uuid
from dataclasses import dataclass
from datetime import datetime
from typing import Any, Final

from django.conf import settings
from django.core.files.base import ContentFile
from django.db import transaction
from django.db.models import Count
from django.utils import timezone

from infrastructure.audit import recorder
from infrastructure.common.errors import ApiError
from infrastructure.common.responses import ResponseTitle
from infrastructure.forms import spec
from infrastructure.forms.models import Form, FormSubmission, new_token
from infrastructure.projects import services as projects
from infrastructure.projects.models import Project
from infrastructure.tasks import services as task_services
from infrastructure.workspaces import access
from infrastructure.workspaces import services as workspace_services
from infrastructure.workspaces.models import MemberStatus, Workspace, WorkspaceMember

MANAGE: Final = "form.manage"
PAGE_DEFAULT: Final = 50
PAGE_MAX: Final = 100
EDITABLE: Final = frozenset(
    {
        "name",
        "description",
        "fields",
        "defaults",
        "enabled",
        "require_email",
        "send_confirmation",
        "notify_status",
        "brand_color",
        "logo_url",
        "rotate_token",
    }
)


def not_found() -> ApiError:
    return ApiError("Not found.", status=404, title=ResponseTitle.NOT_FOUND)


def _by_person(actor: Any) -> None:
    from infrastructure.developer import scopes

    if scopes.token_of(actor) is not None:
        raise ApiError(
            "An API token cannot manage forms.",
            status=403,
            title=ResponseTitle.PERMISSION_DENIED_REASON,
            data={"hint": "sign in as a person"},
        )


def _form(workspace: Workspace, form_id: str, *, lock: bool = False) -> Form:
    try:
        pk = uuid.UUID(str(form_id))
    except ValueError:
        raise not_found() from None
    rows = Form.objects.filter(workspace=workspace, pk=pk).select_related("project")
    form = (rows.select_for_update(of=("self",)) if lock else rows).first()
    if form is None:
        raise not_found()
    return form


def _gate(actor: Any, workspace: Workspace) -> None:
    _by_person(actor)
    access.require(actor, MANAGE, workspace)


@dataclass(frozen=True, slots=True)
class FormView:
    form: Form
    submission_count: int
    problem: str  # why submissions would fail now ("" when none)


def owner_problem(form: Form) -> str:
    owner = form.owner
    if owner is None:
        return "The form's owner no longer exists. Save the form to take it over."
    active = WorkspaceMember.objects.filter(
        workspace_id=form.workspace_id, user=owner, status=MemberStatus.ACTIVE
    ).exists()
    if not active:
        return "The form's owner is no longer a member. Save the form to take it over."
    if not access.can(owner, "task.create", form.workspace).allowed:
        return "The form's owner can no longer create tasks. Save the form to take it over."
    if form.project.archived_at is not None:
        return "The project is archived."
    return ""


def _view(form: Form, count: int | None = None) -> FormView:
    if count is None:
        count = FormSubmission.objects.filter(form=form).count()
    return FormView(form, count, owner_problem(form))


def list_forms(actor: Any, workspace: Workspace, project_id: str = "") -> list[FormView]:
    _gate(actor, workspace)
    rows = Form.objects.filter(workspace=workspace).select_related("project", "owner", "workspace")
    if project_id:
        project = task_services.project_for_view(actor, workspace, project_id)
        rows = rows.filter(project=project)
    else:
        rows = rows.filter(project__in=Project.objects.visible_to(actor, workspace))
    counts = dict(
        FormSubmission.objects.filter(form__in=rows)
        .values("form_id")
        .annotate(n=Count("id"))
        .values_list("form_id", "n")
    )
    return [_view(f, counts.get(f.pk, 0)) for f in rows.order_by("name", "created_at")]


def _audit(form: Form, action: str, changes: dict[str, Any], actor: Any) -> None:
    recorder.record(
        workspace_id=form.workspace_id,
        action=action,
        target_type="form",
        target_id=form.pk,
        project_id=form.project_id,
        changes=changes,
        actor=actor,
    )


def _check_ready(project: Project, fields: list[dict[str, Any]], enabled: bool) -> None:
    missing = spec.uncovered_required(project, fields) if enabled else []
    if missing:
        raise spec.invalid(
            "Add the required project fields to the form first: " + ", ".join(missing) + "."
        )


def create(
    actor: Any,
    workspace: Workspace,
    project_id: str,
    name: str,
    *,
    fields: Any,
    description: str = "",
    defaults: dict[str, Any] | None = None,
    enabled: bool = True,
    require_email: bool = False,
    send_confirmation: bool = True,
    notify_status: bool = False,
    brand_color: str = "",
    logo_url: str = "",
) -> FormView:
    _gate(actor, workspace)
    with transaction.atomic():
        project = task_services.project_for_view(actor, workspace, project_id)
        projects.writable(project)
        if Form.objects.filter(project=project).count() >= settings.FORMS_MAX_PER_PROJECT:
            raise spec.invalid("This project has too many forms. Delete one first.")
        clean_fields = spec.clean_fields(fields, project)
        _check_ready(project, clean_fields, enabled)
        form = Form.objects.create(
            workspace=workspace,
            project=project,
            name=spec.clean_name(name),
            description=spec.clean_description(description),
            token=new_token(),
            fields=clean_fields,
            defaults=spec.clean_defaults(defaults or {}, project),
            enabled=enabled,
            require_email=require_email,
            send_confirmation=send_confirmation,
            notify_status=notify_status,
            brand_color=spec.clean_color(brand_color),
            logo_url=spec.clean_logo_url(logo_url),
            created_by=actor,
            owner=actor,
        )
        _audit(form, "form.created", {"name": form.name}, actor)
    return _view(form, 0)


def _apply(form: Form, changes: dict[str, Any]) -> dict[str, Any]:
    """Validate ``changes`` and set them on ``form``; returns what changed for the audit log."""
    cleaners: dict[str, Any] = {
        "name": spec.clean_name,
        "description": spec.clean_description,
        "brand_color": spec.clean_color,
        "logo_url": spec.clean_logo_url,
        "fields": lambda raw: spec.clean_fields(raw, form.project),
        "defaults": lambda raw: spec.clean_defaults(raw, form.project),
    }
    done: dict[str, Any] = {}
    if "logo_url" in changes and form.logo:
        form.logo = ""  # a linked (or cleared) logo replaces an uploaded one
        done["logo"] = "removed"
    for key, raw in changes.items():
        if key not in EDITABLE:
            raise ApiError(f"Cannot change {key}.")
        if key == "rotate_token":
            if raw:
                form.token = new_token()
                done["token"] = "rotated"
            continue
        value = cleaners[key](raw) if key in cleaners else bool(raw)
        if getattr(form, key) != value:
            done[key] = "changed" if key in ("fields", "defaults") else value
            setattr(form, key, value)
    return done


def update(
    actor: Any, workspace: Workspace, form_id: str, expected_version: int, **changes: Any
) -> FormView:
    """Change the named attributes (``EDITABLE``). A stale ``expected_version`` is a 409. The
    saver becomes the owner. ``rotate_token`` gives the form a new secret URL."""
    _gate(actor, workspace)
    with transaction.atomic():
        form = _form(workspace, form_id, lock=True)
        task_services.project_for_view(actor, workspace, str(form.project_id))
        if form.version != expected_version:
            raise ApiError(
                "The form changed since you opened it.", 409, title=ResponseTitle.VERSION_CONFLICT
            )
        projects.writable(form.project)
        replaced_logo = form.logo.name if "logo_url" in changes else ""
        done = _apply(form, changes)
        _check_ready(form.project, form.fields, form.enabled)
        form.owner = actor
        form.version += 1
        form.updated_at = timezone.now()
        form.save()
        _audit(form, "form.updated", done, actor)
    if replaced_logo:
        form.logo.storage.delete(replaced_logo)
    return _view(form)


def set_logo(
    actor: Any, workspace: Workspace, form_id: str, content: bytes, expected_version: int
) -> FormView:
    """Store an uploaded PNG, JPEG or WebP (read from its bytes, at most 2 MB) as the form's logo.
    It replaces a linked logo and a previous upload; the saver becomes the owner, as in any save."""
    _gate(actor, workspace)
    extension = workspace_services.logo_extension(content)
    if extension is None:
        raise ApiError(
            "The logo must be a PNG, JPEG or WebP image of at most 2 MB.",
            title=ResponseTitle.UPLOAD_INVALID,
        )
    with transaction.atomic():
        form = _form(workspace, form_id, lock=True)
        task_services.project_for_view(actor, workspace, str(form.project_id))
        if form.version != expected_version:
            raise ApiError(
                "The form changed since you opened it.", 409, title=ResponseTitle.VERSION_CONFLICT
            )
        projects.writable(form.project)
        previous = form.logo.name
        stored = form.logo.storage.save(
            f"forms/logos/{form.pk}-{uuid.uuid4().hex[:8]}.{extension}", ContentFile(content)
        )
        form.logo = stored
        form.logo_url = ""
        form.owner = actor
        form.version += 1
        form.updated_at = timezone.now()
        form.save()
        _audit(form, "form.updated", {"logo": "uploaded"}, actor)
    if previous:
        form.logo.storage.delete(previous)
    return _view(form)


def delete(actor: Any, workspace: Workspace, form_id: str) -> None:
    _gate(actor, workspace)
    with transaction.atomic():
        form = _form(workspace, form_id, lock=True)
        task_services.project_for_view(actor, workspace, str(form.project_id))
        _audit(form, "form.deleted", {"name": form.name}, actor)
        form.delete()


def submissions(
    actor: Any, workspace: Workspace, form_id: str, *, before: str = "", limit: int = 0
) -> tuple[list[FormSubmission], str, str]:
    """Newest first, with the form's project id. ``before`` is the cursor a page returns."""
    _gate(actor, workspace)
    form = _form(workspace, form_id)
    task_services.project_for_view(actor, workspace, str(form.project_id))
    size = min(limit or PAGE_DEFAULT, PAGE_MAX)
    rows = FormSubmission.objects.filter(form=form).select_related("task", "task__status")
    if before:
        try:
            cut = datetime.fromisoformat(before)
        except ValueError:
            raise spec.invalid("The page cursor is not valid.") from None
        rows = rows.filter(at__lt=cut)
    page = list(rows.order_by("-at", "-id")[: size + 1])
    cursor = page[size - 1].at.isoformat() if len(page) > size else ""
    return page[:size], cursor, str(form.project_id)
