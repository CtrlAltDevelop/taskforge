# Phase 37 — Two-Factor Auth and SSO

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
- [ ] Enroll 2FA, log in with code and with a recovery code (single use)
- [ ] Enforced policy blocks access until enrolled
- [ ] Login via a local Keycloak test instance works on web and one native platform
- [ ] Forged/unverified-email SSO attempt is refused

## Known starter bug to fix first
On PostgreSQL, a social profile value longer than the column (`varchar(150)`) returns 500 instead of being clipped (`test_oversized_profile_values_are_clipped_to_their_columns`, deselected in `make test-postgres`). SQLite never enforces lengths, so it only shows on Postgres. Fix and re-enable the test before enabling any `oauth_*` provider.

## Tests
TOTP time-step tests, replay rejection, OIDC validation matrix, takeover attempt, policy enforcement.

## Depends on
Phases 01, 04.
