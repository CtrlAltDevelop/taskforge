import 'package:taskforge/core/ui/tf_app_bar.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/fields/application/fields_providers.dart';
import 'package:taskforge/features/fields/domain/field.dart';
import 'package:taskforge/features/forms/application/forms_providers.dart';
import 'package:taskforge/features/forms/domain/forms.dart';
import 'package:taskforge/features/forms/presentation/forms_screen.dart';
import 'package:taskforge/features/forms/presentation/public_form_page.dart';
import 'package:taskforge/features/members/application/members_providers.dart';
import 'package:taskforge/features/workflows/application/workflows_providers.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';

String _newId() =>
    'q${DateTime.now().microsecondsSinceEpoch.toRadixString(36)}';

/// Build or change one form. A new one is made for [projectId]; an existing
/// one is opened by [formId].
class FormBuilderScreen extends ConsumerWidget {
  const FormBuilderScreen({super.key, this.formId, this.projectId});

  final String? formId;
  final String? projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = formId;
    if (id == null) {
      return _Builder(projectId: projectId ?? '');
    }
    final forms = ref.watch(formsProvider);
    return forms.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
        appBar: TfAppBar(),
        body: Center(child: Text(formsErrorMessage(e, context.l10n))),
      ),
      data: (rows) {
        final found = rows.where((f) => f.id == id).firstOrNull;
        if (found == null) {
          return Scaffold(
            appBar: TfAppBar(),
            body: Center(child: Text(context.l10n.formsGone)),
          );
        }
        return _Builder(projectId: found.projectId, existing: found);
      },
    );
  }
}

class _Builder extends ConsumerStatefulWidget {
  const _Builder({required this.projectId, this.existing});

  final String projectId;
  final IntakeForm? existing;

  @override
  ConsumerState<_Builder> createState() => _BuilderState();
}

class _BuilderState extends ConsumerState<_Builder> {
  late final TextEditingController _name;
  late final TextEditingController _description;
  late final TextEditingController _color;
  late final TextEditingController _logo;
  late List<Question> _questions;
  late String _statusId;
  late String _priority;
  late Set<String> _assignees;
  late bool _enabled;
  late bool _requireEmail;
  late bool _sendConfirmation;
  late bool _notifyStatus;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final f = widget.existing;
    _name = TextEditingController(text: f?.name ?? '');
    _description = TextEditingController(text: f?.description ?? '');
    _color = TextEditingController(text: f?.brandColor ?? '');
    _logo = TextEditingController(text: f?.logoUrl ?? '');
    _statusId = f?.statusId ?? '';
    _priority = f?.priority ?? 'none';
    _assignees = {...?f?.assigneeIds};
    _enabled = f?.enabled ?? true;
    _requireEmail = f?.requireEmail ?? false;
    _sendConfirmation = f?.sendConfirmation ?? true;
    _notifyStatus = f?.notifyStatus ?? false;
    _questions = f?.questions ?? const [];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.existing == null && _questions.isEmpty) {
      final t = context.l10n;
      _questions = [
        Question(
          id: _newId(),
          kind: QuestionKind.title,
          label: t.formsDefaultTitle,
          required: true,
        ),
        Question(
          id: '${_newId()}d',
          kind: QuestionKind.description,
          label: t.formsDefaultDescription,
        ),
      ];
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _color.dispose();
    _logo.dispose();
    super.dispose();
  }

  FormDraft _draft() => FormDraft(
    name: _name.text,
    description: _description.text,
    questions: _questions,
    statusId: _statusId,
    priority: _priority,
    assigneeIds: _assignees.toList(),
    enabled: _enabled,
    requireEmail: _requireEmail,
    sendConfirmation: _sendConfirmation,
    notifyStatus: _notifyStatus,
    brandColor: _color.text,
    logoUrl: _logo.text,
  );

  Future<void> _save() async {
    final ws = ref.read(workspaceScopeProvider);
    if (ws == null || _name.text.trim().isEmpty) {
      sayForms(context, context.l10n.formsNeedName);
      return;
    }
    setState(() => _saving = true);
    try {
      final client = ref.read(formsClientProvider);
      final existing = widget.existing;
      if (existing == null) {
        await client.create(ws, widget.projectId, _draft());
      } else {
        await client.update(ws, existing, _draft());
      }
      ref.invalidate(formsProvider);
      if (!mounted) return;
      sayForms(context, context.l10n.formsSaved);
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/forms');
      }
    } on FormsException catch (e) {
      if (mounted) sayForms(context, formsErrorMessage(e, context.l10n));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _move(int from, int to) {
    final next = [..._questions];
    final item = next.removeAt(from);
    next.insert(to, item);
    setState(() => _questions = next);
  }

  Future<void> _edit(int index) async {
    final changed = await showDialog<Question>(
      context: context,
      builder: (_) => _QuestionDialog(question: _questions[index]),
    );
    if (changed == null) return;
    setState(() => _questions = [..._questions]..[index] = changed);
  }

  void _add(Question q) => setState(() => _questions = [..._questions, q]);

  Future<void> _addCustom(List<CustomField> available) async {
    final chosen = await showDialog<CustomField>(
      context: context,
      builder: (c) => SimpleDialog(
        title: Text(c.l10n.formsPickField),
        children: [
          if (available.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(c.l10n.formsNoFields),
            ),
          for (final f in available)
            SimpleDialogOption(
              key: Key('pick-field-${f.id}'),
              onPressed: () => Navigator.of(c).pop(f),
              child: Text(f.name),
            ),
        ],
      ),
    );
    if (chosen == null) return;
    _add(
      Question(
        id: _newId(),
        kind: QuestionKind.custom,
        label: chosen.name,
        required: chosen.required,
        customFieldId: chosen.id,
      ),
    );
  }

  PublicForm _preview(List<CustomField> fields) {
    PublicQuestion publicOf(Question q) {
      final field = fields.where((f) => f.id == q.customFieldId).firstOrNull;
      return PublicQuestion(
        id: q.id,
        kind: q.kind,
        label: q.label,
        help: q.help,
        required: q.required,
        type: field?.type.wire ?? '',
        options: [
          for (final o in field?.options ?? const <FieldOption>[])
            PublicOption(o.id, o.label),
        ],
        maxFiles: q.maxFiles,
      );
    }

    return PublicForm(
      name: _name.text,
      description: _description.text,
      brandColor: _color.text.trim(),
      logoUrl: _logo.text.trim(),
      requireEmail: _requireEmail,
      offersUpdates: _sendConfirmation || _notifyStatus,
      questions: [for (final q in _questions) publicOf(q)],
      captcha: null,
      maxFiles: 5,
      maxFileBytes: 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final fields =
        ref.watch(fieldsProvider(widget.projectId)).value ??
        const <CustomField>[];
    final used = {for (final q in _questions) q.customFieldId};
    final available = [
      for (final f in fields)
        if (f.type != FieldType.user && !used.contains(f.id)) f,
    ];
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: TfAppBar(
          leading: IconButton(
            key: const Key('back-forms'),
            tooltip: t.grpEBack,
            icon: const BackButtonIcon(),
            onPressed: () =>
                context.canPop() ? context.pop() : context.go('/forms'),
          ),
          title: Text(widget.existing == null ? t.formsNew : t.formsEdit),
          actions: [
            TextButton(
              key: const Key('save-form'),
              onPressed: _saving ? null : _save,
              child: Text(t.save),
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(text: t.formsBuildTab),
              Tab(text: t.formsPreviewTab),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildTab(fields, available),
            Builder(
              builder: (context) => FormSheet(
                form: _preview(fields),
                preview: true,
                onSubmit: (_) async => '',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(List<CustomField> fields, List<CustomField> available) {
    final t = context.l10n;
    final workflow = ref.watch(workflowProvider(widget.projectId)).value;
    final members = ref.watch(membersProvider).value ?? const [];
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextField(
          key: const Key('form-name-field'),
          controller: _name,
          decoration: InputDecoration(labelText: t.formsNameLabel),
        ),
        const SizedBox(height: 12),
        TextField(
          key: const Key('form-description-field'),
          controller: _description,
          maxLines: 3,
          decoration: InputDecoration(labelText: t.formsDescriptionLabel),
        ),
        const SizedBox(height: 20),
        Text(t.formsQuestions, style: Theme.of(context).textTheme.titleMedium),
        ReorderableListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          onReorderItem: _move,
          children: [
            for (var i = 0; i < _questions.length; i++)
              ListTile(
                key: ValueKey(_questions[i].id),
                leading: ReorderableDragStartListener(
                  index: i,
                  child: const Icon(Icons.drag_handle),
                ),
                title: Text(_questions[i].label),
                subtitle: Text(_kindLabel(_questions[i], fields)),
                onTap: () => _edit(i),
                trailing: _questions[i].kind == QuestionKind.title
                    ? null
                    : IconButton(
                        key: Key('remove-q-${_questions[i].id}'),
                        tooltip: t.formsRemoveQuestion,
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => setState(
                          () => _questions = [..._questions]..removeAt(i),
                        ),
                      ),
              ),
          ],
        ),
        Wrap(
          spacing: 8,
          children: [
            if (!_questions.any((q) => q.kind == QuestionKind.description))
              OutlinedButton(
                key: const Key('add-description'),
                onPressed: () => _add(
                  Question(
                    id: _newId(),
                    kind: QuestionKind.description,
                    label: t.formsDefaultDescription,
                  ),
                ),
                child: Text(t.formsAddDescription),
              ),
            OutlinedButton(
              key: const Key('add-file'),
              onPressed: () => _add(
                Question(
                  id: _newId(),
                  kind: QuestionKind.file,
                  label: t.formsDefaultFile,
                  maxFiles: 1,
                ),
              ),
              child: Text(t.formsAddFileQuestion),
            ),
            OutlinedButton(
              key: const Key('add-custom'),
              onPressed: () => _addCustom(available),
              child: Text(t.formsAddField),
            ),
          ],
        ),
        const Divider(height: 40),
        Text(t.formsTarget, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          key: const Key('form-status'),
          initialValue: workflow?.statuses.any((s) => s.id == _statusId) == true
              ? _statusId
              : '',
          decoration: InputDecoration(labelText: t.formsStatusLabel),
          items: [
            DropdownMenuItem(value: '', child: Text(t.formsStatusDefault)),
            for (final s in workflow?.statuses ?? const [])
              DropdownMenuItem(value: s.id, child: Text(s.name)),
          ],
          onChanged: (v) => setState(() => _statusId = v ?? ''),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          key: const Key('form-priority'),
          initialValue: _priority,
          decoration: InputDecoration(labelText: t.formsPriorityLabel),
          items: [
            for (final p in priorities)
              DropdownMenuItem(value: p, child: Text(_priorityLabel(p))),
          ],
          onChanged: (v) => setState(() => _priority = v ?? 'none'),
        ),
        const SizedBox(height: 12),
        Text(t.formsAssigneesLabel),
        Wrap(
          spacing: 8,
          children: [
            for (final m in members)
              FilterChip(
                key: Key('assignee-${m.userId}'),
                label: Text(m.displayName),
                selected: _assignees.contains(m.userId),
                onSelected: (on) => setState(() {
                  on ? _assignees.add(m.userId) : _assignees.remove(m.userId);
                }),
              ),
          ],
        ),
        const Divider(height: 40),
        SwitchListTile(
          key: const Key('form-enabled'),
          title: Text(t.formsEnabled),
          value: _enabled,
          onChanged: (v) => setState(() => _enabled = v),
        ),
        SwitchListTile(
          key: const Key('form-require-email'),
          title: Text(t.formsRequireEmail),
          value: _requireEmail,
          onChanged: (v) => setState(() => _requireEmail = v),
        ),
        SwitchListTile(
          key: const Key('form-confirmation'),
          title: Text(t.formsSendConfirmation),
          value: _sendConfirmation,
          onChanged: (v) => setState(() => _sendConfirmation = v),
        ),
        SwitchListTile(
          key: const Key('form-notify'),
          title: Text(t.formsNotifyStatus),
          subtitle: Text(t.formsNotifyStatusHint),
          value: _notifyStatus,
          onChanged: (v) => setState(() => _notifyStatus = v),
        ),
        const Divider(height: 40),
        Text(t.formsBranding, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        TextField(
          key: const Key('form-color'),
          controller: _color,
          decoration: InputDecoration(
            labelText: t.formsColorLabel,
            hintText: '#1a73e8',
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          key: const Key('form-logo'),
          controller: _logo,
          keyboardType: TextInputType.url,
          decoration: InputDecoration(labelText: t.formsLogoLabel),
        ),
      ],
    );
  }

  String _priorityLabel(String p) => switch (p) {
    'low' => context.l10n.formsPriorityLow,
    'medium' => context.l10n.formsPriorityMedium,
    'high' => context.l10n.formsPriorityHigh,
    'urgent' => context.l10n.formsPriorityUrgent,
    _ => context.l10n.formsPriorityNone,
  };

  String _kindLabel(Question q, List<CustomField> fields) {
    final t = context.l10n;
    final suffix = q.required ? ' · ${t.formsRequiredTag}' : '';
    final kind = switch (q.kind) {
      QuestionKind.title => t.formsKindTitle,
      QuestionKind.description => t.formsKindDescription,
      QuestionKind.file => t.formsKindFile,
      QuestionKind.custom =>
        fields.where((f) => f.id == q.customFieldId).firstOrNull?.name ??
            t.formsKindField,
    };
    return '$kind$suffix';
  }
}

class _QuestionDialog extends StatefulWidget {
  const _QuestionDialog({required this.question});

  final Question question;

  @override
  State<_QuestionDialog> createState() => _QuestionDialogState();
}

class _QuestionDialogState extends State<_QuestionDialog> {
  late final _label = TextEditingController(text: widget.question.label);
  late final _help = TextEditingController(text: widget.question.help);
  late bool _required = widget.question.required;
  late int _maxFiles = widget.question.maxFiles;

  @override
  void dispose() {
    _label.dispose();
    _help.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final isTitle = widget.question.kind == QuestionKind.title;
    return AlertDialog(
      title: Text(t.formsEditQuestion),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              key: const Key('question-label'),
              controller: _label,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(labelText: t.formsQuestionLabel),
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('question-help'),
              controller: _help,
              decoration: InputDecoration(labelText: t.formsQuestionHelp),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              key: const Key('question-required'),
              contentPadding: EdgeInsets.zero,
              title: Text(t.formsQuestionRequired),
              value: _required || isTitle,
              onChanged: isTitle ? null : (v) => setState(() => _required = v),
            ),
            const SizedBox(height: 12),
            if (widget.question.kind == QuestionKind.file)
              DropdownButtonFormField<int>(
                key: const Key('question-max-files'),
                initialValue: _maxFiles < 1 ? 1 : _maxFiles,
                decoration: InputDecoration(labelText: t.formsMaxFiles),
                items: [
                  for (var n = 1; n <= 5; n++)
                    DropdownMenuItem(value: n, child: Text('$n')),
                ],
                onChanged: (v) => setState(() => _maxFiles = v ?? 1),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(t.grpCCancel),
        ),
        FilledButton(
          key: const Key('question-ok'),
          onPressed: _label.text.trim().isEmpty
              ? null
              : () => Navigator.of(context).pop(
                  widget.question.copyWith(
                    label: _label.text.trim(),
                    help: _help.text.trim(),
                    required: _required || isTitle,
                    maxFiles: _maxFiles,
                  ),
                ),
          child: Text(t.save),
        ),
      ],
    );
  }
}
