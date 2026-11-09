# Phase 05 — Projects

## Feature
Create and manage **projects** inside a workspace, each with a short key (e.g. `WEB`), a description, and per-project switches for optional features.

## Why it exists
Jira projects are heavy to configure; ClickUp shows every feature to everyone, creating clutter. We start every project minimal and let owners switch on only what they need.

## How it works (plain words)
A project is a bucket of tasks. Its **key** (2–6 capital letters) prefixes task numbers (`WEB-12`). On creation you pick a name, key, icon/color and visibility (**Open** to the workspace or **Private** to invited members). A **Features** page has toggles: sprints, time tracking, dependencies, custom fields, etc. Phases that add those features read these toggles. Projects can be archived (read-only, hidden) and restored.

## Scope
**In:** CRUD, key uniqueness, visibility, archive/restore, favorites, project members for private projects, feature toggles storage and UI, project list/sidebar.
**Out:** tasks (06), workflows (07), project-level permission overrides beyond membership of private projects.

## Data model
- `Project(id, workspace, name, key, description, icon, color, visibility, archived_at, settings jsonb, task_counter, created_by)` with unique `(workspace, key)`
- `ProjectMember(project, user)` for private projects
- `ProjectFavorite(user, project)`

## API surface
- gRPC: `Projects.List/Get/Create/Update/Archive/Restore`, `SetFeatures`, `AddMember/RemoveMember`, `Favorite`
- WS event: `project.updated`

## Flutter UI
Sidebar tree of projects (favorites on top), create dialog, settings page with Features toggles (each with one-line explanation), archived list. Empty state: "Create your first project".

## Rules and edge cases
- Key immutable after the first task exists (tasks reference it in display ids).
- Private projects are invisible (not even in search) to non-members; owners/admins can see them in an admin list but must join to open.
- Turning a feature off hides UI but keeps data.

## Acceptance criteria
- [ ] Create/rename/archive/restore
- [ ] Key rules enforced; private visibility holds on every query
- [ ] Feature toggles persist and are readable by the client in the project payload

## Tests
Key validation, visibility matrix (open/private × role), counter concurrency, cross-tenant access.

## Depends on
Phases 02, 04.
