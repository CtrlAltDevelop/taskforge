import 'package:taskforge/core/ui/tf_app_bar.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:taskforge/core/i18n/context_dates.dart';
import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/core/i18n/weekday_names.dart';
import 'package:taskforge/features/members/application/members_providers.dart';
import 'package:taskforge/features/members/domain/members.dart';
import 'package:taskforge/features/roles/application/roles_providers.dart';
import 'package:taskforge/features/roles/domain/roles.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';
import 'package:taskforge/features/workload/application/workload_providers.dart';
import 'package:taskforge/features/workload/domain/workload.dart';
import 'package:taskforge/features/workload/presentation/workload_cell.dart';
import 'package:taskforge/features/workload/presentation/workload_settings.dart';
import 'package:taskforge/features/workload/presentation/workload_toolbar.dart';

const _nameWidth = 190.0;
const _minCell = 72.0;

String workloadMessage(BuildContext context, Object error) =>
    error is TaskException
    ? taskErrorMessage(error, context.l10n)
    : workloadErrorMessage(error, context.l10n);

void sayWorkload(BuildContext context, String text) =>
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));

/// People by days: how much work each person has against their capacity, with
/// drag and drop to rebalance.
class WorkloadScreen extends ConsumerWidget {
  const WorkloadScreen({super.key});

  Future<void> _drop(
    BuildContext context,
    WidgetRef ref,
    DraggedTask task,
    String toUser,
    DateTime toColumn,
  ) async {
    final notifier = ref.read(workloadProvider.notifier);
    final shift = toColumn.difference(task.fromColumn).inDays;
    // A month or a week column is a whole step: shift by the days between
    // the two columns so the task keeps its place inside the column.
    try {
      if (toUser != task.fromUser) {
        await notifier.reassign(task.taskId, task.fromUser, toUser);
      }
      if (shift != 0) await notifier.shift(task.taskId, shift);
    } on Object catch (e) {
      if (context.mounted) sayWorkload(context, workloadMessage(context, e));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.l10n;
    final async = ref.watch(workloadProvider);
    final perms = ref.watch(permissionSetProvider);
    final members = ref.watch(membersProvider).value ?? const <Member>[];
    final query = ref.watch(workloadQueryProvider);
    return Scaffold(
      appBar: TfAppBar(
        title: Text(t.wlTitle),
        actions: [
          IconButton(
            key: const Key('workload-settings'),
            tooltip: t.wlSettings,
            icon: const Icon(Icons.tune),
            onPressed: () => context.push('/workload/settings'),
          ),
        ],
      ),
      body: Column(
        children: [
          const WorkloadToolbar(),
          const WorkloadLegend(),
          const Divider(height: 1),
          Expanded(
            child: async.when(
              skipLoadingOnReload: true,
              skipLoadingOnRefresh: true,
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(workloadMessage(context, e)),
                    TextButton(
                      onPressed: () => ref.invalidate(workloadProvider),
                      child: Text(t.retry),
                    ),
                  ],
                ),
              ),
              data: (data) => _Body(
                data: data,
                members: members,
                query: query,
                canEdit: perms.can(Perm.taskUpdate),
                canManage: perms.can(Perm.workloadManage),
                onDrop: (task, user, col) =>
                    _drop(context, ref, task, user, col),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.data,
    required this.members,
    required this.query,
    required this.canEdit,
    required this.canManage,
    required this.onDrop,
  });

  final WorkloadData data;
  final List<Member> members;
  final WorkloadQuery query;
  final bool canEdit;
  final bool canManage;
  final void Function(DraggedTask, String, DateTime) onDrop;

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final anyUnset = data.people.any((p) => !p.capacity.isSet);
    return Column(
      children: [
        if (!data.canSeeAll)
          _Note(text: t.wlOnlyYours, icon: Icons.lock_outline),
        if (anyUnset)
          _Note(
            key: const Key('workload-set-capacity-note'),
            text: t.wlSetCapacityHint,
            icon: Icons.info_outline,
            action: canManage
                ? TextButton(
                    onPressed: () => context.push('/workload/settings'),
                    child: Text(t.wlSetCapacity),
                  )
                : null,
          ),
        if (data.truncated)
          _Note(text: t.wlTruncated, icon: Icons.warning_amber),
        Expanded(
          child: data.people.isEmpty
              ? Center(child: Text(t.wlNoPeople))
              : _Grid(
                  data: data,
                  members: members,
                  zoom: query.zoom,
                  canManage: canManage,
                  onDrop: canEdit ? onDrop : null,
                ),
        ),
        _Unplaced(data: data),
      ],
    );
  }
}

class _Note extends StatelessWidget {
  const _Note({super.key, required this.text, required this.icon, this.action});

  final String text;
  final IconData icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
    child: Row(
      children: [
        Icon(icon, size: 18),
        const SizedBox(width: 8),
        Expanded(child: Text(text)),
        ?action,
      ],
    ),
  );
}

class _Grid extends StatelessWidget {
  const _Grid({
    required this.data,
    required this.members,
    required this.zoom,
    required this.canManage,
    required this.onDrop,
  });

  final WorkloadData data;
  final List<Member> members;
  final WorkloadZoom zoom;
  final bool canManage;
  final void Function(DraggedTask, String, DateTime)? onDrop;

  @override
  Widget build(BuildContext context) {
    final columns = columnsOf(zoom, data);
    return LayoutBuilder(
      builder: (context, box) {
        final fit = (box.maxWidth - _nameWidth) / columns.length;
        final width = fit < _minCell ? _minCell : fit;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: _nameWidth + width * columns.length,
            child: Column(
              children: [
                _HeaderRow(columns: columns, zoom: zoom, width: width),
                Expanded(
                  child: ListView.builder(
                    itemCount: data.people.length,
                    itemBuilder: (context, i) {
                      final person = data.people[i];
                      return Row(
                        key: ValueKey('workload-row-${person.userId}'),
                        children: [
                          _NameCell(
                            person: person,
                            member: members
                                .where((m) => m.userId == person.userId)
                                .firstOrNull,
                            canManage: canManage,
                            data: data,
                            columns: columns,
                          ),
                          for (final c in columns)
                            SizedBox(
                              width: width,
                              child: LoadCell(
                                person: person,
                                data: data,
                                column: c,
                                zoom: zoom,
                                onDrop: onDrop,
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow({
    required this.columns,
    required this.zoom,
    required this.width,
  });

  final List<(DateTime, DateTime)> columns;
  final WorkloadZoom zoom;
  final double width;

  String _label(BuildContext context, DateTime start) => switch (zoom) {
    WorkloadZoom.day =>
      '${context.l10n.weekdayShortNames[start.weekday - 1]} ${context.localDigits('${start.day}')}',
    _ => context.localDate(start),
  };

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelSmall;
    return Row(
      children: [
        const SizedBox(width: _nameWidth, height: 32),
        for (final c in columns)
          SizedBox(
            width: width,
            child: Center(
              child: Text(
                _label(context, c.$1),
                style: style,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
      ],
    );
  }
}

class _NameCell extends ConsumerWidget {
  const _NameCell({
    required this.person,
    required this.member,
    required this.canManage,
    required this.data,
    required this.columns,
  });

  final PersonLoad person;
  final Member? member;
  final bool canManage;
  final WorkloadData data;
  final List<(DateTime, DateTime)> columns;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.l10n;
    final theme = Theme.of(context);
    final cap = person.capacity;
    final name = member?.label ?? person.userId;
    return Container(
      width: _nameWidth,
      height: cellHeight,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        border: BorderDirectional(
          end: BorderSide(color: theme.dividerColor),
          bottom: BorderSide(color: theme.dividerColor),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            child: Text(
              member?.initials ?? '?',
              style: theme.textTheme.labelSmall,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
                if (cap.isSet)
                  Text(
                    t.wlCapacitySummary(
                      context.localDigits(hoursText(cap.secondsPerDay)),
                      context.localDigits('${cap.workingDays.length}'),
                    ),
                    style: theme.textTheme.bodySmall,
                  )
                else if (canManage)
                  TextButton(
                    key: Key('set-capacity-${person.userId}'),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 24),
                      alignment: AlignmentDirectional.centerStart,
                    ),
                    onPressed: () async {
                      await editCapacity(
                        context,
                        ref,
                        person.userId,
                        name,
                        cap,
                      );
                      ref.invalidate(workloadProvider);
                    },
                    child: Text(t.wlSetCapacity),
                  )
                else
                  Text(t.wlNoCapacity, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The open tasks the grid cannot count, so they do not hide.
class _Unplaced extends StatelessWidget {
  const _Unplaced({required this.data});

  final WorkloadData data;

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    if (data.unplaced.isEmpty) return const SizedBox.shrink();
    final no = data.unestimatedCount;
    final undated = data.undatedCount;
    final title = [
      if (no > 0) t.wlUnestimated(no),
      if (undated > 0) t.wlUndated(undated),
    ].join(' · ');
    return ExpansionTile(
      key: const Key('workload-unplaced'),
      title: Text(title),
      dense: true,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 220),
          child: ListView(
            shrinkWrap: true,
            children: [
              for (final task in data.unplaced)
                Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: ListTile(
                    dense: true,
                    title: Text('${task.displayId}  ${task.title}'),
                    subtitle: Text(
                      task.reason == UnplacedReason.noDates
                          ? t.wlReasonNoDates
                          : t.wlReasonNoEstimate,
                    ),
                    onTap: () => context.push(
                      '/projects/${task.projectId}?task=${task.id}',
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
