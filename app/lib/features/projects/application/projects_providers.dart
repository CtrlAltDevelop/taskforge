import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/auth/auth_providers.dart';
import 'package:taskforge/core/grpc/grpc_providers.dart';
import 'package:taskforge/core/permissions/refusals.dart';
import 'package:taskforge/features/projects/data/projects_client.dart';
import 'package:taskforge/features/projects/domain/projects.dart';
import 'package:taskforge/features/roles/application/roles_providers.dart';
import 'package:taskforge/features/roles/domain/roles.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';

final projectsClientProvider = Provider<ProjectsClient>(
  (ref) => GrpcProjectsClient(
    ref.watch(grpcChannelProvider),
    ref.watch(authSessionProvider),
    onRefusal: () => ref.read(refusalCountProvider.notifier).bump(),
  ),
);

/// Projects of the current workspace (archived ones only when asked); rebuilt
/// on a workspace switch or a refused call.
final projectsProvider = FutureProvider.autoDispose
    .family<ProjectCatalog, bool>((ref, includeArchived) async {
      ref.watch(refusalCountProvider);
      final id = ref.watch(workspaceScopeProvider);
      if (id == null) return ProjectCatalog.empty;
      return ref
          .watch(projectsClientProvider)
          .list(id, includeArchived: includeArchived);
    }, retry: (_, _) => null);

/// [projectsProvider], but loading (never the previous workspace's list)
/// while the loaded catalog belongs to another workspace than the current one.
final projectCatalogProvider = Provider.autoDispose
    .family<AsyncValue<ProjectCatalog>, bool>((ref, includeArchived) {
      final scope = ref.watch(workspaceScopeProvider);
      final catalog = ref.watch(projectsProvider(includeArchived));
      final stale =
          scope != null &&
          catalog.value != null &&
          catalog.value!.workspaceId != scope;
      return stale ? const AsyncLoading() : catalog;
    });

/// One project looked up in the full list (archived included); null when the
/// list is still loading or the project is not visible.
final projectProvider = Provider.autoDispose.family<Project?, String>(
  (ref, id) => ref
      .watch(projectCatalogProvider(true))
      .value
      ?.projects
      .where((p) => p.id == id)
      .firstOrNull,
);

/// Members of one private project.
final projectMembersProvider = FutureProvider.autoDispose
    .family<List<ProjectMember>, String>((ref, projectId) async {
      ref.watch(refusalCountProvider);
      final id = ref.watch(workspaceScopeProvider);
      if (id == null) return const [];
      return ref.watch(projectsClientProvider).listMembers(id, projectId);
    }, retry: (_, _) => null);

/// Admin list of private projects; empty unless `project.view_private`.
final privateProjectsProvider = FutureProvider.autoDispose<List<Project>>((
  ref,
) async {
  ref.watch(refusalCountProvider);
  final id = ref.watch(workspaceScopeProvider);
  final allowed = ref.watch(permissionSetProvider).can(Perm.projectViewPrivate);
  if (id == null || !allowed) return const [];
  return ref.watch(projectsClientProvider).listPrivate(id);
}, retry: (_, _) => null);

/// Mutations of the current workspace's projects. Each one refreshes what the
/// screens read; failures surface as [ProjectException].
final projectsControllerProvider = Provider<ProjectsController>(
  ProjectsController.new,
);

class ProjectsController {
  ProjectsController(this._ref);

  final Ref _ref;

  ProjectsClient get _client => _ref.read(projectsClientProvider);

  String get _workspace {
    final id = _ref.read(workspaceScopeProvider);
    if (id == null) throw const ProjectException(ProjectFailure.other);
    return id;
  }

  void _refresh() {
    _ref.invalidate(projectsProvider);
    _ref.invalidate(projectMembersProvider);
    _ref.invalidate(privateProjectsProvider);
  }

  /// Runs [call]; the lists are re-read afterwards, also after a failure (a
  /// version conflict means they are stale).
  Future<T> _mutate<T>(Future<T> Function(String workspace) call) async {
    try {
      return await call(_workspace);
    } finally {
      _refresh();
    }
  }

  Future<Project> create({
    required String name,
    required String key,
    String description = '',
    String icon = '',
    String color = '',
    ProjectVisibility visibility = ProjectVisibility.open,
  }) => _mutate(
    (w) => _client.create(
      w,
      name: name,
      key: key,
      description: description,
      icon: icon,
      color: color,
      visibility: visibility,
    ),
  );

  Future<Project> update(
    Project project, {
    String? name,
    String? key,
    String? description,
    String? icon,
    String? color,
    ProjectVisibility? visibility,
  }) => _mutate(
    (w) => _client.update(
      w,
      project.id,
      expectedVersion: project.version,
      name: name,
      key: key,
      description: description,
      icon: icon,
      color: color,
      visibility: visibility,
    ),
  );

  Future<Project> archive(Project p) =>
      _mutate((w) => _client.archive(w, p.id, p.version));

  Future<Project> restore(Project p) =>
      _mutate((w) => _client.restore(w, p.id, p.version));

  Future<Project> setFeatures(Project p, Set<String> enabled) =>
      _mutate((w) => _client.setFeatures(w, p.id, enabled, p.version));

  Future<Project> favorite(Project p, bool favorite) =>
      _mutate((w) => _client.favorite(w, p.id, favorite));

  Future<void> addMember(String projectId, String userId) =>
      _mutate((w) => _client.addMember(w, projectId, userId));

  /// The server reads an empty user id as the caller.
  Future<void> addMe(String projectId) => addMember(projectId, '');

  Future<void> removeMember(String projectId, String userId) =>
      _mutate((w) => _client.removeMember(w, projectId, userId));
}
