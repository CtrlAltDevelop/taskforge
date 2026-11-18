import 'package:material_ui/material_ui.dart';

import 'package:taskforge/core/ui/theme_extension.dart';
import 'package:taskforge/core/ui/tf/tf_interactive.dart';
import 'package:taskforge/core/ui/tf_icons.dart';
import 'package:taskforge/core/ui/tokens/colors.dart';
import 'package:taskforge/core/ui/tokens/spacing.dart';

enum TfButtonVariant { primary, secondary, ghost, danger }

enum TfButtonSize {
  small(-8),
  medium(0),
  large(8);

  const TfButtonSize(this.extraHeight);
  final double extraHeight;
}

/// The one button. Primary is the single accent action on a screen.
class TfButton extends StatelessWidget {
  const TfButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = TfButtonVariant.secondary,
    this.size = TfButtonSize.medium,
    this.icon,
    this.loading = false,
    this.autofocus = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final TfButtonVariant variant;
  final TfButtonSize size;
  final TfIconData? icon;
  final bool loading;
  final bool autofocus;

  /// Colours for [variant] in state [s]: (fill, text, border).
  static (Color, Color, Color?) paint(
    TfColors c,
    TfButtonVariant v,
    Set<WidgetState> s,
  ) {
    final hot = s.contains(WidgetState.pressed)
        ? 0.16
        : (s.contains(WidgetState.hovered) ? 0.08 : 0.0);
    final onDanger = c.isDark ? c.canvas : c.surface;
    return switch (v) {
      TfButtonVariant.primary => (tfShade(c, c.accent, hot), c.onAccent, null),
      TfButtonVariant.danger => (tfShade(c, c.danger.fg, hot), onDanger, null),
      TfButtonVariant.secondary => (
        hot > 0 ? tfShade(c, c.surface, hot / 2) : c.surface,
        c.text,
        c.borderStrong.withValues(alpha: 0.55),
      ),
      TfButtonVariant.ghost => (
        hot > 0 ? tfShade(c, c.canvas, hot) : tfClear,
        c.text,
        null,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final tf = context.tf;
    final c = tf.colors;
    final active = onPressed != null && !loading;
    final height = tf.density.controlHeight + size.extraHeight;
    return TfInteractive(
      onTap: active ? onPressed : null,
      autofocus: autofocus,
      semanticLabel: label,
      builder: (context, states) {
        final (fill, fg, line) = paint(c, variant, states);
        final disabled = onPressed == null;
        final text = tf.typography.label.copyWith(color: fg);
        return Opacity(
          opacity: disabled ? 0.5 : 1,
          child: TfSurface(
            height: height,
            fill: fill,
            border: line,
            focused: states.contains(WidgetState.focused),
            padding: EdgeInsetsDirectional.symmetric(
              horizontal: tf.density.padX + TfSpace.xs,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (loading)
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2, color: fg),
                  )
                else if (icon != null)
                  TfIcon(icon!, color: fg),
                if (loading || icon != null)
                  const SizedBox(width: TfSpace.sm - 2),
                Flexible(
                  child: Text(
                    label,
                    style: text,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// An icon-only button; [tooltip] is required because it is also the label.
class TfIconButton extends StatelessWidget {
  const TfIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.variant = TfButtonVariant.ghost,
    this.size = TfButtonSize.medium,
    this.selected = false,
  });

  final TfIconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final TfButtonVariant variant;
  final TfButtonSize size;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final tf = context.tf;
    final side = tf.density.controlHeight + size.extraHeight;
    return Tooltip(
      message: tooltip,
      child: TfInteractive(
        onTap: onPressed,
        selected: selected ? true : null,
        semanticLabel: tooltip,
        builder: (context, states) {
          final (fill, fg, line) = TfButton.paint(tf.colors, variant, states);
          return Opacity(
            opacity: onPressed == null ? 0.5 : 1,
            child: TfSurface(
              height: side,
              fill: selected ? tf.colors.selected : fill,
              border: line,
              focused: states.contains(WidgetState.focused),
              child: SizedBox(
                width: side,
                child: Center(
                  child: TfIcon(
                    icon,
                    color: selected ? tf.colors.accentTone.fg : fg,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
