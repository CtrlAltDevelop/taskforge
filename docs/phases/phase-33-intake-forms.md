# Phase 33 — Intake Forms

**Status:** DONE

## Feature
Shareable **forms** that create tasks — usable by people **outside** the workspace (clients, customers, other teams).

## Why it exists
Bug reports and requests usually arrive by email or chat and get lost. Jira Service Management / ClickUp Forms solve it but are paid or limited. This is the safe, free way to let outsiders create work without giving them accounts.

## How it works (plain words)
A project admin builds a form by choosing fields (title, description, any custom field from phase 10, file upload) and a **target** (project, default status, default assignee, labels). The form gets a public URL (or can be embedded). A visitor fills and submits; a task is created by the “Form: <name>” actor with the answers. The submitter may leave an email to receive a confirmation and updates (one-way: status change emails, no workspace access). Abuse protection includes a honeypot, rate limit, and optional CAPTCHA (self-hosted-friendly, e.g. hCaptcha/Turnstile key in config).

## Scope
**In:** form builder, field ordering/required/help text, public page, submission → task, confirmation email, optional status-update emails, enable/disable, submissions list, spam protection, branding (logo/color).
**Out:** full customer portal with login, SLAs, conditional logic (v2).

## Data model
- `Form(id, project, name, slug_token, fields jsonb, defaults jsonb, enabled, require_email, created_by)`
- `FormSubmission(id, form, task, submitter_email nullable, ip_hash, at)`

## API surface
- REST (public, no auth): `GET /api/public/forms/{token}`, `POST /api/public/forms/{token}/submit` (multipart for files, using phase 18 pipeline with strict limits)
- gRPC (authenticated): `Forms.List/Create/Update/Delete/Submissions`.

## Flutter UI
Builder (drag fields, preview), submission inbox, public form page rendered by the same Flutter web build at `/f/<token>` (lightweight route, no login chrome).

## Rules and edge cases
- Public endpoints never reveal anything but the form definition; task ids shown to submitter are limited to a reference code.
- Strict validation + size caps; files scanned/typed as in phase 18.
- IP stored hashed (privacy); per-form and per-IP rate limits.
- Disabled/deleted form returns a generic not-found.

## Acceptance criteria
- [x] Anonymous visitor submits form → task appears in the target project
- [x] Spam flood is throttled; honeypot submissions dropped
- [x] Submitter email receives confirmation; no access to workspace data
- [x] Custom field answers validated exactly like in-app

## Tests
Public endpoint isolation, rate limiting, upload limits, field validation reuse, email flow.

## Depends on
Phases 10, 18, 19.

## Implementation notes
- Tasks have no separate label concept, so "labels" in a form's defaults are project field values: `defaults.field_defaults` maps custom field ids to wire values (labels are a multi-select field named Labels). They are checked like a typed value when the form is saved; a default that stopped fitting (field archived, option removed) is left out at submit time, never a reason to refuse a visitor. A visitor's own answer to the same field wins. gRPC: `FieldDefault{field_id, value}` on `FormCreateRequest`, `FormUpdateRequest` (with `changed: ["defaults"]`) and `IntakeForm`.
- The logo can be uploaded: `POST /api/v1/forms/{form_id}/logo` (multipart `file` + `expected_version`, `X-Workspace`; PNG, JPEG or WebP read from the bytes, at most 2 MB; needs `form.manage`). It replaces a linked logo and a previous upload; linking a web address (or clearing `logo_url`) through `Update` removes the upload. `IntakeForm.logo_url` and the public page show whichever is set.
- App: the form builder lists every project field under "Default values" with the field's own input (the saved value in its wire form, cleared by emptying it) and sends it as `field_defaults`. The logo has Upload image (REST multipart; disabled until the form is saved, because the upload needs the form's version), the link field and Remove logo. The builder cannot tell an uploaded logo from a linked one in `logo_url`, so it leaves `logo_url` out of the save until the person edits or removes it; saving never turns an upload into a link. An upload moves the form's version, which the builder keeps for the next save.
