import 'package:material_ui/material_ui.dart';

import 'package:taskforge/core/ui/theme_extension.dart';
import 'package:taskforge/core/ui/tf/tf_button.dart';
import 'package:taskforge/core/ui/tf_icons.dart';
import 'package:taskforge/core/ui/tokens/colors.dart';
import 'package:taskforge/core/ui/tokens/motion.dart';
import 'package:taskforge/core/ui/tokens/shape.dart';
import 'package:taskforge/core/ui/tokens/spacing.dart';

enum TfBannerKind { info, success, warning, danger }

/// A message pinned to the top of a screen or panel: an icon, text, an
/// optional action and dismiss. Colour plus icon plus words.
class TfBanner extends StatelessWidget {
  const TfBanner({
    super.key,
    required this.message,
    this.kind = TfBannerKind.info,
    this.actionLabel,
    this.onAction,
    this.actionKey,
    this.onDismiss,
    this.dismissTooltip,
  }) : assert(onDismiss == null || dismissTooltip != null);

  final String message;
  final TfBannerKind kind;
  final String? actionLabel;
  final VoidCallback? onAction;

  /// Key of the action button (tests and shortcuts find it by this).
  final Key? actionKey;
  final VoidCallback? onDismiss;
  final String? dismissTooltip;

  static (TfTone, TfIconData) look(TfColors c, TfBannerKind k) => switch (k) {
    TfBannerKind.info => (c.info, TfIcons.info),
    TfBannerKind.success => (c.success, TfIcons.success),
    TfBannerKind.warning => (c.warning, TfIcons.warning),
    TfBannerKind.danger => (c.danger, TfIcons.error),
  };

  @override
  Widget build(BuildContext context) {
    final tf = context.tf;
    final (tone, icon) = look(tf.colors, kind);
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: TfSpace.md,
          vertical: TfSpace.sm,
        ),
        decoration: BoxDecoration(
          color: tone.bg,
          borderRadius: TfRadius.control,
          border: Border.all(color: tone.fg.withValues(alpha: 0.35)),
        ),
        child: Row(
          children: [
            TfIcon(icon, color: tone.fg),
            const SizedBox(width: TfSpace.sm),
            Expanded(
              child: Text(
                message,
                style: tf.typography.body.copyWith(color: tone.fg),
              ),
            ),
            if (actionLabel != null)
              TfButton(
                key: actionKey,
                label: actionLabel!,
                onPressed: onAction,
                variant: TfButtonVariant.ghost,
                size: TfButtonSize.small,
              ),
            if (onDismiss != null)
              TfIconButton(
                icon: TfIcons.close,
                tooltip: dismissTooltip!,
                onPressed: onDismiss,
                size: TfButtonSize.small,
              ),
          ],
        ),
      ),
    );
  }
}

/// A short confirmation at the bottom of the screen; read out by screen readers.
void showTfToast(
  BuildContext context,
  String message, {
  TfBannerKind kind = TfBannerKind.info,
  String? actionLabel,
  VoidCallback? onAction,
}) {
  final tf = context.tf;
  final (tone, icon) = TfBanner.look(tf.colors, kind);
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      snackBarAnimationStyle: TfMotion.style(context, TfDuration.base),
      SnackBar(
        content: Row(
          children: [
            TfIcon(
              icon,
              color: (tf.colors.isDark ? tf.colors.text : tf.colors.surface),
            ),
            const SizedBox(width: TfSpace.sm),
            Expanded(child: Text(message)),
          ],
        ),
        action: actionLabel == null
            ? null
            : SnackBarAction(label: actionLabel, onPressed: onAction ?? () {}),
        duration: const Duration(seconds: 4),
      ),
    );
}
