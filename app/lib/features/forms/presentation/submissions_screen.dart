import 'package:taskforge/core/ui/tf_icons.dart';
import 'package:taskforge/core/ui/tf_app_bar.dart';
import 'package:material_ui/material_ui.dart';
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
        leading: IconButton(
          key: const Key('back-forms'),
          tooltip: context.l10n.grpEBack,
          icon: const BackButtonIcon(),
          onPressed: () => context.go('/forms'),
        ),
        title: Text(context.l10n.formsSubmissions),
        actions: [
          IconButton(
            key: const Key('refresh-submissions'),
            tooltip: context.l10n.devRetry,
            icon: const TfIcon(TfIcons.refresh),
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
            : ListView(
                children: [
                  for (final s in data.submissions)
                    Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: ListTile(
                        key: Key('submission-${s.id}'),
                        leading: const TfIcon(TfIcons.inbox),
                        title: Text(
                          s.taskTitle.isEmpty
                              ? context.l10n.formsTaskGone
                              : '${s.taskKey} ${s.taskTitle}',
                        ),
                        subtitle: Text(
                          [
                            s.reference,
                            if (s.statusName.isNotEmpty) s.statusName,
                            if (s.email.isNotEmpty) s.email,
                            _when(context, s.at),
                          ].join(' · '),
                        ),
                        onTap: s.taskTitle.isEmpty
                            ? null
                            : () => context.go('/projects/${s.projectId}'),
                        trailing: IconButton(
                          tooltip: context.l10n.formsCopyReference,
                          icon: const TfIcon(TfIcons.copy),
                          onPressed: () => Clipboard.setData(
                            ClipboardData(text: s.reference),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
