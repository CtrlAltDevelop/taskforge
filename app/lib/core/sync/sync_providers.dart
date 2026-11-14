import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/auth/auth_providers.dart';
import 'package:taskforge/core/auth/dpop/dpop_manager.dart';
import 'package:taskforge/core/config.dart';
import 'package:taskforge/core/grpc/grpc_providers.dart';
import 'package:taskforge/core/sync/catch_up_client.dart';
import 'package:taskforge/core/sync/client_id.dart';
import 'package:taskforge/core/sync/sync_client.dart';
import 'package:taskforge/core/sync/sync_models.dart';
import 'package:taskforge/core/sync/sync_transport.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';

final syncConnectorProvider = Provider<SocketConnector>(
  (ref) => const WebSocketConnector(),
);

final catchUpClientProvider = Provider<CatchUpClient>(
  (ref) => GrpcCatchUpClient(
    ref.watch(grpcChannelProvider),
    ref.watch(authSessionProvider),
  ),
);

/// The live connection of the current workspace (null when none is chosen).
/// A change of workspace closes it and opens another: cursors are per
/// workspace.
final syncClientProvider = Provider<SyncClient?>((ref) {
  final workspace = ref.watch(workspaceScopeProvider);
  if (workspace == null) return null;
  final catchUps = ref.watch(catchUpClientProvider);
  final client = SyncClient(
    connector: ref.watch(syncConnectorProvider),
    url: Uri.parse(AppConfig.syncUrl),
    token: ref.watch(authSessionProvider).accessToken,
    refreshToken: ref.watch(authSessionProvider).forceRefresh,
    socketProof: DpopManager.shared.socketProof,
    onProofRefused: DpopManager.shared.learnFromFrame,
    clientId: appClientId,
    head: () => catchUps.head(workspace),
    catchUp: (cursor) => catchUps.since(workspace, cursor),
  )..subscribe(workspaceRoom(workspace));
  client.start();
  ref.onDispose(() => unawaited(client.dispose()));
  return client;
});

/// Whether the picture on screen is live, for the indicator and the banner.
final syncStateProvider = NotifierProvider<SyncStateNotifier, SyncState>(
  SyncStateNotifier.new,
);

class SyncStateNotifier extends Notifier<SyncState> {
  @override
  SyncState build() {
    final client = ref.watch(syncClientProvider);
    if (client == null) return SyncState.offline;
    void follow() => state = client.state.value;
    client.state.addListener(follow);
    ref.onDispose(() => client.state.removeListener(follow));
    return client.state.value;
  }
}

/// Keeps this client in a project's room for as long as something watches it
/// (the project screen), so its changes arrive live.
final liveProjectProvider = Provider.autoDispose.family<void, String>((
  ref,
  projectId,
) {
  final client = ref.watch(syncClientProvider);
  if (client == null) return;
  final room = projectRoom(projectId);
  client.subscribe(room);
  ref.onDispose(() => client.unsubscribe(room));
});

/// Ids of the tasks somebody else changed a moment ago, for the brief flash.
final recentChangesProvider = NotifierProvider<RecentChanges, Set<String>>(
  RecentChanges.new,
);

class RecentChanges extends Notifier<Set<String>> {
  static const flashFor = Duration(milliseconds: 1600);

  final _timers = <Timer>[];

  @override
  Set<String> build() {
    ref.onDispose(() {
      for (final t in _timers) {
        t.cancel();
      }
    });
    return const {};
  }

  void flash(Iterable<String> ids) {
    final fresh = ids.toSet();
    if (fresh.isEmpty) return;
    state = {...state, ...fresh};
    late final Timer timer;
    timer = Timer(flashFor, () {
      _timers.remove(timer);
      if (!ref.mounted) return;
      state = {...state}..removeAll(fresh);
    });
    _timers.add(timer);
  }
}

// ------------------------------------------------------------------ presence

/// Who is on each task right now, as the server last said.
final presenceProvider =
    NotifierProvider<PresenceBoard, Map<String, List<PresenceUser>>>(
      PresenceBoard.new,
    );

class PresenceBoard extends Notifier<Map<String, List<PresenceUser>>> {
  @override
  Map<String, List<PresenceUser>> build() {
    final client = ref.watch(syncClientProvider);
    if (client == null) return const {};
    final sub = client.presence.listen((update) {
      state = {...state, update.task: List.unmodifiable(update.users)};
    });
    // After a reconnect the server answers the next heartbeat with the real roster; what was
    // known before the drop may be out of date (somebody left while this was away).
    void clearWhenNotLive() {
      if (client.state.value != SyncState.live && state.isNotEmpty) {
        state = const {};
      }
    }

    client.state.addListener(clearWhenNotLive);
    ref.onDispose(() {
      client.state.removeListener(clearWhenNotLive);
      unawaited(sub.cancel());
    });
    return const {};
  }
}

/// The other people on [taskId] (this person left out).
final otherViewersProvider = Provider.autoDispose
    .family<List<PresenceUser>, String>((ref, taskId) {
      final me = ref.watch(syncClientProvider)?.userId ?? '';
      final all = ref.watch(presenceProvider.select((m) => m[taskId]));
      return [
        for (final u in all ?? const <PresenceUser>[])
          if (u.id != me) u,
      ];
    });

/// Tells the others this person is on a task (and typing in it), renewing it
/// every [heartbeat] so it lapses by itself if the app goes away.
final presenceReporterProvider = Provider.autoDispose<PresenceReporter>((ref) {
  final reporter = PresenceReporter(ref.watch(syncClientProvider));
  ref.onDispose(reporter.dispose);
  return reporter;
});

class PresenceReporter {
  PresenceReporter(this._client) {
    _client?.state.addListener(_resendWhenLive);
  }

  static const heartbeat = Duration(seconds: 20);

  final SyncClient? _client;
  String? _project;
  String? _task;
  var _editing = false;
  Timer? _timer;

  void enter(String project, String task) {
    if (_task == task && _project == project) return;
    leave();
    _project = project;
    _task = task;
    _editing = false;
    if (_client == null) return; // nobody to tell: no heartbeat either
    _report();
    _timer = Timer.periodic(heartbeat, (_) => _report());
  }

  void setEditing(bool editing) {
    if (_task == null || _editing == editing) return;
    _editing = editing;
    _report();
  }

  void dispose() {
    leave();
    _client?.state.removeListener(_resendWhenLive);
  }

  void leave() {
    _timer?.cancel();
    _timer = null;
    final project = _project;
    final task = _task;
    _project = _task = null;
    _editing = false;
    if (project != null && task != null) {
      _client?.sendPresence(project, task, 'left');
    }
  }

  void _report() {
    final project = _project;
    final task = _task;
    if (project == null || task == null) return;
    _client?.sendPresence(project, task, _editing ? 'editing' : 'viewing');
  }

  void _resendWhenLive() {
    if (_client?.state.value == SyncState.live) _report();
  }
}
