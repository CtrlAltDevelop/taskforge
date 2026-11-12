// This is a generated file - do not edit.
//
// Generated from infrastructure/audit/grpc/audit.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class ActivityForTaskRequest extends $pb.GeneratedMessage {
  factory ActivityForTaskRequest({
    $core.String? workspaceId,
    $core.String? projectId,
    $core.String? taskId,
    $fixnum.Int64? before,
    $core.int? limit,
  }) {
    final result = ActivityForTaskRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (projectId != null) result.projectId = projectId;
    if (taskId != null) result.taskId = taskId;
    if (before != null) result.before = before;
    if (limit != null) result.limit = limit;
    return result;
  }

  ActivityForTaskRequest._();

  factory ActivityForTaskRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ActivityForTaskRequest()..mergeFromBuffer(data, registry);
  factory ActivityForTaskRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ActivityForTaskRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ActivityForTaskRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.audit'),
      createEmptyInstance: ActivityForTaskRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..aOS(3, _omitFieldNames ? '' : 'taskId')
    ..aInt64(4, _omitFieldNames ? '' : 'before')
    ..aI(5, _omitFieldNames ? '' : 'limit')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ActivityForTaskRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ActivityForTaskRequest copyWith(
          void Function(ActivityForTaskRequest) updates) =>
      super.copyWith((message) => updates(message as ActivityForTaskRequest))
          as ActivityForTaskRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ActivityForTaskRequest() / ActivityForTaskRequest.new instead')
  static ActivityForTaskRequest create() => ActivityForTaskRequest._();
  static $pb.GeneratedMessage $_createMessage() => ActivityForTaskRequest._();
  @$core.override
  ActivityForTaskRequest createEmptyInstance() => ActivityForTaskRequest._();
  @$core.pragma('dart2js:noInline')
  static ActivityForTaskRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ActivityForTaskRequest>(
          ActivityForTaskRequest.$_createMessage);
  static ActivityForTaskRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get projectId => $_getSZ(1);
  @$pb.TagNumber(2)
  set projectId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasProjectId() => $_has(1);
  @$pb.TagNumber(2)
  void clearProjectId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get taskId => $_getSZ(2);
  @$pb.TagNumber(3)
  set taskId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTaskId() => $_has(2);
  @$pb.TagNumber(3)
  void clearTaskId() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get before => $_getI64(3);
  @$pb.TagNumber(4)
  set before($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasBefore() => $_has(3);
  @$pb.TagNumber(4)
  void clearBefore() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get limit => $_getIZ(4);
  @$pb.TagNumber(5)
  set limit($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasLimit() => $_has(4);
  @$pb.TagNumber(5)
  void clearLimit() => $_clearField(5);
}

class AuditEntry extends $pb.GeneratedMessage {
  factory AuditEntry({
    $fixnum.Int64? id,
    $core.String? at,
    $core.String? actor,
    $core.String? actorName,
    $core.String? actorType,
    $core.String? action,
    $core.String? targetType,
    $core.String? targetId,
    $core.String? projectId,
    $core.String? batchId,
    $core.String? ip,
    $core.String? userAgent,
    $core.String? changesJson,
  }) {
    final result = AuditEntry._();
    if (id != null) result.id = id;
    if (at != null) result.at = at;
    if (actor != null) result.actor = actor;
    if (actorName != null) result.actorName = actorName;
    if (actorType != null) result.actorType = actorType;
    if (action != null) result.action = action;
    if (targetType != null) result.targetType = targetType;
    if (targetId != null) result.targetId = targetId;
    if (projectId != null) result.projectId = projectId;
    if (batchId != null) result.batchId = batchId;
    if (ip != null) result.ip = ip;
    if (userAgent != null) result.userAgent = userAgent;
    if (changesJson != null) result.changesJson = changesJson;
    return result;
  }

  AuditEntry._();

  factory AuditEntry.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AuditEntry()..mergeFromBuffer(data, registry);
  factory AuditEntry.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AuditEntry()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AuditEntry',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.audit'),
      createEmptyInstance: AuditEntry.$_createMessage)
    ..aInt64(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'at')
    ..aOS(3, _omitFieldNames ? '' : 'actor')
    ..aOS(4, _omitFieldNames ? '' : 'actorName')
    ..aOS(5, _omitFieldNames ? '' : 'actorType')
    ..aOS(6, _omitFieldNames ? '' : 'action')
    ..aOS(7, _omitFieldNames ? '' : 'targetType')
    ..aOS(8, _omitFieldNames ? '' : 'targetId')
    ..aOS(9, _omitFieldNames ? '' : 'projectId')
    ..aOS(10, _omitFieldNames ? '' : 'batchId')
    ..aOS(11, _omitFieldNames ? '' : 'ip')
    ..aOS(12, _omitFieldNames ? '' : 'userAgent')
    ..aOS(13, _omitFieldNames ? '' : 'changesJson')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AuditEntry clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AuditEntry copyWith(void Function(AuditEntry) updates) =>
      super.copyWith((message) => updates(message as AuditEntry)) as AuditEntry;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use AuditEntry() / AuditEntry.new instead')
  static AuditEntry create() => AuditEntry._();
  static $pb.GeneratedMessage $_createMessage() => AuditEntry._();
  @$core.override
  AuditEntry createEmptyInstance() => AuditEntry._();
  @$core.pragma('dart2js:noInline')
  static AuditEntry getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AuditEntry>(AuditEntry.$_createMessage);
  static AuditEntry? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get at => $_getSZ(1);
  @$pb.TagNumber(2)
  set at($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAt() => $_has(1);
  @$pb.TagNumber(2)
  void clearAt() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get actor => $_getSZ(2);
  @$pb.TagNumber(3)
  set actor($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasActor() => $_has(2);
  @$pb.TagNumber(3)
  void clearActor() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get actorName => $_getSZ(3);
  @$pb.TagNumber(4)
  set actorName($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasActorName() => $_has(3);
  @$pb.TagNumber(4)
  void clearActorName() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get actorType => $_getSZ(4);
  @$pb.TagNumber(5)
  set actorType($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasActorType() => $_has(4);
  @$pb.TagNumber(5)
  void clearActorType() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get action => $_getSZ(5);
  @$pb.TagNumber(6)
  set action($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasAction() => $_has(5);
  @$pb.TagNumber(6)
  void clearAction() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get targetType => $_getSZ(6);
  @$pb.TagNumber(7)
  set targetType($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasTargetType() => $_has(6);
  @$pb.TagNumber(7)
  void clearTargetType() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get targetId => $_getSZ(7);
  @$pb.TagNumber(8)
  set targetId($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasTargetId() => $_has(7);
  @$pb.TagNumber(8)
  void clearTargetId() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get projectId => $_getSZ(8);
  @$pb.TagNumber(9)
  set projectId($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasProjectId() => $_has(8);
  @$pb.TagNumber(9)
  void clearProjectId() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get batchId => $_getSZ(9);
  @$pb.TagNumber(10)
  set batchId($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasBatchId() => $_has(9);
  @$pb.TagNumber(10)
  void clearBatchId() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.String get ip => $_getSZ(10);
  @$pb.TagNumber(11)
  set ip($core.String value) => $_setString(10, value);
  @$pb.TagNumber(11)
  $core.bool hasIp() => $_has(10);
  @$pb.TagNumber(11)
  void clearIp() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.String get userAgent => $_getSZ(11);
  @$pb.TagNumber(12)
  set userAgent($core.String value) => $_setString(11, value);
  @$pb.TagNumber(12)
  $core.bool hasUserAgent() => $_has(11);
  @$pb.TagNumber(12)
  void clearUserAgent() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.String get changesJson => $_getSZ(12);
  @$pb.TagNumber(13)
  set changesJson($core.String value) => $_setString(12, value);
  @$pb.TagNumber(13)
  $core.bool hasChangesJson() => $_has(12);
  @$pb.TagNumber(13)
  void clearChangesJson() => $_clearField(13);
}

class AuditExportChunk extends $pb.GeneratedMessage {
  factory AuditExportChunk({
    $core.String? csv,
  }) {
    final result = AuditExportChunk._();
    if (csv != null) result.csv = csv;
    return result;
  }

  AuditExportChunk._();

  factory AuditExportChunk.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AuditExportChunk()..mergeFromBuffer(data, registry);
  factory AuditExportChunk.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AuditExportChunk()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AuditExportChunk',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.audit'),
      createEmptyInstance: AuditExportChunk.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'csv')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AuditExportChunk clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AuditExportChunk copyWith(void Function(AuditExportChunk) updates) =>
      super.copyWith((message) => updates(message as AuditExportChunk))
          as AuditExportChunk;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use AuditExportChunk() / AuditExportChunk.new instead')
  static AuditExportChunk create() => AuditExportChunk._();
  static $pb.GeneratedMessage $_createMessage() => AuditExportChunk._();
  @$core.override
  AuditExportChunk createEmptyInstance() => AuditExportChunk._();
  @$core.pragma('dart2js:noInline')
  static AuditExportChunk getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AuditExportChunk>(
          AuditExportChunk.$_createMessage);
  static AuditExportChunk? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get csv => $_getSZ(0);
  @$pb.TagNumber(1)
  set csv($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCsv() => $_has(0);
  @$pb.TagNumber(1)
  void clearCsv() => $_clearField(1);
}

class AuditExportRequest extends $pb.GeneratedMessage {
  factory AuditExportRequest({
    $core.String? workspaceId,
    $core.String? actor,
    $core.String? action,
    $core.String? targetType,
    $core.String? targetId,
    $core.String? projectId,
    $core.String? since,
    $core.String? until,
  }) {
    final result = AuditExportRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (actor != null) result.actor = actor;
    if (action != null) result.action = action;
    if (targetType != null) result.targetType = targetType;
    if (targetId != null) result.targetId = targetId;
    if (projectId != null) result.projectId = projectId;
    if (since != null) result.since = since;
    if (until != null) result.until = until;
    return result;
  }

  AuditExportRequest._();

  factory AuditExportRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AuditExportRequest()..mergeFromBuffer(data, registry);
  factory AuditExportRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AuditExportRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AuditExportRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.audit'),
      createEmptyInstance: AuditExportRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'actor')
    ..aOS(3, _omitFieldNames ? '' : 'action')
    ..aOS(4, _omitFieldNames ? '' : 'targetType')
    ..aOS(5, _omitFieldNames ? '' : 'targetId')
    ..aOS(6, _omitFieldNames ? '' : 'projectId')
    ..aOS(7, _omitFieldNames ? '' : 'since')
    ..aOS(8, _omitFieldNames ? '' : 'until')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AuditExportRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AuditExportRequest copyWith(void Function(AuditExportRequest) updates) =>
      super.copyWith((message) => updates(message as AuditExportRequest))
          as AuditExportRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use AuditExportRequest() / AuditExportRequest.new instead')
  static AuditExportRequest create() => AuditExportRequest._();
  static $pb.GeneratedMessage $_createMessage() => AuditExportRequest._();
  @$core.override
  AuditExportRequest createEmptyInstance() => AuditExportRequest._();
  @$core.pragma('dart2js:noInline')
  static AuditExportRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AuditExportRequest>(
          AuditExportRequest.$_createMessage);
  static AuditExportRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get actor => $_getSZ(1);
  @$pb.TagNumber(2)
  set actor($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasActor() => $_has(1);
  @$pb.TagNumber(2)
  void clearActor() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get action => $_getSZ(2);
  @$pb.TagNumber(3)
  set action($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAction() => $_has(2);
  @$pb.TagNumber(3)
  void clearAction() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get targetType => $_getSZ(3);
  @$pb.TagNumber(4)
  set targetType($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasTargetType() => $_has(3);
  @$pb.TagNumber(4)
  void clearTargetType() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get targetId => $_getSZ(4);
  @$pb.TagNumber(5)
  set targetId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasTargetId() => $_has(4);
  @$pb.TagNumber(5)
  void clearTargetId() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get projectId => $_getSZ(5);
  @$pb.TagNumber(6)
  set projectId($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasProjectId() => $_has(5);
  @$pb.TagNumber(6)
  void clearProjectId() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get since => $_getSZ(6);
  @$pb.TagNumber(7)
  set since($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasSince() => $_has(6);
  @$pb.TagNumber(7)
  void clearSince() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get until => $_getSZ(7);
  @$pb.TagNumber(8)
  set until($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasUntil() => $_has(7);
  @$pb.TagNumber(8)
  void clearUntil() => $_clearField(8);
}

class AuditListRequest extends $pb.GeneratedMessage {
  factory AuditListRequest({
    $core.String? workspaceId,
    $core.String? actor,
    $core.String? action,
    $core.String? targetType,
    $core.String? targetId,
    $core.String? projectId,
    $core.String? since,
    $core.String? until,
    $fixnum.Int64? before,
    $core.int? limit,
  }) {
    final result = AuditListRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (actor != null) result.actor = actor;
    if (action != null) result.action = action;
    if (targetType != null) result.targetType = targetType;
    if (targetId != null) result.targetId = targetId;
    if (projectId != null) result.projectId = projectId;
    if (since != null) result.since = since;
    if (until != null) result.until = until;
    if (before != null) result.before = before;
    if (limit != null) result.limit = limit;
    return result;
  }

  AuditListRequest._();

  factory AuditListRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AuditListRequest()..mergeFromBuffer(data, registry);
  factory AuditListRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AuditListRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AuditListRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.audit'),
      createEmptyInstance: AuditListRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'actor')
    ..aOS(3, _omitFieldNames ? '' : 'action')
    ..aOS(4, _omitFieldNames ? '' : 'targetType')
    ..aOS(5, _omitFieldNames ? '' : 'targetId')
    ..aOS(6, _omitFieldNames ? '' : 'projectId')
    ..aOS(7, _omitFieldNames ? '' : 'since')
    ..aOS(8, _omitFieldNames ? '' : 'until')
    ..aInt64(9, _omitFieldNames ? '' : 'before')
    ..aI(10, _omitFieldNames ? '' : 'limit')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AuditListRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AuditListRequest copyWith(void Function(AuditListRequest) updates) =>
      super.copyWith((message) => updates(message as AuditListRequest))
          as AuditListRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use AuditListRequest() / AuditListRequest.new instead')
  static AuditListRequest create() => AuditListRequest._();
  static $pb.GeneratedMessage $_createMessage() => AuditListRequest._();
  @$core.override
  AuditListRequest createEmptyInstance() => AuditListRequest._();
  @$core.pragma('dart2js:noInline')
  static AuditListRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AuditListRequest>(
          AuditListRequest.$_createMessage);
  static AuditListRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get actor => $_getSZ(1);
  @$pb.TagNumber(2)
  set actor($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasActor() => $_has(1);
  @$pb.TagNumber(2)
  void clearActor() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get action => $_getSZ(2);
  @$pb.TagNumber(3)
  set action($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAction() => $_has(2);
  @$pb.TagNumber(3)
  void clearAction() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get targetType => $_getSZ(3);
  @$pb.TagNumber(4)
  set targetType($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasTargetType() => $_has(3);
  @$pb.TagNumber(4)
  void clearTargetType() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get targetId => $_getSZ(4);
  @$pb.TagNumber(5)
  set targetId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasTargetId() => $_has(4);
  @$pb.TagNumber(5)
  void clearTargetId() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get projectId => $_getSZ(5);
  @$pb.TagNumber(6)
  set projectId($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasProjectId() => $_has(5);
  @$pb.TagNumber(6)
  void clearProjectId() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get since => $_getSZ(6);
  @$pb.TagNumber(7)
  set since($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasSince() => $_has(6);
  @$pb.TagNumber(7)
  void clearSince() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get until => $_getSZ(7);
  @$pb.TagNumber(8)
  set until($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasUntil() => $_has(7);
  @$pb.TagNumber(8)
  void clearUntil() => $_clearField(8);

  @$pb.TagNumber(9)
  $fixnum.Int64 get before => $_getI64(8);
  @$pb.TagNumber(9)
  set before($fixnum.Int64 value) => $_setInt64(8, value);
  @$pb.TagNumber(9)
  $core.bool hasBefore() => $_has(8);
  @$pb.TagNumber(9)
  void clearBefore() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.int get limit => $_getIZ(9);
  @$pb.TagNumber(10)
  set limit($core.int value) => $_setSignedInt32(9, value);
  @$pb.TagNumber(10)
  $core.bool hasLimit() => $_has(9);
  @$pb.TagNumber(10)
  void clearLimit() => $_clearField(10);
}

class AuditPage extends $pb.GeneratedMessage {
  factory AuditPage({
    $core.Iterable<AuditEntry>? entries,
    $core.Iterable<Label>? labels,
    $fixnum.Int64? nextBefore,
  }) {
    final result = AuditPage._();
    if (entries != null) result.entries.addAll(entries);
    if (labels != null) result.labels.addAll(labels);
    if (nextBefore != null) result.nextBefore = nextBefore;
    return result;
  }

  AuditPage._();

  factory AuditPage.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AuditPage()..mergeFromBuffer(data, registry);
  factory AuditPage.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AuditPage()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AuditPage',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.audit'),
      createEmptyInstance: AuditPage.$_createMessage)
    ..pPM<AuditEntry>(1, _omitFieldNames ? '' : 'entries',
        subBuilder: AuditEntry.$_createMessage)
    ..pPM<Label>(2, _omitFieldNames ? '' : 'labels',
        subBuilder: Label.$_createMessage)
    ..aInt64(3, _omitFieldNames ? '' : 'nextBefore')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AuditPage clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AuditPage copyWith(void Function(AuditPage) updates) =>
      super.copyWith((message) => updates(message as AuditPage)) as AuditPage;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use AuditPage() / AuditPage.new instead')
  static AuditPage create() => AuditPage._();
  static $pb.GeneratedMessage $_createMessage() => AuditPage._();
  @$core.override
  AuditPage createEmptyInstance() => AuditPage._();
  @$core.pragma('dart2js:noInline')
  static AuditPage getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AuditPage>(AuditPage.$_createMessage);
  static AuditPage? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<AuditEntry> get entries => $_getList(0);

  @$pb.TagNumber(2)
  $pb.PbList<Label> get labels => $_getList(1);

  @$pb.TagNumber(3)
  $fixnum.Int64 get nextBefore => $_getI64(2);
  @$pb.TagNumber(3)
  set nextBefore($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasNextBefore() => $_has(2);
  @$pb.TagNumber(3)
  void clearNextBefore() => $_clearField(3);
}

class Label extends $pb.GeneratedMessage {
  factory Label({
    $core.String? id,
    $core.String? name,
  }) {
    final result = Label._();
    if (id != null) result.id = id;
    if (name != null) result.name = name;
    return result;
  }

  Label._();

  factory Label.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Label()..mergeFromBuffer(data, registry);
  factory Label.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Label()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Label',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.audit'),
      createEmptyInstance: Label.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Label clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Label copyWith(void Function(Label) updates) =>
      super.copyWith((message) => updates(message as Label)) as Label;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Label() / Label.new instead')
  static Label create() => Label._();
  static $pb.GeneratedMessage $_createMessage() => Label._();
  @$core.override
  Label createEmptyInstance() => Label._();
  @$core.pragma('dart2js:noInline')
  static Label getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Label>(Label.$_createMessage);
  static Label? _defaultInstance;

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
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
