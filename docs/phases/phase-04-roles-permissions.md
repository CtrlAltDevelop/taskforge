# Phase 04 — Roles and Permissions

**Status:** DONE

## Feature
Role-based access control with a clear permission matrix and a "why can't I do this?" explanation.

## Why it exists
Jira permission schemes are notoriously tangled; ClickUp's are coarse and gated by plan. Admins can't tell who can see what, and users can't tell why they're blocked.

## How it works (plain words)
Each member has one workspace role: **Owner, Admin, Member, Viewer** (more custom roles can be added per workspace). A role is just a named set of permission keys like `member.invite` (project and task keys arrive with their phases). The backend has one entry point, `can(actor, permission, resource)` (plus `require(...)`, which raises), used by every workspace-scoped service. Project-level overrides (phase 05+) can raise or lower a person's access on a single project. When something is denied, the API returns a machine-readable reason (`missing: task.edit; your role: Viewer`), and the app shows it in a tooltip/dialog.

## Scope
**In:** 4 built-in roles, custom roles (name + permission checklist), assign role, permission registry, `can()` service, deny-reason payload, permissions matrix screen.
**Registry today:** `workspace.view/update/delete`, `member.view/invite/remove/set_role`, `role.view/manage`. Later phases add their own keys.
**Out:** SSO group mapping (37), per-project overrides UI (done when projects exist, phase 05 adds the hook only).

## Data model
- `Role(id, workspace nullable, name, is_builtin, version)`; `version` is the optimistic lock
- `RolePermission(role, permission_key)`
- `WorkspaceMember.role` (required, `on_delete=RESTRICT`: a role with members cannot be deleted; purging a workspace still cascades)

## API surface
- gRPC: `RoleController.List` (also returns the registry), `Create`, `Update` (with `expected_version`), `Delete` (with `reassign_to`); `MemberController.SetRole`; `PermissionController.Check` (lets the UI hide buttons). `Check` uses a repeated answer message because django-socio-grpc has no map fields.
- Deny reason: gRPC `PERMISSION_DENIED` with message `PERMISSION_DENIED_REASON: missing: x; your role: Y` plus trailers `x-error-permission-bin`, `x-error-role-bin`, `x-error-hint-bin` (Envoy exposes them for gRPC-Web). REST: 403 envelope with `data {permission, role, hint}`.
- Non-members (and missing workspaces) get one uniform, reasonless `FORBIDDEN`, so nothing leaks.
- WebSocket: no workspace-scoped socket exists yet, so the reusable guard is built (`workspaces/sockets.py`: `socket_workspace`, `socket_require`, `error_frame`; frames `permission_denied` with `{permission, role, hint}` and a reasonless `forbidden` followed by close 4405) and tested with a test-only handler. Phase 16 mounts the real socket on it.

## Flutter UI
Roles settings page: matrix (rows = permissions grouped by area, columns = roles) with toggle cells; member row has role dropdown. A `PermissionGate` widget hides/disables controls from the cached permission set. Denied actions show the reason.

## Rules and edge cases
- Built-in roles are not editable. Multiple owners are allowed; the last owner cannot be demoted, removed or leave (enforced under a workspace row lock).
- Escalation: you cannot grant, create or edit roles holding permissions you lack; an Admin cannot touch Owners.
- An invitation may carry a role (`Invitation.role`, `role_id` on Create/CreateLink; shown as `role_id`/`role_name`). It must be visible in the workspace (else NOT_FOUND) and the inviter must hold all its keys (an Admin cannot invite as Owner). Accept assigns it, or Member when none or the role was deleted meanwhile; Resend keeps it.
- `ListDeleted` returns only workspaces where the caller holds `workspace.delete` (empty otherwise).
- Phase 01 account endpoints are account-level, so `can()` does not apply.
- Always enforce on the server; the UI gating is cosmetic.
- Permission keys live in one registry file (`registry.py`); adding a key requires a migration declaring `ADDED_GRANTS` and calling `seed.grant_to_builtins`, enforced by `test_registry_grants_are_exactly_what_the_migrations_ship`.
- Cache per-request only; invalidate on role change via event (phase 16 later).

## Acceptance criteria
- [x] Viewer cannot call any write RPC on any transport (tested via a table of all write endpoints; WebSocket has no workspace-scoped writes yet)
- [x] Custom role works end-to-end
- [x] Deny reason visible in UI
- [x] Every existing endpoint from phases 01–03 calls `can()` (or is classified exempt/account-level in the matrix test)

## Tests
Matrix-driven test (`tests/test_rbac_matrix.py`) over every endpoint × role, with every handler classified so a new one cannot slip through; escalation attempts (member promoting self); Flutter gate widget test.

## Depends on
Phases 02, 03.

## Notes from implementation
- Backend: `registry.py` (keys, built-in grants), `seed.py` (migration helpers), `access.py` (`can`/`require`/`Decision`, workspace `lock`), `roles.py` (custom role CRUD), `members.py` (SetRole, last-owner guard), `grpc/roles.py` (`RoleController`, `PermissionController`). Migrations 0004-0008 (0008: `Invitation.role`).
- The phase 03 shortcut "owner is `created_by` and immovable" is gone; ownership is the Owner role and the last-owner rule is real.
- Role updates are optimistic-locked (`expected_version`); a stale write is a conflict, shown in the app as a role-conflict message.
- Flutter: Roles screen with the matrix (built-ins read-only, toggles for custom roles, narrow-width list), role picker on the Members screen, cosmetic `PermissionGate`. `permissionsProvider` resets on workspace switch and is re-read after any refusal; toggles take a busy lock while saving.
- Verified by tests only; not run in a real browser or on a device.
