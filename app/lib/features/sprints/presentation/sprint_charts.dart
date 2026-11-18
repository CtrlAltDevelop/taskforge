import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ohlcv_chart/ohlcv_chart.dart';
import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/sprints/application/sprints_providers.dart';
import 'package:taskforge/features/sprints/domain/sprints.dart';
import 'package:taskforge/core/ui/tf/tf_feedback.dart';
import 'package:taskforge/core/ui/tf/tf_illustration.dart';

/// Burndown of one sprint: remaining work (solid), the ideal line (dashed
/// look via lighter colour), steps where scope changed, and nothing for days
/// still to come. Toggles between story points and task counts.
class BurndownPanel extends ConsumerStatefulWidget {
  const BurndownPanel({
    super.key,
    required this.projectId,
    required this.sprint,
  });

  final String projectId;
  final Sprint sprint;

  @override
  ConsumerState<BurndownPanel> createState() => _BurndownPanelState();
}

class _BurndownPanelState extends ConsumerState<BurndownPanel> {
  var _metric = BurndownMetric.points;

  @override
  Widget build(BuildContext context) {
    final key = (project: widget.projectId, sprint: widget.sprint.id);
    final data = ref.watch(burndownProvider(key));
    return switch (data) {
      AsyncData(:final value) => _body(context, value),
      AsyncError(:final error) => TfError(
        key: const Key('burndown-error'),
        compact: true,
        message: sprintErrorMessage(error, context.l10n),
        details: '$error',
        retryKey: const Key('burndown-retry'),
        onRetry: () => ref.invalidate(burndownProvider(key)),
      ),
      _ => const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      ),
    };
  }

  Widget _body(BuildContext context, Burndown b) {
    final chart = buildBurndownChart(b, _metric);
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                context.l10n.grpABurndownTitle(widget.sprint.name),
                style: theme.textTheme.titleMedium,
              ),
            ),
            SegmentedButton<BurndownMetric>(
              key: const Key('burndown-metric'),
              showSelectedIcon: false,
              segments: [
                ButtonSegment(
                  value: BurndownMetric.points,
                  label: Text(
                    context.l10n.grpAPoints,
                    key: const Key('metric-points'),
                  ),
                ),
                ButtonSegment(
                  value: BurndownMetric.tasks,
                  label: Text(
                    context.l10n.grpATasks,
                    key: const Key('metric-tasks'),
                  ),
                ),
              ],
              selected: {_metric},
              onSelectionChanged: (s) => setState(() => _metric = s.first),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (chart.isEmpty)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              context.l10n.grpABurndownEmpty,
              key: const Key('burndown-empty'),
            ),
          )
        else
          SizedBox(
            height: 220,
            child: Semantics(
              label:
                  context.l10n.grpABurndownChart(
                    chart.points.length,
                    chart.steps.length,
                  ) +
                  (chart.backfilledDays == 0
                      ? ''
                      : context.l10n.grpABurndownBackfilled(
                          chart.backfilledDays,
                        )),
              child: _BurndownChart(
                key: const Key('burndown-chart'),
                data: chart,
                actual: theme.colorScheme.primary,
                ideal: theme.colorScheme.outline,
                scope: theme.colorScheme.error,
                grid: theme.colorScheme.outlineVariant,
              ),
            ),
          ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 16,
          children: [
            _Legend(
              color: theme.colorScheme.primary,
              label: context.l10n.grpALegendRemaining,
            ),
            _Legend(
              color: theme.colorScheme.outline,
              label: context.l10n.grpALegendIdeal,
            ),
            _Legend(
              color: theme.colorScheme.error,
              label: context.l10n.grpALegendScopeChange,
            ),
            if (chart.backfilledDays > 0)
              Row(
                key: const Key('legend-backfilled'),
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.circle_outlined,
                    size: 12,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    context.l10n.grpALegendBackfilled,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(width: 12, height: 3, color: color),
      const SizedBox(width: 4),
      Text(label, style: Theme.of(context).textTheme.bodySmall),
    ],
  );
}

/// Draws a [ChartData]: x is the day, y the remaining work.
class _BurndownChart extends StatelessWidget {
  const _BurndownChart({
    super.key,
    required this.data,
    required this.actual,
    required this.ideal,
    required this.scope,
    required this.grid,
  });

  final ChartData data;
  final Color actual;
  final Color ideal;
  final Color scope;
  final Color grid;

  static String _short(DateTime d) => '${d.month}/${d.day}';

  @override
  Widget build(BuildContext context) {
    final points = data.points;
    final last = points.length - 1;
    final lastMeasured = points.lastIndexWhere((p) => p.actual != null);
    return SeriesChart(
      series: [
        LineSeries.values(
          [for (final p in points) p.ideal],
          label: context.l10n.grpALegendIdeal,
          color: ideal,
          dashPattern: const [6, 4],
        ),
        // Stops at the last day with a measurement (future days stay blank).
        LineSeries.values(
          [for (final p in points) p.actual],
          label: context.l10n.grpALegendRemaining,
          color: actual,
          width: 2.5,
          dotBuilder: (i, _) => i == lastMeasured
              ? SeriesDot(radius: 4, color: actual)
              // A day written late: a ring.
              : points[i].backfilled
              ? SeriesDot(
                  radius: 4,
                  color: Colors.transparent,
                  strokeColor: actual,
                  strokeWidth: 1.5,
                )
              : null,
        ),
      ],
      xAxis: SeriesXAxis(
        labels: [
          for (var i = 0; i <= last; i++)
            i == 0 || i == last ? _short(points[i].date) : '',
        ],
      ),
      yAxis: SeriesYAxis(formatter: pointsText),
      grid: SeriesGrid(color: grid),
      minY: 0,
      maxY: data.maxY,
      // Steps where scope changed: a marker line labelled with the change.
      referenceLines: [
        for (final s in data.steps)
          SeriesReferenceLine.vertical(
            s.index.toDouble(),
            color: scope,
            label: (s.delta > 0 ? '+' : '') + pointsText(s.delta),
          ),
      ],
    );
  }
}

/// Committed against completed points of the last six sprints.
class VelocityPanel extends ConsumerWidget {
  const VelocityPanel({
    super.key,
    required this.projectId,
    required this.sprint,
  });

  final String projectId;

  /// Any sprint of the project: the answer carries the project's velocity.
  final Sprint sprint;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final key = (project: projectId, sprint: sprint.id);
    final theme = Theme.of(context);
    return switch (ref.watch(burndownProvider(key))) {
      AsyncData(:final value) => _body(
        context,
        theme,
        lastVelocity(value.velocity),
        value,
      ),
      AsyncError() => const SizedBox.shrink(),
      _ => const SizedBox.shrink(),
    };
  }

  Widget _body(
    BuildContext context,
    ThemeData theme,
    List<VelocityItem> items,
    Burndown b,
  ) {
    if (items.isEmpty) {
      return TfEmpty(
        key: const Key('velocity-empty'),
        compact: true,
        illustration: TfIllustrationKind.goals,
        title: context.l10n.grpAVelocityEmpty,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.grpAVelocityTitle(
            items.length,
            pointsText(b.averageVelocity),
          ),
          key: const Key('velocity-title'),
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 160,
          child: Semantics(
            label: context.l10n.grpAVelocityChart(items.length),
            child: SeriesChart(
              key: const Key('velocity-chart'),
              series: [
                BarSeries.values(
                  [for (final v in items) v.committedPoints],
                  label: context.l10n.grpALegendCommitted,
                  color: theme.colorScheme.outline,
                ),
                BarSeries.values(
                  [for (final v in items) v.completedPoints],
                  label: context.l10n.grpALegendCompleted,
                  color: theme.colorScheme.primary,
                ),
              ],
              xAxis: SeriesXAxis(labels: [for (final v in items) v.name]),
              yAxis: SeriesYAxis(formatter: pointsText),
              grid: SeriesGrid(color: theme.colorScheme.outlineVariant),
              minY: 0,
            ),
          ),
        ),
        Wrap(
          spacing: 16,
          children: [
            _Legend(
              color: theme.colorScheme.outline,
              label: context.l10n.grpALegendCommitted,
            ),
            _Legend(
              color: theme.colorScheme.primary,
              label: context.l10n.grpALegendCompleted,
            ),
          ],
        ),
      ],
    );
  }
}
