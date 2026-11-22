import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/core/ui/breakpoints.dart';
import 'package:taskforge/core/ui/tf/tf_button.dart';
import 'package:taskforge/core/ui/tf/tf_feedback.dart';
import 'package:taskforge/core/ui/frame_scope.dart';
import 'package:taskforge/core/ui/tf_app_bar.dart';
import 'package:taskforge/core/ui/tf_icons.dart';
import 'package:taskforge/core/ui/tokens/spacing.dart';
import 'package:taskforge/features/home/application/home_providers.dart';
import 'package:taskforge/features/home/presentation/checklist_card.dart';
import 'package:taskforge/features/home/presentation/customize_cards.dart';
import 'package:taskforge/features/home/presentation/home_cards.dart';
import 'package:taskforge/features/home/presentation/home_greeting.dart';
import 'package:taskforge/features/home/presentation/sample_banner.dart';
import 'package:taskforge/features/system/presentation/version_screens.dart';
import 'package:taskforge/features/system/presentation/whats_new.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';
import 'package:taskforge/features/system/presentation/status_screens.dart';
import 'package:taskforge/features/workspaces/domain/workspace.dart';

/// Columns for a screen size: one on a phone, two on a tablet, three on a
/// desktop.
int homeColumns(ScreenSize size) => switch (size) {
  ScreenSize.compact => 1,
  ScreenSize.medium => 2,
  ScreenSize.expanded => 3,
};

Widget _card(String id) => switch (id) {
  'checklist' => const ChecklistCard(),
  'today' => const TodayCard(),
  'assigned' => const AssignedCard(),
  'mentions' => const MentionsCard(),
  'recent' => const RecentCard(),
  'time' => const TimeCard(),
  'pinned' => const PinnedCard(),
  _ => const SizedBox.shrink(),
};

/// Home: a greeting and the cards. Every card loads and fails on its own, so
/// one slow or broken read never blanks the screen.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspaces = ref.watch(workspacesProvider);
    if (workspaces.hasError && !workspaces.hasValue) {
      final failure = workspaces.error;
      if (failure is WorkspaceException) {
        if (failure.failure == WorkspaceFailure.maintenance) {
          return MaintenanceScreen(
            onRetry: () => ref.invalidate(workspacesProvider),
          );
        }
        if (failure.failure == WorkspaceFailure.network) {
          return NoConnectionScreen(
            onRetry: () => ref.invalidate(workspacesProvider),
          );
        }
      }
      return Scaffold(
        body: TfError(
          message: context.l10n.homeLoadWorkspacesFailed,
          details: '${workspaces.error}',
          retryKey: const Key('retry-workspaces'),
          onRetry: () => ref.invalidate(workspacesProvider),
        ),
      );
    }
    if (!workspaces.hasValue) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final cards = ref.watch(homeCardsProvider);
    final checklist = ref.watch(onboardingProvider);
    // No hole where the checklist would be once it is done or dismissed.
    final shown = [
      for (final id in cards.shown)
        if (id != 'checklist' ||
            (checklist.value?.visible ?? !checklist.hasError))
          id,
    ];
    final size = ScreenSize.of(context);
    final gutter = pageGutter(size);
    return Scaffold(
      // A framed phone's top bar already names the page: no empty bar under it.
      appBar:
          (AppFrameScope.maybeOf(context)?.hasAccountMenu ?? false) &&
              size.isCompact
          ? null
          : TfAppBar(title: Text(context.l10n.grpKTHome)),
      body: WhatsNewHost(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(homeSummaryProvider);
            ref.invalidate(homeAssignedProvider);
            ref.invalidate(onboardingProvider);
            try {
              await ref.read(homeSummaryProvider.future);
            } on Object {
              // The card shows its own error.
            }
          },
          child: ListView(
            key: const Key('home-list'),
            padding: EdgeInsets.all(gutter),
            children: [
              const DesktopUpdateNotice(),
              const SampleBanner(),
              Row(
                children: [
                  const Expanded(child: HomeGreeting()),
                  TfButton(
                    key: const Key('home-customize'),
                    label: context.l10n.homeCustomize,
                    icon: TfIcons.tune,
                    size: TfButtonSize.small,
                    variant: TfButtonVariant.ghost,
                    onPressed: () => showCustomizeCards(context),
                  ),
                ],
              ),
              const SizedBox(height: TfSpace.lg),
              _CardGrid(ids: shown, columns: homeColumns(size)),
            ],
          ),
        ),
      ),
    );
  }
}

/// [ids] dealt into [columns] columns in turn, so the order reads across.
class _CardGrid extends StatelessWidget {
  const _CardGrid({required this.ids, required this.columns});

  final List<String> ids;
  final int columns;

  @override
  Widget build(BuildContext context) {
    if (ids.isEmpty) {
      return TfEmpty(
        key: const Key('home-all-hidden'),
        compact: true,
        title: context.l10n.homeAllHidden,
        actionLabel: context.l10n.homeCustomize,
        onAction: () => showCustomizeCards(context),
      );
    }
    final lists = List.generate(columns, (_) => <Widget>[]);
    for (var i = 0; i < ids.length; i++) {
      lists[i % columns].add(
        Padding(
          key: Key('home-card-${ids[i]}'),
          padding: const EdgeInsets.only(bottom: TfSpace.md),
          child: _card(ids[i]),
        ),
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var c = 0; c < columns; c++) ...[
          if (c > 0) const SizedBox(width: TfSpace.md),
          Expanded(child: Column(children: lists[c])),
        ],
      ],
    );
  }
}
