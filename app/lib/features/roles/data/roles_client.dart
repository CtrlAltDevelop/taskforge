import 'package:grpc/grpc.dart' show GrpcError, StatusCode;
import 'package:grpc/grpc_connection_interface.dart' show ClientChannelBase;
import 'package:http/http.dart' as http;

import 'package:taskforge/core/auth/auth_session.dart';
import 'package:taskforge/core/permissions/permission_denied.dart';
import 'package:taskforge/core/workspace/scoped_requests.dart';
import 'package:taskforge/features/roles/domain/roles.dart';
import 'package:taskforge/features/workspaces/domain/workspace.dart'
    show stripErrorTitle;
import 'package:taskforge/gen/infrastructure/workspaces/grpc/workspaces.pbgrpc.dart'
    as pb;

abstract interface class RolesClient {
  Future<RoleCatalog> list(String workspaceId);
  Future<Role> create(
    String workspaceId, {
    required String name,
    required Set<String> permissions,
  });

  /// Replaces name and checklist together. [expectedVersion] is the version
  /// of the role as last loaded; a stale one fails with [RoleFailure.conflict].
  Future<Role> update(
    String workspaceId,
    String id, {
    required String name,
    required Set<String> permissions,
    required int expectedVersion,
  });

  /// [reassignTo] is required only while the role still has members.
  Future<void> delete(String workspaceId, String id, {String? reassignTo});

  /// The caller's answers for [keys] in [workspaceId].
  Future<Permissions> check(String workspaceId, List<String> keys);
}

RoleException mapRoleError(Object error) {
  if (error is RoleException) return error;
  if (error is GrpcError) {
    final message = error.message ?? '';
    final title = RegExp(r'^([A-Z][A-Z0-9_]*): ').firstMatch(message)?.group(1);
    final denied = parsePermissionDenied(error);
    return switch (error.code) {
      StatusCode.permissionDenied when denied != null => RoleException(
        RoleFailure.denied,
        denied.message,
      ),
      StatusCode.permissionDenied => RoleException(switch (title) {
        'ROLE_BUILTIN' => RoleFailure.builtin,
        'OWNER_PROTECTED' => RoleFailure.ownerProtected,
        _ => RoleFailure.forbidden,
      }),
      StatusCode.alreadyExists => const RoleException(RoleFailure.nameTaken),
      StatusCode.invalidArgument => RoleException(
        RoleFailure.invalid,
        stripErrorTitle(message),
      ),
      StatusCode.notFound => const RoleException(RoleFailure.notFound),
      StatusCode.aborted => const RoleException(RoleFailure.conflict),
      StatusCode.unavailable ||
      StatusCode.deadlineExceeded => const RoleException(RoleFailure.network),
      _ => const RoleException(RoleFailure.other),
    };
  }
  if (error is http.ClientException) {
    return const RoleException(RoleFailure.network);
  }
  return const RoleException(RoleFailure.other);
}

Role _role(pb.Role r) => Role(
  id: r.id,
  name: r.name,
  isBuiltin: r.isBuiltin,
  permissions: {...r.permissions},
  memberCount: r.memberCount,
  version: r.version,
);

class GrpcRolesClient implements RolesClient {
  GrpcRolesClient(ClientChannelBase channel, this._session, {this.onRefusal})
    : _roles = pb.RoleControllerClient(channel),
      _checks = pb.PermissionControllerClient(channel);

  final pb.RoleControllerClient _roles;
  final pb.PermissionControllerClient _checks;
  final AuthSession _session;

  /// Called when a mutating call is refused (permissions may be stale).
  final void Function()? onRefusal;

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
      final mapped = mapRoleError(e);
      if (!isRead &&
          (mapped.failure == RoleFailure.denied ||
              mapped.failure == RoleFailure.forbidden)) {
        onRefusal?.call();
      }
      throw mapped;
    }
  }

  @override
  Future<RoleCatalog> list(String workspaceId) async {
    final reply = await _run(
      () => _roles.list(
        pb.RoleListRequest(workspaceId: workspaceId),
        options: _options,
      ),
      isRead: true,
    );
    return RoleCatalog(
      roles: [for (final r in reply.roles) _role(r)],
      registry: [
        for (final a in reply.registry)
          PermissionArea(a.area, [
            for (final p in a.permissions) PermissionInfo(p.key, p.label),
          ]),
      ],
    );
  }

  @override
  Future<Role> create(
    String workspaceId, {
    required String name,
    required Set<String> permissions,
  }) async => _role(
    await _run(
      () => _roles.create(
        pb.RoleCreateRequest(
          workspaceId: workspaceId,
          name: name,
          permissions: permissions,
        ),
        options: _options,
      ),
    ),
  );

  @override
  Future<Role> update(
    String workspaceId,
    String id, {
    required String name,
    required Set<String> permissions,
    required int expectedVersion,
  }) async => _role(
    await _run(
      () => _roles.update(
        pb.RoleUpdateRequest(
          workspaceId: workspaceId,
          id: id,
          name: name,
          permissions: permissions,
          expectedVersion: expectedVersion,
        ),
        options: _options,
      ),
    ),
  );

  @override
  Future<void> delete(
    String workspaceId,
    String id, {
    String? reassignTo,
  }) async {
    await _run(
      () => _roles.delete(
        pb.RoleDeleteRequest(
          workspaceId: workspaceId,
          id: id,
          reassignTo: reassignTo,
        ),
        options: _options,
      ),
    );
  }

  @override
  Future<Permissions> check(String workspaceId, List<String> keys) async {
    final reply = await _run(
      () => _checks.check(
        pb.PermissionCheckRequest(workspaceId: workspaceId, keys: keys),
        options: _options,
      ),
      isRead: true,
    );
    return Permissions(
      workspaceId: workspaceId,
      allowed: {
        for (final a in reply.answers)
          if (a.allowed) a.key,
      },
      roleId: reply.roleId,
      roleName: reply.roleName,
    );
  }
}
