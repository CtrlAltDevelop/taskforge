import 'package:flutter_test/flutter_test.dart';

import 'package:taskforge/features/calendar/domain/calendar_math.dart';
import 'package:taskforge/features/timeline/data/timeline_client.dart';
import 'package:taskforge/features/timeline/domain/timeline_math.dart';
import 'package:taskforge/features/timeline/domain/timeline_scene.dart';

import 'timeline_math_test.dart' show task;

TimelineScene scene({List<TimelineLink> links = const []}) => TimelineScene(
  rows: [
    TimelineRow.task(task('a', start: '2026-11-02', due: '2026-11-11')),
    TimelineRow.header('Group'),
    TimelineRow.task(task('m', due: '2026-11-05')),
    TimelineRow.task(task('u')),
  ],
  axis: TimeAxis(day(2026, 11, 1), 10),
  lastDay: day(2026, 12, 1),
  links: links,
);

void main() {
  test('is as wide as the days it reaches and as tall as its rows', () {
    expect(scene().size.width, 31 * 10);
    expect(scene().size.height, 4 * rowHeight);
  });

  test('a press on the middle of a bar grabs the bar', () {
    final hit = scene().hit(const Offset(60, rowHeight / 2));

    expect(hit?.task.id, 'a');
    expect(hit?.edge, isNull);
  });

  test('a press near either end of a bar grabs that edge', () {
    expect(scene().hit(const Offset(12, 16))?.edge, BarEdge.start);
    expect(scene().hit(const Offset(108, 16))?.edge, BarEdge.end);
  });

  test('a milestone and a very short bar have no edges', () {
    final s = scene();

    expect(s.hit(const Offset(45, 2 * rowHeight + 16))?.task.id, 'm');
    expect(s.hit(const Offset(45, 2 * rowHeight + 16))?.edge, isNull);
  });

  test('empty space, headings, undated tasks and the outside hit nothing', () {
    final s = scene();

    expect(s.hit(const Offset(200, 16)), isNull); // right of the bar
    expect(s.hit(const Offset(60, rowHeight + 5)), isNull); // heading
    expect(s.hit(const Offset(60, 3 * rowHeight + 5)), isNull); // no dates
    expect(s.hit(const Offset(60, -1)), isNull);
    expect(s.hit(const Offset(60, 99 * rowHeight)), isNull);
  });

  test(
    'only links that can show are listed, and not ones to unknown tasks',
    () {
      final s = scene(
        links: const [TimelineLink('a', 'm'), TimelineLink('a', 'elsewhere')],
      );

      expect(s.linksIn((first: 0, last: 3)).map((l) => l.dependentId), ['m']);
      expect(s.linksIn((first: 3, last: 3)), isEmpty);
    },
  );
}
