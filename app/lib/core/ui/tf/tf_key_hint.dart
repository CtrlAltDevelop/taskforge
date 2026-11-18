import 'package:material_ui/material_ui.dart';

import 'package:taskforge/core/ui/theme_extension.dart';
import 'package:taskforge/core/ui/tokens/shape.dart';
import 'package:taskforge/core/ui/tokens/spacing.dart';

/// A keyboard shortcut shown as key caps ("Ctrl", "K"). [keys] is the
/// already-localised label, e.g. "Ctrl+K"; it is split on '+'.
class TfKeyHint extends StatelessWidget {
  const TfKeyHint(this.keys, {super.key});

  final String keys;

  @override
  Widget build(BuildContext context) {
    final tf = context.tf;
    final c = tf.colors;
    final parts = keys.split('+').where((p) => p.isNotEmpty).toList();
    return Semantics(
      label: keys,
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < parts.length; i++) ...[
            if (i > 0) const SizedBox(width: 2),
            Container(
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              padding: const EdgeInsets.symmetric(horizontal: TfSpace.xs),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: c.sunken,
                borderRadius: TfRadius.chip,
                border: Border.all(color: c.border, width: tfHairline),
              ),
              child: Text(
                parts[i],
                style: tf.typography.caption.copyWith(
                  color: c.textMuted,
                  height: 1.1,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
