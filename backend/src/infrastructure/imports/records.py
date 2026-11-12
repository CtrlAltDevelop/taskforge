"""What every parser produces: one neutral shape for an issue, whatever tool it came from."""

from dataclasses import dataclass, field
from datetime import date, datetime
from decimal import Decimal


@dataclass(frozen=True, slots=True)
class Person:
    """Someone named in a file. ``key`` is what the mapping is keyed by: the email when there is
    one (lower case), else the name."""

    name: str
    email: str = ""

    @property
    def key(self) -> str:
        return (self.email or self.name).strip().lower()


@dataclass(frozen=True, slots=True)
class RComment:
    source_id: str
    body: str
    body_format: str = "text"
    author: Person | None = None
    created: datetime | None = None


@dataclass(frozen=True, slots=True)
class RLink:
    """``kind`` is ``blocks``, ``blocked_by`` or ``relates`` from this issue's side."""

    kind: str
    target_id: str  # the other issue's source id (or key; the engine resolves both)


@dataclass(frozen=True, slots=True)
class RSprint:
    name: str
    state: str = ""  # closed | active | future, as the source says
    start: date | None = None
    end: date | None = None


@dataclass(frozen=True, slots=True)
class RAttachment:
    filename: str
    size: int = 0
    url: str = ""


@dataclass(slots=True)
class RIssue:
    source_id: str
    title: str
    key: str = ""
    body: str = ""
    body_format: str = "text"
    status: str = ""
    priority: str = ""
    issue_type: str = ""
    assignees: tuple[Person, ...] = ()
    reporter: Person | None = None
    created: datetime | None = None
    updated: datetime | None = None
    start: date | None = None
    due: date | None = None
    labels: tuple[str, ...] = ()
    sprints: tuple[RSprint, ...] = ()
    parent_id: str = ""
    points: Decimal | None = None
    estimate_sec: int | None = None
    comments: tuple[RComment, ...] = ()
    links: tuple[RLink, ...] = ()
    attachments: tuple[RAttachment, ...] = ()
    extra: dict[str, str] = field(default_factory=dict)  # columns a CSV mapping may pick from
    line: int = 0  # the row or position in the file, for messages


@dataclass(slots=True)
class Problem:
    """A row that could not be read, or something worth a warning (never fatal)."""

    line: int
    message: str
    level: str = "error"  # error | warning


@dataclass(slots=True)
class Analysis:
    """What a first pass over the file learned: the choices a person has to map."""

    source: str
    issues: int = 0
    statuses: dict[str, int] = field(default_factory=dict)
    priorities: dict[str, int] = field(default_factory=dict)
    people: dict[str, str] = field(default_factory=dict)  # key -> display name
    issue_types: dict[str, int] = field(default_factory=dict)
    labels: int = 0
    sprints: list[str] = field(default_factory=list)
    comments: int = 0
    links: int = 0
    subtasks: int = 0
    columns: list[str] = field(default_factory=list)  # CSV only
    sample: list[dict[str, str]] = field(default_factory=list)  # CSV only: the first rows
    problems: list[Problem] = field(default_factory=list)
