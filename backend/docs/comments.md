# Comments

Threaded comments on a task: rich text, `@mentions`, reactions, edit history, pinning and comment-to-subtask. Always installed. gRPC only (`CommentController`). Phase 17.

## Routes

<!-- generated:routes -->
_This app publishes no routes of its own._
<!-- /generated:routes -->

## Models

<!-- generated:models -->
#### `Comment`

``body`` is the shared rich-text document, rebuilt by ``body.clean`` (never as sent).

| Field | Type | Notes |
| --- | --- | --- |
| `id` | UUID | primary key, not editable |
| `workspace` | ForeignKey | → `workspaces.Workspace` |
| `task` | ForeignKey | → `tasks.Task` |
| `author` | ForeignKey | → `accounts.User`, nullable |
| `kind` | Char |  |
| `event` | JSON | nullable |
| `parent` | ForeignKey | → `comments.Comment`, nullable |
| `body` | JSON |  |
| `created_at` | DateTime |  |
| `edited_at` | DateTime | nullable |
| `deleted_at` | DateTime | nullable |
| `pinned` | Boolean |  |
| `version` | PositiveInteger |  |

#### `CommentMention`

The people the current version of a comment mentions.

| Field | Type | Notes |
| --- | --- | --- |
| `id` | BigAuto | primary key |
| `comment` | ForeignKey | → `comments.Comment` |
| `user` | ForeignKey | → `accounts.User` |

#### `CommentReaction`

| Field | Type | Notes |
| --- | --- | --- |
| `id` | BigAuto | primary key |
| `comment` | ForeignKey | → `comments.Comment` |
| `user` | ForeignKey | → `accounts.User` |
| `emoji` | Char |  |
| `at` | DateTime |  |

#### `CommentRevision`

The body a comment had before an edit replaced it, newest edit last.

| Field | Type | Notes |
| --- | --- | --- |
| `id` | BigAuto | primary key |
| `comment` | ForeignKey | → `comments.Comment` |
| `body` | JSON |  |
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

### Permissions

Reading needs a task the caller can open. Writing a comment, replying and reacting need **`comment.create`** (Owner, Admin and Member hold it; a Viewer reads only) and a project that is not archived. **`comment.moderate`** (Owner, Admin) deletes anyone's comment; pinning needs it or `task.update`. Editing is the author's alone. Deleting also needs a project that is not archived. Turning a comment into a subtask needs `task.create`.

### Rules

- **Body** (`body.py`): the shared rich-text document, rebuilt from a short list of node types (paragraph, headings, lists, checklists, code, quote, `hard_break`, `mention`) and marks (bold, italic, code, link). Nothing else survives, text is only ever text, a link must be `http`, `https` or `mailto`, at most 50 KB, 8 deep, 20 mentions.
- **Replies** go one level deep and belong to the same task. A comment can be edited for `COMMENT_EDIT_WINDOW_HOURS` (default 24, `DJANGO_COMMENT_EDIT_WINDOW_HOURS`; 0 = no limit), by its author, on its current `version` (`ABORTED` otherwise); each edit keeps the old body as a revision. **Deleting** leaves a "removed" comment (replies keep their place) and drops its content, mentions, reactions and history.
- **Mentions** are `mention` nodes naming a user by id (the label is display only: the server overwrites it with the person's real name). A mentioned person must be an active member who can open the task's project (open: every member; private: its members). Anyone else refuses the comment (`MENTION_NO_ACCESS`, the people in `x-error-users-bin`) unless the author may manage the private project's members (`project.member.manage`, or created it) and sends `grant_access`: they are added to the project first. `Mentionable` is the picker's list (name or email filter, at most 20).
- **Reactions** are set, not toggled (`on`), so a repeated or racing request ends in the same place; one short emoji token, at most 30 different ones per comment. **Pins**: at most 5 per task.
- **`user_mentioned`** (a Django signal, for phase 19's notifications) is sent through `on_commit` once per person per version of a comment: on creation for everyone it mentions, on an edit only for people it newly mentions (one taken out and put back counts again).
- **Live**: `comment_changed` feeds the sync pipeline as `comment.created|updated|deleted` (reactions and pins are updates); the event's `entity_id` is the **task** whose comments changed.

### gRPC

`List(task, before, page_size)` newest page oldest-first with a `cursor` for earlier ones; `Create(body, parent_id, grant_access)`, `Edit(id, expected_version, body, grant_access)`, `Delete`, `React(id, emoji, on)`, `Pin(id, pinned)`, `History(id)` (every body, the current one last), `ToSubtask(id)` (title from the first line, content as description; answers with the task id), `Mentionable(task, query)`.
