import 'package:material_ui/material_ui.dart';

import 'package:taskforge/core/ui/theme_extension.dart';
import 'package:taskforge/core/ui/tf/tf_interactive.dart';
import 'package:taskforge/core/ui/tf/tf_menu.dart';
import 'package:taskforge/core/ui/tf_icons.dart';
import 'package:taskforge/core/ui/tokens/shape.dart';
import 'package:taskforge/core/ui/tokens/spacing.dart';

/// Width of the label column of the Details grid.
const detailLabelWidth = 108.0;

/// One line of the Details grid: a muted label, then the value (which edits
/// in place when clicked).
class DetailRow extends StatelessWidget {
  const DetailRow({
    super.key,
    required this.label,
    required this.child,
    this.icon,
    this.hint,
  });

  final String label;
  final TfIconData? icon;
  final Widget child;

  /// A line under the value: why it cannot change, or what it needs.
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final tf = context.tf;
    final c = tf.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: TfSpace.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: detailLabelWidth,
            height: tf.density.controlHeight,
            child: Row(
              spacing: TfSpace.sm,
              children: [
                if (icon != null) TfIcon(icon!, size: 14, color: c.textSubtle),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: tf.typography.label.copyWith(color: c.textMuted),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                child,
                if (hint != null)
                  Padding(
                    padding: const EdgeInsets.only(top: TfSpace.xs),
                    child: Text(
                      hint!,
                      style: tf.typography.small.copyWith(color: c.textMuted),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A value that looks like text and becomes a control when pointed at.
/// Without [onTap] it is read-only; [readOnlyReason] then says why, in a
/// tooltip (a field the person may not edit is shown, never hidden).
class ValueButton extends StatelessWidget {
  const ValueButton({
    super.key,
    required this.child,
    required this.onTap,
    this.readOnlyReason,
    this.semanticLabel,
  });

  final Widget child;
  final VoidCallback? onTap;
  final String? readOnlyReason;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final tf = context.tf;
    final c = tf.colors;
    final body = TfInteractive(
      onTap: onTap,
      semanticLabel: semanticLabel,
      builder: (context, states) => Container(
        constraints: BoxConstraints(minHeight: tf.density.controlHeight),
        padding: const EdgeInsetsDirectional.symmetric(horizontal: TfSpace.sm),
        alignment: AlignmentDirectional.centerStart,
        decoration: BoxDecoration(
          color: states.contains(WidgetState.hovered) ? c.hover : null,
          borderRadius: TfRadius.control,
          border: states.contains(WidgetState.focused) ? tfFocusRing(c) : null,
        ),
        child: child,
      ),
    );
    final reason = readOnlyReason;
    final tip = onTap == null && reason != null
        ? TfTooltip(message: reason, child: body)
        : body;
    return Align(alignment: AlignmentDirectional.centerStart, child: tip);
  }
}

/// Text for a field with nothing in it.
class EmptyValue extends StatelessWidget {
  const EmptyValue(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: context.tf.typography.body.copyWith(
      color: context.tf.colors.textSubtle,
    ),
  );
}
