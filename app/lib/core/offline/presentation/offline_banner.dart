import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:taskforge/core/offline/offline_providers.dart';
import 'package:taskforge/core/offline/offline_sync.dart';
import 'package:taskforge/core/sync/sync_models.dart';
import 'package:taskforge/core/sync/sync_providers.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';

/// Tells the person what the app is doing with their changes: offline (they
/// are saved here), waiting to be sent, or needing a decision. Nothing
/// shows when all is sent and the connection is fine.
class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspace = ref.watch(workspaceScopeProvider);
    final online = ref.watch(networkProvider);
    final reconnecting = ref.watch(syncStateProvider) == SyncState.reconnecting;
    final counts = workspace == null
        ? null
        : ref.watch(outboxCountsProvider(workspace)).value;
    final waiting = counts?.waiting ?? 0;
    final attention = counts?.attention ?? 0;
    final showOffline = !online && !reconnecting;
    if (!showOffline && waiting == 0 && attention == 0) {
      return const SizedBox.shrink();
    }
    final colors = Theme.of(context).colorScheme;
    final syncing = ref.watch(offlineSyncProvider);
    return Material(
      key: const Key('offline-banner'),
      color: attention > 0 ? colors.errorContainer : colors.tertiaryContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          children: [
            Icon(online ? Icons.sync : Icons.cloud_off_outlined, size: 16),
            const SizedBox(width: 10),
            Expanded(child: Text(_message(online, waiting, attention))),
            if (attention > 0)
              TextButton(
                key: const Key('offline-review'),
                onPressed: () => context.push('/offline'),
                child: const Text('Review'),
              ),
            if (waiting > 0 && online)
              TextButton(
                key: const Key('offline-sync-now'),
                onPressed: syncing
                    ? null
                    : () => ref.read(offlineSyncProvider.notifier).syncNow(),
                child: Text(syncing ? 'Syncing…' : 'Sync now'),
              ),
          ],
        ),
      ),
    );
  }

  static String _message(bool online, int waiting, int attention) {
    final parts = [
      if (!online) 'You are offline. Changes are saved on this device.',
      if (waiting > 0)
        online
            ? '$waiting ${waiting == 1 ? 'change waits' : 'changes wait'} '
                  'to be sent.'
            : '$waiting waiting to be sent.',
      if (attention > 0)
        '$attention ${attention == 1 ? 'change needs' : 'changes need'} '
            'your attention.',
    ];
    return parts.join(' ');
  }
}

/// A small clock on something made or changed here that the server has not
/// seen yet.
class PendingMark extends ConsumerWidget {
  const PendingMark({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspace = ref.watch(workspaceScopeProvider);
    if (workspace == null) return const SizedBox.shrink();
    final pending = ref.watch(
      pendingIdsProvider(workspace).select((v) => v.value?.contains(id)),
    );
    if (pending != true) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: Icon(
        Icons.schedule,
        key: Key('pending-$id'),
        size: 14,
        semanticLabel: 'Waiting to be sent',
      ),
    );
  }
}
