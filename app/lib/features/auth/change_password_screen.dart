import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskforge/core/auth/auth_providers.dart';
import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/auth/auth_form.dart';
import 'package:taskforge/features/auth/validators.dart';

class ChangePasswordScreen extends ConsumerWidget {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authSessionProvider);
    // Held across the sign-out below, which tears this screen down.
    final messenger = ScaffoldMessenger.of(context);
    final changed = context.l10n.passwordChanged;
    return AuthForm(
      title: context.l10n.changePassword,
      submitLabel: context.l10n.changePassword,
      fields: [
        AuthField(
          key: const Key('current-password'),
          label: context.l10n.currentPassword,
          validator: validateSignInPassword,
          secret: true,
          autofillHints: const [AutofillHints.password],
        ),
        AuthField(
          key: const Key('new-password'),
          label: context.l10n.newPassword,
          validator: validatePassword,
          secret: true,
          autofillHints: const [AutofillHints.newPassword],
        ),
      ],
      onSubmit: (values) async {
        await session.changePassword(values[0], values[1]);
        messenger.showSnackBar(SnackBar(content: Text(changed)));
      },
    );
  }
}
