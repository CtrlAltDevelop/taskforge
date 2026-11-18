import 'package:material_ui/material_ui.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/core/ui/theme_extension.dart';
import 'package:taskforge/core/ui/tf/tf_chip.dart';

/// "Sample": marks a task the first-run starter made, so nobody mistakes it
/// for real work (it is also left out of reports).
class SampleBadge extends StatelessWidget {
  const SampleBadge({super.key});

  @override
  Widget build(BuildContext context) => TfChip(
    key: const Key('sample-badge'),
    label: context.l10n.sampleBadge,
    tone: context.tf.colors.info,
  );
}
