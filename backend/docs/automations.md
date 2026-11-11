# Automations

When-if-then rules on a project's tasks, with a run history and loop guards. Always installed; gRPC only (`AutomationController`, `AutomationRunController`). Phase 24.

A rule belongs to one project and has a **trigger** (task created, status changed, field changed, assigned, due date reached, comment added), an optional **condition** (a TFQL filter from the filters app, evaluated on the task) and a list of **actions** (set a field, set the status, set the assignees, add a comment, create a subtask, notify people, call a webhook). Text an action writes may use `{title}`, `{key}`, `{status}`, `{today}` and `{automation}`.

## Routes

<!-- generated:routes -->
_This app publishes no routes of its own._
<!-- /generated:routes -->

## Models

<!-- generated:models -->
#### `Automation`

One rule of one project. ``trigger`` is ``{"type": ..., ...}``, ``condition_ast`` a TFQL

| Field | Type | Notes |
| --- | --- | --- |
| `id` | UUID | primary key, not editable |
| `workspace` | ForeignKey | → `workspaces.Workspace` |
| `project` | ForeignKey | → `projects.Project` |
| `name` | Char |  |
| `enabled` | Boolean |  |
| `trigger` | JSON |  |
| `condition_ast` | JSON |  |
| `actions` | JSON |  |
| `owner` | ForeignKey | → `accounts.User`, nullable |
| `disabled_reason` | Char |  |
| `version` | PositiveInteger |  |
| `created_at` | DateTime |  |
| `updated_at` | DateTime |  |

#### `AutomationRun`

One evaluation of a rule for one event on one task. ``event_key`` is the id of the event, so

| Field | Type | Notes |
| --- | --- | --- |
| `id` | UUID | primary key, not editable |
| `automation` | ForeignKey | → `automations.Automation` |
| `workspace` | ForeignKey | → `workspaces.Workspace` |
| `task` | ForeignKey | → `tasks.Task`, nullable |
| `event_key` | Char |  |
| `depth` | PositiveSmallInteger |  |
| `status` | Char |  |
| `input` | JSON |  |
| `steps` | JSON |  |
| `error` | Char |  |
| `explanation` | Char |  |
| `started_at` | DateTime |  |
| `finished_at` | DateTime | nullable |
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

Seeing rules and runs needs `workspace.view` and a project the caller can open; every change, the dry run included, needs `automation.manage` (Owner and Admin). Everything is scoped to the workspace and the project: a rule never touches a task of another project, and an id from another project or workspace is a 404.

**Who a rule acts as.** A rule runs with the permissions of its owner, never more: each action goes through the ordinary task, comment and inbox services with the owner as the caller, and before every run the owner must still be an active member holding `automation.manage` with an open, unarchived project, otherwise the run is recorded as failed with that reason and nothing is done. Whoever edits a rule or switches it back on becomes its owner, so a rule cannot be used to do more than its editor could. Comments a rule writes start with `[Automation: <name>]`, and its notifications say "Automation: <name>".

**Events and the worker.** There is no Celery yet. The same events the inbox and the live feed use (`task_activity`, `task_changed`, `comment_changed`) are consumed in `receivers.py`, which queues each matching rule through `queue.run_later`: a two-thread pool in the process, or on the spot when `DJANGO_AUTOMATIONS_SYNC_RUN=1` (tests). `run_later` is the one seam Celery replaces. "Due date reached" has no event, so `manage.py automations_tick` (run by `make tick` every minute) queues those rules, once per task and due date, and prunes run history. A field-changed event names the fields whose version is the event's version.

**Runs.** Each (rule, task, event id) has at most one run row (unique), so retries and repeated ticks never repeat actions. A run has an `input` (the event and the task as the rule saw it), `steps` (what each action did, or "not_run" after a failure; actions are not one transaction), an `error` and a plain-words `explanation` of why nothing was done ("the task does not meet: priority = high"). Statuses: `succeeded`, `failed`, `skipped_condition`, `skipped_loop`, `skipped_rate`. Rules that trigger rules are chained through the actor: a run carries `automation_depth`, the events it causes are one hop deeper, and the sixth hop is recorded as `skipped_loop`. A rule that already ran 30 times in the last minute records `skipped_rate`. Runs older than 30 days, and all but the newest 500 per rule, are pruned.

**Dry run.** `DryRun(rule, task)` runs the owner, condition and action checks and returns the exact would-be changes (`field`, `from`, `to`), the comment text, the notify recipients and the webhook target, without writing, notifying or sending anything.

**When something it names is gone.** Deleting a status, deleting or archiving a custom field, or a named person leaving the project switches the rule off, stores the reason in `disabled_reason` and tells the owner through the inbox (`automation.disabled`). Switching it on again is refused until it is fixed.

**Limits.** 50 rules per project, 10 actions per rule, 20 KB of rule JSON, 80-character names.

**Webhooks and SSRF.** Only `http` and `https`, no credentials in the address. The host is resolved when the call is made and every address must be public (private, loopback, link-local, carrier-grade NAT, multicast and IPv4-mapped forms are refused); the connection is then made to that very address, so a name cannot change its answer. Redirects are never followed, the call times out after 5 seconds and the answer is read up to 64 KB. Addresses that are plainly private are already refused when the rule is saved. There is no setting to relax this.
