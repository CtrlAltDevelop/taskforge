import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/core/ui/appearance.dart';
import 'package:taskforge/core/ui/content_width.dart';
import 'package:taskforge/core/ui/tf/tf_checkbox.dart';
import 'package:taskforge/core/ui/tf/tf_chip.dart';
import 'package:taskforge/core/ui/tf/tf_panel.dart';
import 'package:taskforge/core/ui/tf/tf_status.dart';
import 'package:taskforge/core/ui/tf/tf_tabs.dart';
import 'package:taskforge/core/ui/tf_app_bar.dart';
import 'package:taskforge/core/ui/theme_extension.dart';
import 'package:taskforge/core/ui/tokens/spacing.dart';
import 'package:taskforge/features/shortcuts/application/local_prefs.dart';

/// Theme, density and contrast; every change applies at once and is kept on
/// this device.
class AppearanceScreen extends ConsumerWidget {
  const AppearanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final tf = context.tf;
    final mode = ref.watch(themeModeProvider);
    final density = ref.watch(densityProvider);
    final high = ref.watch(contrastProvider);
    Widget label(String text) => Padding(
      padding: const EdgeInsets.only(top: TfSpace.lg, bottom: TfSpace.sm),
      child: Text(
        text,
        style: tf.typography.label.copyWith(color: tf.colors.textMuted),
      ),
    );
    return Scaffold(
      appBar: TfAppBar(title: Text(l10n.appearance)),
      body: ContentWidth(
        child: ListView(
          padding: const EdgeInsets.all(TfSpace.lg),
          children: [
            label(l10n.themeLabel),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TfSegmented<ThemeMode>(
                options: {
                  ThemeMode.system: l10n.themeSystem,
                  ThemeMode.light: l10n.themeLight,
                  ThemeMode.dark: l10n.themeDark,
                },
                value: mode,
                onChanged: (m) =>
                    ref.read(themeModeProvider.notifier).choose(m),
              ),
            ),
            label(l10n.densityLabel),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TfSegmented<TfDensity>(
                options: {
                  TfDensity.comfortable: l10n.densityComfortable,
                  TfDensity.compact: l10n.densityCompact,
                },
                value: density,
                onChanged: ref.read(densityProvider.notifier).choose,
              ),
            ),
            const SizedBox(height: TfSpace.lg),
            TfCheckbox(
              value: high,
              label: l10n.contrastLabel,
              onChanged: (v) =>
                  ref.read(contrastProvider.notifier).choose(high: v),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.only(
                start: TfSpace.xl,
                top: TfSpace.xs,
              ),
              child: Text(
                l10n.contrastHelp,
                style: tf.typography.small.copyWith(color: tf.colors.textMuted),
              ),
            ),
            label(l10n.appearancePreview),
            TfPanel(
              padding: const EdgeInsets.all(TfSpace.sm),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.appearancePreviewTask,
                      style: tf.typography.body.copyWith(color: tf.colors.text),
                    ),
                  ),
                  const SizedBox(width: TfSpace.sm),
                  TfStatusPill(
                    label: l10n.themeLabel,
                    kind: TfStatusKind.active,
                  ),
                  const SizedBox(width: TfSpace.sm),
                  const TfBadge(count: 3),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
