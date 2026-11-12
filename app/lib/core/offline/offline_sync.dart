import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/auth/auth_providers.dart';
import 'package:taskforge/core/auth/auth_session.dart';
import 'package:taskforge/core/config.dart';
import 'package:taskforge/core/offline/keep_offline.dart';
import 'package:taskforge/core/offline/offline_providers.dart';
import 'package:taskforge/core/offline/outbox.dart';
import 'package:taskforge/core/offline/outbox_files.dart';
import 'package:taskforge/core/offline/outbox_worker.dart';
import 'package:taskforge/core/ping/rest_ping.dart';
import 'package:taskforge/features/account/account_providers.dart';
import 'package:taskforge/features/attachments/application/attachments_providers.dart';
import 'package:taskforge/features/attachments/application/uploader.dart';
import 'package:taskforge/features/comments/application/comments_providers.dart';
import 'package:taskforge/features/tasks/application/tasks_providers.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';

/// How often the outbox is tried while nothing else triggers it.
const outboxInterval = Duration(seconds: 30);

/// Asks the server whether it can be reached. Tests override it.
final reachabilityProbeProvider = Provider<Future<void> Function()>((ref) {
  final ping = RestPing(AppConfig.restUrl);
  return () async {
    await ping.ping();
  };
});

/// The sender of the outbox: it uses the real clients, not the offline ones.
final outboxWorkerProvider = Provider<OutboxWorker>(
  (ref) => OutboxWorker(
    store: () => ref.read(offlineStoreFutureProvider),
    tasks: ref.watch(rawTasksClientProvider),
    comments: ref.watch(rawCommentsClientProvider),
    workspace: () => ref.read(authSessionProvider).status == AuthStatus.signedIn
        ? ref.read(workspaceScopeProvider)
        : null,
    worked: () => ref.read(networkProvider.notifier).worked(),
    failed: () => ref.read(networkProvider.notifier).failed(),
    uploadFile: (e) => _uploadKept(ref, e),
    dropFile: (e) => _dropKept(ref, e),
  ),
);

/// How recent a file must be to count as the one an upload whose answer was
/// lost may have stored.
const _justUploaded = Duration(minutes: 10);

Future<void> _uploadKept(Ref ref, OutboxEntry e) async {
  final source = ref
      .read(outboxFilesProvider)
      .open('${e.payload['path']}', '${e.payload['name']}');
  final task = '${e.payload['taskId']}';
  final me = ref.read(accountProvider).value?.id ?? '';
  await runUpload(
    client: ref.read(uploadsClientProvider),
    source: source,
    workspaceId: e.workspaceId,
    projectId: e.projectId,
    taskId: task,
    commentId: '${e.payload['commentId'] ?? ''}',
    onProgress: (_, _) {},
    cancelled: () => false,
    // An earlier try may have finished with its answer lost.
    findUploaded: (name, size, comment) async {
      final files = await ref
          .read(attachmentsClientProvider)
          .list(e.workspaceId, e.projectId, task);
      final cutoff = DateTime.now().subtract(_justUploaded);
      return files
          .where(
            (f) =>
                f.filename == name &&
                f.size == size &&
                f.uploaderId == me &&
                f.commentId == comment &&
                f.createdAt.isAfter(cutoff),
          )
          .firstOrNull;
    },
  );
}

Future<void> _dropKept(Ref ref, OutboxEntry e) async {
  final path = e.payload['path'];
  if (path is String) await ref.read(outboxFilesProvider).remove(path);
}

/// Sends what was changed offline when the connection is back, every
/// [outboxInterval], and on "Sync now"; empties the local copy at sign-out.
/// The state is true while a pass is running. Watch it from the app's root.
final offlineSyncProvider = NotifierProvider<OfflineSync, bool>(
  OfflineSync.new,
);

class OfflineSync extends Notifier<bool> {
  Timer? _timer;

  @override
  bool build() {
    final session = ref.read(authSessionProvider);
    void onSession() {
      if (session.status == AuthStatus.signedOut) {
        unawaited(_wipe());
      } else if (session.status == AuthStatus.signedIn) {
        unawaited(_open());
      }
    }

    session.addListener(onSession);
    // Signed out already at launch (a wipe that never finished): finish it.
    if (session.status == AuthStatus.signedOut) unawaited(_wipe());
    ref.listen(networkProvider, (was, now) {
      if (now && was == false) unawaited(_back());
    });
    ref.listen(workspaceScopeProvider, (_, _) => unawaited(syncNow()));
    unawaited(_start());
    ref.onDispose(() {
      session.removeListener(onSession);
      _timer?.cancel();
    });
    return false;
  }

  /// The server can be reached again: send what waited, tell the open screens
  /// to read again (others may have changed things meanwhile; the live feed
  /// replays what it missed, this covers what it does not reach) and bring the
  /// projects kept offline up to date.
  Future<void> _back() async {
    await syncNow();
    if (!ref.mounted) return;
    ref.read(outboxDrainedProvider.notifier).bump();
    await ref.read(keepOfflineProvider.notifier).refreshKept();
  }

  Future<void> _start() async {
    // No database (the browser, or it would not open): nothing to send.
    if (await ref.read(offlineStoreFutureProvider) == null) return;
    if (!ref.mounted) return;
    unawaited(_sweepFiles());
    _timer = Timer.periodic(outboxInterval, (_) => unawaited(_tick()));
    await syncNow();
    await _trim();
  }

  /// Files whose entry is gone (a task deleted before they were sent).
  Future<void> _sweepFiles() async {
    final store = await ref.read(offlineStoreFutureProvider);
    if (store == null) return;
    try {
      final wanted = {
        for (final e in await store.everyEntry())
          if (e.entity == OutboxEntity.attachment) '${e.payload['path']}',
      };
      await ref
          .read(outboxFilesProvider)
          .sweep(wanted, grace: const Duration(hours: 1));
    } on Object {
      // No folder yet, or none on this platform: nothing to sweep.
    }
  }

  /// Keeps the local copy inside the size the person allowed.
  Future<void> _trim() async {
    final store = await ref.read(offlineStoreFutureProvider);
    if (!ref.mounted) return;
    try {
      await store?.trimToCap();
    } on StateError {
      // The database closed under it (the app is shutting down).
    }
  }

  Future<void> _tick() async {
    unawaited(_trim());
    if (ref.read(networkProvider)) {
      await syncNow();
      return;
    }
    try {
      await ref.read(reachabilityProbeProvider)();
      ref.read(networkProvider.notifier).worked(); // its listener syncs
    } on Object {
      // Still gone.
    }
  }

  /// One pass over the outbox now ("Sync now" and the triggers above).
  Future<DrainResult> syncNow() async {
    if (state) return const DrainResult();
    state = true;
    try {
      final result = await ref.read(outboxWorkerProvider).drain();
      if (ref.mounted && result.changedSomething) {
        ref.read(outboxDrainedProvider.notifier).bump();
      }
      return result;
    } finally {
      if (ref.mounted) state = false;
    }
  }

  Future<void> _open() async {
    final store = await ref.read(offlineStoreFutureProvider);
    if (store != null) store.sealed = false;
  }

  Future<void> _wipe() async {
    final store = await ref.read(offlineStoreFutureProvider);
    if (store == null) return;
    store.sealed = true; // nothing in flight may write after this
    await store.wipe();
    try {
      await ref.read(outboxFilesProvider).sweep(const {}); // the kept files too
    } on Object {
      // No folder on this platform.
    }
  }
}
