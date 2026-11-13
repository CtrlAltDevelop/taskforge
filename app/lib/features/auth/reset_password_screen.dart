import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:taskforge/core/auth/auth_providers.dart';
import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/auth/auth_form.dart';
import 'package:taskforge/features/auth/validators.dart';

/// Step two of a password reset: the emailed code and the new password.
class ResetPasswordScreen extends ConsumerWidget {
  const ResetPasswordScreen({super.key, required this.ticket});

  final String ticket;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authSessionProvider);
    final messenger = ScaffoldMessenger.of(context);
    final updated = context.l10n.passwordUpdated;
    return AuthForm(
      title: context.l10n.setNewPassword,
      submitLabel: context.l10n.updatePassword,
      fields: [
        AuthField(
          key: const Key('reset-code'),
          label: context.l10n.codeFromEmail,
          validator: validateResetCode,
          keyboardType: TextInputType.number,
          autofillHints: const [AutofillHints.oneTimeCode],
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
        await session.resetPassword(
          ticket: ticket,
          code: values[0].trim(),
          newPassword: values[1],
        );
        messenger.showSnackBar(SnackBar(content: Text(updated)));
        if (context.mounted) context.go('/sign-in');
      },
    );
  }
}
