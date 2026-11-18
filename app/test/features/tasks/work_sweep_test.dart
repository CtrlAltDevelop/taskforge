import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:taskforge/core/ui/appearance.dart';
import 'package:taskforge/core/ui/tf_icons.dart';
import 'package:taskforge/core/ui/tokens/spacing.dart';
import 'package:taskforge/features/calendar/domain/calendar_math.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';
import 'package:taskforge/features/workflows/domain/workflow.dart';

import '../board/fakes.dart';
import '../calendar/fakes.dart';
import '../projects/fakes.dart';
import '../projects/projects_test_support.dart';
import '../workflows/fakes.dart';
import 'fakes.dart';

const _longTitle =
    'A very long task title that has to be cut short somewhere because the '
    'row, the card and the bar are all narrower than it';

List<Task> _tasks() => [
  task(
    'a',
    _longTitle,
    priority: TaskPriority.urgent,
    dueDate: '2026-11-09',
    assignees: ['u1', 'u2', 'u3', 'u4'],
    isBlocked: true,
    blockedBy: ['WEB-2'],
  ),
  task('b', 'Short', number: 2, dueDate: '2026-11-12'),
  task(
    'c',
    _longTitle,
    number: 3,
    statusId: 'done',
    statusName: 'Done',
    category: StatusCategory.done,
    priority: TaskPriority.low,
  ),
];

Future<void> _openView(
  WidgetTester tester,
  Size size,
  TfDensity density,
  String view,
) async {
  final server = FakeTasksClient(_tasks());
  final pumped = await pumpProjects(
    tester,
    projects: [project('p1', 'Web')],
    tasks: server,
    workflows: FakeWorkflowsClient(defaultWorkflow()),
    board: FakeBoardClient(server.tasks),
    calendar: FakeCalendarClient(server),
    today: day(2026, 11, 10),
    size: size,
  );
  pumped.container.read(densityProvider.notifier).choose(density);
  await pumped.go(tester, '/projects/p1${view == 'list' ? '' : '?view=$view'}');
  await tester.pumpAndSettle();
}

void main() {
  // An overflowing Row or Column throws while the test runs, which fails it:
  // the sweep only has to put every view through every size and density.
  for (final width in [360.0, 768.0, 1280.0]) {
    for (final density in TfDensity.values) {
      for (final view in ['list', 'board', 'calendar', 'timeline']) {
        testWidgets('$view at ${width.toInt()} px, ${density.name}: no '
            'overflow', (tester) async {
          await _openView(tester, Size(width, 900), density, view);

          expect(tester.takeException(), isNull);
          expect(find.byKey(const Key('view-switch')), findsOneWidget);
          expect(find.byType(Scaffold), findsWidgets);
        });
      }
    }
  }

  testWidgets('the add-task button stays on screen at 360 px', (tester) async {
    await _openView(tester, const Size(360, 900), TfDensity.compact, 'list');

    final box = tester.getRect(find.byKey(const Key('toolbar-add-task')));
    expect(box.right, lessThanOrEqualTo(360));
    expect(box.left, greaterThanOrEqualTo(0));
    expect(find.byIcon(TfIcons.plus.glyph), findsWidgets);
  });
}
