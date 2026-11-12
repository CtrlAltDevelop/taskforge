# Shortcuts

Each person's own keyboard shortcuts, synced across devices.

## Routes

<!-- generated:routes -->
_This app publishes no routes of its own._
<!-- /generated:routes -->

## Models

<!-- generated:models -->
#### `UserShortcut`

One person's key chord for one registry action; an empty chord means unbound on purpose.

| Field | Type | Notes |
| --- | --- | --- |
| `id` | BigAuto | primary key |
| `user` | ForeignKey | → `accounts.User` |
| `action_id` | Char |  |
| `keys` | Char |  |
| `updated_at` | DateTime |  |
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

- **Transport**: gRPC only (`ShortcutController`: `Get`, `Set`). `Get` returns every override of the caller; `Set` binds one action to a chord, or with `reset` drops the override so the client's default applies again. Both reply with the full list, so a client never merges.
- **What is stored**: only the person's changes. The registry of actions and their default keys is client code; the server keeps `action_id` as an opaque lower-case string (`^[a-z][a-z0-9_.:-]{0,79}$`). An empty chord is an override too: the person unbound the action on purpose.
- **Chords** are modifiers in the fixed order `mod`, `ctrl`, `alt`, `shift`, then one key, joined by `+` (`mod+shift+k`). `mod` is Cmd on macOS and Ctrl elsewhere, so a chord means the same on every device. Input is normalised (case, order); a chord that means nothing, or one a browser keeps (`mod+t`, `mod+w`, `mod+n`, `mod+q`), is `SHORTCUT_INVALID`.
- **Conflicts**: two actions of one person on one chord is refused as `SHORTCUT_CONFLICT` (gRPC `ALREADY_EXISTS`), and the other action's id comes back in the `x-error-action_id-bin` trailer. The check runs under a row lock so two devices cannot both take the chord.
- **Scope**: personal, not per workspace. Any signed-in caller reads and writes only their own rows; there is no workspace header and no permission to check.
- **Limit**: 300 overrides per person.
