import 'package:material_ui/material_ui.dart';

import 'package:taskforge/core/ui/tokens/motion.dart';
import 'package:taskforge/core/ui/theme_extension.dart';
import 'package:taskforge/core/ui/tf/tf_interactive.dart';
import 'package:taskforge/core/ui/tf_icons.dart';
import 'package:taskforge/core/ui/tokens/shape.dart';
import 'package:taskforge/core/ui/tokens/spacing.dart';

/// A checkbox with an optional label; [value] null is the mixed state.
class TfCheckbox extends StatelessWidget {
  const TfCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
  });

  final bool? value;
  final ValueChanged<bool>? onChanged;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final tf = context.tf;
    final c = tf.colors;
    return TfInteractive(
      onTap: onChanged == null ? null : () => onChanged!(value != true),
      button: false,
      padTarget: true,
      checked: value == true,
      mixed: value == null,
      semanticLabel: label,
      builder: (context, states) {
        final on = value != false;
        final box = TfSurface(
          height: 16,
          touchTarget: false,
          fill: on ? c.accent : c.surface,
          border: on ? null : c.borderStrong,
          radius: TfRadius.chip,
          focused: states.contains(WidgetState.focused),
          child: SizedBox(
            width: 16,
            child: on
                ? TfIcon(
                    value == null ? TfIcons.minus : TfIcons.check,
                    size: 12,
                    color: c.onAccent,
                  )
                : null,
          ),
        );
        return Opacity(
          opacity: onChanged == null ? 0.5 : 1,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              box,
              if (label != null) ...[
                const SizedBox(width: TfSpace.sm),
                Flexible(
                  child: Text(
                    label!,
                    style: tf.typography.body.copyWith(color: c.text),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

/// An on/off switch with an optional label.
class TfToggle extends StatelessWidget {
  const TfToggle({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final tf = context.tf;
    final c = tf.colors;
    return TfInteractive(
      onTap: onChanged == null ? null : () => onChanged!(!value),
      button: false,
      padTarget: true,
      toggled: value,
      semanticLabel: label,
      builder: (context, states) {
        final track = AnimatedContainer(
          duration: TfMotion.of(context, TfDuration.fast),
          width: 32,
          height: 18,
          padding: const EdgeInsets.all(2),
          alignment: value
              ? AlignmentDirectional.centerEnd
              : AlignmentDirectional.centerStart,
          decoration: BoxDecoration(
            color: value ? c.accent : c.borderStrong,
            borderRadius: BorderRadius.circular(9),
            border: states.contains(WidgetState.focused)
                ? tfFocusRing(c)
                : null,
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: value ? c.onAccent : c.surface,
              shape: BoxShape.circle,
            ),
            child: const SizedBox(width: 14, height: 14),
          ),
        );
        return Opacity(
          opacity: onChanged == null ? 0.5 : 1,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              track,
              if (label != null) ...[
                const SizedBox(width: TfSpace.sm),
                Flexible(
                  child: Text(
                    label!,
                    style: tf.typography.body.copyWith(color: c.text),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
