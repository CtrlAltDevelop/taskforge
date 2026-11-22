"""Rich-text bodies with real mentions, for comments and chat messages (same JSON shape)."""

import json
from typing import Any


def _part(part: Any) -> dict[str, Any]:
    if isinstance(part, str):
        return {"type": "text", "text": part}
    label = part.profile.display_name or part.username  # a user: a mention node
    return {"type": "mention", "attrs": {"id": str(part.pk), "label": label}}


def broadcast(kind: str) -> dict[str, Any]:
    return {"type": "mention", "attrs": {"id": kind, "label": kind}}


def body(*paragraphs: Any) -> str:
    """Each argument is one paragraph: a string, or a list of strings, users (mentioned) and
    broadcast nodes."""
    blocks = []
    for item in paragraphs:
        parts = [item] if isinstance(item, (str, dict)) or hasattr(item, "pk") else item
        content = [p if isinstance(p, dict) else _part(p) for p in parts]
        blocks.append({"type": "paragraph", "content": content})
    return json.dumps({"type": "doc", "content": blocks}, ensure_ascii=False)
