import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/features/workflows/domain/workflow.dart';
import 'package:taskforge/features/workflows/domain/workflow_draft.dart';
import 'package:taskforge/features/workflows/presentation/workflow_graph.dart';

import '../projects/fakes.dart';
import '../projects/projects_test_support.dart';
import 'fakes.dart';

const _phone = Size(420, 1400);

Future<FakeWorkflowsClient> _open(
  WidgetTester tester, {
  Workflow? workflow,
  String role = 'Owner',
  bool archived = false,
  Size size = const Size(1400, 1200),
  FakeWorkflowsClient? server,
}) async {
  final fake = server ?? FakeWorkflowsClient(workflow);
  final pumped = await pumpProjects(
    tester,
    role: role,
    projects: [project('p1', 'Web', archived: archived)],
    workflows: fake,
    size: size,
  );
  await pumped.go(tester, '/projects/p1/workflow');
  return fake;
}

Future<void> _save(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('workflow-save')));
  await tester.pumpAndSettle();
}

Future<void> _type(WidgetTester tester, String key, String text) async {
  await tester.enterText(find.byKey(Key(key)), text);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows every status with its category and the default marked', (
    tester,
  ) async {
    await _open(tester);

    expect(find.byKey(const Key('status-todo')), findsOneWidget);
    expect(find.byKey(const Key('status-doing')), findsOneWidget);
    expect(find.byKey(const Key('status-done')), findsOneWidget);
    expect(find.text('Not started'), findsWidgets);
    expect(find.byKey(const Key('validation-ok')), findsOneWidget);
    expect(
      tester
          .widget<IconButton>(find.byKey(const Key('status-default-todo')))
          .onPressed,
      isNull,
      reason: 'it already is the default',
    );
    expect(
      tester
          .widget<FilledButton>(find.byKey(const Key('workflow-save')))
          .onPressed,
      isNull,
      reason: 'nothing to save yet',
    );
  });

  testWidgets('a failed load offers a retry that works', (tester) async {
    final server = FakeWorkflowsClient()
      ..failNext = const WorkflowException(WorkflowFailure.network);
    await _open(tester, server: server);

    expect(find.byKey(const Key('retry-workflow')), findsOneWidget);
    await tester.tap(find.byKey(const Key('retry-workflow')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('status-todo')), findsOneWidget);
  });

  testWidgets('renaming and recolouring then saving sends one whole workflow', (
    tester,
  ) async {
    final server = await _open(tester);

    await _type(tester, 'status-name-doing', 'Doing');
    await tester.tap(find.byKey(const Key('status-color-doing')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('#E53935'));
    await tester.pumpAndSettle();
    await _save(tester);

    final sent = server.saved.single;
    expect(sent.statuses.map((s) => s.name), ['To do', 'Doing', 'Done']);
    expect(sent.statuses[1].color, '#E53935');
    expect(find.text('Workflow saved'), findsOneWidget);
    expect(server.workflow.version, 2);
  });

  testWidgets('adding a status appends a card that can be named', (
    tester,
  ) async {
    final server = await _open(tester);

    await tester.tap(find.byKey(const Key('add-status')));
    await tester.pumpAndSettle();
    await _type(tester, 'status-name-new-0', 'QA');
    await _save(tester);

    expect(server.saved.single.statuses.last.name, 'QA');
    expect(server.workflow.statuses.last.id, 'new-0');
  });

  testWidgets('a blank name is explained on the card and blocks saving', (
    tester,
  ) async {
    await _open(tester);

    await _type(tester, 'status-name-doing', '');

    expect(
      find.byKey(const Key('problem-STATUS_NAME_INVALID-doing')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('validation-panel')), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(find.byKey(const Key('workflow-save')))
          .onPressed,
      isNull,
    );
  });

  testWidgets('changing the default and the category', (tester) async {
    final server = await _open(tester);

    await tester.tap(find.byKey(const Key('status-default-doing')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('status-category-doing')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancelled').last);
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('problem-DEFAULT_IS_FINAL-doing')),
      findsOneWidget,
      reason: 'a cancelled status cannot be where new tasks start',
    );

    await tester.tap(find.byKey(const Key('status-category-doing')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Active').last);
    await tester.pumpAndSettle();
    await _save(tester);

    expect(
      [
        for (final s in server.saved.single.statuses)
          if (s.isDefault) s.key,
      ],
      ['doing'],
    );
  });

  testWidgets('deleting a status without tasks removes it at once', (
    tester,
  ) async {
    final server = await _open(tester);

    await tester.tap(find.byKey(const Key('status-delete-doing')));
    await tester.pumpAndSettle();
    await _save(tester);

    expect(server.saved.single.statuses.map((s) => s.key), ['todo', 'done']);
    expect(server.saved.single.migrations, isEmpty);
  });

  testWidgets(
    'deleting a status with tasks asks where they go and cannot be skipped',
    (tester) async {
      final server = await _open(
        tester,
        workflow: defaultWorkflow(doingTasks: 3),
      );

      await tester.tap(find.byKey(const Key('status-delete-doing')));
      await tester.pumpAndSettle();

      expect(
        tester.widget<Text>(find.byKey(const Key('migration-explain'))).data,
        '3 tasks are in this status. Choose where they go.',
      );
      await tester.tap(find.byKey(const Key('cancel-delete-status')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('status-doing')), findsOneWidget);

      await tester.tap(find.byKey(const Key('status-delete-doing')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('migrate-target')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Done').last);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('confirm-delete-status')));
      await tester.pumpAndSettle();
      await _save(tester);

      expect(server.saved.single.migrations, {'doing': 'done'});
      expect(server.saved.single.statuses.map((s) => s.key), ['todo', 'done']);
    },
  );

  testWidgets(
    'deleting the status earlier tasks were sent to asks for a new place',
    (tester) async {
      final server = await _open(
        tester,
        workflow: defaultWorkflow(doingTasks: 2),
      );

      await tester.tap(find.byKey(const Key('status-delete-doing')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('migrate-target')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Done').last);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('confirm-delete-status')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('status-delete-done')));
      await tester.pumpAndSettle();
      expect(
        tester.widget<Text>(find.byKey(const Key('migration-explain'))).data,
        'Tasks you chose to move here need a new place.',
      );
      await tester.tap(find.byKey(const Key('confirm-delete-status')));
      await tester.pumpAndSettle();

      // The tasks have a place; what is missing now is a Done status.
      expect(find.byKey(const Key('listed-NO_DONE_STATUS')), findsOneWidget);
      expect(
        find.byKey(const Key('listed-STATUS_NEEDS_MIGRATION')),
        findsNothing,
      );
      await tester.tap(find.byKey(const Key('add-status')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('status-category-new-0')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Done').last);
      await tester.pumpAndSettle();
      await _save(tester);

      expect(server.saved.single.migrations, {'doing': 'todo'});
      expect(server.saved.single.statuses.map((s) => s.key), ['todo', 'new-0']);
    },
  );

  testWidgets(
    'a delete refused for tasks the editor did not know of offers a place',
    (tester) async {
      final server = await _open(tester);
      await tester.tap(find.byKey(const Key('status-delete-doing')));
      await tester.pumpAndSettle();
      server.rejectWith = const [
        WorkflowProblem(
          'STATUS_NEEDS_MIGRATION',
          'In progress has tasks: choose a status to move them to.',
          'doing',
        ),
      ];
      await _save(tester);

      expect(find.byKey(const Key('needs-target-doing')), findsOneWidget);

      server.rejectWith = null;
      await tester.tap(find.byKey(const Key('migrate-doing')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('To do').last);
      await tester.pumpAndSettle();
      await _save(tester);

      expect(server.saved.single.migrations, {'doing': 'todo'});
      expect(find.byKey(const Key('needs-target-doing')), findsNothing);
    },
  );

  testWidgets(
    'restricting transitions shows what is wrong until arrows are drawn',
    (tester) async {
      final server = await _open(tester);

      await tester.tap(find.byKey(const Key('restrict-switch')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('listed-STATUS_UNREACHABLE')), findsWidgets);
      expect(find.byKey(const Key('listed-NO_DONE_REACHABLE')), findsOneWidget);
      expect(find.text('Can move to'), findsWidgets);

      for (final move in ['todo-doing', 'doing-done', 'doing-todo']) {
        await tester.tap(find.byKey(Key('move-$move')));
        await tester.pumpAndSettle();
      }

      expect(find.byKey(const Key('validation-ok')), findsOneWidget);
      await _save(tester);
      expect(server.saved.single.restrict, isTrue);
      expect(server.workflow.transitions, hasLength(3));
    },
  );

  testWidgets('a move can require an assignee and a role', (tester) async {
    final server = await _open(
      tester,
      workflow: defaultWorkflow(
        restrict: true,
        transitions: const [
          WorkflowTransition(from: 'todo', to: 'doing'),
          WorkflowTransition(from: 'doing', to: 'done'),
          WorkflowTransition(from: 'doing', to: 'todo'),
        ],
      ),
    );

    await tester.tap(find.byKey(const Key('conditions-todo-doing')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('condition-assignee')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('condition-role')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Only Admin').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('save-conditions')));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('needs an assignee, only Admin'),
      findsOneWidget,
    );
    await _save(tester);
    final rule = server.saved.single.transitions.firstWhere(
      (t) => t.from == 'todo' && t.to == 'doing',
    );
    expect(rule.requireAssignee, isTrue);
    expect(rule.requiredRoleId, isNotEmpty);
  });

  testWidgets('the creation rule is a switch that saves with the workflow', (
    tester,
  ) async {
    final server = await _open(tester);

    await tester.tap(find.byKey(const Key('restrict-creation-switch')));
    await tester.pumpAndSettle();
    await _save(tester);

    expect(server.saved.single.restrictCreation, isTrue);
    expect(server.workflow.restrictCreation, isTrue);
  });

  testWidgets(
    'the creation rule is off by default and read-only for a viewer',
    (tester) async {
      await _open(tester, role: 'Viewer');

      final tile = tester.widget<SwitchListTile>(
        find.byKey(const Key('restrict-creation-switch')),
      );
      expect(tile.value, isFalse);
      expect(tile.onChanged, isNull);
    },
  );

  group('someone else saved first', () {
    Future<FakeWorkflowsClient> conflict(WidgetTester tester) async {
      final server = await _open(tester);
      await _type(tester, 'status-name-doing', 'Mine');
      server.workflow = defaultWorkflow(version: 4).copyWithStatuses(
        const WorkflowStatus(id: 'qa', name: 'QA', position: 3),
      );
      await _save(tester);
      return server;
    }

    testWidgets(
      'shows what changed, keeps my edit, and blocks saving until read',
      (tester) async {
        final server = await conflict(tester);

        expect(find.byKey(const Key('merge-banner')), findsOneWidget);
        expect(find.text('Added by someone else: QA.'), findsOneWidget);
        expect(find.byKey(const Key('status-qa')), findsOneWidget);
        expect(find.text('Mine'), findsOneWidget);
        expect(find.byKey(const Key('save-error')), findsOneWidget);
        expect(
          tester
              .widget<FilledButton>(find.byKey(const Key('workflow-save')))
              .onPressed,
          isNull,
        );
        expect(server.saved, isEmpty);
      },
    );

    testWidgets('after reading, Save sends my draft with their status in it', (
      tester,
    ) async {
      final server = await conflict(tester);

      await tester.tap(find.byKey(const Key('merge-acknowledge')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('merge-banner')), findsNothing);
      await _save(tester);

      final sent = server.saved.single;
      expect(sent.statuses.map((s) => s.name), ['To do', 'Mine', 'Done', 'QA']);
      expect(find.text('Workflow saved'), findsOneWidget);
    });

    testWidgets('I can throw my draft away and start from what was saved', (
      tester,
    ) async {
      final server = await conflict(tester);

      await tester.tap(find.byKey(const Key('merge-reload')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('merge-banner')), findsNothing);
      expect(find.byKey(const Key('status-qa')), findsOneWidget);
      expect(find.text('Mine'), findsNothing);
      expect(server.saved, isEmpty);
    });

    testWidgets('the banner works on a phone too', (tester) async {
      final server = await _open(tester, size: _phone);
      await _type(tester, 'status-name-doing', 'Mine');
      server.workflow = defaultWorkflow(version: 4).copyWithStatuses(
        const WorkflowStatus(id: 'qa', name: 'QA', position: 3),
      );
      await _save(tester);

      expect(find.byKey(const Key('merge-banner')), findsOneWidget);
      await tester.tap(find.byKey(const Key('merge-acknowledge')));
      await tester.pumpAndSettle();
      await _save(tester);

      expect(server.saved.single.statuses.last.key, 'qa');
    });
  });

  testWidgets('a move can require all subtasks to be done', (tester) async {
    final server = await _open(
      tester,
      workflow: defaultWorkflow(
        restrict: true,
        transitions: const [
          WorkflowTransition(from: 'todo', to: 'doing'),
          WorkflowTransition(from: 'doing', to: 'done'),
          WorkflowTransition(from: 'doing', to: 'todo'),
        ],
      ),
    );

    await tester.tap(find.byKey(const Key('conditions-doing-done')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('condition-subtasks')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('save-conditions')));
    await tester.pumpAndSettle();

    expect(find.textContaining('needs all subtasks done'), findsOneWidget);
    await _save(tester);
    final rule = server.saved.single.transitions.firstWhere(
      (t) => t.from == 'doing' && t.to == 'done',
    );
    expect(rule.requireSubtasksDone, isTrue);
    expect(
      server.saved.single.transitions
          .where((t) => t.requireSubtasksDone)
          .length,
      1,
    );
  });

  testWidgets('a save the server rejects lists its problems', (tester) async {
    final server = await _open(tester);
    server.rejectWith = const [
      WorkflowProblem('SOMETHING_ELSE', 'The server found another problem.'),
    ];

    await _type(tester, 'status-name-doing', 'Doing');
    await _save(tester);

    expect(find.text('The server found another problem.'), findsOneWidget);
    expect(find.byKey(const Key('validation-panel')), findsOneWidget);
    expect(find.text('Workflow saved'), findsNothing);
  });

  testWidgets('another failed save says so and keeps the edits', (
    tester,
  ) async {
    final server = await _open(tester);

    await _type(tester, 'status-name-doing', 'Doing');
    server.failNext = const WorkflowException(WorkflowFailure.network);
    await _save(tester);

    expect(find.byKey(const Key('save-error')), findsOneWidget);
    expect(find.text('Doing'), findsOneWidget);
  });

  testWidgets('discard throws the edits away', (tester) async {
    await _open(tester);
    await _type(tester, 'status-name-doing', 'Doing');

    await tester.tap(find.byKey(const Key('workflow-discard')));
    await tester.pumpAndSettle();

    expect(find.text('In progress'), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(find.byKey(const Key('workflow-save')))
          .onPressed,
      isNull,
    );
  });

  testWidgets('a member who may not update the project can only read it', (
    tester,
  ) async {
    await _open(tester, role: 'Viewer');

    expect(find.byKey(const Key('workflow-save')), findsNothing);
    expect(find.byKey(const Key('add-status')), findsNothing);
    expect(
      tester
          .widget<TextField>(
            find.descendant(
              of: find.byKey(const Key('status-name-doing')),
              matching: find.byType(TextField),
            ),
          )
          .enabled,
      isFalse,
    );
    expect(
      tester
          .widget<IconButton>(find.byKey(const Key('status-delete-doing')))
          .onPressed,
      isNull,
    );
  });

  testWidgets('an archived project is read-only', (tester) async {
    await _open(tester, archived: true);

    expect(find.byKey(const Key('workflow-save')), findsNothing);
    expect(find.byKey(const Key('add-status')), findsNothing);
  });

  group('layouts', () {
    testWidgets('wide screens draw the workflow beside the list', (
      tester,
    ) async {
      await _open(
        tester,
        workflow: defaultWorkflow(
          restrict: true,
          transitions: const [WorkflowTransition(from: 'todo', to: 'doing')],
        ),
      );

      expect(find.byKey(const Key('workflow-graph')), findsOneWidget);
      expect(find.byKey(const Key('status-todo')), findsOneWidget);
    });

    testWidgets('an unrestricted workflow says any move is allowed', (
      tester,
    ) async {
      await _open(tester);

      expect(find.byKey(const Key('graph-unrestricted')), findsOneWidget);
    });

    testWidgets('on a phone everything stacks and still works', (tester) async {
      final server = await _open(tester, size: _phone);

      expect(find.byKey(const Key('validation-ok')), findsOneWidget);
      expect(find.byKey(const Key('status-doing')), findsOneWidget);

      await _type(tester, 'status-name-doing', 'Doing');
      await _save(tester);

      expect(server.saved.single.statuses[1].name, 'Doing');
    });

    testWidgets('on a phone a status is reordered by dragging its handle', (
      tester,
    ) async {
      final server = await _open(tester, size: _phone);

      final card = tester.getSize(find.byKey(const Key('status-todo'))).height;
      // A real drag is many small moves; one big jump skips the list's checks.
      final gesture = await tester.startGesture(
        tester.getCenter(find.byKey(const Key('status-handle-todo'))),
      );
      for (var i = 0; i < 12; i++) {
        await gesture.moveBy(Offset(0, card * 2.3 / 12));
        await tester.pump(const Duration(milliseconds: 30));
      }
      await gesture.up();
      await tester.pumpAndSettle();
      await _save(tester);

      expect(server.saved.single.statuses.map((s) => s.key), [
        'doing',
        'done',
        'todo',
      ]);
      expect(
        tester.getTopLeft(find.byKey(const Key('status-todo'))).dy,
        greaterThan(tester.getTopLeft(find.byKey(const Key('status-done'))).dy),
      );
    });
  });

  group('the graph', () {
    test('statuses sit evenly around a circle, the first at the top', () {
      const size = Size(300, 300);
      final points = GraphPainter.layout([
        for (final k in ['a', 'b', 'c', 'd']) _draftStatus(k),
      ], size);

      expect(points['a']!.dx, closeTo(150, 0.01));
      expect(points['a']!.dy, lessThan(points['c']!.dy));
      expect(points['b']!.dx, greaterThan(points['d']!.dx));
    });

    test('a single status sits in the middle', () {
      final points = GraphPainter.layout([
        _draftStatus('a'),
      ], const Size(200, 100));

      expect(points['a'], const Offset(100, 50));
    });
  });
}

DraftStatus _draftStatus(String key) => DraftStatus(key: key, name: key);
