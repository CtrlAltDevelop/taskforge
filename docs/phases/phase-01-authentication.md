# Phase 01 — Authentication

**Status:** TODO

## Feature
Email + password sign-up, sign-in, sign-out, and session refresh that works identically on REST, gRPC and WebSocket.

## Why it exists
Everything after this needs to know "who is calling". Done badly it causes the classic bugs: users logged out randomly, tokens leaking in URLs, mobile and web sessions fighting.

## How it works (plain words)
A user registers with email + password. The server stores only a strong hash (Argon2). Sign-in returns two tokens: a **access token** (JWT, 15 min) used on every call, and a **refresh token** (random, 30 days, stored hashed in DB) used only to get a new access token. Each refresh issues a *new* refresh token and invalidates the old one (rotation); reusing an old one revokes the whole session family (theft detection). Sign-out revokes the refresh token. The Flutter app keeps tokens in secure storage (Keychain/Keystore; encrypted storage on web) and a Dio/gRPC interceptor refreshes transparently on expiry.

## Scope
**In:** register, login, logout, refresh, "who am I", change password, password rules, rate limiting, device/session list with revoke.
**Out:** email verification flow beyond a simple flag (later), 2FA/SSO (phase 37), password reset by email (included here only if SMTP is configured — otherwise a console email backend in dev).

## Data model
- `User(id uuid, email unique lowercase, password_hash, display_name, avatar, is_active, created_at)`
- `Session(id, user, refresh_hash, family_id, user_agent, ip, created_at, last_used_at, revoked_at)`

## API surface
Provided by the backend starter (rotation token mode + password login), configured here:
- REST (Ninja): `POST /api/v1/auth/password/signup`, `/login`, `/logout`, `/change`; `POST /api/v1/auth/token/refresh`; `GET /api/v1/auth/token/sessions`; `DELETE /api/v1/auth/token/sessions/{id}`; `GET /api/v1/users/me`. The account's login name is its email (sent as both `identifier` and `email`).
- gRPC: `config.accounts.AccountController/Me`, `config.oauth_rotation.RotationTokenRpcController/Sessions` (token in `authorization` metadata).
- WebSocket: the notifications socket's `authenticate` / `whoami` commands (a bad token is an error frame, not a close; the phase 00 `/ws/ping/` stays credential-free).
- New in this phase: refresh **grace window** (`DJANGO_AUTH_REFRESH_REUSE_GRACE_SECONDS`, default 10): a token spent moments ago answers `409 REFRESH_RACE` and keeps the session; a replay after the window is theft (`401 TOKEN_REUSED`, whole session ended).
- Policy: access token 15 min, refresh 30 days, password minimum 10 (+ Django's common/numeric/similarity validators), 5 failed logins per email+IP per 15 minutes (20 per account).

## Flutter UI
Sign-in and sign-up screens (validation inline, show/hide password), home screen showing the account (gRPC `Me`), "Sessions" screen (gRPC list, revoke another device over REST), go_router guard with a `?from=` return path. Handles: wrong password, rate limited, offline, expired session → login with return-to path.

## Rules and edge cases
- Login error never reveals whether the email exists.
- Rate limit: only **failed** sign-ins count: 5 per email+IP pair lock that pair for 15 minutes, so a stranger cannot lock the owner out; a 20-failure ceiling per account stops guessing spread over many addresses.
- Min password 10 chars; reject top common passwords.
- Concurrent refresh calls from two tabs: server tolerates a 10 s grace window for the just-rotated token.
- Token never in a URL or log: the app sends tokens only in headers and JSON bodies. (The starter's notifications socket also accepts `?token=` for browsers; the app must not use it.)

## Acceptance criteria
- [x] Register → login → call `Me` over gRPC in the app (REST `users/me` and the WebSocket `whoami` are backend-only, covered by starter and `test_ws_identity.py` tests)
- [x] An expired access token — or one the server rejects (session revoked elsewhere, wrong device clock) — is refreshed silently and the call retried (REST and gRPC; WebSocket reconnect-with-token arrives with phase 16)
- [x] Reused refresh token revokes the family (after the grace window)
- [x] Logout on one device doesn't affect others; "Sign out other devices" revokes every other session
- [x] Rate limiting verified

## Tests
Hashing, token expiry/rotation/reuse, rate limit, interceptor for gRPC, WS auth handshake, Flutter auth controller + guard tests.

## Notes from implementation
- **PostgreSQL is required for correctness.** On SQLite two simultaneous refreshes crash with `database is locked` because `select_for_update` is a no-op there. Dev now defaults to Postgres (`make dev`); `make test-postgres` runs the concurrency test (`test_concurrent_refresh.py`) and CI has a Postgres job. Plain `make test` stays on SQLite for speed.
- Refresh is **single-flight** in the app (`AuthSession`): any number of callers share one refresh; a 409 race adopts the tokens another window stored; a network error never signs the user out.
- **Update (round 2):** the following are now built — failure-only login limiting per (email, IP) with an account-wide ceiling of 20; idempotent refresh (`request_id`, `AUTH_REFRESH_RECOVERY_SECONDS`, 900 s) which recovers a lost refresh response; an HttpOnly `tf_refresh` cookie for web (`X-Refresh-Transport: cookie`, middleware `refresh_cookie.py`, access token held in memory only); change-password and forgot/reset-password screens; Sessions/Debug use `go` with a back button so the return path survives expiry. Dev email prints to the console. The earlier "Lost-response", "Web token storage" and rate-limit caveats above are superseded by these.
- **Still not built:** a WebSocket client in the app (phase 16); the OAuth/Postgres starter bug (phase 37). Recovery via `request_id` is REST-only (the gRPC `Refresh` ignores it). `client_ip` trusts `X-Forwarded-For`, so a forged header can dodge the per-pair limit (the account ceiling still holds).
- Token storage is one entry (`auth.tokens`) so a crash cannot leave a new access token beside a spent refresh token; the sign-in screen only requires a non-empty password (older accounts may predate the 10-character rule).
- `AuthSession` is a plain `ChangeNotifier`, not a freezed/Riverpod state class (AGENTS rule 8): it owns identity, I/O and a sign-out fence, and go_router needs a `Listenable`. Its snapshots (`AuthTokens`, `Account`, `SessionInfo`) are immutable.
- A sign-out (or sign-in as someone else) while a refresh is in flight discards that refresh's result, so tokens can never be resurrected.
- Sessions reached by an in-app `push` do not remember `from` after expiry (go_router redirects from the underlying page); a deep link or reload of `/sessions` does.
- The phase 00 `/debug` connectivity screen is now behind sign-in and reachable from Home.
- Starter quirk: gRPC `Sessions` does not flag the current session (`current` is false); the sessions screen therefore falls back to the stored session id.

## Depends on
Phase 00.
