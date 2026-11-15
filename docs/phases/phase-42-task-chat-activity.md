# Phase 42 — Task chat with change messages

**Status:** Backend done and tested. Flutter done: comments, audit, sync and i18n suites pass on Flutter 3.50, analyze and format clean. The old Activity section is kept collapsed at the bottom of the Chat panel for pre-phase history.

## Feature
Every task's comment stream becomes its **chat**: besides what people write, it shows a system message for each change to the task ("@Sara changed priority to High · 38 min ago"), visible to everyone who can see the task, who can answer in the same stream and `@` anyone.

## Why it exists
Today the discussion (phase 17) and the history of changes (phase 27 "Activity", a collapsed section) are two places, so the reason for a change and the change are never read together. Jira keeps them in separate tabs; ClickUp interleaves them but buries them under noise. One stream, quiet by default.

## How it works (plain words)
Open a task: the stream under it is called **Chat**. When someone changes a tracked field (status, priority, assignee, due date, start date, title, estimate, tags, project move, subtask added) the server adds a **system message** to that task's chat in the same transaction: `{actor, field, from, to}`. The app writes the sentence itself from that data, in the reader's language, with a live relative time ("38 min ago", updated as time passes). The actor is shown as an `@mention` chip. System messages cannot be edited, deleted, reacted to or replied to; people reply with a normal message right below. Several changes by one person to the same field within 5 minutes become one message (priority dragged Low → Medium → High reads "changed priority from Low to High"). Changes made by an automation, a form or an import show that actor's name instead of a person's.

## Scope
**In:** `kind` on comments, system messages for the tracked task fields, coalescing, rendering in the Chat panel, a "Hide changes" toggle (per viewer, remembered), the `task.changed` notification for assignee and watchers.
**Out:** channels, groups and direct messages (43); changing the audit log (27 stays the authoritative, complete record — chat shows a readable subset); attachments in chat (18).

## Data model
- `Comment.kind` (`user` | `system`, default `user`), `Comment.event` jsonb nullable: `{actor_type, actor_id, field, from, to}` (ids and raw values, never display text). `body` stays `{}` for system messages.
- Index `(task, created_at, id)` already exists; system rows use it too.
- Migration backfills nothing: history before this phase stays in Activity.

## API surface
- gRPC: `Comments.List` returns both kinds (`kind`, `event` added to the message; field numbers appended, nothing renumbered). `Create` still makes only `user` messages; no RPC creates or edits a system one.
- Event: `comment.created` is emitted for system messages too, so open chats update live (phase 16).
- Domain: written by a receiver on the same task-change signal the audit log (27) and the inbox (19) use; one source of truth for "what changed".

## Flutter UI
`ActivitySection` is folded into the task's **Chat** panel (shown open by default, newest last, grouped by day, "load earlier"). System messages are a single muted line with an icon, no bubble; user messages are as in phase 17. Composer with `@` picker stays at the bottom. States: skeleton rows, empty ("No messages yet — changes and talk will show up here"), error with retry. The relative time ticks every minute while the panel is visible and shows the exact time on hover/long-press.

## Rules and edge cases
- Workspace scoping and task visibility are the comment rules of phase 17: whoever can see the task sees its system messages; nobody else.
- Archived/closed projects: system messages are still written for the changes that are allowed.
- Redaction: a field the viewer may not see (a restricted custom field, phase 10) is shown as "changed a field", never with its values.
- Coalescing happens only for the same actor, same field, within 5 minutes and only when no user message sits between them.
- A bulk edit of many tasks writes one message per task, not one per field per task beyond the coalescing above.
- System messages do not count toward the "unread comments" badge. The **assignee and watchers** are notified of a change (new inbox kind `task.changed`, inbox only by default, push/email per person in phase 19 preferences); the actor is never notified of their own change, and coalesced changes notify once. Existing `status.changed` / `task.assigned` notifications keep working and are not sent twice for the same change. Replies and `@mentions` written under a change notify as in phase 17.
- Retention: system messages are purged with their task; they are not part of the audit retention (27).

## Acceptance criteria
- [ ] Changing priority, status, assignee, due date and title each adds one system message with the right actor, field, from and to
- [ ] Two priority changes by the same person within 5 minutes make one message (first `from`, last `to`); a user message in between, or a different person, breaks the group
- [ ] System messages cannot be edited, deleted, reacted to or replied to (server refuses, UI hides the actions)
- [ ] A person who cannot see the task never receives its messages (list, live event)
- [ ] A hidden custom field's values never reach the client
- [ ] Sentence is built on the client from `event` in the current language, relative time updates without reload
- [ ] "Hide changes" toggle hides only system messages and is remembered per person
- [ ] A change notifies the assignee and watchers (never the actor), once per coalesced message, and never duplicates `status.changed` / `task.assigned`

## Tests
Receiver per tracked field, coalescing boundaries (5 min, other actor, interleaved message), refusal of edits, tenant isolation on list and live event, redaction of restricted fields, automation/form/import actors, widget tests for the sentence in two languages and the ticking time, a golden for the muted line.

## Depends on
06 Tasks, 16 Realtime sync, 17 Comments, 19 Notifications, 27 Audit log.
