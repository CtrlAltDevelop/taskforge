import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:taskforge/features/calendar/domain/calendar_math.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';
import 'package:taskforge/features/timeline/domain/timeline_math.dart';
import 'package:taskforge/features/timeline/domain/timeline_scene.dart';
import 'package:taskforge/features/workflows/domain/workflow.dart';

/// A bar being dragged: [task] shows with [dates] until it is dropped.
@immutable
class DragPreview {
  const DragPreview(this.task, this.dates);

  final Task task;
  final Dates dates;

  Task get shown =>
      task.apply(TaskPatch(startDate: dates.startIso, dueDate: dates.dueIso));
}

/// Paints the visible part of the chart: stripes, off days, grid, today, the
/// arrows and the bars. It only draws what is inside the viewport (the scroll
/// offsets say which), so thousands of bars cost what the screen shows.
class TimelinePainter extends CustomPainter {
  TimelinePainter({
    required this.scene,
    required this.scheme,
    required this.zoom,
    required this.today,
    required this.horizontal,
    required this.vertical,
    required this.viewport,
    required this.drag,
    this.selectedId,
  }) : super(repaint: Listenable.merge([horizontal, vertical, viewport, drag]));

  final TimelineScene scene;
  final ColorScheme scheme;
  final TimelineZoom zoom;
  final Day today;
  final ScrollController horizontal;
  final ScrollController vertical;
  final ValueNotifier<Size> viewport;
  final ValueNotifier<DragPreview?> drag;
  final String? selectedId;

  double _offset(ScrollController c) => c.hasClients ? c.offset : 0;

  Color _barColor(Task t) {
    if (scene.critical.contains(t.id)) return scheme.error;
    return switch (t.statusCategory) {
      StatusCategory.done => scheme.outline,
      StatusCategory.cancelled => scheme.outlineVariant,
      StatusCategory.active => scheme.primary,
      StatusCategory.notStarted => scheme.secondary,
    };
  }

  @override
  void paint(Canvas canvas, Size size) {
    final view = viewport.value;
    final window = Rect.fromLTWH(
      _offset(horizontal),
      _offset(vertical),
      view.width,
      view.height,
    );
    final rows = visibleRows(window.top, window.height, scene.rows.length);
    _stripes(canvas, window, rows, size);
    _days(canvas, window, size);
    _today(canvas, window, size);
    _arrows(canvas, rows);
    _bars(canvas, window, rows);
  }

  void _stripes(
    Canvas canvas,
    Rect window,
    ({int first, int last}) rows,
    Size size,
  ) {
    final paint = Paint()..color = scheme.onSurface.withValues(alpha: 0.04);
    for (var i = rows.first; i <= rows.last; i++) {
      final header = scene.rows[i].header != null;
      if (header || i.isOdd) {
        canvas.drawRect(
          Rect.fromLTWH(window.left, i * rowHeight, window.width, rowHeight),
          header
              ? (Paint()..color = scheme.onSurface.withValues(alpha: 0.08))
              : paint,
        );
      }
    }
  }

  void _days(Canvas canvas, Rect window, Size size) {
    final axis = scene.axis;
    final first = axis.dayAt(window.left);
    final last = axis.dayAt(window.right);
    if (axis.pxPerDay >= 6) {
      final off = Paint()..color = scheme.onSurface.withValues(alpha: 0.05);
      for (var d = first; !d.isAfter(last); d = addDays(d, 1)) {
        if (scene.nonWorking(d)) {
          canvas.drawRect(
            Rect.fromLTWH(
              axis.xOf(d),
              window.top,
              axis.pxPerDay,
              window.height,
            ),
            off,
          );
        }
      }
    }
    final minor = Paint()
      ..color = scheme.outlineVariant.withValues(alpha: 0.5)
      ..strokeWidth = 1;
    final major = Paint()
      ..color = scheme.outline.withValues(alpha: 0.6)
      ..strokeWidth = 1;
    for (final tick in axisTicks(zoom, first, last)) {
      final x = axis.xOf(tick.day);
      canvas.drawLine(
        Offset(x, window.top),
        Offset(x, window.bottom),
        tick.major ? major : minor,
      );
    }
  }

  void _today(Canvas canvas, Rect window, Size size) {
    final x = scene.axis.xOf(today) + scene.axis.pxPerDay / 2;
    if (x < window.left || x > window.right) return;
    canvas.drawLine(
      Offset(x, window.top),
      Offset(x, window.bottom),
      Paint()
        ..color = scheme.primary
        ..strokeWidth = 2,
    );
  }

  Task _shown(Task t) {
    final d = drag.value;
    return d != null && d.task.id == t.id ? d.shown : t;
  }

  void _arrows(Canvas canvas, ({int first, int last}) rows) {
    for (final link in scene.linksIn(rows)) {
      final from = scene.byId[link.blockerId];
      final to = scene.byId[link.dependentId];
      if (from == null || to == null) continue;
      final a = scene.rectOf(_shown(from));
      final b = scene.rectOf(_shown(to));
      if (a == null || b == null) continue;
      final conflict = linkConflicts(_shown(from), _shown(to));
      final critical =
          scene.critical.contains(from.id) && scene.critical.contains(to.id);
      final color = conflict
          ? scheme.error
          : critical
          ? scheme.error.withValues(alpha: 0.8)
          : scheme.onSurfaceVariant;
      final points = arrowPoints(a, b);
      final path = Path()..moveTo(points.first.dx, points.first.dy);
      for (final p in points.skip(1)) {
        path.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = conflict || critical ? 2 : 1.2,
      );
      _head(canvas, points[points.length - 2], points.last, color);
    }
  }

  void _head(Canvas canvas, Offset from, Offset tip, Color color) {
    final angle = math.atan2(tip.dy - from.dy, tip.dx - from.dx);
    final wing = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(
        tip.dx - 7 * math.cos(angle - 0.45),
        tip.dy - 7 * math.sin(angle - 0.45),
      )
      ..lineTo(
        tip.dx - 7 * math.cos(angle + 0.45),
        tip.dy - 7 * math.sin(angle + 0.45),
      )
      ..close();
    canvas.drawPath(wing, Paint()..color = color);
  }

  void _bars(Canvas canvas, Rect window, ({int first, int last}) rows) {
    for (var i = rows.first; i <= rows.last; i++) {
      final base = scene.rows[i].task;
      if (base == null) continue;
      final task = _shown(base);
      final rect = barRect(task, scene.axis, i);
      if (rect == null || !rect.overlaps(window)) continue;
      final color = _barColor(task);
      final fill = Paint()..color = color;
      if (isMilestone(task)) {
        final c = rect.center;
        final r = rect.width / 2;
        canvas.drawPath(
          Path()
            ..moveTo(c.dx, c.dy - r)
            ..lineTo(c.dx + r, c.dy)
            ..lineTo(c.dx, c.dy + r)
            ..lineTo(c.dx - r, c.dy)
            ..close(),
          fill,
        );
      } else {
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(4)),
          fill,
        );
        if (rect.width >= 3 * edgeGrab) {
          final grip = Paint()
            ..color = scheme.onPrimary.withValues(alpha: 0.7)
            ..strokeWidth = 2;
          for (final x in [rect.left + 3, rect.right - 3]) {
            canvas.drawLine(
              Offset(x, rect.top + 5),
              Offset(x, rect.bottom - 5),
              grip,
            );
          }
        }
      }
      if (task.id == selectedId) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect.inflate(2), const Radius.circular(6)),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2
            ..color = scheme.onSurface,
        );
      }
    }
  }

  @override
  bool shouldRepaint(TimelinePainter old) =>
      old.scene != scene ||
      old.scheme != scheme ||
      old.zoom != zoom ||
      old.today != today ||
      old.selectedId != selectedId;
}

/// The date header: one label per tick, following the horizontal scroll.
class AxisHeaderPainter extends CustomPainter {
  AxisHeaderPainter({
    required this.axis,
    required this.zoom,
    required this.scheme,
    required this.style,
    required this.horizontal,
    required this.lastDay,
  }) : super(repaint: horizontal);

  final TimeAxis axis;
  final TimelineZoom zoom;
  final ColorScheme scheme;
  final TextStyle style;
  final ScrollController horizontal;
  final Day lastDay;

  @override
  void paint(Canvas canvas, Size size) {
    final offset = horizontal.hasClients ? horizontal.offset : 0.0;
    canvas.clipRect(Offset.zero & size);
    final first = axis.dayAt(offset);
    final last = axis.dayAt(offset + size.width);
    for (final tick in axisTicks(zoom, first, last)) {
      final x = axis.xOf(tick.day) - offset;
      final text = TextPainter(
        text: TextSpan(
          text: tick.label,
          style: tick.major
              ? style.copyWith(fontWeight: FontWeight.bold)
              : style,
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      text.paint(canvas, Offset(x + 3, (size.height - text.height) / 2));
      canvas.drawLine(
        Offset(x, size.height * 0.3),
        Offset(x, size.height),
        Paint()..color = scheme.outlineVariant,
      );
    }
    canvas.drawLine(
      Offset(0, size.height - 0.5),
      Offset(size.width, size.height - 0.5),
      Paint()..color = scheme.outlineVariant,
    );
  }

  @override
  bool shouldRepaint(AxisHeaderPainter old) =>
      old.axis != axis || old.zoom != zoom || old.scheme != scheme;
}
