"""Reading files as streams: encodings, delimiters, zips, big JSON, and refusals."""

import io
import json
import zipfile

import pytest

from infrastructure.common.errors import ApiError
from infrastructure.imports import richtext, streams


def _text(raw: bytes) -> io.TextIOBase:
    return streams.text_of(io.BytesIO(raw))


def test_csv_header_and_rows_with_a_bom_and_each_delimiter() -> None:
    for delimiter in (",", ";", "\t"):
        raw = (f"﻿a{delimiter}b\n1{delimiter}2\n3{delimiter}4\n").encode()
        header, rows = streams.csv_rows(_text(raw))
        assert header == ["a", "b"]
        assert [cells for _, cells in rows] == [["1", "2"], ["3", "4"]]


def test_a_windows_1252_file_is_read_not_refused() -> None:
    raw = "name,city\nZoë,Zürich\n".encode("cp1252")
    header, rows = streams.csv_rows(_text(raw))
    assert list(rows)[0][1] == ["Zoë", "Zürich"]


def test_a_multibyte_character_across_the_first_block_is_still_utf8() -> None:
    raw = ("h\n" + "é" * (streams.BLOCK // 2 + 1) + "\n").encode()
    header, rows = streams.csv_rows(_text(raw))
    assert list(rows)[0][1][0] == "é" * (streams.BLOCK // 2 + 1)


def test_quoted_newlines_and_blank_lines() -> None:
    header, rows = streams.csv_rows(_text(b'a,b\n"x\ny",2\n\n,\n3,4\n'))
    assert [c for _, c in rows] == [["x\ny", "2"], ["3", "4"]]


def test_an_empty_file_and_a_cell_over_the_limit_are_refused_or_reported() -> None:
    with pytest.raises(ApiError):
        streams.csv_rows(_text(b""))
    header, rows = streams.csv_rows(
        _text(b"a\n" + b"x" * (streams.MAX_FIELD_BYTES + 5) + b"\nok\n")
    )
    out = list(rows)
    assert out[0][1][0].startswith("\x00") and out[1][1] == ["ok"]


def test_json_items_from_a_list_an_object_and_across_block_edges(monkeypatch) -> None:  # type: ignore[no-untyped-def]
    items = [{"i": n, "text": "x" * 50} for n in range(200)]
    for shape in (json.dumps(items), json.dumps({"meta": {"a": [1, 2]}, "issues": items, "z": 1})):
        monkeypatch.setattr(streams, "BLOCK", 97)  # force many refills
        got = list(streams.json_items(_text(shape.encode()), "issues"))
        assert got == items


def test_json_items_refuses_the_wrong_shape() -> None:
    with pytest.raises(ApiError):
        list(streams.json_items(_text(b'{"other": []}'), "issues"))
    with pytest.raises(ApiError):
        list(streams.json_items(_text(b"42"), "issues"))
    with pytest.raises(ApiError):
        list(streams.json_items(_text(b'[{"a": 1}, {"b":'), "issues"))


def test_json_members_before_the_tasks() -> None:
    raw = b'{"format": "f", "project": {"k": 1}, "tasks": [{"id": 1}]}'
    assert streams.json_members_before(_text(raw), "tasks") == {"format": "f", "project": {"k": 1}}
    assert streams.json_members_before(_text(b"[1]"), "tasks") == {}


def _zip(members: dict[str, bytes]) -> io.BytesIO:
    buffer = io.BytesIO()
    with zipfile.ZipFile(buffer, "w") as z:
        for name, data in members.items():
            z.writestr(name, data)
    buffer.seek(0)
    return buffer


def test_a_zip_is_opened_by_its_one_data_file() -> None:
    binary, name = streams.open_binary(_zip({"__MACOSX/x.csv": b"junk", "data.csv": b"a\n1\n"}))
    assert name == "data.csv" and binary.read() == b"a\n1\n"
    assert streams.member_names(_zip({"a.csv": b"x", "b.json": b"y", "c.txt": b"z"})) == [
        "a.csv", "b.json",
    ]  # fmt: skip


def test_a_zip_with_several_files_needs_one_named_and_with_none_is_refused() -> None:
    many = _zip({"a.csv": b"x", "b.csv": b"y"})
    with pytest.raises(ApiError, match="several"):
        streams.open_binary(many)
    many.seek(0)
    assert streams.open_binary(many, "b.csv")[1] == "b.csv"
    with pytest.raises(ApiError, match="no .csv"):
        streams.open_binary(_zip({"a.txt": b"x"}))


def test_a_zip_bomb_is_cut_at_the_limit(monkeypatch) -> None:  # type: ignore[no-untyped-def]
    monkeypatch.setattr(streams, "MAX_MEMBER_BYTES", 1000)
    buffer = io.BytesIO()
    with zipfile.ZipFile(buffer, "w", zipfile.ZIP_DEFLATED) as z:
        z.writestr("big.csv", b"a\n" + b"0" * 5000)  # 5 KB inflates from a few bytes
    buffer.seek(0)
    with pytest.raises(ApiError, match="larger than 2 GB"):
        streams.open_binary(buffer)


@pytest.mark.parametrize(
    ("html", "expected"),
    [
        ("<p>a<script>alert(1)</script>b</p>", "ab"),
        ('<a href="javascript:alert(1)">click</a>', "click"),
        ("<style>p{}</style>text", "text"),
        ("<p onclick='x()'>t</p>", "t"),
    ],
)
def test_html_never_keeps_active_content(html: str, expected: str) -> None:
    doc = richtext.to_doc(html, "html")
    assert richtext.plain_of(doc["content"]) == expected
    assert "javascript" not in json.dumps(doc) and "script" not in json.dumps(doc)


def test_text_formats_produce_our_nodes_and_cut_long_text() -> None:
    doc = richtext.to_doc("h2. T\n* a\n* b\n{code}\nx\n{code}", "jira")
    assert [n["type"] for n in doc["content"]] == ["heading", "bullet_list", "code_block"]
    md = richtext.to_doc("# T\n1. a\n2. b\n**b** `c` [l](https://x.y) [bad](javascript:x)", "md")
    kinds = {
        m["type"] for n in md["content"] for c in n.get("content", []) for m in c.get("marks", [])
    }
    assert {"bold", "code", "link"} <= kinds
    assert "javascript" not in json.dumps(md)
    assert richtext.to_doc("   ", "text") == {}
    long = richtext.to_doc("x" * (richtext.TEXT_MAX + 10))
    assert "Cut:" in richtext.plain_of(long["content"])
    assert richtext.to_doc("not json", "adf")["content"][0]["type"] == "paragraph"
    assert richtext.to_doc("[1]", "doc") == {}


def test_html_lists_tables_and_headings_become_our_blocks() -> None:
    html = (
        "<h2>Title</h2><ul><li>one</li><li>two <b>bold</b></li></ul>"
        "<ol><li>first</li></ol><pre>code\nhere</pre>"
        "<table><tr><td>a</td><td>b</td></tr></table><p>last<br>line</p>"
    )
    doc = richtext.to_doc(html, "html")
    kinds = [n["type"] for n in doc["content"]]
    assert kinds[:4] == ["heading", "bullet_list", "ordered_list", "code_block"]
    assert "paragraph" in kinds[4:]
    text = richtext.plain_of(doc["content"])
    assert "one" in text and "two bold" in text and "a" in text and "last" in text
    assert "<" not in json.dumps(doc).replace('"type"', "")


def test_atlassian_documents_with_lists_code_and_quotes() -> None:
    adf = {
        "type": "doc",
        "content": [
            {"type": "heading", "attrs": {"level": 2}, "content": [{"type": "text", "text": "H"}]},
            {"type": "bulletList", "content": [
                {"type": "listItem", "content": [
                    {"type": "paragraph", "content": [{"type": "text", "text": "x"}]}]}]},
            {"type": "codeBlock", "content": [{"type": "text", "text": "a = 1"}]},
            {"type": "blockquote", "content": [
                {"type": "paragraph", "content": [{"type": "text", "text": "q"}]}]},
            {"type": "rule"},
        ],
    }  # fmt: skip
    doc = richtext.to_doc(json.dumps(adf), "adf")
    assert [n["type"] for n in doc["content"]] == [
        "heading", "bullet_list", "code_block", "blockquote", "horizontal_rule",
    ]  # fmt: skip


def test_a_jira_json_file_that_crosses_many_blocks_is_read_whole() -> None:
    from infrastructure.imports.parsers import jira_json
    from infrastructure.imports.records import RIssue

    issues = [
        {
            "id": str(n),
            "key": f"P-{n}",
            "fields": {"summary": f"Issue {n}", "description": "x" * 5000},
        }
        for n in range(60)
    ]  # several hundred KB: many refills
    raw = json.dumps({"issues": issues}).encode()
    got = list(jira_json.parse(io.BytesIO(raw)))
    parsed = [g for g in got if isinstance(g, RIssue)]
    assert len(got) == len(parsed) == 60
    assert parsed[-1].title == "Issue 59" and len(parsed[0].body) == 5000
