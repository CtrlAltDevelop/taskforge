from typing import Any

import pytest
from django.contrib.auth import get_user_model
from django.db import transaction


@pytest.fixture
def make_user(db: None) -> Any:
    def make(username: str) -> Any:
        return get_user_model().objects.create_user(
            username=username, email=f"{username}@example.com", password="corr3ct-horse-battery"
        )

    return make


@pytest.fixture
def alice(make_user: Any) -> Any:
    return make_user("alice")


@pytest.fixture
def bob(make_user: Any) -> Any:
    return make_user("bob")


@pytest.fixture(autouse=True)
def _commit_hooks_run_now(monkeypatch: pytest.MonkeyPatch) -> None:
    """The ``db`` fixture never commits, so run on_commit hooks at once; the commit-semantics
    tests (test_invite_mail.py) override this to get Django's real behaviour."""
    monkeypatch.setattr(transaction, "on_commit", lambda func, *a, **k: func())


@pytest.fixture
def add_member(db: None) -> Any:
    """``add_member(workspace, user, "Viewer")``: an active member with a built-in role."""
    from infrastructure.workspaces import access
    from infrastructure.workspaces.models import WorkspaceMember

    def add(workspace: Any, user: Any, role_name: str = "Member") -> Any:
        return WorkspaceMember.objects.create(
            workspace=workspace, user=user, role=access.builtin_role(role_name)
        )

    return add
