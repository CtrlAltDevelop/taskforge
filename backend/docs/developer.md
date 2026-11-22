# API tokens and webhooks

Personal access tokens for the public REST API and signed outbound webhooks. Phase 32.

## Routes

<!-- generated:routes -->
| Method | Path | Auth | Purpose |
| --- | --- | --- | --- |
| `GET` | `/api/v1/webhooks` | Bearer | List webhooks |
| `POST` | `/api/v1/webhooks` | Bearer | Create a webhook |
| `DELETE` | `/api/v1/webhooks/{webhook_id}` | Bearer | Delete |
| `PATCH` | `/api/v1/webhooks/{webhook_id}` | Bearer | Change a webhook |
| `GET` | `/api/v1/webhooks/{webhook_id}/deliveries` | Bearer | Delivery log |
| `POST` | `/api/v1/webhooks/{webhook_id}/deliveries/{delivery_id}/redeliver` | Bearer | Send a delivery again |
| `POST` | `/api/v1/webhooks/{webhook_id}/test` | Bearer | Send a test ping now |
<!-- /generated:routes -->

## Models

<!-- generated:models -->
#### `ApiToken`

An access token for one workspace: a person's own, or (``owner`` is its user) a service

| Field | Type | Notes |
| --- | --- | --- |
| `id` | UUID | primary key, not editable |
| `workspace` | ForeignKey | → `workspaces.Workspace` |
| `owner` | ForeignKey | → `accounts.User` |
| `name` | Char |  |
| `prefix` | Char | unique |
| `hash` | Char |  |
| `scopes` | JSON |  |
| `expires_at` | DateTime | nullable |
| `last_used_at` | DateTime | nullable |
| `revoked_at` | DateTime | nullable |
| `created_at` | DateTime |  |

#### `ServiceAccount`

An identity that belongs to a workspace, not to a person, for scripts and integrations.

| Field | Type | Notes |
| --- | --- | --- |
| `id` | UUID | primary key, not editable |
| `workspace` | ForeignKey | → `workspaces.Workspace` |
| `user` | OneToOne | unique, → `accounts.User` |
| `name` | Char |  |
| `created_by` | ForeignKey | → `accounts.User`, nullable |
| `created_at` | DateTime |  |
| `deleted_at` | DateTime | nullable |

#### `Webhook`

A URL that is sent a signed POST for each subscribed event. ``project`` narrows it to one

| Field | Type | Notes |
| --- | --- | --- |
| `id` | UUID | primary key, not editable |
| `workspace` | ForeignKey | → `workspaces.Workspace` |
| `project` | ForeignKey | → `projects.Project`, nullable |
| `created_by` | ForeignKey | → `accounts.User`, nullable |
| `name` | Char |  |
| `url` | Char |  |
| `secret` | Char |  |
| `events` | JSON |  |
| `active` | Boolean |  |
| `disabled_reason` | Char |  |
| `version` | PositiveInteger |  |
| `created_at` | DateTime |  |

#### `WebhookDelivery`

One event for one webhook and its attempts. ``event_id`` is the same on every retry and

| Field | Type | Notes |
| --- | --- | --- |
| `id` | UUID | primary key, not editable |
| `webhook` | ForeignKey | → `developer.Webhook` |
| `workspace` | ForeignKey | → `workspaces.Workspace` |
| `event` | Char |  |
| `event_id` | Char |  |
| `payload` | JSON |  |
| `status` | Char |  |
| `status_code` | PositiveSmallInteger | nullable |
| `response_snippet` | Char |  |
| `error` | Char |  |
| `request_headers` | JSON |  |
| `attempt` | PositiveSmallInteger |  |
| `next_retry_at` | DateTime | nullable |
| `resend_of` | ForeignKey | → `developer.WebhookDelivery`, nullable |
| `created_at` | DateTime |  |
| `at` | DateTime | nullable |
| `duration_ms` | PositiveInteger |  |
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

Tokens look like `tf_<prefix>_<secret>`. Only the prefix and a SHA-256 digest are stored, the secret is shown once when the token is made. A token holds its owner's permissions narrowed by its scopes, is limited per minute (`DJANGO_DEVELOPER_TOKEN_RATE_PER_MINUTE`), and can never manage tokens or webhooks. Webhooks are POSTed a body signed with HMAC-SHA256 over `<timestamp>.<body>` in the `X-TaskForge-Signature` header. Targets are checked against private, loopback and link-local addresses at save time and again when connecting, so a name that changes its answer cannot reach the internal network; a self-hoster may list hosts or networks in `DJANGO_DEVELOPER_WEBHOOK_ALLOWLIST`. Failed deliveries are retried after 1 minute, doubling up to 6 hours, for 24 hours, and a webhook that keeps failing is switched off with a reason.
