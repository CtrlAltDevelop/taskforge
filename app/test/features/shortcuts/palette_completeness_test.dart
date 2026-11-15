import 'dart:convert';
import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/app_router.dart';
import 'package:taskforge/core/actions/chord.dart';
import 'package:taskforge/features/search/application/search_providers.dart';
import 'package:taskforge/features/search/domain/search.dart';
import 'package:taskforge/features/shortcuts/application/builtin_actions.dart';
import 'package:taskforge/features/shortcuts/application/local_prefs.dart';
import 'package:taskforge/features/shortcuts/data/shortcuts_client.dart';
import 'package:taskforge/features/shortcuts/presentation/command_palette.dart';

import '../projects/fakes.dart';
import '../projects/projects_test_support.dart';
import '../search/fakes.dart';
import '../tasks/fakes.dart';
import 'fakes.dart';

Finder key(String k) => find.byKey(Key(k));

Future<({Pumped pumped, FakeShortcutsClient shortcuts, MemoryPrefs prefs})>
open(
  WidgetTester tester, {
  FakeShortcutsClient? shortcuts,
  FakeSearchClient? search,
  MemoryPrefs? prefs,
  String role = 'Owner',
  List<String> workspaces = const ['w1'],
  String at = '/',
  Size size = const Size(1400, 1200),
}) async {
  final fake = shortcuts ?? FakeShortcutsClient();
  final memory = prefs ?? MemoryPrefs();
  final pumped = await pumpProjects(
    tester,
    role: role,
    workspaces: workspaces,
    projects: [project('p1', 'Web')],
    tasks: FakeTasksClient([task('a', 'Alpha')]),
    shortcuts: fake,
    size: size,
    overrides: [
      searchClientProvider.overrideWithValue(search ?? FakeSearchClient()),
      localPrefsProvider.overrideWithValue(memory),
    ],
  );
  await pumped.go(tester, at);
  return (pumped: pumped, shortcuts: fake, prefs: memory);
}

Future<void> chord(
  WidgetTester tester,
  LogicalKeyboardKey key, {
  bool ctrl = false,
  bool alt = false,
}) async {
  if (ctrl) await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
  if (alt) await tester.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
  await tester.sendKeyEvent(key);
  if (alt) await tester.sendKeyUpEvent(LogicalKeyboardKey.altLeft);
  if (ctrl) await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
  await tester.pumpAndSettle();
}

String location(Pumped p) => p.container
    .read(routerProvider)
    .routeInformationProvider
    .value
    .uri
    .toString();

Future<void> askPalette(WidgetTester tester, String text) async {
  await chord(tester, LogicalKeyboardKey.keyK, ctrl: true);
  await tester.enterText(key('palette-field'), text);
  await tester.pump(searchDebounce);
  await tester.pumpAndSettle();
}

void main() {
  group('browser-reserved chords', () {
    // The server reads the same file (its own test checks every chord).
    final shared = (jsonDecode(
      File('../backend/src/infrastructure/shortcuts/reserved_chords.json')
          .readAsStringSync(),
    ) as List).cast<String>();

    test('the app and the server hold the same list', () {
      expect(browserReserved, shared.toSet());
    });

    for (final wire in shared) {
      test('$wire is refused as a binding', () {
        expect(Chord.parse(wire)!.isBrowserReserved, isTrue);
      });
    }

    test('no built-in action defaults to a reserved chord', () {
      for (final a in builtInActions) {
        expect(browserReserved, isNot(contains(a.defaultKeys)), reason: a.id);
      }
    });
  });

  group('the actions people reach for', () {
    for (final (text, id) in [
      ('sign out', 'account.sign_out'),
      ('dark mode', 'theme.toggle'),
      ('offline', 'nav.offline'),
      ('import', 'nav.import'),
      ('create a project', 'project.create'),
      ('create a doc', 'doc.create'),
      ('create a dashboard', 'dashboard.create'),
      ('invite', 'member.invite'),
    ]) {
      testWidgets('"$text" finds $id', (tester) async {
        await open(tester);
        await askPalette(tester, '> $text');
        expect(key('palette-row-$id'), findsOneWidget);
      });
    }

    testWidgets('switching workspace is offered only with more than one', (
      tester,
    ) async {
      await open(tester);
      await askPalette(tester, '> switch workspace');
      expect(key('palette-row-workspace.switch'), findsNothing);
    });

    testWidgets('and with two, it picks the other and goes home', (
      tester,
    ) async {
      final h = await open(tester, workspaces: const ['w1', 'w2']);
      await askPalette(tester, '> switch workspace');
      await tester.tap(key('palette-row-workspace.switch'));
      await tester.pumpAndSettle();
      await tester.tap(key('pick-workspace-w2'));
      await tester.pumpAndSettle();
      expect(location(h.pumped), '/');
      expect(find.text('WS w2'), findsWidgets);
    });

    testWidgets('a viewer is not offered what needs a permission', (
      tester,
    ) async {
      await open(tester, role: 'Viewer');
      await askPalette(tester, '> create a project');
      expect(key('palette-row-project.create'), findsNothing);
      await tester.enterText(key('palette-field'), '> invite');
      await tester.pumpAndSettle();
      expect(key('palette-row-member.invite'), findsNothing);
      await tester.enterText(key('palette-field'), '> import');
      await tester.pumpAndSettle();
      expect(key('palette-row-nav.import'), findsNothing);
    });

    testWidgets('toggle dark mode flips the theme and keeps it', (
      tester,
    ) async {
      final h = await open(tester);
      expect(h.pumped.container.read(themeModeProvider), ThemeMode.system);
      await askPalette(tester, '> dark mode');
      await tester.tap(key('palette-row-theme.toggle'));
      await tester.pumpAndSettle();
      final after = h.pumped.container.read(themeModeProvider);
      expect(after, isNot(ThemeMode.system));
      expect(await h.prefs.read('theme.mode'), after.name);
    });

    testWidgets('/offline is reached from the palette', (tester) async {
      final h = await open(tester);
      await askPalette(tester, '> offline');
      await tester.tap(key('palette-row-nav.offline'));
      await tester.pumpAndSettle();
      expect(location(h.pumped), '/offline');
    });

    testWidgets('create a doc asks for a title and opens the page', (
      tester,
    ) async {
      final h = await open(tester);
      await askPalette(tester, '> create a doc');
      await tester.tap(key('palette-row-doc.create'));
      await tester.pumpAndSettle();
      await tester.enterText(key('prompt-field'), 'Plan');
      await tester.tap(key('prompt-ok'));
      await tester.pumpAndSettle();
      expect(location(h.pumped), startsWith('/docs/'));
    });
  });

  group('recent actions', () {
    test('are kept on the device and found again after a restart', () async {
      final prefs = MemoryPrefs();
      final first = ProviderContainer(
        overrides: [localPrefsProvider.overrideWithValue(prefs)],
      );
      first.read(recentActionsProvider.notifier)
        ..ran('nav.inbox')
        ..ran('nav.members');
      expect(first.read(recentActionsProvider), ['nav.members', 'nav.inbox']);
      first.dispose();

      final second = ProviderContainer(
        overrides: [localPrefsProvider.overrideWithValue(prefs)],
      );
      addTearDown(second.dispose);
      second.read(recentActionsProvider);
      await Future<void>.delayed(Duration.zero);
      expect(second.read(recentActionsProvider), ['nav.members', 'nav.inbox']);
    });

    test('what was run before the saved list loaded stays first', () async {
      final prefs = MemoryPrefs();
      await prefs.write('recent.actions', 'nav.inbox,nav.docs');
      final c = ProviderContainer(
        overrides: [localPrefsProvider.overrideWithValue(prefs)],
      );
      addTearDown(c.dispose);
      c.read(recentActionsProvider.notifier).ran('nav.members');
      await Future<void>.delayed(Duration.zero);
      expect(c.read(recentActionsProvider), [
        'nav.members',
        'nav.inbox',
        'nav.docs',
      ]);
    });
  });

  group('the palette', () {
    testWidgets('a task id jumps to the task', (tester) async {
      final search = FakeSearchClient(
        answer: (text, types, cursor) => SearchResults(
          jump: SearchHit(
            kind: SearchKind.task,
            id: 'a',
            taskId: 'a',
            projectId: 'p1',
            title: 'Alpha',
            key: 'WEB-1',
          ),
        ),
      );
      final h = await open(tester, search: search);
      await askPalette(tester, 'WEB-1');
      expect(search.queries.last.text, 'WEB-1');
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(location(h.pumped), '/projects/p1?task=a');
    });

    testWidgets('> asks for actions only and never searches', (tester) async {
      final search = FakeSearchClient();
      await open(tester, search: search);
      await askPalette(tester, '> inbox');
      expect(search.queries, isEmpty);
      expect(key('palette-row-nav.inbox'), findsOneWidget);
    });
  });

  group('shortcut hints follow the bindings', () {
    testWidgets('the sidebar shows the keys, and a rebinding changes them', (
      tester,
    ) async {
      final h = await open(
        tester,
        shortcuts: FakeShortcutsClient({'nav.inbox': 'alt+j'}),
      );
      expect(
        find.descendant(
          of: key('hint-nav.inbox'),
          matching: find.text('Alt+J'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(of: key('hint-search.open'), matching: find.text('/')),
        findsOneWidget,
      );
      expect(h.shortcuts.stored['nav.inbox'], 'alt+j');
    });

    testWidgets('an unbound action shows no hint', (tester) async {
      await open(tester, shortcuts: FakeShortcutsClient({'nav.inbox': ''}));
      expect(key('hint-nav.inbox'), findsNothing);
    });
  });

  group('Use default', () {
    testWidgets('is refused while another action holds the default keys', (
      tester,
    ) async {
      // Inbox was moved away; Members was moved onto Inbox's default.
      final shortcuts = FakeShortcutsClient({
        'nav.inbox': 'alt+j',
        'nav.members': 'alt+i',
      });
      await open(tester, shortcuts: shortcuts);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.slash);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      await tester.pumpAndSettle();
      await tester.tap(key('rebind-nav.inbox'));
      await tester.pumpAndSettle();
      await tester.tap(key('rebind-reset'));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('default keys are used by "Members"'),
        findsOneWidget,
      );
      expect(shortcuts.calls, isEmpty);
      expect(shortcuts.stored['nav.inbox'], 'alt+j');
    });

    testWidgets('the server refusing it is shown too', (tester) async {
      final shortcuts = FakeShortcutsClient({'nav.inbox': 'alt+j'});
      await open(tester, shortcuts: shortcuts);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.slash);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      await tester.pumpAndSettle();
      await tester.tap(key('rebind-nav.inbox'));
      await tester.pumpAndSettle();
      // Another device bound Members to Inbox's default meanwhile.
      shortcuts.stored['nav.members'] = 'alt+i';
      await tester.tap(key('rebind-reset'));
      await tester.pumpAndSettle();
      expect(find.textContaining('default keys are used'), findsOneWidget);
    });
  });

  group('the rebind dialog when saving fails', () {
    Future<FakeShortcutsClient> openDialog(
      WidgetTester tester,
      Map<String, String> initial,
    ) async {
      final shortcuts = FakeShortcutsClient(initial);
      await open(tester, shortcuts: shortcuts);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.slash);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      await tester.pumpAndSettle();
      await tester.tap(key('rebind-nav.inbox'));
      await tester.pumpAndSettle();
      return shortcuts;
    }

    testWidgets('"No key" says it could not save and stays open', (
      tester,
    ) async {
      final s = await openDialog(tester, {});
      s.failWith = const ShortcutException(ShortcutFailure.network);
      await tester.tap(key('rebind-unbind'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Could not save'), findsOneWidget);
      expect(key('rebind-chord'), findsOneWidget);
    });

    testWidgets('"Use default" says it could not save and stays open', (
      tester,
    ) async {
      final s = await openDialog(tester, {'nav.inbox': 'alt+j'});
      s.failWith = const ShortcutException(ShortcutFailure.network);
      await tester.tap(key('rebind-reset'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Could not save'), findsOneWidget);
    });
  });

  group('per-view actions', () {
    testWidgets('a project page offers the other views, not its own', (
      tester,
    ) async {
      await open(tester, at: '/projects/p1');
      await askPalette(tester, '> view');
      expect(key('palette-row-view.list'), findsNothing);
      expect(key('palette-row-view.board'), findsOneWidget);
      expect(key('palette-row-view.calendar'), findsOneWidget);
    });

    testWidgets('they are not offered off a project page', (tester) async {
      await open(tester);
      await askPalette(tester, '> view');
      expect(key('palette-row-view.board'), findsNothing);
    });

    testWidgets('Alt+2 shows the board and Alt+1 the list again', (
      tester,
    ) async {
      final h = await open(tester, at: '/projects/p1');
      await chord(tester, LogicalKeyboardKey.digit2, alt: true);
      expect(location(h.pumped), '/projects/p1?view=board');
      expect(key('board-toolbar'), findsWidgets);
      await chord(tester, LogicalKeyboardKey.digit1, alt: true);
      expect(location(h.pumped), '/projects/p1');
      expect(key('task-list'), findsWidgets);
    });

    testWidgets('renaming belongs to the list view only', (tester) async {
      await open(tester, at: '/projects/p1');
      await askPalette(tester, '> rename');
      expect(key('palette-row-task.rename'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      await chord(tester, LogicalKeyboardKey.digit2, alt: true);
      await askPalette(tester, '> rename');
      expect(key('palette-row-task.rename'), findsNothing);
    });

    testWidgets('F2 renames the row under the cursor, by the registry', (
      tester,
    ) async {
      await open(tester, at: '/projects/p1');
      await tester.tap(key('task-a'));
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.f2);
      await tester.pumpAndSettle();
      expect(key('rename-a'), findsOneWidget);
    });

    testWidgets('and not on F2 once it is bound to something else', (
      tester,
    ) async {
      await open(
        tester,
        shortcuts: FakeShortcutsClient({'task.rename': 'alt+r'}),
        at: '/projects/p1',
      );
      await tester.tap(key('task-a'));
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.f2);
      await tester.pumpAndSettle();
      expect(key('rename-a'), findsNothing);
      await chord(tester, LogicalKeyboardKey.keyR, alt: true);
      expect(key('rename-a'), findsOneWidget);
    });
  });

  group('the open task is in the route', () {
    testWidgets('opening a task from the list puts ?task= in the URL', (
      tester,
    ) async {
      final h = await open(tester, at: '/projects/p1');
      await tester.tap(key('task-a'));
      await tester.pumpAndSettle();
      expect(location(h.pumped), contains('task=a'));
      // ...so the task's own actions are in the palette.
      await askPalette(tester, '> assign');
      expect(key('palette-row-task.assign_me'), findsOneWidget);
    });

    testWidgets('closing it takes it out of the URL again', (tester) async {
      final h = await open(tester, at: '/projects/p1?task=a');
      expect(location(h.pumped), contains('task=a'));
      await tester.tap(find.byIcon(Icons.close).first);
      await tester.pumpAndSettle();
      expect(location(h.pumped), isNot(contains('task=')));
    });

    testWidgets('a link to another task of the project opens it', (
      tester,
    ) async {
      final h = await open(tester, at: '/projects/p1');
      h.pumped.container.read(routerProvider).go('/projects/p1?task=a');
      await tester.pumpAndSettle();
      expect(key('task-detail'), findsOneWidget);
    });
  });

  group('the phone sheet', () {
    testWidgets('lists what is available and runs the one tapped', (
      tester,
    ) async {
      final h = await open(tester, size: const Size(390, 800));
      await tester.tap(key('quick-actions'));
      await tester.pumpAndSettle();
      final sheet = find
          .descendant(
            of: find.byType(BottomSheet),
            matching: find.byType(Scrollable),
          )
          .first;
      await tester.scrollUntilVisible(
        key('quick-account.sign_out'),
        200,
        scrollable: sheet,
      );
      expect(key('quick-account.sign_out'), findsOneWidget);
      await tester.drag(sheet, const Offset(0, 5000)); // back to the top
      await tester.pumpAndSettle();
      await tester.tap(key('quick-nav.inbox'));
      await tester.pumpAndSettle();
      expect(location(h.pumped), '/inbox');
      expect(
        h.pumped.container.read(recentActionsProvider),
        contains('nav.inbox'),
      );
    });
  });
}
