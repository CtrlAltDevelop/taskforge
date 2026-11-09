"""Simultaneous refreshes of one token, as two tabs or two requests would send.

Only PostgreSQL has the row locks the rotation relies on (SQLite ignores
``select_for_update`` and fails with "database is locked"), so this runs there:
``make test-postgres``.
"""

from concurrent.futures import ThreadPoolExecutor
from threading import Barrier
from typing import Any

import pytest
from django.db import connection, connections
from django.test import Client, override_settings

from infrastructure.oauth.rotation.tests.test_api import _login, _refresh

CALLERS = 6

pytestmark = pytest.mark.skipif(
    connection.vendor != "postgresql", reason="needs PostgreSQL row locks"
)


def _refresh_in_thread(refresh_token: str, barrier: Barrier) -> Any:
    barrier.wait()
    try:
        return _refresh(Client(), refresh_token)
    finally:
        connections.close_all()


@pytest.mark.django_db(transaction=True)
@override_settings(AUTH_REFRESH_REUSE_GRACE_SECONDS=10)
def test_exactly_one_of_many_simultaneous_refreshes_wins_and_the_rest_may_retry() -> None:
    client = Client()
    original = _login(client)
    barrier = Barrier(CALLERS)

    with ThreadPoolExecutor(max_workers=CALLERS) as pool:
        futures = [
            pool.submit(_refresh_in_thread, original["refresh_token"], barrier)
            for _ in range(CALLERS)
        ]
        responses = [future.result() for future in futures]

    statuses = sorted(response.status_code for response in responses)
    assert statuses == [200] + [409] * (CALLERS - 1), statuses
    winner = next(r for r in responses if r.status_code == 200).json()["data"]
    # Nobody was treated as a thief: the winner's token still refreshes.
    assert _refresh(client, winner["refresh_token"]).status_code == 200
