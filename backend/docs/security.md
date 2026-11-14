# Security: two-factor, trusted devices and single sign-on

Workspace security policy, the person's own two-factor settings and OIDC single sign-on. Phase 37.

## Routes

<!-- generated:routes -->
| Method | Path | Auth | Purpose |
| --- | --- | --- | --- |
| `GET` | `/api/v1/auth/sso/callback` | None | Where the identity provider sends the browser back |
| `POST` | `/api/v1/auth/sso/exchange` | None | Trade a sign-in ticket for credentials |
| `GET` | `/api/v1/auth/sso/{slug}/start` | None | Start signing in through a workspace's identity provider |
<!-- /generated:routes -->

## Models

<!-- generated:models -->
#### `ExternalIdentity`

A person as the identity provider knows them: ``subject`` is the provider's stable id.

| Field | Type | Notes |
| --- | --- | --- |
| `id` | UUID | primary key, not editable |
| `user` | ForeignKey | → `accounts.User` |
| `provider` | ForeignKey | → `security.IdentityProvider` |
| `subject` | Char |  |
| `email` | Char |  |
| `created_at` | DateTime |  |
| `last_login_at` | DateTime | nullable |

#### `IdentityProvider`

The OpenID Connect provider a workspace signs in through (one per workspace).

| Field | Type | Notes |
| --- | --- | --- |
| `id` | UUID | primary key, not editable |
| `workspace` | OneToOne | unique, → `workspaces.Workspace` |
| `kind` | Char |  |
| `name` | Char |  |
| `issuer` | Char |  |
| `client_id` | Char |  |
| `client_secret_encrypted` | Text | not editable |
| `scopes` | Char |  |
| `allowed_domains` | JSON |  |
| `group_claim` | Char |  |
| `group_role_map` | JSON |  |
| `default_role` | ForeignKey | → `workspaces.Role`, nullable |
| `auto_create_users` | Boolean |  |
| `enabled` | Boolean |  |
| `enforce_sso` | Boolean |  |
| `created_at` | DateTime |  |
| `updated_at` | DateTime | not editable |
| `version` | PositiveInteger |  |

#### `SecurityPolicy`

What a workspace requires of its members. One row per workspace, made on first change.

| Field | Type | Notes |
| --- | --- | --- |
| `workspace` | OneToOne | primary key, → `workspaces.Workspace` |
| `require_2fa` | Boolean |  |
| `grace_days` | PositiveSmallInteger |  |
| `enforced_from` | DateTime | nullable |
| `updated_by` | ForeignKey | → `accounts.User`, nullable |
| `updated_at` | DateTime | not editable |
| `version` | PositiveInteger |  |

#### `SsoAttempt`

One sign-in in flight: the state, nonce and PKCE verifier of a single redirect.

| Field | Type | Notes |
| --- | --- | --- |
| `id` | UUID | primary key, not editable |
| `provider` | ForeignKey | → `security.IdentityProvider` |
| `state_hash` | Char | unique, not editable |
| `nonce_hash` | Char | not editable |
| `binding_hash` | Char | not editable |
| `code_verifier_encrypted` | Text | not editable |
| `client_challenge` | Char |  |
| `redirect_uri` | Char |  |
| `return_to` | Char |  |
| `ip_address` | GenericIPAddress | nullable |
| `created_at` | DateTime |  |
| `expires_at` | DateTime |  |
| `consumed_at` | DateTime | nullable |
| `error` | Char |  |

#### `TrustedDevice`

A device that skipped the second factor after one successful check, for a while.

| Field | Type | Notes |
| --- | --- | --- |
| `id` | UUID | primary key, not editable |
| `user` | ForeignKey | → `accounts.User` |
| `token_hash` | Char | unique, not editable |
| `label` | Char |  |
| `ip_address` | GenericIPAddress | nullable |
| `created_at` | DateTime |  |
| `last_used_at` | DateTime | nullable |
| `expires_at` | DateTime |  |
| `revoked_at` | DateTime | nullable |
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

Two-factor builds on the `auth_twofactor` app: enrol an authenticator, confirm with a code, receive ten recovery codes once. Turning it off or replacing the codes asks for a current code or an unused recovery code, and wrong codes lock the account for a while. A trusted device skips the second factor on later password sign-ins until it expires, and a password change, removal of two-factor or sign out everywhere ends all of them. A workspace may require two-factor and single sign-on; single sign-on uses OIDC with PKCE, requires a verified email, may be limited to email domains, never attaches an identity to an existing account by email alone, and maps provider groups to roles. Managing it needs `security.manage`.
