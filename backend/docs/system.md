# System

Versions, the update-required check and the device-info setting. Phases 38 and 40.

## Routes

<!-- generated:routes -->
_This app publishes no routes of its own._
<!-- /generated:routes -->

## Models

<!-- generated:models -->
#### `ServerToggle`

| Field | Type | Notes |
| --- | --- | --- |
| `key` | Char | primary key |
| `enabled` | Boolean |  |
| `updated_at` | DateTime |  |
| `updated_by` | ForeignKey | → `accounts.User`, nullable |
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

The system app tells a client which server version it is talking to and whether the client is too old to continue, so an outdated install gets an update screen instead of confusing errors. Platform administrators also read a System page in the admin with the build, the environment and counters, and flip the *Collect device info* toggle that decides whether the `X-Device-Info` header sent at sign-in is read. While it is off the server falls back to the User-Agent for a session's name and stores no fingerprint. The toggle falls back to the `DJANGO_COLLECT_DEVICE_INFO` environment default when nobody has set it.

### Maintenance mode

Set `DJANGO_MAINTENANCE_MODE=true` (default `false`, see `.env.example`) and restart. While it is on, every REST route answers `503` with `{"maintenance": true, "message": ...}` and a `Retry-After` header, and every gRPC call is refused `UNAVAILABLE` with a message starting `maintenance:`, so a client shows its maintenance screen instead of an error. `/api/health*`, `/api/version`, `/metrics`, `/admin` and the `SystemController` gRPC calls stay up. The code is `infrastructure/system/maintenance.py` (a middleware and a gRPC interceptor, both registered in `config/settings/base.py`).
