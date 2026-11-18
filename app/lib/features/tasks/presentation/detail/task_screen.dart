import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskforge/features/tasks/domain/links.dart';
import 'package:go_router/go_router.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/core/ui/theme_extension.dart';
import 'package:taskforge/core/ui/tf/tf_banner.dart';
import 'package:taskforge/core/ui/tf/tf_button.dart';
import 'package:taskforge/core/ui/tf/tf_panel.dart';
import 'package:taskforge/core/ui/tokens/spacing.dart';
import 'package:taskforge/features/members/application/members_providers.dart';
import 'package:taskforge/features/members/domain/members.dart';
import 'package:taskforge/features/projects/application/projects_providers.dart';
import 'package:taskforge/features/projects/domain/projects.dart';
import 'package:taskforge/features/roles/application/roles_providers.dart';
import 'package:taskforge/features/roles/domain/roles.dart';
import 'package:taskforge/features/tasks/application/task_detail_state.dart';
import 'package:taskforge/features/tasks/application/tasks_providers.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';
import 'package:taskforge/features/tasks/presentation/detail/activity/activity_panel.dart';
import 'package:taskforge/features/tasks/presentation/detail/details_panel.dart';
import 'package:taskforge/features/tasks/presentation/detail/task_delete.dart';
import 'package:taskforge/features/tasks/presentation/detail/task_description.dart';
import 'package:taskforge/features/tasks/presentation/detail/task_frame.dart';
import 'package:taskforge/features/tasks/presentation/detail/task_header.dart';
import 'package:taskforge/features/tasks/presentation/detail/task_skeleton.dart';
import 'package:taskforge/features/tasks/presentation/detail/task_tabs.dart';
import 'package:taskforge/features/tasks/presentation/detail/task_title.dart';
import 'package:taskforge/features/templates/presentation/template_dialogs.dart';

/// One task: fields and content on the left, the whole conversation on the
/// right (see [TaskFrame]). The same screen sits in a window, a side panel or
/// a page; the presentation around it is [TaskPresentation].
class TaskScreen extends ConsumerWidget {
  const TaskScreen({
    super.key,
    required this.project,
    required this.taskId,
    required this.kind,
    required this.onClose,
    required this.onOpen,
    required this.onKind,
    this.onPrevious,
    this.onNext,
  });

  final Project project;
  final String taskId;
  final TaskPresentationKind kind;
  final VoidCallback onClose;

  /// Opens another task (an ancestor in the breadcrumb, a subtask).
  final void Function(Task) onOpen;
  final void Function(TaskPresentationKind) onKind;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = ref.watch(taskListProvider(project.id));
    final task = list.tasks.where((t) => t.id == taskId).firstOrNull;
    if (task == null) {
      return list.loading ? const TaskSkeleton() : _NotFound(onClose: onClose);
    }
    final permissions = ref.watch(permissionSetProvider);
    final l10n = context.l10n;
    final canEdit = !project.isArchived && permissions.can(Perm.taskUpdate);
    final readOnlyReason = canEdit
        ? null
        : project.isArchived
        ? l10n.tdArchivedReadOnly
        : l10n.tdNoPermission;
    final members = _candidates(ref);
    final tree = ref.watch(taskTreeProvider(project.id));
    return KeyedSubtree(
      key: const Key('task-detail'),
      child: LayoutBuilder(
        builder: (context, box) => TaskFrame(
          header: TaskHeader(
            task: task,
            breadcrumb: tree.breadcrumb(task.id),
            kind: kind,
            canDelete: !project.isArchived && permissions.can(Perm.taskDelete),
            canTemplate: permissions.can(Perm.templateCreate),
            onClose: onClose,
            onOpen: onOpen,
            onPrevious: onPrevious,
            onNext: onNext,
            onKind: onKind,
            onDelete: () => deleteTaskFlow(context, ref, task, close: onClose),
            onTemplate: () => _saveTemplate(context, task),
          ),
          body: [
            if (task.deletedAt.isNotEmpty)
              TfBanner(
                key: const Key('trashed-banner'),
                message: l10n.tdTrashedBanner,
                kind: TfBannerKind.warning,
              ),
            TaskTitle(
              task: task,
              readOnlyReason: readOnlyReason,
              compact: box.maxWidth < phoneBelow,
            ),
            TaskDescription(task: task, readOnlyReason: readOnlyReason),
            DetailsPanel(
              project: project,
              task: task,
              members: members,
              readOnlyReason: readOnlyReason,
              collapsible: box.maxWidth < phoneBelow,
            ),
            TaskTabs(
              project: project,
              task: task,
              canEdit: canEdit,
              members: members,
              onOpen: onOpen,
              onOpenLink: (link) => _openLink(context, ref, link),
            ),
          ],
          activity: ({leading = const [], topBar}) => ActivityPanel(
            key: ValueKey('activity-panel-${task.id}'),
            projectId: project.id,
            taskId: task.id,
            archived: project.isArchived,
            isPrivate: project.isPrivate,
            leading: leading,
            topBar: topBar,
          ),
        ),
      ),
    );
  }

  Future<void> _saveTemplate(BuildContext context, Task task) async {
    final saved = await showSaveTemplateSheet(
      context,
      projectId: project.id,
      taskId: task.id,
      initialName: task.title,
    );
    if (saved != null && context.mounted) {
      sayTemplates(context, context.l10n.tplSaved);
    }
  }

  void _openLink(BuildContext context, WidgetRef ref, TaskLink link) {
    if (link.otherProjectId != project.id) {
      context.go('/projects/${link.otherProjectId}?task=${link.otherId}');
      return;
    }
    final other = ref
        .read(taskListProvider(project.id))
        .tasks
        .where((t) => t.id == link.otherId)
        .firstOrNull;
    if (other != null) onOpen(other);
  }

  /// Who may be assigned: the project's members. An open project is every
  /// workspace member; a private one only its own members (none are offered
  /// until they have loaded, so nobody ineligible is ever shown).
  List<Member> _candidates(WidgetRef ref) {
    final everyone = ref.watch(membersProvider).value ?? const <Member>[];
    if (!project.isPrivate) return everyone;
    final inProject = {
      for (final m
          in ref.watch(projectMembersProvider(project.id)).value ??
              const <ProjectMember>[])
        m.userId,
    };
    return [
      for (final m in everyone)
        if (inProject.contains(m.userId)) m,
    ];
  }
}

/// The task is not in the project any more (deleted, moved, or never
/// there): say so and offer the way out.
class _NotFound extends StatelessWidget {
  const _NotFound({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final tf = context.tf;
    final l10n = context.l10n;
    return Center(
      child: TfPanel(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: TfSpace.sm,
          children: [
            Text(
              l10n.grpDTaskNotFound,
              key: const Key('no-task'),
              style: tf.typography.lead,
            ),
            Text(
              l10n.tdNotFoundHint,
              style: tf.typography.body.copyWith(color: tf.colors.textMuted),
              textAlign: TextAlign.center,
            ),
            TfButton(
              key: const Key('close-detail'),
              label: l10n.grpDClose,
              onPressed: onClose,
            ),
          ],
        ),
      ),
    );
  }
}
