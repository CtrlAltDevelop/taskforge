"""Subtasks: a parent link of any depth, cycle prevention, subtree path rewrites, progress that
rolls up in the same transaction, delete modes, and the tree order of the list."""

from typing import Any

import pytest

from infrastructure.common.errors import ApiError
from infrastructure.common.responses import ResponseTitle
from infrastructure.projects import services as projects
from infrastructure.tasks import services, tree
from infrastructure.tasks.models import Task
from infrastructure.workflows import services as workflows
from infrastructure.workflows.drafts import StatusDraft, TransitionDraft, WorkflowDraft
from infrastructure.workflows.models import Status
from infrastructure.workspaces import access

pytestmark = pytest.mark.django_db


def _ids(project: Any) -> dict[str, str]:
    workflows.ensure(project)
    return {s.name: str(s.pk) for s in Status.objects.filter(project=project)}


def _make(team: Any, project: Any, title: str = "T", parent: Task | None = None, **kw: Any) -> Task:
    return services.create(
        team.member,
        team.ws,
        str(project.pk),
        title,
        parent_id=str(parent.pk) if parent else "",
        **kw,
    )


def _fresh(task: Task) -> Task:
    return Task.objects.select_related("status").get(pk=task.pk)


def _done(team: Any, project: Any, task: Task) -> Task:
    return services.move(
        team.member,
        team.ws,
        str(project.pk),
        str(task.pk),
        _fresh(task).version,
        _ids(project)["Done"],
    )


def _chain(team: Any, project: Any, depth: int) -> list[Task]:
    tasks: list[Task] = []
    for i in range(depth):
        tasks.append(_make(team, project, f"L{i}", tasks[-1] if tasks else None))
    return tasks


# ----------------------------------------------------------------------------- creating


def test_a_task_starts_at_the_top_with_its_own_path(team: Any, project: Any) -> None:
    task = _make(team, project)

    assert (task.parent_id, task.depth) == (None, 0)
    assert task.path == f"{task.pk}/"
    assert task.tree_key == f"{task.position}{tree.SEP}"
    assert (task.progress_done, task.progress_total) == (0, 0)


def test_a_subtask_sits_under_its_parent(team: Any, project: Any) -> None:
    parent = _make(team, project, "P")
    child = _make(team, project, "C", parent)
    grandchild = _make(team, project, "G", child)

    assert child.parent_id == parent.pk and child.depth == 1
    assert child.path == f"{parent.pk}/{child.pk}/"
    assert child.tree_key == f"{parent.position}{tree.SEP}{child.position}{tree.SEP}"
    assert grandchild.depth == 2 and grandchild.path.startswith(child.path)
    assert grandchild.path == f"{parent.pk}/{child.pk}/{grandchild.pk}/"


def test_siblings_are_ranked_among_themselves(team: Any, project: Any) -> None:
    parent = _make(team, project)
    a, b = _make(team, project, "a", parent), _make(team, project, "b", parent)
    other_root = _make(team, project, "other")

    assert a.position < b.position
    assert other_root.position > parent.position


def test_eight_levels_nest_and_the_path_keeps_every_ancestor(team: Any, project: Any) -> None:
    chain = _chain(team, project, 8)

    assert [t.depth for t in chain] == list(range(8))
    assert chain[-1].path == "".join(f"{t.pk}/" for t in chain)
    assert tree.ancestor_ids(chain[-1]) == [t.pk for t in chain[:-1]]


def test_depth_has_a_hard_cap(team: Any, project: Any) -> None:
    chain = _chain(team, project, tree.MAX_DEPTH + 1)  # depths 0..MAX_DEPTH
    with pytest.raises(ApiError) as refused:
        _make(team, project, "too deep", chain[-1])
    assert refused.value.status == 400 and "deep" in str(refused.value)


def test_the_parent_must_be_a_live_task_of_the_same_project(team: Any, project: Any) -> None:
    other = team.create(team.owner, "OTH")
    foreign = services.create(team.owner, team.ws, str(other.pk), "foreign")
    gone = _make(team, project, "gone")
    services.delete(team.member, team.ws, str(project.pk), str(gone.pk))

    for parent_id in (str(foreign.pk), str(gone.pk), "nope"):
        with pytest.raises(ApiError) as refused:
            services.create(team.member, team.ws, str(project.pk), "C", parent_id=parent_id)
        assert refused.value.status in (400, 404)
    assert Task.objects.filter(project=project).count() == 1


# --------------------------------------------------------------------------- progress


def test_progress_counts_every_descendant_and_the_done_ones(team: Any, project: Any) -> None:
    parent = _make(team, project, "P")
    a, b = _make(team, project, "a", parent), _make(team, project, "b", parent)
    c = _make(team, project, "c", a)

    assert (_fresh(parent).progress_done, _fresh(parent).progress_total) == (0, 3)
    assert (_fresh(a).progress_done, _fresh(a).progress_total) == (0, 1)

    _done(team, project, c)
    assert (_fresh(parent).progress_done, _fresh(parent).progress_total) == (1, 3)
    assert (_fresh(a).progress_done, _fresh(a).progress_total) == (1, 1)
    assert (_fresh(b).progress_done, _fresh(b).progress_total) == (0, 0)

    _done(team, project, b)
    assert (_fresh(parent).progress_done, _fresh(parent).progress_total) == (2, 3)


def test_progress_follows_a_status_moved_back_out_of_done(team: Any, project: Any) -> None:
    parent = _make(team, project, "P")
    child = _make(team, project, "C", parent)
    done = _done(team, project, child)
    services.move(
        team.member, team.ws, str(project.pk), str(child.pk), done.version, _ids(project)["To do"]
    )

    assert (_fresh(parent).progress_done, _fresh(parent).progress_total) == (0, 1)


def test_a_cancelled_status_does_not_count_as_done(team: Any, project: Any) -> None:
    view = workflows.get(team.admin, team.ws, str(project.pk))
    draft = WorkflowDraft(
        statuses=(
            *(
                StatusDraft(str(s.pk), s.name, s.color, s.category, s.is_default)
                for s in view.statuses
            ),
            StatusDraft("x", "Cancelled", "", "cancelled"),
        )
    )
    saved = workflows.update(team.admin, team.ws, str(project.pk), 1, draft, {})
    cancelled = next(str(s.pk) for s in saved.statuses if s.name == "Cancelled")
    parent = _make(team, project, "P")
    child = _make(team, project, "C", parent)

    services.move(team.member, team.ws, str(project.pk), str(child.pk), 1, cancelled)

    assert (_fresh(parent).progress_done, _fresh(parent).progress_total) == (0, 1)


def test_progress_ignores_deleted_subtasks_and_returns_on_restore(team: Any, project: Any) -> None:
    parent = _make(team, project, "P")
    a, b = _make(team, project, "a", parent), _make(team, project, "b", parent)
    _done(team, project, a)
    pid = str(project.pk)

    services.delete(team.member, team.ws, pid, str(a.pk))
    assert (_fresh(parent).progress_done, _fresh(parent).progress_total) == (0, 1)
    services.restore(team.member, team.ws, pid, str(a.pk))
    assert (_fresh(parent).progress_done, _fresh(parent).progress_total) == (1, 2)
    assert b.pk


# --------------------------------------------------------------------------- set_parent


def test_set_parent_nests_a_task_and_rewrites_the_whole_subtree(team: Any, project: Any) -> None:
    pid = str(project.pk)
    a, b = _make(team, project, "A"), _make(team, project, "B")
    b1 = _make(team, project, "B1", b)
    b2 = _make(team, project, "B2", b1)

    moved = services.set_parent(team.member, team.ws, pid, str(b.pk), 1, str(a.pk))

    assert moved.parent_id == a.pk and moved.depth == 1 and moved.version == 2
    assert moved.path == f"{a.pk}/{b.pk}/"
    b1, b2 = _fresh(b1), _fresh(b2)
    assert (b1.depth, b2.depth) == (2, 3)
    assert b1.path == f"{a.pk}/{b.pk}/{b1.pk}/"
    assert b2.path == f"{a.pk}/{b.pk}/{b1.pk}/{b2.pk}/"
    assert b2.tree_key.startswith(f"{_fresh(a).position}{tree.SEP}")
    assert [(_fresh(a).progress_done, _fresh(a).progress_total)] == [(0, 3)]


def test_set_parent_to_nothing_makes_a_top_level_task_again(team: Any, project: Any) -> None:
    pid = str(project.pk)
    a = _make(team, project, "A")
    b = _make(team, project, "B", a)
    b1 = _make(team, project, "B1", b)

    moved = services.set_parent(team.member, team.ws, pid, str(b.pk), 1, "")

    assert moved.parent_id is None and moved.depth == 0 and moved.path == f"{b.pk}/"
    assert _fresh(b1).path == f"{b.pk}/{b1.pk}/" and _fresh(b1).depth == 1
    assert (_fresh(a).progress_done, _fresh(a).progress_total) == (0, 0)


def test_set_parent_updates_the_progress_of_both_old_and_new_ancestors(
    team: Any, project: Any
) -> None:
    pid = str(project.pk)
    old, new = _make(team, project, "old"), _make(team, project, "new")
    child = _make(team, project, "c", old)
    _done(team, project, child)
    assert (_fresh(old).progress_done, _fresh(old).progress_total) == (1, 1)

    services.set_parent(
        team.member, team.ws, pid, str(child.pk), _fresh(child).version, str(new.pk)
    )

    assert (_fresh(old).progress_done, _fresh(old).progress_total) == (0, 0)
    assert (_fresh(new).progress_done, _fresh(new).progress_total) == (1, 1)


def test_a_task_cannot_become_its_own_ancestor(team: Any, project: Any) -> None:
    pid = str(project.pk)
    a, b, c = _chain(team, project, 3)

    for task, under in ((a, a), (a, b), (a, c), (b, c)):
        with pytest.raises(ApiError) as refused:
            services.set_parent(
                team.member, team.ws, pid, str(task.pk), _fresh(task).version, str(under.pk)
            )
        assert refused.value.status == 400 and "own" in str(refused.value).lower()
        assert refused.value.title is ResponseTitle.SUBTASK_CYCLE
    assert _fresh(a).parent_id is None and _fresh(b).parent_id == a.pk


def test_the_subtree_may_not_grow_past_the_depth_cap(team: Any, project: Any) -> None:
    pid = str(project.pk)
    deep = _chain(team, project, tree.MAX_DEPTH)  # depths 0..MAX_DEPTH-1
    sub = _make(team, project, "sub")
    _make(team, project, "subsub", sub)

    with pytest.raises(ApiError) as refused:  # sub would sit at MAX_DEPTH, subsub at MAX_DEPTH+1
        services.set_parent(team.member, team.ws, pid, str(sub.pk), 1, str(deep[-1].pk))
    assert "deep" in str(refused.value)


def test_set_parent_checks_scope_permissions_and_versions(team: Any, project: Any) -> None:
    pid = str(project.pk)
    other = team.create(team.owner, "OTH")
    foreign = services.create(team.owner, team.ws, str(other.pk), "f")
    a, b = _make(team, project, "A"), _make(team, project, "B")

    with pytest.raises(ApiError):
        services.set_parent(team.member, team.ws, pid, str(a.pk), 1, str(foreign.pk))
    with pytest.raises(access.PermissionDenied):
        services.set_parent(team.viewer, team.ws, pid, str(a.pk), 1, str(b.pk))
    with pytest.raises(ApiError) as bad:
        services.set_parent(team.member, team.ws, pid, str(a.pk), 9, str(b.pk))
    assert bad.value.status == 400

    services.set_parent(team.member, team.ws, pid, str(a.pk), 1, str(b.pk))
    with pytest.raises(ApiError) as conflict:  # someone else re-parented it meanwhile
        services.set_parent(team.admin, team.ws, pid, str(a.pk), 1, "")
    assert conflict.value.title is ResponseTitle.VERSION_CONFLICT
    assert (conflict.value.data or {})["field"] == "parent"


def test_re_parenting_to_the_same_parent_changes_nothing(team: Any, project: Any) -> None:
    a = _make(team, project, "A")
    b = _make(team, project, "B", a)

    same = services.set_parent(team.member, team.ws, str(project.pk), str(b.pk), 1, str(a.pk))

    assert same.version == 1


def test_set_parent_needs_a_writable_project(team: Any, project: Any) -> None:
    a, b = _make(team, project, "A"), _make(team, project, "B")
    projects.archive(team.owner, team.ws, str(project.pk), project.version)

    with pytest.raises(ApiError) as refused:
        services.set_parent(team.member, team.ws, str(project.pk), str(a.pk), 1, str(b.pk))
    assert refused.value.title is ResponseTitle.PROJECT_ARCHIVED


# ------------------------------------------------------------------------------ listing


def test_the_list_shows_only_top_level_tasks_unless_subtasks_are_asked_for(
    team: Any, project: Any
) -> None:
    pid = str(project.pk)
    a = _make(team, project, "A")
    a1 = _make(team, project, "A1", a)
    b = _make(team, project, "B")

    top, _ = services.list_page(team.viewer, team.ws, pid)
    every, _ = services.list_page(team.viewer, team.ws, pid, include_subtasks=True)

    assert [t.pk for t in top] == [a.pk, b.pk]
    assert [t.pk for t in every] == [a.pk, a1.pk, b.pk]  # tree order: a child follows its parent


def test_tree_order_nests_children_after_each_parent_at_any_depth(team: Any, project: Any) -> None:
    a = _make(team, project, "A")
    b = _make(team, project, "B")
    a1, a2 = _make(team, project, "A1", a), _make(team, project, "A2", a)
    a1x = _make(team, project, "A1x", a1)
    b1 = _make(team, project, "B1", b)

    every, _ = services.list_page(team.viewer, team.ws, str(project.pk), include_subtasks=True)

    assert [t.title for t in every] == ["A", "A1", "A1x", "A2", "B", "B1"]
    assert {t.pk for t in every} == {a.pk, a1.pk, a1x.pk, a2.pk, b.pk, b1.pk}


def test_tree_pages_resume_by_cursor_without_gaps_or_repeats(team: Any, project: Any) -> None:
    for i in range(4):
        root = _make(team, project, f"R{i}")
        child = _make(team, project, f"R{i}c", root)
        _make(team, project, f"R{i}cc", child)

    seen: list[str] = []
    cursor, pages = "", 0
    while True:
        page, cursor = services.list_page(
            team.viewer, team.ws, str(project.pk), include_subtasks=True, cursor=cursor, limit=5
        )
        seen += [t.title for t in page]
        pages += 1
        if not cursor:
            break

    expected = [t for i in range(4) for t in (f"R{i}", f"R{i}c", f"R{i}cc")]
    assert seen == expected and pages == 3


def test_filters_apply_to_the_tree_and_deleted_subtasks_are_hidden(team: Any, project: Any) -> None:
    pid = str(project.pk)
    a = _make(team, project, "A")
    kept, gone = _make(team, project, "kept", a), _make(team, project, "gone", a)
    services.delete(team.member, team.ws, pid, str(gone.pk))

    every, _ = services.list_page(team.viewer, team.ws, pid, include_subtasks=True)
    done_only, _ = services.list_page(
        team.viewer, team.ws, pid, include_subtasks=True, status=_ids(project)["Done"]
    )

    assert [t.pk for t in every] == [a.pk, kept.pk]
    assert done_only == []


def test_list_children_returns_direct_children_in_order(team: Any, project: Any) -> None:
    a = _make(team, project, "A")
    c1, c2 = _make(team, project, "c1", a), _make(team, project, "c2", a)
    _make(team, project, "g", c1)

    kids = services.list_children(team.viewer, team.ws, str(project.pk), str(a.pk))

    assert [t.pk for t in kids] == [c1.pk, c2.pk]
    assert services.list_children(team.viewer, team.ws, str(project.pk), str(c2.pk)) == []
    with pytest.raises(ApiError):
        services.list_children(team.viewer, team.ws, str(project.pk), "nope")


# ------------------------------------------------------------------------ deleting


def test_deleting_a_task_with_subtasks_asks_how(team: Any, project: Any) -> None:
    a = _make(team, project, "A")
    _make(team, project, "c", a)
    _make(team, project, "d", a)

    with pytest.raises(ApiError) as refused:
        services.delete(team.member, team.ws, str(project.pk), str(a.pk))

    assert refused.value.status == 400
    assert refused.value.title is ResponseTitle.HAS_SUBTASKS
    assert refused.value.data == {"count": 2}
    assert _fresh(a).deleted_at is None


def test_delete_subtree_deletes_every_descendant_together(team: Any, project: Any) -> None:
    pid = str(project.pk)
    a, b, c = _chain(team, project, 3)
    sibling = _make(team, project, "sibling", a)

    services.delete(team.member, team.ws, pid, str(a.pk), mode="subtree")

    for task in (a, b, c, sibling):
        assert _fresh(task).deleted_at is not None
    stamps = {_fresh(t).deleted_at for t in (a, b, c, sibling)}
    assert len(stamps) == 1, "one moment, so a restore can bring the whole batch back"


def test_delete_promote_moves_the_children_up_to_the_grandparent(team: Any, project: Any) -> None:
    pid = str(project.pk)
    root = _make(team, project, "root")
    mid = _make(team, project, "mid", root)
    kid = _make(team, project, "kid", mid)
    grandkid = _make(team, project, "grandkid", kid)

    services.delete(team.member, team.ws, pid, str(mid.pk), mode="promote")

    kid, grandkid = _fresh(kid), _fresh(grandkid)
    assert _fresh(mid).deleted_at is not None
    assert kid.parent_id == root.pk and kid.depth == 1 and kid.path == f"{root.pk}/{kid.pk}/"
    assert grandkid.depth == 2 and grandkid.path == f"{root.pk}/{kid.pk}/{grandkid.pk}/"
    assert (_fresh(root).progress_done, _fresh(root).progress_total) == (0, 2)


def test_delete_promote_of_a_top_level_task_makes_its_children_top_level(
    team: Any, project: Any
) -> None:
    root = _make(team, project, "root")
    kid = _make(team, project, "kid", root)

    services.delete(team.member, team.ws, str(project.pk), str(root.pk), mode="promote")

    assert _fresh(kid).parent_id is None and _fresh(kid).path == f"{kid.pk}/"


def test_an_unknown_delete_mode_is_refused(team: Any, project: Any) -> None:
    a = _make(team, project, "A")
    with pytest.raises(ApiError) as refused:
        services.delete(team.member, team.ws, str(project.pk), str(a.pk), mode="burn")
    assert refused.value.status == 400


def test_a_task_without_subtasks_deletes_as_before(team: Any, project: Any) -> None:
    a = _make(team, project, "A")

    gone = services.delete(team.member, team.ws, str(project.pk), str(a.pk))

    assert gone.deleted_at is not None


def test_restoring_a_parent_brings_back_the_subtasks_deleted_with_it(
    team: Any, project: Any
) -> None:
    pid = str(project.pk)
    a = _make(team, project, "A")
    early = _make(team, project, "early", a)
    late = _make(team, project, "late", a)
    services.delete(team.member, team.ws, pid, str(early.pk))  # deleted on its own first
    services.delete(team.member, team.ws, pid, str(a.pk), mode="subtree")

    services.restore(team.member, team.ws, pid, str(a.pk))

    assert _fresh(a).deleted_at is None and _fresh(late).deleted_at is None
    assert _fresh(early).deleted_at is not None, "it was deleted separately and stays in the trash"
    assert (_fresh(a).progress_done, _fresh(a).progress_total) == (0, 1)


def test_restoring_a_subtask_whose_parent_is_still_deleted_makes_it_top_level(
    team: Any, project: Any
) -> None:
    pid = str(project.pk)
    a = _make(team, project, "A")
    kid = _make(team, project, "kid", a)
    services.delete(team.member, team.ws, pid, str(kid.pk))
    services.delete(team.member, team.ws, pid, str(a.pk))

    back = services.restore(team.member, team.ws, pid, str(kid.pk))

    assert back.parent_id is None and back.depth == 0 and back.path == f"{kid.pk}/"


# ---------------------------------------------------------- moving a parent with subtasks


def test_moving_a_parent_with_subtasks_can_take_the_open_ones_along(
    team: Any, project: Any
) -> None:
    pid = str(project.pk)
    parent = _make(team, project, "P")
    a = _make(team, project, "a", parent)
    b = _make(team, project, "b", a)
    finished = _done(team, project, _make(team, project, "fin", parent))

    moved = services.move(
        team.member, team.ws, pid, str(parent.pk), 1, _ids(project)["Done"], with_subtasks=True
    )

    assert moved.status.name == "Done"
    for task in (a, b):
        assert _fresh(task).status.name == "Done" and _fresh(task).version == 2
    assert _fresh(finished).version == finished.version, "already done: left alone"
    assert (_fresh(parent).progress_done, _fresh(parent).progress_total) == (3, 3)


def test_moving_a_parent_alone_leaves_its_subtasks_open(team: Any, project: Any) -> None:
    parent = _make(team, project, "P")
    kid = _make(team, project, "k", parent)

    services.move(team.member, team.ws, str(project.pk), str(parent.pk), 1, _ids(project)["Done"])

    assert _fresh(kid).status.name == "To do"


def test_moving_with_subtasks_is_all_or_nothing_under_a_restricted_workflow(
    team: Any, project: Any
) -> None:
    pid = str(project.pk)
    ids = _ids(project)
    view = workflows.get(team.admin, team.ws, pid)
    draft = WorkflowDraft(
        statuses=tuple(
            StatusDraft(str(s.pk), s.name, s.color, s.category, s.is_default) for s in view.statuses
        ),
        transitions=(
            TransitionDraft(ids["To do"], ids["In progress"]),
            TransitionDraft(ids["In progress"], ids["Done"]),
        ),
        restrict=True,
    )
    workflows.update(team.admin, team.ws, pid, 1, draft, {})
    parent = _make(team, project, "P", status=ids["In progress"])
    kid = _make(team, project, "k", parent)  # To do: cannot jump to Done

    with pytest.raises(ApiError) as refused:
        services.move(team.member, team.ws, pid, str(parent.pk), 1, ids["Done"], with_subtasks=True)

    assert refused.value.title is ResponseTitle.TRANSITION_NOT_ALLOWED
    assert _fresh(parent).status.name == "In progress" and _fresh(parent).version == 1
    assert _fresh(kid).status.name == "To do"


# ------------------------------------------------------ workflow condition: subtasks done


def _require_subtasks(team: Any, project: Any) -> dict[str, str]:
    pid = str(project.pk)
    ids = _ids(project)
    view = workflows.get(team.admin, team.ws, pid)
    draft = WorkflowDraft(
        statuses=tuple(
            StatusDraft(str(s.pk), s.name, s.color, s.category, s.is_default) for s in view.statuses
        ),
        transitions=(
            TransitionDraft(ids["To do"], ids["In progress"]),
            TransitionDraft(ids["In progress"], ids["Done"], require_subtasks_done=True),
        ),
        restrict=True,
    )
    workflows.update(team.admin, team.ws, pid, 1, draft, {})
    return ids


def test_a_move_can_require_every_subtask_to_be_done(team: Any, project: Any) -> None:
    ids = _require_subtasks(team, project)
    pid = str(project.pk)
    parent = _make(team, project, "P", status=ids["In progress"])
    kid = _make(team, project, "k", parent)
    grandkid = _make(team, project, "g", kid)

    with pytest.raises(ApiError) as refused:
        services.move(team.member, team.ws, pid, str(parent.pk), 1, ids["Done"])
    assert refused.value.title is ResponseTitle.TRANSITION_NOT_ALLOWED
    assert "subtasks" in (refused.value.data or {})["reason"]
    assert "2" in (refused.value.data or {})["reason"], "says how many are open"

    for task in (grandkid, kid):
        services.update(
            team.member,
            team.ws,
            pid,
            str(task.pk),
            _fresh(task).version,
            {"status": ids["In progress"]},
        )
        _done(team, project, task)

    assert (
        services.move(team.member, team.ws, pid, str(parent.pk), 1, ids["Done"]).status.name
        == "Done"
    )


def test_the_subtask_condition_counts_deleted_subtasks_as_gone(team: Any, project: Any) -> None:
    ids = _require_subtasks(team, project)
    pid = str(project.pk)
    parent = _make(team, project, "P", status=ids["In progress"])
    kid = _make(team, project, "k", parent)
    services.delete(team.member, team.ws, pid, str(kid.pk))

    moved = services.move(team.member, team.ws, pid, str(parent.pk), 1, ids["Done"])

    assert moved.status.name == "Done"


def test_the_subtask_condition_also_holds_when_moving_with_subtasks(
    team: Any, project: Any
) -> None:
    ids = _require_subtasks(team, project)
    pid = str(project.pk)
    parent = _make(team, project, "P", status=ids["In progress"])
    _make(team, project, "k", parent, status=ids["In progress"])

    # Taking the subtasks along finishes them in the same step, so the condition is met.
    moved = services.move(
        team.member, team.ws, pid, str(parent.pk), 1, ids["Done"], with_subtasks=True
    )

    assert moved.status.name == "Done"


# --------------------------------------------------------------------------- isolation


def test_a_subtask_never_crosses_projects_or_workspaces(team: Any, project: Any) -> None:
    other = team.create(team.owner, "OTH")
    theirs = services.create(team.owner, team.ws, str(other.pk), "theirs")
    mine = _make(team, project, "mine")

    with pytest.raises(ApiError):
        services.set_parent(team.member, team.ws, str(project.pk), str(mine.pk), 1, str(theirs.pk))
    with pytest.raises(ApiError):
        services.set_parent(team.member, team.ws, str(other.pk), str(theirs.pk), 1, str(mine.pk))
    with pytest.raises(ApiError):
        services.list_children(team.viewer, team.ws, str(project.pk), str(theirs.pk))


def test_private_project_subtasks_are_as_hidden_as_their_tasks(team: Any) -> None:
    private = team.create(team.owner, "PRV", visibility="private")
    root = services.create(team.owner, team.ws, str(private.pk), "root")
    services.create(team.owner, team.ws, str(private.pk), "kid", parent_id=str(root.pk))

    with pytest.raises(ApiError) as hidden:
        services.list_children(team.member, team.ws, str(private.pk), str(root.pk))
    assert hidden.value.status == 404


# ------------------------------------------------------ review findings: progress and moves


def test_a_workflow_save_that_changes_a_category_recounts_the_progress(
    team: Any, project: Any
) -> None:
    pid = str(project.pk)
    parent = _make(team, project, "P")
    a, b = _make(team, project, "a", parent), _make(team, project, "b", parent)
    _done(team, project, a)
    _done(team, project, b)
    assert (_fresh(parent).progress_done, _fresh(parent).progress_total) == (2, 2)
    view = workflows.get(team.admin, team.ws, pid)
    draft = WorkflowDraft(
        statuses=tuple(
            StatusDraft(
                str(s.pk),
                s.name,
                s.color,
                "active" if s.name == "Done" else s.category,
                s.is_default,
            )
            for s in view.statuses
        )
        + (StatusDraft("fin", "Finished", "", "done"),)
    )

    workflows.update(team.admin, team.ws, pid, view.workflow.version, draft, {})

    assert (_fresh(parent).progress_done, _fresh(parent).progress_total) == (0, 2)


def test_a_workflow_save_that_migrates_tasks_into_done_recounts_the_progress(
    team: Any, project: Any
) -> None:
    pid = str(project.pk)
    ids = _ids(project)
    parent = _make(team, project, "P")
    _make(team, project, "k", parent, status=ids["In progress"])
    assert (_fresh(parent).progress_done, _fresh(parent).progress_total) == (0, 1)
    view = workflows.get(team.admin, team.ws, pid)
    draft = WorkflowDraft(
        statuses=tuple(
            StatusDraft(str(s.pk), s.name, s.color, s.category, s.is_default)
            for s in view.statuses
            if s.name != "In progress"
        )
    )

    workflows.update(
        team.admin, team.ws, pid, view.workflow.version, draft, {ids["In progress"]: ids["Done"]}
    )

    assert (_fresh(parent).progress_done, _fresh(parent).progress_total) == (1, 1)


def test_many_ancestors_are_recounted_in_one_pass_and_agree_with_the_small_path(
    team: Any, project: Any
) -> None:
    chain = _chain(team, project, 12)
    _done(team, project, chain[-1])
    Task.objects.filter(project=project).update(progress_done=0, progress_total=0)

    tree.refresh_progress([t.pk for t in chain])  # more than the per-task threshold

    # Each task counts the tasks below it; the finished leaf has none of its own.
    assert [(_fresh(t).progress_done, _fresh(t).progress_total) for t in chain] == [
        (1 if i < 11 else 0, 11 - i) for i in range(12)
    ]


def test_complete_all_leaves_cancelled_and_done_subtasks_alone(team: Any, project: Any) -> None:
    pid = str(project.pk)
    view = workflows.get(team.admin, team.ws, pid)
    draft = WorkflowDraft(
        statuses=(
            *(
                StatusDraft(str(s.pk), s.name, s.color, s.category, s.is_default)
                for s in view.statuses
            ),
            StatusDraft("x", "Cancelled", "", "cancelled"),
        )
    )
    saved = workflows.update(team.admin, team.ws, pid, 1, draft, {})
    ids = {s.name: str(s.pk) for s in saved.statuses}
    parent = _make(team, project, "P")
    cancelled = _make(team, project, "c", parent, status=ids["Cancelled"])
    finished = _done(team, project, _make(team, project, "f", parent))
    open_one = _make(team, project, "o", parent)

    services.move(team.member, team.ws, pid, str(parent.pk), 1, ids["Done"], with_subtasks=True)

    assert _fresh(cancelled).status.name == "Cancelled" and _fresh(cancelled).version == 1
    assert _fresh(finished).version == finished.version
    assert _fresh(open_one).status.name == "Done"
    # Moving to a cancelled status must not turn finished subtasks into cancelled ones.
    other = _make(team, project, "P2")
    done_kid = _done(team, project, _make(team, project, "dk", other))
    services.move(team.member, team.ws, pid, str(other.pk), 1, ids["Cancelled"], with_subtasks=True)
    assert _fresh(done_kid).status.name == "Done"
    assert (_fresh(other).progress_done, _fresh(other).progress_total) == (1, 1)


def test_the_subtasks_condition_is_only_waived_when_the_subtasks_are_taken_to_done(
    team: Any, project: Any
) -> None:
    pid = str(project.pk)
    ids = _ids(project)
    view = workflows.get(team.admin, team.ws, pid)
    draft = WorkflowDraft(
        statuses=tuple(
            StatusDraft(str(s.pk), s.name, s.color, s.category, s.is_default) for s in view.statuses
        ),
        transitions=(
            TransitionDraft(ids["To do"], ids["In progress"], require_subtasks_done=True),
            TransitionDraft(ids["In progress"], ids["Done"]),
        ),
        restrict=True,
    )
    workflows.update(team.admin, team.ws, pid, 1, draft, {})
    parent = _make(team, project, "P")
    _make(team, project, "k", parent)

    # In progress is not a done status: taking the subtasks along does not finish them.
    with pytest.raises(ApiError) as refused:
        services.move(
            team.member, team.ws, pid, str(parent.pk), 1, ids["In progress"], with_subtasks=True
        )
    assert "subtasks" in (refused.value.data or {})["reason"]


def test_restoring_a_subtask_whose_parent_is_gone_announces_the_re_parenting(
    team: Any, project: Any
) -> None:
    from infrastructure.tasks.signals import task_changed

    pid = str(project.pk)
    parent = _make(team, project, "A")
    kid = _make(team, project, "k", parent)
    services.delete(team.member, team.ws, pid, str(kid.pk))
    services.delete(team.member, team.ws, pid, str(parent.pk))
    seen: list[str] = []

    def listen(sender: Any, **payload: Any) -> None:
        seen.append(payload["action"])

    task_changed.connect(listen)
    try:
        services.restore(team.member, team.ws, pid, str(kid.pk))
    finally:
        task_changed.disconnect(listen)

    assert "reparented" in seen
