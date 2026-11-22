import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/app_router.dart';
import 'package:taskforge/core/auth/auth_providers.dart';
import 'package:taskforge/core/auth/auth_session.dart';
import 'package:taskforge/core/sync/sync_models.dart';
import 'package:taskforge/core/sync/sync_providers.dart';
import 'package:taskforge/features/account/locale_providers.dart';
import 'package:taskforge/features/inbox/application/inbox_providers.dart';
import 'package:taskforge/features/inbox/application/push.dart';
import 'package:taskforge/features/inbox/domain/inbox.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';
import 'package:taskforge/l10n/gen/app_localizations.dart';

/// How far back a notification may be and still count as "just arrived" when
/// the first live event is heard (device and server clocks differ a little).
const alertFreshness = Duration(minutes: 2);

/// Events that come in a burst are looked at once (tests make it shorter).
final alertCoalesceProvider = Provider<Duration>(
  (_) => const Duration(milliseconds: 250),
);

/// Where the person is in the app right now (tests say where).
final alertLocationProvider = Provider<Uri Function()>(
  (ref) =>
      () => ref.read(routerProvider).routeInformationProvider.value.uri,
);

/// Where tapping a system notification leads (its payload is `project|task`).
String? routeForPayload(String payload) {
  final parts = payload.split('|');
  if (parts.length != 2 || parts.any((p) => p.isEmpty)) return null;
  return '/projects/${Uri.encodeComponent(parts[0])}'
      '?task=${Uri.encodeQueryComponent(parts[1])}';
}

/// Shows the system's notification for a new inbox item that arrives while
/// the app runs, when the person asked for push for that kind and is not
/// already looking at it; registers this device for push when the session
/// starts and drops it when the session ends. Watch this once, high in the
/// tree.
final liveAlertsProvider = Provider<void>((ref) {
  final session = ref.watch(authSessionProvider);
  final registrar = ref.watch(pushRegistrarProvider);
  void onSession() {
    if (session.status == AuthStatus.signedIn) {
      unawaited(registrar.register());
    } else {
      unawaited(registrar.unregister());
    }
  }

  session.addListener(onSession);
  ref.onDispose(() => session.removeListener(onSession));
  if (session.status == AuthStatus.signedIn) unawaited(registrar.register());

  final notifier = ref.watch(localNotifierProvider);
  notifier.onOpen = (payload) {
    final route = routeForPayload(payload);
    if (route != null) ref.read(routerProvider).go(route);
  };

  final client = ref.watch(syncClientProvider);
  if (client == null) return;
  final alerts = LiveAlerts(ref);
  final sub = client.events.listen((event) {
    final own = client.ownOrigin;
    if (!event.type.startsWith('notification.')) return;
    if (own.isNotEmpty && event.origin == own) return; // this app's own doing
    alerts.heard(event);
  });
  ref.onDispose(() {
    alerts.dispose();
    unawaited(sub.cancel());
  });
});

class LiveAlerts {
  LiveAlerts(this._ref) : _started = _ref.read(inboxNowProvider)();

  final Ref _ref;
  final DateTime _started;
  final _pending = <String>{};
  Timer? _timer;

  /// How many events each notification has folded when last seen.
  final _seen = <String, int>{};

  /// Notes that [event] happened; what it was is looked at after a moment
  /// (a burst is one look per workspace).
  void heard(SyncEvent event) {
    final workspace = event.workspace.isNotEmpty
        ? event.workspace
        : _ref.read(workspaceScopeProvider);
    if (workspace == null) return;
    _pending.add(workspace);
    _timer ??= Timer(_ref.read(alertCoalesceProvider), () {
      _timer = null;
      final workspaces = {..._pending};
      _pending.clear();
      for (final w in workspaces) {
        unawaited(_check(w));
      }
    });
  }

  void dispose() => _timer?.cancel();

  Future<void> _check(String workspace) async {
    try {
      final page = await _ref
          .read(inboxClientProvider)
          .list(workspace, InboxFilter.unread, pageSize: 10);
      final prefs = await _ref.read(prefsProvider.future);
      final cutoff = _started.subtract(alertFreshness);
      final l10n = lookupAppLocalizations(
        _ref.read(localePrefsProvider).locale,
      );
      for (final n in page.notifications) {
        final known = _seen[n.id];
        _seen[n.id] = n.count;
        final fresh = known == null
            ? n.updatedAt.isAfter(cutoff)
            : n.count > known;
        if (!fresh || prefs.of(n.type)?.push != true || _looking(n)) continue;
        await _ref
            .read(localNotifierProvider)
            .show(
              id: n.id.hashCode & 0x7fffffff,
              title: n.kind.labelIn(l10n),
              body: '${n.whatIn(l10n)} ${n.subject}'.trim(),
              payload: '${n.projectId}|${n.taskId}',
            );
      }
    } on Object {
      // A missed pop-up is not worth a failure anywhere.
    }
  }

  /// Whether the person is looking at it right now (the app is in front and
  /// shows that task, or the inbox of that workspace).
  bool _looking(InboxNotification n) {
    final state = WidgetsBinding.instance.lifecycleState;
    if (state != null && state != AppLifecycleState.resumed) return false;
    final uri = _ref.read(alertLocationProvider)();
    if (n.taskId.isNotEmpty && uri.queryParameters['task'] == n.taskId) {
      return true;
    }
    return uri.path == '/inbox' &&
        n.workspaceId == _ref.read(workspaceScopeProvider);
  }
}
