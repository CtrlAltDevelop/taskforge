import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/features/recurrence/domain/recurrence.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';

import '../projects/fakes.dart';
import '../projects/projects_test_support.dart';
import '../tasks/fakes.dart';
import '../workflows/fakes.dart';
import 'fakes.dart';

Finder key(String k) => find.byKey(Key(k));

Future<FakeRecurrenceClient> _open(
  WidgetTester tester, {
  FakeRecurrenceClient? server,
  String role = 'Owner',
  List<Task>? tasks,
}) async {
  final fake = server ?? FakeRecurrenceClient();
  final pumped = await pumpProjects(
    tester,
    role: role,
    projects: [project('p1', 'Web')],
    tasks: FakeTasksClient(tasks ?? [task('a', 'Weekly report')]),
    workflows: FakeWorkflowsClient(defaultWorkflow()),
    recurrence: fake,
  );
  await pumped.go(tester, '/projects/p1');
  await tester.tap(find.text('Weekly report'));
  await tester.pumpAndSettle();
  return fake;
}

void main() {
  testWidgets('a task that does not repeat offers a Repeat chip', (
    tester,
  ) async {
    await _open(tester);
    expect(key('repeat-chip'), findsOneWidget);
    expect(find.text('Repeat'), findsWidgets);
    expect(key('series-badge'), findsNothing);
  });

  testWidgets('a viewer without task.update has no chip on a plain task', (
    tester,
  ) async {
    await _open(tester, role: 'Viewer');
    expect(key('repeat-chip'), findsNothing);
  });

  testWidgets('a repeating task shows its rule, badge and next dates', (
    tester,
  ) async {
    await _open(
      tester,
      server: FakeRecurrenceClient(
        series: {
          'a': repeating('a', index: 2, isTemplate: false, instanceCount: 3),
        },
      ),
    );
    expect(find.text('Every 2 weeks on Mon, Thu'), findsOneWidget);
    expect(find.text('Repeating task'), findsOneWidget);
    expect(find.text('3 tasks in this series'), findsOneWidget);
    expect(find.text('Next: 2026-11-16, 2026-11-19'), findsOneWidget);
  });

  testWidgets('the first instance says so', (tester) async {
    await _open(
      tester,
      server: FakeRecurrenceClient(series: {'a': repeating('a')}),
    );
    expect(find.text('First of a series'), findsOneWidget);
  });

  testWidgets('a paused series says why, and an after-completion one waits', (
    tester,
  ) async {
    await _open(
      tester,
      server: FakeRecurrenceClient(
        series: {'a': repeating('a', paused: true, pauseReason: 'owner left')},
      ),
    );
    expect(find.text('Paused by the system: owner left'), findsOneWidget);
  });

  testWidgets('after completion shows that the next one waits', (tester) async {
    await _open(
      tester,
      server: FakeRecurrenceClient(
        series: {
          'a': repeating(
            'a',
            mode: RepeatKind.afterCompletion,
            nextDates: const [],
          ),
        },
      ),
    );
    expect(key('repeat-waits'), findsOneWidget);
  });

  testWidgets('the editor previews, then saves a weekly rule', (tester) async {
    final server = await _open(tester);
    await tester.tap(key('repeat-chip'));
    await tester.pumpAndSettle();
    expect(key('repeat-editor'), findsOneWidget);
    expect(key('repeat-summary'), findsOneWidget);
    expect(find.textContaining('Next: 2026-11-09'), findsOneWidget);

    // The editor starts on the weekday of today (the task has no due date):
    // tap the day after it, so the test is the same on every day of the week.
    final other = (DateTime.now().weekday - 1 + 1) % 7;
    await tester.tap(key('repeat-day-$other'));
    await tester.pumpAndSettle();
    expect(server.previews.last.weekdays.contains(other), isTrue);

    await tester.tap(key('repeat-save'));
    await tester.pumpAndSettle();
    expect(server.calls.single, startsWith('set a FREQ=WEEKLY;BYDAY='));
    expect(key('repeat-editor'), findsNothing);
    expect(key('series-badge'), findsOneWidget);
  });

  testWidgets('a draft that cannot be saved explains itself', (tester) async {
    final server = await _open(tester);
    await tester.tap(key('repeat-chip'));
    await tester.pumpAndSettle();
    // The new draft starts on the task's weekday; take it off.
    final chips = [
      for (var d = 0; d < 7; d++)
        if (tester.widget<FilterChip>(key('repeat-day-$d')).selected) d,
    ];
    for (final d in chips) {
      await tester.tap(key('repeat-day-$d'));
    }
    await tester.pumpAndSettle();
    expect(find.text('Pick at least one weekday.'), findsWidgets);
    await tester.tap(key('repeat-save'));
    await tester.pumpAndSettle();
    expect(server.calls, isEmpty);
    expect(key('repeat-error'), findsOneWidget);
  });

  testWidgets('monthly offers a day of the month or the nth weekday', (
    tester,
  ) async {
    final server = await _open(tester);
    await tester.tap(key('repeat-chip'));
    await tester.pumpAndSettle();
    await tester.tap(key('repeat-freq'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('month').last);
    await tester.pumpAndSettle();
    expect(key('repeat-month-day'), findsOneWidget);
    await tester.tap(key('repeat-by-weekday'));
    await tester.pumpAndSettle();
    expect(key('repeat-nth'), findsOneWidget);
    await tester.tap(key('repeat-save'));
    await tester.pumpAndSettle();
    expect(server.calls.single, contains('FREQ=MONTHLY;BYDAY=1'));
  });

  testWidgets('after completion hides the weekday and timing choices', (
    tester,
  ) async {
    final server = await _open(tester);
    await tester.tap(key('repeat-chip'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('After it is completed'));
    await tester.pumpAndSettle();
    expect(key('repeat-day-0'), findsNothing);
    expect(key('repeat-lead'), findsNothing);
    await tester.tap(key('repeat-save'));
    await tester.pumpAndSettle();
    expect(server.calls.single, 'set a FREQ=WEEKLY after_completion');
  });

  testWidgets('a refusal from the server is shown and the editor stays', (
    tester,
  ) async {
    final server = FakeRecurrenceClient();
    await _open(tester, server: server);
    await tester.tap(key('repeat-chip'));
    await tester.pumpAndSettle();
    server.failWith = const RepeatException(
      RepeatFailure.invalid,
      detail: 'That is not a rule.',
    );
    await tester.tap(key('repeat-save'));
    await tester.pumpAndSettle();
    expect(find.text('That is not a rule.'), findsOneWidget);
    expect(key('repeat-editor'), findsOneWidget);
  });

  testWidgets('stop, pause and use-for-future act on the series', (
    tester,
  ) async {
    final server = FakeRecurrenceClient(series: {'a': repeating('a')});
    await _open(tester, server: server);
    await tester.tap(key('repeat-chip'));
    await tester.pumpAndSettle();

    await tester.tap(key('repeat-future'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Updated 2 open later tasks'), findsOneWidget);
    expect(server.calls.last, 'future a');

    await tester.tap(key('repeat-chip'));
    await tester.pumpAndSettle();
    await tester.tap(key('repeat-pause'));
    await tester.pumpAndSettle();
    expect(server.calls.last, 'pause a true');
    expect(key('repeat-paused'), findsOneWidget);

    await tester.tap(key('repeat-chip'));
    await tester.pumpAndSettle();
    await tester.tap(key('repeat-stop'));
    await tester.pumpAndSettle();
    expect(server.calls.last, 'clear a');
    expect(key('series-badge'), findsNothing);
    expect(key('repeat-chip'), findsOneWidget);
  });

  testWidgets('deleting the template asks whether to stop the series', (
    tester,
  ) async {
    final server = FakeRecurrenceClient(series: {'a': repeating('a')});
    await _open(tester, server: server);
    await tester.tap(key('delete-task'));
    await tester.pumpAndSettle();
    expect(key('delete-template-dialog'), findsOneWidget);
    await tester.tap(key('stop-series'));
    await tester.pumpAndSettle();
    expect(server.calls, ['clear a']);
    expect(find.text('WEB-1 deleted'), findsOneWidget);
  });

  testWidgets('deleting the template can leave the series running', (
    tester,
  ) async {
    final server = FakeRecurrenceClient(series: {'a': repeating('a')});
    await _open(tester, server: server);
    await tester.tap(key('delete-task'));
    await tester.pumpAndSettle();
    await tester.tap(key('keep-repeating'));
    await tester.pumpAndSettle();
    expect(server.calls, isEmpty);
    expect(server.series, contains('a'));
  });

  testWidgets('cancelling the template prompt keeps the task', (tester) async {
    final server = FakeRecurrenceClient(series: {'a': repeating('a')});
    await _open(tester, server: server);
    await tester.tap(key('delete-task'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('WEB-1 deleted'), findsNothing);
    expect(key('task-detail'), findsOneWidget);
  });

  testWidgets('a task that is not the template deletes without asking', (
    tester,
  ) async {
    final server = FakeRecurrenceClient(
      series: {'a': repeating('a', isTemplate: false, index: 1)},
    );
    await _open(tester, server: server);
    await tester.tap(key('delete-task'));
    await tester.pumpAndSettle();
    expect(key('delete-template-dialog'), findsNothing);
    expect(find.text('WEB-1 deleted'), findsOneWidget);
  });

  testWidgets('a failed read is an error with a retry, not "does not repeat"', (
    tester,
  ) async {
    final server = FakeRecurrenceClient(series: {'a': repeating('a')})
      ..failWith = const RepeatException(RepeatFailure.network);
    await _open(tester, server: server);
    expect(key('repeat-read-error'), findsOneWidget);
    expect(
      key('repeat-chip'),
      findsNothing,
    ); // nothing to overwrite a rule with
    server.failWith = null;
    await tester.tap(key('repeat-retry'));
    await tester.pumpAndSettle();
    expect(key('repeat-read-error'), findsNothing);
    expect(find.text('Every 2 weeks on Mon, Thu'), findsOneWidget);
  });

  testWidgets('a rule the editor cannot show is not rewritten by it', (
    tester,
  ) async {
    final server = FakeRecurrenceClient(
      series: {'a': repeating('a', rrule: 'FREQ=YEARLY;BYMONTH=2')},
    );
    await _open(tester, server: server);
    await tester.tap(key('repeat-chip'));
    await tester.pumpAndSettle();
    expect(key('repeat-unsupported'), findsOneWidget);
    expect(key('repeat-save'), findsNothing);
    expect(key('repeat-pause'), findsOneWidget);
    expect(key('repeat-stop'), findsOneWidget);
    expect(server.previews, isEmpty);
  });

  testWidgets('the preview of a running series counts from its own start', (
    tester,
  ) async {
    final server = FakeRecurrenceClient(
      series: {
        'a': RepeatSeries(
          id: 's-a',
          projectId: 'p1',
          taskId: 'a',
          rrule: 'FREQ=WEEKLY;BYDAY=MO',
          mode: RepeatKind.schedule,
          summary: 'Every week on Mon',
          startsOn: '2026-11-02',
          nextDueOn: '2026-11-23',
          isTemplate: true,
        ),
      },
    );
    await _open(tester, server: server);
    await tester.tap(key('repeat-chip'));
    await tester.pumpAndSettle();
    expect(server.previewAnchors.last, ('2026-11-02', '2026-11-22'));
  });

  testWidgets('cancelling the subtask question leaves the series running', (
    tester,
  ) async {
    final server = FakeRecurrenceClient(series: {'a': repeating('a')});
    await _open(
      tester,
      server: server,
      tasks: [
        task('a', 'Weekly report'),
        task('a1', 'Step one', number: 2, parent: 'a', depth: 1),
      ],
    );
    await tester.tap(key('delete-task'));
    await tester.pumpAndSettle();
    await tester.tap(key('delete-mode-cancel'));
    await tester.pumpAndSettle();
    expect(key('delete-template-dialog'), findsNothing);
    expect(server.calls, isEmpty);
    expect(server.series, contains('a'));
  });

  Future<FakeRecurrenceClient> openList(
    WidgetTester tester,
    FakeRecurrenceClient server,
  ) async {
    final pumped = await pumpProjects(
      tester,
      projects: [project('p1', 'Web')],
      tasks: FakeTasksClient([task('a', 'Weekly report')]),
      workflows: FakeWorkflowsClient(defaultWorkflow()),
      recurrence: server,
    );
    await pumped.go(tester, '/projects/p1');
    return server;
  }

  testWidgets('deleting a template from the list menu asks first too', (
    tester,
  ) async {
    final server = await openList(
      tester,
      FakeRecurrenceClient(series: {'a': repeating('a')}),
    );
    await tester.tap(key('task-menu-a'));
    await tester.pumpAndSettle();
    await tester.tap(key('delete-a'));
    await tester.pumpAndSettle();
    expect(key('delete-template-dialog'), findsOneWidget);
    await tester.tap(key('stop-series'));
    await tester.pumpAndSettle();
    expect(server.calls, ['clear a']);
    expect(find.text('WEB-1 deleted'), findsOneWidget);
  });

  testWidgets('a bulk delete asks about a template among the picked', (
    tester,
  ) async {
    final server = await openList(
      tester,
      FakeRecurrenceClient(series: {'a': repeating('a')}),
    );
    await tester.tap(key('check-a'));
    await tester.pumpAndSettle();
    await tester.tap(key('bulk-delete'));
    await tester.pumpAndSettle();
    await tester.tap(key('bulk-delete-confirm'));
    await tester.pumpAndSettle();
    expect(key('delete-template-dialog'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(server.calls, isEmpty);
    expect(find.text('Weekly report'), findsOneWidget); // nothing deleted
  });

  testWidgets('the time of day can be chosen and reaches the preview', (
    tester,
  ) async {
    final server = await _open(tester);
    await tester.tap(key('repeat-chip'));
    await tester.pumpAndSettle();
    expect(find.text('At 09:00'), findsOneWidget);
    await tester.tap(key('repeat-time'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.keyboard_outlined));
    await tester.pumpAndSettle();
    final fields = find.descendant(
      of: find.byType(Dialog).last,
      matching: find.byType(TextField),
    );
    await tester.enterText(fields.at(0), '10');
    await tester.enterText(fields.at(1), '30');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    debugPrint(
      'FIELDS ${fields.evaluate().length} ${find.text('OK').evaluate().length}',
    );
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.text('At 10:30'), findsOneWidget);
    expect(server.previews.last.atTime, '10:30');
  });
}
