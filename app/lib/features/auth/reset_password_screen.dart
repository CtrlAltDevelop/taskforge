import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:taskforge/core/auth/auth_providers.dart';
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
    return AuthForm(
      title: 'Set a new password',
      submitLabel: 'Update password',
      fields: const [
        AuthField(
          key: Key('reset-code'),
          label: 'Code from your email',
          validator: validateResetCode,
          keyboardType: TextInputType.number,
          autofillHints: [AutofillHints.oneTimeCode],
        ),
        AuthField(
          key: Key('new-password'),
          label: 'New password',
          validator: validatePassword,
          secret: true,
          autofillHints: [AutofillHints.newPassword],
        ),
      ],
      onSubmit: (values) async {
        await session.resetPassword(
          ticket: ticket,
          code: values[0].trim(),
          newPassword: values[1],
        );
        messenger.showSnackBar(
          const SnackBar(content: Text('Password updated. Sign in with it.')),
        );
        if (context.mounted) context.go('/sign-in');
      },
    );
  }
}
