"""A demotion queued behind the workspace lock must be honoured by the next actor.

Only PostgreSQL has the row lock, so this runs there: ``make test-postgres``.
"""

from concurrent.futures import ThreadPoolExecutor
from threading import Event
from typing import Any

import pytest
from django.contrib.auth import get_user_model
from django.db import connection, connections, transaction

from infrastructure.workspaces import access, members, roles, services
from infrastructure.workspaces.models import MemberStatus, WorkspaceMember

pytestmark = [
    pytest.mark.skipif(connection.vendor != "postgresql", reason="needs PostgreSQL row locks"),
    pytest.mark.django_db(transaction=True),
]

HOLD_SECONDS = 1.0


def _users(*names: str) -> list[Any]:
    users = get_user_model().objects
    return [
        users.create_user(username=n, email=f"{n}@example.com", password="x-y-z-12345")
        for n in names
    ]


def _demote_and_hold(workspace: Any, owner: Any, admin: Any, locked: Event) -> None:
    """Demote ``admin`` and keep the transaction (and so the workspace lock) open a while."""
    try:
        with transaction.atomic():
            members.set_role(workspace, owner, str(admin.pk), str(access.builtin_role("Viewer").pk))
            locked.set()
            Event().wait(HOLD_SECONDS)
    finally:
        connections.close_all()


def _remove_as(workspace: Any, actor: Any, target: Any) -> Any:
    try:
        members.remove(workspace, actor, str(target.pk))
    except Exception as refusal:  # noqa: BLE001 - returned for the assertion
        return refusal
    finally:
        connections.close_all()


def test_admin_demoted_concurrently_cannot_complete_a_removal() -> None:
    owner, admin, victim = _users("zoe", "ann", "max")
    workspace = services.create(owner, "Acme", "acme")
    for user, role in ((admin, "Admin"), (victim, "Member")):
        WorkspaceMember.objects.create(
            workspace=workspace, user=user, role=access.builtin_role(role)
        )
    locked = Event()

    with ThreadPoolExecutor(max_workers=2) as pool:
        demotion = pool.submit(_demote_and_hold, workspace, owner, admin, locked)
        assert locked.wait(10)
        removal = pool.submit(_remove_as, workspace, admin, victim).result()
        demotion.result()

    assert isinstance(removal, access.PermissionDenied), removal
    still = WorkspaceMember.objects.get(workspace=workspace, user=victim)
    assert still.status == MemberStatus.ACTIVE


def test_admin_demoted_concurrently_cannot_manage_roles() -> None:
    owner, admin = _users("zoe", "ann")
    workspace = services.create(owner, "Acme", "acme")
    WorkspaceMember.objects.create(
        workspace=workspace, user=admin, role=access.builtin_role("Admin")
    )
    locked = Event()

    def create_as_admin() -> Any:
        try:
            return roles.create_role(workspace, admin, "Sneaky", ["workspace.view"])
        except Exception as refusal:  # noqa: BLE001
            return refusal
        finally:
            connections.close_all()

    with ThreadPoolExecutor(max_workers=2) as pool:
        demotion = pool.submit(_demote_and_hold, workspace, owner, admin, locked)
        assert locked.wait(10)
        created = pool.submit(create_as_admin).result()
        demotion.result()

    assert isinstance(created, access.PermissionDenied), created
