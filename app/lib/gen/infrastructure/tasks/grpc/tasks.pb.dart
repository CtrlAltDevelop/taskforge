// This is a generated file - do not edit.
//
// Generated from infrastructure/tasks/grpc/tasks.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class BoardColumn extends $pb.GeneratedMessage {
  factory BoardColumn({
    $core.String? key,
    $core.String? name,
    $core.int? count,
    $core.Iterable<Task>? tasks,
    $core.String? cursor,
  }) {
    final result = BoardColumn._();
    if (key != null) result.key = key;
    if (name != null) result.name = name;
    if (count != null) result.count = count;
    if (tasks != null) result.tasks.addAll(tasks);
    if (cursor != null) result.cursor = cursor;
    return result;
  }

  BoardColumn._();

  factory BoardColumn.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BoardColumn()..mergeFromBuffer(data, registry);
  factory BoardColumn.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BoardColumn()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'BoardColumn',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.tasks'),
      createEmptyInstance: BoardColumn.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'key')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aI(3, _omitFieldNames ? '' : 'count')
    ..pPM<Task>(4, _omitFieldNames ? '' : 'tasks',
        subBuilder: Task.$_createMessage)
    ..aOS(5, _omitFieldNames ? '' : 'cursor')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BoardColumn clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BoardColumn copyWith(void Function(BoardColumn) updates) =>
      super.copyWith((message) => updates(message as BoardColumn))
          as BoardColumn;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use BoardColumn() / BoardColumn.new instead')
  static BoardColumn create() => BoardColumn._();
  static $pb.GeneratedMessage $_createMessage() => BoardColumn._();
  @$core.override
  BoardColumn createEmptyInstance() => BoardColumn._();
  @$core.pragma('dart2js:noInline')
  static BoardColumn getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<BoardColumn>(
          BoardColumn.$_createMessage);
  static BoardColumn? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get key => $_getSZ(0);
  @$pb.TagNumber(1)
  set key($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasKey() => $_has(0);
  @$pb.TagNumber(1)
  void clearKey() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get count => $_getIZ(2);
  @$pb.TagNumber(3)
  set count($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasCount() => $_has(2);
  @$pb.TagNumber(3)
  void clearCount() => $_clearField(3);

  @$pb.TagNumber(4)
  $pb.PbList<Task> get tasks => $_getList(3);

  @$pb.TagNumber(5)
  $core.String get cursor => $_getSZ(4);
  @$pb.TagNumber(5)
  set cursor($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasCursor() => $_has(4);
  @$pb.TagNumber(5)
  void clearCursor() => $_clearField(5);
}

class BoardGetRequest extends $pb.GeneratedMessage {
  factory BoardGetRequest({
    $core.String? workspaceId,
    $core.String? projectId,
    $core.String? groupBy,
    $core.String? swimlane,
    $core.int? pageSize,
    $core.String? filterAst,
    $core.String? today,
  }) {
    final result = BoardGetRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (projectId != null) result.projectId = projectId;
    if (groupBy != null) result.groupBy = groupBy;
    if (swimlane != null) result.swimlane = swimlane;
    if (pageSize != null) result.pageSize = pageSize;
    if (filterAst != null) result.filterAst = filterAst;
    if (today != null) result.today = today;
    return result;
  }

  BoardGetRequest._();

  factory BoardGetRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BoardGetRequest()..mergeFromBuffer(data, registry);
  factory BoardGetRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BoardGetRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'BoardGetRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.tasks'),
      createEmptyInstance: BoardGetRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..aOS(3, _omitFieldNames ? '' : 'groupBy')
    ..aOS(4, _omitFieldNames ? '' : 'swimlane')
    ..aI(5, _omitFieldNames ? '' : 'pageSize')
    ..aOS(6, _omitFieldNames ? '' : 'filterAst')
    ..aOS(7, _omitFieldNames ? '' : 'today')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BoardGetRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BoardGetRequest copyWith(void Function(BoardGetRequest) updates) =>
      super.copyWith((message) => updates(message as BoardGetRequest))
          as BoardGetRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use BoardGetRequest() / BoardGetRequest.new instead')
  static BoardGetRequest create() => BoardGetRequest._();
  static $pb.GeneratedMessage $_createMessage() => BoardGetRequest._();
  @$core.override
  BoardGetRequest createEmptyInstance() => BoardGetRequest._();
  @$core.pragma('dart2js:noInline')
  static BoardGetRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<BoardGetRequest>(
          BoardGetRequest.$_createMessage);
  static BoardGetRequest? _defaultInstance;

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
  $core.String get groupBy => $_getSZ(2);
  @$pb.TagNumber(3)
  set groupBy($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasGroupBy() => $_has(2);
  @$pb.TagNumber(3)
  void clearGroupBy() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get swimlane => $_getSZ(3);
  @$pb.TagNumber(4)
  set swimlane($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSwimlane() => $_has(3);
  @$pb.TagNumber(4)
  void clearSwimlane() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get pageSize => $_getIZ(4);
  @$pb.TagNumber(5)
  set pageSize($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasPageSize() => $_has(4);
  @$pb.TagNumber(5)
  void clearPageSize() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get filterAst => $_getSZ(5);
  @$pb.TagNumber(6)
  set filterAst($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasFilterAst() => $_has(5);
  @$pb.TagNumber(6)
  void clearFilterAst() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get today => $_getSZ(6);
  @$pb.TagNumber(7)
  set today($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasToday() => $_has(6);
  @$pb.TagNumber(7)
  void clearToday() => $_clearField(7);
}

class BoardLane extends $pb.GeneratedMessage {
  factory BoardLane({
    $core.String? key,
    $core.Iterable<BoardColumn>? columns,
  }) {
    final result = BoardLane._();
    if (key != null) result.key = key;
    if (columns != null) result.columns.addAll(columns);
    return result;
  }

  BoardLane._();

  factory BoardLane.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BoardLane()..mergeFromBuffer(data, registry);
  factory BoardLane.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BoardLane()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'BoardLane',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.tasks'),
      createEmptyInstance: BoardLane.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'key')
    ..pPM<BoardColumn>(2, _omitFieldNames ? '' : 'columns',
        subBuilder: BoardColumn.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BoardLane clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BoardLane copyWith(void Function(BoardLane) updates) =>
      super.copyWith((message) => updates(message as BoardLane)) as BoardLane;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use BoardLane() / BoardLane.new instead')
  static BoardLane create() => BoardLane._();
  static $pb.GeneratedMessage $_createMessage() => BoardLane._();
  @$core.override
  BoardLane createEmptyInstance() => BoardLane._();
  @$core.pragma('dart2js:noInline')
  static BoardLane getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<BoardLane>(BoardLane.$_createMessage);
  static BoardLane? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get key => $_getSZ(0);
  @$pb.TagNumber(1)
  set key($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasKey() => $_has(0);
  @$pb.TagNumber(1)
  void clearKey() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<BoardColumn> get columns => $_getList(1);
}

class BoardListColumnRequest extends $pb.GeneratedMessage {
  factory BoardListColumnRequest({
    $core.String? workspaceId,
    $core.String? projectId,
    $core.String? groupBy,
    $core.String? swimlane,
    $core.int? pageSize,
    $core.String? column,
    $core.String? lane,
    $core.String? cursor,
    $core.String? filterAst,
    $core.String? today,
  }) {
    final result = BoardListColumnRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (projectId != null) result.projectId = projectId;
    if (groupBy != null) result.groupBy = groupBy;
    if (swimlane != null) result.swimlane = swimlane;
    if (pageSize != null) result.pageSize = pageSize;
    if (column != null) result.column = column;
    if (lane != null) result.lane = lane;
    if (cursor != null) result.cursor = cursor;
    if (filterAst != null) result.filterAst = filterAst;
    if (today != null) result.today = today;
    return result;
  }

  BoardListColumnRequest._();

  factory BoardListColumnRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BoardListColumnRequest()..mergeFromBuffer(data, registry);
  factory BoardListColumnRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BoardListColumnRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'BoardListColumnRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.tasks'),
      createEmptyInstance: BoardListColumnRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..aOS(3, _omitFieldNames ? '' : 'groupBy')
    ..aOS(4, _omitFieldNames ? '' : 'swimlane')
    ..aI(5, _omitFieldNames ? '' : 'pageSize')
    ..aOS(6, _omitFieldNames ? '' : 'column')
    ..aOS(7, _omitFieldNames ? '' : 'lane')
    ..aOS(8, _omitFieldNames ? '' : 'cursor')
    ..aOS(9, _omitFieldNames ? '' : 'filterAst')
    ..aOS(10, _omitFieldNames ? '' : 'today')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BoardListColumnRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BoardListColumnRequest copyWith(
          void Function(BoardListColumnRequest) updates) =>
      super.copyWith((message) => updates(message as BoardListColumnRequest))
          as BoardListColumnRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use BoardListColumnRequest() / BoardListColumnRequest.new instead')
  static BoardListColumnRequest create() => BoardListColumnRequest._();
  static $pb.GeneratedMessage $_createMessage() => BoardListColumnRequest._();
  @$core.override
  BoardListColumnRequest createEmptyInstance() => BoardListColumnRequest._();
  @$core.pragma('dart2js:noInline')
  static BoardListColumnRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<BoardListColumnRequest>(
          BoardListColumnRequest.$_createMessage);
  static BoardListColumnRequest? _defaultInstance;

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
  $core.String get groupBy => $_getSZ(2);
  @$pb.TagNumber(3)
  set groupBy($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasGroupBy() => $_has(2);
  @$pb.TagNumber(3)
  void clearGroupBy() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get swimlane => $_getSZ(3);
  @$pb.TagNumber(4)
  set swimlane($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSwimlane() => $_has(3);
  @$pb.TagNumber(4)
  void clearSwimlane() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get pageSize => $_getIZ(4);
  @$pb.TagNumber(5)
  set pageSize($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasPageSize() => $_has(4);
  @$pb.TagNumber(5)
  void clearPageSize() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get column => $_getSZ(5);
  @$pb.TagNumber(6)
  set column($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasColumn() => $_has(5);
  @$pb.TagNumber(6)
  void clearColumn() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get lane => $_getSZ(6);
  @$pb.TagNumber(7)
  set lane($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasLane() => $_has(6);
  @$pb.TagNumber(7)
  void clearLane() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get cursor => $_getSZ(7);
  @$pb.TagNumber(8)
  set cursor($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasCursor() => $_has(7);
  @$pb.TagNumber(8)
  void clearCursor() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get filterAst => $_getSZ(8);
  @$pb.TagNumber(9)
  set filterAst($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasFilterAst() => $_has(8);
  @$pb.TagNumber(9)
  void clearFilterAst() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get today => $_getSZ(9);
  @$pb.TagNumber(10)
  set today($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasToday() => $_has(9);
  @$pb.TagNumber(10)
  void clearToday() => $_clearField(10);
}

class BoardMoveRequest extends $pb.GeneratedMessage {
  factory BoardMoveRequest({
    $core.String? workspaceId,
    $core.String? projectId,
    $core.String? id,
    $core.int? expectedVersion,
    $core.String? groupBy,
    $core.String? column,
    $core.String? beforeId,
    $core.String? afterId,
    $core.bool? includeSubtasks,
    $core.bool? overrideBlocked,
  }) {
    final result = BoardMoveRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (projectId != null) result.projectId = projectId;
    if (id != null) result.id = id;
    if (expectedVersion != null) result.expectedVersion = expectedVersion;
    if (groupBy != null) result.groupBy = groupBy;
    if (column != null) result.column = column;
    if (beforeId != null) result.beforeId = beforeId;
    if (afterId != null) result.afterId = afterId;
    if (includeSubtasks != null) result.includeSubtasks = includeSubtasks;
    if (overrideBlocked != null) result.overrideBlocked = overrideBlocked;
    return result;
  }

  BoardMoveRequest._();

  factory BoardMoveRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BoardMoveRequest()..mergeFromBuffer(data, registry);
  factory BoardMoveRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BoardMoveRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'BoardMoveRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.tasks'),
      createEmptyInstance: BoardMoveRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..aOS(3, _omitFieldNames ? '' : 'id')
    ..aI(4, _omitFieldNames ? '' : 'expectedVersion')
    ..aOS(5, _omitFieldNames ? '' : 'groupBy')
    ..aOS(6, _omitFieldNames ? '' : 'column')
    ..aOS(7, _omitFieldNames ? '' : 'beforeId')
    ..aOS(8, _omitFieldNames ? '' : 'afterId')
    ..aOB(9, _omitFieldNames ? '' : 'includeSubtasks')
    ..aOB(10, _omitFieldNames ? '' : 'overrideBlocked')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BoardMoveRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BoardMoveRequest copyWith(void Function(BoardMoveRequest) updates) =>
      super.copyWith((message) => updates(message as BoardMoveRequest))
          as BoardMoveRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use BoardMoveRequest() / BoardMoveRequest.new instead')
  static BoardMoveRequest create() => BoardMoveRequest._();
  static $pb.GeneratedMessage $_createMessage() => BoardMoveRequest._();
  @$core.override
  BoardMoveRequest createEmptyInstance() => BoardMoveRequest._();
  @$core.pragma('dart2js:noInline')
  static BoardMoveRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<BoardMoveRequest>(
          BoardMoveRequest.$_createMessage);
  static BoardMoveRequest? _defaultInstance;

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
  $core.String get groupBy => $_getSZ(4);
  @$pb.TagNumber(5)
  set groupBy($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasGroupBy() => $_has(4);
  @$pb.TagNumber(5)
  void clearGroupBy() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get column => $_getSZ(5);
  @$pb.TagNumber(6)
  set column($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasColumn() => $_has(5);
  @$pb.TagNumber(6)
  void clearColumn() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get beforeId => $_getSZ(6);
  @$pb.TagNumber(7)
  set beforeId($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasBeforeId() => $_has(6);
  @$pb.TagNumber(7)
  void clearBeforeId() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get afterId => $_getSZ(7);
  @$pb.TagNumber(8)
  set afterId($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasAfterId() => $_has(7);
  @$pb.TagNumber(8)
  void clearAfterId() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.bool get includeSubtasks => $_getBF(8);
  @$pb.TagNumber(9)
  set includeSubtasks($core.bool value) => $_setBool(8, value);
  @$pb.TagNumber(9)
  $core.bool hasIncludeSubtasks() => $_has(8);
  @$pb.TagNumber(9)
  void clearIncludeSubtasks() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.bool get overrideBlocked => $_getBF(9);
  @$pb.TagNumber(10)
  set overrideBlocked($core.bool value) => $_setBool(9, value);
  @$pb.TagNumber(10)
  $core.bool hasOverrideBlocked() => $_has(9);
  @$pb.TagNumber(10)
  void clearOverrideBlocked() => $_clearField(10);
}

class BoardPage extends $pb.GeneratedMessage {
  factory BoardPage({
    $core.Iterable<Task>? tasks,
    $core.String? cursor,
  }) {
    final result = BoardPage._();
    if (tasks != null) result.tasks.addAll(tasks);
    if (cursor != null) result.cursor = cursor;
    return result;
  }

  BoardPage._();

  factory BoardPage.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BoardPage()..mergeFromBuffer(data, registry);
  factory BoardPage.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BoardPage()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'BoardPage',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.tasks'),
      createEmptyInstance: BoardPage.$_createMessage)
    ..pPM<Task>(1, _omitFieldNames ? '' : 'tasks',
        subBuilder: Task.$_createMessage)
    ..aOS(2, _omitFieldNames ? '' : 'cursor')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BoardPage clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BoardPage copyWith(void Function(BoardPage) updates) =>
      super.copyWith((message) => updates(message as BoardPage)) as BoardPage;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use BoardPage() / BoardPage.new instead')
  static BoardPage create() => BoardPage._();
  static $pb.GeneratedMessage $_createMessage() => BoardPage._();
  @$core.override
  BoardPage createEmptyInstance() => BoardPage._();
  @$core.pragma('dart2js:noInline')
  static BoardPage getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<BoardPage>(BoardPage.$_createMessage);
  static BoardPage? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Task> get tasks => $_getList(0);

  @$pb.TagNumber(2)
  $core.String get cursor => $_getSZ(1);
  @$pb.TagNumber(2)
  set cursor($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCursor() => $_has(1);
  @$pb.TagNumber(2)
  void clearCursor() => $_clearField(2);
}

class BoardView extends $pb.GeneratedMessage {
  factory BoardView({
    $core.Iterable<BoardLane>? lanes,
  }) {
    final result = BoardView._();
    if (lanes != null) result.lanes.addAll(lanes);
    return result;
  }

  BoardView._();

  factory BoardView.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BoardView()..mergeFromBuffer(data, registry);
  factory BoardView.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BoardView()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'BoardView',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.tasks'),
      createEmptyInstance: BoardView.$_createMessage)
    ..pPM<BoardLane>(1, _omitFieldNames ? '' : 'lanes',
        subBuilder: BoardLane.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BoardView clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BoardView copyWith(void Function(BoardView) updates) =>
      super.copyWith((message) => updates(message as BoardView)) as BoardView;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use BoardView() / BoardView.new instead')
  static BoardView create() => BoardView._();
  static $pb.GeneratedMessage $_createMessage() => BoardView._();
  @$core.override
  BoardView createEmptyInstance() => BoardView._();
  @$core.pragma('dart2js:noInline')
  static BoardView getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<BoardView>(BoardView.$_createMessage);
  static BoardView? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<BoardLane> get lanes => $_getList(0);
}

class BulkResult extends $pb.GeneratedMessage {
  factory BulkResult({
    $core.String? id,
    $core.bool? ok,
    $core.String? code,
    $core.String? message,
    $core.String? detail,
    TaskResponse? task,
  }) {
    final result = BulkResult._();
    if (id != null) result.id = id;
    if (ok != null) result.ok = ok;
    if (code != null) result.code = code;
    if (message != null) result.message = message;
    if (detail != null) result.detail = detail;
    if (task != null) result.task = task;
    return result;
  }

  BulkResult._();

  factory BulkResult.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BulkResult()..mergeFromBuffer(data, registry);
  factory BulkResult.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BulkResult()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'BulkResult',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.tasks'),
      createEmptyInstance: BulkResult.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOB(2, _omitFieldNames ? '' : 'ok')
    ..aOS(3, _omitFieldNames ? '' : 'code')
    ..aOS(4, _omitFieldNames ? '' : 'message')
    ..aOS(5, _omitFieldNames ? '' : 'detail')
    ..aOM<TaskResponse>(6, _omitFieldNames ? '' : 'task',
        subBuilder: TaskResponse.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BulkResult clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BulkResult copyWith(void Function(BulkResult) updates) =>
      super.copyWith((message) => updates(message as BulkResult)) as BulkResult;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use BulkResult() / BulkResult.new instead')
  static BulkResult create() => BulkResult._();
  static $pb.GeneratedMessage $_createMessage() => BulkResult._();
  @$core.override
  BulkResult createEmptyInstance() => BulkResult._();
  @$core.pragma('dart2js:noInline')
  static BulkResult getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<BulkResult>(BulkResult.$_createMessage);
  static BulkResult? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get ok => $_getBF(1);
  @$pb.TagNumber(2)
  set ok($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasOk() => $_has(1);
  @$pb.TagNumber(2)
  void clearOk() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get code => $_getSZ(2);
  @$pb.TagNumber(3)
  set code($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasCode() => $_has(2);
  @$pb.TagNumber(3)
  void clearCode() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get message => $_getSZ(3);
  @$pb.TagNumber(4)
  set message($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasMessage() => $_has(3);
  @$pb.TagNumber(4)
  void clearMessage() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get detail => $_getSZ(4);
  @$pb.TagNumber(5)
  set detail($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasDetail() => $_has(4);
  @$pb.TagNumber(5)
  void clearDetail() => $_clearField(5);

  @$pb.TagNumber(6)
  TaskResponse get task => $_getN(5);
  @$pb.TagNumber(6)
  set task(TaskResponse value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasTask() => $_has(5);
  @$pb.TagNumber(6)
  void clearTask() => $_clearField(6);
  @$pb.TagNumber(6)
  TaskResponse ensureTask() => $_ensure(5);
}

class CalendarRangeRequest extends $pb.GeneratedMessage {
  factory CalendarRangeRequest({
    $core.String? workspaceId,
    $core.String? projectId,
    $core.String? rangeStart,
    $core.String? rangeEnd,
    $core.bool? includeDone,
    $core.String? filterAst,
    $core.String? today,
  }) {
    final result = CalendarRangeRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (projectId != null) result.projectId = projectId;
    if (rangeStart != null) result.rangeStart = rangeStart;
    if (rangeEnd != null) result.rangeEnd = rangeEnd;
    if (includeDone != null) result.includeDone = includeDone;
    if (filterAst != null) result.filterAst = filterAst;
    if (today != null) result.today = today;
    return result;
  }

  CalendarRangeRequest._();

  factory CalendarRangeRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CalendarRangeRequest()..mergeFromBuffer(data, registry);
  factory CalendarRangeRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CalendarRangeRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CalendarRangeRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.tasks'),
      createEmptyInstance: CalendarRangeRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..aOS(3, _omitFieldNames ? '' : 'rangeStart')
    ..aOS(4, _omitFieldNames ? '' : 'rangeEnd')
    ..aOB(5, _omitFieldNames ? '' : 'includeDone')
    ..aOS(6, _omitFieldNames ? '' : 'filterAst')
    ..aOS(7, _omitFieldNames ? '' : 'today')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CalendarRangeRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CalendarRangeRequest copyWith(void Function(CalendarRangeRequest) updates) =>
      super.copyWith((message) => updates(message as CalendarRangeRequest))
          as CalendarRangeRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use CalendarRangeRequest() / CalendarRangeRequest.new instead')
  static CalendarRangeRequest create() => CalendarRangeRequest._();
  static $pb.GeneratedMessage $_createMessage() => CalendarRangeRequest._();
  @$core.override
  CalendarRangeRequest createEmptyInstance() => CalendarRangeRequest._();
  @$core.pragma('dart2js:noInline')
  static CalendarRangeRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CalendarRangeRequest>(
          CalendarRangeRequest.$_createMessage);
  static CalendarRangeRequest? _defaultInstance;

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
  $core.String get rangeStart => $_getSZ(2);
  @$pb.TagNumber(3)
  set rangeStart($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRangeStart() => $_has(2);
  @$pb.TagNumber(3)
  void clearRangeStart() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get rangeEnd => $_getSZ(3);
  @$pb.TagNumber(4)
  set rangeEnd($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasRangeEnd() => $_has(3);
  @$pb.TagNumber(4)
  void clearRangeEnd() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.bool get includeDone => $_getBF(4);
  @$pb.TagNumber(5)
  set includeDone($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasIncludeDone() => $_has(4);
  @$pb.TagNumber(5)
  void clearIncludeDone() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get filterAst => $_getSZ(5);
  @$pb.TagNumber(6)
  set filterAst($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasFilterAst() => $_has(5);
  @$pb.TagNumber(6)
  void clearFilterAst() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get today => $_getSZ(6);
  @$pb.TagNumber(7)
  set today($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasToday() => $_has(6);
  @$pb.TagNumber(7)
  void clearToday() => $_clearField(7);
}

class CalendarTray extends $pb.GeneratedMessage {
  factory CalendarTray({
    $core.Iterable<Task>? tasks,
    $core.String? cursor,
  }) {
    final result = CalendarTray._();
    if (tasks != null) result.tasks.addAll(tasks);
    if (cursor != null) result.cursor = cursor;
    return result;
  }

  CalendarTray._();

  factory CalendarTray.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CalendarTray()..mergeFromBuffer(data, registry);
  factory CalendarTray.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CalendarTray()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CalendarTray',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.tasks'),
      createEmptyInstance: CalendarTray.$_createMessage)
    ..pPM<Task>(1, _omitFieldNames ? '' : 'tasks',
        subBuilder: Task.$_createMessage)
    ..aOS(2, _omitFieldNames ? '' : 'cursor')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CalendarTray clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CalendarTray copyWith(void Function(CalendarTray) updates) =>
      super.copyWith((message) => updates(message as CalendarTray))
          as CalendarTray;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CalendarTray() / CalendarTray.new instead')
  static CalendarTray create() => CalendarTray._();
  static $pb.GeneratedMessage $_createMessage() => CalendarTray._();
  @$core.override
  CalendarTray createEmptyInstance() => CalendarTray._();
  @$core.pragma('dart2js:noInline')
  static CalendarTray getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CalendarTray>(
          CalendarTray.$_createMessage);
  static CalendarTray? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Task> get tasks => $_getList(0);

  @$pb.TagNumber(2)
  $core.String get cursor => $_getSZ(1);
  @$pb.TagNumber(2)
  set cursor($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCursor() => $_has(1);
  @$pb.TagNumber(2)
  void clearCursor() => $_clearField(2);
}

class CalendarTrayRequest extends $pb.GeneratedMessage {
  factory CalendarTrayRequest({
    $core.String? workspaceId,
    $core.String? projectId,
    $core.String? cursor,
    $core.int? pageSize,
  }) {
    final result = CalendarTrayRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (projectId != null) result.projectId = projectId;
    if (cursor != null) result.cursor = cursor;
    if (pageSize != null) result.pageSize = pageSize;
    return result;
  }

  CalendarTrayRequest._();

  factory CalendarTrayRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CalendarTrayRequest()..mergeFromBuffer(data, registry);
  factory CalendarTrayRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CalendarTrayRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CalendarTrayRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.tasks'),
      createEmptyInstance: CalendarTrayRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..aOS(3, _omitFieldNames ? '' : 'cursor')
    ..aI(4, _omitFieldNames ? '' : 'pageSize')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CalendarTrayRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CalendarTrayRequest copyWith(void Function(CalendarTrayRequest) updates) =>
      super.copyWith((message) => updates(message as CalendarTrayRequest))
          as CalendarTrayRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core
      .Deprecated('Use CalendarTrayRequest() / CalendarTrayRequest.new instead')
  static CalendarTrayRequest create() => CalendarTrayRequest._();
  static $pb.GeneratedMessage $_createMessage() => CalendarTrayRequest._();
  @$core.override
  CalendarTrayRequest createEmptyInstance() => CalendarTrayRequest._();
  @$core.pragma('dart2js:noInline')
  static CalendarTrayRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CalendarTrayRequest>(
          CalendarTrayRequest.$_createMessage);
  static CalendarTrayRequest? _defaultInstance;

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
  $core.String get cursor => $_getSZ(2);
  @$pb.TagNumber(3)
  set cursor($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasCursor() => $_has(2);
  @$pb.TagNumber(3)
  void clearCursor() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get pageSize => $_getIZ(3);
  @$pb.TagNumber(4)
  set pageSize($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasPageSize() => $_has(3);
  @$pb.TagNumber(4)
  void clearPageSize() => $_clearField(4);
}

class CalendarWorkspaceRangeRequest extends $pb.GeneratedMessage {
  factory CalendarWorkspaceRangeRequest({
    $core.String? workspaceId,
    $core.String? rangeStart,
    $core.String? rangeEnd,
    $core.bool? includeDone,
    $core.Iterable<$core.String>? projectIds,
    $core.String? filterAst,
    $core.String? today,
  }) {
    final result = CalendarWorkspaceRangeRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (rangeStart != null) result.rangeStart = rangeStart;
    if (rangeEnd != null) result.rangeEnd = rangeEnd;
    if (includeDone != null) result.includeDone = includeDone;
    if (projectIds != null) result.projectIds.addAll(projectIds);
    if (filterAst != null) result.filterAst = filterAst;
    if (today != null) result.today = today;
    return result;
  }

  CalendarWorkspaceRangeRequest._();

  factory CalendarWorkspaceRangeRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CalendarWorkspaceRangeRequest()..mergeFromBuffer(data, registry);
  factory CalendarWorkspaceRangeRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CalendarWorkspaceRangeRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CalendarWorkspaceRangeRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.tasks'),
      createEmptyInstance: CalendarWorkspaceRangeRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'rangeStart')
    ..aOS(3, _omitFieldNames ? '' : 'rangeEnd')
    ..aOB(4, _omitFieldNames ? '' : 'includeDone')
    ..pPS(5, _omitFieldNames ? '' : 'projectIds')
    ..aOS(6, _omitFieldNames ? '' : 'filterAst')
    ..aOS(7, _omitFieldNames ? '' : 'today')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CalendarWorkspaceRangeRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CalendarWorkspaceRangeRequest copyWith(
          void Function(CalendarWorkspaceRangeRequest) updates) =>
      super.copyWith(
              (message) => updates(message as CalendarWorkspaceRangeRequest))
          as CalendarWorkspaceRangeRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use CalendarWorkspaceRangeRequest() / CalendarWorkspaceRangeRequest.new instead')
  static CalendarWorkspaceRangeRequest create() =>
      CalendarWorkspaceRangeRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      CalendarWorkspaceRangeRequest._();
  @$core.override
  CalendarWorkspaceRangeRequest createEmptyInstance() =>
      CalendarWorkspaceRangeRequest._();
  @$core.pragma('dart2js:noInline')
  static CalendarWorkspaceRangeRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CalendarWorkspaceRangeRequest>(
          CalendarWorkspaceRangeRequest.$_createMessage);
  static CalendarWorkspaceRangeRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get rangeStart => $_getSZ(1);
  @$pb.TagNumber(2)
  set rangeStart($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRangeStart() => $_has(1);
  @$pb.TagNumber(2)
  void clearRangeStart() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get rangeEnd => $_getSZ(2);
  @$pb.TagNumber(3)
  set rangeEnd($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRangeEnd() => $_has(2);
  @$pb.TagNumber(3)
  void clearRangeEnd() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get includeDone => $_getBF(3);
  @$pb.TagNumber(4)
  set includeDone($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasIncludeDone() => $_has(3);
  @$pb.TagNumber(4)
  void clearIncludeDone() => $_clearField(4);

  @$pb.TagNumber(5)
  $pb.PbList<$core.String> get projectIds => $_getList(4);

  @$pb.TagNumber(6)
  $core.String get filterAst => $_getSZ(5);
  @$pb.TagNumber(6)
  set filterAst($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasFilterAst() => $_has(5);
  @$pb.TagNumber(6)
  void clearFilterAst() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get today => $_getSZ(6);
  @$pb.TagNumber(7)
  set today($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasToday() => $_has(6);
  @$pb.TagNumber(7)
  void clearToday() => $_clearField(7);
}

class GroupCount extends $pb.GeneratedMessage {
  factory GroupCount({
    $core.String? key,
    $core.int? count,
  }) {
    final result = GroupCount._();
    if (key != null) result.key = key;
    if (count != null) result.count = count;
    return result;
  }

  GroupCount._();

  factory GroupCount.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GroupCount()..mergeFromBuffer(data, registry);
  factory GroupCount.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GroupCount()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GroupCount',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.tasks'),
      createEmptyInstance: GroupCount.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'key')
    ..aI(2, _omitFieldNames ? '' : 'count')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GroupCount clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GroupCount copyWith(void Function(GroupCount) updates) =>
      super.copyWith((message) => updates(message as GroupCount)) as GroupCount;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GroupCount() / GroupCount.new instead')
  static GroupCount create() => GroupCount._();
  static $pb.GeneratedMessage $_createMessage() => GroupCount._();
  @$core.override
  GroupCount createEmptyInstance() => GroupCount._();
  @$core.pragma('dart2js:noInline')
  static GroupCount getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GroupCount>(GroupCount.$_createMessage);
  static GroupCount? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get key => $_getSZ(0);
  @$pb.TagNumber(1)
  set key($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasKey() => $_has(0);
  @$pb.TagNumber(1)
  void clearKey() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get count => $_getIZ(1);
  @$pb.TagNumber(2)
  set count($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCount() => $_has(1);
  @$pb.TagNumber(2)
  void clearCount() => $_clearField(2);
}

class Link extends $pb.GeneratedMessage {
  factory Link({
    $core.String? id,
    $core.String? kind,
    $core.bool? restricted,
    $core.String? otherId,
    $core.String? otherProjectId,
    $core.String? otherDisplayId,
    $core.String? otherTitle,
    $core.String? otherStatusName,
    $core.String? otherStatusCategory,
  }) {
    final result = Link._();
    if (id != null) result.id = id;
    if (kind != null) result.kind = kind;
    if (restricted != null) result.restricted = restricted;
    if (otherId != null) result.otherId = otherId;
    if (otherProjectId != null) result.otherProjectId = otherProjectId;
    if (otherDisplayId != null) result.otherDisplayId = otherDisplayId;
    if (otherTitle != null) result.otherTitle = otherTitle;
    if (otherStatusName != null) result.otherStatusName = otherStatusName;
    if (otherStatusCategory != null)
      result.otherStatusCategory = otherStatusCategory;
    return result;
  }

  Link._();

  factory Link.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Link()..mergeFromBuffer(data, registry);
  factory Link.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Link()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Link',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.tasks'),
      createEmptyInstance: Link.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'kind')
    ..aOB(3, _omitFieldNames ? '' : 'restricted')
    ..aOS(4, _omitFieldNames ? '' : 'otherId')
    ..aOS(5, _omitFieldNames ? '' : 'otherProjectId')
    ..aOS(6, _omitFieldNames ? '' : 'otherDisplayId')
    ..aOS(7, _omitFieldNames ? '' : 'otherTitle')
    ..aOS(8, _omitFieldNames ? '' : 'otherStatusName')
    ..aOS(9, _omitFieldNames ? '' : 'otherStatusCategory')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Link clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Link copyWith(void Function(Link) updates) =>
      super.copyWith((message) => updates(message as Link)) as Link;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Link() / Link.new instead')
  static Link create() => Link._();
  static $pb.GeneratedMessage $_createMessage() => Link._();
  @$core.override
  Link createEmptyInstance() => Link._();
  @$core.pragma('dart2js:noInline')
  static Link getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Link>(Link.$_createMessage);
  static Link? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get kind => $_getSZ(1);
  @$pb.TagNumber(2)
  set kind($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasKind() => $_has(1);
  @$pb.TagNumber(2)
  void clearKind() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get restricted => $_getBF(2);
  @$pb.TagNumber(3)
  set restricted($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRestricted() => $_has(2);
  @$pb.TagNumber(3)
  void clearRestricted() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get otherId => $_getSZ(3);
  @$pb.TagNumber(4)
  set otherId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasOtherId() => $_has(3);
  @$pb.TagNumber(4)
  void clearOtherId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get otherProjectId => $_getSZ(4);
  @$pb.TagNumber(5)
  set otherProjectId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasOtherProjectId() => $_has(4);
  @$pb.TagNumber(5)
  void clearOtherProjectId() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get otherDisplayId => $_getSZ(5);
  @$pb.TagNumber(6)
  set otherDisplayId($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasOtherDisplayId() => $_has(5);
  @$pb.TagNumber(6)
  void clearOtherDisplayId() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get otherTitle => $_getSZ(6);
  @$pb.TagNumber(7)
  set otherTitle($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasOtherTitle() => $_has(6);
  @$pb.TagNumber(7)
  void clearOtherTitle() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get otherStatusName => $_getSZ(7);
  @$pb.TagNumber(8)
  set otherStatusName($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasOtherStatusName() => $_has(7);
  @$pb.TagNumber(8)
  void clearOtherStatusName() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get otherStatusCategory => $_getSZ(8);
  @$pb.TagNumber(9)
  set otherStatusCategory($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasOtherStatusCategory() => $_has(8);
  @$pb.TagNumber(9)
  void clearOtherStatusCategory() => $_clearField(9);
}

class LinkAddRequest extends $pb.GeneratedMessage {
  factory LinkAddRequest({
    $core.String? workspaceId,
    $core.String? taskId,
    $core.String? otherTaskId,
    $core.String? kind,
    $core.bool? closeDuplicate,
  }) {
    final result = LinkAddRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (taskId != null) result.taskId = taskId;
    if (otherTaskId != null) result.otherTaskId = otherTaskId;
    if (kind != null) result.kind = kind;
    if (closeDuplicate != null) result.closeDuplicate = closeDuplicate;
    return result;
  }

  LinkAddRequest._();

  factory LinkAddRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LinkAddRequest()..mergeFromBuffer(data, registry);
  factory LinkAddRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LinkAddRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LinkAddRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.tasks'),
      createEmptyInstance: LinkAddRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'taskId')
    ..aOS(3, _omitFieldNames ? '' : 'otherTaskId')
    ..aOS(4, _omitFieldNames ? '' : 'kind')
    ..aOB(5, _omitFieldNames ? '' : 'closeDuplicate')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LinkAddRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LinkAddRequest copyWith(void Function(LinkAddRequest) updates) =>
      super.copyWith((message) => updates(message as LinkAddRequest))
          as LinkAddRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use LinkAddRequest() / LinkAddRequest.new instead')
  static LinkAddRequest create() => LinkAddRequest._();
  static $pb.GeneratedMessage $_createMessage() => LinkAddRequest._();
  @$core.override
  LinkAddRequest createEmptyInstance() => LinkAddRequest._();
  @$core.pragma('dart2js:noInline')
  static LinkAddRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LinkAddRequest>(
          LinkAddRequest.$_createMessage);
  static LinkAddRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get taskId => $_getSZ(1);
  @$pb.TagNumber(2)
  set taskId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTaskId() => $_has(1);
  @$pb.TagNumber(2)
  void clearTaskId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get otherTaskId => $_getSZ(2);
  @$pb.TagNumber(3)
  set otherTaskId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasOtherTaskId() => $_has(2);
  @$pb.TagNumber(3)
  void clearOtherTaskId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get kind => $_getSZ(3);
  @$pb.TagNumber(4)
  set kind($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasKind() => $_has(3);
  @$pb.TagNumber(4)
  void clearKind() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.bool get closeDuplicate => $_getBF(4);
  @$pb.TagNumber(5)
  set closeDuplicate($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasCloseDuplicate() => $_has(4);
  @$pb.TagNumber(5)
  void clearCloseDuplicate() => $_clearField(5);
}

class LinkCandidate extends $pb.GeneratedMessage {
  factory LinkCandidate({
    $core.String? id,
    $core.String? projectId,
    $core.String? displayId,
    $core.String? title,
    $core.String? statusName,
    $core.String? statusCategory,
  }) {
    final result = LinkCandidate._();
    if (id != null) result.id = id;
    if (projectId != null) result.projectId = projectId;
    if (displayId != null) result.displayId = displayId;
    if (title != null) result.title = title;
    if (statusName != null) result.statusName = statusName;
    if (statusCategory != null) result.statusCategory = statusCategory;
    return result;
  }

  LinkCandidate._();

  factory LinkCandidate.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LinkCandidate()..mergeFromBuffer(data, registry);
  factory LinkCandidate.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LinkCandidate()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LinkCandidate',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.tasks'),
      createEmptyInstance: LinkCandidate.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..aOS(3, _omitFieldNames ? '' : 'displayId')
    ..aOS(4, _omitFieldNames ? '' : 'title')
    ..aOS(5, _omitFieldNames ? '' : 'statusName')
    ..aOS(6, _omitFieldNames ? '' : 'statusCategory')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LinkCandidate clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LinkCandidate copyWith(void Function(LinkCandidate) updates) =>
      super.copyWith((message) => updates(message as LinkCandidate))
          as LinkCandidate;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use LinkCandidate() / LinkCandidate.new instead')
  static LinkCandidate create() => LinkCandidate._();
  static $pb.GeneratedMessage $_createMessage() => LinkCandidate._();
  @$core.override
  LinkCandidate createEmptyInstance() => LinkCandidate._();
  @$core.pragma('dart2js:noInline')
  static LinkCandidate getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LinkCandidate>(
          LinkCandidate.$_createMessage);
  static LinkCandidate? _defaultInstance;

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
  $core.String get displayId => $_getSZ(2);
  @$pb.TagNumber(3)
  set displayId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDisplayId() => $_has(2);
  @$pb.TagNumber(3)
  void clearDisplayId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get title => $_getSZ(3);
  @$pb.TagNumber(4)
  set title($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasTitle() => $_has(3);
  @$pb.TagNumber(4)
  void clearTitle() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get statusName => $_getSZ(4);
  @$pb.TagNumber(5)
  set statusName($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasStatusName() => $_has(4);
  @$pb.TagNumber(5)
  void clearStatusName() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get statusCategory => $_getSZ(5);
  @$pb.TagNumber(6)
  set statusCategory($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasStatusCategory() => $_has(5);
  @$pb.TagNumber(6)
  void clearStatusCategory() => $_clearField(6);
}

class LinkCandidates extends $pb.GeneratedMessage {
  factory LinkCandidates({
    $core.Iterable<LinkCandidate>? tasks,
  }) {
    final result = LinkCandidates._();
    if (tasks != null) result.tasks.addAll(tasks);
    return result;
  }

  LinkCandidates._();

  factory LinkCandidates.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LinkCandidates()..mergeFromBuffer(data, registry);
  factory LinkCandidates.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LinkCandidates()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LinkCandidates',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.tasks'),
      createEmptyInstance: LinkCandidates.$_createMessage)
    ..pPM<LinkCandidate>(1, _omitFieldNames ? '' : 'tasks',
        subBuilder: LinkCandidate.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LinkCandidates clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LinkCandidates copyWith(void Function(LinkCandidates) updates) =>
      super.copyWith((message) => updates(message as LinkCandidates))
          as LinkCandidates;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use LinkCandidates() / LinkCandidates.new instead')
  static LinkCandidates create() => LinkCandidates._();
  static $pb.GeneratedMessage $_createMessage() => LinkCandidates._();
  @$core.override
  LinkCandidates createEmptyInstance() => LinkCandidates._();
  @$core.pragma('dart2js:noInline')
  static LinkCandidates getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LinkCandidates>(
          LinkCandidates.$_createMessage);
  static LinkCandidates? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<LinkCandidate> get tasks => $_getList(0);
}

class LinkList extends $pb.GeneratedMessage {
  factory LinkList({
    $core.Iterable<Link>? links,
  }) {
    final result = LinkList._();
    if (links != null) result.links.addAll(links);
    return result;
  }

  LinkList._();

  factory LinkList.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LinkList()..mergeFromBuffer(data, registry);
  factory LinkList.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LinkList()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LinkList',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.tasks'),
      createEmptyInstance: LinkList.$_createMessage)
    ..pPM<Link>(1, _omitFieldNames ? '' : 'links',
        subBuilder: Link.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LinkList clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LinkList copyWith(void Function(LinkList) updates) =>
      super.copyWith((message) => updates(message as LinkList)) as LinkList;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use LinkList() / LinkList.new instead')
  static LinkList create() => LinkList._();
  static $pb.GeneratedMessage $_createMessage() => LinkList._();
  @$core.override
  LinkList createEmptyInstance() => LinkList._();
  @$core.pragma('dart2js:noInline')
  static LinkList getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LinkList>(LinkList.$_createMessage);
  static LinkList? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Link> get links => $_getList(0);
}

class LinkListForTaskRequest extends $pb.GeneratedMessage {
  factory LinkListForTaskRequest({
    $core.String? workspaceId,
    $core.String? taskId,
  }) {
    final result = LinkListForTaskRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (taskId != null) result.taskId = taskId;
    return result;
  }

  LinkListForTaskRequest._();

  factory LinkListForTaskRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LinkListForTaskRequest()..mergeFromBuffer(data, registry);
  factory LinkListForTaskRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LinkListForTaskRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LinkListForTaskRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.tasks'),
      createEmptyInstance: LinkListForTaskRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'taskId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LinkListForTaskRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LinkListForTaskRequest copyWith(
          void Function(LinkListForTaskRequest) updates) =>
      super.copyWith((message) => updates(message as LinkListForTaskRequest))
          as LinkListForTaskRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use LinkListForTaskRequest() / LinkListForTaskRequest.new instead')
  static LinkListForTaskRequest create() => LinkListForTaskRequest._();
  static $pb.GeneratedMessage $_createMessage() => LinkListForTaskRequest._();
  @$core.override
  LinkListForTaskRequest createEmptyInstance() => LinkListForTaskRequest._();
  @$core.pragma('dart2js:noInline')
  static LinkListForTaskRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LinkListForTaskRequest>(
          LinkListForTaskRequest.$_createMessage);
  static LinkListForTaskRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get taskId => $_getSZ(1);
  @$pb.TagNumber(2)
  set taskId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTaskId() => $_has(1);
  @$pb.TagNumber(2)
  void clearTaskId() => $_clearField(2);
}

class LinkRemoveRequest extends $pb.GeneratedMessage {
  factory LinkRemoveRequest({
    $core.String? workspaceId,
    $core.String? taskId,
    $core.String? id,
  }) {
    final result = LinkRemoveRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (taskId != null) result.taskId = taskId;
    if (id != null) result.id = id;
    return result;
  }

  LinkRemoveRequest._();

  factory LinkRemoveRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LinkRemoveRequest()..mergeFromBuffer(data, registry);
  factory LinkRemoveRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LinkRemoveRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LinkRemoveRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.tasks'),
      createEmptyInstance: LinkRemoveRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'taskId')
    ..aOS(3, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LinkRemoveRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LinkRemoveRequest copyWith(void Function(LinkRemoveRequest) updates) =>
      super.copyWith((message) => updates(message as LinkRemoveRequest))
          as LinkRemoveRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use LinkRemoveRequest() / LinkRemoveRequest.new instead')
  static LinkRemoveRequest create() => LinkRemoveRequest._();
  static $pb.GeneratedMessage $_createMessage() => LinkRemoveRequest._();
  @$core.override
  LinkRemoveRequest createEmptyInstance() => LinkRemoveRequest._();
  @$core.pragma('dart2js:noInline')
  static LinkRemoveRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LinkRemoveRequest>(
          LinkRemoveRequest.$_createMessage);
  static LinkRemoveRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get taskId => $_getSZ(1);
  @$pb.TagNumber(2)
  set taskId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTaskId() => $_has(1);
  @$pb.TagNumber(2)
  void clearTaskId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get id => $_getSZ(2);
  @$pb.TagNumber(3)
  set id($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasId() => $_has(2);
  @$pb.TagNumber(3)
  void clearId() => $_clearField(3);
}

class LinkSearchTasksRequest extends $pb.GeneratedMessage {
  factory LinkSearchTasksRequest({
    $core.String? workspaceId,
    $core.String? query,
  }) {
    final result = LinkSearchTasksRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (query != null) result.query = query;
    return result;
  }

  LinkSearchTasksRequest._();

  factory LinkSearchTasksRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LinkSearchTasksRequest()..mergeFromBuffer(data, registry);
  factory LinkSearchTasksRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LinkSearchTasksRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LinkSearchTasksRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.tasks'),
      createEmptyInstance: LinkSearchTasksRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'query')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LinkSearchTasksRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LinkSearchTasksRequest copyWith(
          void Function(LinkSearchTasksRequest) updates) =>
      super.copyWith((message) => updates(message as LinkSearchTasksRequest))
          as LinkSearchTasksRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use LinkSearchTasksRequest() / LinkSearchTasksRequest.new instead')
  static LinkSearchTasksRequest create() => LinkSearchTasksRequest._();
  static $pb.GeneratedMessage $_createMessage() => LinkSearchTasksRequest._();
  @$core.override
  LinkSearchTasksRequest createEmptyInstance() => LinkSearchTasksRequest._();
  @$core.pragma('dart2js:noInline')
  static LinkSearchTasksRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LinkSearchTasksRequest>(
          LinkSearchTasksRequest.$_createMessage);
  static LinkSearchTasksRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get query => $_getSZ(1);
  @$pb.TagNumber(2)
  set query($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasQuery() => $_has(1);
  @$pb.TagNumber(2)
  void clearQuery() => $_clearField(2);
}

class SortKey extends $pb.GeneratedMessage {
  factory SortKey({
    $core.String? key,
    $core.bool? desc,
  }) {
    final result = SortKey._();
    if (key != null) result.key = key;
    if (desc != null) result.desc = desc;
    return result;
  }

  SortKey._();

  factory SortKey.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SortKey()..mergeFromBuffer(data, registry);
  factory SortKey.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SortKey()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SortKey',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.tasks'),
      createEmptyInstance: SortKey.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'key')
    ..aOB(2, _omitFieldNames ? '' : 'desc')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SortKey clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SortKey copyWith(void Function(SortKey) updates) =>
      super.copyWith((message) => updates(message as SortKey)) as SortKey;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SortKey() / SortKey.new instead')
  static SortKey create() => SortKey._();
  static $pb.GeneratedMessage $_createMessage() => SortKey._();
  @$core.override
  SortKey createEmptyInstance() => SortKey._();
  @$core.pragma('dart2js:noInline')
  static SortKey getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SortKey>(SortKey.$_createMessage);
  static SortKey? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get key => $_getSZ(0);
  @$pb.TagNumber(1)
  set key($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasKey() => $_has(0);
  @$pb.TagNumber(1)
  void clearKey() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get desc => $_getBF(1);
  @$pb.TagNumber(2)
  set desc($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDesc() => $_has(1);
  @$pb.TagNumber(2)
  void clearDesc() => $_clearField(2);
}

class Task extends $pb.GeneratedMessage {
  factory Task({
    $core.String? id,
    $core.String? workspaceId,
    $core.String? projectId,
    $core.int? number,
    $core.String? displayId,
    $core.String? title,
    $core.String? description,
    $core.String? status,
    $core.String? priority,
    $core.String? startDate,
    $core.String? dueDate,
    $core.Iterable<$core.String>? assigneeIds,
    $core.String? createdBy,
    $core.int? version,
    $core.String? position,
    $core.String? createdAt,
    $core.String? updatedAt,
    $core.String? deletedAt,
    $core.String? statusName,
    $core.String? statusCategory,
    $core.String? parentId,
    $core.int? depth,
    $core.int? progressDone,
    $core.int? progressTotal,
    $core.bool? isBlocked,
    $core.Iterable<$core.String>? blockedBy,
    $core.Iterable<TaskFieldValue>? fields,
    $core.String? groupKey,
    $core.String? dueTime,
    $core.String? blockersDue,
    $core.String? blocksDue,
  }) {
    final result = Task._();
    if (id != null) result.id = id;
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (projectId != null) result.projectId = projectId;
    if (number != null) result.number = number;
    if (displayId != null) result.displayId = displayId;
    if (title != null) result.title = title;
    if (description != null) result.description = description;
    if (status != null) result.status = status;
    if (priority != null) result.priority = priority;
    if (startDate != null) result.startDate = startDate;
    if (dueDate != null) result.dueDate = dueDate;
    if (assigneeIds != null) result.assigneeIds.addAll(assigneeIds);
    if (createdBy != null) result.createdBy = createdBy;
    if (version != null) result.version = version;
    if (position != null) result.position = position;
    if (createdAt != null) result.createdAt = createdAt;
    if (updatedAt != null) result.updatedAt = updatedAt;
    if (deletedAt != null) result.deletedAt = deletedAt;
    if (statusName != null) result.statusName = statusName;
    if (statusCategory != null) result.statusCategory = statusCategory;
    if (parentId != null) result.parentId = parentId;
    if (depth != null) result.depth = depth;
    if (progressDone != null) result.progressDone = progressDone;
    if (progressTotal != null) result.progressTotal = progressTotal;
    if (isBlocked != null) result.isBlocked = isBlocked;
    if (blockedBy != null) result.blockedBy.addAll(blockedBy);
    if (fields != null) result.fields.addAll(fields);
    if (groupKey != null) result.groupKey = groupKey;
    if (dueTime != null) result.dueTime = dueTime;
    if (blockersDue != null) result.blockersDue = blockersDue;
    if (blocksDue != null) result.blocksDue = blocksDue;
    return result;
  }

  Task._();

  factory Task.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Task()..mergeFromBuffer(data, registry);
  factory Task.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Task()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Task',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.tasks'),
      createEmptyInstance: Task.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(3, _omitFieldNames ? '' : 'projectId')
    ..aI(4, _omitFieldNames ? '' : 'number')
    ..aOS(5, _omitFieldNames ? '' : 'displayId')
    ..aOS(6, _omitFieldNames ? '' : 'title')
    ..aOS(7, _omitFieldNames ? '' : 'description')
    ..aOS(8, _omitFieldNames ? '' : 'status')
    ..aOS(9, _omitFieldNames ? '' : 'priority')
    ..aOS(10, _omitFieldNames ? '' : 'startDate')
    ..aOS(11, _omitFieldNames ? '' : 'dueDate')
    ..pPS(12, _omitFieldNames ? '' : 'assigneeIds')
    ..aOS(13, _omitFieldNames ? '' : 'createdBy')
    ..aI(14, _omitFieldNames ? '' : 'version')
    ..aOS(15, _omitFieldNames ? '' : 'position')
    ..aOS(16, _omitFieldNames ? '' : 'createdAt')
    ..aOS(17, _omitFieldNames ? '' : 'updatedAt')
    ..aOS(18, _omitFieldNames ? '' : 'deletedAt')
    ..aOS(19, _omitFieldNames ? '' : 'statusName')
    ..aOS(20, _omitFieldNames ? '' : 'statusCategory')
    ..aOS(21, _omitFieldNames ? '' : 'parentId')
    ..aI(22, _omitFieldNames ? '' : 'depth')
    ..aI(23, _omitFieldNames ? '' : 'progressDone')
    ..aI(24, _omitFieldNames ? '' : 'progressTotal')
    ..aOB(25, _omitFieldNames ? '' : 'isBlocked')
    ..pPS(26, _omitFieldNames ? '' : 'blockedBy')
    ..pPM<TaskFieldValue>(27, _omitFieldNames ? '' : 'fields',
        subBuilder: TaskFieldValue.$_createMessage)
    ..aOS(28, _omitFieldNames ? '' : 'groupKey')
    ..aOS(29, _omitFieldNames ? '' : 'dueTime')
    ..aOS(30, _omitFieldNames ? '' : 'blockersDue')
    ..aOS(31, _omitFieldNames ? '' : 'blocksDue')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Task clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Task copyWith(void Function(Task) updates) =>
      super.copyWith((message) => updates(message as Task)) as Task;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Task() / Task.new instead')
  static Task create() => Task._();
  static $pb.GeneratedMessage $_createMessage() => Task._();
  @$core.override
  Task createEmptyInstance() => Task._();
  @$core.pragma('dart2js:noInline')
  static Task getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Task>(Task.$_createMessage);
  static Task? _defaultInstance;

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
  $core.int get number => $_getIZ(3);
  @$pb.TagNumber(4)
  set number($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasNumber() => $_has(3);
  @$pb.TagNumber(4)
  void clearNumber() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get displayId => $_getSZ(4);
  @$pb.TagNumber(5)
  set displayId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasDisplayId() => $_has(4);
  @$pb.TagNumber(5)
  void clearDisplayId() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get title => $_getSZ(5);
  @$pb.TagNumber(6)
  set title($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasTitle() => $_has(5);
  @$pb.TagNumber(6)
  void clearTitle() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get description => $_getSZ(6);
  @$pb.TagNumber(7)
  set description($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasDescription() => $_has(6);
  @$pb.TagNumber(7)
  void clearDescription() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get status => $_getSZ(7);
  @$pb.TagNumber(8)
  set status($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasStatus() => $_has(7);
  @$pb.TagNumber(8)
  void clearStatus() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get priority => $_getSZ(8);
  @$pb.TagNumber(9)
  set priority($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasPriority() => $_has(8);
  @$pb.TagNumber(9)
  void clearPriority() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get startDate => $_getSZ(9);
  @$pb.TagNumber(10)
  set startDate($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasStartDate() => $_has(9);
  @$pb.TagNumber(10)
  void clearStartDate() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.String get dueDate => $_getSZ(10);
  @$pb.TagNumber(11)
  set dueDate($core.String value) => $_setString(10, value);
  @$pb.TagNumber(11)
  $core.bool hasDueDate() => $_has(10);
  @$pb.TagNumber(11)
  void clearDueDate() => $_clearField(11);

  @$pb.TagNumber(12)
  $pb.PbList<$core.String> get assigneeIds => $_getList(11);

  @$pb.TagNumber(13)
  $core.String get createdBy => $_getSZ(12);
  @$pb.TagNumber(13)
  set createdBy($core.String value) => $_setString(12, value);
  @$pb.TagNumber(13)
  $core.bool hasCreatedBy() => $_has(12);
  @$pb.TagNumber(13)
  void clearCreatedBy() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.int get version => $_getIZ(13);
  @$pb.TagNumber(14)
  set version($core.int value) => $_setSignedInt32(13, value);
  @$pb.TagNumber(14)
  $core.bool hasVersion() => $_has(13);
  @$pb.TagNumber(14)
  void clearVersion() => $_clearField(14);

  @$pb.TagNumber(15)
  $core.String get position => $_getSZ(14);
  @$pb.TagNumber(15)
  set position($core.String value) => $_setString(14, value);
  @$pb.TagNumber(15)
  $core.bool hasPosition() => $_has(14);
  @$pb.TagNumber(15)
  void clearPosition() => $_clearField(15);

  @$pb.TagNumber(16)
  $core.String get createdAt => $_getSZ(15);
  @$pb.TagNumber(16)
  set createdAt($core.String value) => $_setString(15, value);
  @$pb.TagNumber(16)
  $core.bool hasCreatedAt() => $_has(15);
  @$pb.TagNumber(16)
  void clearCreatedAt() => $_clearField(16);

  @$pb.TagNumber(17)
  $core.String get updatedAt => $_getSZ(16);
  @$pb.TagNumber(17)
  set updatedAt($core.String value) => $_setString(16, value);
  @$pb.TagNumber(17)
  $core.bool hasUpdatedAt() => $_has(16);
  @$pb.TagNumber(17)
  void clearUpdatedAt() => $_clearField(17);

  @$pb.TagNumber(18)
  $core.String get deletedAt => $_getSZ(17);
  @$pb.TagNumber(18)
  set deletedAt($core.String value) => $_setString(17, value);
  @$pb.TagNumber(18)
  $core.bool hasDeletedAt() => $_has(17);
  @$pb.TagNumber(18)
  void clearDeletedAt() => $_clearField(18);

  @$pb.TagNumber(19)
  $core.String get statusName => $_getSZ(18);
  @$pb.TagNumber(19)
  set statusName($core.String value) => $_setString(18, value);
  @$pb.TagNumber(19)
  $core.bool hasStatusName() => $_has(18);
  @$pb.TagNumber(19)
  void clearStatusName() => $_clearField(19);

  @$pb.TagNumber(20)
  $core.String get statusCategory => $_getSZ(19);
  @$pb.TagNumber(20)
  set statusCategory($core.String value) => $_setString(19, value);
  @$pb.TagNumber(20)
  $core.bool hasStatusCategory() => $_has(19);
  @$pb.TagNumber(20)
  void clearStatusCategory() => $_clearField(20);

  @$pb.TagNumber(21)
  $core.String get parentId => $_getSZ(20);
  @$pb.TagNumber(21)
  set parentId($core.String value) => $_setString(20, value);
  @$pb.TagNumber(21)
  $core.bool hasParentId() => $_has(20);
  @$pb.TagNumber(21)
  void clearParentId() => $_clearField(21);

  @$pb.TagNumber(22)
  $core.int get depth => $_getIZ(21);
  @$pb.TagNumber(22)
  set depth($core.int value) => $_setSignedInt32(21, value);
  @$pb.TagNumber(22)
  $core.bool hasDepth() => $_has(21);
  @$pb.TagNumber(22)
  void clearDepth() => $_clearField(22);

  @$pb.TagNumber(23)
  $core.int get progressDone => $_getIZ(22);
  @$pb.TagNumber(23)
  set progressDone($core.int value) => $_setSignedInt32(22, value);
  @$pb.TagNumber(23)
  $core.bool hasProgressDone() => $_has(22);
  @$pb.TagNumber(23)
  void clearProgressDone() => $_clearField(23);

  @$pb.TagNumber(24)
  $core.int get progressTotal => $_getIZ(23);
  @$pb.TagNumber(24)
  set progressTotal($core.int value) => $_setSignedInt32(23, value);
  @$pb.TagNumber(24)
  $core.bool hasProgressTotal() => $_has(23);
  @$pb.TagNumber(24)
  void clearProgressTotal() => $_clearField(24);

  @$pb.TagNumber(25)
  $core.bool get isBlocked => $_getBF(24);
  @$pb.TagNumber(25)
  set isBlocked($core.bool value) => $_setBool(24, value);
  @$pb.TagNumber(25)
  $core.bool hasIsBlocked() => $_has(24);
  @$pb.TagNumber(25)
  void clearIsBlocked() => $_clearField(25);

  @$pb.TagNumber(26)
  $pb.PbList<$core.String> get blockedBy => $_getList(25);

  @$pb.TagNumber(27)
  $pb.PbList<TaskFieldValue> get fields => $_getList(26);

  @$pb.TagNumber(28)
  $core.String get groupKey => $_getSZ(27);
  @$pb.TagNumber(28)
  set groupKey($core.String value) => $_setString(27, value);
  @$pb.TagNumber(28)
  $core.bool hasGroupKey() => $_has(27);
  @$pb.TagNumber(28)
  void clearGroupKey() => $_clearField(28);

  @$pb.TagNumber(29)
  $core.String get dueTime => $_getSZ(28);
  @$pb.TagNumber(29)
  set dueTime($core.String value) => $_setString(28, value);
  @$pb.TagNumber(29)
  $core.bool hasDueTime() => $_has(28);
  @$pb.TagNumber(29)
  void clearDueTime() => $_clearField(29);

  @$pb.TagNumber(30)
  $core.String get blockersDue => $_getSZ(29);
  @$pb.TagNumber(30)
  set blockersDue($core.String value) => $_setString(29, value);
  @$pb.TagNumber(30)
  $core.bool hasBlockersDue() => $_has(29);
  @$pb.TagNumber(30)
  void clearBlockersDue() => $_clearField(30);

  @$pb.TagNumber(31)
  $core.String get blocksDue => $_getSZ(30);
  @$pb.TagNumber(31)
  set blocksDue($core.String value) => $_setString(30, value);
  @$pb.TagNumber(31)
  $core.bool hasBlocksDue() => $_has(30);
  @$pb.TagNumber(31)
  void clearBlocksDue() => $_clearField(31);
}

class TaskBulkUpdateRequest extends $pb.GeneratedMessage {
  factory TaskBulkUpdateRequest({
    $core.String? workspaceId,
    $core.String? projectId,
    $core.Iterable<$core.String>? ids,
    $core.String? status,
    $core.String? priority,
    $core.bool? setAssignees,
    $core.Iterable<$core.String>? assigneeIds,
    $core.bool? delete,
    $core.String? deleteMode,
  }) {
    final result = TaskBulkUpdateRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (projectId != null) result.projectId = projectId;
    if (ids != null) result.ids.addAll(ids);
    if (status != null) result.status = status;
    if (priority != null) result.priority = priority;
    if (setAssignees != null) result.setAssignees = setAssignees;
    if (assigneeIds != null) result.assigneeIds.addAll(assigneeIds);
    if (delete != null) result.delete = delete;
    if (deleteMode != null) result.deleteMode = deleteMode;
    return result;
  }

  TaskBulkUpdateRequest._();

  factory TaskBulkUpdateRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TaskBulkUpdateRequest()..mergeFromBuffer(data, registry);
  factory TaskBulkUpdateRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TaskBulkUpdateRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TaskBulkUpdateRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.tasks'),
      createEmptyInstance: TaskBulkUpdateRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..pPS(3, _omitFieldNames ? '' : 'ids')
    ..aOS(4, _omitFieldNames ? '' : 'status')
    ..aOS(5, _omitFieldNames ? '' : 'priority')
    ..aOB(6, _omitFieldNames ? '' : 'setAssignees')
    ..pPS(7, _omitFieldNames ? '' : 'assigneeIds')
    ..aOB(8, _omitFieldNames ? '' : 'delete')
    ..aOS(9, _omitFieldNames ? '' : 'deleteMode')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TaskBulkUpdateRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TaskBulkUpdateRequest copyWith(
          void Function(TaskBulkUpdateRequest) updates) =>
      super.copyWith((message) => updates(message as TaskBulkUpdateRequest))
          as TaskBulkUpdateRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use TaskBulkUpdateRequest() / TaskBulkUpdateRequest.new instead')
  static TaskBulkUpdateRequest create() => TaskBulkUpdateRequest._();
  static $pb.GeneratedMessage $_createMessage() => TaskBulkUpdateRequest._();
  @$core.override
  TaskBulkUpdateRequest createEmptyInstance() => TaskBulkUpdateRequest._();
  @$core.pragma('dart2js:noInline')
  static TaskBulkUpdateRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TaskBulkUpdateRequest>(
          TaskBulkUpdateRequest.$_createMessage);
  static TaskBulkUpdateRequest? _defaultInstance;

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

  @$pb.TagNumber(4)
  $core.String get status => $_getSZ(3);
  @$pb.TagNumber(4)
  set status($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasStatus() => $_has(3);
  @$pb.TagNumber(4)
  void clearStatus() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get priority => $_getSZ(4);
  @$pb.TagNumber(5)
  set priority($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasPriority() => $_has(4);
  @$pb.TagNumber(5)
  void clearPriority() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.bool get setAssignees => $_getBF(5);
  @$pb.TagNumber(6)
  set setAssignees($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasSetAssignees() => $_has(5);
  @$pb.TagNumber(6)
  void clearSetAssignees() => $_clearField(6);

  @$pb.TagNumber(7)
  $pb.PbList<$core.String> get assigneeIds => $_getList(6);

  @$pb.TagNumber(8)
  $core.bool get delete => $_getBF(7);
  @$pb.TagNumber(8)
  set delete($core.bool value) => $_setBool(7, value);
  @$pb.TagNumber(8)
  $core.bool hasDelete() => $_has(7);
  @$pb.TagNumber(8)
  void clearDelete() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get deleteMode => $_getSZ(8);
  @$pb.TagNumber(9)
  set deleteMode($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasDeleteMode() => $_has(8);
  @$pb.TagNumber(9)
  void clearDeleteMode() => $_clearField(9);
}

class TaskChildren extends $pb.GeneratedMessage {
  factory TaskChildren({
    $core.Iterable<Task>? tasks,
  }) {
    final result = TaskChildren._();
    if (tasks != null) result.tasks.addAll(tasks);
    return result;
  }

  TaskChildren._();

  factory TaskChildren.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TaskChildren()..mergeFromBuffer(data, registry);
  factory TaskChildren.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TaskChildren()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TaskChildren',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.tasks'),
      createEmptyInstance: TaskChildren.$_createMessage)
    ..pPM<Task>(1, _omitFieldNames ? '' : 'tasks',
        subBuilder: Task.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TaskChildren clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TaskChildren copyWith(void Function(TaskChildren) updates) =>
      super.copyWith((message) => updates(message as TaskChildren))
          as TaskChildren;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use TaskChildren() / TaskChildren.new instead')
  static TaskChildren create() => TaskChildren._();
  static $pb.GeneratedMessage $_createMessage() => TaskChildren._();
  @$core.override
  TaskChildren createEmptyInstance() => TaskChildren._();
  @$core.pragma('dart2js:noInline')
  static TaskChildren getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TaskChildren>(
          TaskChildren.$_createMessage);
  static TaskChildren? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Task> get tasks => $_getList(0);
}

class TaskCreateRequest extends $pb.GeneratedMessage {
  factory TaskCreateRequest({
    $core.String? workspaceId,
    $core.String? projectId,
    $core.String? title,
    $core.String? description,
    $core.String? status,
    $core.String? priority,
    $core.String? startDate,
    $core.String? dueDate,
    $core.Iterable<$core.String>? assigneeIds,
    $core.String? parentId,
    $core.Iterable<TaskFieldValue>? fieldValues,
    $core.String? dueTime,
  }) {
    final result = TaskCreateRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (projectId != null) result.projectId = projectId;
    if (title != null) result.title = title;
    if (description != null) result.description = description;
    if (status != null) result.status = status;
    if (priority != null) result.priority = priority;
    if (startDate != null) result.startDate = startDate;
    if (dueDate != null) result.dueDate = dueDate;
    if (assigneeIds != null) result.assigneeIds.addAll(assigneeIds);
    if (parentId != null) result.parentId = parentId;
    if (fieldValues != null) result.fieldValues.addAll(fieldValues);
    if (dueTime != null) result.dueTime = dueTime;
    return result;
  }

  TaskCreateRequest._();

  factory TaskCreateRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TaskCreateRequest()..mergeFromBuffer(data, registry);
  factory TaskCreateRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TaskCreateRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TaskCreateRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.tasks'),
      createEmptyInstance: TaskCreateRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..aOS(3, _omitFieldNames ? '' : 'title')
    ..aOS(4, _omitFieldNames ? '' : 'description')
    ..aOS(5, _omitFieldNames ? '' : 'status')
    ..aOS(6, _omitFieldNames ? '' : 'priority')
    ..aOS(7, _omitFieldNames ? '' : 'startDate')
    ..aOS(8, _omitFieldNames ? '' : 'dueDate')
    ..pPS(9, _omitFieldNames ? '' : 'assigneeIds')
    ..aOS(10, _omitFieldNames ? '' : 'parentId')
    ..pPM<TaskFieldValue>(11, _omitFieldNames ? '' : 'fieldValues',
        subBuilder: TaskFieldValue.$_createMessage)
    ..aOS(12, _omitFieldNames ? '' : 'dueTime')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TaskCreateRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TaskCreateRequest copyWith(void Function(TaskCreateRequest) updates) =>
      super.copyWith((message) => updates(message as TaskCreateRequest))
          as TaskCreateRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use TaskCreateRequest() / TaskCreateRequest.new instead')
  static TaskCreateRequest create() => TaskCreateRequest._();
  static $pb.GeneratedMessage $_createMessage() => TaskCreateRequest._();
  @$core.override
  TaskCreateRequest createEmptyInstance() => TaskCreateRequest._();
  @$core.pragma('dart2js:noInline')
  static TaskCreateRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TaskCreateRequest>(
          TaskCreateRequest.$_createMessage);
  static TaskCreateRequest? _defaultInstance;

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
  $core.String get title => $_getSZ(2);
  @$pb.TagNumber(3)
  set title($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTitle() => $_has(2);
  @$pb.TagNumber(3)
  void clearTitle() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get description => $_getSZ(3);
  @$pb.TagNumber(4)
  set description($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasDescription() => $_has(3);
  @$pb.TagNumber(4)
  void clearDescription() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get status => $_getSZ(4);
  @$pb.TagNumber(5)
  set status($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasStatus() => $_has(4);
  @$pb.TagNumber(5)
  void clearStatus() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get priority => $_getSZ(5);
  @$pb.TagNumber(6)
  set priority($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasPriority() => $_has(5);
  @$pb.TagNumber(6)
  void clearPriority() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get startDate => $_getSZ(6);
  @$pb.TagNumber(7)
  set startDate($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasStartDate() => $_has(6);
  @$pb.TagNumber(7)
  void clearStartDate() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get dueDate => $_getSZ(7);
  @$pb.TagNumber(8)
  set dueDate($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasDueDate() => $_has(7);
  @$pb.TagNumber(8)
  void clearDueDate() => $_clearField(8);

  @$pb.TagNumber(9)
  $pb.PbList<$core.String> get assigneeIds => $_getList(8);

  @$pb.TagNumber(10)
  $core.String get parentId => $_getSZ(9);
  @$pb.TagNumber(10)
  set parentId($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasParentId() => $_has(9);
  @$pb.TagNumber(10)
  void clearParentId() => $_clearField(10);

  @$pb.TagNumber(11)
  $pb.PbList<TaskFieldValue> get fieldValues => $_getList(10);

  @$pb.TagNumber(12)
  $core.String get dueTime => $_getSZ(11);
  @$pb.TagNumber(12)
  set dueTime($core.String value) => $_setString(11, value);
  @$pb.TagNumber(12)
  $core.bool hasDueTime() => $_has(11);
  @$pb.TagNumber(12)
  void clearDueTime() => $_clearField(12);
}

class TaskDeleteRequest extends $pb.GeneratedMessage {
  factory TaskDeleteRequest({
    $core.String? workspaceId,
    $core.String? projectId,
    $core.String? id,
    $core.String? mode,
  }) {
    final result = TaskDeleteRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (projectId != null) result.projectId = projectId;
    if (id != null) result.id = id;
    if (mode != null) result.mode = mode;
    return result;
  }

  TaskDeleteRequest._();

  factory TaskDeleteRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TaskDeleteRequest()..mergeFromBuffer(data, registry);
  factory TaskDeleteRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TaskDeleteRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TaskDeleteRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.tasks'),
      createEmptyInstance: TaskDeleteRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..aOS(3, _omitFieldNames ? '' : 'id')
    ..aOS(4, _omitFieldNames ? '' : 'mode')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TaskDeleteRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TaskDeleteRequest copyWith(void Function(TaskDeleteRequest) updates) =>
      super.copyWith((message) => updates(message as TaskDeleteRequest))
          as TaskDeleteRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use TaskDeleteRequest() / TaskDeleteRequest.new instead')
  static TaskDeleteRequest create() => TaskDeleteRequest._();
  static $pb.GeneratedMessage $_createMessage() => TaskDeleteRequest._();
  @$core.override
  TaskDeleteRequest createEmptyInstance() => TaskDeleteRequest._();
  @$core.pragma('dart2js:noInline')
  static TaskDeleteRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TaskDeleteRequest>(
          TaskDeleteRequest.$_createMessage);
  static TaskDeleteRequest? _defaultInstance;

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
  $core.String get mode => $_getSZ(3);
  @$pb.TagNumber(4)
  set mode($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasMode() => $_has(3);
  @$pb.TagNumber(4)
  void clearMode() => $_clearField(4);
}

class TaskFieldValue extends $pb.GeneratedMessage {
  factory TaskFieldValue({
    $core.String? fieldId,
    $core.String? value,
  }) {
    final result = TaskFieldValue._();
    if (fieldId != null) result.fieldId = fieldId;
    if (value != null) result.value = value;
    return result;
  }

  TaskFieldValue._();

  factory TaskFieldValue.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TaskFieldValue()..mergeFromBuffer(data, registry);
  factory TaskFieldValue.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TaskFieldValue()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TaskFieldValue',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.tasks'),
      createEmptyInstance: TaskFieldValue.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'fieldId')
    ..aOS(2, _omitFieldNames ? '' : 'value')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TaskFieldValue clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TaskFieldValue copyWith(void Function(TaskFieldValue) updates) =>
      super.copyWith((message) => updates(message as TaskFieldValue))
          as TaskFieldValue;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use TaskFieldValue() / TaskFieldValue.new instead')
  static TaskFieldValue create() => TaskFieldValue._();
  static $pb.GeneratedMessage $_createMessage() => TaskFieldValue._();
  @$core.override
  TaskFieldValue createEmptyInstance() => TaskFieldValue._();
  @$core.pragma('dart2js:noInline')
  static TaskFieldValue getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TaskFieldValue>(
          TaskFieldValue.$_createMessage);
  static TaskFieldValue? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get fieldId => $_getSZ(0);
  @$pb.TagNumber(1)
  set fieldId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFieldId() => $_has(0);
  @$pb.TagNumber(1)
  void clearFieldId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get value => $_getSZ(1);
  @$pb.TagNumber(2)
  set value($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasValue() => $_has(1);
  @$pb.TagNumber(2)
  void clearValue() => $_clearField(2);
}

class TaskFieldValueResponse extends $pb.GeneratedMessage {
  factory TaskFieldValueResponse({
    $core.String? fieldId,
    $core.String? value,
  }) {
    final result = TaskFieldValueResponse._();
    if (fieldId != null) result.fieldId = fieldId;
    if (value != null) result.value = value;
    return result;
  }

  TaskFieldValueResponse._();

  factory TaskFieldValueResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TaskFieldValueResponse()..mergeFromBuffer(data, registry);
  factory TaskFieldValueResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TaskFieldValueResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TaskFieldValueResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.tasks'),
      createEmptyInstance: TaskFieldValueResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'fieldId')
    ..aOS(2, _omitFieldNames ? '' : 'value')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TaskFieldValueResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TaskFieldValueResponse copyWith(
          void Function(TaskFieldValueResponse) updates) =>
      super.copyWith((message) => updates(message as TaskFieldValueResponse))
          as TaskFieldValueResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use TaskFieldValueResponse() / TaskFieldValueResponse.new instead')
  static TaskFieldValueResponse create() => TaskFieldValueResponse._();
  static $pb.GeneratedMessage $_createMessage() => TaskFieldValueResponse._();
  @$core.override
  TaskFieldValueResponse createEmptyInstance() => TaskFieldValueResponse._();
  @$core.pragma('dart2js:noInline')
  static TaskFieldValueResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TaskFieldValueResponse>(
          TaskFieldValueResponse.$_createMessage);
  static TaskFieldValueResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get fieldId => $_getSZ(0);
  @$pb.TagNumber(1)
  set fieldId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFieldId() => $_has(0);
  @$pb.TagNumber(1)
  void clearFieldId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get value => $_getSZ(1);
  @$pb.TagNumber(2)
  set value($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasValue() => $_has(1);
  @$pb.TagNumber(2)
  void clearValue() => $_clearField(2);
}

class TaskGetRequest extends $pb.GeneratedMessage {
  factory TaskGetRequest({
    $core.String? workspaceId,
    $core.String? projectId,
    $core.String? id,
  }) {
    final result = TaskGetRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (projectId != null) result.projectId = projectId;
    if (id != null) result.id = id;
    return result;
  }

  TaskGetRequest._();

  factory TaskGetRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TaskGetRequest()..mergeFromBuffer(data, registry);
  factory TaskGetRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TaskGetRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TaskGetRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.tasks'),
      createEmptyInstance: TaskGetRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..aOS(3, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TaskGetRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TaskGetRequest copyWith(void Function(TaskGetRequest) updates) =>
      super.copyWith((message) => updates(message as TaskGetRequest))
          as TaskGetRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use TaskGetRequest() / TaskGetRequest.new instead')
  static TaskGetRequest create() => TaskGetRequest._();
  static $pb.GeneratedMessage $_createMessage() => TaskGetRequest._();
  @$core.override
  TaskGetRequest createEmptyInstance() => TaskGetRequest._();
  @$core.pragma('dart2js:noInline')
  static TaskGetRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TaskGetRequest>(
          TaskGetRequest.$_createMessage);
  static TaskGetRequest? _defaultInstance;

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

class TaskGroupCounts extends $pb.GeneratedMessage {
  factory TaskGroupCounts({
    $core.Iterable<GroupCount>? groups,
  }) {
    final result = TaskGroupCounts._();
    if (groups != null) result.groups.addAll(groups);
    return result;
  }

  TaskGroupCounts._();

  factory TaskGroupCounts.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TaskGroupCounts()..mergeFromBuffer(data, registry);
  factory TaskGroupCounts.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TaskGroupCounts()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TaskGroupCounts',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.tasks'),
      createEmptyInstance: TaskGroupCounts.$_createMessage)
    ..pPM<GroupCount>(1, _omitFieldNames ? '' : 'groups',
        subBuilder: GroupCount.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TaskGroupCounts clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TaskGroupCounts copyWith(void Function(TaskGroupCounts) updates) =>
      super.copyWith((message) => updates(message as TaskGroupCounts))
          as TaskGroupCounts;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use TaskGroupCounts() / TaskGroupCounts.new instead')
  static TaskGroupCounts create() => TaskGroupCounts._();
  static $pb.GeneratedMessage $_createMessage() => TaskGroupCounts._();
  @$core.override
  TaskGroupCounts createEmptyInstance() => TaskGroupCounts._();
  @$core.pragma('dart2js:noInline')
  static TaskGroupCounts getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TaskGroupCounts>(
          TaskGroupCounts.$_createMessage);
  static TaskGroupCounts? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<GroupCount> get groups => $_getList(0);
}

class TaskGroupCountsRequest extends $pb.GeneratedMessage {
  factory TaskGroupCountsRequest({
    $core.String? workspaceId,
    $core.String? projectId,
    $core.String? groupBy,
    $core.String? status,
    $core.String? assigneeId,
    $core.bool? includeSubtasks,
    $core.String? filterAst,
    $core.String? today,
  }) {
    final result = TaskGroupCountsRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (projectId != null) result.projectId = projectId;
    if (groupBy != null) result.groupBy = groupBy;
    if (status != null) result.status = status;
    if (assigneeId != null) result.assigneeId = assigneeId;
    if (includeSubtasks != null) result.includeSubtasks = includeSubtasks;
    if (filterAst != null) result.filterAst = filterAst;
    if (today != null) result.today = today;
    return result;
  }

  TaskGroupCountsRequest._();

  factory TaskGroupCountsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TaskGroupCountsRequest()..mergeFromBuffer(data, registry);
  factory TaskGroupCountsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TaskGroupCountsRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TaskGroupCountsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.tasks'),
      createEmptyInstance: TaskGroupCountsRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..aOS(3, _omitFieldNames ? '' : 'groupBy')
    ..aOS(4, _omitFieldNames ? '' : 'status')
    ..aOS(5, _omitFieldNames ? '' : 'assigneeId')
    ..aOB(6, _omitFieldNames ? '' : 'includeSubtasks')
    ..aOS(7, _omitFieldNames ? '' : 'filterAst')
    ..aOS(8, _omitFieldNames ? '' : 'today')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TaskGroupCountsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TaskGroupCountsRequest copyWith(
          void Function(TaskGroupCountsRequest) updates) =>
      super.copyWith((message) => updates(message as TaskGroupCountsRequest))
          as TaskGroupCountsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use TaskGroupCountsRequest() / TaskGroupCountsRequest.new instead')
  static TaskGroupCountsRequest create() => TaskGroupCountsRequest._();
  static $pb.GeneratedMessage $_createMessage() => TaskGroupCountsRequest._();
  @$core.override
  TaskGroupCountsRequest createEmptyInstance() => TaskGroupCountsRequest._();
  @$core.pragma('dart2js:noInline')
  static TaskGroupCountsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TaskGroupCountsRequest>(
          TaskGroupCountsRequest.$_createMessage);
  static TaskGroupCountsRequest? _defaultInstance;

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
  $core.String get groupBy => $_getSZ(2);
  @$pb.TagNumber(3)
  set groupBy($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasGroupBy() => $_has(2);
  @$pb.TagNumber(3)
  void clearGroupBy() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get status => $_getSZ(3);
  @$pb.TagNumber(4)
  set status($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasStatus() => $_has(3);
  @$pb.TagNumber(4)
  void clearStatus() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get assigneeId => $_getSZ(4);
  @$pb.TagNumber(5)
  set assigneeId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasAssigneeId() => $_has(4);
  @$pb.TagNumber(5)
  void clearAssigneeId() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.bool get includeSubtasks => $_getBF(5);
  @$pb.TagNumber(6)
  set includeSubtasks($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasIncludeSubtasks() => $_has(5);
  @$pb.TagNumber(6)
  void clearIncludeSubtasks() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get filterAst => $_getSZ(6);
  @$pb.TagNumber(7)
  set filterAst($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasFilterAst() => $_has(6);
  @$pb.TagNumber(7)
  void clearFilterAst() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get today => $_getSZ(7);
  @$pb.TagNumber(8)
  set today($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasToday() => $_has(7);
  @$pb.TagNumber(8)
  void clearToday() => $_clearField(8);
}

class TaskListChildrenRequest extends $pb.GeneratedMessage {
  factory TaskListChildrenRequest({
    $core.String? workspaceId,
    $core.String? projectId,
    $core.String? id,
  }) {
    final result = TaskListChildrenRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (projectId != null) result.projectId = projectId;
    if (id != null) result.id = id;
    return result;
  }

  TaskListChildrenRequest._();

  factory TaskListChildrenRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TaskListChildrenRequest()..mergeFromBuffer(data, registry);
  factory TaskListChildrenRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TaskListChildrenRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TaskListChildrenRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.tasks'),
      createEmptyInstance: TaskListChildrenRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..aOS(3, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TaskListChildrenRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TaskListChildrenRequest copyWith(
          void Function(TaskListChildrenRequest) updates) =>
      super.copyWith((message) => updates(message as TaskListChildrenRequest))
          as TaskListChildrenRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use TaskListChildrenRequest() / TaskListChildrenRequest.new instead')
  static TaskListChildrenRequest create() => TaskListChildrenRequest._();
  static $pb.GeneratedMessage $_createMessage() => TaskListChildrenRequest._();
  @$core.override
  TaskListChildrenRequest createEmptyInstance() => TaskListChildrenRequest._();
  @$core.pragma('dart2js:noInline')
  static TaskListChildrenRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TaskListChildrenRequest>(
          TaskListChildrenRequest.$_createMessage);
  static TaskListChildrenRequest? _defaultInstance;

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

class TaskListRequest extends $pb.GeneratedMessage {
  factory TaskListRequest({
    $core.String? workspaceId,
    $core.String? projectId,
    $core.String? status,
    $core.String? assigneeId,
    $core.String? cursor,
    $core.int? pageSize,
    $core.bool? includeSubtasks,
    $core.Iterable<SortKey>? sort,
    $core.String? groupBy,
    $core.String? filterAst,
    $core.String? today,
  }) {
    final result = TaskListRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (projectId != null) result.projectId = projectId;
    if (status != null) result.status = status;
    if (assigneeId != null) result.assigneeId = assigneeId;
    if (cursor != null) result.cursor = cursor;
    if (pageSize != null) result.pageSize = pageSize;
    if (includeSubtasks != null) result.includeSubtasks = includeSubtasks;
    if (sort != null) result.sort.addAll(sort);
    if (groupBy != null) result.groupBy = groupBy;
    if (filterAst != null) result.filterAst = filterAst;
    if (today != null) result.today = today;
    return result;
  }

  TaskListRequest._();

  factory TaskListRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TaskListRequest()..mergeFromBuffer(data, registry);
  factory TaskListRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TaskListRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TaskListRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.tasks'),
      createEmptyInstance: TaskListRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..aOS(3, _omitFieldNames ? '' : 'status')
    ..aOS(4, _omitFieldNames ? '' : 'assigneeId')
    ..aOS(5, _omitFieldNames ? '' : 'cursor')
    ..aI(6, _omitFieldNames ? '' : 'pageSize')
    ..aOB(7, _omitFieldNames ? '' : 'includeSubtasks')
    ..pPM<SortKey>(8, _omitFieldNames ? '' : 'sort',
        subBuilder: SortKey.$_createMessage)
    ..aOS(9, _omitFieldNames ? '' : 'groupBy')
    ..aOS(10, _omitFieldNames ? '' : 'filterAst')
    ..aOS(11, _omitFieldNames ? '' : 'today')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TaskListRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TaskListRequest copyWith(void Function(TaskListRequest) updates) =>
      super.copyWith((message) => updates(message as TaskListRequest))
          as TaskListRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use TaskListRequest() / TaskListRequest.new instead')
  static TaskListRequest create() => TaskListRequest._();
  static $pb.GeneratedMessage $_createMessage() => TaskListRequest._();
  @$core.override
  TaskListRequest createEmptyInstance() => TaskListRequest._();
  @$core.pragma('dart2js:noInline')
  static TaskListRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TaskListRequest>(
          TaskListRequest.$_createMessage);
  static TaskListRequest? _defaultInstance;

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
  $core.String get status => $_getSZ(2);
  @$pb.TagNumber(3)
  set status($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasStatus() => $_has(2);
  @$pb.TagNumber(3)
  void clearStatus() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get assigneeId => $_getSZ(3);
  @$pb.TagNumber(4)
  set assigneeId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasAssigneeId() => $_has(3);
  @$pb.TagNumber(4)
  void clearAssigneeId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get cursor => $_getSZ(4);
  @$pb.TagNumber(5)
  set cursor($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasCursor() => $_has(4);
  @$pb.TagNumber(5)
  void clearCursor() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get pageSize => $_getIZ(5);
  @$pb.TagNumber(6)
  set pageSize($core.int value) => $_setSignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasPageSize() => $_has(5);
  @$pb.TagNumber(6)
  void clearPageSize() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.bool get includeSubtasks => $_getBF(6);
  @$pb.TagNumber(7)
  set includeSubtasks($core.bool value) => $_setBool(6, value);
  @$pb.TagNumber(7)
  $core.bool hasIncludeSubtasks() => $_has(6);
  @$pb.TagNumber(7)
  void clearIncludeSubtasks() => $_clearField(7);

  @$pb.TagNumber(8)
  $pb.PbList<SortKey> get sort => $_getList(7);

  @$pb.TagNumber(9)
  $core.String get groupBy => $_getSZ(8);
  @$pb.TagNumber(9)
  set groupBy($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasGroupBy() => $_has(8);
  @$pb.TagNumber(9)
  void clearGroupBy() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get filterAst => $_getSZ(9);
  @$pb.TagNumber(10)
  set filterAst($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasFilterAst() => $_has(9);
  @$pb.TagNumber(10)
  void clearFilterAst() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.String get today => $_getSZ(10);
  @$pb.TagNumber(11)
  set today($core.String value) => $_setString(10, value);
  @$pb.TagNumber(11)
  $core.bool hasToday() => $_has(10);
  @$pb.TagNumber(11)
  void clearToday() => $_clearField(11);
}

class TaskListTrashRequest extends $pb.GeneratedMessage {
  factory TaskListTrashRequest({
    $core.String? workspaceId,
    $core.String? projectId,
  }) {
    final result = TaskListTrashRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (projectId != null) result.projectId = projectId;
    return result;
  }

  TaskListTrashRequest._();

  factory TaskListTrashRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TaskListTrashRequest()..mergeFromBuffer(data, registry);
  factory TaskListTrashRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TaskListTrashRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TaskListTrashRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.tasks'),
      createEmptyInstance: TaskListTrashRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TaskListTrashRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TaskListTrashRequest copyWith(void Function(TaskListTrashRequest) updates) =>
      super.copyWith((message) => updates(message as TaskListTrashRequest))
          as TaskListTrashRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use TaskListTrashRequest() / TaskListTrashRequest.new instead')
  static TaskListTrashRequest create() => TaskListTrashRequest._();
  static $pb.GeneratedMessage $_createMessage() => TaskListTrashRequest._();
  @$core.override
  TaskListTrashRequest createEmptyInstance() => TaskListTrashRequest._();
  @$core.pragma('dart2js:noInline')
  static TaskListTrashRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TaskListTrashRequest>(
          TaskListTrashRequest.$_createMessage);
  static TaskListTrashRequest? _defaultInstance;

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

class TaskMoveRequest extends $pb.GeneratedMessage {
  factory TaskMoveRequest({
    $core.String? workspaceId,
    $core.String? projectId,
    $core.String? id,
    $core.int? expectedVersion,
    $core.String? status,
    $core.bool? includeSubtasks,
    $core.bool? overrideBlocked,
  }) {
    final result = TaskMoveRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (projectId != null) result.projectId = projectId;
    if (id != null) result.id = id;
    if (expectedVersion != null) result.expectedVersion = expectedVersion;
    if (status != null) result.status = status;
    if (includeSubtasks != null) result.includeSubtasks = includeSubtasks;
    if (overrideBlocked != null) result.overrideBlocked = overrideBlocked;
    return result;
  }

  TaskMoveRequest._();

  factory TaskMoveRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TaskMoveRequest()..mergeFromBuffer(data, registry);
  factory TaskMoveRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TaskMoveRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TaskMoveRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.tasks'),
      createEmptyInstance: TaskMoveRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..aOS(3, _omitFieldNames ? '' : 'id')
    ..aI(4, _omitFieldNames ? '' : 'expectedVersion')
    ..aOS(5, _omitFieldNames ? '' : 'status')
    ..aOB(6, _omitFieldNames ? '' : 'includeSubtasks')
    ..aOB(7, _omitFieldNames ? '' : 'overrideBlocked')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TaskMoveRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TaskMoveRequest copyWith(void Function(TaskMoveRequest) updates) =>
      super.copyWith((message) => updates(message as TaskMoveRequest))
          as TaskMoveRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use TaskMoveRequest() / TaskMoveRequest.new instead')
  static TaskMoveRequest create() => TaskMoveRequest._();
  static $pb.GeneratedMessage $_createMessage() => TaskMoveRequest._();
  @$core.override
  TaskMoveRequest createEmptyInstance() => TaskMoveRequest._();
  @$core.pragma('dart2js:noInline')
  static TaskMoveRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TaskMoveRequest>(
          TaskMoveRequest.$_createMessage);
  static TaskMoveRequest? _defaultInstance;

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
  $core.String get status => $_getSZ(4);
  @$pb.TagNumber(5)
  set status($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasStatus() => $_has(4);
  @$pb.TagNumber(5)
  void clearStatus() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.bool get includeSubtasks => $_getBF(5);
  @$pb.TagNumber(6)
  set includeSubtasks($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasIncludeSubtasks() => $_has(5);
  @$pb.TagNumber(6)
  void clearIncludeSubtasks() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.bool get overrideBlocked => $_getBF(6);
  @$pb.TagNumber(7)
  set overrideBlocked($core.bool value) => $_setBool(6, value);
  @$pb.TagNumber(7)
  $core.bool hasOverrideBlocked() => $_has(6);
  @$pb.TagNumber(7)
  void clearOverrideBlocked() => $_clearField(7);
}

class TaskResponse extends $pb.GeneratedMessage {
  factory TaskResponse({
    $core.String? id,
    $core.String? workspaceId,
    $core.String? projectId,
    $core.int? number,
    $core.String? displayId,
    $core.String? title,
    $core.String? description,
    $core.String? status,
    $core.String? statusName,
    $core.String? statusCategory,
    $core.String? priority,
    $core.String? startDate,
    $core.String? dueDate,
    $core.Iterable<$core.String>? assigneeIds,
    $core.String? parentId,
    $core.int? depth,
    $core.int? progressDone,
    $core.int? progressTotal,
    $core.String? createdBy,
    $core.int? version,
    $core.String? position,
    $core.String? createdAt,
    $core.String? updatedAt,
    $core.String? deletedAt,
    $core.bool? isBlocked,
    $core.Iterable<$core.String>? blockedBy,
    $core.Iterable<TaskFieldValueResponse>? fields,
    $core.String? groupKey,
    $core.String? dueTime,
    $core.String? blockersDue,
    $core.String? blocksDue,
  }) {
    final result = TaskResponse._();
    if (id != null) result.id = id;
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (projectId != null) result.projectId = projectId;
    if (number != null) result.number = number;
    if (displayId != null) result.displayId = displayId;
    if (title != null) result.title = title;
    if (description != null) result.description = description;
    if (status != null) result.status = status;
    if (statusName != null) result.statusName = statusName;
    if (statusCategory != null) result.statusCategory = statusCategory;
    if (priority != null) result.priority = priority;
    if (startDate != null) result.startDate = startDate;
    if (dueDate != null) result.dueDate = dueDate;
    if (assigneeIds != null) result.assigneeIds.addAll(assigneeIds);
    if (parentId != null) result.parentId = parentId;
    if (depth != null) result.depth = depth;
    if (progressDone != null) result.progressDone = progressDone;
    if (progressTotal != null) result.progressTotal = progressTotal;
    if (createdBy != null) result.createdBy = createdBy;
    if (version != null) result.version = version;
    if (position != null) result.position = position;
    if (createdAt != null) result.createdAt = createdAt;
    if (updatedAt != null) result.updatedAt = updatedAt;
    if (deletedAt != null) result.deletedAt = deletedAt;
    if (isBlocked != null) result.isBlocked = isBlocked;
    if (blockedBy != null) result.blockedBy.addAll(blockedBy);
    if (fields != null) result.fields.addAll(fields);
    if (groupKey != null) result.groupKey = groupKey;
    if (dueTime != null) result.dueTime = dueTime;
    if (blockersDue != null) result.blockersDue = blockersDue;
    if (blocksDue != null) result.blocksDue = blocksDue;
    return result;
  }

  TaskResponse._();

  factory TaskResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TaskResponse()..mergeFromBuffer(data, registry);
  factory TaskResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TaskResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TaskResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.tasks'),
      createEmptyInstance: TaskResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(3, _omitFieldNames ? '' : 'projectId')
    ..aI(4, _omitFieldNames ? '' : 'number')
    ..aOS(5, _omitFieldNames ? '' : 'displayId')
    ..aOS(6, _omitFieldNames ? '' : 'title')
    ..aOS(7, _omitFieldNames ? '' : 'description')
    ..aOS(8, _omitFieldNames ? '' : 'status')
    ..aOS(9, _omitFieldNames ? '' : 'statusName')
    ..aOS(10, _omitFieldNames ? '' : 'statusCategory')
    ..aOS(11, _omitFieldNames ? '' : 'priority')
    ..aOS(12, _omitFieldNames ? '' : 'startDate')
    ..aOS(13, _omitFieldNames ? '' : 'dueDate')
    ..pPS(14, _omitFieldNames ? '' : 'assigneeIds')
    ..aOS(15, _omitFieldNames ? '' : 'parentId')
    ..aI(16, _omitFieldNames ? '' : 'depth')
    ..aI(17, _omitFieldNames ? '' : 'progressDone')
    ..aI(18, _omitFieldNames ? '' : 'progressTotal')
    ..aOS(19, _omitFieldNames ? '' : 'createdBy')
    ..aI(20, _omitFieldNames ? '' : 'version')
    ..aOS(21, _omitFieldNames ? '' : 'position')
    ..aOS(22, _omitFieldNames ? '' : 'createdAt')
    ..aOS(23, _omitFieldNames ? '' : 'updatedAt')
    ..aOS(24, _omitFieldNames ? '' : 'deletedAt')
    ..aOB(25, _omitFieldNames ? '' : 'isBlocked')
    ..pPS(26, _omitFieldNames ? '' : 'blockedBy')
    ..pPM<TaskFieldValueResponse>(27, _omitFieldNames ? '' : 'fields',
        subBuilder: TaskFieldValueResponse.$_createMessage)
    ..aOS(28, _omitFieldNames ? '' : 'groupKey')
    ..aOS(29, _omitFieldNames ? '' : 'dueTime')
    ..aOS(30, _omitFieldNames ? '' : 'blockersDue')
    ..aOS(31, _omitFieldNames ? '' : 'blocksDue')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TaskResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TaskResponse copyWith(void Function(TaskResponse) updates) =>
      super.copyWith((message) => updates(message as TaskResponse))
          as TaskResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use TaskResponse() / TaskResponse.new instead')
  static TaskResponse create() => TaskResponse._();
  static $pb.GeneratedMessage $_createMessage() => TaskResponse._();
  @$core.override
  TaskResponse createEmptyInstance() => TaskResponse._();
  @$core.pragma('dart2js:noInline')
  static TaskResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TaskResponse>(
          TaskResponse.$_createMessage);
  static TaskResponse? _defaultInstance;

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
  $core.int get number => $_getIZ(3);
  @$pb.TagNumber(4)
  set number($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasNumber() => $_has(3);
  @$pb.TagNumber(4)
  void clearNumber() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get displayId => $_getSZ(4);
  @$pb.TagNumber(5)
  set displayId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasDisplayId() => $_has(4);
  @$pb.TagNumber(5)
  void clearDisplayId() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get title => $_getSZ(5);
  @$pb.TagNumber(6)
  set title($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasTitle() => $_has(5);
  @$pb.TagNumber(6)
  void clearTitle() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get description => $_getSZ(6);
  @$pb.TagNumber(7)
  set description($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasDescription() => $_has(6);
  @$pb.TagNumber(7)
  void clearDescription() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get status => $_getSZ(7);
  @$pb.TagNumber(8)
  set status($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasStatus() => $_has(7);
  @$pb.TagNumber(8)
  void clearStatus() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get statusName => $_getSZ(8);
  @$pb.TagNumber(9)
  set statusName($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasStatusName() => $_has(8);
  @$pb.TagNumber(9)
  void clearStatusName() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get statusCategory => $_getSZ(9);
  @$pb.TagNumber(10)
  set statusCategory($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasStatusCategory() => $_has(9);
  @$pb.TagNumber(10)
  void clearStatusCategory() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.String get priority => $_getSZ(10);
  @$pb.TagNumber(11)
  set priority($core.String value) => $_setString(10, value);
  @$pb.TagNumber(11)
  $core.bool hasPriority() => $_has(10);
  @$pb.TagNumber(11)
  void clearPriority() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.String get startDate => $_getSZ(11);
  @$pb.TagNumber(12)
  set startDate($core.String value) => $_setString(11, value);
  @$pb.TagNumber(12)
  $core.bool hasStartDate() => $_has(11);
  @$pb.TagNumber(12)
  void clearStartDate() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.String get dueDate => $_getSZ(12);
  @$pb.TagNumber(13)
  set dueDate($core.String value) => $_setString(12, value);
  @$pb.TagNumber(13)
  $core.bool hasDueDate() => $_has(12);
  @$pb.TagNumber(13)
  void clearDueDate() => $_clearField(13);

  @$pb.TagNumber(14)
  $pb.PbList<$core.String> get assigneeIds => $_getList(13);

  @$pb.TagNumber(15)
  $core.String get parentId => $_getSZ(14);
  @$pb.TagNumber(15)
  set parentId($core.String value) => $_setString(14, value);
  @$pb.TagNumber(15)
  $core.bool hasParentId() => $_has(14);
  @$pb.TagNumber(15)
  void clearParentId() => $_clearField(15);

  @$pb.TagNumber(16)
  $core.int get depth => $_getIZ(15);
  @$pb.TagNumber(16)
  set depth($core.int value) => $_setSignedInt32(15, value);
  @$pb.TagNumber(16)
  $core.bool hasDepth() => $_has(15);
  @$pb.TagNumber(16)
  void clearDepth() => $_clearField(16);

  @$pb.TagNumber(17)
  $core.int get progressDone => $_getIZ(16);
  @$pb.TagNumber(17)
  set progressDone($core.int value) => $_setSignedInt32(16, value);
  @$pb.TagNumber(17)
  $core.bool hasProgressDone() => $_has(16);
  @$pb.TagNumber(17)
  void clearProgressDone() => $_clearField(17);

  @$pb.TagNumber(18)
  $core.int get progressTotal => $_getIZ(17);
  @$pb.TagNumber(18)
  set progressTotal($core.int value) => $_setSignedInt32(17, value);
  @$pb.TagNumber(18)
  $core.bool hasProgressTotal() => $_has(17);
  @$pb.TagNumber(18)
  void clearProgressTotal() => $_clearField(18);

  @$pb.TagNumber(19)
  $core.String get createdBy => $_getSZ(18);
  @$pb.TagNumber(19)
  set createdBy($core.String value) => $_setString(18, value);
  @$pb.TagNumber(19)
  $core.bool hasCreatedBy() => $_has(18);
  @$pb.TagNumber(19)
  void clearCreatedBy() => $_clearField(19);

  @$pb.TagNumber(20)
  $core.int get version => $_getIZ(19);
  @$pb.TagNumber(20)
  set version($core.int value) => $_setSignedInt32(19, value);
  @$pb.TagNumber(20)
  $core.bool hasVersion() => $_has(19);
  @$pb.TagNumber(20)
  void clearVersion() => $_clearField(20);

  @$pb.TagNumber(21)
  $core.String get position => $_getSZ(20);
  @$pb.TagNumber(21)
  set position($core.String value) => $_setString(20, value);
  @$pb.TagNumber(21)
  $core.bool hasPosition() => $_has(20);
  @$pb.TagNumber(21)
  void clearPosition() => $_clearField(21);

  @$pb.TagNumber(22)
  $core.String get createdAt => $_getSZ(21);
  @$pb.TagNumber(22)
  set createdAt($core.String value) => $_setString(21, value);
  @$pb.TagNumber(22)
  $core.bool hasCreatedAt() => $_has(21);
  @$pb.TagNumber(22)
  void clearCreatedAt() => $_clearField(22);

  @$pb.TagNumber(23)
  $core.String get updatedAt => $_getSZ(22);
  @$pb.TagNumber(23)
  set updatedAt($core.String value) => $_setString(22, value);
  @$pb.TagNumber(23)
  $core.bool hasUpdatedAt() => $_has(22);
  @$pb.TagNumber(23)
  void clearUpdatedAt() => $_clearField(23);

  @$pb.TagNumber(24)
  $core.String get deletedAt => $_getSZ(23);
  @$pb.TagNumber(24)
  set deletedAt($core.String value) => $_setString(23, value);
  @$pb.TagNumber(24)
  $core.bool hasDeletedAt() => $_has(23);
  @$pb.TagNumber(24)
  void clearDeletedAt() => $_clearField(24);

  @$pb.TagNumber(25)
  $core.bool get isBlocked => $_getBF(24);
  @$pb.TagNumber(25)
  set isBlocked($core.bool value) => $_setBool(24, value);
  @$pb.TagNumber(25)
  $core.bool hasIsBlocked() => $_has(24);
  @$pb.TagNumber(25)
  void clearIsBlocked() => $_clearField(25);

  @$pb.TagNumber(26)
  $pb.PbList<$core.String> get blockedBy => $_getList(25);

  @$pb.TagNumber(27)
  $pb.PbList<TaskFieldValueResponse> get fields => $_getList(26);

  @$pb.TagNumber(28)
  $core.String get groupKey => $_getSZ(27);
  @$pb.TagNumber(28)
  set groupKey($core.String value) => $_setString(27, value);
  @$pb.TagNumber(28)
  $core.bool hasGroupKey() => $_has(27);
  @$pb.TagNumber(28)
  void clearGroupKey() => $_clearField(28);

  @$pb.TagNumber(29)
  $core.String get dueTime => $_getSZ(28);
  @$pb.TagNumber(29)
  set dueTime($core.String value) => $_setString(28, value);
  @$pb.TagNumber(29)
  $core.bool hasDueTime() => $_has(28);
  @$pb.TagNumber(29)
  void clearDueTime() => $_clearField(29);

  @$pb.TagNumber(30)
  $core.String get blockersDue => $_getSZ(29);
  @$pb.TagNumber(30)
  set blockersDue($core.String value) => $_setString(29, value);
  @$pb.TagNumber(30)
  $core.bool hasBlockersDue() => $_has(29);
  @$pb.TagNumber(30)
  void clearBlockersDue() => $_clearField(30);

  @$pb.TagNumber(31)
  $core.String get blocksDue => $_getSZ(30);
  @$pb.TagNumber(31)
  set blocksDue($core.String value) => $_setString(30, value);
  @$pb.TagNumber(31)
  $core.bool hasBlocksDue() => $_has(30);
  @$pb.TagNumber(31)
  void clearBlocksDue() => $_clearField(31);
}

class TaskRestoreRequest extends $pb.GeneratedMessage {
  factory TaskRestoreRequest({
    $core.String? workspaceId,
    $core.String? projectId,
    $core.String? id,
  }) {
    final result = TaskRestoreRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (projectId != null) result.projectId = projectId;
    if (id != null) result.id = id;
    return result;
  }

  TaskRestoreRequest._();

  factory TaskRestoreRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TaskRestoreRequest()..mergeFromBuffer(data, registry);
  factory TaskRestoreRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TaskRestoreRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TaskRestoreRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.tasks'),
      createEmptyInstance: TaskRestoreRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..aOS(3, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TaskRestoreRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TaskRestoreRequest copyWith(void Function(TaskRestoreRequest) updates) =>
      super.copyWith((message) => updates(message as TaskRestoreRequest))
          as TaskRestoreRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use TaskRestoreRequest() / TaskRestoreRequest.new instead')
  static TaskRestoreRequest create() => TaskRestoreRequest._();
  static $pb.GeneratedMessage $_createMessage() => TaskRestoreRequest._();
  @$core.override
  TaskRestoreRequest createEmptyInstance() => TaskRestoreRequest._();
  @$core.pragma('dart2js:noInline')
  static TaskRestoreRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TaskRestoreRequest>(
          TaskRestoreRequest.$_createMessage);
  static TaskRestoreRequest? _defaultInstance;

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

class TaskSetParentRequest extends $pb.GeneratedMessage {
  factory TaskSetParentRequest({
    $core.String? workspaceId,
    $core.String? projectId,
    $core.String? id,
    $core.int? expectedVersion,
    $core.String? parentId,
  }) {
    final result = TaskSetParentRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (projectId != null) result.projectId = projectId;
    if (id != null) result.id = id;
    if (expectedVersion != null) result.expectedVersion = expectedVersion;
    if (parentId != null) result.parentId = parentId;
    return result;
  }

  TaskSetParentRequest._();

  factory TaskSetParentRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TaskSetParentRequest()..mergeFromBuffer(data, registry);
  factory TaskSetParentRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TaskSetParentRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TaskSetParentRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.tasks'),
      createEmptyInstance: TaskSetParentRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..aOS(3, _omitFieldNames ? '' : 'id')
    ..aI(4, _omitFieldNames ? '' : 'expectedVersion')
    ..aOS(5, _omitFieldNames ? '' : 'parentId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TaskSetParentRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TaskSetParentRequest copyWith(void Function(TaskSetParentRequest) updates) =>
      super.copyWith((message) => updates(message as TaskSetParentRequest))
          as TaskSetParentRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use TaskSetParentRequest() / TaskSetParentRequest.new instead')
  static TaskSetParentRequest create() => TaskSetParentRequest._();
  static $pb.GeneratedMessage $_createMessage() => TaskSetParentRequest._();
  @$core.override
  TaskSetParentRequest createEmptyInstance() => TaskSetParentRequest._();
  @$core.pragma('dart2js:noInline')
  static TaskSetParentRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TaskSetParentRequest>(
          TaskSetParentRequest.$_createMessage);
  static TaskSetParentRequest? _defaultInstance;

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
  $core.String get parentId => $_getSZ(4);
  @$pb.TagNumber(5)
  set parentId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasParentId() => $_has(4);
  @$pb.TagNumber(5)
  void clearParentId() => $_clearField(5);
}

class TaskTrash extends $pb.GeneratedMessage {
  factory TaskTrash({
    $core.Iterable<Task>? tasks,
  }) {
    final result = TaskTrash._();
    if (tasks != null) result.tasks.addAll(tasks);
    return result;
  }

  TaskTrash._();

  factory TaskTrash.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TaskTrash()..mergeFromBuffer(data, registry);
  factory TaskTrash.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TaskTrash()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TaskTrash',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.tasks'),
      createEmptyInstance: TaskTrash.$_createMessage)
    ..pPM<Task>(1, _omitFieldNames ? '' : 'tasks',
        subBuilder: Task.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TaskTrash clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TaskTrash copyWith(void Function(TaskTrash) updates) =>
      super.copyWith((message) => updates(message as TaskTrash)) as TaskTrash;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use TaskTrash() / TaskTrash.new instead')
  static TaskTrash create() => TaskTrash._();
  static $pb.GeneratedMessage $_createMessage() => TaskTrash._();
  @$core.override
  TaskTrash createEmptyInstance() => TaskTrash._();
  @$core.pragma('dart2js:noInline')
  static TaskTrash getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TaskTrash>(TaskTrash.$_createMessage);
  static TaskTrash? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Task> get tasks => $_getList(0);
}

class TaskUpdateRequest extends $pb.GeneratedMessage {
  factory TaskUpdateRequest({
    $core.String? workspaceId,
    $core.String? projectId,
    $core.String? id,
    $core.int? expectedVersion,
    $core.String? title,
    $core.String? description,
    $core.String? status,
    $core.String? priority,
    $core.String? startDate,
    $core.String? dueDate,
    $core.bool? setAssignees,
    $core.Iterable<$core.String>? assigneeIds,
    $core.bool? overrideBlocked,
    $core.Iterable<TaskFieldValue>? fieldValues,
    $core.String? dueTime,
  }) {
    final result = TaskUpdateRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (projectId != null) result.projectId = projectId;
    if (id != null) result.id = id;
    if (expectedVersion != null) result.expectedVersion = expectedVersion;
    if (title != null) result.title = title;
    if (description != null) result.description = description;
    if (status != null) result.status = status;
    if (priority != null) result.priority = priority;
    if (startDate != null) result.startDate = startDate;
    if (dueDate != null) result.dueDate = dueDate;
    if (setAssignees != null) result.setAssignees = setAssignees;
    if (assigneeIds != null) result.assigneeIds.addAll(assigneeIds);
    if (overrideBlocked != null) result.overrideBlocked = overrideBlocked;
    if (fieldValues != null) result.fieldValues.addAll(fieldValues);
    if (dueTime != null) result.dueTime = dueTime;
    return result;
  }

  TaskUpdateRequest._();

  factory TaskUpdateRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TaskUpdateRequest()..mergeFromBuffer(data, registry);
  factory TaskUpdateRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TaskUpdateRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TaskUpdateRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.tasks'),
      createEmptyInstance: TaskUpdateRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..aOS(3, _omitFieldNames ? '' : 'id')
    ..aI(4, _omitFieldNames ? '' : 'expectedVersion')
    ..aOS(5, _omitFieldNames ? '' : 'title')
    ..aOS(6, _omitFieldNames ? '' : 'description')
    ..aOS(7, _omitFieldNames ? '' : 'status')
    ..aOS(8, _omitFieldNames ? '' : 'priority')
    ..aOS(9, _omitFieldNames ? '' : 'startDate')
    ..aOS(10, _omitFieldNames ? '' : 'dueDate')
    ..aOB(11, _omitFieldNames ? '' : 'setAssignees')
    ..pPS(12, _omitFieldNames ? '' : 'assigneeIds')
    ..aOB(13, _omitFieldNames ? '' : 'overrideBlocked')
    ..pPM<TaskFieldValue>(14, _omitFieldNames ? '' : 'fieldValues',
        subBuilder: TaskFieldValue.$_createMessage)
    ..aOS(15, _omitFieldNames ? '' : 'dueTime')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TaskUpdateRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TaskUpdateRequest copyWith(void Function(TaskUpdateRequest) updates) =>
      super.copyWith((message) => updates(message as TaskUpdateRequest))
          as TaskUpdateRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use TaskUpdateRequest() / TaskUpdateRequest.new instead')
  static TaskUpdateRequest create() => TaskUpdateRequest._();
  static $pb.GeneratedMessage $_createMessage() => TaskUpdateRequest._();
  @$core.override
  TaskUpdateRequest createEmptyInstance() => TaskUpdateRequest._();
  @$core.pragma('dart2js:noInline')
  static TaskUpdateRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TaskUpdateRequest>(
          TaskUpdateRequest.$_createMessage);
  static TaskUpdateRequest? _defaultInstance;

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
  $core.String get title => $_getSZ(4);
  @$pb.TagNumber(5)
  set title($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasTitle() => $_has(4);
  @$pb.TagNumber(5)
  void clearTitle() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get description => $_getSZ(5);
  @$pb.TagNumber(6)
  set description($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasDescription() => $_has(5);
  @$pb.TagNumber(6)
  void clearDescription() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get status => $_getSZ(6);
  @$pb.TagNumber(7)
  set status($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasStatus() => $_has(6);
  @$pb.TagNumber(7)
  void clearStatus() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get priority => $_getSZ(7);
  @$pb.TagNumber(8)
  set priority($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasPriority() => $_has(7);
  @$pb.TagNumber(8)
  void clearPriority() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get startDate => $_getSZ(8);
  @$pb.TagNumber(9)
  set startDate($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasStartDate() => $_has(8);
  @$pb.TagNumber(9)
  void clearStartDate() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get dueDate => $_getSZ(9);
  @$pb.TagNumber(10)
  set dueDate($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasDueDate() => $_has(9);
  @$pb.TagNumber(10)
  void clearDueDate() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.bool get setAssignees => $_getBF(10);
  @$pb.TagNumber(11)
  set setAssignees($core.bool value) => $_setBool(10, value);
  @$pb.TagNumber(11)
  $core.bool hasSetAssignees() => $_has(10);
  @$pb.TagNumber(11)
  void clearSetAssignees() => $_clearField(11);

  @$pb.TagNumber(12)
  $pb.PbList<$core.String> get assigneeIds => $_getList(11);

  @$pb.TagNumber(13)
  $core.bool get overrideBlocked => $_getBF(12);
  @$pb.TagNumber(13)
  set overrideBlocked($core.bool value) => $_setBool(12, value);
  @$pb.TagNumber(13)
  $core.bool hasOverrideBlocked() => $_has(12);
  @$pb.TagNumber(13)
  void clearOverrideBlocked() => $_clearField(13);

  @$pb.TagNumber(14)
  $pb.PbList<TaskFieldValue> get fieldValues => $_getList(13);

  @$pb.TagNumber(15)
  $core.String get dueTime => $_getSZ(14);
  @$pb.TagNumber(15)
  set dueTime($core.String value) => $_setString(14, value);
  @$pb.TagNumber(15)
  $core.bool hasDueTime() => $_has(14);
  @$pb.TagNumber(15)
  void clearDueTime() => $_clearField(15);
}

class TimelineApplied extends $pb.GeneratedMessage {
  factory TimelineApplied({
    $core.Iterable<Task>? tasks,
  }) {
    final result = TimelineApplied._();
    if (tasks != null) result.tasks.addAll(tasks);
    return result;
  }

  TimelineApplied._();

  factory TimelineApplied.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TimelineApplied()..mergeFromBuffer(data, registry);
  factory TimelineApplied.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TimelineApplied()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TimelineApplied',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.tasks'),
      createEmptyInstance: TimelineApplied.$_createMessage)
    ..pPM<Task>(1, _omitFieldNames ? '' : 'tasks',
        subBuilder: Task.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TimelineApplied clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TimelineApplied copyWith(void Function(TimelineApplied) updates) =>
      super.copyWith((message) => updates(message as TimelineApplied))
          as TimelineApplied;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use TimelineApplied() / TimelineApplied.new instead')
  static TimelineApplied create() => TimelineApplied._();
  static $pb.GeneratedMessage $_createMessage() => TimelineApplied._();
  @$core.override
  TimelineApplied createEmptyInstance() => TimelineApplied._();
  @$core.pragma('dart2js:noInline')
  static TimelineApplied getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TimelineApplied>(
          TimelineApplied.$_createMessage);
  static TimelineApplied? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Task> get tasks => $_getList(0);
}

class TimelineApplyRequest extends $pb.GeneratedMessage {
  factory TimelineApplyRequest({
    $core.String? workspaceId,
    $core.String? projectId,
    $core.String? taskId,
    $core.String? startDate,
    $core.String? dueDate,
    $core.int? expectedVersion,
    $core.Iterable<$core.String>? affectedIds,
  }) {
    final result = TimelineApplyRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (projectId != null) result.projectId = projectId;
    if (taskId != null) result.taskId = taskId;
    if (startDate != null) result.startDate = startDate;
    if (dueDate != null) result.dueDate = dueDate;
    if (expectedVersion != null) result.expectedVersion = expectedVersion;
    if (affectedIds != null) result.affectedIds.addAll(affectedIds);
    return result;
  }

  TimelineApplyRequest._();

  factory TimelineApplyRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TimelineApplyRequest()..mergeFromBuffer(data, registry);
  factory TimelineApplyRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TimelineApplyRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TimelineApplyRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.tasks'),
      createEmptyInstance: TimelineApplyRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..aOS(3, _omitFieldNames ? '' : 'taskId')
    ..aOS(4, _omitFieldNames ? '' : 'startDate')
    ..aOS(5, _omitFieldNames ? '' : 'dueDate')
    ..aI(6, _omitFieldNames ? '' : 'expectedVersion')
    ..pPS(7, _omitFieldNames ? '' : 'affectedIds')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TimelineApplyRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TimelineApplyRequest copyWith(void Function(TimelineApplyRequest) updates) =>
      super.copyWith((message) => updates(message as TimelineApplyRequest))
          as TimelineApplyRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use TimelineApplyRequest() / TimelineApplyRequest.new instead')
  static TimelineApplyRequest create() => TimelineApplyRequest._();
  static $pb.GeneratedMessage $_createMessage() => TimelineApplyRequest._();
  @$core.override
  TimelineApplyRequest createEmptyInstance() => TimelineApplyRequest._();
  @$core.pragma('dart2js:noInline')
  static TimelineApplyRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TimelineApplyRequest>(
          TimelineApplyRequest.$_createMessage);
  static TimelineApplyRequest? _defaultInstance;

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
  $core.String get startDate => $_getSZ(3);
  @$pb.TagNumber(4)
  set startDate($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasStartDate() => $_has(3);
  @$pb.TagNumber(4)
  void clearStartDate() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get dueDate => $_getSZ(4);
  @$pb.TagNumber(5)
  set dueDate($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasDueDate() => $_has(4);
  @$pb.TagNumber(5)
  void clearDueDate() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get expectedVersion => $_getIZ(5);
  @$pb.TagNumber(6)
  set expectedVersion($core.int value) => $_setSignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasExpectedVersion() => $_has(5);
  @$pb.TagNumber(6)
  void clearExpectedVersion() => $_clearField(6);

  @$pb.TagNumber(7)
  $pb.PbList<$core.String> get affectedIds => $_getList(6);
}

class TimelineChunk extends $pb.GeneratedMessage {
  factory TimelineChunk({
    $core.Iterable<Task>? tasks,
    $core.Iterable<TimelineLink>? links,
  }) {
    final result = TimelineChunk._();
    if (tasks != null) result.tasks.addAll(tasks);
    if (links != null) result.links.addAll(links);
    return result;
  }

  TimelineChunk._();

  factory TimelineChunk.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TimelineChunk()..mergeFromBuffer(data, registry);
  factory TimelineChunk.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TimelineChunk()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TimelineChunk',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.tasks'),
      createEmptyInstance: TimelineChunk.$_createMessage)
    ..pPM<Task>(1, _omitFieldNames ? '' : 'tasks',
        subBuilder: Task.$_createMessage)
    ..pPM<TimelineLink>(2, _omitFieldNames ? '' : 'links',
        subBuilder: TimelineLink.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TimelineChunk clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TimelineChunk copyWith(void Function(TimelineChunk) updates) =>
      super.copyWith((message) => updates(message as TimelineChunk))
          as TimelineChunk;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use TimelineChunk() / TimelineChunk.new instead')
  static TimelineChunk create() => TimelineChunk._();
  static $pb.GeneratedMessage $_createMessage() => TimelineChunk._();
  @$core.override
  TimelineChunk createEmptyInstance() => TimelineChunk._();
  @$core.pragma('dart2js:noInline')
  static TimelineChunk getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TimelineChunk>(
          TimelineChunk.$_createMessage);
  static TimelineChunk? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Task> get tasks => $_getList(0);

  @$pb.TagNumber(2)
  $pb.PbList<TimelineLink> get links => $_getList(1);
}

class TimelineCriticalPath extends $pb.GeneratedMessage {
  factory TimelineCriticalPath({
    $core.Iterable<$core.String>? taskIds,
  }) {
    final result = TimelineCriticalPath._();
    if (taskIds != null) result.taskIds.addAll(taskIds);
    return result;
  }

  TimelineCriticalPath._();

  factory TimelineCriticalPath.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TimelineCriticalPath()..mergeFromBuffer(data, registry);
  factory TimelineCriticalPath.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TimelineCriticalPath()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TimelineCriticalPath',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.tasks'),
      createEmptyInstance: TimelineCriticalPath.$_createMessage)
    ..pPS(1, _omitFieldNames ? '' : 'taskIds')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TimelineCriticalPath clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TimelineCriticalPath copyWith(void Function(TimelineCriticalPath) updates) =>
      super.copyWith((message) => updates(message as TimelineCriticalPath))
          as TimelineCriticalPath;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use TimelineCriticalPath() / TimelineCriticalPath.new instead')
  static TimelineCriticalPath create() => TimelineCriticalPath._();
  static $pb.GeneratedMessage $_createMessage() => TimelineCriticalPath._();
  @$core.override
  TimelineCriticalPath createEmptyInstance() => TimelineCriticalPath._();
  @$core.pragma('dart2js:noInline')
  static TimelineCriticalPath getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TimelineCriticalPath>(
          TimelineCriticalPath.$_createMessage);
  static TimelineCriticalPath? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$core.String> get taskIds => $_getList(0);
}

class TimelineCriticalPathRequest extends $pb.GeneratedMessage {
  factory TimelineCriticalPathRequest({
    $core.String? workspaceId,
    $core.String? projectId,
  }) {
    final result = TimelineCriticalPathRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (projectId != null) result.projectId = projectId;
    return result;
  }

  TimelineCriticalPathRequest._();

  factory TimelineCriticalPathRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TimelineCriticalPathRequest()..mergeFromBuffer(data, registry);
  factory TimelineCriticalPathRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TimelineCriticalPathRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TimelineCriticalPathRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.tasks'),
      createEmptyInstance: TimelineCriticalPathRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TimelineCriticalPathRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TimelineCriticalPathRequest copyWith(
          void Function(TimelineCriticalPathRequest) updates) =>
      super.copyWith(
              (message) => updates(message as TimelineCriticalPathRequest))
          as TimelineCriticalPathRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use TimelineCriticalPathRequest() / TimelineCriticalPathRequest.new instead')
  static TimelineCriticalPathRequest create() =>
      TimelineCriticalPathRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      TimelineCriticalPathRequest._();
  @$core.override
  TimelineCriticalPathRequest createEmptyInstance() =>
      TimelineCriticalPathRequest._();
  @$core.pragma('dart2js:noInline')
  static TimelineCriticalPathRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TimelineCriticalPathRequest>(
          TimelineCriticalPathRequest.$_createMessage);
  static TimelineCriticalPathRequest? _defaultInstance;

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

class TimelineGetRequest extends $pb.GeneratedMessage {
  factory TimelineGetRequest({
    $core.String? workspaceId,
    $core.String? projectId,
    $core.String? rangeStart,
    $core.String? rangeEnd,
    $core.bool? includeDone,
    $core.String? filterAst,
    $core.String? today,
  }) {
    final result = TimelineGetRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (projectId != null) result.projectId = projectId;
    if (rangeStart != null) result.rangeStart = rangeStart;
    if (rangeEnd != null) result.rangeEnd = rangeEnd;
    if (includeDone != null) result.includeDone = includeDone;
    if (filterAst != null) result.filterAst = filterAst;
    if (today != null) result.today = today;
    return result;
  }

  TimelineGetRequest._();

  factory TimelineGetRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TimelineGetRequest()..mergeFromBuffer(data, registry);
  factory TimelineGetRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TimelineGetRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TimelineGetRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.tasks'),
      createEmptyInstance: TimelineGetRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..aOS(3, _omitFieldNames ? '' : 'rangeStart')
    ..aOS(4, _omitFieldNames ? '' : 'rangeEnd')
    ..aOB(5, _omitFieldNames ? '' : 'includeDone')
    ..aOS(6, _omitFieldNames ? '' : 'filterAst')
    ..aOS(7, _omitFieldNames ? '' : 'today')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TimelineGetRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TimelineGetRequest copyWith(void Function(TimelineGetRequest) updates) =>
      super.copyWith((message) => updates(message as TimelineGetRequest))
          as TimelineGetRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use TimelineGetRequest() / TimelineGetRequest.new instead')
  static TimelineGetRequest create() => TimelineGetRequest._();
  static $pb.GeneratedMessage $_createMessage() => TimelineGetRequest._();
  @$core.override
  TimelineGetRequest createEmptyInstance() => TimelineGetRequest._();
  @$core.pragma('dart2js:noInline')
  static TimelineGetRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TimelineGetRequest>(
          TimelineGetRequest.$_createMessage);
  static TimelineGetRequest? _defaultInstance;

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
  $core.String get rangeStart => $_getSZ(2);
  @$pb.TagNumber(3)
  set rangeStart($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRangeStart() => $_has(2);
  @$pb.TagNumber(3)
  void clearRangeStart() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get rangeEnd => $_getSZ(3);
  @$pb.TagNumber(4)
  set rangeEnd($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasRangeEnd() => $_has(3);
  @$pb.TagNumber(4)
  void clearRangeEnd() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.bool get includeDone => $_getBF(4);
  @$pb.TagNumber(5)
  set includeDone($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasIncludeDone() => $_has(4);
  @$pb.TagNumber(5)
  void clearIncludeDone() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get filterAst => $_getSZ(5);
  @$pb.TagNumber(6)
  set filterAst($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasFilterAst() => $_has(5);
  @$pb.TagNumber(6)
  void clearFilterAst() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get today => $_getSZ(6);
  @$pb.TagNumber(7)
  set today($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasToday() => $_has(6);
  @$pb.TagNumber(7)
  void clearToday() => $_clearField(7);
}

class TimelineLink extends $pb.GeneratedMessage {
  factory TimelineLink({
    $core.String? fromId,
    $core.String? toId,
  }) {
    final result = TimelineLink._();
    if (fromId != null) result.fromId = fromId;
    if (toId != null) result.toId = toId;
    return result;
  }

  TimelineLink._();

  factory TimelineLink.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TimelineLink()..mergeFromBuffer(data, registry);
  factory TimelineLink.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TimelineLink()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TimelineLink',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.tasks'),
      createEmptyInstance: TimelineLink.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'fromId')
    ..aOS(2, _omitFieldNames ? '' : 'toId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TimelineLink clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TimelineLink copyWith(void Function(TimelineLink) updates) =>
      super.copyWith((message) => updates(message as TimelineLink))
          as TimelineLink;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use TimelineLink() / TimelineLink.new instead')
  static TimelineLink create() => TimelineLink._();
  static $pb.GeneratedMessage $_createMessage() => TimelineLink._();
  @$core.override
  TimelineLink createEmptyInstance() => TimelineLink._();
  @$core.pragma('dart2js:noInline')
  static TimelineLink getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TimelineLink>(
          TimelineLink.$_createMessage);
  static TimelineLink? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get fromId => $_getSZ(0);
  @$pb.TagNumber(1)
  set fromId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFromId() => $_has(0);
  @$pb.TagNumber(1)
  void clearFromId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get toId => $_getSZ(1);
  @$pb.TagNumber(2)
  set toId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasToId() => $_has(1);
  @$pb.TagNumber(2)
  void clearToId() => $_clearField(2);
}

class TimelinePreviewRequest extends $pb.GeneratedMessage {
  factory TimelinePreviewRequest({
    $core.String? workspaceId,
    $core.String? projectId,
    $core.String? taskId,
    $core.String? startDate,
    $core.String? dueDate,
  }) {
    final result = TimelinePreviewRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (projectId != null) result.projectId = projectId;
    if (taskId != null) result.taskId = taskId;
    if (startDate != null) result.startDate = startDate;
    if (dueDate != null) result.dueDate = dueDate;
    return result;
  }

  TimelinePreviewRequest._();

  factory TimelinePreviewRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TimelinePreviewRequest()..mergeFromBuffer(data, registry);
  factory TimelinePreviewRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TimelinePreviewRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TimelinePreviewRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.tasks'),
      createEmptyInstance: TimelinePreviewRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..aOS(3, _omitFieldNames ? '' : 'taskId')
    ..aOS(4, _omitFieldNames ? '' : 'startDate')
    ..aOS(5, _omitFieldNames ? '' : 'dueDate')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TimelinePreviewRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TimelinePreviewRequest copyWith(
          void Function(TimelinePreviewRequest) updates) =>
      super.copyWith((message) => updates(message as TimelinePreviewRequest))
          as TimelinePreviewRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use TimelinePreviewRequest() / TimelinePreviewRequest.new instead')
  static TimelinePreviewRequest create() => TimelinePreviewRequest._();
  static $pb.GeneratedMessage $_createMessage() => TimelinePreviewRequest._();
  @$core.override
  TimelinePreviewRequest createEmptyInstance() => TimelinePreviewRequest._();
  @$core.pragma('dart2js:noInline')
  static TimelinePreviewRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TimelinePreviewRequest>(
          TimelinePreviewRequest.$_createMessage);
  static TimelinePreviewRequest? _defaultInstance;

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
  $core.String get startDate => $_getSZ(3);
  @$pb.TagNumber(4)
  set startDate($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasStartDate() => $_has(3);
  @$pb.TagNumber(4)
  void clearStartDate() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get dueDate => $_getSZ(4);
  @$pb.TagNumber(5)
  set dueDate($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasDueDate() => $_has(4);
  @$pb.TagNumber(5)
  void clearDueDate() => $_clearField(5);
}

class TimelineShift extends $pb.GeneratedMessage {
  factory TimelineShift({
    Task? task,
    $core.String? newStart,
    $core.String? newDue,
  }) {
    final result = TimelineShift._();
    if (task != null) result.task = task;
    if (newStart != null) result.newStart = newStart;
    if (newDue != null) result.newDue = newDue;
    return result;
  }

  TimelineShift._();

  factory TimelineShift.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TimelineShift()..mergeFromBuffer(data, registry);
  factory TimelineShift.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TimelineShift()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TimelineShift',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.tasks'),
      createEmptyInstance: TimelineShift.$_createMessage)
    ..aOM<Task>(1, _omitFieldNames ? '' : 'task',
        subBuilder: Task.$_createMessage)
    ..aOS(2, _omitFieldNames ? '' : 'newStart')
    ..aOS(3, _omitFieldNames ? '' : 'newDue')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TimelineShift clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TimelineShift copyWith(void Function(TimelineShift) updates) =>
      super.copyWith((message) => updates(message as TimelineShift))
          as TimelineShift;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use TimelineShift() / TimelineShift.new instead')
  static TimelineShift create() => TimelineShift._();
  static $pb.GeneratedMessage $_createMessage() => TimelineShift._();
  @$core.override
  TimelineShift createEmptyInstance() => TimelineShift._();
  @$core.pragma('dart2js:noInline')
  static TimelineShift getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TimelineShift>(
          TimelineShift.$_createMessage);
  static TimelineShift? _defaultInstance;

  @$pb.TagNumber(1)
  Task get task => $_getN(0);
  @$pb.TagNumber(1)
  set task(Task value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasTask() => $_has(0);
  @$pb.TagNumber(1)
  void clearTask() => $_clearField(1);
  @$pb.TagNumber(1)
  Task ensureTask() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.String get newStart => $_getSZ(1);
  @$pb.TagNumber(2)
  set newStart($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasNewStart() => $_has(1);
  @$pb.TagNumber(2)
  void clearNewStart() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get newDue => $_getSZ(2);
  @$pb.TagNumber(3)
  set newDue($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasNewDue() => $_has(2);
  @$pb.TagNumber(3)
  void clearNewDue() => $_clearField(3);
}

class TimelineShifts extends $pb.GeneratedMessage {
  factory TimelineShifts({
    $core.Iterable<TimelineShift>? shifts,
  }) {
    final result = TimelineShifts._();
    if (shifts != null) result.shifts.addAll(shifts);
    return result;
  }

  TimelineShifts._();

  factory TimelineShifts.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TimelineShifts()..mergeFromBuffer(data, registry);
  factory TimelineShifts.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TimelineShifts()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TimelineShifts',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.tasks'),
      createEmptyInstance: TimelineShifts.$_createMessage)
    ..pPM<TimelineShift>(1, _omitFieldNames ? '' : 'shifts',
        subBuilder: TimelineShift.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TimelineShifts clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TimelineShifts copyWith(void Function(TimelineShifts) updates) =>
      super.copyWith((message) => updates(message as TimelineShifts))
          as TimelineShifts;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use TimelineShifts() / TimelineShifts.new instead')
  static TimelineShifts create() => TimelineShifts._();
  static $pb.GeneratedMessage $_createMessage() => TimelineShifts._();
  @$core.override
  TimelineShifts createEmptyInstance() => TimelineShifts._();
  @$core.pragma('dart2js:noInline')
  static TimelineShifts getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TimelineShifts>(
          TimelineShifts.$_createMessage);
  static TimelineShifts? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<TimelineShift> get shifts => $_getList(0);
}

class TimelineWorkingDays extends $pb.GeneratedMessage {
  factory TimelineWorkingDays({
    $core.Iterable<$core.int>? days,
    $core.Iterable<$core.String>? holidays,
  }) {
    final result = TimelineWorkingDays._();
    if (days != null) result.days.addAll(days);
    if (holidays != null) result.holidays.addAll(holidays);
    return result;
  }

  TimelineWorkingDays._();

  factory TimelineWorkingDays.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TimelineWorkingDays()..mergeFromBuffer(data, registry);
  factory TimelineWorkingDays.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TimelineWorkingDays()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TimelineWorkingDays',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.tasks'),
      createEmptyInstance: TimelineWorkingDays.$_createMessage)
    ..p<$core.int>(1, _omitFieldNames ? '' : 'days', $pb.PbFieldType.K3)
    ..pPS(2, _omitFieldNames ? '' : 'holidays')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TimelineWorkingDays clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TimelineWorkingDays copyWith(void Function(TimelineWorkingDays) updates) =>
      super.copyWith((message) => updates(message as TimelineWorkingDays))
          as TimelineWorkingDays;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core
      .Deprecated('Use TimelineWorkingDays() / TimelineWorkingDays.new instead')
  static TimelineWorkingDays create() => TimelineWorkingDays._();
  static $pb.GeneratedMessage $_createMessage() => TimelineWorkingDays._();
  @$core.override
  TimelineWorkingDays createEmptyInstance() => TimelineWorkingDays._();
  @$core.pragma('dart2js:noInline')
  static TimelineWorkingDays getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TimelineWorkingDays>(
          TimelineWorkingDays.$_createMessage);
  static TimelineWorkingDays? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$core.int> get days => $_getList(0);

  @$pb.TagNumber(2)
  $pb.PbList<$core.String> get holidays => $_getList(1);
}

class TimelineWorkingDaysGetRequest extends $pb.GeneratedMessage {
  factory TimelineWorkingDaysGetRequest({
    $core.String? workspaceId,
  }) {
    final result = TimelineWorkingDaysGetRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    return result;
  }

  TimelineWorkingDaysGetRequest._();

  factory TimelineWorkingDaysGetRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TimelineWorkingDaysGetRequest()..mergeFromBuffer(data, registry);
  factory TimelineWorkingDaysGetRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TimelineWorkingDaysGetRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TimelineWorkingDaysGetRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.tasks'),
      createEmptyInstance: TimelineWorkingDaysGetRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TimelineWorkingDaysGetRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TimelineWorkingDaysGetRequest copyWith(
          void Function(TimelineWorkingDaysGetRequest) updates) =>
      super.copyWith(
              (message) => updates(message as TimelineWorkingDaysGetRequest))
          as TimelineWorkingDaysGetRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use TimelineWorkingDaysGetRequest() / TimelineWorkingDaysGetRequest.new instead')
  static TimelineWorkingDaysGetRequest create() =>
      TimelineWorkingDaysGetRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      TimelineWorkingDaysGetRequest._();
  @$core.override
  TimelineWorkingDaysGetRequest createEmptyInstance() =>
      TimelineWorkingDaysGetRequest._();
  @$core.pragma('dart2js:noInline')
  static TimelineWorkingDaysGetRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TimelineWorkingDaysGetRequest>(
          TimelineWorkingDaysGetRequest.$_createMessage);
  static TimelineWorkingDaysGetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);
}

class TimelineWorkingDaysSetRequest extends $pb.GeneratedMessage {
  factory TimelineWorkingDaysSetRequest({
    $core.String? workspaceId,
    $core.Iterable<$core.int>? days,
    $core.Iterable<$core.String>? holidays,
  }) {
    final result = TimelineWorkingDaysSetRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (days != null) result.days.addAll(days);
    if (holidays != null) result.holidays.addAll(holidays);
    return result;
  }

  TimelineWorkingDaysSetRequest._();

  factory TimelineWorkingDaysSetRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TimelineWorkingDaysSetRequest()..mergeFromBuffer(data, registry);
  factory TimelineWorkingDaysSetRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TimelineWorkingDaysSetRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TimelineWorkingDaysSetRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.tasks'),
      createEmptyInstance: TimelineWorkingDaysSetRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..p<$core.int>(2, _omitFieldNames ? '' : 'days', $pb.PbFieldType.K3)
    ..pPS(3, _omitFieldNames ? '' : 'holidays')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TimelineWorkingDaysSetRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TimelineWorkingDaysSetRequest copyWith(
          void Function(TimelineWorkingDaysSetRequest) updates) =>
      super.copyWith(
              (message) => updates(message as TimelineWorkingDaysSetRequest))
          as TimelineWorkingDaysSetRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use TimelineWorkingDaysSetRequest() / TimelineWorkingDaysSetRequest.new instead')
  static TimelineWorkingDaysSetRequest create() =>
      TimelineWorkingDaysSetRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      TimelineWorkingDaysSetRequest._();
  @$core.override
  TimelineWorkingDaysSetRequest createEmptyInstance() =>
      TimelineWorkingDaysSetRequest._();
  @$core.pragma('dart2js:noInline')
  static TimelineWorkingDaysSetRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TimelineWorkingDaysSetRequest>(
          TimelineWorkingDaysSetRequest.$_createMessage);
  static TimelineWorkingDaysSetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<$core.int> get days => $_getList(1);

  @$pb.TagNumber(3)
  $pb.PbList<$core.String> get holidays => $_getList(2);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
