# Phase 03 — Members and Invitations

**Status:** DONE

## Feature
Invite people to a workspace by email or shareable link, and manage the member list.

## Why it exists
Jira charges per seat and ClickUp limits guests; both make onboarding people harder than it should be. Here, invitations are free and unlimited, and the member list is a simple, honest table.

## How it works (plain words)
Any active member enters one or more emails (or generates a link with an expiry and max uses). Each invite has a token. The invitee opens the link, signs in or registers, and clicks **Join** — they become a member. Members can see pending invites, resend and revoke them; only the owner removes members. A member can leave. The owner (`created_by` until phase 04) can neither leave nor be removed.

## Scope
**In:** email invite, invite link, accept/decline, pending list, resend/revoke, remove member, leave workspace, member profile card.
**Out:** what members are allowed to do (phase 04; everyone is "member" with full access here, except that only the owner removes), guests/forms (33), Windows/Linux/iOS scheme registration and HTTPS app links (assetlinks/AASA), web hosting of `/invite/*` (phase 38).

## Data model
- `WorkspaceMember` gains `status (active|removed)`, `invited_by`, `removed_at`
- `Invitation(id, workspace, email nullable, token_hash, created_by, expires_at, max_uses, uses, revoked_at, accepted_at)`

## API surface
- gRPC `MemberController`: `List`, `Remove`, `Leave`
- gRPC `InvitationController`: `Create`, `CreateLink`, `List`, `Revoke`, `Resend`, `Accept`, `Decline`
- REST: `POST /api/v1/invites/preview` (public) and `POST /api/v1/invites/accept` (authenticated), body `{token}` (tokens never in URL paths, so they stay out of access logs)
- Email is signal-driven and async: `invitation_issued` is sent on commit; a receiver queues the job on a small in-process thread pool that calls the starter's `send_email` (3 attempts, backoff; failures logged by id only, invite stays resendable). `undelivered_emails` stays in the proto but is always empty. No durability across restarts; upgrade path is the phase 19/24 worker (no Celery yet).
- Tokens: email-bound invites never return the token to the caller (only emailed); link invites return it from `CreateLink` only.
- `list_pending` is SQL-filtered, capped at 200, and hides revoked/used-up invites and invites expired more than 30 days ago.

## Flutter UI
Members screen (search, avatar, joined date) with a Pending tab and a profile card sheet; "Invite" dialog (email chips + link tab with expiry and max uses, copy); deep link `/invite/:token`. Web uses the path URL strategy; the production Caddy serves `index.html` for `/invite/*` (`try_files`, checked by `deploy/scripts/check-web.sh`). `app_links` routes `taskforge://invite/<token>` on macOS and Android; the scheme is also registered in the iOS plist. Windows registers `taskforge://` for the current user at start-up and forwards a link to the running instance (`SendAppLinkToInstance`); Linux is single-instance and ships `linux/taskforge.desktop` (`MimeType=x-scheme-handler/taskforge`; copy it to `~/.local/share/applications/` and run `xdg-mime default`); iOS has the scheme in `Info.plist`. HTTPS app links: Caddy serves `/.well-known/assetlinks.json` and `/.well-known/apple-app-site-association` from env vars, Android has an `autoVerify` filter for `https://<domain>/invite/`, and `ios/Runner/Runner.entitlements` (Profile and Release only) holds the associated domain. Replace `tasks.example.com` in the manifest and the entitlements with your domain. Not verified (needs a real device or domain): Windows and Linux link handling, Android verification, iOS universal links; the Caddy file is checked statically, `caddy validate` runs only when Docker is up.

## Rules and edge cases
- Token stored hashed; compared in constant time.
- Accepting twice is idempotent; expired/revoked shows a clear message.
- Email invite is bound to that email: other accounts can't use it. A matching but unverified primary email may accept (token possession + match is the proof).
- Re-inviting a removed member re-activates the old row, not a duplicate.
- An invitation created at or before a member's removal cannot re-admit them (`INVITE_BEFORE_REMOVAL`); removing a member revokes their pending invitations.
- Rate limit invite creation per workspace.

## Acceptance criteria
- [x] Invite by email and by link both end with a member visible in the list
- [x] Revoked/expired tokens refused
- [x] Last owner protection enforced (creator can neither leave nor be removed)
- [x] Deep link opens the correct invite on web and one native platform — web checked in a real browser (signed-out redirect with `from`, return after sign-in, reload, dead-link message); macOS checked by launching `taskforge://invite/<token>` warm and cold and seeing it routed to `/invite/<token>`. Android, iOS, Windows and Linux were not run

## Tests
Token lifecycle, double accept, bound-email check, last-owner rule, removal/re-invite ordering, signal-after-commit email (rollback sends none, retry, no token in logs), deep-link routing test.

## Depends on
Phases 01, 02.
