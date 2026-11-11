"""What a comment body may hold: the shared rich-text document, mentions, safe links, no HTML."""

import json
import uuid
from typing import Any

import pytest

from infrastructure.comments import body
from infrastructure.common.errors import ApiError


def doc(*blocks: dict[str, Any]) -> str:
    return json.dumps({"type": "doc", "content": list(blocks)})


def para(*inline: dict[str, Any]) -> dict[str, Any]:
    return {"type": "paragraph", "content": list(inline)}


def text(value: str, *marks: dict[str, Any]) -> dict[str, Any]:
    return {"type": "text", "text": value, **({"marks": list(marks)} if marks else {})}


def mention(user_id: Any, label: str = "Ana") -> dict[str, Any]:
    return {"type": "mention", "attrs": {"id": str(user_id), "label": label}}


def link(href: str) -> dict[str, Any]:
    return {"type": "link", "attrs": {"href": href}}


def test_a_plain_paragraph_is_accepted_and_its_text_read_back() -> None:
    cleaned = body.clean(doc(para(text("Looks good"), text(" to me"))))

    assert cleaned.document["type"] == "doc"
    assert cleaned.plain_text == "Looks good to me"
    assert cleaned.mention_ids == []


def test_mentions_are_collected_once_each_in_order() -> None:
    a, b = uuid.uuid4(), uuid.uuid4()

    cleaned = body.clean(
        doc(para(mention(a), text(" and "), mention(b), text(" and "), mention(a)))
    )

    assert cleaned.mention_ids == [a, b]
    assert cleaned.plain_text == "@Ana and @Ana and @Ana"


def test_an_empty_or_blank_comment_is_refused() -> None:
    for value in ("", "  ", doc(), doc(para()), doc(para(text("   ")))):
        with pytest.raises(ApiError):
            body.clean(value)


@pytest.mark.parametrize(
    "bad",
    [
        "not json",
        "[]",
        json.dumps({"type": "paragraph"}),
        doc({"type": "script", "content": []}),
        doc(para({"type": "html", "text": "<b>x</b>"})),
        doc(para({"type": "text", "text": 5})),
        doc(para(mention("not-a-uuid"))),
        doc(para({"type": "mention", "attrs": {}})),
        doc(para(text("x", {"type": "style", "attrs": {"css": "x"}}))),
    ],
)
def test_a_body_that_is_not_the_shared_document_is_refused(bad: str) -> None:
    with pytest.raises(ApiError):
        body.clean(bad)


@pytest.mark.parametrize(
    "href", ["javascript:alert(1)", "data:text/html,x", "file:///etc/passwd", "//evil.example", ""]
)
def test_a_link_that_is_not_http_https_or_mailto_is_refused(href: str) -> None:
    with pytest.raises(ApiError):
        body.clean(doc(para(text("click", link(href)))))


@pytest.mark.parametrize(
    "href", ["https://example.com/a?b=1", "http://example.com", "mailto:a@b.co"]
)
def test_ordinary_links_are_kept(href: str) -> None:
    cleaned = body.clean(doc(para(text("see", link(href)))))

    assert cleaned.document["content"][0]["content"][0]["marks"][0]["attrs"] == {"href": href}


def test_html_in_text_is_just_text_and_nothing_else_survives_in_a_node() -> None:
    cleaned = body.clean(doc(para({"type": "text", "text": "<img src=x onerror=1>", "extra": "x"})))

    node = cleaned.document["content"][0]["content"][0]
    assert node == {"type": "text", "text": "<img src=x onerror=1>"}  # unknown keys are dropped


def test_a_label_is_kept_short_and_never_trusted_for_identity() -> None:
    uid = uuid.uuid4()

    cleaned = body.clean(doc(para(mention(uid, "x" * 500))))

    node = cleaned.document["content"][0]["content"][0]
    assert len(node["attrs"]["label"]) <= body.LABEL_MAX and cleaned.mention_ids == [uid]


def test_a_huge_body_or_a_deep_one_is_refused() -> None:
    with pytest.raises(ApiError):
        body.clean(doc(para(text("x" * (body.MAX_BYTES + 1)))))
    deep: dict[str, Any] = {"type": "blockquote", "content": [para(text("x"))]}
    for _ in range(12):
        deep = {"type": "blockquote", "content": [deep]}
    with pytest.raises(ApiError):
        body.clean(doc(deep))


def test_a_mention_cap_stops_a_comment_that_pings_everyone() -> None:
    nodes = [mention(uuid.uuid4()) for _ in range(body.MAX_MENTIONS + 1)]

    with pytest.raises(ApiError):
        body.clean(doc(para(*nodes)))


def test_lists_code_and_quotes_are_allowed() -> None:
    cleaned = body.clean(
        doc(
            {"type": "heading", "attrs": {"level": 2}, "content": [text("Plan")]},
            {
                "type": "bullet_list",
                "content": [{"type": "list_item", "content": [para(text("one"))]}],
            },
            {"type": "code_block", "content": [text("print(1)")]},
            {"type": "blockquote", "content": [para(text("said"))]},
        )
    )

    assert "Plan" in cleaned.plain_text and "print(1)" in cleaned.plain_text
