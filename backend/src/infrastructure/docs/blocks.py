"""The body of a page: a versioned list of blocks, checked and rebuilt on every save.

Schema version 1. A block is ``{"id", "type", "attrs"?, ...}``; the content depends on the type:

* ``paragraph``, ``quote``: ``content`` (inline nodes).
* ``heading``: ``attrs.level`` 1-3, ``content``.
* ``bullet_item``, ``numbered_item``: ``attrs.indent`` 0-5, ``content``.
* ``checklist_item``: ``attrs.indent``, ``attrs.checked``, ``content``.
* ``code``: ``attrs.language`` and ``text`` (plain text).
* ``table``: ``rows`` (rows of cells; a cell is a list of inline nodes) and ``attrs.header`` (the
  first row is a header).
* ``divider``: nothing.
* ``image``: ``attrs.src`` (http or https), ``attrs.alt``, ``attrs.width``.
* ``callout``: ``attrs.tone`` (info, warning, success, danger) and ``content``.
* ``task_card``: ``attrs.task_id``.

Inline nodes: ``text`` (``text`` and ``marks``: bold italic strike code link), ``hard_break`` and
``mention`` (``attrs.doc_id``, ``attrs.label``: a ``[[`` page mention). Known blocks are rebuilt
from the keys listed, so nothing else (and no HTML: text is only ever text) survives. A block or
inline node of a type this version does not know is kept exactly as it came (it may be from a newer
client), checked only for being plain JSON of bounded depth; it is never dropped.
"""

import json
import uuid
from dataclasses import dataclass, field
from typing import Any, Final
from urllib.parse import urlparse

from infrastructure.common.errors import ApiError
from infrastructure.common.responses import ResponseTitle

SCHEMA_VERSION: Final = 1
MAX_BYTES: Final = 2 * 1024 * 1024
MAX_BLOCKS: Final = 5000
MAX_TEXT: Final = 100_000
MAX_DEPTH: Final = 16
MAX_ROWS: Final = 200
MAX_COLUMNS: Final = 20
MAX_INDENT: Final = 5
ID_MAX: Final = 64
LABEL_MAX: Final = 200
MARKS: Final = ("bold", "italic", "strike", "code", "link")
LINK_SCHEMES: Final = frozenset({"http", "https", "mailto"})
TONES: Final = ("info", "warning", "success", "danger")
KNOWN: Final = frozenset(
    {
        "paragraph",
        "quote",
        "heading",
        "bullet_item",
        "numbered_item",
        "checklist_item",
        "code",
        "table",
        "divider",
        "image",
        "callout",
        "task_card",
    }
)


def invalid(message: str) -> ApiError:
    return ApiError(message, title=ResponseTitle.DOC_INVALID)


@dataclass(slots=True)
class Cleaned:
    """The rebuilt ``blocks`` and what they point at: ids of mentioned pages and embedded tasks,
    each once, in order."""

    blocks: list[dict[str, Any]]
    doc_ids: list[uuid.UUID] = field(default_factory=list)
    task_ids: list[uuid.UUID] = field(default_factory=list)


def _uuid(raw: Any, what: str) -> uuid.UUID:
    try:
        return uuid.UUID(str(raw))
    except ValueError:
        raise invalid(f"{what} needs a valid id.") from None


def _int(raw: Any, default: int) -> int:
    return raw if isinstance(raw, int) and not isinstance(raw, bool) else default


def _href(raw: Any) -> str:
    if not isinstance(raw, str) or not raw or len(raw) > 2048 or raw != raw.strip():
        raise invalid("A link needs an address.")
    parsed = urlparse(raw)
    if parsed.scheme not in LINK_SCHEMES or (parsed.scheme != "mailto" and not parsed.netloc):
        raise invalid("A link must be an http, https or mailto address.")
    return raw


def _plain_json(value: Any, depth: int = 0) -> Any:
    """``value`` if it is plain JSON of bounded depth (what an unknown node may be), else raise."""
    if depth > MAX_DEPTH:
        raise invalid("A block is nested too deeply.")
    if value is None or isinstance(value, (bool, int, float, str)):
        return value
    if isinstance(value, list):
        return [_plain_json(v, depth + 1) for v in value]
    if isinstance(value, dict) and all(isinstance(k, str) for k in value):
        return {k: _plain_json(v, depth + 1) for k, v in value.items()}
    raise invalid("A block holds something that is not JSON.")


def _marks(raw: Any) -> list[Any]:
    if raw is None:
        return []
    if not isinstance(raw, list):
        raise invalid("Marks must be a list.")
    marks: list[Any] = []
    for mark in raw:
        if not isinstance(mark, dict) or not isinstance(mark.get("type"), str):
            raise invalid("A mark needs a type.")
        kind = mark["type"]
        if kind == "link":
            attrs = mark.get("attrs")
            href = _href(attrs.get("href") if isinstance(attrs, dict) else None)
            marks.append({"type": "link", "attrs": {"href": href}})
        elif kind in MARKS:
            marks.append({"type": kind})
        else:
            marks.append(_plain_json(mark))  # a newer client's mark: kept
    return marks


class _Walker:
    def __init__(self) -> None:
        self.cleaned = Cleaned([])
        self._ids: set[str] = set()

    def _text(self, value: Any) -> str:
        if not isinstance(value, str):
            raise invalid("Text must be a string.")
        if len(value) > MAX_TEXT:
            raise invalid("That text is too long.")
        return value

    def inline(self, node: Any) -> dict[str, Any]:
        if not isinstance(node, dict) or not isinstance(node.get("type"), str):
            raise invalid("An inline node needs a type.")
        kind = node["type"]
        if kind == "text":
            out: dict[str, Any] = {"type": "text", "text": self._text(node.get("text"))}
            marks = _marks(node.get("marks"))
            if marks:
                out["marks"] = marks
            return out
        if kind == "hard_break":
            return {"type": "hard_break"}
        if kind == "mention":
            attrs = node.get("attrs")
            attrs = attrs if isinstance(attrs, dict) else {}
            target = _uuid(attrs.get("doc_id"), "A page mention")
            if target not in self.cleaned.doc_ids:
                self.cleaned.doc_ids.append(target)
            label = str(attrs.get("label", ""))[:LABEL_MAX]
            return {"type": "mention", "attrs": {"doc_id": str(target), "label": label}}
        return _plain_json(node)  # a newer client's inline node: kept

    def inlines(self, raw: Any) -> list[dict[str, Any]]:
        if raw is None:
            return []
        if not isinstance(raw, list):
            raise invalid("A block's content must be a list.")
        return [self.inline(n) for n in raw]

    def _block_id(self, raw: Any) -> str:
        ident = raw if isinstance(raw, str) and 0 < len(raw) <= ID_MAX else ""
        if not ident or ident in self._ids:
            ident = uuid.uuid4().hex
        self._ids.add(ident)
        return ident

    def block(self, node: Any) -> dict[str, Any]:
        if not isinstance(node, dict) or not isinstance(node.get("type"), str):
            raise invalid("A block needs a type.")
        kind = node["type"]
        if kind not in KNOWN:
            if isinstance(node.get("id"), str):
                self._ids.add(node["id"])
            return _plain_json(node)  # a type this version does not know: kept untouched
        attrs = node.get("attrs")
        attrs = attrs if isinstance(attrs, dict) else {}
        out: dict[str, Any] = {"id": self._block_id(node.get("id")), "type": kind}
        out.update(getattr(self, f"_{kind}")(node, attrs))
        return out

    # One builder per known type; each returns the keys beyond ``id`` and ``type``.

    def _text_block(self, node: dict[str, Any], attrs: dict[str, Any]) -> dict[str, Any]:
        return {"content": self.inlines(node.get("content"))}

    _paragraph = _quote = _text_block

    def _heading(self, node: dict[str, Any], attrs: dict[str, Any]) -> dict[str, Any]:
        level = min(max(_int(attrs.get("level"), 1), 1), 3)
        return {"attrs": {"level": level}, "content": self.inlines(node.get("content"))}

    def _bullet_item(self, node: dict[str, Any], attrs: dict[str, Any]) -> dict[str, Any]:
        indent = min(max(_int(attrs.get("indent"), 0), 0), MAX_INDENT)
        return {"attrs": {"indent": indent}, "content": self.inlines(node.get("content"))}

    _numbered_item = _bullet_item

    def _checklist_item(self, node: dict[str, Any], attrs: dict[str, Any]) -> dict[str, Any]:
        indent = min(max(_int(attrs.get("indent"), 0), 0), MAX_INDENT)
        return {
            "attrs": {"indent": indent, "checked": attrs.get("checked") is True},
            "content": self.inlines(node.get("content")),
        }

    def _code(self, node: dict[str, Any], attrs: dict[str, Any]) -> dict[str, Any]:
        return {
            "attrs": {"language": str(attrs.get("language", ""))[:32]},
            "text": self._text(node.get("text", "")),
        }

    def _table(self, node: dict[str, Any], attrs: dict[str, Any]) -> dict[str, Any]:
        rows = node.get("rows", [])
        if not isinstance(rows, list) or len(rows) > MAX_ROWS:
            raise invalid(f"A table can have at most {MAX_ROWS} rows.")
        built = []
        for row in rows:
            if not isinstance(row, list) or len(row) > MAX_COLUMNS:
                raise invalid(f"A table can have at most {MAX_COLUMNS} columns.")
            built.append([self.inlines(cell) for cell in row])
        return {"attrs": {"header": attrs.get("header") is True}, "rows": built}

    def _divider(self, node: dict[str, Any], attrs: dict[str, Any]) -> dict[str, Any]:
        return {}

    def _image(self, node: dict[str, Any], attrs: dict[str, Any]) -> dict[str, Any]:
        src = attrs.get("src")
        parsed = urlparse(src) if isinstance(src, str) else None
        if (
            not isinstance(src, str)
            or len(src) > 2048
            or parsed is None
            or parsed.scheme not in ("http", "https")
            or not parsed.netloc
        ):
            raise invalid("An image needs an http or https address.")
        out: dict[str, Any] = {"src": src, "alt": str(attrs.get("alt", ""))[:LABEL_MAX]}
        width = attrs.get("width")
        if isinstance(width, int) and not isinstance(width, bool) and 0 < width <= 10_000:
            out["width"] = width
        return {"attrs": out}

    def _callout(self, node: dict[str, Any], attrs: dict[str, Any]) -> dict[str, Any]:
        tone = attrs.get("tone")
        return {
            "attrs": {"tone": tone if tone in TONES else "info"},
            "content": self.inlines(node.get("content")),
        }

    def _task_card(self, node: dict[str, Any], attrs: dict[str, Any]) -> dict[str, Any]:
        task = _uuid(attrs.get("task_id"), "A task card")
        if task not in self.cleaned.task_ids:
            self.cleaned.task_ids.append(task)
        return {"attrs": {"task_id": str(task)}}


def clean(value: str, schema_version: int = 0) -> Cleaned:
    """Parse and rebuild ``value`` (the blocks as a JSON array), or raise ``ApiError``.
    ``schema_version`` 0 means the current one; a newer one than this server knows is refused."""
    if schema_version not in (0, SCHEMA_VERSION):
        raise invalid(f"This server reads block schema {SCHEMA_VERSION}, not {schema_version}.")
    if len(value.encode()) > MAX_BYTES:
        raise invalid(f"A page can be at most {MAX_BYTES // 1024 // 1024} MB.")
    try:
        raw = json.loads(value) if value.strip() else []
    except (ValueError, RecursionError):
        raise invalid("The blocks must be valid JSON.") from None
    if not isinstance(raw, list):
        raise invalid("The blocks must be a JSON array.")
    if len(raw) > MAX_BLOCKS:
        raise invalid(f"A page can have at most {MAX_BLOCKS} blocks.")
    walker = _Walker()
    try:
        walker.cleaned.blocks = [walker.block(b) for b in raw]
    except RecursionError:
        raise invalid("A block is nested too deeply.") from None
    return walker.cleaned


def references(blocks: list[dict[str, Any]]) -> tuple[list[uuid.UUID], list[uuid.UUID]]:
    """``(page ids, task ids)`` a stored (already clean) list points at."""
    found = clean(json.dumps(blocks))
    return found.doc_ids, found.task_ids


def _inline_text(nodes: list[Any]) -> str:
    parts = []
    for node in nodes:
        if not isinstance(node, dict):
            continue
        if node.get("type") == "text":
            parts.append(str(node.get("text", "")))
        elif node.get("type") == "hard_break":
            parts.append("\n")
        elif node.get("type") == "mention":
            parts.append(str(node.get("attrs", {}).get("label", "")))
    return "".join(parts)


def plain_text(blocks: list[dict[str, Any]]) -> str:
    """The words of a stored list, one line per block (for search and snippets)."""
    lines = []
    for block in blocks:
        if not isinstance(block, dict):
            continue
        kind = block.get("type")
        if kind == "code":
            lines.append(str(block.get("text", "")))
        elif kind == "table":
            lines.extend(
                " ".join(c for c in (_inline_text(cell) for cell in row) if c)
                for row in block.get("rows", [])
            )
        elif kind == "image":
            lines.append(str(block.get("attrs", {}).get("alt", "")))
        elif isinstance(block.get("content"), list):
            lines.append(_inline_text(block["content"]))
    return "\n".join(line for line in lines if line.strip())


def strip_ids(blocks: list[dict[str, Any]]) -> list[dict[str, Any]]:
    """The blocks without their ids (to compare two lists by content)."""
    return [{k: v for k, v in b.items() if k != "id"} for b in blocks]
