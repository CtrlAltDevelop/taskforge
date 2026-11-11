import socket
from typing import Any

import pytest

from infrastructure.automations import safe_http
from infrastructure.automations.safe_http import UnsafeUrl


def answer_with(monkeypatch: pytest.MonkeyPatch, *addresses: str) -> None:
    def fake(host: str, port: Any, **_: Any) -> list[Any]:
        family = socket.AF_INET6 if ":" in addresses[0] else socket.AF_INET
        return [(family, socket.SOCK_STREAM, 6, "", (a, port)) for a in addresses]

    monkeypatch.setattr(safe_http.socket, "getaddrinfo", fake)


@pytest.mark.parametrize(
    "url",
    [
        "http://127.0.0.1/x",
        "http://localhost/x",
        "http://app.localhost:8000/",
        "http://10.0.0.5/",
        "http://192.168.1.1/",
        "http://172.16.0.1/",
        "http://169.254.169.254/latest/meta-data",
        "http://100.64.0.1/",
        "http://0.0.0.0/",
        "http://[::1]/",
        "http://[::ffff:127.0.0.1]/",
        "http://[fe80::1]/",
        "ftp://example.com/",
        "file:///etc/passwd",
        "gopher://example.com/",
        "http://user:pass@example.com/",
        "http:///nohost",
        "",
    ],
)
def test_addresses_that_reach_the_servers_own_network_are_refused_when_saving(url: str) -> None:
    with pytest.raises(UnsafeUrl):
        safe_http.check_static(url)


def test_a_public_address_passes_the_static_check() -> None:
    safe_http.check_static("https://hooks.example.com/path?x=1")
    safe_http.check_static("http://93.184.216.34:8080/")


@pytest.mark.parametrize("address", ["127.0.0.1", "10.1.2.3", "169.254.169.254", "::1", "fd00::1"])
def test_a_name_that_resolves_to_a_private_address_is_refused(
    monkeypatch: pytest.MonkeyPatch, address: str
) -> None:
    answer_with(monkeypatch, address)
    with pytest.raises(UnsafeUrl, match="public address"):
        safe_http.resolve("https://rebind.example.com/")


def test_one_private_answer_among_public_ones_is_enough_to_refuse(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    answer_with(monkeypatch, "93.184.216.34", "10.0.0.1")
    with pytest.raises(UnsafeUrl):
        safe_http.resolve("https://mixed.example.com/")


def test_an_unknown_host_is_refused(monkeypatch: pytest.MonkeyPatch) -> None:
    def fail(*_: Any, **__: Any) -> None:
        raise socket.gaierror

    monkeypatch.setattr(safe_http.socket, "getaddrinfo", fail)
    with pytest.raises(UnsafeUrl, match="public address"):
        safe_http.resolve("https://nowhere.example.com/")


def test_a_call_connects_to_the_checked_address_and_reports_the_answer(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    answer_with(monkeypatch, "93.184.216.34")
    seen: list[safe_http.Target] = []

    def fake_send(target: safe_http.Target, method: str, body: bytes) -> safe_http.Answer:
        seen.append(target)
        return safe_http.Answer(302, 0, False)  # a redirect is an answer; it is never followed

    monkeypatch.setattr(safe_http, "_send", fake_send)

    got = safe_http.call("https://hooks.example.com:8443/in?a=1", "POST", {"a": 1})

    assert got.status == 302
    assert (seen[0].ip, seen[0].host, seen[0].port, seen[0].path) == (
        "93.184.216.34",
        "hooks.example.com",
        8443,
        "/in?a=1",
    )


def test_a_huge_body_is_refused() -> None:
    with pytest.raises(UnsafeUrl, match="too large"):
        safe_http.call("http://93.184.216.34/", "POST", {"x": "a" * safe_http.MAX_BODY_BYTES})


@pytest.mark.parametrize(
    "address",
    [
        "64:ff9b::7f00:1",  # NAT64 -> 127.0.0.1
        "64:ff9b::a00:1",  # NAT64 -> 10.0.0.1
        "2002:7f00:1::1",  # 6to4 -> 127.0.0.1
        "2002:c0a8:101::1",  # 6to4 -> 192.168.1.1
    ],
)
def test_nat64_and_6to4_addresses_hiding_a_private_ipv4_are_refused(
    monkeypatch: pytest.MonkeyPatch, address: str
) -> None:
    answer_with(monkeypatch, address)
    with pytest.raises(UnsafeUrl):
        safe_http.resolve("https://sneaky.example.com/")
    with pytest.raises(UnsafeUrl):
        safe_http.check_static(f"http://[{address}]/")


def test_nat64_of_a_public_address_is_allowed(monkeypatch: pytest.MonkeyPatch) -> None:
    answer_with(monkeypatch, "64:ff9b::5db8:d822")  # 93.184.216.34
    assert safe_http.resolve("https://ok.example.com/").ip == "64:ff9b::5db8:d822"


def test_unresolved_and_private_hosts_give_the_same_message(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    def fail(*_: Any, **__: Any) -> None:
        raise socket.gaierror

    monkeypatch.setattr(safe_http.socket, "getaddrinfo", fail)
    with pytest.raises(UnsafeUrl) as missing:
        safe_http.resolve("https://nowhere.example.com/")
    answer_with(monkeypatch, "10.0.0.1")
    with pytest.raises(UnsafeUrl) as private:
        safe_http.resolve("https://internal.example.com/")
    assert str(missing.value) == str(private.value)


def test_a_dns_lookup_that_hangs_is_cut_off(monkeypatch: pytest.MonkeyPatch) -> None:
    import threading

    release = threading.Event()

    def slow(*_: Any, **__: Any) -> list[Any]:
        release.wait(5)
        return []

    monkeypatch.setattr(safe_http.socket, "getaddrinfo", slow)
    monkeypatch.setattr(safe_http, "DNS_TIMEOUT_SECONDS", 0.05)
    try:
        with pytest.raises(UnsafeUrl):
            safe_http.resolve("https://slow.example.com/")
    finally:
        release.set()


class _Trickle:
    """A response that hands out one byte per read, forever, and a clock that moves per read."""

    def __init__(self, clock: list[float]) -> None:
        self.clock = clock
        self.status = 200

    def read(self, _n: int) -> bytes:
        self.clock[0] += 3.0
        return b"x"


def test_a_slow_trickling_answer_is_aborted_at_the_overall_deadline(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    clock = [1000.0]
    monkeypatch.setattr(safe_http.time, "monotonic", lambda: clock[0])
    connection = type("C", (), {"sock": None})()
    with pytest.raises(TimeoutError):
        safe_http._read_capped(connection, _Trickle(clock), clock[0] + safe_http.DEADLINE_SECONDS)  # type: ignore[arg-type]


def test_a_normal_answer_is_read_in_full_and_capped() -> None:
    class Body:
        def __init__(self, size: int) -> None:
            self.left = size

        def read(self, n: int) -> bytes:
            got = min(n, self.left)
            self.left -= got
            return b"x" * got

    connection = type("C", (), {"sock": None})()
    deadline = safe_http.time.monotonic() + 5
    assert safe_http._read_capped(connection, Body(100), deadline) == 100  # type: ignore[arg-type]
    huge = safe_http._read_capped(connection, Body(10**7), deadline)  # type: ignore[arg-type]
    assert huge == safe_http.MAX_RESPONSE_BYTES + 1
