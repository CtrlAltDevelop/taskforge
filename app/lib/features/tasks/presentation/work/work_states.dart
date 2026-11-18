import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/core/ui/theme_extension.dart';
import 'package:taskforge/core/ui/tf/tf_banner.dart';
import 'package:taskforge/core/ui/tf/tf_feedback.dart';
import 'package:taskforge/core/ui/tf_icons.dart';
import 'package:taskforge/core/ui/tokens/shape.dart';
import 'package:taskforge/core/ui/tokens/spacing.dart';
import 'package:taskforge/features/filters/application/filters_providers.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';
import 'package:taskforge/features/tasks/presentation/work/view_search.dart';
import 'package:taskforge/features/tasks/presentation/work/work_style.dart';

/// How many placeholder rows a loading list shows.
const skeletonRows = 8;

/// Placeholder rows as tall as the real ones (so the list does not jump when
/// the data arrives). [cards] is the phone's list of cards.
class WorkSkeleton extends StatelessWidget {
  const WorkSkeleton({super.key, this.cards = false});

  final bool cards;

  @override
  Widget build(BuildContext context) {
    // A card sits in a slot of [phoneCardHeight] (its margin included).
    final height = cards
        ? phoneCardHeight - TfSpace.xs * 2
        : workRowHeight(context);
    final c = context.tf.colors;
    return ListView(
      key: const Key('tasks-skeleton'),
      physics: const NeverScrollableScrollPhysics(),
      children: [
        for (var i = 0; i < skeletonRows; i++)
          Container(
            key: Key('skeleton-row-$i'),
            height: height,
            margin: cards
                ? const EdgeInsets.symmetric(
                    horizontal: TfSpace.md,
                    vertical: TfSpace.xs,
                  )
                : null,
            padding: const EdgeInsets.symmetric(horizontal: TfSpace.md),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: c.border)),
              borderRadius: cards ? TfRadius.panel : null,
            ),
            child: Row(
              spacing: TfSpace.md,
              children: [
                const TfSkeleton(width: 16, height: 16, circle: true),
                const TfSkeleton(width: 56),
                Expanded(child: TfSkeleton(height: cards ? 14 : 12)),
                const TfSkeleton(width: 64),
              ],
            ),
          ),
      ],
    );
  }
}

/// Nothing to show: either filters/search hide every task (offer to clear
/// them) or the project has none yet (offer to add one).
class WorkEmpty extends ConsumerWidget {
  const WorkEmpty({super.key, required this.projectId, this.onAddTask});

  final String projectId;

  /// Null when the person may not create tasks.
  final VoidCallback? onAddTask;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final filters = ref.watch(activeFilterProvider(projectId));
    final search = ref.watch(viewSearchProvider(projectId));
    if (!filters.query.isEmpty || search.isNotEmpty) {
      return TfEmpty(
        key: const Key('no-matches'),
        icon: TfIcons.filter,
        title: l10n.wvNoMatch,
        actionLabel: l10n.wvClearFilters,
        onAction: () {
          ref.read(activeFilterProvider(projectId).notifier).clear();
          ref.read(viewSearchProvider(projectId).notifier).set('');
        },
      );
    }
    return TfEmpty(
      key: const Key('no-tasks'),
      icon: TfIcons.list,
      title: l10n.wvNoTasks,
      message: l10n.wvNoTasksHint,
      actionLabel: onAddTask == null ? null : l10n.wvAddFirstTask,
      onAction: onAddTask,
    );
  }
}

/// The load failed and there is nothing to show: why, and a retry.
class WorkError extends StatelessWidget {
  const WorkError({
    super.key,
    required this.error,
    required this.onRetry,
    required this.retryKey,
  });

  final Object error;
  final VoidCallback onRetry;
  final Key retryKey;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(TfSpace.lg),
    child: Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: TfBanner(
          key: const Key('work-error'),
          kind: TfBannerKind.danger,
          message:
              '${context.l10n.wvLoadFailed}. ${taskErrorMessage(error, context.l10n)}',
          actionLabel: context.l10n.retry,
          actionKey: retryKey,
          onAction: onRetry,
        ),
      ),
    ),
  );
}

/// Placeholder columns for a loading board (three, with a few cards each).
class BoardSkeleton extends StatelessWidget {
  const BoardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.tf.colors;
    return SingleChildScrollView(
      key: const Key('board-loading'),
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(TfSpace.xs),
      // Scrollable (never by hand) so a short screen cuts the columns off
      // instead of overflowing.
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var column = 0; column < 3; column++)
              Container(
                width: 280,
                margin: const EdgeInsets.all(TfSpace.xs),
                padding: const EdgeInsets.all(TfSpace.sm),
                decoration: BoxDecoration(
                  color: c.sunken,
                  borderRadius: TfRadius.panel,
                  border: Border.all(color: c.border, width: tfHairline),
                ),
                child: Column(
                  spacing: TfSpace.sm,
                  children: [
                    const Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: TfSkeleton(width: 96),
                    ),
                    for (var card = 0; card < 3 - column; card++)
                      Container(
                        height: 72,
                        padding: const EdgeInsets.all(TfSpace.md),
                        decoration: BoxDecoration(
                          color: c.surface,
                          borderRadius: TfRadius.panel,
                          border: Border.all(
                            color: c.border,
                            width: tfHairline,
                          ),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: TfSpace.sm,
                          children: [TfSkeleton(width: 40), TfSkeleton()],
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
