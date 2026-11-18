import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/core/ui/breakpoints.dart';
import 'package:taskforge/core/ui/content_width.dart';
import 'package:taskforge/core/ui/tf/tf_button.dart';
import 'package:taskforge/core/ui/tf/tf_checkbox.dart';
import 'package:taskforge/core/ui/tf/tf_feedback.dart';
import 'package:taskforge/core/ui/tf/tf_illustration.dart';
import 'package:taskforge/core/ui/tf/tf_tabs.dart';
import 'package:taskforge/core/ui/tf_app_bar.dart';
import 'package:taskforge/core/ui/theme_extension.dart';
import 'package:taskforge/core/ui/tokens/spacing.dart';
import 'package:taskforge/features/filters/application/filters_providers.dart';
import 'package:taskforge/features/filters/presentation/filter_bar.dart';
import 'package:taskforge/features/home/application/home_providers.dart';
import 'package:taskforge/features/home/domain/home.dart';
import 'package:taskforge/features/home/presentation/home_task_row.dart';

/// Everything assigned to the person or watched by them, across projects,
/// with the shared filter, a relation switch and "include done", paged by
/// cursor.
class MyWorkScreen extends ConsumerWidget {
  const MyWorkScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final size = ScreenSize.of(context);
    return Scaffold(
      appBar: TfAppBar(title: Text(l.mwTitle)),
      body: ContentWidth(
        maxWidth: 960,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: pageGutter(size),
                vertical: TfSpace.sm,
              ),
              child: const _MyWorkToolbar(),
            ),
            const Expanded(child: _MyWorkList()),
          ],
        ),
      ),
    );
  }
}

class _MyWorkToolbar extends ConsumerWidget {
  const _MyWorkToolbar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final options = ref.watch(myWorkOptionsProvider);
    final notifier = ref.read(myWorkOptionsProvider.notifier);
    return Wrap(
      spacing: TfSpace.md,
      runSpacing: TfSpace.sm,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        TfSegmented<MyWorkRelation>(
          key: const Key('mywork-relation'),
          options: {
            MyWorkRelation.both: l.mwRelationBoth,
            MyWorkRelation.assigned: l.mwRelationAssigned,
            MyWorkRelation.watching: l.mwRelationWatching,
          },
          value: options.relation,
          onChanged: notifier.relation,
        ),
        const FilterBar(projectId: myWorkFilterScope, canShare: false),
        TfCheckbox(
          key: const Key('mywork-include-done'),
          label: l.mwIncludeDone,
          value: options.includeDone,
          onChanged: (on) => notifier.includeDone(on: on),
        ),
      ],
    );
  }
}

class _MyWorkList extends ConsumerWidget {
  const _MyWorkList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final state = ref.watch(myWorkProvider);
    final notifier = ref.read(myWorkProvider.notifier);
    final today = ref.watch(homeTodayProvider);
    final filtered = ref.watch(myWorkQueryProvider).filterAst.isNotEmpty;
    final items = state.page.items;
    if (state.loading && items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(TfSpace.lg),
        child: HomeSkeletonRows(),
      );
    }
    if (state.error != null && items.isEmpty) {
      return TfError(
        key: const Key('mywork-error'),
        message: l.mwFailed,
        details: '${state.error}',
        retryKey: const Key('mywork-retry'),
        onRetry: notifier.reload,
      );
    }
    if (items.isEmpty) {
      return filtered
          ? TfEmpty(
              key: const Key('mywork-no-match'),
              illustration: TfIllustrationKind.search,
              title: l.mwNoMatch,
              actionLabel: l.mwClearFilter,
              onAction: ref
                  .read(activeFilterProvider(myWorkFilterScope).notifier)
                  .clear,
            )
          : TfEmpty(
              key: const Key('mywork-empty'),
              illustration: TfIllustrationKind.tasks,
              title: l.mwEmpty,
              message: l.mwEmptyHint,
            );
    }
    return RefreshIndicator(
      onRefresh: notifier.reload,
      child: ListView(
        key: const Key('mywork-list'),
        padding: const EdgeInsets.symmetric(horizontal: TfSpace.sm),
        children: [
          if (state.stale)
            Padding(
              padding: const EdgeInsets.all(TfSpace.sm),
              child: Text(
                l.homeStaleNoTime,
                key: const Key('mywork-stale'),
                style: context.tf.typography.small.copyWith(
                  color: context.tf.colors.textSubtle,
                ),
              ),
            ),
          for (final item in items)
            HomeTaskRow(
              task: item.task,
              today: today,
              notes: [
                if (item.assigned) l.mwAssigned,
                if (item.watching) l.mwWatching,
              ],
            ),
          if (state.error != null)
            TfError(
              key: const Key('mywork-more-error'),
              compact: true,
              message: l.mwFailed,
              details: '${state.error}',
              retryKey: const Key('mywork-more-retry'),
              onRetry: notifier.loadMore,
            ),
          if (state.page.hasMore)
            Padding(
              padding: const EdgeInsets.all(TfSpace.md),
              child: Center(
                child: TfButton(
                  key: const Key('mywork-load-more'),
                  label: l.mwLoadMore,
                  loading: state.loadingMore,
                  onPressed: state.loadingMore ? null : notifier.loadMore,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Placeholder rows while My work loads.
class HomeSkeletonRows extends StatelessWidget {
  const HomeSkeletonRows({super.key});

  @override
  Widget build(BuildContext context) => Column(
    key: const Key('mywork-skeleton'),
    children: [
      for (var i = 0; i < 6; i++)
        const Padding(
          padding: EdgeInsets.symmetric(vertical: TfSpace.sm),
          child: Row(
            spacing: TfSpace.md,
            children: [
              TfSkeleton(width: 56),
              Expanded(child: TfSkeleton(height: 14)),
              TfSkeleton(width: 72),
            ],
          ),
        ),
    ],
  );
}
