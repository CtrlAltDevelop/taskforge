# Phase 40 — Device Info and Named Sessions

**Status:** TODO

## Feature
Every session gets a readable **name** ("Pixel 8 · Android 14") and a privacy-safe **device fingerprint**, so users can see, rename and control exactly which devices are signed in.

## Why it exists
A list of anonymous sessions ("Session 7f3a…, IP 10.0.0.4") is useless: nobody knows which one to revoke. Jira and ClickUp show little more than a browser string. Naming sessions and recognizing a returning or new device makes revocation and "was this you?" alerts practical.

## How it works (plain words)
At sign-in, sign-up and refresh the app sends one header, `X-Device-Info`, with a few facts about the device. The server (only while the admin's **Collect device info** setting is on) validates them, builds a display label, and computes a **fingerprint**: a keyed hash of the stable facts. The session is saved with that label as its name. The Sessions screen lists each session as name, last used, coarse place, a **This device** badge, and a short fingerprint tag; the user can **rename** any session and revoke it. If a sign-in arrives with a fingerprint this user has never used, it is flagged **new device** (hook for the phase 19 notification). If a session's fingerprint matches an earlier one but its DPoP key (phase 39) differs, it shows **key changed**.

The fingerprint is a **label, not a credential**: the client reports it, so it can be faked. Security comes from the DPoP key of phase 39; this phase is about clarity and control.

## Scope
**In:** `X-Device-Info` parsing and validation, `collect_device_info` server setting, fingerprint computation, session name (auto and user-edited), current-session flag, new-device and key-changed flags, Sessions API additions, rename endpoint, Flutter collection and Sessions screen update.
**Out:** sending email/push alerts (phase 19), geo-IP lookups beyond what phase 01 already stores, device trust / skip-2FA (phase 37), device attestation.

## Data model
- `Session` gains: `name` (≤ 80 chars, user-editable), `device_label` (derived, e.g. "Pixel 8 · Android 14"), `device_fingerprint` (16-byte HMAC, hex), `name_edited` bool.
- `KnownDevice(user, fingerprint, first_seen_at, last_seen_at)` unique `(user, fingerprint)` — drives the new-device flag.
- Setting `COLLECT_DEVICE_INFO` (env + admin toggle), default **off**.
- Raw header values are **not stored**. Only the derived label and the fingerprint are, and the label holds only model, OS and OS version.

## API surface
- Request header on sign-in, sign-up and refresh (not needed on every route): `X-Device-Info: model=Pixel 8;os=android;osVersion=14;build=19;screen=1080x2400@2.75;locale=en-US;tz=Asia/Tehran;abi=arm64-v8a`. gRPC: metadata `x-device-info`.
- Format: `key=value` pairs joined by `;`, at most 512 ASCII characters, each key at most once, unknown keys dropped. `model` and `os` are required (otherwise the whole header is ignored); `osVersion`, `build`, `screen`, `locale`, `tz`, `abi` are optional and each is checked against a fixed pattern (a bad one is ignored, not an error). Web sends the browser as the model, for example `model=Chrome 126;os=macos`.
- REST: `GET /api/v1/auth/token/sessions` adds `name`, `device_label`, `fingerprint_short` (first 8 hex), `is_current`, `new_device`, `key_changed`; `PATCH /api/v1/auth/token/sessions/{id}` body `{name}` renames (own sessions only). gRPC `Sessions` gains the same fields when the starter allows; otherwise the app reads REST for the list.
- No header or setting off: sessions fall back to a name built from the `User-Agent` (browser and OS) or "Unknown device", never an error.

## Flutter UI
Sessions screen rows show the name with an edit icon (inline rename), a **This device** chip, a **New** or **Key changed** chip when flagged, the last-used time and coarse place, and the existing revoke action. Collection uses `device_info_plus` (model, OS, version, build, ABI), `dart:ui` for screen size and pixel ratio, the platform locale and `DateTime.now().timeZoneName`/IANA zone; on web it uses `navigator.userAgentData` with a `User-Agent` fallback. The header is built in one place next to the auth client and sent only on sign-in, sign-up and refresh. A privacy line in Settings states what is sent and that the server may ignore it.

## Rules and edge cases
- **Fingerprint** = `HMAC-SHA256(server_pepper ‖ user_id, model|os|screen|locale|tz|abi)` truncated to 16 bytes. The user id in the key means the same phone under two accounts yields two unrelated fingerprints; nothing links accounts, and a database leak reveals no raw values. `osVersion` and `build` are excluded because they change with updates and would make a returning device look new.
- Missing optional fields are hashed as empty, so a client that omits `tz` has a different fingerprint from one that sends it; clients must send the same set every time (one builder, tested).
- Validation: ASCII only, length cap before any parsing, per-key regexes (for example `screen=^\d{3,5}x\d{3,5}@\d(\.\d{1,2})?$`, `tz` IANA pattern, `locale` BCP 47), values containing `;` or `=` rejected, control characters rejected. Bad values are dropped silently and counted in a metric.
- The label is built only from validated `model`, `os`, `osVersion` and is HTML-escaped on render; the user-supplied name is plain text, trimmed, 1–80 chars.
- A user-edited name is never overwritten by later refreshes (`name_edited`).
- Renaming and listing are scoped to the caller's own sessions (cross-user test mandatory). Revoking the current session behaves as sign-out.
- Server setting off: header is ignored entirely, no fingerprint, no `KnownDevice` rows, `new_device` always false; existing rows keep their names.
- Fixes the phase 01 starter quirk that gRPC `Sessions` does not flag the current session: `is_current` comes from the bound session id of the request.
- `KnownDevice` rows are removed when the user is deleted and pruned after 12 months unused.

## Acceptance criteria
- [ ] Sign-in with the header creates a session named from model and OS, and the Sessions screen shows it with "This device"
- [ ] Rename persists, survives refresh, and only works on the caller's own sessions
- [ ] A malformed header (too long, missing `model` or `os`, bad pattern) never fails a sign-in; bad optional keys are ignored
- [ ] Same device signing in twice gives the same fingerprint; a different device or a different account gives a different one
- [ ] First sign-in with an unseen fingerprint sets `new_device`; the second does not
- [ ] Same fingerprint with a different DPoP key shows `key_changed`
- [ ] With **Collect device info** off, nothing is stored or flagged and the app still works
- [ ] No raw header value other than the derived label is stored or logged

## Tests
Header parser table (each key valid and invalid, length cap, duplicates, control characters), fingerprint stability and per-user separation, new-device and key-changed flags, rename authorization (cross-user), setting off path, no raw values in DB or logs, Flutter header builder and Sessions screen widget tests (rename, chips, current device).

## Notes for implementation
- Keep the parser and fingerprint in `infrastructure/auth/core/device.py`, used by REST and gRPC adapters alike.
- The pepper comes from env (`DJANGO_DEVICE_FINGERPRINT_PEPPER`), required at startup when the setting is on; rotating it makes every device look new once.

## Depends on
Phase 01. Phase 39 for `key_changed`; the rest works without it.
