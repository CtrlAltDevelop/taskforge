# Phase 02 — Workspaces

**Status:** DONE

## Feature
A **workspace** is the top-level container (a company or team). Users can create several, switch between them, and everything else belongs to exactly one.

## Why it exists
Multi-tenancy is the base of all permission and data-isolation logic. ClickUp's Workspace/Space/Folder/List and Jira's site/project layers confuse users; we use a flat, clear hierarchy: **Workspace → Project → Task**.

## How it works (plain words)
After sign-up the user lands on "Create your workspace" (name + URL slug). They become its owner. The top bar has a switcher listing all their workspaces. The selected workspace id is sent with every request (gRPC metadata `x-workspace`, REST header `X-Workspace`; the WS group comes with phase 16). The backend rejects it unless the user is a member (membership arrives in phase 03; in this phase, the creator is the sole member).

## Scope
**In:** create, rename, change slug, change logo, delete (owner only, with typed confirmation + 7-day soft-delete), restore from "Recently deleted", list mine, switch.
**Out:** inviting others (03), roles (04).

## Data model
- `Workspace(id, name, slug unique, logo, created_by, created_at, deleted_at, version)` — `version` is for optimistic locking; every update carries `expected_version` (stale = `ABORTED` / 409 `VERSION_CONFLICT`)
- `WorkspaceMember(workspace, user, joined_at)` — minimal here; extended in 03/04. Until phase 04 the owner is `created_by`.

## API surface
- gRPC: service `config.workspaces.WorkspaceController` — `List`, `Create`, `Update`, `Delete`, `Restore`, `ListDeleted`
- REST: logo upload `POST /api/v1/workspaces/{id}/logo` (PNG/JPEG/WebP, max 2 MB, type sniffed from leading bytes)
- Scoping helper in `infrastructure.workspaces.scoping`: `require_workspace`, `workspace_from_request` (REST), `grpc_workspace` (gRPC). It is an **explicit call, not an interceptor**: every later phase's endpoint must call it and filter by the returned workspace. Non-member and missing id are indistinguishable (`PERMISSION_DENIED` / 403).
- Management command `manage.py purge_workspaces` hard-deletes workspaces soft-deleted over 7 days ago and frees their slugs.

## Flutter UI
Onboarding screen, workspace switcher (dropdown on desktop/web, bottom sheet on mobile), settings page (General, Danger zone), and a "Recently deleted" section to restore. Remembers last workspace per device. The selected id is injected as `x-workspace` / `X-Workspace` through `scopedCallOptionsProvider`; the logo is picked with `file_picker`.

## Rules and edge cases
- Slug: lowercase a-z0-9-, 3–40 chars, no leading or trailing hyphen, ~38 reserved words blocked (`api`, `admin`, `app`…).
- Soft-deleted workspaces are invisible (except in `ListDeleted`) and their slug is held for 7 days, then `purge_workspaces` frees it.
- A user with zero workspaces is always routed to onboarding.
- **Cross-tenant test is mandatory**: user A cannot read B's workspace by guessing id.

## Acceptance criteria
- [x] Create/rename/delete/restore work
- [x] Switching workspace reloads scoped state with no leakage from the previous one
- [ ] Non-member gets `PERMISSION_DENIED` / 403 (done) / WS close (**deferred to phase 16**: no workspace-scoped socket exists yet)
- [x] Slug validation and reservation enforced

## Tests
Scoping helper, slug rules, soft-delete timing, cross-tenant access, Flutter switcher state reset.

## Notes from implementation
- Scoping is an explicit helper, not an interceptor. Later phases must call `grpc_workspace` / `workspace_from_request` themselves; forgetting it is a tenant leak, so the code-reviewer checks for it.
- **`purge_workspaces` must be scheduled** once a job runner exists (phase 19/24 worker); until then run it by hand or from cron. Without it slugs of deleted workspaces are never freed.
- The WS non-member close is deferred to phase 16 (first workspace-scoped socket).
- Owner = `created_by` until roles land in phase 04.
- Added dependency: `file_picker` (logo selection). New proto added to `DART_PROTOS` in the Makefile.
- Logo size is checked twice: a cheap declared-size check before reading, then a read capped at 2 MB + 1 byte.
- Verified by tests only; not run in a real browser or on a device.

## Depends on
Phase 01.
