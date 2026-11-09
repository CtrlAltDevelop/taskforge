import pytest

from infrastructure.common.errors import ApiError
from infrastructure.projects import fields


@pytest.mark.parametrize(
    ("raw", "stored"),
    [("WEB", "WEB"), ("web", "WEB"), (" Ab ", "AB"), ("abcdef", "ABCDEF")],
)
def test_valid_keys_are_stored_uppercase(raw: str, stored: str) -> None:
    assert fields.clean_key(raw) == stored


@pytest.mark.parametrize("raw", ["", "A", "ABCDEFG", "AB1", "A-B", "W E", "ÄÖ", "12", "AB_"])
def test_invalid_keys_are_refused(raw: str) -> None:
    with pytest.raises(ApiError) as refusal:
        fields.clean_key(raw)
    assert refusal.value.status == 400


@pytest.mark.parametrize("name", ["", "   ", "x" * 81])
def test_bad_names_are_refused(name: str) -> None:
    with pytest.raises(ApiError):
        fields.clean_name(name)


def test_name_bounds_are_inclusive() -> None:
    assert fields.clean_name(" x ") == "x"
    assert len(fields.clean_name("x" * 80)) == 80


def test_description_limit() -> None:
    assert len(fields.clean_description("d" * 2000)) == 2000
    with pytest.raises(ApiError):
        fields.clean_description("d" * 2001)


@pytest.mark.parametrize("color", ["#12ab9F", ""])
def test_valid_colors(color: str) -> None:
    assert fields.clean_color(color) == color.upper()


@pytest.mark.parametrize("color", ["red", "#12345", "#1234567", "123456", "#GGGGGG"])
def test_invalid_colors(color: str) -> None:
    with pytest.raises(ApiError):
        fields.clean_color(color)


@pytest.mark.parametrize("icon", ["rocket", "🚀", ""])
def test_valid_icons(icon: str) -> None:
    assert fields.clean_icon(icon) == icon


@pytest.mark.parametrize("icon", ["x" * 33, "a\nb", "a\x00"])
def test_invalid_icons(icon: str) -> None:
    with pytest.raises(ApiError):
        fields.clean_icon(icon)


def test_visibility_must_be_known() -> None:
    assert fields.clean_visibility("private") == "private"
    with pytest.raises(ApiError):
        fields.clean_visibility("secret")
