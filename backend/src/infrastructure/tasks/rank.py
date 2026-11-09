"""Fractional-indexing rank strings: ``between(a, b)`` is a string sorting strictly between.

Lowercase letters only, so the order is the same under any database collation. A rank never
ends in ``a`` (the smallest digit), which is what keeps a string below it always available.
"""

from typing import Final

ALPHABET: Final = "abcdefghijklmnopqrstuvwxyz"
BASE: Final = len(ALPHABET)


def between(low: str | None, high: str | None) -> str:
    """A rank strictly between ``low`` and ``high`` (either may be None for "no bound")."""
    low = low or ""
    if high is not None and low >= high:
        raise ValueError("low must sort before high")
    result: list[str] = []
    tight_high = high is not None
    position = 0
    while True:
        low_digit = ALPHABET.index(low[position]) if position < len(low) else 0
        high_digit = (
            ALPHABET.index(high[position])
            if tight_high and high is not None and position < len(high)
            else BASE
        )
        if high_digit - low_digit > 1:
            result.append(ALPHABET[(low_digit + high_digit) // 2])
            return "".join(result)
        result.append(ALPHABET[low_digit])
        if low_digit < high_digit:
            tight_high = False
        position += 1


APPEND_WIDTH: Final = 6
APPEND_DIGITS: Final = ALPHABET[1:]  # no "a": a rank never ends in it, and 25**6 is ~244 million


def after(last: str | None) -> str:
    """A rank sorting after ``last`` (or the first rank when there is none).

    Appending is the common case (a new task goes last), so it counts in fixed width: the
    rank stays 6 characters however many tasks there are. A rank that is not in that form
    (one made by ``between``) or a full counter falls back to ``between(last, None)``.
    """
    if last is None:
        return APPEND_DIGITS[0] * APPEND_WIDTH
    if len(last) == APPEND_WIDTH and all(c in APPEND_DIGITS for c in last):
        digits = list(last)
        for index in range(APPEND_WIDTH - 1, -1, -1):
            position = APPEND_DIGITS.index(digits[index])
            if position + 1 < len(APPEND_DIGITS):
                digits[index] = APPEND_DIGITS[position + 1]
                return "".join(digits)
            digits[index] = APPEND_DIGITS[0]
    return between(last, None)
