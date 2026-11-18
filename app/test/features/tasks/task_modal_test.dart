import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';

import '../board/fakes.dart';
import '../projects/fakes.dart';
import '../projects/projects_test_support.dart';
import '../workflows/fakes.dart';
import 'fakes.dart';

final _longTitle = 'A very long task title ' * 6;

Future<FakeTasksClient> _open(
  WidgetTester tester, {
  Size size = const Size(1400, 1000),
  String view = '',
  String role = 'Owner',
  List<Task>? tasks,
}) async {
  final server = FakeTasksClient(
    tasks ?? [task('a', _longTitle), task('b', 'Second', number: 2)],
  );
  final pumped = await pumpProjects(
    tester,
    role: role,
    projects: [project('p1', 'Web')],
    tasks: server,
    workflows: FakeWorkflowsClient(defaultWorkflow()),
    board: FakeBoardClient(server.tasks),
    size: size,
  );
  await pumped.go(tester, '/projects/p1$view');
  return server;
}

Finder _k(String key) => find.byKey(Key(key));

void main() {
  testWidgets('a task opens as a modal: fields left, conversation right', (
    tester,
  ) async {
    await _open(tester);
    await tester.tap(_k('task-a'));
    await tester.pumpAndSettle();

    expect(_k('task-modal'), findsOneWidget);
    final fields = tester.getCenter(_k('detail-title')).dx;
    final chat = tester.getCenter(_k('main-composer')).dx;
    expect(fields, lessThan(chat));
    expect(_k('details-grid'), findsOneWidget);
    expect(_k('task-tabs'), findsOneWidget);
  });

  testWidgets('a phone gets a page, one column, composer pinned', (
    tester,
  ) async {
    await _open(tester, size: const Size(390, 800));
    await tester.tap(_k('task-a'));
    await tester.pumpAndSettle();

    expect(_k('task-modal'), findsNothing);
    expect(_k('task-detail'), findsOneWidget);
    expect(_k('main-composer'), findsOneWidget);
  });

  testWidgets('every field type of the grid saves one field', (tester) async {
    final server = await _open(tester);
    await tester.tap(_k('task-a'));
    await tester.pumpAndSettle();

    await tester.tap(_k('detail-priority'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('High').last);
    await tester.pumpAndSettle();
    expect(server.updates.last.patch.fields, ['priority']);

    await tester.tap(_k('assignee-u2'));
    await tester.pumpAndSettle();
    expect(server.updates.last.patch.fields, ['assignee_ids']);

    await tester.tap(_k('detail-due'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(server.updates.last.patch.fields, ['due_date']);
  });

  testWidgets('a viewer sees read-only fields, not hidden ones', (
    tester,
  ) async {
    await _open(tester, role: 'Viewer');
    await tester.tap(_k('task-a'));
    await tester.pumpAndSettle();

    expect(_k('detail-status'), findsOneWidget);
    expect(_k('detail-priority'), findsOneWidget);
    expect(tester.widget<TextField>(_k('detail-title')).enabled, isFalse);
    expect(find.byType(Tooltip), findsWidgets);
  });

  testWidgets('Esc closes and ] goes to the next task', (tester) async {
    await _open(tester);
    await tester.tap(_k('task-a'));
    await tester.pumpAndSettle();

    await tester.sendKeyEvent(LogicalKeyboardKey.bracketRight);
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextField>(_k('detail-title')).controller!.text,
      'Second',
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(_k('task-modal'), findsNothing);
  });

  testWidgets('board -> status -> comment -> next task', (tester) async {
    final server = await _open(tester, view: '?view=board');
    await tester.tap(_k('card-a'));
    await tester.pumpAndSettle();

    await tester.tap(_k('detail-status'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done').last);
    await tester.pumpAndSettle();
    expect(server.updates.last.patch.fields, ['status']);

    await tester.enterText(_k('comment-input').first, 'Shipped');
    await tester.tap(_k('comment-send').first);
    await tester.pumpAndSettle();
    expect(find.text('Shipped'), findsWidgets);

    await tester.tap(_k('next-task'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextField>(_k('detail-title')).controller!.text,
      'Second',
    );
  });

  for (final width in [360.0, 768.0, 1280.0]) {
    testWidgets('no overflow at $width px', (tester) async {
      await _open(tester, size: Size(width, 900));
      await tester.tap(_k('task-a'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(_k('task-detail'), findsOneWidget);
    });
  }
}
