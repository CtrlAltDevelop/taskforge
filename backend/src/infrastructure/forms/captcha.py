"""Pluggable CAPTCHA check for the public form. A verifier is any object with ``verify``; the two
shipped ones (Cloudflare Turnstile, hCaptcha) are used only when their keys are in the settings, so
a self-hoster with no keys has no CAPTCHA at all and the honeypot and rate limits still apply.
"""

import json
import logging
import urllib.parse
import urllib.request
from dataclasses import dataclass
from typing import Final, Protocol

from django.conf import settings

logger = logging.getLogger(__name__)

TIMEOUT_SECONDS: Final = 5
TURNSTILE_URL: Final = "https://challenges.cloudflare.com/turnstile/v0/siteverify"
HCAPTCHA_URL: Final = "https://api.hcaptcha.com/siteverify"
MAX_TOKEN: Final = 4096


class CaptchaVerifier(Protocol):
    @property
    def provider(self) -> str: ...

    @property
    def site_key(self) -> str: ...

    def verify(self, token: str, remote_ip: str) -> bool: ...


@dataclass(frozen=True, slots=True)
class _SiteVerify:
    provider: str
    site_key: str
    secret: str
    url: str

    def verify(self, token: str, remote_ip: str) -> bool:
        if not token or len(token) > MAX_TOKEN:
            return False
        fields = {"secret": self.secret, "response": token}
        if remote_ip:
            fields["remoteip"] = remote_ip
        request = urllib.request.Request(  # noqa: S310 -- fixed https endpoints above
            self.url, data=urllib.parse.urlencode(fields).encode(), method="POST"
        )
        try:
            with urllib.request.urlopen(request, timeout=TIMEOUT_SECONDS) as answer:  # noqa: S310
                return bool(json.loads(answer.read(65536)).get("success"))
        except (OSError, ValueError):
            logger.warning("%s verification could not be completed", self.provider)
            return False  # fail closed: a visitor retries, a bot gains nothing


def TurnstileVerifier(site_key: str, secret: str) -> CaptchaVerifier:  # noqa: N802
    return _SiteVerify("turnstile", site_key, secret, TURNSTILE_URL)


def HCaptchaVerifier(site_key: str, secret: str) -> CaptchaVerifier:  # noqa: N802
    return _SiteVerify("hcaptcha", site_key, secret, HCAPTCHA_URL)


def configured() -> CaptchaVerifier | None:
    """The verifier the settings enable, or ``None`` when no keys are set."""
    if settings.FORMS_TURNSTILE_SITE_KEY and settings.FORMS_TURNSTILE_SECRET:
        return TurnstileVerifier(settings.FORMS_TURNSTILE_SITE_KEY, settings.FORMS_TURNSTILE_SECRET)
    if settings.FORMS_HCAPTCHA_SITE_KEY and settings.FORMS_HCAPTCHA_SECRET:
        return HCaptchaVerifier(settings.FORMS_HCAPTCHA_SITE_KEY, settings.FORMS_HCAPTCHA_SECRET)
    return None
