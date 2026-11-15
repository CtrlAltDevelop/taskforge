import 'package:taskforge/core/ui/tf_app_bar.dart';
import 'package:material_ui/material_ui.dart';
import 'package:taskforge/core/auth/auth_api.dart';
import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/account/language_menu.dart';
import 'package:taskforge/features/auth/validators.dart';

/// One text field of an [AuthForm].
class AuthField {
  const AuthField({
    required this.key,
    required this.label,
    this.validator,
    this.secret = false,
    this.keyboardType,
    this.autofillHints,
  });

  final Key key;
  final String label;
  final AuthValidator? validator;

  /// Hide the text, with a show/hide toggle.
  final bool secret;
  final TextInputType? keyboardType;
  final Iterable<String>? autofillHints;
}

/// A titled form that validates, submits, shows server errors and a busy state.
/// The submit button is `Key('submit')`.
class AuthForm extends StatefulWidget {
  const AuthForm({
    super.key,
    required this.title,
    required this.submitLabel,
    required this.fields,
    required this.onSubmit,
    this.footer,
  });

  final String title;
  final String submitLabel;
  final List<AuthField> fields;

  /// Receives the field values in order. Throw [AuthApiException] or
  /// [NetworkUnavailable] to show a message and stay on the form.
  final Future<void> Function(List<String> values) onSubmit;
  final Widget? footer;

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  late final List<TextEditingController> _controllers = [
    for (final _ in widget.fields) TextEditingController(),
  ];
  late final List<bool> _hidden = [for (final f in widget.fields) f.secret];
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final l10n = context.l10n;
    String? error;
    try {
      await widget.onSubmit([for (final c in _controllers) c.text]);
    } on AuthApiException catch (e) {
      error = authErrorMessage(e, l10n);
    } on NetworkUnavailable catch (e) {
      error = authErrorMessage(e, l10n);
    }
    if (!mounted) return;
    setState(() {
      _busy = false;
      _error = error;
    });
  }

  Widget _field(int index) {
    final spec = widget.fields[index];
    final last = index == widget.fields.length - 1;
    return TextFormField(
      key: spec.key,
      controller: _controllers[index],
      decoration: InputDecoration(
        labelText: spec.label,
        suffixIcon: spec.secret
            ? IconButton(
                tooltip: _hidden[index]
                    ? context.l10n.showPassword
                    : context.l10n.hidePassword,
                icon: Icon(
                  _hidden[index] ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () =>
                    setState(() => _hidden[index] = !_hidden[index]),
              )
            : null,
      ),
      obscureText: _hidden[index],
      keyboardType: spec.keyboardType,
      autofillHints: spec.autofillHints,
      textInputAction: last ? TextInputAction.done : TextInputAction.next,
      validator: spec.validator == null
          ? null
          : (value) => spec.validator!(value, context.l10n),
      onFieldSubmitted: last ? (_) => _submit() : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: TfAppBar(
        title: Text(widget.title),
        actions: const [LanguageMenuButton()],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(24),
              shrinkWrap: true,
              children: [
                for (var i = 0; i < widget.fields.length; i++) ...[
                  if (i > 0) const SizedBox(height: 16),
                  _field(i),
                ],
                if (_error case final error?) ...[
                  const SizedBox(height: 16),
                  Text(error, style: TextStyle(color: colors.error)),
                ],
                const SizedBox(height: 24),
                FilledButton(
                  key: const Key('submit'),
                  onPressed: _busy ? null : _submit,
                  child: _busy
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(widget.submitLabel),
                ),
                if (widget.footer case final footer?) ...[
                  const SizedBox(height: 8),
                  footer,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
