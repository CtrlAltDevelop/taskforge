import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:taskforge/core/ui/appearance.dart';
import 'package:taskforge/core/ui/tokens/spacing.dart';
import 'package:taskforge/features/calendar/domain/calendar_math.dart';

import '../features/projects/fakes.dart';
import '../features/projects/projects_test_support.dart';
import '../features/tasks/fakes.dart';
import '../features/workflows/fakes.dart';

/// Phase 49 smoke: from a cold app to the first paint of a task list in a
/// 5,000-task workspace. The test VM is debug-mode and GPU-less, so the budget
/// is a generous ceiling and, more telling, a limit on how much slower 5,000
/// tasks are than 200 (the list builds only what is on screen). Scroll frame
/// cost is in test/features/tasks/work_perf_test.dart. Last numbers and the
/// real-device budget: docs/phases/phase-49-polish-motion-release-qa.md.
const _debugCeiling = Duration(seconds: 6);
const _scaleLimit = 3.0;

Future<Duration> _coldToFirstList(WidgetTester tester, int tasks) async {
  final server = FakeTasksClient([
    for (var i = 1; i <= tasks; i++) task('t$i', 'Task number $i', number: i),
  ]);
  final watch = Stopwatch()..start();
  final pumped = await pumpProjects(
    tester,
    projects: [project('p1', 'Web')],
    tasks: server,
    workflows: FakeWorkflowsClient(defaultWorkflow()),
    today: day(2026, 11, 10),
  );
  pumped.container.read(densityProvider.notifier).choose(TfDensity.compact);
  await pumped.go(tester, '/projects/p1');
  watch.stop();
  expect(find.byKey(const Key('task-t1')), findsOneWidget);
  return watch.elapsed;
}

void main() {
  testWidgets('5,000 tasks reach the first list paint within budget', (
    tester,
  ) async {
    await _coldToFirstList(tester, 20); // warm-up: first pump pays for JIT
    final small = await _coldToFirstList(tester, 200);
    final big = await _coldToFirstList(tester, 5000);
    debugPrint(
      'PERF cold start to first list paint: 200 tasks '
      '${small.inMilliseconds} ms, 5000 tasks ${big.inMilliseconds} ms '
      '(debug VM)',
    );

    expect(big, lessThan(_debugCeiling));
    expect(big.inMicroseconds, lessThan(small.inMicroseconds * _scaleLimit));
  });
}
