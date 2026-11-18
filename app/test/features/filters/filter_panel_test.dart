import 'dart:convert';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/core/ui/tf_icons.dart';
import 'package:taskforge/features/calendar/domain/calendar_math.dart';
import 'package:taskforge/features/filters/application/filters_providers.dart';
import 'package:taskforge/features/filters/domain/filter_query.dart';
import 'package:taskforge/features/filters/domain/saved_filters.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';
import 'package:taskforge/features/views/domain/filter_layout.dart';
import 'package:taskforge/features/views/domain/list_layout.dart';

import '../board/fakes.dart';
import '../calendar/fakes.dart';
import '../projects/fakes.dart';
import '../projects/projects_test_support.dart';
import '../tasks/fakes.dart';
import '../views/fakes.dart';
import '../workflows/fakes.dart';
import 'fakes.dart';

const _wide = Size(1400, 1000);

final _high = FilterQuery(
  root: const FilterGroup(
    children: [
      FilterCondition(
        field: 'priority',
        cmp: 'eq',
        values: [FilterValue.id('high')],
      ),
    ],
  ),
);

typedef Opened = ({
  FakeFiltersClient filters,
  FakeTasksClient tasks,
  FakeBoardClient board,
  FakeCalendarClient calendar,
  Pumped pumped,
});

Future<Opened> _open(
  WidgetTester tester, {
  FakeFiltersClient? filters,
  FakeViewsClient? views,
  String role = 'Owner',
  Size size = _wide,
}) async {
  final server = FakeTasksClient([
    task('a', 'Alpha', priority: TaskPriority.high),
    task('b', 'Bravo', number: 2),
  ]);
  final fake = filters ?? FakeFiltersClient(texts: {'priority = high': _high});
  final board = FakeBoardClient(server.tasks);
  final calendar = FakeCalendarClient(server);
  final pumped = await pumpProjects(
    tester,
    role: role,
    projects: [project('p1', 'Web')],
    tasks: server,
    workflows: FakeWorkflowsClient(defaultWorkflow()),
    filters: fake,
    views: views,
    board: board,
    calendar: calendar,
    today: day(2026, 11, 10),
    size: size,
  );
  await pumped.go(tester, '/projects/p1');
  return (
    filters: fake,
    tasks: server,
    board: board,
    calendar: calendar,
    pumped: pumped,
  );
}

Future<void> _tap(WidgetTester tester, String key) async {
  await tester.tap(find.byKey(Key(key)));
  await tester.pumpAndSettle();
  // The filter is saved a moment after a change: let that timer run.
  await tester.pump(const Duration(milliseconds: 700));
  await tester.pumpAndSettle();
}

/// Lets the save-a-moment-later timer of a changed filter run.
Future<void> _flush(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 700));
  await tester.pumpAndSettle();
}

Future<void> _pick(WidgetTester tester, String key, String label) async {
  await _tap(tester, key);
  await tester.tap(find.text(label).last);
  await tester.pumpAndSettle();
}

/// Builds "priority is High" in the panel.
Future<void> _buildHigh(WidgetTester tester) async {
  await _tap(tester, 'add-condition-root');
  await _pick(tester, 'field-0', 'Priority');
  await _pick(tester, 'value-0', 'High');
}

Map<String, dynamic> _sent(String ast) =>
    jsonDecode(ast) as Map<String, dynamic>;

Future<void> _settle(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 500));
  await tester.pumpAndSettle();
}

void main() {
  group('building a filter', () {
    testWidgets('rows make a filter that reaches the list', (tester) async {
      final s = await _open(tester);

      await _tap(tester, 'filter-button');
      await _buildHigh(tester);
      await _tap(tester, 'filter-apply');

      expect(find.byKey(const Key('filter-panel')), findsNothing);
      expect(find.byKey(const Key('active-filter')), findsOneWidget);
      final where = _sent(s.tasks.queries.last.filterAst)['where'] as Map;
      expect(where['field'], 'priority');
      expect(where['cmp'], 'eq');
      expect(where['values'], [
        {'k': 'id', 'v': 'high'},
      ]);
      expect(find.text('Filter (1)'), findsOneWidget);
    });

    testWidgets('operators follow the field and values follow the operator', (
      tester,
    ) async {
      await _open(tester);
      await _tap(tester, 'filter-button');
      await _tap(tester, 'add-condition-root');

      await _pick(tester, 'field-0', 'Due date');
      await _tap(tester, 'op-0');
      expect(find.text('is before'), findsWidgets);
      expect(find.text('contains'), findsNothing); // a date has no "contains"
      await tester.tap(find.text('is empty').last);
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('value-0')),
        findsNothing,
      ); // no value to give

      await _pick(tester, 'field-0', 'Priority');
      await _pick(tester, 'op-0', 'is any of');
      expect(find.byKey(const Key('choice-0-high')), findsOneWidget);
      await tester.tap(find.byKey(const Key('choice-0-high')));
      await tester.tap(find.byKey(const Key('choice-0-low')));
      await tester.pumpAndSettle();
      await _tap(tester, 'filter-apply');
    });

    testWidgets('groups nest, switch to ANY and can be negated', (
      tester,
    ) async {
      final s = await _open(tester);
      await _tap(tester, 'filter-button');
      await _buildHigh(tester);

      await _tap(tester, 'add-group-root');
      await _tap(tester, 'group-not-1');
      await tester.tap(
        find.descendant(
          of: find.byKey(const Key('group-op-1')),
          matching: find.text('All of'),
        ),
      );
      await tester.pumpAndSettle();
      await _pick(tester, 'field-1-0', 'Priority');
      await _tap(tester, 'filter-apply');

      final where = _sent(s.tasks.queries.last.filterAst)['where'] as Map;
      expect(where['op'], 'and');
      final nested = (where['args'] as List)[1] as Map;
      expect(nested['op'], 'not');
      expect((nested['arg'] as Map)['op'], 'cmp'); // a group of one is its row
    });

    testWidgets('a row can be removed and an ordering added', (tester) async {
      final s = await _open(tester);
      await _tap(tester, 'filter-button');
      await _buildHigh(tester);
      await _tap(tester, 'add-order');
      await _tap(tester, 'order-dir-0');
      await tester.tap(find.text('Descending'));
      await tester.pumpAndSettle();
      await _tap(tester, 'add-condition-root');
      await _tap(tester, 'remove-row-1');
      await _tap(tester, 'filter-apply');

      final ast = _sent(s.tasks.queries.last.filterAst);
      expect(ast['order'], [
        {'field': 'title', 'desc': true},
      ]);
      expect((ast['where'] as Map)['field'], 'priority');
    });

    testWidgets('an unfinished condition is explained, not applied', (
      tester,
    ) async {
      final s = await _open(tester);
      await _tap(tester, 'filter-button');
      await _tap(tester, 'add-condition-root'); // title is ... (no value)

      await _tap(tester, 'filter-apply');

      expect(find.byKey(const Key('filter-panel')), findsOneWidget);
      expect(find.text('A condition needs a value.'), findsOneWidget);
      expect(s.tasks.queries.last.filterAst, '');
    });
  });

  group('one filter for every view', () {
    testWidgets('the board and the calendar read with it too', (tester) async {
      final s = await _open(tester);
      await _tap(tester, 'filter-button');
      await _buildHigh(tester);
      await _tap(tester, 'filter-apply');
      final expected = s.tasks.queries.last.filterAst;

      await tester.tap(find.text('Board'));
      await tester.pumpAndSettle();
      expect(s.board.filters.last, expected);

      await tester.tap(
        find.descendant(
          of: find.byKey(const Key('view-switch')),
          matching: find.byIcon(TfIcons.calendar.glyph),
        ),
      );
      await tester.pumpAndSettle();
      expect(s.calendar.filters.last, expected);

      await tester.tap(
        find.descendant(
          of: find.byKey(const Key('view-switch')),
          matching: find.byIcon(TfIcons.list.glyph),
        ),
      );
      await tester.pumpAndSettle();
      expect(s.tasks.queries.last.filterAst, expected);
      expect(find.byKey(const Key('active-filter')), findsOneWidget);
    });

    testWidgets('clearing it reads everything again in every view', (
      tester,
    ) async {
      final s = await _open(tester);
      await _tap(tester, 'filter-button');
      await _buildHigh(tester);
      await _tap(tester, 'filter-apply');

      await tester.tap(find.byTooltip('Clear the filter')); // the chip's delete
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('active-filter')), findsNothing);
      expect(s.tasks.queries.last.filterAst, '');
      await tester.tap(find.text('Board'));
      await tester.pumpAndSettle();
      expect(s.board.filters.last, '');
    });

    testWidgets('a filtered list is flat and cannot be dragged into a tree', (
      tester,
    ) async {
      final s = await _open(tester);
      s.filters.texts['priority = high'] = _high;
      await _tap(tester, 'filter-button');
      await _buildHigh(tester);
      await _tap(tester, 'filter-apply');

      expect(s.tasks.queries.last.isDefault, isFalse);
    });
  });

  group('changing the filter on the view that is open', () {
    testWidgets('the board reads again with it, and without it when cleared', (
      tester,
    ) async {
      final s = await _open(tester);
      await tester.tap(find.text('Board'));
      await tester.pumpAndSettle();
      final before = s.board.getCalls.length;
      expect(s.board.filters.last, '');

      await _tap(tester, 'filter-button');
      await _buildHigh(tester);
      await _tap(tester, 'filter-apply');

      expect(s.board.getCalls.length, greaterThan(before));
      expect(s.board.filters.last, isNotEmpty);

      await tester.tap(find.byTooltip('Clear the filter'));
      await tester.pumpAndSettle();
      expect(s.board.filters.last, '');
      await _flush(tester);
    });

    testWidgets('the calendar reads again with it, and without it', (
      tester,
    ) async {
      final s = await _open(tester);
      await tester.tap(
        find.descendant(
          of: find.byKey(const Key('view-switch')),
          matching: find.byIcon(TfIcons.calendar.glyph),
        ),
      );
      await tester.pumpAndSettle();
      final before = s.calendar.filters.length;

      await _tap(tester, 'filter-button');
      await _buildHigh(tester);
      await _tap(tester, 'filter-apply');

      expect(s.calendar.filters.length, greaterThan(before));
      expect(s.calendar.filters.last, isNotEmpty);
      await tester.tap(find.byTooltip('Clear the filter'));
      await tester.pumpAndSettle();
      expect(s.calendar.filters.last, '');
      await _flush(tester);
    });

    testWidgets(
      'the chip follows the text of the filter, even for the same query',
      (tester) async {
        final s = await _open(tester);
        final container = s.pumped.container;
        container
            .read(activeFilterProvider('p1').notifier)
            .apply(_high, text: 'first');
        await tester.pumpAndSettle();
        expect(find.text('first'), findsOneWidget);

        container
            .read(activeFilterProvider('p1').notifier)
            .apply(_high, saved: 'f1', text: 'second');
        await tester.pumpAndSettle();

        expect(find.text('first'), findsNothing);
        expect(find.text('second'), findsOneWidget);
        expect(container.read(activeFilterProvider('p1')).savedId, 'f1');
        await _flush(tester);
      },
    );
  });

  group('the filter is kept', () {
    testWidgets('it is saved a moment after it is applied and when cleared', (
      tester,
    ) async {
      final views = FakeViewsClient();
      await _open(tester, views: views);

      await _tap(tester, 'filter-button');
      await _buildHigh(tester);
      await _tap(tester, 'filter-apply');

      expect(views.filterSaves, hasLength(1));
      expect(
        _sent(views.filterSaves.single.astJson)['where'],
        isA<Map<dynamic, dynamic>>(),
      );
      await tester.tap(find.byTooltip('Clear the filter'));
      await _flush(tester);
      expect(views.filterSaves.last.astJson, '');
      expect(views.filterSaves, hasLength(2));
    });

    testWidgets('it is there when the project opens, in every view, at once', (
      tester,
    ) async {
      final views = FakeViewsClient()
        ..filterLayout = (
          id: 'flt',
          version: 3,
          layout: FilterLayout(astJson: _high.toJsonString(), savedId: 'f9'),
        );
      final s = await _open(tester, views: views);

      expect(find.byKey(const Key('active-filter')), findsOneWidget);
      // The first read was already filtered: nothing was read unfiltered first.
      expect(s.tasks.queries.every((q) => q.filterAst.isNotEmpty), isTrue);
      expect(s.tasks.queries, isNotEmpty);
      await tester.tap(find.text('Board'));
      await tester.pumpAndSettle();
      expect(s.board.filters.every((f) => f.isNotEmpty), isTrue);
      await tester.tap(
        find.descendant(
          of: find.byKey(const Key('view-switch')),
          matching: find.byIcon(TfIcons.calendar.glyph),
        ),
      );
      await tester.pumpAndSettle();
      expect(s.calendar.filters.every((f) => f.isNotEmpty), isTrue);
      expect(s.pumped.container.read(activeFilterProvider('p1')).savedId, 'f9');
    });

    testWidgets('a kept filter shows its text as the server writes it today', (
      tester,
    ) async {
      final fake = FakeFiltersClient(texts: {'priority = high': _high});
      final views = FakeViewsClient()
        ..filterLayout = (
          id: 'flt',
          version: 1,
          layout: FilterLayout(astJson: _high.toJsonString()),
        );
      await _open(tester, filters: fake, views: views);

      expect(find.text('priority = high'), findsOneWidget);
    });

    testWidgets('a kept filter that no longer means anything is dropped', (
      tester,
    ) async {
      final broken = FilterQuery(
        root: const FilterGroup(
          children: [FilterCondition(field: 'title', cmp: 'eq')],
        ),
      ); // the fake refuses a condition with no value, as the server would
      final views = FakeViewsClient()
        ..filterLayout = (
          id: 'flt',
          version: 1,
          layout: FilterLayout(astJson: broken.toJsonString()),
        );
      final s = await _open(tester, views: views);

      expect(find.byKey(const Key('active-filter')), findsNothing);
      expect(s.tasks.queries.every((q) => q.filterAst.isEmpty), isTrue);
    });

    testWidgets('failing to read it still lets the project open', (
      tester,
    ) async {
      final views = FakeViewsClient()
        ..failFindFilter = const ViewException(ViewFailure.network);
      final s = await _open(tester, views: views);

      expect(s.tasks.queries, isNotEmpty);
      expect(find.byKey(const Key('filter-button')), findsOneWidget);
    });
  });

  group('advanced mode', () {
    testWidgets('shows the filter as text and checks what is typed', (
      tester,
    ) async {
      final s = await _open(tester);
      await _tap(tester, 'filter-button');
      await _buildHigh(tester);

      await _tap(tester, 'filter-mode');
      await tester.tap(find.text('Advanced'));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<TextField>(find.byKey(const Key('tfql-text')))
            .controller!
            .text,
        'priority = high',
      );

      await tester.enterText(
        find.byKey(const Key('tfql-text')),
        'priority = ?',
      );
      await _settle(tester);
      expect(find.byKey(const Key('tfql-error')), findsOneWidget);
      expect(find.textContaining('at character 12'), findsOneWidget);

      await tester.enterText(
        find.byKey(const Key('tfql-text')),
        'priority = high',
      );
      await _settle(tester);
      expect(find.byKey(const Key('tfql-error')), findsNothing);
      expect(s.filters.validated.last.tfql, 'priority = high');
    });

    testWidgets('typed text applies as the same filter as the rows', (
      tester,
    ) async {
      final s = await _open(tester);
      await _tap(tester, 'filter-button');
      await _tap(tester, 'filter-mode');
      await tester.tap(find.text('Advanced'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('tfql-text')),
        'priority = high',
      );
      await _tap(tester, 'filter-apply');

      expect(
        _sent(s.tasks.queries.last.filterAst),
        _sent(_high.toJsonString()),
      );
      expect(
        tester
            .widget<Text>(
              find.descendant(
                of: find.byKey(const Key('active-filter')),
                matching: find.byType(Text),
              ),
            )
            .data,
        'priority = high',
      );
    });

    testWidgets('going back to the builder shows the rows of the text', (
      tester,
    ) async {
      await _open(tester);
      await _tap(tester, 'filter-button');
      await _tap(tester, 'filter-mode');
      await tester.tap(find.text('Advanced'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('tfql-text')),
        'priority = high',
      );
      await _settle(tester);

      await _tap(tester, 'filter-mode');
      await tester.tap(find.text('Builder'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('row-0')), findsOneWidget);
      expect(find.text('Priority'), findsWidgets);
      expect(find.text('High'), findsWidgets);
    });

    testWidgets('text that does not read keeps you in the editor', (
      tester,
    ) async {
      await _open(tester);
      await _tap(tester, 'filter-button');
      await _tap(tester, 'filter-mode');
      await tester.tap(find.text('Advanced'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('tfql-text')),
        'what is this ?',
      );
      await _settle(tester);

      await _tap(tester, 'filter-mode');
      await tester.tap(find.text('Builder'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('tfql-text')), findsOneWidget);
      expect(find.byKey(const Key('tfql-error')), findsOneWidget);
    });

    testWidgets('suggestions are offered and a tap puts them in', (
      tester,
    ) async {
      final fake = FakeFiltersClient(texts: {'priority = high': _high})
        ..suggestions = const [
          QuerySuggestion('priority', 'field', 0, 'built-in'),
        ];
      final s = await _open(tester, filters: fake);
      await _tap(tester, 'filter-button');
      await _tap(tester, 'filter-mode');
      await tester.tap(find.text('Advanced'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('tfql-text')), 'pri');
      await _settle(tester);
      expect(s.filters.suggested.last.partial, 'pri');
      await _tap(tester, 'suggest-priority');

      expect(
        tester
            .widget<TextField>(find.byKey(const Key('tfql-text')))
            .controller!
            .text,
        'priority ',
      );
    });
  });

  group('saved filters', () {
    testWidgets('a filter is saved, listed, applied and deleted', (
      tester,
    ) async {
      final s = await _open(tester);
      await _tap(tester, 'filter-button');
      await _buildHigh(tester);

      await _tap(tester, 'filter-save');
      await tester.enterText(find.byKey(const Key('filter-name')), 'Hot');
      await _tap(tester, 'filter-save-confirm');

      expect(s.filters.filters.single.name, 'Hot');
      expect(find.byKey(const Key('filter-panel')), findsNothing);
      expect(find.byKey(const Key('active-filter')), findsOneWidget);

      await tester.tap(find.byKey(const Key('active-filter')).last);
      await tester.pumpAndSettle();
      await _tap(tester, 'filter-clear');
      expect(find.byKey(const Key('active-filter')), findsNothing);

      await _tap(tester, 'saved-filters-menu');
      await tester.tap(find.byKey(Key('saved-${s.filters.filters.single.id}')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('active-filter')), findsOneWidget);
      expect(s.tasks.queries.last.filterAst, isNotEmpty);

      await _tap(tester, 'saved-filters-menu');
      await _tap(tester, 'manage-filters');
      await _tap(tester, 'delete-filter-${s.filters.filters.single.id}');
      expect(s.filters.filters, isEmpty);
      expect(find.byKey(const Key('no-saved-filters')), findsOneWidget);
      expect(find.byKey(const Key('active-filter')), findsNothing); // it was on
    });

    testWidgets('only a manager is offered to share it with the project', (
      tester,
    ) async {
      await _open(tester);
      await _tap(tester, 'filter-button');
      await _buildHigh(tester);
      await _tap(tester, 'filter-save');
      expect(find.byKey(const Key('filter-visibility')), findsOneWidget);
      await tester.tap(find.text('Cancel').last);
      await tester.pumpAndSettle();
    });

    testWidgets('a member saves only for themselves', (tester) async {
      await _open(tester, role: 'Member');
      await _tap(tester, 'filter-button');
      await _buildHigh(tester);

      await _tap(tester, 'filter-save');

      expect(find.byKey(const Key('filter-visibility')), findsNothing);
    });

    testWidgets('a taken name is explained', (tester) async {
      final fake = FakeFiltersClient(
        texts: {'priority = high': _high},
        saved: [
          SavedFilter(
            id: 'x',
            name: 'Hot',
            visibility: 'private',
            query: _high,
            tfql: 'priority = high',
            version: 1,
          ),
        ],
      );
      await _open(tester, filters: fake);
      await _tap(tester, 'filter-button');
      await _buildHigh(tester);
      await _tap(tester, 'filter-save');
      await tester.enterText(find.byKey(const Key('filter-name')), 'hot');

      await _tap(tester, 'filter-save-confirm');

      expect(
        find.text('A filter with that name already exists here.'),
        findsOneWidget,
      );
    });

    testWidgets(
      'a filter whose field is gone is listed but cannot be applied',
      (tester) async {
        final fake = FakeFiltersClient(
          saved: [
            SavedFilter(
              id: 'broken',
              name: 'Old',
              visibility: 'project',
              query: _high,
              tfql: '',
              version: 1,
            ),
          ],
        );
        await _open(tester, filters: fake);

        await _tap(tester, 'saved-filters-menu');

        expect(find.textContaining('a field is gone'), findsOneWidget);
        final item = tester.widget<MenuItemButton>(
          find.byKey(const Key('saved-broken')),
        );
        expect(item.onPressed, isNull);
      },
    );
  });

  testWidgets('works on a phone: the bar wraps and the panel opens', (
    tester,
  ) async {
    await _open(tester, size: const Size(420, 900));

    await _tap(tester, 'filter-button');

    expect(find.byKey(const Key('filter-panel')), findsOneWidget);
  });
}
