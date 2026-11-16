"""Every write endpoint of the earlier phases leaves an audit entry.

Reuses the permission matrix: its ``ENDPOINTS`` already call every workspace-scoped RPC and route
against a seeded world, so a new write that forgets to record fails here. A read must be named in
``READS``; personal state (keys, inbox, watching, search history, favourites) is ``PERSONAL``.
"""

from typing import Any

import pytest

from infrastructure.audit.models import AuditEntry
from infrastructure.workspaces.registry import BUILTIN_GRANTS, BUILTIN_ROLES
from infrastructure.workspaces.tests.conftest import make_user  # noqa: F401
from infrastructure.workspaces.tests.test_rbac_matrix import (  # noqa: F401
    ACCOUNT_LEVEL_MODULES,
    ENDPOINTS,
    EXEMPT,
    Endpoint,
    _grpc_handlers,
    _rest_handlers,
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
        "ImportController.List",
        "ImportController.Get",
        "ImportController.Analyze",
        "ImportController.DryRun",
        "ImportController.Progress",
        "ImportController.ListPlaceholders",
        "ExportController.Status",
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
        "ChatController.ListSpaces",
        "ChatController.ListMessages",
        "ChatController.Mentionable",
        # Personal state (read position, mute, notify): one person's own row, not workspace data.
        "ChatController.MarkRead",
        "ChatController.Mute",
        "ChatController.Notify",
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
        "WebhookController.List",
        "ApiTokenController.List",
        "ApiTokenController.Catalog",
        "GoalController.List",
        "TemplateController.List",
        "CapacityController.Get",
        "HolidayController.List",
        "WorkloadController.Get",
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
        "ChatController.Leave",  # the matrix caller is not in the channel; chat test_audit
        "ChatController.Join",  # the Owner who made the channel is in it; chat test_audit
        "TaskController.Move",
        "FieldController.Update",
        "FieldController.Reorder",
        "DocController.Move",
        "DocController.UnlinkTask",
        "WorkflowController.Update",  # the matrix saves the workflow as it is
        "POST /uploads",
    }
)
WRITES = [
    e for e in ENDPOINTS if not _is_read(e.name) and e.name not in MATRIX_CALL_CHANGES_NOTHING
]


def test_the_write_list_is_not_empty_and_has_no_obvious_reads() -> None:
    assert len(WRITES) > 60
    assert {e.name for e in ENDPOINTS} >= READS, "a name in READS no longer exists"


def test_every_handler_is_in_the_matrix_so_it_is_checked_here(db: None) -> None:
    """A write that is in neither ``ENDPOINTS`` nor ``EXEMPT`` would escape the list above."""
    handlers = _grpc_handlers() | _rest_handlers()
    assert handlers - ({e.name for e in ENDPOINTS} | set(EXEMPT)) == set()


def _proto_rpcs() -> set[str]:
    """``Service.Rpc`` for every rpc in every .proto of the backend."""
    import re
    from pathlib import Path

    found: set[str] = set()
    for path in Path(__file__).resolve().parents[2].rglob("*.proto"):
        service = ""
        for line in path.read_text().splitlines():
            if m := re.match(r"\s*service\s+(\w+)", line):
                service = m.group(1)
            elif m := re.match(r"\s*rpc\s+(\w+)", line):
                found.add(f"{service}.{m.group(1)}")
    return found


def test_every_workspace_rpc_in_the_protos_is_classified() -> None:
    """Straight from the .proto files: an rpc nobody listed as a write, a read or an exemption
    fails here, even if its handler was never added to the matrix."""
    from config.grpc import grpc_app_services

    account_level: set[str] = set()
    for _, services_ in grpc_app_services(serving=False):
        for service in services_:
            if service.__module__ in ACCOUNT_LEVEL_MODULES:
                account_level.add(service.get_controller_name())  # type: ignore[attr-defined]
    named = {e.name for e in ENDPOINTS} | set(EXEMPT)
    rpcs = {r for r in _proto_rpcs() if r.split(".")[0] not in account_level}
    # Streams and server-internal calls of other services are not workspace writes.
    assert rpcs - named == set(), "classify these in the matrix (ENDPOINTS or EXEMPT)"


@pytest.mark.parametrize("endpoint", WRITES, ids=lambda e: e.name)
def test_a_write_by_a_non_owner_is_attributed_to_that_person(
    endpoint: Endpoint,
    people: dict[str, Any],  # noqa: F811 - the fixture, imported above
    grpc_call: Any,
) -> None:
    role = next((r for r in ("Member", "Admin") if endpoint.permission in BUILTIN_GRANTS[r]), None)
    if role is None:
        pytest.skip("Owner only: covered by test_a_write_leaves_an_entry")
    world = _world(people, BUILTIN_ROLES.index(role))
    if endpoint.prepare:
        endpoint.prepare(world)
    before = AuditEntry.objects.filter(workspace=world.ws).count()
    endpoint.call(world, role, grpc_call)
    new = AuditEntry.objects.filter(workspace=world.ws).order_by("pk")[before:]
    assert new, f"{endpoint.name} as {role}"
    mine = str(people["users"][role].pk)
    assert any(e.actor == mine for e in new) or all(e.actor_type != "user" for e in new), [
        (e.action, e.actor) for e in new
    ]


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
