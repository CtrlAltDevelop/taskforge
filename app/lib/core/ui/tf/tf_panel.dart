import 'package:material_ui/material_ui.dart';

import 'package:taskforge/core/ui/theme_extension.dart';
import 'package:taskforge/core/ui/tokens/shape.dart';
import 'package:taskforge/core/ui/tokens/spacing.dart';
import 'package:taskforge/core/ui/tokens/typography.dart';

/// A grouped block on the canvas: surface fill, hairline border, no shadow.
class TfPanel extends StatelessWidget {
  const TfPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(TfSpace.lg),
    this.raised = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  /// A panel that floats (menus, popovers) uses the raised fill.
  final bool raised;

  @override
  Widget build(BuildContext context) {
    final c = context.tf.colors;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: raised ? c.raised : c.surface,
        borderRadius: TfRadius.panel,
        border: Border.all(color: c.border, width: tfHairline),
      ),
      child: child,
    );
  }
}

/// A title for a group of rows, with an optional count and trailing action.
class TfSectionHeader extends StatelessWidget {
  const TfSectionHeader({
    super.key,
    required this.title,
    this.count,
    this.trailing,
  });

  final String title;
  final int? count;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final tf = context.tf;
    final c = tf.colors;
    return Padding(
      padding: EdgeInsetsDirectional.symmetric(
        horizontal: tf.density.padX,
        vertical: TfSpace.sm,
      ),
      child: Row(
        children: [
          Flexible(
            child: Semantics(
              header: true,
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: tf.typography.label.copyWith(
                  color: c.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          if (count != null) ...[
            const SizedBox(width: TfSpace.sm),
            Text(
              '$count',
              style: tf.typography.tabular.copyWith(
                color: c.textSubtle,
                fontSize: TfFontSize.small,
              ),
            ),
          ],
          if (trailing != null) ...[const Spacer(), trailing!],
        ],
      ),
    );
  }
}
