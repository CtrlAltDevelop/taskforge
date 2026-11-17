# Phase 43 — Chat spaces (channels, groups, direct messages)

**Status:** DONE (verified: backend chat suite and Flutter chat suites, analyze and format clean; SQLite and the in-memory broker only, not run against Redis or a live socket; no golden images). See backend/docs/chat.md.

## Feature
A **Chat** area where the team talks outside any one task: every workspace and every project gets a default channel, and members can create more channels, private groups and direct messages, with `@` notifications.

## Why it exists
Teams leave for Slack to say anything that is not about one task, and the link between the talk and the work is lost. ClickUp has Chat but behind a paywall tier and separate from task comments; Jira has none. Ours is part of the product and uses the same mentions, permissions and notifications as everything else.

## How it works (plain words)
A **space** is a place to talk. Kinds: `channel` (open to the workspace or to one project's members, joined freely), `group` (private, invite-only, 2+ people with a name) and `dm` (exactly two people, created on first message). Creating a workspace creates **#general**; creating a project creates **#<project name>** for its members (new members are added, removed members lose access at once). A "New" button in the Chat area offers *Channel* or *Group* (and *Message* for a DM). Task chats (42) stay on the tasks; the Chat area lists them under "Task chats" so everything you can talk in is in one list, searchable. Typing `@` picks a person (only people who can see that space), `@channel` / `@here` notify everyone / everyone online. Messages have replies in a thread, reactions, edit (24 h) and delete, like comments in phase 17.

## Scope
**In:** spaces (channel, group, dm), default workspace and project channels, membership, messages with threads, reactions, edit/delete, mentions, unread counts, mute per space, notifications through the inbox, live delivery, Chat area UI, search of spaces and members.
**Out:** voice/video, file attachments in chat (18 later), message search inside spaces (20 extension), bots/slash commands, external guests, end-to-end encryption, message retention policies.

## Data model
- `ChatSpace(id, workspace, kind, name, project nullable, created_by, archived_at, created_at)`; one default channel per workspace and per project (unique partial constraints).
- `ChatMember(space, user, role owner|member, last_read_at, muted_until nullable, joined_at)` unique `(space, user)`; project channels derive membership from project members and keep rows only for read state.
- `ChatMessage(id, space, workspace, author, parent nullable, body jsonb, created_at, edited_at, deleted_at, version)`; reuses the body sanitizer, mention parser and reactions of `comments` (shared helpers, not copies); index `(space, created_at, id)`.
- `ChatReaction(message, user, emoji)` unique per triple.
- DM uniqueness: a sorted pair key so two people never get two DMs.

## API surface
- gRPC `Chat`: `ListSpaces`, `CreateSpace`, `UpdateSpace` (rename/archive), `Join`, `Leave`, `AddMembers`, `RemoveMember`, `OpenDm`, `ListMessages(space, cursor)`, `Send`, `Edit`, `Delete`, `React`, `MarkRead`, `Mute`, `Mentionable(space)`.
- Event (phase 16 socket): `chat.message.created|updated|deleted`, `chat.space.updated`, `chat.read`.
- Notifications (19): new kinds `chat.mentioned` (push), `chat.dm` (inbox + push), `chat.channel_all` for `@channel`/`@here`; a plain channel message notifies nobody unless the person turned it on for that space.
- Permissions (04): `chat.read`, `chat.post`, `chat.manage` (create channels and groups, archive; Owner, Admin, Member for the first two, Owner and Admin for archive of others'). Guests are excluded.

## Flutter UI
A **Chat** entry in the sidebar (unread badge). Two panes on wide screens (space list: Channels, Groups, Direct messages, Task chats / conversation), one at a time on phones. Composer shared with task chat. Unread divider and "jump to latest". "New channel/group" dialog with name, visibility and members. States: skeleton, empty ("Say hi"), error with retry, offline (queued sends with retry as in phase 30 for task comments).

## Rules and edge cases
- Every query is workspace-scoped and then membership-scoped: a private group or DM is invisible, in lists and live events, to anyone not in it (the #1 risk; tested for every RPC).
- Mentioning someone who cannot see the space offers "add to this group" for group/channel managers, else is refused; `@channel` in a channel over 50 members asks for confirmation.
- Removing someone from a project removes them from its channel in the same transaction; archiving a project archives its channel (read-only, kept).
- DMs and groups survive a member leaving the workspace as read-only history for the others; the member's name is replaced by "Former member" per phase 03.
- Rate limit sends per user per space; body size cap; sanitization identical to comments.
- Deleting a message leaves a "message removed" row so threads keep their place.
- Mute silences pushes but not `@` mentions of you unless "mute completely" is set.

## Acceptance criteria
- [x] New workspace has #general; new project has its channel with exactly its members; adding/removing a project member updates it
- [x] A person outside a private group/DM can neither list it, read it, post to it nor receive its live events
- [x] Create channel, create group, open DM (second `OpenDm` for the same pair returns the same space)
- [x] `@name` notifies exactly that person once per message version; `@channel`/`@here` follow the rules above; the author is never notified of their own message
- [x] Unread count per space is correct across devices after `MarkRead`
- [x] Thread replies, reactions, edit within 24 h, delete leaves a placeholder
- [x] Task chats appear in the same list and open the task's chat from phase 42
- [x] Offline sends queue and retry with idempotent client ids

## Tests
Tenant and membership isolation for every RPC and event, default-space creation and project-membership sync, DM pair uniqueness under concurrency, mention parsing and notification fan-out, unread math, permission matrix, widget tests for the list, composer and unread divider, an integration test for send → live receive on a second client.

## Depends on
03 Members, 04 Roles, 05 Projects, 16 Realtime sync, 17 Comments (shared body/mention helpers), 19 Notifications, 30 Offline, 42 Task chat.
