import 'package:material_ui/material_ui.dart';
import 'package:taskforge/features/tasks/domain/list_drop.dart';

/// A list row that takes a dragged task id. It shows where the drop would land
/// (a line above or below, or a frame for nesting) and tells [onDrop] the zone.
class RowDropTarget extends StatefulWidget {
  const RowDropTarget({
    super.key,
    required this.canNest,
    required this.willAccept,
    required this.onDrop,
    required this.child,
  });

  final bool canNest;
  final bool Function(String draggedId) willAccept;
  final void Function(String draggedId, DropZone zone) onDrop;
  final Widget child;

  @override
  State<RowDropTarget> createState() => _RowDropTargetState();
}

class _RowDropTargetState extends State<RowDropTarget> {
  DropZone _zone = DropZone.onto;

  void _track(DragTargetDetails<String> d) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    final zone = zoneAt(
      box.globalToLocal(d.offset).dy,
      box.size.height,
      canNest: widget.canNest,
    );
    if (zone != _zone) setState(() => _zone = zone);
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return DragTarget<String>(
      onWillAcceptWithDetails: (d) => widget.willAccept(d.data),
      onMove: _track,
      onAcceptWithDetails: (d) => widget.onDrop(d.data, _zone),
      builder: (context, hovering, _) {
        final border = hovering.isEmpty
            ? null
            : switch (_zone) {
                DropZone.above => Border(
                  top: BorderSide(color: color, width: 3),
                ),
                DropZone.below => Border(
                  bottom: BorderSide(color: color, width: 3),
                ),
                DropZone.onto => Border.all(color: color),
              };
        return DecoratedBox(
          decoration: BoxDecoration(border: border),
          child: widget.child,
        );
      },
    );
  }
}
