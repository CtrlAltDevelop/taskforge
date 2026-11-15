import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:taskforge/features/dashboards/domain/dashboards.dart';
import 'package:taskforge/features/dashboards/presentation/widget_card.dart';

/// Below this width the grid stacks into one column (a phone).
const stackBelow = 700.0;

/// Height of one grid row.
const rowHeight = 76.0;

/// The widgets laid out on the 12-column grid. In edit mode a card moves by
/// dragging its header and resizes by dragging its corner; both snap to the
/// grid and push what they land on down, never shuffling the rest.
class DashboardGrid extends StatelessWidget {
  const DashboardGrid({
    super.key,
    required this.dashboard,
    required this.editing,
    required this.onLayout,
    required this.onEdit,
    required this.onRemove,
    this.unsaved = const {},
  });

  final Dashboard dashboard;
  final bool editing;
  final ValueChanged<List<LayoutCell>> onLayout;
  final ValueChanged<DashboardWidget> onEdit;
  final ValueChanged<DashboardWidget> onRemove;

  /// Widget ids that exist only in the unsaved draft.
  final Set<String> unsaved;

  DashboardWidget? _widget(String id) =>
      dashboard.widgets.where((w) => w.id == id).firstOrNull;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, c) {
      final cells = [
        ...dashboard.layout.where((l) => _widget(l.widgetId) != null),
      ]..sort((a, b) => a.y != b.y ? a.y.compareTo(b.y) : a.x.compareTo(b.x));
      if (c.maxWidth < stackBelow) return _stacked(cells);
      return _grid(cells, c.maxWidth);
    },
  );

  Widget _card(LayoutCell cell) {
    final w = _widget(cell.widgetId)!;
    return WidgetCard(
      widget: w,
      editing: editing,
      saved: !unsaved.contains(w.id),
      onEdit: () => onEdit(w),
      onRemove: () => onRemove(w),
    );
  }

  Widget _stacked(List<LayoutCell> cells) => ListView(
    key: const Key('dashboard-stack'),
    padding: const EdgeInsets.all(12),
    children: [
      for (final cell in cells)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: SizedBox(
            height: (cell.h * rowHeight).clamp(180, 360).toDouble(),
            child: _card(cell),
          ),
        ),
    ],
  );

  Widget _grid(List<LayoutCell> cells, double width) {
    final cellW = width / gridColumns;
    final rows = cells.fold<int>(0, (m, c) => c.y + c.h > m ? c.y + c.h : m);
    return SingleChildScrollView(
      key: const Key('dashboard-grid'),
      child: SizedBox(
        height: rows * rowHeight + 16,
        child: Stack(
          children: [
            for (final cell in cells)
              _Cell(
                key: ValueKey(cell.widgetId),
                cell: cell,
                cellWidth: cellW,
                editing: editing,
                onMove: (dx, dy) =>
                    onLayout(moveCell(dashboard.layout, cell.widgetId, dx, dy)),
                onResize: (dw, dh) => onLayout(
                  resizeCell(dashboard.layout, cell.widgetId, dw, dh),
                ),
                child: _card(cell),
              ),
          ],
        ),
      ),
    );
  }
}

class _Cell extends StatefulWidget {
  const _Cell({
    super.key,
    required this.cell,
    required this.cellWidth,
    required this.editing,
    required this.onMove,
    required this.onResize,
    required this.child,
  });

  final LayoutCell cell;
  final double cellWidth;
  final bool editing;
  final void Function(int dx, int dy) onMove;
  final void Function(int dw, int dh) onResize;
  final Widget child;

  @override
  State<_Cell> createState() => _CellState();
}

class _CellState extends State<_Cell> {
  var _drag = Offset.zero;
  var _grow = Offset.zero;

  @override
  Widget build(BuildContext context) {
    final c = widget.cell;
    final w = widget.cellWidth;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    // The preview never shrinks below the smallest card, whatever the drag.
    final width = math.max(c.w * w + _grow.dx, minCellWidth * w);
    final height = math.max(
      c.h * rowHeight + _grow.dy,
      minCellHeight * rowHeight,
    );
    final across = c.x * w + (rtl ? -_drag.dx : _drag.dx);
    return Positioned(
      left: rtl ? null : across,
      right: rtl ? across : null,
      top: c.y * rowHeight + _drag.dy,
      width: width,
      height: height,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Stack(
          children: [
            Positioned.fill(child: widget.child),
            if (widget.editing) ...[
              // The header strip moves the card.
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                height: 36,
                child: GestureDetector(
                  key: Key('move-${c.widgetId}'),
                  behavior: HitTestBehavior.translucent,
                  onPanUpdate: (d) => setState(() => _drag += d.delta),
                  onPanEnd: (_) {
                    final dx = (_drag.dx / w).round();
                    final dy = (_drag.dy / rowHeight).round();
                    setState(() => _drag = Offset.zero);
                    if (dx != 0 || dy != 0) widget.onMove(dx, dy);
                  },
                ),
              ),
              PositionedDirectional(
                end: 0,
                bottom: 0,
                child: GestureDetector(
                  key: Key('resize-${c.widgetId}'),
                  // The handle is at the end edge: dragging toward it grows
                  // the card, which is leftwards in right-to-left.
                  onPanUpdate: (d) => setState(
                    () => _grow += Offset(
                      rtl ? -d.delta.dx : d.delta.dx,
                      d.delta.dy,
                    ),
                  ),
                  onPanEnd: (_) {
                    final dw = (_grow.dx / w).round();
                    final dh = (_grow.dy / rowHeight).round();
                    setState(() => _grow = Offset.zero);
                    if (dw != 0 || dh != 0) widget.onResize(dw, dh);
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.open_in_full, size: 16),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
