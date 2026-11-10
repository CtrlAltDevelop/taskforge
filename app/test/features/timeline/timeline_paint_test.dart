import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:taskforge/features/calendar/domain/calendar_math.dart';
import 'package:taskforge/features/timeline/data/timeline_client.dart';
import 'package:taskforge/features/timeline/domain/timeline_math.dart';
import 'package:taskforge/features/timeline/domain/timeline_scene.dart';
import 'package:taskforge/features/timeline/presentation/timeline_painter.dart';

import 'timeline_math_test.dart' show task;

void main() {
  test('two thousand bars and arrows paint a frame in well under a second', () {
    final tasks = [
      for (var i = 0; i < 2000; i++)
        task(
          't$i',
          start: formatDay(addDays(day(2026, 1, 1), i % 300)),
          due: formatDay(addDays(day(2026, 1, 1), i % 300 + 5)),
        ),
    ];
    final scene = TimelineScene(
      rows: [for (final t in tasks) TimelineRow.task(t)],
      axis: TimeAxis(day(2026, 1, 1), TimelineZoom.week.pxPerDay),
      lastDay: day(2027, 1, 1),
      links: [for (var i = 0; i < 1999; i++) TimelineLink('t$i', 't${i + 1}')],
      critical: {for (var i = 0; i < 50; i++) 't$i'},
    );
    final h = ScrollController();
    final v = ScrollController();
    final viewport = ValueNotifier(const Size(1200, 800));
    final drag = ValueNotifier<DragPreview?>(null);
    final painter = TimelinePainter(
      scene: scene,
      scheme: const ColorScheme.light(),
      zoom: TimelineZoom.week,
      today: day(2026, 6, 1),
      horizontal: h,
      vertical: v,
      viewport: viewport,
      drag: drag,
    );
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final watch = Stopwatch()..start();
    for (var frame = 0; frame < 20; frame++) {
      painter.paint(canvas, scene.size);
    }
    watch.stop();

    // 20 frames of the visible window: a loose bound that a painter drawing
    // all 2,000 bars and arrows each frame would break on any machine.
    expect(watch.elapsedMilliseconds / 20, lessThan(50));
    recorder.endRecording().dispose();
  });
}
