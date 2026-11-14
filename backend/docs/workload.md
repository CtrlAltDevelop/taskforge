# Workload and capacity

Who has how much to do, against capacity, time off and holidays. Phase 36.

## Routes

<!-- generated:routes -->
_This app publishes no routes of its own._
<!-- /generated:routes -->

## Models

<!-- generated:models -->
#### `AssigneeEstimate`

One assignee's own estimate for a task. When any exists, the task's estimate is no longer

| Field | Type | Notes |
| --- | --- | --- |
| `id` | BigAuto | primary key |
| `task` | ForeignKey | → `tasks.Task` |
| `user` | ForeignKey | → `accounts.User` |
| `estimate_sec` | PositiveInteger |  |

#### `Holiday`

A day nobody in the workspace works.

| Field | Type | Notes |
| --- | --- | --- |
| `id` | UUID | primary key, not editable |
| `workspace` | ForeignKey | → `workspaces.Workspace` |
| `date` | Date |  |
| `name` | Char |  |

#### `MemberCapacity`

How much a person can take on: ``hours_per_day`` on each of ``working_days``. No row means

| Field | Type | Notes |
| --- | --- | --- |
| `id` | UUID | primary key, not editable |
| `workspace` | ForeignKey | → `workspaces.Workspace` |
| `user` | ForeignKey | → `accounts.User` |
| `hours_per_day` | Decimal |  |
| `working_days` | JSON |  |
| `updated_at` | DateTime |  |

#### `TimeOff`

Days (first and last inclusive) a person is away; their capacity is zero on them.

| Field | Type | Notes |
| --- | --- | --- |
| `id` | UUID | primary key, not editable |
| `workspace` | ForeignKey | → `workspaces.Workspace` |
| `user` | ForeignKey | → `accounts.User` |
| `start_date` | Date |  |
| `end_date` | Date |  |
| `kind` | Char |  |
| `note` | Char |  |
| `created_by` | ForeignKey | → `accounts.User`, nullable |
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

A task's estimate is spread over the working days between its start and due date, in whole seconds that add up exactly, the first days taking the remainder. Days that are not working days (weekend, holiday, time off) are skipped; when none remain the whole estimate lands on the due date with a warning. With several assignees, those with an estimate of their own keep it and the rest share what is left. Everything is calendar dates, so a daylight-saving change cannot move load. Seeing others' load needs `workload.view`; setting capacity and holidays needs `workload.manage`.
