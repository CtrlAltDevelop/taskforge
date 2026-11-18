import 'package:material_ui/material_ui.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/core/ui/tf/tf_button.dart';
import 'package:taskforge/core/ui/tf/tf_chip.dart';
import 'package:taskforge/core/ui/tf/tf_menu.dart';
import 'package:taskforge/core/ui/tf_icons.dart';
import 'package:taskforge/core/ui/tokens/spacing.dart';
import 'package:taskforge/features/comments/domain/comments.dart';

/// The emoji people gave a message (tap to add yours or take it back) and a
/// button to add another.
class ReactionsRow extends StatelessWidget {
  const ReactionsRow({
    super.key,
    required this.id,
    required this.reactions,
    required this.me,
    required this.names,
    required this.canReact,
    required this.onReact,
  });

  final String id;

  /// Emoji -> ids of those who gave it.
  final Map<String, List<String>> reactions;
  final String me;
  final String Function(String) names;
  final bool canReact;
  final void Function(String) onReact;

  @override
  Widget build(BuildContext context) {
    if (reactions.isEmpty && !canReact) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: TfSpace.xs),
      child: Wrap(
        spacing: TfSpace.xs,
        runSpacing: TfSpace.xs,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          for (final e in reactions.entries)
            TfTooltip(
              message: e.value.map(names).join(', '),
              child: TfChip(
                key: Key('reaction-$id-${e.key}'),
                label: '${e.key} ${e.value.length}',
                selected: e.value.contains(me),
                onTap: canReact ? () => onReact(e.key) : null,
              ),
            ),
          if (canReact)
            TfMenu(
              items: [
                for (final e in quickReactions)
                  TfMenuItem(label: e, onSelected: () => onReact(e)),
              ],
              builder: (context, toggle) => TfIconButton(
                key: Key('react-$id'),
                icon: TfIcons.smile,
                tooltip: context.l10n.grpBAddReaction,
                size: TfButtonSize.small,
                onPressed: toggle,
              ),
            ),
        ],
      ),
    );
  }
}
