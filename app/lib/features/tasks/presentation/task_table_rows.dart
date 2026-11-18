part of 'task_table.dart';

/// The lines of the table (rows, group headers) built for [_TaskTableState].
extension _TableRows on _TaskTableState {
  Widget _rows(BuildContext context, Set<String> selected) {
    final entries = widget.entries;
    _fresh.update([
      for (final e in entries)
        if (e is TaskEntry) e.task.id,
    ], settled: !widget.loading);
    final count = entries.length + (widget.loading ? 1 : 0);
    return ListView.builder(
      key: const Key('task-list'),
      controller: _vertical,
      itemCount: count,
      itemExtentBuilder: (i, _) => i >= entries.length ? 4 : _rowHeight,
      itemBuilder: (context, i) {
        if (i >= entries.length) {
          return const LinearProgressIndicator(key: Key('tasks-streaming'));
        }
        return switch (entries[i]) {
          GroupEntry(:final key) when entries[i] is GroupEntry => _group(
            context,
            entries[i] as GroupEntry,
            key,
          ),
          final TaskEntry entry => _taskRow(
            context,
            entry,
            selected.contains(entry.task.id),
          ),
          _ => const SizedBox.shrink(),
        };
      },
    );
  }

  Widget _group(BuildContext context, GroupEntry group, String key) {
    final header = TableGroupHeader(
      group: group,
      groupBy: widget.layout.groupBy,
      lookups: widget.lookups,
      height: _rowHeight,
      focused: _cursor == 'group:$key',
      onToggle: () {
        _focus.requestFocus();
        _toggleGroup(key);
      },
    );
    return widget.wrapGroup?.call(group, header) ?? header;
  }

  Widget _taskRow(BuildContext context, TaskEntry entry, bool picked) {
    final task = entry.task;
    final row = TaskRow(
      entry: entry,
      layout: widget.layout,
      columns: _visible,
      lookups: widget.lookups,
      height: _rowHeight,
      picked: picked,
      open: task.id == widget.openTaskId,
      focused: _cursor == task.id,
      renaming: _renaming == task.id,
      canUpdate: widget.canUpdate,
      actions: widget.actionsFor(task),
      progress: widget.progressOf(task.id),
      renameHint: withShortcut(
        ref,
        context.l10n.grpJRename,
        'task.rename',
        l10n: context.l10n,
      ),
      onOpen: () {
        _focus.requestFocus();
        _setCursor(task.id);
        widget.onOpen(task);
      },
      onPick: () => _pick(task),
      onToggleFold: () => ref
          .read(collapsedTasksProvider(widget.projectId).notifier)
          .toggle(task.id),
      onRename: () => _startRename(task.id),
      onRenameDone: _endRename,
      onAction: (a) => widget.onAction(a, task),
      wrap: widget.wrapRow,
    );
    return TfSettleIn(
      key: ValueKey('settle-${task.id}'),
      enabled: _fresh.isFresh(task.id),
      child: row,
    );
  }
}
