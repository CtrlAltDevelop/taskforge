import 'package:flutter/foundation.dart';

/// Registry keys (mirrors backend `registry.py`; the server is the authority).
abstract final class Perm {
  static const workspaceView = 'workspace.view';
  static const workspaceUpdate = 'workspace.update';
  static const workspaceDelete = 'workspace.delete';
  static const memberView = 'member.view';
  static const memberInvite = 'member.invite';
  static const memberRemove = 'member.remove';
  static const memberSetRole = 'member.set_role';
  static const roleView = 'role.view';
  static const roleManage = 'role.manage';
  static const projectCreate = 'project.create';
  static const projectUpdate = 'project.update';
  static const projectArchive = 'project.archive';
  static const projectMemberManage = 'project.member.manage';
  static const projectViewPrivate = 'project.view_private';
  static const taskCreate = 'task.create';
  static const taskUpdate = 'task.update';
  static const taskDelete = 'task.delete';
  static const taskAttachmentManage = 'task.attachment_manage';
  static const commentCreate = 'comment.create';
  static const commentModerate = 'comment.moderate';
  static const timeLog = 'time.log';
  static const timeEditOthers = 'time.edit_others';
  static const sprintManage = 'sprint.manage';
  static const docEdit = 'doc.edit';
  static const docManage = 'doc.manage';
  static const automationManage = 'automation.manage';
  static const auditView = 'audit.view';

  static const all = [
    workspaceView,
    workspaceUpdate,
    workspaceDelete,
    memberView,
    memberInvite,
    memberRemove,
    memberSetRole,
    roleView,
    roleManage,
    projectCreate,
    projectUpdate,
    projectArchive,
    projectMemberManage,
    projectViewPrivate,
    taskCreate,
    taskUpdate,
    taskDelete,
    taskAttachmentManage,
    commentCreate,
    commentModerate,
    timeLog,
    timeEditOthers,
    sprintManage,
    docEdit,
    docManage,
    automationManage,
    auditView,
  ];
}

@immutable
class Role {
  const Role({
    required this.id,
    required this.name,
    required this.isBuiltin,
    required this.permissions,
    this.memberCount = 0,
    this.version = 1,
  });

  final String id;
  final String name;
  final bool isBuiltin;
  final Set<String> permissions;
  final int memberCount;

  /// Optimistic-lock counter; send it back as `expected_version`.
  final int version;

  Role copyWith({String? name, Set<String>? permissions, int? version}) => Role(
    id: id,
    name: name ?? this.name,
    isBuiltin: isBuiltin,
    permissions: permissions ?? this.permissions,
    memberCount: memberCount,
    version: version ?? this.version,
  );
}

@immutable
class PermissionInfo {
  const PermissionInfo(this.key, this.label);

  final String key;
  final String label;
}

@immutable
class PermissionArea {
  const PermissionArea(this.area, this.permissions);

  final String area;
  final List<PermissionInfo> permissions;
}

/// Roles of a workspace plus the registry of every grantable permission.
@immutable
class RoleCatalog {
  const RoleCatalog({required this.roles, required this.registry});

  final List<Role> roles;
  final List<PermissionArea> registry;
}

/// What the signed-in member may do in one workspace. Cosmetic: the server
/// enforces every call again.
@immutable
class Permissions {
  const Permissions({
    required this.workspaceId,
    required this.allowed,
    this.roleId = '',
    this.roleName = '',
  });

  /// Nothing allowed: while loading, on failure, or for a stale workspace.
  static const none = Permissions(workspaceId: null, allowed: {});

  final String? workspaceId;
  final Set<String> allowed;
  final String roleId;
  final String roleName;

  bool can(String key) => allowed.contains(key);
}

enum RoleFailure {
  builtin,
  nameTaken,
  ownerProtected,
  denied,
  forbidden,
  invalid,
  notFound,
  conflict,
  network,
  other,
}

class RoleException implements Exception {
  const RoleException(this.failure, [this.detail]);

  final RoleFailure failure;
  final String? detail;

  @override
  String toString() => 'RoleException($failure, $detail)';
}

/// What to tell the user about a failed roles call.
String roleErrorMessage(Object error) {
  if (error is! RoleException) return 'Something went wrong. Try again.';
  return switch (error.failure) {
    RoleFailure.builtin => 'Built-in roles cannot be changed or deleted.',
    RoleFailure.nameTaken => 'A role with that name already exists.',
    RoleFailure.ownerProtected => 'A workspace needs at least one owner.',
    RoleFailure.denied => error.detail ?? 'You do not have permission.',
    RoleFailure.forbidden => 'You do not have permission to do that.',
    RoleFailure.invalid => error.detail ?? 'Check the values and try again.',
    RoleFailure.notFound => 'That role no longer exists.',
    RoleFailure.conflict =>
      'This role changed in the meantime. Reloaded — try again.',
    RoleFailure.network =>
      'Cannot reach the server. Check your connection and try again.',
    RoleFailure.other => 'Something went wrong. Try again.',
  };
}
