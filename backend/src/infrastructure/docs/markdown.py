"""Markdown out of a page's blocks, and back in (the import proves the export loses nothing).

Basic blocks round-trip exactly: paragraphs, headings, bullet/numbered/checklist items (with
indent), quotes, code, dividers, images, tables, callouts and task cards, with the inline marks
bold, italic, strike, code and link, hard breaks and ``[[`` mentions. A block this version does not
know is written as an HTML comment holding its JSON and read back from it.
"""

import json
import re
from typing import Any, Final

from infrastructure.docs import blocks as schema

INDENT: Final = "  "
_SPECIAL = re.compile(r"([\\*_`\[\]~|<>])")
_UNKNOWN = re.compile(r"^<!-- taskforge-block (.*) -->$")
_HEADING = re.compile(r"^(#{1,3}) (.*)$")
_BULLET = re.compile(r"^((?:  )*)- (?!\[[ x]\] )(.*)$")
_CHECK = re.compile(r"^((?:  )*)- \[([ x])\] (.*)$")
_NUMBER = re.compile(r"^((?:  )*)\d+\. (.*)$")
_QUOTE = re.compile(r"^> ?(.*)$")
_CALLOUT = re.compile(r"^> \[!(info|warning|success|danger)\] ?(.*)$")
_IMAGE = re.compile(r"^!\[((?:[^\]\\]|\\.)*)\]\(([^)\s]+)(?: =(\d+))?\)$")
_TASK = re.compile(r"^\[task\]\(taskforge://task/([0-9a-f-]{36})\)$")
_FENCE = re.compile(r"^(`{3,})(.*)$")
_ROW = re.compile(r"^\|(.*)\|$")


# -- export ----------------------------------------------------------------------------------


def _escape(text: str) -> str:
    return _SPECIAL.sub(r"\\\1", text)


def _wrap(text: str, marks: list[dict[str, Any]]) -> str:
    for mark in marks:
        kind = mark.get("type")
        if kind == "bold":
            text = f"**{text}**"
        elif kind == "italic":
            text = f"_{text}_"
        elif kind == "strike":
            text = f"~~{text}~~"
        elif kind == "link":
            text = f"[{text}]({mark['attrs']['href']})"
    return text


def _code_span(text: str) -> str:
    longest = max((len(m) for m in re.findall(r"`+", text)), default=0)
    fence = "`" * (longest + 1)
    pad = " " if text.startswith("`") or text.endswith("`") or text.startswith(" ") else ""
    return f"{fence}{pad}{text}{pad}{fence}"


def _inline(nodes: list[Any]) -> str:
    out = []
    for node in nodes:
        kind = node.get("type")
        if kind == "text":
            marks = node.get("marks", [])
            known = [m for m in marks if m.get("type") in schema.MARKS]
            if any(m["type"] == "code" for m in known):
                body = _code_span(node["text"])
                known = [m for m in known if m["type"] != "code"]
            else:
                body = _escape(node["text"])
            out.append(_wrap(body, known))
        elif kind == "hard_break":
            out.append("  \n")
        elif kind == "mention":
            attrs = node.get("attrs", {})
            out.append(f"[[{_escape(str(attrs.get('label', '')))}|{attrs.get('doc_id', '')}]]")
    return "".join(out)


def _line_start(text: str) -> str:
    """Stop a paragraph that starts like markup from being read as markup."""
    if re.match(r"^(#{1,3} |- |> |\d+\. |!\[|---$|```|<!--|\[task\])", text):
        return "\\" + text
    return text


def _block(block: dict[str, Any]) -> str:
    kind = block.get("type")
    attrs = block.get("attrs", {})
    content = _inline(block.get("content", []))
    pad = INDENT * int(attrs.get("indent", 0))
    if kind == "paragraph":
        return _line_start(content)
    if kind == "heading":
        return f"{'#' * int(attrs.get('level', 1))} {content}"
    if kind == "bullet_item":
        return f"{pad}- {content}"
    if kind == "numbered_item":
        return f"{pad}1. {content}"
    if kind == "checklist_item":
        return f"{pad}- [{'x' if attrs.get('checked') else ' '}] {content}"
    if kind == "quote":
        return "\n".join(f"> {line}" for line in content.split("\n"))
    if kind == "callout":
        return f"> [!{attrs.get('tone', 'info')}] {content}"
    if kind == "code":
        text = str(block.get("text", ""))
        longest = max((len(m) for m in re.findall(r"`+", text)), default=0)
        fence = "`" * max(3, longest + 1)
        return f"{fence}{attrs.get('language', '')}\n{text}\n{fence}"
    if kind == "divider":
        return "---"
    if kind == "image":
        width = f" ={attrs['width']}" if attrs.get("width") else ""
        return f"![{_escape(attrs.get('alt', ''))}]({attrs['src']}{width})"
    if kind == "task_card":
        return f"[task](taskforge://task/{attrs['task_id']})"
    if kind == "table":
        return _table(block)
    return f"<!-- taskforge-block {json.dumps(block, separators=(',', ':'))} -->"


def _table(block: dict[str, Any]) -> str:
    rows = block.get("rows", [])
    width = max((len(r) for r in rows), default=1)
    cells = [[_inline(c).replace("\n", " ") for c in r] + [""] * (width - len(r)) for r in rows]
    if not block.get("attrs", {}).get("header"):
        cells.insert(0, [""] * width)
    lines = ["| " + " | ".join(cells[0]) + " |", "|" + " --- |" * width]
    lines += ["| " + " | ".join(r) + " |" for r in cells[1:]]
    return "\n".join(lines)


def to_markdown(blocks: list[dict[str, Any]]) -> str:
    """The page as Markdown. List items stay together; every other block has a blank line around."""
    out: list[str] = []
    previous = ""
    for block in blocks:
        kind = str(block.get("type"))
        text = _block(block)
        if kind == "paragraph" and not text:
            continue  # an empty paragraph has no Markdown form
        listy = ("bullet_item", "numbered_item", "checklist_item")
        if out:
            out.append("\n" if kind in listy and previous in listy else "\n\n")
        out.append(text)
        previous = kind
    return "".join(out) + ("\n" if out else "")


# -- import ----------------------------------------------------------------------------------


def _find(text: str, token: str, start: int) -> int:
    """The next ``token`` at or after ``start`` that is not escaped."""
    i = start
    while i < len(text):
        if text[i] == "\\":
            i += 2
            continue
        if text.startswith(token, i):
            return i
        i += 1
    return -1


def _merge(nodes: list[dict[str, Any]]) -> list[dict[str, Any]]:
    merged: list[dict[str, Any]] = []
    for node in nodes:
        last = merged[-1] if merged else None
        if (
            last
            and node["type"] == "text"
            and last["type"] == "text"
            and last.get("marks") == node.get("marks")
        ):
            last["text"] += node["text"]
        else:
            merged.append(node)
    return merged


def _with_mark(nodes: list[dict[str, Any]], mark: dict[str, Any]) -> list[dict[str, Any]]:
    for node in nodes:
        if node["type"] == "text":
            node["marks"] = [*node.get("marks", []), mark]
    return nodes


def parse_inline(text: str) -> list[dict[str, Any]]:
    """Inline markdown to inline nodes (see the module docstring for what is understood)."""
    nodes: list[dict[str, Any]] = []
    plain: list[str] = []

    def flush() -> None:
        if plain:
            nodes.append({"type": "text", "text": "".join(plain)})
            plain.clear()

    i = 0
    while i < len(text):
        ch = text[i]
        if ch == "\\" and i + 1 < len(text):
            plain.append(text[i + 1])
            i += 2
        elif text.startswith("  \n", i):
            flush()
            nodes.append({"type": "hard_break"})
            i += 3
        elif ch == "`":
            run = len(text[i:]) - len(text[i:].lstrip("`"))
            end = text.find("`" * run, i + run)
            if end < 0:
                plain.append(ch)
                i += 1
                continue
            code = text[i + run : end]
            if len(code) >= 2 and code[0] == code[-1] == " " and code.strip(" ") != "":
                code = code[1:-1]
            flush()
            nodes.append({"type": "text", "text": code, "marks": [{"type": "code"}]})
            i = end + run
        elif text.startswith("[[", i):
            end = _find(text, "]]", i + 2)
            label, _, doc_id = text[i + 2 : end].rpartition("|") if end > 0 else ("", "", "")
            if end < 0 or not doc_id:
                plain.append(ch)
                i += 1
                continue
            flush()
            attrs = {"doc_id": doc_id, "label": parse_plain(label)}
            nodes.append({"type": "mention", "attrs": attrs})
            i = end + 2
        elif ch == "[":
            end = _find(text, "](", i + 1)
            close = text.find(")", end) if end > 0 else -1
            if end < 0 or close < 0:
                plain.append(ch)
                i += 1
                continue
            flush()
            href = text[end + 2 : close]
            inner = parse_inline(text[i + 1 : end])
            nodes.extend(_with_mark(inner, {"type": "link", "attrs": {"href": href}}))
            i = close + 1
        else:
            token = next((t for t in ("**", "~~", "_") if text.startswith(t, i)), "")
            end = _find(text, token, i + len(token)) if token else -1
            if not token or end < 0:
                plain.append(ch)
                i += 1
                continue
            flush()
            kind = {"**": "bold", "~~": "strike", "_": "italic"}[token]
            inner = parse_inline(text[i + len(token) : end])
            nodes.extend(_with_mark(inner, {"type": kind}))
            i = end + len(token)
    flush()
    return _merge(nodes)


def parse_plain(text: str) -> str:
    return re.sub(r"\\(.)", r"\1", text)


def _split_row(line: str) -> list[str]:
    body = line.strip()[1:-1]
    cells, current, i = [], "", 0
    while i < len(body):
        if body[i] == "\\" and i + 1 < len(body):
            current += body[i : i + 2]
            i += 2
        elif body[i] == "|":
            cells.append(current.strip())
            current = ""
            i += 1
        else:
            current += body[i]
            i += 1
    cells.append(current.strip())
    return cells


class _Reader:
    def __init__(self, lines: list[str]) -> None:
        self.lines = lines
        self.at = 0
        self.blocks: list[dict[str, Any]] = []

    def more(self) -> bool:
        return self.at < len(self.lines)

    def peek(self) -> str:
        return self.lines[self.at]

    def take(self) -> str:
        self.at += 1
        return self.lines[self.at - 1]

    def run(self) -> list[dict[str, Any]]:
        while self.more():
            line = self.take()
            if line.strip():
                self.blocks.append(self._block(line))
        return self.blocks

    def _block(self, line: str) -> dict[str, Any]:
        found = _UNKNOWN.match(line)
        if found:
            return dict(json.loads(found.group(1)))
        fence = _FENCE.match(line)
        if fence:
            return self._code(fence.group(1), fence.group(2))
        if line == "---":
            return {"type": "divider"}
        for build in (self._heading, self._lists, self._image_task):
            made = build(line)
            if made:
                return made
        if line.startswith(">"):
            return self._quote(line)
        if _ROW.match(line) and self.more() and re.match(r"^\|( --- \|)+$", self.peek()):
            return self._table(line)
        return self._paragraph(line)

    def _code(self, fence: str, language: str) -> dict[str, Any]:
        body = []
        while self.more() and self.peek() != fence:
            body.append(self.take())
        if self.more():
            self.take()
        return {"type": "code", "attrs": {"language": language}, "text": "\n".join(body)}

    def _heading(self, line: str) -> dict[str, Any] | None:
        found = _HEADING.match(line)
        if not found:
            return None
        return {
            "type": "heading",
            "attrs": {"level": len(found.group(1))},
            "content": parse_inline(found.group(2)),
        }

    def _lists(self, line: str) -> dict[str, Any] | None:
        kinds = ((_CHECK, "checklist_item"), (_BULLET, "bullet_item"), (_NUMBER, "numbered_item"))
        for pattern, kind in kinds:
            found = pattern.match(line)
            if not found:
                continue
            attrs: dict[str, Any] = {"indent": len(found.group(1)) // len(INDENT)}
            if kind == "checklist_item":
                attrs["checked"] = found.group(2) == "x"
            return {"type": kind, "attrs": attrs, "content": parse_inline(found.groups()[-1])}
        return None

    def _image_task(self, line: str) -> dict[str, Any] | None:
        image = _IMAGE.match(line)
        if image:
            attrs: dict[str, Any] = {"src": image.group(2), "alt": parse_plain(image.group(1))}
            if image.group(3):
                attrs["width"] = int(image.group(3))
            return {"type": "image", "attrs": attrs}
        task = _TASK.match(line)
        if task:
            return {"type": "task_card", "attrs": {"task_id": task.group(1)}}
        return None

    def _quote(self, line: str) -> dict[str, Any]:
        callout = _CALLOUT.match(line)
        if callout:
            return {
                "type": "callout",
                "attrs": {"tone": callout.group(1)},
                "content": parse_inline(callout.group(2)),
            }
        parts = [_QUOTE.match(line).group(1)]  # type: ignore[union-attr]
        while self.more() and self.peek().startswith(">"):
            parts.append(_QUOTE.match(self.take()).group(1))  # type: ignore[union-attr]
        return {"type": "quote", "content": parse_inline("\n".join(parts))}

    def _table(self, head: str) -> dict[str, Any]:
        self.take()  # the separator
        rows = [_split_row(head)]
        while self.more() and _ROW.match(self.peek()):
            rows.append(_split_row(self.take()))
        header = any(rows[0])
        if not header:
            rows = rows[1:]
        return {
            "type": "table",
            "attrs": {"header": header},
            "rows": [[parse_inline(c) for c in row] for row in rows],
        }

    def _paragraph(self, line: str) -> dict[str, Any]:
        text = line
        while text.endswith("  ") and self.more() and self.peek().strip():
            text += "\n" + self.take()  # a hard break continues the paragraph
        return {"type": "paragraph", "content": parse_inline(text)}


def from_markdown(text: str) -> list[dict[str, Any]]:
    """Blocks (not yet cleaned: run them through ``blocks.clean`` to get ids) from Markdown."""
    return _Reader(text.replace("\r\n", "\n").split("\n")).run()
