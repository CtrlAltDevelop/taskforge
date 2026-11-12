import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/offline/offline_providers.dart';
import 'package:taskforge/features/fields/application/fields_providers.dart';
import 'package:taskforge/features/members/application/members_providers.dart';
import 'package:taskforge/features/projects/application/projects_providers.dart';
import 'package:taskforge/features/tasks/application/tasks_providers.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';
import 'package:taskforge/features/workflows/application/workflows_providers.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';

/// The projects of the current workspace the person keeps for offline use.
final keptProjectsProvider = FutureProvider.autoDispose<Set<String>>((
  ref,
) async {
  final workspace = ref.watch(workspaceScopeProvider);
  final store = await ref.watch(offlineStoreFutureProvider);
  if (workspace == null || store == null) return const {};
  return store.keptProjects(workspace);
});

/// How far the copying of one project is: tasks read so far, and what went
/// wrong when it stopped.
typedef KeepProgress = ({int fetched, String? error});

final keepOfflineProvider =
    NotifierProvider<KeepOffline, Map<String, KeepProgress>>(KeepOffline.new);

/// "Keep this project offline": reads the whole project (tasks, workflow,
/// fields, members) into the local copy, which then never trims it away
/// unasked and answers for it when the server is gone.
class KeepOffline extends Notifier<Map<String, KeepProgress>> {
  @override
  Map<String, KeepProgress> build() => const {};

  void _set(String project, KeepProgress? progress) {
    final next = {...state};
    if (progress == null) {
      next.remove(project);
    } else {
      next[project] = progress;
    }
    state = next;
  }

  Future<void> keep(String projectId) async {
    final workspace = ref.read(workspaceScopeProvider);
    final store = await ref.read(offlineStoreFutureProvider);
    if (workspace == null || store == null || state.containsKey(projectId)) {
      return;
    }
    _set(projectId, (fetched: 0, error: null));
    try {
      var fetched = 0;
      await for (final _
          in ref.read(tasksClientProvider).list(workspace, projectId)) {
        fetched++;
        if (fetched % 25 == 0) {
          _set(projectId, (fetched: fetched, error: null));
        }
      }
      await ref.read(workflowsClientProvider).get(workspace, projectId);
      await ref.read(fieldsClientProvider).list(workspace, projectId);
      await ref.read(membersClientProvider).listMembers(workspace);
      await ref.read(projectsClientProvider).listMembers(workspace, projectId);
      final kept = await store.keptProjects(workspace);
      await store.setKeptProjects(workspace, {...kept, projectId});
      ref.invalidate(keptProjectsProvider);
      _set(projectId, null);
    } on TaskException catch (e) {
      _set(projectId, (fetched: 0, error: taskErrorMessage(e)));
    } on Object {
      _set(projectId, (fetched: 0, error: 'It could not be read. Try again.'));
    }
  }

  Future<void> forget(String projectId) async {
    final workspace = ref.read(workspaceScopeProvider);
    final store = await ref.read(offlineStoreFutureProvider);
    if (workspace == null || store == null) return;
    final kept = await store.keptProjects(workspace);
    await store.setKeptProjects(workspace, {...kept}..remove(projectId));
    ref.invalidate(keptProjectsProvider);
  }

  /// Dismisses the error shown for [projectId].
  void clearError(String projectId) => _set(projectId, null);
}
