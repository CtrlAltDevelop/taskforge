// This is a generated file - do not edit.
//
// Generated from infrastructure/docs/grpc/wikidocs.proto.

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

class DocAnswer extends $pb.GeneratedMessage {
  factory DocAnswer({
    DocNode? doc,
    $core.int? version,
    $core.int? schemaVersion,
    $core.String? blocksJson,
    $core.String? updatedBy,
    $core.Iterable<Editor>? editing,
    $core.Iterable<TaskCard>? cards,
    $core.bool? canEdit,
    $core.bool? canManage,
    $core.Iterable<$core.String>? accessUserIds,
  }) {
    final result = DocAnswer._();
    if (doc != null) result.doc = doc;
    if (version != null) result.version = version;
    if (schemaVersion != null) result.schemaVersion = schemaVersion;
    if (blocksJson != null) result.blocksJson = blocksJson;
    if (updatedBy != null) result.updatedBy = updatedBy;
    if (editing != null) result.editing.addAll(editing);
    if (cards != null) result.cards.addAll(cards);
    if (canEdit != null) result.canEdit = canEdit;
    if (canManage != null) result.canManage = canManage;
    if (accessUserIds != null) result.accessUserIds.addAll(accessUserIds);
    return result;
  }

  DocAnswer._();

  factory DocAnswer.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DocAnswer()..mergeFromBuffer(data, registry);
  factory DocAnswer.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DocAnswer()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DocAnswer',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.wikidocs'),
      createEmptyInstance: DocAnswer.$_createMessage)
    ..aOM<DocNode>(1, _omitFieldNames ? '' : 'doc',
        subBuilder: DocNode.$_createMessage)
    ..aI(2, _omitFieldNames ? '' : 'version')
    ..aI(3, _omitFieldNames ? '' : 'schemaVersion')
    ..aOS(4, _omitFieldNames ? '' : 'blocksJson')
    ..aOS(5, _omitFieldNames ? '' : 'updatedBy')
    ..pPM<Editor>(6, _omitFieldNames ? '' : 'editing',
        subBuilder: Editor.$_createMessage)
    ..pPM<TaskCard>(7, _omitFieldNames ? '' : 'cards',
        subBuilder: TaskCard.$_createMessage)
    ..aOB(8, _omitFieldNames ? '' : 'canEdit')
    ..aOB(9, _omitFieldNames ? '' : 'canManage')
    ..pPS(10, _omitFieldNames ? '' : 'accessUserIds')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DocAnswer clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DocAnswer copyWith(void Function(DocAnswer) updates) =>
      super.copyWith((message) => updates(message as DocAnswer)) as DocAnswer;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use DocAnswer() / DocAnswer.new instead')
  static DocAnswer create() => DocAnswer._();
  static $pb.GeneratedMessage $_createMessage() => DocAnswer._();
  @$core.override
  DocAnswer createEmptyInstance() => DocAnswer._();
  @$core.pragma('dart2js:noInline')
  static DocAnswer getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DocAnswer>(DocAnswer.$_createMessage);
  static DocAnswer? _defaultInstance;

  @$pb.TagNumber(1)
  DocNode get doc => $_getN(0);
  @$pb.TagNumber(1)
  set doc(DocNode value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasDoc() => $_has(0);
  @$pb.TagNumber(1)
  void clearDoc() => $_clearField(1);
  @$pb.TagNumber(1)
  DocNode ensureDoc() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.int get version => $_getIZ(1);
  @$pb.TagNumber(2)
  set version($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasVersion() => $_has(1);
  @$pb.TagNumber(2)
  void clearVersion() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get schemaVersion => $_getIZ(2);
  @$pb.TagNumber(3)
  set schemaVersion($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSchemaVersion() => $_has(2);
  @$pb.TagNumber(3)
  void clearSchemaVersion() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get blocksJson => $_getSZ(3);
  @$pb.TagNumber(4)
  set blocksJson($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasBlocksJson() => $_has(3);
  @$pb.TagNumber(4)
  void clearBlocksJson() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get updatedBy => $_getSZ(4);
  @$pb.TagNumber(5)
  set updatedBy($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasUpdatedBy() => $_has(4);
  @$pb.TagNumber(5)
  void clearUpdatedBy() => $_clearField(5);

  @$pb.TagNumber(6)
  $pb.PbList<Editor> get editing => $_getList(5);

  @$pb.TagNumber(7)
  $pb.PbList<TaskCard> get cards => $_getList(6);

  @$pb.TagNumber(8)
  $core.bool get canEdit => $_getBF(7);
  @$pb.TagNumber(8)
  set canEdit($core.bool value) => $_setBool(7, value);
  @$pb.TagNumber(8)
  $core.bool hasCanEdit() => $_has(7);
  @$pb.TagNumber(8)
  void clearCanEdit() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.bool get canManage => $_getBF(8);
  @$pb.TagNumber(9)
  set canManage($core.bool value) => $_setBool(8, value);
  @$pb.TagNumber(9)
  $core.bool hasCanManage() => $_has(8);
  @$pb.TagNumber(9)
  void clearCanManage() => $_clearField(9);

  @$pb.TagNumber(10)
  $pb.PbList<$core.String> get accessUserIds => $_getList(9);
}

class DocArchiveRequest extends $pb.GeneratedMessage {
  factory DocArchiveRequest({
    $core.String? workspaceId,
    $core.String? docId,
  }) {
    final result = DocArchiveRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (docId != null) result.docId = docId;
    return result;
  }

  DocArchiveRequest._();

  factory DocArchiveRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DocArchiveRequest()..mergeFromBuffer(data, registry);
  factory DocArchiveRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DocArchiveRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DocArchiveRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.wikidocs'),
      createEmptyInstance: DocArchiveRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'docId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DocArchiveRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DocArchiveRequest copyWith(void Function(DocArchiveRequest) updates) =>
      super.copyWith((message) => updates(message as DocArchiveRequest))
          as DocArchiveRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use DocArchiveRequest() / DocArchiveRequest.new instead')
  static DocArchiveRequest create() => DocArchiveRequest._();
  static $pb.GeneratedMessage $_createMessage() => DocArchiveRequest._();
  @$core.override
  DocArchiveRequest createEmptyInstance() => DocArchiveRequest._();
  @$core.pragma('dart2js:noInline')
  static DocArchiveRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DocArchiveRequest>(
          DocArchiveRequest.$_createMessage);
  static DocArchiveRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get docId => $_getSZ(1);
  @$pb.TagNumber(2)
  set docId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDocId() => $_has(1);
  @$pb.TagNumber(2)
  void clearDocId() => $_clearField(2);
}

class DocBacklinksRequest extends $pb.GeneratedMessage {
  factory DocBacklinksRequest({
    $core.String? workspaceId,
    $core.String? docId,
  }) {
    final result = DocBacklinksRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (docId != null) result.docId = docId;
    return result;
  }

  DocBacklinksRequest._();

  factory DocBacklinksRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DocBacklinksRequest()..mergeFromBuffer(data, registry);
  factory DocBacklinksRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DocBacklinksRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DocBacklinksRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.wikidocs'),
      createEmptyInstance: DocBacklinksRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'docId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DocBacklinksRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DocBacklinksRequest copyWith(void Function(DocBacklinksRequest) updates) =>
      super.copyWith((message) => updates(message as DocBacklinksRequest))
          as DocBacklinksRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core
      .Deprecated('Use DocBacklinksRequest() / DocBacklinksRequest.new instead')
  static DocBacklinksRequest create() => DocBacklinksRequest._();
  static $pb.GeneratedMessage $_createMessage() => DocBacklinksRequest._();
  @$core.override
  DocBacklinksRequest createEmptyInstance() => DocBacklinksRequest._();
  @$core.pragma('dart2js:noInline')
  static DocBacklinksRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DocBacklinksRequest>(
          DocBacklinksRequest.$_createMessage);
  static DocBacklinksRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get docId => $_getSZ(1);
  @$pb.TagNumber(2)
  set docId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDocId() => $_has(1);
  @$pb.TagNumber(2)
  void clearDocId() => $_clearField(2);
}

class DocCreateRequest extends $pb.GeneratedMessage {
  factory DocCreateRequest({
    $core.String? workspaceId,
    $core.String? projectId,
    $core.String? parentId,
    $core.String? title,
    $core.String? icon,
    $core.String? blocksJson,
  }) {
    final result = DocCreateRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (projectId != null) result.projectId = projectId;
    if (parentId != null) result.parentId = parentId;
    if (title != null) result.title = title;
    if (icon != null) result.icon = icon;
    if (blocksJson != null) result.blocksJson = blocksJson;
    return result;
  }

  DocCreateRequest._();

  factory DocCreateRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DocCreateRequest()..mergeFromBuffer(data, registry);
  factory DocCreateRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DocCreateRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DocCreateRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.wikidocs'),
      createEmptyInstance: DocCreateRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..aOS(3, _omitFieldNames ? '' : 'parentId')
    ..aOS(4, _omitFieldNames ? '' : 'title')
    ..aOS(5, _omitFieldNames ? '' : 'icon')
    ..aOS(6, _omitFieldNames ? '' : 'blocksJson')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DocCreateRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DocCreateRequest copyWith(void Function(DocCreateRequest) updates) =>
      super.copyWith((message) => updates(message as DocCreateRequest))
          as DocCreateRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use DocCreateRequest() / DocCreateRequest.new instead')
  static DocCreateRequest create() => DocCreateRequest._();
  static $pb.GeneratedMessage $_createMessage() => DocCreateRequest._();
  @$core.override
  DocCreateRequest createEmptyInstance() => DocCreateRequest._();
  @$core.pragma('dart2js:noInline')
  static DocCreateRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DocCreateRequest>(
          DocCreateRequest.$_createMessage);
  static DocCreateRequest? _defaultInstance;

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
  $core.String get parentId => $_getSZ(2);
  @$pb.TagNumber(3)
  set parentId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasParentId() => $_has(2);
  @$pb.TagNumber(3)
  void clearParentId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get title => $_getSZ(3);
  @$pb.TagNumber(4)
  set title($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasTitle() => $_has(3);
  @$pb.TagNumber(4)
  void clearTitle() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get icon => $_getSZ(4);
  @$pb.TagNumber(5)
  set icon($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasIcon() => $_has(4);
  @$pb.TagNumber(5)
  void clearIcon() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get blocksJson => $_getSZ(5);
  @$pb.TagNumber(6)
  set blocksJson($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasBlocksJson() => $_has(5);
  @$pb.TagNumber(6)
  void clearBlocksJson() => $_clearField(6);
}

class DocExportRequest extends $pb.GeneratedMessage {
  factory DocExportRequest({
    $core.String? workspaceId,
    $core.String? docId,
  }) {
    final result = DocExportRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (docId != null) result.docId = docId;
    return result;
  }

  DocExportRequest._();

  factory DocExportRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DocExportRequest()..mergeFromBuffer(data, registry);
  factory DocExportRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DocExportRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DocExportRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.wikidocs'),
      createEmptyInstance: DocExportRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'docId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DocExportRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DocExportRequest copyWith(void Function(DocExportRequest) updates) =>
      super.copyWith((message) => updates(message as DocExportRequest))
          as DocExportRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use DocExportRequest() / DocExportRequest.new instead')
  static DocExportRequest create() => DocExportRequest._();
  static $pb.GeneratedMessage $_createMessage() => DocExportRequest._();
  @$core.override
  DocExportRequest createEmptyInstance() => DocExportRequest._();
  @$core.pragma('dart2js:noInline')
  static DocExportRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DocExportRequest>(
          DocExportRequest.$_createMessage);
  static DocExportRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get docId => $_getSZ(1);
  @$pb.TagNumber(2)
  set docId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDocId() => $_has(1);
  @$pb.TagNumber(2)
  void clearDocId() => $_clearField(2);
}

class DocForTaskRequest extends $pb.GeneratedMessage {
  factory DocForTaskRequest({
    $core.String? workspaceId,
    $core.String? projectId,
    $core.String? taskId,
  }) {
    final result = DocForTaskRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (projectId != null) result.projectId = projectId;
    if (taskId != null) result.taskId = taskId;
    return result;
  }

  DocForTaskRequest._();

  factory DocForTaskRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DocForTaskRequest()..mergeFromBuffer(data, registry);
  factory DocForTaskRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DocForTaskRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DocForTaskRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.wikidocs'),
      createEmptyInstance: DocForTaskRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..aOS(3, _omitFieldNames ? '' : 'taskId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DocForTaskRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DocForTaskRequest copyWith(void Function(DocForTaskRequest) updates) =>
      super.copyWith((message) => updates(message as DocForTaskRequest))
          as DocForTaskRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use DocForTaskRequest() / DocForTaskRequest.new instead')
  static DocForTaskRequest create() => DocForTaskRequest._();
  static $pb.GeneratedMessage $_createMessage() => DocForTaskRequest._();
  @$core.override
  DocForTaskRequest createEmptyInstance() => DocForTaskRequest._();
  @$core.pragma('dart2js:noInline')
  static DocForTaskRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DocForTaskRequest>(
          DocForTaskRequest.$_createMessage);
  static DocForTaskRequest? _defaultInstance;

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

class DocGetRequest extends $pb.GeneratedMessage {
  factory DocGetRequest({
    $core.String? workspaceId,
    $core.String? docId,
  }) {
    final result = DocGetRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (docId != null) result.docId = docId;
    return result;
  }

  DocGetRequest._();

  factory DocGetRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DocGetRequest()..mergeFromBuffer(data, registry);
  factory DocGetRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DocGetRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DocGetRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.wikidocs'),
      createEmptyInstance: DocGetRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'docId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DocGetRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DocGetRequest copyWith(void Function(DocGetRequest) updates) =>
      super.copyWith((message) => updates(message as DocGetRequest))
          as DocGetRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use DocGetRequest() / DocGetRequest.new instead')
  static DocGetRequest create() => DocGetRequest._();
  static $pb.GeneratedMessage $_createMessage() => DocGetRequest._();
  @$core.override
  DocGetRequest createEmptyInstance() => DocGetRequest._();
  @$core.pragma('dart2js:noInline')
  static DocGetRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DocGetRequest>(
          DocGetRequest.$_createMessage);
  static DocGetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get docId => $_getSZ(1);
  @$pb.TagNumber(2)
  set docId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDocId() => $_has(1);
  @$pb.TagNumber(2)
  void clearDocId() => $_clearField(2);
}

class DocLinkTaskRequest extends $pb.GeneratedMessage {
  factory DocLinkTaskRequest({
    $core.String? workspaceId,
    $core.String? projectId,
    $core.String? taskId,
    $core.String? docId,
  }) {
    final result = DocLinkTaskRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (projectId != null) result.projectId = projectId;
    if (taskId != null) result.taskId = taskId;
    if (docId != null) result.docId = docId;
    return result;
  }

  DocLinkTaskRequest._();

  factory DocLinkTaskRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DocLinkTaskRequest()..mergeFromBuffer(data, registry);
  factory DocLinkTaskRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DocLinkTaskRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DocLinkTaskRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.wikidocs'),
      createEmptyInstance: DocLinkTaskRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..aOS(3, _omitFieldNames ? '' : 'taskId')
    ..aOS(4, _omitFieldNames ? '' : 'docId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DocLinkTaskRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DocLinkTaskRequest copyWith(void Function(DocLinkTaskRequest) updates) =>
      super.copyWith((message) => updates(message as DocLinkTaskRequest))
          as DocLinkTaskRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use DocLinkTaskRequest() / DocLinkTaskRequest.new instead')
  static DocLinkTaskRequest create() => DocLinkTaskRequest._();
  static $pb.GeneratedMessage $_createMessage() => DocLinkTaskRequest._();
  @$core.override
  DocLinkTaskRequest createEmptyInstance() => DocLinkTaskRequest._();
  @$core.pragma('dart2js:noInline')
  static DocLinkTaskRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DocLinkTaskRequest>(
          DocLinkTaskRequest.$_createMessage);
  static DocLinkTaskRequest? _defaultInstance;

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
  $core.String get docId => $_getSZ(3);
  @$pb.TagNumber(4)
  set docId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasDocId() => $_has(3);
  @$pb.TagNumber(4)
  void clearDocId() => $_clearField(4);
}

class DocMarkdown extends $pb.GeneratedMessage {
  factory DocMarkdown({
    $core.String? title,
    $core.String? markdown,
  }) {
    final result = DocMarkdown._();
    if (title != null) result.title = title;
    if (markdown != null) result.markdown = markdown;
    return result;
  }

  DocMarkdown._();

  factory DocMarkdown.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DocMarkdown()..mergeFromBuffer(data, registry);
  factory DocMarkdown.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DocMarkdown()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DocMarkdown',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.wikidocs'),
      createEmptyInstance: DocMarkdown.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'title')
    ..aOS(2, _omitFieldNames ? '' : 'markdown')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DocMarkdown clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DocMarkdown copyWith(void Function(DocMarkdown) updates) =>
      super.copyWith((message) => updates(message as DocMarkdown))
          as DocMarkdown;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use DocMarkdown() / DocMarkdown.new instead')
  static DocMarkdown create() => DocMarkdown._();
  static $pb.GeneratedMessage $_createMessage() => DocMarkdown._();
  @$core.override
  DocMarkdown createEmptyInstance() => DocMarkdown._();
  @$core.pragma('dart2js:noInline')
  static DocMarkdown getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DocMarkdown>(
          DocMarkdown.$_createMessage);
  static DocMarkdown? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get title => $_getSZ(0);
  @$pb.TagNumber(1)
  set title($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTitle() => $_has(0);
  @$pb.TagNumber(1)
  void clearTitle() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get markdown => $_getSZ(1);
  @$pb.TagNumber(2)
  set markdown($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMarkdown() => $_has(1);
  @$pb.TagNumber(2)
  void clearMarkdown() => $_clearField(2);
}

class DocMoveRequest extends $pb.GeneratedMessage {
  factory DocMoveRequest({
    $core.String? workspaceId,
    $core.String? docId,
    $core.String? parentId,
    $core.int? index,
  }) {
    final result = DocMoveRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (docId != null) result.docId = docId;
    if (parentId != null) result.parentId = parentId;
    if (index != null) result.index = index;
    return result;
  }

  DocMoveRequest._();

  factory DocMoveRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DocMoveRequest()..mergeFromBuffer(data, registry);
  factory DocMoveRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DocMoveRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DocMoveRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.wikidocs'),
      createEmptyInstance: DocMoveRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'docId')
    ..aOS(3, _omitFieldNames ? '' : 'parentId')
    ..aI(4, _omitFieldNames ? '' : 'index')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DocMoveRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DocMoveRequest copyWith(void Function(DocMoveRequest) updates) =>
      super.copyWith((message) => updates(message as DocMoveRequest))
          as DocMoveRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use DocMoveRequest() / DocMoveRequest.new instead')
  static DocMoveRequest create() => DocMoveRequest._();
  static $pb.GeneratedMessage $_createMessage() => DocMoveRequest._();
  @$core.override
  DocMoveRequest createEmptyInstance() => DocMoveRequest._();
  @$core.pragma('dart2js:noInline')
  static DocMoveRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DocMoveRequest>(
          DocMoveRequest.$_createMessage);
  static DocMoveRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get docId => $_getSZ(1);
  @$pb.TagNumber(2)
  set docId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDocId() => $_has(1);
  @$pb.TagNumber(2)
  void clearDocId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get parentId => $_getSZ(2);
  @$pb.TagNumber(3)
  set parentId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasParentId() => $_has(2);
  @$pb.TagNumber(3)
  void clearParentId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get index => $_getIZ(3);
  @$pb.TagNumber(4)
  set index($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasIndex() => $_has(3);
  @$pb.TagNumber(4)
  void clearIndex() => $_clearField(4);
}

class DocNode extends $pb.GeneratedMessage {
  factory DocNode({
    $core.String? id,
    $core.String? workspaceId,
    $core.String? projectId,
    $core.String? parentId,
    $core.String? title,
    $core.String? icon,
    $core.int? position,
    $core.bool? restricted,
    $core.bool? archived,
    $core.String? createdBy,
    $core.String? createdAt,
    $core.String? updatedAt,
  }) {
    final result = DocNode._();
    if (id != null) result.id = id;
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (projectId != null) result.projectId = projectId;
    if (parentId != null) result.parentId = parentId;
    if (title != null) result.title = title;
    if (icon != null) result.icon = icon;
    if (position != null) result.position = position;
    if (restricted != null) result.restricted = restricted;
    if (archived != null) result.archived = archived;
    if (createdBy != null) result.createdBy = createdBy;
    if (createdAt != null) result.createdAt = createdAt;
    if (updatedAt != null) result.updatedAt = updatedAt;
    return result;
  }

  DocNode._();

  factory DocNode.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DocNode()..mergeFromBuffer(data, registry);
  factory DocNode.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DocNode()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DocNode',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.wikidocs'),
      createEmptyInstance: DocNode.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(3, _omitFieldNames ? '' : 'projectId')
    ..aOS(4, _omitFieldNames ? '' : 'parentId')
    ..aOS(5, _omitFieldNames ? '' : 'title')
    ..aOS(6, _omitFieldNames ? '' : 'icon')
    ..aI(7, _omitFieldNames ? '' : 'position')
    ..aOB(8, _omitFieldNames ? '' : 'restricted')
    ..aOB(9, _omitFieldNames ? '' : 'archived')
    ..aOS(10, _omitFieldNames ? '' : 'createdBy')
    ..aOS(11, _omitFieldNames ? '' : 'createdAt')
    ..aOS(12, _omitFieldNames ? '' : 'updatedAt')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DocNode clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DocNode copyWith(void Function(DocNode) updates) =>
      super.copyWith((message) => updates(message as DocNode)) as DocNode;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use DocNode() / DocNode.new instead')
  static DocNode create() => DocNode._();
  static $pb.GeneratedMessage $_createMessage() => DocNode._();
  @$core.override
  DocNode createEmptyInstance() => DocNode._();
  @$core.pragma('dart2js:noInline')
  static DocNode getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DocNode>(DocNode.$_createMessage);
  static DocNode? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get workspaceId => $_getSZ(1);
  @$pb.TagNumber(2)
  set workspaceId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasWorkspaceId() => $_has(1);
  @$pb.TagNumber(2)
  void clearWorkspaceId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get projectId => $_getSZ(2);
  @$pb.TagNumber(3)
  set projectId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasProjectId() => $_has(2);
  @$pb.TagNumber(3)
  void clearProjectId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get parentId => $_getSZ(3);
  @$pb.TagNumber(4)
  set parentId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasParentId() => $_has(3);
  @$pb.TagNumber(4)
  void clearParentId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get title => $_getSZ(4);
  @$pb.TagNumber(5)
  set title($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasTitle() => $_has(4);
  @$pb.TagNumber(5)
  void clearTitle() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get icon => $_getSZ(5);
  @$pb.TagNumber(6)
  set icon($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasIcon() => $_has(5);
  @$pb.TagNumber(6)
  void clearIcon() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.int get position => $_getIZ(6);
  @$pb.TagNumber(7)
  set position($core.int value) => $_setSignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasPosition() => $_has(6);
  @$pb.TagNumber(7)
  void clearPosition() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.bool get restricted => $_getBF(7);
  @$pb.TagNumber(8)
  set restricted($core.bool value) => $_setBool(7, value);
  @$pb.TagNumber(8)
  $core.bool hasRestricted() => $_has(7);
  @$pb.TagNumber(8)
  void clearRestricted() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.bool get archived => $_getBF(8);
  @$pb.TagNumber(9)
  set archived($core.bool value) => $_setBool(8, value);
  @$pb.TagNumber(9)
  $core.bool hasArchived() => $_has(8);
  @$pb.TagNumber(9)
  void clearArchived() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get createdBy => $_getSZ(9);
  @$pb.TagNumber(10)
  set createdBy($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasCreatedBy() => $_has(9);
  @$pb.TagNumber(10)
  void clearCreatedBy() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.String get createdAt => $_getSZ(10);
  @$pb.TagNumber(11)
  set createdAt($core.String value) => $_setString(10, value);
  @$pb.TagNumber(11)
  $core.bool hasCreatedAt() => $_has(10);
  @$pb.TagNumber(11)
  void clearCreatedAt() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.String get updatedAt => $_getSZ(11);
  @$pb.TagNumber(12)
  set updatedAt($core.String value) => $_setString(11, value);
  @$pb.TagNumber(12)
  $core.bool hasUpdatedAt() => $_has(11);
  @$pb.TagNumber(12)
  void clearUpdatedAt() => $_clearField(12);
}

class DocPresence extends $pb.GeneratedMessage {
  factory DocPresence({
    $core.Iterable<Editor>? editing,
  }) {
    final result = DocPresence._();
    if (editing != null) result.editing.addAll(editing);
    return result;
  }

  DocPresence._();

  factory DocPresence.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DocPresence()..mergeFromBuffer(data, registry);
  factory DocPresence.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DocPresence()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DocPresence',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.wikidocs'),
      createEmptyInstance: DocPresence.$_createMessage)
    ..pPM<Editor>(1, _omitFieldNames ? '' : 'editing',
        subBuilder: Editor.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DocPresence clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DocPresence copyWith(void Function(DocPresence) updates) =>
      super.copyWith((message) => updates(message as DocPresence))
          as DocPresence;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use DocPresence() / DocPresence.new instead')
  static DocPresence create() => DocPresence._();
  static $pb.GeneratedMessage $_createMessage() => DocPresence._();
  @$core.override
  DocPresence createEmptyInstance() => DocPresence._();
  @$core.pragma('dart2js:noInline')
  static DocPresence getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DocPresence>(
          DocPresence.$_createMessage);
  static DocPresence? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Editor> get editing => $_getList(0);
}

class DocPresenceRequest extends $pb.GeneratedMessage {
  factory DocPresenceRequest({
    $core.String? workspaceId,
    $core.String? docId,
    $core.String? state,
  }) {
    final result = DocPresenceRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (docId != null) result.docId = docId;
    if (state != null) result.state = state;
    return result;
  }

  DocPresenceRequest._();

  factory DocPresenceRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DocPresenceRequest()..mergeFromBuffer(data, registry);
  factory DocPresenceRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DocPresenceRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DocPresenceRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.wikidocs'),
      createEmptyInstance: DocPresenceRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'docId')
    ..aOS(3, _omitFieldNames ? '' : 'state')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DocPresenceRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DocPresenceRequest copyWith(void Function(DocPresenceRequest) updates) =>
      super.copyWith((message) => updates(message as DocPresenceRequest))
          as DocPresenceRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use DocPresenceRequest() / DocPresenceRequest.new instead')
  static DocPresenceRequest create() => DocPresenceRequest._();
  static $pb.GeneratedMessage $_createMessage() => DocPresenceRequest._();
  @$core.override
  DocPresenceRequest createEmptyInstance() => DocPresenceRequest._();
  @$core.pragma('dart2js:noInline')
  static DocPresenceRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DocPresenceRequest>(
          DocPresenceRequest.$_createMessage);
  static DocPresenceRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get docId => $_getSZ(1);
  @$pb.TagNumber(2)
  set docId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDocId() => $_has(1);
  @$pb.TagNumber(2)
  void clearDocId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get state => $_getSZ(2);
  @$pb.TagNumber(3)
  set state($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasState() => $_has(2);
  @$pb.TagNumber(3)
  void clearState() => $_clearField(3);
}

class DocRestoreRequest extends $pb.GeneratedMessage {
  factory DocRestoreRequest({
    $core.String? workspaceId,
    $core.String? docId,
  }) {
    final result = DocRestoreRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (docId != null) result.docId = docId;
    return result;
  }

  DocRestoreRequest._();

  factory DocRestoreRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DocRestoreRequest()..mergeFromBuffer(data, registry);
  factory DocRestoreRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DocRestoreRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DocRestoreRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.wikidocs'),
      createEmptyInstance: DocRestoreRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'docId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DocRestoreRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DocRestoreRequest copyWith(void Function(DocRestoreRequest) updates) =>
      super.copyWith((message) => updates(message as DocRestoreRequest))
          as DocRestoreRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use DocRestoreRequest() / DocRestoreRequest.new instead')
  static DocRestoreRequest create() => DocRestoreRequest._();
  static $pb.GeneratedMessage $_createMessage() => DocRestoreRequest._();
  @$core.override
  DocRestoreRequest createEmptyInstance() => DocRestoreRequest._();
  @$core.pragma('dart2js:noInline')
  static DocRestoreRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DocRestoreRequest>(
          DocRestoreRequest.$_createMessage);
  static DocRestoreRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get docId => $_getSZ(1);
  @$pb.TagNumber(2)
  set docId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDocId() => $_has(1);
  @$pb.TagNumber(2)
  void clearDocId() => $_clearField(2);
}

class DocRevisionAnswer extends $pb.GeneratedMessage {
  factory DocRevisionAnswer({
    RevisionInfo? revision,
    $core.String? blocksJson,
  }) {
    final result = DocRevisionAnswer._();
    if (revision != null) result.revision = revision;
    if (blocksJson != null) result.blocksJson = blocksJson;
    return result;
  }

  DocRevisionAnswer._();

  factory DocRevisionAnswer.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DocRevisionAnswer()..mergeFromBuffer(data, registry);
  factory DocRevisionAnswer.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DocRevisionAnswer()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DocRevisionAnswer',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.wikidocs'),
      createEmptyInstance: DocRevisionAnswer.$_createMessage)
    ..aOM<RevisionInfo>(1, _omitFieldNames ? '' : 'revision',
        subBuilder: RevisionInfo.$_createMessage)
    ..aOS(2, _omitFieldNames ? '' : 'blocksJson')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DocRevisionAnswer clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DocRevisionAnswer copyWith(void Function(DocRevisionAnswer) updates) =>
      super.copyWith((message) => updates(message as DocRevisionAnswer))
          as DocRevisionAnswer;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use DocRevisionAnswer() / DocRevisionAnswer.new instead')
  static DocRevisionAnswer create() => DocRevisionAnswer._();
  static $pb.GeneratedMessage $_createMessage() => DocRevisionAnswer._();
  @$core.override
  DocRevisionAnswer createEmptyInstance() => DocRevisionAnswer._();
  @$core.pragma('dart2js:noInline')
  static DocRevisionAnswer getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DocRevisionAnswer>(
          DocRevisionAnswer.$_createMessage);
  static DocRevisionAnswer? _defaultInstance;

  @$pb.TagNumber(1)
  RevisionInfo get revision => $_getN(0);
  @$pb.TagNumber(1)
  set revision(RevisionInfo value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasRevision() => $_has(0);
  @$pb.TagNumber(1)
  void clearRevision() => $_clearField(1);
  @$pb.TagNumber(1)
  RevisionInfo ensureRevision() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.String get blocksJson => $_getSZ(1);
  @$pb.TagNumber(2)
  set blocksJson($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasBlocksJson() => $_has(1);
  @$pb.TagNumber(2)
  void clearBlocksJson() => $_clearField(2);
}

class DocRevisionGetRequest extends $pb.GeneratedMessage {
  factory DocRevisionGetRequest({
    $core.String? workspaceId,
    $core.String? docId,
    $fixnum.Int64? revisionId,
  }) {
    final result = DocRevisionGetRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (docId != null) result.docId = docId;
    if (revisionId != null) result.revisionId = revisionId;
    return result;
  }

  DocRevisionGetRequest._();

  factory DocRevisionGetRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DocRevisionGetRequest()..mergeFromBuffer(data, registry);
  factory DocRevisionGetRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DocRevisionGetRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DocRevisionGetRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.wikidocs'),
      createEmptyInstance: DocRevisionGetRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'docId')
    ..aInt64(3, _omitFieldNames ? '' : 'revisionId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DocRevisionGetRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DocRevisionGetRequest copyWith(
          void Function(DocRevisionGetRequest) updates) =>
      super.copyWith((message) => updates(message as DocRevisionGetRequest))
          as DocRevisionGetRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use DocRevisionGetRequest() / DocRevisionGetRequest.new instead')
  static DocRevisionGetRequest create() => DocRevisionGetRequest._();
  static $pb.GeneratedMessage $_createMessage() => DocRevisionGetRequest._();
  @$core.override
  DocRevisionGetRequest createEmptyInstance() => DocRevisionGetRequest._();
  @$core.pragma('dart2js:noInline')
  static DocRevisionGetRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DocRevisionGetRequest>(
          DocRevisionGetRequest.$_createMessage);
  static DocRevisionGetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get docId => $_getSZ(1);
  @$pb.TagNumber(2)
  set docId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDocId() => $_has(1);
  @$pb.TagNumber(2)
  void clearDocId() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get revisionId => $_getI64(2);
  @$pb.TagNumber(3)
  set revisionId($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRevisionId() => $_has(2);
  @$pb.TagNumber(3)
  void clearRevisionId() => $_clearField(3);
}

class DocRevisionList extends $pb.GeneratedMessage {
  factory DocRevisionList({
    $core.Iterable<RevisionInfo>? revisions,
  }) {
    final result = DocRevisionList._();
    if (revisions != null) result.revisions.addAll(revisions);
    return result;
  }

  DocRevisionList._();

  factory DocRevisionList.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DocRevisionList()..mergeFromBuffer(data, registry);
  factory DocRevisionList.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DocRevisionList()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DocRevisionList',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.wikidocs'),
      createEmptyInstance: DocRevisionList.$_createMessage)
    ..pPM<RevisionInfo>(1, _omitFieldNames ? '' : 'revisions',
        subBuilder: RevisionInfo.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DocRevisionList clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DocRevisionList copyWith(void Function(DocRevisionList) updates) =>
      super.copyWith((message) => updates(message as DocRevisionList))
          as DocRevisionList;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use DocRevisionList() / DocRevisionList.new instead')
  static DocRevisionList create() => DocRevisionList._();
  static $pb.GeneratedMessage $_createMessage() => DocRevisionList._();
  @$core.override
  DocRevisionList createEmptyInstance() => DocRevisionList._();
  @$core.pragma('dart2js:noInline')
  static DocRevisionList getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DocRevisionList>(
          DocRevisionList.$_createMessage);
  static DocRevisionList? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<RevisionInfo> get revisions => $_getList(0);
}

class DocRevisionListRequest extends $pb.GeneratedMessage {
  factory DocRevisionListRequest({
    $core.String? workspaceId,
    $core.String? docId,
  }) {
    final result = DocRevisionListRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (docId != null) result.docId = docId;
    return result;
  }

  DocRevisionListRequest._();

  factory DocRevisionListRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DocRevisionListRequest()..mergeFromBuffer(data, registry);
  factory DocRevisionListRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DocRevisionListRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DocRevisionListRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.wikidocs'),
      createEmptyInstance: DocRevisionListRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'docId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DocRevisionListRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DocRevisionListRequest copyWith(
          void Function(DocRevisionListRequest) updates) =>
      super.copyWith((message) => updates(message as DocRevisionListRequest))
          as DocRevisionListRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use DocRevisionListRequest() / DocRevisionListRequest.new instead')
  static DocRevisionListRequest create() => DocRevisionListRequest._();
  static $pb.GeneratedMessage $_createMessage() => DocRevisionListRequest._();
  @$core.override
  DocRevisionListRequest createEmptyInstance() => DocRevisionListRequest._();
  @$core.pragma('dart2js:noInline')
  static DocRevisionListRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DocRevisionListRequest>(
          DocRevisionListRequest.$_createMessage);
  static DocRevisionListRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get docId => $_getSZ(1);
  @$pb.TagNumber(2)
  set docId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDocId() => $_has(1);
  @$pb.TagNumber(2)
  void clearDocId() => $_clearField(2);
}

class DocRevisionRestoreRequest extends $pb.GeneratedMessage {
  factory DocRevisionRestoreRequest({
    $core.String? workspaceId,
    $core.String? docId,
    $fixnum.Int64? revisionId,
    $core.int? expectedVersion,
  }) {
    final result = DocRevisionRestoreRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (docId != null) result.docId = docId;
    if (revisionId != null) result.revisionId = revisionId;
    if (expectedVersion != null) result.expectedVersion = expectedVersion;
    return result;
  }

  DocRevisionRestoreRequest._();

  factory DocRevisionRestoreRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DocRevisionRestoreRequest()..mergeFromBuffer(data, registry);
  factory DocRevisionRestoreRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DocRevisionRestoreRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DocRevisionRestoreRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.wikidocs'),
      createEmptyInstance: DocRevisionRestoreRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'docId')
    ..aInt64(3, _omitFieldNames ? '' : 'revisionId')
    ..aI(4, _omitFieldNames ? '' : 'expectedVersion')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DocRevisionRestoreRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DocRevisionRestoreRequest copyWith(
          void Function(DocRevisionRestoreRequest) updates) =>
      super.copyWith((message) => updates(message as DocRevisionRestoreRequest))
          as DocRevisionRestoreRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use DocRevisionRestoreRequest() / DocRevisionRestoreRequest.new instead')
  static DocRevisionRestoreRequest create() => DocRevisionRestoreRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      DocRevisionRestoreRequest._();
  @$core.override
  DocRevisionRestoreRequest createEmptyInstance() =>
      DocRevisionRestoreRequest._();
  @$core.pragma('dart2js:noInline')
  static DocRevisionRestoreRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DocRevisionRestoreRequest>(
          DocRevisionRestoreRequest.$_createMessage);
  static DocRevisionRestoreRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get docId => $_getSZ(1);
  @$pb.TagNumber(2)
  set docId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDocId() => $_has(1);
  @$pb.TagNumber(2)
  void clearDocId() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get revisionId => $_getI64(2);
  @$pb.TagNumber(3)
  set revisionId($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRevisionId() => $_has(2);
  @$pb.TagNumber(3)
  void clearRevisionId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get expectedVersion => $_getIZ(3);
  @$pb.TagNumber(4)
  set expectedVersion($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasExpectedVersion() => $_has(3);
  @$pb.TagNumber(4)
  void clearExpectedVersion() => $_clearField(4);
}

class DocSetAccessRequest extends $pb.GeneratedMessage {
  factory DocSetAccessRequest({
    $core.String? workspaceId,
    $core.String? docId,
    $core.bool? restricted,
    $core.Iterable<$core.String>? userIds,
  }) {
    final result = DocSetAccessRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (docId != null) result.docId = docId;
    if (restricted != null) result.restricted = restricted;
    if (userIds != null) result.userIds.addAll(userIds);
    return result;
  }

  DocSetAccessRequest._();

  factory DocSetAccessRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DocSetAccessRequest()..mergeFromBuffer(data, registry);
  factory DocSetAccessRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DocSetAccessRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DocSetAccessRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.wikidocs'),
      createEmptyInstance: DocSetAccessRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'docId')
    ..aOB(3, _omitFieldNames ? '' : 'restricted')
    ..pPS(4, _omitFieldNames ? '' : 'userIds')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DocSetAccessRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DocSetAccessRequest copyWith(void Function(DocSetAccessRequest) updates) =>
      super.copyWith((message) => updates(message as DocSetAccessRequest))
          as DocSetAccessRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core
      .Deprecated('Use DocSetAccessRequest() / DocSetAccessRequest.new instead')
  static DocSetAccessRequest create() => DocSetAccessRequest._();
  static $pb.GeneratedMessage $_createMessage() => DocSetAccessRequest._();
  @$core.override
  DocSetAccessRequest createEmptyInstance() => DocSetAccessRequest._();
  @$core.pragma('dart2js:noInline')
  static DocSetAccessRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DocSetAccessRequest>(
          DocSetAccessRequest.$_createMessage);
  static DocSetAccessRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get docId => $_getSZ(1);
  @$pb.TagNumber(2)
  set docId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDocId() => $_has(1);
  @$pb.TagNumber(2)
  void clearDocId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get restricted => $_getBF(2);
  @$pb.TagNumber(3)
  set restricted($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRestricted() => $_has(2);
  @$pb.TagNumber(3)
  void clearRestricted() => $_clearField(3);

  @$pb.TagNumber(4)
  $pb.PbList<$core.String> get userIds => $_getList(3);
}

class DocTaskCards extends $pb.GeneratedMessage {
  factory DocTaskCards({
    $core.Iterable<TaskCard>? cards,
  }) {
    final result = DocTaskCards._();
    if (cards != null) result.cards.addAll(cards);
    return result;
  }

  DocTaskCards._();

  factory DocTaskCards.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DocTaskCards()..mergeFromBuffer(data, registry);
  factory DocTaskCards.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DocTaskCards()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DocTaskCards',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.wikidocs'),
      createEmptyInstance: DocTaskCards.$_createMessage)
    ..pPM<TaskCard>(1, _omitFieldNames ? '' : 'cards',
        subBuilder: TaskCard.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DocTaskCards clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DocTaskCards copyWith(void Function(DocTaskCards) updates) =>
      super.copyWith((message) => updates(message as DocTaskCards))
          as DocTaskCards;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use DocTaskCards() / DocTaskCards.new instead')
  static DocTaskCards create() => DocTaskCards._();
  static $pb.GeneratedMessage $_createMessage() => DocTaskCards._();
  @$core.override
  DocTaskCards createEmptyInstance() => DocTaskCards._();
  @$core.pragma('dart2js:noInline')
  static DocTaskCards getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DocTaskCards>(
          DocTaskCards.$_createMessage);
  static DocTaskCards? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<TaskCard> get cards => $_getList(0);
}

class DocTaskCardsRequest extends $pb.GeneratedMessage {
  factory DocTaskCardsRequest({
    $core.String? workspaceId,
    $core.Iterable<$core.String>? taskIds,
  }) {
    final result = DocTaskCardsRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (taskIds != null) result.taskIds.addAll(taskIds);
    return result;
  }

  DocTaskCardsRequest._();

  factory DocTaskCardsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DocTaskCardsRequest()..mergeFromBuffer(data, registry);
  factory DocTaskCardsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DocTaskCardsRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DocTaskCardsRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.wikidocs'),
      createEmptyInstance: DocTaskCardsRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..pPS(2, _omitFieldNames ? '' : 'taskIds')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DocTaskCardsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DocTaskCardsRequest copyWith(void Function(DocTaskCardsRequest) updates) =>
      super.copyWith((message) => updates(message as DocTaskCardsRequest))
          as DocTaskCardsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core
      .Deprecated('Use DocTaskCardsRequest() / DocTaskCardsRequest.new instead')
  static DocTaskCardsRequest create() => DocTaskCardsRequest._();
  static $pb.GeneratedMessage $_createMessage() => DocTaskCardsRequest._();
  @$core.override
  DocTaskCardsRequest createEmptyInstance() => DocTaskCardsRequest._();
  @$core.pragma('dart2js:noInline')
  static DocTaskCardsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DocTaskCardsRequest>(
          DocTaskCardsRequest.$_createMessage);
  static DocTaskCardsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<$core.String> get taskIds => $_getList(1);
}

class DocTree extends $pb.GeneratedMessage {
  factory DocTree({
    $core.Iterable<DocNode>? docs,
  }) {
    final result = DocTree._();
    if (docs != null) result.docs.addAll(docs);
    return result;
  }

  DocTree._();

  factory DocTree.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DocTree()..mergeFromBuffer(data, registry);
  factory DocTree.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DocTree()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DocTree',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.wikidocs'),
      createEmptyInstance: DocTree.$_createMessage)
    ..pPM<DocNode>(1, _omitFieldNames ? '' : 'docs',
        subBuilder: DocNode.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DocTree clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DocTree copyWith(void Function(DocTree) updates) =>
      super.copyWith((message) => updates(message as DocTree)) as DocTree;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use DocTree() / DocTree.new instead')
  static DocTree create() => DocTree._();
  static $pb.GeneratedMessage $_createMessage() => DocTree._();
  @$core.override
  DocTree createEmptyInstance() => DocTree._();
  @$core.pragma('dart2js:noInline')
  static DocTree getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DocTree>(DocTree.$_createMessage);
  static DocTree? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<DocNode> get docs => $_getList(0);
}

class DocTreeRequest extends $pb.GeneratedMessage {
  factory DocTreeRequest({
    $core.String? workspaceId,
    $core.String? projectId,
    $core.bool? includeArchived,
  }) {
    final result = DocTreeRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (projectId != null) result.projectId = projectId;
    if (includeArchived != null) result.includeArchived = includeArchived;
    return result;
  }

  DocTreeRequest._();

  factory DocTreeRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DocTreeRequest()..mergeFromBuffer(data, registry);
  factory DocTreeRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DocTreeRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DocTreeRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.wikidocs'),
      createEmptyInstance: DocTreeRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..aOB(3, _omitFieldNames ? '' : 'includeArchived')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DocTreeRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DocTreeRequest copyWith(void Function(DocTreeRequest) updates) =>
      super.copyWith((message) => updates(message as DocTreeRequest))
          as DocTreeRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use DocTreeRequest() / DocTreeRequest.new instead')
  static DocTreeRequest create() => DocTreeRequest._();
  static $pb.GeneratedMessage $_createMessage() => DocTreeRequest._();
  @$core.override
  DocTreeRequest createEmptyInstance() => DocTreeRequest._();
  @$core.pragma('dart2js:noInline')
  static DocTreeRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DocTreeRequest>(
          DocTreeRequest.$_createMessage);
  static DocTreeRequest? _defaultInstance;

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
  $core.bool get includeArchived => $_getBF(2);
  @$pb.TagNumber(3)
  set includeArchived($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasIncludeArchived() => $_has(2);
  @$pb.TagNumber(3)
  void clearIncludeArchived() => $_clearField(3);
}

class DocUpdateRequest extends $pb.GeneratedMessage {
  factory DocUpdateRequest({
    $core.String? workspaceId,
    $core.String? docId,
    $core.int? expectedVersion,
    $core.Iterable<$core.String>? fields,
    $core.String? title,
    $core.String? icon,
    $core.String? blocksJson,
    $core.int? schemaVersion,
  }) {
    final result = DocUpdateRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (docId != null) result.docId = docId;
    if (expectedVersion != null) result.expectedVersion = expectedVersion;
    if (fields != null) result.fields.addAll(fields);
    if (title != null) result.title = title;
    if (icon != null) result.icon = icon;
    if (blocksJson != null) result.blocksJson = blocksJson;
    if (schemaVersion != null) result.schemaVersion = schemaVersion;
    return result;
  }

  DocUpdateRequest._();

  factory DocUpdateRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DocUpdateRequest()..mergeFromBuffer(data, registry);
  factory DocUpdateRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DocUpdateRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DocUpdateRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.wikidocs'),
      createEmptyInstance: DocUpdateRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'docId')
    ..aI(3, _omitFieldNames ? '' : 'expectedVersion')
    ..pPS(4, _omitFieldNames ? '' : 'fields')
    ..aOS(5, _omitFieldNames ? '' : 'title')
    ..aOS(6, _omitFieldNames ? '' : 'icon')
    ..aOS(7, _omitFieldNames ? '' : 'blocksJson')
    ..aI(8, _omitFieldNames ? '' : 'schemaVersion')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DocUpdateRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DocUpdateRequest copyWith(void Function(DocUpdateRequest) updates) =>
      super.copyWith((message) => updates(message as DocUpdateRequest))
          as DocUpdateRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use DocUpdateRequest() / DocUpdateRequest.new instead')
  static DocUpdateRequest create() => DocUpdateRequest._();
  static $pb.GeneratedMessage $_createMessage() => DocUpdateRequest._();
  @$core.override
  DocUpdateRequest createEmptyInstance() => DocUpdateRequest._();
  @$core.pragma('dart2js:noInline')
  static DocUpdateRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DocUpdateRequest>(
          DocUpdateRequest.$_createMessage);
  static DocUpdateRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get docId => $_getSZ(1);
  @$pb.TagNumber(2)
  set docId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDocId() => $_has(1);
  @$pb.TagNumber(2)
  void clearDocId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get expectedVersion => $_getIZ(2);
  @$pb.TagNumber(3)
  set expectedVersion($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasExpectedVersion() => $_has(2);
  @$pb.TagNumber(3)
  void clearExpectedVersion() => $_clearField(3);

  @$pb.TagNumber(4)
  $pb.PbList<$core.String> get fields => $_getList(3);

  @$pb.TagNumber(5)
  $core.String get title => $_getSZ(4);
  @$pb.TagNumber(5)
  set title($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasTitle() => $_has(4);
  @$pb.TagNumber(5)
  void clearTitle() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get icon => $_getSZ(5);
  @$pb.TagNumber(6)
  set icon($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasIcon() => $_has(5);
  @$pb.TagNumber(6)
  void clearIcon() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get blocksJson => $_getSZ(6);
  @$pb.TagNumber(7)
  set blocksJson($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasBlocksJson() => $_has(6);
  @$pb.TagNumber(7)
  void clearBlocksJson() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.int get schemaVersion => $_getIZ(7);
  @$pb.TagNumber(8)
  set schemaVersion($core.int value) => $_setSignedInt32(7, value);
  @$pb.TagNumber(8)
  $core.bool hasSchemaVersion() => $_has(7);
  @$pb.TagNumber(8)
  void clearSchemaVersion() => $_clearField(8);
}

class Editor extends $pb.GeneratedMessage {
  factory Editor({
    $core.String? userId,
    $core.bool? editing,
  }) {
    final result = Editor._();
    if (userId != null) result.userId = userId;
    if (editing != null) result.editing = editing;
    return result;
  }

  Editor._();

  factory Editor.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Editor()..mergeFromBuffer(data, registry);
  factory Editor.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Editor()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Editor',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.wikidocs'),
      createEmptyInstance: Editor.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'userId')
    ..aOB(2, _omitFieldNames ? '' : 'editing')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Editor clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Editor copyWith(void Function(Editor) updates) =>
      super.copyWith((message) => updates(message as Editor)) as Editor;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Editor() / Editor.new instead')
  static Editor create() => Editor._();
  static $pb.GeneratedMessage $_createMessage() => Editor._();
  @$core.override
  Editor createEmptyInstance() => Editor._();
  @$core.pragma('dart2js:noInline')
  static Editor getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Editor>(Editor.$_createMessage);
  static Editor? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get userId => $_getSZ(0);
  @$pb.TagNumber(1)
  set userId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get editing => $_getBF(1);
  @$pb.TagNumber(2)
  set editing($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasEditing() => $_has(1);
  @$pb.TagNumber(2)
  void clearEditing() => $_clearField(2);
}

class RelatedDoc extends $pb.GeneratedMessage {
  factory RelatedDoc({
    DocNode? doc,
    $core.String? kind,
  }) {
    final result = RelatedDoc._();
    if (doc != null) result.doc = doc;
    if (kind != null) result.kind = kind;
    return result;
  }

  RelatedDoc._();

  factory RelatedDoc.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RelatedDoc()..mergeFromBuffer(data, registry);
  factory RelatedDoc.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RelatedDoc()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RelatedDoc',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.wikidocs'),
      createEmptyInstance: RelatedDoc.$_createMessage)
    ..aOM<DocNode>(1, _omitFieldNames ? '' : 'doc',
        subBuilder: DocNode.$_createMessage)
    ..aOS(2, _omitFieldNames ? '' : 'kind')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RelatedDoc clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RelatedDoc copyWith(void Function(RelatedDoc) updates) =>
      super.copyWith((message) => updates(message as RelatedDoc)) as RelatedDoc;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use RelatedDoc() / RelatedDoc.new instead')
  static RelatedDoc create() => RelatedDoc._();
  static $pb.GeneratedMessage $_createMessage() => RelatedDoc._();
  @$core.override
  RelatedDoc createEmptyInstance() => RelatedDoc._();
  @$core.pragma('dart2js:noInline')
  static RelatedDoc getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RelatedDoc>(RelatedDoc.$_createMessage);
  static RelatedDoc? _defaultInstance;

  @$pb.TagNumber(1)
  DocNode get doc => $_getN(0);
  @$pb.TagNumber(1)
  set doc(DocNode value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasDoc() => $_has(0);
  @$pb.TagNumber(1)
  void clearDoc() => $_clearField(1);
  @$pb.TagNumber(1)
  DocNode ensureDoc() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.String get kind => $_getSZ(1);
  @$pb.TagNumber(2)
  set kind($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasKind() => $_has(1);
  @$pb.TagNumber(2)
  void clearKind() => $_clearField(2);
}

class RelatedDocs extends $pb.GeneratedMessage {
  factory RelatedDocs({
    $core.Iterable<RelatedDoc>? docs,
  }) {
    final result = RelatedDocs._();
    if (docs != null) result.docs.addAll(docs);
    return result;
  }

  RelatedDocs._();

  factory RelatedDocs.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RelatedDocs()..mergeFromBuffer(data, registry);
  factory RelatedDocs.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RelatedDocs()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RelatedDocs',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.wikidocs'),
      createEmptyInstance: RelatedDocs.$_createMessage)
    ..pPM<RelatedDoc>(1, _omitFieldNames ? '' : 'docs',
        subBuilder: RelatedDoc.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RelatedDocs clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RelatedDocs copyWith(void Function(RelatedDocs) updates) =>
      super.copyWith((message) => updates(message as RelatedDocs))
          as RelatedDocs;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use RelatedDocs() / RelatedDocs.new instead')
  static RelatedDocs create() => RelatedDocs._();
  static $pb.GeneratedMessage $_createMessage() => RelatedDocs._();
  @$core.override
  RelatedDocs createEmptyInstance() => RelatedDocs._();
  @$core.pragma('dart2js:noInline')
  static RelatedDocs getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RelatedDocs>(
          RelatedDocs.$_createMessage);
  static RelatedDocs? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<RelatedDoc> get docs => $_getList(0);
}

class RevisionInfo extends $pb.GeneratedMessage {
  factory RevisionInfo({
    $core.int? id,
    $core.int? version,
    $core.String? title,
    $core.String? authorId,
    $core.String? at,
    $core.String? savedAt,
  }) {
    final result = RevisionInfo._();
    if (id != null) result.id = id;
    if (version != null) result.version = version;
    if (title != null) result.title = title;
    if (authorId != null) result.authorId = authorId;
    if (at != null) result.at = at;
    if (savedAt != null) result.savedAt = savedAt;
    return result;
  }

  RevisionInfo._();

  factory RevisionInfo.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RevisionInfo()..mergeFromBuffer(data, registry);
  factory RevisionInfo.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RevisionInfo()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RevisionInfo',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.wikidocs'),
      createEmptyInstance: RevisionInfo.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'id')
    ..aI(2, _omitFieldNames ? '' : 'version')
    ..aOS(3, _omitFieldNames ? '' : 'title')
    ..aOS(4, _omitFieldNames ? '' : 'authorId')
    ..aOS(5, _omitFieldNames ? '' : 'at')
    ..aOS(6, _omitFieldNames ? '' : 'savedAt')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RevisionInfo clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RevisionInfo copyWith(void Function(RevisionInfo) updates) =>
      super.copyWith((message) => updates(message as RevisionInfo))
          as RevisionInfo;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use RevisionInfo() / RevisionInfo.new instead')
  static RevisionInfo create() => RevisionInfo._();
  static $pb.GeneratedMessage $_createMessage() => RevisionInfo._();
  @$core.override
  RevisionInfo createEmptyInstance() => RevisionInfo._();
  @$core.pragma('dart2js:noInline')
  static RevisionInfo getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RevisionInfo>(
          RevisionInfo.$_createMessage);
  static RevisionInfo? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get id => $_getIZ(0);
  @$pb.TagNumber(1)
  set id($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get version => $_getIZ(1);
  @$pb.TagNumber(2)
  set version($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasVersion() => $_has(1);
  @$pb.TagNumber(2)
  void clearVersion() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get title => $_getSZ(2);
  @$pb.TagNumber(3)
  set title($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTitle() => $_has(2);
  @$pb.TagNumber(3)
  void clearTitle() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get authorId => $_getSZ(3);
  @$pb.TagNumber(4)
  set authorId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasAuthorId() => $_has(3);
  @$pb.TagNumber(4)
  void clearAuthorId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get at => $_getSZ(4);
  @$pb.TagNumber(5)
  set at($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasAt() => $_has(4);
  @$pb.TagNumber(5)
  void clearAt() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get savedAt => $_getSZ(5);
  @$pb.TagNumber(6)
  set savedAt($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasSavedAt() => $_has(5);
  @$pb.TagNumber(6)
  void clearSavedAt() => $_clearField(6);
}

class TaskCard extends $pb.GeneratedMessage {
  factory TaskCard({
    $core.String? taskId,
    $core.bool? hidden,
    $core.String? projectId,
    $core.String? key,
    $core.String? title,
    $core.String? statusName,
    $core.String? statusCategory,
    $core.String? priority,
  }) {
    final result = TaskCard._();
    if (taskId != null) result.taskId = taskId;
    if (hidden != null) result.hidden = hidden;
    if (projectId != null) result.projectId = projectId;
    if (key != null) result.key = key;
    if (title != null) result.title = title;
    if (statusName != null) result.statusName = statusName;
    if (statusCategory != null) result.statusCategory = statusCategory;
    if (priority != null) result.priority = priority;
    return result;
  }

  TaskCard._();

  factory TaskCard.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TaskCard()..mergeFromBuffer(data, registry);
  factory TaskCard.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TaskCard()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TaskCard',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.wikidocs'),
      createEmptyInstance: TaskCard.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'taskId')
    ..aOB(2, _omitFieldNames ? '' : 'hidden')
    ..aOS(3, _omitFieldNames ? '' : 'projectId')
    ..aOS(4, _omitFieldNames ? '' : 'key')
    ..aOS(5, _omitFieldNames ? '' : 'title')
    ..aOS(6, _omitFieldNames ? '' : 'statusName')
    ..aOS(7, _omitFieldNames ? '' : 'statusCategory')
    ..aOS(8, _omitFieldNames ? '' : 'priority')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TaskCard clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TaskCard copyWith(void Function(TaskCard) updates) =>
      super.copyWith((message) => updates(message as TaskCard)) as TaskCard;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use TaskCard() / TaskCard.new instead')
  static TaskCard create() => TaskCard._();
  static $pb.GeneratedMessage $_createMessage() => TaskCard._();
  @$core.override
  TaskCard createEmptyInstance() => TaskCard._();
  @$core.pragma('dart2js:noInline')
  static TaskCard getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TaskCard>(TaskCard.$_createMessage);
  static TaskCard? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get taskId => $_getSZ(0);
  @$pb.TagNumber(1)
  set taskId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTaskId() => $_has(0);
  @$pb.TagNumber(1)
  void clearTaskId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get hidden => $_getBF(1);
  @$pb.TagNumber(2)
  set hidden($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasHidden() => $_has(1);
  @$pb.TagNumber(2)
  void clearHidden() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get projectId => $_getSZ(2);
  @$pb.TagNumber(3)
  set projectId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasProjectId() => $_has(2);
  @$pb.TagNumber(3)
  void clearProjectId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get key => $_getSZ(3);
  @$pb.TagNumber(4)
  set key($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasKey() => $_has(3);
  @$pb.TagNumber(4)
  void clearKey() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get title => $_getSZ(4);
  @$pb.TagNumber(5)
  set title($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasTitle() => $_has(4);
  @$pb.TagNumber(5)
  void clearTitle() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get statusName => $_getSZ(5);
  @$pb.TagNumber(6)
  set statusName($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasStatusName() => $_has(5);
  @$pb.TagNumber(6)
  void clearStatusName() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get statusCategory => $_getSZ(6);
  @$pb.TagNumber(7)
  set statusCategory($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasStatusCategory() => $_has(6);
  @$pb.TagNumber(7)
  void clearStatusCategory() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get priority => $_getSZ(7);
  @$pb.TagNumber(8)
  set priority($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasPriority() => $_has(7);
  @$pb.TagNumber(8)
  void clearPriority() => $_clearField(8);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
