from datetime import date
from decimal import Decimal

import pytest

from infrastructure.goals import progress
from infrastructure.goals.models import GoalStatus, KrType

D = Decimal


@pytest.mark.parametrize(
    ("start", "target", "current", "expected"),
    [
        (0, 10, 5, 0.5),
        (10, 0, 5, 0.5),  # a target below the start counts down
        (10, 0, 0, 1.0),
        (10, 0, 20, 0.0),  # moved the wrong way: clamped at 0
        (0, 10, 99, 1.0),
        (5, 5, 5, 1.0),  # zero span
        (5, 5, 4, 0.0),
    ],
)
def test_number_progress(start: int, target: int, current: int, expected: float) -> None:
    assert progress.number_progress(D(start), D(target), D(current)) == pytest.approx(expected)


def test_kr_progress_by_type() -> None:
    assert progress.kr_progress(KrType.LINKED, D(0), D(0), D(0), done=1, total=4) == 0.25
    assert progress.kr_progress(KrType.LINKED, D(0), D(0), D(0), done=0, total=0) == 0.0
    assert progress.kr_progress(KrType.BOOLEAN, D(0), D(1), D(1)) == 1.0
    assert progress.kr_progress(KrType.BOOLEAN, D(0), D(1), D(0)) == 0.0
    assert progress.kr_progress(KrType.PERCENTAGE, D(0), D(0), D(40)) == pytest.approx(0.4)


def test_weighted_average_and_zero_weights() -> None:
    assert progress.weighted([(1.0, D(1)), (0.0, D(3))]) == pytest.approx(0.25)
    assert progress.weighted([]) == 0.0
    assert progress.weighted([(1.0, D(0))]) == 0.0


def test_elapsed_share_edges() -> None:
    start, end = date(2026, 1, 1), date(2026, 1, 11)
    assert progress.elapsed_share(start, end, date(2025, 12, 1)) == 0.0
    assert progress.elapsed_share(start, end, date(2026, 1, 6)) == 0.5
    assert progress.elapsed_share(start, end, date(2027, 1, 1)) == 1.0
    assert progress.elapsed_share(end, start, date(2026, 1, 12)) == 1.0


def test_risk_hint_thresholds_and_override() -> None:
    s, e = date(2026, 1, 1), date(2026, 1, 11)
    today = date(2026, 1, 6)  # half gone
    assert progress.risk_hint(1.0, s, e, today) == GoalStatus.ON_TRACK
    assert progress.risk_hint(0.45, s, e, today) == GoalStatus.ON_TRACK
    assert progress.risk_hint(0.35, s, e, today) == GoalStatus.AT_RISK
    assert progress.risk_hint(0.1, s, e, today) == GoalStatus.OFF_TRACK
    assert progress.status_of(GoalStatus.AT_RISK, GoalStatus.ON_TRACK) == GoalStatus.AT_RISK
    assert progress.status_of("bogus", GoalStatus.OFF_TRACK) == GoalStatus.OFF_TRACK
