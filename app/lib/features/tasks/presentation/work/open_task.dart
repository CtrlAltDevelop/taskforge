import 'package:flutter/widgets.dart';

import 'package:taskforge/features/tasks/domain/tasks.dart';

/// Installed by the project page: how a task opens (today a side pane on a
/// wide screen, a page on a narrow one).
class TaskOpenScope extends InheritedWidget {
  const TaskOpenScope({super.key, required this.open, required super.child});

  final void Function(Task task) open;

  static TaskOpenScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<TaskOpenScope>();

  @override
  bool updateShouldNotify(TaskOpenScope old) => false;
}

/// The one door to a task's detail: every list row, board card, calendar chip
/// and timeline bar opens its task through here. Phase 47 changes how
/// [TaskOpenScope.open] presents it (a modal), not the callers.
void openTask(BuildContext context, Task task) =>
    TaskOpenScope.maybeOf(context)?.open(task);
