import 'package:material_ui/material_ui.dart';

import 'package:taskforge/core/ui/theme_extension.dart';
import 'package:taskforge/core/ui/tokens/shape.dart';
import 'package:taskforge/core/ui/tokens/spacing.dart';
import 'package:taskforge/core/ui/tokens/colors.dart';

/// The look of a [showTfDialog] modal as a widget, for dialogs that are their
/// own (stateful) widgets and open with `showDialog`: title, [content] and a
/// row of [actions] (cancel first, confirm last). Replaces `AlertDialog`.
class TfDialogFrame extends StatelessWidget {
  const TfDialogFrame({
    super.key,
    this.title,
    this.content,
    this.actions = const [],
    this.maxWidth = 480,
    this.scrollable = false,
  });

  final String? title;
  final Widget? content;
  final List<Widget> actions;
  final double maxWidth;

  /// Let a tall [content] scroll instead of overflowing a short window.
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final tf = context.tf;
    final c = tf.colors;
    Widget? body = content == null
        ? null
        : DefaultTextStyle(
            style: tf.typography.body.copyWith(color: c.textMuted),
            child: content!,
          );
    if (body != null && scrollable) body = SingleChildScrollView(child: body);
    return Dialog(
      backgroundColor: c.raised,
      surfaceTintColor: tfClear,
      shape: RoundedRectangleBorder(
        borderRadius: TfRadius.dialog,
        side: BorderSide(color: c.border),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: const EdgeInsets.all(TfSpace.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null)
                Semantics(
                  header: true,
                  child: Text(
                    title!,
                    style: tf.typography.lead.copyWith(color: c.text),
                  ),
                ),
              if (title != null && body != null)
                const SizedBox(height: TfSpace.md),
              if (body != null) Flexible(child: body),
              if (actions.isNotEmpty) ...[
                const SizedBox(height: TfSpace.xl),
                Wrap(
                  alignment: WrapAlignment.end,
                  spacing: TfSpace.sm,
                  runSpacing: TfSpace.sm,
                  children: actions,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
