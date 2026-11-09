# Phase 02 — Workspaces

## Feature
A **workspace** is the top-level container (a company or team). Users can create several, switch between them, and everything else belongs to exactly one.

## Why it exists
Multi-tenancy is the base of all permission and data-isolation logic. ClickUp's Workspace/Space/Folder/List and Jira's site/project layers confuse users; we use a flat, clear hierarchy: **Workspace → Project → Task**.

## How it works (plain words)
After sign-up the user lands on "Create your workspace" (name + URL slug). They become its owner. The top bar has a switcher listing all their workspaces. The selected workspace id is sent with every request (gRPC metadata `x-workspace`, REST header `X-Workspace`, WS group). The backend rejects it unless the user is a member (membership arrives in phase 03; in this phase, the creator is the sole member).

## Scope
**In:** create, rename, change slug, change logo, delete (owner only, with typed confirmation + 7-day soft-delete), list mine, switch.
**Out:** inviting others (03), roles (04).

## Data model
- `Workspace(id, name, slug unique, logo, created_by, created_at, deleted_at)`
- `WorkspaceMember(workspace, user, joined_at)` — minimal here; extended in 03/04

## API surface
- gRPC: `Workspaces.List`, `Create`, `Update`, `Delete`, `Restore`
- REST: logo upload `POST /api/workspaces/{id}/logo`
- Workspace-scoping interceptor/dependency used by all later phases.

## Flutter UI
Onboarding screen, workspace switcher (dropdown on desktop/web, bottom sheet on mobile), settings page (General, Danger zone). Remembers last workspace per device.

## Rules and edge cases
- Slug: lowercase a-z0-9-, 3–40 chars, reserved words blocked (`api`, `admin`, `app`…).
- Soft-deleted workspaces are invisible and their slug is held for 7 days.
- A user with zero workspaces is always routed to onboarding.
- **Cross-tenant test is mandatory**: user A cannot read B's workspace by guessing id.

## Acceptance criteria
- [ ] Create/rename/delete/restore work
- [ ] Switching workspace reloads scoped state with no leakage from the previous one
- [ ] Non-member gets `PERMISSION_DENIED` / 403 / WS close
- [ ] Slug validation and reservation enforced

## Tests
Scoping helper, slug rules, soft-delete timing, cross-tenant access, Flutter switcher state reset.

## Depends on
Phase 01.
