import 'package:taskforge/core/ui/tokens/spacing.dart';
import 'package:taskforge/core/ui/tf/tf_button.dart';
import 'package:taskforge/core/ui/tf/tf_row.dart';
import 'package:taskforge/core/ui/tf/tf_panel.dart';
import 'package:taskforge/core/ui/tf_icons.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/goals/application/goals_providers.dart';
import 'package:taskforge/features/goals/domain/goals.dart';
import 'package:taskforge/features/goals/presentation/goal_widgets.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';

/// Task detail: "Contributes to: Goal > Key result", with a way to count the
/// task in one more linked key result.
class ContributesPanel extends ConsumerWidget {
  const ContributesPanel({super.key, required this.taskId});

  final String taskId;

  Future<void> _add(BuildContext context, WidgetRef ref) async {
    final ws = ref.read(workspaceScopeProvider);
    if (ws == null) return;
    final cat = ref.read(goalsProvider).value ?? GoalCatalog.empty;
    final options = [
      for (final g in cat.goals)
        if (g.canEdit)
          for (final kr in g.keyResults)
            if (kr.type == KrType.linked && !kr.taskIds.contains(taskId))
              (g, kr),
    ];
    final chosen = await showDialog<(Goal, KeyResult)>(
      context: context,
      builder: (c) => SimpleDialog(
        title: Text(c.l10n.goalsPickKr),
        children: [
          if (options.isEmpty)
            Padding(
              padding: const EdgeInsets.all(TfSpace.xl),
              child: Text(c.l10n.goalsNoLinkedKr),
            ),
          for (final (g, kr) in options)
            SimpleDialogOption(
              key: Key('pick-kr-${kr.id}'),
              onPressed: () => Navigator.of(c).pop((g, kr)),
              child: Text('${g.name} › ${kr.name}'),
            ),
        ],
      ),
    );
    if (chosen == null || !context.mounted) return;
    final (_, kr) = chosen;
    try {
      await ref.read(goalsClientProvider).updateKeyResult(
        ws,
        kr,
        KrDraft(name: kr.name, type: kr.type, taskIds: [...kr.taskIds, taskId]),
        const ['task_ids'],
      );
    } on GoalsException catch (e) {
      if (context.mounted) {
        sayGoals(context, goalsErrorMessage(e, context.l10n));
      }
    }
    ref.invalidate(goalsProvider);
    ref.invalidate(taskContributionsProvider(taskId));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.l10n;
    final rows = ref.watch(taskContributionsProvider(taskId)).value;
    final catalog = ref.watch(goalsProvider).value ?? GoalCatalog.empty;
    final canAdd = catalog.goals.any(
      (g) => g.canEdit && g.keyResults.any((k) => k.type == KrType.linked),
    );
    if ((rows == null || rows.isEmpty) && !canAdd) {
      return const SizedBox.shrink();
    }
    return Column(
      key: const Key('contributes-panel'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                t.goalsContributes,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            if (canAdd)
              TfButton(
                key: const Key('contribute-add'),
                label: t.goalsAddToKr,
                variant: TfButtonVariant.ghost,
                icon: TfIcons.plus,
                onPressed: () => _add(context, ref),
              ),
          ],
        ),
        for (final c in rows ?? const <Contribution>[])
          Padding(
            padding: const EdgeInsets.symmetric(vertical: TfSpace.xs),
            child: TfPanel(
              padding: EdgeInsets.zero,
              child: TfRow(
                key: Key('contribution-${c.krId}'),
                title: '${c.goalName} › ${c.krName}',
                leading: const TfIcon(TfIcons.flag, size: 18),
                onTap: () => context.push('/goals/${c.goalId}'),
              ),
            ),
          ),
      ],
    );
  }
}
