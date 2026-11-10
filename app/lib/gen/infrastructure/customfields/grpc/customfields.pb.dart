// This is a generated file - do not edit.
//
// Generated from infrastructure/customfields/grpc/customfields.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class Field extends $pb.GeneratedMessage {
  factory Field({
    $core.String? id,
    $core.String? projectId,
    $core.String? name,
    $core.String? type,
    $core.Iterable<FieldOptionResponse>? options,
    $core.bool? required,
    $core.String? default_7,
    $core.Iterable<$core.String>? hiddenViews,
    $core.int? position,
    $core.int? version,
    $core.String? archivedAt,
  }) {
    final result = Field._();
    if (id != null) result.id = id;
    if (projectId != null) result.projectId = projectId;
    if (name != null) result.name = name;
    if (type != null) result.type = type;
    if (options != null) result.options.addAll(options);
    if (required != null) result.required = required;
    if (default_7 != null) result.default_7 = default_7;
    if (hiddenViews != null) result.hiddenViews.addAll(hiddenViews);
    if (position != null) result.position = position;
    if (version != null) result.version = version;
    if (archivedAt != null) result.archivedAt = archivedAt;
    return result;
  }

  Field._();

  factory Field.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Field()..mergeFromBuffer(data, registry);
  factory Field.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Field()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Field',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.customfields'),
      createEmptyInstance: Field.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..aOS(3, _omitFieldNames ? '' : 'name')
    ..aOS(4, _omitFieldNames ? '' : 'type')
    ..pPM<FieldOptionResponse>(5, _omitFieldNames ? '' : 'options',
        subBuilder: FieldOptionResponse.$_createMessage)
    ..aOB(6, _omitFieldNames ? '' : 'required')
    ..aOS(7, _omitFieldNames ? '' : 'default')
    ..pPS(8, _omitFieldNames ? '' : 'hiddenViews')
    ..aI(9, _omitFieldNames ? '' : 'position')
    ..aI(10, _omitFieldNames ? '' : 'version')
    ..aOS(11, _omitFieldNames ? '' : 'archivedAt')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Field clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Field copyWith(void Function(Field) updates) =>
      super.copyWith((message) => updates(message as Field)) as Field;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Field() / Field.new instead')
  static Field create() => Field._();
  static $pb.GeneratedMessage $_createMessage() => Field._();
  @$core.override
  Field createEmptyInstance() => Field._();
  @$core.pragma('dart2js:noInline')
  static Field getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Field>(Field.$_createMessage);
  static Field? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get projectId => $_getSZ(1);
  @$pb.TagNumber(2)
  set projectId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasProjectId() => $_has(1);
  @$pb.TagNumber(2)
  void clearProjectId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get name => $_getSZ(2);
  @$pb.TagNumber(3)
  set name($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasName() => $_has(2);
  @$pb.TagNumber(3)
  void clearName() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get type => $_getSZ(3);
  @$pb.TagNumber(4)
  set type($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasType() => $_has(3);
  @$pb.TagNumber(4)
  void clearType() => $_clearField(4);

  @$pb.TagNumber(5)
  $pb.PbList<FieldOptionResponse> get options => $_getList(4);

  @$pb.TagNumber(6)
  $core.bool get required => $_getBF(5);
  @$pb.TagNumber(6)
  set required($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasRequired() => $_has(5);
  @$pb.TagNumber(6)
  void clearRequired() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get default_7 => $_getSZ(6);
  @$pb.TagNumber(7)
  set default_7($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasDefault_7() => $_has(6);
  @$pb.TagNumber(7)
  void clearDefault_7() => $_clearField(7);

  @$pb.TagNumber(8)
  $pb.PbList<$core.String> get hiddenViews => $_getList(7);

  @$pb.TagNumber(9)
  $core.int get position => $_getIZ(8);
  @$pb.TagNumber(9)
  set position($core.int value) => $_setSignedInt32(8, value);
  @$pb.TagNumber(9)
  $core.bool hasPosition() => $_has(8);
  @$pb.TagNumber(9)
  void clearPosition() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.int get version => $_getIZ(9);
  @$pb.TagNumber(10)
  set version($core.int value) => $_setSignedInt32(9, value);
  @$pb.TagNumber(10)
  $core.bool hasVersion() => $_has(9);
  @$pb.TagNumber(10)
  void clearVersion() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.String get archivedAt => $_getSZ(10);
  @$pb.TagNumber(11)
  set archivedAt($core.String value) => $_setString(10, value);
  @$pb.TagNumber(11)
  $core.bool hasArchivedAt() => $_has(10);
  @$pb.TagNumber(11)
  void clearArchivedAt() => $_clearField(11);
}

class FieldArchiveRequest extends $pb.GeneratedMessage {
  factory FieldArchiveRequest({
    $core.String? workspaceId,
    $core.String? projectId,
    $core.String? id,
    $core.int? expectedVersion,
  }) {
    final result = FieldArchiveRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (projectId != null) result.projectId = projectId;
    if (id != null) result.id = id;
    if (expectedVersion != null) result.expectedVersion = expectedVersion;
    return result;
  }

  FieldArchiveRequest._();

  factory FieldArchiveRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FieldArchiveRequest()..mergeFromBuffer(data, registry);
  factory FieldArchiveRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FieldArchiveRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FieldArchiveRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.customfields'),
      createEmptyInstance: FieldArchiveRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..aOS(3, _omitFieldNames ? '' : 'id')
    ..aI(4, _omitFieldNames ? '' : 'expectedVersion')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FieldArchiveRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FieldArchiveRequest copyWith(void Function(FieldArchiveRequest) updates) =>
      super.copyWith((message) => updates(message as FieldArchiveRequest))
          as FieldArchiveRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core
      .Deprecated('Use FieldArchiveRequest() / FieldArchiveRequest.new instead')
  static FieldArchiveRequest create() => FieldArchiveRequest._();
  static $pb.GeneratedMessage $_createMessage() => FieldArchiveRequest._();
  @$core.override
  FieldArchiveRequest createEmptyInstance() => FieldArchiveRequest._();
  @$core.pragma('dart2js:noInline')
  static FieldArchiveRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FieldArchiveRequest>(
          FieldArchiveRequest.$_createMessage);
  static FieldArchiveRequest? _defaultInstance;

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

  @$pb.TagNumber(4)
  $core.int get expectedVersion => $_getIZ(3);
  @$pb.TagNumber(4)
  set expectedVersion($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasExpectedVersion() => $_has(3);
  @$pb.TagNumber(4)
  void clearExpectedVersion() => $_clearField(4);
}

class FieldCreateRequest extends $pb.GeneratedMessage {
  factory FieldCreateRequest({
    $core.String? workspaceId,
    $core.String? projectId,
    $core.String? name,
    $core.String? type,
    $core.Iterable<FieldOption>? options,
    $core.bool? required,
    $core.String? default_7,
    $core.Iterable<$core.String>? hiddenViews,
  }) {
    final result = FieldCreateRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (projectId != null) result.projectId = projectId;
    if (name != null) result.name = name;
    if (type != null) result.type = type;
    if (options != null) result.options.addAll(options);
    if (required != null) result.required = required;
    if (default_7 != null) result.default_7 = default_7;
    if (hiddenViews != null) result.hiddenViews.addAll(hiddenViews);
    return result;
  }

  FieldCreateRequest._();

  factory FieldCreateRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FieldCreateRequest()..mergeFromBuffer(data, registry);
  factory FieldCreateRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FieldCreateRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FieldCreateRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.customfields'),
      createEmptyInstance: FieldCreateRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..aOS(3, _omitFieldNames ? '' : 'name')
    ..aOS(4, _omitFieldNames ? '' : 'type')
    ..pPM<FieldOption>(5, _omitFieldNames ? '' : 'options',
        subBuilder: FieldOption.$_createMessage)
    ..aOB(6, _omitFieldNames ? '' : 'required')
    ..aOS(7, _omitFieldNames ? '' : 'default')
    ..pPS(8, _omitFieldNames ? '' : 'hiddenViews')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FieldCreateRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FieldCreateRequest copyWith(void Function(FieldCreateRequest) updates) =>
      super.copyWith((message) => updates(message as FieldCreateRequest))
          as FieldCreateRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use FieldCreateRequest() / FieldCreateRequest.new instead')
  static FieldCreateRequest create() => FieldCreateRequest._();
  static $pb.GeneratedMessage $_createMessage() => FieldCreateRequest._();
  @$core.override
  FieldCreateRequest createEmptyInstance() => FieldCreateRequest._();
  @$core.pragma('dart2js:noInline')
  static FieldCreateRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FieldCreateRequest>(
          FieldCreateRequest.$_createMessage);
  static FieldCreateRequest? _defaultInstance;

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
  $core.String get name => $_getSZ(2);
  @$pb.TagNumber(3)
  set name($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasName() => $_has(2);
  @$pb.TagNumber(3)
  void clearName() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get type => $_getSZ(3);
  @$pb.TagNumber(4)
  set type($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasType() => $_has(3);
  @$pb.TagNumber(4)
  void clearType() => $_clearField(4);

  @$pb.TagNumber(5)
  $pb.PbList<FieldOption> get options => $_getList(4);

  @$pb.TagNumber(6)
  $core.bool get required => $_getBF(5);
  @$pb.TagNumber(6)
  set required($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasRequired() => $_has(5);
  @$pb.TagNumber(6)
  void clearRequired() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get default_7 => $_getSZ(6);
  @$pb.TagNumber(7)
  set default_7($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasDefault_7() => $_has(6);
  @$pb.TagNumber(7)
  void clearDefault_7() => $_clearField(7);

  @$pb.TagNumber(8)
  $pb.PbList<$core.String> get hiddenViews => $_getList(7);
}

class FieldList extends $pb.GeneratedMessage {
  factory FieldList({
    $core.Iterable<Field>? fields,
  }) {
    final result = FieldList._();
    if (fields != null) result.fields.addAll(fields);
    return result;
  }

  FieldList._();

  factory FieldList.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FieldList()..mergeFromBuffer(data, registry);
  factory FieldList.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FieldList()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FieldList',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.customfields'),
      createEmptyInstance: FieldList.$_createMessage)
    ..pPM<Field>(1, _omitFieldNames ? '' : 'fields',
        subBuilder: Field.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FieldList clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FieldList copyWith(void Function(FieldList) updates) =>
      super.copyWith((message) => updates(message as FieldList)) as FieldList;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use FieldList() / FieldList.new instead')
  static FieldList create() => FieldList._();
  static $pb.GeneratedMessage $_createMessage() => FieldList._();
  @$core.override
  FieldList createEmptyInstance() => FieldList._();
  @$core.pragma('dart2js:noInline')
  static FieldList getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FieldList>(FieldList.$_createMessage);
  static FieldList? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Field> get fields => $_getList(0);
}

class FieldListRequest extends $pb.GeneratedMessage {
  factory FieldListRequest({
    $core.String? workspaceId,
    $core.String? projectId,
    $core.bool? includeArchived,
  }) {
    final result = FieldListRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (projectId != null) result.projectId = projectId;
    if (includeArchived != null) result.includeArchived = includeArchived;
    return result;
  }

  FieldListRequest._();

  factory FieldListRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FieldListRequest()..mergeFromBuffer(data, registry);
  factory FieldListRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FieldListRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FieldListRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.customfields'),
      createEmptyInstance: FieldListRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..aOB(3, _omitFieldNames ? '' : 'includeArchived')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FieldListRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FieldListRequest copyWith(void Function(FieldListRequest) updates) =>
      super.copyWith((message) => updates(message as FieldListRequest))
          as FieldListRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use FieldListRequest() / FieldListRequest.new instead')
  static FieldListRequest create() => FieldListRequest._();
  static $pb.GeneratedMessage $_createMessage() => FieldListRequest._();
  @$core.override
  FieldListRequest createEmptyInstance() => FieldListRequest._();
  @$core.pragma('dart2js:noInline')
  static FieldListRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<FieldListRequest>(
          FieldListRequest.$_createMessage);
  static FieldListRequest? _defaultInstance;

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

class FieldOption extends $pb.GeneratedMessage {
  factory FieldOption({
    $core.String? id,
    $core.String? label,
    $core.String? color,
  }) {
    final result = FieldOption._();
    if (id != null) result.id = id;
    if (label != null) result.label = label;
    if (color != null) result.color = color;
    return result;
  }

  FieldOption._();

  factory FieldOption.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FieldOption()..mergeFromBuffer(data, registry);
  factory FieldOption.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FieldOption()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FieldOption',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.customfields'),
      createEmptyInstance: FieldOption.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'label')
    ..aOS(3, _omitFieldNames ? '' : 'color')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FieldOption clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FieldOption copyWith(void Function(FieldOption) updates) =>
      super.copyWith((message) => updates(message as FieldOption))
          as FieldOption;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use FieldOption() / FieldOption.new instead')
  static FieldOption create() => FieldOption._();
  static $pb.GeneratedMessage $_createMessage() => FieldOption._();
  @$core.override
  FieldOption createEmptyInstance() => FieldOption._();
  @$core.pragma('dart2js:noInline')
  static FieldOption getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<FieldOption>(
          FieldOption.$_createMessage);
  static FieldOption? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get label => $_getSZ(1);
  @$pb.TagNumber(2)
  set label($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasLabel() => $_has(1);
  @$pb.TagNumber(2)
  void clearLabel() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get color => $_getSZ(2);
  @$pb.TagNumber(3)
  set color($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasColor() => $_has(2);
  @$pb.TagNumber(3)
  void clearColor() => $_clearField(3);
}

class FieldOptionResponse extends $pb.GeneratedMessage {
  factory FieldOptionResponse({
    $core.String? id,
    $core.String? label,
    $core.String? color,
  }) {
    final result = FieldOptionResponse._();
    if (id != null) result.id = id;
    if (label != null) result.label = label;
    if (color != null) result.color = color;
    return result;
  }

  FieldOptionResponse._();

  factory FieldOptionResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FieldOptionResponse()..mergeFromBuffer(data, registry);
  factory FieldOptionResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FieldOptionResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FieldOptionResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.customfields'),
      createEmptyInstance: FieldOptionResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'label')
    ..aOS(3, _omitFieldNames ? '' : 'color')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FieldOptionResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FieldOptionResponse copyWith(void Function(FieldOptionResponse) updates) =>
      super.copyWith((message) => updates(message as FieldOptionResponse))
          as FieldOptionResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core
      .Deprecated('Use FieldOptionResponse() / FieldOptionResponse.new instead')
  static FieldOptionResponse create() => FieldOptionResponse._();
  static $pb.GeneratedMessage $_createMessage() => FieldOptionResponse._();
  @$core.override
  FieldOptionResponse createEmptyInstance() => FieldOptionResponse._();
  @$core.pragma('dart2js:noInline')
  static FieldOptionResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FieldOptionResponse>(
          FieldOptionResponse.$_createMessage);
  static FieldOptionResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get label => $_getSZ(1);
  @$pb.TagNumber(2)
  set label($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasLabel() => $_has(1);
  @$pb.TagNumber(2)
  void clearLabel() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get color => $_getSZ(2);
  @$pb.TagNumber(3)
  set color($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasColor() => $_has(2);
  @$pb.TagNumber(3)
  void clearColor() => $_clearField(3);
}

class FieldReorderRequest extends $pb.GeneratedMessage {
  factory FieldReorderRequest({
    $core.String? workspaceId,
    $core.String? projectId,
    $core.Iterable<$core.String>? ids,
  }) {
    final result = FieldReorderRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (projectId != null) result.projectId = projectId;
    if (ids != null) result.ids.addAll(ids);
    return result;
  }

  FieldReorderRequest._();

  factory FieldReorderRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FieldReorderRequest()..mergeFromBuffer(data, registry);
  factory FieldReorderRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FieldReorderRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FieldReorderRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.customfields'),
      createEmptyInstance: FieldReorderRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..pPS(3, _omitFieldNames ? '' : 'ids')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FieldReorderRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FieldReorderRequest copyWith(void Function(FieldReorderRequest) updates) =>
      super.copyWith((message) => updates(message as FieldReorderRequest))
          as FieldReorderRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core
      .Deprecated('Use FieldReorderRequest() / FieldReorderRequest.new instead')
  static FieldReorderRequest create() => FieldReorderRequest._();
  static $pb.GeneratedMessage $_createMessage() => FieldReorderRequest._();
  @$core.override
  FieldReorderRequest createEmptyInstance() => FieldReorderRequest._();
  @$core.pragma('dart2js:noInline')
  static FieldReorderRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FieldReorderRequest>(
          FieldReorderRequest.$_createMessage);
  static FieldReorderRequest? _defaultInstance;

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
  $pb.PbList<$core.String> get ids => $_getList(2);
}

class FieldRestoreRequest extends $pb.GeneratedMessage {
  factory FieldRestoreRequest({
    $core.String? workspaceId,
    $core.String? projectId,
    $core.String? id,
    $core.int? expectedVersion,
  }) {
    final result = FieldRestoreRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (projectId != null) result.projectId = projectId;
    if (id != null) result.id = id;
    if (expectedVersion != null) result.expectedVersion = expectedVersion;
    return result;
  }

  FieldRestoreRequest._();

  factory FieldRestoreRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FieldRestoreRequest()..mergeFromBuffer(data, registry);
  factory FieldRestoreRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FieldRestoreRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FieldRestoreRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.customfields'),
      createEmptyInstance: FieldRestoreRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..aOS(3, _omitFieldNames ? '' : 'id')
    ..aI(4, _omitFieldNames ? '' : 'expectedVersion')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FieldRestoreRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FieldRestoreRequest copyWith(void Function(FieldRestoreRequest) updates) =>
      super.copyWith((message) => updates(message as FieldRestoreRequest))
          as FieldRestoreRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core
      .Deprecated('Use FieldRestoreRequest() / FieldRestoreRequest.new instead')
  static FieldRestoreRequest create() => FieldRestoreRequest._();
  static $pb.GeneratedMessage $_createMessage() => FieldRestoreRequest._();
  @$core.override
  FieldRestoreRequest createEmptyInstance() => FieldRestoreRequest._();
  @$core.pragma('dart2js:noInline')
  static FieldRestoreRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FieldRestoreRequest>(
          FieldRestoreRequest.$_createMessage);
  static FieldRestoreRequest? _defaultInstance;

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

  @$pb.TagNumber(4)
  $core.int get expectedVersion => $_getIZ(3);
  @$pb.TagNumber(4)
  set expectedVersion($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasExpectedVersion() => $_has(3);
  @$pb.TagNumber(4)
  void clearExpectedVersion() => $_clearField(4);
}

class FieldUpdateRequest extends $pb.GeneratedMessage {
  factory FieldUpdateRequest({
    $core.String? workspaceId,
    $core.String? projectId,
    $core.String? id,
    $core.int? expectedVersion,
    $core.String? name,
    $core.String? type,
    $core.String? default_7,
    $core.bool? required,
    $core.bool? setOptions,
    $core.Iterable<FieldOption>? options,
    $core.bool? setHiddenViews,
    $core.Iterable<$core.String>? hiddenViews,
    $core.Iterable<OptionRemap>? remaps,
  }) {
    final result = FieldUpdateRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (projectId != null) result.projectId = projectId;
    if (id != null) result.id = id;
    if (expectedVersion != null) result.expectedVersion = expectedVersion;
    if (name != null) result.name = name;
    if (type != null) result.type = type;
    if (default_7 != null) result.default_7 = default_7;
    if (required != null) result.required = required;
    if (setOptions != null) result.setOptions = setOptions;
    if (options != null) result.options.addAll(options);
    if (setHiddenViews != null) result.setHiddenViews = setHiddenViews;
    if (hiddenViews != null) result.hiddenViews.addAll(hiddenViews);
    if (remaps != null) result.remaps.addAll(remaps);
    return result;
  }

  FieldUpdateRequest._();

  factory FieldUpdateRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FieldUpdateRequest()..mergeFromBuffer(data, registry);
  factory FieldUpdateRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FieldUpdateRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FieldUpdateRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.customfields'),
      createEmptyInstance: FieldUpdateRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..aOS(3, _omitFieldNames ? '' : 'id')
    ..aI(4, _omitFieldNames ? '' : 'expectedVersion')
    ..aOS(5, _omitFieldNames ? '' : 'name')
    ..aOS(6, _omitFieldNames ? '' : 'type')
    ..aOS(7, _omitFieldNames ? '' : 'default')
    ..aOB(8, _omitFieldNames ? '' : 'required')
    ..aOB(9, _omitFieldNames ? '' : 'setOptions')
    ..pPM<FieldOption>(10, _omitFieldNames ? '' : 'options',
        subBuilder: FieldOption.$_createMessage)
    ..aOB(11, _omitFieldNames ? '' : 'setHiddenViews')
    ..pPS(12, _omitFieldNames ? '' : 'hiddenViews')
    ..pPM<OptionRemap>(13, _omitFieldNames ? '' : 'remaps',
        subBuilder: OptionRemap.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FieldUpdateRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FieldUpdateRequest copyWith(void Function(FieldUpdateRequest) updates) =>
      super.copyWith((message) => updates(message as FieldUpdateRequest))
          as FieldUpdateRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use FieldUpdateRequest() / FieldUpdateRequest.new instead')
  static FieldUpdateRequest create() => FieldUpdateRequest._();
  static $pb.GeneratedMessage $_createMessage() => FieldUpdateRequest._();
  @$core.override
  FieldUpdateRequest createEmptyInstance() => FieldUpdateRequest._();
  @$core.pragma('dart2js:noInline')
  static FieldUpdateRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FieldUpdateRequest>(
          FieldUpdateRequest.$_createMessage);
  static FieldUpdateRequest? _defaultInstance;

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

  @$pb.TagNumber(4)
  $core.int get expectedVersion => $_getIZ(3);
  @$pb.TagNumber(4)
  set expectedVersion($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasExpectedVersion() => $_has(3);
  @$pb.TagNumber(4)
  void clearExpectedVersion() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get name => $_getSZ(4);
  @$pb.TagNumber(5)
  set name($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasName() => $_has(4);
  @$pb.TagNumber(5)
  void clearName() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get type => $_getSZ(5);
  @$pb.TagNumber(6)
  set type($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasType() => $_has(5);
  @$pb.TagNumber(6)
  void clearType() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get default_7 => $_getSZ(6);
  @$pb.TagNumber(7)
  set default_7($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasDefault_7() => $_has(6);
  @$pb.TagNumber(7)
  void clearDefault_7() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.bool get required => $_getBF(7);
  @$pb.TagNumber(8)
  set required($core.bool value) => $_setBool(7, value);
  @$pb.TagNumber(8)
  $core.bool hasRequired() => $_has(7);
  @$pb.TagNumber(8)
  void clearRequired() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.bool get setOptions => $_getBF(8);
  @$pb.TagNumber(9)
  set setOptions($core.bool value) => $_setBool(8, value);
  @$pb.TagNumber(9)
  $core.bool hasSetOptions() => $_has(8);
  @$pb.TagNumber(9)
  void clearSetOptions() => $_clearField(9);

  @$pb.TagNumber(10)
  $pb.PbList<FieldOption> get options => $_getList(9);

  @$pb.TagNumber(11)
  $core.bool get setHiddenViews => $_getBF(10);
  @$pb.TagNumber(11)
  set setHiddenViews($core.bool value) => $_setBool(10, value);
  @$pb.TagNumber(11)
  $core.bool hasSetHiddenViews() => $_has(10);
  @$pb.TagNumber(11)
  void clearSetHiddenViews() => $_clearField(11);

  @$pb.TagNumber(12)
  $pb.PbList<$core.String> get hiddenViews => $_getList(11);

  @$pb.TagNumber(13)
  $pb.PbList<OptionRemap> get remaps => $_getList(12);
}

class OptionRemap extends $pb.GeneratedMessage {
  factory OptionRemap({
    $core.String? fromOption,
    $core.String? toOption,
  }) {
    final result = OptionRemap._();
    if (fromOption != null) result.fromOption = fromOption;
    if (toOption != null) result.toOption = toOption;
    return result;
  }

  OptionRemap._();

  factory OptionRemap.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      OptionRemap()..mergeFromBuffer(data, registry);
  factory OptionRemap.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      OptionRemap()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'OptionRemap',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.customfields'),
      createEmptyInstance: OptionRemap.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'fromOption')
    ..aOS(2, _omitFieldNames ? '' : 'toOption')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OptionRemap clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OptionRemap copyWith(void Function(OptionRemap) updates) =>
      super.copyWith((message) => updates(message as OptionRemap))
          as OptionRemap;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use OptionRemap() / OptionRemap.new instead')
  static OptionRemap create() => OptionRemap._();
  static $pb.GeneratedMessage $_createMessage() => OptionRemap._();
  @$core.override
  OptionRemap createEmptyInstance() => OptionRemap._();
  @$core.pragma('dart2js:noInline')
  static OptionRemap getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<OptionRemap>(
          OptionRemap.$_createMessage);
  static OptionRemap? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get fromOption => $_getSZ(0);
  @$pb.TagNumber(1)
  set fromOption($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFromOption() => $_has(0);
  @$pb.TagNumber(1)
  void clearFromOption() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get toOption => $_getSZ(1);
  @$pb.TagNumber(2)
  set toOption($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasToOption() => $_has(1);
  @$pb.TagNumber(2)
  void clearToOption() => $_clearField(2);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
