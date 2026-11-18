import 'package:material_ui/material_ui.dart';

import 'package:taskforge/core/ui/theme_extension.dart';
import 'package:taskforge/core/ui/tf/tf_button.dart';
import 'package:taskforge/core/ui/tf_icons.dart';
import 'package:taskforge/core/ui/tokens/shape.dart';
import 'package:taskforge/core/ui/tokens/spacing.dart';

/// Nothing here yet: an icon, what this place is for, and the next step.
class TfEmpty extends StatelessWidget {
  const TfEmpty({
    super.key,
    required this.title,
    this.message,
    this.icon,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? message;
  final TfIconData? icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final tf = context.tf;
    final c = tf.colors;
    // Centred when there is room, scrolls when there is not (small panes, big text).
    return LayoutBuilder(
      builder: (context, box) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: box.hasBoundedHeight ? box.maxHeight : 0,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: Padding(
                padding: const EdgeInsets.all(TfSpace.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      TfIcon(icon!, size: 32, color: c.textSubtle),
                      const SizedBox(height: TfSpace.md),
                    ],
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: tf.typography.lead.copyWith(color: c.text),
                    ),
                    if (message != null) ...[
                      const SizedBox(height: TfSpace.xs),
                      Text(
                        message!,
                        textAlign: TextAlign.center,
                        style: tf.typography.body.copyWith(color: c.textMuted),
                      ),
                    ],
                    if (actionLabel != null) ...[
                      const SizedBox(height: TfSpace.lg),
                      TfButton(
                        label: actionLabel!,
                        onPressed: onAction,
                        variant: TfButtonVariant.primary,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A grey placeholder block shown while data loads. Static (no shimmer) so
/// it respects reduced motion by default.
class TfSkeleton extends StatelessWidget {
  const TfSkeleton({
    super.key,
    this.width,
    this.height = 12,
    this.circle = false,
  });

  final double? width;
  final double height;
  final bool circle;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: context.tf.colors.border,
        shape: circle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: circle ? null : TfRadius.chip,
      ),
    ),
  );
}
