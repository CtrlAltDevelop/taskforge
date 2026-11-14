from typing import Any

import pytest

from infrastructure.tasks.tests import conftest as task_fixtures

# The tasks fixtures (a workspace with a user per role and a project), registered by name.
make_user = task_fixtures.make_user
add_member = task_fixtures.add_member
_commit_hooks_run_now = task_fixtures._commit_hooks_run_now
team = task_fixtures.team
project = task_fixtures.project


@pytest.fixture(autouse=True)
def _fresh_cache() -> Any:
    from django.core.cache import cache

    cache.clear()
    yield
    cache.clear()
