import 'package:taskforge/core/ui/page/tf_page.dart';
import 'package:taskforge/core/ui/page/tf_tile.dart';
import 'package:taskforge/core/ui/tokens/spacing.dart';
import 'package:taskforge/core/ui/page/tf_select_field.dart';
import 'package:taskforge/core/ui/page/tf_dialog_frame.dart';
import 'package:taskforge/core/ui/tf_icons.dart';
import 'package:taskforge/core/ui/tf/tf_panel.dart';
import 'package:taskforge/core/ui/tf/tf_checkbox.dart';
import 'package:taskforge/core/ui/tf/tf_button.dart';
import 'package:taskforge/core/ui/tf_app_bar.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:taskforge/core/i18n/context_dates.dart';
import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/core/offline/codecs.dart';
import 'package:taskforge/core/offline/keep_offline.dart';
import 'package:taskforge/core/offline/offline_providers.dart';
import 'package:taskforge/core/offline/offline_reason.dart';
import 'package:taskforge/core/offline/offline_store.dart';
import 'package:taskforge/core/offline/offline_sync.dart';
import 'package:taskforge/core/offline/outbox.dart';
import 'package:taskforge/core/offline/outbox_worker.dart';
import 'package:taskforge/features/projects/application/projects_providers.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';
import 'package:taskforge/l10n/gen/app_localizations.dart';

/// The cache sizes to choose from, in megabytes.
const cacheCapChoicesMb = [25, 50, 100, 250, 500];

const _mb = 1024 * 1024;

/// The queue of the workspace, again each time it changes.
final outboxQueueProvider = StreamProvider.autoDispose
    .family<List<OutboxEntry>, String>((ref, workspaceId) async* {
      final store = await ref.watch(offlineStoreFutureProvider);
      if (store == null) {
        yield const [];
        return;
      }
      yield* store.watchQueue(workspaceId);
    });

/// The title of a task as the local copy has it ('' when unknown).
final cachedTaskTitleProvider = FutureProvider.autoDispose
    .family<String, ({String workspace, String task})>((ref, key) async {
      final store = await ref.watch(offlineStoreFutureProvider);
      final json = await store?.get(key.workspace, Kinds.task, key.task);
      return json == null ? '' : taskFromJson(json).title;
    });

/// How much the local copy holds and the most it may.
final cacheUsageProvider = FutureProvider.autoDispose<({int size, int cap})>((
  ref,
) async {
  final store = await ref.watch(offlineStoreFutureProvider);
  if (store == null) return (size: 0, cap: defaultCacheBytes);
  return (size: await store.sizeBytes(), cap: await store.cacheCap());
});

/// What changes were made offline and what became of them, and the local
/// copy's size and the projects kept for offline use.
class OfflineScreen extends ConsumerWidget {
  const OfflineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspace = ref.watch(workspaceScopeProvider);
    return Scaffold(
      appBar: TfAppBar(
        leading: TfIconButton(
          key: const Key('back-home'),
          icon: TfIcons.arrowStart,
          tooltip: context.l10n.grpAOfflineBack,
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
        title: Text(context.l10n.grpAOfflineTitle),
      ),
      body: workspace == null
          ? Center(child: Text(context.l10n.grpAOfflineChooseWorkspace))
          : TfPage(
              children: [
                _Changes(workspace: workspace),
                const SizedBox(height: TfSpace.xl),
                const _Storage(),
                const SizedBox(height: TfSpace.xl),
                const _KeptProjects(),
              ],
            ),
    );
  }
}

class _Changes extends ConsumerWidget {
  const _Changes({required this.workspace});

  final String workspace;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queue = ref.watch(outboxQueueProvider(workspace)).value ?? const [];
    final attention = [
      for (final e in queue)
        if (e.state.needsAttention) e,
    ];
    final waiting = [
      for (final e in queue)
        if (!e.state.needsAttention) e,
    ];
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.grpAOfflineNeedsAttention,
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: TfSpace.sm),
        if (attention.isEmpty)
          Text(
            context.l10n.grpAOfflineNothingToDecide,
            key: const Key('nothing-to-decide'),
          ),
        for (final e in attention)
          _AttentionCard(key: Key('attention-${e.id}'), entry: e),
        const SizedBox(height: TfSpace.xl),
        Row(
          children: [
            Expanded(
              child: Text(
                context.l10n.grpAOfflineWaiting(waiting.length),
                style: theme.textTheme.titleMedium,
              ),
            ),
            TextButton.icon(
              key: const Key('sync-now'),
              onPressed: () => ref.read(offlineSyncProvider.notifier).syncNow(),
              icon: const TfIcon(TfIcons.refresh),
              label: Text(context.l10n.grpASyncNow),
            ),
          ],
        ),
        if (waiting.isEmpty) Text(context.l10n.grpAOfflineNothingWaiting),
        for (final e in waiting)
          TfTile(
            key: Key('waiting-${e.id}'),
            title: _Summary(entry: e),
            leading: const TfIcon(TfIcons.clock),
          ),
      ],
    );
  }
}

/// One line saying what the change is.
class _Summary extends ConsumerWidget {
  const _Summary({required this.entry});

  final OutboxEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final task = switch (entry.entity) {
      OutboxEntity.task => entry.entityId,
      OutboxEntity.chat => '',
      _ => '${entry.payload['taskId']}',
    };
    final title =
        ref
            .watch(
              cachedTaskTitleProvider((
                workspace: entry.workspaceId,
                task: task,
              )),
            )
            .value ??
        '';
    return Text(describeEntry(entry, title, context.l10n));
  }
}

/// What [entry] does, for a list: "Edit “Fix login”: title, dueDate".
String describeEntry(
  OutboxEntry entry,
  String taskTitle, [
  AppLocalizations? l10n,
]) {
  final l = l10n ?? lookupAppLocalizations(const Locale('en'));
  final name = taskTitle.isEmpty ? l.grpAEntryATask : '“$taskTitle”';
  return switch ((entry.entity, entry.op)) {
    (OutboxEntity.task, OutboxOp.create) => l.grpAEntryNewTask(
      '${entry.payload['title'] ?? ''}',
    ),
    (OutboxEntity.task, OutboxOp.update) => l.grpAEntryEdit(
      name,
      entry.payload.keys.join(', '),
    ),
    (OutboxEntity.task, OutboxOp.delete) => l.grpAEntryDelete(name),
    (OutboxEntity.comment, _) => l.grpAEntryComment(name),
    (OutboxEntity.chat, _) => l.chatEntryMessage(
      '${entry.payload['spaceName'] ?? ''}',
    ),
    (OutboxEntity.attachment, _) => l.grpAEntryUpload(
      '${entry.payload['name'] ?? ''}',
      name,
    ),
  };
}

class _AttentionCard extends ConsumerWidget {
  const _AttentionCard({super.key, required this.entry});

  final OutboxEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final worker = ref.read(outboxWorkerProvider);
    final sync = ref.read(offlineSyncProvider.notifier);
    final conflict = entry.state == OutboxState.conflict;
    final info = ConflictInfo.parse(entry.theirs);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: TfSpace.xs),
      child: TfPanel(
        padding: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(TfSpace.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DefaultTextStyle.merge(
                style: const TextStyle(fontWeight: FontWeight.bold),
                child: _Summary(entry: entry),
              ),
              const SizedBox(height: TfSpace.xs),
              Text(reasonText(entry.error, context.l10n)),
              if (conflict && info.field.isNotEmpty) ...[
                const SizedBox(height: TfSpace.xs),
                Text(
                  context.l10n.grpAOfflineClash(
                    info.field,
                    info.current,
                    '${entry.payload[info.field] ?? ''}',
                  ),
                  key: Key('clash-${entry.id}'),
                ),
              ],
              const SizedBox(height: TfSpace.sm),
              Wrap(
                spacing: 8,
                children: [
                  if (conflict) ...[
                    TfButton(
                      key: Key('keep-mine-${entry.id}'),
                      label: context.l10n.grpAKeepMine,
                      variant: TfButtonVariant.primary,
                      onPressed: () async {
                        await worker.keepMine(entry);
                        await sync.syncNow();
                      },
                    ),
                    TfButton(
                      key: Key('take-theirs-${entry.id}'),
                      label: context.l10n.grpATakeTheirs,
                      onPressed: () => worker.takeTheirs(entry),
                    ),
                    if (entry.payload.length > 1)
                      TfButton(
                        key: Key('merge-${entry.id}'),
                        label: context.l10n.grpAMerge,
                        onPressed: () => _merge(context, worker, sync),
                      ),
                  ] else ...[
                    TfButton(
                      key: Key('retry-${entry.id}'),
                      label: context.l10n.grpATryAgain,
                      variant: TfButtonVariant.primary,
                      onPressed: () async {
                        await worker.retry(entry);
                        await sync.syncNow();
                      },
                    ),
                    TfButton(
                      key: Key('discard-${entry.id}'),
                      label: context.l10n.grpADiscard,
                      onPressed: () => worker.discard(entry),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _merge(
    BuildContext context,
    OutboxWorker worker,
    OfflineSync sync,
  ) async {
    final chosen = await showDialog<Set<String>>(
      context: context,
      builder: (_) => _MergeDialog(fields: entry.payload.keys.toList()),
    );
    if (chosen == null) return;
    await worker.merge(entry, chosen);
    await sync.syncNow();
  }
}

class _MergeDialog extends StatefulWidget {
  const _MergeDialog({required this.fields});

  final List<String> fields;

  @override
  State<_MergeDialog> createState() => _MergeDialogState();
}

class _MergeDialogState extends State<_MergeDialog> {
  late var _mine = {...widget.fields};

  @override
  Widget build(BuildContext context) => TfDialogFrame(
    title: context.l10n.grpAMergeTitle,
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final f in widget.fields)
          TfCheckbox(
            key: Key('merge-field-$f'),
            value: _mine.contains(f),
            onChanged: (on) => setState(
              () =>
                  _mine = on == true ? {..._mine, f} : ({..._mine}..remove(f)),
            ),
            label: f,
          ),
      ],
    ),
    actions: [
      TfButton(
        label: context.l10n.grpACancel,
        variant: TfButtonVariant.ghost,
        onPressed: () => Navigator.pop(context),
      ),
      TfButton(
        key: const Key('merge-confirm'),
        label: context.l10n.grpAMerge,
        variant: TfButtonVariant.primary,
        onPressed: () => Navigator.pop(context, _mine),
      ),
    ],
  );
}

class _Storage extends ConsumerWidget {
  const _Storage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usage = ref.watch(cacheUsageProvider).value;
    final workspace = ref.watch(workspaceScopeProvider);
    final capMb = usage == null ? null : usage.cap ~/ _mb;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.grpAStorage,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: TfSpace.sm),
        Text(
          usage == null
              ? context.l10n.grpAReading
              : context.l10n.grpAStorageUsage(
                  context.localDigits((usage.size / _mb).toStringAsFixed(1)),
                  capMb!,
                ),
          key: const Key('cache-usage'),
        ),
        Row(
          children: [
            Expanded(child: Text(context.l10n.grpAMostItMayHold)),
            const SizedBox(width: TfSpace.md),
            TfSelectField(
              key: const Key('cache-cap'),
              options: {
                for (final mb in cacheCapChoicesMb)
                  mb: context.l10n.grpAMegabytes(mb),
              },
              value: cacheCapChoicesMb.contains(capMb) ? capMb : null,
              onChanged: (mb) async {
                final store = await ref.read(offlineStoreFutureProvider);
                if (store == null) return;
                await store.setCacheCap(mb * _mb);
                await store.trimToCap();
                ref.invalidate(cacheUsageProvider);
              },
            ),
          ],
        ),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: TfButton(
            key: const Key('clear-cache'),
            label: context.l10n.grpAClearCopy,
            onPressed: workspace == null
                ? null
                : () => _clear(context, ref, workspace),
          ),
        ),
        const SizedBox(height: TfSpace.xs),
        Text(
          context.l10n.grpAStorageNote,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Future<void> _clear(
    BuildContext context,
    WidgetRef ref,
    String workspace,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => TfDialogFrame(
        title: ctx.l10n.grpAClearTitle,
        content: Text(ctx.l10n.grpAClearBody),
        actions: [
          TfButton(
            label: ctx.l10n.grpACancel,
            variant: TfButtonVariant.ghost,
            onPressed: () => Navigator.pop(ctx, false),
          ),
          TfButton(
            key: const Key('clear-cache-confirm'),
            label: ctx.l10n.grpAClear,
            variant: TfButtonVariant.primary,
            onPressed: () => Navigator.pop(ctx, true),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final store = await ref.read(offlineStoreFutureProvider);
    await store?.clearCache(workspaceId: workspace);
    await store?.setKeptProjects(workspace, const {});
    ref.invalidate(cacheUsageProvider);
    ref.invalidate(keptProjectsProvider);
  }
}

class _KeptProjects extends ConsumerWidget {
  const _KeptProjects();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projects =
        ref.watch(projectsProvider(false)).value?.projects ?? const [];
    final kept = ref.watch(keptProjectsProvider).value ?? const <String>{};
    final progress = ref.watch(keepOfflineProvider);
    final keeper = ref.read(keepOfflineProvider.notifier);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.grpAKeepOfflineTitle,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: TfSpace.xs),
        Text(context.l10n.grpAKeepOfflineBody),
        for (final p in projects)
          Builder(
            builder: (context) {
              final working = progress[p.id];
              return TfToggleTile(
                key: Key('keep-${p.id}'),
                value:
                    kept.contains(p.id) ||
                    (working?.error == null && working != null),
                title: p.name,
                subtitle: working == null
                    ? null
                    : working.error != null
                    ? reasonText(working.error!, context.l10n)
                    : context.l10n.grpACopying(working.fetched),
                onChanged: working != null && working.error == null
                    ? null
                    : (on) => on ? keeper.keep(p.id) : keeper.forget(p.id),
              );
            },
          ),
      ],
    );
  }
}
