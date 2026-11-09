"""Two accounts racing for the last use of a link.

Only PostgreSQL has the row lock ``accept`` relies on, so this runs there:
``make test-postgres``.
"""

from concurrent.futures import ThreadPoolExecutor
from threading import Barrier
from typing import Any

import pytest
from django.contrib.auth import get_user_model
from django.db import connection, connections

from infrastructure.common.errors import ApiError
from infrastructure.workspaces import invitations, services
from infrastructure.workspaces.models import Invitation, MemberStatus, WorkspaceMember

pytestmark = [
    pytest.mark.skipif(connection.vendor != "postgresql", reason="needs PostgreSQL row locks"),
    pytest.mark.django_db(transaction=True),
]


def _accept(token: str, user: Any, barrier: Barrier) -> Any:
    barrier.wait()
    try:
        return invitations.accept(token, user)
    except ApiError as refusal:
        return refusal
    finally:
        connections.close_all()


def test_single_use_link_admits_exactly_one_of_two_simultaneous_accepts() -> None:
    users = get_user_model().objects
    owner = users.create_user(username="zoe", email="zoe@example.com", password="x-y-z-12345")
    rivals = [
        users.create_user(username=n, email=f"{n}@example.com", password="x-y-z-12345")
        for n in ("max", "ann")
    ]
    workspace = services.create(owner, "Acme", "acme")
    link = invitations.create_link(workspace, owner, max_uses=1)
    barrier = Barrier(2)

    with ThreadPoolExecutor(max_workers=2) as pool:
        futures = [pool.submit(_accept, link.token, u, barrier) for u in rivals]
        results = [f.result() for f in futures]

    assert sum(isinstance(r, WorkspaceMember) for r in results) == 1, results
    assert sum(isinstance(r, ApiError) and r.status == 410 for r in results) == 1, results
    assert Invitation.objects.get(pk=link.invitation.pk).uses == 1
    active = WorkspaceMember.objects.filter(workspace=workspace, status=MemberStatus.ACTIVE)
    assert active.count() == 2  # owner + the winner
