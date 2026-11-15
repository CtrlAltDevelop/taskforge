import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/i18n/context_dates.dart';
import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/audit/application/audit_providers.dart';
import 'package:taskforge/features/audit/domain/activity_lines.dart';
import 'package:taskforge/features/audit/domain/audit.dart';
import 'package:taskforge/features/audit/domain/describe.dart';

/// "Activity" in a task's detail: who changed what, newest first, grouped by
/// day. Collapsed until opened, so closed tasks cost nothing to read.
class ActivitySection extends StatefulWidget {
  const ActivitySection({
    super.key,
    required this.projectId,
    required this.taskId,
  });

  final String projectId;
  final String taskId;

  @override
  State<ActivitySection> createState() => _ActivitySectionState();
}

class _ActivitySectionState extends State<ActivitySection> {
  var _open = false;

  @override
  Widget build(BuildContext context) => ExpansionTile(
    key: const Key('activity-section'),
    tilePadding: EdgeInsets.zero,
    title: Text(
      context.l10n.grpJActivity,
      style: Theme.of(context).textTheme.titleMedium,
    ),
    leading: const Icon(Icons.history),
    onExpansionChanged: (v) => setState(() => _open = v),
    children: [
      if (_open)
        ActivityList(task: (project: widget.projectId, task: widget.taskId)),
    ],
  );
}

class ActivityList extends ConsumerWidget {
  const ActivityList({super.key, required this.task});

  final ({String project, String task}) task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(taskActivityProvider(task));
    final now = ref.watch(auditNowProvider)();
    if (state.loading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (state.entries.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(8),
        child: state.error == null
            ? Text(
                context.l10n.grpJNoActivity,
                key: const Key('activity-empty'),
              )
            : _Failed(
                error: state.error!,
                onRetry: ref.read(taskActivityProvider(task).notifier).refresh,
              ),
      );
    }
    final lines = activityLines(state.entries);
    final children = <Widget>[];
    String? heading;
    for (final line in lines) {
      final h = dayHeading(
        now,
        line.entry.at,
        context.l10n,
        context.localePrefs,
      );
      if (h != heading) {
        heading = h;
        children.add(
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 2),
            child: Text(h, style: Theme.of(context).textTheme.labelMedium),
          ),
        );
      }
      children.add(_Line(line: line, labels: state.labels, now: now));
    }
    return Column(
      key: const Key('activity-list'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (state.error != null)
          _Failed(
            error: state.error!,
            onRetry: ref.read(taskActivityProvider(task).notifier).refresh,
          ),
        ...children,
        if (state.hasMore)
          TextButton(
            key: const Key('activity-more'),
            onPressed: state.loadingMore
                ? null
                : ref.read(taskActivityProvider(task).notifier).more,
            child: Text(
              state.loadingMore
                  ? context.l10n.grpBLoading
                  : context.l10n.grpBShowOlder,
            ),
          ),
      ],
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.line, required this.labels, required this.now});

  final ActivityLine line;
  final Map<String, String> labels;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final e = line.entry;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        key: Key('activity-${e.id}'),
        dense: true,
        contentPadding: EdgeInsets.zero,
        leading: Icon(
          e.actorType == 'user'
              ? Icons.person_outline
              : Icons.smart_toy_outlined,
          size: 18,
        ),
        title: Text(
          '${e.whoIn(context.l10n)} ${describeEntry(e, labels, context.l10n)}',
        ),
        subtitle: Text(
          relativeTime(now, e.at, context.l10n, context.localePrefs),
        ),
      ),
    );
  }
}

class _Failed extends StatelessWidget {
  const _Failed({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(
          auditErrorMessage(error, context.l10n),
          key: const Key('activity-error'),
        ),
      ),
      TextButton(
        key: const Key('activity-retry'),
        onPressed: onRetry,
        child: Text(context.l10n.retry),
      ),
    ],
  );
}
