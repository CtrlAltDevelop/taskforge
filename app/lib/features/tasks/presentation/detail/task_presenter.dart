import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/scheduler.dart';

import 'package:taskforge/features/tasks/application/task_detail_state.dart';

/// Builds what a route shows for the task in [current].
typedef TaskRouteBuilder = Widget Function(
  BuildContext context,
  ValueListenable<String?> current,
  TaskPresentationKind kind,
);

/// Puts a task on screen as a window or a page and keeps it there while the
/// person moves between tasks. One route at a time: opening another task just
/// changes [current] (no second animation); a new kind replaces the route
/// without animating; closing by any means (Esc, the barrier, the back
/// button) ends in [onClosed].
class TaskPresenter {
  TaskPresenter({
    required this.navigator,
    required this.builder,
    required this.onClosed,
    required this.barrierColor,
    required this.barrierLabel,
  });

  final NavigatorState Function() navigator;
  final TaskRouteBuilder builder;
  final VoidCallback onClosed;
  final Color Function() barrierColor;
  final String Function() barrierLabel;

  /// The task shown; null when nothing is.
  final current = ValueNotifier<String?>(null);

  Route<void>? _route;
  TaskPresentationKind? _kind;

  bool get isShowing => _route != null;

  /// Shows [id] as [kind]. With a route of that kind already up it only
  /// changes the task.
  void show(String id, TaskPresentationKind kind, {bool animate = true}) {
    current.value = id;
    if (_route != null && _kind == kind) return;
    final hadRoute = _route != null;
    _dismiss();
    _push(kind, animate: animate && !hadRoute);
  }

  void _push(TaskPresentationKind kind, {required bool animate}) {
    final nav = navigator();
    final duration = animate
        ? const Duration(milliseconds: 160)
        : Duration.zero;
    Widget page(BuildContext context) => builder(context, current, kind);
    final Route<void> route = switch (kind) {
      TaskPresentationKind.page => PageRouteBuilder<void>(
        settings: const RouteSettings(name: 'task'),
        transitionDuration: duration,
        reverseTransitionDuration: duration,
        pageBuilder: (context, _, _) => page(context),
        transitionsBuilder: (context, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
      _ => RawDialogRoute<void>(
        settings: const RouteSettings(name: 'task'),
        barrierDismissible: true,
        barrierColor: barrierColor(),
        barrierLabel: barrierLabel(),
        transitionDuration: duration,
        pageBuilder: (context, _, _) => page(context),
        transitionBuilder: (context, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    };
    _route = route;
    _kind = kind;
    nav.push<void>(route).then((_) {
      if (!identical(_route, route)) return; // replaced, not closed
      _route = null;
      _kind = null;
      current.value = null;
      onClosed();
    });
  }

  /// Takes the route down without it counting as a close (another is about
  /// to go up, or the owner shows the task inline).
  void _dismiss() {
    final route = _route;
    if (route == null) return;
    _route = null;
    _kind = null;
    if (route.isActive) route.navigator?.removeRoute(route);
  }

  /// Closes the task: the route if there is one (its completion tells the
  /// owner), else just clears it (a side panel is not a route).
  void close() {
    final route = _route;
    if (route == null) {
      if (current.value != null) {
        current.value = null;
        onClosed();
      }
      return;
    }
    current.value = null;
    if (route.isCurrent) {
      route.navigator?.pop();
    } else {
      _route = null;
      _kind = null;
      route.navigator?.removeRoute(route);
      onClosed();
    }
  }

  /// Switches to the side panel (not a route): drops any route quietly.
  void showInline(String id) {
    current.value = id;
    _dismiss();
  }

  /// The owner is going away: take the route down after this frame (it may
  /// be mid-build) without telling anyone.
  void dispose() {
    final route = _route;
    _route = null;
    _kind = null;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (route != null && route.isActive) route.navigator?.removeRoute(route);
      current.dispose();
    });
  }
}
