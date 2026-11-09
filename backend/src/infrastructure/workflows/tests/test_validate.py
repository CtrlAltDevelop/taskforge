"""The pure rules of a workflow draft: no database."""

import pytest

from infrastructure.workflows.drafts import StatusDraft, TransitionDraft, WorkflowDraft
from infrastructure.workflows.validate import validate


def _s(key: str, category: str, *, name: str | None = None, default: bool = False) -> StatusDraft:
    return StatusDraft(key, name or key.title(), "#3F51B5", category, default)


def _draft(
    *statuses: StatusDraft, transitions: tuple[TransitionDraft, ...] = (), restrict: bool = False
) -> WorkflowDraft:
    return WorkflowDraft(tuple(statuses), transitions, restrict)


def _t(a: str, b: str) -> TransitionDraft:
    return TransitionDraft(a, b)


def _codes(draft: WorkflowDraft) -> set[str]:
    return {p.code for p in validate(draft)}


BASIC = (
    _s("todo", "not_started", name="To do", default=True),
    _s("doing", "active", name="Doing"),
    _s("done", "done", name="Done"),
)


def test_the_default_shape_is_valid() -> None:
    assert validate(_draft(*BASIC)) == []


def test_needs_a_not_started_and_a_done_status() -> None:
    no_done = _draft(_s("a", "not_started", default=True), _s("b", "active"))
    no_start = _draft(_s("a", "active", default=True), _s("b", "done"))

    assert "NO_DONE_STATUS" in _codes(no_done)
    assert "NO_NOT_STARTED_STATUS" in _codes(no_start)


def test_exactly_one_default_that_is_not_final() -> None:
    none = _draft(_s("a", "not_started"), _s("b", "done"))
    two = _draft(_s("a", "not_started", default=True), _s("b", "done", default=True))
    final = _draft(_s("a", "not_started"), _s("b", "done", default=True))

    assert "NO_DEFAULT_STATUS" in _codes(none)
    assert "MANY_DEFAULT_STATUSES" in _codes(two)
    assert "DEFAULT_IS_FINAL" in _codes(final)


def test_names_are_required_short_and_unique_ignoring_case() -> None:
    blank = _draft(*BASIC, _s("x", "active", name="  "))
    long = _draft(*BASIC, _s("x", "active", name="n" * 41))
    clash = _draft(*BASIC, _s("x", "active", name="to DO"))

    assert "STATUS_NAME_INVALID" in _codes(blank)
    assert "STATUS_NAME_INVALID" in _codes(long)
    assert "STATUS_NAME_TAKEN" in _codes(clash)


def test_category_and_color_must_be_known() -> None:
    bad_category = _draft(*BASIC, _s("x", "later"))
    bad_color = _draft(*BASIC, StatusDraft("x", "X", "red", "active"))

    assert "STATUS_CATEGORY_INVALID" in _codes(bad_category)
    assert "STATUS_COLOR_INVALID" in _codes(bad_color)
    assert validate(_draft(*BASIC, StatusDraft("x", "X", "", "active"))) == []


def test_at_most_thirty_statuses_and_keys_are_unique() -> None:
    many = _draft(*BASIC, *(_s(f"k{i}", "active", name=f"S{i}") for i in range(28)))
    dup_key = _draft(*BASIC, _s("todo", "active", name="Other"))

    assert "TOO_MANY_STATUSES" in _codes(many)
    assert "STATUS_KEY_DUPLICATE" in _codes(dup_key)


def test_transitions_must_name_real_distinct_statuses_once() -> None:
    unknown = _draft(*BASIC, transitions=(_t("todo", "nope"),))
    loop = _draft(*BASIC, transitions=(_t("todo", "todo"),))
    twice = _draft(*BASIC, transitions=(_t("todo", "doing"), _t("todo", "doing")))

    assert "TRANSITION_UNKNOWN_STATUS" in _codes(unknown)
    assert "TRANSITION_TO_SELF" in _codes(loop)
    assert "TRANSITION_DUPLICATE" in _codes(twice)


def test_unrestricted_workflows_ignore_the_graph() -> None:
    assert validate(_draft(*BASIC, restrict=False)) == []


def test_restricted_workflow_reports_unreachable_and_dead_end_statuses() -> None:
    draft = _draft(*BASIC, transitions=(_t("todo", "done"),), restrict=True)

    problems = {(p.code, p.status_key) for p in validate(draft)}

    assert ("STATUS_UNREACHABLE", "doing") in problems
    assert ("NO_DONE_REACHABLE", "") not in problems


def test_restricted_workflow_needs_a_way_to_done() -> None:
    draft = _draft(*BASIC, transitions=(_t("todo", "doing"), _t("doing", "todo")), restrict=True)

    codes = _codes(draft)

    assert "NO_DONE_REACHABLE" in codes
    assert "STATUS_UNREACHABLE" in codes  # done itself


def test_restricted_dead_end_is_reported_for_non_final_statuses_only() -> None:
    draft = _draft(*BASIC, transitions=(_t("todo", "doing"), _t("todo", "done")), restrict=True)

    problems = {(p.code, p.status_key) for p in validate(draft)}

    assert ("STATUS_DEAD_END", "doing") in problems
    assert ("STATUS_DEAD_END", "done") not in problems


def test_a_connected_restricted_workflow_is_valid() -> None:
    draft = _draft(
        *BASIC,
        transitions=(_t("todo", "doing"), _t("doing", "done"), _t("doing", "todo")),
        restrict=True,
    )

    assert validate(draft) == []


@pytest.mark.parametrize("category", ["not_started", "active", "done", "cancelled"])
def test_every_category_is_accepted(category: str) -> None:
    assert "STATUS_CATEGORY_INVALID" not in _codes(_draft(*BASIC, _s("x", category)))
