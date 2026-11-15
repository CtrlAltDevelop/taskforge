# Phase 37 — Two-Factor Auth and SSO

**Status:** DONE — see the roadmap entry for what was verified and what could not be run here

## Feature
Stronger sign-in: **TOTP two-factor authentication** with recovery codes, and **single sign-on** via OIDC (and optional SAML).

## Why it exists
SSO and enforced 2FA are classic “enterprise tier” paywalls in Jira and ClickUp. Security shouldn’t cost extra, especially for self-hosted teams that already have an identity provider.

## How it works (plain words)
**2FA:** a user scans a QR code with an authenticator app, confirms a code, and receives ten one-time **recovery codes**. After the password step, login asks for the 6-digit code (or a recovery code). Admins may **require 2FA** for all members after a grace period. **SSO:** an admin configures an OIDC provider (issuer, client id/secret) — Google, Microsoft, Keycloak, Authentik, Okta etc. Users click “Continue with SSO”, authenticate at the provider, and return with a verified identity; the server links it to an existing user by verified email or creates one (if domain allowed). Optional group claims map to roles from phase 04. All of this ends by issuing the **same JWT/refresh tokens** as phase 01.

## Scope
**In:** TOTP enroll/disable, recovery codes, enforce policy, trusted device (30 days, optional), OIDC login with PKCE, domain allowlist, just-in-time user creation, group→role mapping, disable password login for SSO-only workspaces, session revocation on role/identity change. SAML via a maintained library as a stretch step.
**Out:** SCIM provisioning, hardware keys/WebAuthn (good follow-up phase), SMS codes (insecure).

## Data model
- `TotpDevice(user, secret_encrypted, confirmed_at)`; `RecoveryCode(user, hash, used_at)`
- `IdentityProvider(workspace, kind, issuer, client_id, client_secret_encrypted, allowed_domains[], group_role_map jsonb, enforce_sso)`
- `ExternalIdentity(user, provider, subject)`

## API surface
- REST (browser redirects need HTTP): `GET /api/auth/sso/{provider}/start`, `GET /api/auth/sso/callback`
- REST/gRPC: `TwoFactor.Begin/Confirm/Disable/RegenerateCodes`; login returns `mfa_required` challenge token (short-lived).

## Flutter UI
Security settings page (QR, codes download/copy), 2FA prompt screen, “Continue with SSO” button flow using system browser/web redirect (deep link back on mobile/desktop), admin SSO setup page with test button.

## Rules and edge cases
- TOTP secrets and client secrets encrypted at rest (key from env/KMS); codes accepted once per time-step, ±1 window; brute-force lockouts.
- Linking SSO to an existing account requires **verified** email from the provider to prevent takeover.
- OIDC: validate `iss`, `aud`, `nonce`, signature via JWKS; use state + PKCE.
- Locked-out admin recovery path documented (CLI command).

## Acceptance criteria
- [x] Enroll 2FA, log in with code and with a recovery code (single use)
- [x] Enforced policy blocks access until enrolled
- [x] Login via a local Keycloak test instance works on web and one native platform (live test `test_keycloak_live.py` runs the whole flow against the dev realm with the native return address; the web return address takes the same server path)
- [x] Forged/unverified-email SSO attempt is refused

## Known starter bug to fix first
On PostgreSQL, a social profile value longer than the column (`varchar(150)`) returns 500 instead of being clipped (`test_oversized_profile_values_are_clipped_to_their_columns`, deselected in `make test-postgres`). SQLite never enforces lengths, so it only shows on Postgres. Fix and re-enable the test before enabling any `oauth_*` provider.

## Tests
TOTP time-step tests, replay rejection, OIDC validation matrix, takeover attempt, policy enforcement.

## Depends on
Phases 01, 04.

## Implementation notes

**Recovery.** A locked-out person (lost authenticator and recovery codes) is recovered by an operator on the server: `python manage.py disable2fa <username-or-email>`. It removes their authenticator and recovery codes, forgets their trusted devices and ends every session; there is deliberately no API for it.

**Trusted devices** end on every password change or reset, on 2FA removal and when an unverified account is linked to an identity.

**OIDC safety.** Issuer, discovery and JWKS addresses must be https and public: private, loopback, link-local (cloud metadata) and reserved addresses are refused, including names that resolve to them. Plain http is accepted only for `localhost` while `DEBUG` is on (the Keycloak dev flow). Discovery and JWKS are fetched with a timeout, no redirects and a 256 KiB cap; ID tokens are verified against that JWKS with asymmetric algorithms only.

**Accepted deviations**
- OIDC only; SAML is skipped.
- The SSO entry key is the workspace slug, with one identity provider per workspace.
- A single-sign-on login skips the local second factor (the identity provider's multi-factor stands in).
- Verified against a real Keycloak: `deploy/keycloak/taskforge-realm.json` and the `keycloak` service (profile `sso`, port 8082). Run `docker compose -f deploy/docker-compose.yml --profile sso up -d keycloak`, then `TASKFORGE_LIVE_KEYCLOAK=http://localhost:8082/realms/taskforge pytest -k keycloak_live` from `backend/`. The test is skipped without that variable.
