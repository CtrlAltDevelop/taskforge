import 'package:material_ui/material_ui.dart';

import 'package:taskforge/core/ui/theme_extension.dart';
import 'package:taskforge/core/ui/tf/tf_button.dart';
import 'package:taskforge/core/ui/tf/tf_overlays.dart';
import 'package:taskforge/core/ui/tf/tf_field.dart';
import 'package:taskforge/core/ui/tokens/shape.dart';
import 'package:taskforge/core/ui/tokens/spacing.dart';

/// One irreversible action of a [TfDangerZone]: what it does and its button.
class TfDangerAction {
  const TfDangerAction({
    required this.label,
    required this.onPressed,
    this.description,
    this.buttonKey,
  });

  final String label;
  final String? description;
  final VoidCallback? onPressed;
  final Key? buttonKey;
}

/// The one place destructive actions live on a page: a danger-toned panel at
/// the end, each action with its consequence spelled out and a danger button.
/// The button should open [showTfTypedConfirm] (or a plain confirm) first.
class TfDangerZone extends StatelessWidget {
  const TfDangerZone({
    super.key,
    required this.title,
    required this.actions,
    this.description,
  });

  final String title;
  final String? description;
  final List<TfDangerAction> actions;

  @override
  Widget build(BuildContext context) {
    final tf = context.tf;
    final c = tf.colors;
    return Padding(
      padding: const EdgeInsets.only(top: TfSpace.xl),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: TfRadius.panel,
          border: Border.all(
            color: c.danger.fg.withValues(alpha: 0.5),
            width: tfHairline,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(TfSpace.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                header: true,
                child: Text(
                  title,
                  style: tf.typography.lead.copyWith(color: c.danger.fg),
                ),
              ),
              if (description != null) ...[
                const SizedBox(height: TfSpace.xs),
                Text(
                  description!,
                  style: tf.typography.body.copyWith(color: c.textMuted),
                ),
              ],
              for (final a in actions) ...[
                const SizedBox(height: TfSpace.md),
                if (a.description != null) ...[
                  Text(
                    a.description!,
                    style: tf.typography.small.copyWith(color: c.textMuted),
                  ),
                  const SizedBox(height: TfSpace.sm),
                ],
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: TfButton(
                    key: a.buttonKey,
                    label: a.label,
                    variant: TfButtonVariant.danger,
                    onPressed: a.onPressed,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Asks the person to type [phrase] before a destructive action. Resolves to
/// `true` only when they typed it exactly and confirmed; cancel, Esc and a
/// tap outside give `false`.
Future<bool> showTfTypedConfirm(
  BuildContext context, {
  required String title,
  required String phrase,
  required String promptLabel,
  required String confirmLabel,
  required String cancelLabel,
  String? body,
  Key? fieldKey,
  Key? confirmKey,
}) async {
  final result = await showTfDialog<bool>(
    context,
    title: title,
    body: _TypedConfirmBody(
      phrase: phrase,
      promptLabel: promptLabel,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      body: body,
      fieldKey: fieldKey,
      confirmKey: confirmKey,
    ),
    actions: const [],
  );
  return result ?? false;
}

/// The dialog body owns the field and the buttons so the confirm button can
/// follow what is typed; [showTfDialog]'s own action row stays empty.
class _TypedConfirmBody extends StatefulWidget {
  const _TypedConfirmBody({
    required this.phrase,
    required this.promptLabel,
    required this.confirmLabel,
    required this.cancelLabel,
    this.body,
    this.fieldKey,
    this.confirmKey,
  });

  final String phrase;
  final String promptLabel;
  final String confirmLabel;
  final String cancelLabel;
  final String? body;
  final Key? fieldKey;
  final Key? confirmKey;

  @override
  State<_TypedConfirmBody> createState() => _TypedConfirmBodyState();
}

class _TypedConfirmBodyState extends State<_TypedConfirmBody> {
  final _typed = TextEditingController();

  @override
  void dispose() {
    _typed.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      ValueListenableBuilder<TextEditingValue>(
        valueListenable: _typed,
        builder: (context, value, _) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.body != null) ...[
              Text(widget.body!),
              const SizedBox(height: TfSpace.md),
            ],
            TfTextField(
              key: widget.fieldKey,
              controller: _typed,
              label: widget.promptLabel,
              autofocus: true,
            ),
            const SizedBox(height: TfSpace.xl),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TfButton(
                  label: widget.cancelLabel,
                  variant: TfButtonVariant.ghost,
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                const SizedBox(width: TfSpace.sm),
                TfButton(
                  key: widget.confirmKey,
                  label: widget.confirmLabel,
                  variant: TfButtonVariant.danger,
                  onPressed: value.text == widget.phrase
                      ? () => Navigator.of(context).pop(true)
                      : null,
                ),
              ],
            ),
          ],
        ),
      );
}
