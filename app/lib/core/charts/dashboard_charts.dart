import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';

/// One value on a chart: [key] is what a click reports back (the bucket).
class ChartDatum {
  const ChartDatum(this.key, this.label, this.value, this.shown);

  final String key;
  final String label;
  final double value;

  /// The number as the server wrote it, so the chart never rounds it again.
  final String shown;
}

/// The colours of a chart's series, the same in every chart and in both
/// themes (picked to stay apart for the common kinds of colour blindness).
List<Color> chartPalette(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  return dark
      ? const [
          Color(0xFF6CA6FF),
          Color(0xFFFFB454),
          Color(0xFF5FD3A5),
          Color(0xFFE88AB8),
          Color(0xFFB8A2FF),
          Color(0xFFE5E066),
          Color(0xFF63D5E6),
          Color(0xFFFF8A75),
        ]
      : const [
          Color(0xFF1F6FEB),
          Color(0xFFD97706),
          Color(0xFF0E9F6E),
          Color(0xFFC2417A),
          Color(0xFF7C5CE6),
          Color(0xFF9A8F00),
          Color(0xFF0891B2),
          Color(0xFFD9482B),
        ];
}

Color chartColor(BuildContext context, int index) {
  final palette = chartPalette(Theme.of(context).brightness);
  return palette[index % palette.length];
}

/// A big number with its caption.
class NumberTile extends StatelessWidget {
  const NumberTile({super.key, required this.value, this.caption = ''});

  final String value;
  final String caption;

  @override
  Widget build(BuildContext context) => Semantics(
    label: '$caption $value'.trim(),
    child: Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          value,
          key: const Key('number-value'),
          style: Theme.of(context).textTheme.displayMedium,
        ),
      ),
    ),
  );
}

/// Horizontal bars, longest first as given; a bar is a button.
class BarChartView extends StatelessWidget {
  const BarChartView({
    super.key,
    required this.data,
    this.onTap,
    this.semanticsLabel,
  });

  final List<ChartDatum> data;
  final ValueChanged<ChartDatum>? onTap;

  /// The name read out first; the chart's own kind when null.
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final top = data.fold<double>(0, (m, d) => math.max(m, d.value));
    return Semantics(
      label: context.l10n.grpRChartBars(
        semanticsLabel ?? context.l10n.grpMWkBar,
        data.length,
      ),
      container: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < data.length; i++)
            _BarRow(
              key: Key('bar-${data[i].key}'),
              datum: data[i],
              fraction: top <= 0 ? 0 : data[i].value / top,
              color: chartColor(context, i),
              onTap: onTap,
            ),
        ],
      ),
    );
  }
}

class _BarRow extends StatelessWidget {
  const _BarRow({
    super.key,
    required this.datum,
    required this.fraction,
    required this.color,
    this.onTap,
  });

  final ChartDatum datum;
  final double fraction;
  final Color color;
  final ValueChanged<ChartDatum>? onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme.bodySmall;
    return Semantics(
      button: onTap != null,
      label: '${datum.label}, ${datum.shown}',
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap == null ? null : () => onTap!(datum),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(
            children: [
              SizedBox(
                width: 96,
                child: Text(
                  datum.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: text,
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (_, c) => Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Container(
                      height: 14,
                      width: math.max(2, c.maxWidth * fraction),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(datum.shown, style: text),
            ],
          ),
        ),
      ),
    );
  }
}

/// A pie with a legend; both a slice and a legend row report their bucket.
class PieChartView extends StatelessWidget {
  const PieChartView({
    super.key,
    required this.data,
    this.onTap,
    this.semanticsLabel,
  });

  final List<ChartDatum> data;
  final ValueChanged<ChartDatum>? onTap;

  /// The name read out first; the chart's own kind when null.
  final String? semanticsLabel;

  double get _sum => data.fold<double>(0, (s, d) => s + math.max(d.value, 0));

  /// The slice an angle (clockwise from the top, in radians) falls in.
  static int? sliceAt(List<double> values, double angle) {
    final sum = values.fold<double>(0, (s, v) => s + math.max(v, 0));
    if (sum <= 0) return null;
    var from = 0.0;
    for (var i = 0; i < values.length; i++) {
      final sweep = math.max(values[i], 0) / sum * 2 * math.pi;
      if (angle >= from && angle < from + sweep) return i;
      from += sweep;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final colors = [
      for (var i = 0; i < data.length; i++) chartColor(context, i),
    ];
    final sum = _sum;
    return Semantics(
      label: context.l10n.grpRChartSlices(
        semanticsLabel ?? context.l10n.grpMWkPie,
        data.length,
      ),
      container: true,
      child: Row(
        children: [
          SizedBox(
            width: 120,
            height: 120,
            child: GestureDetector(
              key: const Key('pie'),
              onTapUp: onTap == null
                  ? null
                  : (d) {
                      final centre = const Offset(60, 60);
                      final v = d.localPosition - centre;
                      if (v.distance > 60) return;
                      final angle =
                          (math.atan2(v.dx, -v.dy) + 2 * math.pi) %
                          (2 * math.pi);
                      final i = sliceAt([for (final d in data) d.value], angle);
                      if (i != null) onTap!(data[i]);
                    },
              child: CustomPaint(
                painter: _PiePainter(
                  [for (final d in data) d.value],
                  colors,
                  Theme.of(context).colorScheme.surface,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < data.length; i++)
                  Semantics(
                    button: onTap != null,
                    label: sum <= 0
                        ? '${data[i].label}, ${data[i].shown}'
                        : context.l10n.grpRChartPercent(
                            data[i].label,
                            data[i].shown,
                            (data[i].value / sum * 100).round(),
                          ),
                    excludeSemantics: true,
                    child: InkWell(
                      key: Key('slice-${data[i].key}'),
                      onTap: onTap == null ? null : () => onTap!(data[i]),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            Container(width: 10, height: 10, color: colors[i]),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                data[i].label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                            Text(
                              data[i].shown,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PiePainter extends CustomPainter {
  _PiePainter(this.values, this.colors, this.gap);

  final List<double> values;
  final List<Color> colors;
  final Color gap;

  @override
  void paint(Canvas canvas, Size size) {
    final sum = values.fold<double>(0, (s, v) => s + math.max(v, 0));
    final rect = Offset.zero & size;
    if (sum <= 0) {
      canvas.drawCircle(
        rect.center,
        size.shortestSide / 2,
        Paint()..color = gap,
      );
      return;
    }
    var start = -math.pi / 2;
    for (var i = 0; i < values.length; i++) {
      final sweep = math.max(values[i], 0) / sum * 2 * math.pi;
      canvas.drawArc(rect, start, sweep, true, Paint()..color = colors[i]);
      canvas.drawArc(
        rect,
        start,
        sweep,
        true,
        Paint()
          ..color = gap
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(_PiePainter old) =>
      !listEquals(old.values, values) || !listEquals(old.colors, colors);
}

bool listEquals<T>(List<T> a, List<T> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

/// One line on a [LineChartView]: its name and values, aligned with the
/// chart's x labels.
class ChartSeries {
  const ChartSeries(this.name, this.values);

  final String name;
  final List<double?> values;
}

/// Lines over a shared x axis (dates). A point is tappable when [onTap] is
/// given: it reports the x label's index.
class LineChartView extends StatelessWidget {
  const LineChartView({
    super.key,
    required this.xLabels,
    required this.series,
    this.onTap,
    this.semanticsLabel,
  });

  final List<String> xLabels;
  final List<ChartSeries> series;
  final ValueChanged<int>? onTap;

  /// The name read out first; the chart's own kind when null.
  final String? semanticsLabel;

  /// The x position (0..count-1) nearest to [dx] of [width] pixels.
  static int nearest(double dx, double width, int count) {
    if (count <= 1 || width <= 0) return 0;
    final i = (dx / width * (count - 1)).round();
    return i.clamp(0, count - 1);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = [
      for (var i = 0; i < series.length; i++) chartColor(context, i),
    ];
    final text = Theme.of(context).textTheme.bodySmall;
    return Semantics(
      label: context.l10n.grpRChartLines(
        semanticsLabel ?? context.l10n.grpMWkLine,
        series.length,
        xLabels.length,
      ),
      container: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (_, c) => GestureDetector(
                key: const Key('line-chart'),
                onTapUp: onTap == null
                    ? null
                    : (d) => onTap!(
                        nearest(d.localPosition.dx, c.maxWidth, xLabels.length),
                      ),
                child: CustomPaint(
                  size: Size.infinite,
                  painter: _LinePainter(
                    series,
                    colors,
                    scheme.outlineVariant,
                    scheme.onSurface,
                  ),
                ),
              ),
            ),
          ),
          if (xLabels.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(xLabels.first, style: text),
                Text(xLabels.last, style: text),
              ],
            ),
          if (series.length > 1)
            Wrap(
              spacing: 12,
              children: [
                for (var i = 0; i < series.length; i++)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(width: 10, height: 10, color: colors[i]),
                      const SizedBox(width: 4),
                      Text(series[i].name, style: text),
                    ],
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _LinePainter extends CustomPainter {
  _LinePainter(this.series, this.colors, this.grid, this.text);

  final List<ChartSeries> series;
  final List<Color> colors;
  final Color grid;
  final Color text;

  @override
  void paint(Canvas canvas, Size size) {
    final all = [for (final s in series) ...s.values.nonNulls];
    final count = series.fold<int>(0, (m, s) => math.max(m, s.values.length));
    if (all.isEmpty || count == 0) return;
    final top = all.reduce(math.max);
    final low = math.min(0.0, all.reduce(math.min));
    final span = (top - low) == 0 ? 1.0 : top - low;
    final axis = Paint()
      ..color = grid
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(0, size.height),
      Offset(size.width, size.height),
      axis,
    );
    canvas.drawLine(Offset.zero, Offset(0, size.height), axis);
    Offset at(int i, double v) => Offset(
      count == 1 ? size.width / 2 : i / (count - 1) * size.width,
      size.height - (v - low) / span * (size.height - 4) - 2,
    );
    for (var s = 0; s < series.length; s++) {
      final paint = Paint()
        ..color = colors[s]
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      final path = Path();
      var open = false;
      for (var i = 0; i < series[s].values.length; i++) {
        final v = series[s].values[i];
        if (v == null) {
          open = false;
          continue;
        }
        final p = at(i, v);
        open ? path.lineTo(p.dx, p.dy) : path.moveTo(p.dx, p.dy);
        open = true;
        canvas.drawCircle(p, 2.5, Paint()..color = colors[s]);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_LinePainter old) =>
      old.series != series || old.colors != colors;
}

/// Rows of label and value; a row is a button.
class TableChartView extends StatelessWidget {
  const TableChartView({
    super.key,
    required this.data,
    this.onTap,
    this.valueHeader = 'Value',
  });

  final List<ChartDatum> data;
  final ValueChanged<ChartDatum>? onTap;
  final String valueHeader;

  @override
  Widget build(BuildContext context) {
    final head = Theme.of(context).textTheme.labelMedium;
    return ListView(
      shrinkWrap: true,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Expanded(child: Text(context.l10n.grpHChartGroup, style: head)),
              Text(valueHeader, style: head),
            ],
          ),
        ),
        const Divider(height: 1),
        for (final d in data)
          InkWell(
            key: Key('row-${d.key}'),
            onTap: onTap == null ? null : () => onTap!(d),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Expanded(child: Text(d.label)),
                  Text(d.shown),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
