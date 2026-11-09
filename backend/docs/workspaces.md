# Workspaces

The top-level tenant container; every project and task belongs to one. Always installed. gRPC: `WorkspaceController` (List, Create,
Update, Delete, Restore, ListDeleted), `MemberController`, `InvitationController`, `RoleController`, `PermissionController`; REST: logo upload and public invite preview/accept.

## Scoping later phases' endpoints

Clients send the workspace id as gRPC metadata `x-workspace` / REST header
`X-Workspace`. `infrastructure.workspaces.scoping` resolves it:
`await grpc_workspace(context, user)` or `workspace_from_request(request)`. Both
return the `Workspace` only if the caller is a member and it is not deleted;
otherwise `PERMISSION_DENIED` / 403, identical for a non-member and a missing id.
Filter every query by the returned workspace.

## Rules

- A creator becomes the sole member with the Owner role. `Workspace.created_by` is
  history only; no rule reads it (see Roles and permissions).
- Slugs are 3-40 characters of `a-z`, `0-9` and `-`, never starting or ending with
  a hyphen, and a reserved word (`api`, `admin`, `app`, `www`...) is refused. They
  are unique, and a soft-deleted workspace keeps holding its slug.
- Delete is soft and needs the workspace name typed exactly. Restore works for 7
  days (`ListDeleted` lists them); after that `manage.py purge_workspaces` (calls
  `purge_expired()`) hard-deletes the row and its logo and frees the slug (a workspace that fails is logged by id and skipped; the rest still purge). Run it
  daily; schedule it from the worker when jobs arrive (phase 19/24).
- Every update carries `expected_version`. A stale one is `ABORTED` over gRPC and
  409 `VERSION_CONFLICT` over REST; re-read and retry.
- The logo is a PNG, JPEG or WebP of at most 2 MB, identified by its leading bytes
  rather than the client's claimed content type. The size is checked against the
  declared length before reading and again on a capped read.

## Members and invitations (phase 03)

- Decisions: no Celery exists, so invite emails are signal-driven and async. Create/resend
  send `invitation_issued` (invitation id, raw token, workspace, inviter, email) via
  `transaction.on_commit` (a rollback sends nothing). The receiver (`invite_mail.py`) queues
  the job on a 4-thread in-process pool, which calls `auth.core.delivery.send_email` up to 3
  times with backoff. Failures are logged with invitation id + workspace id only (never the
  token or address); the invite stays pending and can be resent. gRPC
  `InvitationCreateResponse.undelivered_emails` is kept for contract stability but is always
  empty. The raw token lives only in memory for the job. Ceiling: no durability across
  restarts; move the job to the phase 19/24 worker. `WORKSPACE_EMAIL_ASYNC=false` runs it
  inline (set in tests); `WORKSPACE_EMAIL_BACKOFF_SECONDS` (default 1) scales the retry wait.
  Who may do what is decided by roles (phase 04, below): `member.invite` creates, lists,
  revokes and resends invitations (Member role has it, so phase 03 behaviour is kept),
  `member.view` lists members, `member.remove` removes, leaving is self-service.
- `WorkspaceMember.status` is `active|removed`; only `active` counts as membership
  everywhere (scoping helper, `list_mine`, `list_deleted`, owner lookups). Accepting an
  invite for a removed member re-activates the same row.
- Tokens: 32 random bytes urlsafe; only the SHA-256 is stored; looked up by hash and
  compared with `hmac.compare_digest`. Link invitations return the raw token once
  (CreateLink); email invitations never do: Create and Resend return `token=""` and the
  token exists only in the email. List never returns it. Tokens never appear in URL paths.
- Email invite = single use, 7 days, bound to an address: only an account whose primary
  email equals it case-insensitively can accept. Verification is not required: the token is
  only emailed to the invitee, so token plus matching address is the proof (password signup
  never verifies emails).
  Re-inviting an address revokes its earlier pending invite. Active members' addresses are
  skipped (`skipped_emails`). At most 20 addresses per call.
- Link: expiry 1h-30d (`expires_in` seconds, 0 = 7 days); `max_uses` 1-1000, **0 = unlimited**.
- Accept is idempotent (already active member: membership returned, `uses` unchanged) and
  runs under `select_for_update`. Errors: 404 unknown/deleted-workspace token; 410 with title
  `INVITE_EXPIRED` / `INVITE_REVOKED` / `INVITE_USED_UP`; 403 `INVITE_EMAIL_MISMATCH`;
  410 `INVITE_BEFORE_REMOVAL` when the invitation was created at or before the caller's
  removal (a removed member cannot rejoin through an old link).
- Removal (`remove`/`leave`) sets `WorkspaceMember.removed_at` and revokes every pending
  invitation the removed user created in that workspace. A new invitation created after
  removal re-activates the row and clears `removed_at`.
- `Invitation.List`: newest first, max 200, excludes revoked, used-up and invitations
  expired more than 30 days ago.
- Rate limit: `WORKSPACE_INVITES_PER_HOUR` (default 50) invitations/links/resends per
  workspace per hour -> 429 / RESOURCE_EXHAUSTED. Public preview is throttled per IP by
  `API_THROTTLE_INVITE` (30/min). Email link: `WORKSPACE_INVITE_URL` (`{token}` placeholder).
- gRPC (workspace id in the body as `workspace_id`; PERMISSION_DENIED for non-/removed
  members): `Member.List/Remove/Leave/SetRole`, `Invitation.Create/CreateLink/List/Revoke/Resend`
  (members), `Invitation.Accept/Decline` (any signed-in caller, by `token`).
  gRPC status mapping: 410 becomes NOT_FOUND; use the title in the detail to tell them apart.
- REST: `POST /api/v1/invites/preview` (public) and `POST /api/v1/invites/accept`, both with
  body `{"token": "..."}`.

## Roles and permissions (phase 04)

Every workspace-scoped rule goes through `infrastructure.workspaces.access`; adapters only
translate. Registry of keys and built-in grants: `registry.py` (single source of truth).

| Key | Covers | Owner | Admin | Member | Viewer |
| --- | --- | :-: | :-: | :-: | :-: |
| `workspace.view` | scoping helpers for later phases | x | x | x | x |
| `workspace.update` | rename, slug, logo (gRPC Update, REST logo) | x | x | | |
| `workspace.delete` | Delete, Restore, ListDeleted | x | | | |
| `member.view` | Member.List | x | x | x | x |
| `member.invite` | Invitation Create/CreateLink/List/Revoke/Resend | x | x | x | |
| `member.remove` | Member.Remove | x | x | | |
| `member.set_role` | Member.SetRole | x | x | | |
| `role.view` | Role.List (roles + registry), matrix screen | x | x | x | x |
| `role.manage` | Role.Create/Update/Delete | x | x | | |
| `project.create` | Project.Create ([projects](projects.md)) | x | x | x | |
| `project.update` | Project.Update, SetFeatures | x | x | | |
| `project.archive` | Project.Archive, Restore | x | x | | |
| `project.member.manage` | Project.AddMember, RemoveMember | x | x | | |
| `project.view_private` | Project.ListPrivate (admin list) | x | x | | |

- **API**: `can(actor, key, resource) -> Decision(allowed, permission, role, hint)` never raises
  (unknown key = programming error, `ValueError`); `require(actor, key, workspace)` raises and
  returns the loaded `Grant(role, keys)`. No cache: one query per check (nothing outlives the
  call, so a role change applies on the next request). `Permission.Check` loads once for many keys.
- **Roles**: `Role.workspace` NULL = built-in (Owner, Admin, Member, Viewer; `is_builtin`, never
  editable or deletable, `ROLE_BUILTIN` 403). Custom roles belong to one workspace; the name is
  unique case-insensitively within the workspace and may not equal a built-in name
  (`ROLE_NAME_TAKEN` 409). `WorkspaceMember.role` is a required FK (RESTRICT, so purging a workspace may cascade through its roles and members). A role id from
  another workspace is a plain 404. Update replaces name and checklist together. Delete moves
  members (any status) to `reassign_to` (required while the role has members).
- **Owners**: several allowed. Ownership transfer = an Owner sets someone's role to Owner.
  The last Owner cannot be demoted, removed or leave (`OWNER_PROTECTED` 403); with another
  Owner present any of these is fine. Every member/role change takes the workspace row lock *before* loading the actor's grant (`access.lock`), so a demotion queued ahead is honoured.
- **Escalation**: assigning roles needs `member.set_role`; nobody may assign a role, create or
  edit a role, or act on (set the role of / remove) a member whose role holds a permission they
  lack themselves. So an Admin cannot assign Owner, change an Owner's role or remove an Owner,
  and a custom role manager cannot mint roles above their own checklist. Denied with
  `PERMISSION_DENIED_REASON` naming the missing keys.
- **Invitation roles.** `Invitation.role` (nullable FK, `SET_NULL`) is the role the joiner gets;
  none means Member. `Invitation.Create` and `CreateLink` take an optional `role_id` ("" =
  Member); `Invitation` returns `role_id` / `role_name` ("" when none). The role must be a
  built-in or this workspace's (else `NOT_FOUND`, so another tenant's ids are not probed), and
  the inviter must hold every key of it (the SetRole escalation rule: an Admin cannot invite as
  Owner; an Owner can). Checked before anything is created or the quota charged. Accept assigns
  the invitation's role, also for a returning, previously removed member (who never keeps an
  old role); if the role was deleted meanwhile it falls back to Member. Resend keeps the role.
  Existing invitations (no role) behave as before.
- **Seeding**: migration 0005 creates the built-ins and backfills members (creator -> Owner,
  everyone else -> Member). 0005 freezes the phase-04 grants (it never reads the live registry). A `post_migrate`
  hook recreates *missing* built-ins only (a flushed test database), from the migrations' grants
  (`seed.migrated_grants()`), and never edits existing ones. **Adding a key** = add it to
  `registry.py` and write a migration that calls `seed.grant_to_builtins(...)` and declares
  `ADDED_GRANTS = {key: (roles,)}`; `test_registry_grants_are_exactly_what_the_migrations_ship`
  fails until the migrations and `BUILTIN_GRANTS` agree.
- **Denials**. Non-member, removed member, deleted/unknown workspace: the uniform 403
  `FORBIDDEN` with no reason. A member lacking a key: title `PERMISSION_DENIED_REASON`,
  message `missing: <key>[, <key>]; your role: <Role>`. REST: 403, envelope
  `data = {permission, role, hint}`. gRPC: `PERMISSION_DENIED`, detail
  `PERMISSION_DENIED_REASON: <hint>` plus trailing metadata `x-error-permission-bin`,
  `x-error-role-bin`, `x-error-hint-bin` (UTF-8 bytes; read them from the call's trailers).
  `deploy/envoy.yaml` lists these in CORS `expose_headers` (with `grpc-status`, `grpc-message`);
  without that, Flutter web cannot read them. Add any new `x-error-*-bin` trailer there too.
- **WebSocket denials** (`workspaces/sockets.py`; no workspace-scoped socket is mounted yet,
  phase 16 mounts one). A socket handler calls `await socket_workspace(user, raw_id)` (member
  holding `workspace.view`) or `await socket_require(user, permission, workspace_id)` (also the
  permission); both reuse `scoping.require_workspace` / `access.require` in a thread. On an
  `ApiError` it sends `error_frame(error)`: a member lacking a key gets
  `{"type":"error","code":"permission_denied","permission":..,"role":..,"hint":..}` and the
  connection stays open; a non-member / deleted / unknown / malformed id gets
  `{"type":"error","code":"forbidden"}` with no reason, after which the socket should close with
  `FORBIDDEN_CLOSE_CODE` (4405; 4403 is already the origin refusal in `config.sockets`). Any
  other refusal is `{"type":"error","code":"error","detail":..}`.
  `tests/test_workspace_socket.py` proves it with a test-only handler.
- **Phase 01 endpoints** (accounts, auth, oauth) are account-level, not workspace-scoped:
  `can()` does not apply. Also exempt: Workspace.List/Create, Member.Leave, Invitation
  Accept/Decline and REST invite preview/accept (token-based), Permission.Check (membership
  only). `tests/test_rbac_matrix.py` lists every workspace-scoped handler against every
  built-in role and fails if a handler is in neither its table nor its exempt list.
- gRPC contract: `Role.List(workspace_id) -> RoleList{roles[Role{id,name,is_builtin,permissions[],
  member_count,version}], registry[PermissionArea{area, permissions[{key,label}]}]}`;
  `Role.Create{workspace_id,name,permissions[]}`, `Role.Update{workspace_id,id,name,permissions[],expected_version}`
  -> `Role`; `Role.Delete{workspace_id,id,reassign_to}`; `Member.SetRole{workspace_id,user_id,
  role_id} -> Member` (which gains `role_id`, `role_name`; `is_owner` = role is Owner);
  `Permission.Check{workspace_id,keys[]} -> {answers[{key,allowed}], role_id, role_name}`
  (a repeated message instead of a map: django-socio-grpc cannot generate map fields).
  `Workspace.is_owner` is likewise the caller's Owner role. `Role.version` starts at 1 and bumps on every update; a stale `expected_version` is gRPC `ABORTED` / REST 409, title `VERSION_CONFLICT`, and changes nothing.

## Routes

<!-- generated:routes -->
| Method | Path | Auth | Purpose |
| --- | --- | --- | --- |
| `POST` | `/api/v1/invites/accept` | Bearer | Join via invitation |
| `POST` | `/api/v1/invites/preview` | None | Preview an invitation (public) |
<!-- /generated:routes -->

## Models

<!-- generated:models -->
#### `Invitation`

A way into a workspace: bound to one email, or a link anyone holding it may use.

| Field | Type | Notes |
| --- | --- | --- |
| `id` | UUID | primary key, not editable |
| `workspace` | ForeignKey | → `workspaces.Workspace` |
| `email` | Char | nullable |
| `token_hash` | Char | unique |
| `created_by` | ForeignKey | → `accounts.User` |
| `expires_at` | DateTime |  |
| `role` | ForeignKey | → `workspaces.Role`, nullable |
| `max_uses` | PositiveInteger |  |
| `uses` | PositiveInteger |  |
| `revoked_at` | DateTime | nullable |
| `accepted_at` | DateTime | nullable |
| `created_at` | DateTime |  |

#### `Role`

A named set of permission keys. ``workspace`` NULL means built-in (shared, read-only).

| Field | Type | Notes |
| --- | --- | --- |
| `id` | BigAuto | primary key |
| `workspace` | ForeignKey | → `workspaces.Workspace`, nullable |
| `name` | Char |  |
| `is_builtin` | Boolean |  |
| `version` | PositiveInteger |  |

#### `RolePermission`

| Field | Type | Notes |
| --- | --- | --- |
| `id` | BigAuto | primary key |
| `role` | ForeignKey | → `workspaces.Role` |
| `permission_key` | Char |  |

#### `Workspace`

A company or team. Everything else in TaskForge belongs to exactly one.

| Field | Type | Notes |
| --- | --- | --- |
| `id` | UUID | primary key, not editable |
| `name` | Char |  |
| `slug` | Char | unique |
| `logo` | File |  |
| `created_by` | ForeignKey | → `accounts.User` |
| `created_at` | DateTime |  |
| `deleted_at` | DateTime | nullable |
| `version` | PositiveInteger |  |

#### `WorkspaceMember`

A user's membership and role.

| Field | Type | Notes |
| --- | --- | --- |
| `id` | BigAuto | primary key |
| `workspace` | ForeignKey | → `workspaces.Workspace` |
| `user` | ForeignKey | → `accounts.User` |
| `joined_at` | DateTime |  |
| `status` | Char |  |
| `invited_by` | ForeignKey | → `accounts.User`, nullable |
| `removed_at` | DateTime | nullable |
| `role` | ForeignKey | → `workspaces.Role` |
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
