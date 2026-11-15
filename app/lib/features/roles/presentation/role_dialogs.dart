import 'package:material_ui/material_ui.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/roles/domain/roles.dart';

typedef RoleDraft = ({String name, Set<String> permissions});

String? _validateName(BuildContext context, String? value) =>
    (value ?? '').trim().isEmpty ? context.l10n.grpEEnterName : null;

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
      title: Text(context.l10n.grpENewRole),
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
                  decoration: InputDecoration(labelText: context.l10n.grpEName),
                  validator: (v) => _validateName(context, v),
                ),
                const SizedBox(height: 12),
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
          child: Text(context.l10n.grpECancel),
        ),
        FilledButton(
          key: const Key('create-role-submit'),
          onPressed: () {
            if (!_form.currentState!.validate()) return;
            Navigator.of(context)
                .pop((name: _name.text.trim(), permissions: _granted));
          },
          child: Text(context.l10n.grpECreate),
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
      title: Text(context.l10n.grpERenameRole),
      content: Form(
        key: _form,
        child: TextFormField(
          key: const Key('role-name'),
          controller: _name,
          autofocus: true,
          decoration: InputDecoration(labelText: context.l10n.grpEName),
          validator: (v) => _validateName(context, v),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.l10n.grpECancel),
        ),
        FilledButton(
          key: const Key('rename-role-submit'),
          onPressed: () {
            if (_form.currentState!.validate()) {
              Navigator.of(context).pop(_name.text.trim());
            }
          },
          child: Text(context.l10n.grpERename),
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
      title: Text(context.l10n.grpEDeleteRoleTitle(role.name)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!needsTarget) Text(context.l10n.grpERoleNoOne),
          if (needsTarget) ...[
            Text(context.l10n.grpERoleMoveMembers(role.memberCount)),
            const SizedBox(height: 8),
            DropdownButton<String>(
              key: const Key('reassign-to'),
              isExpanded: true,
              hint: Text(context.l10n.grpEChooseRole),
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
          child: Text(context.l10n.grpECancel),
        ),
        FilledButton(
          key: const Key('delete-role-submit'),
          onPressed: needsTarget && _target == null
              ? null
              : () => Navigator.of(context).pop(_target ?? ''),
          child: Text(context.l10n.grpEDelete),
        ),
      ],
    );
  }
}
