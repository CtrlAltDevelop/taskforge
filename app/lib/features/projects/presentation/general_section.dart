import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/projects/application/project_access.dart';
import 'package:taskforge/features/projects/application/projects_providers.dart';
import 'package:taskforge/features/projects/domain/projects.dart';
import 'package:taskforge/features/projects/presentation/project_look_picker.dart';
import 'package:taskforge/features/roles/application/roles_providers.dart';
import 'package:taskforge/features/roles/domain/roles.dart';

class GeneralSection extends ConsumerStatefulWidget {
  const GeneralSection({super.key, required this.project});

  final Project project;

  @override
  ConsumerState<GeneralSection> createState() => _GeneralSectionState();
}

class _GeneralSectionState extends ConsumerState<GeneralSection> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.project.name);
  late final _key = TextEditingController(text: widget.project.key);
  late final _description = TextEditingController(
    text: widget.project.description,
  );
  late String _icon = widget.project.icon;
  late String _color = widget.project.color;
  late ProjectVisibility _visibility = widget.project.visibility;
  bool _busy = false;
  String? _error;
  String? _keyError;

  @override
  void dispose() {
    _name.dispose();
    _key.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    final p = widget.project;
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    final name = _name.text.trim();
    final description = _description.text.trim();
    setState(() {
      _busy = true;
      _error = null;
      _keyError = null;
    });
    try {
      await ref
          .read(projectsControllerProvider)
          .update(
            p,
            name: name == p.name ? null : name,
            key: _key.text == p.key ? null : _key.text,
            description: description == p.description ? null : description,
            icon: _icon == p.icon ? null : _icon,
            color: _color == p.color ? null : _color,
            visibility: _visibility == p.visibility ? null : _visibility,
          );
      messenger.showSnackBar(SnackBar(content: Text(l10n.grpHProjectUpdated)));
    } on ProjectException catch (e) {
      if (e.failure == ProjectFailure.conflict) {
        // The refreshed project rebuilds this form, so say it out of band.
        messenger.showSnackBar(
          SnackBar(content: Text(projectErrorMessage(e, l10n))),
        );
      } else if (mounted) {
        setState(() {
          if (e.failure == ProjectFailure.keyTaken ||
              e.failure == ProjectFailure.keyLocked) {
            _keyError = projectErrorMessage(e, l10n);
          } else {
            _error = projectErrorMessage(e, l10n);
          }
        });
      }
    } finally {
      // A no-op save or a failed refresh keeps this form alive: re-enable it.
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.project;
    final canEdit =
        canManageProject(
          ref.watch(permissionSetProvider),
          Perm.projectUpdate,
        ) &&
        !p.isArchived;
    return Form(
      key: _form,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.grpHGeneral,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          TextFormField(
            key: const Key('settings-name'),
            controller: _name,
            enabled: canEdit,
            decoration: InputDecoration(labelText: context.l10n.grpHName),
            validator: validateProjectName,
          ),
          const SizedBox(height: 12),
          TextFormField(
            key: const Key('settings-key'),
            controller: _key,
            enabled: canEdit && !p.keyLocked,
            inputFormatters: [
              TextInputFormatter.withFunction(
                (_, v) => v.copyWith(text: normalizeKey(v.text)),
              ),
            ],
            decoration: InputDecoration(
              labelText: context.l10n.grpHKey,
              helperText: p.keyLocked
                  ? context.l10n.grpHKeyFixed('${p.key}-${p.taskCounter}')
                  : context.l10n.grpHKeyHelp,
              errorText: _keyError,
            ),
            validator: validateProjectKey,
          ),
          const SizedBox(height: 12),
          TextFormField(
            key: const Key('settings-description'),
            controller: _description,
            enabled: canEdit,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: context.l10n.grpHDescription,
            ),
          ),
          const SizedBox(height: 16),
          ProjectLookPicker(
            icon: _icon,
            color: _color,
            enabled: canEdit,
            onIcon: (v) => setState(() => _icon = v),
            onColor: (v) => setState(() => _color = v),
          ),
          const SizedBox(height: 16),
          VisibilityPicker(
            value: _visibility,
            enabled: canEdit,
            onChanged: (v) => setState(() => _visibility = v),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              key: const Key('settings-error'),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          if (canEdit) ...[
            const SizedBox(height: 16),
            FilledButton(
              key: const Key('save-project'),
              onPressed: _busy ? null : _save,
              child: Text(context.l10n.grpHSaveChanges),
            ),
          ],
        ],
      ),
    );
  }
}
