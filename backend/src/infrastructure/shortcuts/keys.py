"""What a key chord may look like: modifiers in a fixed order, then one key, joined by ``+``.

``mod`` is Cmd on macOS and Ctrl elsewhere, so a chord means the same thing on every device a
person signs in on. Anything else is refused, not repaired, so a client bug shows up at once."""

import json
import re
from pathlib import Path
from typing import Final

from infrastructure.common.errors import ApiError
from infrastructure.common.responses import ResponseTitle

MODIFIERS: Final = ("mod", "ctrl", "alt", "shift")
NAMED: Final = frozenset(
    {
        "enter",
        "escape",
        "space",
        "tab",
        "backspace",
        "delete",
        "up",
        "down",
        "left",
        "right",
        "home",
        "end",
        "pageup",
        "pagedown",
        "slash",
        "comma",
        "period",
        "question",
        "bracketleft",
        "bracketright",
    }  # fmt: skip
)
FUNCTION_KEY = re.compile(r"^f([1-9]|1[0-2])$")
# Browsers keep these: a binding that cannot fire is worse than none. One list for both sides: the
# app's ``Chord.isBrowserReserved`` must hold the same chords (a test in each reads this file).
RESERVED: Final = frozenset(
    json.loads((Path(__file__).parent / "reserved_chords.json").read_text())
)


def invalid(message: str) -> ApiError:
    return ApiError(message, title=ResponseTitle.SHORTCUT_INVALID)


def _is_key(token: str) -> bool:
    return (
        (len(token) == 1 and token.isascii() and token.isalnum())
        or token in NAMED
        or bool(FUNCTION_KEY.match(token))
    )


def normalise(raw: str) -> str:
    """Return the canonical chord, ``""`` for unbound, or refuse a chord that means nothing."""
    text = raw.strip().lower()
    if not text:
        return ""
    parts = [p.strip() for p in text.split("+")]
    key = parts[-1]
    mods = parts[:-1]
    if not _is_key(key):
        raise invalid(f"'{key}' is not a key.")
    unknown = [m for m in mods if m not in MODIFIERS]
    if unknown:
        raise invalid(f"'{unknown[0]}' is not a modifier.")
    if len(set(mods)) != len(mods):
        raise invalid("A modifier is repeated.")
    if "mod" in mods and "ctrl" in mods:
        raise invalid("Use either mod or ctrl, not both.")
    chord = "+".join([*(m for m in MODIFIERS if m in mods), key])
    if chord in RESERVED:
        raise invalid(f"{chord} belongs to the browser.")
    return chord
