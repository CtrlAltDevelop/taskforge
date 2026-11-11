"""Docs rules on the services: tree, saves, history, access, links, search, sync."""

import json
from datetime import timedelta
from typing import Any

import pytest
from django.utils import timezone

from infrastructure.common.errors import ApiError
from infrastructure.common.responses import ResponseTitle
from infrastructure.docs import reach, revisions, services
from infrastructure.docs.models import Doc, DocLink, DocRevision, LinkKind
from infrastructure.docs.tests.conftest import body, card, make_task, mention, page, para
from infrastructure.projects import services as projects
from infrastructure.search import index
from infrastructure.search import services as search
from infrastructure.sync.models import ChangeLog
from infrastructure.workspaces import access
from infrastructure.workspaces.models import MemberStatus, WorkspaceMember


def pk(doc: Any) -> str:
    return str(doc.pk)


def edit(team: Any, doc: Any, version: int, *blocks: Any, actor: Any = None, **more: str) -> Any:
    changes = {"blocks": body(*blocks), **more}
    return services.update(actor or team.owner, team.ws, pk(doc), version, changes)


def refused(call: Any, status: int | None = None, title: ResponseTitle | None = None) -> ApiError:
    with pytest.raises(ApiError) as error:
        call()
    if status is not None:
        assert error.value.status == status
    if title is not None:
        assert error.value.title is title
    return error.value


# -- tree and content ------------------------------------------------------------------------


def test_nested_pages_and_content_survive_a_reload(team: Any) -> None:
    root = page(team, "Root", blocks=body(para("hello")))
    child = page(team, "Child", parent=root)
    page(team, "Second root")

    got = services.get(team.member, team.ws, pk(root))
    tree = services.tree(team.member, team.ws)

    assert got.body().blocks[0]["content"][0]["text"] == "hello"
    assert [d.title for d in tree] == ["Root", "Child", "Second root"]
    assert tree[1].parent_id == child.parent_id == root.pk
    assert got.can_edit and not got.can_manage


def test_tree_scopes_project_and_workspace_pages_apart(team: Any, web: Any) -> None:
    page(team, "Workspace page")
    page(team, "Project page", project=web)

    assert [d.title for d in services.tree(team.owner, team.ws)] == ["Workspace page"]
    assert [d.title for d in services.tree(team.owner, team.ws, pk(web))] == ["Project page"]


def test_parent_must_share_the_place(team: Any, web: Any) -> None:
    top = page(team, "Top")

    refused(
        lambda: services.create(team.owner, team.ws, pk(web), pk(top), "x"),
        400,
        ResponseTitle.DOC_INVALID,
    )


def test_title_icon_and_depth_limits(team: Any) -> None:
    refused(lambda: services.create(team.owner, team.ws, "", "", "x" * 201), 400)
    refused(lambda: services.create(team.owner, team.ws, "", "", "t", "i" * 33), 400)
    parent = None
    for _ in range(reach.MAX_DEPTH):
        parent = page(team, "L", parent=parent)

    refused(lambda: page(team, "too deep", parent=parent), 400, ResponseTitle.DOC_INVALID)


def test_invalid_body_is_refused_and_stored_clean(team: Any) -> None:
    refused(lambda: page(team, blocks='[{"type": "image", "attrs": {"src": "javascript:x"}}]'))
    doc = page(team, blocks=body({"type": "paragraph", "onclick": "x", "content": []}))

    stored = services.get(team.owner, team.ws, pk(doc)).body().blocks
    assert "onclick" not in stored[0] and stored[0]["id"]


def test_unknown_blocks_are_kept_through_a_save(team: Any) -> None:
    odd = {"id": "k", "type": "whiteboard", "strokes": [1, 2]}
    doc = page(team, blocks=body(odd))

    view = edit(team, doc, 1, odd, para("more"))

    assert view.body().blocks[0] == odd


# -- saving: versions, conflicts, revisions -------------------------------------------------


def test_save_bumps_the_version_and_stale_save_carries_the_server_copy(team: Any) -> None:
    doc = page(team, blocks=body(para("a")))
    edit(team, doc, 1, para("b"), actor=team.member)

    error = refused(lambda: edit(team, doc, 1, para("c")), 409, ResponseTitle.VERSION_CONFLICT)

    assert error.data is not None and error.data["version"] == 2
    assert json.loads(error.data["blocks"])[0]["content"][0]["text"] == "b"
    assert error.data["updated_by"] == str(team.member.pk)


def test_conflict_omits_a_large_body(team: Any) -> None:
    doc = page(team, blocks=body(para("x" * 6000)))
    edit(team, doc, 1, para("y" * 6000))

    error = refused(lambda: edit(team, doc, 1, para("z")), 409, ResponseTitle.VERSION_CONFLICT)

    assert error.data is not None
    assert "blocks" not in error.data and error.data["blocks_omitted"] == "1"


def test_saving_the_same_content_is_not_a_save(team: Any) -> None:
    doc = page(team, "T", blocks=body(para("a")))
    same = services.get(team.owner, team.ws, pk(doc)).body().blocks

    view = services.update(
        team.owner, team.ws, pk(doc), 99, {"title": "T", "blocks": json.dumps(same)}
    )

    assert view.body().version == 1 and DocRevision.objects.filter(doc=doc).count() == 1


def test_title_and_icon_save_and_unknown_field_is_refused(team: Any) -> None:
    doc = page(team, "Old")

    view = services.update(team.owner, team.ws, pk(doc), 1, {"title": " New ", "icon": "x"})

    assert (view.doc.title, view.doc.icon, view.body().version) == ("New", "x", 2)
    refused(lambda: services.update(team.owner, team.ws, pk(doc), 2, {"restricted": "1"}), 400)


def test_bursts_of_editing_fold_into_one_revision_and_old_ones_start_a_new_one(team: Any) -> None:
    doc = page(team, blocks=body(para("0")))
    for n in range(1, 4):
        edit(team, doc, n, para(str(n)))
    assert DocRevision.objects.filter(doc=doc).count() == 1  # one burst, creation included
    last = DocRevision.objects.get(doc=doc)
    assert last.blocks[0]["content"][0]["text"] == "3" and last.version == 4

    DocRevision.objects.filter(doc=doc).update(at=timezone.now() - timedelta(minutes=6))
    edit(team, doc, 4, para("later"))
    assert DocRevision.objects.filter(doc=doc).count() == 2


def test_another_editor_starts_a_new_revision(team: Any) -> None:
    doc = page(team, blocks=body(para("0")))

    edit(team, doc, 1, para("1"), actor=team.member)

    authors = list(
        DocRevision.objects.filter(doc=doc).order_by("id").values_list("author", flat=True)
    )
    assert authors == [team.owner.pk, team.member.pk]


def test_revisions_are_pruned_to_the_limit(team: Any, settings: Any) -> None:
    settings.DOCS_REVISION_KEEP = 3
    doc = page(team, blocks=body(para("0")))
    for n in range(1, 7):
        DocRevision.objects.filter(doc=doc).update(at=timezone.now() - timedelta(minutes=6))
        edit(team, doc, n, para(str(n)))

    rows = list(DocRevision.objects.filter(doc=doc).order_by("id"))
    assert len(rows) == 3 and rows[-1].version == 7
    assert len(services.revision_list(team.owner, team.ws, pk(doc))) == 3
    assert revisions.keep() == 3


def test_restore_an_older_revision_as_a_new_save(team: Any) -> None:
    doc = page(team, "One", blocks=body(para("first")))
    first = DocRevision.objects.get(doc=doc)
    DocRevision.objects.filter(doc=doc).update(at=timezone.now() - timedelta(minutes=6))
    edit(team, doc, 1, para("second"), title="Two")

    peek = services.revision_get(team.viewer, team.ws, pk(doc), first.pk)
    view = services.revision_restore(team.owner, team.ws, pk(doc), first.pk, 2)

    assert peek.blocks[0]["content"][0]["text"] == "first"
    assert view.body().blocks[0]["content"][0]["text"] == "first"
    assert (view.doc.title, view.body().version) == ("One", 3)
    assert DocRevision.objects.filter(doc=doc).count() == 3  # restoring is history too
    refused(lambda: services.revision_restore(team.owner, team.ws, pk(doc), first.pk, 2), 409)
    refused(lambda: services.revision_restore(team.owner, team.ws, pk(doc), 0, 3), 404)
    other = page(team, "Other")
    refused(lambda: services.revision_get(team.owner, team.ws, pk(other), first.pk), 404)


# -- move, archive ---------------------------------------------------------------------------


def test_move_reorders_and_reparents(team: Any) -> None:
    a, b, c = page(team, "A"), page(team, "B"), page(team, "C")

    services.move(team.member, team.ws, pk(c), "", 0)
    services.move(team.member, team.ws, pk(b), pk(a), 5)

    tree = services.tree(team.owner, team.ws)
    assert [(d.title, d.position) for d in tree] == [("C", 0), ("A", 1), ("B", 0)]
    assert Doc.objects.get(pk=b.pk).parent_id == a.pk


def test_move_is_cycle_proof(team: Any) -> None:
    a = page(team, "A")
    b = page(team, "B", parent=a)
    c = page(team, "C", parent=b)

    for target in (a, b, c):
        refused(
            lambda t=target: services.move(team.owner, team.ws, pk(a), pk(t), 0),
            409,
            ResponseTitle.DOC_CYCLE,
        )
    services.move(team.owner, team.ws, pk(c), pk(a), 0)  # a sibling of b is fine


def test_move_refuses_other_places_depth_and_archived_parents(team: Any, web: Any) -> None:
    a, mine = page(team, "A"), page(team, "Mine", project=web)
    refused(lambda: services.move(team.owner, team.ws, pk(a), pk(mine), 0), 400)
    deep = None
    for _ in range(reach.MAX_DEPTH):
        deep = page(team, "L", parent=deep)
    refused(lambda: services.move(team.owner, team.ws, pk(a), pk(deep), 0), 400)
    gone = page(team, "Gone")
    services.archive(team.owner, team.ws, pk(gone))
    refused(
        lambda: services.move(team.owner, team.ws, pk(a), pk(gone), 0),
        409,
        ResponseTitle.DOC_ARCHIVED,
    )
    height = page(team, "Tall", parent=a)
    page(team, "Taller", parent=height)
    anchor = None
    for _ in range(reach.MAX_DEPTH - 2):
        anchor = page(team, "Anchor", parent=anchor)
    refused(lambda: services.move(team.owner, team.ws, pk(a), pk(anchor), 0), 400)


def test_archive_takes_the_subtree_and_restore_brings_back_exactly_it(team: Any) -> None:
    a = page(team, "A")
    b = page(team, "B", parent=a)
    c = page(team, "C", parent=b)
    services.archive(team.owner, team.ws, pk(c))
    services.archive(team.owner, team.ws, pk(a))

    assert services.tree(team.owner, team.ws) == []
    assert len(services.tree(team.owner, team.ws, include_archived=True)) == 3
    refused(
        lambda: services.update(team.owner, team.ws, pk(a), 1, {"title": "x"}),
        409,
        ResponseTitle.DOC_ARCHIVED,
    )
    refused(lambda: services.restore(team.owner, team.ws, pk(b)), 400)

    services.restore(team.owner, team.ws, pk(a))

    assert [d.title for d in services.tree(team.owner, team.ws)] == ["A", "B"]  # C stays archived
    services.restore(team.owner, team.ws, pk(c))
    assert len(services.tree(team.owner, team.ws)) == 3
    assert services.restore(team.owner, team.ws, pk(c)).doc.archived_at is None


def test_archived_project_makes_its_pages_read_only(team: Any, web: Any) -> None:
    doc = page(team, "P", project=web)
    projects.archive(team.owner, team.ws, pk(web), web.version)

    assert services.get(team.owner, team.ws, pk(doc)).can_edit
    refused(lambda: services.update(team.owner, team.ws, pk(doc), 1, {"title": "x"}), 409)
    refused(lambda: page(team, "New", project=web), 409)


# -- permissions and access ------------------------------------------------------------------


def test_permissions(team: Any) -> None:
    doc = page(team, "P")

    assert services.get(team.viewer, team.ws, pk(doc)).can_edit is False
    for call in (
        lambda: page(team, "x", actor=team.viewer),
        lambda: services.update(team.viewer, team.ws, pk(doc), 1, {"title": "x"}),
        lambda: services.move(team.viewer, team.ws, pk(doc), "", 0),
        lambda: services.archive(team.viewer, team.ws, pk(doc)),
        lambda: services.set_access(team.member, team.ws, pk(doc), True, []),
    ):
        assert refused(call).status == 403
    page(team, "ok", actor=team.member)
    assert services.set_access(team.admin, team.ws, pk(doc), False, []).can_manage


def test_other_workspaces_and_removed_members_get_nothing(team: Any) -> None:
    doc = page(team, "P")

    assert refused(lambda: services.tree(team.outsider, team.ws)).status == 403
    assert refused(lambda: services.get(team.outsider, team.ws, pk(doc))).status == 403
    foreign = page(
        team.__class__(**{**team.__dict__, "ws": team.other_ws}), "F", actor=team.outsider
    )
    refused(lambda: services.get(team.owner, team.ws, pk(foreign)), 404)
    WorkspaceMember.objects.filter(workspace=team.ws, user=team.member).update(
        status=MemberStatus.REMOVED
    )
    assert refused(lambda: services.get(team.member, team.ws, pk(doc))).status == 403


def test_restricted_page_and_its_subpages_are_invisible_to_others(team: Any) -> None:
    secret = page(team, "Secret", actor=team.member)
    inner = page(team, "Inner", parent=secret, actor=team.member)
    open_page = page(team, "Open")
    services.set_access(team.owner, team.ws, pk(secret), True, [str(team.viewer.pk)])

    def titles(user: Any) -> list[str]:
        return [d.title for d in services.tree(user, team.ws)]

    assert titles(team.viewer) == ["Secret", "Inner", "Open"]  # listed: sees it and below
    assert titles(team.member) == ["Secret", "Inner", "Open"]  # the creator
    assert titles(team.owner) == ["Secret", "Inner", "Open"]  # doc.manage
    assert titles(team.pm) == ["Open"]
    for doc in (secret, inner):
        refused(lambda d=doc: services.get(team.pm, team.ws, pk(d)), 404)
        refused(lambda d=doc: services.update(team.pm, team.ws, pk(d), 1, {"title": "x"}), 404)
        refused(lambda d=doc: services.revision_list(team.pm, team.ws, pk(d)), 404)
        refused(lambda d=doc: services.backlinks(team.pm, team.ws, pk(d)), 404)
        refused(lambda d=doc: services.touch_presence(team.pm, team.ws, pk(d), "editing"), 404)
    refused(lambda: services.move(team.pm, team.ws, pk(open_page), pk(secret), 0), 404)
    refused(lambda: services.create(team.pm, team.ws, "", pk(secret), "x"), 404)

    services.set_access(team.owner, team.ws, pk(secret), False, [])
    assert titles(team.pm) == ["Secret", "Inner", "Open"]


def test_restriction_stacks_down_the_tree(team: Any) -> None:
    top = page(team, "Top")
    mid = page(team, "Mid", parent=top)
    leaf = page(team, "Leaf", parent=mid)
    services.set_access(team.owner, team.ws, pk(top), True, [str(team.pm.pk)])
    services.set_access(team.owner, team.ws, pk(mid), True, [str(team.viewer.pk)])

    assert [d.title for d in services.tree(team.pm, team.ws)] == ["Top"]
    assert [d.title for d in services.tree(team.viewer, team.ws)] == []
    assert reach.accessible_ids(team.owner, team.ws) == {top.pk, mid.pk, leaf.pk}


def test_set_access_validates_people_and_reports_the_list_to_managers(team: Any) -> None:
    doc = page(team, "P")
    refused(
        lambda: services.set_access(team.owner, team.ws, pk(doc), True, [str(team.outsider.pk)]),
        400,
    )
    refused(lambda: services.set_access(team.owner, team.ws, pk(doc), True, ["nope"]), 400)

    view = services.set_access(team.owner, team.ws, pk(doc), True, [str(team.viewer.pk)])
    again = services.set_access(team.owner, team.ws, pk(doc), True, [str(team.viewer.pk)])

    assert view.access_user_ids == again.access_user_ids == [str(team.viewer.pk)]
    assert services.get(team.viewer, team.ws, pk(doc)).access_user_ids == []
    services.set_access(team.owner, team.ws, pk(doc), True, [])
    assert services.get(team.owner, team.ws, pk(doc)).access_user_ids == []


def test_project_pages_follow_project_visibility(team: Any, secret: Any) -> None:
    doc = page(team, "Plans", project=secret)

    assert [d.title for d in services.tree(team.owner, team.ws, pk(secret))] == ["Plans"]
    assert [d.title for d in services.tree(team.pm, team.ws, pk(secret))] == ["Plans"]
    refused(lambda: services.tree(team.member, team.ws, pk(secret)), 404)
    refused(lambda: services.get(team.member, team.ws, pk(doc)), 404)
    refused(lambda: services.create(team.member, team.ws, pk(secret), "", "x"), 404)
    assert pk(doc) not in {str(i) for i in reach.accessible_ids(team.member, team.ws)}


def test_corrupt_trees_are_closed_not_looped(team: Any) -> None:
    a = page(team, "A")
    b = page(team, "B", parent=a)
    Doc.objects.filter(pk=a.pk).update(parent=b.pk)  # cannot happen through the service

    assert reach.accessible_ids(team.owner, team.ws) == set()
    refused(lambda: services.get(team.owner, team.ws, pk(a)), 404)


# -- links ------------------------------------------------------------------------------------


def test_mentions_and_cards_make_links_that_follow_the_body(team: Any, web: Any) -> None:
    target, task = page(team, "Target"), make_task(team, web)
    doc = page(team, "Source", blocks=body(mention(target.pk), card(task)))

    kinds = set(DocLink.objects.filter(doc=doc).values_list("kind", flat=True))
    assert kinds == {LinkKind.MENTION, LinkKind.TASK_CARD}
    assert [d.title for d in services.backlinks(team.viewer, team.ws, pk(target))] == ["Source"]

    edit(team, doc, 1, para("none"))
    assert DocLink.objects.filter(doc=doc).count() == 0
    assert services.backlinks(team.viewer, team.ws, pk(target)) == []


def test_mentions_of_foreign_pages_and_self_make_no_row(team: Any) -> None:
    foreign = page(
        team.__class__(**{**team.__dict__, "ws": team.other_ws}), "F", actor=team.outsider
    )
    doc = page(team, "Source")

    view = edit(team, doc, 1, mention(foreign.pk), mention(doc.pk))

    assert DocLink.objects.filter(doc=doc).count() == 0
    assert len(view.body().blocks) == 2  # the nodes stay in the body


def test_backlinks_only_list_pages_the_caller_may_open_and_live_ones(team: Any) -> None:
    target = page(team, "Target")
    hidden = page(team, "Hidden", blocks=body(mention(target.pk)))
    gone = page(team, "Gone", blocks=body(mention(target.pk)))
    page(team, "Shown", blocks=body(mention(target.pk)))
    services.set_access(team.owner, team.ws, pk(hidden), True, [])
    services.archive(team.owner, team.ws, pk(gone))

    assert [d.title for d in services.backlinks(team.member, team.ws, pk(target))] == ["Shown"]


def test_task_cards_are_hidden_from_people_without_access(team: Any, web: Any, secret: Any) -> None:
    open_task, private_task = make_task(team, web, "Open"), make_task(team, secret, "Private")
    doc = page(team, "Spec", blocks=body(card(open_task), card(private_task)))

    owner_cards = services.get(team.owner, team.ws, pk(doc)).cards
    member_view = services.get(team.member, team.ws, pk(doc))

    assert [c.hidden for c in owner_cards] == [False, False]
    assert owner_cards[0].key == "WEB-1" and owner_cards[0].title == "Open"
    assert [(c.hidden, c.title) for c in member_view.cards] == [(False, "Open"), (True, "")]
    assert len(member_view.body().blocks) == 2  # kept, so a save never drops it
    deleted = services.task_cards(team.owner, team.ws, [pk(open_task), "bad", str(doc.pk)])
    assert [c.hidden for c in deleted] == [False, True]


def test_for_task_link_and_unlink(team: Any, web: Any, secret: Any) -> None:
    task = make_task(team, web)
    embedded = page(team, "Embeds", blocks=body(card(task)))
    manual = page(team, "Manual")
    hidden = page(team, "Hidden", blocks=body(card(task)))
    services.set_access(team.owner, team.ws, pk(hidden), True, [])

    services.link_task(team.member, team.ws, pk(web), pk(task), pk(manual))
    services.link_task(team.member, team.ws, pk(web), pk(task), pk(manual))  # idempotent
    services.link_task(team.member, team.ws, pk(web), pk(task), pk(embedded))
    rows = services.for_task(team.pm, team.ws, pk(web), pk(task))

    assert {(r.doc.title, r.kind) for r in rows} == {("Embeds", "related"), ("Manual", "related")}
    assert "Hidden" in {
        r.doc.title for r in services.for_task(team.owner, team.ws, pk(web), pk(task))
    }
    left = services.unlink_task(team.member, team.ws, pk(web), pk(task), pk(manual))
    assert {r.doc.title for r in left} == {"Embeds"}
    refused(lambda: services.link_task(team.viewer, team.ws, pk(web), pk(task), pk(manual)), 403)
    private = make_task(team, secret)
    refused(lambda: services.for_task(team.member, team.ws, pk(secret), pk(private)), 404)
    refused(lambda: services.link_task(team.member, team.ws, pk(web), pk(task), "nope"), 404)


def test_embedded_kind_without_a_manual_link(team: Any, web: Any) -> None:
    task = make_task(team, web)
    page(team, "Embeds", blocks=body(card(task)))

    rows = services.for_task(team.viewer, team.ws, pk(web), pk(task))

    assert [(r.doc.title, r.kind) for r in rows] == [("Embeds", "embedded")]


# -- presence ---------------------------------------------------------------------------------


def test_presence_lists_who_is_editing_and_lapses(team: Any) -> None:
    from infrastructure.sync import presence

    presence.reset_store()
    doc = page(team, "P")

    services.touch_presence(team.member, team.ws, pk(doc), "viewing")
    roster = services.touch_presence(team.owner, team.ws, pk(doc), "editing")

    assert {(r["id"], r["editing"]) for r in roster} == {
        (str(team.member.pk), False),
        (str(team.owner.pk), True),
    }
    assert len(services.get(team.viewer, team.ws, pk(doc)).editing) == 2
    assert services.touch_presence(team.owner, team.ws, pk(doc), "left")[0]["id"] == str(
        team.member.pk
    )
    refused(lambda: services.touch_presence(team.owner, team.ws, pk(doc), "dancing"), 400)
    presence.reset_store()


# -- sync and search --------------------------------------------------------------------------


def test_changes_are_announced(team: Any, web: Any) -> None:
    doc = page(team, "P", project=web)
    top = page(team, "Top")
    edit(team, doc, 1, para("x"))
    services.move(team.owner, team.ws, pk(top), "", 0)
    services.archive(team.owner, team.ws, pk(top))
    services.set_access(team.owner, team.ws, pk(doc), True, [])

    rows = ChangeLog.objects.filter(entity_type="doc").order_by("id")
    events = [(r.event_type, r.entity_id == doc.pk, r.project) for r in rows]
    assert events[0] == ("doc.created", True, web.pk)
    assert ("doc.updated", True, web.pk) in events
    assert [r.event_type for r in rows if r.entity_id == top.pk] == [
        "doc.created",
        "doc.moved",
        "doc.updated",
    ]
    assert all(r.workspace_id == team.ws.pk for r in rows)


def hits(team: Any, actor: Any, text: str) -> list[str]:
    return [h.title for h in search.query(actor, team.ws, text, ["doc"]).hits["doc"]]


def test_search_finds_pages_by_title_and_body_and_follows_access(team: Any, secret: Any) -> None:
    open_doc = page(team, "Launch plan", blocks=body(para("zebra rollout")))
    private = page(team, "Private plan", project=secret, blocks=body(para("zebra budget")))
    restricted = page(team, "Restricted plan", blocks=body(para("zebra")))
    services.set_access(team.owner, team.ws, pk(restricted), True, [])

    assert sorted(hits(team, team.owner, "zebra")) == [
        "Launch plan",
        "Private plan",
        "Restricted plan",
    ]
    assert hits(team, team.member, "zebra") == ["Launch plan"]
    assert hits(team, team.member, "launch") == ["Launch plan"]
    assert hits(team, team.owner, "zebra in:SEC") == []  # an operator is about tasks
    edit(team, open_doc, 1, para("giraffe"))
    assert hits(team, team.member, "zebra") == []
    assert hits(team, team.member, "giraffe") == ["Launch plan"]
    services.archive(team.owner, team.ws, pk(open_doc))
    assert hits(team, team.member, "giraffe") == []
    hit = search.query(team.owner, team.ws, "budget", ["doc"]).hits["doc"][0]
    assert (hit.id, hit.project_id, hit.project_name) == (pk(private), pk(secret), secret.name)
    assert access.can(team.viewer, "workspace.view", team.ws).allowed


def test_archived_subpages_drop_out_of_search_and_reindex_rebuilds(team: Any) -> None:
    parent = page(team, "Parent")
    page(team, "Child kiwi", parent=parent)
    services.archive(team.owner, team.ws, pk(parent))

    assert hits(team, team.owner, "kiwi") == []  # the child's row is still there, hidden live
    services.restore(team.owner, team.ws, pk(parent))
    index.reindex(team.ws.pk)
    assert hits(team, team.owner, "kiwi") == ["Child kiwi"]
    index.put_doc(pk(parent))
    index.put_doc("00000000-0000-0000-0000-000000000000")


def test_restricted_pages_are_announced_only_to_people_who_may_open_them(
    team: Any, monkeypatch: pytest.MonkeyPatch
) -> None:
    from infrastructure.docs import reach
    from infrastructure.sync import publish

    secret = page(team, "Secret")
    child = page(team, "Child", parent=secret)
    assert reach.audience(secret) is None

    services.set_access(team.owner, team.ws, pk(secret), True, [str(team.member.pk)])
    secret.refresh_from_db()
    child.refresh_from_db()
    allowed = tuple(sorted({str(team.owner.pk), str(team.member.pk)}))
    assert reach.audience(secret) == allowed
    assert reach.audience(child) == allowed  # restriction runs down the tree

    sent: list[str] = []

    class Broker:
        def publish(self, channel: str, message: dict[str, Any]) -> None:
            sent.append(message["room"])

    monkeypatch.setattr(publish, "get_broker", lambda: Broker())
    publish.record(
        entity_type="doc",
        entity_id=secret.pk,
        workspace_id=team.ws.pk,
        users=reach.audience(secret),
    )
    assert sorted(sent) == sorted(publish.user_room(u) for u in allowed)
    assert publish.workspace_room(team.ws.pk) not in sent
