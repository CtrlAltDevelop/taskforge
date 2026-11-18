import 'package:taskforge/core/ui/tokens/shape.dart';
import 'package:taskforge/core/ui/tf_icons.dart';
import 'package:taskforge/core/ui/tf_app_bar.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:taskforge/core/i18n/context_dates.dart';
import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/comments/application/comments_providers.dart';
import 'package:taskforge/features/goals/application/goals_providers.dart';
import 'package:taskforge/features/goals/domain/goals.dart';
import 'package:taskforge/features/goals/presentation/goal_dialogs.dart';
import 'package:taskforge/features/goals/presentation/goal_widgets.dart';
import 'package:taskforge/features/members/application/members_providers.dart';
import 'package:taskforge/features/members/domain/members.dart';
import 'package:taskforge/features/roles/application/roles_providers.dart';
import 'package:taskforge/features/roles/domain/roles.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';
import 'package:taskforge/core/ui/tf/tf_feedback.dart';
import 'package:taskforge/core/ui/tf/tf_illustration.dart';

enum _FolderAction { rename, delete }

/// The workspace's goals: folders, nesting, progress and status.
class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  Future<void> _run(
    BuildContext context,
    WidgetRef ref,
    Future<void> Function(String ws) call,
  ) async {
    final ws = ref.read(workspaceScopeProvider);
    if (ws == null) return;
    try {
      await call(ws);
    } on GoalsException catch (e) {
      if (context.mounted) {
        sayGoals(context, goalsErrorMessage(e, context.l10n));
      }
    }
    ref.invalidate(goalsProvider);
  }

  Future<void> _newGoal(
    BuildContext context,
    WidgetRef ref,
    GoalCatalog catalog,
  ) async {
    final members = ref.read(membersProvider).value ?? const <Member>[];
    final draft = await showGoalDialog(
      context,
      catalog: catalog,
      members: members,
      me: ref.read(currentUserIdProvider),
    );
    if (draft == null || !context.mounted) return;
    await _run(context, ref, (ws) async {
      final goal = await ref.read(goalsClientProvider).createGoal(ws, draft);
      if (context.mounted) context.push('/goals/${goal.id}');
    });
  }

  Future<void> _newFolder(BuildContext context, WidgetRef ref) async {
    final name = await showFolderDialog(context);
    if (name == null || name.isEmpty || !context.mounted) return;
    await _run(
      context,
      ref,
      (ws) => ref.read(goalsClientProvider).saveFolder(ws, name),
    );
  }

  Future<void> _folderAction(
    BuildContext context,
    WidgetRef ref,
    GoalFolder folder,
    _FolderAction action,
  ) async {
    switch (action) {
      case _FolderAction.rename:
        final name = await showFolderDialog(context, initial: folder.name);
        if (name == null || name.isEmpty || !context.mounted) return;
        await _run(
          context,
          ref,
          (ws) => ref
              .read(goalsClientProvider)
              .saveFolder(ws, name, folderId: folder.id),
        );
      case _FolderAction.delete:
        await _run(
          context,
          ref,
          (ws) => ref.read(goalsClientProvider).deleteFolder(ws, folder.id),
        );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.l10n;
    final goals = ref.watch(goalsProvider);
    final perms = ref.watch(permissionSetProvider);
    final catalog = goals.value ?? GoalCatalog.empty;
    return Scaffold(
      appBar: TfAppBar(
        title: Text(t.goalsTitle),
        actions: [
          if (perms.can(Perm.goalManage))
            IconButton(
              key: const Key('new-folder'),
              tooltip: t.goalsNewFolder,
              icon: const TfIcon(TfIcons.folderPlus),
              onPressed: () => _newFolder(context, ref),
            ),
          if (perms.can(Perm.goalCreate))
            IconButton(
              key: const Key('new-goal'),
              tooltip: t.goalsNew,
              icon: const TfIcon(TfIcons.plus),
              onPressed: goals.hasValue
                  ? () => _newGoal(context, ref, catalog)
                  : null,
            ),
        ],
      ),
      body: goals.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => TfError(
          message: goalsErrorMessage(e, t),
          details: '$e',
          retryKey: const Key('retry-goals'),
          onRetry: () => ref.invalidate(goalsProvider),
        ),
        data: (cat) {
          if (cat.goals.isEmpty) {
            return TfEmpty(
              illustration: TfIllustrationKind.goals,
              title: t.goalsEmpty,
            );
          }
          final roots = cat.roots;
          final folderIds = {for (final f in cat.folders) f.id};
          final loose = [
            for (final g in roots)
              if (!folderIds.contains(g.folderId)) g,
          ];
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              for (final f in cat.folders) ...[
                _FolderHeader(
                  folder: f,
                  menu: perms.can(Perm.goalManage)
                      ? (a) => _folderAction(context, ref, f, a)
                      : null,
                ),
                for (final g in roots.where((g) => g.folderId == f.id))
                  ..._tree(context, cat, g, 0),
              ],
              if (cat.folders.isNotEmpty && loose.isNotEmpty)
                _FolderHeader(name: t.goalsNoFolder),
              for (final g in loose) ..._tree(context, cat, g, 0),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _tree(
    BuildContext context,
    GoalCatalog cat,
    Goal goal,
    int depth,
  ) => [
    GoalTile(goal: goal, depth: depth),
    if (depth < 5)
      for (final c in cat.childrenOf(goal.id))
        ..._tree(context, cat, c, depth + 1),
  ];
}

class _FolderHeader extends StatelessWidget {
  const _FolderHeader({this.folder, this.name, this.menu});

  final GoalFolder? folder;
  final String? name;
  final void Function(_FolderAction)? menu;

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Row(
        children: [
          const TfIcon(TfIcons.folder, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              folder?.name ?? name ?? '',
              key: folder == null ? null : Key('folder-${folder!.id}'),
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          if (menu != null)
            PopupMenuButton<_FolderAction>(
              key: Key('folder-menu-${folder!.id}'),
              onSelected: menu,
              itemBuilder: (c) => [
                PopupMenuItem(
                  value: _FolderAction.rename,
                  child: Text(t.goalsRenameFolder),
                ),
                PopupMenuItem(
                  value: _FolderAction.delete,
                  child: Text(t.goalsDeleteFolder),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

/// One row of the list: name, period, status chip and a progress bar.
class GoalTile extends StatelessWidget {
  const GoalTile({super.key, required this.goal, this.depth = 0});

  final Goal goal;
  final int depth;

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final start = goal.start;
    final end = goal.end;
    return Padding(
      padding: EdgeInsetsDirectional.only(start: 16.0 * depth),
      child: Card(
        child: InkWell(
          key: Key('goal-${goal.id}'),
          borderRadius: TfRadius.dialog,
          onTap: () => context.push('/goals/${goal.id}'),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (goal.private)
                      const Padding(
                        padding: EdgeInsetsDirectional.only(end: 6),
                        child: TfIcon(TfIcons.lock, size: 16),
                      ),
                    Expanded(
                      child: Text(
                        goal.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    GoalStatusChip(status: goal.status),
                  ],
                ),
                if (start != null && end != null)
                  Text(
                    t.goalsPeriod(
                      context.localDate(start),
                      context.localDate(end),
                    ),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                const SizedBox(height: 8),
                GoalProgressBar(
                  progress: goal.progress,
                  color: goalStatusColor(goal.status),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
