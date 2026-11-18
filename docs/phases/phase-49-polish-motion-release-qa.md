# Phase 49 — Motion, accessibility and visual release QA

**Status:** TODO

## Feature
The final pass that makes the redesign release-quality: motion, accessibility, performance, remaining screens (settings and admin) and a visual-regression gate.

## Why it exists
A design system only feels professional when the last 20 % is done: nothing jumps, everything responds in 100 ms, keyboard and screen readers work, and no screen is left in the old style. Jira and ClickUp both ship visible inconsistencies between old and new areas; we remove the old style entirely before release (phase 38 ships it).

## How it works (plain words)
A short **motion spec** (durations 100/160/240 ms, one ease-out curve, no bounce) is applied: sheet and peek slide, menu fade-scale, list insert/remove, board drop settle, toast, tab underline slide, skeleton shimmer. `reduce motion` turns all of it to instant fades. Remaining screens move to `Tf*`: Settings (profile, security, sessions, language, appearance, notifications), admin (members, roles, audit, import/export, developer, webhooks, forms builder, workflow and field editors, sprints, automations, goals, docs editor chrome, dashboards editor, workload, timesheet). Then the **gate**: lint allow-list is empty, golden suite covers every top-level screen on phone and desktop in light/dark and en/fa, and an accessibility audit passes.

## Scope
**In:** motion tokens and use, remaining-screen migration, accessibility (focus order, labels, roles, contrast, 200 % text, screen-reader pass on web with VoiceOver/NVDA notes, reduced motion), performance budget (cold start, first list paint, scroll), deleting dead pre-redesign widgets and aliases (`radiusSmall/Medium/Large`, old shell), updated screenshots in README and docs, release checklist entry in phase 38 docs.
**Out:** new features; marketing assets; custom themes.

## Data model
- None.

## API surface
- None.

## Flutter UI
- No new screens. Every screen listed above converted; each conversion is its own small commit ("restyle <screen> on Tf components").
- Global: consistent page-level container (max width, padding), page headers with title/description/actions, form layout (label above field, helper text, inline errors, sticky save bar), destructive-action pattern (danger zone, typed confirm).

## Rules and edge cases
- No animation blocks input or delays data; nothing animates on first paint of cached data.
- Focus is trapped in dialogs and sheets and returned on close; `Esc` always closes the top layer only.
- Every icon-only button has a tooltip and semantic label; every image has alt text or is marked decorative.
- Performance budget (measured on a mid Android phone, an M-series Mac and web): cold start to interactive list < 2 s on a 5,000-task workspace, scroll ≥ 55 fps; recorded in the phase notes and re-checked by a smoke script.
- Goldens use the tolerance already agreed in phase 31 so another OS does not fail them.

## Acceptance criteria
- [ ] Lint allow-list empty: no hex colour, ad-hoc radius or raw `Icons.*` anywhere in `features/`
- [ ] Old shell, old toolbars and deprecated token aliases deleted; `flutter analyze` clean
- [ ] Golden suite: every top-level route on phone and desktop, light/dark, en/fa
- [ ] Reduce-motion honoured; motion spec applied to the listed surfaces
- [ ] Accessibility checklist signed off: keyboard-only walk of sign in → create task → comment → settings; screen-reader labels; 200 % text; contrast AA
- [ ] Performance budget met and recorded
- [ ] README and docs screenshots refreshed; brand assets in all six platform builds verified by running them
- [ ] Release checklist (phase 38) references this gate

## Tests
Golden gate in CI, keyboard-traversal widget tests for dialogs/sheets, semantics tests (`SemanticsHandle`) on key screens, a profile-mode timing script, a test that fails on forbidden literals.

## Depends on
44–48.
