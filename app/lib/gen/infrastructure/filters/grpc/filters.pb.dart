// This is a generated file - do not edit.
//
// Generated from infrastructure/filters/grpc/filters.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class Filter extends $pb.GeneratedMessage {
  factory Filter({
    $core.String? id,
    $core.String? projectId,
    $core.String? ownerId,
    $core.String? name,
    $core.String? visibility,
    $core.String? astJson,
    $core.String? tfql,
    $core.int? version,
    $core.String? updatedAt,
  }) {
    final result = Filter._();
    if (id != null) result.id = id;
    if (projectId != null) result.projectId = projectId;
    if (ownerId != null) result.ownerId = ownerId;
    if (name != null) result.name = name;
    if (visibility != null) result.visibility = visibility;
    if (astJson != null) result.astJson = astJson;
    if (tfql != null) result.tfql = tfql;
    if (version != null) result.version = version;
    if (updatedAt != null) result.updatedAt = updatedAt;
    return result;
  }

  Filter._();

  factory Filter.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Filter()..mergeFromBuffer(data, registry);
  factory Filter.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Filter()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Filter',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.filters'),
      createEmptyInstance: Filter.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..aOS(3, _omitFieldNames ? '' : 'ownerId')
    ..aOS(4, _omitFieldNames ? '' : 'name')
    ..aOS(5, _omitFieldNames ? '' : 'visibility')
    ..aOS(6, _omitFieldNames ? '' : 'astJson')
    ..aOS(7, _omitFieldNames ? '' : 'tfql')
    ..aI(8, _omitFieldNames ? '' : 'version')
    ..aOS(9, _omitFieldNames ? '' : 'updatedAt')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Filter clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Filter copyWith(void Function(Filter) updates) =>
      super.copyWith((message) => updates(message as Filter)) as Filter;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Filter() / Filter.new instead')
  static Filter create() => Filter._();
  static $pb.GeneratedMessage $_createMessage() => Filter._();
  @$core.override
  Filter createEmptyInstance() => Filter._();
  @$core.pragma('dart2js:noInline')
  static Filter getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Filter>(Filter.$_createMessage);
  static Filter? _defaultInstance;

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
  $core.String get ownerId => $_getSZ(2);
  @$pb.TagNumber(3)
  set ownerId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasOwnerId() => $_has(2);
  @$pb.TagNumber(3)
  void clearOwnerId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get name => $_getSZ(3);
  @$pb.TagNumber(4)
  set name($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasName() => $_has(3);
  @$pb.TagNumber(4)
  void clearName() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get visibility => $_getSZ(4);
  @$pb.TagNumber(5)
  set visibility($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasVisibility() => $_has(4);
  @$pb.TagNumber(5)
  void clearVisibility() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get astJson => $_getSZ(5);
  @$pb.TagNumber(6)
  set astJson($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasAstJson() => $_has(5);
  @$pb.TagNumber(6)
  void clearAstJson() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get tfql => $_getSZ(6);
  @$pb.TagNumber(7)
  set tfql($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasTfql() => $_has(6);
  @$pb.TagNumber(7)
  void clearTfql() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.int get version => $_getIZ(7);
  @$pb.TagNumber(8)
  set version($core.int value) => $_setSignedInt32(7, value);
  @$pb.TagNumber(8)
  $core.bool hasVersion() => $_has(7);
  @$pb.TagNumber(8)
  void clearVersion() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get updatedAt => $_getSZ(8);
  @$pb.TagNumber(9)
  set updatedAt($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasUpdatedAt() => $_has(8);
  @$pb.TagNumber(9)
  void clearUpdatedAt() => $_clearField(9);
}

class FilterDeleteRequest extends $pb.GeneratedMessage {
  factory FilterDeleteRequest({
    $core.String? workspaceId,
    $core.String? projectId,
    $core.String? id,
  }) {
    final result = FilterDeleteRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (projectId != null) result.projectId = projectId;
    if (id != null) result.id = id;
    return result;
  }

  FilterDeleteRequest._();

  factory FilterDeleteRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FilterDeleteRequest()..mergeFromBuffer(data, registry);
  factory FilterDeleteRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FilterDeleteRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FilterDeleteRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.filters'),
      createEmptyInstance: FilterDeleteRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..aOS(3, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FilterDeleteRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FilterDeleteRequest copyWith(void Function(FilterDeleteRequest) updates) =>
      super.copyWith((message) => updates(message as FilterDeleteRequest))
          as FilterDeleteRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core
      .Deprecated('Use FilterDeleteRequest() / FilterDeleteRequest.new instead')
  static FilterDeleteRequest create() => FilterDeleteRequest._();
  static $pb.GeneratedMessage $_createMessage() => FilterDeleteRequest._();
  @$core.override
  FilterDeleteRequest createEmptyInstance() => FilterDeleteRequest._();
  @$core.pragma('dart2js:noInline')
  static FilterDeleteRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FilterDeleteRequest>(
          FilterDeleteRequest.$_createMessage);
  static FilterDeleteRequest? _defaultInstance;

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

class FilterList extends $pb.GeneratedMessage {
  factory FilterList({
    $core.Iterable<Filter>? filters,
  }) {
    final result = FilterList._();
    if (filters != null) result.filters.addAll(filters);
    return result;
  }

  FilterList._();

  factory FilterList.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FilterList()..mergeFromBuffer(data, registry);
  factory FilterList.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FilterList()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FilterList',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.filters'),
      createEmptyInstance: FilterList.$_createMessage)
    ..pPM<Filter>(1, _omitFieldNames ? '' : 'filters',
        subBuilder: Filter.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FilterList clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FilterList copyWith(void Function(FilterList) updates) =>
      super.copyWith((message) => updates(message as FilterList)) as FilterList;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use FilterList() / FilterList.new instead')
  static FilterList create() => FilterList._();
  static $pb.GeneratedMessage $_createMessage() => FilterList._();
  @$core.override
  FilterList createEmptyInstance() => FilterList._();
  @$core.pragma('dart2js:noInline')
  static FilterList getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FilterList>(FilterList.$_createMessage);
  static FilterList? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Filter> get filters => $_getList(0);
}

class FilterListRequest extends $pb.GeneratedMessage {
  factory FilterListRequest({
    $core.String? workspaceId,
    $core.String? projectId,
  }) {
    final result = FilterListRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (projectId != null) result.projectId = projectId;
    return result;
  }

  FilterListRequest._();

  factory FilterListRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FilterListRequest()..mergeFromBuffer(data, registry);
  factory FilterListRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FilterListRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FilterListRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.filters'),
      createEmptyInstance: FilterListRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FilterListRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FilterListRequest copyWith(void Function(FilterListRequest) updates) =>
      super.copyWith((message) => updates(message as FilterListRequest))
          as FilterListRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use FilterListRequest() / FilterListRequest.new instead')
  static FilterListRequest create() => FilterListRequest._();
  static $pb.GeneratedMessage $_createMessage() => FilterListRequest._();
  @$core.override
  FilterListRequest createEmptyInstance() => FilterListRequest._();
  @$core.pragma('dart2js:noInline')
  static FilterListRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<FilterListRequest>(
          FilterListRequest.$_createMessage);
  static FilterListRequest? _defaultInstance;

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
}

class FilterSaveRequest extends $pb.GeneratedMessage {
  factory FilterSaveRequest({
    $core.String? workspaceId,
    $core.String? projectId,
    $core.String? id,
    $core.int? expectedVersion,
    $core.String? name,
    $core.String? tfql,
    $core.String? astJson,
    $core.String? visibility,
  }) {
    final result = FilterSaveRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (projectId != null) result.projectId = projectId;
    if (id != null) result.id = id;
    if (expectedVersion != null) result.expectedVersion = expectedVersion;
    if (name != null) result.name = name;
    if (tfql != null) result.tfql = tfql;
    if (astJson != null) result.astJson = astJson;
    if (visibility != null) result.visibility = visibility;
    return result;
  }

  FilterSaveRequest._();

  factory FilterSaveRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FilterSaveRequest()..mergeFromBuffer(data, registry);
  factory FilterSaveRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FilterSaveRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FilterSaveRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.filters'),
      createEmptyInstance: FilterSaveRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..aOS(3, _omitFieldNames ? '' : 'id')
    ..aI(4, _omitFieldNames ? '' : 'expectedVersion')
    ..aOS(5, _omitFieldNames ? '' : 'name')
    ..aOS(6, _omitFieldNames ? '' : 'tfql')
    ..aOS(7, _omitFieldNames ? '' : 'astJson')
    ..aOS(8, _omitFieldNames ? '' : 'visibility')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FilterSaveRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FilterSaveRequest copyWith(void Function(FilterSaveRequest) updates) =>
      super.copyWith((message) => updates(message as FilterSaveRequest))
          as FilterSaveRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use FilterSaveRequest() / FilterSaveRequest.new instead')
  static FilterSaveRequest create() => FilterSaveRequest._();
  static $pb.GeneratedMessage $_createMessage() => FilterSaveRequest._();
  @$core.override
  FilterSaveRequest createEmptyInstance() => FilterSaveRequest._();
  @$core.pragma('dart2js:noInline')
  static FilterSaveRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<FilterSaveRequest>(
          FilterSaveRequest.$_createMessage);
  static FilterSaveRequest? _defaultInstance;

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
  $core.String get tfql => $_getSZ(5);
  @$pb.TagNumber(6)
  set tfql($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasTfql() => $_has(5);
  @$pb.TagNumber(6)
  void clearTfql() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get astJson => $_getSZ(6);
  @$pb.TagNumber(7)
  set astJson($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasAstJson() => $_has(6);
  @$pb.TagNumber(7)
  void clearAstJson() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get visibility => $_getSZ(7);
  @$pb.TagNumber(8)
  set visibility($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasVisibility() => $_has(7);
  @$pb.TagNumber(8)
  void clearVisibility() => $_clearField(8);
}

class QueryChecked extends $pb.GeneratedMessage {
  factory QueryChecked({
    $core.bool? ok,
    $core.String? astJson,
    $core.String? tfql,
    $core.Iterable<QueryProblem>? errors,
  }) {
    final result = QueryChecked._();
    if (ok != null) result.ok = ok;
    if (astJson != null) result.astJson = astJson;
    if (tfql != null) result.tfql = tfql;
    if (errors != null) result.errors.addAll(errors);
    return result;
  }

  QueryChecked._();

  factory QueryChecked.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      QueryChecked()..mergeFromBuffer(data, registry);
  factory QueryChecked.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      QueryChecked()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'QueryChecked',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.filters'),
      createEmptyInstance: QueryChecked.$_createMessage)
    ..aOB(1, _omitFieldNames ? '' : 'ok')
    ..aOS(2, _omitFieldNames ? '' : 'astJson')
    ..aOS(3, _omitFieldNames ? '' : 'tfql')
    ..pPM<QueryProblem>(4, _omitFieldNames ? '' : 'errors',
        subBuilder: QueryProblem.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  QueryChecked clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  QueryChecked copyWith(void Function(QueryChecked) updates) =>
      super.copyWith((message) => updates(message as QueryChecked))
          as QueryChecked;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use QueryChecked() / QueryChecked.new instead')
  static QueryChecked create() => QueryChecked._();
  static $pb.GeneratedMessage $_createMessage() => QueryChecked._();
  @$core.override
  QueryChecked createEmptyInstance() => QueryChecked._();
  @$core.pragma('dart2js:noInline')
  static QueryChecked getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<QueryChecked>(
          QueryChecked.$_createMessage);
  static QueryChecked? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get ok => $_getBF(0);
  @$pb.TagNumber(1)
  set ok($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasOk() => $_has(0);
  @$pb.TagNumber(1)
  void clearOk() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get astJson => $_getSZ(1);
  @$pb.TagNumber(2)
  set astJson($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAstJson() => $_has(1);
  @$pb.TagNumber(2)
  void clearAstJson() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get tfql => $_getSZ(2);
  @$pb.TagNumber(3)
  set tfql($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTfql() => $_has(2);
  @$pb.TagNumber(3)
  void clearTfql() => $_clearField(3);

  @$pb.TagNumber(4)
  $pb.PbList<QueryProblem> get errors => $_getList(3);
}

class QueryProblem extends $pb.GeneratedMessage {
  factory QueryProblem({
    $core.int? position,
    $core.int? length,
    $core.String? message,
  }) {
    final result = QueryProblem._();
    if (position != null) result.position = position;
    if (length != null) result.length = length;
    if (message != null) result.message = message;
    return result;
  }

  QueryProblem._();

  factory QueryProblem.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      QueryProblem()..mergeFromBuffer(data, registry);
  factory QueryProblem.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      QueryProblem()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'QueryProblem',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.filters'),
      createEmptyInstance: QueryProblem.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'position')
    ..aI(2, _omitFieldNames ? '' : 'length')
    ..aOS(3, _omitFieldNames ? '' : 'message')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  QueryProblem clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  QueryProblem copyWith(void Function(QueryProblem) updates) =>
      super.copyWith((message) => updates(message as QueryProblem))
          as QueryProblem;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use QueryProblem() / QueryProblem.new instead')
  static QueryProblem create() => QueryProblem._();
  static $pb.GeneratedMessage $_createMessage() => QueryProblem._();
  @$core.override
  QueryProblem createEmptyInstance() => QueryProblem._();
  @$core.pragma('dart2js:noInline')
  static QueryProblem getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<QueryProblem>(
          QueryProblem.$_createMessage);
  static QueryProblem? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get position => $_getIZ(0);
  @$pb.TagNumber(1)
  set position($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPosition() => $_has(0);
  @$pb.TagNumber(1)
  void clearPosition() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get length => $_getIZ(1);
  @$pb.TagNumber(2)
  set length($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasLength() => $_has(1);
  @$pb.TagNumber(2)
  void clearLength() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get message => $_getSZ(2);
  @$pb.TagNumber(3)
  set message($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasMessage() => $_has(2);
  @$pb.TagNumber(3)
  void clearMessage() => $_clearField(3);
}

class QuerySuggestRequest extends $pb.GeneratedMessage {
  factory QuerySuggestRequest({
    $core.String? workspaceId,
    $core.String? projectId,
    $core.String? partial,
    $core.int? cursor,
  }) {
    final result = QuerySuggestRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (projectId != null) result.projectId = projectId;
    if (partial != null) result.partial = partial;
    if (cursor != null) result.cursor = cursor;
    return result;
  }

  QuerySuggestRequest._();

  factory QuerySuggestRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      QuerySuggestRequest()..mergeFromBuffer(data, registry);
  factory QuerySuggestRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      QuerySuggestRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'QuerySuggestRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.filters'),
      createEmptyInstance: QuerySuggestRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..aOS(3, _omitFieldNames ? '' : 'partial')
    ..aI(4, _omitFieldNames ? '' : 'cursor')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  QuerySuggestRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  QuerySuggestRequest copyWith(void Function(QuerySuggestRequest) updates) =>
      super.copyWith((message) => updates(message as QuerySuggestRequest))
          as QuerySuggestRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core
      .Deprecated('Use QuerySuggestRequest() / QuerySuggestRequest.new instead')
  static QuerySuggestRequest create() => QuerySuggestRequest._();
  static $pb.GeneratedMessage $_createMessage() => QuerySuggestRequest._();
  @$core.override
  QuerySuggestRequest createEmptyInstance() => QuerySuggestRequest._();
  @$core.pragma('dart2js:noInline')
  static QuerySuggestRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<QuerySuggestRequest>(
          QuerySuggestRequest.$_createMessage);
  static QuerySuggestRequest? _defaultInstance;

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
  $core.String get partial => $_getSZ(2);
  @$pb.TagNumber(3)
  set partial($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPartial() => $_has(2);
  @$pb.TagNumber(3)
  void clearPartial() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get cursor => $_getIZ(3);
  @$pb.TagNumber(4)
  set cursor($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasCursor() => $_has(3);
  @$pb.TagNumber(4)
  void clearCursor() => $_clearField(4);
}

class QuerySuggestion extends $pb.GeneratedMessage {
  factory QuerySuggestion({
    $core.String? text,
    $core.String? kind,
    $core.int? start,
    $core.String? label,
  }) {
    final result = QuerySuggestion._();
    if (text != null) result.text = text;
    if (kind != null) result.kind = kind;
    if (start != null) result.start = start;
    if (label != null) result.label = label;
    return result;
  }

  QuerySuggestion._();

  factory QuerySuggestion.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      QuerySuggestion()..mergeFromBuffer(data, registry);
  factory QuerySuggestion.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      QuerySuggestion()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'QuerySuggestion',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.filters'),
      createEmptyInstance: QuerySuggestion.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'text')
    ..aOS(2, _omitFieldNames ? '' : 'kind')
    ..aI(3, _omitFieldNames ? '' : 'start')
    ..aOS(4, _omitFieldNames ? '' : 'label')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  QuerySuggestion clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  QuerySuggestion copyWith(void Function(QuerySuggestion) updates) =>
      super.copyWith((message) => updates(message as QuerySuggestion))
          as QuerySuggestion;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use QuerySuggestion() / QuerySuggestion.new instead')
  static QuerySuggestion create() => QuerySuggestion._();
  static $pb.GeneratedMessage $_createMessage() => QuerySuggestion._();
  @$core.override
  QuerySuggestion createEmptyInstance() => QuerySuggestion._();
  @$core.pragma('dart2js:noInline')
  static QuerySuggestion getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<QuerySuggestion>(
          QuerySuggestion.$_createMessage);
  static QuerySuggestion? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get text => $_getSZ(0);
  @$pb.TagNumber(1)
  set text($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasText() => $_has(0);
  @$pb.TagNumber(1)
  void clearText() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get kind => $_getSZ(1);
  @$pb.TagNumber(2)
  set kind($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasKind() => $_has(1);
  @$pb.TagNumber(2)
  void clearKind() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get start => $_getIZ(2);
  @$pb.TagNumber(3)
  set start($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasStart() => $_has(2);
  @$pb.TagNumber(3)
  void clearStart() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get label => $_getSZ(3);
  @$pb.TagNumber(4)
  set label($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasLabel() => $_has(3);
  @$pb.TagNumber(4)
  void clearLabel() => $_clearField(4);
}

class QuerySuggestions extends $pb.GeneratedMessage {
  factory QuerySuggestions({
    $core.Iterable<QuerySuggestion>? items,
  }) {
    final result = QuerySuggestions._();
    if (items != null) result.items.addAll(items);
    return result;
  }

  QuerySuggestions._();

  factory QuerySuggestions.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      QuerySuggestions()..mergeFromBuffer(data, registry);
  factory QuerySuggestions.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      QuerySuggestions()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'QuerySuggestions',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.filters'),
      createEmptyInstance: QuerySuggestions.$_createMessage)
    ..pPM<QuerySuggestion>(1, _omitFieldNames ? '' : 'items',
        subBuilder: QuerySuggestion.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  QuerySuggestions clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  QuerySuggestions copyWith(void Function(QuerySuggestions) updates) =>
      super.copyWith((message) => updates(message as QuerySuggestions))
          as QuerySuggestions;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use QuerySuggestions() / QuerySuggestions.new instead')
  static QuerySuggestions create() => QuerySuggestions._();
  static $pb.GeneratedMessage $_createMessage() => QuerySuggestions._();
  @$core.override
  QuerySuggestions createEmptyInstance() => QuerySuggestions._();
  @$core.pragma('dart2js:noInline')
  static QuerySuggestions getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<QuerySuggestions>(
          QuerySuggestions.$_createMessage);
  static QuerySuggestions? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<QuerySuggestion> get items => $_getList(0);
}

class QueryValidateRequest extends $pb.GeneratedMessage {
  factory QueryValidateRequest({
    $core.String? workspaceId,
    $core.String? projectId,
    $core.String? tfql,
    $core.String? astJson,
  }) {
    final result = QueryValidateRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (projectId != null) result.projectId = projectId;
    if (tfql != null) result.tfql = tfql;
    if (astJson != null) result.astJson = astJson;
    return result;
  }

  QueryValidateRequest._();

  factory QueryValidateRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      QueryValidateRequest()..mergeFromBuffer(data, registry);
  factory QueryValidateRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      QueryValidateRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'QueryValidateRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.filters'),
      createEmptyInstance: QueryValidateRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..aOS(3, _omitFieldNames ? '' : 'tfql')
    ..aOS(4, _omitFieldNames ? '' : 'astJson')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  QueryValidateRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  QueryValidateRequest copyWith(void Function(QueryValidateRequest) updates) =>
      super.copyWith((message) => updates(message as QueryValidateRequest))
          as QueryValidateRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use QueryValidateRequest() / QueryValidateRequest.new instead')
  static QueryValidateRequest create() => QueryValidateRequest._();
  static $pb.GeneratedMessage $_createMessage() => QueryValidateRequest._();
  @$core.override
  QueryValidateRequest createEmptyInstance() => QueryValidateRequest._();
  @$core.pragma('dart2js:noInline')
  static QueryValidateRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<QueryValidateRequest>(
          QueryValidateRequest.$_createMessage);
  static QueryValidateRequest? _defaultInstance;

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
  $core.String get tfql => $_getSZ(2);
  @$pb.TagNumber(3)
  set tfql($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTfql() => $_has(2);
  @$pb.TagNumber(3)
  void clearTfql() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get astJson => $_getSZ(3);
  @$pb.TagNumber(4)
  set astJson($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasAstJson() => $_has(3);
  @$pb.TagNumber(4)
  void clearAstJson() => $_clearField(4);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
