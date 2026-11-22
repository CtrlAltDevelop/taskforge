import 'package:material_ui/material_ui.dart';

import 'package:taskforge/core/ui/theme_extension.dart';
import 'package:taskforge/core/ui/tf/tf_checkbox.dart';
import 'package:taskforge/core/ui/tf/tf_interactive.dart';
import 'package:taskforge/core/ui/tokens/shape.dart';
import 'package:taskforge/core/ui/tokens/spacing.dart';

/// A [TfRow] whose title and subtitle are widgets (rich text, wrapped chips,
/// selectable text). Use [TfRow] when plain strings are enough.
class TfTile extends StatelessWidget {
  const TfTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.selected = false,
    this.checked,
    this.inGroup = false,
    this.semanticLabel,
  });

  /// Radio rows: whether this choice is the chosen one, and that it belongs to
  /// a group. [semanticLabel] then replaces the children's own text.
  final bool? checked;
  final bool inGroup;
  final String? semanticLabel;

  final Widget title;
  final Widget? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final tf = context.tf;
    final c = tf.colors;
    return TfInteractive(
      onTap: onTap,
      onLongPress: onLongPress,
      selected: selected ? true : null,
      checked: checked,
      inGroup: inGroup,
      semanticLabel: semanticLabel,
      button: onTap != null && !inGroup,
      builder: (context, states) => Container(
        constraints: BoxConstraints(
          minHeight: tfTarget(context, tf.density.rowHeight),
        ),
        padding: EdgeInsetsDirectional.symmetric(
          horizontal: tf.density.padX,
          vertical: TfSpace.xs,
        ),
        decoration: BoxDecoration(
          color: selected
              ? c.selected
              : (states.contains(WidgetState.hovered) ? c.hover : null),
          borderRadius: TfRadius.control,
          border: states.contains(WidgetState.focused) ? tfFocusRing(c) : null,
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
                    DefaultTextStyle.merge(
                      style: tf.typography.body.copyWith(color: c.text),
                      child: title,
                    ),
                    if (subtitle != null)
                      DefaultTextStyle.merge(
                        style: tf.typography.small.copyWith(color: c.textMuted),
                        child: subtitle!,
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
      ),
    );
  }
}

/// A switch ([checkbox] false) or checkbox row with a title and a line of help
/// under it; the whole row toggles. Replaces `SwitchListTile` and
/// `CheckboxListTile`.
class TfToggleTile extends StatelessWidget {
  const TfToggleTile({
    super.key,
    required this.value,
    required this.onChanged,
    required this.title,
    this.subtitle,
    this.checkbox = false,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final String title;
  final String? subtitle;
  final bool checkbox;

  @override
  Widget build(BuildContext context) {
    final control = ExcludeSemantics(
      child: IgnorePointer(
        child: checkbox
            ? TfCheckbox(value: value, onChanged: onChanged)
            : TfToggle(value: value, onChanged: onChanged),
      ),
    );
    return TfInteractive(
      onTap: onChanged == null ? null : () => onChanged!(!value),
      button: false,
      toggled: checkbox ? null : value,
      checked: checkbox ? value : null,
      semanticLabel: subtitle == null ? title : '$title. $subtitle',
      builder: (context, states) {
        final tf = context.tf;
        final c = tf.colors;
        return Opacity(
          opacity: onChanged == null ? 0.5 : 1,
          child: Container(
            constraints: BoxConstraints(
              minHeight: tfTarget(context, tf.density.rowHeight),
            ),
            padding: EdgeInsetsDirectional.symmetric(
              horizontal: tf.density.padX,
              vertical: TfSpace.xs,
            ),
            decoration: BoxDecoration(
              color: states.contains(WidgetState.hovered) ? c.hover : null,
              borderRadius: TfRadius.control,
              border: states.contains(WidgetState.focused)
                  ? tfFocusRing(c)
                  : null,
            ),
            child: Row(
              children: [
                if (checkbox) ...[control, const SizedBox(width: TfSpace.md)],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: tf.typography.body.copyWith(color: c.text),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          style: tf.typography.small.copyWith(
                            color: c.textMuted,
                          ),
                        ),
                    ],
                  ),
                ),
                if (!checkbox) ...[const SizedBox(width: TfSpace.md), control],
              ],
            ),
          ),
        );
      },
    );
  }
}

/// One choice of a [RadioGroup] as a row: radio, title and a line of help;
/// the whole row picks it. Replaces `RadioListTile`.
class TfRadioTile<T> extends StatelessWidget {
  const TfRadioTile({
    super.key,
    required this.value,
    required this.title,
    this.subtitle,
    this.enabled = true,
  });

  final T value;
  final String title;
  final String? subtitle;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final registry = RadioGroup.maybeOf<T>(context);
    final tf = context.tf;
    final chosen = registry?.groupValue == value;
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: TfTile(
        selected: chosen,
        checked: chosen,
        inGroup: true,
        semanticLabel: subtitle == null ? title : '$title. $subtitle',
        // The row is the one tab stop and the one thing announced; the radio
        // inside only paints.
        leading: ExcludeFocus(
          child: ExcludeSemantics(
            child: IgnorePointer(child: Radio<T>(value: value)),
          ),
        ),
        title: Text(title, style: tf.typography.body),
        subtitle: subtitle == null ? null : Text(subtitle!),
        onTap: !enabled || registry == null
            ? null
            : () => registry.onChanged(value),
      ),
    );
  }
}
