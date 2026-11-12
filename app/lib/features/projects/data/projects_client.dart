import 'package:grpc/grpc.dart' show GrpcError, StatusCode;
import 'package:grpc/grpc_connection_interface.dart' show ClientChannelBase;
import 'package:http/http.dart' as http;

import 'package:taskforge/core/auth/auth_session.dart';
import 'package:taskforge/core/offline/read_cache.dart';
import 'package:taskforge/core/permissions/permission_denied.dart';
import 'package:taskforge/core/workspace/scoped_requests.dart';
import 'package:taskforge/features/projects/domain/projects.dart';
import 'package:taskforge/features/workspaces/domain/workspace.dart'
    show stripErrorTitle;
import 'package:taskforge/gen/infrastructure/projects/grpc/projects.pbgrpc.dart'
    as pb;

abstract interface class ProjectsClient {
  /// Favorites first, then by name; archived ones only with [includeArchived].
  Future<ProjectCatalog> list(
    String workspaceId, {
    bool includeArchived = false,
  });
  Future<Project> create(
    String workspaceId, {
    required String name,
    required String key,
    String description = '',
    String icon = '',
    String color = '',
    ProjectVisibility visibility = ProjectVisibility.open,
  });

  /// Only the fields given change.
  Future<Project> update(
    String workspaceId,
    String id, {
    required int expectedVersion,
    String? name,
    String? key,
    String? description,
    String? icon,
    String? color,
    ProjectVisibility? visibility,
  });
  Future<Project> archive(String workspaceId, String id, int expectedVersion);
  Future<Project> restore(String workspaceId, String id, int expectedVersion);
  Future<Project> setFeatures(
    String workspaceId,
    String id,
    Set<String> enabledKeys,
    int expectedVersion,
  );
  Future<Project> favorite(String workspaceId, String id, bool favorite);
  Future<List<ProjectMember>> listMembers(String workspaceId, String id);
  Future<void> addMember(String workspaceId, String id, String userId);
  Future<void> removeMember(String workspaceId, String id, String userId);

  /// Admin list of active private projects (needs `project.view_private`).
  Future<List<Project>> listPrivate(String workspaceId);
}

/// Maps a transport failure to a [ProjectException]. The gRPC message starts
/// with a `TITLE: ` that tells the conflicts apart, so it is read here, before
/// [stripErrorTitle] would drop it.
ProjectException mapProjectError(Object error) {
  if (error is ProjectException) return error;
  if (error is GrpcError) {
    final message = error.message ?? '';
    final title = RegExp(r'^([A-Z][A-Z0-9_]*): ').firstMatch(message)?.group(1);
    final denied = parsePermissionDenied(error);
    return switch (error.code) {
      StatusCode.permissionDenied when denied != null => ProjectException(
        ProjectFailure.denied,
        denied.message,
      ),
      StatusCode.permissionDenied => const ProjectException(
        ProjectFailure.forbidden,
      ),
      StatusCode.alreadyExists => ProjectException(switch (title) {
        'KEY_LOCKED' => ProjectFailure.keyLocked,
        'PROJECT_ARCHIVED' => ProjectFailure.archived,
        'LAST_MEMBER' => ProjectFailure.lastMember,
        _ => ProjectFailure.keyTaken,
      }),
      StatusCode.invalidArgument => ProjectException(
        ProjectFailure.invalid,
        stripErrorTitle(message),
      ),
      StatusCode.notFound => const ProjectException(ProjectFailure.notFound),
      StatusCode.aborted => const ProjectException(ProjectFailure.conflict),
      StatusCode.unavailable || StatusCode.deadlineExceeded =>
        const ProjectException(ProjectFailure.network),
      _ => const ProjectException(ProjectFailure.other),
    };
  }
  if (error is http.ClientException) {
    return const ProjectException(ProjectFailure.network);
  }
  return const ProjectException(ProjectFailure.other);
}

Project _project(pb.Project p) => Project(
  id: p.id,
  name: p.name,
  key: p.key,
  description: p.description,
  icon: p.icon,
  color: p.color,
  visibility: p.visibility == 'private'
      ? ProjectVisibility.private
      : ProjectVisibility.open,
  archivedAt: p.archivedAt,
  version: p.version,
  taskCounter: p.taskCounter,
  features: [
    for (final f in p.features) Feature(key: f.key, enabled: f.enabled),
  ],
  isFavorite: p.isFavorite,
  memberCount: p.memberCount,
  isMember: p.isMember,
  canOpen: p.canOpen,
);

class GrpcProjectsClient implements ProjectsClient {
  GrpcProjectsClient(
    ClientChannelBase channel,
    this._session, {
    this.onRefusal,
    this.cache,
  }) : _stub = pb.ProjectControllerClient(channel);

  final pb.ProjectControllerClient _stub;
  final AuthSession _session;

  /// Called when a mutating call is refused (permissions may be stale).
  final void Function()? onRefusal;

  /// Keeps the last reads for when the server cannot be reached.
  final ReadCache? cache;

  // The workspace id travels in each request body, so no x-workspace header.
  late final _options = scopedCallOptions(_session, () => null);

  /// Runs [call]; one refresh-and-retry when the token is rejected.
  Future<T> _run<T>(Future<T> Function() call, {bool isRead = false}) async {
    try {
      try {
        return await call();
      } on GrpcError catch (e) {
        if (e.code != StatusCode.unauthenticated) rethrow;
        if (await _session.forceRefresh() == null) rethrow;
        return await call();
      }
    } on Object catch (e) {
      final mapped = mapProjectError(e);
      if (!isRead &&
          (mapped.failure == ProjectFailure.denied ||
              mapped.failure == ProjectFailure.forbidden)) {
        onRefusal?.call();
      }
      throw mapped;
    }
  }

  @override
  Future<ProjectCatalog> list(
    String workspaceId, {
    bool includeArchived = false,
  }) async {
    final reply = await _run(
      () => readThrough(
        cache,
        workspaceId,
        'projects:$includeArchived',
        () => _stub.list(
          pb.ProjectListRequest(
            workspaceId: workspaceId,
            includeArchived: includeArchived,
          ),
          options: _options,
        ),
        pb.ProjectList.fromBuffer,
      ),
      isRead: true,
    );
    return ProjectCatalog(
      projects: [for (final p in reply.projects) _project(p)],
      featureInfo: [
        for (final f in reply.featureInfo)
          FeatureInfo(key: f.key, label: f.label, description: f.description),
      ],
      workspaceId: workspaceId,
    );
  }

  @override
  Future<Project> create(
    String workspaceId, {
    required String name,
    required String key,
    String description = '',
    String icon = '',
    String color = '',
    ProjectVisibility visibility = ProjectVisibility.open,
  }) async => _project(
    await _run(
      () => _stub.create(
        pb.ProjectCreateRequest(
          workspaceId: workspaceId,
          name: name,
          key: key,
          description: description,
          icon: icon,
          color: color,
          visibility: visibility.wire,
        ),
        options: _options,
      ),
    ),
  );

  @override
  Future<Project> update(
    String workspaceId,
    String id, {
    required int expectedVersion,
    String? name,
    String? key,
    String? description,
    String? icon,
    String? color,
    ProjectVisibility? visibility,
  }) async => _project(
    await _run(
      () => _stub.update(
        pb.ProjectUpdateRequest(
          workspaceId: workspaceId,
          id: id,
          expectedVersion: expectedVersion,
          name: name,
          key: key,
          description: description,
          icon: icon,
          color: color,
          visibility: visibility?.wire,
        ),
        options: _options,
      ),
    ),
  );

  @override
  Future<Project> archive(
    String workspaceId,
    String id,
    int expectedVersion,
  ) async => _project(
    await _run(
      () => _stub.archive(
        pb.ProjectArchiveRequest(
          workspaceId: workspaceId,
          id: id,
          expectedVersion: expectedVersion,
        ),
        options: _options,
      ),
    ),
  );

  @override
  Future<Project> restore(
    String workspaceId,
    String id,
    int expectedVersion,
  ) async => _project(
    await _run(
      () => _stub.restore(
        pb.ProjectRestoreRequest(
          workspaceId: workspaceId,
          id: id,
          expectedVersion: expectedVersion,
        ),
        options: _options,
      ),
    ),
  );

  @override
  Future<Project> setFeatures(
    String workspaceId,
    String id,
    Set<String> enabledKeys,
    int expectedVersion,
  ) async => _project(
    await _run(
      () => _stub.setFeatures(
        pb.ProjectSetFeaturesRequest(
          workspaceId: workspaceId,
          projectId: id,
          enabledKeys: enabledKeys,
          expectedVersion: expectedVersion,
        ),
        options: _options,
      ),
    ),
  );

  @override
  Future<Project> favorite(
    String workspaceId,
    String id,
    bool favorite,
  ) async => _project(
    await _run(
      () => _stub.favorite(
        pb.ProjectFavoriteRequest(
          workspaceId: workspaceId,
          projectId: id,
          favorite: favorite,
        ),
        options: _options,
      ),
    ),
  );

  @override
  Future<List<ProjectMember>> listMembers(String workspaceId, String id) async {
    final reply = await _run(
      () => readThrough(
        cache,
        workspaceId,
        'project-members:$id',
        () => _stub.listMembers(
          pb.ProjectListMembersRequest(workspaceId: workspaceId, projectId: id),
          options: _options,
        ),
        pb.ProjectMemberList.fromBuffer,
      ),
      isRead: true,
    );
    return [
      for (final m in reply.members)
        ProjectMember(
          userId: m.userId,
          displayName: m.displayName,
          email: m.email,
        ),
    ];
  }

  @override
  Future<void> addMember(String workspaceId, String id, String userId) async {
    await _run(
      () => _stub.addMember(
        pb.ProjectAddMemberRequest(
          workspaceId: workspaceId,
          projectId: id,
          userId: userId,
        ),
        options: _options,
      ),
    );
  }

  @override
  Future<void> removeMember(
    String workspaceId,
    String id,
    String userId,
  ) async {
    await _run(
      () => _stub.removeMember(
        pb.ProjectRemoveMemberRequest(
          workspaceId: workspaceId,
          projectId: id,
          userId: userId,
        ),
        options: _options,
      ),
    );
  }

  @override
  Future<List<Project>> listPrivate(String workspaceId) async {
    final reply = await _run(
      () => _stub.listPrivate(
        pb.ProjectListPrivateRequest(workspaceId: workspaceId),
        options: _options,
      ),
      isRead: true,
    );
    return [for (final p in reply.projects) _project(p)];
  }
}
