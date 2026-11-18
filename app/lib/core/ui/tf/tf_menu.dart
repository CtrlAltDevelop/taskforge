import 'package:material_ui/material_ui.dart';

import 'package:taskforge/core/ui/theme_extension.dart';
import 'package:taskforge/core/ui/tf/tf_button.dart';
import 'package:taskforge/core/ui/tf/tf_interactive.dart';
import 'package:taskforge/core/ui/tf/tf_key_hint.dart';
import 'package:taskforge/core/ui/tf_icons.dart';
import 'package:taskforge/core/ui/tokens/shape.dart';
import 'package:taskforge/core/ui/tokens/spacing.dart';

/// One entry of a [TfMenu]. [shortcut] is shown as key caps.
class TfMenuItem {
  const TfMenuItem({
    this.key,
    required this.label,
    required this.onSelected,
    this.icon,
    this.shortcut,
    this.danger = false,
    this.selected = false,
  });

  final Key? key;
  final String label;
  final VoidCallback? onSelected;
  final TfIconData? icon;
  final String? shortcut;
  final bool danger;
  final bool selected;
}

/// A popover menu opened from [builder] (usually a button). Arrow keys move,
/// Enter picks, Escape closes (MenuAnchor).
class TfMenu extends StatelessWidget {
  const TfMenu({super.key, required this.items, required this.builder});

  final List<TfMenuItem> items;
  final Widget Function(BuildContext context, VoidCallback toggle) builder;

  @override
  Widget build(BuildContext context) {
    final tf = context.tf;
    final c = tf.colors;
    return MenuAnchor(
      // A click outside only closes the menu; it does not also hit what is
      // under it (a window's backdrop, a row).
      consumeOutsideTap: true,
      style: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(c.raised),
        surfaceTintColor: const WidgetStatePropertyAll(Color(0x00000000)),
        shadowColor: WidgetStatePropertyAll(TfShadow.popover.first.color),
        elevation: const WidgetStatePropertyAll(6), // popover shadow
        padding: const WidgetStatePropertyAll(EdgeInsets.all(TfSpace.xs)),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: TfRadius.panel,
            side: BorderSide(color: c.border),
          ),
        ),
      ),
      menuChildren: [
        for (final item in items)
          MenuItemButton(
            key: item.key,
            onPressed: item.onSelected,
            leadingIcon: item.icon == null
                ? null
                : TfIcon(
                    item.icon!,
                    color: item.danger ? c.danger.fg : c.textMuted,
                  ),
            trailingIcon: item.shortcut != null
                ? TfKeyHint(item.shortcut!)
                : (item.selected
                      ? TfIcon(TfIcons.check, color: c.accent)
                      : null),
            style: ButtonStyle(
              minimumSize: WidgetStatePropertyAll(
                Size(160, tf.density.rowHeight),
              ),
              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(borderRadius: TfRadius.control),
              ),
              overlayColor: WidgetStatePropertyAll(c.hover),
              foregroundColor: WidgetStatePropertyAll(
                item.danger ? c.danger.fg : c.text,
              ),
              textStyle: WidgetStatePropertyAll(tf.typography.body),
            ),
            child: Text(item.label),
          ),
      ],
      builder: (context, controller, _) => builder(
        context,
        () => controller.isOpen ? controller.close() : controller.open(),
      ),
    );
  }
}

/// A button that opens a [TfMenu] of choices and shows the current one.
class TfSelect<T> extends StatelessWidget {
  const TfSelect({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
    this.hint = '',
  });

  final Map<T, String> options;
  final T? value;
  final ValueChanged<T> onChanged;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final c = context.tf.colors;
    return TfMenu(
      items: [
        for (final e in options.entries)
          TfMenuItem(
            label: e.value,
            selected: e.key == value,
            onSelected: () => onChanged(e.key),
          ),
      ],
      builder: (context, toggle) => TfInteractive(
        onTap: toggle,
        semanticLabel: options[value] ?? hint,
        builder: (context, states) {
          final (fill, fg, line) = TfButton.paint(
            c,
            TfButtonVariant.secondary,
            states,
          );
          return TfSurface(
            height: context.tf.density.controlHeight,
            fill: fill,
            border: line,
            focused: states.contains(WidgetState.focused),
            padding: EdgeInsetsDirectional.only(
              start: context.tf.density.padX + TfSpace.xs,
              end: TfSpace.sm,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    options[value] ?? hint,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.tf.typography.label.copyWith(
                      color: value == null ? c.textSubtle : fg,
                    ),
                  ),
                ),
                const SizedBox(width: TfSpace.sm),
                TfIcon(TfIcons.chevronDown, color: c.textMuted),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Wraps [child] with a styled tooltip; the message is also its semantic label.
class TfTooltip extends StatelessWidget {
  const TfTooltip({super.key, required this.message, required this.child});

  final String message;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tf = context.tf;
    final c = tf.colors;
    return Tooltip(
      message: message,
      waitDuration: const Duration(milliseconds: 400),
      decoration: BoxDecoration(
        color: c.isDark ? c.raised : c.text,
        borderRadius: TfRadius.chip,
        border: c.isDark ? Border.all(color: c.border) : null,
      ),
      textStyle: tf.typography.small.copyWith(
        color: c.isDark ? c.text : c.surface,
      ),
      child: child,
    );
  }
}
