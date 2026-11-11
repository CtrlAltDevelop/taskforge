// This is a generated file - do not edit.
//
// Generated from infrastructure/sync/grpc/sync.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class SyncEntry extends $pb.GeneratedMessage {
  factory SyncEntry({
    $core.String? cursor,
    $core.String? type,
    $core.String? projectId,
    $core.String? entityId,
    $core.int? version,
    $core.String? actor,
    $core.String? at,
  }) {
    final result = SyncEntry._();
    if (cursor != null) result.cursor = cursor;
    if (type != null) result.type = type;
    if (projectId != null) result.projectId = projectId;
    if (entityId != null) result.entityId = entityId;
    if (version != null) result.version = version;
    if (actor != null) result.actor = actor;
    if (at != null) result.at = at;
    return result;
  }

  SyncEntry._();

  factory SyncEntry.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SyncEntry()..mergeFromBuffer(data, registry);
  factory SyncEntry.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SyncEntry()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SyncEntry',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.sync'),
      createEmptyInstance: SyncEntry.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'cursor')
    ..aOS(2, _omitFieldNames ? '' : 'type')
    ..aOS(3, _omitFieldNames ? '' : 'projectId')
    ..aOS(4, _omitFieldNames ? '' : 'entityId')
    ..aI(5, _omitFieldNames ? '' : 'version')
    ..aOS(6, _omitFieldNames ? '' : 'actor')
    ..aOS(7, _omitFieldNames ? '' : 'at')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SyncEntry clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SyncEntry copyWith(void Function(SyncEntry) updates) =>
      super.copyWith((message) => updates(message as SyncEntry)) as SyncEntry;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SyncEntry() / SyncEntry.new instead')
  static SyncEntry create() => SyncEntry._();
  static $pb.GeneratedMessage $_createMessage() => SyncEntry._();
  @$core.override
  SyncEntry createEmptyInstance() => SyncEntry._();
  @$core.pragma('dart2js:noInline')
  static SyncEntry getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SyncEntry>(SyncEntry.$_createMessage);
  static SyncEntry? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get cursor => $_getSZ(0);
  @$pb.TagNumber(1)
  set cursor($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCursor() => $_has(0);
  @$pb.TagNumber(1)
  void clearCursor() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get type => $_getSZ(1);
  @$pb.TagNumber(2)
  set type($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasType() => $_has(1);
  @$pb.TagNumber(2)
  void clearType() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get projectId => $_getSZ(2);
  @$pb.TagNumber(3)
  set projectId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasProjectId() => $_has(2);
  @$pb.TagNumber(3)
  void clearProjectId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get entityId => $_getSZ(3);
  @$pb.TagNumber(4)
  set entityId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasEntityId() => $_has(3);
  @$pb.TagNumber(4)
  void clearEntityId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get version => $_getIZ(4);
  @$pb.TagNumber(5)
  set version($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasVersion() => $_has(4);
  @$pb.TagNumber(5)
  void clearVersion() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get actor => $_getSZ(5);
  @$pb.TagNumber(6)
  set actor($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasActor() => $_has(5);
  @$pb.TagNumber(6)
  void clearActor() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get at => $_getSZ(6);
  @$pb.TagNumber(7)
  set at($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasAt() => $_has(6);
  @$pb.TagNumber(7)
  void clearAt() => $_clearField(7);
}

class SyncHead extends $pb.GeneratedMessage {
  factory SyncHead({
    $core.String? cursor,
  }) {
    final result = SyncHead._();
    if (cursor != null) result.cursor = cursor;
    return result;
  }

  SyncHead._();

  factory SyncHead.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SyncHead()..mergeFromBuffer(data, registry);
  factory SyncHead.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SyncHead()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SyncHead',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.sync'),
      createEmptyInstance: SyncHead.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'cursor')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SyncHead clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SyncHead copyWith(void Function(SyncHead) updates) =>
      super.copyWith((message) => updates(message as SyncHead)) as SyncHead;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SyncHead() / SyncHead.new instead')
  static SyncHead create() => SyncHead._();
  static $pb.GeneratedMessage $_createMessage() => SyncHead._();
  @$core.override
  SyncHead createEmptyInstance() => SyncHead._();
  @$core.pragma('dart2js:noInline')
  static SyncHead getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SyncHead>(SyncHead.$_createMessage);
  static SyncHead? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get cursor => $_getSZ(0);
  @$pb.TagNumber(1)
  set cursor($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCursor() => $_has(0);
  @$pb.TagNumber(1)
  void clearCursor() => $_clearField(1);
}

class SyncHeadRequest extends $pb.GeneratedMessage {
  factory SyncHeadRequest({
    $core.String? workspaceId,
  }) {
    final result = SyncHeadRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    return result;
  }

  SyncHeadRequest._();

  factory SyncHeadRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SyncHeadRequest()..mergeFromBuffer(data, registry);
  factory SyncHeadRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SyncHeadRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SyncHeadRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.sync'),
      createEmptyInstance: SyncHeadRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SyncHeadRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SyncHeadRequest copyWith(void Function(SyncHeadRequest) updates) =>
      super.copyWith((message) => updates(message as SyncHeadRequest))
          as SyncHeadRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SyncHeadRequest() / SyncHeadRequest.new instead')
  static SyncHeadRequest create() => SyncHeadRequest._();
  static $pb.GeneratedMessage $_createMessage() => SyncHeadRequest._();
  @$core.override
  SyncHeadRequest createEmptyInstance() => SyncHeadRequest._();
  @$core.pragma('dart2js:noInline')
  static SyncHeadRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SyncHeadRequest>(
          SyncHeadRequest.$_createMessage);
  static SyncHeadRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);
}

class SyncSinceRequest extends $pb.GeneratedMessage {
  factory SyncSinceRequest({
    $core.String? workspaceId,
    $core.String? cursor,
    $core.int? limit,
    $core.int? overlap,
  }) {
    final result = SyncSinceRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (cursor != null) result.cursor = cursor;
    if (limit != null) result.limit = limit;
    if (overlap != null) result.overlap = overlap;
    return result;
  }

  SyncSinceRequest._();

  factory SyncSinceRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SyncSinceRequest()..mergeFromBuffer(data, registry);
  factory SyncSinceRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SyncSinceRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SyncSinceRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.sync'),
      createEmptyInstance: SyncSinceRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'cursor')
    ..aI(3, _omitFieldNames ? '' : 'limit')
    ..aI(4, _omitFieldNames ? '' : 'overlap')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SyncSinceRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SyncSinceRequest copyWith(void Function(SyncSinceRequest) updates) =>
      super.copyWith((message) => updates(message as SyncSinceRequest))
          as SyncSinceRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SyncSinceRequest() / SyncSinceRequest.new instead')
  static SyncSinceRequest create() => SyncSinceRequest._();
  static $pb.GeneratedMessage $_createMessage() => SyncSinceRequest._();
  @$core.override
  SyncSinceRequest createEmptyInstance() => SyncSinceRequest._();
  @$core.pragma('dart2js:noInline')
  static SyncSinceRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SyncSinceRequest>(
          SyncSinceRequest.$_createMessage);
  static SyncSinceRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get cursor => $_getSZ(1);
  @$pb.TagNumber(2)
  set cursor($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCursor() => $_has(1);
  @$pb.TagNumber(2)
  void clearCursor() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get limit => $_getIZ(2);
  @$pb.TagNumber(3)
  set limit($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasLimit() => $_has(2);
  @$pb.TagNumber(3)
  void clearLimit() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get overlap => $_getIZ(3);
  @$pb.TagNumber(4)
  set overlap($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasOverlap() => $_has(3);
  @$pb.TagNumber(4)
  void clearOverlap() => $_clearField(4);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
