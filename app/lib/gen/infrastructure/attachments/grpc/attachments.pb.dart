// This is a generated file - do not edit.
//
// Generated from infrastructure/attachments/grpc/attachments.proto.

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

class Attachment extends $pb.GeneratedMessage {
  factory Attachment({
    $core.String? id,
    $core.String? taskId,
    $core.String? commentId,
    $core.String? uploaderId,
    $core.String? filename,
    $core.String? mime,
    $fixnum.Int64? size,
    $core.bool? hasThumb,
    $core.String? createdAt,
  }) {
    final result = Attachment._();
    if (id != null) result.id = id;
    if (taskId != null) result.taskId = taskId;
    if (commentId != null) result.commentId = commentId;
    if (uploaderId != null) result.uploaderId = uploaderId;
    if (filename != null) result.filename = filename;
    if (mime != null) result.mime = mime;
    if (size != null) result.size = size;
    if (hasThumb != null) result.hasThumb = hasThumb;
    if (createdAt != null) result.createdAt = createdAt;
    return result;
  }

  Attachment._();

  factory Attachment.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Attachment()..mergeFromBuffer(data, registry);
  factory Attachment.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Attachment()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Attachment',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.attachments'),
      createEmptyInstance: Attachment.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'taskId')
    ..aOS(3, _omitFieldNames ? '' : 'commentId')
    ..aOS(4, _omitFieldNames ? '' : 'uploaderId')
    ..aOS(5, _omitFieldNames ? '' : 'filename')
    ..aOS(6, _omitFieldNames ? '' : 'mime')
    ..aInt64(7, _omitFieldNames ? '' : 'size')
    ..aOB(8, _omitFieldNames ? '' : 'hasThumb')
    ..aOS(9, _omitFieldNames ? '' : 'createdAt')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Attachment clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Attachment copyWith(void Function(Attachment) updates) =>
      super.copyWith((message) => updates(message as Attachment)) as Attachment;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Attachment() / Attachment.new instead')
  static Attachment create() => Attachment._();
  static $pb.GeneratedMessage $_createMessage() => Attachment._();
  @$core.override
  Attachment createEmptyInstance() => Attachment._();
  @$core.pragma('dart2js:noInline')
  static Attachment getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Attachment>(Attachment.$_createMessage);
  static Attachment? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get taskId => $_getSZ(1);
  @$pb.TagNumber(2)
  set taskId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTaskId() => $_has(1);
  @$pb.TagNumber(2)
  void clearTaskId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get commentId => $_getSZ(2);
  @$pb.TagNumber(3)
  set commentId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasCommentId() => $_has(2);
  @$pb.TagNumber(3)
  void clearCommentId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get uploaderId => $_getSZ(3);
  @$pb.TagNumber(4)
  set uploaderId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasUploaderId() => $_has(3);
  @$pb.TagNumber(4)
  void clearUploaderId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get filename => $_getSZ(4);
  @$pb.TagNumber(5)
  set filename($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasFilename() => $_has(4);
  @$pb.TagNumber(5)
  void clearFilename() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get mime => $_getSZ(5);
  @$pb.TagNumber(6)
  set mime($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasMime() => $_has(5);
  @$pb.TagNumber(6)
  void clearMime() => $_clearField(6);

  @$pb.TagNumber(7)
  $fixnum.Int64 get size => $_getI64(6);
  @$pb.TagNumber(7)
  set size($fixnum.Int64 value) => $_setInt64(6, value);
  @$pb.TagNumber(7)
  $core.bool hasSize() => $_has(6);
  @$pb.TagNumber(7)
  void clearSize() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.bool get hasThumb => $_getBF(7);
  @$pb.TagNumber(8)
  set hasThumb($core.bool value) => $_setBool(7, value);
  @$pb.TagNumber(8)
  $core.bool hasHasThumb() => $_has(7);
  @$pb.TagNumber(8)
  void clearHasThumb() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get createdAt => $_getSZ(8);
  @$pb.TagNumber(9)
  set createdAt($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasCreatedAt() => $_has(8);
  @$pb.TagNumber(9)
  void clearCreatedAt() => $_clearField(9);
}

class AttachmentDeleteRequest extends $pb.GeneratedMessage {
  factory AttachmentDeleteRequest({
    $core.String? workspaceId,
    $core.String? projectId,
    $core.String? id,
  }) {
    final result = AttachmentDeleteRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (projectId != null) result.projectId = projectId;
    if (id != null) result.id = id;
    return result;
  }

  AttachmentDeleteRequest._();

  factory AttachmentDeleteRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AttachmentDeleteRequest()..mergeFromBuffer(data, registry);
  factory AttachmentDeleteRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AttachmentDeleteRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AttachmentDeleteRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.attachments'),
      createEmptyInstance: AttachmentDeleteRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..aOS(3, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AttachmentDeleteRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AttachmentDeleteRequest copyWith(
          void Function(AttachmentDeleteRequest) updates) =>
      super.copyWith((message) => updates(message as AttachmentDeleteRequest))
          as AttachmentDeleteRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use AttachmentDeleteRequest() / AttachmentDeleteRequest.new instead')
  static AttachmentDeleteRequest create() => AttachmentDeleteRequest._();
  static $pb.GeneratedMessage $_createMessage() => AttachmentDeleteRequest._();
  @$core.override
  AttachmentDeleteRequest createEmptyInstance() => AttachmentDeleteRequest._();
  @$core.pragma('dart2js:noInline')
  static AttachmentDeleteRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AttachmentDeleteRequest>(
          AttachmentDeleteRequest.$_createMessage);
  static AttachmentDeleteRequest? _defaultInstance;

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
  $core.String get id => $_getSZ(2);
  @$pb.TagNumber(3)
  set id($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasId() => $_has(2);
  @$pb.TagNumber(3)
  void clearId() => $_clearField(3);
}

class AttachmentList extends $pb.GeneratedMessage {
  factory AttachmentList({
    $core.Iterable<Attachment>? attachments,
  }) {
    final result = AttachmentList._();
    if (attachments != null) result.attachments.addAll(attachments);
    return result;
  }

  AttachmentList._();

  factory AttachmentList.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AttachmentList()..mergeFromBuffer(data, registry);
  factory AttachmentList.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AttachmentList()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AttachmentList',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.attachments'),
      createEmptyInstance: AttachmentList.$_createMessage)
    ..pPM<Attachment>(1, _omitFieldNames ? '' : 'attachments',
        subBuilder: Attachment.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AttachmentList clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AttachmentList copyWith(void Function(AttachmentList) updates) =>
      super.copyWith((message) => updates(message as AttachmentList))
          as AttachmentList;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use AttachmentList() / AttachmentList.new instead')
  static AttachmentList create() => AttachmentList._();
  static $pb.GeneratedMessage $_createMessage() => AttachmentList._();
  @$core.override
  AttachmentList createEmptyInstance() => AttachmentList._();
  @$core.pragma('dart2js:noInline')
  static AttachmentList getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AttachmentList>(
          AttachmentList.$_createMessage);
  static AttachmentList? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Attachment> get attachments => $_getList(0);
}

class AttachmentListRequest extends $pb.GeneratedMessage {
  factory AttachmentListRequest({
    $core.String? workspaceId,
    $core.String? projectId,
    $core.String? taskId,
  }) {
    final result = AttachmentListRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (projectId != null) result.projectId = projectId;
    if (taskId != null) result.taskId = taskId;
    return result;
  }

  AttachmentListRequest._();

  factory AttachmentListRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AttachmentListRequest()..mergeFromBuffer(data, registry);
  factory AttachmentListRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AttachmentListRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AttachmentListRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.attachments'),
      createEmptyInstance: AttachmentListRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..aOS(3, _omitFieldNames ? '' : 'taskId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AttachmentListRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AttachmentListRequest copyWith(
          void Function(AttachmentListRequest) updates) =>
      super.copyWith((message) => updates(message as AttachmentListRequest))
          as AttachmentListRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use AttachmentListRequest() / AttachmentListRequest.new instead')
  static AttachmentListRequest create() => AttachmentListRequest._();
  static $pb.GeneratedMessage $_createMessage() => AttachmentListRequest._();
  @$core.override
  AttachmentListRequest createEmptyInstance() => AttachmentListRequest._();
  @$core.pragma('dart2js:noInline')
  static AttachmentListRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AttachmentListRequest>(
          AttachmentListRequest.$_createMessage);
  static AttachmentListRequest? _defaultInstance;

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
}

class StorageUsage extends $pb.GeneratedMessage {
  factory StorageUsage({
    $fixnum.Int64? usedBytes,
    $fixnum.Int64? quotaBytes,
    $core.int? fileCount,
    $fixnum.Int64? maxFileBytes,
  }) {
    final result = StorageUsage._();
    if (usedBytes != null) result.usedBytes = usedBytes;
    if (quotaBytes != null) result.quotaBytes = quotaBytes;
    if (fileCount != null) result.fileCount = fileCount;
    if (maxFileBytes != null) result.maxFileBytes = maxFileBytes;
    return result;
  }

  StorageUsage._();

  factory StorageUsage.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      StorageUsage()..mergeFromBuffer(data, registry);
  factory StorageUsage.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      StorageUsage()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'StorageUsage',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.attachments'),
      createEmptyInstance: StorageUsage.$_createMessage)
    ..aInt64(1, _omitFieldNames ? '' : 'usedBytes')
    ..aInt64(2, _omitFieldNames ? '' : 'quotaBytes')
    ..aI(3, _omitFieldNames ? '' : 'fileCount')
    ..aInt64(4, _omitFieldNames ? '' : 'maxFileBytes')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StorageUsage clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StorageUsage copyWith(void Function(StorageUsage) updates) =>
      super.copyWith((message) => updates(message as StorageUsage))
          as StorageUsage;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use StorageUsage() / StorageUsage.new instead')
  static StorageUsage create() => StorageUsage._();
  static $pb.GeneratedMessage $_createMessage() => StorageUsage._();
  @$core.override
  StorageUsage createEmptyInstance() => StorageUsage._();
  @$core.pragma('dart2js:noInline')
  static StorageUsage getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<StorageUsage>(
          StorageUsage.$_createMessage);
  static StorageUsage? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get usedBytes => $_getI64(0);
  @$pb.TagNumber(1)
  set usedBytes($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUsedBytes() => $_has(0);
  @$pb.TagNumber(1)
  void clearUsedBytes() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get quotaBytes => $_getI64(1);
  @$pb.TagNumber(2)
  set quotaBytes($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasQuotaBytes() => $_has(1);
  @$pb.TagNumber(2)
  void clearQuotaBytes() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get fileCount => $_getIZ(2);
  @$pb.TagNumber(3)
  set fileCount($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFileCount() => $_has(2);
  @$pb.TagNumber(3)
  void clearFileCount() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get maxFileBytes => $_getI64(3);
  @$pb.TagNumber(4)
  set maxFileBytes($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasMaxFileBytes() => $_has(3);
  @$pb.TagNumber(4)
  void clearMaxFileBytes() => $_clearField(4);
}

class UsageRequest extends $pb.GeneratedMessage {
  factory UsageRequest({
    $core.String? workspaceId,
  }) {
    final result = UsageRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    return result;
  }

  UsageRequest._();

  factory UsageRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UsageRequest()..mergeFromBuffer(data, registry);
  factory UsageRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UsageRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UsageRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.attachments'),
      createEmptyInstance: UsageRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UsageRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UsageRequest copyWith(void Function(UsageRequest) updates) =>
      super.copyWith((message) => updates(message as UsageRequest))
          as UsageRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use UsageRequest() / UsageRequest.new instead')
  static UsageRequest create() => UsageRequest._();
  static $pb.GeneratedMessage $_createMessage() => UsageRequest._();
  @$core.override
  UsageRequest createEmptyInstance() => UsageRequest._();
  @$core.pragma('dart2js:noInline')
  static UsageRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UsageRequest>(
          UsageRequest.$_createMessage);
  static UsageRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
