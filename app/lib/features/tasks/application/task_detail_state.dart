import 'dart:ui' show VoidCallback;

import 'package:flutter/widgets.dart' show Route;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/features/shortcuts/application/local_prefs.dart';

/// How a task opens: a centred window, a panel at the side, or a page of its
/// own. A phone always gets the page whatever is chosen.
enum TaskPresentationKind {
  modal,
  peek,
  page;

  static TaskPresentationKind parse(String? wire) =>
      values.where((k) => k.name == wire).firstOrNull ?? modal;
}

/// The presentation this person chose, remembered on this device.
final taskPresentationProvider =
    NotifierProvider<TaskPresentationNotifier, TaskPresentationKind>(
      TaskPresentationNotifier.new,
    );

class TaskPresentationNotifier extends Notifier<TaskPresentationKind> {
  static const _key = 'task.presentation';

  @override
  TaskPresentationKind build() {
    ref.read(localPrefsProvider).read(_key).then((saved) {
      if (ref.mounted && saved != null) {
        state = TaskPresentationKind.parse(saved);
      }
    });
    return TaskPresentationKind.modal;
  }

  void choose(TaskPresentationKind kind) {
    state = kind;
    ref.read(localPrefsProvider).write(_key, kind.name);
  }
}

/// The width of the side peek, resizable and remembered.
const peekMinWidth = 380.0;
const peekMaxWidth = 720.0;
const peekDefaultWidth = 460.0;

final peekWidthProvider = NotifierProvider<PeekWidthNotifier, double>(
  PeekWidthNotifier.new,
);

class PeekWidthNotifier extends Notifier<double> {
  static const _key = 'task.peekWidth';

  @override
  double build() {
    ref.read(localPrefsProvider).read(_key).then((saved) {
      final width = double.tryParse(saved ?? '');
      if (ref.mounted && width != null) state = _clamp(width);
    });
    return peekDefaultWidth;
  }

  static double _clamp(double v) => v.clamp(peekMinWidth, peekMaxWidth);

  void resize(double width) => state = _clamp(width);

  /// Remembered once the drag ends, not on every pixel.
  void remember() =>
      ref.read(localPrefsProvider).write(_key, state.toStringAsFixed(0));
}

/// Descriptions typed but not yet saved, by task id. A draft survives closing
/// the task or moving to the next one, and goes when it is saved.
final taskDraftsProvider =
    NotifierProvider<TaskDraftsNotifier, Map<String, String>>(
      TaskDraftsNotifier.new,
    );

class TaskDraftsNotifier extends Notifier<Map<String, String>> {
  @override
  Map<String, String> build() => const {};

  void keep(String taskId, String text) => state = {...state, taskId: text};

  void drop(String taskId) {
    if (!state.containsKey(taskId)) return;
    state = {
      for (final e in state.entries)
        if (e.key != taskId) e.key: e.value,
    };
  }
}

/// Which tab of the open task is showing (kept while moving between tasks).
final taskTabProvider = NotifierProvider<TaskTabNotifier, int>(
  TaskTabNotifier.new,
);

class TaskTabNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void pick(int index) => state = index;
}

/// What the open task's window can be told to do from the action registry
/// (Esc, `[`, `]`, Cmd+Enter). The window and the composer fill it in while
/// they are on screen; it is a handle, not state anyone watches.
class TaskCommands {
  /// The route the task is shown in: shortcuts work only while it is on top.
  Route<dynamic>? route;
  VoidCallback? close;
  VoidCallback? previous;
  VoidCallback? next;
  VoidCallback? send;

  bool get onTop => route?.isCurrent ?? false;

  void clearPresentation(Route<dynamic>? owner) {
    if (route != owner) return;
    route = null;
    close = null;
    previous = null;
    next = null;
  }
}

final taskCommandsProvider = Provider<TaskCommands>((_) => TaskCommands());
