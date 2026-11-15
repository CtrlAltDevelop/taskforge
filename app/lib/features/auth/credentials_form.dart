import 'package:material_ui/material_ui.dart';
import 'package:taskforge/features/auth/auth_form.dart';
import 'package:taskforge/core/i18n/l10n_context.dart';
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
  final AuthValidator passwordValidator;
  final Future<void> Function(String email, String password) onSubmit;
  final Widget footer;

  @override
  Widget build(BuildContext context) {
    return AuthForm(
      title: title,
      submitLabel: submitLabel,
      fields: [
        AuthField(
          key: const Key('email'),
          label: context.l10n.email,
          validator: validateEmail,
          keyboardType: TextInputType.emailAddress,
          autofillHints: const [AutofillHints.email],
        ),
        AuthField(
          key: const Key('password'),
          label: context.l10n.password,
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
