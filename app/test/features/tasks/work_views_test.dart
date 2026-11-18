import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:taskforge/core/ui/appearance.dart';
import 'package:taskforge/core/ui/tf_icons.dart';
import 'package:taskforge/core/ui/tokens/spacing.dart';
import 'package:taskforge/features/calendar/domain/calendar_math.dart';
import 'package:taskforge/features/filters/application/filters_providers.dart';
import 'package:taskforge/features/filters/domain/filter_query.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';
import 'package:taskforge/features/views/application/views_providers.dart';
import 'package:taskforge/features/views/domain/list_layout.dart';
import 'package:taskforge/features/workflows/domain/workflow.dart';

import '../board/fakes.dart';
import '../calendar/fakes.dart';
import '../filters/fakes.dart';
import '../projects/fakes.dart';
import '../projects/projects_test_support.dart';
import '../views/fakes.dart';
import '../workflows/fakes.dart';
import 'fakes.dart';

const _wide = Size(1400, 1000);
const _narrow = Size(400, 900);

SavedView _tab(String id, String name, int order, {ListLayout? layout}) =>
    SavedView(
      id: id,
      name: name,
      layout: layout ?? const ListLayout(),
      isShared: true,
      version: 1,
      pinnedAsTab: order > 0,
      tabOrder: order,
    );

FilterQuery _two() => FilterQuery(
  root: const FilterGroup(
    children: [
      FilterCondition(
        field: 'priority',
        cmp: 'eq',
        values: [FilterValue.id('high')],
      ),
      FilterCondition(field: 'title', cmp: 'eq', values: [FilterValue.id('x')]),
    ],
  ),
);

Future<({FakeViewsClient views, Pumped pumped})> _open(
  WidgetTester tester, {
  List<Task>? tasks,
  List<SavedView> views = const [],
  Size size = _wide,
}) async {
  final server = FakeTasksClient(
    tasks ??
        [
          task('a', 'Alpha', priority: TaskPriority.high),
          task('b', 'Bravo', number: 2),
        ],
  );
  final saved = FakeViewsClient(views);
  final pumped = await pumpProjects(
    tester,
    role: 'Owner',
    projects: [project('p1', 'Web')],
    tasks: server,
    workflows: FakeWorkflowsClient(defaultWorkflow()),
    filters: FakeFiltersClient(),
    views: saved,
    board: FakeBoardClient(server.tasks),
    calendar: FakeCalendarClient(server),
    today: day(2026, 11, 10),
    size: size,
  );
  await pumped.go(tester, '/projects/p1');
  return (views: saved, pumped: pumped);
}

Future<void> _tap(WidgetTester tester, String key) async {
  await tester.tap(find.byKey(Key(key)));
  await tester.pumpAndSettle();
}

Finder _tabIcon(TfIconData icon) => find.descendant(
  of: find.byKey(const Key('view-switch')),
  matching: find.byIcon(icon.glyph),
);

Finder _searchField() => find.descendant(
  of: find.byKey(const Key('view-search')),
  matching: find.byType(TextField),
);

double _x(WidgetTester tester, String key) =>
    tester.getTopLeft(find.byKey(Key(key))).dx;

void main() {
  group('the toolbar', () {
    testWidgets('lists, in order, search, filter, group, sort, fields, the '
        'view\'s own controls and + Task', (tester) async {
      await _open(tester);

      final order = [
        'view-search-open',
        'filter-button',
        'group-menu',
        'sort-menu',
        'columns-menu',
        'layouts-menu',
        'toolbar-add-task',
      ];
      final xs = [for (final k in order) _x(tester, k)];
      expect(xs, orderedEquals([...xs]..sort()));
      expect(find.byKey(const Key('list-toolbar')), findsOneWidget);
    });

    testWidgets('the board fills the same slots with its own controls', (
      tester,
    ) async {
      await _open(tester);
      await tester.tap(_tabIcon(TfIcons.board));
      await tester.pumpAndSettle();

      for (final k in [
        'view-search-open',
        'filter-button',
        'board-group-menu',
        'board-fields-menu',
        'board-lane-menu',
        'toolbar-add-task',
      ]) {
        expect(find.byKey(Key(k)), findsOneWidget, reason: k);
      }
      expect(find.byKey(const Key('sort-menu')), findsNothing);
      expect(find.byKey(const Key('list-toolbar')), findsNothing);
    });

    testWidgets('the calendar and the timeline use it too', (tester) async {
      await _open(tester);
      for (final (icon, own) in [
        (TfIcons.calendar, 'cal-today'),
        (TfIcons.timeline, 'timeline-zoom'),
      ]) {
        await tester.tap(_tabIcon(icon));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('filter-button')), findsOneWidget);
        expect(find.byKey(const Key('view-search-open')), findsOneWidget);
        expect(find.byKey(Key(own)), findsOneWidget);
      }
    });

    testWidgets('a viewer has no + Task', (tester) async {
      final server = FakeTasksClient([task('a', 'Alpha')]);
      final pumped = await pumpProjects(
        tester,
        role: 'Viewer',
        projects: [project('p1', 'Web')],
        tasks: server,
        workflows: FakeWorkflowsClient(defaultWorkflow()),
        size: _wide,
      );
      await pumped.go(tester, '/projects/p1');

      expect(find.byKey(const Key('toolbar-add-task')), findsNothing);
    });
  });

  group('filters and search', () {
    testWidgets('chips show each condition; one is removed, then all', (
      tester,
    ) async {
      final s = await _open(tester);
      final filter = s.pumped.container.read(
        activeFilterProvider('p1').notifier,
      );

      filter.apply(_two());
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('active-filter')), findsOneWidget);
      expect(find.byKey(const Key('filter-chip-1')), findsOneWidget);
      expect(find.text('Filter (2)'), findsOneWidget);

      await tester.tap(find.byTooltip('Clear the filter').first);
      await tester.pumpAndSettle();
      expect(
        s.pumped.container
            .read(activeFilterProvider('p1'))
            .query
            .conditionCount,
        1,
      );
      expect(find.byKey(const Key('filter-chip-1')), findsNothing);

      filter.apply(_two());
      await tester.pumpAndSettle();
      await _tap(tester, 'filter-clear-all');
      expect(
        s.pumped.container.read(activeFilterProvider('p1')).query.isEmpty,
        isTrue,
      );
      expect(find.byKey(const Key('filter-chips-row')), findsNothing);
    });

    testWidgets('filter and search stay when the tab changes', (tester) async {
      final s = await _open(tester);
      s.pumped.container
          .read(activeFilterProvider('p1').notifier)
          .apply(_two());
      await _tap(tester, 'view-search-open');
      await tester.enterText(_searchField(), 'Alpha');
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('task-b')), findsNothing);

      await tester.tap(_tabIcon(TfIcons.board));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('active-filter')), findsOneWidget);
      expect(find.text('Alpha'), findsWidgets);
      expect(find.text('Bravo'), findsNothing);

      await tester.tap(_tabIcon(TfIcons.list));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('active-filter')), findsOneWidget);
      expect(find.byKey(const Key('task-a')), findsOneWidget);
      expect(find.byKey(const Key('task-b')), findsNothing);
      expect(
        tester.widget<TextField>(_searchField()).controller!.text,
        'Alpha',
      );
    });

    testWidgets('a view-only setting stays with its view', (tester) async {
      final s = await _open(tester);
      await _tap(tester, 'group-menu');
      await _tap(tester, 'group-by-priority');
      expect(
        s.pumped.container.read(listLayoutProvider('p1')).layout.groupBy,
        'priority',
      );

      await tester.tap(_tabIcon(TfIcons.board));
      await tester.pumpAndSettle();
      await tester.tap(_tabIcon(TfIcons.list));
      await tester.pumpAndSettle();

      expect(
        s.pumped.container.read(listLayoutProvider('p1')).layout.groupBy,
        'priority',
      );
    });
  });

  group('view tabs', () {
    testWidgets('pinned layouts come back as tabs, in their order', (
      tester,
    ) async {
      await _open(
        tester,
        views: [
          _tab('v2', 'Second', 2),
          _tab('v1', 'First', 1),
          _tab('v3', 'Loose', 0),
        ],
      );

      expect(find.byKey(const Key('tab-saved-v3')), findsNothing);
      expect(_x(tester, 'tab-saved-v1'), lessThan(_x(tester, 'tab-saved-v2')));
    });

    testWidgets('a layout is pinned from "+ View" and saved as a tab', (
      tester,
    ) async {
      final s = await _open(tester, views: [_tab('v1', 'Plan', 0)]);

      await _tap(tester, 'tab-add-view');
      await _tap(tester, 'tab-pin-v1');

      expect(find.byKey(const Key('tab-saved-v1')), findsOneWidget);
      expect(s.views.views.single.pinnedAsTab, isTrue);
    });

    testWidgets('a tab opens its layout in the list', (tester) async {
      final s = await _open(
        tester,
        views: [
          _tab(
            'v1',
            'By priority',
            1,
            layout: const ListLayout(groupBy: 'priority'),
          ),
        ],
      );
      await tester.tap(_tabIcon(TfIcons.board));
      await tester.pumpAndSettle();

      await _tap(tester, 'tab-saved-v1');

      expect(find.byKey(const Key('task-list')), findsOneWidget);
      expect(
        s.pumped.container.read(listLayoutProvider('p1')).layout.groupBy,
        'priority',
      );
    });

    testWidgets('tabs are reordered, unpinned and deleted', (tester) async {
      final s = await _open(
        tester,
        views: [_tab('v1', 'First', 1), _tab('v2', 'Second', 2)],
      );

      await _tap(tester, 'tab-menu-v2');
      await _tap(tester, 'tab-earlier-v2');
      expect(_x(tester, 'tab-saved-v2'), lessThan(_x(tester, 'tab-saved-v1')));
      expect(s.views.views.firstWhere((v) => v.id == 'v2').tabOrder, 1);

      await _tap(tester, 'tab-menu-v1');
      await _tap(tester, 'tab-unpin-v1');
      expect(find.byKey(const Key('tab-saved-v1')), findsNothing);
      expect(
        s.views.views.firstWhere((v) => v.id == 'v1').pinnedAsTab,
        isFalse,
      );

      await _tap(tester, 'tab-menu-v2');
      await _tap(tester, 'tab-delete-v2');
      await _tap(tester, 'layout-delete-confirm');
      expect(find.byKey(const Key('tab-saved-v2')), findsNothing);
      expect(s.views.views.any((v) => v.id == 'v2'), isFalse);
    });

    testWidgets('a narrow bar scrolls and keeps the active tab on screen', (
      tester,
    ) async {
      await _open(
        tester,
        size: _narrow,
        views: [
          for (var i = 1; i <= 4; i++) _tab('v$i', 'Layout number $i', i),
        ],
      );
      expect(
        tester.getTopRight(find.byKey(const Key('tab-saved-v4'))).dx,
        greaterThan(_narrow.width),
      );

      await tester.ensureVisible(find.byKey(const Key('tab-saved-v4')));
      await tester.tap(find.byKey(const Key('tab-saved-v4')));
      await tester.pumpAndSettle();

      final box = tester.getRect(find.byKey(const Key('tab-saved-v4')));
      expect(box.right, lessThanOrEqualTo(_narrow.width));
    });
  });

  group('the list', () {
    testWidgets('row height follows the density: 36 compact, 44 comfortable', (
      tester,
    ) async {
      final s = await _open(tester);
      final density = s.pumped.container.read(densityProvider.notifier);
      Finder line() => find.ancestor(
        of: find.byKey(const Key('check-a')),
        matching: find.byType(Container),
      );
      double lineHeight() => tester.getSize(line().first).height;

      density.choose(TfDensity.comfortable);
      await tester.pumpAndSettle();
      expect(lineHeight(), 44);

      density.choose(TfDensity.compact);
      await tester.pumpAndSettle();
      expect(lineHeight(), 36);
    });

    testWidgets('an open task past its due date shows a warning icon, not '
        'only red', (tester) async {
      await _open(
        tester,
        tasks: [
          task('a', 'Late', dueDate: '2026-11-01'),
          task('b', 'Fine', number: 2, dueDate: '2026-11-20'),
          task(
            'c',
            'Done late',
            number: 3,
            dueDate: '2026-11-01',
            category: StatusCategory.done,
          ),
        ],
      );

      final warnings = find.byWidgetPredicate(
        (w) => w is TfIcon && w.icon == TfIcons.warning,
      );
      expect(warnings, findsOneWidget);
      expect(tester.widget<TfIcon>(warnings).semanticLabel, 'Overdue');
    });

    testWidgets('the header stays while the rows scroll', (tester) async {
      await _open(
        tester,
        tasks: [
          for (var i = 1; i <= 80; i++) task('t$i', 'Task $i', number: i),
        ],
      );
      final before = tester.getTopLeft(find.byKey(const Key('table-header')));

      await tester.drag(
        find.byKey(const Key('task-list')),
        const Offset(0, -600),
      );
      await tester.pumpAndSettle();

      expect(tester.getTopLeft(find.byKey(const Key('table-header'))), before);
      expect(find.byKey(const Key('task-t1')), findsNothing);
    });

    testWidgets('row actions show on hover', (tester) async {
      await _open(tester);
      Opacity menuOpacity() => tester.widget<Opacity>(
        find.descendant(
          of: find.byKey(const Key('task-menu-a')),
          matching: find.byType(Opacity),
        ),
      );

      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: Offset.zero);
      await mouse.moveTo(tester.getCenter(find.byKey(const Key('task-a'))));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('task-menu-a')), findsOneWidget);
      expect(menuOpacity().opacity, 1);
    });
  });

  group('opening a task', () {
    testWidgets('a row opens its task through the one door', (tester) async {
      await _open(tester);
      await _tap(tester, 'task-a');
      expect(find.byKey(const Key('detail-title')), findsOneWidget);
    });
  });
}
