import 'package:material_ui/material_ui.dart';

import 'package:taskforge/core/ui/theme_extension.dart';
import 'package:taskforge/core/ui/tf/tf_button.dart';
import 'package:taskforge/core/ui/tf/tf_interactive.dart';
import 'package:taskforge/core/ui/tf_icons.dart';
import 'package:taskforge/core/ui/tokens/colors.dart';
import 'package:taskforge/core/ui/tokens/shape.dart';
import 'package:taskforge/core/ui/tokens/spacing.dart';

/// A small label on a soft fill: a filter, a value, a removable selection.
/// Tappable when [onTap] is set; [onRemove] adds an x button (its own focus
/// stop and tooltip), so [removeTooltip] is then required.
class TfChip extends StatelessWidget {
  const TfChip({
    super.key,
    required this.label,
    this.tone,
    this.icon,
    this.onTap,
    this.onRemove,
    this.removeTooltip,
    this.selected = false,
  }) : assert(onRemove == null || removeTooltip != null);

  final String label;
  final TfTone? tone;
  final TfIconData? icon;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;
  final String? removeTooltip;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final tf = context.tf;
    final c = tf.colors;
    final base = selected ? c.accentTone : (tone ?? c.neutral);
    final body = TfInteractive(
      onTap: onTap,
      button: onTap != null,
      selected: selected ? true : null,
      semanticLabel: label,
      builder: (context, states) {
        final hover = states.contains(WidgetState.hovered);
        return Container(
          constraints: BoxConstraints(minHeight: tf.density.controlHeight - 8),
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: TfSpace.sm,
          ),
          decoration: BoxDecoration(
            color: hover ? tfShade(c, base.bg, 0.06) : base.bg,
            borderRadius: TfRadius.chip,
            border: states.contains(WidgetState.focused)
                ? tfFocusRing(c)
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                TfIcon(icon!, size: 12, color: base.fg),
                const SizedBox(width: TfSpace.xs),
              ],
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: tf.typography.small.copyWith(
                    color: base.fg,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
    if (onRemove == null) return body;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(child: body),
        TfIconButton(
          icon: TfIcons.close,
          tooltip: removeTooltip!,
          onPressed: onRemove,
          size: TfButtonSize.small,
        ),
      ],
    );
  }
}

/// A coloured tag from the categorical palette (a label, a project colour).
class TfTag extends StatelessWidget {
  const TfTag({super.key, required this.label, required this.colorIndex});

  final String label;
  final int colorIndex;

  @override
  Widget build(BuildContext context) {
    final tf = context.tf;
    final k = tf.colors.category(colorIndex);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(color: k, borderRadius: TfRadius.chip),
          child: const SizedBox(width: 8, height: 8),
        ),
        const SizedBox(width: TfSpace.xs + 2),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: tf.typography.small.copyWith(color: tf.colors.text),
          ),
        ),
      ],
    );
  }
}

/// A count or dot on an icon (unread, notifications). Numbers use tabular figures.
class TfBadge extends StatelessWidget {
  const TfBadge({super.key, this.count, this.tone});

  /// Null draws a plain dot.
  final int? count;
  final TfTone? tone;

  @override
  Widget build(BuildContext context) {
    final tf = context.tf;
    final c = tf.colors;
    final fill = tone?.fg ?? c.accent;
    final fg = tone == null ? c.onAccent : (c.isDark ? c.canvas : c.surface);
    if (count == null) {
      return DecoratedBox(
        decoration: BoxDecoration(color: fill, shape: BoxShape.circle),
        child: const SizedBox(width: 8, height: 8),
      );
    }
    return Container(
      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
      padding: const EdgeInsets.symmetric(horizontal: TfSpace.xs),
      decoration: BoxDecoration(color: fill, borderRadius: TfRadius.panel),
      alignment: Alignment.center,
      child: Text(
        count! > 99 ? '99+' : '$count',
        style: tf.typography.tabular.copyWith(
          color: fg,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          height: 1.2,
        ),
      ),
    );
  }
}
