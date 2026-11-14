import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/i18n/date_picker.dart';
import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/projects/application/projects_providers.dart';
import 'package:taskforge/features/projects/domain/projects.dart';
import 'package:taskforge/features/roles/application/roles_providers.dart';
import 'package:taskforge/features/roles/domain/roles.dart';
import 'package:taskforge/features/templates/application/templates_providers.dart';
import 'package:taskforge/features/templates/domain/templates.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';

void sayTemplates(BuildContext context, String text) =>
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));

/// Asks for the variables, the start date and the target, then creates
/// everything in one go. Returns the result, or null when cancelled.
Future<ApplyResult?> showApplyDialog(
  BuildContext context,
  Template template, {
  String projectId = '',
}) => showDialog<ApplyResult>(
  context: context,
  builder: (_) => _ApplyDialog(template: template, projectId: projectId),
);

class _ApplyDialog extends ConsumerStatefulWidget {
  const _ApplyDialog({required this.template, required this.projectId});

  final Template template;
  final String projectId;

  @override
  ConsumerState<_ApplyDialog> createState() => _ApplyState();
}

class _ApplyState extends ConsumerState<_ApplyDialog> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.template.name);
  late final _key = TextEditingController(
    text: deriveKey(widget.template.name),
  );
  late final Map<String, TextEditingController> _vars = {
    for (final v in widget.template.variables) v: TextEditingController(),
  };
  late String _projectId = widget.projectId;
  DateTime _start = DateTime.now();
  bool _keyEdited = false;
  bool _busy = false;
  String? _error;

  bool get _isProject => widget.template.kind == TemplateKind.project;

  @override
  void dispose() {
    _name.dispose();
    _key.dispose();
    for (final c in _vars.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    final ws = ref.read(workspaceScopeProvider);
    if (ws == null) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final result = await ref
          .read(templatesClientProvider)
          .apply(
            ws,
            ApplyDraft(
              templateId: widget.template.id,
              projectId: _projectId,
              projectName: _name.text,
              projectKey: _key.text,
              startDate: isoDay(_start),
              variables: {
                for (final e in _vars.entries) e.key: e.value.text.trim(),
              },
            ),
          );
      refreshAfterApply(ref);
      if (mounted) Navigator.of(context).pop(result);
    } on TemplatesException catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = templatesErrorMessage(e, context.l10n);
      });
    }
  }

  Future<void> _pickDate() async {
    final picked = await showAppDatePicker(
      context: context,
      initialDate: _start,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: context.l10n.tplStartDate,
    );
    if (picked != null) setState(() => _start = picked);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final projects =
        ref
            .watch(projectCatalogProvider(false))
            .value
            ?.projects
            .where((p) => !p.isArchived)
            .toList() ??
        const <Project>[];
    String? required(String? v) =>
        (v ?? '').trim().isEmpty ? t.tplRequired : null;
    return AlertDialog(
      title: Text(t.tplApplyTitle(widget.template.name)),
      content: SizedBox(
        width: 440,
        child: Form(
          key: _form,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_isProject) ...[
                  TextFormField(
                    key: const Key('tpl-project-name'),
                    controller: _name,
                    decoration: InputDecoration(labelText: t.tplProjectName),
                    validator: validateProjectName,
                    onChanged: (v) {
                      if (!_keyEdited) {
                        setState(() => _key.text = deriveKey(v));
                      }
                    },
                  ),
                  TextFormField(
                    key: const Key('tpl-project-key'),
                    controller: _key,
                    textCapitalization: TextCapitalization.characters,
                    inputFormatters: [
                      TextInputFormatter.withFunction(
                        (_, v) => v.copyWith(text: normalizeKey(v.text)),
                      ),
                    ],
                    decoration: InputDecoration(labelText: t.tplProjectKey),
                    validator: validateProjectKey,
                    onChanged: (_) => _keyEdited = true,
                  ),
                ] else
                  DropdownButtonFormField<String>(
                    key: const Key('tpl-target-project'),
                    initialValue: _projectId.isEmpty ? null : _projectId,
                    decoration: InputDecoration(labelText: t.tplTargetProject),
                    items: [
                      for (final p in projects)
                        DropdownMenuItem(
                          value: p.id,
                          child: Text('${p.key} · ${p.name}'),
                        ),
                    ],
                    validator: (v) => v == null ? t.tplRequired : null,
                    onChanged: (v) => setState(() => _projectId = v ?? ''),
                  ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(t.tplStartDate),
                  subtitle: Text(t.tplStartHelp),
                  trailing: TextButton(
                    key: const Key('tpl-start-date'),
                    onPressed: _pickDate,
                    child: Text(isoDay(_start)),
                  ),
                ),
                if (_vars.isNotEmpty) ...[
                  Text(
                    t.tplVariables,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  for (final e in _vars.entries)
                    TextFormField(
                      key: Key('tpl-var-${e.key}'),
                      controller: e.value,
                      decoration: InputDecoration(labelText: e.key),
                      validator: required,
                    ),
                ],
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      _error!,
                      key: const Key('tpl-error'),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(),
          child: Text(t.grpHCancel),
        ),
        FilledButton(
          key: const Key('tpl-apply'),
          onPressed: _busy ? null : _submit,
          child: Text(t.tplCreate),
        ),
      ],
    );
  }
}

/// The "Save as template" sheet. For a task pass [taskId]; for a project the
/// include checkboxes appear. Returns the saved template, or null.
Future<Template?> showSaveTemplateSheet(
  BuildContext context, {
  required String projectId,
  required String initialName,
  String taskId = '',
}) => showModalBottomSheet<Template>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  builder: (_) => _SaveSheet(
    projectId: projectId,
    taskId: taskId,
    initialName: initialName,
  ),
);

class _SaveSheet extends ConsumerStatefulWidget {
  const _SaveSheet({
    required this.projectId,
    required this.taskId,
    required this.initialName,
  });

  final String projectId;
  final String taskId;
  final String initialName;

  @override
  ConsumerState<_SaveSheet> createState() => _SaveState();
}

class _SaveState extends ConsumerState<_SaveSheet> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.initialName);
  final _description = TextEditingController();
  var _visibility = TemplateVisibility.workspace;
  final _parts = <TemplatePart>{
    TemplatePart.workflow,
    TemplatePart.fields,
    TemplatePart.features,
    TemplatePart.tasks,
  };
  var _assignees = false;
  bool _busy = false;
  String? _error;

  bool get _isTask => widget.taskId.isNotEmpty;

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    final ws = ref.read(workspaceScopeProvider);
    if (ws == null) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final draft = SaveDraft(
      name: _name.text,
      description: _description.text,
      visibility: _visibility,
      parts: _parts,
      includeAssignees: _assignees,
    );
    final client = ref.read(templatesClientProvider);
    try {
      final saved = _isTask
          ? await client.saveFromTask(
              ws,
              widget.projectId,
              widget.taskId,
              draft,
            )
          : await client.saveFromProject(ws, widget.projectId, draft);
      if (mounted) Navigator.of(context).pop(saved);
    } on TemplatesException catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = templatesErrorMessage(e, context.l10n);
      });
    }
  }

  String _partLabel(TemplatePart p) {
    final t = context.l10n;
    return switch (p) {
      TemplatePart.workflow => t.tplPartWorkflow,
      TemplatePart.fields => t.tplPartFields,
      TemplatePart.automations => t.tplPartAutomations,
      TemplatePart.features => t.tplPartFeatures,
      TemplatePart.tasks => t.tplPartTasks,
    };
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final perms = ref.watch(permissionSetProvider);
    final parts = [
      for (final p in TemplatePart.values)
        if (p != TemplatePart.automations || perms.can(Perm.automationManage))
          p,
    ];
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        0,
        16,
        16 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Form(
        key: _form,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t.tplSaveTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              TextFormField(
                key: const Key('tpl-save-name'),
                controller: _name,
                maxLength: 80,
                decoration: InputDecoration(labelText: t.tplName),
                validator: (v) =>
                    (v ?? '').trim().isEmpty ? t.tplRequired : null,
              ),
              TextFormField(
                controller: _description,
                maxLength: 500,
                maxLines: 2,
                decoration: InputDecoration(labelText: t.tplDescription),
              ),
              const SizedBox(height: 8),
              Text(
                t.tplVisibility,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              SegmentedButton<TemplateVisibility>(
                segments: [
                  ButtonSegment(
                    value: TemplateVisibility.workspace,
                    label: Text(t.tplShared),
                  ),
                  ButtonSegment(
                    value: TemplateVisibility.private,
                    label: Text(t.tplPrivate),
                  ),
                ],
                selected: {_visibility},
                onSelectionChanged: (s) =>
                    setState(() => _visibility = s.first),
              ),
              if (!_isTask) ...[
                const SizedBox(height: 8),
                Text(
                  t.tplInclude,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                for (final p in parts)
                  CheckboxListTile(
                    key: Key('tpl-include-${p.wire}'),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    value: _parts.contains(p),
                    title: Text(_partLabel(p)),
                    onChanged: (on) => setState(
                      () => on == true ? _parts.add(p) : _parts.remove(p),
                    ),
                  ),
              ],
              CheckboxListTile(
                key: const Key('tpl-include-assignees'),
                dense: true,
                contentPadding: EdgeInsets.zero,
                value: _assignees,
                title: Text(t.tplAssignees),
                onChanged: (on) => setState(() => _assignees = on ?? false),
              ),
              if (_error != null)
                Text(
                  _error!,
                  key: const Key('tpl-error'),
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              const SizedBox(height: 8),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: FilledButton(
                  key: const Key('tpl-save'),
                  onPressed: _busy ? null : _submit,
                  child: Text(t.tplSave),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Edits name, description and who can use a saved template.
Future<bool> showEditTemplateDialog(
  BuildContext context,
  WidgetRef ref,
  Template template,
) async {
  final name = TextEditingController(text: template.name);
  final description = TextEditingController(text: template.description);
  var visibility = template.visibility;
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => AlertDialog(
        title: Text(ctx.l10n.tplEdit),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: name,
                maxLength: 80,
                decoration: InputDecoration(labelText: ctx.l10n.tplName),
              ),
              TextField(
                controller: description,
                maxLength: 500,
                maxLines: 2,
                decoration: InputDecoration(labelText: ctx.l10n.tplDescription),
              ),
              SegmentedButton<TemplateVisibility>(
                segments: [
                  ButtonSegment(
                    value: TemplateVisibility.workspace,
                    label: Text(ctx.l10n.tplShared),
                  ),
                  ButtonSegment(
                    value: TemplateVisibility.private,
                    label: Text(ctx.l10n.tplPrivate),
                  ),
                ],
                selected: {visibility},
                onSelectionChanged: (s) => setState(() => visibility = s.first),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(ctx.l10n.grpHCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(ctx.l10n.tplSave),
          ),
        ],
      ),
    ),
  );
  final nextName = name.text;
  final nextDescription = description.text;
  name.dispose();
  description.dispose();
  final ws = ref.read(workspaceScopeProvider);
  if (ok != true || ws == null || nextName.trim().isEmpty) return false;
  try {
    await ref
        .read(templatesClientProvider)
        .update(
          ws,
          template,
          name: nextName,
          description: nextDescription,
          visibility: visibility,
        );
    return true;
  } on TemplatesException catch (e) {
    if (context.mounted) {
      sayTemplates(context, templatesErrorMessage(e, context.l10n));
    }
    return false;
  }
}
