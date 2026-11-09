import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:taskforge/features/projects/application/projects_providers.dart';
import 'package:taskforge/features/projects/domain/projects.dart';
import 'package:taskforge/features/projects/presentation/project_look_picker.dart';

/// Opens the create dialog and, on success, the new project.
Future<void> createProject(BuildContext context) async {
  final router = GoRouter.of(context);
  final created = await showDialog<Project>(
    context: context,
    builder: (_) => const CreateProjectDialog(),
  );
  if (created != null) router.go('/projects/${created.id}');
}

class CreateProjectDialog extends ConsumerStatefulWidget {
  const CreateProjectDialog({super.key});

  @override
  ConsumerState<CreateProjectDialog> createState() => _State();
}

class _State extends ConsumerState<CreateProjectDialog> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _key = TextEditingController();
  final _description = TextEditingController();
  bool _keyEdited = false;
  String _icon = projectIcons.first;
  String _color = projectColors.first;
  ProjectVisibility _visibility = ProjectVisibility.open;
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

  void _nameChanged(String name) {
    if (_keyEdited) return;
    setState(() => _key.text = deriveKey(name));
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
      _keyError = null;
    });
    try {
      final project = await ref
          .read(projectsControllerProvider)
          .create(
            name: _name.text.trim(),
            key: _key.text,
            description: _description.text.trim(),
            icon: _icon,
            color: _color,
            visibility: _visibility,
          );
      if (mounted) Navigator.of(context).pop(project);
    } on ProjectException catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        if (e.failure == ProjectFailure.keyTaken) {
          _keyError = projectErrorMessage(e);
        } else {
          _error = projectErrorMessage(e);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('New project'),
    content: SizedBox(
      width: 420,
      child: Form(
        key: _form,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                key: const Key('project-name'),
                controller: _name,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: validateProjectName,
                onChanged: _nameChanged,
              ),
              TextFormField(
                key: const Key('project-key'),
                controller: _key,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [
                  TextInputFormatter.withFunction(
                    (_, v) => v.copyWith(text: normalizeKey(v.text)),
                  ),
                ],
                decoration: InputDecoration(
                  labelText: 'Key',
                  helperText: 'Prefix of task numbers, e.g. WEB-12',
                  errorText: _keyError,
                ),
                validator: validateProjectKey,
                onChanged: (_) {
                  _keyEdited = true;
                  if (_keyError != null) setState(() => _keyError = null);
                },
              ),
              TextFormField(
                key: const Key('project-description'),
                controller: _description,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 16),
              ProjectLookPicker(
                icon: _icon,
                color: _color,
                onIcon: (v) => setState(() => _icon = v),
                onColor: (v) => setState(() => _color = v),
              ),
              const SizedBox(height: 16),
              VisibilityPicker(
                value: _visibility,
                onChanged: (v) => setState(() => _visibility = v),
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    _error!,
                    key: const Key('project-error'),
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
        child: const Text('Cancel'),
      ),
      FilledButton(
        key: const Key('create-project'),
        onPressed: _busy ? null : _submit,
        child: const Text('Create'),
      ),
    ],
  );
}
