"""Per-type validation and the wire form, with no database."""

from decimal import Decimal

import pytest

from infrastructure.common.errors import ApiError
from infrastructure.common.responses import ResponseTitle
from infrastructure.customfields import types
from infrastructure.customfields.types import EMPTY, Stored

OPTIONS = [
    {"id": "a", "label": "Alpha", "color": "#FF0000"},
    {"id": "b", "label": "Beta", "color": ""},
]


def _user(raw: str) -> str:
    if raw != "u1":
        raise types.invalid("No such user.")
    return raw


def _clean(kind: str, raw: str) -> Stored:
    return types.clean_value(kind, OPTIONS, raw, _user)


@pytest.mark.parametrize(
    ("kind", "raw", "wire"),
    [
        ("text", "  hello ", "hello"),
        ("url", "https://a.example/x?y=1", "https://a.example/x?y=1"),
        ("number", "12.50", "12.5"),
        ("number", "-3", "-3"),
        ("number", "100", "100"),
        ("money", "12.5 usd", "12.50 USD"),
        ("money", "0.0001 EUR", "0.0001 EUR"),
        ("date", "2026-02-28", "2026-02-28"),
        ("checkbox", "TRUE", "true"),
        ("checkbox", "false", "false"),
        ("select", "b", "b"),
        ("multiselect", "b, a", "a,b"),
        ("user", "u1", "u1"),
    ],
)
def test_value_round_trips_to_its_wire_form(kind: str, raw: str, wire: str) -> None:
    stored = _clean(kind, raw)

    assert types.render(kind, stored) == wire
    assert types.render(kind, _clean(kind, wire)) == wire


@pytest.mark.parametrize("kind", ["text", "number", "select", "date", "checkbox", "money"])
def test_blank_value_is_empty(kind: str) -> None:
    assert _clean(kind, "  ") == EMPTY
    assert types.render(kind, EMPTY) == ""


@pytest.mark.parametrize(
    ("kind", "raw"),
    [
        ("text", "x" * 501),
        ("url", "ftp://a.example"),
        ("url", "https://a b.example"),
        ("url", "https://é.example"),
        ("url", "javascript:alert(1)"),
        ("number", "abc"),
        ("number", "NaN"),
        ("number", "Infinity"),
        ("number", "1.1234567"),
        ("number", "1" + "0" * 20),
        ("money", "12.50"),
        ("money", "12.50 US"),
        ("money", "1.23456 USD"),
        ("date", "2026-02-30"),
        ("date", "28/02/2026"),
        ("checkbox", "yes"),
        ("select", "zzz"),
        ("multiselect", "a,zzz"),
        ("user", "nobody"),
    ],
)
def test_invalid_value_is_refused_with_field_invalid(kind: str, raw: str) -> None:
    with pytest.raises(ApiError) as refusal:
        _clean(kind, raw)

    assert refusal.value.title is ResponseTitle.FIELD_INVALID


def test_money_never_goes_through_a_float() -> None:
    stored = _clean("money", "0.1 USD")

    assert stored.number == Decimal("0.1")
    assert types.render("money", Stored(text="USD", number=Decimal("1234567890123.4567"))) == (
        "1234567890123.4567 USD"
    )


def test_multiselect_keeps_option_order_and_drops_repeats() -> None:
    assert _clean("multiselect", "b,a,b").json == ["a", "b"]


def test_options_get_ids_and_must_be_distinct() -> None:
    cleaned = types.clean_options(
        "select", [{"label": "One"}, {"label": "Two", "color": "#abcdef"}]
    )

    assert all(len(o["id"]) == 32 for o in cleaned)
    assert cleaned[1]["color"] == "#ABCDEF"
    for bad in (
        [],
        [{"label": "A"}, {"label": "a"}],
        [{"id": "x", "label": "A"}, {"id": "x", "label": "B"}],
        [{"label": "A", "color": "red"}],
        [{"label": " "}],
    ):
        with pytest.raises(ApiError):
            types.clean_options("select", bad)


def test_only_select_types_take_options() -> None:
    assert types.clean_options("text", []) == []
    with pytest.raises(ApiError):
        types.clean_options("text", [{"label": "A"}])


def test_name_type_and_views_are_checked() -> None:
    assert types.clean_name("  Story points ") == "Story points"
    for call in (
        lambda: types.clean_name(" "),
        lambda: types.clean_name("x" * 61),
        lambda: types.clean_type("formula"),
        lambda: types.clean_hidden_views(["sprint"]),
    ):
        with pytest.raises(ApiError):
            call()
    assert types.clean_hidden_views(["list", "list", "board"]) == ["list", "board"]
