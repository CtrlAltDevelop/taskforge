import 'package:taskforge/core/ui/tf_app_bar.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:taskforge/core/config.dart';
import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/forms/application/forms_providers.dart';
import 'package:taskforge/features/forms/domain/forms.dart';
import 'package:taskforge/features/projects/application/projects_providers.dart';
import 'package:taskforge/features/projects/domain/projects.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';

void sayForms(BuildContext context, String text) =>
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));

enum _Action { copy, submissions, edit, rotate, delete }

/// Settings, Forms: the workspace's intake forms.
class FormsScreen extends ConsumerWidget {
  const FormsScreen({super.key});

  Future<void> _run(
    BuildContext context,
    WidgetRef ref,
    Future<String?> Function(String ws) call,
  ) async {
    final ws = ref.read(workspaceScopeProvider);
    if (ws == null) return;
    try {
      final note = await call(ws);
      if (note != null && context.mounted) sayForms(context, note);
    } on FormsException catch (e) {
      if (context.mounted) {
        sayForms(context, formsErrorMessage(e, context.l10n));
      }
    }
    ref.invalidate(formsProvider);
  }

  Future<void> _new(BuildContext context, WidgetRef ref) async {
    final projects =
        ref.read(projectCatalogProvider(false)).value?.projects ??
        const <Project>[];
    if (projects.isEmpty) return;
    final chosen = await showDialog<String>(
      context: context,
      builder: (c) => SimpleDialog(
        title: Text(c.l10n.formsPickProject),
        children: [
          for (final p in projects)
            SimpleDialogOption(
              key: Key('pick-project-${p.id}'),
              onPressed: () => Navigator.of(c).pop(p.id),
              child: Text(p.name),
            ),
        ],
      ),
    );
    if (chosen != null && context.mounted) {
      await context.push('/forms/new?project=$chosen');
      ref.invalidate(formsProvider);
    }
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    IntakeForm form,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(c.l10n.formsDeleteTitle(form.name)),
        content: Text(c.l10n.formsDeleteBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(c).pop(false),
            child: Text(c.l10n.grpCCancel),
          ),
          FilledButton(
            key: const Key('confirm-delete-form'),
            onPressed: () => Navigator.of(c).pop(true),
            child: Text(c.l10n.formsDelete),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    await _run(context, ref, (ws) async {
      await ref.read(formsClientProvider).delete(ws, form.id);
      return null;
    });
  }

  Future<void> _pick(
    BuildContext context,
    WidgetRef ref,
    IntakeForm form,
    _Action action,
  ) async {
    switch (action) {
      case _Action.copy:
        await Clipboard.setData(
          ClipboardData(text: formAddress(AppConfig.webUrl, form.token)),
        );
        if (context.mounted) sayForms(context, context.l10n.formsLinkCopied);
      case _Action.submissions:
        await context.push('/forms/${form.id}/submissions');
      case _Action.edit:
        await context.push('/forms/${form.id}');
        ref.invalidate(formsProvider);
      case _Action.rotate:
        await _run(context, ref, (ws) async {
          await ref.read(formsClientProvider).rotateToken(ws, form);
          return context.mounted ? context.l10n.formsLinkRotated : null;
        });
      case _Action.delete:
        await _delete(context, ref, form);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final forms = ref.watch(formsProvider);
    final projects =
        ref.watch(projectCatalogProvider(false)).value?.projects ??
        const <Project>[];
    String projectName(String id) =>
        projects.where((p) => p.id == id).firstOrNull?.name ?? '';
    return Scaffold(
      appBar: TfAppBar(
        leading: IconButton(
          key: const Key('back-settings'),
          tooltip: context.l10n.grpEBack,
          icon: const BackButtonIcon(),
          onPressed: () => context.go('/workspaces/settings'),
        ),
        title: Text(context.l10n.formsTitle),
      ),
      body: forms.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(formsErrorMessage(e, context.l10n)),
              TextButton(
                key: const Key('retry-forms'),
                onPressed: () => ref.invalidate(formsProvider),
                child: Text(context.l10n.devRetry),
              ),
            ],
          ),
        ),
        data: (rows) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(context.l10n.formsHint),
            const SizedBox(height: 12),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: FilledButton.icon(
                key: const Key('new-form'),
                onPressed: projects.isEmpty ? null : () => _new(context, ref),
                icon: const Icon(Icons.add),
                label: Text(context.l10n.formsNew),
              ),
            ),
            const SizedBox(height: 8),
            if (rows.isEmpty)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text(context.l10n.formsEmpty),
              ),
            for (final f in rows)
              Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                clipBehavior: Clip.antiAlias,
                child: ListTile(
                  key: Key('form-${f.id}'),
                  leading: const Icon(Icons.dynamic_form_outlined),
                  title: Text(f.name),
                  subtitle: Text(
                    [
                      projectName(f.projectId),
                      context.l10n.formsSubmissionCount(f.submissionCount),
                      if (f.problem.isNotEmpty) f.problem,
                    ].where((s) => s.isNotEmpty).join(' · '),
                  ),
                  onTap: () => _pick(context, ref, f, _Action.edit),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Switch(
                        key: Key('enable-${f.id}'),
                        value: f.enabled,
                        onChanged: (on) => _run(context, ref, (ws) async {
                          await ref
                              .read(formsClientProvider)
                              .setEnabled(ws, f, enabled: on);
                          return null;
                        }),
                      ),
                      PopupMenuButton<_Action>(
                        key: Key('menu-${f.id}'),
                        onSelected: (a) => _pick(context, ref, f, a),
                        itemBuilder: (c) => [
                          PopupMenuItem(
                            value: _Action.copy,
                            child: Text(c.l10n.formsCopyLink),
                          ),
                          PopupMenuItem(
                            value: _Action.submissions,
                            child: Text(c.l10n.formsSubmissions),
                          ),
                          PopupMenuItem(
                            value: _Action.edit,
                            child: Text(c.l10n.formsEdit),
                          ),
                          PopupMenuItem(
                            value: _Action.rotate,
                            child: Text(c.l10n.formsRotateLink),
                          ),
                          PopupMenuItem(
                            value: _Action.delete,
                            child: Text(c.l10n.formsDelete),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
