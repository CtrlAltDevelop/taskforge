# Phase 19 — Notifications

**Status:** DONE

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

## Contract (as built)
New backend app `infrastructure.inbox` (label `inbox`; the starter's `apps.notifications` tables are not used: they have no workspace, task or per-person preferences). gRPC package `config.inbox`; stubs in `app/lib/gen/infrastructure/inbox/grpc/`. Everything is the caller's own.

| Service.RPC | Request | Answer |
|---|---|---|
| `InboxController.List` | `workspace_id`, `filter` (`all` default, `unread`, `mentions`, `assigned`, `snoozed`, `archived`), `before` (cursor), `page_size` | `InboxPage{notifications, cursor, unread_count}`. Newest activity first. Snoozed/archived ones only show under their own filter; one for a task the caller can no longer open never shows |
| `InboxController.MarkRead` | `workspace_id`, `ids[]` or `all`, `read` (false = mark unread) | `UnreadTotal{count}` (what is unread now in that workspace) |
| `InboxController.Snooze` | `workspace_id`, `id`, `until` (ISO 8601 with offset; empty = un-snooze) | the `Notification`. Hidden until `until`, then back in the inbox as unread |
| `InboxController.Archive` | `workspace_id`, `ids[]`, `archived` | `UnreadTotal` |
| `InboxController.UnreadCount` | `workspace_id` (empty = every workspace, for the app icon badge) | `UnreadTotal` |
| `WatcherController.Get/Add/Remove` | `workspace_id`, `project_id`, `task_id` | `WatchState{watching, watcher_count}`. The creator, assignees and commenters watch automatically |
| `PrefController.Get` | | `PrefsAnswer{prefs[], settings}`: one `PrefRow{event_type, label, inbox, push, email_mode}` per kind below, defaults filled in |
| `PrefController.Set` | `event_type`, `inbox`, `push`, `email_mode` (`off`/`instant`/`digest`) | `PrefsAnswer` |
| `PrefController.SetSettings` | `timezone` (IANA), `quiet_start`, `quiet_end` (`HH:MM`, both empty = none), `digest_hour` (0-23) | `PrefsAnswer` |
| `DeviceController.Register/Unregister` | `platform` (`ios`/`android`/`web`/`desktop`), `token` / `token` | `DeviceAnswer{registered}` |

Kinds (`Notification.type`, `PrefRow.event_type`) and their quiet defaults: `task.assigned` (inbox, push), `user.mentioned` (inbox, push), `comment.added` (inbox; watched tasks), `status.changed` (inbox; watched tasks), `task.due_soon` (inbox, push). Email is off until asked. `Notification.payload` is JSON: always `title` and `key` of the task (`WEB-12`); `from`/`to` (status names) for `status.changed`; `comment_id` and `excerpt` for `user.mentioned` and `comment.added`; `due_date` for `task.due_soon`. `count` is how many events were folded into it (ten quick status changes are one notification with count 10 and the first `from`, the last `to`).

Live: `notification.new` and `notification.changed` arrive on the sync socket's `user:<id>` room (always joined) and through catch-up; `entity_id` is the **recipient** (you), `workspace` says which one. They carry no content: read the unread count and the list again. REST: `GET /api/v1/inbox/unsubscribe?token=…` (public) shows a confirmation page; `POST` to the same URL acts (so mail scanners that prefetch links cannot unsubscribe anyone). The signed token in every email turns that kind's emails off.

Built differently from the plan:
- **Clock:** no Celery yet. `manage.py inbox_tick` (`make tick`) does snoozes ending, due-soon, held push/email and retries; run it every minute from cron. Nothing schedules it yet.
- **Delivery:** a `Delivery` row per person and channel is planned, claimed and retried; a digest is claimed whole per person and respects quiet hours; push is re-checked just before sending. A per-person flood limit caps bursts. For private projects push shows the task key only.
- **Workflow status re-mapping** (phase 07 moving tasks) does not notify.
- **Push is backend-only.** `LoggingPush` and `FcmPush` (FCM HTTP v1) exist and the device RPCs work, but the app has no `firebase_messaging`, so no device registers a token yet.
- **App-icon badge:** the unread total of every workspace goes to the icon (`app_badge_plus`; iOS, Android launchers that support it, macOS). Desktop and web notifications (`flutter_local_notifications`) show only while the app is open.
