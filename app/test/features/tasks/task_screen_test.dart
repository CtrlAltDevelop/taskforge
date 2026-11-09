import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/app_router.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';

import '../projects/fakes.dart';
import '../projects/projects_test_support.dart';
import 'fakes.dart';

Future<(Pumped, FakeTasksClient)> _open(
  WidgetTester tester, {
  List<Task> tasks = const [],
  String role = 'Owner',
  bool archived = false,
  Size size = const Size(1400, 1200),
  FakeTasksClient? server,
}) async {
  final fake = server ?? FakeTasksClient(tasks);
  final pumped = await pumpProjects(
    tester,
    role: role,
    projects: [project('p1', 'Web', archived: archived)],
    tasks: fake,
    size: size,
  );
  await pumped.go(tester, '/projects/p1');
  return (pumped, fake);
}

void main() {
  testWidgets('shows a skeleton while loading, then the tasks', (tester) async {
    final server = FakeTasksClient([task('a', 'First task')]);
    final gate = server.gate = Completer<void>();
    final pumped = await pumpProjects(
      tester,
      projects: [project('p1', 'Web')],
      tasks: server,
    );
    pumped.container.read(routerProvider).go('/projects/p1');
    await tester.pump();
    await tester.pump();

    expect(find.byKey(const Key('tasks-skeleton')), findsOneWidget);

    gate.complete();
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('tasks-skeleton')), findsNothing);
    expect(find.text('First task'), findsOneWidget);
    expect(find.text('WEB-1 · To do'), findsOneWidget);
  });

  testWidgets('an empty project says so', (tester) async {
    await _open(tester);

    expect(find.byKey(const Key('no-tasks')), findsOneWidget);
  });

  testWidgets('a failed load offers a retry that works', (tester) async {
    final server = FakeTasksClient([task('a', 'Back again')])
      ..failList = const TaskException(TaskFailure.network);
    await _open(tester, server: server);

    expect(find.byKey(const Key('retry-tasks')), findsOneWidget);

    server.failList = null;
    await tester.tap(find.byKey(const Key('retry-tasks')));
    await tester.pumpAndSettle();

    expect(find.text('Back again'), findsOneWidget);
  });

  testWidgets('quick-add creates a numbered task and clears the field', (
    tester,
  ) async {
    final (_, server) = await _open(tester);

    await tester.enterText(find.byKey(const Key('quick-add')), '  Fix login ');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(server.tasks.single.title, 'Fix login');
    expect(find.text('Fix login'), findsOneWidget);
    expect(find.text('WEB-1 · To do'), findsOneWidget);
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('quick-add')))
          .controller!
          .text,
      '',
    );
  });

  testWidgets('a viewer can read tasks but not add or edit', (tester) async {
    await _open(tester, role: 'Viewer', tasks: [task('a', 'Read me')]);

    expect(find.byKey(const Key('quick-add')), findsNothing);
    await tester.tap(find.text('Read me'));
    await tester.pumpAndSettle();

    expect(
      tester.widget<TextField>(find.byKey(const Key('detail-title'))).enabled,
      isFalse,
    );
    expect(find.byKey(const Key('delete-task')), findsNothing);
  });

  testWidgets('an archived project is read-only', (tester) async {
    await _open(tester, archived: true, tasks: [task('a', 'Frozen')]);

    expect(find.byKey(const Key('quick-add')), findsNothing);
    await tester.tap(find.text('Frozen'));
    await tester.pumpAndSettle();

    expect(
      tester.widget<TextField>(find.byKey(const Key('detail-title'))).enabled,
      isFalse,
    );
  });

  testWidgets('wide screens open the detail beside the list', (tester) async {
    await _open(tester, tasks: [task('a', 'Side by side')]);

    await tester.tap(find.byKey(const Key('task-a')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('task-list')), findsOneWidget);
    expect(find.byKey(const Key('task-detail')), findsOneWidget);
    expect(find.byKey(const Key('detail-id')), findsOneWidget);

    await tester.tap(find.byKey(const Key('close-detail')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('task-detail')), findsNothing);
  });

  testWidgets('narrow screens open the detail as a page', (tester) async {
    await _open(
      tester,
      size: const Size(420, 900),
      tasks: [task('a', 'Full page')],
    );

    await tester.tap(find.byKey(const Key('task-a')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('task-detail')), findsOneWidget);
    expect(find.byKey(const Key('task-list')), findsNothing);
  });

  testWidgets('editing the title sends only the title and shows it', (
    tester,
  ) async {
    final (_, server) = await _open(tester, tasks: [task('a', 'Old title')]);
    await tester.tap(find.byKey(const Key('task-a')));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('detail-title')), 'New title');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(server.updates.single.patch.fields, ['title']);
    expect(server.tasks.single.title, 'New title');
    expect(find.text('New title'), findsWidgets);
  });

  testWidgets('changing priority and status saves each field alone', (
    tester,
  ) async {
    final (_, server) = await _open(tester, tasks: [task('a', 'T')]);
    await tester.tap(find.byKey(const Key('task-a')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('detail-priority')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Urgent').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('detail-status')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done').last);
    await tester.pumpAndSettle();

    expect(server.updates.map((u) => u.patch.fields), [
      ['priority'],
      ['status'],
    ]);
    expect(server.tasks.single.priority, TaskPriority.urgent);
    expect(server.tasks.single.status, TaskStatus.done);
  });

  testWidgets('a refused edit goes back and says why', (tester) async {
    final server = FakeTasksClient([task('a', 'Keep me')]);
    await _open(tester, server: server);
    await tester.tap(find.byKey(const Key('task-a')));
    await tester.pumpAndSettle();
    server.failNext = const TaskException(
      TaskFailure.denied,
      detail: 'You need permission "task.update"',
    );

    await tester.enterText(find.byKey(const Key('detail-title')), 'Nope');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(find.text('You need permission "task.update"'), findsOneWidget);
    expect(find.text('Keep me'), findsWidgets);
  });

  testWidgets('a conflict offers their value or mine, and keep mine wins', (
    tester,
  ) async {
    final server = FakeTasksClient([task('a', 'Original')]);
    await _open(tester, server: server);
    await tester.tap(find.byKey(const Key('task-a')));
    await tester.pumpAndSettle();
    server.conflictNext = (
      field: 'title',
      theirs: task('a', 'Their title', version: 2),
    );

    await tester.enterText(find.byKey(const Key('detail-title')), 'My title');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('keep-mine')), findsOneWidget);
    expect(
      tester.widget<Text>(find.byKey(const Key('theirs'))).data,
      'Their title',
    );
    expect(tester.widget<Text>(find.byKey(const Key('mine'))).data, 'My title');

    await tester.tap(find.byKey(const Key('keep-mine')));
    await tester.pumpAndSettle();

    expect(server.updates.last.expectedVersion, 2);
    expect(server.tasks.single.title, 'My title');
  });

  testWidgets('take theirs leaves the other value in place', (tester) async {
    final server = FakeTasksClient([task('a', 'Original')]);
    await _open(tester, server: server);
    await tester.tap(find.byKey(const Key('task-a')));
    await tester.pumpAndSettle();
    server.conflictNext = (
      field: 'title',
      theirs: task('a', 'Their title', version: 2),
    );

    await tester.enterText(find.byKey(const Key('detail-title')), 'My title');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('take-theirs')));
    await tester.pumpAndSettle();

    expect(server.updates, hasLength(1));
    expect(server.tasks.single.title, 'Their title');
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('detail-title')))
          .controller!
          .text,
      'Their title',
    );
  });

  testWidgets('assignees are picked as chips', (tester) async {
    final (_, server) = await _open(tester, tasks: [task('a', 'T')]);
    await tester.tap(find.byKey(const Key('task-a')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('assignee-u2')));
    await tester.pumpAndSettle();

    expect(server.updates.single.patch.assigneeIds, ['u2']);
    expect(server.tasks.single.assigneeIds, ['u2']);
  });

  testWidgets('deleting removes the task and Undo brings it back', (
    tester,
  ) async {
    final (_, server) = await _open(tester, tasks: [task('a', 'Short lived')]);
    await tester.tap(find.byKey(const Key('task-a')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('delete-task')));
    await tester.pumpAndSettle();

    expect(server.deleted, ['a']);
    expect(find.byKey(const Key('task-a')), findsNothing);
    expect(find.text('WEB-1 deleted'), findsOneWidget);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('task-a')), findsOneWidget);
  });
}
