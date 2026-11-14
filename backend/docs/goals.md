# Goals

Goals with key results, check-ins and a progress that rolls up. Phase 34.

## Routes

<!-- generated:routes -->
_This app publishes no routes of its own._
<!-- /generated:routes -->

## Models

<!-- generated:models -->
#### `CheckIn`

One reading of a key result. ``user`` is empty for the readings the system takes when a

| Field | Type | Notes |
| --- | --- | --- |
| `id` | UUID | primary key, not editable |
| `kr` | ForeignKey | → `goals.KeyResult` |
| `user` | ForeignKey | → `accounts.User`, nullable |
| `value` | Decimal |  |
| `previous_value` | Decimal |  |
| `progress` | Float |  |
| `note` | Char |  |
| `at` | DateTime |  |

#### `Goal`

An objective. ``parent`` nests it under a bigger goal (its progress rolls up there with

| Field | Type | Notes |
| --- | --- | --- |
| `id` | UUID | primary key, not editable |
| `workspace` | ForeignKey | → `workspaces.Workspace` |
| `parent` | ForeignKey | → `goals.Goal`, nullable |
| `folder` | ForeignKey | → `goals.GoalFolder`, nullable |
| `name` | Char |  |
| `description` | Char |  |
| `owner` | ForeignKey | → `accounts.User`, nullable |
| `created_by` | ForeignKey | → `accounts.User`, nullable |
| `private` | Boolean |  |
| `period_start` | Date |  |
| `period_end` | Date |  |
| `status_override` | Char |  |
| `weight` | Decimal |  |
| `version` | PositiveInteger |  |
| `created_at` | DateTime |  |
| `updated_at` | DateTime |  |

#### `GoalContributor`

| Field | Type | Notes |
| --- | --- | --- |
| `id` | BigAuto | primary key |
| `goal` | ForeignKey | → `goals.Goal` |
| `user` | ForeignKey | → `accounts.User` |

#### `GoalFolder`

| Field | Type | Notes |
| --- | --- | --- |
| `id` | UUID | primary key, not editable |
| `workspace` | ForeignKey | → `workspaces.Workspace` |
| `name` | Char |  |
| `position` | PositiveInteger |  |
| `created_at` | DateTime |  |

#### `KeyResult`

One measurable result. number/percentage/boolean keep ``current_value`` (set by check-ins);

| Field | Type | Notes |
| --- | --- | --- |
| `id` | UUID | primary key, not editable |
| `goal` | ForeignKey | → `goals.Goal` |
| `name` | Char |  |
| `type` | Char |  |
| `start_value` | Decimal |  |
| `target_value` | Decimal |  |
| `current_value` | Decimal |  |
| `filter_text` | Char |  |
| `filter_ast` | JSON | nullable |
| `weight` | Decimal |  |
| `linked_done` | PositiveInteger |  |
| `linked_total` | PositiveInteger |  |
| `position` | PositiveInteger |  |
| `version` | PositiveInteger |  |
| `created_at` | DateTime |  |
| `updated_at` | DateTime |  |

#### `KeyResultTask`

| Field | Type | Notes |
| --- | --- | --- |
| `id` | BigAuto | primary key |
| `kr` | ForeignKey | → `goals.KeyResult` |
| `task` | ForeignKey | → `tasks.Task` |

#### `ProgressDirty`

A linked key result to recount once ``due_at`` has passed (the debounce of task events).

| Field | Type | Notes |
| --- | --- | --- |
| `id` | BigAuto | primary key |
| `kr` | OneToOne | unique, → `goals.KeyResult` |
| `due_at` | DateTime |  |
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

A goal has a period and an owner and holds key results and child goals. A key result is a number (start, target, current, in either direction), a percentage, a yes or no, or linked to tasks (done over total). Progress is a number from 0 to 1 that never divides by zero: a linked key result without tasks is at 0 and so is a goal without anything to average. A goal's progress is the weighted average of its key results and child goals. Status is computed by comparing progress with the share of the period gone (at risk, off track) unless a person overrides it. Check-ins record each reading with a note. Creating goals needs `goal.create`; changing others' goals needs `goal.manage`.
