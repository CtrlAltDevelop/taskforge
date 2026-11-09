# Phase 31 — Localization and RTL

**Status:** TODO

## Feature
Full **multi-language UI** with right-to-left layout support (Persian/Dari, Pashto, Arabic) plus localized dates, numbers and calendars.

## Why it exists
Incumbent RTL support is partial and buggy; many regions are poorly served. Doing it properly (not just translated strings) is a real differentiator.

## How it works (plain words)
All user-facing strings live in ARB files (`app_en.arb`, `app_fa.arb`, `app_ps.arb`, `app_ar.arb`…) via Flutter’s `gen_l10n`; no hardcoded text. Layout uses directional widgets (`EdgeInsetsDirectional`, `AlignmentDirectional`) so the UI mirrors automatically. Dates and numbers use `intl`; users can pick **Gregorian or Jalali (Solar Hijri)** display and week start (Saturday/Sunday/Monday). The backend returns machine-readable error codes plus localized messages based on `Accept-Language`/user setting. Fonts include good Arabic-script faces (e.g. Vazirmatn / Noto) bundled so web doesn’t depend on system fonts.

## Scope
**In:** l10n pipeline, English + Persian + Arabic + Pashto at launch, RTL mirroring audit of all screens, Jalali date option (display + pickers), localized numerals option, per-user language, backend message localization, bidi-safe text (mixed English ids like `WEB-12` inside RTL text), translation contribution guide.
**Out:** machine translation of user content, right-to-left in exported PDFs (CSV/JSON unaffected).

## Data model
- `User.locale`, `User.calendar_system`, `User.week_start`
- `Workspace.default_locale`

## API surface
- gRPC/REST: error details carry `code` + params; `Me.UpdatePreferences`.
- Server `gettext`-based messages for emails/notifications in the recipient’s language.

## Flutter UI
Language picker (onboarding + settings), calendar/week-start settings, all date pickers able to render Jalali. Golden tests in LTR and RTL for key screens.

## Rules and edge cases
- Jalali is **display only**: stored dates stay ISO/Gregorian; conversion is in one util with tests (leap years, boundaries).
- Icons that imply direction (back arrows, progress, undo) mirror; logos/media icons don’t.
- Plurals via ICU message syntax (Arabic/Persian rules differ).
- Pseudo-localization build flag to catch hardcoded/truncated strings.

## Acceptance criteria
- [ ] Every screen from phases 01–30 renders correctly in RTL (golden/visual check list)
- [ ] Switching language is instant without restart
- [ ] Jalali ⇄ Gregorian conversion verified against reference fixtures
- [ ] No hardcoded user-visible strings (lint rule/CI check)

## Tests
Date-conversion fixtures, locale-based golden tests, plural tests, l10n completeness check (missing keys fail CI).

## Depends on
Best done once most screens exist (after 25), but the l10n pipeline should be wired from phase 00.
