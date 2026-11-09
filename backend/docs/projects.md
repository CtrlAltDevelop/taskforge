# Projects

Projects inside a workspace: a short key, a look, open or private visibility, archive, favorites and per-project feature switches. Always installed. gRPC only (`ProjectController`), so it has no REST routes and is listed in `INSTALLED_APPS` directly rather than through `api_registry.json`. Phase 05; tasks (phase 06) number themselves with `next_task_number`.

## Routes

<!-- generated:routes -->
_This app publishes no routes of its own._
<!-- /generated:routes -->

## Models

<!-- generated:models -->
#### `Project`

``task_counter`` is the last task number handed out (phase 06 prefixes it with ``key``).

| Field | Type | Notes |
| --- | --- | --- |
| `id` | UUID | primary key, not editable |
| `workspace` | ForeignKey | → `workspaces.Workspace` |
| `name` | Char |  |
| `key` | Char |  |
| `description` | Char |  |
| `icon` | Char |  |
| `color` | Char |  |
| `visibility` | Char |  |
| `archived_at` | DateTime | nullable |
| `settings` | JSON |  |
| `task_counter` | PositiveInteger |  |
| `created_by` | ForeignKey | → `accounts.User` |
| `created_at` | DateTime |  |
| `updated_at` | DateTime |  |
| `version` | PositiveInteger |  |

#### `ProjectFavorite`

| Field | Type | Notes |
| --- | --- | --- |
| `id` | BigAuto | primary key |
| `user` | ForeignKey | → `accounts.User` |
| `project` | ForeignKey | → `projects.Project` |

#### `ProjectMember`

| Field | Type | Notes |
| --- | --- | --- |
| `id` | BigAuto | primary key |
| `project` | ForeignKey | → `projects.Project` |
| `user` | ForeignKey | → `accounts.User` |
| `added_at` | DateTime |  |
<!-- /generated:models -->

## Admin

<!-- generated:admin -->
_This app registers nothing in the admin._
<!-- /generated:admin -->

## Setup

<!-- generated:settings -->
_This app requires no settings of its own._
<!-- /generated:settings -->

## Usage

### Layout

`infrastructure/projects`: `models.py` (+ `Project.objects.visible_to`), `fields.py` (validation), `services.py` (create/update/archive/restore/features/favorite/numbering), `members.py` (private-project members, admin list), `features.py` (feature registry), `signals.py`, `grpc/` (adapter, serializers, `projects.proto`). The permission keys live in the single workspaces registry (`workspaces/registry.py`); their grants migration is `workspaces/migrations/0009_project_permissions.py`.

### Permissions

| Key | Covers | Owner | Admin | Member | Viewer |
| --- | --- | :-: | :-: | :-: | :-: |
| `project.create` | Create | x | x | x | |
| `project.update` | Update (name, description, icon, color, visibility, key), SetFeatures | x | x | | |
| `project.archive` | Archive, Restore | x | x | | |
| `project.member.manage` | AddMember, RemoveMember | x | x | | |
| `project.view_private` | ListPrivate | x | x | | |

**Creator rule** (`access.can/require(..., resource=project)`, one place: `access.CREATOR_KEYS`): the creator of a project may `project.update`, `project.archive` and `project.member.manage` THAT project even if their role lacks the key, as long as they are an active workspace member who still holds `project.create`. Never `project.view_private`, never another project. Services/members use it through `services.authorize`.

List, Get, ListMembers and Favorite need only `workspace.view`. Every call runs `access.require` first, then loads the project through `visible_to`; a missing key is `PERMISSION_DENIED` with the usual reason, an invisible/foreign/unknown id is `NOT_FOUND`. A viewer of an open project can read it; nothing else.

### Rules

- **Key**: 2-6 letters A-Z, stored uppercase, unique per workspace case-insensitively (`unique (workspace, lower(key))`; another workspace may reuse it). It can change only while `task_counter == 0`; afterwards a different key is `KEY_LOCKED` (re-sending the same key is fine). Name 1-80, description up to 2000, icon up to 32 printable characters (emoji or an icon id), color `#RRGGBB` or empty (stored uppercase).
- **One visibility entry point**: `Project.objects.visible_to(user, workspace)` = only for active workspace members: open projects plus private ones the user is a `ProjectMember` of. Every read and write in `services.py`/`members.py` goes through `services.load` which uses it (a source-scan test enforces it), so a private project is `NOT_FOUND` exactly like a missing one. `as_admin=True` also returns private projects the user is not in; it is used only after `require(project.view_private / project.member.manage)` (ListPrivate, AddMember, RemoveMember, Restore; Restore and AddMember by a non-member admin return the blanked admin-list view).
- **Private projects**: the creator is auto-added; making an open project private adds the actor. Only active workspace members can be added; AddMember/RemoveMember on an open project is refused (open projects have no member list; `ListMembers` of an open project returns the rows that exist, normally none). A private project keeps at least one active member: removing the last one is `LAST_MEMBER`. Members who left the workspace do not count and cannot see the project.
- **Admin list** (`ListPrivate`): every private project, archived ones included (`archived_at` set) so admins can find and Restore them; no dead end: Restore alone is enough, then AddMember works. Each carries `member_count` and `can_open` (true only if the caller is a member). For `can_open=false` the message carries identity, look, visibility, `member_count` and nothing else (description, features, counter, creator are blank). To open one, the admin calls `AddMember` with an empty `user_id` (= the caller) or their own id. For any other id: must be an active workspace member, private projects only.
- **Archive**: sets `archived_at`; archived projects are hidden from `List` unless `include_archived`; every mutation except Restore (Update, SetFeatures, Archive, AddMember/RemoveMember, starring, numbering) is `PROJECT_ARCHIVED`. Unstarring is still allowed. Restoring a project that is not archived is a no-op.
- **Favorites** are per user, only for visible non-archived projects; `List` returns favorites first, then by name.
- **Features** (`features.py`, all default off): `subtasks`, `dependencies`, `custom_fields`, `time_tracking`, `sprints`, each with a label and a one-line description. `SetFeatures` replaces the enabled set (stored as `settings["features"]` in registry order); unknown keys are `INVALID_ARGUMENT`. Turning a feature off keeps its data (phases that add the data read the switch). The project payload carries `features[]` as `Feature{key, enabled}` for every key; labels come from `ProjectList.feature_info`.
- **Task counter**: `services.next_task_number(project)` atomically increments `task_counter` and returns it (`UPDATE ... SET task_counter = task_counter + 1`, the row lock lasts until the caller's transaction ends; call it inside the transaction that creates the task). `services.number_task(actor, workspace, project_id)` is the same behind `visible_to` and refuses archived projects (phase 06 must read tasks through `visible_to` and number via `number_task`; `next_task_number` itself refuses an archived project). Numbering does not bump `version`. Concurrency is tested on PostgreSQL only (`make test-postgres`, from `backend/` with the venv `bin` on PATH).
- **Optimistic locking**: `version` starts at 1 and bumps on Update, SetFeatures, Archive and a real Restore; a stale `expected_version` is gRPC `ABORTED` / `VERSION_CONFLICT`. An Update that changes nothing keeps the version, but a stale `expected_version` is still `VERSION_CONFLICT`. Member changes and favorites do not bump it.
- **Notes**: private -> open -> private keeps the `ProjectMember` rows. `project_changed` for a private project (`member_added`/`member_removed`) must only be broadcast to its project members when phase 16 bridges it.
- **Realtime hook**: `signals.project_changed(sender=Project, project_id, workspace_id, version, action)` is sent through `transaction.on_commit` after every mutation (`created updated archived restored features member_added member_removed`; never on rollback; favorites are silent). Phase 16 connects the `project.updated` WebSocket event to it; no socket code exists yet.

### gRPC contract (`config.projects`)

All requests carry `workspace_id`. Responses: `Project`, except where noted.

| RPC | Request fields | Response |
| --- | --- | --- |
| `List` | `workspace_id`, `include_archived` | `ProjectList{projects[], feature_info[FeatureInfo{key,label,description}]}` |
| `Get` | `workspace_id`, `id` | `Project` |
| `Create` | `workspace_id`, `name`, `key`, `description`, `icon`, `color`, `visibility` ("" = open) | `Project` |
| `Update` | `workspace_id`, `id`, `expected_version`, optional `name key description icon color visibility` (only sent fields change) | `Project` |
| `Archive` / `Restore` | `workspace_id`, `id`, `expected_version` | `Project` |
| `SetFeatures` | `workspace_id`, `project_id`, `enabled_keys[]`, `expected_version` | `Project` |
| `Favorite` | `workspace_id`, `project_id`, `favorite` | `Project` |
| `ListMembers` | `workspace_id`, `project_id` | `ProjectMemberList{members[ProjectMember{user_id,display_name,email,added_at}]}` |
| `AddMember` | `workspace_id`, `project_id`, `user_id` | `ProjectMember` |
| `RemoveMember` | `workspace_id`, `project_id`, `user_id` | `ProjectEmpty` |
| `ListPrivate` | `workspace_id` | `PrivateProjectList{projects[]}` (`Project`, see admin list) |

`Project{id, workspace_id, name, key, description, icon, color, visibility, archived_at, version, task_counter, features[Feature{key,enabled}], is_favorite, member_count, is_member, can_open, created_by}` (`archived_at` is an ISO string, "" when active).

Errors: `PERMISSION_DENIED` (`PERMISSION_DENIED_REASON: missing: x; your role: Y`, or `FORBIDDEN` for a non-member of the workspace), `NOT_FOUND` (invisible, foreign or unknown project; unknown user), `INVALID_ARGUMENT` (validation, unknown features, member on an open project), `ALREADY_EXISTS` with title `KEY_TAKEN`, `KEY_LOCKED`, `PROJECT_ARCHIVED` or `LAST_MEMBER` (all HTTP 409 in the shared status table), `ABORTED` `VERSION_CONFLICT`.
