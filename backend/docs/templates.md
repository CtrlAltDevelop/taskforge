# Templates

Save a task or a project as a template and apply it again. Phase 35.

## Routes

<!-- generated:routes -->
_This app publishes no routes of its own._
<!-- /generated:routes -->

## Models

<!-- generated:models -->
#### `Template`

``content`` is the snapshot (see ``infrastructure.templates.content``): it names statuses,

| Field | Type | Notes |
| --- | --- | --- |
| `id` | UUID | primary key, not editable |
| `workspace` | ForeignKey | → `workspaces.Workspace` |
| `kind` | Char |  |
| `name` | Char |  |
| `description` | Char |  |
| `content` | JSON |  |
| `task_count` | PositiveInteger |  |
| `visibility` | Char |  |
| `created_by` | ForeignKey | → `accounts.User`, nullable |
| `version` | PositiveInteger |  |
| `created_at` | DateTime |  |
| `updated_at` | DateTime |  |
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

A template stores a task tree, or a whole project with its workflow, custom fields and automations, in a portable form. Dates are saved as day offsets from an anchor, so applying a template on another start date shifts every date by the same amount. People are included only when asked. Applying runs in one transaction and reports warnings for parts that could not be recreated, for instance an automation the person may not manage; a failure rolls the whole application back. Saving needs `template.create`, changing or deleting someone else's template needs `template.manage`, and workspace visibility shares a template with everyone.
