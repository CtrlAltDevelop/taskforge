"""Intake forms and what visitors sent through them."""

import secrets
import uuid

from django.conf import settings as django_settings
from django.db import models
from django.utils import timezone

from infrastructure.projects.models import Project
from infrastructure.tasks.models import Task
from infrastructure.workspaces.models import Workspace

TOKEN_BYTES = 24  # 32 URL-safe characters


def new_token() -> str:
    return secrets.token_urlsafe(TOKEN_BYTES)


class Form(models.Model):
    """A shareable form that creates a task in ``project``.

    ``fields`` is the ordered list of what the visitor sees (see ``spec``); ``defaults`` what the
    task starts with (``status_id``, ``assignee_ids``, ``priority``). ``owner`` is the member whose
    permissions the form borrows to create tasks (the last person who saved it), exactly like an
    automation's owner. ``token`` is the secret in the public URL."""

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    workspace = models.ForeignKey(Workspace, on_delete=models.CASCADE, related_name="+")
    project = models.ForeignKey(Project, on_delete=models.CASCADE, related_name="+")
    name = models.CharField(max_length=80)
    description = models.CharField(max_length=500, blank=True)
    token = models.CharField(max_length=64, unique=True, default=new_token)
    fields = models.JSONField(default=list)
    defaults = models.JSONField(default=dict)
    enabled = models.BooleanField(default=True)
    require_email = models.BooleanField(default=False)
    send_confirmation = models.BooleanField(default=True)
    notify_status = models.BooleanField(default=False)
    brand_color = models.CharField(max_length=7, blank=True)
    logo_url = models.CharField(max_length=500, blank=True)
    logo = models.FileField(upload_to="forms/logos", blank=True)  # an upload; excludes logo_url
    created_by = models.ForeignKey(
        django_settings.AUTH_USER_MODEL, null=True, on_delete=models.SET_NULL, related_name="+"
    )
    owner = models.ForeignKey(
        django_settings.AUTH_USER_MODEL, null=True, on_delete=models.SET_NULL, related_name="+"
    )
    version = models.PositiveIntegerField(default=1)
    created_at = models.DateTimeField(default=timezone.now)
    updated_at = models.DateTimeField(default=timezone.now)

    class Meta:
        indexes = [models.Index(fields=["workspace", "project"], name="form_ws_project_idx")]

    def __str__(self) -> str:
        return self.name

    @property
    def logo_src(self) -> str:
        """What the public page shows: the uploaded logo, else the linked one, else nothing."""
        return self.logo.url if self.logo else self.logo_url

    @property
    def actor_label(self) -> str:
        return f"Form: {self.name}"


class FormSubmission(models.Model):
    """One visitor's send. ``reference`` is all the visitor ever learns about the task. ``ip_hash``
    is a keyed hash (never the address). ``wants_updates`` is set when the visitor left an email
    and the form emails status changes; ``locale`` is the language their emails are written in."""

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    form = models.ForeignKey(Form, on_delete=models.CASCADE, related_name="submissions")
    task = models.ForeignKey(Task, null=True, on_delete=models.SET_NULL, related_name="+")
    reference = models.CharField(max_length=16, unique=True)
    submitter_email = models.CharField(max_length=254, blank=True)
    ip_hash = models.CharField(max_length=64, blank=True)
    locale = models.CharField(max_length=8, default="en")
    wants_updates = models.BooleanField(default=False)
    at = models.DateTimeField(default=timezone.now)

    class Meta:
        indexes = [models.Index(fields=["form", "-at"], name="formsub_form_at_idx")]
        ordering = ["-at"]

    def __str__(self) -> str:
        return self.reference
