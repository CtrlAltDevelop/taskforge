import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/projects/presentation/app_shell.dart';
import 'package:taskforge/features/templates/application/templates_providers.dart';
import 'package:taskforge/features/templates/domain/templates.dart';
import 'package:taskforge/features/templates/presentation/template_dialogs.dart';
import 'package:taskforge/features/templates/presentation/template_preview.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';

/// The gallery: search, the structure of each template, use / edit / delete.
class TemplatesScreen extends ConsumerStatefulWidget {
  const TemplatesScreen({super.key, this.kind});

  /// Opens filtered to one kind (the project-create flow asks for projects).
  final TemplateKind? kind;

  @override
  ConsumerState<TemplatesScreen> createState() => _State();
}

class _State extends ConsumerState<TemplatesScreen> {
  final _search = TextEditingController();
  late TemplateKind? _kind = widget.kind;
  String _text = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _open(Template template) async {
    await showDialog<void>(
      context: context,
      builder: (_) => _PreviewDialog(
        summary: template,
        onChanged: () =>
            ref.invalidate(templatesProvider((text: _text, kind: _kind))),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final query = (text: _text, kind: _kind);
    final gallery = ref.watch(templatesProvider(query));
    return ShellScaffold(
      appBar: AppBar(title: Text(t.tplTitle)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              key: const Key('tpl-search'),
              controller: _search,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: t.tplSearch,
              ),
              onChanged: (v) => setState(() => _text = v),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: SegmentedButton<TemplateKind?>(
                showSelectedIcon: false,
                segments: [
                  ButtonSegment(value: null, label: Text(t.tplAll)),
                  ButtonSegment(
                    value: TemplateKind.project,
                    label: Text(t.tplKindProject),
                  ),
                  ButtonSegment(
                    value: TemplateKind.task,
                    label: Text(t.tplKindTask),
                  ),
                ],
                selected: {_kind},
                onSelectionChanged: (s) => setState(() => _kind = s.first),
              ),
            ),
          ),
          Expanded(
            child: gallery.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: TextButton(
                  onPressed: () => ref.invalidate(templatesProvider(query)),
                  child: Text(templatesErrorMessage(e, t)),
                ),
              ),
              data: (items) => items.isEmpty
                  ? Center(child: Text(t.tplEmpty, key: const Key('tpl-empty')))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: items.length,
                      itemBuilder: (_, i) => _Card(
                        template: items[i],
                        onTap: () => _open(items[i]),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.template, required this.onTap});

  final Template template;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final badges = [
      if (template.builtin) t.tplBuiltIn,
      if (template.visibility == TemplateVisibility.private) t.tplPrivate,
      template.kind == TemplateKind.project ? t.tplKindProject : t.tplKindTask,
      t.tplTasksN(template.taskCount),
    ];
    return Card(
      child: ListTile(
        key: Key('tpl-${template.id}'),
        leading: Icon(
          template.kind == TemplateKind.project
              ? Icons.folder_copy_outlined
              : Icons.account_tree_outlined,
        ),
        title: Text(template.name),
        subtitle: Text(
          [
            if (template.description.isNotEmpty) template.description,
            badges.join(' · '),
          ].join('\n'),
        ),
        isThreeLine: template.description.isNotEmpty,
        onTap: onTap,
      ),
    );
  }
}

class _PreviewDialog extends ConsumerWidget {
  const _PreviewDialog({required this.summary, required this.onChanged});

  final Template summary;
  final VoidCallback onChanged;

  Future<void> _use(BuildContext context, WidgetRef ref, Template tpl) async {
    final navigator = Navigator.of(context);
    final router = GoRouter.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    final result = await showApplyDialog(context, tpl);
    if (result == null) return;
    navigator.pop();
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            result.warnings.isEmpty
                ? l10n.tplApplied(result.taskIds.length)
                : '${l10n.tplWarnings}: ${result.warnings.join(' ')}',
          ),
        ),
      );
    if (result.projectId.isNotEmpty) {
      router.go('/projects/${result.projectId}');
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final t = context.l10n;
    final sure = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Text(t.tplDeleteAsk),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(t.grpHCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(t.tplDelete),
          ),
        ],
      ),
    );
    final ws = ref.read(workspaceScopeProvider);
    if (sure != true || ws == null || !context.mounted) return;
    final navigator = Navigator.of(context);
    try {
      await ref.read(templatesClientProvider).delete(ws, summary.id);
      onChanged();
      navigator.pop();
    } on TemplatesException catch (e) {
      if (context.mounted) {
        sayTemplates(context, templatesErrorMessage(e, t));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.l10n;
    final detail = ref.watch(templateProvider(summary.id));
    final template = detail.value;
    return AlertDialog(
      title: Text(summary.name),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (summary.description.isNotEmpty) Text(summary.description),
              if (template != null)
                TemplatePreview(template: template)
              else if (detail.hasError)
                Text(templatesErrorMessage(detail.error!, t))
              else
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                ),
            ],
          ),
        ),
      ),
      actions: [
        if (template != null && !template.builtin && template.canEdit) ...[
          TextButton(
            key: const Key('tpl-delete'),
            onPressed: () => _delete(context, ref),
            child: Text(t.tplDelete),
          ),
          TextButton(
            key: const Key('tpl-edit'),
            onPressed: () async {
              final navigator = Navigator.of(context);
              if (await showEditTemplateDialog(context, ref, template)) {
                onChanged();
                navigator.pop();
              }
            },
            child: Text(t.tplEdit),
          ),
        ],
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(t.grpHCancel),
        ),
        FilledButton(
          key: const Key('tpl-use'),
          onPressed: template == null
              ? null
              : () => _use(context, ref, template),
          child: Text(t.tplApply),
        ),
      ],
    );
  }
}
