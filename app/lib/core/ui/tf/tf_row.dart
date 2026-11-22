import 'package:material_ui/material_ui.dart';

import 'package:taskforge/core/ui/theme_extension.dart';
import 'package:taskforge/core/ui/tf/tf_interactive.dart';
import 'package:taskforge/core/ui/tokens/shape.dart';
import 'package:taskforge/core/ui/tokens/spacing.dart';
import 'package:taskforge/core/ui/tokens/colors.dart';

/// A dense row for lists and tables: leading, title + subtitle, trailing.
/// Height follows the density; hover and selection fill the whole row.
class TfRow extends StatelessWidget {
  const TfRow({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.selected = false,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final tf = context.tf;
    final c = tf.colors;
    return TfInteractive(
      onTap: onTap,
      selected: selected ? true : null,
      button: onTap != null,
      builder: (context, states) {
        final fill = selected
            ? c.selected
            : (states.contains(WidgetState.hovered) ? c.hover : tfClear);
        return Container(
          constraints: BoxConstraints(
            minHeight: tfTarget(context, tf.density.rowHeight),
          ),
          padding: EdgeInsetsDirectional.symmetric(
            horizontal: tf.density.padX,
            vertical: TfSpace.xs,
          ),
          decoration: BoxDecoration(
            color: fill,
            borderRadius: TfRadius.control,
            border: states.contains(WidgetState.focused)
                ? tfFocusRing(c)
                : null,
          ),
          child: LayoutBuilder(
            builder: (context, box) => Row(
              children: [
                if (leading != null) ...[
                  leading!,
                  const SizedBox(width: TfSpace.md),
                ],
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: tf.typography.body.copyWith(color: c.text),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: tf.typography.small.copyWith(
                            color: c.textMuted,
                          ),
                        ),
                    ],
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: TfSpace.md),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: box.maxWidth * 0.6),
                    child: trailing!,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

/// A table row: fixed-width-friendly cells laid out by the caller, with the
/// same hover, selection and focus as [TfRow], and a hairline below.
class TfTableRow extends StatelessWidget {
  const TfTableRow({
    super.key,
    required this.cells,
    this.onTap,
    this.selected = false,
    this.header = false,
  });

  final List<Widget> cells;
  final VoidCallback? onTap;
  final bool selected;

  /// A column-heading row: muted label type, no hover.
  final bool header;

  @override
  Widget build(BuildContext context) {
    final tf = context.tf;
    final c = tf.colors;
    final style = header
        ? tf.typography.caption.copyWith(
            color: c.textMuted,
            fontWeight: FontWeight.w600,
          )
        : tf.typography.body.copyWith(color: c.text);
    return TfInteractive(
      onTap: header ? null : onTap,
      selected: selected ? true : null,
      button: onTap != null && !header,
      builder: (context, states) => Container(
        constraints: BoxConstraints(
          minHeight: header ? tf.density.rowHeight - 4 : tf.density.rowHeight,
        ),
        padding: EdgeInsetsDirectional.symmetric(horizontal: tf.density.padX),
        decoration: BoxDecoration(
          color: selected
              ? c.selected
              : (states.contains(WidgetState.hovered) ? c.hover : null),
          border: Border(
            bottom: BorderSide(color: c.border, width: tfHairline),
          ),
          boxShadow: const [],
        ),
        foregroundDecoration: states.contains(WidgetState.focused)
            ? BoxDecoration(border: tfFocusRing(c))
            : null,
        child: DefaultTextStyle(
          style: style,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: cells,
          ),
        ),
      ),
    );
  }
}
