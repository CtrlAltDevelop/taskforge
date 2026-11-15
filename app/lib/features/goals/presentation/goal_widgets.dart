import 'package:material_ui/material_ui.dart';
import 'package:ohlcv_chart/ohlcv_chart.dart';

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
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: height,
      width: double.infinity,
      child: points.isEmpty
          ? null
          : SeriesChart(
              series: [
                LineSeries.values(
                  points,
                  color: scheme.primary,
                  width: 2,
                  dotBuilder: (i, _) => i == points.length - 1
                      ? SeriesDot(radius: 3, color: scheme.primary)
                      : null,
                ),
              ],
              // Nothing but the line: no axes, no grid, no readout.
              xAxis: SeriesXAxis.hidden,
              yAxis: const SeriesYAxis(show: false),
              grid: SeriesGrid.none,
              minY: 0,
              maxY: 1,
              touch: null,
            ),
    );
  }
}

void sayGoals(BuildContext context, String text) =>
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
