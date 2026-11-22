import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/core/ui/appearance.dart';
import 'package:taskforge/core/ui/page/tf_page.dart';
import 'package:taskforge/core/ui/page/tf_tile.dart';
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
    final reduce = ref.watch(reduceMotionProvider);
    Widget label(String text) => Padding(
      padding: const EdgeInsets.only(bottom: TfSpace.sm),
      child: Text(
        text,
        style: tf.typography.label.copyWith(color: tf.colors.textMuted),
      ),
    );
    Widget panel(List<Widget> children) => Padding(
      padding: const EdgeInsets.only(bottom: TfSpace.lg),
      child: TfPanel(
        padding: const EdgeInsets.all(TfSpace.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    );
    return Scaffold(
      appBar: TfAppBar(title: Text(l10n.appearance)),
      body: TfPage(
        children: [
          panel([
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
            const SizedBox(height: TfSpace.lg),
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
          ]),
          panel([
            TfToggleTile(
              value: high,
              title: l10n.contrastLabel,
              subtitle: l10n.contrastHelp,
              onChanged: (v) =>
                  ref.read(contrastProvider.notifier).choose(high: v),
            ),
            TfToggleTile(
              key: const Key('reduce-motion'),
              value: reduce,
              title: l10n.reduceMotionLabel,
              subtitle: l10n.reduceMotionHelp,
              onChanged: (v) =>
                  ref.read(reduceMotionProvider.notifier).choose(reduce: v),
            ),
          ]),
          label(l10n.appearancePreview),
          TfPanel(
            padding: const EdgeInsets.all(TfSpace.md),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.appearancePreviewTask,
                    style: tf.typography.body.copyWith(color: tf.colors.text),
                  ),
                ),
                const SizedBox(width: TfSpace.sm),
                TfStatusPill(label: l10n.themeLabel, kind: TfStatusKind.active),
                const SizedBox(width: TfSpace.sm),
                const TfBadge(count: 3),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
