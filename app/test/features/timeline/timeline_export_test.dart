import 'dart:typed_data';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:taskforge/features/calendar/domain/calendar_math.dart';
import 'package:taskforge/features/timeline/data/timeline_client.dart';
import 'package:taskforge/features/timeline/domain/timeline_math.dart';
import 'package:taskforge/features/timeline/domain/timeline_scene.dart';
import 'package:taskforge/features/timeline/presentation/timeline_export.dart';

import 'timeline_math_test.dart' show task;

void main() {
  testWidgets('the export is a PNG as big as the chart plus its labels', (
    tester,
  ) async {
    final scene = TimelineScene(
      rows: [
        TimelineRow.task(task('a', start: '2026-11-02', due: '2026-11-05')),
        TimelineRow.task(task('b', start: '2026-11-06', due: '2026-11-09')),
      ],
      axis: TimeAxis(day(2026, 11, 1), 20),
      lastDay: day(2026, 11, 30),
      links: const [TimelineLink('a', 'b')],
    );

    final bytes = await tester.runAsync(
      () => renderTimelinePng(
        scene: scene,
        zoom: TimelineZoom.day,
        scheme: const ColorScheme.light(),
        textStyle: const TextStyle(fontSize: 12),
        today: day(2026, 11, 3),
      ),
    );

    expect(bytes, isA<Uint8List>());
    expect(bytes!.sublist(0, 8), [137, 80, 78, 71, 13, 10, 26, 10]); // PNG
    final view = ByteData.sublistView(bytes);
    expect(view.getUint32(16), 30 * 20 + exportLabelWidth); // width
    expect(view.getUint32(20), 2 * rowHeight + exportHeaderHeight); // height
  });

  testWidgets('a very long chart is cut at the size limit', (tester) async {
    final scene = TimelineScene(
      rows: [
        for (var i = 0; i < 400; i++)
          TimelineRow.task(task('t$i', due: '2026-11-02')),
      ],
      axis: TimeAxis(day(2026, 11, 1), 20),
      lastDay: day(2026, 11, 30),
    );

    final bytes = await tester.runAsync(
      () => renderTimelinePng(
        scene: scene,
        zoom: TimelineZoom.day,
        scheme: const ColorScheme.light(),
        textStyle: const TextStyle(fontSize: 12),
        today: day(2026, 11, 3),
      ),
    );

    expect(ByteData.sublistView(bytes!).getUint32(20), exportMaxSide);
  });
}
