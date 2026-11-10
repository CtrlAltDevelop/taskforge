"""A workflow as the editor sends it: plain values, no database. ``validate`` judges one."""

from dataclasses import dataclass


@dataclass(frozen=True, slots=True)
class StatusDraft:
    """``key`` is the status id for an existing one, or any client-chosen text for a new one."""

    key: str
    name: str
    color: str
    category: str
    is_default: bool = False


@dataclass(frozen=True, slots=True)
class TransitionDraft:
    from_key: str
    to_key: str
    required_role_id: str = ""  # only people holding exactly this role may make the move
    require_assignee: bool = False  # the task must have an assignee
    require_subtasks_done: bool = False  # every live subtask must be done (or cancelled)


@dataclass(frozen=True, slots=True)
class WorkflowDraft:
    """``statuses`` is in display order (that order becomes ``Status.position``)."""

    statuses: tuple[StatusDraft, ...]
    transitions: tuple[TransitionDraft, ...] = ()
    restrict: bool = False
    restrict_creation: bool = False


@dataclass(frozen=True, slots=True)
class Problem:
    """One thing wrong with a draft. ``code`` is stable (clients translate it); ``status_key``
    names the status it is about, or is empty for a problem of the whole workflow."""

    code: str
    message: str
    status_key: str = ""
