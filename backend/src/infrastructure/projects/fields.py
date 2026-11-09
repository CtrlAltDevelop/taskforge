"""Validation of the editable project fields. Each cleaner returns the stored form or raises."""

import re
from typing import Final

from infrastructure.common.errors import ApiError
from infrastructure.projects.models import Visibility

NAME_MAX: Final = 80
DESCRIPTION_MAX: Final = 2000
ICON_MAX: Final = 32
KEY_PATTERN: Final = re.compile(r"[A-Za-z]{2,6}")
COLOR_PATTERN: Final = re.compile(r"#[0-9A-Fa-f]{6}")


def clean_name(value: str) -> str:
    cleaned = value.strip()
    if not cleaned or len(cleaned) > NAME_MAX:
        raise ApiError(f"The name must be 1-{NAME_MAX} characters.")
    return cleaned


def clean_key(value: str) -> str:
    cleaned = value.strip()
    if not KEY_PATTERN.fullmatch(cleaned):
        raise ApiError("The key must be 2-6 letters A-Z.")
    return cleaned.upper()


def clean_description(value: str) -> str:
    cleaned = value.strip()
    if len(cleaned) > DESCRIPTION_MAX:
        raise ApiError(f"The description must be at most {DESCRIPTION_MAX} characters.")
    return cleaned


def clean_icon(value: str) -> str:
    cleaned = value.strip()
    if len(cleaned) > ICON_MAX or not cleaned.isprintable():
        raise ApiError(f"The icon must be a short printable value (at most {ICON_MAX} characters).")
    return cleaned


def clean_color(value: str) -> str:
    cleaned = value.strip()
    if cleaned and not COLOR_PATTERN.fullmatch(cleaned):
        raise ApiError("The color must look like #RRGGBB.")
    return cleaned.upper()


def clean_visibility(value: str) -> str:
    if value not in Visibility.values:
        raise ApiError("Visibility must be 'open' or 'private'.")
    return value


CLEANERS = {
    "name": clean_name,
    "key": clean_key,
    "description": clean_description,
    "icon": clean_icon,
    "color": clean_color,
    "visibility": clean_visibility,
}
