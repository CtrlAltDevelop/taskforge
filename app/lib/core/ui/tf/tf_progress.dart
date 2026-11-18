import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import 'package:taskforge/core/ui/theme_extension.dart';
import 'package:taskforge/core/ui/tokens/shape.dart';

/// A horizontal bar for [value] from 0 to 1.
class TfProgressBar extends StatelessWidget {
  const TfProgressBar({
    super.key,
    required this.value,
    this.height = 6,
    this.semanticLabel,
  });

  final double value;
  final double height;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final c = context.tf.colors;
    final v = value.clamp(0.0, 1.0);
    return Semantics(
      label: semanticLabel,
      value: '${(v * 100).round()}%',
      child: ClipRRect(
        borderRadius: TfRadius.pill,
        child: Stack(
          children: [
            Container(height: height, color: c.border),
            FractionallySizedBox(
              widthFactor: v,
              alignment: AlignmentDirectional.centerStart,
              child: Container(
                height: height,
                color: v >= 1 ? c.success.fg : c.accent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A ring for [value] from 0 to 1, with the percentage in the middle when big enough.
class TfProgressRing extends StatelessWidget {
  const TfProgressRing({
    super.key,
    required this.value,
    this.size = 24,
    this.semanticLabel,
  });

  final double value;
  final double size;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final tf = context.tf;
    final v = value.clamp(0.0, 1.0);
    return Semantics(
      label: semanticLabel,
      value: '${(v * 100).round()}%',
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _RingPainter(
            v,
            tf.colors.border,
            v >= 1 ? tf.colors.success.fg : tf.colors.accent,
          ),
          child: size >= 36
              ? Center(
                  child: Text(
                    '${(v * 100).round()}',
                    style: tf.typography.tabular.copyWith(
                      fontSize: size * 0.3,
                      color: tf.colors.text,
                    ),
                  ),
                )
              : null,
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.value, this.track, this.fill);

  final double value;
  final Color track;
  final Color fill;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = math.max(2.0, size.width / 8);
    final rect =
        Offset(stroke / 2, stroke / 2) &
        Size(size.width - stroke, size.height - stroke);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, 0, math.pi * 2, false, paint..color = track);
    if (value > 0) {
      final sweep = math.pi * 2 * value;
      canvas.drawArc(rect, -math.pi / 2, sweep, false, paint..color = fill);
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.value != value || old.track != track || old.fill != fill;
}
