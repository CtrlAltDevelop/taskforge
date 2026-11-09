import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:taskforge/core/auth/auth_providers.dart';
import 'package:taskforge/features/auth/credentials_form.dart';
import 'package:taskforge/features/auth/validators.dart';

class SignUpScreen extends ConsumerWidget {
  const SignUpScreen({super.key, this.from});

  final String? from;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authSessionProvider);
    return CredentialsForm(
      title: 'Create account',
      submitLabel: 'Create account',
      passwordValidator: validatePassword,
      onSubmit: session.signUp,
      footer: TextButton(
        key: const Key('go-sign-in'),
        onPressed: () => context.go(
          from == null
              ? '/sign-in'
              : '/sign-in?from=${Uri.encodeComponent(from!)}',
        ),
        child: const Text('I already have an account'),
      ),
    );
  }
}
