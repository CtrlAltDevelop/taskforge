import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:taskforge/features/calendar/domain/calendar_math.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';
import 'package:taskforge/features/timeline/data/timeline_client.dart';
import 'package:taskforge/features/timeline/domain/timeline_math.dart';
import 'package:taskforge/features/timeline/domain/timeline_scene.dart';
import 'package:taskforge/features/timeline/presentation/timeline_painter.dart';
import 'package:taskforge/features/workflows/domain/workflow.dart';

import 'timeline_math_test.dart' show task;

Task _done(Task t) => Task(
  id: t.id,
  projectId: t.projectId,
  number: t.number,
  displayId: t.displayId,
  title: t.title,
  statusId: t.statusId,
  statusCategory: StatusCategory.done,
  startDate: t.startDate,
  dueDate: t.dueDate,
);

/// The chart's picture: bars, a milestone, a normal arrow, a conflicting one,
/// the critical path and the today line (no text, so no font differences).
void main() {
  testWidgets(
    'the chart paints bars, arrows, a conflict, a milestone and today',
    (tester) async {
      final a = task('a', start: '2026-11-02', due: '2026-11-05');
      final b = task('b', start: '2026-11-08', due: '2026-11-11');
      final c = task(
        'c',
        start: '2026-11-09',
        due: '2026-11-12',
      ); // starts before b is due
      final m = task('m', due: '2026-11-14');
      final done = _done(task('d', start: '2026-11-03', due: '2026-11-06'));
      final scene = TimelineScene(
        rows: [
          for (final t in [a, b, c, m, done]) TimelineRow.task(t),
        ],
        axis: TimeAxis(day(2026, 11, 1), 24),
        lastDay: day(2026, 11, 20),
        links: const [
          TimelineLink('a', 'b'),
          TimelineLink('b', 'c'),
          TimelineLink('c', 'm'),
        ],
        critical: const {'a', 'b'},
        nonWorking: (d) => d.weekday >= 6,
      );
      final h = ScrollController();
      final v = ScrollController();
      addTearDown(h.dispose);
      addTearDown(v.dispose);

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(colorScheme: const ColorScheme.light()),
          home: RepaintBoundary(
            key: const Key('shot'),
            child: Container(
              color: Colors.white,
              width: 20 * 24.0,
              height: 5 * rowHeight,
              child: CustomPaint(
                painter: TimelinePainter(
                  scene: scene,
                  scheme: const ColorScheme.light(),
                  zoom: TimelineZoom.day,
                  today: day(2026, 11, 4),
                  horizontal: h,
                  vertical: v,
                  viewport: ValueNotifier(Size(20 * 24.0, 5 * rowHeight)),
                  drag: ValueNotifier(null),
                ),
              ),
            ),
          ),
        ),
      );

      await expectLater(
        find.byKey(const Key('shot')),
        matchesGoldenFile('goldens/timeline_chart.png'),
      );
    },
  );
}
