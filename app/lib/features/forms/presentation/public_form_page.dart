import 'package:taskforge/core/ui/tokens/spacing.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/forms/application/forms_providers.dart';
import 'package:taskforge/features/forms/domain/forms.dart';
import 'package:taskforge/features/forms/presentation/public_form_view.dart';
import 'package:taskforge/core/ui/tf/tf_feedback.dart';
import 'package:taskforge/core/ui/tf/tf_illustration.dart';

/// The page at `/f/<token>`: a form for anyone, with no app bar, no menu and
/// no sign-in. It knows only what the server tells a visitor about the form.
class PublicFormPage extends ConsumerWidget {
  const PublicFormPage({super.key, required this.token});

  final String token;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(publicFormProvider(token));
    return Scaffold(
      body: SafeArea(
        child: form.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => _Problem(
            error: e,
            onRetry: () => ref.invalidate(publicFormProvider(token)),
          ),
          data: (data) => FormSheet(
            form: data,
            onSubmit: (answers) => ref
                .read(publicFormsClientProvider)
                .submit(
                  token,
                  answers,
                  languageTag: Localizations.localeOf(context).toLanguageTag(),
                ),
          ),
        ),
      ),
    );
  }
}

/// A form's heading (logo, name, text) above its fields, in its brand colour.
class FormSheet extends StatelessWidget {
  const FormSheet({
    super.key,
    required this.form,
    required this.onSubmit,
    this.preview = false,
  });

  final PublicForm form;
  final Future<String> Function(FormAnswers answers) onSubmit;
  final bool preview;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brand = brandColorOf(form.brandColor);
    final themed = brand == null
        ? theme
        : theme.copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: brand,
              brightness: theme.brightness,
            ),
          );
    return Theme(
      data: themed,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(TfSpace.xl),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (form.logoUrl.isNotEmpty)
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Image.network(
                      form.logoUrl,
                      height: 56,
                      excludeFromSemantics: true, // the name is right below
                      errorBuilder: (_, _, _) => const SizedBox.shrink(),
                    ),
                  ),
                const SizedBox(height: TfSpace.md),
                Text(
                  form.name,
                  key: const Key('form-name'),
                  style: themed.textTheme.headlineSmall?.copyWith(
                    color: themed.colorScheme.primary,
                  ),
                ),
                if (form.description.isNotEmpty) ...[
                  const SizedBox(height: TfSpace.sm),
                  Text(form.description),
                ],
                const SizedBox(height: TfSpace.xl),
                PublicFormView(
                  form: form,
                  onSubmit: onSubmit,
                  preview: preview,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Problem extends StatelessWidget {
  const _Problem({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final gone =
        error is FormsException &&
        (error as FormsException).failure == FormsFailure.notFound;
    if (gone) {
      return TfEmpty(
        key: const Key('form-problem'),
        illustration: TfIllustrationKind.notFound,
        title: context.l10n.formsGonePage,
      );
    }
    return TfError(
      key: const Key('form-problem'),
      message: formsErrorMessage(error, context.l10n),
      details: '$error',
      retryKey: const Key('retry-public-form'),
      onRetry: onRetry,
    );
  }
}
