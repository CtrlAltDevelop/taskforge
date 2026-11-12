"""Comments on a task: the rules. Adapters only authenticate, call these and serialize.

Reading needs a task the caller can open; writing needs ``comment.create`` and a project that is
not archived. The author edits their own comment for ``COMMENT_EDIT_WINDOW_HOURS`` (the old body is
kept as a revision); the author or a moderator (``comment.moderate``) deletes, which empties the
comment (replies keep their place) and drops its history. Replies go one level deep.
"""

import json
import unicodedata
import uuid
from dataclasses import dataclass
from datetime import datetime, timedelta
from typing import Any, Final

from django.conf import settings
from django.db import transaction
from django.db.models import Count, Q
from django.utils import timezone

from infrastructure.audit import recorder
from infrastructure.comments import body as bodies
from infrastructure.comments import mentions
from infrastructure.comments.models import (
    Comment,
    CommentMention,
    CommentReaction,
    CommentRevision,
)
from infrastructure.comments.signals import announce, announce_mentions
from infrastructure.common.errors import ApiError
from infrastructure.common.responses import ResponseTitle
from infrastructure.projects import services as projects
from infrastructure.projects.models import Project
from infrastructure.tasks import services as task_services
from infrastructure.tasks.models import Task
from infrastructure.workspaces import access
from infrastructure.workspaces.models import Workspace

VIEW: Final = "workspace.view"
WRITE: Final = "comment.create"
MODERATE: Final = "comment.moderate"
PAGE_DEFAULT: Final = 50
PAGE_MAX: Final = 200
MAX_EMOJIS: Final = 30  # different reactions on one comment
MAX_PINNED: Final = 5  # pinned comments on one task
EMOJI_MAX: Final = 16


def not_found() -> ApiError:
    return ApiError("No such comment.", status=404)


@dataclass(frozen=True, slots=True)
class Page:
    """Comments oldest first. ``cursor`` is what to pass as ``before`` to load the ones before
    these (``""`` when there are none)."""

    comments: list[Comment]
    cursor: str


def _task(
    actor: Any, workspace: Workspace, project_id: str, task_id: str, *, write: bool = False
) -> tuple[Project, Task]:
    project = task_services.project_for_view(actor, workspace, project_id)
    if write:
        access.require(actor, WRITE, workspace)
        projects.writable(project)
    try:
        pk = uuid.UUID(str(task_id))
    except ValueError:
        raise task_services.not_found() from None
    task = Task.objects.filter(project=project, pk=pk, deleted_at__isnull=True).first()
    if task is None:
        raise task_services.not_found()
    return project, task


def _load(
    actor: Any,
    workspace: Workspace,
    project_id: str,
    comment_id: str,
    *,
    lock: bool = False,
    write: bool = False,
) -> tuple[Project, Comment]:
    project = task_services.project_for_view(actor, workspace, project_id)
    if write:
        access.require(actor, WRITE, workspace)
        projects.writable(project)
    try:
        pk = uuid.UUID(str(comment_id))
    except ValueError:
        raise not_found() from None
    rows = Comment.objects.filter(
        pk=pk, workspace=workspace, task__project=project, task__deleted_at__isnull=True
    ).select_related("task")
    comment = (rows.select_for_update(of=("self",)) if lock else rows).first()
    if comment is None:
        raise not_found()
    return project, comment


def present_one(actor: Any, workspace: Workspace, project_id: str, comment_id: str) -> Comment:
    """The comment as a client shows it, for whoever may see its task."""
    _, comment = _load(actor, workspace, project_id, comment_id)
    return present([comment])[0]


def present(comments: list[Comment]) -> list[Comment]:
    """Attach what a client shows of each comment (its mentions, reactions as ``{emoji: [user
    ids]}``, how many edits it has) in three queries; returns the same comments."""
    ids = [c.pk for c in comments]
    mentioned: dict[Any, list[str]] = {}
    for comment_id, user_id in CommentMention.objects.filter(comment_id__in=ids).values_list(
        "comment_id", "user_id"
    ):
        mentioned.setdefault(comment_id, []).append(str(user_id))
    reacted: dict[Any, dict[str, list[str]]] = {}
    for comment_id, emoji, user_id in (
        CommentReaction.objects.filter(comment_id__in=ids)
        .order_by("at", "id")
        .values_list("comment_id", "emoji", "user_id")
    ):
        reacted.setdefault(comment_id, {}).setdefault(emoji, []).append(str(user_id))
    edits = dict(
        CommentRevision.objects.filter(comment_id__in=ids)
        .values_list("comment_id")
        .annotate(n=Count("id"))
        .values_list("comment_id", "n")
    )
    for c in comments:
        c.mention_ids = sorted(mentioned.get(c.pk, []))
        c.reaction_map = reacted.get(c.pk, {})
        c.edit_count = edits.get(c.pk, 0)
    return comments


def _cursor(raw: str) -> tuple[datetime, uuid.UUID] | None:
    if not raw:
        return None
    try:
        stamp, _, ident = raw.partition("|")
        return datetime.fromisoformat(stamp), uuid.UUID(ident)
    except ValueError:
        raise ApiError("That cursor is not valid.") from None


def list_page(
    actor: Any,
    workspace: Workspace,
    project_id: str,
    task_id: str,
    *,
    before: str = "",
    limit: int = PAGE_DEFAULT,
) -> Page:
    """The newest ``limit`` comments of the task (or the ones before ``before``), oldest first."""
    _, task = _task(actor, workspace, project_id, task_id)
    size = max(1, min(limit or PAGE_DEFAULT, PAGE_MAX))
    rows = Comment.objects.filter(task=task).order_by("-created_at", "-id")
    mark = _cursor(before)
    if mark is not None:
        stamp, ident = mark
        rows = rows.filter(Q(created_at__lt=stamp) | Q(created_at=stamp, id__lt=ident))
    found = list(rows[: size + 1])
    more = len(found) > size
    page = list(reversed(found[:size]))
    cursor = f"{page[0].created_at.isoformat()}|{page[0].pk}" if more and page else ""
    return Page(present(page), cursor)


def _record_mentions(comment: Comment, users: list[Any]) -> list[Any]:
    """Make ``users`` the mentions of ``comment``; returns the ones that are new to it."""
    before = set(CommentMention.objects.filter(comment=comment).values_list("user_id", flat=True))
    wanted = {u.pk for u in users}
    CommentMention.objects.filter(comment=comment).exclude(user_id__in=wanted).delete()
    fresh = sorted(wanted - before, key=str)
    CommentMention.objects.bulk_create([CommentMention(comment=comment, user_id=u) for u in fresh])
    return fresh


def _labelled(document: dict[str, Any], people: list[Any]) -> dict[str, Any]:
    return bodies.relabel(document, {str(u.pk): mentions.display_name(u) for u in people})


def _others(actor: Any, ids: list[Any]) -> list[Any]:
    """Nobody is told about mentioning themselves."""
    return [u for u in ids if u != actor.pk]


def create(
    actor: Any,
    workspace: Workspace,
    project_id: str,
    task_id: str,
    body: str,
    *,
    parent_id: str = "",
    grant_access: bool = False,
    comment_id: str = "",
) -> Comment:
    """Add a comment (or, with ``parent_id``, a reply to a top-level one of the same task).
    Everyone it mentions must be able to see the task (see ``mentions.resolve``)."""
    with transaction.atomic():
        project, task = _task(actor, workspace, project_id, task_id, write=True)
        cleaned = bodies.clean(body)
        parent = _parent(task, parent_id)
        people = mentions.resolve(
            actor, workspace, project, cleaned.mention_ids, grant_access=grant_access
        )
        chosen = _chosen_id(comment_id, workspace)
        comment = Comment.objects.create(
            id=chosen,
            workspace=workspace,
            task=task,
            author=actor,
            parent=parent,
            body=_labelled(cleaned.document, people),
        )
        fresh = _record_mentions(comment, people)
        announce(comment, "created")
        announce_mentions(comment, _others(actor, fresh))
    return present([comment])[0]


_UNUSABLE_ID = "The comment id must be a new UUID."


def _chosen_id(raw: str, workspace: Workspace) -> uuid.UUID:
    """The id for a new comment: the one an offline client chose, else a new one.

    An id that another workspace holds is refused exactly like one that is not a UUID."""
    if not raw:
        return uuid.uuid4()
    try:
        chosen = uuid.UUID(str(raw))
    except ValueError:
        raise ApiError(_UNUSABLE_ID) from None
    if Comment.objects.filter(pk=chosen, workspace=workspace).exists():
        raise ApiError("A comment with that id exists already.", status=409)
    if Comment.objects.filter(pk=chosen).exists():
        raise ApiError(_UNUSABLE_ID)
    return chosen


def _parent(task: Task, parent_id: str) -> Comment | None:
    if not parent_id:
        return None
    try:
        pk = uuid.UUID(str(parent_id))
    except ValueError:
        raise not_found() from None
    parent = Comment.objects.filter(pk=pk, task=task).first()
    if parent is None:
        raise not_found()
    if parent.parent_id is not None:
        raise ApiError(
            "Replies go one level deep: reply to the comment above.",
            title=ResponseTitle.COMMENT_INVALID,
        )
    return parent


def _window_open(comment: Comment) -> bool:
    hours = settings.COMMENT_EDIT_WINDOW_HOURS
    return hours <= 0 or timezone.now() - comment.created_at <= timedelta(hours=hours)


def edit(
    actor: Any,
    workspace: Workspace,
    project_id: str,
    comment_id: str,
    expected_version: int,
    body: str,
    *,
    grant_access: bool = False,
) -> Comment:
    """Replace the body (author only, within the edit window, on its current version). The old
    body is kept as a revision; people newly mentioned are told once."""
    with transaction.atomic():
        project, comment = _load(actor, workspace, project_id, comment_id, lock=True, write=True)
        if comment.author_id != actor.pk:
            raise access.PermissionDenied(WRITE, "", "Only the author can edit a comment.")
        if comment.is_deleted or not _window_open(comment):
            raise ApiError(
                "That comment can no longer be edited.", title=ResponseTitle.COMMENT_LOCKED
            )
        if comment.version != expected_version:
            raise ApiError(
                "Someone changed this comment first.",
                status=409,
                title=ResponseTitle.VERSION_CONFLICT,
                data={"version": str(comment.version)},
            )
        cleaned = bodies.clean(body)
        people = mentions.resolve(
            actor, workspace, project, cleaned.mention_ids, grant_access=grant_access
        )
        CommentRevision.objects.create(comment=comment, body=comment.body)
        comment.body = _labelled(cleaned.document, people)
        comment.version += 1
        comment.edited_at = timezone.now()
        comment.save(update_fields=["body", "version", "edited_at"])
        fresh = _record_mentions(comment, people)
        announce(comment, "updated")
        announce_mentions(comment, _others(actor, fresh))
    return present([comment])[0]


def delete(actor: Any, workspace: Workspace, project_id: str, comment_id: str) -> Comment:
    """Remove a comment: its author or a moderator. It stays as "removed" (replies keep their
    place); its content, mentions, reactions and history are dropped."""
    with transaction.atomic():
        project, comment = _load(actor, workspace, project_id, comment_id, lock=True)
        projects.writable(project)
        if comment.author_id != actor.pk:
            access.require(actor, MODERATE, workspace)
        if comment.is_deleted:
            return present([comment])[0]
        comment.body = {}
        comment.deleted_at = timezone.now()
        comment.pinned = False
        comment.version += 1
        comment.save(update_fields=["body", "deleted_at", "pinned", "version"])
        CommentMention.objects.filter(comment=comment).delete()
        CommentRevision.objects.filter(comment=comment).delete()
        CommentReaction.objects.filter(comment=comment).delete()
        from infrastructure.attachments import services as attachment_services

        attachment_services.remove_for_comment(comment)  # its files go with it
        announce(comment, "deleted")
    return present([comment])[0]


# -- reactions, pins, history, subtasks -----------------------------------------------------------


def _emoji(raw: str) -> str:
    """One short token with no spaces or control characters (a ZWJ sequence is one token)."""
    if (
        not raw
        or len(raw) > EMOJI_MAX
        or any(ch.isspace() or unicodedata.category(ch) == "Cc" for ch in raw)
    ):
        raise ApiError(
            f"A reaction is one short emoji (at most {EMOJI_MAX} characters, no spaces).",
            title=ResponseTitle.COMMENT_INVALID,
        )
    return raw


def _lock_task(comment: Comment) -> None:
    """Serialize the limit checks (reactions, pins) of one task's comments."""
    Task.objects.select_for_update().filter(pk=comment.task_id).first()


def _gone() -> ApiError:
    return ApiError("That comment was removed.", title=ResponseTitle.COMMENT_LOCKED)


def _record_reaction(comment: Comment, action: str, emoji: str) -> None:
    recorder.record(
        workspace_id=comment.workspace_id,
        action=action,
        target_type="task",
        target_id=comment.task_id,
        project_id=comment.task.project_id,
        changes={"comment_id": comment.pk, "emoji": emoji},
    )


def react(
    actor: Any, workspace: Workspace, project_id: str, comment_id: str, emoji: str, on: bool
) -> Comment:
    """Give (``on``) or take back ``emoji``. Setting rather than toggling, so a request repeated
    or racing with itself ends in the same place."""
    token = _emoji(emoji)
    with transaction.atomic():
        _, comment = _load(actor, workspace, project_id, comment_id, write=True)
        if comment.is_deleted:
            raise _gone()
        _lock_task(comment)
        mine = CommentReaction.objects.filter(comment=comment, user=actor, emoji=token)
        if on and not mine.exists():
            kinds = set(
                CommentReaction.objects.filter(comment=comment).values_list("emoji", flat=True)
            )
            if token not in kinds and len(kinds) >= MAX_EMOJIS:
                raise ApiError(
                    f"A comment holds at most {MAX_EMOJIS} different reactions.",
                    title=ResponseTitle.COMMENT_INVALID,
                )
            CommentReaction.objects.bulk_create(
                [CommentReaction(comment=comment, user=actor, emoji=token)], ignore_conflicts=True
            )
            _record_reaction(comment, "comment.reacted", token)
            announce(comment, "reacted")
        elif not on and mine.exists():
            mine.delete()
            _record_reaction(comment, "comment.unreacted", token)
            announce(comment, "reacted")
    return present([comment])[0]


def pin(
    actor: Any, workspace: Workspace, project_id: str, comment_id: str, pinned: bool
) -> Comment:
    """Pin (or unpin) a comment: a moderator, or anyone who may edit tasks."""
    with transaction.atomic():
        project, comment = _load(actor, workspace, project_id, comment_id, lock=True)
        projects.writable(project)
        if not access.can(actor, MODERATE, workspace).allowed:
            access.require(actor, "task.update", workspace)
        if comment.is_deleted:
            raise _gone()
        if pinned and not comment.pinned:
            _lock_task(comment)
            others = Comment.objects.filter(task=comment.task, pinned=True).count()
            if others >= MAX_PINNED:
                raise ApiError(
                    f"A task keeps at most {MAX_PINNED} comments pinned.",
                    title=ResponseTitle.COMMENT_INVALID,
                )
        if comment.pinned != pinned:
            comment.pinned = pinned
            comment.save(update_fields=["pinned"])
            announce(comment, "pinned")
    return present([comment])[0]


@dataclass(frozen=True, slots=True)
class Revision:
    """One body a comment has had; ``current`` marks the one it has now."""

    body: dict[str, Any]
    at: datetime
    current: bool


def history(actor: Any, workspace: Workspace, project_id: str, comment_id: str) -> list[Revision]:
    """Every body of the comment, oldest first, the current one last; empty once it is removed."""
    _, comment = _load(actor, workspace, project_id, comment_id)
    if comment.is_deleted:
        return []
    old = [Revision(r.body, r.at, False) for r in comment.revisions.all()]
    return [*old, Revision(comment.body, comment.edited_at or comment.created_at, True)]


def to_subtask(actor: Any, workspace: Workspace, project_id: str, comment_id: str) -> Task:
    """Make the comment a subtask of its task: its first line is the title, its content the
    description. Needs the right to create tasks."""
    _, comment = _load(actor, workspace, project_id, comment_id)
    if comment.is_deleted:
        raise _gone()
    first = next(
        (line.strip() for line in bodies.plain_text(comment.body).splitlines() if line.strip()), ""
    )
    title = first if len(first) <= 500 else first[:499] + "…"
    return task_services.create(
        actor,
        workspace,
        project_id,
        title or "Comment",
        description=json.dumps(bodies.for_description(comment.body)),
        parent_id=str(comment.task_id),
    )
