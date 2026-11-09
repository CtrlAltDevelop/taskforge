import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskforge/core/auth/auth_providers.dart';
import 'package:taskforge/features/auth/auth_form.dart';
import 'package:taskforge/features/auth/validators.dart';

class ChangePasswordScreen extends ConsumerWidget {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authSessionProvider);
    // Held across the sign-out below, which tears this screen down.
    final messenger = ScaffoldMessenger.of(context);
    return AuthForm(
      title: 'Change password',
      submitLabel: 'Change password',
      fields: const [
        AuthField(
          key: Key('current-password'),
          label: 'Current password',
          validator: validateSignInPassword,
          secret: true,
          autofillHints: [AutofillHints.password],
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
        await session.changePassword(values[0], values[1]);
        messenger.showSnackBar(
          const SnackBar(content: Text('Password changed. Sign in again.')),
        );
      },
    );
  }
}
