import 'package:taskforge/features/views/application/views_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/features/projects/domain/projects.dart';
import 'package:taskforge/features/tasks/application/tasks_providers.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';

import '../projects/fakes.dart';
import '../projects/projects_test_support.dart';
import 'fakes.dart';
import '../views/fakes.dart';

Future<(Pumped, FakeTasksClient)> _open(
  WidgetTester tester, {
  List<Project>? projects,
  List<dynamic> tasks = const [],
  String role = 'Owner',
  FakeProjectsClient? server,
}) async {
  final fake = FakeTasksClient([for (final t in tasks) t]);
  final pumped = await pumpProjects(
    tester,
    role: role,
    projects: projects ?? [project('p1', 'Web')],
    server: server,
    tasks: fake,
  );
  await pumped.go(tester, '/projects/p1');
  return (pumped, fake);
}

void main() {
  testWidgets('deleted tasks are listed in the trash and can be restored', (
    tester,
  ) async {
    final (_, server) = await _open(tester, tasks: [task('a', 'Gone soon')]);
    await tester.tap(find.byKey(const Key('task-a')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('delete-task')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('task-a')), findsNothing);

    await tester.tap(find.byKey(const Key('open-task-trash')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('trashed-a')), findsOneWidget);
    expect(find.text('WEB-1 · deleted'), findsOneWidget);

    await tester.tap(find.byKey(const Key('restore-a')));
    await tester.pumpAndSettle();
    expect(server.trashed, isEmpty);
    expect(find.byKey(const Key('trash-empty')), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('task-a')), findsOneWidget);
  });

  testWidgets('an empty trash says so', (tester) async {
    await _open(tester);

    await tester.tap(find.byKey(const Key('open-task-trash')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('trash-empty')), findsOneWidget);
  });

  testWidgets('a failed trash read offers a retry', (tester) async {
    final (_, server) = await _open(tester, tasks: [task('a', 'A')]);
    server.failNext = const TaskException(TaskFailure.network);

    await tester.tap(find.byKey(const Key('open-task-trash')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('retry-trash')), findsOneWidget);

    await tester.tap(find.byKey(const Key('retry-trash')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('trash-empty')), findsOneWidget);
  });

  testWidgets('a viewer has no trash', (tester) async {
    await _open(tester, role: 'Viewer');

    expect(find.byKey(const Key('open-task-trash')), findsNothing);
  });

  testWidgets('a private project only offers its own members as assignees', (
    tester,
  ) async {
    final projects = FakeProjectsClient([project('p1', 'Web', private: true)]);
    projects.members['p1'] = [
      const ProjectMember(userId: 'u1', displayName: 'Zoe', email: 'z@x.io'),
    ];
    await _open(
      tester,
      server: projects,
      projects: [project('p1', 'Web', private: true)],
      tasks: [task('a', 'Secret')],
    );
    await tester.tap(find.byKey(const Key('task-a')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('assignee-u1')), findsOneWidget);
    expect(find.byKey(const Key('assignee-u2')), findsNothing);
  });

  testWidgets('an open project offers every workspace member', (tester) async {
    await _open(tester, tasks: [task('a', 'Open')]);
    await tester.tap(find.byKey(const Key('task-a')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('assignee-u1')), findsOneWidget);
    expect(find.byKey(const Key('assignee-u2')), findsOneWidget);
  });

  test('10,000 tasks: the first page is in the list within 500 ms', () async {
    final server = FakeTasksClient([
      for (var i = 1; i <= 10000; i++) task('t$i', 'Task $i', number: i),
    ]);
    final container = ProviderContainer(
      overrides: [
        viewsClientProvider.overrideWithValue(FakeViewsClient()),
        tasksClientProvider.overrideWithValue(server),
        workspaceScopeProvider.overrideWithValue('w1'),
      ],
    );
    addTearDown(container.dispose);
    final timer = Stopwatch()..start();
    Duration? firstPage;
    final sub = container.listen(taskListProvider('p1'), (_, state) {
      if (firstPage == null && state.tasks.length >= streamBatch) {
        firstPage = timer.elapsed;
      }
    });
    addTearDown(sub.close);

    while (container.read(taskListProvider('p1')).loading) {
      await Future<void>.delayed(Duration.zero);
    }
    timer.stop();

    expect(container.read(taskListProvider('p1')).tasks, hasLength(10000));
    expect(firstPage, isNotNull);
    expect(firstPage!, lessThan(const Duration(milliseconds: 500)));
    // Whole list too: nothing about the stream is quadratic.
    expect(timer.elapsed, lessThan(const Duration(seconds: 5)));
  });
}
