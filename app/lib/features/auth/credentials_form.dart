import 'package:flutter/material.dart';
import 'package:taskforge/features/auth/auth_form.dart';
import 'package:taskforge/features/auth/validators.dart';

/// Email + password form shared by sign-in and sign-up.
class CredentialsForm extends StatelessWidget {
  const CredentialsForm({
    super.key,
    required this.title,
    required this.submitLabel,
    required this.passwordValidator,
    required this.onSubmit,
    required this.footer,
  });

  final String title;
  final String submitLabel;
  final FormFieldValidator<String> passwordValidator;
  final Future<void> Function(String email, String password) onSubmit;
  final Widget footer;

  @override
  Widget build(BuildContext context) {
    return AuthForm(
      title: title,
      submitLabel: submitLabel,
      fields: [
        const AuthField(
          key: Key('email'),
          label: 'Email',
          validator: validateEmail,
          keyboardType: TextInputType.emailAddress,
          autofillHints: [AutofillHints.email],
        ),
        AuthField(
          key: const Key('password'),
          label: 'Password',
          validator: passwordValidator,
          secret: true,
          autofillHints: const [AutofillHints.password],
        ),
      ],
      onSubmit: (values) => onSubmit(values[0].trim(), values[1]),
      footer: footer,
    );
  }
}
