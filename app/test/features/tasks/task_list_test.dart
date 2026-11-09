import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/features/tasks/application/tasks_providers.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';

import 'fakes.dart';

ProviderContainer _container(FakeTasksClient server) {
  final container = ProviderContainer(
    overrides: [
      tasksClientProvider.overrideWithValue(server),
      workspaceScopeProvider.overrideWithValue('w1'),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

Future<TaskListState> _loaded(ProviderContainer container) async {
  final sub = container.listen(taskListProvider('p1'), (_, _) {});
  addTearDown(sub.close);
  while (container.read(taskListProvider('p1')).loading) {
    await Future<void>.delayed(Duration.zero);
  }
  return container.read(taskListProvider('p1'));
}

void main() {
  _reviewFixes();
  test('starts loading, then holds every streamed task in order', () async {
    final server = FakeTasksClient([task('a', 'A'), task('b', 'B', number: 2)]);
    final container = _container(server);

    final first = container.read(taskListProvider('p1'));
    final done = await _loaded(container);

    expect(first.loading, isTrue);
    expect(first.tasks, isEmpty);
    expect([for (final t in done.tasks) t.title], ['A', 'B']);
    expect(done.error, isNull);
  });

  test('a failed stream keeps what arrived and reports the error', () async {
    final server = FakeTasksClient([task('a', 'A')])
      ..failList = const TaskException(TaskFailure.network);
    final container = _container(server);

    final state = await _loaded(container);

    expect(state.error?.failure, TaskFailure.network);
    expect(state.loading, isFalse);
  });

  test('update shows the change before the server answers', () async {
    final server = FakeTasksClient([task('a', 'Old')]);
    final container = _container(server);
    await _loaded(container);
    final list = container.read(taskListProvider('p1').notifier);

    final pending = list.update(
      container.read(taskListProvider('p1')).tasks.single,
      const TaskPatch(title: 'New'),
    );

    expect(container.read(taskListProvider('p1')).tasks.single.title, 'New');
    final saved = await pending;
    expect(saved.version, 2);
    expect(container.read(taskListProvider('p1')).tasks.single.version, 2);
    expect(server.updates.single.patch.fields, ['title']);
  });

  test('a refused update puts the old task back and rethrows', () async {
    final server = FakeTasksClient([task('a', 'Old')])
      ..failNext = const TaskException(TaskFailure.forbidden);
    final container = _container(server);
    final state = await _loaded(container);
    final list = container.read(taskListProvider('p1').notifier);

    await expectLater(
      list.update(state.tasks.single, const TaskPatch(title: 'New')),
      throwsA(
        isA<TaskException>().having(
          (e) => e.failure,
          'failure',
          TaskFailure.forbidden,
        ),
      ),
    );

    expect(container.read(taskListProvider('p1')).tasks.single.title, 'Old');
  });

  test('a conflict shows their value in the list and reports it', () async {
    final server = FakeTasksClient(
      [task('a', 'Old')],
    )..conflictNext = (field: 'title', theirs: task('a', 'Theirs', version: 2));
    final container = _container(server);
    final state = await _loaded(container);
    final list = container.read(taskListProvider('p1').notifier);

    TaskException? caught;
    try {
      await list.update(state.tasks.single, const TaskPatch(title: 'Mine'));
    } on TaskException catch (e) {
      caught = e;
    }

    expect(caught?.failure, TaskFailure.conflict);
    expect(caught?.conflict?.field, 'title');
    expect(caught?.conflict?.current, 'Theirs');
    final shown = container.read(taskListProvider('p1')).tasks.single;
    expect(shown.title, 'Theirs');
    expect(shown.version, 2);
  });

  test('keep mine resends against the current version', () async {
    final server = FakeTasksClient(
      [task('a', 'Old')],
    )..conflictNext = (field: 'title', theirs: task('a', 'Theirs', version: 2));
    final container = _container(server);
    final state = await _loaded(container);
    final list = container.read(taskListProvider('p1').notifier);
    await list
        .update(state.tasks.single, const TaskPatch(title: 'Mine'))
        .then<void>((_) {}, onError: (Object _) {});

    final current = container.read(taskListProvider('p1')).tasks.single;
    final saved = await list.update(
      current,
      const TaskPatch(title: 'Mine'),
      expectedVersion: current.version,
    );

    expect(saved.title, 'Mine');
    expect(server.updates.last.expectedVersion, 2);
  });

  test('delete removes at once and comes back if refused', () async {
    final server = FakeTasksClient([task('a', 'A'), task('b', 'B', number: 2)]);
    final container = _container(server);
    final state = await _loaded(container);
    final list = container.read(taskListProvider('p1').notifier);

    final done = list.delete(state.tasks.first);
    expect(container.read(taskListProvider('p1')).tasks.length, 1);
    await done;
    expect(server.deleted, ['a']);

    server.failNext = const TaskException(TaskFailure.denied, detail: 'no');
    await expectLater(
      list.delete(container.read(taskListProvider('p1')).tasks.single),
      throwsA(isA<TaskException>()),
    );
    expect(container.read(taskListProvider('p1')).tasks.length, 1);
  });

  test('create appends the numbered task', () async {
    final server = FakeTasksClient([task('a', 'A')]);
    final container = _container(server);
    await _loaded(container);

    final created = await container
        .read(taskListProvider('p1').notifier)
        .create('Fix it', priority: TaskPriority.high);

    expect(created.displayId, 'WEB-2');
    expect(container.read(taskListProvider('p1')).tasks.last.title, 'Fix it');
  });

  test('a stream longer than one batch ends complete', () async {
    final server = FakeTasksClient([
      for (var i = 1; i <= streamBatch * 2 + 5; i++)
        task('t$i', 'Task $i', number: i),
    ]);
    final container = _container(server);

    final state = await _loaded(container);

    expect(state.tasks.length, streamBatch * 2 + 5);
    expect(state.loading, isFalse);
  });

  test('the first tasks are shown while the stream is still open', () async {
    final server = FakeTasksClient([
      for (var i = 1; i <= streamBatch + 1; i++) task('t$i', 'T$i', number: i),
    ]);
    final gate = Completer<void>();
    server.gate = gate;
    final container = _container(server);
    final sub = container.listen(taskListProvider('p1'), (_, _) {});
    addTearDown(sub.close);

    await Future<void>.delayed(Duration.zero);
    expect(container.read(taskListProvider('p1')).loading, isTrue);
    gate.complete();
    final state = await _loaded(container);
    expect(state.tasks, hasLength(streamBatch + 1));
  });
}

void _reviewFixes() {
  test('a failed edit does not undo a different edit that succeeded', () async {
    final server = FakeTasksClient([task('a', 'Old')]);
    final container = _container(server);
    final state = await _loaded(container);
    final list = container.read(taskListProvider('p1').notifier);
    final gate = server.updateGate = Completer<void>();
    server.failNext = const TaskException(TaskFailure.forbidden);

    final first = list
        .update(state.tasks.single, const TaskPatch(title: 'Nope'))
        .then<void>((_) {}, onError: (Object _) {});
    final second = list.update(
      state.tasks.single,
      const TaskPatch(priority: TaskPriority.urgent),
    );
    gate.complete();
    await first;
    await second;

    final shown = container.read(taskListProvider('p1')).tasks.single;
    expect(shown.title, 'Old');
    expect(shown.priority, TaskPriority.urgent);
    expect(shown.version, 2);
  });

  test('an edit made from a stale snapshot keeps the earlier edit', () async {
    final server = FakeTasksClient([task('a', 'Old')]);
    final container = _container(server);
    final stale = (await _loaded(container)).tasks.single;
    final list = container.read(taskListProvider('p1').notifier);

    await list.update(stale, const TaskPatch(title: 'New'));
    await list.update(stale, const TaskPatch(priority: TaskPriority.high));

    final shown = container.read(taskListProvider('p1')).tasks.single;
    expect((shown.title, shown.priority), ('New', TaskPriority.high));
    expect(
      server.updates.last.task.version,
      2,
      reason: 'sent from the current task',
    );
  });

  test('a task created while the list is still loading is kept', () async {
    final server = FakeTasksClient([task('a', 'A')]);
    final gate = server.gate = Completer<void>();
    final container = _container(server);
    final sub = container.listen(taskListProvider('p1'), (_, _) {});
    addTearDown(sub.close);
    await Future<void>.delayed(Duration.zero);

    await container.read(taskListProvider('p1').notifier).create('Early');
    gate.complete();
    final state = await _loaded(container);

    expect([for (final t in state.tasks) t.title], ['A', 'Early']);
  });

  test('restoring puts the task back once, never twice', () async {
    final server = FakeTasksClient([task('a', 'A')]);
    final container = _container(server);
    final state = await _loaded(container);
    final list = container.read(taskListProvider('p1').notifier);

    await list.restore(state.tasks.single);
    await list.restore(state.tasks.single);

    expect(container.read(taskListProvider('p1')).tasks, hasLength(1));
  });
}
