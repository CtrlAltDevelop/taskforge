import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/app_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskforge/features/tasks/application/tasks_providers.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';
import 'package:taskforge/features/views/domain/list_layout.dart';

import '../projects/fakes.dart';
import '../projects/projects_test_support.dart';
import '../views/fakes.dart';
import '../workflows/fakes.dart';
import 'fakes.dart';

const _wide = Size(1400, 1000);
const _phone = Size(420, 900);

Future<({FakeTasksClient tasks, FakeViewsClient views})> _open(
  WidgetTester tester, {
  List<Task>? tasks,
  FakeViewsClient? views,
  String role = 'Owner',
  Size size = _wide,
}) async {
  final server = FakeTasksClient(
    tasks ??
        [
          task(
            'a',
            'Charlie',
            priority: TaskPriority.low,
            dueDate: '2026-03-02',
          ),
          task('b', 'Alpha', number: 2, priority: TaskPriority.high),
          task('c', 'Bravo', number: 3, dueDate: '2026-03-01'),
        ],
  );
  final saved = views ?? FakeViewsClient();
  final pumped = await pumpProjects(
    tester,
    role: role,
    projects: [project('p1', 'Web')],
    tasks: server,
    workflows: FakeWorkflowsClient(defaultWorkflow()),
    views: saved,
    size: size,
  );
  await pumped.go(tester, '/projects/p1');
  return (tasks: server, views: saved);
}

List<String> _titles(WidgetTester tester) => [
  for (final e in find.byType(InkWell).evaluate())
    if (e.widget.key case final ValueKey<String> k
        when k.value.startsWith('task-'))
      k.value.substring(5),
];

Future<void> _tap(WidgetTester tester, String key) async {
  await tester.tap(find.byKey(Key(key)));
  await tester.pumpAndSettle();
}

Future<void> _saveDelay(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 700));
  await tester.pumpAndSettle();
}

/// Presses Tab until the focus is on the control under [key]; fails if it is
/// not reachable from the keyboard.
Future<void> _tabTo(WidgetTester tester, String key) async {
  final target = find.byKey(Key(key)).evaluate().single;
  for (var i = 0; i < 80; i++) {
    final focused = FocusManager.instance.primaryFocus?.context;
    var inside = false;
    focused?.visitAncestorElements((e) {
      inside = identical(e, target);
      return !inside;
    });
    if (inside) return;
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
  }
  fail('$key cannot be reached with Tab');
}

void main() {
  group('table', () {
    testWidgets('shows a header and one row per task with its columns', (
      tester,
    ) async {
      await _open(tester);

      expect(find.byKey(const Key('table-header')), findsOneWidget);
      for (final c in ['title', 'status', 'assignee', 'priority', 'due_date']) {
        expect(find.byKey(Key('header-$c')), findsOneWidget);
      }
      expect(_titles(tester), ['a', 'b', 'c']);
      expect(find.text('2026-03-02'), findsOneWidget);
    });

    testWidgets(
      'a header click sorts on the server, again flips, again clears',
      (tester) async {
        final s = await _open(tester);

        await _tap(tester, 'header-title');
        expect(s.tasks.queries.last.sort, [const SortKey('title')]);
        expect(_titles(tester), ['b', 'c', 'a']);
        expect(find.byKey(const Key('sort-arrow-title')), findsOneWidget);

        await _tap(tester, 'header-title');
        expect(s.tasks.queries.last.sort, [const SortKey('title', desc: true)]);
        expect(_titles(tester), ['a', 'c', 'b']);

        await _tap(tester, 'header-title');
        expect(s.tasks.queries.last.isDefault, isTrue);
        expect(_titles(tester), ['a', 'b', 'c']);
        expect(find.byKey(const Key('sort-arrow-title')), findsNothing);
      },
    );

    testWidgets('empty values sort last', (tester) async {
      await _open(tester);

      await _tap(tester, 'header-due_date');

      expect(_titles(tester), ['c', 'a', 'b']);
    });

    testWidgets('shift-click adds a second key', (tester) async {
      final s = await _open(tester);
      await _tap(tester, 'header-priority');

      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.tap(find.byKey(const Key('header-title')));
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      await tester.pumpAndSettle();

      expect(s.tasks.queries.last.sort, [
        const SortKey('priority'),
        const SortKey('title'),
      ]);
    });

    testWidgets(
      'grouping shows headers with counts; a header folds its group',
      (tester) async {
        final s = await _open(tester);

        await _tap(tester, 'group-menu');
        await _tap(tester, 'group-by-priority');

        expect(s.tasks.queries.last.groupBy, 'priority');
        expect(find.byKey(const Key('group-high')), findsOneWidget);
        expect(find.byKey(const Key('group-count-high')), findsOneWidget);
        expect(
          tester.widget<Text>(find.byKey(const Key('group-count-none'))).data,
          '1',
        );
        expect(_titles(tester), ['b', 'a', 'c']);

        await _tap(tester, 'group-high');
        expect(_titles(tester), ['a', 'c']);
        expect(find.byKey(const Key('group-count-high')), findsOneWidget);
      },
    );

    testWidgets('columns can be hidden and shown', (tester) async {
      await _open(tester);

      await _tap(tester, 'columns-menu');
      await _tap(tester, 'column-assignee');
      expect(find.byKey(const Key('header-assignee')), findsNothing);

      await _tap(tester, 'columns-menu');
      await _tap(tester, 'column-created_at');
      expect(find.byKey(const Key('header-created_at')), findsOneWidget);
    });

    testWidgets('dragging a column edge resizes it and the layout is saved', (
      tester,
    ) async {
      final s = await _open(tester);
      final before = tester
          .getSize(find.byKey(const Key('header-status')))
          .width;

      await tester.drag(
        find.byKey(const Key('resize-status')),
        const Offset(60, 0),
      );
      await tester.pumpAndSettle();
      await _saveDelay(tester);

      final after = tester
          .getSize(find.byKey(const Key('header-status')))
          .width;
      expect(after, before + 60);
      expect(s.views.saves.last.layout.widthOf('status'), before + 60);
    });

    testWidgets('a saved layout is applied when the list opens', (
      tester,
    ) async {
      final s = await _open(
        tester,
        views: FakeViewsClient([
          const SavedView(
            id: 'v1',
            name: personalLayoutName,
            layout: ListLayout(columns: ['priority'], sort: [SortKey('title')]),
            isShared: false,
            version: 1,
          ),
        ]),
      );

      expect(s.tasks.listCalls, 1);
      expect(find.byKey(const Key('header-status')), findsNothing);
      expect(find.byKey(const Key('header-priority')), findsOneWidget);
      expect(_titles(tester), ['b', 'c', 'a']);
    });

    testWidgets('a status is changed in place through the workflow', (
      tester,
    ) async {
      final s = await _open(tester);

      await _tap(tester, 'cell-status-a');
      await _tap(tester, 'status-done-a');

      expect(s.tasks.updates.single.patch.status!.id, 'done');
      expect(statusCell('a', 'Done'), findsOneWidget);
    });

    testWidgets('a priority is changed in place', (tester) async {
      final s = await _open(tester);

      await _tap(tester, 'cell-priority-a');
      await _tap(tester, 'priority-urgent-a');

      expect(s.tasks.updates.single.patch.priority, TaskPriority.urgent);
    });

    testWidgets('assignees are picked in a dialog', (tester) async {
      final s = await _open(tester);

      await _tap(tester, 'cell-assignee-a');
      await _tap(tester, 'assign-u2');
      await _tap(tester, 'assign-save');

      expect(s.tasks.updates.single.patch.assigneeIds, ['u2']);
      expect(find.text('Hank Hill'), findsOneWidget);
    });

    testWidgets('a title is renamed in place and Esc cancels', (tester) async {
      final s = await _open(tester);

      await _tap(tester, 'rename-btn-a');
      await tester.enterText(find.byKey(const Key('rename-a')), '  Delta ');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(s.tasks.updates.single.patch.title, 'Delta');
      expect(find.text('Delta'), findsOneWidget);

      await _tap(tester, 'rename-btn-b');
      await tester.enterText(find.byKey(const Key('rename-b')), 'Nope');
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      expect(s.tasks.updates, hasLength(1));
      expect(find.text('Alpha'), findsOneWidget);
    });

    testWidgets('a viewer reads the table but edits nothing', (tester) async {
      await _open(tester, role: 'Viewer');

      expect(find.byKey(const Key('cell-status-a')), findsNothing);
      expect(find.byKey(const Key('cell-priority-a')), findsNothing);
      expect(find.byKey(const Key('rename-btn-a')), findsNothing);
      expect(find.text('To do'), findsWidgets);
    });

    testWidgets('only the rows on screen are built, whatever the size', (
      tester,
    ) async {
      final many = [
        for (var i = 1; i <= 10000; i++) task('t$i', 'Task $i', number: i),
      ];
      await _open(tester, tasks: many);

      expect(find.byType(Checkbox).evaluate().length, lessThan(60));
      expect(find.text('Task 1'), findsOneWidget);

      await tester.drag(
        find.byKey(const Key('task-list')),
        const Offset(0, -440 * 9000),
      );
      await tester.pumpAndSettle();
      expect(find.text('Task 1'), findsNothing);
      expect(find.byType(Checkbox).evaluate().length, lessThan(60));
    });
  });

  group('while it loads and after it changes', () {
    testWidgets('rows are placeholders until the first page arrives', (
      tester,
    ) async {
      final server = FakeTasksClient([task('a', 'First')]);
      final gate = server.gate = Completer<void>();
      final pumped = await pumpProjects(
        tester,
        projects: [project('p1', 'Web')],
        tasks: server,
        workflows: FakeWorkflowsClient(defaultWorkflow()),
        views: FakeViewsClient(),
        size: _wide,
      );
      pumped.container.read(routerProvider).go('/projects/p1');
      await tester.pump();
      await tester.pump();

      expect(find.byKey(const Key('tasks-skeleton')), findsOneWidget);
      expect(find.byKey(const Key('task-a')), findsNothing);

      gate.complete();
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('tasks-skeleton')), findsNothing);
      expect(find.byKey(const Key('task-a')), findsOneWidget);
    });

    testWidgets('the scroll position survives an inline edit and a refresh', (
      tester,
    ) async {
      final many = [
        for (var i = 1; i <= 2000; i++) task('t$i', 'Task $i', number: i),
      ];
      final s = await _open(tester, tasks: many);
      await tester.drag(
        find.byKey(const Key('task-list')),
        const Offset(0, -440 * 20),
      );
      await tester.pumpAndSettle();
      double offset() => tester
          .state<ScrollableState>(
            find
                .descendant(
                  of: find.byKey(const Key('task-list')),
                  matching: find.byType(Scrollable),
                )
                .first,
          )
          .position
          .pixels;
      final before = offset();
      expect(before, greaterThan(1000));

      final visible = _titles(tester).firstWhere((id) {
        final y = tester.getCenter(find.byKey(Key('task-$id'))).dy;
        return y > 300 && y < 600;
      });
      final list = ProviderScope.containerOf(
        tester.element(find.byKey(const Key('task-list'))),
      ).read(taskListProvider('p1').notifier);
      final edited = list.state.tasks.firstWhere((t) => t.id == visible);
      await list.update(edited, const TaskPatch(priority: TaskPriority.urgent));
      await tester.pumpAndSettle();
      expect(s.tasks.updates, hasLength(1));
      expect(offset(), before);

      await _tap(tester, 'refresh-tasks');
      expect(offset(), before);
    });

    testWidgets('a shared layout can be deleted by someone who manages', (
      tester,
    ) async {
      final views = FakeViewsClient([
        const SavedView(
          id: 'v9',
          name: 'By due date',
          layout: ListLayout(columns: ['due_date']),
          isShared: true,
          version: 1,
        ),
      ]);
      await _open(tester, views: views);

      await _tap(tester, 'layouts-menu');
      await _tap(tester, 'shared-delete-v9');
      await _tap(tester, 'layout-delete-confirm');

      expect(views.views, isEmpty);
      await _tap(tester, 'layouts-menu');
      expect(find.byKey(const Key('shared-v9')), findsNothing);
    });

    testWidgets('a viewer is not offered the delete', (tester) async {
      final views = FakeViewsClient([
        const SavedView(
          id: 'v9',
          name: 'Team',
          layout: ListLayout(),
          isShared: true,
          version: 1,
        ),
      ]);
      await _open(tester, views: views, role: 'Viewer');

      await _tap(tester, 'layouts-menu');

      expect(find.byKey(const Key('shared-v9')), findsOneWidget);
      expect(find.byKey(const Key('shared-delete-v9')), findsNothing);
    });
  });

  group('selection and bulk edit', () {
    testWidgets('picked rows show the bar; the count survives a regroup', (
      tester,
    ) async {
      await _open(tester);
      expect(find.byKey(const Key('bulk-bar')), findsNothing);

      await _tap(tester, 'check-a');
      await _tap(tester, 'check-b');
      expect(find.text('2 selected'), findsOneWidget);

      await _tap(tester, 'group-menu');
      await _tap(tester, 'group-by-priority');
      expect(find.text('2 selected'), findsOneWidget);
      expect(
        tester.widget<Checkbox>(find.byKey(const Key('check-a'))).value,
        isTrue,
      );

      await _tap(tester, 'bulk-clear');
      expect(find.byKey(const Key('bulk-bar')), findsNothing);
    });

    testWidgets('select all picks every task, again drops them', (
      tester,
    ) async {
      await _open(tester);

      await _tap(tester, 'select-all');
      expect(find.text('3 selected'), findsOneWidget);

      await _tap(tester, 'select-all');
      expect(find.byKey(const Key('bulk-bar')), findsNothing);
    });

    testWidgets('shift-click picks a range', (tester) async {
      await _open(tester);
      await _tap(tester, 'check-a');

      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.tap(find.byKey(const Key('check-c')));
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      await tester.pumpAndSettle();

      expect(find.text('3 selected'), findsOneWidget);
    });

    testWidgets('setting a status changes every picked task and clears them', (
      tester,
    ) async {
      final s = await _open(tester);
      await _tap(tester, 'check-a');
      await _tap(tester, 'check-b');

      await _tap(tester, 'bulk-status');
      await _tap(tester, 'bulk-status-done');

      expect(s.tasks.bulkCalls.single.ids, ['a', 'b']);
      expect(s.tasks.bulkCalls.single.change.status!.id, 'done');
      expect(statusCell('a', 'Done'), findsOneWidget);
      expect(statusCell('b', 'Done'), findsOneWidget);
      expect(find.byKey(const Key('bulk-bar')), findsNothing);
      expect(find.text('2 tasks updated'), findsOneWidget);
    });

    testWidgets('a task that refuses stays picked and is explained', (
      tester,
    ) async {
      final s = await _open(tester);
      s.tasks.bulkRefusals['a'] = (
        code: 'TASK_BLOCKED',
        message: 'Blocked by WEB-9.',
      );
      await _tap(tester, 'check-a');
      await _tap(tester, 'check-b');

      await _tap(tester, 'bulk-priority');
      await _tap(tester, 'bulk-priority-urgent');

      expect(find.byKey(const Key('bulk-partial')), findsOneWidget);
      expect(
        find.text('1 of 2 tasks updated; 1 could not be.'),
        findsOneWidget,
      );
      expect(find.text('1 selected'), findsOneWidget);
      expect(
        tester.widget<Checkbox>(find.byKey(const Key('check-a'))).value,
        isTrue,
      );

      await _tap(tester, 'bulk-details');
      expect(find.text('WEB-1'), findsWidgets);
      expect(find.text('Blocked by WEB-9.'), findsOneWidget);
    });

    testWidgets('progress shows while the server works', (tester) async {
      final s = await _open(tester);
      s.tasks.bulkGate = Completer<void>();
      await _tap(tester, 'check-a');
      await _tap(tester, 'check-b');

      await tester.tap(find.byKey(const Key('bulk-priority')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('bulk-priority-low')));
      await tester.pump();
      await tester.pump();

      expect(find.byKey(const Key('bulk-progress')), findsOneWidget);
      expect(find.text('Updating 0 of 2…'), findsOneWidget);
      expect(
        tester
            .widget<TextButton>(find.byKey(const Key('bulk-clear')))
            .onPressed,
        isNull,
      );

      s.tasks.bulkGate!.complete();
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('bulk-progress')), findsNothing);
    });

    testWidgets(
      'delete asks first, then removes the tasks and their subtasks',
      (tester) async {
        final s = await _open(tester);
        await _tap(tester, 'check-a');

        await _tap(tester, 'bulk-delete');
        expect(s.tasks.bulkCalls, isEmpty);
        await _tap(tester, 'bulk-delete-confirm');

        expect(s.tasks.bulkCalls.single.change.delete, isTrue);
        expect(_titles(tester), ['b', 'c']);
      },
    );

    testWidgets('a viewer is offered nothing to change', (tester) async {
      await _open(tester, role: 'Viewer');

      await _tap(tester, 'check-a');

      expect(find.byKey(const Key('bulk-status')), findsNothing);
      expect(find.byKey(const Key('bulk-priority')), findsNothing);
      expect(find.byKey(const Key('bulk-delete')), findsNothing);
      expect(find.byKey(const Key('bulk-clear')), findsOneWidget);
    });
  });

  group('keyboard', () {
    testWidgets('arrows move, Space picks, Enter opens, Esc clears', (
      tester,
    ) async {
      await _open(tester);
      // The focus is in the table once a row has been clicked.
      await tester.tap(find.byKey(const Key('task-a')));
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();
      expect(find.text('1 selected'), findsOneWidget);
      expect(
        tester.widget<Checkbox>(find.byKey(const Key('check-b'))).value,
        isTrue,
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(find.text('WEB-2'), findsWidgets);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('bulk-bar')), findsNothing);
    });

    testWidgets('Ctrl+A picks every row; F2 renames the focused one', (
      tester,
    ) async {
      final s = await _open(tester);
      await tester.tap(find.byKey(const Key('task-a')));
      await tester.pumpAndSettle();

      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pumpAndSettle();
      expect(find.text('3 selected'), findsOneWidget);

      await tester.sendKeyEvent(LogicalKeyboardKey.f2);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('rename-a')), findsOneWidget);
      await tester.enterText(find.byKey(const Key('rename-a')), 'Zed');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(s.tasks.updates.single.patch.title, 'Zed');
    });

    testWidgets('a column header sorts on Enter, the menus open on Enter', (
      tester,
    ) async {
      final s = await _open(tester);

      await _tabTo(tester, 'header-due_date');
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(s.tasks.queries.last.sort, [const SortKey('due_date')]);

      await _tabTo(tester, 'columns-menu');
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('column-created_at')), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
    });

    testWidgets('the bulk bar works without a mouse', (tester) async {
      final s = await _open(tester);
      await _tap(tester, 'check-a');

      await _tabTo(tester, 'bulk-priority');
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(s.tasks.bulkCalls.single.ids, ['a']);
      expect(s.tasks.bulkCalls.single.change.priority, isNotNull);
    });

    testWidgets('on a group header Enter folds the group', (tester) async {
      await _open(tester);
      await _tap(tester, 'group-menu');
      await _tap(tester, 'group-by-priority');
      await tester.tap(find.byKey(const Key('task-b')));
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(_titles(tester), ['a', 'c']);
    });
  });

  group('layouts', () {
    testWidgets(
      'a shared layout is applied and then kept as the person\'s own',
      (tester) async {
        final views = FakeViewsClient([
          const SavedView(
            id: 'v9',
            name: 'By due date',
            layout: ListLayout(
              columns: ['due_date'],
              sort: [SortKey('due_date')],
            ),
            isShared: true,
            version: 1,
          ),
        ]);
        final s = await _open(tester, views: views);

        await _tap(tester, 'layouts-menu');
        await _tap(tester, 'shared-v9');
        await _saveDelay(tester);

        expect(s.tasks.queries.last.sort, [const SortKey('due_date')]);
        expect(find.byKey(const Key('header-status')), findsNothing);
        expect(views.saves.last.shared, isFalse);
      },
    );

    testWidgets('someone who manages the project can share the layout', (
      tester,
    ) async {
      final s = await _open(tester);
      await _tap(tester, 'group-menu');
      await _tap(tester, 'group-by-status');

      await _tap(tester, 'layouts-menu');
      await _tap(tester, 'layout-share');
      await tester.enterText(
        find.byKey(const Key('layout-name')),
        'Status view',
      );
      await _tap(tester, 'layout-share-confirm');

      final shared = s.views.saves.where((v) => v.shared).single;
      expect(shared.name, 'Status view');
      expect(shared.layout.groupBy, 'status');
    });

    testWidgets('a viewer cannot share a layout', (tester) async {
      await _open(tester, role: 'Viewer');

      await _tap(tester, 'layouts-menu');

      expect(find.byKey(const Key('layout-share')), findsNothing);
      expect(find.byKey(const Key('layout-reset')), findsOneWidget);
    });

    testWidgets('a layout that cannot be saved says so', (tester) async {
      final views = FakeViewsClient()
        ..failSave = const ViewException(ViewFailure.network);
      await _open(tester, views: views);

      await _tap(tester, 'header-title');
      await _saveDelay(tester);

      expect(find.byKey(const Key('layout-not-saved')), findsOneWidget);
    });
  });

  group('phone', () {
    testWidgets('shows cards, with sort and group in the toolbar', (
      tester,
    ) async {
      final s = await _open(tester, size: _phone);

      expect(find.byKey(const Key('table-header')), findsNothing);
      expect(find.byKey(const Key('task-a')), findsOneWidget);

      await _tap(tester, 'sort-menu');
      await _tap(tester, 'sort-title');
      expect(s.tasks.queries.last.sort, [const SortKey('title')]);

      await _tap(tester, 'group-menu');
      await _tap(tester, 'group-by-status');
      expect(find.byKey(const Key('group-todo')), findsOneWidget);
      expect(find.byKey(const Key('group-count-todo')), findsOneWidget);
    });

    testWidgets('long-press starts picking, taps then pick instead of open', (
      tester,
    ) async {
      await _open(tester, size: _phone);

      await tester.longPress(find.byKey(const Key('task-a')));
      await tester.pumpAndSettle();
      expect(find.text('1 selected'), findsOneWidget);

      await tester.tap(find.byKey(const Key('task-b')));
      await tester.pumpAndSettle();
      expect(find.text('2 selected'), findsOneWidget);
      expect(find.byKey(const Key('detail-title')), findsNothing);
    });

    testWidgets('swiping right completes the task', (tester) async {
      final s = await _open(tester, size: _phone);

      await tester.drag(find.byKey(const Key('task-a')), const Offset(500, 0));
      await tester.pumpAndSettle();

      expect(s.tasks.updates.single.patch.status!.id, 'done');
      expect(find.byKey(const Key('task-a')), findsOneWidget);
    });

    testWidgets('pulling down reads the list again', (tester) async {
      final s = await _open(tester, size: _phone);
      final calls = s.tasks.listCalls;

      await tester.fling(
        find.byKey(const Key('task-list')),
        const Offset(0, 400),
        1000,
      );
      await tester.pumpAndSettle();

      expect(s.tasks.listCalls, calls + 1);
    });
  });
}
