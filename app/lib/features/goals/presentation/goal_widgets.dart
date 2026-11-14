import 'package:flutter/material.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/goals/domain/goals.dart';
import 'package:taskforge/l10n/gen/app_localizations.dart';

String goalStatusLabel(AppLocalizations t, GoalStatus status) =>
    switch (status) {
      GoalStatus.onTrack => t.goalsStatusOnTrack,
      GoalStatus.atRisk => t.goalsStatusAtRisk,
      GoalStatus.offTrack => t.goalsStatusOffTrack,
    };

Color goalStatusColor(GoalStatus status) => switch (status) {
  GoalStatus.onTrack => Colors.green.shade700,
  GoalStatus.atRisk => Colors.orange.shade800,
  GoalStatus.offTrack => Colors.red.shade700,
};

/// A small pill with the goal's health.
class GoalStatusChip extends StatelessWidget {
  const GoalStatusChip({super.key, required this.status});

  final GoalStatus status;

  @override
  Widget build(BuildContext context) {
    final color = goalStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        goalStatusLabel(context.l10n, status),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color),
      ),
    );
  }
}

/// A bar for progress from 0 to 1 with its percentage.
class GoalProgressBar extends StatelessWidget {
  const GoalProgressBar({
    super.key,
    required this.progress,
    this.color,
    this.height = 8,
  });

  final double progress;
  final Color? color;
  final double height;

  @override
  Widget build(BuildContext context) {
    final percent = percentOf(progress);
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(height),
            child: LinearProgressIndicator(
              value: progress.clamp(0, 1),
              minHeight: height,
              color: color,
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 44,
          child: Text(
            context.l10n.goalsProgressPercent(percent),
            textAlign: TextAlign.end,
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ),
      ],
    );
  }
}

/// A line through [points] (0 to 1, oldest first).
class Sparkline extends StatelessWidget {
  const Sparkline({super.key, required this.points, this.height = 48});

  final List<double> points;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _SparklinePainter(
          points,
          Theme.of(context).colorScheme.primary,
          Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter(this.points, this.line, this.base);

  final List<double> points;
  final Color line;
  final Color base;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawLine(
      Offset(0, size.height),
      Offset(size.width, size.height),
      Paint()
        ..color = base
        ..strokeWidth = 1,
    );
    if (points.isEmpty) return;
    Offset at(int i) => Offset(
      points.length == 1
          ? size.width / 2
          : size.width * i / (points.length - 1),
      size.height - 4 - (size.height - 8) * points[i].clamp(0, 1),
    );
    final paint = Paint()
      ..color = line
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;
    final path = Path()..moveTo(at(0).dx, at(0).dy);
    for (var i = 1; i < points.length; i++) {
      path.lineTo(at(i).dx, at(i).dy);
    }
    canvas.drawPath(path, paint);
    canvas.drawCircle(at(points.length - 1), 3, Paint()..color = line);
  }

  @override
  bool shouldRepaint(_SparklinePainter old) =>
      old.points != points || old.line != line;
}

void sayGoals(BuildContext context, String text) =>
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
