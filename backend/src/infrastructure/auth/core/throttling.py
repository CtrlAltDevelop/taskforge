"""Caps on how often a flow will send a code or accept a guess.

The counters live in the same store as the challenges, so a deployment that runs
Redis gets limits that hold across every worker rather than per process.
"""

from hashlib import sha256

from django.conf import settings

from infrastructure.auth.core.challenges import get_challenge_store

HOUR_SECONDS = 3600


class RateLimited(RuntimeError):
    """Raised when a caller has to wait before trying again."""

    def __init__(self, message: str, retry_after: int) -> None:
        super().__init__(message)
        self.retry_after = retry_after


def fingerprint(value: str) -> str:
    """Return a short digest so counters never hold a raw address or number."""
    return sha256(value.encode()).hexdigest()[:32]


def guard_delivery(scope: str, destination: str) -> None:
    """Enforce the resend cooldown and the hourly ceiling for one destination.

    The cooldown is charged before the message is handed to a carrier, so a
    provider outage cannot be turned into an unmetered send loop.
    """
    store = get_challenge_store()
    tag = f"{scope}:{fingerprint(destination)}"
    cooldown = settings.AUTH_RESEND_COOLDOWN_SECONDS
    if cooldown > 0 and store.increment(f"cooldown:{tag}", cooldown) > 1:
        raise RateLimited("A code was just sent. Wait before requesting another.", cooldown)
    ceiling = settings.AUTH_MAX_SENDS_PER_HOUR
    if ceiling > 0 and store.increment(f"hourly:{tag}", HOUR_SECONDS) > ceiling:
        raise RateLimited("Too many codes requested. Try again later.", HOUR_SECONDS)


def guard_attempts(scope: str, subject: str, *, limit: int, window: int = HOUR_SECONDS) -> None:
    """Cap repeated guesses against one subject, such as a password login."""
    store = get_challenge_store()
    tag = f"{scope}:{fingerprint(subject)}"
    if limit > 0 and store.increment(f"attempts:{tag}", window) > limit:
        raise RateLimited("Too many attempts. Try again later.", window)


def attempts_exhausted(scope: str, subject: str, *, limit: int) -> bool:
    """Whether [subject] has already used up its failed attempts. Does not count one."""
    tag = f"{scope}:{fingerprint(subject)}"
    return limit > 0 and get_challenge_store().count(f"attempts:{tag}") >= limit


def record_failed_attempt(scope: str, subject: str, *, window: int) -> None:
    """Charge one failed attempt, so only wrong guesses (never successes) add up."""
    get_challenge_store().increment(f"attempts:{scope}:{fingerprint(subject)}", window)


def clear_attempts(scope: str, subject: str) -> None:
    """Forget a subject's failures, e.g. after the owner signs in properly."""
    get_challenge_store().clear(f"attempts:{scope}:{fingerprint(subject)}")
