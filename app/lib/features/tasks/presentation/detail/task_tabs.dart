import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskforge/features/tasks/domain/links.dart';

import 'package:taskforge/core/i18n/context_dates.dart';
import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/core/ui/tf/tf_tabs.dart';
import 'package:taskforge/core/ui/tokens/spacing.dart';
import 'package:taskforge/features/attachments/application/attachments_providers.dart';
import 'package:taskforge/features/attachments/presentation/attachments_section.dart';
import 'package:taskforge/features/docs/application/docs_providers.dart';
import 'package:taskforge/features/docs/presentation/related_docs_panel.dart';
import 'package:taskforge/features/fields/application/fields_providers.dart';
import 'package:taskforge/features/goals/presentation/contributes_panel.dart';
import 'package:taskforge/features/members/domain/members.dart';
import 'package:taskforge/features/projects/domain/projects.dart';
import 'package:taskforge/features/roles/application/roles_providers.dart';
import 'package:taskforge/features/roles/domain/roles.dart';
import 'package:taskforge/features/tasks/application/task_detail_state.dart';
import 'package:taskforge/features/tasks/application/tasks_providers.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';
import 'package:taskforge/features/tasks/presentation/links_panel.dart';
import 'package:taskforge/features/tasks/presentation/subtasks_panel.dart';
import 'package:taskforge/features/tasks/presentation/task_fields_panel.dart';
import 'package:taskforge/features/time/domain/time.dart' show timeFeature;
import 'package:taskforge/features/time/presentation/time_section.dart';

enum _Tab { subtasks, links, attachments, docs, time, fields }

/// Subtasks, Links, Attachments, Docs, Time and Fields under the details,
/// each with a count. The chosen tab is remembered while moving between tasks.
class TaskTabs extends ConsumerWidget {
  const TaskTabs({
    super.key,
    required this.project,
    required this.task,
    required this.canEdit,
    required this.members,
    required this.onOpen,
    required this.onOpenLink,
  });

  final Project project;
  final Task task;
  final bool canEdit;
  final List<Member> members;
  final void Function(Task) onOpen;
  final void Function(TaskLink) onOpenLink;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final fields = ref.watch(fieldsProvider(project.id)).value ?? const [];
    final tabs = [
      _Tab.subtasks,
      _Tab.links,
      _Tab.attachments,
      _Tab.docs,
      if (project.enabledFeatures.contains(timeFeature)) _Tab.time,
      if (fields.isNotEmpty) _Tab.fields,
    ];
    final counts = <_Tab, int?>{
      _Tab.subtasks: ref
          .watch(taskTreeProvider(project.id))
          .childrenOf(task.id)
          .length,
      _Tab.links: ref.watch(taskLinksProvider(task.id)).value?.length,
      _Tab.attachments: ref.watch(
        attachmentsProvider((project: project.id, task: task.id))
            .select((s) => s.loading ? null : s.attachments.length),
      ),
      _Tab.docs: ref
          .watch(relatedDocsProvider((project: project.id, task: task.id)))
          .value
          ?.length,
      _Tab.fields: fields.length,
    };
    final missing = [
      for (final f in fields)
        if (f.required && (task.fieldValues[f.id] ?? '').isEmpty) f,
    ].length;
    String name(_Tab t) => switch (t) {
      _Tab.subtasks => l10n.grpFSubtasks,
      _Tab.links => l10n.grpFLinks,
      _Tab.attachments => l10n.grpHAttachments,
      _Tab.docs => l10n.grpEDocs,
      _Tab.time => l10n.tdTabTime,
      _Tab.fields => l10n.grpFFields,
    };
    String label(_Tab t) {
      final n = counts[t];
      final text = n == null
          ? name(t)
          : l10n.tdTabWithCount(name(t), context.localDigits('$n'));
      return t == _Tab.fields && missing > 0
          ? l10n.tdTabNeedsInput(text)
          : text;
    }

    final index = ref.watch(taskTabProvider).clamp(0, tabs.length - 1);
    return Column(
      key: const Key('task-tabs'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TfTabs(
          labels: [for (final t in tabs) label(t)],
          index: index,
          onChanged: ref.read(taskTabProvider.notifier).pick,
        ),
        const SizedBox(height: TfSpace.md),
        _panel(ref, tabs[index]),
      ],
    );
  }

  Widget _panel(WidgetRef ref, _Tab tab) {
    final permissions = ref.watch(permissionSetProvider);
    return switch (tab) {
      _Tab.subtasks => SubtasksPanel(
        project: project,
        task: task,
        canEdit: canEdit,
        canCreate: !project.isArchived && permissions.can(Perm.taskCreate),
        onOpen: onOpen,
      ),
      _Tab.links => LinksPanel(
        project: project,
        task: task,
        canEdit: canEdit,
        onOpen: onOpenLink,
      ),
      _Tab.attachments => AttachmentsSection(
        key: ValueKey('attachments-${task.id}'),
        projectId: project.id,
        taskId: task.id,
        archived: project.isArchived,
      ),
      _Tab.docs => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: TfSpace.lg,
        children: [
          RelatedDocsPanel(
            projectId: project.id,
            taskId: task.id,
            canEdit: permissions.can(Perm.docEdit),
          ),
          ContributesPanel(taskId: task.id),
        ],
      ),
      _Tab.time => TimeSection(
        key: ValueKey('time-${task.id}'),
        projectId: project.id,
        taskId: task.id,
        archived: project.isArchived,
      ),
      _Tab.fields => TaskFieldsPanel(
        projectId: project.id,
        task: task,
        canEdit: canEdit,
        members: members,
      ),
    };
  }
}
