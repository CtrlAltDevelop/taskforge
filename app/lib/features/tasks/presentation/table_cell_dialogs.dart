import 'package:material_ui/material_ui.dart';

import 'package:taskforge/core/i18n/date_picker.dart';
import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/fields/domain/field.dart';
import 'package:taskforge/features/fields/presentation/field_input.dart';
import 'package:taskforge/features/members/domain/members.dart';

/// A date for a task: the picked day as `YYYY-MM-DD`, an empty string to clear
/// it, null when cancelled.
Future<String?> pickTaskDate(BuildContext context, String current) async {
  final now = DateTime.now();
  final initial = DateTime.tryParse(current) ?? now;
  final choice = await showDialog<String>(
    context: context,
    builder: (dialog) => SimpleDialog(
      title: Text(dialog.l10n.grpFDate),
      children: [
        SimpleDialogOption(
          key: const Key('date-pick'),
          onPressed: () async {
            final day = await showAppDatePicker(
              context: dialog,
              initialDate: initial,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (!dialog.mounted) return;
            Navigator.pop(dialog, day?.toIso8601String().substring(0, 10));
          },
          child: Text(dialog.l10n.grpFPickDay),
        ),
        if (current.isNotEmpty)
          SimpleDialogOption(
            key: const Key('date-clear'),
            onPressed: () => Navigator.pop(dialog, ''),
            child: Text(dialog.l10n.grpFClear),
          ),
      ],
    ),
  );
  return choice;
}

/// Several members to assign: the chosen user ids when confirmed.
class AssigneeDialog extends StatefulWidget {
  const AssigneeDialog({
    super.key,
    required this.members,
    required this.selected,
  });

  final List<Member> members;
  final List<String> selected;

  @override
  State<AssigneeDialog> createState() => _AssigneeDialogState();
}

class _AssigneeDialogState extends State<AssigneeDialog> {
  late final _picked = {...widget.selected};

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(context.l10n.grpFAssignees),
    content: SizedBox(
      width: 320,
      child: ListView(
        shrinkWrap: true,
        children: [
          for (final m in widget.members)
            CheckboxListTile(
              key: Key('assign-${m.userId}'),
              value: _picked.contains(m.userId),
              title: Text(m.label),
              onChanged: (on) => setState(
                () => on == true
                    ? _picked.add(m.userId)
                    : _picked.remove(m.userId),
              ),
            ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text(context.l10n.cancel),
      ),
      FilledButton(
        key: const Key('assign-save'),
        onPressed: () => Navigator.pop(context, _picked.toList()),
        child: Text(context.l10n.save),
      ),
    ],
  );
}

/// One custom field's value in a small dialog: the new value when saved.
class FieldValueDialog extends StatefulWidget {
  const FieldValueDialog({
    super.key,
    required this.field,
    required this.value,
    required this.members,
  });

  final CustomField field;
  final String value;
  final List<Member> members;

  @override
  State<FieldValueDialog> createState() => _FieldValueDialogState();
}

class _FieldValueDialogState extends State<FieldValueDialog> {
  late String _value = widget.value;

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.field.name),
    content: SizedBox(
      width: 320,
      child: FieldInput(
        field: widget.field,
        value: _value,
        members: widget.members,
        onChanged: (v) => setState(() => _value = v),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text(context.l10n.cancel),
      ),
      FilledButton(
        key: const Key('field-value-save'),
        onPressed: () => Navigator.pop(context, _value),
        child: Text(context.l10n.save),
      ),
    ],
  );
}
