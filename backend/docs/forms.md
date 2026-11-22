# Intake forms

Public forms that turn a submission into a task. Phase 33.

## Routes

<!-- generated:routes -->
| Method | Path | Auth | Purpose |
| --- | --- | --- | --- |
| `GET` | `/api/v1/public/forms/{token}` | None | Read a public form (the definition only) |
| `POST` | `/api/v1/public/forms/{token}/submit` | None | Submit a public form (multipart) |
<!-- /generated:routes -->

## Models

<!-- generated:models -->
#### `Form`

A shareable form that creates a task in ``project``.

| Field | Type | Notes |
| --- | --- | --- |
| `id` | UUID | primary key, not editable |
| `workspace` | ForeignKey | → `workspaces.Workspace` |
| `project` | ForeignKey | → `projects.Project` |
| `name` | Char |  |
| `description` | Char |  |
| `token` | Char | unique |
| `fields` | JSON |  |
| `defaults` | JSON |  |
| `enabled` | Boolean |  |
| `require_email` | Boolean |  |
| `send_confirmation` | Boolean |  |
| `notify_status` | Boolean |  |
| `brand_color` | Char |  |
| `logo_url` | Char |  |
| `logo` | File |  |
| `created_by` | ForeignKey | → `accounts.User`, nullable |
| `owner` | ForeignKey | → `accounts.User`, nullable |
| `version` | PositiveInteger |  |
| `created_at` | DateTime |  |
| `updated_at` | DateTime |  |

#### `FormSubmission`

One visitor's send. ``reference`` is all the visitor ever learns about the task. ``ip_hash``

| Field | Type | Notes |
| --- | --- | --- |
| `id` | UUID | primary key, not editable |
| `form` | ForeignKey | → `forms.Form` |
| `task` | ForeignKey | → `tasks.Task`, nullable |
| `reference` | Char | unique |
| `submitter_email` | Char |  |
| `ip_hash` | Char |  |
| `locale` | Char |  |
| `wants_updates` | Boolean |  |
| `at` | DateTime |  |
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

A form belongs to a project and is reached through a secret token in its public address. The public endpoints answer the same not-found for a wrong token, a switched-off form and a deleted one, so tokens cannot be probed. Submissions are limited per form and per address (`DJANGO_FORMS_RATE_PER_FORM`, `DJANGO_FORMS_RATE_PER_IP`), a hidden honeypot field silently drops bots, and answers are validated against the form's field list before a task is made in the form's project with the form's defaults. The submitter gets a reference they can quote. Managing forms needs `form.manage`; the public page shows only the fields the form exposes, never project internals.
