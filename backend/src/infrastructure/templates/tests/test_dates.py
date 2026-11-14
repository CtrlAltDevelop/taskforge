from datetime import date

import pytest

from infrastructure.common.errors import ApiError
from infrastructure.templates import apply, snapshot


def test_offsets_round_trip_across_a_start_change() -> None:
    anchor = date(2026, 1, 30)
    due = date(2026, 3, 2)
    offset = snapshot._offset_of(due, anchor)
    assert offset == 31
    assert apply._shift(anchor, offset) == due.isoformat()
    # applying on another start moves every date by the same amount (month ends, leap day)
    assert apply._shift(date(2028, 2, 20), 9) == "2028-02-29"
    assert apply._shift(date(2026, 1, 1), -1) == "2025-12-31"


def test_missing_dates_stay_missing() -> None:
    assert snapshot._offset_of(None, date(2026, 1, 1)) is None
    assert snapshot._offset_of(date(2026, 1, 1), None) is None
    assert apply._shift(date(2026, 1, 1), None) == ""


def test_start_date_parsing() -> None:
    assert apply._parse_start("2026-02-03") == date(2026, 2, 3)
    assert apply._parse_start("")  # today
    with pytest.raises(ApiError):
        apply._parse_start("03/02/2026")
