# Workspaces

The top-level tenant container; every project and task belongs to one. Always installed. gRPC: `WorkspaceController` (List, Create,
Update, Delete, Restore, ListDeleted); REST: logo upload only.

## Scoping later phases' endpoints

Clients send the workspace id as gRPC metadata `x-workspace` / REST header
`X-Workspace`. `infrastructure.workspaces.scoping` resolves it:
`await grpc_workspace(context, user)` or `workspace_from_request(request)`. Both
return the `Workspace` only if the caller is a member and it is not deleted;
otherwise `PERMISSION_DENIED` / 403, identical for a non-member and a missing id.
Filter every query by the returned workspace.

## Rules

- A creator becomes the sole member and the owner (`created_by`). Roles arrive in
  phase 04; until then every mutation is owner-only.
- Slugs are 3-40 characters of `a-z`, `0-9` and `-`, never starting or ending with
  a hyphen, and a reserved word (`api`, `admin`, `app`, `www`...) is refused. They
  are unique, and a soft-deleted workspace keeps holding its slug.
- Delete is soft and needs the workspace name typed exactly. Restore works for 7
  days (`ListDeleted` lists them); after that `manage.py purge_workspaces` (calls
  `purge_expired()`) hard-deletes the row and its logo and frees the slug. Run it
  daily; schedule it from the worker when jobs arrive (phase 19/24).
- Every update carries `expected_version`. A stale one is `ABORTED` over gRPC and
  409 `VERSION_CONFLICT` over REST; re-read and retry.
- The logo is a PNG, JPEG or WebP of at most 2 MB, identified by its leading bytes
  rather than the client's claimed content type. The size is checked against the
  declared length before reading and again on a capped read.

## Routes

<!-- generated:routes -->
| Method | Path | Auth | Purpose |
| --- | --- | --- | --- |
| `POST` | `/api/v1/workspaces/{workspace_id}/logo` | Bearer | Upload the workspace logo (PNG, JPEG or WebP, up to 2 MB) |
<!-- /generated:routes -->

## Models

<!-- generated:models -->
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

A user's membership. Roles arrive in phase 04.

| Field | Type | Notes |
| --- | --- | --- |
| `id` | BigAuto | primary key |
| `workspace` | ForeignKey | → `workspaces.Workspace` |
| `user` | ForeignKey | → `accounts.User` |
| `joined_at` | DateTime |  |
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
