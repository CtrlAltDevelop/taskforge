"""Plain text with light markdown -> the ``{"type": "doc"}`` JSON that tasks and docs store.

Same grammar as the app's own ``markdownToDoc``: ``#`` headings, ``- `` bullets, ``- [x] ``
checklists, ``1. `` lists, ``> `` quotes, ``---`` rules, fenced code, ``[text](url)`` links.
"""

import json
import re
from typing import Any

_LINK = re.compile(r"\[([^\]]+)\]\(([^)\s]+)\)")
_HEAD = re.compile(r"^(#{1,3}) (.*)$")
_CHECK = re.compile(r"^- \[([ xX])\] (.*)$")
_BULLET = re.compile(r"^[-*] (.*)$")
_ORDERED = re.compile(r"^\d+\. (.*)$")
_QUOTE = re.compile(r"^> ?(.*)$")


def _inline(line: str) -> list[dict[str, Any]]:
    nodes: list[dict[str, Any]] = []
    at = 0
    for m in _LINK.finditer(line):
        if m.start() > at:
            nodes.append({"type": "text", "text": line[at : m.start()]})
        nodes.append(
            {
                "type": "text",
                "text": m.group(1),
                "marks": [{"type": "link", "attrs": {"href": m.group(2)}}],
            }
        )
        at = m.end()
    if at < len(line):
        nodes.append({"type": "text", "text": line[at:]})
    return nodes


def _block(kind: str, line: str, attrs: Any = None) -> dict[str, Any]:
    node: dict[str, Any] = {"type": kind}
    if attrs is not None:
        node["attrs"] = attrs
    if line:
        node["content"] = _inline(line)
    return node


def _items(lines: list[str], i: int, pattern: re.Pattern[str], kind: str) -> tuple[list[Any], int]:
    items: list[dict[str, Any]] = []
    while i < len(lines) and (m := pattern.match(lines[i])):
        if kind == "check":
            items.append(_block("checklist_item", m.group(2), {"checked": m.group(1) != " "}))
        else:
            items.append({"type": "list_item", "content": [_block("paragraph", m.group(1))]})
        i += 1
    return items, i


def doc(text: str) -> dict[str, Any]:
    """The document for ``text`` (the dict), e.g. for services that take it unserialised."""
    blocks: list[dict[str, Any]] = []
    lines = text.replace("\r\n", "\n").strip("\n").split("\n")
    i = 0
    while i < len(lines):
        line = lines[i]
        if line.rstrip() == "```":
            code: list[str] = []
            i += 1
            while i < len(lines) and lines[i].rstrip() != "```":
                code.append(lines[i])
                i += 1
            i += 1
            node: dict[str, Any] = {"type": "code_block"}
            if code:
                node["content"] = [{"type": "text", "text": "\n".join(code)}]
            blocks.append(node)
        elif line.strip() == "---":
            blocks.append({"type": "horizontal_rule"})
            i += 1
        elif m := _HEAD.match(line):
            blocks.append(_block("heading", m.group(2), {"level": len(m.group(1))}))
            i += 1
        elif _CHECK.match(line):
            items, i = _items(lines, i, _CHECK, "check")
            blocks.append({"type": "checklist", "content": items})
        elif _BULLET.match(line):
            items, i = _items(lines, i, _BULLET, "bullet")
            blocks.append({"type": "bullet_list", "content": items})
        elif _ORDERED.match(line):
            items, i = _items(lines, i, _ORDERED, "ordered")
            blocks.append({"type": "ordered_list", "content": items})
        elif m := _QUOTE.match(line):
            blocks.append({"type": "blockquote", "content": [_block("paragraph", m.group(1))]})
            i += 1
        else:
            blocks.append(_block("paragraph", line))
            i += 1
    return {"type": "doc", "content": blocks}


def rich(text: str) -> str:
    """``doc(text)`` as the JSON string the task services take; ``""`` for no text."""
    return json.dumps(doc(text), ensure_ascii=False) if text.strip() else ""
