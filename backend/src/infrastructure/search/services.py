"""Global search: tasks, comments, projects and people the caller may open, and recent queries.

Access is part of the SQL (the caller's visible projects), never a filter on the page afterwards,
so a page is never short and no count leaks. Operators in the text narrow tasks and comments:
``in:KEY`` (a project's key or the start of its name), ``assignee:me`` (or part of a name or
email), ``status:open|done|closed`` (or a status name). With any operator people and projects are
left out. An id like ``WEB-12`` also comes back as ``jump``.
"""

import re
from dataclasses import dataclass, field
from typing import Any

from django.conf import settings
from django.core.cache import cache
from django.db.models import Exists, F, OuterRef, Q
from django.utils import timezone

from infrastructure.comments.mentions import display_name
from infrastructure.comments.models import Comment
from infrastructure.common.errors import ApiError
from infrastructure.common.responses import ResponseTitle
from infrastructure.projects.models import Project
from infrastructure.search import index, matching
from infrastructure.search.fold import fold, marks, snippet, terms
from infrastructure.search.models import SearchEntry, SearchHistory
from infrastructure.tasks.models import Task, TaskAssignee
from infrastructure.workflows.models import Category
from infrastructure.workspaces import access
from infrastructure.workspaces.models import MemberStatus, Workspace, WorkspaceMember

VIEW = "workspace.view"
KINDS = ("task", "comment", "project", "member", "doc")
MAX_TEXT = 200
DEFAULT_PAGE = 8
MAX_PAGE = 50
HISTORY_LIMIT = 20
MAX_OFFSET = 10_000
MIN_REMEMBERED = 2
_OPERATOR = re.compile(r"^(in|assignee|status):(\S+)$", re.IGNORECASE)
_ID = re.compile(r"^\s*([A-Za-z][A-Za-z0-9]{0,5})-(\d+)\s*$")
OPEN = (Category.NOT_STARTED, Category.ACTIVE)
CLOSED = (Category.DONE, Category.CANCELLED)


@dataclass(frozen=True, slots=True)
class Parsed:
    words: list[str]
    project: str = ""
    assignee: str = ""
    status: str = ""

    @property
    def has_operator(self) -> bool:
        return bool(self.project or self.assignee or self.status)


@dataclass(slots=True)
class Hit:
    kind: str
    id: str
    title: str
    project_id: str = ""
    task_id: str = ""
    key: str = ""
    project_name: str = ""
    status: str = ""
    author: str = ""
    snippet: str = ""
    title_marks: list[tuple[int, int]] = field(default_factory=list)
    snippet_marks: list[tuple[int, int]] = field(default_factory=list)
    updated_at: str = ""


@dataclass(slots=True)
class Page:
    hits: dict[str, list[Hit]]
    jump: Hit | None
    next_cursor: str


def _invalid(message: str) -> ApiError:
    return ApiError(message, title=ResponseTitle.VALIDATION_ERROR)


def parse(text: str) -> Parsed:
    """Split the operators out of ``text``; what is left is the words to find."""
    ops: dict[str, str] = {}
    rest: list[str] = []
    for token in text.split():
        found = _OPERATOR.match(token)
        if found and found.group(1).lower() not in ops:
            ops[found.group(1).lower()] = found.group(2)
        else:
            rest.append(token)
    return Parsed(
        terms(" ".join(rest)), ops.get("in", ""), ops.get("assignee", ""), ops.get("status", "")
    )


def _throttle(actor: Any) -> None:
    # ponytail: counted in Django's cache, so per process unless CACHES points at Redis.
    limit = settings.SEARCH_RATE_PER_MINUTE
    if not limit:
        return
    key = f"search:rate:{actor.pk}"
    cache.add(key, 0, 60)
    try:
        used = cache.incr(key)
    except ValueError:  # expired between the two calls
        cache.set(key, 1, 60)
        used = 1
    if used > limit:
        raise ApiError(
            "Too many searches. Wait a moment.", status=429, title=ResponseTitle.RATE_LIMITED
        )


def _offset(cursor: str) -> int:
    if not cursor:
        return 0
    if not (cursor.isascii() and cursor.isdigit()) or int(cursor) > MAX_OFFSET:
        raise _invalid("That cursor is not valid.")
    return int(cursor)


def _task_rows(actor: Any, workspace: Workspace, kinds: list[str], parsed: Parsed) -> Any:
    visible = Project.objects.visible_to(actor, workspace).values("pk")
    rows = SearchEntry.objects.filter(
        workspace=workspace,
        kind__in=kinds,
        task__deleted_at__isnull=True,
        task__project_id__in=visible,
    )
    if parsed.project:
        wanted = Project.objects.visible_to(actor, workspace).filter(
            Q(key__iexact=parsed.project) | Q(name__istartswith=parsed.project)
        )
        rows = rows.filter(task__project_id__in=wanted.values("pk"))
    if parsed.status:
        rows = rows.filter(_status(parsed.status))
    if parsed.assignee:
        rows = rows.filter(Exists(_assigned(actor, parsed.assignee, OuterRef("task_id"))))
    return rows


def _status(value: str) -> Q:
    named = {"open": OPEN, "done": (Category.DONE,), "closed": CLOSED}.get(value.lower())
    if named:
        return Q(task__status__category__in=named)
    return Q(task__status__name__iexact=value)


def _assigned(actor: Any, who: str, task: Any) -> Any:
    rows = TaskAssignee.objects.filter(task_id=task)
    if who.lower() == "me":
        return rows.filter(user=actor)
    return rows.filter(
        Q(user__profile__display_name__icontains=who) | Q(user__email__icontains=who)
    )


def _slice(rows: Any, offset: int, size: int) -> tuple[list[Any], bool]:
    page = list(rows[offset : offset + size + 1])
    return page[:size], len(page) > size


def _task_hits(entries: list[SearchEntry], words: list[str]) -> list[Hit]:
    from infrastructure.search.index import plain

    tasks = Task.objects.select_related("project", "status").in_bulk([e.task_id for e in entries])
    hits = []
    for entry in entries:
        task = tasks[entry.task_id]
        text, spans = snippet(plain(task.description), words)
        hits.append(
            Hit(
                kind="task",
                id=str(task.pk),
                title=task.title,
                title_marks=marks(task.title, words),
                project_id=str(task.project_id),
                task_id=str(task.pk),
                key=f"{task.project.key}-{task.number}",
                project_name=task.project.name,
                status=task.status.name,
                snippet=text,
                snippet_marks=spans,
                updated_at=task.updated_at.isoformat(),
            )
        )
    return hits


def _comment_hits(entries: list[SearchEntry], words: list[str]) -> list[Hit]:
    comments = Comment.objects.select_related("author__profile").in_bulk(
        [e.ref_id for e in entries]
    )
    tasks = Task.objects.select_related("project", "status").in_bulk([e.task_id for e in entries])
    hits = []
    for entry in entries:
        comment, task = comments[entry.ref_id], tasks[entry.task_id]
        text, spans = snippet(index.plain(comment.body), words)
        hits.append(
            Hit(
                kind="comment",
                id=str(comment.pk),
                title=task.title,
                project_id=str(task.project_id),
                task_id=str(task.pk),
                key=f"{task.project.key}-{task.number}",
                project_name=task.project.name,
                status=task.status.name,
                author=display_name(comment.author),
                snippet=text,
                snippet_marks=spans,
                updated_at=(comment.edited_at or comment.created_at).isoformat(),
            )
        )
    return hits


def _doc_hits(
    actor: Any, workspace: Workspace, parsed: Parsed, offset: int, size: int, mine: Exists
) -> tuple[list[Hit], bool]:
    """Pages the caller may open (the restriction rules are part of the id list, so a restricted
    page is never matched, counted or snippeted for someone outside it); archived ones are left
    out."""
    from infrastructure.docs import reach
    from infrastructure.docs.models import Doc

    # ponytail: the permitted ids are computed in Python and passed as an IN list.
    readable = reach.readable(actor, workspace).filter(archived_at__isnull=True)
    rows = SearchEntry.objects.filter(
        workspace=workspace, kind="doc", doc_id__in=readable.values("pk")
    )
    page, more = _slice(matching.match(rows, parsed.words, mine), offset, size)
    docs = Doc.objects.select_related("content", "project").in_bulk([e.doc_id for e in page])
    hits = []
    for entry in page:
        doc = docs[entry.doc_id]
        text, spans = snippet(index.plain_blocks(doc.content.blocks), parsed.words)
        hits.append(
            Hit(
                kind="doc",
                id=str(doc.pk),
                title=doc.title,
                title_marks=marks(doc.title, parsed.words),
                project_id=str(doc.project_id or ""),
                project_name=doc.project.name if doc.project else "",
                snippet=text,
                snippet_marks=spans,
                updated_at=doc.updated_at.isoformat(),
            )
        )
    return hits, more


def _words_filter(words: list[str], *fields: str) -> Q:
    where = Q()
    for word in words:
        any_field = Q()
        for name in fields:
            any_field |= Q(**{f"{name}__icontains": word})
        where &= any_field
    return where


def _project_hits(
    actor: Any, workspace: Workspace, words: list[str], offset: int, size: int
) -> tuple[list[Hit], bool]:
    rows = Project.objects.visible_to(actor, workspace).filter(
        _words_filter(words, "name", "key", "description")
    )
    page, more = _slice(
        rows.order_by(F("archived_at").asc(nulls_first=True), "name", "id"), offset, size
    )
    return (
        [
            Hit(
                kind="project",
                id=str(p.pk),
                title=p.name,
                title_marks=marks(p.name, words),
                project_id=str(p.pk),
                key=p.key,
                snippet=p.description[:160],
                updated_at=p.updated_at.isoformat(),
            )
            for p in page
        ],
        more,
    )


def _member_hits(
    workspace: Workspace, words: list[str], offset: int, size: int
) -> tuple[list[Hit], bool]:
    rows = WorkspaceMember.objects.filter(workspace=workspace, status=MemberStatus.ACTIVE).filter(
        _words_filter(words, "user__profile__display_name", "user__email", "user__username")
    )
    page, more = _slice(
        rows.select_related("user__profile").order_by("user__profile__display_name", "user_id"),
        offset,
        size,
    )
    hits = []
    for member in page:
        name = display_name(member.user)
        hits.append(
            Hit(
                kind="member",
                id=str(member.user_id),
                title=name,
                title_marks=marks(name, words),
                snippet=member.user.email,
            )
        )
    return hits, more


def _jump(actor: Any, workspace: Workspace, text: str) -> Hit | None:
    found = _ID.match(text)
    if not found:
        return None
    visible = Project.objects.visible_to(actor, workspace)
    task = (
        Task.objects.select_related("project", "status")
        .filter(
            project__in=visible,
            project__key__iexact=found.group(1),
            number=int(found.group(2)),
            deleted_at__isnull=True,
        )
        .first()
    )
    if task is None:
        return None
    return _task_hits([SearchEntry(task_id=task.pk)], [])[0]


def query(
    actor: Any,
    workspace: Workspace,
    text: str,
    kinds: list[str],
    cursor: str = "",
    page_size: int = 0,
) -> Page:
    """Everything of the wanted ``kinds`` (all four when empty) that matches ``text``, grouped by
    kind, ``page_size`` each from the ``cursor`` offset; ``next_cursor`` is set when any group has
    more."""
    access.require(actor, VIEW, workspace)
    unknown = [k for k in kinds if k not in KINDS]
    if unknown:
        raise _invalid(f"Unknown type {unknown[0]!r}.")
    text = text.strip()
    if len(text) > MAX_TEXT:
        raise _invalid("That search is too long.")
    _throttle(actor)
    size = min(max(page_size or DEFAULT_PAGE, 1), MAX_PAGE)
    offset = _offset(cursor)
    wanted = list(kinds or KINDS)
    parsed = parse(text)
    empty = Page({k: [] for k in wanted}, None, "")
    if not parsed.words and not parsed.has_operator:
        return empty
    more = False
    hits: dict[str, list[Hit]] = {k: [] for k in wanted}
    jump = _jump(actor, workspace, text) if not cursor else None
    with matching.session():
        entry_kinds = [k for k in wanted if k in ("task", "comment")]
        mine = Exists(TaskAssignee.objects.filter(task_id=OuterRef("task_id"), user=actor))
        for kind in entry_kinds:
            rows = _task_rows(actor, workspace, [kind], parsed)
            page, has_more = _slice(matching.match(rows, parsed.words, mine), offset, size)
            hits[kind] = (_task_hits if kind == "task" else _comment_hits)(page, parsed.words)
            more = more or has_more
        if not parsed.has_operator and parsed.words:
            if "doc" in wanted:
                hits["doc"], has_more = _doc_hits(actor, workspace, parsed, offset, size, mine)
                more = more or has_more
            if "project" in wanted:
                hits["project"], has_more = _project_hits(
                    actor, workspace, parsed.words, offset, size
                )
                more = more or has_more
            if "member" in wanted and access.can(actor, "member.view", workspace).allowed:
                hits["member"], has_more = _member_hits(workspace, parsed.words, offset, size)
                more = more or has_more
    return Page(hits, jump, str(offset + size) if more else "")


def remember(actor: Any, workspace: Workspace, text: str) -> None:
    """Keep ``text`` as the newest recent query (the person opened a result for it)."""
    access.require(actor, VIEW, workspace)
    _throttle(actor)
    text = " ".join(text.split())[:MAX_TEXT]
    if len(fold(text)) < MIN_REMEMBERED:
        return
    SearchHistory.objects.update_or_create(
        user=actor, workspace=workspace, query=text, defaults={"at": timezone.now()}
    )
    keep = SearchHistory.objects.filter(user=actor, workspace=workspace).order_by("-at", "-id")
    stale = list(keep.values_list("pk", flat=True)[HISTORY_LIMIT:])
    if stale:
        SearchHistory.objects.filter(pk__in=stale).delete()


def recent(actor: Any, workspace: Workspace) -> list[str]:
    access.require(actor, VIEW, workspace)
    rows = SearchHistory.objects.filter(user=actor, workspace=workspace).order_by("-at", "-id")
    return list(rows.values_list("query", flat=True)[:HISTORY_LIMIT])
