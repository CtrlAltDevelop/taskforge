from typing import Any

import pytest
from django.contrib.auth import get_user_model


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
