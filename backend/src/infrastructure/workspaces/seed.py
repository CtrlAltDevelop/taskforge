"""Create the built-in roles and their grants. Works on live models and on migration state.

What the built-ins hold is defined by the *migrations*, never by the live registry:
migration 0001 freezes the grants (``INITIAL_GRANTS``) and every later
migration that adds a permission key declares ``ADDED_GRANTS`` and calls
``grant_to_builtins``. ``migrated_grants()`` replays those declarations; a test
compares the result with ``registry.BUILTIN_GRANTS`` so a key added without a
migration fails instead of being silently re-seeded.
"""

import pkgutil
from collections.abc import Iterable, Mapping
from importlib import import_module
from typing import Any

SEED_MIGRATION = "infrastructure.workspaces.migrations.0001_initial"
MIGRATIONS_PACKAGE = "infrastructure.workspaces.migrations"


def seed_builtin_roles(
    role_model: Any, grant_model: Any, grants: Mapping[str, Iterable[str]]
) -> None:
    """Create each missing built-in role with ``grants``; never touches an existing role."""
    for name, keys in grants.items():
        role, created = role_model.objects.get_or_create(
            workspace=None, name=name, defaults={"is_builtin": True}
        )
        if created:
            grant_model.objects.bulk_create(
                [grant_model(role=role, permission_key=k) for k in sorted(keys)]
            )


def grant_to_builtins(
    role_model: Any, grant_model: Any, key: str, role_names: Iterable[str]
) -> None:
    """For a migration that adds ``key`` to the registry: give it to ``role_names``."""
    for role in role_model.objects.filter(workspace=None, is_builtin=True, name__in=role_names):
        grant_model.objects.get_or_create(role=role, permission_key=key)


def migrated_grants() -> dict[str, frozenset[str]]:
    """Built-in role -> keys as the migrations grant them (frozen seed + every ADDED_GRANTS)."""
    grants = {
        name: set(keys) for name, keys in import_module(SEED_MIGRATION).INITIAL_GRANTS.items()
    }
    package = import_module(MIGRATIONS_PACKAGE)
    for info in sorted(pkgutil.iter_modules(package.__path__), key=lambda i: i.name):
        added: Mapping[str, Iterable[str]] = getattr(
            import_module(f"{MIGRATIONS_PACKAGE}.{info.name}"), "ADDED_GRANTS", {}
        )
        for key, role_names in added.items():
            for name in role_names:
                grants[name].add(key)
    return {name: frozenset(keys) for name, keys in grants.items()}
