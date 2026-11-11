import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/charts/chart_paint.dart';
import 'package:taskforge/features/sprints/application/sprints_providers.dart';
import 'package:taskforge/features/sprints/domain/sprints.dart';

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
      AsyncError(:final error) => Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                sprintErrorMessage(error),
                key: const Key('burndown-error'),
              ),
            ),
            TextButton(
              key: const Key('burndown-retry'),
              onPressed: () => ref.invalidate(burndownProvider(key)),
              child: const Text('Retry'),
            ),
          ],
        ),
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
                'Burndown: ${widget.sprint.name}',
                style: theme.textTheme.titleMedium,
              ),
            ),
            SegmentedButton<BurndownMetric>(
              key: const Key('burndown-metric'),
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(
                  value: BurndownMetric.points,
                  label: Text('Points', key: Key('metric-points')),
                ),
                ButtonSegment(
                  value: BurndownMetric.tasks,
                  label: Text('Tasks', key: Key('metric-tasks')),
                ),
              ],
              selected: {_metric},
              onSelectionChanged: (s) => setState(() => _metric = s.first),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (chart.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'The burndown starts once the sprint is started.',
              key: Key('burndown-empty'),
            ),
          )
        else
          SizedBox(
            height: 220,
            child: Semantics(
              label:
                  'Burndown chart, ${chart.points.length} days, '
                  '${chart.steps.length} scope changes'
                  '${chart.backfilledDays == 0 ? '' : ', ${chart.backfilledDays} back-filled days'}',
              child: CustomPaint(
                key: const Key('burndown-chart'),
                size: Size.infinite,
                painter: BurndownPainter(
                  chart,
                  actual: theme.colorScheme.primary,
                  ideal: theme.colorScheme.outline,
                  scope: theme.colorScheme.error,
                  text: theme.colorScheme.onSurface,
                ),
              ),
            ),
          ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 16,
          children: [
            _Legend(color: theme.colorScheme.primary, label: 'Remaining'),
            _Legend(color: theme.colorScheme.outline, label: 'Ideal'),
            _Legend(color: theme.colorScheme.error, label: 'Scope change'),
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
                  Text('Back-filled day', style: theme.textTheme.bodySmall),
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
class BurndownPainter extends CustomPainter {
  BurndownPainter(
    this.data, {
    required this.actual,
    required this.ideal,
    required this.scope,
    required this.text,
  });

  final ChartData data;
  final Color actual;
  final Color ideal;
  final Color scope;
  final Color text;

  static const _left = 32.0;
  static const _bottom = 20.0;

  Offset _at(Size size, int i, double v) {
    final w = size.width - _left - 8;
    final h = size.height - _bottom - 8;
    final n = data.points.length;
    final x = _left + (n <= 1 ? 0 : w * i / (n - 1));
    return Offset(x, 8 + h * (1 - v / data.maxY));
  }

  @override
  void paint(Canvas canvas, Size size) {
    paintChartAxes(
      canvas,
      Rect.fromLTRB(_left, 8, size.width - 8, size.height - _bottom),
      text,
    );
    _label(canvas, pointsText(data.maxY), const Offset(0, 2));
    _label(canvas, '0', Offset(14, size.height - _bottom - 12));
    final n = data.points.length;
    if (n > 0) {
      _label(
        canvas,
        _short(data.points.first.date),
        Offset(_left, size.height - 14),
      );
      if (n > 1) {
        _label(
          canvas,
          _short(data.points.last.date),
          Offset(size.width - 40, size.height - 14),
        );
      }
    }

    final idealPaint = Paint()
      ..color = ideal
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final idealPath = Path();
    for (var i = 0; i < n; i++) {
      final p = _at(size, i, data.points[i].ideal);
      i == 0 ? idealPath.moveTo(p.dx, p.dy) : idealPath.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(idealPath, idealPaint);

    // Steps where scope changed: a marker line with an arrow-ish label.
    final stepPaint = Paint()
      ..color = scope
      ..strokeWidth = 1.5;
    for (final s in data.steps) {
      final x = _at(size, s.index, 0).dx;
      canvas.drawLine(
        Offset(x, 8),
        Offset(x, size.height - _bottom),
        stepPaint,
      );
      _label(
        canvas,
        (s.delta > 0 ? '+' : '') + pointsText(s.delta),
        Offset(x + 2, 8),
      );
    }

    // Actual: stops at the last day with a measurement (future days blank).
    final actualPaint = Paint()
      ..color = actual
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    final path = Path();
    var started = false;
    Offset? last;
    for (var i = 0; i < n; i++) {
      final v = data.points[i].actual;
      if (v == null) continue;
      final p = _at(size, i, v);
      started ? path.lineTo(p.dx, p.dy) : path.moveTo(p.dx, p.dy);
      started = true;
      last = p;
    }
    canvas.drawPath(path, actualPaint);
    if (last != null) {
      canvas.drawCircle(last, 4, Paint()..color = actual);
    }

    // A day written late (its remaining count is as of the late run): a ring.
    final ring = Paint()
      ..color = actual
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    for (var i = 0; i < n; i++) {
      final p = data.points[i];
      final v = p.actual;
      if (p.backfilled && v != null) {
        canvas.drawCircle(_at(size, i, v), 4, ring);
      }
    }
  }

  String _short(DateTime d) => '${d.month}/${d.day}';

  void _label(Canvas canvas, String s, Offset at) =>
      paintChartLabel(canvas, s, at, text);

  @override
  bool shouldRepaint(BurndownPainter old) =>
      old.data != data ||
      old.actual != actual ||
      old.ideal != ideal ||
      old.scope != scope;
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
        theme,
        lastVelocity(value.velocity),
        value,
      ),
      AsyncError() => const SizedBox.shrink(),
      _ => const SizedBox.shrink(),
    };
  }

  Widget _body(ThemeData theme, List<VelocityItem> items, Burndown b) {
    if (items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'Velocity appears after the first completed sprint.',
          key: Key('velocity-empty'),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Velocity (last ${items.length} sprints): '
          'average ${pointsText(b.averageVelocity)} points',
          key: const Key('velocity-title'),
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 160,
          child: Semantics(
            label: 'Velocity chart, ${items.length} sprints',
            child: CustomPaint(
              key: const Key('velocity-chart'),
              size: Size.infinite,
              painter: VelocityPainter(
                items,
                committed: theme.colorScheme.outline,
                completed: theme.colorScheme.primary,
                text: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ),
        Wrap(
          spacing: 16,
          children: [
            _Legend(color: theme.colorScheme.outline, label: 'Committed'),
            _Legend(color: theme.colorScheme.primary, label: 'Completed'),
          ],
        ),
      ],
    );
  }
}

class VelocityPainter extends CustomPainter {
  VelocityPainter(
    this.items, {
    required this.committed,
    required this.completed,
    required this.text,
  });

  final List<VelocityItem> items;
  final Color committed;
  final Color completed;
  final Color text;

  @override
  void paint(Canvas canvas, Size size) {
    var top = 1.0;
    for (final v in items) {
      if (v.committedPoints > top) top = v.committedPoints;
      if (v.completedPoints > top) top = v.completedPoints;
    }
    final slot = size.width / items.length;
    final h = size.height - 18;
    paintChartAxes(canvas, Rect.fromLTRB(0, 0, size.width, h), text);
    for (var i = 0; i < items.length; i++) {
      final v = items[i];
      final bar = slot * 0.3;
      final x = slot * i + slot * 0.15;
      canvas.drawRect(
        Rect.fromLTWH(
          x,
          h * (1 - v.committedPoints / top),
          bar,
          h * v.committedPoints / top,
        ),
        Paint()..color = committed,
      );
      canvas.drawRect(
        Rect.fromLTWH(
          x + bar + 2,
          h * (1 - v.completedPoints / top),
          bar,
          h * v.completedPoints / top,
        ),
        Paint()..color = completed,
      );
      paintChartLabel(
        canvas,
        v.name,
        Offset(slot * i + 2, size.height - 14),
        text,
        maxWidth: slot - 4,
      );
    }
  }

  @override
  bool shouldRepaint(VelocityPainter old) => old.items != items;
}
