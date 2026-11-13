"""Calling a webhook without letting it reach the server's own network (SSRF).

Built on the pieces of ``automations.safe_http`` (which has no switch to relax it) with what
webhooks add: the answer's first bytes are kept for the delivery log, and a self-hoster may list
internal hosts or networks in ``DEVELOPER_WEBHOOK_ALLOWLIST``.

* only ``http`` / ``https``, no user name or password in the address;
* the host is resolved and *every* address must be public (or on the allowlist), including the
  IPv4 address an IPv6 one carries;
* the connection is made to the address that was checked, and that address is checked again at
  the moment of connecting, so a name that answers differently a second time (DNS rebinding) gets
  nowhere;
* redirects are never followed (a 3xx is an answer, and a failed delivery);
* 10 seconds for the whole call, and the answer is read only up to a cap.
"""

import http.client
import ipaddress
import socket
import ssl
import time
from dataclasses import dataclass
from typing import Any, Final

from django.conf import settings

from infrastructure.automations import safe_http
from infrastructure.automations.safe_http import REFUSED, UnsafeUrl

__all__ = ["REFUSED", "Response", "UnsafeUrl", "check_url", "post"]

DEADLINE_SECONDS: Final = 10.0
SOCKET_TIMEOUT_SECONDS: Final = 5.0
MAX_READ_BYTES: Final = 64 * 1024
SNIPPET_BYTES: Final = 2000
MAX_BODY_BYTES: Final = 256 * 1024
PRIVATE_ADDRESS: Final = "A webhook cannot call a private, loopback or link-local address."


@dataclass(frozen=True, slots=True)
class Response:
    status: int
    snippet: str
    duration_ms: int


def _entries() -> list[str]:
    return [str(e).strip().lower() for e in settings.DEVELOPER_WEBHOOK_ALLOWLIST if str(e).strip()]


def _allowlisted(host: str, address: str) -> bool:
    """Whether the self-hoster allowed this host name, or a network holding this address."""
    ip = ipaddress.ip_address(address.split("%", 1)[0])
    for entry in _entries():
        if entry == host.lower().rstrip("."):
            return True
        try:
            if ip in ipaddress.ip_network(entry, strict=False):
                return True
        except ValueError:
            continue
    return False


def _public(address: str) -> bool:
    try:
        ip = ipaddress.ip_address(address.split("%", 1)[0])
    except ValueError:
        return False
    return all(c.is_global and not c.is_multicast for c in safe_http._embedded(ip))


def _vet(host: str, address: str) -> None:
    if not _public(address) and not _allowlisted(host, address):
        raise UnsafeUrl(REFUSED)


def check_url(url: str) -> None:
    """What can be said about an address without the network, for when a webhook is saved."""
    _, host, _, _ = safe_http._split(url)
    bare = host.strip("[]")
    lowered = bare.lower().rstrip(".")
    try:
        ipaddress.ip_address(bare)
    except ValueError:
        if (lowered == "localhost" or lowered.endswith(".localhost")) and lowered not in _entries():
            raise UnsafeUrl(PRIVATE_ADDRESS) from None
        return
    try:
        _vet(bare, bare)
    except UnsafeUrl:
        raise UnsafeUrl(PRIVATE_ADDRESS) from None


def _resolve(url: str) -> safe_http.Target:
    scheme, host, port, path = safe_http._split(url)
    addresses = [str(item[4][0]) for item in safe_http._lookup(host, port)]
    if not addresses:
        raise UnsafeUrl(REFUSED)
    for address in addresses:
        _vet(host, address)
    return safe_http.Target(scheme, host, port, path, addresses[0])


def _left(deadline: float) -> float:
    left = deadline - time.monotonic()
    if left <= 0:
        raise TimeoutError("The webhook took too long.")
    return min(left, SOCKET_TIMEOUT_SECONDS)


class _Pinned(http.client.HTTPConnection):
    def __init__(self, target: safe_http.Target, deadline: float) -> None:
        super().__init__(target.host, target.port, timeout=SOCKET_TIMEOUT_SECONDS)
        self._target, self._deadline = target, deadline

    def connect(self) -> None:
        _vet(self._target.host, self._target.ip)  # again, at the moment of connecting
        self.sock = socket.create_connection((self._target.ip, self.port), _left(self._deadline))


class _PinnedTls(http.client.HTTPSConnection):
    def __init__(self, target: safe_http.Target, deadline: float) -> None:
        super().__init__(
            target.host,
            target.port,
            timeout=SOCKET_TIMEOUT_SECONDS,
            context=ssl.create_default_context(),
        )
        self._target, self._deadline = target, deadline

    def connect(self) -> None:
        _vet(self._target.host, self._target.ip)
        raw = socket.create_connection((self._target.ip, self.port), _left(self._deadline))
        self.sock = self._context.wrap_socket(raw, server_hostname=self.host)  # type: ignore[attr-defined]


def _read(connection: Any, response: http.client.HTTPResponse, deadline: float) -> bytes:
    kept = bytearray()
    total = 0
    while total <= MAX_READ_BYTES:
        if connection.sock is not None:
            connection.sock.settimeout(_left(deadline))
        chunk = response.read(min(8192, MAX_READ_BYTES + 1 - total))
        if not chunk:
            break
        total += len(chunk)
        if len(kept) < SNIPPET_BYTES:
            kept.extend(chunk[: SNIPPET_BYTES - len(kept)])
    return bytes(kept)


def post(url: str, body: bytes, headers: dict[str, str]) -> Response:
    """POST ``body``. ``UnsafeUrl`` for an address that may not be called; ``OSError`` /
    ``TimeoutError`` / ``http.client.HTTPException`` for a network failure."""
    if len(body) > MAX_BODY_BYTES:
        raise UnsafeUrl("The webhook body is too large.")
    started = time.monotonic()
    target = _resolve(url)
    deadline = started + DEADLINE_SECONDS
    connection: Any = (
        _PinnedTls(target, deadline) if target.scheme == "https" else _Pinned(target, deadline)
    )
    try:
        connection.request("POST", target.path, body=body, headers=headers)
        if connection.sock is not None:
            connection.sock.settimeout(_left(deadline))
        response = connection.getresponse()
        snippet = _read(connection, response, deadline)  # a 3xx is an answer, never followed
        return Response(
            response.status,
            snippet.decode("utf-8", "replace"),
            int((time.monotonic() - started) * 1000),
        )
    finally:
        connection.close()
