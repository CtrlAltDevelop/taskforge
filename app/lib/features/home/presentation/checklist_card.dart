import 'package:taskforge/core/i18n/context_dates.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/core/ui/theme_extension.dart';
import 'package:taskforge/core/ui/tf/tf_button.dart';
import 'package:taskforge/core/ui/tf/tf_row.dart';
import 'package:taskforge/core/ui/tf_icons.dart';
import 'package:taskforge/core/ui/tokens/spacing.dart';
import 'package:taskforge/features/home/application/home_providers.dart';
import 'package:taskforge/features/home/domain/home.dart';
import 'package:taskforge/features/home/presentation/home_card.dart';
import 'package:taskforge/features/members/presentation/invite_dialog.dart';
import 'package:taskforge/features/shortcuts/presentation/command_palette.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';
import 'package:taskforge/l10n/gen/app_localizations.dart';

String stepLabel(AppLocalizations l, String step) => switch (step) {
  'create_task' => l.homeStepCreateTask,
  'invite_member' => l.homeStepInvite,
  'try_board' => l.homeStepBoard,
  'open_palette' => l.homeStepPalette,
  _ => step,
};

/// "Getting started": four steps that tick themselves. It is not on Home at
/// all once the checklist is complete or dismissed (the server says so).
class ChecklistCard extends ConsumerWidget {
  const ChecklistCard({super.key});

  Future<void> _dismiss(BuildContext context, WidgetRef ref) async {
    final ws = ref.read(workspaceScopeProvider);
    if (ws == null) return;
    try {
      await ref.read(onboardingClientProvider).dismiss(ws);
    } on Object {
      // Shown again below; nothing was lost.
    }
    ref.invalidate(onboardingProvider);
  }

  void _open(BuildContext context, WidgetRef ref, String step, String project) {
    switch (step) {
      case 'create_task':
        context.go(project.isEmpty ? '/' : '/projects/$project');
      case 'invite_member':
        showDialog<void>(
          context: context,
          builder: (_) => const InviteDialog(),
        );
      case 'try_board':
        context.go(project.isEmpty ? '/' : '/projects/$project?view=board');
      case 'open_palette':
        openCommandPalette(context);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final state = ref.watch(onboardingProvider);
    // A failing checklist is not worth a card of its own: Home is complete
    // without it.
    final data = state.value;
    if (data == null) {
      return state.hasError
          ? const SizedBox.shrink()
          : const HomeCardFrame(
              id: 'checklist',
              title: '',
              icon: TfIcons.checkAll,
              child: HomeSkeleton(rows: 4),
            );
    }
    if (!data.visible) return const SizedBox.shrink();
    final c = context.tf.colors;
    return HomeCardFrame(
      id: 'checklist',
      title: l.homeCardChecklist,
      icon: TfIcons.checkAll,
      action: TfButton(
        key: const Key('checklist-dismiss'),
        label: l.homeCheckDismiss,
        size: TfButtonSize.small,
        variant: TfButtonVariant.ghost,
        onPressed: () => _dismiss(context, ref),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l.homeCheckProgress(
              context.localDigits('${data.doneCount}'),
              context.localDigits('${checklistSteps.length}'),
            ),
            key: const Key('checklist-progress'),
            style: context.tf.typography.small.copyWith(color: c.textMuted),
          ),
          const SizedBox(height: TfSpace.xs),
          for (final step in checklistSteps)
            TfRow(
              key: Key('checklist-$step'),
              title: stepLabel(l, step),
              leading: TfIcon(
                data.done(step) ? TfIcons.success : TfIcons.circle,
                size: 18,
                color: data.done(step) ? c.success.fg : c.textSubtle,
              ),
              onTap: data.done(step)
                  ? null
                  : () => _open(context, ref, step, data.sampleProjectId),
            ),
        ],
      ),
    );
  }
}
