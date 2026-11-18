import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/core/offline/presentation/offline_banner.dart';
import 'package:taskforge/core/ui/theme_extension.dart';
import 'package:taskforge/core/ui/tf/tf_button.dart';
import 'package:taskforge/core/ui/tf/tf_menu.dart';
import 'package:taskforge/core/ui/tf_icons.dart';
import 'package:taskforge/core/ui/tokens/spacing.dart';
import 'package:taskforge/features/inbox/presentation/watch_button.dart';
import 'package:taskforge/features/tasks/application/task_detail_state.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';
import 'package:taskforge/features/tasks/presentation/presence_strip.dart';
import 'package:taskforge/features/tasks/presentation/subtasks_panel.dart';
import 'package:taskforge/features/tasks/presentation/task_actions.dart';
import 'package:taskforge/l10n/gen/app_localizations.dart';
import 'package:taskforge/features/home/presentation/sample_badge.dart';

/// Below this width the header keeps only the essentials in the row.
const _headerCompactBelow = 520.0;

/// The top of the task: `PROJ-123` (with where it sits), who is looking, and
/// the actions: previous/next, copy link, watch, save as template, delete,
/// how it opens, close.
class TaskHeader extends ConsumerWidget {
  const TaskHeader({
    super.key,
    required this.task,
    required this.breadcrumb,
    required this.kind,
    required this.canDelete,
    required this.canTemplate,
    required this.onClose,
    required this.onOpen,
    required this.onDelete,
    required this.onTemplate,
    required this.onKind,
    this.onPrevious,
    this.onNext,
    this.showClose = true,
  });

  final Task task;
  final List<Task> breadcrumb;
  final TaskPresentationKind kind;
  final bool canDelete;
  final bool canTemplate;
  final VoidCallback onClose;
  final void Function(Task) onOpen;
  final VoidCallback onDelete;
  final VoidCallback onTemplate;
  final void Function(TaskPresentationKind) onKind;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final bool showClose;

  Future<void> _copyLink(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final said = context.l10n.tdLinkCopied;
    final path = Uri(
      path: '/projects/${task.projectId}',
      queryParameters: {'task': task.id},
    ).toString();
    final base = Uri.base;
    final link = base.scheme.startsWith('http') ? '${base.origin}$path' : path;
    await Clipboard.setData(ClipboardData(text: link));
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(said)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final tf = context.tf;
    final c = tf.colors;
    return LayoutBuilder(
      builder: (context, box) {
        final compact = box.maxWidth < _headerCompactBelow;
        final more = TfMenu(
          items: [
            if (compact && onPrevious != null)
              TfMenuItem(
                label: l10n.tdPreviousTask,
                icon: TfIcons.arrowUp,
                shortcut: '[',
                onSelected: onPrevious,
              ),
            if (compact && onNext != null)
              TfMenuItem(
                label: l10n.tdNextTask,
                icon: TfIcons.arrowDown,
                shortcut: ']',
                onSelected: onNext,
              ),
            TfMenuItem(
              label: l10n.tdCopyLink,
              icon: TfIcons.link,
              onSelected: () => _copyLink(context),
            ),
            if (compact && canTemplate)
              TfMenuItem(
                label: l10n.tplSaveTask,
                icon: TfIcons.copy,
                onSelected: onTemplate,
              ),
            for (final k in TaskPresentationKind.values)
              TfMenuItem(
                key: Key('open-as-${k.name}'),
                label: l10n.tdOpenAs(_kindLabel(l10n, k)),
                icon: switch (k) {
                  TaskPresentationKind.modal => TfIcons.columns,
                  TaskPresentationKind.peek => TfIcons.sidebar,
                  TaskPresentationKind.page => TfIcons.file,
                },
                selected: k == kind,
                onSelected: () => onKind(k),
              ),
          ],
          builder: (context, toggle) => TfIconButton(
            key: const Key('task-more'),
            icon: TfIcons.more,
            tooltip: l10n.grpFMore,
            onPressed: toggle,
          ),
        );
        return Padding(
          padding: const EdgeInsets.only(bottom: TfSpace.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  PendingMark(id: task.id),
                  Flexible(
                    child: Text(
                      task.displayId,
                      key: const Key('detail-id'),
                      textDirection: TextDirection.ltr,
                      overflow: TextOverflow.ellipsis,
                      style: tf.typography.mono.copyWith(
                        color: c.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (task.isBlocked) ...[
                    const SizedBox(width: TfSpace.sm),
                    BlockedBadge(blockedBy: task.blockedBy),
                  ],
                  if (task.isSample) ...[
                    const SizedBox(width: TfSpace.sm),
                    const SampleBadge(),
                  ],
                  const Spacer(),
                  if (!compact) ...[
                    PresenceStrip(projectId: task.projectId, taskId: task.id),
                    if (onPrevious != null)
                      TfIconButton(
                        key: const Key('prev-task'),
                        icon: TfIcons.arrowUp,
                        tooltip: l10n.tdPreviousTask,
                        onPressed: onPrevious,
                      ),
                    if (onNext != null)
                      TfIconButton(
                        key: const Key('next-task'),
                        icon: TfIcons.arrowDown,
                        tooltip: l10n.tdNextTask,
                        onPressed: onNext,
                      ),
                  ],
                  WatchButton(projectId: task.projectId, taskId: task.id),
                  if (!compact && canTemplate)
                    TfIconButton(
                      key: const Key('save-task-template'),
                      icon: TfIcons.copy,
                      tooltip: l10n.tplSaveTask,
                      onPressed: onTemplate,
                    ),
                  if (canDelete)
                    TfIconButton(
                      key: const Key('delete-task'),
                      icon: TfIcons.trash,
                      tooltip: l10n.grpDDeleteTask,
                      onPressed: onDelete,
                    ),
                  more,
                  if (showClose)
                    TfIconButton(
                      key: const Key('close-detail'),
                      icon: TfIcons.close,
                      tooltip: l10n.grpDClose,
                      onPressed: onClose,
                    ),
                ],
              ),
              Breadcrumb(chain: breadcrumb, onOpen: onOpen),
            ],
          ),
        );
      },
    );
  }
}

String _kindLabel(AppLocalizations l10n, TaskPresentationKind k) => switch (k) {
  TaskPresentationKind.modal => l10n.tdKindModal,
  TaskPresentationKind.peek => l10n.tdKindPeek,
  TaskPresentationKind.page => l10n.tdKindPage,
};
