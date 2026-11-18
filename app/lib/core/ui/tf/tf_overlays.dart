import 'package:material_ui/material_ui.dart';

import 'package:taskforge/core/ui/theme_extension.dart';
import 'package:taskforge/core/ui/tf/tf_button.dart';
import 'package:taskforge/core/ui/tf_icons.dart';
import 'package:taskforge/core/ui/tokens/motion.dart';
import 'package:taskforge/core/ui/tokens/shape.dart';
import 'package:taskforge/core/ui/tokens/spacing.dart';

/// A centred modal: title, body, and a row of actions (cancel left of confirm).
Future<T?> showTfDialog<T>(
  BuildContext context, {
  required String title,
  required Widget body,
  required List<Widget> actions,
  bool dismissible = true,
}) => showDialog<T>(
  context: context,
  barrierDismissible: dismissible,
  animationStyle: TfMotion.style(context, TfDuration.base),
  builder: (context) {
    final tf = context.tf;
    return Dialog(
      backgroundColor: tf.colors.raised,
      surfaceTintColor: const Color(0x00000000),
      shape: RoundedRectangleBorder(
        borderRadius: TfRadius.dialog,
        side: BorderSide(color: tf.colors.border),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Padding(
          padding: const EdgeInsets.all(TfSpace.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                header: true,
                child: Text(
                  title,
                  style: tf.typography.lead.copyWith(color: tf.colors.text),
                ),
              ),
              const SizedBox(height: TfSpace.md),
              DefaultTextStyle(
                style: tf.typography.body.copyWith(color: tf.colors.textMuted),
                child: body,
              ),
              const SizedBox(height: TfSpace.xl),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  for (var i = 0; i < actions.length; i++) ...[
                    if (i > 0) const SizedBox(width: TfSpace.sm),
                    actions[i],
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  },
);

/// A panel sliding in from the end edge (right in LTR): details beside a list.
Future<T?> showTfSideSheet<T>(
  BuildContext context, {
  required String title,
  required Widget body,
  required String closeTooltip,
  double width = 420,
}) => showGeneralDialog<T>(
  context: context,
  barrierDismissible: true,
  barrierLabel: title,
  barrierColor: const Color(0x66000000),
  transitionDuration: TfMotion.of(context, TfDuration.slow),
  pageBuilder: (context, _, _) {
    final tf = context.tf;
    return Align(
      alignment: AlignmentDirectional.centerEnd,
      child: Material(
        color: tf.colors.raised,
        elevation: 0,
        child: Container(
          width: width,
          height: double.infinity,
          decoration: BoxDecoration(
            border: BorderDirectional(
              start: BorderSide(color: tf.colors.border),
            ),
            boxShadow: TfShadow.modal,
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.only(
                  start: TfSpace.lg,
                  end: TfSpace.sm,
                  top: TfSpace.sm,
                  bottom: TfSpace.sm,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Semantics(
                        header: true,
                        child: Text(
                          title,
                          style: tf.typography.lead.copyWith(
                            color: tf.colors.text,
                          ),
                        ),
                      ),
                    ),
                    TfIconButton(
                      icon: TfIcons.close,
                      tooltip: closeTooltip,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: tf.colors.border),
              Expanded(child: body),
            ],
          ),
        ),
      ),
    );
  },
  transitionBuilder: (context, animation, _, child) => SlideTransition(
    position: Tween(
      begin: Offset(
        Directionality.of(context) == TextDirection.rtl ? -1 : 1,
        0,
      ),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: animation, curve: tfCurve)),
    child: child,
  ),
);

/// A sheet rising from the bottom edge, for phones.
Future<T?> showTfBottomSheet<T>(BuildContext context, {required Widget body}) =>
    showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      sheetAnimationStyle: TfMotion.style(context, TfDuration.slow),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            TfSpace.lg,
            0,
            TfSpace.lg,
            TfSpace.lg,
          ),
          child: body,
        ),
      ),
    );
