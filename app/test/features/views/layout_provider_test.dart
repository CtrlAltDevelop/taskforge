import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/features/fields/application/fields_providers.dart';
import 'package:taskforge/features/fields/domain/field.dart';
import 'package:taskforge/features/tasks/application/tasks_providers.dart';
import 'package:taskforge/features/tasks/domain/bulk.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';
import 'package:taskforge/features/views/application/views_providers.dart';
import 'package:taskforge/features/views/domain/list_layout.dart';
import 'package:taskforge/features/workflows/domain/workflow.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';

import '../fields/fakes.dart';
import '../tasks/fakes.dart';
import 'fakes.dart';

const _waitForSave = Duration(milliseconds: 750);

ProviderContainer _container({
  FakeViewsClient? views,
  FakeTasksClient? tasks,
  FakeFieldsClient? fields,
}) {
  final container = ProviderContainer(
    overrides: [
      viewsClientProvider.overrideWithValue(views ?? FakeViewsClient()),
      tasksClientProvider.overrideWithValue(tasks ?? FakeTasksClient()),
      fieldsClientProvider.overrideWithValue(fields ?? FakeFieldsClient()),
      workspaceScopeProvider.overrideWithValue('w1'),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

Future<void> _ready(ProviderContainer c) async {
  final sub = c.listen(listLayoutProvider('p1'), (_, _) {});
  addTearDown(sub.close);
  while (!c.read(listLayoutProvider('p1')).loaded) {
    await Future<void>.delayed(Duration.zero);
  }
}

SavedView _view(
  String id,
  String name,
  ListLayout layout, {
  bool shared = false,
  int version = 1,
}) => SavedView(
  id: id,
  name: name,
  layout: layout,
  isShared: shared,
  version: version,
);

void main() {
  const mine = ListLayout(
    columns: ['status'],
    sort: [SortKey('title', desc: true)],
    groupBy: 'priority',
  );

  test('reads the person\'s saved layout and the shared ones', () async {
    final views = FakeViewsClient([
      _view('v1', personalLayoutName, mine),
      _view('v2', 'Sprint board', const ListLayout(), shared: true),
    ]);
    final c = _container(views: views);

    await _ready(c);

    final state = c.read(listLayoutProvider('p1'));
    expect(state.layout, mine);
    expect([for (final v in state.shared) v.name], ['Sprint board']);
  });

  test('the list is read once, in the saved order', () async {
    final tasks = FakeTasksClient([task('a', 'A')]);
    final c = _container(
      views: FakeViewsClient([_view('v1', personalLayoutName, mine)]),
      tasks: tasks,
    );
    final sub = c.listen(taskListProvider('p1'), (_, _) {});
    addTearDown(sub.close);

    while (c.read(taskListProvider('p1')).loading) {
      await Future<void>.delayed(Duration.zero);
    }

    expect(tasks.queries, [mine.query]);
  });

  test(
    'a layout that cannot be read leaves the default and the list works',
    () async {
      final tasks = FakeTasksClient([task('a', 'A')]);
      final c = _container(
        views: FakeViewsClient()
          ..failList = const ViewException(ViewFailure.network),
        tasks: tasks,
      );
      final sub = c.listen(taskListProvider('p1'), (_, _) {});
      addTearDown(sub.close);

      while (c.read(taskListProvider('p1')).loading) {
        await Future<void>.delayed(Duration.zero);
      }

      expect(c.read(listLayoutProvider('p1')).layout.sort, isEmpty);
      expect(c.read(taskListProvider('p1')).tasks, hasLength(1));
    },
  );

  test(
    'changes show at once and are saved once, shortly after the last',
    () async {
      final views = FakeViewsClient();
      final c = _container(views: views);
      await _ready(c);
      final layout = c.read(listLayoutProvider('p1').notifier);

      layout.update((l) => l.sortedBy('title'));
      layout.update((l) => l.withWidth('title', 300));
      layout.update((l) => l.groupedBy('status'));

      expect(c.read(listLayoutProvider('p1')).layout.groupBy, 'status');
      expect(views.saves, isEmpty);
      await Future<void>.delayed(_waitForSave);
      expect(views.saves, hasLength(1));
      expect(views.saves.single.name, personalLayoutName);
      expect(views.saves.single.layout.widthOf('title'), 300);
      expect(views.saves.single.shared, isFalse);
    },
  );

  test('the second save replaces the first against its version', () async {
    final views = FakeViewsClient();
    final c = _container(views: views);
    await _ready(c);
    final layout = c.read(listLayoutProvider('p1').notifier);

    layout.update((l) => l.groupedBy('status'));
    await Future<void>.delayed(_waitForSave);
    layout.update((l) => l.groupedBy('priority'));
    await Future<void>.delayed(_waitForSave);

    expect(
      views.saves[1].id,
      views.saves[0].id.isEmpty ? 'v1' : views.saves[0].id,
    );
    expect(views.saves[1].version, 1);
    expect(views.views, hasLength(1));
  });

  test(
    'a conflict from another device is retried against its version',
    () async {
      final views = FakeViewsClient([_view('v1', personalLayoutName, mine)]);
      final c = _container(views: views);
      await _ready(c);
      views.conflictWithVersion = 7;

      c
          .read(listLayoutProvider('p1').notifier)
          .update((l) => l.groupedBy('status'));
      await Future<void>.delayed(_waitForSave);

      expect(views.saves.map((s) => s.version), [1, 7]);
      expect(c.read(listLayoutProvider('p1')).saveFailed, isFalse);
      expect(views.views.single.layout.groupBy, 'status');
    },
  );

  test('a save that fails is flagged, not swallowed', () async {
    final views = FakeViewsClient()
      ..failSave = const ViewException(ViewFailure.network);
    final c = _container(views: views);
    await _ready(c);

    c
        .read(listLayoutProvider('p1').notifier)
        .update((l) => l.groupedBy('status'));
    await Future<void>.delayed(_waitForSave);

    expect(c.read(listLayoutProvider('p1')).saveFailed, isTrue);
    expect(c.read(listLayoutProvider('p1')).layout.groupBy, 'status');
  });

  test('a first read that failed does not stop later saves', () async {
    final views = FakeViewsClient([_view('v1', personalLayoutName, mine)])
      ..failList = const ViewException(ViewFailure.network);
    final c = _container(views: views);
    await _ready(c);
    views.failList = null;

    c
        .read(listLayoutProvider('p1').notifier)
        .update((l) => l.groupedBy('status'));
    await Future<void>.delayed(_waitForSave);

    expect(c.read(listLayoutProvider('p1')).saveFailed, isFalse);
    expect(views.views.single.layout.groupBy, 'status');
    expect(views.views, hasLength(1));
  });

  test(
    'until chosen, columns are the usual ones plus the fields the list shows',
    () async {
      final c = _container(
        fields: FakeFieldsClient([
          field('t', 'Customer', FieldType.text),
          field('h', 'Secret', FieldType.text, hidden: const ['list']),
        ]),
      );
      await _ready(c);
      c.listen(fieldsProvider('p1'), (_, _) {});
      await c.read(fieldsProvider('p1').future);
      await Future<void>.delayed(Duration.zero);

      expect(c.read(listLayoutProvider('p1')).layout.columns, [
        ...defaultColumns,
        'field:t',
      ]);
    },
  );

  test(
    'a shared layout becomes the one in use, then saved as the person\'s own',
    () async {
      final shared = _view(
        'v2',
        'Team',
        const ListLayout(columns: ['priority']),
        shared: true,
      );
      final views = FakeViewsClient([shared]);
      final c = _container(views: views);
      await _ready(c);

      c.read(listLayoutProvider('p1').notifier).useShared(shared);
      await Future<void>.delayed(_waitForSave);

      expect(c.read(listLayoutProvider('p1')).layout.columns, ['priority']);
      expect(views.saves.single.shared, isFalse);
      expect(views.saves.single.name, personalLayoutName);
    },
  );

  test(
    'sharing, overwriting and deleting a shared layout reload the list',
    () async {
      final views = FakeViewsClient();
      final c = _container(views: views);
      await _ready(c);
      final layout = c.read(listLayoutProvider('p1').notifier);

      await layout.shareCurrent('Team');
      var shared = c.read(listLayoutProvider('p1')).shared;
      expect([for (final v in shared) v.name], ['Team']);

      layout.set(const ListLayout(groupBy: 'status'));
      await layout.overwriteShared(shared.single);
      shared = c.read(listLayoutProvider('p1')).shared;
      expect(shared.single.layout.groupBy, 'status');
      expect(shared.single.version, 2);

      await layout.deleteShared(shared.single);
      expect(c.read(listLayoutProvider('p1')).shared, isEmpty);
    },
  );

  group('bulk', () {
    Future<(ProviderContainer, FakeTasksClient)> loaded(
      List<Task> tasks,
    ) async {
      final server = FakeTasksClient(tasks);
      final c = _container(tasks: server);
      final sub = c.listen(taskListProvider('p1'), (_, _) {});
      addTearDown(sub.close);
      while (c.read(taskListProvider('p1')).loading) {
        await Future<void>.delayed(Duration.zero);
      }
      return (c, server);
    }

    test(
      'updates each task as its result arrives and reports progress',
      () async {
        final (c, server) = await loaded([
          task('a', 'A'),
          task('b', 'B', number: 2),
        ]);
        final progress = <int>[];

        final summary = await c
            .read(taskListProvider('p1').notifier)
            .bulk(
              ['a', 'b'],
              const BulkChange(priority: TaskPriority.high),
              onProgress: (done, total) => progress.add(done),
            );

        expect(summary.allOk, isTrue);
        expect(summary.succeeded, ['a', 'b']);
        expect(progress, [1, 2]);
        expect(server.bulkCalls.single.ids, ['a', 'b']);
        expect(c.read(taskListProvider('p1')).tasks.map((t) => t.priority), [
          TaskPriority.high,
          TaskPriority.high,
        ]);
      },
    );

    test(
      'a task that refuses is reported and the others still change',
      () async {
        final (c, server) = await loaded([
          task('a', 'A'),
          task('b', 'B', number: 2),
        ]);
        server.bulkRefusals['a'] = (
          code: 'TASK_BLOCKED',
          message: 'Blocked by WEB-9.',
        );

        final summary = await c.read(taskListProvider('p1').notifier).bulk(
          ['a', 'b'],
          BulkChange(
            status: const WorkflowStatus(id: 'done', name: 'Done'),
          ),
        );

        expect(summary.succeeded, ['b']);
        expect(summary.failed.single.id, 'a');
        expect(summary.failed.single.message, 'Blocked by WEB-9.');
        final now = c.read(taskListProvider('p1')).tasks;
        expect(now.firstWhere((t) => t.id == 'a').statusId, 'todo');
        expect(now.firstWhere((t) => t.id == 'b').statusId, 'done');
      },
    );

    test('a delete reads the list again, as subtasks went too', () async {
      final (c, _) = await loaded([
        task('a', 'A'),
        task('b', 'B', number: 2, parent: 'a', depth: 1),
        task('c', 'C', number: 3),
      ]);

      await c.read(taskListProvider('p1').notifier).bulk([
        'a',
      ], const BulkChange.delete());

      expect(c.read(taskListProvider('p1')).tasks.map((t) => t.id), ['c']);
    });

    test('a call refused as a whole throws and changes nothing', () async {
      final (c, server) = await loaded([task('a', 'A')]);
      server.failBulk = const TaskException(TaskFailure.forbidden);

      await expectLater(
        c.read(taskListProvider('p1').notifier).bulk([
          'a',
        ], const BulkChange(priority: TaskPriority.low)),
        throwsA(
          isA<TaskException>().having(
            (e) => e.failure,
            'failure',
            TaskFailure.forbidden,
          ),
        ),
      );
      expect(
        c.read(taskListProvider('p1')).tasks.single.priority,
        TaskPriority.none,
      );
    });

    test('more than the server takes at once is sent in turns', () async {
      final many = [
        for (var i = 0; i < maxBulkTasks + 5; i++)
          task('t$i', 'T$i', number: i + 1),
      ];
      final (c, server) = await loaded(many);

      final summary = await c.read(taskListProvider('p1').notifier).bulk([
        for (final t in many) t.id,
      ], const BulkChange(priority: TaskPriority.low));

      expect(server.bulkCalls.map((c) => c.ids.length), [maxBulkTasks, 5]);
      expect(summary.succeeded, hasLength(maxBulkTasks + 5));
    });
  });

  test('leaving the project mid-way does not cancel a bulk edit', () async {
    final many = [
      for (var i = 0; i < maxBulkTasks + 5; i++)
        task('t$i', 'T$i', number: i + 1),
    ];
    final server = FakeTasksClient(many);
    final c = _container(tasks: server);
    final sub = c.listen(taskListProvider('p1'), (_, _) {});
    while (c.read(taskListProvider('p1')).loading) {
      await Future<void>.delayed(Duration.zero);
    }

    final running = c.read(taskListProvider('p1').notifier).bulk([
      for (final t in many) t.id,
    ], const BulkChange(priority: TaskPriority.low));
    sub.close(); // the person navigates away
    final summary = await running;

    expect(server.bulkCalls.map((c) => c.ids.length), [maxBulkTasks, 5]);
    expect(summary.succeeded, hasLength(maxBulkTasks + 5));
  });

  test('selection is by id: it survives and can be extended and cleared', () {
    final c = _container();
    final selection = c.read(taskSelectionProvider('p1').notifier);
    c.listen(taskSelectionProvider('p1'), (_, _) {});

    selection.toggle('a');
    selection.addAll(['b', 'c']);
    selection.toggle('b');
    expect(c.read(taskSelectionProvider('p1')), {'a', 'c'});

    selection.removeAll(['a']);
    expect(c.read(taskSelectionProvider('p1')), {'c'});
    selection.clear();
    expect(c.read(taskSelectionProvider('p1')), isEmpty);
  });
}
