import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/core/ui/theme_extension.dart';
import 'package:taskforge/core/ui/tf/tf_button.dart';
import 'package:taskforge/core/ui/tf/tf_illustration.dart';
import 'package:taskforge/core/ui/tf_icons.dart';
import 'package:taskforge/core/ui/tokens/shape.dart';
import 'package:taskforge/core/ui/tokens/spacing.dart';

/// Nothing here yet: a small picture (or [icon]), what this place is for, one
/// sentence, one primary action and an optional link to the docs.
class TfEmpty extends StatelessWidget {
  const TfEmpty({
    super.key,
    required this.title,
    this.message,
    this.icon,
    this.illustration,
    this.actionLabel,
    this.onAction,
    this.actionKey,
    this.docsLabel,
    this.onDocs,
    this.compact = false,
  });

  final String title;
  final String? message;
  final TfIconData? icon;

  /// The scene drawn above the title; wins over [icon].
  final TfIllustrationKind? illustration;
  final String? actionLabel;
  final VoidCallback? onAction;

  /// Key of the action button, for callers whose tests find it by key.
  final Key? actionKey;

  /// "Learn more" link under the action; shown when both are given.
  final String? docsLabel;
  final VoidCallback? onDocs;

  /// Inside a list or card: tighter, no scroll view.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final tf = context.tf;
    final c = tf.colors;
    // Centred when there is room, scrolls when there is not (small panes, big text).
    return _Centered(
      compact: compact,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (illustration != null && !compact) ...[
            TfIllustration(illustration!, height: 88),
            const SizedBox(height: TfSpace.md),
          ] else if (icon != null && !compact) ...[
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
          if (docsLabel != null && onDocs != null) ...[
            const SizedBox(height: TfSpace.xs),
            TfButton(
              key: const Key('empty-docs'),
              label: docsLabel!,
              onPressed: onDocs,
              variant: TfButtonVariant.ghost,
              size: TfButtonSize.small,
            ),
          ],
        ],
      ),
    );
  }
}

/// Something failed: what, in plain words, a Retry and "copy details" (the raw
/// error, for a bug report). [message] is the plain sentence; [details] the
/// technical text, copied to the clipboard.
class TfError extends StatelessWidget {
  const TfError({
    super.key,
    this.title,
    this.message,
    this.details,
    this.onRetry,
    this.retryKey,
    this.compact = false,
  });

  final String? title;
  final String? message;
  final String? details;
  final VoidCallback? onRetry;

  /// Key of the Retry button, for callers whose tests find it by key.
  final Key? retryKey;

  /// Inside a list or card: tighter, no picture, no scroll view.
  final bool compact;

  Future<void> _copy(BuildContext context) async {
    final done = context.l10n.errCopied;
    final messenger = ScaffoldMessenger.maybeOf(context);
    await Clipboard.setData(ClipboardData(text: details ?? message ?? ''));
    messenger?.showSnackBar(SnackBar(content: Text(done)));
  }

  @override
  Widget build(BuildContext context) {
    final tf = context.tf;
    final c = tf.colors;
    final t = context.l10n;
    return _Centered(
      compact: compact,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!compact) ...[
            const TfIllustration(TfIllustrationKind.generic, height: 72),
            const SizedBox(height: TfSpace.md),
          ],
          Text(
            title ?? t.errTitle,
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
          const SizedBox(height: TfSpace.lg),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: TfSpace.sm,
            runSpacing: TfSpace.sm,
            children: [
              if (onRetry != null)
                TfButton(
                  key: retryKey ?? const Key('error-retry'),
                  label: t.errRetry,
                  onPressed: onRetry,
                  variant: TfButtonVariant.primary,
                ),
              if (details != null || message != null)
                TfButton(
                  key: const Key('error-copy'),
                  label: t.errCopyDetails,
                  onPressed: () => _copy(context),
                  variant: TfButtonVariant.ghost,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Centres [child] when there is room and scrolls when there is not (small
/// panes, big text). [compact] is for use inside a list or card: no scroll
/// view, just padded content.
class _Centered extends StatelessWidget {
  const _Centered({required this.compact, required this.child});

  final bool compact;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final body = Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Padding(
          padding: EdgeInsets.all(compact ? TfSpace.md : TfSpace.xl),
          child: child,
        ),
      ),
    );
    if (compact) return body;
    return LayoutBuilder(
      builder: (context, box) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: box.hasBoundedHeight ? box.maxHeight : 0,
          ),
          child: body,
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
