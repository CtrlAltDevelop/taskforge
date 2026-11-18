import 'package:material_ui/material_ui.dart';

import 'package:taskforge/core/ui/theme_extension.dart';
import 'package:taskforge/core/ui/tf/tf_button.dart';
import 'package:taskforge/core/ui/tf/tf_panel.dart';
import 'package:taskforge/core/ui/tokens/shape.dart';
import 'package:taskforge/core/ui/tokens/spacing.dart';

/// A titled group of form fields in a panel, with an optional description.
class TfFormSection extends StatelessWidget {
  const TfFormSection({
    super.key,
    required this.children,
    this.title,
    this.description,
  });

  final String? title;
  final String? description;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final tf = context.tf;
    final c = tf.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: TfSpace.lg),
      child: TfPanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (title != null)
              Semantics(
                header: true,
                child: Text(
                  title!,
                  style: tf.typography.lead.copyWith(color: c.text),
                ),
              ),
            if (description != null) ...[
              const SizedBox(height: TfSpace.xs),
              Text(
                description!,
                style: tf.typography.small.copyWith(color: c.textMuted),
              ),
            ],
            if (title != null || description != null)
              const SizedBox(height: TfSpace.md),
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0) const SizedBox(height: TfSpace.md),
              children[i],
            ],
          ],
        ),
      ),
    );
  }
}

/// The label above any control, with helper text and an inline error under it.
/// (A [TfTextField] already does this itself; use this for dropdowns, toggles,
/// pickers and custom controls.)
class TfFormField extends StatelessWidget {
  const TfFormField({
    super.key,
    required this.child,
    this.label,
    this.helper,
    this.error,
  });

  final String? label;
  final Widget child;
  final String? helper;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final tf = context.tf;
    final c = tf.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!, style: tf.typography.label.copyWith(color: c.textMuted)),
          const SizedBox(height: TfSpace.xs),
        ],
        child,
        if (error != null) ...[
          const SizedBox(height: TfSpace.xs),
          Semantics(
            liveRegion: true,
            child: Text(
              error!,
              style: tf.typography.small.copyWith(color: c.danger.fg),
            ),
          ),
        ] else if (helper != null) ...[
          const SizedBox(height: TfSpace.xs),
          Text(
            helper!,
            style: tf.typography.small.copyWith(color: c.textSubtle),
          ),
        ],
      ],
    );
  }
}

/// A bar pinned under the form that appears only while there are unsaved
/// changes ([dirty]): discard on one side, save on the other.
class TfStickySaveBar extends StatelessWidget {
  const TfStickySaveBar({
    super.key,
    required this.dirty,
    required this.onSave,
    required this.saveLabel,
    this.onDiscard,
    this.discardLabel,
    this.saving = false,
    this.message,
    this.saveKey,
  }) : assert(
         onDiscard == null || discardLabel != null,
         'A discard button needs a label',
       );

  final bool dirty;
  final VoidCallback? onSave;
  final String saveLabel;
  final VoidCallback? onDiscard;
  final String? discardLabel;
  final bool saving;

  /// Shown at the start of the bar, e.g. "Unsaved changes".
  final String? message;

  /// Lets a screen keep the key its tests and automation use for "save".
  final Key? saveKey;

  @override
  Widget build(BuildContext context) {
    if (!dirty) return const SizedBox.shrink();
    final tf = context.tf;
    final c = tf.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.raised,
        border: Border(
          top: BorderSide(color: c.border, width: tfHairline),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: TfSpace.lg,
            vertical: TfSpace.sm,
          ),
          child: Wrap(
            alignment: WrapAlignment.end,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: TfSpace.sm,
            runSpacing: TfSpace.sm,
            children: [
              if (message != null)
                Text(
                  message!,
                  style: tf.typography.small.copyWith(color: c.textMuted),
                ),
              if (onDiscard != null)
                TfButton(
                  key: const Key('save-bar-discard'),
                  label: discardLabel!,
                  variant: TfButtonVariant.ghost,
                  onPressed: saving ? null : onDiscard,
                ),
              TfButton(
                key: saveKey ?? const Key('save-bar-save'),
                label: saveLabel,
                variant: TfButtonVariant.primary,
                loading: saving,
                onPressed: onSave,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
