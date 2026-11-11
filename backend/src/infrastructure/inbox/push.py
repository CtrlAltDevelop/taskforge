"""Sending a push to one device. ``LoggingPush`` (the default) only logs; ``FcmPush`` talks to
Firebase Cloud Messaging (HTTP v1) with a service account. Choose with ``INBOX_PUSH_PROVIDER``
(a dotted path); a provider has ``send(device, title, body, data)`` and raises ``DeadToken`` for a
token the service no longer knows (the device is then forgotten)."""

import json
import logging
import threading
import time
from typing import Any

from django.conf import settings

logger = logging.getLogger(__name__)

FCM_SCOPE = "https://www.googleapis.com/auth/firebase.messaging"
TOKEN_URL = "https://oauth2.googleapis.com/token"  # noqa: S105 -- an address, not a secret
SEND_URL = "https://fcm.googleapis.com/v1/projects/{project}/messages:send"
TIMEOUT_SECONDS = 10


class DeadToken(Exception):
    """The push service says this token is no longer valid."""


class LoggingPush:
    def send(self, device: Any, title: str, body: str, data: dict[str, str]) -> None:
        logger.info("push to %s device %s: %s", device.platform, device.pk, title)


class FcmPush:
    """FCM HTTP v1. Settings: ``INBOX_FCM_PROJECT_ID`` and ``INBOX_FCM_CREDENTIALS_FILE`` (a
    service-account JSON). ``client`` (an ``httpx.Client``) can be given for tests."""

    def __init__(self, client: Any = None) -> None:
        import httpx

        self._client = client or httpx.Client(timeout=TIMEOUT_SECONDS)
        self._token = ""
        self._expires = 0.0
        self._account: dict[str, Any] | None = None
        self._lock = threading.Lock()

    def _credentials(self) -> dict[str, Any]:
        if self._account is None:
            if not settings.INBOX_FCM_CREDENTIALS_FILE or not settings.INBOX_FCM_PROJECT_ID:
                raise RuntimeError("FCM needs INBOX_FCM_PROJECT_ID and INBOX_FCM_CREDENTIALS_FILE")
            with open(settings.INBOX_FCM_CREDENTIALS_FILE, encoding="utf-8") as handle:
                self._account = json.load(handle)
        return self._account

    def _access_token(self) -> str:
        with self._lock:
            return self._refresh()

    def _refresh(self) -> str:
        if self._token and time.time() < self._expires - 60:
            return self._token
        import jwt

        account = self._credentials()
        now = int(time.time())
        assertion = jwt.encode(
            {
                "iss": account["client_email"],
                "scope": FCM_SCOPE,
                "aud": TOKEN_URL,
                "iat": now,
                "exp": now + 3600,
            },
            account["private_key"],
            algorithm="RS256",
        )
        reply = self._client.post(
            TOKEN_URL,
            data={
                "grant_type": "urn:ietf:params:oauth:grant-type:jwt-bearer",
                "assertion": assertion,
            },
        )
        reply.raise_for_status()
        self._token = reply.json()["access_token"]
        self._expires = time.time() + float(reply.json().get("expires_in", 3600))
        return self._token

    def send(self, device: Any, title: str, body: str, data: dict[str, str]) -> None:
        reply = self._client.post(
            SEND_URL.format(project=settings.INBOX_FCM_PROJECT_ID),
            headers={"Authorization": f"Bearer {self._access_token()}"},
            json={
                "message": {
                    "token": device.token,
                    "notification": {"title": title, "body": body},
                    "data": data,
                }
            },
        )
        if reply.status_code in (404, 410) or (
            reply.status_code == 400 and "UNREGISTERED" in reply.text
        ):
            raise DeadToken  # never carries the token: it must not reach a log
        reply.raise_for_status()
