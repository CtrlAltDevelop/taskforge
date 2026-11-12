import 'package:taskforge/features/roles/data/roles_client.dart';
import 'package:taskforge/features/roles/domain/roles.dart';

const _everything = Perm.all;

/// Built-in grants (mirrors the backend registry table).
final _builtinGrants = <String, Set<String>>{
  'Owner': {..._everything},
  'Admin': {
    Perm.workspaceView,
    Perm.workspaceUpdate,
    Perm.memberView,
    Perm.memberInvite,
    Perm.memberRemove,
    Perm.memberSetRole,
    Perm.roleView,
    Perm.roleManage,
    Perm.projectCreate,
    Perm.projectUpdate,
    Perm.projectArchive,
    Perm.projectMemberManage,
    Perm.projectViewPrivate,
    Perm.taskCreate,
    Perm.taskUpdate,
    Perm.taskDelete,
    Perm.taskAttachmentManage,
    Perm.commentCreate,
    Perm.commentModerate,
    Perm.timeLog,
    Perm.timeEditOthers,
    Perm.sprintManage,
    Perm.docEdit,
    Perm.docManage,
    Perm.automationManage,
    Perm.auditView,
    Perm.dashboardManage,
    Perm.dataManage,
  },
  'Member': {
    Perm.workspaceView,
    Perm.memberView,
    Perm.memberInvite,
    Perm.roleView,
    Perm.projectCreate,
    Perm.taskCreate,
    Perm.taskUpdate,
    Perm.taskDelete,
    Perm.commentCreate,
    Perm.timeLog,
    Perm.sprintManage,
    Perm.docEdit,
  },
  'Viewer': {Perm.workspaceView, Perm.memberView, Perm.roleView},
};

const registry = [
  PermissionArea('Workspace', [
    PermissionInfo(Perm.workspaceView, 'View workspace'),
    PermissionInfo(Perm.workspaceUpdate, 'Edit workspace'),
    PermissionInfo(Perm.workspaceDelete, 'Delete workspace'),
  ]),
  PermissionArea('Members', [
    PermissionInfo(Perm.memberView, 'View members'),
    PermissionInfo(Perm.memberInvite, 'Invite members'),
    PermissionInfo(Perm.memberRemove, 'Remove members'),
    PermissionInfo(Perm.memberSetRole, 'Change roles'),
  ]),
  PermissionArea('Roles', [
    PermissionInfo(Perm.roleView, 'View roles'),
    PermissionInfo(Perm.roleManage, 'Manage roles'),
  ]),
  PermissionArea('Projects', [
    PermissionInfo(Perm.projectCreate, 'Create projects'),
    PermissionInfo(Perm.projectUpdate, 'Edit projects'),
    PermissionInfo(Perm.projectArchive, 'Archive projects'),
    PermissionInfo(Perm.projectMemberManage, 'Manage project members'),
    PermissionInfo(Perm.projectViewPrivate, 'See private projects'),
  ]),
  PermissionArea('Tasks', [
    PermissionInfo(Perm.taskCreate, 'Create tasks'),
    PermissionInfo(Perm.taskUpdate, 'Edit tasks'),
    PermissionInfo(Perm.taskDelete, 'Delete tasks'),
    PermissionInfo(Perm.taskAttachmentManage, "Delete anyone's attachments"),
  ]),
  PermissionArea('Comments', [
    PermissionInfo(Perm.commentCreate, 'Write comments'),
    PermissionInfo(Perm.commentModerate, 'Moderate comments'),
  ]),
  PermissionArea('Automations', [
    PermissionInfo(
      Perm.automationManage,
      'Create, edit, switch on and off, test and delete automations',
    ),
  ]),
  PermissionArea('Audit', [
    PermissionInfo(Perm.auditView, 'Read and export the workspace audit log'),
  ]),
  PermissionArea('Dashboards', [
    PermissionInfo(
      Perm.dashboardManage,
      'Share dashboards with a project or the workspace, edit shared ones',
    ),
  ]),
  PermissionArea('Data', [
    PermissionInfo(
      Perm.dataManage,
      'Import projects from other tools, undo an import, export data',
    ),
  ]),
];

/// In-memory roles server. The caller's role is [callerRole] (by name) and may
/// be changed mid-test to simulate a role change.
class FakeRolesClient implements RolesClient {
  FakeRolesClient({String Function(String workspaceId)? callerRole})
    : callerRoleFor = callerRole ?? ((_) => 'Owner') {
    var id = 1;
    for (final e in _builtinGrants.entries) {
      roles.add(
        Role(
          id: '${id++}',
          name: e.key,
          isBuiltin: true,
          permissions: e.value,
          memberCount: e.key == 'Member' ? 2 : 1,
        ),
      );
    }
  }

  String Function(String workspaceId) callerRoleFor;
  final roles = <Role>[];
  final checks = <String>[];
  RoleException? failNext;
  int listCalls = 0;

  /// Every accepted or rejected update, in arrival order.
  final updates =
      <({String id, int expectedVersion, Set<String> permissions})>[];

  /// While set, [update] waits for it (keeps a request in flight).
  Future<void>? hold;
  int _next = 100;

  /// Reassign targets passed to [delete], for assertions.
  final deletes = <({String id, String? reassignTo})>[];

  void _maybeFail() {
    final e = failNext;
    failNext = null;
    if (e != null) throw e;
  }

  Role roleNamed(String name) => roles.firstWhere((r) => r.name == name);

  @override
  Future<RoleCatalog> list(String workspaceId) async {
    listCalls++;
    _maybeFail();
    return RoleCatalog(roles: [...roles], registry: registry);
  }

  @override
  Future<Role> create(
    String workspaceId, {
    required String name,
    required Set<String> permissions,
  }) async {
    _maybeFail();
    if (roles.any((r) => r.name.toLowerCase() == name.toLowerCase())) {
      throw const RoleException(RoleFailure.nameTaken);
    }
    final role = Role(
      id: '${_next++}',
      name: name,
      isBuiltin: false,
      permissions: permissions,
    );
    roles.add(role);
    return role;
  }

  @override
  Future<Role> update(
    String workspaceId,
    String id, {
    required String name,
    required Set<String> permissions,
    required int expectedVersion,
  }) async {
    updates.add((
      id: id,
      expectedVersion: expectedVersion,
      permissions: permissions,
    ));
    await hold;
    _maybeFail();
    final i = roles.indexWhere((r) => r.id == id);
    if (roles[i].isBuiltin) throw const RoleException(RoleFailure.builtin);
    if (roles[i].version != expectedVersion) {
      throw const RoleException(RoleFailure.conflict);
    }
    return roles[i] = roles[i].copyWith(
      name: name,
      permissions: permissions,
      version: roles[i].version + 1,
    );
  }

  /// Simulates someone else editing role [id]: bumps its version.
  void editElsewhere(String id) {
    final i = roles.indexWhere((r) => r.id == id);
    roles[i] = roles[i].copyWith(version: roles[i].version + 1);
  }

  @override
  Future<void> delete(
    String workspaceId,
    String id, {
    String? reassignTo,
  }) async {
    _maybeFail();
    deletes.add((id: id, reassignTo: reassignTo));
    roles.removeWhere((r) => r.id == id);
  }

  @override
  Future<Permissions> check(String workspaceId, List<String> keys) async {
    checks.add(workspaceId);
    final role = roleNamed(callerRoleFor(workspaceId));
    return Permissions(
      workspaceId: workspaceId,
      allowed: {
        for (final k in keys)
          if (role.permissions.contains(k)) k,
      },
      roleId: role.id,
      roleName: role.name,
    );
  }
}
