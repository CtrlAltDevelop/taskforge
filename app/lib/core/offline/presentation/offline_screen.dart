import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:taskforge/core/offline/codecs.dart';
import 'package:taskforge/core/offline/keep_offline.dart';
import 'package:taskforge/core/offline/offline_providers.dart';
import 'package:taskforge/core/offline/offline_store.dart';
import 'package:taskforge/core/offline/offline_sync.dart';
import 'package:taskforge/core/offline/outbox.dart';
import 'package:taskforge/core/offline/outbox_worker.dart';
import 'package:taskforge/features/projects/application/projects_providers.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';

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
      appBar: AppBar(
        leading: IconButton(
          key: const Key('back-home'),
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
        title: const Text('Offline and storage'),
      ),
      body: workspace == null
          ? const Center(child: Text('Choose a workspace first.'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _Changes(workspace: workspace),
                const SizedBox(height: 24),
                const _Storage(),
                const SizedBox(height: 24),
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
        Text('Needs your attention', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        if (attention.isEmpty)
          const Text(
            'Nothing. Every change made offline was sent.',
            key: Key('nothing-to-decide'),
          ),
        for (final e in attention)
          _AttentionCard(key: Key('attention-${e.id}'), entry: e),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: Text(
                'Waiting to be sent (${waiting.length})',
                style: theme.textTheme.titleMedium,
              ),
            ),
            TextButton.icon(
              key: const Key('sync-now'),
              onPressed: () => ref.read(offlineSyncProvider.notifier).syncNow(),
              icon: const Icon(Icons.sync),
              label: const Text('Sync now'),
            ),
          ],
        ),
        if (waiting.isEmpty) const Text('Nothing is waiting.'),
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
    final task = entry.entity == OutboxEntity.task
        ? entry.entityId
        : '${entry.payload['taskId']}';
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
    return Text(describeEntry(entry, title));
  }
}

/// What [entry] does, for a list: "Edit “Fix login”: title, dueDate".
String describeEntry(OutboxEntry entry, String taskTitle) {
  final name = taskTitle.isEmpty ? 'a task' : '“$taskTitle”';
  return switch ((entry.entity, entry.op)) {
    (OutboxEntity.task, OutboxOp.create) =>
      'New task “${entry.payload['title'] ?? ''}”',
    (OutboxEntity.task, OutboxOp.update) =>
      'Edit $name: ${entry.payload.keys.join(', ')}',
    (OutboxEntity.task, OutboxOp.delete) => 'Delete $name',
    (OutboxEntity.comment, _) => 'Comment on $name',
    (OutboxEntity.attachment, _) =>
      'Upload “${entry.payload['name'] ?? ''}” to $name',
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
            Text(entry.error),
            if (conflict && info.field.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Theirs (${info.field}): ${info.current}\n'
                'Yours: ${entry.payload[info.field] ?? ''}',
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
                    child: const Text('Keep mine'),
                  ),
                  OutlinedButton(
                    key: Key('take-theirs-${entry.id}'),
                    onPressed: () => worker.takeTheirs(entry),
                    child: const Text('Take theirs'),
                  ),
                  if (entry.payload.length > 1)
                    OutlinedButton(
                      key: Key('merge-${entry.id}'),
                      onPressed: () => _merge(context, worker, sync),
                      child: const Text('Merge'),
                    ),
                ] else ...[
                  FilledButton(
                    key: Key('retry-${entry.id}'),
                    onPressed: () async {
                      await worker.retry(entry);
                      await sync.syncNow();
                    },
                    child: const Text('Try again'),
                  ),
                  OutlinedButton(
                    key: Key('discard-${entry.id}'),
                    onPressed: () => worker.discard(entry),
                    child: const Text('Discard'),
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
    title: const Text('Which of your changes to keep?'),
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
        child: const Text('Cancel'),
      ),
      FilledButton(
        key: const Key('merge-confirm'),
        onPressed: () => Navigator.pop(context, _mine),
        child: const Text('Merge'),
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
        Text('Storage', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(
          usage == null
              ? 'Reading…'
              : 'The copy on this device holds '
                    '${(usage.size / _mb).toStringAsFixed(1)} MB '
                    'of at most $capMb MB.',
          key: const Key('cache-usage'),
        ),
        Row(
          children: [
            const Expanded(child: Text('Most it may hold')),
            const SizedBox(width: 12),
            DropdownButton<int>(
              key: const Key('cache-cap'),
              value: cacheCapChoicesMb.contains(capMb) ? capMb : null,
              items: [
                for (final mb in cacheCapChoicesMb)
                  DropdownMenuItem(value: mb, child: Text('$mb MB')),
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
          alignment: Alignment.centerLeft,
          child: OutlinedButton(
            key: const Key('clear-cache'),
            onPressed: workspace == null
                ? null
                : () => _clear(context, ref, workspace),
            child: const Text('Clear the copy on this device'),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Changes still waiting to be sent are kept. The copy is stored '
          'unencrypted: use your device\'s disk encryption.',
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
        title: const Text('Clear the copy on this device?'),
        content: const Text(
          'What you read is fetched again when you are online. Changes '
          'waiting to be sent are not removed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            key: const Key('clear-cache-confirm'),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Clear'),
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
          'Keep projects offline',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 4),
        const Text(
          'A kept project is copied whole, so its tasks, statuses and '
          'members are there without a connection. Other projects show '
          'what you read last.',
        ),
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
                    ? Text(working.error!)
                    : Text('Copying… ${working.fetched} tasks'),
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
