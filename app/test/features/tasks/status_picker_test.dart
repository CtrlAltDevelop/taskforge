import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';
import 'package:taskforge/features/workflows/domain/workflow.dart';

import '../projects/fakes.dart';
import '../projects/projects_test_support.dart';
import '../workflows/fakes.dart';
import 'fakes.dart';

Future<FakeTasksClient> _open(
  WidgetTester tester, {
  required Workflow workflow,
  List<Task>? tasks,
  String role = 'Owner',
}) async {
  final server = FakeTasksClient(tasks ?? [task('a', 'Move me')]);
  final pumped = await pumpProjects(
    tester,
    role: role,
    projects: [project('p1', 'Web')],
    tasks: server,
    workflows: FakeWorkflowsClient(workflow),
  );
  await pumped.go(tester, '/projects/p1');
  await tester.tap(find.byKey(const Key('task-a')));
  await tester.pumpAndSettle();
  return server;
}

Future<void> _openPicker(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('detail-status')));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('an unrestricted workflow offers every status', (tester) async {
    await _open(tester, workflow: defaultWorkflow());

    await _openPicker(tester);

    expect(find.text('In progress'), findsWidgets);
    expect(find.text('Done'), findsWidgets);
  });

  testWidgets('a restricted workflow offers only where the task may go', (
    tester,
  ) async {
    await _open(
      tester,
      workflow: defaultWorkflow(
        restrict: true,
        transitions: const [WorkflowTransition(from: 'todo', to: 'doing')],
      ),
    );

    await _openPicker(tester);

    expect(find.text('In progress'), findsWidgets);
    expect(find.text('Done'), findsNothing);
  });

  testWidgets(
    'an assignee condition hides the move until someone is assigned',
    (tester) async {
      await _open(
        tester,
        workflow: defaultWorkflow(
          restrict: true,
          transitions: const [
            WorkflowTransition(
              from: 'todo',
              to: 'doing',
              requireAssignee: true,
            ),
          ],
        ),
      );

      await _openPicker(tester);
      expect(find.text('In progress'), findsNothing);
    },
  );

  testWidgets('a role condition offers the move only to that role', (
    tester,
  ) async {
    final flow = defaultWorkflow(
      restrict: true,
      transitions: const [
        WorkflowTransition(from: 'todo', to: 'doing', requiredRoleId: 'nobody'),
      ],
    );
    await _open(tester, workflow: flow);

    await _openPicker(tester);

    expect(find.text('In progress'), findsNothing);
  });

  testWidgets('picking a status moves the task and shows the new name', (
    tester,
  ) async {
    final server = await _open(tester, workflow: defaultWorkflow());

    await _openPicker(tester);
    await tester.tap(find.text('In progress').last);
    await tester.pumpAndSettle();

    expect(server.updates.single.patch.fields, ['status']);
    expect(server.updates.single.patch.status!.id, 'doing');
    expect(server.tasks.single.statusName, 'In progress');
    expect(statusCell('a', 'In progress'), findsOneWidget);
  });

  testWidgets(
    'a move the server refuses shows its reason and puts the status back',
    (tester) async {
      final server = await _open(tester, workflow: defaultWorkflow());
      server.failNext = const TaskException(
        TaskFailure.transitionNotAllowed,
        detail: 'To do → Done is not allowed.',
      );

      await _openPicker(tester);
      await tester.tap(find.text('Done').last);
      await tester.pumpAndSettle();

      expect(find.text('To do → Done is not allowed.'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const Key('cell-status-a')),
          matching: find.text('To do'),
        ),
        findsOneWidget,
      );
      expect(
        tester
            .widget<DropdownButtonFormField<String>>(
              find.byKey(const Key('detail-status')),
            )
            .initialValue,
        'todo',
      );
    },
  );

  testWidgets(
    'the list shows each task in its status, finished ones struck out',
    (tester) async {
      await _open(
        tester,
        workflow: defaultWorkflow(),
        tasks: [
          task('a', 'Open one'),
          task(
            'b',
            'Finished one',
            number: 2,
            statusId: 'done',
            statusName: 'Done',
            category: StatusCategory.done,
          ),
        ],
      );

      expect(statusCell('a', 'To do'), findsOneWidget);
      expect(statusCell('b', 'Done'), findsOneWidget);
      final struck = tester.widget<Text>(find.text('Finished one'));
      expect(struck.style?.decoration, TextDecoration.lineThrough);
    },
  );

  testWidgets('a viewer cannot change the status', (tester) async {
    await _open(tester, workflow: defaultWorkflow(), role: 'Viewer');

    expect(
      tester
          .widget<DropdownButtonFormField<String>>(
            find.byKey(const Key('detail-status')),
          )
          .onChanged,
      isNull,
    );
  });
}
