import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/app_router.dart';
import 'package:taskforge/features/search/application/search_providers.dart';
import 'package:taskforge/features/search/domain/search.dart';
import 'package:taskforge/features/shortcuts/data/shortcuts_client.dart';

import '../projects/fakes.dart';
import '../projects/projects_test_support.dart';
import '../search/fakes.dart';
import '../tasks/fakes.dart';
import 'fakes.dart';

Finder key(String k) => find.byKey(Key(k));

Future<
  ({Pumped pumped, FakeShortcutsClient shortcuts, FakeSearchClient search})
>
open(
  WidgetTester tester, {
  FakeShortcutsClient? shortcuts,
  FakeSearchClient? search,
  String at = '/',
  Size size = const Size(1400, 1200),
}) async {
  final fake = shortcuts ?? FakeShortcutsClient();
  final searcher = search ?? FakeSearchClient();
  final pumped = await pumpProjects(
    tester,
    projects: [project('p1', 'Web')],
    tasks: FakeTasksClient([task('a', 'Alpha')]),
    shortcuts: fake,
    size: size,
    overrides: [searchClientProvider.overrideWithValue(searcher)],
  );
  await pumped.go(tester, at);
  return (pumped: pumped, shortcuts: fake, search: searcher);
}

Future<void> chord(
  WidgetTester tester,
  LogicalKeyboardKey key, {
  bool ctrl = false,
  bool alt = false,
  bool shift = false,
}) async {
  if (ctrl) await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
  if (alt) await tester.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
  if (shift) await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
  await tester.sendKeyEvent(key);
  if (shift) await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
  if (alt) await tester.sendKeyUpEvent(LogicalKeyboardKey.altLeft);
  if (ctrl) await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
  await tester.pumpAndSettle();
}

/// [keys] in the cheat sheet's row of [action] (the sidebar shows them too).
Finder inRow(String action, String keys) =>
    find.descendant(of: key('cheat-$action'), matching: find.text(keys));

String location(Pumped pumped) => pumped.container
    .read(routerProvider)
    .routeInformationProvider
    .value
    .uri
    .toString();

void main() {
  testWidgets('Ctrl+K opens the palette, typing filters, Enter runs', (
    tester,
  ) async {
    final h = await open(tester);

    await chord(tester, LogicalKeyboardKey.keyK, ctrl: true);
    expect(key('palette-field'), findsOneWidget);

    await tester.enterText(key('palette-field'), '> inbo');
    await tester.pump();
    expect(key('palette-row-nav.inbox'), findsOneWidget);
    expect(key('palette-row-nav.members'), findsNothing);

    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();

    expect(key('palette-field'), findsNothing);
    expect(location(h.pumped), '/inbox');
  });

  testWidgets('Escape closes the palette without running anything', (
    tester,
  ) async {
    final h = await open(tester);

    await chord(tester, LogicalKeyboardKey.keyK, ctrl: true);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();

    expect(key('palette-field'), findsNothing);
    expect(location(h.pumped), '/');
  });

  testWidgets('the arrow keys move the highlight', (tester) async {
    final h = await open(tester);

    await chord(tester, LogicalKeyboardKey.keyK, ctrl: true);
    await tester.enterText(key('palette-field'), '> go');
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();

    // Home is where we are, so it is not offered; the second row ran.
    expect(location(h.pumped), isNot('/'));
  });

  testWidgets('a project page is not offered outside a project', (
    tester,
  ) async {
    await open(tester, at: '/inbox');
    await chord(tester, LogicalKeyboardKey.keyK, ctrl: true);
    await tester.enterText(key('palette-field'), '> workflow');
    await tester.pump();
    expect(key('palette-row-project.workflow'), findsNothing);
  });

  testWidgets('a project page is offered inside a project', (tester) async {
    await open(tester, at: '/projects/p1');
    await chord(tester, LogicalKeyboardKey.keyK, ctrl: true);
    await tester.enterText(key('palette-field'), '> workflow');
    await tester.pump();
    expect(key('palette-row-project.workflow'), findsOneWidget);
  });

  testWidgets('# looks only for projects and a hit is followed', (
    tester,
  ) async {
    final search = FakeSearchClient(
      answer: (text, types, cursor) => const SearchResults(
        hits: {
          SearchKind.project: [
            SearchHit(
              kind: SearchKind.project,
              id: 'p1',
              projectId: 'p1',
              title: 'Web',
              key: 'WEB',
            ),
          ],
        },
      ),
    );
    final h = await open(tester, search: search);

    await chord(tester, LogicalKeyboardKey.keyK, ctrl: true);
    await tester.enterText(key('palette-field'), '#we');
    await tester.pump(searchDebounce);
    await tester.pumpAndSettle();

    expect(search.queries.last.types, [SearchKind.project]);
    expect(search.queries.last.text, 'we');
    expect(key('palette-row-nav.inbox'), findsNothing); // no actions with #
    await tester.tap(key('palette-hit-project-p1'));
    await tester.pumpAndSettle();
    expect(location(h.pumped), '/projects/p1');
  });

  testWidgets('@ looks only for people', (tester) async {
    final search = FakeSearchClient();
    await open(tester, search: search);

    await chord(tester, LogicalKeyboardKey.keyK, ctrl: true);
    await tester.enterText(key('palette-field'), '@zo');
    await tester.pump(searchDebounce);
    await tester.pumpAndSettle();

    expect(search.queries.last.types, [SearchKind.member]);
  });

  testWidgets('a key bound to an action runs it, but not while typing', (
    tester,
  ) async {
    final h = await open(tester);

    await chord(tester, LogicalKeyboardKey.keyI, alt: true);
    expect(location(h.pumped), '/inbox');

    // "?" is not typed into a text field as a command.
    await chord(tester, LogicalKeyboardKey.keyK, ctrl: true);
    await tester.enterText(key('palette-field'), '');
    await tester.sendKeyEvent(LogicalKeyboardKey.slash);
    await tester.pumpAndSettle();
    expect(key('search-field'), findsNothing);
  });

  testWidgets('? opens the cheat sheet built from the registry', (
    tester,
  ) async {
    await open(tester);

    await chord(tester, LogicalKeyboardKey.slash, shift: true);

    expect(find.text('Keyboard shortcuts'), findsWidgets);
    expect(key('cheat-nav.inbox'), findsOneWidget);
    expect(inRow('nav.inbox', 'Alt+I'), findsOneWidget);
  });

  testWidgets('rebinding saves, shows the new keys and takes effect', (
    tester,
  ) async {
    final h = await open(tester);

    await chord(tester, LogicalKeyboardKey.slash, shift: true);
    await tester.tap(key('rebind-nav.inbox'));
    await tester.pumpAndSettle();
    await chord(tester, LogicalKeyboardKey.keyJ, alt: true);

    expect(find.text('Alt+J'), findsWidgets);
    await tester.tap(key('rebind-save'));
    await tester.pumpAndSettle();

    expect(h.shortcuts.stored['nav.inbox'], 'alt+j');
    expect(find.text('Changed by you'), findsOneWidget);
    expect(inRow('nav.inbox', 'Alt+J'), findsOneWidget);

    await tester.tap(key('cheat-close'));
    await tester.pumpAndSettle();
    await chord(tester, LogicalKeyboardKey.keyJ, alt: true);
    expect(location(h.pumped), '/inbox');
  });

  testWidgets('a key another action holds is refused and names it', (
    tester,
  ) async {
    final h = await open(tester);

    await chord(tester, LogicalKeyboardKey.slash, shift: true);
    await tester.tap(key('rebind-nav.inbox'));
    await tester.pumpAndSettle();
    await chord(tester, LogicalKeyboardKey.keyM, alt: true); // Members has it

    expect(find.textContaining('Already used by "Members"'), findsOneWidget);
    final save = tester.widget<FilledButton>(key('rebind-save'));
    expect(save.onPressed, isNull);
    expect(h.shortcuts.calls, isEmpty);
  });

  testWidgets('a key the browser keeps is refused', (tester) async {
    await open(tester);

    await chord(tester, LogicalKeyboardKey.slash, shift: true);
    await tester.tap(key('rebind-nav.inbox'));
    await tester.pumpAndSettle();
    await chord(tester, LogicalKeyboardKey.keyW, ctrl: true);

    expect(find.textContaining('The browser keeps'), findsOneWidget);
  });

  testWidgets('the server refusing a save says so and keeps the old keys', (
    tester,
  ) async {
    final shortcuts = FakeShortcutsClient();
    await open(tester, shortcuts: shortcuts);

    await chord(tester, LogicalKeyboardKey.slash, shift: true);
    await tester.tap(key('rebind-nav.inbox'));
    await tester.pumpAndSettle();
    await chord(tester, LogicalKeyboardKey.keyJ, alt: true);
    shortcuts.failWith = const ShortcutException(ShortcutFailure.network);
    await tester.tap(key('rebind-save'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Could not save'), findsOneWidget);
    expect(shortcuts.stored, isEmpty);
  });

  testWidgets('keys saved on another device apply here', (tester) async {
    final h = await open(
      tester,
      shortcuts: FakeShortcutsClient({'nav.inbox': 'alt+j'}),
    );

    await chord(tester, LogicalKeyboardKey.keyI, alt: true); // old key: nothing
    expect(location(h.pumped), '/');
    await chord(tester, LogicalKeyboardKey.keyJ, alt: true);
    expect(location(h.pumped), '/inbox');
  });

  testWidgets('Use default drops the override', (tester) async {
    final h = await open(
      tester,
      shortcuts: FakeShortcutsClient({'nav.inbox': 'alt+j'}),
    );

    await chord(tester, LogicalKeyboardKey.slash, shift: true);
    await tester.tap(key('rebind-nav.inbox'));
    await tester.pumpAndSettle();
    await tester.tap(key('rebind-reset'));
    await tester.pumpAndSettle();

    expect(h.shortcuts.stored, isEmpty);
    expect(inRow('nav.inbox', 'Alt+I'), findsOneWidget);
  });

  testWidgets('offline, the defaults still work', (tester) async {
    final shortcuts = FakeShortcutsClient()
      ..failWith = const ShortcutException(ShortcutFailure.network);
    final h = await open(tester, shortcuts: shortcuts);

    await chord(tester, LogicalKeyboardKey.keyI, alt: true);

    expect(location(h.pumped), '/inbox');
  });

  testWidgets('on a phone a button opens the actions as a sheet', (
    tester,
  ) async {
    final h = await open(tester, size: const Size(390, 800));

    await tester.tap(key('quick-actions'));
    await tester.pumpAndSettle();
    expect(key('quick-nav.inbox'), findsOneWidget);
    await tester.tap(key('quick-nav.inbox'));
    await tester.pumpAndSettle();

    expect(location(h.pumped), '/inbox');
  });
}
