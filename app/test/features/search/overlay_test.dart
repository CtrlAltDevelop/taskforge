import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/app_router.dart';
import 'package:taskforge/features/search/application/search_providers.dart';
import 'package:taskforge/features/search/domain/search.dart';
import 'package:taskforge/features/search/presentation/search_hotkeys.dart';
import 'package:taskforge/features/search/presentation/search_overlay.dart';

import '../projects/fakes.dart';
import '../projects/projects_test_support.dart';
import '../tasks/fakes.dart';
import 'fakes.dart';

Finder key(String k) => find.byKey(Key(k));

Future<({Pumped pumped, FakeSearchClient search})> open(
  WidgetTester tester, {
  FakeSearchClient? client,
}) async {
  final search = client ?? FakeSearchClient();
  final pumped = await pumpProjects(
    tester,
    projects: [project('p1', 'Web')],
    tasks: FakeTasksClient([task('a', 'Alpha')]),
    overrides: [searchClientProvider.overrideWithValue(search)],
  );
  await pumped.go(tester, '/');
  return (pumped: pumped, search: search);
}

Future<void> type(WidgetTester tester, String text) async {
  await tester.enterText(key('search-field'), text);
  await tester.pump(searchDebounce);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'typing asks once the typing pauses and shows grouped, bold hits',
    (tester) async {
      final search = FakeSearchClient(
        answer: (text, types, cursor) => SearchResults(
          hits: {
            SearchKind.task: [
              taskHit(
                'a',
                'Fix login',
                marks: const [Mark(4, 9)],
                snippet: 'cannot login',
                project: 'p1',
              ),
            ],
            SearchKind.project: const [
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
      await open(tester, client: search);

      await tester.tap(key('open-search'));
      await tester.pumpAndSettle();
      await tester.enterText(key('search-field'), 'l');
      await tester.enterText(key('search-field'), 'lo');
      await tester.enterText(key('search-field'), 'login');
      await tester.pump(const Duration(milliseconds: 100));
      expect(search.queries, isEmpty); // still typing
      await tester.pump(searchDebounce);
      await tester.pumpAndSettle();

      expect(search.queries.map((q) => q.text), ['login']);
      Finder inBox(String text) => find.descendant(
        of: find.byType(SearchOverlay),
        matching: find.text(text),
      );
      expect(inBox('Tasks'), findsOneWidget);
      expect(inBox('Projects'), findsOneWidget);
      final title = tester.widget<Text>(
        find
            .descendant(of: key('hit-task-a'), matching: find.byType(Text))
            .first,
      );
      final bold = (title.textSpan! as TextSpan).children!
          .whereType<TextSpan>()
          .where((s) => s.style?.fontWeight == FontWeight.w700)
          .map((s) => s.text);
      expect(bold, ['login']);
    },
  );

  testWidgets(
    'Down then Enter opens the second result and remembers the text',
    (tester) async {
      final search = FakeSearchClient(
        answer: (text, types, cursor) => SearchResults(
          hits: {
            SearchKind.task: [taskHit('a', 'One'), taskHit('b', 'Two')],
          },
        ),
      );
      final opened = await open(tester, client: search);
      await tester.tap(key('open-search'));
      await tester.pumpAndSettle();
      await type(tester, 'o');

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(search.remembered, ['o']);
      expect(
        opened.pumped.container.read(routerProvider).state.uri.toString(),
        '/projects/p1?task=b',
      );
      expect(key('search-field'), findsNothing);
    },
  );

  testWidgets('an id jump is offered first', (tester) async {
    final search = FakeSearchClient(
      answer: (text, types, cursor) =>
          SearchResults(jump: taskHit('j', 'Jumped')),
    );
    await open(tester, client: search);
    await tester.tap(key('open-search'));
    await tester.pumpAndSettle();
    await type(tester, 'WEB-1');

    expect(find.text('Go to'), findsOneWidget);
    expect(key('hit-task-j'), findsOneWidget);
  });

  testWidgets('chips add and remove operators, and the question follows', (
    tester,
  ) async {
    final search = FakeSearchClient();
    await open(tester, client: search);
    await tester.tap(key('open-search'));
    await tester.pumpAndSettle();
    await type(tester, 'deploy');

    await tester.tap(key('chip-assignee:me'));
    await tester.pump(searchDebounce);
    await tester.pumpAndSettle();
    expect(search.queries.last.text, 'deploy assignee:me');

    await tester.tap(key('chip-assignee:me'));
    await tester.pump(searchDebounce);
    await tester.pumpAndSettle();
    expect(search.queries.last.text, 'deploy');
  });

  testWidgets(
    'nothing found explains what to try; recent searches fill an empty box',
    (tester) async {
      final search = FakeSearchClient()..recentValue = ['invoice'];
      await open(tester, client: search);
      await tester.tap(key('open-search'));
      await tester.pumpAndSettle();
      expect(key('recent-invoice'), findsOneWidget);

      await tester.tap(key('recent-invoice'));
      await tester.pump(searchDebounce);
      await tester.pumpAndSettle();

      expect(search.queries.last.text, 'invoice');
      expect(key('search-empty'), findsOneWidget);
    },
  );

  testWidgets('an empty box with no history shows tips', (tester) async {
    await open(tester);
    await tester.tap(key('open-search'));
    await tester.pumpAndSettle();

    expect(key('search-tips'), findsOneWidget);
  });

  testWidgets('a failed search says so and Retry asks again', (tester) async {
    final search = FakeSearchClient(
      answer: (text, types, cursor) => SearchResults(
        hits: {
          SearchKind.task: [taskHit('a', 'Back again')],
        },
      ),
    )..failNext = const SearchException(SearchFailure.rateLimited);
    await open(tester, client: search);
    await tester.tap(key('open-search'));
    await tester.pumpAndSettle();
    await type(tester, 'x');

    expect(find.textContaining('Too many searches'), findsOneWidget);
    await tester.tap(key('search-retry'));
    await tester.pump(searchDebounce);
    await tester.pumpAndSettle();

    expect(key('hit-task-a'), findsOneWidget);
  });

  testWidgets('Show more adds the next page of that kind only', (tester) async {
    final search = FakeSearchClient(
      answer: (text, types, cursor) => cursor.isEmpty
          ? SearchResults(
              hits: {
                SearchKind.task: [taskHit('a', 'First')],
              },
              cursors: {SearchKind.task: 'c1'},
            )
          : SearchResults(
              hits: {
                SearchKind.task: [taskHit('b', 'Second')],
              },
            ),
    );
    await open(tester, client: search);
    await tester.tap(key('open-search'));
    await tester.pumpAndSettle();
    await type(tester, 'page');

    await tester.tap(key('more-task'));
    await tester.pumpAndSettle();

    expect(search.queries.last.types, [SearchKind.task]);
    expect(search.queries.last.cursor, 'c1');
    expect(key('hit-task-a'), findsOneWidget);
    expect(key('hit-task-b'), findsOneWidget);
    expect(key('more-task'), findsNothing);
  });

  testWidgets('the slash key and Ctrl+K open the box, but not while typing', (
    tester,
  ) async {
    await open(tester);

    await tester.sendKeyEvent(LogicalKeyboardKey.slash);
    await tester.pumpAndSettle();
    expect(key('search-field'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(key('search-field'), findsNothing);

    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyK);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pumpAndSettle();
    expect(key('search-field'), findsOneWidget);
  });

  testWidgets('a slash typed into a text field is text, not a shortcut', (
    tester,
  ) async {
    // No router here: opening the search would throw, so a pass means the
    // guard held.
    await tester.pumpWidget(
      const MaterialApp(
        home: SearchHotkeys(child: Scaffold(body: TextField(autofocus: true))),
      ),
    );
    await tester.pump();

    await tester.sendKeyEvent(LogicalKeyboardKey.slash);
    await tester.pump();

    expect(tester.takeException(), isNull);
  });

  testWidgets('Show more survives a newer search and two pages at once', (
    tester,
  ) async {
    final search = FakeSearchClient(
      answer: (text, types, cursor) {
        if (cursor.isEmpty) {
          return SearchResults(
            hits: {
              SearchKind.task: [taskHit('a', 'T $text')],
              SearchKind.project: const [
                SearchHit(
                  kind: SearchKind.project,
                  id: 'p1',
                  projectId: 'p1',
                  title: 'Web',
                ),
              ],
            },
            cursors: {SearchKind.task: 'ct', SearchKind.project: 'cp'},
          );
        }
        return SearchResults(
          hits: {
            types.single: [
              if (types.single == SearchKind.task)
                taskHit('b', 'More tasks')
              else
                const SearchHit(
                  kind: SearchKind.project,
                  id: 'p2',
                  projectId: 'p2',
                  title: 'More projects',
                ),
            ],
          },
        );
      },
    );
    await open(tester, client: search);
    await tester.tap(key('open-search'));
    await tester.pumpAndSettle();
    await type(tester, 'first');

    // Two pages in flight together: neither may wipe the other.
    await tester.tap(key('more-task'));
    await tester.tap(key('more-project'));
    await tester.pumpAndSettle();
    expect(find.text('More tasks', findRichText: true), findsOneWidget);
    expect(find.text('More projects', findRichText: true), findsOneWidget);

    // A newer search starts clean: its Show more works again.
    await type(tester, 'second');
    expect(key('more-task'), findsOneWidget);
    await tester.tap(key('more-task'));
    await tester.pumpAndSettle();
    expect(find.text('More tasks', findRichText: true), findsOneWidget);
  });
}
