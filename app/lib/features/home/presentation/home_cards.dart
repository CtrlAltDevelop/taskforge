import 'package:taskforge/core/i18n/context_dates.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/core/ui/theme_extension.dart';
import 'package:taskforge/core/ui/tf/tf_button.dart';
import 'package:taskforge/core/ui/tf/tf_feedback.dart';
import 'package:taskforge/core/ui/tf/tf_menu.dart';
import 'package:taskforge/core/ui/tf/tf_row.dart';
import 'package:taskforge/core/ui/tf/tf_status.dart';
import 'package:taskforge/core/ui/tf_icons.dart';
import 'package:taskforge/core/ui/tokens/shape.dart';
import 'package:taskforge/core/ui/tokens/spacing.dart';
import 'package:taskforge/features/calendar/domain/calendar_math.dart';
import 'package:taskforge/features/home/application/home_providers.dart';
import 'package:taskforge/features/home/domain/home.dart';
import 'package:taskforge/features/home/presentation/home_card.dart';
import 'package:taskforge/features/home/presentation/home_task_row.dart';
import 'package:taskforge/features/tasks/application/tasks_providers.dart';
import 'package:taskforge/features/time/domain/time.dart';
import 'package:taskforge/features/workflows/application/workflows_providers.dart';
import 'package:taskforge/features/workflows/domain/workflow.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';

/// How many rows a Home card lists before pointing at the full page.
const homeCardRows = 5;

/// A card whose body comes from the one Home summary.
class _SummaryCard extends ConsumerWidget {
  const _SummaryCard({
    required this.id,
    required this.title,
    required this.icon,
    required this.body,
    this.action,
  });

  final String id;
  final String title;
  final TfIconData icon;
  final Widget Function(BuildContext context, HomeSummary summary) body;
  final Widget? action;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(homeSummaryProvider);
    return HomeCardFrame(
      id: id,
      title: title,
      icon: icon,
      stale: summary.value?.stale ?? false,
      computedAt: summary.value?.value.computedAt ?? '',
      action: action,
      child: HomeAsync<Fresh<HomeSummary>>(
        value: summary,
        onRetry: () => ref.invalidate(homeSummaryProvider),
        data: (fresh) => body(context, fresh.value),
      ),
    );
  }
}

/// Today: the counts, then what is due (overdue first).
class TodayCard extends ConsumerWidget {
  const TodayCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final today = ref.watch(homeTodayProvider);
    return _SummaryCard(
      id: 'today',
      title: l.homeCardToday,
      icon: TfIcons.calendarCheck,
      body: (context, s) {
        if (s.dueItems.isEmpty && s.inProgressCount == 0) {
          return TfEmpty(
            key: const Key('home-today-empty'),
            compact: true,
            title: l.homeTodayEmpty,
            message: l.homeTodayEmptyHint,
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              spacing: TfSpace.sm,
              children: [
                _Stat(
                  key: const Key('home-stat-today'),
                  label: l.homeStatToday,
                  value: s.todayCount,
                ),
                _Stat(
                  key: const Key('home-stat-overdue'),
                  label: l.homeStatOverdue,
                  value: s.overdueCount,
                  alarm: s.overdueCount > 0,
                ),
                _Stat(
                  key: const Key('home-stat-progress'),
                  label: l.homeStatInProgress,
                  value: s.inProgressCount,
                ),
              ],
            ),
            const SizedBox(height: TfSpace.sm),
            for (final t in s.dueItems.take(homeCardRows))
              HomeTaskRow(task: t, today: today),
          ],
        );
      },
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    super.key,
    required this.label,
    required this.value,
    this.alarm = false,
  });

  final String label;
  final int value;
  final bool alarm;

  @override
  Widget build(BuildContext context) {
    final tf = context.tf;
    final c = tf.colors;
    return Expanded(
      child: Semantics(
        label: '$label: ${context.localDigits('$value')}',
        excludeSemantics: true,
        child: Container(
          padding: const EdgeInsets.all(TfSpace.sm),
          decoration: BoxDecoration(
            color: alarm ? c.danger.bg : c.sunken,
            borderRadius: TfRadius.control,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.localDigits('$value'),
                style: tf.typography.title.copyWith(
                  color: alarm ? c.danger.fg : c.text,
                ),
              ),
              Text(
                label,
                style: tf.typography.small.copyWith(color: c.textMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Assigned to me, grouped by project, with a status menu on each row.
class AssignedCard extends ConsumerWidget {
  const AssignedCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final assigned = ref.watch(homeAssignedProvider);
    final today = ref.watch(homeTodayProvider);
    return HomeCardFrame(
      id: 'assigned',
      title: l.homeCardAssigned,
      icon: TfIcons.user,
      stale: assigned.value?.stale ?? false,
      action: TfButton(
        key: const Key('home-open-my-work'),
        label: l.homeSeeAll,
        size: TfButtonSize.small,
        variant: TfButtonVariant.ghost,
        onPressed: () => context.go('/my-work'),
      ),
      child: HomeAsync<Fresh<List<MyWorkItem>>>(
        value: assigned,
        onRetry: () => ref.invalidate(homeAssignedProvider),
        data: (fresh) {
          if (fresh.value.isEmpty) {
            return TfEmpty(
              key: const Key('home-assigned-empty'),
              compact: true,
              title: l.homeAssignedEmpty,
              message: l.homeAssignedEmptyHint,
            );
          }
          final byProject = <String, List<HomeTask>>{};
          for (final item in fresh.value) {
            byProject.putIfAbsent(item.task.projectId, () => []).add(item.task);
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final MapEntry(key: project, value: tasks)
                  in byProject.entries)
                _ProjectGroup(projectId: project, tasks: tasks, today: today),
            ],
          );
        },
      ),
    );
  }
}

class _ProjectGroup extends ConsumerWidget {
  const _ProjectGroup({
    required this.projectId,
    required this.tasks,
    required this.today,
  });

  final String projectId;
  final List<HomeTask> tasks;
  final String today;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tf = context.tf;
    final flow = ref.watch(workflowProvider(projectId)).value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: TfSpace.xs),
          child: Text(
            tasks.first.projectKey,
            key: Key('home-group-$projectId'),
            style: tf.typography.small.copyWith(color: tf.colors.textSubtle),
          ),
        ),
        for (final t in tasks)
          HomeTaskRow(
            task: t,
            today: today,
            status: flow == null || flow.statuses.isEmpty
                ? null
                : _StatusMenu(task: t, flow: flow),
          ),
      ],
    );
  }
}

/// The status pill of a Home row as a menu of the project's statuses; a
/// move goes through the same task client as every other status change.
class _StatusMenu extends ConsumerWidget {
  const _StatusMenu({required this.task, required this.flow});

  final HomeTask task;
  final Workflow flow;

  Future<void> _move(
    BuildContext context,
    WidgetRef ref,
    String statusId,
  ) async {
    final ws = ref.read(workspaceScopeProvider);
    if (ws == null) return;
    final messenger = ScaffoldMessenger.maybeOf(context);
    final failed = context.l10n.homeStatusFailed;
    try {
      final client = ref.read(tasksClientProvider);
      final full = await client.get(ws, task.projectId, task.taskId);
      await client.move(ws, full, statusId);
      ref.invalidate(homeAssignedProvider);
      ref.invalidate(homeSummaryProvider);
    } on Object {
      messenger?.showSnackBar(SnackBar(content: Text(failed)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) => TfMenu(
    key: Key('home-status-${task.taskId}'),
    items: [
      for (final s in flow.statuses)
        TfMenuItem(
          key: Key('home-status-${s.id}-${task.taskId}'),
          label: s.name,
          selected: s.name == task.statusName,
          onSelected: s.name == task.statusName
              ? null
              : () => _move(context, ref, s.id),
        ),
    ],
    builder: (context, toggle) => TfStatusPill(
      label: task.statusName,
      kind: statusKindOf(task.statusCategory),
      onTap: toggle,
    ),
  );
}

/// Tasks the person opened lately.
class RecentCard extends ConsumerWidget {
  const RecentCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final today = ref.watch(homeTodayProvider);
    return _SummaryCard(
      id: 'recent',
      title: l.homeCardRecent,
      icon: TfIcons.history,
      body: (context, s) => s.recent.isEmpty
          ? TfEmpty(
              key: const Key('home-recent-empty'),
              compact: true,
              title: l.homeRecentEmpty,
              message: l.homeRecentEmptyHint,
            )
          : Column(
              children: [
                for (final t in s.recent.take(homeCardRows))
                  HomeTaskRow(task: t, today: today),
              ],
            ),
    );
  }
}

/// Mentions and unread chat: the top five, and the way to the inbox.
class MentionsCard extends ConsumerWidget {
  const MentionsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final c = context.tf.colors;
    return _SummaryCard(
      id: 'mentions',
      title: l.homeCardMentions,
      icon: TfIcons.inbox,
      action: TfButton(
        key: const Key('home-open-inbox'),
        label: l.homeOpenInbox,
        size: TfButtonSize.small,
        variant: TfButtonVariant.ghost,
        onPressed: () => context.go('/inbox'),
      ),
      body: (context, s) {
        if (s.mentions.isEmpty &&
            s.unreadChat == 0 &&
            s.unreadNotifications == 0) {
          return TfEmpty(
            key: const Key('home-mentions-empty'),
            compact: true,
            title: l.homeMentionsEmpty,
            message: l.homeMentionsEmptyHint,
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              spacing: TfSpace.sm,
              children: [
                _Stat(
                  key: const Key('home-unread-notifications'),
                  label: l.homeUnreadNotifications,
                  value: s.unreadNotifications,
                ),
                _Stat(
                  key: const Key('home-unread-chat'),
                  label: l.homeUnreadChat,
                  value: s.unreadChat,
                ),
              ],
            ),
            for (final m in s.mentions.take(homeCardRows))
              TfRow(
                key: Key('home-mention-${m.id}'),
                title: l.homeMentionRow,
                leading: TfIcon(
                  TfIcons.bell,
                  size: 16,
                  color: m.read ? c.textSubtle : c.accent,
                ),
                onTap: () => context.go('/inbox'),
              ),
          ],
        );
      },
    );
  }
}

/// Time logged in the last seven days, one bar per day.
class TimeCard extends ConsumerWidget {
  const TimeCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    return _SummaryCard(
      id: 'time',
      title: l.homeCardTime,
      icon: TfIcons.clock,
      body: (context, s) => s.weekSeconds == 0
          ? TfEmpty(
              key: const Key('home-time-empty'),
              compact: true,
              title: l.homeTimeEmpty,
              message: l.homeTimeEmptyHint,
              actionLabel: l.homeTimeOpen,
              onAction: () => context.go('/timesheet'),
            )
          : _WeekBars(days: s.week, total: s.weekSeconds),
    );
  }
}

class _WeekBars extends StatelessWidget {
  const _WeekBars({required this.days, required this.total});

  final List<HomeDay> days;
  final int total;

  static const _barHeight = 56.0;

  @override
  Widget build(BuildContext context) {
    final tf = context.tf;
    final c = tf.colors;
    final most = days.fold(1, (m, d) => d.seconds > m ? d.seconds : m);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.homeTimeTotal(context.localDigits(durationText(total))),
          key: const Key('home-time-total'),
          style: tf.typography.body.copyWith(color: c.text),
        ),
        const SizedBox(height: TfSpace.sm),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (var i = 0; i < days.length; i++)
              Expanded(
                child: Semantics(
                  label: context.l10n.homeTimeBar(
                    context.localIso(parseDay(days[i].date) ?? DateTime.now()),
                    context.localDigits(durationText(days[i].seconds)),
                  ),
                  excludeSemantics: true,
                  child: Column(
                    children: [
                      Container(
                        key: Key('home-time-bar-$i'),
                        height: 4 + _barHeight * days[i].seconds / most,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          color: days[i].seconds == 0 ? c.border : c.accent,
                          borderRadius: TfRadius.chip,
                        ),
                      ),
                      const SizedBox(height: TfSpace.xs),
                      Text(
                        context.localDigits(
                          '${parseDay(days[i].date)?.day ?? ''}',
                        ),
                        style: tf.typography.small.copyWith(
                          color: c.textSubtle,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// Dashboards the person pinned.
class PinnedCard extends ConsumerWidget {
  const PinnedCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    return _SummaryCard(
      id: 'pinned',
      title: l.homeCardPinned,
      icon: TfIcons.pin,
      body: (context, s) => s.pinned.isEmpty
          ? TfEmpty(
              key: const Key('home-pinned-empty'),
              compact: true,
              title: l.homePinnedEmpty,
              message: l.homePinnedEmptyHint,
              actionLabel: l.homePinnedOpen,
              onAction: () => context.go('/dashboards'),
            )
          : Column(
              children: [
                for (final p in s.pinned)
                  TfRow(
                    key: Key('home-pin-${p.dashboardId}'),
                    title: p.name,
                    leading: const TfIcon(TfIcons.dashboard, size: 16),
                    onTap: () => context.go(
                      p.projectId.isEmpty
                          ? '/dashboards'
                          : '/projects/${p.projectId}/dashboards',
                    ),
                  ),
              ],
            ),
    );
  }
}
