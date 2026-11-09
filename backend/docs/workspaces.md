# Workspaces

The top-level tenant container; every project and task belongs to one. Always installed. gRPC: `WorkspaceController` (List, Create,
Update, Delete, Restore, ListDeleted), `MemberController`, `InvitationController`; REST: logo upload and public invite preview/accept.

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
  The owner is `created_by` until phase 04. Any active member may create, list, revoke and
  resend invitations and list members; only the owner removes; a non-owner may leave; the
  owner can neither leave nor be removed (no ownership transfer).
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
  members): `Member.List/Remove/Leave`, `Invitation.Create/CreateLink/List/Revoke/Resend`
  (members), `Invitation.Accept/Decline` (any signed-in caller, by `token`).
  gRPC status mapping: 410 becomes NOT_FOUND; use the title in the detail to tell them apart.
- REST: `POST /api/v1/invites/preview` (public) and `POST /api/v1/invites/accept`, both with
  body `{"token": "..."}`.

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
| `max_uses` | PositiveInteger |  |
| `uses` | PositiveInteger |  |
| `revoked_at` | DateTime | nullable |
| `accepted_at` | DateTime | nullable |
| `created_at` | DateTime |  |

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
| `status` | Char |  |
| `invited_by` | ForeignKey | → `accounts.User`, nullable |
| `removed_at` | DateTime | nullable |
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
