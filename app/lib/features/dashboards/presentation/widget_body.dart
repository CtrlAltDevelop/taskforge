import 'package:flutter/material.dart';

import 'package:taskforge/core/charts/dashboard_charts.dart';
import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/dashboards/domain/dashboards.dart';

/// A widget's numbers drawn the way its kind asks. [onBucket] gets the bucket
/// a click landed on ('' for the whole number): the caller lists its tasks.
class WidgetBody extends StatelessWidget {
  const WidgetBody({
    super.key,
    required this.widget,
    required this.data,
    this.onBucket,
  });

  final DashboardWidget widget;
  final WidgetData data;
  final ValueChanged<String>? onBucket;

  List<ChartDatum> get _bars => [
    for (final b in data.buckets)
      ChartDatum(b.key, b.label, b.amount, shortNumber(b.value)),
  ];

  @override
  Widget build(BuildContext context) {
    final label = widget.title.isEmpty ? widget.kind.label : widget.title;
    switch (widget.kind) {
      case WidgetKind.number:
        return InkWell(
          key: const Key('number-tap'),
          onTap: onBucket == null ? null : () => onBucket!(''),
          child: NumberTile(value: shortNumber(data.total), caption: label),
        );
      case WidgetKind.bar:
      case WidgetKind.workload:
        if (_bars.isEmpty) return const _Empty();
        return SingleChildScrollView(
          child: BarChartView(
            data: _bars,
            semanticsLabel: label,
            onTap: onBucket == null ? null : (d) => onBucket!(d.key),
          ),
        );
      case WidgetKind.pie:
        if (_bars.isEmpty) return const _Empty();
        return SingleChildScrollView(
          child: PieChartView(
            data: _bars,
            semanticsLabel: label,
            onTap: onBucket == null ? null : (d) => onBucket!(d.key),
          ),
        );
      case WidgetKind.table:
        if (_bars.isEmpty) return const _Empty();
        return TableChartView(
          data: _bars,
          valueHeader: widget.config.measure.label,
          onTap: onBucket == null ? null : (d) => onBucket!(d.key),
        );
      case WidgetKind.line:
      case WidgetKind.burndown:
        final lines = data.series;
        if (lines.isEmpty || lines.every((s) => s.points.isEmpty)) {
          return const _Empty();
        }
        // The longest line sets the axis (a burndown's ideal runs to the end of
        // the sprint; its remaining line only to today).
        final longest = lines.reduce(
          (a, b) => b.points.length > a.points.length ? b : a,
        );
        final labels = [for (final p in longest.points) p.x];
        return LineChartView(
          xLabels: labels,
          semanticsLabel: label,
          series: [
            for (final s in lines)
              ChartSeries(s.name, [
                for (final x in labels)
                  s.points.where((p) => p.x == x).firstOrNull?.amount,
              ]),
          ],
          onTap: onBucket == null || widget.kind == WidgetKind.burndown
              ? null
              : (i) => onBucket!(labels[i]),
        );
    }
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) => Center(
    child: Text(context.l10n.grpINothingToShow, key: const Key('widget-empty')),
  );
}
