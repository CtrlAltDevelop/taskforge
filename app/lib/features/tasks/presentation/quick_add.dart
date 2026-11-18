import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/fields/application/fields_providers.dart';
import 'package:taskforge/features/fields/domain/field.dart';
import 'package:taskforge/features/members/application/members_providers.dart';
import 'package:taskforge/features/members/domain/members.dart';
import 'package:taskforge/features/tasks/application/tasks_providers.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';

export 'package:taskforge/features/tasks/presentation/task_actions.dart'
    show TaskAction;
import 'package:taskforge/features/tasks/presentation/task_fields_panel.dart';
import 'package:taskforge/core/ui/tf_icons.dart';
import 'package:taskforge/features/shortcuts/presentation/shortcut_hint.dart';

/// One field, Enter adds a task: no dialog, no required fields beyond the title.
class QuickAdd extends ConsumerStatefulWidget {
  const QuickAdd({super.key, required this.projectId});

  final String projectId;

  @override
  ConsumerState<QuickAdd> createState() => _QuickAddState();
}

class _QuickAddState extends ConsumerState<QuickAdd> {
  final _controller = TextEditingController();
  var _busy = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit(String value) async {
    final title = value.trim();
    if (title.isEmpty || _busy) return;
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    setState(() => _busy = true);
    try {
      final values = await _requiredValues(title);
      if (values == null) return; // cancelled
      await ref
          .read(taskListProvider(widget.projectId).notifier)
          .create(title, fieldValues: values);
      _controller.clear();
    } on TaskException catch (e) {
      if (e.failure == TaskFailure.fieldRequired) {
        // The field list we hold is stale: read it again and ask next time.
        ref.invalidate(fieldsProvider(widget.projectId));
      }
      messenger.showSnackBar(
        SnackBar(content: Text(taskErrorMessage(e, l10n))),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Values for the required fields that nothing fills in (none when there are
  /// no such fields); null when the user cancelled the dialog.
  Future<Map<String, String>?> _requiredValues(String title) async {
    final List<CustomField> fields;
    try {
      fields = await ref.read(fieldsProvider(widget.projectId).future);
    } on FieldException {
      return const {}; // cannot tell: the server decides (FIELD_REQUIRED)
    }
    if (!mounted) return null;
    final needed = [
      for (final f in fields)
        if (f.needsValueOnCreate) f,
    ];
    if (needed.isEmpty) return const {};
    return showDialog<Map<String, String>>(
      context: context,
      builder: (_) => RequiredFieldsDialog(
        title: title,
        fields: needed,
        members: ref.read(membersProvider).value ?? const <Member>[],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Kept loaded, so submitting does not wait for the field list.
    ref.watch(fieldsProvider(widget.projectId));
    return _field();
  }

  Widget _field() => Padding(
    padding: const EdgeInsets.all(12),
    child: TextField(
      key: const Key('quick-add'),
      controller: _controller,
      enabled: !_busy,
      maxLength: maxTitleLength,
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        hintText: withShortcut(
          ref,
          context.l10n.taskAddHint,
          'task.new',
          l10n: context.l10n,
        ),
        prefixIcon: const TfIcon(TfIcons.plus, size: TfIconSize.control),
        counterText: '',
        border: const OutlineInputBorder(),
      ),
      onSubmitted: _submit,
    ),
  );
}
