# Phase 44 — Design system and brand

**Status:** DONE

## Feature
One TaskForge design system — brand identity, colour, type, icons, spacing, elevation and a library of `Tf*` components — that every screen is rebuilt on in phases 45–49.

## Why it exists
The app looks like stock Material 3 with an indigo seed: default `Card`s, `SegmentedButton`s, `NavigationRail`, raw `Icons.*` and 8–16 px radii scattered per screen. It reads as an MVP. Jira and ClickUp feel like products because every surface uses the same few decisions: a quiet neutral canvas, one confident accent, tight dense rows, small precise type, coloured status/priority chips, soft borders instead of shadows. Both have weaknesses we fix here: Jira is cluttered and slow-looking; ClickUp is busy, many accent colours and inconsistent spacing. Ours: **calm, dense when you want it, one accent.**

## How it works (plain words)
Design decisions live in code as **tokens** (`app/lib/core/ui/tokens/`), never as literals in screens. Screens use `Tf*` components (`TfButton`, `TfChip`, `TfAvatar`, `TfRow`, `TfPanel`, `TfMenu`, `TfEmpty`, …) which read tokens through a `ThemeExtension`. A lint test fails the build if a screen under `features/` uses a hex colour, a hand-written radius or a raw `Icons.*` outside the icon map. Light, dark and a "high contrast" variant come from the same tokens. Density (Comfortable / Compact) is one switch that scales row height, padding and type.

## Scope
**In:**
- **Brand:** name stays TaskForge. New mark (anvil/spark monogram, works at 16 px), wordmark, app icon for all six platforms, splash, favicon, social card. Accent: a warm *ember* (orange-amber) against deep *ink* neutrals — distinct from Jira blue and ClickUp purple. Decision is recorded in `docs/brand.md` with the palette, clear-space and misuse rules.
- **Colour tokens:** neutral ramp (12 steps, light/dark), accent ramp, semantic (success/warning/danger/info), status-category colours (to do / in progress / done) and a 10-colour categorical palette for projects, labels and chart series. Every pair checked for WCAG AA contrast by a unit test.
- **Type:** one UI family bundled (Inter, with Vazirmatn kept as the Arabic-script fallback), a 7-step scale (11/12/13/14/16/20/28), tabular numerals for ids, counts and times, mono for task keys.
- **Spacing/shape/elevation:** 4-pt spacing scale, radii 4/6/8/12, 1 px hairline borders, two shadows only (popover, modal).
- **Icons:** one icon set with a single weight, bundled, mapped by name in `tf_icons.dart` (RTL-mirroring flag per icon). Every `Icons.*` in `features/` is replaced.
- **Components:** button (primary/secondary/ghost/danger, sizes S/M/L, loading), icon button, input/search field, select, menu/popover, tooltip, dialog, side sheet, bottom sheet, tabs, segmented switch, chip/tag/badge, avatar and avatar stack, status pill, priority icon, progress ring/bar, checkbox, toggle, table row, list row, section header, empty state, skeleton, toast, banner, keyboard-key hint.
- **Theming:** light, dark, high contrast, density, per-user choice in Settings; follows system by default.
- **Component gallery:** a debug-only `/debug/gallery` route showing every component in every state, light/dark, LTR/RTL — the single place designers and reviewers look.

**Out:** redesign of any screen (45–49); custom per-workspace theming; illustration set (48).

## Data model
- None on the server. Local prefs (existing `local_prefs`): `theme_mode`, `density`, `contrast`.

## API surface
- None.

## Flutter UI
- New: `core/ui/tokens/{colors,typography,spacing,shape}.dart`, `core/ui/tf/*.dart` (one file per component, ≤ 200 lines), `core/ui/tf_icons.dart`, `core/ui/theme_extension.dart`; `app_theme.dart` rebuilt on tokens.
- Settings → Appearance: theme, density, contrast, live preview.
- States every component documents and renders in the gallery: default, hover, focus (visible ring), pressed, disabled, loading, error, selected.
- Platform notes: hover and focus rings on desktop/web; ≥ 44 dp targets on touch (density does not shrink touch targets below 40 dp); no Material ripple colour on desktop, subtle fill instead.

## Rules and edge cases
- Colour is never the only carrier of meaning (status/priority also have a shape or label).
- RTL: all `Tf*` use directional insets/alignment; icon map flags which icons mirror.
- Dark mode is designed, not inverted: elevation shown by lighter surface and border, not shadow.
- Text scale up to 200 % must not clip a component (checked in the gallery sweep).
- Bundled fonts only; no runtime font download (offline phase 30, privacy).
- Migration: old `radiusSmall/Medium/Large` stay as aliases until phase 49 deletes them, so screens move over one phase at a time.

## Acceptance criteria
- [x] `docs/brand.md` exists with palette, type, mark and rules; new icon and favicon ship on web, macOS, Windows, Linux, Android, iOS
- [x] All tokens defined once; contrast test passes AA for every text/background pair in light, dark and high contrast
- [x] Every component in the list exists with all states and is in the gallery
- [x] Density switch changes row height and padding app-wide without layout overflow
- [x] Lint test: no hex colour, no ad-hoc `BorderRadius.circular`, no raw `Icons.*` in migrated screens (allow-list shrinks each phase, empty at 49)
- [x] Gallery sweep (en/fa/ar, light/dark, 100 %/200 % text) has no overflow
- [x] Appearance settings persist and apply live

## Tests
Unit: contrast ratios, token completeness, icon map covers every name used. Widget: each `Tf*` states, keyboard focus and activation, RTL mirror. Golden: gallery in light/dark/RTL. Lint test described above.

## Depends on
31 (RTL and fonts), 25 (shortcut hints).
