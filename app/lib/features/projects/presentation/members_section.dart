import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/members/application/members_providers.dart';
import 'package:taskforge/features/members/domain/members.dart';
import 'package:taskforge/features/projects/application/project_access.dart';
import 'package:taskforge/features/projects/application/projects_providers.dart';
import 'package:taskforge/features/projects/domain/projects.dart';
import 'package:taskforge/features/projects/presentation/project_actions.dart';
import 'package:taskforge/features/roles/application/roles_providers.dart';
import 'package:taskforge/features/roles/domain/roles.dart';

/// Who can open a private project.
class MembersSection extends ConsumerWidget {
  const MembersSection({super.key, required this.project});

  final Project project;

  Future<void> _add(BuildContext context, WidgetRef ref) async {
    final inProject = {
      for (final m
          in ref.read(projectMembersProvider(project.id)).value ??
              const <ProjectMember>[])
        m.userId,
    };
    final candidates = [
      for (final m in await ref.read(membersProvider.future))
        if (!inProject.contains(m.userId)) m,
    ];
    if (!context.mounted) return;
    final picked = await showDialog<Member>(
      context: context,
      builder: (dialog) => SimpleDialog(
        title: Text(dialog.l10n.grpHAddAMember),
        children: [
          if (candidates.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(dialog.l10n.grpHAllAreMembers),
            ),
          for (final m in candidates)
            SimpleDialogOption(
              key: Key('pick-member-${m.userId}'),
              onPressed: () => Navigator.of(dialog).pop(m),
              child: Text(m.label),
            ),
        ],
      ),
    );
    if (picked == null || !context.mounted) return;
    await runProjectAction(
      context,
      () => ref
          .read(projectsControllerProvider)
          .addMember(project.id, picked.userId),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final members = ref.watch(projectMembersProvider(project.id));
    final allowed = canManageProject(
      ref.watch(permissionSetProvider),
      Perm.projectMemberManage,
    );
    final canManage = allowed && !project.isArchived;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                context.l10n.grpHMembers,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            if (allowed)
              TextButton.icon(
                key: const Key('add-project-member'),
                onPressed: canManage ? () => _add(context, ref) : null,
                icon: const Icon(Icons.person_add),
                label: Text(context.l10n.grpHAddMember),
              ),
          ],
        ),
        switch (members) {
          AsyncData(:final value) => Column(
            children: [
              for (final m in value)
                Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: ListTile(
                    key: Key('project-member-${m.userId}'),
                    contentPadding: EdgeInsets.zero,
                    title: Text(m.label),
                    subtitle: m.displayName.isEmpty ? null : Text(m.email),
                    trailing: allowed
                        ? IconButton(
                            key: Key('remove-project-member-${m.userId}'),
                            tooltip: context.l10n.grpHRemove,
                            icon: const Icon(Icons.person_remove),
                            onPressed: canManage
                                ? () => runProjectAction(
                                    context,
                                    () => ref
                                        .read(projectsControllerProvider)
                                        .removeMember(project.id, m.userId),
                                  )
                                : null,
                          )
                        : null,
                  ),
                ),
            ],
          ),
          AsyncError() => TextButton(
            onPressed: () => ref.invalidate(projectMembersProvider),
            child: Text(context.l10n.grpHLoadMembersRetry),
          ),
          _ => const LinearProgressIndicator(),
        },
      ],
    );
  }
}
