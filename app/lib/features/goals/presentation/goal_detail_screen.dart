import 'package:taskforge/core/ui/page/tf_dialog_frame.dart';
import 'package:taskforge/core/ui/tokens/spacing.dart';
import 'package:taskforge/core/ui/tf/tf_panel.dart';
import 'package:taskforge/core/ui/tf/tf_button.dart';
import 'package:taskforge/core/ui/tf_icons.dart';
import 'package:taskforge/core/ui/tf_app_bar.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:taskforge/core/i18n/context_dates.dart';
import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/comments/application/comments_providers.dart';
import 'package:taskforge/features/goals/application/goals_providers.dart';
import 'package:taskforge/features/goals/domain/goals.dart';
import 'package:taskforge/features/goals/presentation/goal_dialogs.dart';
import 'package:taskforge/features/goals/presentation/goal_widgets.dart';
import 'package:taskforge/features/goals/presentation/goals_screen.dart';
import 'package:taskforge/features/members/application/members_providers.dart';
import 'package:taskforge/features/members/domain/members.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';
import 'package:taskforge/core/ui/tf/tf_feedback.dart';
import 'package:taskforge/core/ui/tf/tf_illustration.dart';
import 'package:taskforge/core/ui/theme_extension.dart';

const _goalFields = [
  'name',
  'description',
  'owner_id',
  'parent_id',
  'folder_id',
  'private',
  'period_start',
  'period_end',
  'status_override',
  'weight',
  'contributor_ids',
];

/// One goal: progress, status, its key results (check in from each row),
/// sub-goals and people.
class GoalDetailScreen extends ConsumerWidget {
  const GoalDetailScreen({super.key, required this.goalId});

  final String goalId;

  Future<void> _run(
    BuildContext context,
    WidgetRef ref,
    Future<void> Function(String ws) call,
  ) async {
    final ws = ref.read(workspaceScopeProvider);
    if (ws == null) return;
    try {
      await call(ws);
    } on GoalsException catch (e) {
      if (context.mounted) {
        sayGoals(context, goalsErrorMessage(e, context.l10n));
      }
    }
    ref.invalidate(goalsProvider);
  }

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref,
    Goal goal,
    GoalCatalog cat,
    List<Member> members,
  ) async {
    final draft = await showGoalDialog(
      context,
      catalog: cat,
      members: members,
      me: ref.read(currentUserIdProvider),
      goal: goal,
    );
    if (draft == null || !context.mounted) return;
    await _run(
      context,
      ref,
      (ws) => ref
          .read(goalsClientProvider)
          .updateGoal(ws, goal, draft, _goalFields),
    );
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, Goal goal) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => TfDialogFrame(
        title: c.l10n.goalsDeleteTitle(goal.name),
        content: Text(c.l10n.goalsDeleteBody),
        actions: [
          TfButton(
            label: c.l10n.grpCCancel,
            variant: TfButtonVariant.ghost,
            onPressed: () => Navigator.of(c).pop(false),
          ),
          TfButton(
            key: const Key('confirm-delete-goal'),
            label: c.l10n.goalsDelete,
            variant: TfButtonVariant.primary,
            onPressed: () => Navigator.of(c).pop(true),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    await _run(
      context,
      ref,
      (ws) => ref.read(goalsClientProvider).deleteGoal(ws, goal.id),
    );
    if (context.mounted) context.pop();
  }

  Future<void> _addKr(BuildContext context, WidgetRef ref, Goal goal) async {
    final draft = await showKrDialog(context);
    if (draft == null || !context.mounted) return;
    await _run(
      context,
      ref,
      (ws) => ref.read(goalsClientProvider).createKeyResult(ws, goal.id, draft),
    );
  }

  Future<void> _editKr(
    BuildContext context,
    WidgetRef ref,
    KeyResult kr,
  ) async {
    final draft = await showKrDialog(context, kr: kr);
    if (draft == null || !context.mounted) return;
    final changed = [
      'name',
      'weight',
      if (kr.type == KrType.number) ...['start_value', 'target_value'],
      if (kr.type == KrType.linked) 'filter_text',
    ];
    await _run(
      context,
      ref,
      (ws) =>
          ref.read(goalsClientProvider).updateKeyResult(ws, kr, draft, changed),
    );
  }

  Future<void> _deleteKr(BuildContext context, WidgetRef ref, KeyResult kr) =>
      _run(
        context,
        ref,
        (ws) => ref.read(goalsClientProvider).deleteKeyResult(ws, kr.id),
      );

  Future<void> _checkIn(
    BuildContext context,
    WidgetRef ref,
    KeyResult kr,
    Map<String, String> names,
  ) async {
    final updated = await showCheckInDialog(context, kr: kr, names: names);
    if (updated != null) ref.invalidate(goalsProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.l10n;
    final catalog = ref.watch(goalsProvider);
    final members = ref.watch(membersProvider).value ?? const <Member>[];
    final names = {for (final m in members) m.userId: m.label};
    final cat = catalog.value ?? GoalCatalog.empty;
    final goal = cat.byId(goalId);
    return Scaffold(
      appBar: TfAppBar(
        leading: TfIconButton(
          key: const Key('back-goals'),
          icon: TfIcons.arrowStart,
          tooltip: t.grpEBack,
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/goals'),
        ),
        title: Text(goal?.name ?? t.goalsTitle),
        actions: [
          if (goal != null && goal.canEdit) ...[
            TfIconButton(
              key: const Key('edit-goal'),
              icon: TfIcons.edit,
              tooltip: t.goalsEdit,
              onPressed: () => _edit(context, ref, goal, cat, members),
            ),
            TfIconButton(
              key: const Key('delete-goal'),
              icon: TfIcons.trash,
              tooltip: t.goalsDelete,
              onPressed: () => _delete(context, ref, goal),
            ),
          ],
        ],
      ),
      body: goal == null
          ? catalog.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) =>
                  TfError(message: goalsErrorMessage(e, t), details: '$e'),
              data: (_) => TfEmpty(
                illustration: TfIllustrationKind.notFound,
                title: t.goalsGone,
              ),
            )
          : _Body(
              goal: goal,
              catalog: cat,
              names: names,
              onAddKr: () => _addKr(context, ref, goal),
              onEditKr: (kr) => _editKr(context, ref, kr),
              onDeleteKr: (kr) => _deleteKr(context, ref, kr),
              onCheckIn: (kr) => _checkIn(context, ref, kr, names),
            ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.goal,
    required this.catalog,
    required this.names,
    required this.onAddKr,
    required this.onEditKr,
    required this.onDeleteKr,
    required this.onCheckIn,
  });

  final Goal goal;
  final GoalCatalog catalog;
  final Map<String, String> names;
  final VoidCallback onAddKr;
  final void Function(KeyResult) onEditKr;
  final void Function(KeyResult) onDeleteKr;
  final void Function(KeyResult) onCheckIn;

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final start = goal.start;
    final end = goal.end;
    final children = catalog.childrenOf(goal.id);
    final people = [
      if (goal.ownerId.isNotEmpty) names[goal.ownerId] ?? '',
      for (final id in goal.contributorIds) names[id] ?? '',
    ].where((s) => s.isNotEmpty);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            GoalStatusChip(status: goal.status),
            const SizedBox(width: 8),
            if (goal.statusOverride.isEmpty)
              Text(
                t.goalsStatusAutoNote,
                style: Theme.of(context).textTheme.bodySmall,
              )
            else
              Text(
                t.goalsStatusSet(goalStatusLabel(t, goal.statusHint)),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            if (goal.private) ...[
              const Spacer(),
              const TfIcon(TfIcons.lock, size: 16),
              const SizedBox(width: 4),
              Text(t.goalsPrivate),
            ],
          ],
        ),
        const SizedBox(height: 12),
        GoalProgressBar(
          progress: goal.progress,
          color: goalStatusColor(context.tf.colors, goal.status),
          height: 12,
        ),
        if (start != null && end != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              t.goalsPeriod(context.localDate(start), context.localDate(end)),
            ),
          ),
        if (goal.description.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(goal.description),
          ),
        if (people.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '${t.goalsOwner} / ${t.goalsContributors}: ${people.join(', ')}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        const Divider(height: 32),
        Row(
          children: [
            Expanded(
              child: Text(
                t.goalsKeyResults,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            if (goal.canEdit)
              TfButton(
                key: const Key('add-kr'),
                label: t.goalsAddKr,
                variant: TfButtonVariant.ghost,
                icon: TfIcons.plus,
                onPressed: onAddKr,
              ),
          ],
        ),
        if (goal.keyResults.isEmpty) Text(t.goalsNoKr),
        for (final kr in goal.keyResults)
          KeyResultRow(
            kr: kr,
            canEdit: goal.canEdit,
            canCheckIn: goal.canCheckIn,
            onCheckIn: () => onCheckIn(kr),
            onEdit: () => onEditKr(kr),
            onDelete: () => onDeleteKr(kr),
          ),
        if (children.isNotEmpty) ...[
          const Divider(height: 32),
          Text(t.goalsSubgoals, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          for (final c in children) GoalTile(goal: c),
        ],
      ],
    );
  }
}

/// What a key result is at, in words.
String krSummary(BuildContext context, KeyResult kr) {
  final t = context.l10n;
  return switch (kr.type) {
    KrType.number => t.goalsKrNumberProgress(
      trimNumber(kr.currentValue),
      trimNumber(kr.targetValue),
    ),
    KrType.percentage => t.goalsKrNumberProgress(
      '${trimNumber(kr.currentValue)}%',
      '100%',
    ),
    KrType.boolean => kr.progress >= 1 ? t.goalsKrDone : t.goalsKrNotDone,
    KrType.linked => t.goalsKrLinkedProgress(kr.linkedDone, kr.linkedTotal),
  };
}

class KeyResultRow extends StatelessWidget {
  const KeyResultRow({
    super.key,
    required this.kr,
    required this.canEdit,
    required this.canCheckIn,
    required this.onCheckIn,
    required this.onEdit,
    required this.onDelete,
  });

  final KeyResult kr;
  final bool canEdit;
  final bool canCheckIn;
  final VoidCallback onCheckIn;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: TfSpace.xs),
      child: TfPanel(
        key: Key('kr-${kr.id}'),
        padding: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      kr.name,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  if (canCheckIn)
                    TfButton(
                      key: Key('checkin-${kr.id}'),
                      label: t.goalsCheckIn,
                      variant: TfButtonVariant.ghost,
                      onPressed: onCheckIn,
                    ),
                  if (canEdit)
                    PopupMenuButton<bool>(
                      key: Key('kr-menu-${kr.id}'),
                      onSelected: (edit) => edit ? onEdit() : onDelete(),
                      itemBuilder: (c) => [
                        PopupMenuItem(
                          value: true,
                          child: Text(c.l10n.goalsEditKr),
                        ),
                        PopupMenuItem(
                          value: false,
                          child: Text(c.l10n.goalsDeleteKr),
                        ),
                      ],
                    ),
                ],
              ),
              Text(
                krSummary(context, kr),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 6),
              GoalProgressBar(progress: kr.progress),
            ],
          ),
        ),
      ),
    );
  }
}
