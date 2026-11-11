"""Docs: a tree of pages, each a list of blocks, with its history and its links."""

import uuid

from django.conf import settings as django_settings
from django.db import models
from django.db.models import Q
from django.utils import timezone

from infrastructure.projects.models import Project
from infrastructure.workspaces.models import Workspace

SCHEMA_VERSION = 1


class Doc(models.Model):
    """A page. ``project`` is empty for a workspace-level page; a page and all its ancestors are in
    the same scope. ``restricted``: only the creator and the people in ``DocAccess`` (and holders
    of ``doc.manage``) may open it, and so its subpages; otherwise it inherits who may open its
    parent (at the top: everyone who can see the workspace or project)."""

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    workspace = models.ForeignKey(Workspace, on_delete=models.CASCADE, related_name="+")
    project = models.ForeignKey(
        Project, null=True, blank=True, on_delete=models.CASCADE, related_name="+"
    )
    parent = models.ForeignKey(
        "self", null=True, blank=True, on_delete=models.CASCADE, related_name="children"
    )
    title = models.CharField(max_length=200, blank=True)
    icon = models.CharField(max_length=32, blank=True)
    position = models.PositiveIntegerField(default=0)
    restricted = models.BooleanField(default=False)
    created_by = models.ForeignKey(
        django_settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="+"
    )
    created_at = models.DateTimeField(default=timezone.now)
    updated_at = models.DateTimeField(default=timezone.now)
    archived_at = models.DateTimeField(null=True, blank=True)

    class Meta:
        indexes = [
            models.Index(
                fields=["workspace", "project", "parent", "position"], name="doc_tree_idx"
            ),
        ]

    def __str__(self) -> str:
        return self.title or "Untitled"


class DocContent(models.Model):
    """The body: ``blocks`` (a JSON list, ``schema_version`` says how to read it). ``version`` is
    the optimistic lock, bumped by every save."""

    doc = models.OneToOneField(
        Doc, primary_key=True, on_delete=models.CASCADE, related_name="content"
    )
    blocks = models.JSONField(default=list)
    schema_version = models.PositiveSmallIntegerField(default=SCHEMA_VERSION)
    version = models.PositiveIntegerField(default=1)
    updated_by = models.ForeignKey(
        django_settings.AUTH_USER_MODEL, null=True, on_delete=models.SET_NULL, related_name="+"
    )
    updated_at = models.DateTimeField(default=timezone.now)

    def __str__(self) -> str:
        return f"{self.doc_id} v{self.version}"


class DocRevision(models.Model):
    """A snapshot. Saves by one person within ``REVISION_WINDOW`` of a revision's start fold into
    it, so there is one revision per burst of editing."""

    id = models.BigAutoField(primary_key=True)
    doc = models.ForeignKey(Doc, on_delete=models.CASCADE, related_name="revisions")
    title = models.CharField(max_length=200, blank=True)
    blocks = models.JSONField(default=list)
    schema_version = models.PositiveSmallIntegerField(default=SCHEMA_VERSION)
    version = models.PositiveIntegerField(default=1)  # the content version it holds
    author = models.ForeignKey(
        django_settings.AUTH_USER_MODEL, null=True, on_delete=models.SET_NULL, related_name="+"
    )
    at = models.DateTimeField(default=timezone.now)  # when the burst began
    saved_at = models.DateTimeField(default=timezone.now)  # its last save

    class Meta:
        indexes = [models.Index(fields=["doc", "-id"], name="docrev_doc_idx")]

    def __str__(self) -> str:
        return f"{self.doc_id} rev {self.pk}"


class LinkKind(models.TextChoices):
    MENTION = "mention"  # a ``[[`` page mention in the body: doc -> target_doc
    TASK_CARD = "task_card"  # a task card in the body: doc -> task
    RELATED = "related"  # linked by hand ("Related docs" on a task): doc -> task


class DocLink(models.Model):
    """What a page points at. ``mention`` and ``task_card`` rows are rebuilt from the body on every
    save; ``related`` rows are made and removed by hand."""

    id = models.BigAutoField(primary_key=True)
    doc = models.ForeignKey(Doc, on_delete=models.CASCADE, related_name="links")
    kind = models.CharField(max_length=10, choices=LinkKind.choices)
    task = models.ForeignKey(
        "tasks.Task", null=True, blank=True, on_delete=models.CASCADE, related_name="+"
    )
    target_doc = models.ForeignKey(
        Doc, null=True, blank=True, on_delete=models.CASCADE, related_name="backlinks"
    )

    class Meta:
        constraints = [
            models.UniqueConstraint(
                fields=["doc", "kind", "task"], condition=Q(task__isnull=False), name="doclink_task"
            ),
            models.UniqueConstraint(
                fields=["doc", "kind", "target_doc"],
                condition=Q(target_doc__isnull=False),
                name="doclink_target",
            ),
            models.CheckConstraint(
                condition=Q(task__isnull=False) ^ Q(target_doc__isnull=False),
                name="doclink_one_target",
            ),
        ]
        indexes = [models.Index(fields=["task"], name="doclink_task_idx")]

    def __str__(self) -> str:
        return f"{self.doc_id} {self.kind}"


class DocAccess(models.Model):
    """A person allowed into a restricted page (and so its subpages)."""

    doc = models.ForeignKey(Doc, on_delete=models.CASCADE, related_name="allowed")
    user = models.ForeignKey(
        django_settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="+"
    )

    class Meta:
        constraints = [models.UniqueConstraint(fields=["doc", "user"], name="docaccess_unique")]

    def __str__(self) -> str:
        return f"{self.doc_id} {self.user_id}"
