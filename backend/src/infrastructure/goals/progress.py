"""The arithmetic of progress. Pure functions: no database, no clock beyond the date passed in.

Progress is a float from 0 to 1. A key result's comes from its type; a goal's is the weighted
average of its key results and its child goals (each child counts with its own ``weight``). A
denominator of zero never raises: a linked key result without tasks is at 0, a goal without
anything to average is at 0.
"""

from collections.abc import Iterable
from datetime import date
from decimal import Decimal
from typing import Final

from infrastructure.goals.models import GoalStatus, KrType

AT_RISK_GAP: Final = 0.10  # this far behind the elapsed share of the period: at risk
OFF_TRACK_GAP: Final = 0.25  # this far behind: off track


def clamp(value: float) -> float:
    return max(0.0, min(1.0, value))


def number_progress(start: Decimal, target: Decimal, current: Decimal) -> float:
    """From ``start`` towards ``target``: works for a target above or below the start. When the
    two are equal there is no distance to cover, so it is done exactly when ``current`` is there."""
    span = target - start
    if span == 0:
        return 1.0 if current == target else 0.0
    return clamp(float((current - start) / span))


def kr_progress(
    kind: str,
    start: Decimal,
    target: Decimal,
    current: Decimal,
    done: int = 0,
    total: int = 0,
) -> float:
    if kind == KrType.LINKED:
        return clamp(done / total) if total > 0 else 0.0
    if kind == KrType.BOOLEAN:
        return 1.0 if current >= 1 else 0.0
    if kind == KrType.PERCENTAGE:
        return number_progress(Decimal(0), Decimal(100), current)
    return number_progress(start, target, current)


def weighted(items: Iterable[tuple[float, Decimal]]) -> float:
    """The weighted average of ``(progress, weight)`` pairs; 0 when the weights add up to 0."""
    pairs = list(items)
    weight = sum((w for _, w in pairs), Decimal(0))
    if weight <= 0:
        return 0.0
    return clamp(sum(p * float(w) for p, w in pairs) / float(weight))


def elapsed_share(start: date, end: date, today: date) -> float:
    if today <= start:
        return 0.0
    if today >= end or end <= start:
        return 1.0
    return (today - start).days / (end - start).days


def risk_hint(progress: float, start: date, end: date, today: date) -> str:
    """Compare the progress with the share of the period gone: on track, at risk or off track."""
    if progress >= 1.0:
        return GoalStatus.ON_TRACK
    behind = elapsed_share(start, end, today) - progress
    if behind >= OFF_TRACK_GAP:
        return GoalStatus.OFF_TRACK
    if behind >= AT_RISK_GAP:
        return GoalStatus.AT_RISK
    return GoalStatus.ON_TRACK


def status_of(override: str, hint: str) -> str:
    return override if override in GoalStatus.ALL else hint
