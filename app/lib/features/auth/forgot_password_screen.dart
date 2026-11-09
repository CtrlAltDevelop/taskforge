import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:taskforge/core/auth/auth_providers.dart';
import 'package:taskforge/features/auth/auth_form.dart';
import 'package:taskforge/features/auth/validators.dart';

/// Step one of a password reset: ask for a one-time code by email.
class ForgotPasswordScreen extends ConsumerWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authSessionProvider);
    return AuthForm(
      title: 'Reset password',
      submitLabel: 'Send code',
      fields: const [
        AuthField(
          key: Key('email'),
          label: 'Email',
          validator: validateEmail,
          keyboardType: TextInputType.emailAddress,
          autofillHints: [AutofillHints.email],
        ),
      ],
      onSubmit: (values) async {
        final ticket = await session.requestPasswordReset(values[0].trim());
        if (!context.mounted) return;
        // The ticket travels in navigation state, not in the URL.
        context.go('/reset-password', extra: ticket);
      },
      footer: TextButton(
        onPressed: () => context.go('/sign-in'),
        child: const Text('Back to sign in'),
      ),
    );
  }
}
