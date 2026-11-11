"""Markdown export, and the import that proves nothing basic is lost."""

import json
from typing import Any

from infrastructure.docs import blocks, markdown

DOC = "22222222-2222-4222-8222-222222222222"
TASK = "11111111-1111-4111-8111-111111111111"


def t(text: str, *marks: Any) -> dict[str, Any]:
    node: dict[str, Any] = {"type": "text", "text": text}
    if marks:
        node["marks"] = [m if isinstance(m, dict) else {"type": m} for m in marks]
    return node


def block(kind: str, content: list[Any] | None = None, **attrs: Any) -> dict[str, Any]:
    out: dict[str, Any] = {"type": kind}
    if attrs:
        out["attrs"] = attrs
    if content is not None:
        out["content"] = content
    return out


LINK = {"type": "link", "attrs": {"href": "https://e.com/a_b"}}
SAMPLE = [
    block("heading", [t("Plan")], level=1),
    block("heading", [t("Part")], level=3),
    block("paragraph", [t("plain "), t("bold", "bold"), t(" "), t("it", "italic")]),
    block("paragraph", [t("both", "bold", "italic"), t(" "), t("gone", "strike")]),
    block("paragraph", [t("x = 1", "code"), t(" and "), t("`tick`", "code")]),
    block("paragraph", [t("site", LINK)]),
    block("paragraph", [t("one"), {"type": "hard_break"}, t("two")]),
    block("paragraph", [t("special * _ ` [ ] ~ | < > \\ chars")]),
    block("paragraph", [t("# not a heading")]),
    block("paragraph", [t("- not a list")]),
    block("paragraph", [{"type": "mention", "attrs": {"doc_id": DOC, "label": "Spec [v2]"}}]),
    block("bullet_item", [t("a")], indent=0),
    block("bullet_item", [t("b")], indent=1),
    block("numbered_item", [t("n1")], indent=0),
    block("numbered_item", [t("n2")], indent=0),
    block("checklist_item", [t("todo")], indent=0, checked=False),
    block("checklist_item", [t("done")], indent=1, checked=True),
    block("quote", [t("wise"), {"type": "hard_break"}, t("words")]),
    block("callout", [t("careful")], tone="warning"),
    {"type": "code", "attrs": {"language": "py"}, "text": "a = 1\n\n```\nb = 2"},
    {"type": "divider"},
    {"type": "image", "attrs": {"src": "https://e.com/i.png", "alt": "A [b]", "width": 40}},
    {"type": "task_card", "attrs": {"task_id": TASK}},
    {
        "type": "table",
        "attrs": {"header": True},
        "rows": [[[t("h1")], [t("h2")]], [[t("a", "bold")], [t("b | c")]]],
    },
    {"type": "table", "attrs": {"header": False}, "rows": [[[t("x")], [t("y")]]]},
    {"id": "u", "type": "whiteboard", "strokes": [1, 2]},
]


def test_export_reads_like_markdown() -> None:
    out = markdown.to_markdown(SAMPLE)

    assert out.startswith("# Plan\n\n### Part\n\n")
    assert "plain **bold** _it_" in out
    assert "- a\n  - b" in out
    assert "- [ ] todo\n  - [x] done" in out
    assert "```py\na = 1" in out and "---" in out
    assert "![A \\[b\\]](https://e.com/i.png =40)" in out


def test_basic_blocks_round_trip() -> None:
    first = blocks.clean(json.dumps(SAMPLE)).blocks
    again = blocks.clean(json.dumps(markdown.from_markdown(markdown.to_markdown(first)))).blocks

    assert blocks.strip_ids(again) == blocks.strip_ids(first)


def test_round_trip_is_stable() -> None:
    text = markdown.to_markdown(SAMPLE)

    assert markdown.to_markdown(markdown.from_markdown(text)) == text


def test_empty_page_and_empty_paragraphs() -> None:
    assert markdown.to_markdown([]) == ""
    assert markdown.from_markdown("") == []
    assert markdown.to_markdown([block("paragraph", [])]) == ""


def test_import_understands_hand_written_markdown() -> None:
    made = markdown.from_markdown("## Hi\r\n\r\n1. one\r\n2. two\r\n\r\nsome **text** here\r\n")

    assert [b["type"] for b in made] == ["heading", "numbered_item", "numbered_item", "paragraph"]
    assert made[3]["content"][1] == {"type": "text", "text": "text", "marks": [{"type": "bold"}]}
