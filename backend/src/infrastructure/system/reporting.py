"""Error reporting to any Sentry-compatible service, optional and never a hard dependency.

Set ``DJANGO_SENTRY_DSN`` and install ``sentry-sdk`` (``pip install 'backend[sentry]'``). Without
a DSN nothing is imported; with a DSN but no SDK the process logs one warning and carries on.
"""

import logging

logger = logging.getLogger(__name__)


def init_error_reporting(
    dsn: str, *, environment: str, release: str, traces_sample_rate: float
) -> bool:
    """Start reporting; returns whether it is on."""
    if not dsn:
        return False
    try:
        import sentry_sdk
    except ImportError:
        logger.warning("DJANGO_SENTRY_DSN is set but sentry-sdk is not installed; not reporting")
        return False
    sentry_sdk.init(
        dsn=dsn,
        environment=environment,
        release=release,
        traces_sample_rate=traces_sample_rate,
        # Never send request bodies, cookies or user details: tasks and comments are private.
        send_default_pii=False,
    )
    return True
