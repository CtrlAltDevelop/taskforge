import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/core/sync/sync_models.dart';
import 'package:taskforge/core/sync/sync_providers.dart';
import 'package:taskforge/core/ui/tf_icons.dart';

/// A small dot: green while changes arrive live, amber while reconnecting.
/// Shows nothing when there is no connection to speak of.
class LiveIndicator extends ConsumerWidget {
  const LiveIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(syncStateProvider);
    final (color, label) = switch (state) {
      SyncState.live => (Colors.green, context.l10n.grp1SyncLive),
      SyncState.connecting => (Colors.amber, context.l10n.grp1SyncConnecting),
      SyncState.reconnecting => (
        Colors.amber,
        context.l10n.grp1SyncReconnecting,
      ),
      SyncState.offline => (null, ''),
    };
    if (color == null) return const SizedBox.shrink();
    return Tooltip(
      message: state == SyncState.live
          ? context.l10n.grp1SyncLiveTip
          : context.l10n.grp1SyncNotLiveTip,
      child: Row(
        key: Key('live-${state.name}'),
        mainAxisSize: MainAxisSize.min,
        children: [
          TfIcon(TfIcons.circle, size: 10, color: color),
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
