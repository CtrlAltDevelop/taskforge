// This is a generated file - do not edit.
//
// Generated from infrastructure/workspaces/grpc/workspaces.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class Workspace extends $pb.GeneratedMessage {
  factory Workspace({
    $core.String? id,
    $core.String? name,
    $core.String? slug,
    $core.String? logo,
    $core.String? createdBy,
    $core.String? createdAt,
    $core.String? deletedAt,
    $core.int? version,
    $core.bool? isOwner,
  }) {
    final result = Workspace._();
    if (id != null) result.id = id;
    if (name != null) result.name = name;
    if (slug != null) result.slug = slug;
    if (logo != null) result.logo = logo;
    if (createdBy != null) result.createdBy = createdBy;
    if (createdAt != null) result.createdAt = createdAt;
    if (deletedAt != null) result.deletedAt = deletedAt;
    if (version != null) result.version = version;
    if (isOwner != null) result.isOwner = isOwner;
    return result;
  }

  Workspace._();

  factory Workspace.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Workspace()..mergeFromBuffer(data, registry);
  factory Workspace.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Workspace()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Workspace',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.workspaces'),
      createEmptyInstance: Workspace.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOS(3, _omitFieldNames ? '' : 'slug')
    ..aOS(4, _omitFieldNames ? '' : 'logo')
    ..aOS(5, _omitFieldNames ? '' : 'createdBy')
    ..aOS(6, _omitFieldNames ? '' : 'createdAt')
    ..aOS(7, _omitFieldNames ? '' : 'deletedAt')
    ..aI(8, _omitFieldNames ? '' : 'version')
    ..aOB(9, _omitFieldNames ? '' : 'isOwner')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Workspace clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Workspace copyWith(void Function(Workspace) updates) =>
      super.copyWith((message) => updates(message as Workspace)) as Workspace;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Workspace() / Workspace.new instead')
  static Workspace create() => Workspace._();
  static $pb.GeneratedMessage $_createMessage() => Workspace._();
  @$core.override
  Workspace createEmptyInstance() => Workspace._();
  @$core.pragma('dart2js:noInline')
  static Workspace getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Workspace>(Workspace.$_createMessage);
  static Workspace? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get slug => $_getSZ(2);
  @$pb.TagNumber(3)
  set slug($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSlug() => $_has(2);
  @$pb.TagNumber(3)
  void clearSlug() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get logo => $_getSZ(3);
  @$pb.TagNumber(4)
  set logo($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasLogo() => $_has(3);
  @$pb.TagNumber(4)
  void clearLogo() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get createdBy => $_getSZ(4);
  @$pb.TagNumber(5)
  set createdBy($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasCreatedBy() => $_has(4);
  @$pb.TagNumber(5)
  void clearCreatedBy() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get createdAt => $_getSZ(5);
  @$pb.TagNumber(6)
  set createdAt($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasCreatedAt() => $_has(5);
  @$pb.TagNumber(6)
  void clearCreatedAt() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get deletedAt => $_getSZ(6);
  @$pb.TagNumber(7)
  set deletedAt($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasDeletedAt() => $_has(6);
  @$pb.TagNumber(7)
  void clearDeletedAt() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.int get version => $_getIZ(7);
  @$pb.TagNumber(8)
  set version($core.int value) => $_setSignedInt32(7, value);
  @$pb.TagNumber(8)
  $core.bool hasVersion() => $_has(7);
  @$pb.TagNumber(8)
  void clearVersion() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.bool get isOwner => $_getBF(8);
  @$pb.TagNumber(9)
  set isOwner($core.bool value) => $_setBool(8, value);
  @$pb.TagNumber(9)
  $core.bool hasIsOwner() => $_has(8);
  @$pb.TagNumber(9)
  void clearIsOwner() => $_clearField(9);
}

class WorkspaceCreateRequest extends $pb.GeneratedMessage {
  factory WorkspaceCreateRequest({
    $core.String? name,
    $core.String? slug,
  }) {
    final result = WorkspaceCreateRequest._();
    if (name != null) result.name = name;
    if (slug != null) result.slug = slug;
    return result;
  }

  WorkspaceCreateRequest._();

  factory WorkspaceCreateRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WorkspaceCreateRequest()..mergeFromBuffer(data, registry);
  factory WorkspaceCreateRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WorkspaceCreateRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WorkspaceCreateRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.workspaces'),
      createEmptyInstance: WorkspaceCreateRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aOS(2, _omitFieldNames ? '' : 'slug')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WorkspaceCreateRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WorkspaceCreateRequest copyWith(
          void Function(WorkspaceCreateRequest) updates) =>
      super.copyWith((message) => updates(message as WorkspaceCreateRequest))
          as WorkspaceCreateRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use WorkspaceCreateRequest() / WorkspaceCreateRequest.new instead')
  static WorkspaceCreateRequest create() => WorkspaceCreateRequest._();
  static $pb.GeneratedMessage $_createMessage() => WorkspaceCreateRequest._();
  @$core.override
  WorkspaceCreateRequest createEmptyInstance() => WorkspaceCreateRequest._();
  @$core.pragma('dart2js:noInline')
  static WorkspaceCreateRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WorkspaceCreateRequest>(
          WorkspaceCreateRequest.$_createMessage);
  static WorkspaceCreateRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get slug => $_getSZ(1);
  @$pb.TagNumber(2)
  set slug($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSlug() => $_has(1);
  @$pb.TagNumber(2)
  void clearSlug() => $_clearField(2);
}

class WorkspaceDeleteRequest extends $pb.GeneratedMessage {
  factory WorkspaceDeleteRequest({
    $core.String? id,
    $core.String? confirmation,
  }) {
    final result = WorkspaceDeleteRequest._();
    if (id != null) result.id = id;
    if (confirmation != null) result.confirmation = confirmation;
    return result;
  }

  WorkspaceDeleteRequest._();

  factory WorkspaceDeleteRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WorkspaceDeleteRequest()..mergeFromBuffer(data, registry);
  factory WorkspaceDeleteRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WorkspaceDeleteRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WorkspaceDeleteRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.workspaces'),
      createEmptyInstance: WorkspaceDeleteRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'confirmation')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WorkspaceDeleteRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WorkspaceDeleteRequest copyWith(
          void Function(WorkspaceDeleteRequest) updates) =>
      super.copyWith((message) => updates(message as WorkspaceDeleteRequest))
          as WorkspaceDeleteRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use WorkspaceDeleteRequest() / WorkspaceDeleteRequest.new instead')
  static WorkspaceDeleteRequest create() => WorkspaceDeleteRequest._();
  static $pb.GeneratedMessage $_createMessage() => WorkspaceDeleteRequest._();
  @$core.override
  WorkspaceDeleteRequest createEmptyInstance() => WorkspaceDeleteRequest._();
  @$core.pragma('dart2js:noInline')
  static WorkspaceDeleteRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WorkspaceDeleteRequest>(
          WorkspaceDeleteRequest.$_createMessage);
  static WorkspaceDeleteRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get confirmation => $_getSZ(1);
  @$pb.TagNumber(2)
  set confirmation($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasConfirmation() => $_has(1);
  @$pb.TagNumber(2)
  void clearConfirmation() => $_clearField(2);
}

class WorkspaceList extends $pb.GeneratedMessage {
  factory WorkspaceList({
    $core.Iterable<Workspace>? workspaces,
  }) {
    final result = WorkspaceList._();
    if (workspaces != null) result.workspaces.addAll(workspaces);
    return result;
  }

  WorkspaceList._();

  factory WorkspaceList.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WorkspaceList()..mergeFromBuffer(data, registry);
  factory WorkspaceList.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WorkspaceList()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WorkspaceList',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.workspaces'),
      createEmptyInstance: WorkspaceList.$_createMessage)
    ..pPM<Workspace>(1, _omitFieldNames ? '' : 'workspaces',
        subBuilder: Workspace.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WorkspaceList clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WorkspaceList copyWith(void Function(WorkspaceList) updates) =>
      super.copyWith((message) => updates(message as WorkspaceList))
          as WorkspaceList;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use WorkspaceList() / WorkspaceList.new instead')
  static WorkspaceList create() => WorkspaceList._();
  static $pb.GeneratedMessage $_createMessage() => WorkspaceList._();
  @$core.override
  WorkspaceList createEmptyInstance() => WorkspaceList._();
  @$core.pragma('dart2js:noInline')
  static WorkspaceList getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<WorkspaceList>(
          WorkspaceList.$_createMessage);
  static WorkspaceList? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Workspace> get workspaces => $_getList(0);
}

class WorkspaceRestoreRequest extends $pb.GeneratedMessage {
  factory WorkspaceRestoreRequest({
    $core.String? id,
  }) {
    final result = WorkspaceRestoreRequest._();
    if (id != null) result.id = id;
    return result;
  }

  WorkspaceRestoreRequest._();

  factory WorkspaceRestoreRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WorkspaceRestoreRequest()..mergeFromBuffer(data, registry);
  factory WorkspaceRestoreRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WorkspaceRestoreRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WorkspaceRestoreRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.workspaces'),
      createEmptyInstance: WorkspaceRestoreRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WorkspaceRestoreRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WorkspaceRestoreRequest copyWith(
          void Function(WorkspaceRestoreRequest) updates) =>
      super.copyWith((message) => updates(message as WorkspaceRestoreRequest))
          as WorkspaceRestoreRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use WorkspaceRestoreRequest() / WorkspaceRestoreRequest.new instead')
  static WorkspaceRestoreRequest create() => WorkspaceRestoreRequest._();
  static $pb.GeneratedMessage $_createMessage() => WorkspaceRestoreRequest._();
  @$core.override
  WorkspaceRestoreRequest createEmptyInstance() => WorkspaceRestoreRequest._();
  @$core.pragma('dart2js:noInline')
  static WorkspaceRestoreRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WorkspaceRestoreRequest>(
          WorkspaceRestoreRequest.$_createMessage);
  static WorkspaceRestoreRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class WorkspaceUpdateRequest extends $pb.GeneratedMessage {
  factory WorkspaceUpdateRequest({
    $core.String? id,
    $core.int? expectedVersion,
    $core.String? name,
    $core.String? slug,
  }) {
    final result = WorkspaceUpdateRequest._();
    if (id != null) result.id = id;
    if (expectedVersion != null) result.expectedVersion = expectedVersion;
    if (name != null) result.name = name;
    if (slug != null) result.slug = slug;
    return result;
  }

  WorkspaceUpdateRequest._();

  factory WorkspaceUpdateRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WorkspaceUpdateRequest()..mergeFromBuffer(data, registry);
  factory WorkspaceUpdateRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WorkspaceUpdateRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WorkspaceUpdateRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.workspaces'),
      createEmptyInstance: WorkspaceUpdateRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aI(2, _omitFieldNames ? '' : 'expectedVersion')
    ..aOS(3, _omitFieldNames ? '' : 'name')
    ..aOS(4, _omitFieldNames ? '' : 'slug')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WorkspaceUpdateRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WorkspaceUpdateRequest copyWith(
          void Function(WorkspaceUpdateRequest) updates) =>
      super.copyWith((message) => updates(message as WorkspaceUpdateRequest))
          as WorkspaceUpdateRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use WorkspaceUpdateRequest() / WorkspaceUpdateRequest.new instead')
  static WorkspaceUpdateRequest create() => WorkspaceUpdateRequest._();
  static $pb.GeneratedMessage $_createMessage() => WorkspaceUpdateRequest._();
  @$core.override
  WorkspaceUpdateRequest createEmptyInstance() => WorkspaceUpdateRequest._();
  @$core.pragma('dart2js:noInline')
  static WorkspaceUpdateRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WorkspaceUpdateRequest>(
          WorkspaceUpdateRequest.$_createMessage);
  static WorkspaceUpdateRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get expectedVersion => $_getIZ(1);
  @$pb.TagNumber(2)
  set expectedVersion($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasExpectedVersion() => $_has(1);
  @$pb.TagNumber(2)
  void clearExpectedVersion() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get name => $_getSZ(2);
  @$pb.TagNumber(3)
  set name($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasName() => $_has(2);
  @$pb.TagNumber(3)
  void clearName() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get slug => $_getSZ(3);
  @$pb.TagNumber(4)
  set slug($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSlug() => $_has(3);
  @$pb.TagNumber(4)
  void clearSlug() => $_clearField(4);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
