"""The sources an import can read, one parser each, all producing ``records.RIssue``."""

from collections.abc import Iterator
from typing import IO, Any, Final

from infrastructure.imports.parsers import clickup_json, jira_json, tabular, taskforge
from infrastructure.imports.records import Problem, RIssue

SOURCES: Final = {
    "jira_csv": "Jira (CSV export)",
    "jira_json": "Jira (JSON)",
    "clickup_csv": "ClickUp (CSV export)",
    "clickup_json": "ClickUp (JSON)",
    "csv": "Any CSV file",
    "taskforge": "TaskForge export (tasks.json)",
}
FAMILY: Final = {
    "jira_csv": "jira",
    "jira_json": "jira",
    "clickup_csv": "clickup",
    "clickup_json": "clickup",
    "csv": "csv",
    "taskforge": "taskforge",
}
CSV_SOURCES: Final = frozenset({"jira_csv", "clickup_csv", "csv"})


def is_csv(source: str) -> bool:
    return source in CSV_SOURCES


def parse(
    source: str,
    binary: IO[bytes],
    mapping: dict[str, Any] | None = None,
    head: dict[str, Any] | None = None,
) -> Iterator[RIssue | Problem]:
    """Every issue of the file, in file order, as ``RIssue`` (or a ``Problem`` for a row that
    cannot be read). The file is read as a stream."""
    if source in CSV_SOURCES:
        return tabular.parse(source, binary, (mapping or {}).get("columns"))
    if source == "jira_json":
        return jira_json.parse(binary)
    if source == "clickup_json":
        return clickup_json.parse(binary)
    return taskforge.parse(binary, head)
