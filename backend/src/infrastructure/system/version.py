"""The version this build reports, and the SemVer comparison clients are held to.

Source of truth is the ``VERSION`` file at the repository root. A Docker image has no repository
around it, so the image build writes it to ``TASKFORGE_VERSION``; ``DJANGO_APP_VERSION`` (the
``APP_VERSION`` setting) overrides both for a custom build.
"""

import os
import re
from dataclasses import dataclass
from functools import cache
from pathlib import Path

from django.conf import settings

_SEMVER = re.compile(r"^v?(\d+)\.(\d+)\.(\d+)(?:-([0-9A-Za-z.-]+))?(?:\+[0-9A-Za-z.-]+)?$")
UNKNOWN_VERSION = "0.0.0-dev"
API_VERSION = "v1"


@dataclass(frozen=True, slots=True, order=True)
class SemVer:
    """A parsed version. A pre-release (``1.2.0-rc.1``) sorts before its release."""

    major: int
    minor: int
    patch: int
    # Sorts before a release: (0, "rc.1") < (1, "").
    pre: tuple[int, str] = (1, "")


def parse(text: str) -> SemVer | None:
    """Return the version in ``text``, or ``None`` when it is not SemVer."""
    match = _SEMVER.match(text.strip())
    if match is None:
        return None
    major, minor, patch, pre = match.groups()
    return SemVer(int(major), int(minor), int(patch), (0, pre) if pre else (1, ""))


def is_older(version: str, minimum: str) -> bool:
    """Whether ``version`` is below ``minimum``. Anything unparseable is never "older"."""
    have, floor = parse(version), parse(minimum)
    return have is not None and floor is not None and have < floor


@cache
def _file_version() -> str:
    for parent in Path(__file__).resolve().parents:
        candidate = parent / "VERSION"
        if candidate.is_file():
            return candidate.read_text(encoding="utf-8").strip()
    return ""


def server_version() -> str:
    return (
        getattr(settings, "APP_VERSION", "")
        or os.getenv("TASKFORGE_VERSION", "")
        or _file_version()
        or UNKNOWN_VERSION
    )


def min_client_version() -> str:
    return str(getattr(settings, "MIN_CLIENT_VERSION", "0.0.0"))


def version_info() -> dict[str, str]:
    return {
        "version": server_version(),
        "min_client_version": min_client_version(),
        "api": API_VERSION,
        "commit": str(getattr(settings, "BUILD_COMMIT", "")),
    }
