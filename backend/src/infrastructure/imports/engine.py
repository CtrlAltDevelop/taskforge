"""Running an import: a structure pass, then the tasks level by level in chunks, then the links.

Every chunk is one transaction and every row it makes has an ``ImportedRef`` in that same
transaction, so a run that stops anywhere (crash, cancel, error) leaves only whole chunks, and
running the job again skips what is there and goes on. Nothing is queried per task: numbers are
taken for the whole chunk, ranks are counted in memory, rows go in with ``bulk_create``.

The audit log gets one entry for the whole import (the per-row signals are not sent by bulk
writes), and open clients see the new tasks when they next read the project.
"""

import logging
import uuid
from collections.abc import Iterator
from datetime import datetime
from typing import Any, Final, NamedTuple

from django.contrib.auth import get_user_model
from django.db import transaction
from django.db.models import F
from django.utils import timezone

from infrastructure.audit import context as audit_context
from infrastructure.audit import recorder
from infrastructure.audit.models import ActorType, AuditEntry
from infrastructure.common.errors import ApiError
from infrastructure.imports import files, parsers, prepare, richtext
from infrastructure.imports import mapping as mapping_rules
from infrastructure.imports import scan as scanning
from infrastructure.imports.models import ImportedRef, ImportJob, PlaceholderAssignment
from infrastructure.imports.models import Status as JobStatus
from infrastructure.imports.prepare import Run
from infrastructure.imports.records import Problem, RIssue
from infrastructure.projects.models import Project
from infrastructure.search import index as search_index
from infrastructure.sprints.models import EventKind, ScopeEvent, State
from infrastructure.tasks import rank, tree
from infrastructure.tasks.models import Task, TaskAssignee
from infrastructure.workspaces.models import Workspace

logger = logging.getLogger(__name__)
CHUNK: Final = 200
STALE_AFTER_SECONDS: Final = 120
TITLE_MAX: Final = 500


class Cancelled(Exception):  # noqa: N818 -- a person's choice, not an error
    pass


class Superseded(Exception):  # noqa: N818 -- another run owns the job now: this one just stops
    pass


BEAT_EVERY: Final = 1000  # items read between two heartbeats while only streaming


def _stream(job: ImportJob, run: Run, head: dict[str, Any]) -> Iterator[RIssue | Problem]:
    binary = files.open_job(job)
    try:
        for n, item in enumerate(parsers.parse(job.source, binary, run.mapping, head), 1):
            if n % BEAT_EVERY == 0:
                _heartbeat(job)  # a long read is a live run, not a dead one
            yield item
    finally:
        binary.close()


def _heartbeat(job: ImportJob, **fields: Any) -> None:
    """Show the run is alive; stop it when a person cancelled, or when another run has taken over
    the job (a tick that thought this one was dead): two runs must never write at once."""
    mine = ImportJob.objects.filter(pk=job.pk, status=JobStatus.RUNNING, run_token=job.run_token)
    if not mine.update(heartbeat_at=timezone.now(), **fields):
        state = ImportJob.objects.filter(pk=job.pk).values_list("status", flat=True).first()
        raise Cancelled if state == JobStatus.CANCELLED else Superseded


class Structure:
    """Depth of every issue (0: top level) and its resolved parent (a source id), from what the
    scan saw. A parent that is missing, cyclic or too deep makes the issue a top-level one, with a
    warning."""

    def __init__(self, run: Run, found: scanning.Scan) -> None:
        self.depth: dict[str, int] = {}
        self.parent: dict[str, str] = {}
        self._parents: frozenset[str] | None = None
        self._run, self._known = run, found.ids
        wanted = {k: found.keys.get(v, v) for k, v in found.parents.items()}
        for source_id in found.ids:
            self._settle(source_id, wanted)

    def _settle(self, start: str, wanted: dict[str, str]) -> None:
        """Give ``start`` and its unsettled ancestors their depth, walking up without recursion
        (a chain can be thousands long)."""
        chain: list[str] = []
        seen: set[str] = set()
        node = start
        while node not in self.depth:
            if node in seen:  # a loop: the issue where we came round starts a tree again
                self._run.warn(0, f"{node} is its own ancestor: imported as a top-level task.")
                self.depth[node] = 0
                chain.remove(node)
                break
            seen.add(node)
            chain.append(node)
            parent = wanted.get(node)
            if parent and parent in self._known and parent != node:
                node = parent
                continue
            if parent == node:
                self._run.warn(0, f"{node} is its own ancestor: imported as a top-level task.")
            elif parent:
                self._run.warn(
                    0,
                    f"Parent {parent} of {node} is not in the file: imported as a top-level task.",
                )
            self.depth[node] = 0
            chain.pop()
            break
        for member in reversed(chain):
            parent = wanted[member]
            depth = self.depth[parent] + 1
            if depth > tree.MAX_DEPTH:
                self._run.warn(
                    0, f"{member} is nested deeper than {tree.MAX_DEPTH} levels: made top-level."
                )
                depth = 0
            else:
                self.parent[member] = parent
            self.depth[member] = depth

    @property
    def parents_of_others(self) -> frozenset[str]:
        if self._parents is None:
            self._parents = frozenset(self.parent.values())
        return self._parents

    @property
    def levels(self) -> int:
        return max(self.depth.values(), default=0) + 1


class Node(NamedTuple):
    """Where a task sits in the tree: all a child needs to place itself under it."""

    pk: Any
    depth: int
    path: str
    tree_key: str


class Nodes:
    """Where the tasks that have children sit in the tree, by source id (only parents are kept,
    so memory follows the number of parents, not of issues)."""

    def __init__(self) -> None:
        self.by_source: dict[str, Any] = {}
        self.last: dict[Any, str | None] = {}

    def next_position(self, project_id: Any, parent_id: Any) -> str:
        if parent_id not in self.last:
            last = (
                Task.objects.filter(project_id=project_id, parent_id=parent_id)
                .order_by("-position")
                .values_list("position", flat=True)
                .first()
            )
            self.last[parent_id] = last
        position = rank.after(self.last[parent_id])
        self.last[parent_id] = position
        return position


def _load_nodes(run: Run, nodes: Nodes, parents: frozenset[str]) -> None:
    ids = {
        sid: eid for (kind, sid), eid in run.existing.items() if kind == "task" and sid in parents
    }
    for chunk_start in range(0, len(ids), 1000):
        chunk = dict(list(ids.items())[chunk_start : chunk_start + 1000])
        rows = {
            r.pk: r
            for r in Task.objects.filter(
                pk__in=list(chunk.values()),
                project=run.project,  # a parent made into another project cannot be a parent here
                deleted_at__isnull=True,
            ).only("id", "depth", "path", "tree_key")
        }
        for sid, eid in chunk.items():
            if eid in rows:
                row = rows[eid]
                nodes.by_source[sid] = Node(row.pk, row.depth, row.path, row.tree_key)


def _author(run: Run, person: Any) -> Any:
    return run.users.get(person.key) if person else None


def _day_text(value: datetime | None) -> str:
    return value.date().isoformat() if value else ""


def _task_row(
    run: Run, issue: RIssue, number: int, parent: Any, nodes: Nodes, now: datetime
) -> Task:
    project = run.project
    assert project is not None
    task_id = uuid.uuid4()
    position = nodes.next_position(project.pk, parent.pk if parent else None)
    depth, path, tree_key = tree.placement(parent, task_id, position)
    status = run.statuses.get(issue.status) or run.default_status
    priority = run.mapping["priorities"].get(issue.priority) or mapping_rules.priority_of(
        issue.priority
    )
    start, due = issue.start, issue.due
    if start and due and due < start:
        run.warn(
            issue.line,
            f"{issue.key or issue.source_id}: due before start; the start is dropped.",
        )
        start = None
    sprint = run.sprints.get(issue.sprints[-1].name) if issue.sprints else None
    created = issue.created or now
    return Task(
        id=task_id,
        workspace=run.workspace,
        project=project,
        number=number,
        title=(issue.title.strip() or "Untitled")[:TITLE_MAX],
        description=richtext.to_doc(issue.body, issue.body_format),
        status=status,
        priority=priority,
        start_date=start,
        due_date=due,
        estimate_sec=min(issue.estimate_sec, 100 * 24 * 3600) if issue.estimate_sec else None,
        points=issue.points,
        sprint=sprint,
        created_by=_author(run, issue.reporter) or run.creator,
        position=position,
        parent_id=parent.pk if parent else None,
        depth=depth,
        path=path,
        tree_key=tree_key,
        created_at=created,
        updated_at=issue.updated or created,
    )


def _assign(run: Run, issue: RIssue, task: Task, assignees: list[Any], holders: list[Any]) -> None:
    for person in issue.assignees:
        user = run.users.get(person.key)
        if user is not None:
            if run.project_members is not None and user.pk not in run.project_members:
                run.warn(
                    issue.line, f"{person.name} cannot open this private project: not assigned."
                )
            else:
                assignees.append(TaskAssignee(task=task, user=user))
        elif person.key in run.placeholders:
            holders.append(
                PlaceholderAssignment(task=task, placeholder=run.placeholders[person.key])
            )


def _comments(run: Run, issue: RIssue, task: Task) -> tuple[list[Any], list[ImportedRef]]:
    from infrastructure.comments.models import Comment

    made, refs = [], []
    for c in issue.comments:
        doc = richtext.to_doc(c.body, c.body_format)
        if not doc:
            continue
        author = _author(run, c.author)
        if author is None and c.author is not None:
            stamp = c.created.date().isoformat() if c.created else ""
            note = {
                "type": "paragraph",
                "content": [
                    {
                        "type": "text",
                        "text": f"{c.author.name} wrote{f' on {stamp}' if stamp else ''}:",
                        "marks": [{"type": "italic"}],
                    }
                ],
            }
            doc = {"type": "doc", "content": [note, *doc.get("content", [])]}
        row = Comment(
            workspace=run.workspace,
            task=task,
            author=author or run.creator,
            body=doc,
            created_at=c.created or task.created_at,
        )
        made.append(row)
        refs.append(
            ImportedRef(
                workspace=run.workspace,
                job=run.job,
                family=run.family,
                entity_type="comment",
                source_id=f"{issue.source_id}:{c.source_id}"[:300],
                entity_id=row.pk,
            )
        )
    return made, refs


def _values(run: Run, issue: RIssue, task: Task) -> list[Any]:
    from infrastructure.customfields.models import FieldValue

    out = []
    if run.label_field is not None and issue.labels:
        ids = [
            run.label_options[x.casefold()]
            for x in issue.labels
            if x.casefold() in run.label_options
        ]
        if ids:
            out.append(FieldValue(task=task, field=run.label_field, value_json=ids))
    for name, wire in issue.extra.items():
        field_row = run.fields.get(name)
        if field_row is None or wire == "":
            continue
        try:
            from infrastructure.customfields import types, values

            stored = types.clean_value(
                field_row.type,
                field_row.options,
                wire,
                values.user_check(run.project),  # type: ignore[arg-type]
            )
        except ApiError:
            run.warn(
                issue.line, f"The value of {name!r} on {issue.source_id} was not valid: left empty."
            )
            continue
        out.append(
            FieldValue(
                task=task,
                field=field_row,
                value_text=stored.text,
                value_number=stored.number,
                value_date=stored.day,
                value_json=stored.json,
            )
        )
    return out


def _scope_events(tasks: list[Task], now: datetime) -> list[ScopeEvent]:
    """Tasks made into a sprint that is already running are a scope change on its burndown."""
    return [
        ScopeEvent(
            sprint=t.sprint,
            task=t,
            kind=EventKind.ADDED,
            delta_points=t.points or 0,
            delta_tasks=1,
            after_start=True,
            at=now,
        )
        for t in tasks
        if t.sprint is not None and t.sprint.state == State.ACTIVE
    ]


def _history(run: Run, issues: list[RIssue], tasks: list[Task], now: datetime) -> list[AuditEntry]:
    """The history line of each imported task: where it came from, who wrote it there and when
    (the task itself keeps the importer as its author when that person is not a member)."""
    return [
        AuditEntry(
            workspace=run.workspace.pk,
            actor=str(run.creator.pk),
            actor_type=ActorType.SYSTEM,
            action="task.imported",
            target_type="task",
            target_id=str(task.pk),
            project=task.project_id,
            changes={
                "source": run.family,
                "key": issue.key,
                "author": issue.reporter.name if issue.reporter else "",
                "created_at": task.created_at.isoformat(),
                "job": str(run.job.pk),
            },
            at=now,
        )
        for issue, task in zip(issues, tasks, strict=True)
    ]


def _chunk(run: Run, nodes: Nodes, issues: list[RIssue], structure: Structure) -> None:
    """Make ``issues`` (all of one depth) in one transaction."""
    from infrastructure.comments.models import Comment
    from infrastructure.customfields.models import FieldValue

    now = timezone.now()
    with transaction.atomic(), audit_context.suppressed():
        project = Project.objects.select_for_update().get(pk=run.project.pk)  # type: ignore[union-attr]
        first = project.task_counter + 1
        Project.objects.filter(pk=project.pk).update(task_counter=F("task_counter") + len(issues))
        tasks: list[Task] = []
        assignees: list[TaskAssignee] = []
        holders: list[PlaceholderAssignment] = []
        comments: list[Any] = []
        refs: list[ImportedRef] = []
        values: list[Any] = []
        for offset, issue in enumerate(issues):
            parent_source = structure.parent.get(issue.source_id)
            parent = nodes.by_source.get(parent_source) if parent_source else None
            if parent_source and parent is None:
                run.warn(
                    issue.line,
                    f"{issue.key or issue.source_id}: parent not in this project: top-level.",
                )
            task = _task_row(run, issue, first + offset, parent, nodes, now)
            tasks.append(task)
            _assign(run, issue, task, assignees, holders)
            made, comment_refs = _comments(run, issue, task)
            comments += made
            refs += comment_refs
            values += _values(run, issue, task)
            meta: dict[str, Any] = {"key": issue.key, "type": issue.issue_type}
            if issue.reporter:
                meta["author"] = issue.reporter.name
            if issue.attachments:
                meta["attachments"] = [
                    {"filename": a.filename, "size": a.size, "url": a.url}
                    for a in issue.attachments
                ][:50]
            refs.append(
                ImportedRef(
                    workspace=run.workspace,
                    job=run.job,
                    family=run.family,
                    entity_type="task",
                    source_id=issue.source_id,
                    entity_id=task.pk,
                    meta=meta,
                )
            )
        Task.objects.bulk_create(tasks)
        TaskAssignee.objects.bulk_create(assignees, ignore_conflicts=True)
        PlaceholderAssignment.objects.bulk_create(holders, ignore_conflicts=True)
        Comment.objects.bulk_create(comments)
        FieldValue.objects.bulk_create(values, ignore_conflicts=True)
        ImportedRef.objects.bulk_create(refs)  # a clash rolls the whole chunk back
        search_index.add_many(tasks, comments)
        AuditEntry.objects.bulk_create(_history(run, issues, tasks, now))
        ScopeEvent.objects.bulk_create(_scope_events(tasks, now))
        for issue, task in zip(issues, tasks, strict=True):
            if issue.source_id in structure.parents_of_others:
                nodes.by_source[issue.source_id] = Node(
                    task.pk, task.depth, task.path, task.tree_key
                )
            run.existing[("task", issue.source_id)] = task.pk
        run.count("tasks", len(tasks))
        run.count("comments", len(comments))
        run.count("assignments", len(assignees) + len(holders))
        _heartbeat(run.job, done=F("done") + len(tasks))


def _pending(
    run: Run, head: dict[str, Any], structure: Structure, level: int
) -> Iterator[list[RIssue]]:
    batch: list[RIssue] = []
    seen: set[str] = set()
    for item in _stream(run.job, run, head):
        if isinstance(item, Problem):
            continue
        if (
            item.source_id in seen
            or structure.depth.get(item.source_id) != level
            or ("task", item.source_id) in run.existing
        ):
            continue
        seen.add(item.source_id)
        batch.append(item)
        if len(batch) == CHUNK:
            yield batch
            batch = []
    if batch:
        yield batch


# -- links ---------------------------------------------------------------------------------


def _edges(run: Run, head: dict[str, Any], keys: dict[str, str]) -> set[tuple[Any, Any, str]]:
    """The links of every issue as ``(from_task, to_task, type)``, a ``relates`` pair once."""
    out: set[tuple[Any, Any, str]] = set()
    for item in _stream(run.job, run, head):
        if isinstance(item, Problem) or not item.links:
            continue
        mine = run.existing.get(("task", item.source_id))
        for link in item.links:
            other = run.existing.get(("task", keys.get(link.target_id, link.target_id)))
            if mine is None or other is None or mine == other:
                run.warn(
                    item.line,
                    f"{item.key or item.source_id}: link to {link.target_id} is outside: skipped.",
                )
                continue
            if link.kind == "blocks":
                out.add((mine, other, "blocks"))
            elif link.kind == "blocked_by":
                out.add((other, mine, "blocks"))
            else:
                a, b = sorted((mine, other), key=str)
                out.add((a, b, "relates"))
    return out


def _existing_blocks(ends: set[Any]) -> set[tuple[Any, Any]]:
    """The blocking links already stored between (or from) these tasks, from an earlier run."""
    from infrastructure.tasks.models import TaskLink

    found: set[tuple[Any, Any]] = set()
    wanted = sorted(ends, key=str)
    for start in range(0, len(wanted), 1000):
        part = wanted[start : start + 1000]
        rows = TaskLink.objects.filter(type="blocks", from_task_id__in=part)
        found.update(rows.values_list("from_task_id", "to_task_id"))
    return found


def _without_cycles(run: Run, edges: set[tuple[Any, Any, str]]) -> set[tuple[Any, Any, str]]:
    """Drop the blocking links that would close a loop (A blocks B blocks A): nothing could ever
    be finished. Depth-first in a fixed order (so a resumed run drops the same edge as the first
    one would have) over the links made earlier as well as these; only a link of this run is ever
    dropped."""
    ordered = sorted(edges, key=lambda e: (str(e[0]), str(e[1]), e[2]))
    graph: dict[Any, list[Any]] = {}
    blocks = [(a, b) for a, b, kind in ordered if kind == "blocks"]
    ends = {x for pair in blocks for x in pair}
    for a, b in sorted(_existing_blocks(ends), key=lambda e: (str(e[0]), str(e[1]))):
        graph.setdefault(a, []).append(b)
    for a, b in blocks:
        graph.setdefault(a, []).append(b)
    mine = set(blocks)
    state: dict[Any, int] = {}
    bad: set[tuple[Any, Any]] = set()

    def children(node: Any) -> Iterator[Any]:
        return (c for c in graph.get(node, []) if (node, c) not in bad)  # lazily: drops apply

    for root in sorted(graph, key=str):
        if root in state:
            continue
        path = [root]
        stack = [children(root)]
        state[root] = 1
        while stack:
            nxt = next(stack[-1], None)
            if nxt is None:
                state[path.pop()] = 2
                stack.pop()
            elif state.get(nxt) == 1:
                # A loop: take out one of its links that this run is making (the closing one
                # first, then back along the path); links stored earlier are never touched.
                loop = [(path[-1], nxt)]
                at = path.index(nxt)
                loop += [(path[k], path[k + 1]) for k in range(len(path) - 2, at - 1, -1)]
                cut = next((e for e in loop if e in mine), None)
                if cut is not None:
                    bad.add(cut)
            elif nxt not in state:
                state[nxt] = 1
                path.append(nxt)
                stack.append(children(nxt))
    dropped = {e for e in blocks if e in bad}
    if dropped:
        run.warn(0, f"{len(dropped)} blocking link(s) would have formed a loop and were skipped.")
    return {e for e in edges if not (e[2] == "blocks" and (e[0], e[1]) in dropped)}


def _links(run: Run, head: dict[str, Any], keys: dict[str, str]) -> None:
    from infrastructure.tasks.models import TaskLink

    edges = _without_cycles(run, _edges(run, head, keys))
    fresh = [e for e in edges if ("link", f"{e[0]}>{e[1]}:{e[2]}") not in run.existing]
    for start in range(0, len(fresh), 1000):
        part = fresh[start : start + 1000]
        with transaction.atomic(), audit_context.suppressed():
            rows = [
                TaskLink(
                    workspace=run.workspace,
                    from_task_id=a,
                    to_task_id=b,
                    type=t,
                    created_by=run.creator,
                )
                for a, b, t in part
            ]
            TaskLink.objects.bulk_create(rows, ignore_conflicts=True)
            ImportedRef.objects.bulk_create(
                [
                    ImportedRef(
                        workspace=run.workspace,
                        job=run.job,
                        family=run.family,
                        entity_type="link",
                        source_id=f"{a}>{b}:{t}",
                        entity_id=row.pk,
                    )
                    for (a, b, t), row in zip(part, rows, strict=True)
                ],
            )
            run.count("links", len(rows))
        _heartbeat(run.job)


# -- the run -------------------------------------------------------------------------------


def _header(job: ImportJob) -> dict[str, Any]:
    if job.source != "taskforge":
        return {}
    binary = files.open_job(job)
    try:
        from infrastructure.imports.parsers import taskforge

        return taskforge.header(binary)
    finally:
        binary.close()


def _merge_stats(job: ImportJob, run: Run) -> dict[str, Any]:
    stats = dict(job.stats or {})
    for name, n in run.stats.items():
        stats[name] = stats.get(name, 0) + n
    return stats


def execute(job: ImportJob) -> None:
    workspace: Workspace = job.workspace
    run = Run(job, workspace, job.created_by, parsers.FAMILY[job.source], job.mapping)
    head = _header(job)
    binary = files.open_job(job)
    try:
        found = scanning.scan(job.source, binary, run.mapping, head, beat=lambda: _heartbeat(job))
    finally:
        binary.close()
    for problem in found.analysis.problems:
        run.warn(problem.line, problem.message, problem.level)
    prepare.load_existing(run)
    prepare.prepare(run, found, head)
    structure = Structure(run, found)
    nodes = Nodes()
    _load_nodes(run, nodes, structure.parents_of_others)
    already = sum(1 for sid in found.ids if ("task", sid) in run.existing)
    ImportJob.objects.filter(pk=job.pk).update(
        total=found.analysis.issues, done=already, phase="tasks"
    )
    for level in range(structure.levels):
        for chunk in _pending(run, head, structure, level):
            _chunk(run, nodes, chunk, structure)
    if found.analysis.links:
        ImportJob.objects.filter(pk=job.pk).update(phase="links")
        _links(run, head, found.keys)
    tree.refresh_project(run.project.pk)  # type: ignore[union-attr]
    _finish(job, run)


def tell_clients(project_id: Any) -> None:
    """One ``project.updated`` event: open clients read the project's tasks again (a bulk write
    sends none of the per-task events)."""
    from infrastructure.sync import publish

    project = Project.objects.filter(pk=project_id).first()
    if project is not None:
        publish.record(
            entity_type="project",
            entity_id=project.pk,
            workspace_id=project.workspace_id,
            project_id=project.pk,
            version=project.version,
            action="updated",
        )


def _finish(job: ImportJob, run: Run) -> None:
    token = job.run_token
    job.refresh_from_db()
    if job.run_token != token or job.status != JobStatus.RUNNING:
        raise Cancelled if job.status == JobStatus.CANCELLED else Superseded
    stats = _merge_stats(job, run)
    with transaction.atomic():
        recorder.record(
            workspace_id=job.workspace_id,
            action="import.completed",
            target_type="import",
            target_id=job.pk,
            project_id=run.project.pk if run.project else None,
            actor=job.created_by,
            actor_type="system",
            changes={
                "source": job.source,
                "created": {
                    k: v
                    for k, v in stats.items()
                    if not k.endswith("s")
                    or k
                    in (
                        "tasks",
                        "comments",
                        "links",
                        "sprints",
                        "statuses",
                        "placeholders",
                        "assignments",
                    )
                },
            },
        )
        ImportJob.objects.filter(
            pk=job.pk, status=JobStatus.RUNNING, run_token=job.run_token
        ).update(
            status=JobStatus.DONE,
            phase="",
            stats=stats,
            error_report=(job.error_report + run.problems)[:1000],
            error="",
            finished_at=timezone.now(),
            heartbeat_at=timezone.now(),
            version=F("version") + 1,
        )
    if run.project is not None:
        tell_clients(run.project.pk)


def run_job(job_id: Any) -> None:
    """Run (or resume) a queued job to its end; its row says how it went."""
    token = uuid.uuid4()
    claimed = ImportJob.objects.filter(pk=job_id, status=JobStatus.QUEUED).update(
        status=JobStatus.RUNNING,
        run_token=token,
        started_at=timezone.now(),
        heartbeat_at=timezone.now(),
        attempts=F("attempts") + 1,
        error="",
    )
    if not claimed:
        return
    job = ImportJob.objects.select_related("workspace", "created_by", "project").get(pk=job_id)
    mine = ImportJob.objects.filter(pk=job_id, run_token=token)  # only the owner writes the end
    try:
        execute(job)
    except Superseded:
        return  # another run owns the job now; it will say how it went
    except Cancelled:
        mine.update(status=JobStatus.CANCELLED, finished_at=timezone.now())
    except Exception as error:  # noqa: BLE001 -- recorded on the job; Start again resumes
        logger.exception("import %s failed", job_id)
        reason = (
            str(error)
            if isinstance(error, ApiError)
            else "The import stopped on an unexpected error."
        )
        mine.filter(status=JobStatus.RUNNING).update(
            status=JobStatus.FAILED, error=reason[:500], finished_at=timezone.now()
        )


def resume_stalled(now: datetime | None = None) -> int:
    """Queue the runs whose heartbeat stopped (the process died); returns how many."""
    from datetime import timedelta

    from infrastructure.imports import queue

    moment = now or timezone.now()
    stale = list(
        ImportJob.objects.filter(
            status=JobStatus.RUNNING,
            heartbeat_at__lt=moment - timedelta(seconds=STALE_AFTER_SECONDS),
        ).values_list("pk", flat=True)
    )
    for job_id in stale:
        if ImportJob.objects.filter(pk=job_id, status=JobStatus.RUNNING).update(
            status=JobStatus.QUEUED, run_token=None
        ):
            queue.run_later(run_job, job_id)
    return len(stale)


get_user_model  # noqa: B018 -- kept for type-checkers that resolve the user model lazily
