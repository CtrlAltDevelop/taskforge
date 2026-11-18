# Home

The Home summary, My work, first-run onboarding and the recently opened list.

## Routes

<!-- generated:routes -->
_This app publishes no routes of its own._
<!-- /generated:routes -->

## Models

<!-- generated:models -->
#### `DashboardPin`

A dashboard the person pinned to their Home.

| Field | Type | Notes |
| --- | --- | --- |
| `id` | BigAuto | primary key |
| `user` | ForeignKey | → `accounts.User` |
| `workspace` | ForeignKey | → `workspaces.Workspace` |
| `dashboard` | ForeignKey | → `dashboards.Dashboard` |
| `created_at` | DateTime |  |

#### `RecentItem`

A task the person opened (newest ``opened_at`` first, trimmed to ``RECENT_KEEP``).

| Field | Type | Notes |
| --- | --- | --- |
| `id` | BigAuto | primary key |
| `user` | ForeignKey | → `accounts.User` |
| `workspace` | ForeignKey | → `workspaces.Workspace` |
| `task` | ForeignKey | → `tasks.Task` |
| `opened_at` | DateTime |  |

#### `UserOnboarding`

One person's first-run checklist in one workspace (a new workspace starts a new one).

| Field | Type | Notes |
| --- | --- | --- |
| `id` | BigAuto | primary key |
| `user` | ForeignKey | → `accounts.User` |
| `workspace` | ForeignKey | → `workspaces.Workspace` |
| `checklist` | JSON |  |
| `dismissed_at` | DateTime | nullable |
| `sample_project` | ForeignKey | → `projects.Project`, nullable |
| `created_at` | DateTime |  |
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

- **Transport**: gRPC only. `HomeController`: `Summary` (the whole Home screen in one call, cached 30 s per viewer, workspace and day), `MyWork` (tasks assigned to or watched by the caller, with the toolbar's TFQL filter), `RecordRecent`, `PinDashboard`. `OnboardingController`: `Get`, `CompleteStep`, `Dismiss`, `ApplyStarter`, `DeleteSamples`.
- **Scope**: everything is read through `Project.objects.visible_to`, so a private project the caller cannot open never reaches a count, item, recent entry, pin or My work row. Sample tasks (`Task.is_sample`) are left out of Home counts and dashboards.
- **Checklist**: `create_task` and `invite_member` tick from the real action; `try_board` and `open_palette` through `CompleteStep`. It never returns after dismiss or completion, and each workspace has its own.
- **Starters**: `software-team`, `marketing`, `bug-tracker` (the built-in templates) and `blank`. `ApplyStarter` needs `project.create`, runs in one transaction and is audited; `DeleteSamples` sends the caller's sample tasks to the trash and keeps the projects.
