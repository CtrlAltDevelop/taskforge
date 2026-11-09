"""The workflow every project starts with. Works on live models and on migration state."""

from typing import Any, Final

# (legacy phase-06 status value, name, colour, category, is_default)
DEFAULT_STATUSES: Final = (
    ("todo", "To do", "#9E9E9E", "not_started", True),
    ("in_progress", "In progress", "#1E88E5", "active", False),
    ("done", "Done", "#43A047", "done", False),
)


def create_default_statuses(status_model: Any, project_id: Any) -> dict[str, Any]:
    """Create the three default statuses of ``project_id``.

    Returns them by their legacy phase-06 value (``todo`` / ``in_progress`` / ``done``), which
    the data migration of ``Task.status`` uses.
    """
    created: dict[str, Any] = {}
    for position, (legacy, name, color, category, is_default) in enumerate(DEFAULT_STATUSES):
        created[legacy] = status_model.objects.create(
            project_id=project_id,
            name=name,
            color=color,
            category=category,
            position=position,
            is_default=is_default,
        )
    return created
