import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:taskforge/core/ui/appearance.dart';
import 'package:taskforge/core/ui/tokens/spacing.dart';
import 'package:taskforge/features/calendar/domain/calendar_math.dart';

import '../board/fakes.dart';
import '../projects/fakes.dart';
import '../projects/projects_test_support.dart';
import '../workflows/fakes.dart';
import 'fakes.dart';

/// Smoke for "5,000 rows / 1,000 cards stay smooth": a widget test runs the
/// debug VM, several times slower than a release build and with no GPU, so it
/// cannot show 60 fps. What it can show is that the work per frame depends on
/// what is on screen, not on how many tasks exist: scrolling a big list costs
/// about what scrolling a small one does, and stays under a generous ceiling.
/// The numbers of the last run are in docs/phases/phase-46-work-views.md.
const _debugCeiling = Duration(milliseconds: 100);

/// Big may cost this many times the small one's frame (noise allowed for).
const _scaleLimit = 2.5;
const _frames = 40;

Duration _median(List<Duration> frames) {
  final sorted = [...frames]..sort();
  return sorted[sorted.length ~/ 2];
}

Future<List<Duration>> _scroll(WidgetTester tester, Finder list) async {
  final frames = <Duration>[];
  final watch = Stopwatch();
  for (var i = 0; i < _frames; i++) {
    await tester.drag(list, const Offset(0, -240));
    watch.reset();
    watch.start();
    await tester.pump(const Duration(milliseconds: 16));
    watch.stop();
    frames.add(watch.elapsed);
  }
  return frames;
}

Future<Duration> _listMedian(WidgetTester tester, int rows) async {
  final server = FakeTasksClient([
    for (var i = 1; i <= rows; i++) task('t$i', 'Task number $i', number: i),
  ]);
  final pumped = await pumpProjects(
    tester,
    projects: [project('p1', 'Web')],
    tasks: server,
    workflows: FakeWorkflowsClient(defaultWorkflow()),
    today: day(2026, 11, 10),
  );
  pumped.container.read(densityProvider.notifier).choose(TfDensity.compact);
  await pumped.go(tester, '/projects/p1');
  await tester.pumpAndSettle();
  return _median(await _scroll(tester, find.byType(Scrollable).last));
}

Future<Duration> _boardMedian(WidgetTester tester, int cards) async {
  final server = FakeTasksClient([
    for (var i = 1; i <= cards; i++) task('t$i', 'Card number $i', number: i),
  ]);
  final pumped = await pumpProjects(
    tester,
    projects: [project('p1', 'Web')],
    tasks: server,
    workflows: FakeWorkflowsClient(defaultWorkflow()),
    board: FakeBoardClient(server.tasks)..pageSize = cards,
    today: day(2026, 11, 10),
  );
  await pumped.go(tester, '/projects/p1?view=board');
  await tester.pumpAndSettle();
  final list = find.byKey(const Key('cards-todo'));
  expect(list, findsOneWidget);
  return _median(await _scroll(tester, list));
}

void _record(String what, Duration small, Duration big) => debugPrint(
  'PERF $what: small ${small.inMicroseconds / 1000} ms, '
  'big ${big.inMicroseconds / 1000} ms per scrolled frame (debug VM)',
);

void main() {
  testWidgets('5,000 rows cost a scrolled frame no more than 200 do', (
    tester,
  ) async {
    final small = await _listMedian(tester, 200);
    final big = await _listMedian(tester, 5000);
    _record('list 200 vs 5000 rows', small, big);

    expect(big, lessThan(_debugCeiling));
    expect(big.inMicroseconds, lessThan(small.inMicroseconds * _scaleLimit));
  });

  testWidgets('1,000 cards cost a scrolled frame no more than 50 do', (
    tester,
  ) async {
    final small = await _boardMedian(tester, 50);
    final big = await _boardMedian(tester, 1000);
    _record('board 50 vs 1000 cards', small, big);

    expect(big, lessThan(_debugCeiling));
    expect(big.inMicroseconds, lessThan(small.inMicroseconds * _scaleLimit));
  });
}
