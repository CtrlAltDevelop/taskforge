"""Every write endpoint of the earlier phases leaves an audit entry.

Reuses the permission matrix: its ``ENDPOINTS`` already call every workspace-scoped RPC and route
against a seeded world, so a new write that forgets to record fails here. A read must be named in
``READS``; personal state (keys, inbox, watching, search history, favourites) is ``PERSONAL``.
"""

from typing import Any

import pytest

from infrastructure.audit.models import AuditEntry
from infrastructure.workspaces.tests.conftest import make_user  # noqa: F401
from infrastructure.workspaces.tests.test_rbac_matrix import (  # noqa: F401
    ENDPOINTS,
    Endpoint,
    _world,
    people,
)

# An endpoint that only reads. Anything not named here is a write and must leave an entry, so a
# new RPC fails until it either records or is added here on purpose.
READS = frozenset(
    {
        "ActivityController.ForTask",
        "AttachmentController.List",
        "AttachmentController.Usage",
        "AuditController.Export",
        "AuditController.List",
        "AutomationController.DryRun",
        "RecurrenceController.Get",
        "RecurrenceController.Preview",
        "RecurrenceController.Upcoming",
        "AutomationController.List",
        "AutomationRunController.Get",
        "WidgetController.Export",
        "WidgetController.Drilldown",
        "WidgetController.Preview",
        "WidgetController.Data",
        "DashboardController.Get",
        "DashboardController.List",
        "AutomationRunController.List",
        "BacklogController.List",
        "BoardController.Get",
        "BoardController.ListColumn",
        "CalendarController.ListRange",
        "CalendarController.ListUnscheduled",
        "CalendarController.ListWorkspaceRange",
        "CommentController.History",
        "CommentController.List",
        "CommentController.Mentionable",
        "DocController.Backlinks",
        "DocController.ExportMarkdown",
        "DocController.ForTask",
        "DocController.Get",
        "DocController.Presence",
        "DocController.RevisionGet",
        "DocController.RevisionList",
        "DocController.TaskCards",
        "DocController.Tree",
        "FieldController.List",
        "FilterController.List",
        "GET /files/{attachment_id}",
        "GET /files/{attachment_id}/link",
        "InboxController.Archive",
        "InboxController.List",
        "InboxController.MarkRead",
        "InboxController.UnreadCount",
        "InvitationController.List",
        "LinkController.ListForTask",
        "LinkController.SearchTasks",
        "MemberController.List",
        "ProjectController.Favorite",
        "ProjectController.Get",
        "ProjectController.List",
        "ProjectController.ListMembers",
        "ProjectController.ListPrivate",
        "QueryController.Suggest",
        "QueryController.Validate",
        "RoleController.List",
        "SearchController.Query",
        "SearchController.Recent",
        "SearchController.Remember",
        "SprintController.Burndown",
        "SprintController.List",
        "SprintController.Tasks",
        "SyncController.Head",
        "SyncController.Since",
        "TaskController.Get",
        "TaskController.GroupCounts",
        "TaskController.List",
        "TaskController.ListChildren",
        "TaskController.ListTrash",
        "TimeController.Current",
        "TimeController.Entries",
        "TimeController.Summary",
        "TimeController.Timesheet",
        "TimeController.Totals",
        "TimelineController.CriticalPath",
        "TimelineController.Get",
        "TimelineController.GetWorkingDays",
        "TimelineController.PreviewShift",
        "ViewController.List",
        "WatcherController.Add",
        "WatcherController.Get",
        "WatcherController.Remove",
        "WorkflowController.Get",
        "WorkflowController.Validate",
        "WorkspaceController.ListDeleted",
    }
)


def _is_read(name: str) -> bool:
    return name in READS


# The matrix calls these with a request that changes nothing (same parent, same status, one field
# to reorder ...), or that opens an upload (the file is recorded when it completes). Each is
# proven to record a real change in ``test_real_changes.py``.
MATRIX_CALL_CHANGES_NOTHING = frozenset(
    {
        "TaskController.SetParent",
        "TaskController.Move",
        "FieldController.Update",
        "FieldController.Reorder",
        "DocController.Move",
        "DocController.UnlinkTask",
        "POST /uploads",
    }
)
WRITES = [
    e for e in ENDPOINTS if not _is_read(e.name) and e.name not in MATRIX_CALL_CHANGES_NOTHING
]


def test_the_write_list_is_not_empty_and_has_no_obvious_reads() -> None:
    assert len(WRITES) > 60
    assert {e.name for e in ENDPOINTS} >= READS, "a name in READS no longer exists"


@pytest.mark.parametrize("endpoint", WRITES, ids=lambda e: e.name)
def test_a_write_leaves_an_entry(
    endpoint: Endpoint,
    people: dict[str, Any],  # noqa: F811 - the fixture, imported above
    grpc_call: Any,
) -> None:
    world = _world(people, 0)
    if endpoint.prepare:
        endpoint.prepare(world)
    before = AuditEntry.objects.filter(workspace=world.ws).count()
    endpoint.call(world, "Owner", grpc_call)
    new = AuditEntry.objects.filter(workspace=world.ws).order_by("pk")[before:]
    assert new, endpoint.name
    assert all(
        e.action and "." in e.action and (e.actor or e.actor_type == "system") for e in new
    ), [(e.action, e.actor) for e in new]


def test_a_rest_write_is_attributed_to_the_person(
    people: dict[str, Any],  # noqa: F811 - the fixture, imported above
    grpc_call: Any,
) -> None:
    logo = next(e for e in ENDPOINTS if e.name == "POST /workspaces/{workspace_id}/logo")
    world = _world(people, 0)
    logo.call(world, "Owner", grpc_call)
    entry = AuditEntry.objects.filter(workspace=world.ws, action="workspace.updated").latest("pk")
    assert entry.actor == str(people["users"]["Owner"].pk)
    assert entry.actor_type == "user"
