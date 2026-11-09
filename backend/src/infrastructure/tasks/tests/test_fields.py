import json

import pytest

from infrastructure.common.errors import ApiError
from infrastructure.tasks import fields


def test_title_is_trimmed_and_required() -> None:
    assert fields.clean_title("  Fix it ") == "Fix it"
    for bad in ("", "   ", "x" * 501):
        with pytest.raises(ApiError):
            fields.clean_title(bad)
    assert fields.clean_title("x" * 500)


def test_priority_is_from_the_fixed_list() -> None:
    assert fields.clean_priority("urgent") == "urgent"
    with pytest.raises(ApiError):
        fields.clean_priority("bogus")


def test_description_accepts_the_shared_rich_text_shape() -> None:
    doc = {
        "type": "doc",
        "content": [
            {"type": "heading", "attrs": {"level": 2}, "content": [{"type": "text", "text": "Hi"}]},
            {
                "type": "paragraph",
                "content": [{"type": "text", "text": "a", "marks": [{"type": "bold"}]}],
            },
            {
                "type": "checklist",
                "content": [{"type": "checklist_item", "attrs": {"checked": True}}],
            },
        ],
    }
    assert fields.clean_description(json.dumps(doc)) == doc
    assert fields.clean_description("") == {}


@pytest.mark.parametrize(
    "bad",
    [
        "not json",
        "[]",
        '{"type": "paragraph"}',
        '{"type": "doc", "content": "x"}',
        '{"type": "doc", "content": [{"type": "script"}]}',
        '{"type": "doc", "content": [{"type": "paragraph", "content": [{"type": "text"}]}]}',
    ],
)
def test_description_rejects_malformed_documents(bad: str) -> None:
    with pytest.raises(ApiError):
        fields.clean_description(bad)


def test_description_is_capped_at_200_kb() -> None:
    big = json.dumps(
        {
            "type": "doc",
            "content": [
                {"type": "paragraph", "content": [{"type": "text", "text": "x" * 205_000}]}
            ],
        }
    )
    with pytest.raises(ApiError):
        fields.clean_description(big)


def test_dates_parse_and_order() -> None:
    assert str(fields.clean_date("2026-03-01")) == "2026-03-01"
    assert fields.clean_date("") is None
    with pytest.raises(ApiError):
        fields.clean_date("03/01/2026")
    with pytest.raises(ApiError):
        fields.check_range(fields.clean_date("2026-03-02"), fields.clean_date("2026-03-01"))
