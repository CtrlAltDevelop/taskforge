import 'package:taskforge/features/views/application/views_providers.dart';

import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/features/tasks/application/tasks_providers.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';
import 'package:taskforge/features/workflows/domain/workflow.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';

import '../projects/fakes.dart';
import '../projects/projects_test_support.dart';
import 'fakes.dart';
import '../views/fakes.dart';

const _phone = Size(420, 1400);

/// A (a1 (a1x), a2), B
List<Task> family() => [
  task('a', 'Alpha', number: 1),
  task('a1', 'Alpha one', number: 2, parent: 'a', depth: 1),
  task('a1x', 'Alpha one x', number: 3, parent: 'a1', depth: 2),
  task('a2', 'Alpha two', number: 4, parent: 'a', depth: 1),
  task('b', 'Bravo', number: 5),
];

Future<(Pumped, FakeTasksClient)> _open(
  WidgetTester tester, {
  List<Task>? tasks,
  String role = 'Owner',
  bool archived = false,
  Size size = const Size(1400, 1200),
  FakeTasksClient? server,
}) async {
  final fake = server ?? FakeTasksClient(tasks ?? family());
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

Future<void> _menu(WidgetTester tester, String taskId, String item) async {
  await tester.tap(find.byKey(Key('task-menu-$taskId')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(Key('$item-$taskId')));
  await tester.pumpAndSettle();
}

/// Press and hold [from], then drag it onto [to] and let go.
Future<void> _dragOnto(WidgetTester tester, String from, String to) async {
  final gesture = await tester.startGesture(
    tester.getCenter(find.byKey(Key('task-$from'))),
  );
  await tester.pump(const Duration(milliseconds: 600));
  final target = tester.getCenter(find.byKey(Key('task-$to')));
  await gesture.moveTo(target);
  await tester.pump(const Duration(milliseconds: 100));
  await gesture.up();
  await tester.pumpAndSettle();
}

double _left(WidgetTester tester, String taskId) =>
    tester.getTopLeft(find.byKey(Key('task-$taskId'))).dx;

void main() {
  group('the tree list', () {
    testWidgets('subtasks are indented under their parent, in tree order', (
      tester,
    ) async {
      await _open(tester);

      for (final id in ['a', 'a1', 'a1x', 'a2', 'b']) {
        expect(find.byKey(Key('task-$id')), findsOneWidget);
      }
      expect(
        tester.getTopLeft(find.byKey(const Key('task-a1'))).dy,
        greaterThan(tester.getTopLeft(find.byKey(const Key('task-a'))).dy),
      );
      expect(
        tester.getTopLeft(find.byKey(const Key('task-b'))).dy,
        greaterThan(tester.getTopLeft(find.byKey(const Key('task-a2'))).dy),
      );
      expect(
        tester.getTopLeft(find.byKey(const Key('toggle-a1'))).dx,
        greaterThan(tester.getTopLeft(find.byKey(const Key('toggle-a'))).dx),
      );
    });

    testWidgets(
      'the chevron folds and unfolds a parent and everything under it',
      (tester) async {
        await _open(tester);

        await tester.tap(find.byKey(const Key('toggle-a')));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('task-a1')), findsNothing);
        expect(find.byKey(const Key('task-a1x')), findsNothing);
        expect(find.byKey(const Key('task-b')), findsOneWidget);

        await tester.tap(find.byKey(const Key('toggle-a')));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('task-a1x')), findsOneWidget);
      },
    );

    testWidgets('folding an inner parent leaves its siblings showing', (
      tester,
    ) async {
      await _open(tester);

      await tester.tap(find.byKey(const Key('toggle-a1')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('task-a1x')), findsNothing);
      expect(find.byKey(const Key('task-a2')), findsOneWidget);
    });

    testWidgets('a parent shows a ring of how much below it is done', (
      tester,
    ) async {
      await _open(
        tester,
        tasks: [
          task('a', 'Alpha', number: 1),
          changed(
            task('a1', 'Done one', number: 2, parent: 'a', depth: 1),
            statusId: 'done',
          ),
          task('a2', 'Open one', number: 3, parent: 'a', depth: 1),
        ],
      );

      expect(find.byKey(const Key('progress-a')), findsOneWidget);
      expect(find.text('1/2'), findsOneWidget);
      expect(find.byKey(const Key('progress-a1')), findsNothing);
    });

    testWidgets('on a phone the tree works the same', (tester) async {
      await _open(tester, size: _phone);

      expect(_left(tester, 'a1'), greaterThanOrEqualTo(_left(tester, 'a')));
      await tester.tap(find.byKey(const Key('toggle-a')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('task-a2')), findsNothing);
    });

    testWidgets('five thousand tasks are built lazily, not all at once', (
      tester,
    ) async {
      final many = <Task>[
        for (var r = 0; r < 50; r++) ...[
          task('r$r', 'Root $r', number: r * 100 + 1),
          for (var c = 0; c < 99; c++)
            task(
              'r$r-$c',
              'Child $c',
              number: r * 100 + c + 2,
              parent: 'r$r',
              depth: 1,
            ),
        ],
      ];
      await _open(tester, tasks: many);

      expect(find.byType(ListTile).evaluate().length, lessThan(60));
      await tester.drag(
        find.byKey(const Key('task-list')),
        const Offset(0, -20000),
      );
      await tester.pumpAndSettle();
      expect(find.byType(ListTile).evaluate().length, lessThan(60));
      expect(find.byKey(const Key('task-r0')), findsNothing);
    });
  });

  group('adding a subtask', () {
    testWidgets('the row menu opens an inline field under the task', (
      tester,
    ) async {
      final (_, server) = await _open(tester);

      await _menu(tester, 'b', 'addSubtask');
      await tester.enterText(
        find.byKey(const Key('add-subtask-b')),
        'Bravo child',
      );
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(server.tasks.last.parentId, 'b');
      expect(server.tasks.last.title, 'Bravo child');
      expect(find.text('Bravo child'), findsOneWidget);
      expect(
        find.byKey(const Key('add-subtask-b')),
        findsNothing,
        reason: 'the field closes',
      );
      expect(find.byKey(const Key('progress-b')), findsOneWidget);
    });

    testWidgets(
      'the new subtask appears right after the last one of its parent',
      (tester) async {
        await _open(tester);

        await _menu(tester, 'a', 'addSubtask');
        await tester.enterText(find.byKey(const Key('add-subtask-a')), 'Late');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();

        final a2 = tester.getTopLeft(find.byKey(const Key('task-a2'))).dy;
        final b = tester.getTopLeft(find.byKey(const Key('task-b'))).dy;
        final late = tester.getTopLeft(find.text('Late')).dy;
        expect(late, greaterThan(a2));
        expect(late, lessThan(b));
      },
    );

    testWidgets('adding under a folded parent opens it', (tester) async {
      await _open(tester);
      await tester.tap(find.byKey(const Key('toggle-a')));
      await tester.pumpAndSettle();

      await _menu(tester, 'a', 'addSubtask');
      await tester.enterText(find.byKey(const Key('add-subtask-a')), 'New');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('task-a1')), findsOneWidget);
      expect(find.text('New'), findsOneWidget);
    });

    testWidgets('an empty field closes without adding anything', (
      tester,
    ) async {
      final (_, server) = await _open(tester);

      await _menu(tester, 'b', 'addSubtask');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('add-subtask-b')), findsNothing);
      expect(server.tasks, hasLength(5));
    });

    testWidgets('a refused add says why and keeps the field', (tester) async {
      final (_, server) = await _open(tester);
      server.failNext = const TaskException(TaskFailure.forbidden);

      await _menu(tester, 'b', 'addSubtask');
      await tester.enterText(find.byKey(const Key('add-subtask-b')), 'Nope');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(
        find.text('You do not have permission to do that.'),
        findsOneWidget,
      );
      expect(find.byKey(const Key('add-subtask-b')), findsOneWidget);
    });

    testWidgets('no more nesting is offered at the depth limit', (
      tester,
    ) async {
      final chain = [
        for (var i = 0; i < 8; i++)
          task(
            'n$i',
            'Level $i',
            number: i + 1,
            parent: i == 0 ? '' : 'n${i - 1}',
            depth: i,
          ),
      ];
      await _open(tester, tasks: chain);

      await tester.tap(find.byKey(const Key('task-menu-n7')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('addSubtask-n7')), findsNothing);
      expect(find.byKey(const Key('moveUnder-n7')), findsOneWidget);
    });
  });

  group('moving a task under another', () {
    testWidgets('the menu offers every task but itself and its own subtasks', (
      tester,
    ) async {
      await _open(tester);

      await _menu(tester, 'a', 'moveUnder');

      expect(find.byKey(const Key('pick-parent-b')), findsOneWidget);
      expect(find.byKey(const Key('pick-parent-a1')), findsNothing);
      expect(find.byKey(const Key('pick-parent-a1x')), findsNothing);
      expect(find.byKey(const Key('pick-parent-a')), findsNothing);
      expect(
        find.byKey(const Key('pick-parent-top')),
        findsNothing,
        reason: 'already top level',
      );
    });

    testWidgets('choosing a parent nests the task with its subtree', (
      tester,
    ) async {
      final (_, server) = await _open(tester);

      await _menu(tester, 'a', 'moveUnder');
      await tester.tap(find.byKey(const Key('pick-parent-b')));
      await tester.pumpAndSettle();

      expect(server.parentCalls, [(task: 'a', parent: 'b')]);
      expect(find.byKey(const Key('progress-b')), findsOneWidget);
      expect(find.text('0/4'), findsOneWidget);
      expect(_left(tester, 'a'), greaterThanOrEqualTo(_left(tester, 'b')));
    });

    testWidgets('a subtask can be sent back to the top level', (tester) async {
      final (_, server) = await _open(tester);

      await _menu(tester, 'a1', 'moveUnder');
      expect(find.byKey(const Key('pick-parent-top')), findsOneWidget);
      await tester.tap(find.byKey(const Key('pick-parent-top')));
      await tester.pumpAndSettle();

      expect(server.parentCalls, [(task: 'a1', parent: '')]);
      expect(server.tasks.firstWhere((t) => t.id == 'a1').parentId, '');
    });

    testWidgets('"Make top level" does it in one tap', (tester) async {
      final (_, server) = await _open(tester);

      await _menu(tester, 'a2', 'makeTopLevel');

      expect(server.parentCalls, [(task: 'a2', parent: '')]);
      expect(find.byKey(const Key('makeTopLevel-a')), findsNothing);
    });

    testWidgets('a top-level task has no "make top level"', (tester) async {
      await _open(tester);

      await tester.tap(find.byKey(const Key('task-menu-a')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('makeTopLevel-a')), findsNothing);
    });

    testWidgets('cancelling the picker changes nothing', (tester) async {
      final (_, server) = await _open(tester);

      await _menu(tester, 'a', 'moveUnder');
      await tester.tap(find.byKey(const Key('pick-parent-cancel')));
      await tester.pumpAndSettle();

      expect(server.parentCalls, isEmpty);
    });

    testWidgets('a refusal from the server is shown', (tester) async {
      final (_, server) = await _open(tester);
      server.failNext = const TaskException(TaskFailure.cycle);

      await _menu(tester, 'b', 'moveUnder');
      await tester.tap(find.byKey(const Key('pick-parent-a')));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('cannot become a subtask of itself'),
        findsOneWidget,
      );
    });

    testWidgets('on a wide screen a row is held and dragged onto another', (
      tester,
    ) async {
      final (_, server) = await _open(tester);

      await _dragOnto(tester, 'b', 'a2');

      expect(server.parentCalls, [(task: 'b', parent: 'a2')]);
    });

    testWidgets('a row cannot be dropped onto its own subtask', (tester) async {
      final (_, server) = await _open(tester);

      await _dragOnto(tester, 'a', 'a1x');

      expect(server.parentCalls, isEmpty);
    });

    testWidgets('an ordinary drag still scrolls the list on a wide screen', (
      tester,
    ) async {
      final many = [
        for (var i = 0; i < 60; i++) task('t$i', 'Task $i', number: i + 1),
      ];
      final (_, server) = await _open(tester, tasks: many);

      await tester.drag(
        find.byKey(const Key('task-t5')),
        const Offset(0, -600),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('task-t0')), findsNothing);
      expect(server.parentCalls, isEmpty);
    });

    testWidgets('on a phone there is no dragging, only the menu', (
      tester,
    ) async {
      await _open(tester, size: _phone);

      expect(find.byKey(const Key('drag-a')), findsNothing);
      expect(find.byKey(const Key('task-menu-a')), findsOneWidget);
    });
  });

  group('deleting a task with subtasks', () {
    testWidgets('a task without subtasks is deleted without a question', (
      tester,
    ) async {
      final (_, server) = await _open(tester);

      await _menu(tester, 'b', 'delete');

      expect(server.deleted, ['b']);
      expect(server.deleteModes, [null]);
      expect(find.byKey(const Key('delete-mode-explain')), findsNothing);
    });

    testWidgets(
      'a parent asks what to do with its subtasks, and cancel stops it',
      (tester) async {
        final (_, server) = await _open(tester);

        await _menu(tester, 'a', 'delete');
        expect(
          tester
              .widget<Text>(find.byKey(const Key('delete-mode-explain')))
              .data,
          'It has 3 subtasks. What should happen to them?',
        );
        await tester.tap(find.byKey(const Key('delete-mode-cancel')));
        await tester.pumpAndSettle();

        expect(server.deleted, isEmpty);
        expect(find.byKey(const Key('task-a')), findsOneWidget);
      },
    );

    testWidgets('delete them too removes the whole subtree', (tester) async {
      final (_, server) = await _open(tester);

      await _menu(tester, 'a', 'delete');
      await tester.tap(find.byKey(const Key('delete-mode-subtree')));
      await tester.pumpAndSettle();

      expect(server.deleteModes, [DeleteMode.subtree]);
      for (final id in ['a', 'a1', 'a1x', 'a2']) {
        expect(find.byKey(Key('task-$id')), findsNothing);
      }
      expect(find.byKey(const Key('task-b')), findsOneWidget);
    });

    testWidgets('keep them moves the subtasks up a level', (tester) async {
      final (_, server) = await _open(tester);

      await _menu(tester, 'a1', 'delete');
      await tester.tap(find.byKey(const Key('delete-mode-promote')));
      await tester.pumpAndSettle();

      expect(server.deleteModes, [DeleteMode.promote]);
      expect(find.byKey(const Key('task-a1')), findsNothing);
      expect(find.byKey(const Key('task-a1x')), findsOneWidget);
      expect(server.tasks.firstWhere((t) => t.id == 'a1x').parentId, 'a');
    });

    testWidgets(
      'Undo after keeping the subtasks puts them back under the task',
      (tester) async {
        final (_, server) = await _open(tester);
        await _menu(tester, 'a1', 'delete');
        await tester.tap(find.byKey(const Key('delete-mode-promote')));
        await tester.pumpAndSettle();
        expect(server.tasks.firstWhere((t) => t.id == 'a1x').parentId, 'a');

        await tester.tap(find.text('Undo'));
        await tester.pumpAndSettle();

        final x = server.tasks.firstWhere((t) => t.id == 'a1x');
        expect((x.parentId, x.depth), ('a1', 2));
        expect(find.byKey(const Key('task-a1')), findsOneWidget);
      },
    );

    testWidgets('Undo brings the deleted subtree back', (tester) async {
      final (_, server) = await _open(tester);
      await _menu(tester, 'a', 'delete');
      await tester.tap(find.byKey(const Key('delete-mode-subtree')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();

      expect(server.trashed.contains('a'), isFalse);
    });
  });

  group('the detail of a subtask', () {
    testWidgets(
      'shows where it sits and opens an ancestor from the breadcrumb',
      (tester) async {
        await _open(tester);
        await tester.tap(find.byKey(const Key('task-a1x')));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('breadcrumb')), findsOneWidget);
        expect(find.text('WEB-3'), findsWidgets);

        await tester.tap(find.byKey(const Key('crumb-a')));
        await tester.pumpAndSettle();

        expect(
          tester.widget<Text>(find.byKey(const Key('detail-id'))).data,
          'WEB-1',
        );
        expect(
          find.byKey(const Key('breadcrumb')),
          findsNothing,
          reason: 'a top-level task has none',
        );
      },
    );

    testWidgets('lists the direct subtasks as a checklist with progress', (
      tester,
    ) async {
      await _open(tester);
      await tester.tap(find.byKey(const Key('task-a')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('subtask-a1')), findsOneWidget);
      expect(find.byKey(const Key('subtask-a2')), findsOneWidget);
      expect(
        find.byKey(const Key('subtask-a1x')),
        findsNothing,
        reason: 'only direct children',
      );
      expect(
        tester.widget<Text>(find.byKey(const Key('subtasks-progress'))).data,
        '0/3',
      );
    });

    testWidgets('ticking a subtask finishes it, unticking sends it back', (
      tester,
    ) async {
      final (_, server) = await _open(tester);
      await tester.tap(find.byKey(const Key('task-a')));
      await tester.pumpAndSettle();

      Finder box() => find.descendant(
        of: find.byKey(const Key('subtask-a2')),
        matching: find.byType(Checkbox),
      );
      await tester.tap(box());
      await tester.pumpAndSettle();
      expect(server.tasks.firstWhere((t) => t.id == 'a2').statusName, 'Done');
      expect(
        tester.widget<Text>(find.byKey(const Key('subtasks-progress'))).data,
        '1/3',
      );

      await tester.tap(box());
      await tester.pumpAndSettle();
      expect(server.tasks.firstWhere((t) => t.id == 'a2').statusName, 'To do');
    });

    testWidgets('a subtask is opened from the checklist', (tester) async {
      await _open(tester);
      await tester.tap(find.byKey(const Key('task-a')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('open-subtask-a2')));
      await tester.pumpAndSettle();

      expect(
        tester.widget<Text>(find.byKey(const Key('detail-id'))).data,
        'WEB-4',
      );
    });

    testWidgets('a subtask is added from the checklist', (tester) async {
      final (_, server) = await _open(tester);
      await tester.tap(find.byKey(const Key('task-b')));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('add-subtask-b')),
        'From detail',
      );
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(server.tasks.last.parentId, 'b');
      expect(
        find.byKey(Key('subtask-${server.tasks.last.id}')),
        findsOneWidget,
      );
    });

    testWidgets(
      'closing the panel while a subtask is being added is harmless',
      (tester) async {
        final (_, server) = await _open(tester);
        await tester.tap(find.byKey(const Key('task-b')));
        await tester.pumpAndSettle();
        final gate = server.createGate = Completer<void>();

        await tester.enterText(
          find.byKey(const Key('add-subtask-b')),
          'Late one',
        );
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pump();
        await tester.tap(find.byKey(const Key('close-detail')));
        await tester.pumpAndSettle();
        gate.complete();
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(server.tasks.last.title, 'Late one');
        expect(
          find.text('Late one'),
          findsOneWidget,
          reason: 'it is in the list',
        );
      },
    );

    testWidgets('a viewer sees the checklist but cannot change it', (
      tester,
    ) async {
      await _open(tester, role: 'Viewer');
      await tester.tap(find.byKey(const Key('task-a')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('add-subtask-a')), findsNothing);
      expect(
        tester
            .widget<CheckboxListTile>(find.byKey(const Key('subtask-a2')))
            .onChanged,
        isNull,
      );
      expect(find.byKey(const Key('task-menu-a')), findsNothing);
    });

    testWidgets('an archived project is read-only', (tester) async {
      await _open(tester, archived: true);
      await tester.tap(find.byKey(const Key('task-a')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('add-subtask-a')), findsNothing);
      expect(find.byKey(const Key('task-menu-a')), findsNothing);
    });

    testWidgets('deleting a parent from its detail asks what to do', (
      tester,
    ) async {
      final (_, server) = await _open(tester);
      await tester.tap(find.byKey(const Key('task-a')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('delete-task')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('delete-mode-promote')));
      await tester.pumpAndSettle();

      expect(server.deleteModes, [DeleteMode.promote]);
    });
  });

  group('completing a parent', () {
    Future<(FakeTasksClient, Pumped)> parentWithOpenChild(
      WidgetTester tester,
    ) async {
      final (pumped, server) = await _open(tester);
      await tester.tap(find.byKey(const Key('task-a')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('detail-status')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Done').last);
      await tester.pumpAndSettle();
      return (server, pumped);
    }

    testWidgets('asks whether to complete the open subtasks too', (
      tester,
    ) async {
      await parentWithOpenChild(tester);

      expect(
        tester.widget<Text>(find.byKey(const Key('complete-explain'))).data,
        '3 subtasks are not finished. Move them to Done too?',
      );
    });

    testWidgets(
      'complete all moves the parent and its open subtasks together',
      (tester) async {
        final (server, _) = await parentWithOpenChild(tester);

        await tester.tap(find.byKey(const Key('complete-all')));
        await tester.pumpAndSettle();

        expect(server.moves, [(task: 'a', status: 'done', withSubtasks: true)]);
        for (final id in ['a', 'a1', 'a1x', 'a2']) {
          expect(server.tasks.firstWhere((t) => t.id == id).statusName, 'Done');
        }
        expect(
          tester.widget<Text>(find.byKey(const Key('subtasks-progress'))).data,
          '3/3',
        );
      },
    );

    testWidgets('leave them open completes only the parent', (tester) async {
      final (server, _) = await parentWithOpenChild(tester);

      await tester.tap(find.byKey(const Key('leave-open')));
      await tester.pumpAndSettle();

      expect(server.moves, isEmpty);
      expect(server.updates.single.patch.status!.id, 'done');
      expect(server.tasks.firstWhere((t) => t.id == 'a1').statusName, 'To do');
    });

    testWidgets('cancel changes nothing', (tester) async {
      final (server, _) = await parentWithOpenChild(tester);

      await tester.tap(find.byKey(const Key('complete-cancel')));
      await tester.pumpAndSettle();

      expect(server.moves, isEmpty);
      expect(server.updates, isEmpty);
    });

    testWidgets('a task without open subtasks moves straight away', (
      tester,
    ) async {
      final (_, server) = await _open(tester);
      await tester.tap(find.byKey(const Key('task-b')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('detail-status')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Done').last);
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('complete-explain')), findsNothing);
      expect(server.updates.single.patch.status!.id, 'done');
    });

    testWidgets('the server refusing "complete all" shows its reason', (
      tester,
    ) async {
      final (server, _) = await parentWithOpenChild(tester);
      server.failNext = const TaskException(
        TaskFailure.transitionNotAllowed,
        detail: 'To do → Done is not allowed.',
      );

      await tester.tap(find.byKey(const Key('complete-all')));
      await tester.pumpAndSettle();

      expect(find.text('To do → Done is not allowed.'), findsOneWidget);
    });
  });

  group('the notifier', () {
    ProviderContainer container(FakeTasksClient server) {
      final c = ProviderContainer(
        overrides: [
          viewsClientProvider.overrideWithValue(FakeViewsClient()),
          tasksClientProvider.overrideWithValue(server),
          workspaceScopeProvider.overrideWithValue('w1'),
        ],
      );
      addTearDown(c.dispose);
      return c;
    }

    Future<void> loaded(ProviderContainer c) async {
      final sub = c.listen(taskListProvider('p1'), (_, _) {});
      addTearDown(sub.close);
      while (c.read(taskListProvider('p1')).loading) {
        await Future<void>.delayed(Duration.zero);
      }
    }

    test(
      'the tree follows the list and folding is remembered per project',
      () async {
        final c = container(FakeTasksClient(family()));
        await loaded(c);

        expect(c.read(taskTreeProvider('p1')).progressOf('a').total, 3);
        c.read(collapsedTasksProvider('p1').notifier).toggle('a');
        expect(c.read(collapsedTasksProvider('p1')), {'a'});
        c.read(collapsedTasksProvider('p1').notifier).expand('a');
        expect(c.read(collapsedTasksProvider('p1')), isEmpty);
        expect(c.read(collapsedTasksProvider('p2')), isEmpty);
      },
    );

    test('a deeper list loads in tree order with every depth', () async {
      final c = container(FakeTasksClient(family()));
      await loaded(c);

      expect(
        [for (final t in c.read(taskListProvider('p1')).tasks) t.id],
        ['a', 'a1', 'a1x', 'a2', 'b'],
      );
    });

    test('a failed delete of a subtree puts everything back', () async {
      final server = FakeTasksClient(family());
      final c = container(server);
      await loaded(c);
      server.failNext = const TaskException(TaskFailure.forbidden);

      await expectLater(
        c
            .read(taskListProvider('p1').notifier)
            .delete(
              c.read(taskListProvider('p1')).tasks.first,
              mode: DeleteMode.subtree,
            ),
        throwsA(isA<TaskException>()),
      );

      expect(c.read(taskListProvider('p1')).tasks, hasLength(5));
    });

    test(
      'deleting a parent without a mode is refused with the count',
      () async {
        final server = FakeTasksClient(family());
        final c = container(server);
        await loaded(c);

        TaskException? caught;
        try {
          await c
              .read(taskListProvider('p1').notifier)
              .delete(c.read(taskListProvider('p1')).tasks.first);
        } on TaskException catch (e) {
          caught = e;
        }

        expect(caught?.failure, TaskFailure.hasSubtasks);
        expect(caught?.subtaskCount, 3);
        expect(c.read(taskListProvider('p1')).tasks, hasLength(5));
      },
    );

    test(
      'moving under a parent reads the list again, in the new order',
      () async {
        final server = FakeTasksClient(family());
        final c = container(server);
        await loaded(c);

        await c
            .read(taskListProvider('p1').notifier)
            .setParent(c.read(taskListProvider('p1')).tasks.last, 'a1');

        expect(
          [for (final t in c.read(taskListProvider('p1')).tasks) t.id],
          ['a', 'a1', 'a1x', 'b', 'a2'],
        );
        expect(c.read(taskListProvider('p1')).tasks[3].depth, 2);
      },
    );

    test('a cycle is refused and the list is left as it was', () async {
      final server = FakeTasksClient(family());
      final c = container(server);
      await loaded(c);

      await expectLater(
        c
            .read(taskListProvider('p1').notifier)
            .setParent(c.read(taskListProvider('p1')).tasks.first, 'a1x'),
        throwsA(
          isA<TaskException>().having(
            (e) => e.failure,
            'failure',
            TaskFailure.cycle,
          ),
        ),
      );

      expect(c.read(taskListProvider('p1')).tasks.first.parentId, '');
    });

    test('creating a subtask places it after its parent subtree', () async {
      final server = FakeTasksClient(family());
      final c = container(server);
      await loaded(c);

      await c
          .read(taskListProvider('p1').notifier)
          .create('New', parentId: 'a');

      expect(
        [for (final t in c.read(taskListProvider('p1')).tasks) t.id],
        ['a', 'a1', 'a1x', 'a2', 't6', 'b'],
      );
    });

    test('moving with subtasks reads the list again', () async {
      final server = FakeTasksClient(family());
      final c = container(server);
      await loaded(c);
      const done = WorkflowStatus(
        id: 'done',
        name: 'Done',
        category: StatusCategory.done,
      );

      await c
          .read(taskListProvider('p1').notifier)
          .moveWithSubtasks(c.read(taskListProvider('p1')).tasks.first, done);

      expect(
        c.read(taskListProvider('p1')).tasks.where((t) => t.statusId == 'done'),
        hasLength(4),
      );
    });
  });
}
