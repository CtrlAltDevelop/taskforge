"""What a workspace URL name may look like."""

import re
from typing import Final

from infrastructure.common.errors import ApiError
from infrastructure.common.responses import ResponseTitle

SLUG_PATTERN: Final = re.compile(r"^[a-z0-9](?:[a-z0-9-]{1,38})[a-z0-9]$")
RESERVED_SLUGS: Final = frozenset(
    {
        "api", "admin", "app", "www", "static", "media", "auth", "login", "logout", "signup",
        "signin", "register", "settings", "support", "help", "docs", "status", "billing",
        "blog", "about", "mail", "root", "system", "taskforge", "workspace", "workspaces",
        "new", "null", "undefined", "me", "grpc", "ws", "health",
    }
)  # fmt: skip


def validate_slug(slug: str) -> str:
    """Return the slug if it is well-formed and not reserved, else refuse."""
    if not SLUG_PATTERN.fullmatch(slug):
        raise ApiError(
            "Use 3-40 lowercase letters, digits or hyphens, not starting or ending with a hyphen.",
            title=ResponseTitle.SLUG_INVALID,
        )
    if slug in RESERVED_SLUGS:
        raise ApiError("That URL name is reserved.", title=ResponseTitle.SLUG_INVALID)
    return slug
