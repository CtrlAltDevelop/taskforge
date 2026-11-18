import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:taskforge/core/i18n/context_dates.dart';
import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/core/ui/theme_extension.dart';
import 'package:taskforge/core/ui/tf/tf_button.dart';
import 'package:taskforge/core/ui/tf/tf_feedback.dart';
import 'package:taskforge/core/ui/tf/tf_illustration.dart';
import 'package:taskforge/core/ui/tf/tf_interactive.dart';
import 'package:taskforge/core/ui/tokens/shape.dart';
import 'package:taskforge/core/ui/tokens/spacing.dart';
import 'package:taskforge/features/home/application/home_providers.dart';
import 'package:taskforge/features/home/domain/home.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';
import 'package:taskforge/l10n/gen/app_localizations.dart';

/// The starters the server offers when it names none (it always does; this
/// keeps the step usable if the list is empty).
const defaultStarterKeys = [
  'software-team',
  'marketing',
  'bug-tracker',
  'blank',
];

String starterName(AppLocalizations l, String key) => switch (key) {
  'software-team' => l.obStarterSoftware,
  'marketing' => l.obStarterMarketing,
  'bug-tracker' => l.obStarterBugs,
  _ => l.obStarterBlank,
};

String starterDescription(AppLocalizations l, String key) => switch (key) {
  'software-team' => l.obStarterSoftwareDesc,
  'marketing' => l.obStarterMarketingDesc,
  'bug-tracker' => l.obStarterBugsDesc,
  _ => l.obStarterBlankDesc,
};

TfIllustrationKind starterPicture(String key) => switch (key) {
  'software-team' => TfIllustrationKind.board,
  'marketing' => TfIllustrationKind.calendar,
  'bug-tracker' => TfIllustrationKind.tasks,
  _ => TfIllustrationKind.generic,
};

/// Step 2 of first run: pick a starter (software team, marketing, bug
/// tracker or blank). Making it creates a project with sample tasks.
class StarterScreen extends ConsumerStatefulWidget {
  const StarterScreen({super.key});

  @override
  ConsumerState<StarterScreen> createState() => _StarterScreenState();
}

class _StarterScreenState extends ConsumerState<StarterScreen> {
  String _chosen = defaultStarterKeys.first;
  bool _busy = false;
  Object? _error;

  Future<void> _create() async {
    final ws = ref.read(workspaceScopeProvider);
    if (ws == null) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final made = await ref
          .read(onboardingClientProvider)
          .applyStarter(ws, _chosen);
      ref.invalidate(onboardingProvider);
      if (mounted) context.go('/welcome/invite?project=${made.projectId}');
    } on Object catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = e;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final tf = context.tf;
    final offered = ref.watch(onboardingProvider).value?.starters ?? const [];
    final keys = offered.isEmpty
        ? defaultStarterKeys
        : [for (final s in offered) s.key];
    final chosen = keys.contains(_chosen) ? _chosen : keys.first;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(TfSpace.xl),
                    children: [
                      Text(
                        l.obStepOf(
                          context.localDigits('2'),
                          context.localDigits('3'),
                        ),
                        key: const Key('onboarding-step'),
                        style: tf.typography.small.copyWith(
                          color: tf.colors.textMuted,
                        ),
                      ),
                      const SizedBox(height: TfSpace.xs),
                      Semantics(
                        header: true,
                        child: Text(
                          l.obStarterTitle,
                          style: tf.typography.title.copyWith(
                            color: tf.colors.text,
                          ),
                        ),
                      ),
                      const SizedBox(height: TfSpace.xs),
                      Text(
                        l.obStarterHint,
                        style: tf.typography.body.copyWith(
                          color: tf.colors.textMuted,
                        ),
                      ),
                      const SizedBox(height: TfSpace.lg),
                      Wrap(
                        spacing: TfSpace.md,
                        runSpacing: TfSpace.md,
                        children: [
                          for (final key in keys)
                            _StarterCard(
                              starterKey: key,
                              selected: key == chosen,
                              onTap: _busy
                                  ? null
                                  : () => setState(() => _chosen = key),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(TfSpace.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_error != null)
                        TfError(
                          key: const Key('starter-error'),
                          compact: true,
                          message: homeErrorMessage(_error!, l),
                          details: '$_error',
                          retryKey: const Key('starter-retry'),
                          onRetry: _create,
                        ),
                      TfButton(
                        key: const Key('starter-create'),
                        label: _busy
                            ? l.obStarterCreating
                            : l.obStarterContinue,
                        variant: TfButtonVariant.primary,
                        size: TfButtonSize.large,
                        loading: _busy,
                        onPressed: _busy ? null : _create,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StarterCard extends StatelessWidget {
  const _StarterCard({
    required this.starterKey,
    required this.selected,
    required this.onTap,
  });

  final String starterKey;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final tf = context.tf;
    final c = tf.colors;
    return SizedBox(
      width: 220,
      child: TfInteractive(
        key: Key('starter-$starterKey'),
        onTap: onTap,
        selected: selected,
        semanticLabel:
            '${starterName(l, starterKey)}. ${starterDescription(l, starterKey)}',
        builder: (context, states) => Container(
          padding: const EdgeInsets.all(TfSpace.md),
          decoration: BoxDecoration(
            color: selected ? c.selected : c.surface,
            borderRadius: TfRadius.panel,
            border: Border.all(
              color: selected ? c.accent : c.border,
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              TfIllustration(starterPicture(starterKey), height: 72),
              const SizedBox(height: TfSpace.sm),
              Text(
                starterName(l, starterKey),
                textAlign: TextAlign.center,
                style: tf.typography.lead.copyWith(color: c.text),
              ),
              const SizedBox(height: TfSpace.xs),
              Text(
                starterDescription(l, starterKey),
                textAlign: TextAlign.center,
                style: tf.typography.small.copyWith(color: c.textMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
