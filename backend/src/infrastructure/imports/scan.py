"""One pass over a file that learns everything the wizard and the dry run need, keeping only small
summaries (counts, ids, keys), never the issues themselves."""

from collections.abc import Callable
from dataclasses import dataclass, field
from typing import IO, Any, Final

from infrastructure.imports import parsers, richtext
from infrastructure.imports.records import Analysis, Problem, RIssue

MAX_PROBLEMS: Final = 1000
MAX_PEOPLE: Final = 10_000
MAX_DISTINCT: Final = 2000  # statuses, priorities, types, sprints


@dataclass(slots=True)
class Scan:
    analysis: Analysis
    ids: set[str] = field(default_factory=set)
    keys: dict[str, str] = field(default_factory=dict)  # key -> source id
    parents: dict[str, str] = field(default_factory=dict)  # source id -> parent (id or key)
    targets: set[str] = field(default_factory=set)  # link targets named by any issue
    duplicates: int = 0
    due_before_start: int = 0
    long_texts: int = 0
    no_title: int = 0
    undated_sprints: set[str] = field(default_factory=set)
    sprint_names: dict[str, tuple[Any, Any, str]] = field(default_factory=dict)
    labels: set[str] = field(default_factory=set)

    def problem(self, line: int, message: str, level: str = "error") -> None:
        if len(self.analysis.problems) < MAX_PROBLEMS:
            self.analysis.problems.append(Problem(line, message, level))


def _count(table: dict[str, int], value: str) -> None:
    if value and (value in table or len(table) < MAX_DISTINCT):
        table[value] = table.get(value, 0) + 1


def scan(
    source: str,
    binary: IO[bytes],
    mapping: dict[str, Any] | None = None,
    head: dict[str, Any] | None = None,
    beat: Callable[[], None] | None = None,
) -> Scan:
    """``beat`` is called about every thousand issues (a running import uses it to show it is
    alive while it reads)."""
    out = Scan(Analysis(source=source))
    info = out.analysis
    for n, item in enumerate(parsers.parse(source, binary, mapping, head), 1):
        if beat is not None and n % 1000 == 0:
            beat()
        if isinstance(item, Problem):
            out.problem(item.line, item.message)
            if "no title" in item.message:
                out.no_title += 1
            continue
        _take(out, info, item)
    return out


def _take(out: Scan, info: Analysis, issue: RIssue) -> None:
    if issue.source_id in out.ids:
        out.duplicates += 1
        out.problem(
            issue.line,
            f"Issue {issue.key or issue.source_id} appears twice; the first is kept.",
            "warning",
        )
        return
    out.ids.add(issue.source_id)
    info.issues += 1
    if issue.key:
        out.keys[issue.key] = issue.source_id
    if issue.parent_id:
        out.parents[issue.source_id] = issue.parent_id
        info.subtasks += 1
    _count(info.statuses, issue.status)
    _count(info.priorities, issue.priority)
    _count(info.issue_types, issue.issue_type)
    for person in (*issue.assignees, issue.reporter, *(c.author for c in issue.comments)):
        if person and (person.key in info.people or len(info.people) < MAX_PEOPLE):
            info.people.setdefault(person.key, person.name)
    out.labels.update(issue.labels)
    for sprint in issue.sprints:
        if sprint.name not in out.sprint_names and len(out.sprint_names) < MAX_DISTINCT:
            out.sprint_names[sprint.name] = (sprint.start, sprint.end, sprint.state)
    info.comments += len(issue.comments)
    info.links += len(issue.links)
    out.targets.update(link.target_id for link in issue.links)
    if issue.start and issue.due and issue.due < issue.start:
        out.due_before_start += 1
    if len(issue.body) > richtext.TEXT_MAX:
        out.long_texts += 1
    if len(info.sample) < 5:
        info.sample.append({"id": issue.source_id, "title": issue.title, "status": issue.status})


def finish(out: Scan) -> Analysis:
    info = out.analysis
    info.labels = len(out.labels)
    info.sprints = sorted(out.sprint_names)
    return info
