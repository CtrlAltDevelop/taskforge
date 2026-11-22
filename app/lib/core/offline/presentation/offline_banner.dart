import 'package:taskforge/core/ui/tokens/spacing.dart';
import 'package:taskforge/core/ui/tf/tf_button.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/l10n/gen/app_localizations.dart';
import 'package:taskforge/core/offline/offline_providers.dart';
import 'package:taskforge/core/offline/offline_sync.dart';
import 'package:taskforge/core/sync/sync_models.dart';
import 'package:taskforge/core/sync/sync_providers.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';
import 'package:taskforge/core/ui/tf_icons.dart';

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
        padding: const EdgeInsets.symmetric(
          horizontal: TfSpace.md,
          vertical: TfSpace.sm,
        ),
        child: Row(
          children: [
            TfIcon(online ? TfIcons.refresh : TfIcons.cloudOff),
            const SizedBox(width: TfSpace.md),
            Expanded(
              child: Text(_message(context.l10n, online, waiting, attention)),
            ),
            if (attention > 0)
              TfButton(
                key: const Key('offline-review'),
                label: context.l10n.grpHOfflineReview,
                variant: TfButtonVariant.ghost,
                onPressed: () => context.push('/offline'),
              ),
            if (waiting > 0 && online)
              TfButton(
                key: const Key('offline-sync-now'),
                label: syncing
                    ? context.l10n.grpHOfflineSyncing
                    : context.l10n.grpHOfflineSyncNow,
                variant: TfButtonVariant.ghost,
                onPressed: syncing
                    ? null
                    : () => ref.read(offlineSyncProvider.notifier).syncNow(),
              ),
          ],
        ),
      ),
    );
  }

  static String _message(
    AppLocalizations l10n,
    bool online,
    int waiting,
    int attention,
  ) {
    final parts = [
      if (!online) l10n.grpHOfflineSaved,
      if (waiting > 0)
        online
            ? l10n.grpHOfflineWaitsOnline(waiting)
            : l10n.grpHOfflineWaitsOffline(waiting),
      if (attention > 0) l10n.grpHOfflineAttention(attention),
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
      padding: const EdgeInsetsDirectional.only(end: TfSpace.sm),
      child: TfIcon(
        TfIcons.clock,
        key: Key('pending-$id'),
        semanticLabel: context.l10n.grpHWaitingToBeSent,
      ),
    );
  }
}
