# Phase 19 — Notifications

**Status:** TODO

## Feature
A notification system with **in-app inbox, push, and email**, controlled by per-event preferences, quiet hours and digests.

## Why it exists
Notification spam (or missing ones) is the most common complaint about both tools. Users must be able to say precisely what they want, where, and when.

## How it works (plain words)
Services emit domain events (`task.assigned`, `user.mentioned`, `task.due_soon`, `status.changed` on watched tasks…). A notifier turns events into **notifications** for the right recipients (assignee, mentioned, watchers), de-duplicating bursts (ten edits in a minute become one). Each user chooses, per event type, which channels are on: inbox, push, email — with defaults that are quiet. Email can be real-time or a daily digest. Quiet hours hold push/email until morning. The inbox shows unread/read/snoozed items; clicking opens the task and marks read. New items also arrive live over WebSocket.

## Scope
**In:** watch/unwatch tasks, inbox (read/unread/snooze/archive/mark all), preference matrix, quiet hours, email digest, push (FCM for mobile/web; native desktop notifications), de-dup and batching.
**Out:** SMS, Slack/Teams (webhooks in 32 can do it).

## Data model
- `Notification(id, user, workspace, type, task nullable, actor, payload, created_at, read_at, snoozed_until, archived_at)`
- `NotificationPref(user, event_type, inbox, push, email_mode)`
- `Watcher(task, user)`; `PushDevice(user, platform, token)`

## API surface
- gRPC: `Notifications.List/MarkRead/Snooze/Archive`, `Prefs.Get/Set`, `Watchers.Add/Remove`, `Devices.Register`
- WS: `notification.new` to `user:<id>` room
- Celery: batch/digest/send tasks

## Flutter UI
Inbox page with filters (Unread, Mentions, Assigned), badge counts on sidebar/app icon, preferences matrix screen, permission prompts for push with a clear explanation.

## Rules and edge cases
- Never notify the actor about their own action.
- Do not notify users who lost access to the item.
- Idempotent: the same event can't create two notifications (dedupe key).
- Unsubscribe link in every email; digests list grouped by project.

## Acceptance criteria
- [ ] Assign → assignee gets inbox + (if enabled) push within 5 s
- [ ] Ten rapid edits produce one notification
- [ ] Quiet hours respected; digest arrives once per day
- [ ] Unread count live-updates across devices

## Tests
Dedupe, preference resolution, quiet-hour scheduler (time zones), access-loss filter, push provider fake.

## Depends on
Phases 16, 17.
