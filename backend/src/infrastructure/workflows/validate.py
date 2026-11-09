"""Workflow rules that need no database: what a draft must satisfy to be saved.

Rules: 2+ statuses with at least one *not started* and one *done*; exactly one default, which is
not a final status; unique case-insensitive names of 1-40 characters; known category; a colour is
``#RRGGBB`` or empty; at most 30 statuses. Transitions name real, distinct statuses, once each.
When transitions are restricted, every status must be reachable from the default, a *done* status
must be reachable, and a status that is not final (done / cancelled) must lead somewhere.
"""

import re
from collections import deque
from typing import Final

from infrastructure.workflows.drafts import Problem, WorkflowDraft
from infrastructure.workflows.models import Category

NAME_MAX: Final = 40
STATUS_MAX: Final = 30
COLOR: Final = re.compile(r"#[0-9A-Fa-f]{6}")
FINAL: Final = frozenset({Category.DONE, Category.CANCELLED})


def _status_problems(draft: WorkflowDraft) -> list[Problem]:
    problems: list[Problem] = []
    seen_keys: set[str] = set()
    seen_names: set[str] = set()
    for status in draft.statuses:
        if status.key in seen_keys:
            problems.append(Problem("STATUS_KEY_DUPLICATE", "A status appears twice.", status.key))
        seen_keys.add(status.key)
        name = status.name.strip()
        if not name or len(name) > NAME_MAX:
            problems.append(
                Problem(
                    "STATUS_NAME_INVALID", f"A name must be 1-{NAME_MAX} characters.", status.key
                )
            )
        elif name.lower() in seen_names:
            problems.append(
                Problem("STATUS_NAME_TAKEN", f"Two statuses are called {name}.", status.key)
            )
        seen_names.add(name.lower())
        if status.category not in Category.values:
            problems.append(
                Problem("STATUS_CATEGORY_INVALID", f"{name}: unknown category.", status.key)
            )
        if status.color and not COLOR.fullmatch(status.color):
            problems.append(
                Problem("STATUS_COLOR_INVALID", f"{name}: colour is #RRGGBB.", status.key)
            )
    if len(draft.statuses) > STATUS_MAX:
        problems.append(
            Problem("TOO_MANY_STATUSES", f"A project can have at most {STATUS_MAX} statuses.")
        )
    return problems


def _shape_problems(draft: WorkflowDraft) -> list[Problem]:
    categories = {s.category for s in draft.statuses}
    problems: list[Problem] = []
    if Category.NOT_STARTED not in categories:
        problems.append(Problem("NO_NOT_STARTED_STATUS", 'There must be a "Not started" status.'))
    if Category.DONE not in categories:
        problems.append(Problem("NO_DONE_STATUS", 'There must be a "Done" status.'))
    defaults = [s for s in draft.statuses if s.is_default]
    if not defaults:
        problems.append(Problem("NO_DEFAULT_STATUS", "Choose the status new tasks start in."))
    elif len(defaults) > 1:
        problems.append(Problem("MANY_DEFAULT_STATUSES", "Only one status can be the default."))
    elif defaults[0].category in FINAL:
        problems.append(
            Problem(
                "DEFAULT_IS_FINAL",
                f"{defaults[0].name}: new tasks cannot start Done or Cancelled.",
                defaults[0].key,
            )
        )
    return problems


def _transition_problems(draft: WorkflowDraft) -> list[Problem]:
    keys = {s.key for s in draft.statuses}
    problems: list[Problem] = []
    seen: set[tuple[str, str]] = set()
    for t in draft.transitions:
        if t.from_key not in keys or t.to_key not in keys:
            problems.append(Problem("TRANSITION_UNKNOWN_STATUS", "A transition names no status."))
        elif t.from_key == t.to_key:
            problems.append(
                Problem("TRANSITION_TO_SELF", "A status cannot lead to itself.", t.from_key)
            )
        elif (t.from_key, t.to_key) in seen:
            problems.append(
                Problem("TRANSITION_DUPLICATE", "A transition is listed twice.", t.from_key)
            )
        seen.add((t.from_key, t.to_key))
    return problems


def _graph_problems(draft: WorkflowDraft) -> list[Problem]:
    default = next((s for s in draft.statuses if s.is_default), None)
    if default is None:
        return []
    edges: dict[str, set[str]] = {s.key: set() for s in draft.statuses}
    for t in draft.transitions:
        if t.from_key in edges and t.to_key in edges and t.from_key != t.to_key:
            edges[t.from_key].add(t.to_key)
    reached = {default.key}
    queue = deque([default.key])
    while queue:
        for nxt in edges[queue.popleft()] - reached:
            reached.add(nxt)
            queue.append(nxt)
    problems = [
        Problem("STATUS_UNREACHABLE", f"{s.name} can never be reached.", s.key)
        for s in draft.statuses
        if s.key not in reached
    ]
    if not any(s.category == Category.DONE and s.key in reached for s in draft.statuses):
        problems.append(Problem("NO_DONE_REACHABLE", "No Done status can be reached."))
    problems += [
        Problem("STATUS_DEAD_END", f"{s.name} leads nowhere.", s.key)
        for s in draft.statuses
        if s.category not in FINAL and not edges[s.key]
    ]
    return problems


def validate(draft: WorkflowDraft) -> list[Problem]:
    """Every problem with ``draft`` (empty when it can be saved)."""
    problems = _status_problems(draft) + _shape_problems(draft) + _transition_problems(draft)
    if draft.restrict:
        problems += _graph_problems(draft)
    return problems
