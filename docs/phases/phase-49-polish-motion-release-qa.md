# Phase 49 — Motion, accessibility and visual release QA

**Status:** implemented on `develop`. What is left is device and screen-reader work that needs a person: see **Owner must test** at the end of this file (Part F).

## Feature
The final pass that makes the redesign release-quality: motion, accessibility, performance, remaining screens (settings and admin) and a visual-regression gate.

## Why it exists
A design system only feels professional when the last 20 % is done: nothing jumps, everything responds in 100 ms, keyboard and screen readers work, and no screen is left in the old style. Jira and ClickUp both ship visible inconsistencies between old and new areas; we remove the old style entirely before release (phase 38 ships it).

## How it works (plain words)
A short **motion spec** (durations 100/160/240 ms, one ease-out curve, no bounce) is applied: sheet and peek slide, menu fade-scale, list insert/remove, board drop settle, toast, tab underline slide, skeleton shimmer. `reduce motion` turns all of it to instant fades. Remaining screens move to `Tf*`: Settings (profile, security, sessions, language, appearance, notifications), admin (members, roles, audit, import/export, developer, webhooks, forms builder, workflow and field editors, sprints, automations, goals, docs editor chrome, dashboards editor, workload, timesheet). Then the **gate**: there is no lint allow-list, golden suite covers every top-level screen on phone and desktop in light/dark and en/fa, and an accessibility audit passes.

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
- Performance budget (measured on a mid Android phone, an M-series Mac and web): cold start to interactive list < 2 s on a 5,000-task workspace, scroll ≥ 55 fps; recorded in the phase notes; `make perf` re-runs the smoke tests that keep cost from growing with task count, the device numbers are measured by hand with the recipe it prints.
- Goldens use the tolerance already agreed in phase 31 so another OS does not fail them.

## Acceptance criteria
- [x] Lint allow-list empty: no hex colour, ad-hoc radius, raw `Icons.*` or Material `Colors.*` anywhere in `features/` or `core/` outside the tokens (`test/core/ui/forbidden_literals_test.dart`, no allow-list)
- [x] Old shell, old toolbars and deprecated token aliases deleted; `flutter analyze` clean
- [x] Golden suite: every top-level route on phone and desktop, light/dark, en/fa (all eight combinations; routes that need a server challenge or a seeded record are listed with a reason in the test)
- [x] Reduce-motion honoured; motion spec applied to the listed surfaces (menu, tabs, sheets, dialog, toast, list insert and remove, board settle, skeleton), each tested normal and reduced; the Appearance switch has a widget test
- [ ] Accessibility checklist signed off. Automated parts are done and green (focus trap and Esc, labelled tap targets, 200 % text, contrast AA, a11y lint). **Owner:** the keyboard-only walk and the VoiceOver / NVDA pass in [docs/accessibility-checklist.md](../accessibility-checklist.md)
- [ ] Performance budget met and recorded. `make perf` runs the smoke tests (cost does not grow with task count); **owner:** the profile-mode numbers on a mid Android phone, an M-series Mac and web (recipe printed by `make perf`)
- [ ] README and docs screenshots refreshed (done, six web screenshots); **owner:** brand assets run on Android, iOS, Windows and Linux (Part F table)
- [x] Release checklist (phase 38) references this gate

## Tests
Golden gate in CI, keyboard-traversal widget tests for dialogs/sheets, semantics tests (`SemanticsHandle`) on key screens, a performance smoke (`make perf`; the profile-mode recipe it prints is run by a person on a device), a test that fails on forbidden literals.

## Depends on
44–48.

## Notes: motion, focus, semantics, performance (part C)

**Motion.** `core/ui/tokens/motion.dart`: `TfDuration` fast 100 / base 160 / slow 240 ms, one curve `tfCurve` (ease-out cubic, no overshoot), `TfMotion.of(context, d)` (zero when reduced) and `TfMotion.style` for routes. Reduce motion is `MediaQuery.disableAnimations` (system flag) or the Appearance choice `reduceMotionProvider`; `app.dart` folds both into the media query. Applied to: side sheet and bottom sheet slide (slow), dialog fade, toast, task open fade, tab underline colour, checkbox, row actions, live flash, shell page fade, jump-to-latest scroll, skeleton shimmer (three sweeps, then still; static when reduced), board drop settle (`TfSettleIn`, only for the card just dropped, never for cached data). Tests: `test/core/ui/motion/motion_test.dart` (normal and reduced per surface).
Part E closed three of these: the menu panel (`TfMenu`) is drawn by the menu's own child (`_MenuPanelMotion`) and fades and scales in from its top edge (MenuAnchor only positions it); the tab underline slides (`TfTabs` measures the chosen tab and moves one `AnimatedPositioned`); rows inserted into the task list (table and phone cards) and board columns ease in through `TfSettleIn`, driven by `TfFreshIds` (an id is fresh only if it was not in the list at the first settled paint, so cached or still-streaming rows never animate). Removal: a row removed after the first settled paint stays as a ghost for 160 ms and fades and collapses (`TfRemovals`, `TfRemoveOut` in `core/ui/tf/tf_list_motion.dart`; task table, phone list and board columns; instant under reduce-motion; `removal_test.dart`). The table's rows have a fixed height, so there the ghost fades inside its slot. Filtering a list shows the rows that come into the result as inserted. The Appearance screen has the reduce-motion switch (`reduce-motion`, tested in `appearance_screen_test.dart`).

**Focus.** `test/core/ui/overlay_focus_test.dart` locks in what Flutter's routes give us: Esc closes only the top layer (dialog over sheet, dialog over task peek), focus returns to the opener, Tab and Shift+Tab stay inside a dialog or sheet.

**Semantics.** `test/core/ui/a11y_lint_test.dart` scans `lib/` and fails on an `IconButton` without `tooltip:` and on `Image`/`SvgPicture` without a label or `excludeFromSemantics: true`. `test/a11y/screens_semantics_test.dart` runs Flutter's `labeledTapTargetGuideline` on sign in, Home, list, board, task modal and three settings pages, and the 200 % text sweep on Home, My work and the list at 360/768/1280. It found two real gaps, fixed: the list's row and select-all checkboxes had no name (new key `tblSelectAll`; rows use the task title), and the row's wide hit area announced as an unnamed button. The contrast test (`tokens/colors_test.dart`) already covers every colour token (text, accent, tones, borders, focus, categorical); motion adds none.

**Icons.** A bare `TfIcon` stays 16 (`TfIconSize.inline`). Inside Material controls with their own 40-48 px target (IconButton, PopupMenuButton, ListTile leading, input affixes) call sites use `TfIconSize.control` (20) in the work views, filters, task detail, calendar, inbox, chat, search and shortcuts. Settings and admin screens are left to the restyle.

**Dead code.** The `radiusSmall/Medium/Large` aliases are deleted (no callers). No old shell or old toolbar files remain; a sweep of `core/ui`, `features/shell` and `work/` found no unreferenced file or symbol. `ChatSystemLine` (no callers) is deleted with its test and goldens.

**Performance.** `test/perf/cold_start_test.dart` (cold app to first list paint, 5,000 vs 200 tasks; ceiling 6 s and at most 3x the small workspace) and `test/features/tasks/work_perf_test.dart` (scroll frame cost 5,000 vs 200 rows, 1,000 vs 50 cards). Debug test VM on an M-series Mac, last runs: cold start to first list 200 tasks 1.7-2.6 s, 5,000 tasks 1.2-1.6 s; scrolled frame 92 ms (200 rows) vs 69 ms (5,000), board 45 vs 35 ms. These show cost does not grow with task count; they are not fps figures. Not measured: `flutter run --profile` on macOS, web, and a mid Android phone. **Owner to measure on a mid Android phone** (cold start to interactive list < 2 s on 5,000 tasks, scroll >= 55 fps, DevTools frame chart in profile mode) and record the numbers here.

## Notes: release gate (part E)

**Goldens.** `test/i18n/release_goldens_test.dart` reads every `path:` of `lib/app_router.dart`, so a new route without a picture, or without an entry in `_notPictured` (with a reason), fails; a second test checks the parsed list against the real router. Every route gets all eight combinations (phone and desktop, light and dark, en and fa): 408 PNGs in `test/i18n/goldens/release/` (about 7 MB), compared with the tolerant comparator of phase 31 (`useTolerantGoldens`). Not pictured, each with its reason: two-factor, SSO callback, public form, form builder (3 routes), webhook detail, goal detail (they need a challenge, a ticket or a seeded record) and the debug gallery (own sweep).

**Lint.** `test/core/ui/forbidden_literals_test.dart` covers `lib/features` and `lib/core` (outside `core/ui/tokens`) with no allow-list, and catches hex colours, `BorderRadius.circular`, `Icons.*` and every `Colors.*` (even `Colors.transparent`); semantic colours come from the theme's tones (`context.tf.colors.success.fg`, ...); `ui_lint_test.dart` and `ui_lint_allowlist.txt` are deleted. The raw values moved into tokens: `tfBlack`, `tfWhite`, `tfClear`, `tfScrim`, `TfRadius.inset/pill`, `tokens/chart_palette.dart`; the last Material icons in `core/` (sync status, date picker, offline) now use `TfIcons`.

## Notes: release QA, brand assets, screenshots (Part F)

Run on an M-series Mac with Flutter 3.50, Xcode 27.2, 2026-11-18. The checklist that references this gate is in [phase 38](phase-38-release-deploy.md#release-checklist); the screen-reader and keyboard sign-off sheet is [docs/accessibility-checklist.md](../accessibility-checklist.md).

**Brand assets, per platform** (launch name is now `TaskForge` everywhere; the brand page says never "Taskforge"):

| Platform | Icon | Launch / splash | Name shown | Status |
|----------|------|-----------------|------------|--------|
| Android | `mipmap-*/ic_launcher.png` (legacy) plus new adaptive icon (`mipmap-anydpi-v26/ic_launcher.xml`, ink background, foreground in `drawable-nodpi`, monochrome layer) | `launch_background.xml` ink plus `launch_mark.png` | `android:label="TaskForge"` (was `taskforge`) | `flutter build apk --debug` built; the APK contains the adaptive icon and launch resources. Not run on a device |
| iOS | `AppIcon.appiconset` (full-bleed, no alpha) | `LaunchScreen.storyboard` plus `LaunchImage.imageset` | `CFBundleDisplayName` `TaskForge` (was `Taskforge`) | `flutter build ios --simulator --debug` built; launch on the simulator not done (simulator access was not granted to the agent) |
| macOS | `AppIcon.appiconset` 16-1024 | none (window opens directly) | `CFBundleDisplayName` `TaskForge` added; bundle file stays `taskforge.app` (renaming it touches the Xcode project) | `flutter build macos --debug` built and the app launched against the backend (window "TaskForge" opened, process alive); screenshots of the native window were not possible (screen capture returns black for the agent) |
| Windows | `windows/runner/resources/app_icon.ico` (16-256, wired in `Runner.rc`) | none | window title and `ProductName`/`FileDescription` now `TaskForge` | verified by files only |
| Linux | `runner/app_icon.png` 512, installed beside the binary by `CMakeLists.txt` and loaded in `my_application.cc` from `<exe dir>/data/app_icon.png` | none | window and header-bar title now `TaskForge` | verified by files only. Phase 44 said the wiring was never compiled; it reads correctly (glib `g_file_read_link` plus `gtk_window_set_icon_from_file`, installed path matches), but only a Linux build proves it |
| Web | `favicon.png` 32, `icons/Icon-192/512` plus maskable 192/512 in `manifest.json`, `apple-touch-icon`, `social-card.png` | none | `TaskForge` in title, manifest, og tags | `flutter build web` built; ran in the browser against the backend (see screenshots) |

`python3 tool/make_brand_icons.py` now also writes the Android adaptive icon; rerunning it changes no other asset.

**Build faults found and fixed while building (not in the plan):** `flutter build apk` failed on the current toolchain: Flutter 3.50 needs Android Gradle Plugin 9.1.1 (the project had 9.1.0; `android/settings.gradle.kts`) and plugins need `compileSdk` 37 (`android/app/build.gradle.kts` now sets 37 instead of `flutter.compileSdkVersion`). Flutter warns AGP 9.1.1 and Kotlin 2.4.10 will soon be dropped (wants 9.3.1 and 2.4.20); upgrade before it becomes an error.

**What was run.** Backend on a throwaway SQLite database and ports 8011/50052 (another stack already held 8010/50051; its data was not touched), seeded with `seed_demo`, then two tasks given status and assignee so Home, list and board show real data. Web ran with `flutter run -d web-server --profile` and an Envoy container (`deploy/envoy.yaml` copy on 8082 pointing at 50052). Needed `--dart-define=DPOP_ORIGIN=http://localhost:8010` because the backend signs against `DJANGO_PUBLIC_ORIGIN`/8010 (running REST on 8011 otherwise fails sign-in with "The proof is for another URL"). Sign in, Home, list, board, task modal with a comment, Settings > Language and a switch to Persian all worked. Nothing else on the web path failed.

**Screenshots added** (800x500 PNG, palette-optimised, 38-55 KB each) in `docs/screenshots/`, referenced from the README: `home-light.png`, `list-light.png`, `board-light.png`, `task-modal-light.png`, `board-dark.png`, `board-fa-rtl.png`. Taken in the web app in the in-app browser (debug ribbon absent: profile mode). The workflow status names (To do, In progress, Done) are data from the seed and stay English in Persian; the Persian sidebar's workspace name "Demo" renders pale in light mode on the first load (seen in one frame, not reproduced after navigation; check contrast during the RTL review).

**Not verified here.** Screenshots at 1280x800 (the pane renders 800x500); mobile and native-window shots; the web build with the production `SAME_ORIGIN` setup; Android and iOS launch; Windows and Linux builds.

**Owner must test**
- Android phone: run a release or profile build; check the adaptive icon (round and squircle masks, themed icon), launch name and splash; performance numbers (cold start to interactive list under 2 s on 5,000 tasks, scroll at 55 fps or better, DevTools frame chart in profile mode) and the same on an M-series Mac (`flutter run --profile -d macos`) and web profile; record them in the Part C Performance note.
- iOS simulator or device: launch screen and AppIcon, display name.
- Windows run: exe icon in Explorer and taskbar, window title `TaskForge`.
- Linux run: build, confirm the window icon loads (the first real compile of the icon wiring) and the title.
- VoiceOver (macOS and iOS) and NVDA (Windows): follow [docs/accessibility-checklist.md](../accessibility-checklist.md) and sign it off.
- Native review of the phase 48-49 strings in Persian, Arabic and Pashto (fa, ar, ps).
- PostgreSQL runs: the phase 48 Summary p95 and the full backend suite (both so far only on SQLite).
- `make integration` on a desktop (needs a desktop runner; not run here).
- Housekeeping: Docker Desktop was started for the Envoy container and left running; commit `1f9fc1b` (another agent's) swept in `app/android/.kotlin/sessions/*.salive` and a Gradle problems report under `app/android/build/reports/`; remove them from git and add them to `.gitignore`.

## Notes: review fixes (part G)

Lazy pages: `TfPage.builder` (itemBuilder rows plus a `pinned` header above the list) now backs members, audit and automations; the members search field and the audit filters sit above the list, so typed text survives scrolling (`tf_page_builder_test.dart`). The timesheet and import pages stay eager on purpose (a grid, and a wizard whose state must not be disposed). `TfStickySaveBar` is passed through `TfPage.bottom` from the workspace general section, so it stays visible while the page scrolls (`settings_sticky_bar_test.dart`). `TfRadioTile` is one tab stop and one announced radio (checked, in a group, enabled or not); `TfInteractive` now states tap and focus on labelled controls. `TfMenu` and `TfSelect` entries announce `selected`. The menu panel keeps a transparent margin so its shadow is not clipped (`tf_menu_panel_test.dart` golden, with shadows on). Tabs re-measure on size change and draw the chosen underline from the first frame; skeleton shimmer follows the reading direction and restarts when reduce-motion is switched off.
