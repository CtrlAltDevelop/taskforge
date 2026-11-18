import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:taskforge/app_router.dart';
import 'package:taskforge/features/filters/application/filters_providers.dart';
import 'package:taskforge/features/filters/domain/filter_query.dart';
import 'package:taskforge/features/home/application/home_providers.dart';
import 'package:taskforge/features/home/domain/home.dart';
import 'package:taskforge/features/shortcuts/application/local_prefs.dart';

import '../projects/fakes.dart';
import '../projects/projects_test_support.dart';
import '../tasks/fakes.dart';
import '../workflows/fakes.dart';
import 'fakes.dart';

MyWorkItem _item(
  String id,
  String title, {
  bool assigned = true,
  bool watching = false,
}) => MyWorkItem(
  task: homeTask(id, title: title, number: 1),
  assigned: assigned,
  watching: watching,
);

Future<Pumped> _open(
  WidgetTester t,
  FakeHomeClient home, {
  Size size = const Size(1400, 1000),
  List<Override> overrides = const [],
}) async {
  final app = await pumpProjects(
    t,
    projects: [project('p1', 'Web')],
    tasks: FakeTasksClient([task('a', 'One')]),
    workflows: FakeWorkflowsClient(defaultWorkflow()),
    home: home,
    size: size,
    overrides: [
      localPrefsProvider.overrideWithValue(MemoryPrefs()),
      ...overrides,
    ],
  );
  await app.go(t, '/my-work');
  return app;
}

Finder _key(String k) => find.byKey(Key(k));

void main() {
  group('the relation and include-done choice', () {
    ProviderContainer containerWith(MemoryPrefs prefs) {
      final c = ProviderContainer(
        overrides: [localPrefsProvider.overrideWithValue(prefs)],
      );
      addTearDown(c.dispose);
      return c;
    }

    test('are kept on this device and read back next time', () async {
      final prefs = MemoryPrefs();
      final first = containerWith(prefs);
      first
        ..read(myWorkOptionsProvider.notifier).relation(MyWorkRelation.watching)
        ..read(myWorkOptionsProvider.notifier).includeDone(on: true);

      final second = containerWith(prefs);
      await second.read(myWorkOptionsProvider.notifier).ready;
      final options = second.read(myWorkOptionsProvider);
      expect(options.relation, MyWorkRelation.watching);
      expect(options.includeDone, isTrue);
    });

    test('start from the defaults when nothing or garbage was saved', () async {
      final empty = containerWith(MemoryPrefs());
      await empty.read(myWorkOptionsProvider.notifier).ready;
      expect(empty.read(myWorkOptionsProvider).relation, MyWorkRelation.both);

      final prefs = MemoryPrefs();
      await prefs.write('mywork.options.v1', 'not json');
      final broken = containerWith(prefs);
      await broken.read(myWorkOptionsProvider.notifier).ready;
      expect(broken.read(myWorkOptionsProvider).includeDone, isFalse);
    });

    testWidgets('are applied the next time My work opens', (t) async {
      final prefs = MemoryPrefs();
      await prefs.write(
        'mywork.options.v1',
        '{"relation":"assigned","includeDone":true}',
      );
      final home = FakeHomeClient(assigned: [_item('a', 'Mine')]);
      await pumpProjects(
        t,
        projects: [project('p1', 'Web')],
        home: home,
        overrides: [localPrefsProvider.overrideWithValue(prefs)],
      );
      final app = ProviderScope.containerOf(
        t.element(find.byType(MaterialApp)),
      );
      app.read(routerProvider).go('/my-work');
      await t.pumpAndSettle();
      expect(home.myWorkQueries.last.relation, MyWorkRelation.assigned);
      expect(home.myWorkQueries.last.includeDone, isTrue);
    });
  });

  testWidgets('lists assigned and watched tasks and says which', (t) async {
    final home = FakeHomeClient(
      assigned: [
        _item('a', 'Mine'),
        _item('b', 'Followed', assigned: false, watching: true),
      ],
    );
    await _open(t, home);
    expect(find.text('Mine'), findsOneWidget);
    expect(find.text('Followed'), findsOneWidget);
    expect(find.textContaining('WEB-1 · Assigned'), findsOneWidget);
    expect(find.textContaining('WEB-1 · Watching'), findsOneWidget);
  });

  testWidgets('asks for assigned only, watching only, and with done', (
    t,
  ) async {
    final home = FakeHomeClient(assigned: [_item('a', 'Mine')]);
    await _open(t, home);
    expect(home.myWorkQueries.last.relation, MyWorkRelation.both);

    await t.tap(find.text('Watching').first);
    await t.pumpAndSettle();
    expect(home.myWorkQueries.last.relation, MyWorkRelation.watching);

    await t.tap(find.text('Assigned to me').first);
    await t.pumpAndSettle();
    expect(home.myWorkQueries.last.relation, MyWorkRelation.assigned);

    await t.tap(_key('mywork-include-done'));
    await t.pumpAndSettle();
    expect(home.myWorkQueries.last.includeDone, isTrue);
  });

  testWidgets('pages by cursor with Load more', (t) async {
    final home = FakeHomeClient()
      ..pages = {
        '': MyWorkPage([_item('a', 'First page')], nextCursor: 'c2'),
        'c2': MyWorkPage([_item('b', 'Second page')]),
      };
    await _open(t, home);
    expect(find.text('Second page'), findsNothing);
    await t.ensureVisible(_key('mywork-load-more'));
    await t.tap(_key('mywork-load-more'));
    await t.pumpAndSettle();
    expect(find.text('First page'), findsOneWidget);
    expect(find.text('Second page'), findsOneWidget);
    expect(_key('mywork-load-more'), findsNothing);
  });

  testWidgets('sends the shared filter as its AST', (t) async {
    final home = FakeHomeClient(assigned: [_item('a', 'Mine')]);
    final app = await _open(t, home);
    app.container
        .read(activeFilterProvider(myWorkFilterScope).notifier)
        .apply(
          const FilterQuery(
            root: FilterGroup(
              children: [
                FilterCondition(
                  field: 'priority',
                  cmp: 'eq',
                  values: [FilterValue.text('high')],
                ),
              ],
            ),
          ),
        );
    await t.pumpAndSettle();
    expect(home.myWorkQueries.last.filterAst, contains('priority'));
  });

  testWidgets('empty, empty under a filter, and failing each say so', (
    t,
  ) async {
    final home = FakeHomeClient();
    final app = await _open(t, home);
    expect(_key('mywork-empty'), findsOneWidget);

    app.container
        .read(activeFilterProvider(myWorkFilterScope).notifier)
        .apply(
          const FilterQuery(
            root: FilterGroup(
              children: [FilterCondition(field: 'priority', cmp: 'empty')],
            ),
          ),
        );
    await t.pumpAndSettle();
    expect(_key('mywork-no-match'), findsOneWidget);
    await t.tap(find.text('Clear filter'));
    await t.pumpAndSettle();
    expect(_key('mywork-empty'), findsOneWidget);

    home.myWorkError = const HomeException(HomeFailure.network);
    app.container.invalidate(myWorkProvider);
    await t.pumpAndSettle();
    expect(_key('mywork-error'), findsOneWidget);
    home.myWorkError = null;
    home.assigned = [_item('a', 'Back')];
    await t.tap(_key('mywork-retry'));
    await t.pumpAndSettle();
    expect(find.text('Back'), findsOneWidget);
  });

  testWidgets('is in the sidebar and in the phone More sheet', (t) async {
    final home = FakeHomeClient();
    await pumpProjects(
      t,
      projects: [project('p1', 'Web')],
      home: home,
      overrides: [localPrefsProvider.overrideWithValue(MemoryPrefs())],
    );
    expect(_key('nav-my-work'), findsOneWidget);
  });

  testWidgets('opens on a phone through More', (t) async {
    final home = FakeHomeClient(assigned: [_item('a', 'Mine')]);
    await pumpProjects(
      t,
      projects: [project('p1', 'Web')],
      home: home,
      size: const Size(390, 800),
      overrides: [localPrefsProvider.overrideWithValue(MemoryPrefs())],
    );
    await t.tap(_key('more-tab'));
    await t.pumpAndSettle();
    await t.tap(_key('more-my-work'));
    await t.pumpAndSettle();
    expect(find.text('Mine'), findsOneWidget);
  });
}
