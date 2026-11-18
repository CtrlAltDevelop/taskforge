# Accessibility checklist (phase 49 gate)

Owner sign-off sheet for a release (see the release checklist in
[phase 38](phases/phase-38-release-deploy.md#release-checklist)). Automated checks run in CI
and are listed first; the rest needs a person with a keyboard and a screen reader.
Record the date, build, platform and screen reader at the bottom.

## 1. Automated (must be green in CI)

| Check | Where |
|-------|-------|
| Every text/background colour pair AA (4.5:1; UI parts and focus ring 3:1), light, dark, high contrast | `app/test/core/ui/tokens/colors_test.dart` |
| `IconButton` has `tooltip:`; `Image`/`SvgPicture` has a label or `excludeFromSemantics` | `app/test/core/ui/a11y_lint_test.dart` |
| Tap targets named and at least 48 px (`labeledTapTargetGuideline`); 200 % text without overflow at 360/768/1280 | `app/test/a11y/screens_semantics_test.dart` |
| Esc closes only the top layer; focus returns to the opener; Tab stays in dialogs and sheets | `app/test/core/ui/overlay_focus_test.dart` |
| Reduce motion makes every animation instant | `app/test/core/ui/motion/motion_test.dart` |

## 2. Keyboard-only walk (no mouse, no touch)

Do it on web (Chrome) and on one desktop app. Tab, Shift+Tab, arrows, Enter, Space, Esc only.

1. **Sign in:** first Tab lands on the email/username field; the order is field, password, Sign in, secondary links. Enter submits. Errors are announced and focus moves to the first invalid field.
2. **Create task:** reach New task by keyboard (shortcut `c` or Tab to the button). The dialog traps focus, the title field is focused on open, Enter creates, Esc cancels and focus returns to the button.
3. **Comment:** open the task (Enter on the row). Tab to the comment box, type, send with the documented shortcut or the Send button. The new comment is reachable by Tab.
4. **Settings:** reach Settings from the shell, move between pages, change a switch with Space and a select with arrows, Save with Enter. Danger-zone actions need the typed confirm, and Esc cancels.

Pass when: a visible focus ring is on every stop, nothing is skipped or unreachable, no keyboard trap other than modal layers, Esc never closes two layers.

## 3. Screen reader

Test pairs: **VoiceOver** (macOS Safari/Chrome and the macOS app; iOS Safari if available) and **NVDA** (Windows, Firefox and Chrome). Flutter web needs accessibility enabled: press the hidden "Enable accessibility" button (first Tab stop) before testing.

### VoiceOver (macOS: Cmd+F5; navigate with VO keys, Ctrl+Option+arrows)
- Rotor (VO+U) Landmarks/Buttons/Form controls are populated; every control has a name.
- Announcements to listen for are in the table below.

### NVDA (Insert+Space toggles browse and focus mode; Tab to move)
- Form fields are read as "edit, <label>"; buttons as "button, <label>"; checkboxes with checked state.
- Toasts and inline errors are spoken without moving focus (live region).

### Expected labels (English; same keys exist in fa/ar/ps, see below)

Wording comes from `app/lib/l10n/app_en.arb` and may be tuned; what must hold is that every control has a name that says what it does, plus its role and state. "Select all tasks" (`tblSelectAll`) and "Close" are exact; the others are the shape to expect.

| Screen | Control | Expected announcement |
|--------|---------|-----------------------|
| Sign in | username/email field | "Email or username, edit text" |
| Sign in | submit | "Sign in, button" |
| List | select-all checkbox in header | "Select all tasks, checkbox, not checked" |
| List | row checkbox | "<task title>, checkbox, not checked" (the title, not "checkbox") |
| List | row | task title with status, priority, assignee and due date in one phrase; no unnamed "button" |
| List/board | icon-only buttons (filter, view options, more) | their tooltip text, e.g. "Filter, button" |
| Board | card | task title plus status column; drag has a keyboard alternative (Move to...) |
| Task modal | title | "Title, edit text, <title>" |
| Task modal | comment box | "Comment, edit text"; Send is "Send comment, button" |
| Task modal | close | "Close, button"; Esc closes; focus returns to the row |
| Settings | switch | "<setting>, switch, on/off" |
| Settings | danger zone | heading "Danger zone"; confirm field named for what to type |
| Toast | after save | the message is spoken once, focus does not move |

If an announcement differs, the screen has a labelling gap: file it against the phase 49 gate, do not sign off.

## 4. 200 % text and zoom
- OS text size 200 % (macOS: Accessibility > Display > Text size; Windows: Ease of Access > Text size; Android: Font size largest; iOS: Larger Text max) and browser zoom 200 %.
- Sign in, Home, My work, list, board, task modal, Settings: no clipped text, no overlapping controls, all actions still reachable (scrolling is fine, hidden is not).

## 5. Contrast AA
- Token pairs are asserted by test. Spot-check by eye in light, dark and high contrast: placeholder text, disabled controls (exempt, but legible), status chips, links, focus ring, selected row, charts (colour is never the only signal).
- Check the three handwritten places not covered by tokens: skeleton shimmer, toast on dark, board column header tint.

## 6. Reduce motion
- Turn on the system flag (macOS: Reduce motion; Windows: Animation effects off; Android: Remove animations; iOS: Reduce Motion) and relaunch.
- Sheets, dialogs, toasts, tab underline, skeleton and board drop appear instantly or with a plain fade; nothing slides or bounces.

## 7. Right-to-left and language
- Switch to Persian (fa) and Arabic (ar): layout mirrors, arrows and chevrons flip, focus order follows reading order, the screen reader speaks the translated label (needs a native speaker, see the phase 49 owner list).

## Sign-off

| Date | Build / version | Platform | Screen reader | Sections 2-7 pass | Signed |
|------|-----------------|----------|---------------|-------------------|--------|
|      |                 |          |               |                   |        |
