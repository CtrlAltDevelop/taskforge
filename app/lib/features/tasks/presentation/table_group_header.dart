import 'package:material_ui/material_ui.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/core/ui/tf/tf_interactive.dart';
import 'package:taskforge/core/ui/theme_extension.dart';
import 'package:taskforge/core/ui/tf_icons.dart';
import 'package:taskforge/core/ui/tokens/spacing.dart';
import 'package:taskforge/features/tasks/domain/list_rows.dart';
import 'package:taskforge/features/tasks/presentation/list_lookups.dart';

/// The line over a group of rows: fold arrow, the group's colour and name,
/// and how many tasks it holds. A click (or Enter) folds it.
class TableGroupHeader extends StatelessWidget {
  const TableGroupHeader({
    super.key,
    required this.group,
    required this.groupBy,
    required this.lookups,
    required this.height,
    required this.focused,
    required this.onToggle,
  });

  final GroupEntry group;
  final String groupBy;
  final ListLookups lookups;
  final double height;

  /// The keyboard cursor is on this line.
  final bool focused;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final tf = context.tf;
    final c = tf.colors;
    final color = lookups.groupColor(groupBy, group.key);
    return TfInteractive(
      key: Key('group-${group.key}'),
      onTap: onToggle,
      button: false,
      semanticLabel: lookups.groupLabel(groupBy, group.key, context.l10n),
      builder: (context, states) => Container(
        height: height,
        padding: const EdgeInsetsDirectional.only(start: TfSpace.sm),
        decoration: BoxDecoration(
          color: states.contains(WidgetState.hovered) ? c.hover : c.sunken,
          border: focused ? tfFocusRing(c) : null,
        ),
        child: Row(
          children: [
            TfIcon(
              group.collapsed ? TfIcons.chevronEnd : TfIcons.chevronDown,
              color: c.textMuted,
            ),
            const SizedBox(width: TfSpace.xs),
            if (color != null) ...[
              TfIcon(TfIcons.circle, size: 10, color: color),
              const SizedBox(width: TfSpace.xs + TfSpace.xxs),
            ],
            Flexible(
              child: Text(
                lookups.groupLabel(groupBy, group.key, context.l10n),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: tf.typography.bodyStrong.copyWith(color: c.text),
              ),
            ),
            const SizedBox(width: TfSpace.sm),
            Text(
              '${group.count}',
              key: Key('group-count-${group.key}'),
              style: tf.typography.tabular.copyWith(color: c.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
