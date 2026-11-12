import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/offline/local_db.dart';
import 'package:taskforge/core/offline/offline_store.dart';
import 'package:taskforge/core/offline/open_db.dart';
import 'package:taskforge/core/offline/read_cache.dart';
import 'package:taskforge/core/sync/sync_models.dart';
import 'package:taskforge/core/sync/sync_providers.dart';
import 'package:taskforge/features/account/account_providers.dart';
import 'package:taskforge/features/tasks/data/offline_tasks_client.dart';

/// The local database, or null where there is none (the browser). Tests
/// override this with an in-memory one.
final localDbProvider = Provider<LocalDb?>((ref) {
  final db = openLocalDb();
  if (db == null) return null;
  ref.onDispose(db.close);
  return db;
});

/// The store over [localDbProvider], opened once. Null when the database
/// cannot be opened (the app then works online only, as it did before).
final offlineStoreFutureProvider = Provider<Future<OfflineStore?>>((ref) async {
  final db = ref.watch(localDbProvider);
  if (db == null) return null;
  try {
    final store = OfflineStore(db);
    await store.requeueSending(); // a send cut off by the app closing
    return store;
  } on Object catch (e) {
    debugPrint('Offline storage unavailable: $e');
    return null;
  }
});

/// Whether the server looks reachable. A call that cannot reach it flips this
/// to false (later calls are answered from the local copy at once); a call
/// that is answered, the live feed coming back, or the probe flips it back.
final networkProvider = NotifierProvider<NetworkMonitor, bool>(
  NetworkMonitor.new,
);

class NetworkMonitor extends Notifier<bool> {
  @override
  bool build() {
    ref.listen(syncStateProvider, (_, next) {
      if (next == SyncState.live) state = true;
      if (next == SyncState.reconnecting) state = false;
    });
    return true;
  }

  void failed() => state = false;

  void worked() => state = true;
}

/// A random (version 4) UUID in the form the server writes ids, so the id a
/// client chose and the one it gets back are the same string.
String newClientId() {
  final random = Random.secure();
  final b = List.generate(16, (_) => random.nextInt(256));
  b[6] = (b[6] & 0x0f) | 0x40;
  b[8] = (b[8] & 0x3f) | 0x80;
  final h = [for (final v in b) v.toRadixString(16).padLeft(2, '0')];
  return '${h.sublist(0, 4).join()}-${h.sublist(4, 6).join()}-'
      '${h.sublist(6, 8).join()}-${h.sublist(8, 10).join()}-'
      '${h.sublist(10).join()}';
}

/// What the offline decorators need from the app around them.
final offlineEnvProvider = Provider<OfflineEnv>(
  (ref) => OfflineEnv(
    store: () => ref.read(offlineStoreFutureProvider),
    online: () => ref.read(networkProvider),
    failed: () => ref.read(networkProvider.notifier).failed(),
    worked: () => ref.read(networkProvider.notifier).worked(),
    newId: newClientId,
    now: DateTime.now,
    me: () => ref.read(accountProvider).value?.id ?? '',
  ),
);

/// The last answers of the catalog reads, for when the server is gone.
final readCacheProvider = Provider<ReadCache>((ref) {
  final env = ref.watch(offlineEnvProvider);
  return ReadCache(
    store: env.store,
    online: env.online,
    failed: env.failed,
    worked: env.worked,
  );
});

/// Counts the passes of the outbox that changed something, so lists read
/// again what the server now says.
final outboxDrainedProvider = NotifierProvider<OutboxDrained, int>(
  OutboxDrained.new,
);

class OutboxDrained extends Notifier<int> {
  @override
  int build() => 0;

  void bump() => state++;
}

/// How many changes wait to be sent and how many need a decision (for the
/// banner and the badge).
final outboxCountsProvider =
    StreamProvider.family<({int waiting, int attention}), String>((
      ref,
      workspaceId,
    ) async* {
      final store = await ref.watch(offlineStoreFutureProvider);
      if (store == null) {
        yield (waiting: 0, attention: 0);
        return;
      }
      yield* store.watchCounts(workspaceId);
    });

/// The ids of the things made or changed here and not yet sent.
final pendingIdsProvider = StreamProvider.family<Set<String>, String>((
  ref,
  workspaceId,
) async* {
  final store = await ref.watch(offlineStoreFutureProvider);
  if (store == null) {
    yield const {};
    return;
  }
  yield* store.watchPendingIds(workspaceId);
});
