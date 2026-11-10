import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/features/tasks/application/tasks_providers.dart';
import 'package:taskforge/features/tasks/domain/bulk.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';
import 'package:taskforge/features/tasks/presentation/list_lookups.dart';
import 'package:taskforge/features/tasks/presentation/table_cells.dart';
import 'package:taskforge/features/workflows/domain/workflow.dart';

/// What can be done to the picked tasks at once: set the status, priority or
/// assignees, or delete them. Shows progress while the server works and
/// afterwards says which tasks could not take the change, and why.
class BulkBar extends ConsumerStatefulWidget {
  const BulkBar({
    super.key,
    required this.projectId,
    required this.lookups,
    required this.canUpdate,
    required this.canDelete,
  });

  final String projectId;
  final ListLookups lookups;
  final bool canUpdate;
  final bool canDelete;

  @override
  ConsumerState<BulkBar> createState() => _BulkBarState();
}

class _BulkBarState extends ConsumerState<BulkBar> {
  ({int done, int total})? _progress;

  Future<void> _run(BulkChange change) async {
    final selection = ref.read(taskSelectionProvider(widget.projectId));
    if (selection.isEmpty || _progress != null) return;
    final messenger = ScaffoldMessenger.of(context);
    final tasks = ref.read(taskListProvider(widget.projectId));
    final names = {for (final t in tasks.tasks) t.id: t.displayId};
    final ids = selection.toList();
    setState(() => _progress = (done: 0, total: ids.length));
    try {
      final summary = await ref
          .read(taskListProvider(widget.projectId).notifier)
          .bulk(
            ids,
            change,
            onProgress: (done, total) {
              if (!mounted) return;
              setState(() => _progress = (done: done, total: total));
            },
          );
      ref
          .read(taskSelectionProvider(widget.projectId).notifier)
          .removeAll(summary.succeeded);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(_summaryBar(summary, names, change.delete));
    } on TaskException catch (e) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(taskErrorMessage(e))));
    } finally {
      if (mounted) setState(() => _progress = null);
    }
  }

  SnackBar _summaryBar(
    BulkSummary summary,
    Map<String, String> names,
    bool deleted,
  ) {
    final verb = deleted ? 'deleted' : 'updated';
    if (summary.allOk) {
      return SnackBar(content: Text('${summary.succeeded.length} tasks $verb'));
    }
    return SnackBar(
      key: const Key('bulk-partial'),
      duration: const Duration(seconds: 10),
      content: Text(
        '${summary.succeeded.length} of ${summary.total} tasks $verb; '
        '${summary.failed.length} could not be.',
      ),
      action: SnackBarAction(
        key: const Key('bulk-details'),
        label: 'Details',
        onPressed: () => showDialog<void>(
          context: context,
          builder: (_) =>
              BulkFailuresDialog(failed: summary.failed, names: names),
        ),
      ),
    );
  }

  Future<void> _assign() async {
    final picked = await showDialog<List<String>>(
      context: context,
      builder: (_) =>
          AssigneeDialog(members: widget.lookups.members, selected: const []),
    );
    if (picked != null) await _run(BulkChange(assigneeIds: picked));
  }

  Future<void> _delete(int count) async {
    final sure = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Delete $count tasks?'),
        content: const Text(
          'Their subtasks go with them. You can restore them from the trash.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            key: const Key('bulk-delete-confirm'),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (sure == true) await _run(const BulkChange.delete());
  }

  @override
  Widget build(BuildContext context) {
    final selection = ref.watch(taskSelectionProvider(widget.projectId));
    if (selection.isEmpty && _progress == null) return const SizedBox.shrink();
    final busy = _progress != null;
    final statuses = widget.lookups.flow?.statuses ?? const <WorkflowStatus>[];
    final progress = _progress;
    return Material(
      key: const Key('bulk-bar'),
      elevation: 3,
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (progress != null)
            LinearProgressIndicator(
              key: const Key('bulk-progress'),
              value: progress.total == 0
                  ? null
                  : progress.done / progress.total,
            ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                const SizedBox(width: 12),
                Text(
                  busy
                      ? 'Updating ${progress!.done} of ${progress.total}…'
                      : '${selection.length} selected',
                  key: const Key('bulk-count'),
                ),
                const SizedBox(width: 8),
                if (widget.canUpdate && statuses.isNotEmpty)
                  PopupMenuButton<WorkflowStatus>(
                    key: const Key('bulk-status'),
                    enabled: !busy,
                    tooltip: 'Set status',
                    onSelected: (s) => _run(BulkChange(status: s)),
                    itemBuilder: (_) => [
                      for (final s in statuses)
                        PopupMenuItem(
                          key: Key('bulk-status-${s.id}'),
                          value: s,
                          child: Text(s.name),
                        ),
                    ],
                    child: const _BarLabel(Icons.flag_outlined, 'Status'),
                  ),
                if (widget.canUpdate)
                  PopupMenuButton<TaskPriority>(
                    key: const Key('bulk-priority'),
                    enabled: !busy,
                    tooltip: 'Set priority',
                    onSelected: (p) => _run(BulkChange(priority: p)),
                    itemBuilder: (_) => [
                      for (final p in TaskPriority.values)
                        PopupMenuItem(
                          key: Key('bulk-priority-${p.wire}'),
                          value: p,
                          child: Text(p.label),
                        ),
                    ],
                    child: const _BarLabel(Icons.low_priority, 'Priority'),
                  ),
                if (widget.canUpdate)
                  TextButton.icon(
                    key: const Key('bulk-assign'),
                    onPressed: busy ? null : _assign,
                    icon: const Icon(Icons.person_add_alt),
                    label: const Text('Assign'),
                  ),
                if (widget.canDelete)
                  TextButton.icon(
                    key: const Key('bulk-delete'),
                    onPressed: busy ? null : () => _delete(selection.length),
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Delete'),
                  ),
                TextButton(
                  key: const Key('bulk-clear'),
                  onPressed: busy
                      ? null
                      : ref
                            .read(
                              taskSelectionProvider(widget.projectId).notifier,
                            )
                            .clear,
                  child: const Text('Clear'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BarLabel extends StatelessWidget {
  const _BarLabel(this.icon, this.label);

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [Icon(icon, size: 18), const SizedBox(width: 4), Text(label)],
    ),
  );
}

/// Which tasks a bulk call could not change, and why.
class BulkFailuresDialog extends StatelessWidget {
  const BulkFailuresDialog({
    super.key,
    required this.failed,
    required this.names,
  });

  final List<BulkOutcome> failed;
  final Map<String, String> names;

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text('${failed.length} tasks not changed'),
    content: SizedBox(
      width: 420,
      child: ListView(
        shrinkWrap: true,
        children: [
          for (final f in failed)
            ListTile(
              dense: true,
              title: Text(names[f.id] ?? 'Task'),
              subtitle: Text(f.message),
            ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Close'),
      ),
    ],
  );
}
