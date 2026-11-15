"""A comment body: the shared rich-text document, checked and rebuilt.

The client's document is never stored as sent. It is parsed, every node is checked against a short
list and rebuilt from the keys that list allows, so nothing unknown (and no HTML: text is only ever
text) survives. A link must be http, https or mailto. Mentions are ``mention`` nodes naming a user
by id; the label is only for display and is never used to decide who was mentioned.
"""

import json
import uuid
from dataclasses import dataclass
from typing import Any, Final
from urllib.parse import urlparse

from infrastructure.common.errors import ApiError
from infrastructure.common.responses import ResponseTitle
from infrastructure.tasks.fields import BLOCKS

MAX_BYTES: Final = 50 * 1024
MAX_DEPTH: Final = 8
MAX_MENTIONS: Final = 20
LABEL_MAX: Final = 80
MARKS: Final = frozenset({"bold", "italic", "code", "link"})
LINK_SCHEMES: Final = frozenset({"http", "https", "mailto"})
BROADCASTS: Final = frozenset({"channel", "here"})


@dataclass(frozen=True, slots=True)
class Cleaned:
    """The rebuilt ``document``, its ``plain_text`` (for titles and search) and the ids of the
    people it mentions, each once, in the order they first appear."""

    document: dict[str, Any]
    plain_text: str
    mention_ids: list[uuid.UUID]
    # Only where broadcasts are allowed (chat): ``"channel"`` and/or ``"here"``, as written.
    broadcasts: frozenset[str] = frozenset()


def invalid(message: str) -> ApiError:
    return ApiError(message, title=ResponseTitle.COMMENT_INVALID)


def _href(raw: Any) -> str:
    if not isinstance(raw, str) or not raw or len(raw) > 2048 or raw != raw.strip():
        raise invalid("A link needs an address.")
    parsed = urlparse(raw)
    if parsed.scheme not in LINK_SCHEMES or (parsed.scheme != "mailto" and not parsed.netloc):
        raise invalid("A link must be an http, https or mailto address.")
    return raw


def _marks(raw: Any) -> list[dict[str, Any]]:
    if raw is None:
        return []
    if not isinstance(raw, list):
        raise invalid("Marks must be a list.")
    marks = []
    for mark in raw:
        kind = mark.get("type") if isinstance(mark, dict) else None
        if kind not in MARKS:
            raise invalid(f"Unknown mark: {kind!r}.")
        if kind == "link":
            attrs = mark.get("attrs")
            marks.append(
                {
                    "type": "link",
                    "attrs": {
                        "href": _href(attrs.get("href") if isinstance(attrs, dict) else None)
                    },
                }
            )
        else:
            marks.append({"type": kind})
    return marks


def _attrs(kind: str, raw: Any) -> dict[str, Any]:
    attrs = raw if isinstance(raw, dict) else {}
    if kind == "heading":
        level = attrs.get("level", 1)
        return {"level": level if isinstance(level, int) and 1 <= level <= 3 else 1}
    if kind == "checklist_item":
        return {"checked": attrs.get("checked") is True}
    return {}


class _Walker:
    def __init__(self, *, allow_broadcast: bool = False) -> None:
        self.allow_broadcast = allow_broadcast
        self.broadcasts: set[str] = set()
        self.mentions: list[uuid.UUID] = []
        self.lines: list[str] = []
        self._line = ""

    def _flush(self) -> None:
        if self._line:
            self.lines.append(self._line)
        self._line = ""

    def node(self, node: Any, depth: int) -> dict[str, Any]:
        if depth > MAX_DEPTH or not isinstance(node, dict):
            raise invalid("The comment is not a valid document.")
        kind = node.get("type")
        if kind == "text":
            value = node.get("text")
            if not isinstance(value, str):
                raise invalid("A text node needs a text string.")
            self._line += value
            marks = _marks(node.get("marks"))
            return {"type": "text", "text": value, **({"marks": marks} if marks else {})}
        if kind == "hard_break":
            self._line += "\n"
            return {"type": "hard_break"}
        if kind == "mention":
            return self._mention(node)
        if kind not in BLOCKS:
            raise invalid(f"Unknown comment node type: {kind!r}.")
        content = node.get("content", [])
        if not isinstance(content, list):
            raise invalid("A node's content must be a list.")
        built = [self.node(child, depth + 1) for child in content]
        self._flush()
        out: dict[str, Any] = {"type": kind}
        attrs = _attrs(kind, node.get("attrs"))
        if attrs:
            out["attrs"] = attrs
        if built:
            out["content"] = built
        return out

    def _mention(self, node: dict[str, Any]) -> dict[str, Any]:
        attrs = node.get("attrs")
        raw = attrs.get("id") if isinstance(attrs, dict) else None
        if self.allow_broadcast and raw in BROADCASTS:
            self.broadcasts.add(raw)
            self._line += f"@{raw}"
            return {"type": "mention", "attrs": {"id": raw, "label": raw}}
        try:
            user = uuid.UUID(str(raw))
        except ValueError:
            raise invalid("A mention needs a person.") from None
        label = str(attrs.get("label", ""))[:LABEL_MAX] if isinstance(attrs, dict) else ""
        if user not in self.mentions:
            self.mentions.append(user)
        if len(self.mentions) > MAX_MENTIONS:
            raise invalid(f"A comment can mention at most {MAX_MENTIONS} people.")
        self._line += f"@{label}"
        return {"type": "mention", "attrs": {"id": str(user), "label": label}}


def clean(value: str, *, allow_broadcast: bool = False, max_bytes: int = MAX_BYTES) -> Cleaned:
    """Parse and rebuild ``value`` (the document as JSON), or raise ``ApiError``.

    ``allow_broadcast`` (chat) also accepts ``@channel`` / ``@here`` mention nodes, reported in
    ``Cleaned.broadcasts``; ``max_bytes`` lowers the size cap."""
    if not value.strip():
        raise invalid("Write something first.")
    if len(value.encode()) > max_bytes:
        raise invalid(f"A message can be at most {max_bytes // 1024} KB.")
    try:
        document = json.loads(value)
    except (ValueError, RecursionError):
        raise invalid("The comment must be valid JSON.") from None
    if not isinstance(document, dict) or document.get("type") != "doc":
        raise invalid('The comment must be a {"type": "doc"} document.')
    content = document.get("content", [])
    if not isinstance(content, list):
        raise invalid("The document content must be a list.")
    walker = _Walker(allow_broadcast=allow_broadcast)
    built = [walker.node(child, 1) for child in content]
    walker._flush()
    plain = "\n".join(walker.lines)
    if not plain.strip():
        raise invalid("Write something first.")
    return Cleaned(
        {"type": "doc", "content": built}, plain, walker.mentions, frozenset(walker.broadcasts)
    )


def plain_text(document: dict[str, Any], *, allow_broadcast: bool = False) -> str:
    """The text of a stored (already clean) document."""
    return clean(json.dumps(document), allow_broadcast=allow_broadcast).plain_text


def mentions_of(document: dict[str, Any], *, allow_broadcast: bool = False) -> Cleaned:
    """What a stored (already clean) document mentions: the same walk as ``clean``."""
    return clean(json.dumps(document), allow_broadcast=allow_broadcast)


def relabel(document: dict[str, Any], labels: dict[str, str]) -> dict[str, Any]:
    """The document with every mention's label set to the person's own name (``labels`` by id), so
    what readers see always matches who was notified, whatever the client sent."""

    def convert(node: dict[str, Any]) -> dict[str, Any]:
        if node.get("type") == "mention":
            ident = node["attrs"]["id"]
            return {"type": "mention", "attrs": {"id": ident, "label": labels.get(ident, "")}}
        children = node.get("content")
        if children is None:
            return node
        return {**node, "content": [convert(child) for child in children]}

    return convert(document)


def for_description(document: dict[str, Any]) -> dict[str, Any]:
    """The document as a task description can hold it: a mention becomes its ``@label`` text."""

    def convert(node: dict[str, Any]) -> dict[str, Any]:
        if node.get("type") == "mention":
            return {"type": "text", "text": f"@{node.get('attrs', {}).get('label', '')}"}
        children = node.get("content")
        if children is None:
            return node
        return {**node, "content": [convert(child) for child in children]}

    return convert(document)
