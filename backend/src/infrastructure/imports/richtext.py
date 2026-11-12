"""Text from other tools (HTML, Jira wiki markup, Markdown, plain) as our rich-text document.

Nothing in a file is ever run or kept as markup: HTML is parsed for its structure only (``script``
and ``style`` are dropped, attributes are ignored but for a link's ``href``), and every document
ends in ``comments.body.clean``, which rebuilds it from the node kinds we allow and refuses a link
that is not http, https or mailto (such a link is kept as its text).
"""

import json
import re
from html.parser import HTMLParser
from typing import Any, Final

from infrastructure.comments import body
from infrastructure.common.errors import ApiError

TEXT_MAX: Final = 40_000  # characters kept; a longer text is cut with a note
CUT_NOTE: Final = "\n\n[Cut: the imported text was longer than TaskForge keeps.]"
SAFE_SCHEMES: Final = ("http://", "https://", "mailto:")

Node = dict[str, Any]


def _text(value: str, *marks: Node) -> Node:
    node: Node = {"type": "text", "text": value}
    if marks:
        node["marks"] = list(marks)
    return node


def _link(href: str) -> Node | None:
    return (
        {"type": "link", "attrs": {"href": href.strip()}}
        if href.strip().lower().startswith(SAFE_SCHEMES)
        else None
    )


def _para(inline: list[Node]) -> Node:
    return {"type": "paragraph", "content": inline} if inline else {"type": "paragraph"}


def _finish(blocks: list[Node]) -> dict[str, Any]:
    document = {"type": "doc", "content": blocks or [_para([])]}
    try:
        return body.clean(json.dumps(document)).document
    except ApiError:
        return {"type": "doc", "content": [_para([_text(plain_of(blocks)[:2000])])]}


def plain_of(blocks: list[Node]) -> str:
    out: list[str] = []

    def walk(node: Node) -> None:
        if node.get("type") == "text":
            out.append(str(node.get("text", "")))
        for child in node.get("content", []):
            walk(child)
        if node.get("type") in ("paragraph", "heading", "list_item", "code_block"):
            out.append("\n")

    for block in blocks:
        walk(block)
    return "".join(out).strip()


# -- plain text and the two line-based markups -------------------------------------------------

_JIRA_INLINE = re.compile(
    r"\[(?P<ltext>[^\]|]+)\|(?P<lurl>[^\]]+)\]|\{\{(?P<code>.+?)\}\}|\*(?P<bold>[^*\n]+)\*|_(?P<ital>[^_\n]+)_"
)
_MD_INLINE = re.compile(
    r"\[(?P<ltext>[^\]]+)\]\((?P<lurl>[^)\s]+)\)|`(?P<code>[^`]+)`|\*\*(?P<bold>.+?)\*\*|[*_](?P<ital>[^*_\n]+)[*_]"
)


def _inline(line: str, style: str) -> list[Node]:
    pattern = _JIRA_INLINE if style == "jira" else _MD_INLINE
    out: list[Node] = []
    last = 0
    for found in pattern.finditer(line):
        if found.start() > last:
            out.append(_text(line[last : found.start()]))
        last = found.end()
        if found.group("ltext"):
            mark = _link(found.group("lurl"))
            out.append(_text(found.group("ltext"), *([mark] if mark else [])))
        elif found.group("code"):
            out.append(_text(found.group("code"), {"type": "code"}))
        elif found.group("bold"):
            out.append(_text(found.group("bold"), {"type": "bold"}))
        else:
            out.append(_text(found.group("ital"), {"type": "italic"}))
    if last < len(line):
        out.append(_text(line[last:]))
    return [n for n in out if n["text"]]


def _lines_to_blocks(text: str, style: str) -> list[Node]:
    heading = (
        re.compile(r"^h([1-6])\.\s+(.*)$") if style == "jira" else re.compile(r"^(#{1,6})\s+(.*)$")
    )
    bullet = re.compile(r"^\s*[*-]+\s+(.*)$")
    numbered = re.compile(r"^\s*(?:#+|\d+[.)])\s+(.*)$")
    blocks: list[Node] = []
    para: list[str] = []
    items: list[str] = []
    kind = ""
    code: list[str] | None = None

    def flush_para() -> None:
        if para:
            inline: list[Node] = []
            for n, line in enumerate(para):
                if n:
                    inline.append({"type": "hard_break"})
                inline.extend(_inline(line, style))
            blocks.append(_para(inline))
            para.clear()

    def flush_items() -> None:
        nonlocal kind
        if items:
            blocks.append(
                {
                    "type": kind,
                    "content": [
                        {"type": "list_item", "content": [_para(_inline(i, style))]} for i in items
                    ],
                }
            )
            items.clear()
        kind = ""

    for line in text.splitlines():
        fence = line.strip() in ("{code}", "```") or line.strip().startswith(("{code:", "```"))
        if code is not None:
            if fence:
                blocks.append(
                    {"type": "code_block", "content": [_text("\n".join(code))]}
                    if code
                    else {"type": "code_block"}
                )
                code = None
            else:
                code.append(line)
            continue
        if fence:
            flush_para()
            flush_items()
            code = []
            continue
        head = heading.match(line)
        if head:
            flush_para()
            flush_items()
            level = min(3, len(head.group(1)) if style == "md" else int(head.group(1)))
            blocks.append(
                {
                    "type": "heading",
                    "attrs": {"level": level},
                    "content": _inline(head.group(2), style),
                }
            )
            continue
        item = bullet.match(line) or (
            numbered.match(line) if style == "jira" or re.match(r"^\s*\d", line) else None
        )
        if item and (bullet.match(line) or numbered.match(line)):
            wanted = "bullet_list" if bullet.match(line) else "ordered_list"
            if kind and kind != wanted:
                flush_items()
            flush_para()
            kind = wanted
            items.append(item.group(1))
            continue
        if not line.strip():
            flush_para()
            flush_items()
            continue
        flush_items()
        para.append(line)
    if code is not None:
        blocks.append({"type": "code_block", "content": [_text("\n".join(code))]})
    flush_para()
    flush_items()
    return blocks


# -- HTML ----------------------------------------------------------------------------------

_BLOCK_TAGS = {"p", "div", "li", "h1", "h2", "h3", "h4", "h5", "h6", "pre", "blockquote", "tr"}
_MARK_TAGS = {"b": "bold", "strong": "bold", "i": "italic", "em": "italic", "code": "code"}


class _Html(HTMLParser):
    def __init__(self) -> None:
        super().__init__(convert_charrefs=True)
        self.blocks: list[Node] = []
        self.inline: list[Node] = []
        self.marks: list[str] = []
        self.href: list[str] = []
        self.skip = 0
        self.heading = 0
        self.list_kind: list[str] = []
        self.items: list[Node] = []
        self.in_item = False
        self.in_pre = False

    def _flush(self) -> None:
        inline = self.inline
        while inline and inline[-1].get("type") == "hard_break":
            inline.pop()
        self.inline = []
        if not inline:
            return
        if self.in_item:
            self.items.append({"type": "list_item", "content": [_para(inline)]})
        elif self.in_pre:
            self.blocks.append(
                {
                    "type": "code_block",
                    "content": [_text("".join(n.get("text", "") for n in inline))],
                }
            )
        elif self.heading:
            self.blocks.append(
                {"type": "heading", "attrs": {"level": min(3, self.heading)}, "content": inline}
            )
        else:
            self.blocks.append(_para(inline))

    def _flush_list(self) -> None:
        if self.items:
            self.blocks.append(
                {
                    "type": self.list_kind[-1] if self.list_kind else "bullet_list",
                    "content": self.items,
                }
            )
            self.items = []

    def handle_starttag(self, tag: str, attrs: list[tuple[str, str | None]]) -> None:
        if tag in ("script", "style"):
            self.skip += 1
        elif tag in ("ul", "ol"):
            self._flush()
            self._flush_list()
            self.list_kind.append("ordered_list" if tag == "ol" else "bullet_list")
        elif tag == "li":
            self._flush()
            self.in_item = True
        elif tag == "pre":
            self._flush()
            self.in_pre = True
        elif tag in _BLOCK_TAGS:
            self._flush()
            if tag[0] == "h" and len(tag) == 2:
                self.heading = int(tag[1])
        elif tag == "br":
            self.inline.append({"type": "hard_break"})
        elif tag in _MARK_TAGS:
            self.marks.append(_MARK_TAGS[tag])
        elif tag == "a":
            self.href.append(dict(attrs).get("href") or "")

    def handle_endtag(self, tag: str) -> None:
        if tag in ("script", "style"):
            self.skip = max(0, self.skip - 1)
        elif tag in ("ul", "ol"):
            self._flush()
            self._flush_list()
            if self.list_kind:
                self.list_kind.pop()
        elif tag == "li":
            self._flush()
            self.in_item = False
        elif tag == "pre":
            self._flush()
            self.in_pre = False
        elif tag in _BLOCK_TAGS:
            self._flush()
            self.heading = 0
        elif tag in _MARK_TAGS and _MARK_TAGS[tag] in self.marks:
            self.marks.remove(_MARK_TAGS[tag])
        elif tag == "a" and self.href:
            self.href.pop()

    def handle_data(self, data: str) -> None:
        if self.skip or not data:
            return
        if not self.in_pre:
            data = re.sub(r"\s+", " ", data)
            if not data.strip() and not self.inline:
                return
        marks = [{"type": m} for m in dict.fromkeys(self.marks)]
        link = _link(self.href[-1]) if self.href else None
        if link:
            marks.append(link)
        self.inline.append(_text(data, *marks))

    def close(self) -> None:
        super().close()
        self._flush()
        self._flush_list()


def _from_html(text: str) -> list[Node]:
    parser = _Html()
    parser.feed(text)
    parser.close()
    return parser.blocks


_ADF_MARKS = {"strong": "bold", "em": "italic", "code": "code"}


def _adf_inline(nodes: list[Any]) -> list[Node]:
    out: list[Node] = []
    for node in nodes:
        kind = node.get("type") if isinstance(node, dict) else None
        if kind == "text":
            marks: list[Node] = []
            for m in node.get("marks") or []:
                if m.get("type") in _ADF_MARKS:
                    marks.append({"type": _ADF_MARKS[m["type"]]})
                elif m.get("type") == "link" and (
                    mark := _link(str(m.get("attrs", {}).get("href", "")))
                ):
                    marks.append(mark)
            out.append(_text(str(node.get("text", "")), *marks))
        elif kind == "hardBreak":
            out.append({"type": "hard_break"})
        elif kind in ("mention", "emoji", "status"):
            out.append(_text(str(node.get("attrs", {}).get("text", ""))))
    return [n for n in out if n.get("type") != "text" or n["text"]]


def _adf_blocks(nodes: list[Any]) -> list[Node]:
    out: list[Node] = []
    for node in nodes:
        if not isinstance(node, dict):
            continue
        kind, kids = node.get("type"), node.get("content") or []
        if kind == "paragraph":
            out.append(_para(_adf_inline(kids)))
        elif kind == "heading":
            level = min(3, int(node.get("attrs", {}).get("level", 1)))
            out.append({"type": "heading", "attrs": {"level": level}, "content": _adf_inline(kids)})
        elif kind in ("bulletList", "orderedList"):
            items = [
                {"type": "list_item", "content": _adf_blocks(i.get("content") or []) or [_para([])]}
                for i in kids
                if isinstance(i, dict)
            ]
            out.append(
                {
                    "type": "bullet_list" if kind == "bulletList" else "ordered_list",
                    "content": items,
                }
            )
        elif kind == "codeBlock":
            code = "".join(str(k.get("text", "")) for k in kids if isinstance(k, dict))
            out.append(
                {"type": "code_block", "content": [_text(code)]} if code else {"type": "code_block"}
            )
        elif kind == "blockquote":
            out.append({"type": "blockquote", "content": _adf_blocks(kids)})
        elif kind == "rule":
            out.append({"type": "horizontal_rule"})
    return out


def to_doc(text: str, fmt: str = "text") -> dict[str, Any]:
    """``text`` written in ``fmt`` (``text``, ``html``, ``jira``, ``md``) as a clean document."""
    text = (text or "").replace("\r\n", "\n").replace("\r", "\n")
    if len(text) > TEXT_MAX:
        text = text[:TEXT_MAX] + CUT_NOTE
    if not text.strip():
        return {}
    if fmt in ("adf", "doc"):
        try:
            loaded = json.loads(text)
        except (ValueError, RecursionError):
            return to_doc(text, "text")
        if not isinstance(loaded, dict):
            return {}
        blocks = (
            _adf_blocks(loaded.get("content") or [])
            if fmt == "adf"
            else [n for n in loaded.get("content") or [] if isinstance(n, dict)]
        )
    elif fmt == "html":
        blocks = _from_html(text)
    elif fmt in ("jira", "md"):
        blocks = _lines_to_blocks(text, fmt)
    else:
        blocks = [
            _para(_text_inline(chunk)) for chunk in re.split(r"\n\s*\n", text) if chunk.strip()
        ]
    return _finish(blocks)


def _text_inline(chunk: str) -> list[Node]:
    out: list[Node] = []
    for n, line in enumerate(chunk.strip("\n").split("\n")):
        if n:
            out.append({"type": "hard_break"})
        if line:
            out.append(_text(line))
    return out
