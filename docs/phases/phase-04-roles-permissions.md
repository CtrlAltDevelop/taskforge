# Phase 04 — Roles and Permissions

## Feature
Role-based access control with a clear permission matrix and a "why can't I do this?" explanation.

## Why it exists
Jira permission schemes are notoriously tangled; ClickUp's are coarse and gated by plan. Admins can't tell who can see what, and users can't tell why they're blocked.

## How it works (plain words)
Each member has one workspace role: **Owner, Admin, Member, Viewer** (more custom roles can be added). A role is just a named set of permission keys like `project.create`, `task.edit`, `member.invite`. The backend has one function, `can(actor, permission, resource)`, used by every service. Project-level overrides (phase 05+) can raise or lower a person's access on a single project. When something is denied, the API returns a machine-readable reason (`missing: task.edit; your role: Viewer`), and the app shows it in a tooltip/dialog.

## Scope
**In:** 4 built-in roles, custom roles (name + permission checklist), assign role, permission registry, `can()` service, deny-reason payload, permissions matrix screen.
**Out:** SSO group mapping (37), per-project overrides UI (done when projects exist, phase 05 adds the hook only).

## Data model
- `Role(id, workspace nullable, name, is_builtin)`
- `RolePermission(role, permission_key)`
- `WorkspaceMember.role`

## API surface
- gRPC: `Roles.List/Create/Update/Delete`, `Members.SetRole`, `Permissions.Check(keys[])` (lets the UI hide buttons)
- Error detail type `PermissionDenied{permission, role, hint}` on all transports.

## Flutter UI
Roles settings page: matrix (rows = permissions grouped by area, columns = roles) with toggle cells; member row has role dropdown. A `PermissionGate` widget hides/disables controls from the cached permission set. Denied actions show the reason.

## Rules and edge cases
- Built-in roles are not editable; Owner can't be removed from the last owner.
- Always enforce on the server; the UI gating is cosmetic.
- Permission keys live in one registry file; adding a key requires a migration giving it to the right built-ins.
- Cache per-request only; invalidate on role change via event (phase 16 later).

## Acceptance criteria
- [ ] Viewer cannot call any write RPC on any transport (tested via a table of all write endpoints)
- [ ] Custom role works end-to-end
- [ ] Deny reason visible in UI
- [ ] Every existing endpoint from phases 01–03 calls `can()`

## Tests
Matrix-driven test over every endpoint × role; escalation attempts (member promoting self); Flutter gate widget test.

## Depends on
Phases 02, 03.
