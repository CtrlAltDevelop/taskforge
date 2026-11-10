import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:taskforge/features/fields/application/fields_providers.dart';
import 'package:taskforge/features/fields/domain/field.dart';
import 'package:taskforge/features/fields/presentation/field_dialogs.dart';
import 'package:taskforge/features/members/application/members_providers.dart';
import 'package:taskforge/features/members/domain/members.dart';
import 'package:taskforge/features/projects/application/project_access.dart';
import 'package:taskforge/features/projects/application/projects_providers.dart';
import 'package:taskforge/features/roles/application/roles_providers.dart';
import 'package:taskforge/features/roles/domain/roles.dart';
import 'package:taskforge/features/tasks/application/tasks_providers.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';

IconData fieldTypeIcon(FieldType type) => switch (type) {
  FieldType.text => Icons.text_fields,
  FieldType.number => Icons.numbers,
  FieldType.select => Icons.arrow_drop_down_circle_outlined,
  FieldType.multiselect => Icons.checklist,
  FieldType.date => Icons.calendar_today,
  FieldType.checkbox => Icons.check_box_outlined,
  FieldType.url => Icons.link,
  FieldType.user => Icons.person_outline,
  FieldType.money => Icons.attach_money,
};

/// Project settings → Fields: add, edit, reorder, archive and restore the
/// project's custom fields.
class FieldsScreen extends ConsumerStatefulWidget {
  const FieldsScreen({super.key, required this.projectId});

  final String projectId;

  @override
  ConsumerState<FieldsScreen> createState() => _FieldsScreenState();
}

class _FieldsScreenState extends ConsumerState<FieldsScreen> {
  /// The order while a reorder is being saved (so the list does not jump back).
  List<CustomField>? _reordered;

  String get _workspace => ref.read(workspaceScopeProvider) ?? '';

  void _say(String text) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text)));

  /// What changed on the server may have changed task values (a remap, an
  /// archive): read the list again.
  void _refresh() {
    ref.invalidate(fieldsProvider(widget.projectId));
    ref.invalidate(archivedFieldsProvider(widget.projectId));
    ref.read(taskListProvider(widget.projectId).notifier).refresh();
    setState(() => _reordered = null);
  }

  List<Member> get _members =>
      ref.read(membersProvider).value ?? const <Member>[];

  Future<void> _add() async {
    final draft = await showDialog<FieldDraft>(
      context: context,
      builder: (_) => FieldEditorDialog(members: _members),
    );
    if (draft == null || !mounted) return;
    try {
      await ref
          .read(fieldsClientProvider)
          .create(_workspace, widget.projectId, draft);
      _refresh();
    } on Object catch (e) {
      if (mounted) _say(fieldErrorMessage(mapAny(e)));
    }
  }

  Future<void> _edit(CustomField field) async {
    final draft = await showDialog<FieldDraft>(
      context: context,
      builder: (_) => FieldEditorDialog(field: field, members: _members),
    );
    if (draft == null || !mounted) return;
    await _save(field, draft, const {});
  }

  Future<void> _save(
    CustomField field,
    FieldDraft draft,
    Map<String, String> remap,
  ) async {
    try {
      await ref
          .read(fieldsClientProvider)
          .update(_workspace, field, draft, remap: remap);
      _refresh();
    } on Object catch (e) {
      final error = mapAny(e);
      if (error.failure == FieldFailure.needsRemap && mounted) {
        final chosen = await showDialog<Map<String, String>>(
          context: context,
          builder: (_) => RemapDialog(
            field: field,
            usage: error.usage,
            kept: draft.options,
          ),
        );
        if (chosen != null && mounted) await _save(field, draft, chosen);
        return;
      }
      if (mounted) {
        _say(fieldErrorMessage(error));
        if (error.failure == FieldFailure.conflict) _refresh();
      }
    }
  }

  Future<void> _archive(CustomField field) async {
    try {
      final archived = await ref
          .read(fieldsClientProvider)
          .archive(_workspace, field);
      _refresh();
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('Archived ${field.name}. Values are kept 30 days.'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () => _restore(archived),
            ),
          ),
        );
    } on Object catch (e) {
      if (mounted) _say(fieldErrorMessage(mapAny(e)));
    }
  }

  Future<void> _restore(CustomField field) async {
    try {
      await ref.read(fieldsClientProvider).restore(_workspace, field);
      _refresh();
    } on Object catch (e) {
      if (mounted) _say(fieldErrorMessage(mapAny(e)));
    }
  }

  Future<void> _move(List<CustomField> fields, int from, int to) async {
    final next = [...fields];
    next.insert(to, next.removeAt(from));
    setState(() => _reordered = next);
    try {
      await ref.read(fieldsClientProvider).reorder(
        _workspace,
        widget.projectId,
        [for (final f in next) f.id],
      );
      _refresh();
    } on Object catch (e) {
      if (mounted) {
        setState(() => _reordered = null);
        _say(fieldErrorMessage(mapAny(e)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final project = ref.watch(projectProvider(widget.projectId));
    final permissions = ref.watch(permissionSetProvider);
    final canEdit =
        project != null &&
        !project.isArchived &&
        canManageProject(permissions, Perm.projectUpdate);
    final fields = ref.watch(fieldsProvider(widget.projectId));
    final archived = canEdit
        ? ref.watch(archivedFieldsProvider(widget.projectId)).value ?? const []
        : const <CustomField>[];
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          key: const Key('back-to-settings'),
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/projects/${widget.projectId}/settings'),
        ),
        title: const Text('Fields'),
      ),
      floatingActionButton: canEdit
          ? FloatingActionButton.extended(
              key: const Key('add-field'),
              onPressed: _add,
              icon: const Icon(Icons.add),
              label: const Text('Add field'),
            )
          : null,
      body: fields.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: TextButton(
            key: const Key('fields-retry'),
            onPressed: () => ref.invalidate(fieldsProvider(widget.projectId)),
            child: Text('${fieldErrorMessage(e)} Retry'),
          ),
        ),
        data: (loaded) {
          final shown = _reordered ?? loaded;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            children: [
              if (shown.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'No custom fields yet. Add one for things like Customer or Story points.',
                    key: Key('fields-empty'),
                  ),
                ),
              ReorderableListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                buildDefaultDragHandles: canEdit,
                onReorderItem: (a, b) => _move(shown, a, b),
                children: [
                  for (final f in shown)
                    _FieldTile(
                      key: ValueKey(f.id),
                      field: f,
                      canEdit: canEdit,
                      onEdit: () => _edit(f),
                      onArchive: () => _archive(f),
                    ),
                ],
              ),
              if (archived.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text(
                  'Archived (restorable for 30 days)',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                for (final f in archived)
                  ListTile(
                    key: Key('archived-${f.id}'),
                    leading: Icon(fieldTypeIcon(f.type)),
                    title: Text(f.name),
                    trailing: TextButton(
                      key: Key('restore-${f.id}'),
                      onPressed: () => _restore(f),
                      child: const Text('Restore'),
                    ),
                  ),
              ],
            ],
          );
        },
      ),
    );
  }
}

FieldException mapAny(Object error) =>
    error is FieldException ? error : const FieldException(FieldFailure.other);

class _FieldTile extends StatelessWidget {
  const _FieldTile({
    super.key,
    required this.field,
    required this.canEdit,
    required this.onEdit,
    required this.onArchive,
  });

  final CustomField field;
  final bool canEdit;
  final VoidCallback onEdit;
  final VoidCallback onArchive;

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      key: Key('field-tile-${field.id}'),
      leading: Icon(fieldTypeIcon(field.type)),
      title: Text(field.name),
      subtitle: Text(
        [
          field.type.label,
          if (field.required) 'Required',
          if (field.type.hasOptions) '${field.options.length} options',
        ].join(' · '),
      ),
      onTap: canEdit ? onEdit : null,
      trailing: canEdit
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  key: Key('edit-${field.id}'),
                  tooltip: 'Edit',
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: onEdit,
                ),
                IconButton(
                  key: Key('archive-${field.id}'),
                  tooltip: 'Archive',
                  icon: const Icon(Icons.archive_outlined),
                  onPressed: onArchive,
                ),
                const SizedBox(width: 24),
              ],
            )
          : null,
    ),
  );
}
