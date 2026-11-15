import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:material_ui/material_ui.dart';

import 'package:taskforge/features/calendar/domain/calendar_math.dart';
import 'package:taskforge/features/timeline/domain/timeline_math.dart';
import 'package:taskforge/features/timeline/domain/timeline_scene.dart';
import 'package:taskforge/features/timeline/presentation/timeline_painter.dart';

const exportLabelWidth = 220.0;
const exportHeaderHeight = 32.0;

/// The most pixels an exported side gets: a longer chart is cut, not scaled.
const exportMaxSide = 8000.0;

/// The whole chart as a PNG: a date header, the task names down the left, then
/// the bars and arrows. Returns the encoded bytes.
Future<Uint8List> renderTimelinePng({
  required TimelineScene scene,
  required TimelineZoom zoom,
  required ColorScheme scheme,
  required TextStyle textStyle,
  required Day today,
}) async {
  final width = math.min(exportLabelWidth + scene.size.width, exportMaxSide);
  final height = math.min(
    exportHeaderHeight + scene.size.height,
    exportMaxSide,
  );
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  canvas.drawRect(
    Rect.fromLTWH(0, 0, width, height),
    Paint()..color = scheme.surface,
  );
  for (var i = 0; i < scene.rows.length; i++) {
    final y = exportHeaderHeight + i * rowHeight;
    if (y > height) break;
    final row = scene.rows[i];
    final label = row.task == null
        ? row.header!
        : '${row.task!.displayId}  ${row.task!.title}';
    final text = TextPainter(
      text: TextSpan(
        text: label,
        style: row.task == null
            ? textStyle.copyWith(fontWeight: FontWeight.bold)
            : textStyle,
      ),
      maxLines: 1,
      ellipsis: '…',
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: exportLabelWidth - 12 - 10.0 * (row.depth));
    text.paint(
      canvas,
      Offset(8 + 10.0 * row.depth, y + (rowHeight - text.height) / 2),
    );
  }
  final offsetless = ScrollController();
  final viewport = ValueNotifier(
    Size(width - exportLabelWidth, height - exportHeaderHeight),
  );
  final drag = ValueNotifier<DragPreview?>(null);
  canvas.save();
  canvas.translate(exportLabelWidth, 0);
  AxisHeaderPainter(
    axis: scene.axis,
    zoom: zoom,
    scheme: scheme,
    style: textStyle,
    horizontal: offsetless,
    lastDay: scene.lastDay,
  ).paint(canvas, Size(width - exportLabelWidth, exportHeaderHeight));
  canvas.translate(0, exportHeaderHeight);
  canvas.clipRect(Offset.zero & viewport.value);
  TimelinePainter(
    scene: scene,
    scheme: scheme,
    zoom: zoom,
    today: today,
    horizontal: offsetless,
    vertical: offsetless,
    viewport: viewport,
    drag: drag,
  ).paint(canvas, scene.size);
  canvas.restore();
  offsetless.dispose();
  viewport.dispose();
  drag.dispose();
  final image = await recorder.endRecording().toImage(
    width.ceil(),
    height.ceil(),
  );
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  return bytes!.buffer.asUint8List();
}
