# Notifications (inbox)

The inbox, watchers, per-person preferences, quiet hours, push and email (instant or daily digest). Always installed. gRPC (`InboxController`, `WatcherController`, `PrefController`, `DeviceController`) plus one public REST route, the unsubscribe link. Phase 19. It does not use the starter's `apps.notifications` tables (no workspace, task or per-person choices); it reuses its broker and the phase-16 sync socket for live updates.

## Routes

<!-- generated:routes -->
| Method | Path | Auth | Purpose |
| --- | --- | --- | --- |
| `GET` | `/api/v1/inbox/unsubscribe` | None | Confirm turning off a kind of email |
| `POST` | `/api/v1/inbox/unsubscribe` | None | Turn off a kind of email with the link in it |
<!-- /generated:routes -->

## Models

<!-- generated:models -->
#### `Delivery`

A push or email owed for a notification. ``due_at`` is now, the end of quiet hours, or the

| Field | Type | Notes |
| --- | --- | --- |
| `id` | UUID | primary key, not editable |
| `notification` | ForeignKey | → `inbox.Notification` |
| `channel` | Char |  |
| `status` | Char |  |
| `due_at` | DateTime |  |
| `sent_at` | DateTime | nullable |
| `claimed_at` | DateTime | nullable |
| `attempts` | PositiveSmallInteger |  |

#### `InboxSettings`

When a person may be disturbed: a time zone, quiet hours (push and email wait for them to

| Field | Type | Notes |
| --- | --- | --- |
| `id` | BigAuto | primary key |
| `user` | OneToOne | unique, → `accounts.User` |
| `timezone` | Char |  |
| `quiet_start` | Time | nullable |
| `quiet_end` | Time | nullable |
| `digest_hour` | PositiveSmallInteger |  |

#### `Notification`

One thing that happened that ``user`` should know about. ``dedupe_key`` makes the same event

| Field | Type | Notes |
| --- | --- | --- |
| `id` | UUID | primary key, not editable |
| `user` | ForeignKey | → `accounts.User` |
| `workspace` | ForeignKey | → `workspaces.Workspace` |
| `type` | Char |  |
| `task` | ForeignKey | → `tasks.Task`, nullable |
| `project_id` | UUID | nullable |
| `actor` | ForeignKey | → `accounts.User`, nullable |
| `payload` | JSON |  |
| `dedupe_key` | Char |  |
| `last_key` | Char |  |
| `count` | PositiveInteger |  |
| `in_inbox` | Boolean |  |
| `created_at` | DateTime |  |
| `updated_at` | DateTime |  |
| `read_at` | DateTime | nullable |
| `snoozed_until` | DateTime | nullable |
| `archived_at` | DateTime | nullable |

#### `NotificationPref`

One person's choice of channels for one kind of event (across every workspace).

| Field | Type | Notes |
| --- | --- | --- |
| `id` | BigAuto | primary key |
| `user` | ForeignKey | → `accounts.User` |
| `event_type` | Char |  |
| `inbox` | Boolean |  |
| `push` | Boolean |  |
| `email_mode` | Char |  |

#### `PushDevice`

A phone, browser or computer that can be pushed to (``token`` is its provider token).

| Field | Type | Notes |
| --- | --- | --- |
| `id` | BigAuto | primary key |
| `user` | ForeignKey | → `accounts.User` |
| `platform` | Char |  |
| `token` | Char | unique |
| `created_at` | DateTime |  |
| `last_seen_at` | DateTime |  |

#### `Watcher`

Somebody who hears about a task's changes.

| Field | Type | Notes |
| --- | --- | --- |
| `id` | BigAuto | primary key |
| `task` | ForeignKey | → `tasks.Task` |
| `user` | ForeignKey | → `accounts.User` |
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

### From an event to a notification

Other apps announce what happened (`tasks.signals.task_activity`: created, assigned, status changed; `comments.signals`: mentioned, comment created); `receivers.py` turns each into `notify.notify(kind, recipients, …)`, which for each candidate:

1. leaves out the actor (never told about their own action) and anyone who is not an active member who can open the project, so access lost is never notified;
2. looks up their choice for that kind (`prefs.effective`, quiet defaults in `kinds.py`) and stops if every channel is off;
3. is idempotent: `dedupe_key` (event id + person) is unique, so the same event twice is one notification;
4. folds a burst: an unread notification of the same kind on the same task made in the last `INBOX_COALESCE_SECONDS` (60) takes the new event as `count + 1` (the first `from`, the latest `to`; nobody is pushed again) instead of a new row;
5. plans a push and/or an email (`delivery.plan`): due now, after the person's quiet hours (their time zone), or at their next digest hour;
6. tells their open apps: `notification.new` / `notification.changed` on the `user:<id>` room (and catch-up), carrying only "it is you"; clients read the list again. Marking read, snoozing or archiving on one device announces `changed` so the others update their badge.

Kinds: `task.assigned`, `user.mentioned`, `comment.added` (watchers), `status.changed` (watchers), `task.due_soon`. The creator, assignees and commenters watch a task automatically; `WatcherController` switches it.

### Delivery

`deliver_due` sends what is due: a push to each device (`INBOX_PUSH_PROVIDER`: `LoggingPush` by default, `FcmPush` for Firebase Cloud Messaging with `INBOX_FCM_PROJECT_ID` and `INBOX_FCM_CREDENTIALS_FILE`; a dead token is forgotten), an email through the auth app's email backend with a signed unsubscribe link, or one digest email per person grouped by project. It re-checks, just before sending, that the person still has access and has not already read it. A failure is retried up to three times five minutes apart. There is no job queue yet: a notification triggers delivery on a small background pool (in-thread with `INBOX_SYNC_DELIVERY=1`), and `manage.py inbox_tick` (**run it every minute from cron**, `make tick`) sends what was held, wakes snoozed notifications, scans for tasks due within `INBOX_DUE_SOON_DAYS` (UTC dates) and retries.

### Settings

`DJANGO_INBOX_PUSH_PROVIDER`, `DJANGO_INBOX_FCM_PROJECT_ID`, `DJANGO_INBOX_FCM_CREDENTIALS_FILE`, `DJANGO_INBOX_COALESCE_SECONDS` (60), `DJANGO_INBOX_SYNC_DELIVERY`, `DJANGO_INBOX_UNSUBSCRIBE_URL` (set it to the public address of `/api/v1/inbox/unsubscribe?token={token}`), `DJANGO_INBOX_DUE_SOON_DAYS` (1). FCM needs `backend[oauth]` (httpx) and PyJWT.

### Permissions and privacy

Everything is the caller's own: the inbox, preferences and devices are scoped to the signed-in person (a stranger to the workspace is 403), a notification for a task the person can no longer open is neither listed nor counted. `/inbox/unsubscribe?token=` is public: the token (signed, valid `INBOX_UNSUBSCRIBE_DAYS`, 180) is the capability. A **GET only shows a page with a button** (mail scanners fetch every link in an email); the **POST** from the button turns that kind's emails (or all, from a digest) off, and doing it again changes nothing. Production refuses to start with the default localhost `INBOX_UNSUBSCRIBE_URL`.

A push crosses Google's or Apple's servers and shows on a lock screen, so for a task in a **private project** it says only "New activity" and the task key. Emails and pushes are re-checked just before sending: a channel turned off, a notification read, a task trashed or access lost since it was planned all cancel it. A person keeps at most 10 devices (the oldest is forgotten; `inbox_tick` prunes devices unseen for 60 days). Mentions from one person to another are capped at `INBOX_FLOOD_LIMIT` (20) per 10 minutes; assignments and due-soon are never dropped. The digest waits for the end of quiet hours too, is claimed whole per person (never two a day) and shows at most 50 lines.

Known limits: two events at the very same instant can make two notifications instead of one folded (no row lock to take on SQLite; add an advisory lock on PostgreSQL if seen); a workflow status re-mapping by an admin (`workflows._move_tasks`) does not notify anyone; "due soon" uses UTC dates and only looks back 7 days.

### gRPC

`InboxController`: `List(filter, before, page_size)` (`all`, `unread`, `mentions`, `assigned`, `snoozed`, `archived`), `MarkRead(ids | all, read)`, `Snooze(id, until)`, `Archive(ids, archived)`, `UnreadCount(workspace_id | empty for all)`. `WatcherController`: `Get`, `Add`, `Remove`. `PrefController`: `Get`, `Set`, `SetSettings` (time zone, quiet hours, digest hour). `DeviceController`: `Register`, `Unregister`.
