"""Recording a committed change and telling the sockets about it.

Called after the change committed (the existing ``*_changed`` signals are sent through
``transaction.on_commit``), so a rollback records and sends nothing. The row comes first: its id
is the cursor a client that missed the event catches up from, and the event carries it.

Rooms: ``proj:<id>`` for everything about a project, ``ws:<id>`` as well when the project is open
to every member of the workspace (a private project's events never go there), ``user:<id>`` for a
person's own, and ``ws:<id>`` for workspace-level changes. Events are hints (ids and a version),
so even a wrong room could leak no content; the socket still checks who may join each room.
"""

import logging
from typing import Any, Final
from uuid import UUID

from apps.notifications.broadcast import channel_prefix, get_broker
from infrastructure.projects.models import Project, Visibility
from infrastructure.sync.actor import current_actor, current_origin, origin_tag
from infrastructure.sync.models import ChangeLog

RETENTION_DAYS: Final = 14
log = logging.getLogger(__name__)


def workspace_room(workspace_id: Any) -> str:
    return f"ws:{workspace_id}"


def project_room(project_id: Any) -> str:
    return f"proj:{project_id}"


def user_room(user_id: Any) -> str:
    return f"user:{user_id}"


def channel_of(room: str) -> str:
    """The broker channel a room is carried on."""
    return f"{channel_prefix()}:sync:{room}"


def _rooms(row: ChangeLog, user_id: str = "") -> list[str]:
    if user_id:
        return [user_room(user_id)]
    if row.project is None:
        return [workspace_room(row.workspace_id)]
    rooms = [project_room(row.project)]
    visibility = Project.objects.filter(pk=row.project).values_list("visibility", flat=True).first()
    if visibility == Visibility.OPEN:
        rooms.append(workspace_room(row.workspace_id))
    return rooms


def record(
    *,
    entity_type: str,
    entity_id: Any,
    workspace_id: Any,
    project_id: Any = None,
    version: int = 0,
    action: str = "updated",
    user_id: str = "",
) -> ChangeLog:
    """Append the row and publish its event. ``user_id`` aims an event at one person's room (an
    access change); without it the event goes to the project's or the workspace's rooms."""
    row = ChangeLog.objects.create(
        workspace_id=workspace_id,
        project=UUID(str(project_id)) if project_id else None,
        entity_type=entity_type,
        entity_id=UUID(str(entity_id)),
        version=version,
        action=action,
        actor=current_actor(),
    )
    event = {**row.as_event(), "origin": origin_tag(row.actor, current_origin())}
    try:
        broker = get_broker()
        for room in _rooms(row, user_id):
            broker.publish(channel_of(room), {"room": room, "event": event})
    except Exception:
        # The change is committed and logged: a client that missed the event catches up from the
        # log, so a broker that is away must not fail the request or the hooks after this one.
        log.exception("Could not publish %s", event["type"])
    return row
