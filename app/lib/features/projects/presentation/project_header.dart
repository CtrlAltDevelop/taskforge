import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/core/ui/tf/tf_avatar.dart';
import 'package:taskforge/core/ui/tf/tf_button.dart';
import 'package:taskforge/core/ui/tf/tf_menu.dart';
import 'package:taskforge/core/ui/theme_extension.dart';
import 'package:taskforge/core/ui/tf_icons.dart';
import 'package:taskforge/core/ui/tokens/spacing.dart';
import 'package:taskforge/features/members/application/members_providers.dart';
import 'package:taskforge/features/members/domain/members.dart';
import 'package:taskforge/features/projects/application/projects_providers.dart';
import 'package:taskforge/features/projects/domain/projects.dart';
import 'package:taskforge/features/projects/presentation/project_actions.dart';
import 'package:taskforge/features/projects/presentation/project_avatar.dart';

/// Below this width the members stack makes room for the name.
const _membersMinWidth = 520.0;

/// The top of a project's page: avatar, name and key, the favourite star, who
/// is in it and a Share / Settings menu.
class ProjectHeader extends ConsumerWidget {
  const ProjectHeader({super.key, required this.project});

  final Project project;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tf = context.tf;
    final l10n = context.l10n;
    return LayoutBuilder(
      builder: (context, box) => Padding(
        padding: EdgeInsets.all(
          box.maxWidth < _membersMinWidth ? TfSpace.md : TfSpace.lg,
        ),
        child: Row(
          children: [
            ProjectAvatar(project: project, radius: 20),
            const SizedBox(width: TfSpace.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          project.name,
                          key: const Key('project-title'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: tf.typography.title.copyWith(
                            color: tf.colors.text,
                          ),
                        ),
                      ),
                      if (project.isPrivate) ...[
                        const SizedBox(width: TfSpace.xs),
                        const TfIcon(TfIcons.lock),
                      ],
                    ],
                  ),
                  Text(
                    project.key,
                    key: const Key('project-key-label'),
                    style: tf.typography.small.copyWith(
                      color: tf.colors.textMuted,
                    ),
                  ),
                  if (project.description.isNotEmpty)
                    Text(
                      project.description,
                      key: const Key('project-desc'),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: tf.typography.small.copyWith(
                        color: tf.colors.textMuted,
                      ),
                    ),
                ],
              ),
            ),
            if (box.maxWidth >= _membersMinWidth) _MembersStack(project),
            IconButton(
              key: const Key('favorite-toggle'),
              tooltip: project.isFavorite
                  ? l10n.grpHRemoveFavorite
                  : l10n.grpHAddFavorite,
              icon: TfIcon(
                TfIcons.star,
                size: 24,
                color: project.isFavorite ? tf.colors.accent : null,
              ),
              // The server refuses starring an archived project.
              onPressed: project.isArchived
                  ? null
                  : () => runProjectAction(
                      context,
                      () => ref
                          .read(projectsControllerProvider)
                          .favorite(project, !project.isFavorite),
                    ),
            ),
            TfMenu(
              items: [
                TfMenuItem(
                  key: const Key('header-copy-link'),
                  icon: TfIcons.link,
                  label: l10n.wvCopyLink,
                  onSelected: () => _copyLink(context),
                ),
                TfMenuItem(
                  key: const Key('header-settings'),
                  icon: TfIcons.settings,
                  label: l10n.grpHProjectSettings,
                  onSelected: () =>
                      context.push('/projects/${project.id}/settings'),
                ),
              ],
              builder: (context, toggle) => box.maxWidth < _membersMinWidth
                  ? TfIconButton(
                      key: const Key('project-menu'),
                      icon: TfIcons.users,
                      tooltip: l10n.wvShare,
                      size: TfButtonSize.small,
                      onPressed: toggle,
                    )
                  : TfButton(
                      key: const Key('project-menu'),
                      label: l10n.wvShare,
                      icon: TfIcons.users,
                      size: TfButtonSize.small,
                      onPressed: toggle,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _copyLink(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final said = context.l10n.wvLinkCopied;
    await Clipboard.setData(ClipboardData(text: '/projects/${project.id}'));
    messenger.showSnackBar(SnackBar(content: Text(said)));
  }
}

/// Avatars of the people in the project (everyone of the workspace when it is
/// open), with how many.
class _MembersStack extends ConsumerWidget {
  const _MembersStack(this.project);

  final Project project;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<String> names = project.isPrivate
        ? [
            for (final m
                in ref.watch(projectMembersProvider(project.id)).value ??
                    const <ProjectMember>[])
              m.label,
          ]
        : [
            for (final m
                in ref.watch(membersProvider).value ?? const <Member>[])
              m.label,
          ];
    if (names.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: TfSpace.md),
      child: Row(
        key: const Key('project-members'),
        mainAxisSize: MainAxisSize.min,
        children: [
          TfAvatarStack(names: names),
          const SizedBox(width: TfSpace.sm),
          Text(
            context.l10n.wvMembers(names.length),
            style: context.tf.typography.small.copyWith(
              color: context.tf.colors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
