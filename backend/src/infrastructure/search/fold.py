"""Text in a form where Persian, Arabic and Latin match each other the way people type them.

Folding is **one character in, one character out**, so a position found in the folded text is the
same position in the original (that is how matches are highlighted).
"""

import re

_MAP = str.maketrans(
    {
        "ي": "ی",  # Arabic yeh -> Persian yeh
        "ى": "ی",
        "ك": "ک",  # Arabic kaf -> Persian kaf
        "ە": "ه",
        **{chr(0x0660 + i): str(i) for i in range(10)},  # Arabic-Indic digits
        **{chr(0x06F0 + i): str(i) for i in range(10)},  # Persian digits
    }
)
_WORD = re.compile(r"[^\W_]+", re.UNICODE)
MAX_TERMS = 8


def fold(text: str) -> str:
    """Lower-case and map look-alike letters and digits; same length as ``text``."""
    lowered = "".join(c.lower() if len(c.lower()) == 1 else c for c in text)
    return lowered.translate(_MAP)


def terms(text: str) -> list[str]:
    """The words of a query, folded, without duplicates, at most ``MAX_TERMS``."""
    found: list[str] = []
    for word in _WORD.findall(fold(text)):
        if word not in found:
            found.append(word)
    return found[:MAX_TERMS]


def utf16(text: str, index: int) -> int:
    """``index`` (code points) as UTF-16 units, which is what Dart and JavaScript count."""
    return len(text[:index].encode("utf-16-le")) // 2


def marks(text: str, words: list[str]) -> list[tuple[int, int]]:
    """Where any of ``words`` starts and ends in ``text`` (UTF-16 units), sorted, no overlaps."""
    folded = fold(text)
    spans: list[tuple[int, int]] = []
    for word in sorted(words, key=len, reverse=True):
        start = folded.find(word)
        while start != -1:
            end = start + len(word)
            if not any(s < end and start < e for s, e in spans):
                spans.append((start, end))
            start = folded.find(word, end)
    return [(utf16(text, s), utf16(text, e)) for s, e in sorted(spans)]


SNIPPET_BEFORE = 40
SNIPPET_LENGTH = 160


def snippet(text: str, words: list[str]) -> tuple[str, list[tuple[int, int]]]:
    """A short excerpt of ``text`` around the first word found in it (its start when none is),
    with ``…`` where it was cut, and the spans of ``words`` inside the excerpt."""
    flat = " ".join(text.split())
    folded = fold(flat)
    first = min((i for i in (folded.find(w) for w in words) if i != -1), default=0)
    start = max(0, first - SNIPPET_BEFORE)
    if start:
        start = flat.rfind(" ", 0, start + 1) + 1 if " " in flat[: start + 1] else start
    excerpt = flat[start : start + SNIPPET_LENGTH].strip()
    cut_end = start + SNIPPET_LENGTH < len(flat)
    out = ("…" if start else "") + excerpt + ("…" if cut_end else "")
    return out, marks(out, words)
