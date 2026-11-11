import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/features/inbox/application/push.dart'
    show localNotifierProvider;
import 'package:taskforge/features/time/application/time_providers.dart';

/// The id of the one notification the timer keeps.
const timerNotificationId = 7021;

/// While a timer runs, the system shows a notification that stays (Android
/// even counts the time); it goes when the timer stops. Watch it once, high
/// in the tree.
final timerNotificationProvider = Provider<void>((ref) {
  final notifier = ref.watch(localNotifierProvider);
  // Show and cancel run one after the other, so a quick start-then-stop cannot
  // leave the notification behind.
  var queue = Future<void>.value();
  void later(Future<void> Function() job) => queue = queue.then((_) => job());
  ref.listen(currentTimerProvider, (_, next) {
    final state = next.value;
    if (state == null || next.hasError) return; // unknown: leave it as it is
    final entry = state.entry;
    if (entry == null) {
      later(() => notifier.cancel(timerNotificationId));
      return;
    }
    // The chronometer counts from when the timer started by the server's
    // figure, not by this device's idea of the date.
    final since = state.receivedAt.subtract(
      Duration(seconds: entry.durationSec),
    );
    later(
      () => notifier.showOngoing(
        id: timerNotificationId,
        title: 'Timer running',
        body: '${entry.key} ${entry.title}',
        since: since,
        payload: '${entry.projectId}|${entry.taskId}',
      ),
    );
  }, fireImmediately: true);
});
