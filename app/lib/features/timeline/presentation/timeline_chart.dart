import 'package:flutter/gestures.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

import 'package:taskforge/features/calendar/domain/calendar_math.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';
import 'package:taskforge/features/timeline/domain/timeline_math.dart';
import 'package:taskforge/features/timeline/domain/timeline_scene.dart';
import 'package:taskforge/features/timeline/presentation/timeline_painter.dart';

/// A recognizer that only takes a pointer when [accepts] says it landed on a
/// bar (and of the right kind of device), so every other touch scrolls.
class _OnBarPan extends PanGestureRecognizer {
  _OnBarPan(this.accepts) : super(debugOwner: null);

  final bool Function(PointerEvent) accepts;

  @override
  bool isPointerAllowed(PointerEvent event) =>
      accepts(event) && super.isPointerAllowed(event);
}

class _OnBarLongPress extends LongPressGestureRecognizer {
  _OnBarLongPress(this.accepts) : super(debugOwner: null);

  final bool Function(PointerEvent) accepts;

  @override
  bool isPointerAllowed(PointerDownEvent event) =>
      accepts(event) && super.isPointerAllowed(event);
}

class _OnBarTap extends TapGestureRecognizer {
  _OnBarTap(this.accepts) : super(debugOwner: null);

  final bool Function(PointerEvent) accepts;

  @override
  bool isPointerAllowed(PointerDownEvent event) =>
      accepts(event) && super.isPointerAllowed(event);
}

/// The scrolling canvas: bars and arrows, drag to move, drag an edge to
/// resize (at once with a mouse or pen, after a long press on touch so a drag
/// still scrolls), pinch or Ctrl/Cmd + wheel to zoom.
class TimelineChart extends StatefulWidget {
  const TimelineChart({
    super.key,
    required this.scene,
    required this.zoom,
    required this.today,
    required this.horizontal,
    required this.vertical,
    required this.canMove,
    required this.onMove,
    required this.onOpen,
    required this.onZoomStep,
    required this.onHover,
    this.selectedId,
  });

  final TimelineScene scene;
  final TimelineZoom zoom;
  final Day today;
  final ScrollController horizontal;
  final ScrollController vertical;
  final bool canMove;

  /// A bar was dropped with these dates.
  final void Function(Task task, Dates dates) onMove;
  final void Function(Task task) onOpen;

  /// Zoom one step: positive spreads the days out.
  final void Function(int steps) onZoomStep;

  /// The bar under the mouse (or being dragged) and the dates it has now.
  final void Function(Task? task, Dates? dates) onHover;
  final String? selectedId;

  @override
  State<TimelineChart> createState() => _TimelineChartState();
}

class _TimelineChartState extends State<TimelineChart> {
  final _viewport = ValueNotifier<Size>(Size.zero);
  final _drag = ValueNotifier<DragPreview?>(null);
  final _pointers = <int, Offset>{};
  double? _pinchStart;
  BarHit? _grabbed;
  Day? _grabbedDay;
  Offset? _downAt;

  @override
  void dispose() {
    _viewport.dispose();
    _drag.dispose();
    super.dispose();
  }

  BarHit? _hitAt(Offset local) => widget.scene.hit(local);

  bool _onBar(PointerEvent e, {required bool touch}) {
    final isTouch = e.kind == PointerDeviceKind.touch;
    if (isTouch != touch) return false;
    return _hitAt(e.localPosition) != null;
  }

  bool _movable(PointerEvent e, {required bool touch}) =>
      widget.canMove && _onBar(e, touch: touch);

  void _grab(Offset local) {
    _grabbed = _hitAt(local);
    _grabbedDay = widget.scene.axis.dayAt(local.dx);
  }

  void _dragTo(Offset local) {
    final hit = _grabbed;
    if (hit == null) return;
    final target = widget.scene.axis.dayAt(local.dx);
    final dates = hit.edge != null
        ? resizeTask(hit.task, hit.edge!, target)
        : moveTask(hit.task, target, grabbed: _grabbedDay);
    _drag.value = DragPreview(hit.task, dates);
    widget.onHover(hit.task, dates);
  }

  void _drop() {
    final shown = _drag.value;
    _drag.value = null;
    _grabbed = null;
    if (shown == null) return;
    final task = shown.task;
    final same =
        shown.dates.startIso == task.startDate &&
        shown.dates.dueIso == task.dueDate;
    widget.onHover(null, null);
    if (!same) widget.onMove(task, shown.dates);
  }

  void _cancelDrag() {
    _drag.value = null;
    _grabbed = null;
    widget.onHover(null, null);
  }

  // A pinch is two pointers moving apart or together: watched beside the
  // gesture arena, so the scroll views keep scrolling.
  void _pointerDown(PointerDownEvent e) {
    _pointers[e.pointer] = e.position;
    if (_pointers.length == 2) _pinchStart = _spread();
  }

  double _spread() {
    final p = _pointers.values.toList();
    return (p[0] - p[1]).distance;
  }

  void _pointerUp(PointerEvent e) {
    final start = _pinchStart;
    if (start != null && start > 0 && _pointers.length == 2) {
      final scale = _spread() / start;
      final zoom = zoomAfter(widget.zoom, scale);
      if (zoom != widget.zoom) {
        widget.onZoomStep(zoom.index < widget.zoom.index ? 1 : -1);
      }
    }
    _pointers.remove(e.pointer);
    if (_pointers.length < 2) _pinchStart = null;
  }

  void _pointerMove(PointerMoveEvent e) {
    if (_pointers.containsKey(e.pointer)) _pointers[e.pointer] = e.position;
  }

  void _signal(PointerSignalEvent e) {
    if (e is! PointerScrollEvent) return;
    final keys = HardwareKeyboard.instance;
    if (!keys.isControlPressed && !keys.isMetaPressed) return;
    GestureBinding.instance.pointerSignalResolver.register(e, (_) {
      widget.onZoomStep(e.scrollDelta.dy < 0 ? 1 : -1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final scene = widget.scene;
    final painter = TimelinePainter(
      scene: scene,
      scheme: Theme.of(context).colorScheme,
      zoom: widget.zoom,
      today: widget.today,
      horizontal: widget.horizontal,
      vertical: widget.vertical,
      viewport: _viewport,
      drag: _drag,
      selectedId: widget.selectedId,
    );
    final gestures = <Type, GestureRecognizerFactory>{
      _OnBarTap: GestureRecognizerFactoryWithHandlers<_OnBarTap>(
        () =>
            _OnBarTap((e) => _onBar(e, touch: true) || _onBar(e, touch: false)),
        (t) {
          // A tap is read where it ended: its position is set by the pointer.
          t.onTapUp = (d) {
            final hit = _hitAt(d.localPosition);
            if (hit != null) widget.onOpen(hit.task);
          };
        },
      ),
      _OnBarPan: GestureRecognizerFactoryWithHandlers<_OnBarPan>(
        () => _OnBarPan((e) => _movable(e, touch: false)),
        (p) {
          p.onDown = (d) => _downAt = d.localPosition;
          p.onStart = (d) {
            // Grabbed where the pointer went down, not where the slop ended.
            _grab(_downAt ?? d.localPosition);
            _dragTo(d.localPosition);
          };
          p.onUpdate = (d) => _dragTo(d.localPosition);
          p.onEnd = (_) => _drop();
          p.onCancel = _cancelDrag;
        },
      ),
      _OnBarLongPress: GestureRecognizerFactoryWithHandlers<_OnBarLongPress>(
        () => _OnBarLongPress((e) => _movable(e, touch: true)),
        (l) {
          l.onLongPressStart = (d) {
            HapticFeedback.selectionClick();
            _grab(d.localPosition);
            _dragTo(d.localPosition);
          };
          l.onLongPressMoveUpdate = (d) => _dragTo(d.localPosition);
          l.onLongPressEnd = (_) => _drop();
          l.onLongPressCancel = _cancelDrag;
        },
      ),
    };
    return LayoutBuilder(
      builder: (context, box) {
        final size = Size(box.maxWidth, box.maxHeight);
        if (_viewport.value != size) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _viewport.value = size;
          });
        }
        return Listener(
          onPointerDown: _pointerDown,
          onPointerMove: _pointerMove,
          onPointerUp: _pointerUp,
          onPointerCancel: _pointerUp,
          child: SingleChildScrollView(
            controller: widget.vertical,
            child: SingleChildScrollView(
              controller: widget.horizontal,
              scrollDirection: Axis.horizontal,
              child: RawGestureDetector(
                gestures: gestures,
                child: MouseRegion(
                  onHover: (e) {
                    final hit = _hitAt(e.localPosition);
                    widget.onHover(hit?.task, null);
                  },
                  onExit: (_) => widget.onHover(null, null),
                  child: Listener(
                    onPointerSignal: _signal,
                    child: CustomPaint(
                      key: const Key('timeline-canvas'),
                      size: Size(
                        scene.size.width < size.width
                            ? size.width
                            : scene.size.width,
                        scene.size.height < size.height
                            ? size.height
                            : scene.size.height,
                      ),
                      painter: painter,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
