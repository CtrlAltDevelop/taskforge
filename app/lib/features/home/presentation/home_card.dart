import 'package:taskforge/core/i18n/context_dates.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/core/ui/theme_extension.dart';
import 'package:taskforge/core/ui/tf/tf_button.dart';
import 'package:taskforge/core/ui/tf/tf_feedback.dart';
import 'package:taskforge/core/ui/tf/tf_menu.dart';
import 'package:taskforge/core/ui/tf/tf_panel.dart';
import 'package:taskforge/core/ui/tf_icons.dart';
import 'package:taskforge/core/ui/tokens/spacing.dart';
import 'package:taskforge/features/home/application/home_providers.dart';
import 'package:taskforge/features/home/domain/home.dart';

/// The frame of one Home card: title, a menu to hide it, the stale mark when
/// the card shows a saved copy, and the card's own body.
class HomeCardFrame extends ConsumerWidget {
  const HomeCardFrame({
    super.key,
    required this.id,
    required this.title,
    required this.icon,
    required this.child,
    this.stale = false,
    this.computedAt = '',
    this.action,
  });

  final String id;
  final String title;
  final TfIconData icon;
  final Widget child;
  final bool stale;

  /// When the saved copy was made (ISO), shown with the stale mark.
  final String computedAt;

  /// A link in the title row, before the menu, e.g. "Open inbox".
  final Widget? action;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tf = context.tf;
    final c = tf.colors;
    final l = context.l10n;
    return TfPanel(
      padding: const EdgeInsets.all(TfSpace.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              TfIcon(icon, size: 18, color: c.textMuted),
              const SizedBox(width: TfSpace.sm),
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(
                    title,
                    style: tf.typography.lead.copyWith(color: c.text),
                  ),
                ),
              ),
              if (action != null) ...[
                const SizedBox(width: TfSpace.xs),
                action!,
              ],
              TfMenu(
                key: Key('home-card-menu-$id'),
                items: [
                  TfMenuItem(
                    key: Key('home-card-hide-$id'),
                    label: l.homeCardHide,
                    icon: TfIcons.eye,
                    onSelected: () =>
                        ref.read(homeCardsProvider.notifier).hide(id),
                  ),
                ],
                builder: (context, toggle) => TfIconButton(
                  icon: TfIcons.more,
                  tooltip: l.homeCardMenu,
                  size: TfButtonSize.small,
                  variant: TfButtonVariant.ghost,
                  onPressed: toggle,
                ),
              ),
            ],
          ),
          if (stale)
            Padding(
              padding: const EdgeInsets.only(top: TfSpace.xs),
              child: Row(
                key: Key('home-stale-$id'),
                children: [
                  TfIcon(TfIcons.cloudOff, size: 14, color: c.textSubtle),
                  const SizedBox(width: TfSpace.xs),
                  Expanded(
                    child: Text(
                      _staleText(context, computedAt),
                      style: tf.typography.small.copyWith(color: c.textSubtle),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: TfSpace.sm),
          child,
        ],
      ),
    );
  }

  static String _staleText(BuildContext context, String computedAt) {
    final at = DateTime.tryParse(computedAt)?.toLocal();
    return at == null
        ? context.l10n.homeStaleNoTime
        : context.l10n.homeStale('${context.localDate(at)} ${_hm(at)}');
  }

  static String _hm(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}

/// Turns an async read into a card body: a skeleton while loading, a compact
/// [TfError] with Retry on failure, [data] otherwise.
class HomeAsync<T> extends StatelessWidget {
  const HomeAsync({
    super.key,
    required this.value,
    required this.data,
    required this.onRetry,
    this.skeletonRows = 3,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final VoidCallback onRetry;
  final int skeletonRows;

  @override
  Widget build(BuildContext context) => value.when(
    skipLoadingOnReload: true,
    skipLoadingOnRefresh: true,
    loading: () => HomeSkeleton(rows: skeletonRows),
    error: (e, _) => TfError(
      compact: true,
      message: homeErrorMessage(e, context.l10n),
      details: '$e',
      retryKey: const Key('home-card-retry'),
      onRetry: onRetry,
    ),
    data: data,
  );
}

class HomeSkeleton extends StatelessWidget {
  const HomeSkeleton({super.key, this.rows = 3});

  final int rows;

  @override
  Widget build(BuildContext context) => Column(
    key: const Key('home-card-skeleton'),
    children: [
      for (var i = 0; i < rows; i++)
        const Padding(
          padding: EdgeInsets.symmetric(vertical: TfSpace.xs),
          child: Row(
            spacing: TfSpace.sm,
            children: [
              TfSkeleton(width: 48),
              Expanded(child: TfSkeleton(height: 12)),
              TfSkeleton(width: 56),
            ],
          ),
        ),
    ],
  );
}
