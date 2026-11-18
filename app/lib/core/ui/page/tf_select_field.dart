import 'package:material_ui/material_ui.dart';

import 'package:taskforge/core/ui/page/tf_form.dart';
import 'package:taskforge/core/ui/theme_extension.dart';
import 'package:taskforge/core/ui/tf/tf_button.dart';
import 'package:taskforge/core/ui/tf/tf_interactive.dart';
import 'package:taskforge/core/ui/tf/tf_menu.dart';
import 'package:taskforge/core/ui/tf_icons.dart';
import 'package:taskforge/core/ui/tokens/spacing.dart';

/// A choice of one among [options] (value to label) as a button that opens a
/// [TfMenu], with an optional label above, helper and error text. [onChanged]
/// null disables it. Replaces `DropdownButton` and `DropdownButtonFormField`.
class TfSelectField<T> extends StatelessWidget {
  const TfSelectField({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
    this.label,
    this.hint = '',
    this.helper,
    this.errorText,
    this.expand = false,
    this.itemKey,
  });

  final Map<T, String> options;
  final T? value;
  final ValueChanged<T>? onChanged;
  final String? label;
  final String hint;
  final String? helper;
  final String? errorText;

  /// Fill the available width (form fields); false hugs the label (toolbars).
  final bool expand;

  /// A key for each menu entry, for tests and automation.
  final Key Function(T value)? itemKey;

  @override
  Widget build(BuildContext context) {
    final tf = context.tf;
    final c = tf.colors;
    final shown = options.containsKey(value) ? options[value] : null;
    final text = Text(
      shown ?? hint,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: tf.typography.label.copyWith(
        color: shown == null ? c.textSubtle : c.text,
      ),
    );
    final button = TfMenu(
      items: [
        for (final e in options.entries)
          TfMenuItem(
            key: itemKey?.call(e.key),
            label: e.value,
            selected: e.key == value,
            onSelected: onChanged == null ? null : () => onChanged!(e.key),
          ),
      ],
      builder: (context, toggle) => TfInteractive(
        onTap: onChanged == null || options.isEmpty ? null : toggle,
        semanticLabel: label == null
            ? (shown ?? hint)
            : '$label, ${shown ?? hint}',
        builder: (context, states) {
          final (fill, _, line) = TfButton.paint(
            c,
            TfButtonVariant.secondary,
            states,
          );
          return Opacity(
            opacity: onChanged == null ? 0.5 : 1,
            child: TfSurface(
              height: tf.density.controlHeight,
              fill: fill,
              border: errorText != null ? c.danger.fg : line,
              focused: states.contains(WidgetState.focused),
              padding: EdgeInsetsDirectional.only(
                start: tf.density.padX + TfSpace.xs,
                end: TfSpace.sm,
              ),
              child: Row(
                mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
                children: [
                  expand ? Expanded(child: text) : Flexible(child: text),
                  const SizedBox(width: TfSpace.sm),
                  TfIcon(TfIcons.chevronDown, color: c.textMuted),
                ],
              ),
            ),
          );
        },
      ),
    );
    if (label == null && helper == null && errorText == null) return button;
    return TfFormField(
      label: label,
      helper: helper,
      error: errorText,
      child: button,
    );
  }
}
