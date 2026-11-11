# Phase 17 — Comments and Mentions

**Status:** DONE

## Feature
Threaded **comments** on tasks with rich text, `@mentions`, reactions and edit/delete history.

## Why it exists
Discussion belongs next to the work. Jira comments are plain and lack threads/reactions; ClickUp comments are good but notifications from them are noisy. Ours produce precise, controllable notifications.

## How it works (plain words)
Under each task is a comment stream. Typing `@` opens a user picker (members with access to that task only). A comment can have one level of replies (thread). Emoji reactions replace “+1” comments. Authors can edit (an “edited” mark and history are kept) or delete (soft-delete showing “comment removed”). Comments are rendered with the same rich-text format as descriptions. A comment can be turned into a new subtask with one click.

## Scope
**In:** create/edit/delete, replies (1 level), mentions, reactions, edit history, pin comment, comment→subtask, permission-aware mention picker.
**Out:** notification delivery (19 — this phase emits `mention` events only), attachments inside comments (18).

## Data model
- `Comment(id, task, author, parent nullable, body jsonb, created_at, edited_at, deleted_at, pinned)`
- `CommentRevision(comment, body, at)`
- `CommentMention(comment, user)`
- `CommentReaction(comment, user, emoji)` unique per triple.

## API surface
- gRPC: `Comments.List(task, cursor)`, `Create`, `Edit`, `Delete`, `React`, `Pin`, `ToSubtask`
- Event: `comment.created|updated|deleted`; domain event `user.mentioned` for phase 19.

## Flutter UI
Composer with mention autocomplete and formatting toolbar (desktop shortcuts: Cmd/Ctrl+Enter to send), grouped by day, reactions bar, "edited" tooltip showing history, skeletons and optimistic send with “sending/failed/retry”.

## Rules and edge cases
- Mentioning someone without access to the task: offer to **add them as watcher/grant access** (admin only) or block.
- Only author or admin can delete; edits allowed 24 h (setting).
- Body sanitized (no raw HTML); links get `rel=noopener`.
- Large threads paginated, newest-last with “load earlier”.

## Acceptance criteria
- [x] Mention picker lists only users who can see the task (the server decides; tested there)
- [x] Edit history stored and viewable
- [x] Optimistic send with retry on failure
- [x] `user.mentioned` event emitted exactly once per mentioned user per comment version (the author is never told about mentioning themselves)

## Tests
Mention parsing, permission filtering, sanitization, revision creation, reaction toggling concurrency.

## Depends on
Phase 06 (events used by 16 and 19).

## As built
- **Backend**: a `comments` app (`Comment`, `CommentRevision`, `CommentMention`, `CommentReaction`), `CommentController` over gRPC with two extra RPCs, `History` and `Mentionable` (the picker's list). New permissions `comment.create` (Owner, Admin, Member) and `comment.moderate` (Owner, Admin: delete anyone's comment, pin). Reference: `backend/docs/comments.md`.
- **Body**: rebuilt from an allow-list on every write; links are http, https or mailto. A mention's label is always replaced by the person's real name on the server, so what is shown matches who was notified.
- **Rules as built**: edits are the author's alone (24 h, `COMMENT_EDIT_WINDOW_HOURS`); deleting, like every other write, needs a project that is not archived; at most 5 pinned comments and 30 different reactions per comment (counted under a lock on the task); the grant offered for a mention of someone outside a private project goes through the same function as adding a project member, so the member list updates live.
- **Flutter**: the composer has a small formatting toolbar (bullet, quote, code block, link; the text stays lightly marked up as in descriptions) and Ctrl/Cmd+Enter. Links are shown underlined but are not tappable yet, so there is no `rel=noopener` to set; add it when they become tappable. Loading shows skeleton rows. There is no bold/italic button: the shared description format has no marker for them yet.
- Not verified: a real browser, PostgreSQL (the pin and reaction limit locks only matter there), a real network.
