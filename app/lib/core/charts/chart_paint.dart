import 'package:flutter/material.dart';

/// The pieces every chart painter in the app draws the same way: the two axes
/// of a plot and a small muted label. Painters keep their own data drawing.

/// Draws the left and bottom axis of [plot] in [color] (at a low opacity).
void paintChartAxes(Canvas canvas, Rect plot, Color color) {
  final paint = Paint()
    ..color = color.withValues(alpha: 0.3)
    ..strokeWidth = 1;
  canvas.drawLine(plot.topLeft, plot.bottomLeft, paint);
  canvas.drawLine(plot.bottomLeft, plot.bottomRight, paint);
}

/// Paints [text] at [at] in a muted 10 px style; with [maxWidth] a long text
/// is cut with an ellipsis.
void paintChartLabel(
  Canvas canvas,
  String text,
  Offset at,
  Color color, {
  double? maxWidth,
}) {
  final painter = TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(color: color.withValues(alpha: 0.7), fontSize: 10),
    ),
    maxLines: maxWidth == null ? null : 1,
    ellipsis: maxWidth == null ? null : '…',
    textDirection: TextDirection.ltr,
  )..layout(maxWidth: maxWidth ?? double.infinity);
  painter.paint(canvas, at);
}
