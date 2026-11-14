import 'dart:ui' show Locale;

import 'package:flutter/foundation.dart';
import 'package:taskforge/l10n/gen/app_localizations.dart';

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
  static const dashboardManage = 'dashboard.manage';
  static const dataManage = 'data.manage';
  static const webhookManage = 'webhook.manage';
  static const formManage = 'form.manage';
  static const goalCreate = 'goal.create';
  static const goalManage = 'goal.manage';
  static const templateCreate = 'template.create';
  static const templateManage = 'template.manage';
  static const workloadView = 'workload.view';
  static const workloadManage = 'workload.manage';
  static const securityManage = 'security.manage';

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
    dashboardManage,
    dataManage,
    webhookManage,
    formManage,
    goalCreate,
    goalManage,
    templateCreate,
    templateManage,
    workloadView,
    workloadManage,
    securityManage,
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
String roleErrorMessage(Object error, [AppLocalizations? l10n]) {
  final t = l10n ?? lookupAppLocalizations(const Locale('en'));
  if (error is! RoleException) return t.grpLGeneric;
  return switch (error.failure) {
    RoleFailure.builtin => t.grpLRoleBuiltin,
    RoleFailure.nameTaken => t.grpLRoleNameTaken,
    RoleFailure.ownerProtected => t.grpLOwnerNeeded,
    RoleFailure.denied => error.detail ?? t.grpLNoPerm,
    RoleFailure.forbidden => t.grpLNoPermDo,
    RoleFailure.invalid => error.detail ?? t.grpLCheckValues,
    RoleFailure.notFound => t.grpLRoleGone,
    RoleFailure.conflict => t.grpLRoleConflict,
    RoleFailure.network => t.grpLNetCheck,
    RoleFailure.other => t.grpLGeneric,
  };
}
