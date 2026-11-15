# Translating TaskForge

TaskForge ships in English (`en`), Persian (`fa`), Arabic (`ar`) and Pashto (`ps`).
Anyone can fix a translation or add a language; no Dart knowledge is needed.

## Where the text lives

| What | Where |
|------|-------|
| App (Flutter) strings | `app/lib/l10n/app_<code>.arb`; `app_en.arb` is the template |
| Generated Dart (committed) | `app/lib/l10n/gen/` — never edit by hand |
| Server messages (error descriptions, notification and email text) | `backend/src/infrastructure/common/locales.py` and `messages.py` |

An `.arb` file is JSON: `"key": "text"`. Keys starting with `@` (English file only)
describe placeholders and plurals; leave them alone.

## Fixing or improving a translation

1. Edit the value in `app_fa.arb` / `app_ar.arb` / `app_ps.arb`. Do not rename keys.
2. Keep every placeholder exactly as in English: `{name}`, `{count}`. Move it where
   your language needs it, but do not translate or remove it.
3. Plurals use ICU syntax, for example
   `{count, plural, =1{1 task} other{{count} tasks}}`. Arabic needs the extra
   forms `zero`, `one`, `two`, `few`, `many`, `other`; Persian and Pashto need
   `one` and `other`.
4. A single quote in a message is written as it is; if it breaks the build, double it (`''`).
5. Run, from `app/`:

   ```bash
   flutter gen-l10n
   flutter test test/i18n
   ```

   The second command fails when a key is missing, empty, unknown, or a placeholder differs.

## Adding a language

1. Copy `app_en.arb` to `app_<code>.arb` and translate every value (drop the `@` entries).
2. Add the code to `SUPPORTED_LOCALES` (and `RTL_LOCALES` if it is written right to left)
   in `backend/src/infrastructure/common/locales.py`, and its catalog entries.
3. Add the code to `normalizeLanguage` and the language list in
   `app/lib/core/i18n/locale_prefs.dart` and `language_screen.dart`, with its name
   written in its own script.
4. Add it to the `for (final code in [...])` loop in `app/test/i18n/l10n_checks_test.dart`.
5. Run `flutter gen-l10n`, `flutter test` and the backend tests.

## Writing code that can be translated

- Never put user-visible text in Dart: use `context.l10n.someKey` and add the key to
  `app_en.arb` first. `flutter test test/i18n` counts hardcoded strings per file and
  fails when a file gets worse.
- Prefer start/end over left/right: `EdgeInsetsDirectional`, `AlignmentDirectional`,
  and `DirectionalIcon` for chevrons and arrows.
- Ids and keys such as `WEB-12` stay left to right inside right-to-left text: wrap
  them with `isolateLtr`.
- Dates go through `formatDate` so the user's calendar (Gregorian or Jalali) and
  numerals apply; never format dates by hand.
- Test a screen in the pseudo-language (see below) and in `fa` before calling it done.

## Pseudo-language

`en-XA` is English with accents, padding and brackets (`[Ñéw tåsk ~~~]`), generated
from `app_en.arb`. It shows hardcoded text (it stays plain English), strings that do
not fit when text grows, and clipped layouts. Regenerate it with
`dart run tool/pseudo_locale.dart` from `app/` after changing `app_en.arb`.

## Fonts

Persian, Arabic and Pashto text is drawn with **Vazirmatn**, bundled in
`app/assets/fonts/` (SIL Open Font License 1.1, license file beside it) and set as
the first Arabic-script fallback in `app/lib/app.dart`, so it looks the same on
every platform and on the web. To change the face, replace the file, update the
`fonts:` section of `app/pubspec.yaml`, and keep the license text with it.

## Review status

The Persian, Arabic and Pashto text was drafted by machine and has not been reviewed
by a native speaker. Pashto is the weakest. A review pass is the most useful
contribution right now.
