import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/core/sync/sync_models.dart';
import 'package:taskforge/core/sync/sync_providers.dart';

/// A small dot: green while changes arrive live, amber while reconnecting.
/// Shows nothing when there is no connection to speak of.
class LiveIndicator extends ConsumerWidget {
  const LiveIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(syncStateProvider);
    final (color, label) = switch (state) {
      SyncState.live => (Colors.green, 'Live'),
      SyncState.connecting => (Colors.amber, 'Connecting…'),
      SyncState.reconnecting => (Colors.amber, 'Reconnecting…'),
      SyncState.offline => (null, ''),
    };
    if (color == null) return const SizedBox.shrink();
    return Tooltip(
      message: state == SyncState.live
          ? 'Changes by others appear as they happen'
          : 'Not live: changes by others will appear once reconnected',
      child: Row(
        key: Key('live-${state.name}'),
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 10, color: color),
          const SizedBox(width: 4),
          Text(label, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}

/// A strip across the top while the connection is down: what is on screen may
/// be behind, and it says it will catch up.
class ConnectionBanner extends ConsumerWidget {
  const ConnectionBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(syncStateProvider) != SyncState.reconnecting) {
      return const SizedBox.shrink();
    }
    return Material(
      key: const Key('reconnecting-banner'),
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          children: [
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(context.l10n.grpHReconnecting)),
          ],
        ),
      ),
    );
  }
}
