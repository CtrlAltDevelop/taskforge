"""Chat spaces: channels, private groups and direct messages, and what is said in them."""

import uuid

from django.conf import settings as django_settings
from django.db import models
from django.db.models import Q
from django.utils import timezone

from infrastructure.projects.models import Project
from infrastructure.workspaces.models import Workspace

CHANNEL = "channel"
GROUP = "group"
DM = "dm"
KINDS = (CHANNEL, GROUP, DM)
OWNER = "owner"
MEMBER = "member"


class ChatSpace(models.Model):
    """A place to talk. ``channel``: open to the workspace (``project`` null) or to one project's
    members; ``group``: private and invite-only; ``dm``: exactly two people, found by ``dm_key``
    (their sorted ids), so two people never have two. ``is_default`` marks the workspace's
    ``#general``; a project's channel is the one with ``project`` set. Their membership follows
    the workspace or the project (see ``access``). ``version`` rises with each rename or archive."""

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    workspace = models.ForeignKey(Workspace, on_delete=models.CASCADE, related_name="+")
    kind = models.CharField(max_length=8, default=CHANNEL)
    name = models.CharField(max_length=80, blank=True)
    project = models.ForeignKey(
        Project, null=True, blank=True, on_delete=models.CASCADE, related_name="+"
    )
    is_default = models.BooleanField(default=False)
    dm_key = models.CharField(max_length=73, null=True, blank=True)
    created_by = models.ForeignKey(
        django_settings.AUTH_USER_MODEL,
        null=True,
        blank=True,
        on_delete=models.SET_NULL,
        related_name="+",
    )
    archived_at = models.DateTimeField(null=True, blank=True)
    created_at = models.DateTimeField(default=timezone.now)
    version = models.PositiveIntegerField(default=1)

    class Meta:
        constraints = [
            models.UniqueConstraint(
                fields=["workspace"],
                condition=Q(is_default=True),
                name="chat_one_general_per_workspace",
            ),
            models.UniqueConstraint(
                fields=["project"],
                condition=Q(project__isnull=False),
                name="chat_one_channel_per_project",
            ),
            models.UniqueConstraint(
                fields=["workspace", "dm_key"],
                condition=Q(dm_key__isnull=False),
                name="chat_one_dm_per_pair",
            ),
        ]
        indexes = [models.Index(fields=["workspace", "kind"], name="chat_space_ws_kind_idx")]

    def __str__(self) -> str:
        return f"{self.kind} {self.name or self.pk}"

    @property
    def is_archived(self) -> bool:
        return self.archived_at is not None

    @property
    def follows_workspace_or_project(self) -> bool:
        """``#general`` and a project's channel: everyone who may see them is in them."""
        return self.kind == CHANNEL and (self.is_default or self.project_id is not None)


class ChatMember(models.Model):
    """One person's place in a space. For ``#general`` and a project's channel the row only holds
    read state and settings (who is in follows the workspace or project). ``muted_until`` silences
    pushes (``muted_completely`` also @mentions); ``notify_all`` asks to hear every message."""

    space = models.ForeignKey(ChatSpace, on_delete=models.CASCADE, related_name="members")
    user = models.ForeignKey(
        django_settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="+"
    )
    role = models.CharField(max_length=6, default=MEMBER)
    last_read_at = models.DateTimeField(default=timezone.now)
    muted_until = models.DateTimeField(null=True, blank=True)
    muted_completely = models.BooleanField(default=False)
    notify_all = models.BooleanField(default=False)
    joined_at = models.DateTimeField(default=timezone.now)

    class Meta:
        constraints = [models.UniqueConstraint(fields=["space", "user"], name="chat_member_unique")]

    def __str__(self) -> str:
        return f"{self.user_id} in {self.space_id}"

    @property
    def muted(self) -> bool:
        return self.muted_until is not None and self.muted_until > timezone.now()


class ChatMessage(models.Model):
    """``body`` is the shared rich-text document, rebuilt by ``comments.body.clean``. ``deleted_at``
    is a soft delete: the row stays so a thread keeps its place and the body is emptied.
    ``version`` counts edits, from 1. ``parent`` is a top-level message of the same space (a
    thread is one level deep)."""

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    space = models.ForeignKey(ChatSpace, on_delete=models.CASCADE, related_name="messages")
    workspace = models.ForeignKey(Workspace, on_delete=models.CASCADE, related_name="+")
    author = models.ForeignKey(
        django_settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="+"
    )
    parent = models.ForeignKey(
        "self", null=True, blank=True, on_delete=models.CASCADE, related_name="replies"
    )
    body = models.JSONField(default=dict)
    created_at = models.DateTimeField(default=timezone.now)
    edited_at = models.DateTimeField(null=True, blank=True)
    deleted_at = models.DateTimeField(null=True, blank=True)
    version = models.PositiveIntegerField(default=1)

    class Meta:
        indexes = [models.Index(fields=["space", "created_at", "id"], name="chat_msg_time_idx")]

    def __str__(self) -> str:
        return f"message {self.pk} in {self.space_id}"

    @property
    def is_deleted(self) -> bool:
        return self.deleted_at is not None


class ChatReaction(models.Model):
    message = models.ForeignKey(ChatMessage, on_delete=models.CASCADE, related_name="reactions")
    user = models.ForeignKey(
        django_settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="+"
    )
    emoji = models.CharField(max_length=16)
    at = models.DateTimeField(default=timezone.now)

    class Meta:
        constraints = [
            models.UniqueConstraint(
                fields=["message", "user", "emoji"], name="chat_reaction_unique"
            )
        ]

    def __str__(self) -> str:
        return f"{self.emoji} by {self.user_id} on {self.message_id}"
