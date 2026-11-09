import pytest

from infrastructure.tasks import rank


def test_after_none_starts_the_sequence() -> None:
    assert rank.after(None) == rank.after(None)
    assert rank.after(None) < rank.after(rank.after(None))


def test_between_sorts_strictly_between_neighbours() -> None:
    low, high = rank.after(None), rank.after(rank.after(None))
    middle = rank.between(low, high)
    assert low < middle < high


def test_repeated_insertion_at_one_spot_keeps_order() -> None:
    low, high = "a", "b"
    seen = []
    for _ in range(40):
        high = rank.between(low, high)
        seen.append(high)
    assert seen == sorted(seen, reverse=True)
    assert len(set(seen)) == 40


def test_between_without_neighbours() -> None:
    assert rank.between(None, "m") < "m"
    assert rank.between("m", None) > "m"
    assert rank.between(None, None)


def test_equal_or_inverted_bounds_are_refused() -> None:
    with pytest.raises(ValueError):
        rank.between("b", "a")
    with pytest.raises(ValueError):
        rank.between("a", "a")


def test_appending_ten_thousand_ranks_stays_short_and_ordered() -> None:
    last = None
    seen = []
    for _ in range(10_000):
        last = rank.after(last)
        seen.append(last)
    assert seen == sorted(seen) and len(set(seen)) == 10_000
    assert max(len(r) for r in seen) == rank.APPEND_WIDTH


def test_after_a_between_rank_or_a_full_counter_still_sorts_after() -> None:
    inserted = rank.between(rank.after(None), rank.after(rank.after(None)))
    assert rank.after(inserted) > inserted
    full = "z" * rank.APPEND_WIDTH
    assert rank.after(full) > full
    assert not rank.after(inserted).endswith("a")
