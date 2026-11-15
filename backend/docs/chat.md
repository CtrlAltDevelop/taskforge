# Chat

Channels, private groups and direct messages with threads, reactions and mentions. Phase 43.

## Routes

<!-- generated:routes -->
_This app publishes no routes of its own._
<!-- /generated:routes -->

## Models

<!-- generated:models -->
#### `ChatMember`

One person's place in a space. For ``#general`` and a project's channel the row only holds

| Field | Type | Notes |
| --- | --- | --- |
| `id` | BigAuto | primary key |
| `space` | ForeignKey | → `chat.ChatSpace` |
| `user` | ForeignKey | → `accounts.User` |
| `role` | Char |  |
| `last_read_at` | DateTime |  |
| `muted_until` | DateTime | nullable |
| `muted_completely` | Boolean |  |
| `notify_all` | Boolean |  |
| `joined_at` | DateTime |  |

#### `ChatMessage`

``body`` is the shared rich-text document, rebuilt by ``comments.body.clean``. ``deleted_at``

| Field | Type | Notes |
| --- | --- | --- |
| `id` | UUID | primary key, not editable |
| `space` | ForeignKey | → `chat.ChatSpace` |
| `workspace` | ForeignKey | → `workspaces.Workspace` |
| `author` | ForeignKey | → `accounts.User` |
| `parent` | ForeignKey | → `chat.ChatMessage`, nullable |
| `body` | JSON |  |
| `created_at` | DateTime |  |
| `edited_at` | DateTime | nullable |
| `deleted_at` | DateTime | nullable |
| `version` | PositiveInteger |  |

#### `ChatReaction`

| Field | Type | Notes |
| --- | --- | --- |
| `id` | BigAuto | primary key |
| `message` | ForeignKey | → `chat.ChatMessage` |
| `user` | ForeignKey | → `accounts.User` |
| `emoji` | Char |  |
| `at` | DateTime |  |

#### `ChatSpace`

A place to talk. ``channel``: open to the workspace (``project`` null) or to one project's

| Field | Type | Notes |
| --- | --- | --- |
| `id` | UUID | primary key, not editable |
| `workspace` | ForeignKey | → `workspaces.Workspace` |
| `kind` | Char |  |
| `name` | Char |  |
| `project` | ForeignKey | → `projects.Project`, nullable |
| `is_default` | Boolean |  |
| `dm_key` | Char | nullable |
| `created_by` | ForeignKey | → `accounts.User`, nullable |
| `archived_at` | DateTime | nullable |
| `created_at` | DateTime |  |
| `version` | PositiveInteger |  |
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

A space is `channel`, `group` or `dm`. `#general` (one per workspace) and a project's channel (one per project, named after it, read-only once the project is archived) include everyone who may see the workspace or the project: their `ChatMember` rows only hold read state and settings, and project member changes keep them in step in the same transaction. Any other channel is open to the workspace and joined freely; a group is private and invite-only; a direct message is found by the sorted pair of its two people, so `OpenDm` returns the same space every time.

Every query is workspace-scoped and then membership-scoped: a group or DM is a 404 to everyone outside it, in lists, in every call and in live events and catch-up (events go to the `user:` rooms of the people who can read the space, never to a workspace or project room). Chat needs `chat.read` (read), `chat.post` (write, react, open DMs) and `chat.manage` (create channels and groups, archive and rename your own); Owner, Admin and Member hold all three, a Viewer (guest) none. Archiving or renaming other people's spaces and removing their messages is for a workspace Owner or Admin.

Messages use the comments' body sanitizer, mention parser and reaction rules; `@channel` and `@here` are `mention` nodes with the id `channel` or `here`. A message of a space with more than 50 members that writes either needs `confirm_broadcast`. A mention of someone who cannot see the space is refused unless the caller manages it and sets `grant_access`. Sends are idempotent by `client_id` (the message id) and `client_mutation_id`, limited per person per space per minute and capped in size. Edits are the author's within 24 hours; delete leaves a placeholder.

Notifications: `chat.mentioned` (named, once per message version), `chat.channel_all` (`@channel` to the members, `@here` to those who read the space in the last 30 minutes), `chat.dm` (the other person) and `chat.message` (a space the person asked to follow with `Notify`). A plain channel message notifies nobody else and never its author. Muting silences pushes except for being named; muting completely silences everything from the space.

Events (entity: the space): `chat.message.created|updated|deleted`, `chat.space.updated`, `chat.read` (the reader's own devices only).
