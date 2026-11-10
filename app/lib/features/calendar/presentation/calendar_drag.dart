import 'package:flutter/widgets.dart';

import 'package:taskforge/features/calendar/domain/calendar_math.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';

/// What is being dragged on the calendar: a task (picked up on day [grabbed],
/// null from the tray) or one edge of its bar.
class CalDrag {
  CalDrag(this.task, {this.edge, this.fromTray = false});

  final Task task;
  final BarEdge? edge;
  final bool fromTray;

  /// The day the bar was picked up on; set when the pointer goes down on it.
  Day? grabbed;

  /// The dates this drag gives [task] when dropped on [target].
  Dates datesOn(Day target) => edge != null
      ? resizeTask(task, edge!, target)
      : moveTask(task, target, grabbed: grabbed);
}

/// A draggable that starts at once with a mouse and after a long press on a
/// touch screen (so a drag there still scrolls).
Widget calDraggable({
  required bool longPress,
  required CalDrag data,
  required Widget feedback,
  required Widget child,
  Widget? childWhenDragging,
}) => longPress
    ? LongPressDraggable<CalDrag>(
        data: data,
        dragAnchorStrategy: pointerDragAnchorStrategy,
        feedback: feedback,
        childWhenDragging: childWhenDragging,
        child: child,
      )
    : Draggable<CalDrag>(
        data: data,
        dragAnchorStrategy: pointerDragAnchorStrategy,
        feedback: feedback,
        childWhenDragging: childWhenDragging,
        child: child,
      );
