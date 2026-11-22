import 'package:taskforge/core/ui/tokens/spacing.dart';
import 'package:taskforge/core/ui/tf/tf_row.dart';
import 'package:taskforge/core/ui/tf/tf_panel.dart';
import 'package:taskforge/core/ui/tf/tf_button.dart';
import 'package:taskforge/core/ui/tf_icons.dart';
import 'package:taskforge/core/ui/tf_app_bar.dart';
import 'package:material_ui/material_ui.dart';
import 'package:taskforge/core/ui/page/tf_page.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:taskforge/core/i18n/context_dates.dart';
import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/forms/application/forms_providers.dart';
import 'package:taskforge/features/forms/domain/forms.dart';
import 'package:taskforge/core/ui/tf/tf_feedback.dart';
import 'package:taskforge/core/ui/tf/tf_illustration.dart';

/// What came in through one form: reference, the task it made, who sent it.
class SubmissionsScreen extends ConsumerWidget {
  const SubmissionsScreen({super.key, required this.formId});

  final String formId;

  String _when(BuildContext context, String iso) {
    final at = DateTime.tryParse(iso);
    return at == null ? '' : context.localIso(at.toLocal());
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final page = ref.watch(submissionsProvider(formId));
    return Scaffold(
      appBar: TfAppBar(
        leading: TfIconButton(
          key: const Key('back-forms'),
          icon: TfIcons.arrowStart,
          tooltip: context.l10n.grpEBack,
          onPressed: () => context.go('/forms'),
        ),
        title: Text(context.l10n.formsSubmissions),
        actions: [
          TfIconButton(
            key: const Key('refresh-submissions'),
            icon: TfIcons.refresh,
            tooltip: context.l10n.devRetry,
            onPressed: () => ref.invalidate(submissionsProvider(formId)),
          ),
        ],
      ),
      body: page.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => TfError(
          message: formsErrorMessage(e, context.l10n),
          details: '$e',
          retryKey: const Key('retry-submissions'),
          onRetry: () => ref.invalidate(submissionsProvider(formId)),
        ),
        data: (data) => data.submissions.isEmpty
            ? TfEmpty(
                illustration: TfIllustrationKind.docs,
                title: context.l10n.formsNoSubmissions,
              )
            : TfPage(
                lazy: true,
                children: [
                  for (final s in data.submissions)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: TfSpace.xs),
                      child: TfPanel(
                        padding: EdgeInsets.zero,
                        child: TfRow(
                          key: Key('submission-${s.id}'),
                          title: s.taskTitle.isEmpty
                              ? context.l10n.formsTaskGone
                              : '${s.taskKey} ${s.taskTitle}',
                          subtitle: [
                            s.reference,
                            if (s.statusName.isNotEmpty) s.statusName,
                            if (s.email.isNotEmpty) s.email,
                            _when(context, s.at),
                          ].join(' · '),
                          leading: const TfIcon(TfIcons.inbox),
                          trailing: TfIconButton(
                            icon: TfIcons.copy,
                            tooltip: context.l10n.formsCopyReference,
                            onPressed: () => Clipboard.setData(
                              ClipboardData(text: s.reference),
                            ),
                          ),
                          onTap: s.taskTitle.isEmpty
                              ? null
                              : () => context.go('/projects/${s.projectId}'),
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
