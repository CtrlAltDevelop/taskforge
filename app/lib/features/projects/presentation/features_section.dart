import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/features/projects/application/project_access.dart';
import 'package:taskforge/features/projects/application/projects_providers.dart';
import 'package:taskforge/features/projects/domain/projects.dart';
import 'package:taskforge/features/projects/presentation/project_actions.dart';
import 'package:taskforge/features/roles/application/roles_providers.dart';
import 'package:taskforge/features/roles/domain/roles.dart';

/// One switch per optional feature. Turning one off keeps its data.
class FeaturesSection extends ConsumerStatefulWidget {
  const FeaturesSection({super.key, required this.project, required this.info});

  final Project project;
  final List<FeatureInfo> info;

  @override
  ConsumerState<FeaturesSection> createState() => _FeaturesSectionState();
}

class _FeaturesSectionState extends ConsumerState<FeaturesSection> {
  bool _busy = false;

  Future<void> _toggle(String key, bool on) async {
    final enabled = {...widget.project.enabledFeatures};
    on ? enabled.add(key) : enabled.remove(key);
    setState(() => _busy = true);
    await runProjectAction(
      context,
      () => ref
          .read(projectsControllerProvider)
          .setFeatures(widget.project, enabled),
    );
    if (mounted) setState(() => _busy = false);
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
    final enabled = p.enabledFeatures;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Features', style: Theme.of(context).textTheme.titleLarge),
        const Text('Switching a feature off hides it but keeps its data.'),
        for (final f in widget.info)
          SwitchListTile(
            key: Key('feature-${f.key}'),
            contentPadding: EdgeInsets.zero,
            title: Text(f.label),
            subtitle: Text(f.description),
            value: enabled.contains(f.key),
            onChanged: canEdit && !_busy ? (v) => _toggle(f.key, v) : null,
          ),
      ],
    );
  }
}
