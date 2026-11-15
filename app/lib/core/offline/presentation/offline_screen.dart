import 'package:taskforge/core/ui/content_width.dart';
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
        leading: IconButton(
          key: const Key('back-home'),
          tooltip: context.l10n.grpAOfflineBack,
          icon: const BackButtonIcon(),
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
        title: Text(context.l10n.grpAOfflineTitle),
      ),
      body: workspace == null
          ? Center(child: Text(context.l10n.grpAOfflineChooseWorkspace))
          : ContentWidth(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _Changes(workspace: workspace),
                  const SizedBox(height: 24),
                  const _Storage(),
                  const SizedBox(height: 24),
                  const _KeptProjects(),
                ],
              ),
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
        const SizedBox(height: 8),
        if (attention.isEmpty)
          Text(
            context.l10n.grpAOfflineNothingToDecide,
            key: const Key('nothing-to-decide'),
          ),
        for (final e in attention)
          _AttentionCard(key: Key('attention-${e.id}'), entry: e),
        const SizedBox(height: 24),
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
              icon: const Icon(Icons.sync),
              label: Text(context.l10n.grpASyncNow),
            ),
          ],
        ),
        if (waiting.isEmpty) Text(context.l10n.grpAOfflineNothingWaiting),
        for (final e in waiting)
          ListTile(
            key: Key('waiting-${e.id}'),
            dense: true,
            leading: const Icon(Icons.schedule),
            title: _Summary(entry: e),
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DefaultTextStyle.merge(
              style: const TextStyle(fontWeight: FontWeight.bold),
              child: _Summary(entry: entry),
            ),
            const SizedBox(height: 4),
            Text(reasonText(entry.error, context.l10n)),
            if (conflict && info.field.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                context.l10n.grpAOfflineClash(
                  info.field,
                  info.current,
                  '${entry.payload[info.field] ?? ''}',
                ),
                key: Key('clash-${entry.id}'),
              ),
            ],
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                if (conflict) ...[
                  FilledButton(
                    key: Key('keep-mine-${entry.id}'),
                    onPressed: () async {
                      await worker.keepMine(entry);
                      await sync.syncNow();
                    },
                    child: Text(context.l10n.grpAKeepMine),
                  ),
                  OutlinedButton(
                    key: Key('take-theirs-${entry.id}'),
                    onPressed: () => worker.takeTheirs(entry),
                    child: Text(context.l10n.grpATakeTheirs),
                  ),
                  if (entry.payload.length > 1)
                    OutlinedButton(
                      key: Key('merge-${entry.id}'),
                      onPressed: () => _merge(context, worker, sync),
                      child: Text(context.l10n.grpAMerge),
                    ),
                ] else ...[
                  FilledButton(
                    key: Key('retry-${entry.id}'),
                    onPressed: () async {
                      await worker.retry(entry);
                      await sync.syncNow();
                    },
                    child: Text(context.l10n.grpATryAgain),
                  ),
                  OutlinedButton(
                    key: Key('discard-${entry.id}'),
                    onPressed: () => worker.discard(entry),
                    child: Text(context.l10n.grpADiscard),
                  ),
                ],
              ],
            ),
          ],
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
  Widget build(BuildContext context) => AlertDialog(
    title: Text(context.l10n.grpAMergeTitle),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final f in widget.fields)
          CheckboxListTile(
            key: Key('merge-field-$f'),
            value: _mine.contains(f),
            title: Text(f),
            onChanged: (on) => setState(
              () =>
                  _mine = on == true ? {..._mine, f} : ({..._mine}..remove(f)),
            ),
          ),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text(context.l10n.grpACancel),
      ),
      FilledButton(
        key: const Key('merge-confirm'),
        onPressed: () => Navigator.pop(context, _mine),
        child: Text(context.l10n.grpAMerge),
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
        const SizedBox(height: 8),
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
            const SizedBox(width: 12),
            DropdownButton<int>(
              key: const Key('cache-cap'),
              value: cacheCapChoicesMb.contains(capMb) ? capMb : null,
              items: [
                for (final mb in cacheCapChoicesMb)
                  DropdownMenuItem(
                    value: mb,
                    child: Text(context.l10n.grpAMegabytes(mb)),
                  ),
              ],
              onChanged: (mb) async {
                final store = await ref.read(offlineStoreFutureProvider);
                if (mb == null || store == null) return;
                await store.setCacheCap(mb * _mb);
                await store.trimToCap();
                ref.invalidate(cacheUsageProvider);
              },
            ),
          ],
        ),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: OutlinedButton(
            key: const Key('clear-cache'),
            onPressed: workspace == null
                ? null
                : () => _clear(context, ref, workspace),
            child: Text(context.l10n.grpAClearCopy),
          ),
        ),
        const SizedBox(height: 4),
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
      builder: (ctx) => AlertDialog(
        title: Text(ctx.l10n.grpAClearTitle),
        content: Text(ctx.l10n.grpAClearBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(ctx.l10n.grpACancel),
          ),
          FilledButton(
            key: const Key('clear-cache-confirm'),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(ctx.l10n.grpAClear),
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
        const SizedBox(height: 4),
        Text(context.l10n.grpAKeepOfflineBody),
        for (final p in projects)
          Builder(
            builder: (context) {
              final working = progress[p.id];
              return SwitchListTile(
                key: Key('keep-${p.id}'),
                value:
                    kept.contains(p.id) ||
                    (working?.error == null && working != null),
                title: Text(p.name),
                subtitle: working == null
                    ? null
                    : working.error != null
                    ? Text(reasonText(working.error!, context.l10n))
                    : Text(context.l10n.grpACopying(working.fetched)),
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
