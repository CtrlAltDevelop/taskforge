"""The block schema: what is kept, rebuilt and refused."""

import json
from typing import Any

import pytest

from infrastructure.common.errors import ApiError
from infrastructure.common.responses import ResponseTitle
from infrastructure.docs import blocks

TASK = "11111111-1111-4111-8111-111111111111"
DOC = "22222222-2222-4222-8222-222222222222"


def clean(*raw: Any, version: int = 0) -> blocks.Cleaned:
    return blocks.clean(json.dumps(list(raw)), version)


def test_empty_text_is_an_empty_page() -> None:
    assert blocks.clean("").blocks == []
    assert blocks.clean("[]").blocks == []


def test_every_known_block_is_rebuilt_with_its_attributes() -> None:
    text = [{"type": "text", "text": "x"}]
    made = clean(
        {"type": "paragraph", "content": text},
        {"type": "heading", "attrs": {"level": 9}, "content": text},
        {"type": "bullet_item", "attrs": {"indent": 99}, "content": text},
        {"type": "numbered_item", "content": text},
        {"type": "checklist_item", "attrs": {"checked": True, "indent": 1}, "content": text},
        {"type": "quote", "content": text},
        {"type": "code", "attrs": {"language": "py"}, "text": "a = 1"},
        {"type": "table", "attrs": {"header": True}, "rows": [[text, text]]},
        {"type": "divider"},
        {"type": "image", "attrs": {"src": "https://e.com/a.png", "alt": "A", "width": 50}},
        {"type": "callout", "attrs": {"tone": "nope"}, "content": text},
        {"type": "task_card", "attrs": {"task_id": TASK}},
    ).blocks

    kinds = [b["type"] for b in made]
    assert kinds == [
        "paragraph",
        "heading",
        "bullet_item",
        "numbered_item",
        "checklist_item",
        "quote",
        "code",
        "table",
        "divider",
        "image",
        "callout",
        "task_card",
    ]
    assert made[1]["attrs"]["level"] == 3 and made[2]["attrs"]["indent"] == blocks.MAX_INDENT
    assert made[4]["attrs"] == {"indent": 1, "checked": True}
    assert made[9]["attrs"] == {"src": "https://e.com/a.png", "alt": "A", "width": 50}
    assert made[10]["attrs"]["tone"] == "info"
    assert all(b["id"] for b in made)


def test_unknown_block_and_inline_node_are_kept_untouched() -> None:
    odd = {"id": "k", "type": "whiteboard", "strokes": [1, 2, {"a": None}], "v": 2}
    inline = {"type": "emoji", "code": "smile"}
    made = clean(odd, {"type": "paragraph", "content": [inline]}).blocks

    assert made[0] == odd
    assert made[1]["content"] == [inline]


def test_unknown_mark_is_kept_and_known_marks_are_rebuilt() -> None:
    node = {
        "type": "text",
        "text": "a",
        "marks": [{"type": "bold", "x": 1}, {"type": "wave", "n": 3}],
    }
    out = clean({"type": "paragraph", "content": [node]}).blocks[0]["content"][0]

    assert out["marks"] == [{"type": "bold"}, {"type": "wave", "n": 3}]


@pytest.mark.parametrize(
    "bad",
    [
        {"type": "image", "attrs": {"src": "javascript:alert(1)"}},
        {"type": "image", "attrs": {"src": "data:image/png;base64,AA"}},
        {"type": "task_card", "attrs": {"task_id": "nope"}},
        {"type": "paragraph", "content": [{"type": "mention", "attrs": {"doc_id": "x"}}]},
        {
            "type": "paragraph",
            "content": [
                {
                    "type": "text",
                    "text": "a",
                    "marks": [{"type": "link", "attrs": {"href": "javascript:alert(1)"}}],
                }
            ],
        },
        {"type": "paragraph", "content": "text"},
        {"type": "paragraph", "content": [{"type": "text", "text": 5}]},
        {"text": "no type"},
        {"type": "table", "rows": [[[]] * (blocks.MAX_COLUMNS + 1)]},
    ],
)
def test_bad_blocks_are_refused(bad: dict[str, Any]) -> None:
    with pytest.raises(ApiError) as error:
        clean(bad)

    assert error.value.title is ResponseTitle.DOC_INVALID


def test_text_is_data_and_stray_keys_are_dropped() -> None:
    out = clean(
        {"type": "paragraph", "onclick": "x", "content": [{"type": "text", "text": "<b>x</b>"}]}
    )

    assert out.blocks[0]["content"][0]["text"] == "<b>x</b>"
    assert "onclick" not in out.blocks[0]


def test_references_are_collected_once_in_order() -> None:
    mentions = {
        "type": "paragraph",
        "content": [{"type": "mention", "attrs": {"doc_id": DOC, "label": "P"}}] * 2,
    }
    out = clean(mentions, {"type": "task_card", "attrs": {"task_id": TASK}})

    assert [str(d) for d in out.doc_ids] == [DOC]
    assert [str(t) for t in out.task_ids] == [TASK]
    assert blocks.references(out.blocks) == (out.doc_ids, out.task_ids)


def test_duplicate_or_missing_ids_are_made_unique() -> None:
    made = clean(
        {"id": "a", "type": "divider"}, {"id": "a", "type": "divider"}, {"type": "divider"}
    ).blocks

    assert len({b["id"] for b in made}) == 3


@pytest.mark.parametrize(
    "raw",
    ["{", '{"a": 1}', "[1]", json.dumps([{"type": "divider"}] * (blocks.MAX_BLOCKS + 1))],
)
def test_malformed_documents_are_refused(raw: str) -> None:
    with pytest.raises(ApiError):
        blocks.clean(raw)


def test_too_big_and_too_deep_are_refused() -> None:
    huge = [{"type": "paragraph", "content": [], "pad": "x" * blocks.MAX_BYTES}]
    with pytest.raises(ApiError):
        blocks.clean(json.dumps(huge))
    deep: Any = {"type": "future"}
    for _ in range(blocks.MAX_DEPTH + 2):
        deep = {"type": "future", "inner": deep}
    with pytest.raises(ApiError):
        clean(deep)


def test_newer_schema_is_refused() -> None:
    with pytest.raises(ApiError):
        clean(version=blocks.SCHEMA_VERSION + 1)
    assert clean(version=blocks.SCHEMA_VERSION).blocks == []


def test_plain_text_and_strip_ids() -> None:
    made = clean(
        {"type": "heading", "content": [{"type": "text", "text": "Title"}]},
        {"type": "code", "text": "x = 1"},
        {"type": "table", "rows": [[[{"type": "text", "text": "a"}], []]]},
        {"type": "image", "attrs": {"src": "https://e.com/a", "alt": "Alt"}},
    ).blocks

    assert blocks.plain_text(made) == "Title\nx = 1\na\nAlt"
    assert all("id" not in b for b in blocks.strip_ids(made))
