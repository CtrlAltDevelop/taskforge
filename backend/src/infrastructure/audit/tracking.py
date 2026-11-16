"""What is recorded for each model saved or deleted through the ORM.

One row of ``TRACKED`` per model: how to find its workspace, project and *target* (the thing the
history is filed under: a task for its comments, files, links and time), which fields are watched
and what a change to them is called. Writes that skip the ORM's signals (``queryset.update``,
``bulk_create``, ``bulk_update``) call ``recorder.record`` themselves.
"""

from collections.abc import Callable
from dataclasses import dataclass, field
from typing import Any

Getter = Callable[[Any], Any]


def _none(_: Any) -> Any:
    return None


def _pk(o: Any) -> Any:
    return o.pk


@dataclass(frozen=True, slots=True)
class Track:
    prefix: str  # actions are "<prefix>.created|updated|deleted" ...
    target_type: str
    fields: tuple[str, ...]  # attnames: ``status_id``, not ``status``
    workspace: Getter
    target: Getter = _pk
    project: Getter = _none
    # Merged into every entry as plain values: ids that say which child row it was.
    extra: Callable[[Any], dict[str, Any]] = lambda _o: {}
    # A field that flips null <-> value names a verb: {"deleted_at": ("deleted", "restored")}.
    states: dict[str, tuple[str, str]] = field(default_factory=dict)
    # Only this field changed: {"status_id": "status_changed"} -> "<prefix>.status_changed".
    single: dict[str, str] = field(default_factory=dict)
    # A child row (a comment, a file) is "created"/"deleted" under another prefix and has no
    # "updated" worth a line unless a watched field moved.
    record_create: bool = True
    # Which rows count at all (a page's own links are derived from its body, not edits).
    when: Callable[[Any], bool] = lambda _o: True


def _project_ws(o: Any) -> Any:
    return o.project.workspace_id


TRACKED: dict[str, Track] = {
    "tasks.Task": Track(
        "task",
        "task",
        (
            "title",
            "description",
            "status_id",
            "priority",
            "start_date",
            "due_date",
            "due_time",
            "estimate_sec",
            "points",
            "sprint_id",
            "parent_id",
            "deleted_at",
        ),
        workspace=lambda o: o.workspace_id,
        project=lambda o: o.project_id,
        states={"deleted_at": ("deleted", "restored")},
        single={"status_id": "status_changed"},
    ),
    # A blocked task completed anyway: who, and which blockers were open.
    "tasks.BlockOverride": Track(
        "block_override",
        "task",
        ("blockers",),
        workspace=lambda o: o.task.workspace_id,
        target=lambda o: o.task_id,
        project=lambda o: o.task.project_id,
    ),
    "tasks.TaskLink": Track(
        "link",
        "task",
        ("type", "to_task_id"),
        workspace=lambda o: o.workspace_id,
        target=lambda o: o.from_task_id,
        project=lambda o: o.from_task.project_id,
        extra=lambda o: {"link_id": o.pk},
    ),
    "dashboards.Dashboard": Track(
        "dashboard",
        "dashboard",
        ("name", "visibility", "project_id", "layout"),
        workspace=lambda o: o.workspace_id,
        project=lambda o: o.project_id,
    ),
    "dashboards.Widget": Track(
        "widget",
        "dashboard",
        ("type", "title", "config"),
        workspace=lambda o: o.dashboard.workspace_id,
        target=lambda o: o.dashboard_id,
        project=lambda o: o.dashboard.project_id,
        extra=lambda o: {"widget_id": o.pk},
    ),
    "tasks.WorkingCalendarSetting": Track(
        "calendar",
        "workspace",
        ("days", "holidays"),
        workspace=lambda o: o.workspace_id,
        target=lambda o: o.workspace_id,
    ),
    "projects.Project": Track(
        "project",
        "project",
        (
            "name",
            "key",
            "description",
            "icon",
            "color",
            "visibility",
            "archived_at",
            "settings",
        ),
        workspace=lambda o: o.workspace_id,
        project=lambda o: o.pk,
        states={"archived_at": ("archived", "restored")},
    ),
    "projects.ProjectMember": Track(
        "project_member",
        "project",
        ("user_id",),
        workspace=_project_ws,
        target=lambda o: o.project_id,
        project=lambda o: o.project_id,
        extra=lambda o: {"user_id": o.user_id},
    ),
    "workflows.Workflow": Track(
        "workflow",
        "project",
        ("restrict_transitions", "restrict_creation"),
        workspace=_project_ws,
        target=lambda o: o.project_id,
        project=lambda o: o.project_id,
    ),
    "workflows.Status": Track(
        "status",
        "project",
        ("name", "color", "category", "is_default"),
        workspace=_project_ws,
        target=lambda o: o.project_id,
        project=lambda o: o.project_id,
        extra=lambda o: {"status_id": o.pk},
    ),
    "workflows.Transition": Track(
        "transition",
        "project",
        ("from_status_id", "to_status_id", "required_role_id", "require_assignee"),
        workspace=_project_ws,
        target=lambda o: o.project_id,
        project=lambda o: o.project_id,
    ),
    "customfields.FieldDefinition": Track(
        "field",
        "project",
        (
            "name",
            "type",
            "options",
            "required",
            "default",
            "hidden_views",
            "position",
            "archived_at",
        ),
        workspace=_project_ws,
        target=lambda o: o.project_id,
        project=lambda o: o.project_id,
        extra=lambda o: {"field_id": o.pk},
        states={"archived_at": ("archived", "restored")},
    ),
    "customfields.FieldValue": Track(
        "field_value",
        "task",
        ("value_text", "value_number", "value_date", "value_json"),
        workspace=lambda o: o.task.workspace_id,
        target=lambda o: o.task_id,
        project=lambda o: o.task.project_id,
        extra=lambda o: {"field_id": o.field_id},
    ),
    "comments.Comment": Track(
        "comment",
        "task",
        ("pinned", "edited_at", "deleted_at"),
        workspace=lambda o: o.workspace_id,
        target=lambda o: o.task_id,
        project=lambda o: o.task.project_id,
        extra=lambda o: {"comment_id": o.pk},
        states={"deleted_at": ("deleted", "restored")},
        when=lambda o: o.kind == "user",  # a change message repeats what the task entry says
    ),
    # Chat keeps who did what and where, never what was said (DMs stay private to their pair).
    "chat.ChatSpace": Track(
        "chat_space",
        "chat_space",
        ("name", "archived_at"),
        workspace=lambda o: o.workspace_id,
        project=lambda o: o.project_id,
        states={"archived_at": ("archived", "restored")},
    ),
    "chat.ChatMember": Track(
        "chat_member",
        "chat_space",
        ("role",),
        workspace=lambda o: o.space.workspace_id,
        target=lambda o: o.space_id,
        project=lambda o: o.space.project_id,
        extra=lambda o: {"user_id": o.user_id},
        when=lambda o: not o.space.follows_workspace_or_project,
    ),
    "chat.ChatMessage": Track(
        "chat_message",
        "chat_space",
        ("deleted_at",),
        workspace=lambda o: o.workspace_id,
        target=lambda o: o.space_id,
        project=lambda o: o.space.project_id,
        extra=lambda o: {"message_id": o.pk},
        states={"deleted_at": ("deleted", "restored")},
        when=lambda o: o.space.kind != "dm",
    ),
    "chat.ChatReaction": Track(
        "chat_reaction",
        "chat_space",
        (),
        workspace=lambda o: o.message.workspace_id,
        target=lambda o: o.message.space_id,
        extra=lambda o: {"message_id": o.message_id, "emoji": o.emoji},
        when=lambda o: o.message.space.kind != "dm",
    ),
    "attachments.Attachment": Track(
        "attachment",
        "task",
        ("filename", "mime", "size", "deleted_at"),
        workspace=lambda o: o.workspace_id,
        target=lambda o: o.task_id or o.comment.task_id,
        project=lambda o: (o.task or o.comment.task).project_id,
        extra=lambda o: {"attachment_id": o.pk},
        states={"deleted_at": ("deleted", "restored")},
    ),
    "sprints.Sprint": Track(
        "sprint",
        "sprint",
        (
            "name",
            "goal",
            "start_date",
            "end_date",
            "state",
            "capacity_points",
            "capacity_sec",
        ),
        workspace=lambda o: o.workspace_id,
        project=lambda o: o.project_id,
        single={"state": "state_changed"},
    ),
    "wikidocs.Doc": Track(
        "doc",
        "doc",
        ("title", "parent_id", "restricted", "archived_at"),
        workspace=lambda o: o.workspace_id,
        project=lambda o: o.project_id,
        states={"archived_at": ("archived", "restored")},
    ),
    "wikidocs.DocContent": Track(
        "doc",
        "doc",
        ("version",),
        workspace=lambda o: o.doc.workspace_id,
        target=lambda o: o.doc_id,
        project=lambda o: o.doc.project_id,
        single={"version": "saved"},
        record_create=False,
    ),
    "wikidocs.DocLink": Track(
        "doc_link",
        "task",
        ("kind",),
        workspace=lambda o: o.doc.workspace_id,
        target=lambda o: o.task_id,
        project=lambda o: o.task.project_id,
        extra=lambda o: {"doc_id": o.doc_id},
        when=lambda o: o.kind == "related" and o.task_id is not None,
    ),
    "wikidocs.DocAccess": Track(
        "doc_access",
        "doc",
        ("user_id",),
        workspace=lambda o: o.doc.workspace_id,
        target=lambda o: o.doc_id,
        project=lambda o: o.doc.project_id,
        extra=lambda o: {"user_id": o.user_id},
    ),
    "timetracking.TimeEntry": Track(
        "time",
        "task",
        ("started_at", "ended_at", "duration_sec", "note", "billable"),
        workspace=lambda o: o.workspace_id,
        target=lambda o: o.task_id,
        project=lambda o: o.task.project_id,
        extra=lambda o: {"entry_id": o.pk, "user_id": o.user_id},
    ),
    "automations.Automation": Track(
        "automation",
        "automation",
        ("name", "enabled", "trigger", "condition_ast", "actions", "owner_id", "disabled_reason"),
        workspace=lambda o: o.workspace_id,
        project=lambda o: o.project_id,
        single={"enabled": "toggled"},
    ),
    "recurrence.RecurrenceSeries": Track(
        "recurrence",
        "recurrence",
        ("rrule", "mode", "timezone", "at_time", "lead_days", "ends_on", "skip_weekends", "paused"),
        workspace=lambda o: o.workspace_id,
        project=lambda o: o.project_id,
        extra=lambda o: {"task_id": o.template_task_id},
        single={"paused": "paused"},
    ),
    "savedviews.SavedView": Track(
        "view",
        "view",
        ("kind", "name", "config", "is_shared"),
        workspace=lambda o: o.workspace_id,
        project=lambda o: o.project_id,
    ),
    "filters.SavedFilter": Track(
        "filter",
        "filter",
        ("name", "ast", "visibility"),
        workspace=lambda o: o.workspace_id,
        project=lambda o: o.project_id,
    ),
    "workspaces.Workspace": Track(
        "workspace",
        "workspace",
        ("name", "slug", "logo", "deleted_at"),
        workspace=lambda o: o.pk,
        states={"deleted_at": ("deleted", "restored")},
    ),
    "workspaces.Role": Track(
        "role",
        "role",
        ("name",),
        workspace=lambda o: o.workspace_id,
    ),
    "workspaces.RolePermission": Track(
        "role_permission",
        "role",
        ("permission_key",),
        workspace=lambda o: o.role.workspace_id,
        target=lambda o: o.role_id,
        extra=lambda o: {"permission_key": o.permission_key},
    ),
    "workspaces.WorkspaceMember": Track(
        "member",
        "member",
        ("role_id", "status", "removed_at"),
        workspace=lambda o: o.workspace_id,
        target=lambda o: o.user_id,
        states={"removed_at": ("removed", "rejoined")},
        single={"role_id": "role_changed"},
    ),
    "workspaces.Invitation": Track(
        "invitation",
        "invitation",
        ("email", "role_id", "expires_at", "max_uses", "revoked_at", "accepted_at"),
        workspace=lambda o: o.workspace_id,
        states={"revoked_at": ("revoked", "reopened"), "accepted_at": ("accepted", "reopened")},
    ),
}
