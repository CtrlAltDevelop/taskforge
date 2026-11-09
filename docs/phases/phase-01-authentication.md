# Phase 01 — Authentication

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
- REST (Ninja): `POST /api/auth/register`, `/login`, `/refresh`, `/logout`, `GET /api/auth/me`, `POST /api/auth/password`, `GET/DELETE /api/auth/sessions`
- gRPC: `Auth.Me`, `Auth.ListSessions` (token in metadata `authorization`)
- WS: connect, first message `{type:"auth", token}`; server closes with 4401 if invalid/expired.

## Flutter UI
Sign-in and sign-up screens (validation inline, show/hide password), "Sessions" list in profile, auto-redirect via router guard. Handles: wrong password, rate limited, offline, expired session → login with return-to path.

## Rules and edge cases
- Login error never reveals whether the email exists.
- Rate limit: 5 failed logins / 15 min per email+IP.
- Min password 10 chars; reject top common passwords.
- Concurrent refresh calls from two tabs: server tolerates a 10 s grace window for the just-rotated token.
- Token never in URL or logs.

## Acceptance criteria
- [ ] Register → login → call `Me` over REST, gRPC and WS
- [ ] Expired access token silently refreshes on all three transports
- [ ] Reused refresh token revokes the family
- [ ] Logout on one device doesn't affect others; "revoke all" works
- [ ] Rate limiting verified

## Tests
Hashing, token expiry/rotation/reuse, rate limit, interceptor for gRPC, WS auth handshake, Flutter auth controller + guard tests.

## Depends on
Phase 00.
