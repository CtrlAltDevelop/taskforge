import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';

import 'package:taskforge/features/workflows/domain/workflow.dart';
import 'package:taskforge/features/workflows/domain/workflow_draft.dart';

/// The workflow as nodes and arrows (a read-only picture of the draft: the
/// arrows are edited on the status cards). Unrestricted workflows say so.
class WorkflowGraph extends StatelessWidget {
  const WorkflowGraph({super.key, required this.draft});

  final WorkflowDraft draft;

  @override
  Widget build(BuildContext context) {
    if (!draft.restrict) {
      return Card(
        key: const Key('graph-unrestricted'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(context.l10n.grpIAnyStatusMoves),
        ),
      );
    }
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: context.l10n.grpIWorkflowGraphLabel(
        draft.statuses.length,
        draft.transitions.length,
      ),
      child: Card(
        child: AspectRatio(
          aspectRatio: 1.1,
          child: CustomPaint(
            key: const Key('workflow-graph'),
            painter: GraphPainter(
              draft: draft,
              edge: scheme.onSurfaceVariant,
              text: scheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}

class GraphPainter extends CustomPainter {
  GraphPainter({required this.draft, required this.edge, required this.text});

  final WorkflowDraft draft;
  final Color edge;
  final Color text;

  static const nodeRadius = 22.0;

  /// Where each status sits: evenly around a circle, the first at the top.
  static Map<String, Offset> layout(List<DraftStatus> statuses, Size size) {
    final centre = size.center(Offset.zero);
    final radius = math.max(0.0, math.min(size.width, size.height) / 2 - 48);
    return {
      for (final (i, s) in statuses.indexed)
        s.key: statuses.length == 1
            ? centre
            : centre +
                  Offset(
                    radius * math.sin(2 * math.pi * i / statuses.length),
                    -radius * math.cos(2 * math.pi * i / statuses.length),
                  ),
    };
  }

  @override
  void paint(Canvas canvas, Size size) {
    final at = layout(draft.statuses, size);
    final line = Paint()
      ..color = edge
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;
    for (final t in draft.transitions) {
      final a = at[t.from];
      final b = at[t.to];
      if (a == null || b == null) continue;
      _arrow(canvas, a, b, line, bend: draft.allows(t.to, t.from));
    }
    for (final s in draft.statuses) {
      final p = at[s.key]!;
      canvas.drawCircle(
        p,
        nodeRadius,
        Paint()..color = parseStatusColor(s.color),
      );
      if (s.isDefault) {
        canvas.drawCircle(
          p,
          nodeRadius + 4,
          Paint()
            ..color = edge
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
      }
      final label = TextPainter(
        text: TextSpan(
          text: s.name.isEmpty ? '?' : s.name,
          style: TextStyle(color: text, fontSize: 12),
        ),
        textDirection: TextDirection.ltr,
        maxLines: 1,
        ellipsis: '…',
      )..layout(maxWidth: 96);
      label.paint(canvas, p + Offset(-label.width / 2, nodeRadius + 6));
    }
  }

  /// A line from [a] to [b] stopping at the node edge, with an arrowhead; when
  /// the way back exists too ([bend]) each direction curves to its own side.
  void _arrow(
    Canvas canvas,
    Offset a,
    Offset b,
    Paint paint, {
    required bool bend,
  }) {
    final direction = (b - a);
    if (direction.distance < 1) return;
    final unit = direction / direction.distance;
    final normal = Offset(-unit.dy, unit.dx);
    final start = a + unit * nodeRadius;
    final end = b - unit * (nodeRadius + 4);
    final control = bend ? (start + end) / 2 + normal * 26 : (start + end) / 2;
    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..quadraticBezierTo(control.dx, control.dy, end.dx, end.dy);
    canvas.drawPath(path, paint);
    final tip = end - control;
    final heading = tip.distance < 1 ? unit : tip / tip.distance;
    final side = Offset(-heading.dy, heading.dx);
    final head = Path()
      ..moveTo(end.dx, end.dy)
      ..lineTo(
        (end - heading * 9 + side * 5).dx,
        (end - heading * 9 + side * 5).dy,
      )
      ..lineTo(
        (end - heading * 9 - side * 5).dx,
        (end - heading * 9 - side * 5).dy,
      )
      ..close();
    canvas.drawPath(head, Paint()..color = paint.color);
  }

  @override
  bool shouldRepaint(GraphPainter old) =>
      old.draft != draft || old.edge != edge || old.text != text;
}
