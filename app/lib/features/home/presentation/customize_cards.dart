import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskforge/core/ui/tokens/spacing.dart';
import 'package:material_ui/material_ui.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/core/ui/tf/tf_button.dart';
import 'package:taskforge/core/ui/tf/tf_checkbox.dart';
import 'package:taskforge/core/ui/tf/tf_overlays.dart';
import 'package:taskforge/core/ui/tf_icons.dart';
import 'package:taskforge/features/home/application/home_providers.dart';
import 'package:taskforge/l10n/gen/app_localizations.dart';

String cardTitle(AppLocalizations l, String id) => switch (id) {
  'checklist' => l.homeCardChecklist,
  'today' => l.homeCardToday,
  'assigned' => l.homeCardAssigned,
  'mentions' => l.homeCardMentions,
  'recent' => l.homeCardRecent,
  'time' => l.homeCardTime,
  'pinned' => l.homeCardPinned,
  _ => id,
};

/// Show, hide and reorder the cards (kept on this device).
Future<void> showCustomizeCards(BuildContext context) => showTfDialog<void>(
  context,
  title: context.l10n.homeCustomizeTitle,
  body: const _CustomizeBody(),
  actions: [
    Consumer(
      builder: (context, ref, _) => TfButton(
        key: const Key('home-customize-reset'),
        label: context.l10n.homeReset,
        onPressed: ref.read(homeCardsProvider.notifier).reset,
      ),
    ),
    TfButton(
      key: const Key('home-customize-done'),
      label: context.l10n.grpIClose,
      variant: TfButtonVariant.primary,
      onPressed: () => Navigator.of(context).pop(),
    ),
  ],
);

class _CustomizeBody extends ConsumerWidget {
  const _CustomizeBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final cards = ref.watch(homeCardsProvider);
    final notifier = ref.read(homeCardsProvider.notifier);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.homeCustomizeHint),
        const SizedBox(height: TfSpace.md),
        for (var i = 0; i < cards.order.length; i++)
          Row(
            key: Key('home-customize-${cards.order[i]}'),
            children: [
              Expanded(
                child: TfCheckbox(
                  label: cardTitle(l, cards.order[i]),
                  value: !cards.hidden.contains(cards.order[i]),
                  onChanged: (on) => on
                      ? notifier.show(cards.order[i])
                      : notifier.hide(cards.order[i]),
                ),
              ),
              TfIconButton(
                key: Key('home-up-${cards.order[i]}'),
                icon: TfIcons.arrowUp,
                tooltip: l.homeCardMoveUp,
                size: TfButtonSize.small,
                onPressed: i == 0 ? null : () => notifier.reorder(i, i - 1),
              ),
              TfIconButton(
                key: Key('home-down-${cards.order[i]}'),
                icon: TfIcons.arrowDown,
                tooltip: l.homeCardMoveDown,
                size: TfButtonSize.small,
                onPressed: i == cards.order.length - 1
                    ? null
                    : () => notifier.reorder(i, i + 2),
              ),
            ],
          ),
      ],
    );
  }
}
