# Phase 03 — Members and Invitations

## Feature
Invite people to a workspace by email or shareable link, and manage the member list.

## Why it exists
Jira charges per seat and ClickUp limits guests; both make onboarding people harder than it should be. Here, invitations are free and unlimited, and the member list is a simple, honest table.

## How it works (plain words)
An admin enters one or more emails (or generates a link with an expiry and max uses). Each invite has a token. The invitee opens the link, signs in or registers, and clicks **Join** — they become a member. Admins can see pending invites, resend, revoke, and remove members. A member can leave. The last owner cannot leave or be removed.

## Scope
**In:** email invite, invite link, accept/decline, pending list, resend/revoke, remove member, leave workspace, member profile card.
**Out:** what members are allowed to do (phase 04; everyone is "member" with full access here), guests/forms (33).

## Data model
- `WorkspaceMember` gains `status (active|removed)`, `invited_by`
- `Invitation(id, workspace, email nullable, token_hash, created_by, expires_at, max_uses, uses, revoked_at, accepted_at)`

## API surface
- gRPC: `Members.List`, `Remove`, `Leave`; `Invitations.Create`, `List`, `Revoke`, `Resend`
- REST: `GET /api/invites/{token}` (preview, public), `POST /api/invites/{token}/accept`
- Email via Celery task (console backend in dev).

## Flutter UI
Members screen (search, avatar, joined date), "Invite" dialog (emails chips + link tab with copy), Pending tab, deep link `/invite/<token>` working on web, mobile (app links) and desktop (custom scheme).

## Rules and edge cases
- Token stored hashed; compared in constant time.
- Accepting twice is idempotent; expired/revoked shows a clear message.
- Email invite is bound to that email: other accounts can't use it.
- Re-inviting a removed member re-activates the old row, not a duplicate.
- Rate limit invite creation per workspace.

## Acceptance criteria
- [ ] Invite by email and by link both end with a member visible in the list
- [ ] Revoked/expired tokens refused
- [ ] Last owner protection enforced
- [ ] Deep link opens the correct invite on web and one native platform

## Tests
Token lifecycle, double accept, bound-email check, last-owner rule, email task, deep-link routing test.

## Depends on
Phases 01, 02.
