import 'package:flutter/material.dart';

import 'package:taskforge/features/roles/domain/roles.dart';

typedef RoleDraft = ({String name, Set<String> permissions});

String? _validateName(String? value) =>
    (value ?? '').trim().isEmpty ? 'Enter a name.' : null;

/// Name plus a checklist of every registry permission.
Future<RoleDraft?> showCreateRoleDialog(
  BuildContext context,
  List<PermissionArea> registry,
) => showDialog<RoleDraft>(
  context: context,
  builder: (_) => _CreateRoleDialog(registry: registry),
);

class _CreateRoleDialog extends StatefulWidget {
  const _CreateRoleDialog({required this.registry});

  final List<PermissionArea> registry;

  @override
  State<_CreateRoleDialog> createState() => _CreateRoleDialogState();
}

class _CreateRoleDialogState extends State<_CreateRoleDialog> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  Set<String> _granted = const {};

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _toggle(String key, bool on) => setState(
    () => _granted = on ? {..._granted, key} : {..._granted}.difference({key}),
  );

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New role'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _form,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  key: const Key('role-name'),
                  controller: _name,
                  autofocus: true,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: _validateName,
                ),
                for (final area in widget.registry) ...[
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      area.area,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  for (final p in area.permissions)
                    CheckboxListTile(
                      key: Key('new-perm-${p.key}'),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(p.label),
                      value: _granted.contains(p.key),
                      onChanged: (v) => _toggle(p.key, v ?? false),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          key: const Key('create-role-submit'),
          onPressed: () {
            if (!_form.currentState!.validate()) return;
            Navigator.of(context)
                .pop((name: _name.text.trim(), permissions: _granted));
          },
          child: const Text('Create'),
        ),
      ],
    );
  }
}

Future<String?> showRenameRoleDialog(BuildContext context, Role role) =>
    showDialog<String>(
      context: context,
      builder: (_) => _RenameRoleDialog(role: role),
    );

class _RenameRoleDialog extends StatefulWidget {
  const _RenameRoleDialog({required this.role});

  final Role role;

  @override
  State<_RenameRoleDialog> createState() => _RenameRoleDialogState();
}

class _RenameRoleDialogState extends State<_RenameRoleDialog> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.role.name);

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Rename role'),
      content: Form(
        key: _form,
        child: TextFormField(
          key: const Key('role-name'),
          controller: _name,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Name'),
          validator: _validateName,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          key: const Key('rename-role-submit'),
          onPressed: () {
            if (_form.currentState!.validate()) {
              Navigator.of(context).pop(_name.text.trim());
            }
          },
          child: const Text('Rename'),
        ),
      ],
    );
  }
}

/// Confirms a delete. A role with members needs a role to move them to; the
/// result is that role's id, `''` when nobody has to move, null when cancelled.
Future<String?> showDeleteRoleDialog(
  BuildContext context,
  Role role,
  List<Role> others,
) => showDialog<String>(
  context: context,
  builder: (_) => _DeleteRoleDialog(role: role, others: others),
);

class _DeleteRoleDialog extends StatefulWidget {
  const _DeleteRoleDialog({required this.role, required this.others});

  final Role role;
  final List<Role> others;

  @override
  State<_DeleteRoleDialog> createState() => _DeleteRoleDialogState();
}

class _DeleteRoleDialogState extends State<_DeleteRoleDialog> {
  String? _target;

  @override
  Widget build(BuildContext context) {
    final role = widget.role;
    final needsTarget = role.memberCount > 0;
    return AlertDialog(
      title: Text('Delete "${role.name}"?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!needsTarget) const Text('No one has this role.'),
          if (needsTarget) ...[
            Text('${role.memberCount} member(s) have this role. Move them to:'),
            const SizedBox(height: 8),
            DropdownButton<String>(
              key: const Key('reassign-to'),
              isExpanded: true,
              hint: const Text('Choose a role'),
              value: _target,
              items: [
                for (final r in widget.others)
                  DropdownMenuItem(
                    key: Key('reassign-option-${r.id}'),
                    value: r.id,
                    child: Text(r.name),
                  ),
              ],
              onChanged: (v) => setState(() => _target = v),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          key: const Key('delete-role-submit'),
          onPressed: needsTarget && _target == null
              ? null
              : () => Navigator.of(context).pop(_target ?? ''),
          child: const Text('Delete'),
        ),
      ],
    );
  }
}
