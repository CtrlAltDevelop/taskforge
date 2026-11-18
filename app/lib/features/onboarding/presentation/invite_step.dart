import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:taskforge/core/i18n/context_dates.dart';
import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/core/ui/theme_extension.dart';
import 'package:taskforge/core/ui/tf/tf_button.dart';
import 'package:taskforge/core/ui/tf/tf_illustration.dart';
import 'package:taskforge/core/ui/tokens/spacing.dart';
import 'package:taskforge/features/members/presentation/invite_dialog.dart';

/// Step 3 of first run: invite teammates (skippable), then land in the
/// project the starter made.
class InviteStepScreen extends StatelessWidget {
  const InviteStepScreen({super.key, required this.projectId});

  final String projectId;

  void _finish(BuildContext context) =>
      context.go(projectId.isEmpty ? '/' : '/projects/$projectId');

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final tf = context.tf;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.all(TfSpace.xl),
              children: [
                Center(
                  child: TfIllustration(TfIllustrationKind.chat, height: 120),
                ),
                const SizedBox(height: TfSpace.lg),
                Text(
                  l.obStepOf(
                    context.localDigits('3'),
                    context.localDigits('3'),
                  ),
                  key: const Key('onboarding-step'),
                  textAlign: TextAlign.center,
                  style: tf.typography.small.copyWith(
                    color: tf.colors.textMuted,
                  ),
                ),
                const SizedBox(height: TfSpace.xs),
                Semantics(
                  header: true,
                  child: Text(
                    l.obInviteTitle,
                    textAlign: TextAlign.center,
                    style: tf.typography.title.copyWith(color: tf.colors.text),
                  ),
                ),
                const SizedBox(height: TfSpace.xs),
                Text(
                  l.obInviteHint,
                  textAlign: TextAlign.center,
                  style: tf.typography.body.copyWith(
                    color: tf.colors.textMuted,
                  ),
                ),
                const SizedBox(height: TfSpace.xl),
                TfButton(
                  key: const Key('onboarding-invite'),
                  label: l.obInviteButton,
                  variant: TfButtonVariant.primary,
                  onPressed: () => showDialog<void>(
                    context: context,
                    builder: (_) => const InviteDialog(),
                  ),
                ),
                const SizedBox(height: TfSpace.sm),
                TfButton(
                  key: const Key('onboarding-skip'),
                  label: l.obInviteSkip,
                  variant: TfButtonVariant.ghost,
                  onPressed: () => _finish(context),
                ),
                const SizedBox(height: TfSpace.lg),
                TfButton(
                  key: const Key('onboarding-done'),
                  label: l.obInviteDone,
                  onPressed: () => _finish(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
