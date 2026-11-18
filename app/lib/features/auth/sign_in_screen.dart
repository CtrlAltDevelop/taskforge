import 'package:taskforge/core/ui/tf_icons.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:taskforge/core/auth/auth_api.dart' show SecondFactorRequired;
import 'package:taskforge/core/auth/auth_providers.dart';
import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/auth/credentials_form.dart';
import 'package:taskforge/features/auth/validators.dart';
import 'package:taskforge/features/security/presentation/sso_flow.dart';

class SignInScreen extends ConsumerWidget {
  const SignInScreen({super.key, this.from});

  /// Where to go after signing in (the page that needed a session).
  final String? from;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authSessionProvider);
    return CredentialsForm(
      title: context.l10n.signIn,
      submitLabel: context.l10n.signIn,
      passwordValidator: validateSignInPassword,
      onSubmit: (email, password) async {
        try {
          await session.signIn(email, password);
        } on SecondFactorRequired catch (challenge) {
          if (!context.mounted) return;
          // The password was right; the code is the next step.
          context.go(
            from == null
                ? '/two-factor'
                : '/two-factor?from=${Uri.encodeComponent(from!)}',
            extra: challenge,
          );
        }
      },
      footer: Column(
        children: [
          ValueListenableBuilder<bool>(
            valueListenable: session.keyChanged,
            builder: (context, changed, _) => changed
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      key: const Key('key-changed'),
                      context.l10n.dpopKeyChanged,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          OutlinedButton.icon(
            key: const Key('go-sso'),
            onPressed: () => showSsoDialog(context, ref),
            icon: const TfIcon(TfIcons.user),
            label: Text(context.l10n.ssoContinue),
          ),
          TextButton(
            key: const Key('go-forgot'),
            onPressed: () => context.go('/forgot-password'),
            child: Text(context.l10n.forgotPassword),
          ),
          TextButton(
            key: const Key('go-sign-up'),
            onPressed: () => context.go(
              from == null
                  ? '/sign-up'
                  : '/sign-up?from=${Uri.encodeComponent(from!)}',
            ),
            child: Text(context.l10n.createAnAccount),
          ),
        ],
      ),
    );
  }
}
