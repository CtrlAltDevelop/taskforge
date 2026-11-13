import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/i18n/context_dates.dart';
import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/comments/application/comments_providers.dart'
    show currentUserIdProvider;
import 'package:taskforge/features/roles/application/roles_providers.dart';
import 'package:taskforge/features/roles/domain/roles.dart';
import 'package:taskforge/features/time/application/time_providers.dart';
import 'package:taskforge/features/time/domain/time.dart';
import 'package:taskforge/features/time/presentation/entry_dialog.dart';

/// The "Time" part of a task: logged against estimated, a start/stop button,
/// manual entries, and everyone's entries on it. Shown only in a project that
/// has time tracking switched on.
class TimeSection extends ConsumerStatefulWidget {
  const TimeSection({
    super.key,
    required this.projectId,
    required this.taskId,
    this.archived = false,
  });

  final String projectId;
  final String taskId;
  final bool archived;

  @override
  ConsumerState<TimeSection> createState() => _TimeSectionState();
}

class _TimeSectionState extends ConsumerState<TimeSection> {
  String? _message;
  var _busy = false; // one start/stop at a time: a double tap is one tap

  ({String project, String task}) get _ref =>
      (project: widget.projectId, task: widget.taskId);

  Future<void> _do(Future<void> Function() act) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await act();
      if (mounted) setState(() => _message = null);
    } on Object catch (e) {
      if (mounted) setState(() => _message = timeErrorMessage(e, context.l10n));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Starts the timer here and says which other timer that stopped.
  Future<void> _start() => _do(() async {
    final started = await ref
        .read(timeActionsProvider)
        .start(widget.projectId, widget.taskId);
    final stopped = started.stopped;
    if (stopped != null && mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            key: const Key('timer-replaced'),
            content: Text(
              context.l10n.grpJTimerStoppedOn(stopped.key, stopped.title),
            ),
          ),
        );
    }
  });

  Future<void> _add() async {
    final input = await askEntry(context);
    if (input == null) return;
    await _do(
      () => ref
          .read(timeActionsProvider)
          .add(
            widget.projectId,
            widget.taskId,
            startedAt: input.startedAt!,
            durationSec: input.durationSec!,
            note: input.note,
            billable: input.billable,
          ),
    );
  }

  Future<void> _edit(TimeEntry entry) async {
    final input = await askEntry(context, existing: entry);
    if (input == null) return;
    await _do(
      () => ref
          .read(timeActionsProvider)
          .edit(
            entry.id,
            startedAt: input.startedAt,
            durationSec: input.durationSec,
            note: input.note,
            billable: input.billable,
          ),
    );
  }

  Future<void> _estimate(TimeSummary summary) async {
    final seconds = await askEstimate(context, summary.estimateSec);
    if (seconds == null) return;
    await _do(
      () => ref
          .read(timeActionsProvider)
          .estimate(widget.projectId, widget.taskId, seconds),
    );
  }

  @override
  Widget build(BuildContext context) {
    final permissions = ref.watch(permissionSetProvider);
    final canLog = !widget.archived && permissions.can(Perm.timeLog);
    final canEstimate = !widget.archived && permissions.can(Perm.taskUpdate);
    final others = permissions.can(Perm.timeEditOthers);
    final summary = ref.watch(timeSummaryProvider(_ref)).value;
    final entries = ref.watch(timeEntriesProvider(_ref)).value ?? const [];
    final timer = ref.watch(currentTimerProvider).value;
    final runningHere = timer?.entry?.taskId == widget.taskId;
    final me = ref.watch(currentUserIdProvider);
    final theme = Theme.of(context);

    return Column(
      key: const Key('time-section'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(context.l10n.grpJTime, style: theme.textTheme.titleMedium),
            const Spacer(),
            if (canLog)
              runningHere
                  ? FilledButton.tonalIcon(
                      key: const Key('time-stop'),
                      onPressed: () =>
                          _do(() async => ref.read(timeActionsProvider).stop()),
                      icon: const Icon(Icons.stop),
                      label: Text(context.l10n.grpJStop),
                    )
                  : FilledButton.tonalIcon(
                      key: const Key('time-start'),
                      onPressed: _busy ? null : _start,
                      icon: const Icon(Icons.play_arrow),
                      label: Text(context.l10n.grpJStartTimer),
                    ),
            if (canLog)
              IconButton(
                key: const Key('time-add'),
                tooltip: context.l10n.grpJAddTime,
                icon: const Icon(Icons.add),
                onPressed: _add,
              ),
          ],
        ),
        if (summary != null) _SummaryLine(summary, canEstimate, _estimate),
        if (_message != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              _message!,
              key: const Key('time-error'),
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
        for (final e in entries)
          _EntryTile(
            entry: e,
            mine: e.userId == me,
            canChange: !widget.archived && (e.userId == me ? canLog : others),
            onEdit: () => _edit(e),
            onDelete: () async {
              if (!await confirmDelete(context)) return;
              await _do(() => ref.read(timeActionsProvider).remove(e.id));
            },
          ),
      ],
    );
  }
}

class _SummaryLine extends StatelessWidget {
  const _SummaryLine(this.summary, this.canEstimate, this.onEstimate);

  final TimeSummary summary;
  final bool canEstimate;
  final void Function(TimeSummary) onEstimate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = summary.hasEstimate
        ? context.l10n.grpJTimeOfEstimate(
            durationText(summary.loggedSec),
            durationText(summary.estimateSec),
          )
        : context.l10n.grpJTimeLogged(durationText(summary.loggedSec));
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                text,
                key: const Key('time-summary'),
                style: summary.over
                    ? TextStyle(color: theme.colorScheme.error)
                    : null,
              ),
              if (summary.billableSec > 0)
                Text(
                  '  ·  '
                  '${context.l10n.grpJTimeBillable(durationText(summary.billableSec))}',
                ),
              if (canEstimate)
                TextButton(
                  key: const Key('time-estimate'),
                  onPressed: () => onEstimate(summary),
                  child: Text(
                    summary.hasEstimate
                        ? context.l10n.grpJChangeEstimate
                        : context.l10n.grpJSetEstimate,
                  ),
                ),
            ],
          ),
          if (summary.hasEstimate)
            LinearProgressIndicator(
              value: (summary.loggedSec / summary.estimateSec).clamp(0.0, 1.0),
            ),
        ],
      ),
    );
  }
}

class _EntryTile extends StatelessWidget {
  const _EntryTile({
    required this.entry,
    required this.mine,
    required this.canChange,
    required this.onEdit,
    required this.onDelete,
  });

  final TimeEntry entry;
  final bool mine;
  final bool canChange;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final day = entry.startedAt.toLocal();
    final when = context.localIso(day);
    return ListTile(
      key: Key('entry-${entry.id}'),
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        entry.running ? Icons.timer : Icons.schedule,
        semanticLabel: entry.running
            ? context.l10n.grpJRunning
            : context.l10n.grpJLoggedLabel,
      ),
      title: Text(
        '${entry.running ? context.l10n.grpJRunning : durationText(entry.durationSec)}'
        ' · ${mine ? context.l10n.grpJYou : entry.userName} · $when'
        '${entry.billable ? ' · ${context.l10n.grpJBillableSuffix}' : ''}',
      ),
      subtitle: Wrap(
        spacing: 8,
        children: [
          if (entry.note.isNotEmpty) Text(entry.note),
          if (entry.overlaps)
            Chip(
              key: Key('overlap-${entry.id}'),
              label: Text(context.l10n.grpJOverlapsEntry),
              visualDensity: VisualDensity.compact,
            ),
          if (entry.isLong)
            Chip(
              key: Key('long-${entry.id}'),
              label: Text(context.l10n.grpJOver24h),
              visualDensity: VisualDensity.compact,
            ),
        ],
      ),
      trailing: canChange
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  key: Key('edit-${entry.id}'),
                  tooltip: context.l10n.grpJEdit,
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: onEdit,
                ),
                IconButton(
                  key: Key('delete-${entry.id}'),
                  tooltip: context.l10n.grpJDelete,
                  icon: const Icon(Icons.delete_outline),
                  onPressed: onDelete,
                ),
              ],
            )
          : null,
    );
  }
}
