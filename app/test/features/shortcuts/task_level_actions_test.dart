import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/features/comments/application/comments_providers.dart';
import 'package:taskforge/features/time/domain/time.dart';

import '../projects/fakes.dart';
import '../projects/projects_test_support.dart';
import '../tasks/fakes.dart';
import '../time/fakes.dart';
import 'fakes.dart';

Finder key(String k) => find.byKey(Key(k));

Future<({FakeTasksClient tasks, FakeTimeClient time})> open(
  WidgetTester tester, {
  String at = '/projects/p1?task=a',
  bool timeTracking = true,
  FakeTimeClient? time,
}) async {
  final tasks = FakeTasksClient([task('a', 'Alpha')]);
  final clock = time ?? FakeTimeClient();
  final pumped = await pumpProjects(
    tester,
    projects: [
      project('p1', 'Web', enabled: {if (timeTracking) timeFeature}),
    ],
    tasks: tasks,
    time: clock,
    shortcuts: FakeShortcutsClient(),
    overrides: [currentUserIdProvider.overrideWithValue('u1')],
  );
  await pumped.go(tester, at);
  return (tasks: tasks, time: clock);
}

Future<void> run(WidgetTester tester, String query, String id) async {
  await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
  await tester.sendKeyEvent(LogicalKeyboardKey.keyK);
  await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
  await tester.pumpAndSettle();
  await tester.enterText(key('palette-field'), '> $query');
  await tester.pump();
  await tester.tap(key('palette-row-$id'));
  await tester.pumpAndSettle();
}

Future<void> openPalette(WidgetTester tester, String query) async {
  await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
  await tester.sendKeyEvent(LogicalKeyboardKey.keyK);
  await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
  await tester.pumpAndSettle();
  await tester.enterText(key('palette-field'), '> $query');
  await tester.pump();
}

void main() {
  testWidgets('New task asks for a title and creates it', (tester) async {
    final h = await open(tester, at: '/projects/p1');
    await run(tester, 'new task', 'task.new');

    await tester.enterText(key('new-task-title'), 'From the palette');
    await tester.tap(key('new-task-create'));
    await tester.pumpAndSettle();

    expect(h.tasks.tasks.map((t) => t.title), contains('From the palette'));
  });

  testWidgets('assign to me adds the caller and is then no longer offered', (
    tester,
  ) async {
    final h = await open(tester);
    await run(tester, 'assign', 'task.assign_me');

    expect(h.tasks.updates.single.patch.assigneeIds, ['u1']);

    await openPalette(tester, 'assign');
    expect(key('palette-row-task.assign_me'), findsNothing);
  });

  testWidgets('change status offers the workflow targets and moves the task', (
    tester,
  ) async {
    final h = await open(tester);
    await run(tester, 'status', 'task.status');

    await tester.tap(key('status-option-doing'));
    await tester.pumpAndSettle();

    expect(h.tasks.updates.single.patch.status?.id, 'doing');
  });

  testWidgets('task actions are not offered without a task on screen', (
    tester,
  ) async {
    await open(tester, at: '/projects/p1');
    await openPalette(tester, 'task');
    expect(key('palette-row-task.new'), findsOneWidget);
    expect(key('palette-row-task.status'), findsNothing);
    expect(key('palette-row-task.assign_me'), findsNothing);
    expect(key('palette-row-timer.start'), findsNothing);
  });

  testWidgets('the timer starts from the palette and stops from it', (
    tester,
  ) async {
    final h = await open(tester);
    await run(tester, 'start the timer', 'timer.start');
    expect(h.time.startCalls, ['a']);

    await openPalette(tester, 'timer');
    expect(key('palette-row-timer.start'), findsNothing);
    await tester.tap(key('palette-row-timer.stop'));
    await tester.pumpAndSettle();
    expect(h.time.stopCalls, hasLength(1));
  });

  testWidgets('no timer actions in a project without time tracking', (
    tester,
  ) async {
    await open(tester, timeTracking: false);
    await openPalette(tester, 'timer');
    expect(key('palette-row-timer.start'), findsNothing);
  });

  testWidgets('Alt+S starts the timer on the open task', (tester) async {
    final h = await open(tester);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyS);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.altLeft);
    await tester.pumpAndSettle();
    expect(h.time.startCalls, ['a']);
  });

  testWidgets('the palette is on screen in the first frame after Ctrl+K', (
    tester,
  ) async {
    await open(tester, at: '/projects/p1');
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyK);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pump(); // one frame, no waiting on anything
    expect(key('palette-field'), findsOneWidget);
  });
}
