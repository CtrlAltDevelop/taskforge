"""Calling a webhook without letting a rule reach the server's own network (SSRF).

Only ``http`` / ``https`` to a host whose every address is public. The address is checked *after*
the name is resolved and the connection is then made to that very address (so the name cannot
change its answer in between), redirects are never followed, the call has a short timeout and the
answer is read only up to a cap. There is no switch to relax it.
"""

import http.client
import ipaddress
import json
import socket
import ssl
import threading
import time
from dataclasses import dataclass
from typing import Any, Final
from urllib.parse import urlsplit

TIMEOUT_SECONDS: Final = 5
DEADLINE_SECONDS: Final = 10.0  # connect + send + the whole answer
DNS_TIMEOUT_SECONDS: Final = 3.0
READ_CHUNK: Final = 8 * 1024
MAX_RESPONSE_BYTES: Final = 64 * 1024
MAX_BODY_BYTES: Final = 64 * 1024
MAX_URL_LENGTH: Final = 2000
SCHEMES: Final = ("http", "https")


# One text for "does not resolve" and "resolves to a private address", so the dry run cannot be
# used to probe which internal names exist.
REFUSED: Final = "The webhook host cannot be called: it must resolve to a public address."


class UnsafeUrl(ValueError):
    """The address may not be called; the message says why, in words for the rule's owner."""


@dataclass(frozen=True, slots=True)
class Target:
    scheme: str
    host: str
    port: int
    path: str
    ip: str


def _split(url: str) -> tuple[str, str, int, str]:
    if not url or len(url) > MAX_URL_LENGTH:
        raise UnsafeUrl(f"A webhook address is 1 to {MAX_URL_LENGTH} characters.")
    parts = urlsplit(url.strip())
    if parts.scheme not in SCHEMES:
        raise UnsafeUrl("A webhook address must start with http:// or https://.")
    if parts.username or parts.password:
        raise UnsafeUrl("A webhook address cannot hold a user name or password.")
    host = parts.hostname
    try:
        port = parts.port or (443 if parts.scheme == "https" else 80)
    except ValueError:
        raise UnsafeUrl("The webhook address has a bad port.") from None
    if not host:
        raise UnsafeUrl("The webhook address has no host.")
    path = (parts.path or "/") + (f"?{parts.query}" if parts.query else "")
    return parts.scheme, host, port, path


def _refuse_address(raw: str) -> None:
    try:
        ip = ipaddress.ip_address(raw.split("%", 1)[0])
    except ValueError:
        raise UnsafeUrl(REFUSED) from None
    for candidate in _embedded(ip):
        if not candidate.is_global or candidate.is_multicast:
            raise UnsafeUrl(REFUSED)


_NAT64 = ipaddress.ip_network("64:ff9b::/96")
_SIX_TO_FOUR = ipaddress.ip_network("2002::/16")


def _embedded(ip: ipaddress.IPv4Address | ipaddress.IPv6Address) -> list[Any]:
    """The address itself plus any IPv4 address it carries (mapped, NAT64, 6to4)."""
    found: list[Any] = [ip]
    if isinstance(ip, ipaddress.IPv6Address):
        if ip.ipv4_mapped is not None:
            found.append(ip.ipv4_mapped)
        if ip in _NAT64:
            found.append(ipaddress.IPv4Address(int(ip) & 0xFFFFFFFF))
        if ip in _SIX_TO_FOUR:
            found.append(ipaddress.IPv4Address((int(ip) >> 80) & 0xFFFFFFFF))
    return found


def check_static(url: str) -> None:
    """What can be said without the network: the scheme, and a host that is a literal private
    address or ``localhost``. Used when a rule is saved."""
    _, host, _, _ = _split(url)
    if host.lower().rstrip(".") == "localhost" or host.lower().endswith(".localhost"):
        raise UnsafeUrl("A webhook cannot call a private, loopback or link-local address.")
    try:
        ipaddress.ip_address(host)
    except ValueError:
        return
    _refuse_address(host)


def describe(url: str) -> tuple[str, str, str]:
    """``(scheme, host, path)`` of a valid address, without touching the network."""
    check_static(url)
    scheme, host, _, path = _split(url)
    return scheme, host, path


def _lookup(host: str, port: int) -> list[Any]:
    """``getaddrinfo`` bounded by ``DNS_TIMEOUT_SECONDS`` (it has no timeout of its own)."""
    box: list[Any] = []

    def work() -> None:
        try:
            box.append(socket.getaddrinfo(host, port, type=socket.SOCK_STREAM))
        except (OSError, UnicodeError):
            box.append(None)

    thread = threading.Thread(target=work, name="automations-dns", daemon=True)
    thread.start()
    thread.join(DNS_TIMEOUT_SECONDS)
    if not box or box[0] is None:
        raise UnsafeUrl(REFUSED)
    return box[0]


def resolve(url: str) -> Target:
    """The checked target of ``url``: every address its host resolves to must be public."""
    scheme, host, port, path = _split(url)
    addresses = [str(item[4][0]) for item in _lookup(host, port)]
    if not addresses:
        raise UnsafeUrl(REFUSED)
    for address in addresses:
        _refuse_address(address)
    return Target(scheme, host, port, path, addresses[0])


def _remaining(deadline: float) -> float:
    left = deadline - time.monotonic()
    if left <= 0:
        raise TimeoutError("The webhook took too long.")
    return min(left, TIMEOUT_SECONDS)


class _Pinned(http.client.HTTPConnection):
    def __init__(self, target: Target, deadline: float) -> None:
        super().__init__(target.host, target.port, timeout=TIMEOUT_SECONDS)
        self._ip = target.ip
        self.deadline = deadline

    def connect(self) -> None:
        self.sock = socket.create_connection((self._ip, self.port), _remaining(self.deadline))


class _PinnedTls(http.client.HTTPSConnection):
    def __init__(self, target: Target, deadline: float) -> None:
        super().__init__(
            target.host, target.port, timeout=TIMEOUT_SECONDS, context=ssl.create_default_context()
        )
        self._ip = target.ip
        self.deadline = deadline

    def connect(self) -> None:
        raw = socket.create_connection((self._ip, self.port), _remaining(self.deadline))
        self.sock = self._context.wrap_socket(raw, server_hostname=self.host)  # type: ignore[attr-defined]


@dataclass(frozen=True, slots=True)
class Answer:
    status: int
    size: int
    truncated: bool


def _read_capped(connection: Any, response: http.client.HTTPResponse, deadline: float) -> int:
    """Read up to the cap + 1 bytes in chunks, giving up when the overall deadline passes."""
    total = 0
    while total <= MAX_RESPONSE_BYTES:
        left = _remaining(deadline)
        if connection.sock is not None:
            connection.sock.settimeout(left)
        chunk = response.read(min(READ_CHUNK, MAX_RESPONSE_BYTES + 1 - total))
        if not chunk:
            break
        total += len(chunk)
    return total


def _send(target: Target, method: str, body: bytes) -> Answer:
    deadline = time.monotonic() + DEADLINE_SECONDS
    connection = (
        _PinnedTls(target, deadline) if target.scheme == "https" else _Pinned(target, deadline)
    )
    try:
        connection.request(
            method,
            target.path,
            body=body,
            headers={"Content-Type": "application/json", "User-Agent": "TaskForge-Automation"},
        )
        if connection.sock is not None:
            connection.sock.settimeout(_remaining(deadline))
        response = connection.getresponse()
        size = _read_capped(connection, response, deadline)  # a 3xx is an answer, never followed
        return Answer(response.status, min(size, MAX_RESPONSE_BYTES), size > MAX_RESPONSE_BYTES)
    finally:
        connection.close()


def call(url: str, method: str, payload: dict[str, Any]) -> Answer:
    """Send ``payload`` as JSON. ``UnsafeUrl`` for an address that may not be called, ``OSError``
    for a network failure or a timeout."""
    body = json.dumps(payload, default=str).encode()
    if len(body) > MAX_BODY_BYTES:
        raise UnsafeUrl("The webhook body is too large.")
    return _send(resolve(url), method, body)
