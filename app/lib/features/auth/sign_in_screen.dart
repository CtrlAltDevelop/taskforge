import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:taskforge/core/auth/auth_providers.dart';
import 'package:taskforge/features/auth/credentials_form.dart';
import 'package:taskforge/features/auth/validators.dart';

class SignInScreen extends ConsumerWidget {
  const SignInScreen({super.key, this.from});

  /// Where to go after signing in (the page that needed a session).
  final String? from;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authSessionProvider);
    return CredentialsForm(
      title: 'Sign in',
      submitLabel: 'Sign in',
      passwordValidator: validateSignInPassword,
      onSubmit: session.signIn,
      footer: Column(
        children: [
          TextButton(
            key: const Key('go-forgot'),
            onPressed: () => context.go('/forgot-password'),
            child: const Text('Forgot your password?'),
          ),
          TextButton(
            key: const Key('go-sign-up'),
            onPressed: () => context.go(
              from == null
                  ? '/sign-up'
                  : '/sign-up?from=${Uri.encodeComponent(from!)}',
            ),
            child: const Text('Create an account'),
          ),
        ],
      ),
    );
  }
}
