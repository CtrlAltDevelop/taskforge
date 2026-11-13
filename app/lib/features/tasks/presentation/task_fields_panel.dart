import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/fields/application/fields_providers.dart';
import 'package:taskforge/features/fields/domain/field.dart';
import 'package:taskforge/features/fields/presentation/field_input.dart';
import 'package:taskforge/features/members/domain/members.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';
import 'package:taskforge/features/tasks/presentation/task_actions.dart';
import 'package:taskforge/l10n/gen/app_localizations.dart';

/// The custom fields of a project on the task detail: one input per field.
/// A required field with no value is highlighted; clearing one is refused
/// before it is sent.
class TaskFieldsPanel extends ConsumerWidget {
  const TaskFieldsPanel({
    super.key,
    required this.projectId,
    required this.task,
    required this.canEdit,
    required this.members,
  });

  final String projectId;
  final Task task;
  final bool canEdit;
  final List<Member> members;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fields = ref.watch(fieldsProvider(projectId)).value ?? const [];
    if (fields.isEmpty) return const SizedBox.shrink();
    return Column(
      key: const Key('task-fields'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.grpFFields,
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 8),
        for (final f in fields)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            // Keyed by the value so a rollback or someone else's edit shows.
            child: KeyedSubtree(
              key: ValueKey('${f.id}=${task.fieldValues[f.id] ?? ''}'),
              child: FieldInput(
                field: f,
                value: task.fieldValues[f.id] ?? '',
                enabled: canEdit,
                members: members,
                errorText: f.required && (task.fieldValues[f.id] ?? '').isEmpty
                    ? 'Required'
                    : null,
                onChanged: (v) => saveTask(
                  context,
                  ref,
                  task,
                  TaskPatch(fieldValues: {f.id: v}),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// What a task row shows of its custom fields: the values of the fields that
/// the List view shows, as `Name: value`, at most [limit] of them.
String fieldSummary(
  Task task,
  List<CustomField> fields, {
  String Function(String id)? userLabel,
  int limit = 3,
  AppLocalizations? l10n,
}) {
  final parts = <String>[];
  for (final f in fields) {
    if (!f.shownIn('list')) continue;
    final text = fieldDisplay(
      f,
      task.fieldValues[f.id] ?? '',
      userLabel: userLabel,
      l10n: l10n,
    );
    if (text.isNotEmpty) parts.add('${f.name}: $text');
    if (parts.length == limit) break;
  }
  return parts.join(' · ');
}

/// "New task" with the required custom fields that nothing fills in. Pops the
/// values (field id -> wire value) once every one has one.
class RequiredFieldsDialog extends StatefulWidget {
  const RequiredFieldsDialog({
    super.key,
    required this.title,
    required this.fields,
    required this.members,
  });

  final String title;
  final List<CustomField> fields;
  final List<Member> members;

  @override
  State<RequiredFieldsDialog> createState() => _RequiredFieldsDialogState();
}

class _RequiredFieldsDialogState extends State<RequiredFieldsDialog> {
  // A checkbox shows as off, so off ("false") is its value until it is switched.
  late final _values = <String, String>{
    for (final f in widget.fields)
      if (f.type == FieldType.checkbox) f.id: 'false',
  };
  var _tried = false;

  bool _missing(CustomField f) => (_values[f.id] ?? '').isEmpty;

  void _create() {
    setState(() => _tried = true);
    if (widget.fields.any(_missing)) return;
    Navigator.pop(context, Map<String, String>.of(_values));
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.title),
    content: SizedBox(
      width: 420,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(context.l10n.grpFRequiredFieldsIntro),
            const SizedBox(height: 12),
            for (final f in widget.fields)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: FieldInput(
                  field: f,
                  value: _values[f.id] ?? '',
                  members: widget.members,
                  errorText: _tried && _missing(f)
                      ? context.l10n.grpFRequired
                      : null,
                  onChanged: (v) => setState(() => _values[f.id] = v),
                ),
              ),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        key: const Key('required-cancel'),
        onPressed: () => Navigator.pop(context),
        child: Text(context.l10n.cancel),
      ),
      FilledButton(
        key: const Key('required-create'),
        onPressed: _create,
        child: Text(context.l10n.grpFCreate),
      ),
    ],
  );
}
