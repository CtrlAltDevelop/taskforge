// This is a generated file - do not edit.
//
// Generated from infrastructure/savedviews/grpc/savedviews.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class BoardLayout extends $pb.GeneratedMessage {
  factory BoardLayout({
    $core.String? groupBy,
    $core.String? swimlane,
    $core.Iterable<$core.String>? cardFields,
    $core.Iterable<BoardLimit>? limits,
  }) {
    final result = BoardLayout._();
    if (groupBy != null) result.groupBy = groupBy;
    if (swimlane != null) result.swimlane = swimlane;
    if (cardFields != null) result.cardFields.addAll(cardFields);
    if (limits != null) result.limits.addAll(limits);
    return result;
  }

  BoardLayout._();

  factory BoardLayout.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BoardLayout()..mergeFromBuffer(data, registry);
  factory BoardLayout.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BoardLayout()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'BoardLayout',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.savedviews'),
      createEmptyInstance: BoardLayout.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'groupBy')
    ..aOS(2, _omitFieldNames ? '' : 'swimlane')
    ..pPS(3, _omitFieldNames ? '' : 'cardFields')
    ..pPM<BoardLimit>(4, _omitFieldNames ? '' : 'limits',
        subBuilder: BoardLimit.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BoardLayout clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BoardLayout copyWith(void Function(BoardLayout) updates) =>
      super.copyWith((message) => updates(message as BoardLayout))
          as BoardLayout;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use BoardLayout() / BoardLayout.new instead')
  static BoardLayout create() => BoardLayout._();
  static $pb.GeneratedMessage $_createMessage() => BoardLayout._();
  @$core.override
  BoardLayout createEmptyInstance() => BoardLayout._();
  @$core.pragma('dart2js:noInline')
  static BoardLayout getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<BoardLayout>(
          BoardLayout.$_createMessage);
  static BoardLayout? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get groupBy => $_getSZ(0);
  @$pb.TagNumber(1)
  set groupBy($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasGroupBy() => $_has(0);
  @$pb.TagNumber(1)
  void clearGroupBy() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get swimlane => $_getSZ(1);
  @$pb.TagNumber(2)
  set swimlane($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSwimlane() => $_has(1);
  @$pb.TagNumber(2)
  void clearSwimlane() => $_clearField(2);

  @$pb.TagNumber(3)
  $pb.PbList<$core.String> get cardFields => $_getList(2);

  @$pb.TagNumber(4)
  $pb.PbList<BoardLimit> get limits => $_getList(3);
}

class BoardLayoutResponse extends $pb.GeneratedMessage {
  factory BoardLayoutResponse({
    $core.String? groupBy,
    $core.String? swimlane,
    $core.Iterable<$core.String>? cardFields,
    $core.Iterable<BoardLimitResponse>? limits,
  }) {
    final result = BoardLayoutResponse._();
    if (groupBy != null) result.groupBy = groupBy;
    if (swimlane != null) result.swimlane = swimlane;
    if (cardFields != null) result.cardFields.addAll(cardFields);
    if (limits != null) result.limits.addAll(limits);
    return result;
  }

  BoardLayoutResponse._();

  factory BoardLayoutResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BoardLayoutResponse()..mergeFromBuffer(data, registry);
  factory BoardLayoutResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BoardLayoutResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'BoardLayoutResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.savedviews'),
      createEmptyInstance: BoardLayoutResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'groupBy')
    ..aOS(2, _omitFieldNames ? '' : 'swimlane')
    ..pPS(3, _omitFieldNames ? '' : 'cardFields')
    ..pPM<BoardLimitResponse>(4, _omitFieldNames ? '' : 'limits',
        subBuilder: BoardLimitResponse.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BoardLayoutResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BoardLayoutResponse copyWith(void Function(BoardLayoutResponse) updates) =>
      super.copyWith((message) => updates(message as BoardLayoutResponse))
          as BoardLayoutResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core
      .Deprecated('Use BoardLayoutResponse() / BoardLayoutResponse.new instead')
  static BoardLayoutResponse create() => BoardLayoutResponse._();
  static $pb.GeneratedMessage $_createMessage() => BoardLayoutResponse._();
  @$core.override
  BoardLayoutResponse createEmptyInstance() => BoardLayoutResponse._();
  @$core.pragma('dart2js:noInline')
  static BoardLayoutResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<BoardLayoutResponse>(
          BoardLayoutResponse.$_createMessage);
  static BoardLayoutResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get groupBy => $_getSZ(0);
  @$pb.TagNumber(1)
  set groupBy($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasGroupBy() => $_has(0);
  @$pb.TagNumber(1)
  void clearGroupBy() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get swimlane => $_getSZ(1);
  @$pb.TagNumber(2)
  set swimlane($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSwimlane() => $_has(1);
  @$pb.TagNumber(2)
  void clearSwimlane() => $_clearField(2);

  @$pb.TagNumber(3)
  $pb.PbList<$core.String> get cardFields => $_getList(2);

  @$pb.TagNumber(4)
  $pb.PbList<BoardLimitResponse> get limits => $_getList(3);
}

class BoardLimit extends $pb.GeneratedMessage {
  factory BoardLimit({
    $core.String? column,
    $core.int? limit,
  }) {
    final result = BoardLimit._();
    if (column != null) result.column = column;
    if (limit != null) result.limit = limit;
    return result;
  }

  BoardLimit._();

  factory BoardLimit.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BoardLimit()..mergeFromBuffer(data, registry);
  factory BoardLimit.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BoardLimit()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'BoardLimit',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.savedviews'),
      createEmptyInstance: BoardLimit.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'column')
    ..aI(2, _omitFieldNames ? '' : 'limit')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BoardLimit clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BoardLimit copyWith(void Function(BoardLimit) updates) =>
      super.copyWith((message) => updates(message as BoardLimit)) as BoardLimit;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use BoardLimit() / BoardLimit.new instead')
  static BoardLimit create() => BoardLimit._();
  static $pb.GeneratedMessage $_createMessage() => BoardLimit._();
  @$core.override
  BoardLimit createEmptyInstance() => BoardLimit._();
  @$core.pragma('dart2js:noInline')
  static BoardLimit getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<BoardLimit>(BoardLimit.$_createMessage);
  static BoardLimit? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get column => $_getSZ(0);
  @$pb.TagNumber(1)
  set column($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasColumn() => $_has(0);
  @$pb.TagNumber(1)
  void clearColumn() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get limit => $_getIZ(1);
  @$pb.TagNumber(2)
  set limit($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasLimit() => $_has(1);
  @$pb.TagNumber(2)
  void clearLimit() => $_clearField(2);
}

class BoardLimitResponse extends $pb.GeneratedMessage {
  factory BoardLimitResponse({
    $core.String? column,
    $core.int? limit,
  }) {
    final result = BoardLimitResponse._();
    if (column != null) result.column = column;
    if (limit != null) result.limit = limit;
    return result;
  }

  BoardLimitResponse._();

  factory BoardLimitResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BoardLimitResponse()..mergeFromBuffer(data, registry);
  factory BoardLimitResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BoardLimitResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'BoardLimitResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.savedviews'),
      createEmptyInstance: BoardLimitResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'column')
    ..aI(2, _omitFieldNames ? '' : 'limit')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BoardLimitResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BoardLimitResponse copyWith(void Function(BoardLimitResponse) updates) =>
      super.copyWith((message) => updates(message as BoardLimitResponse))
          as BoardLimitResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use BoardLimitResponse() / BoardLimitResponse.new instead')
  static BoardLimitResponse create() => BoardLimitResponse._();
  static $pb.GeneratedMessage $_createMessage() => BoardLimitResponse._();
  @$core.override
  BoardLimitResponse createEmptyInstance() => BoardLimitResponse._();
  @$core.pragma('dart2js:noInline')
  static BoardLimitResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<BoardLimitResponse>(
          BoardLimitResponse.$_createMessage);
  static BoardLimitResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get column => $_getSZ(0);
  @$pb.TagNumber(1)
  set column($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasColumn() => $_has(0);
  @$pb.TagNumber(1)
  void clearColumn() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get limit => $_getIZ(1);
  @$pb.TagNumber(2)
  set limit($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasLimit() => $_has(1);
  @$pb.TagNumber(2)
  void clearLimit() => $_clearField(2);
}

class CalendarLayout extends $pb.GeneratedMessage {
  factory CalendarLayout({
    $core.String? mode,
    $core.String? colorBy,
    $core.int? weekStart,
    $core.bool? hideDone,
  }) {
    final result = CalendarLayout._();
    if (mode != null) result.mode = mode;
    if (colorBy != null) result.colorBy = colorBy;
    if (weekStart != null) result.weekStart = weekStart;
    if (hideDone != null) result.hideDone = hideDone;
    return result;
  }

  CalendarLayout._();

  factory CalendarLayout.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CalendarLayout()..mergeFromBuffer(data, registry);
  factory CalendarLayout.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CalendarLayout()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CalendarLayout',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.savedviews'),
      createEmptyInstance: CalendarLayout.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'mode')
    ..aOS(2, _omitFieldNames ? '' : 'colorBy')
    ..aI(3, _omitFieldNames ? '' : 'weekStart')
    ..aOB(4, _omitFieldNames ? '' : 'hideDone')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CalendarLayout clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CalendarLayout copyWith(void Function(CalendarLayout) updates) =>
      super.copyWith((message) => updates(message as CalendarLayout))
          as CalendarLayout;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CalendarLayout() / CalendarLayout.new instead')
  static CalendarLayout create() => CalendarLayout._();
  static $pb.GeneratedMessage $_createMessage() => CalendarLayout._();
  @$core.override
  CalendarLayout createEmptyInstance() => CalendarLayout._();
  @$core.pragma('dart2js:noInline')
  static CalendarLayout getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CalendarLayout>(
          CalendarLayout.$_createMessage);
  static CalendarLayout? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get mode => $_getSZ(0);
  @$pb.TagNumber(1)
  set mode($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMode() => $_has(0);
  @$pb.TagNumber(1)
  void clearMode() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get colorBy => $_getSZ(1);
  @$pb.TagNumber(2)
  set colorBy($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasColorBy() => $_has(1);
  @$pb.TagNumber(2)
  void clearColorBy() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get weekStart => $_getIZ(2);
  @$pb.TagNumber(3)
  set weekStart($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasWeekStart() => $_has(2);
  @$pb.TagNumber(3)
  void clearWeekStart() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get hideDone => $_getBF(3);
  @$pb.TagNumber(4)
  set hideDone($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasHideDone() => $_has(3);
  @$pb.TagNumber(4)
  void clearHideDone() => $_clearField(4);
}

class CalendarLayoutResponse extends $pb.GeneratedMessage {
  factory CalendarLayoutResponse({
    $core.String? mode,
    $core.String? colorBy,
    $core.int? weekStart,
    $core.bool? hideDone,
  }) {
    final result = CalendarLayoutResponse._();
    if (mode != null) result.mode = mode;
    if (colorBy != null) result.colorBy = colorBy;
    if (weekStart != null) result.weekStart = weekStart;
    if (hideDone != null) result.hideDone = hideDone;
    return result;
  }

  CalendarLayoutResponse._();

  factory CalendarLayoutResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CalendarLayoutResponse()..mergeFromBuffer(data, registry);
  factory CalendarLayoutResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CalendarLayoutResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CalendarLayoutResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.savedviews'),
      createEmptyInstance: CalendarLayoutResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'mode')
    ..aOS(2, _omitFieldNames ? '' : 'colorBy')
    ..aI(3, _omitFieldNames ? '' : 'weekStart')
    ..aOB(4, _omitFieldNames ? '' : 'hideDone')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CalendarLayoutResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CalendarLayoutResponse copyWith(
          void Function(CalendarLayoutResponse) updates) =>
      super.copyWith((message) => updates(message as CalendarLayoutResponse))
          as CalendarLayoutResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use CalendarLayoutResponse() / CalendarLayoutResponse.new instead')
  static CalendarLayoutResponse create() => CalendarLayoutResponse._();
  static $pb.GeneratedMessage $_createMessage() => CalendarLayoutResponse._();
  @$core.override
  CalendarLayoutResponse createEmptyInstance() => CalendarLayoutResponse._();
  @$core.pragma('dart2js:noInline')
  static CalendarLayoutResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CalendarLayoutResponse>(
          CalendarLayoutResponse.$_createMessage);
  static CalendarLayoutResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get mode => $_getSZ(0);
  @$pb.TagNumber(1)
  set mode($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMode() => $_has(0);
  @$pb.TagNumber(1)
  void clearMode() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get colorBy => $_getSZ(1);
  @$pb.TagNumber(2)
  set colorBy($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasColorBy() => $_has(1);
  @$pb.TagNumber(2)
  void clearColorBy() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get weekStart => $_getIZ(2);
  @$pb.TagNumber(3)
  set weekStart($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasWeekStart() => $_has(2);
  @$pb.TagNumber(3)
  void clearWeekStart() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get hideDone => $_getBF(3);
  @$pb.TagNumber(4)
  set hideDone($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasHideDone() => $_has(3);
  @$pb.TagNumber(4)
  void clearHideDone() => $_clearField(4);
}

class FilterLayout extends $pb.GeneratedMessage {
  factory FilterLayout({
    $core.String? astJson,
    $core.String? savedId,
  }) {
    final result = FilterLayout._();
    if (astJson != null) result.astJson = astJson;
    if (savedId != null) result.savedId = savedId;
    return result;
  }

  FilterLayout._();

  factory FilterLayout.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FilterLayout()..mergeFromBuffer(data, registry);
  factory FilterLayout.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FilterLayout()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FilterLayout',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.savedviews'),
      createEmptyInstance: FilterLayout.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'astJson')
    ..aOS(2, _omitFieldNames ? '' : 'savedId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FilterLayout clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FilterLayout copyWith(void Function(FilterLayout) updates) =>
      super.copyWith((message) => updates(message as FilterLayout))
          as FilterLayout;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use FilterLayout() / FilterLayout.new instead')
  static FilterLayout create() => FilterLayout._();
  static $pb.GeneratedMessage $_createMessage() => FilterLayout._();
  @$core.override
  FilterLayout createEmptyInstance() => FilterLayout._();
  @$core.pragma('dart2js:noInline')
  static FilterLayout getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<FilterLayout>(
          FilterLayout.$_createMessage);
  static FilterLayout? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get astJson => $_getSZ(0);
  @$pb.TagNumber(1)
  set astJson($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAstJson() => $_has(0);
  @$pb.TagNumber(1)
  void clearAstJson() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get savedId => $_getSZ(1);
  @$pb.TagNumber(2)
  set savedId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSavedId() => $_has(1);
  @$pb.TagNumber(2)
  void clearSavedId() => $_clearField(2);
}

class FilterLayoutResponse extends $pb.GeneratedMessage {
  factory FilterLayoutResponse({
    $core.String? astJson,
    $core.String? savedId,
  }) {
    final result = FilterLayoutResponse._();
    if (astJson != null) result.astJson = astJson;
    if (savedId != null) result.savedId = savedId;
    return result;
  }

  FilterLayoutResponse._();

  factory FilterLayoutResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FilterLayoutResponse()..mergeFromBuffer(data, registry);
  factory FilterLayoutResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FilterLayoutResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FilterLayoutResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.savedviews'),
      createEmptyInstance: FilterLayoutResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'astJson')
    ..aOS(2, _omitFieldNames ? '' : 'savedId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FilterLayoutResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FilterLayoutResponse copyWith(void Function(FilterLayoutResponse) updates) =>
      super.copyWith((message) => updates(message as FilterLayoutResponse))
          as FilterLayoutResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use FilterLayoutResponse() / FilterLayoutResponse.new instead')
  static FilterLayoutResponse create() => FilterLayoutResponse._();
  static $pb.GeneratedMessage $_createMessage() => FilterLayoutResponse._();
  @$core.override
  FilterLayoutResponse createEmptyInstance() => FilterLayoutResponse._();
  @$core.pragma('dart2js:noInline')
  static FilterLayoutResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FilterLayoutResponse>(
          FilterLayoutResponse.$_createMessage);
  static FilterLayoutResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get astJson => $_getSZ(0);
  @$pb.TagNumber(1)
  set astJson($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAstJson() => $_has(0);
  @$pb.TagNumber(1)
  void clearAstJson() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get savedId => $_getSZ(1);
  @$pb.TagNumber(2)
  set savedId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSavedId() => $_has(1);
  @$pb.TagNumber(2)
  void clearSavedId() => $_clearField(2);
}

class Layout extends $pb.GeneratedMessage {
  factory Layout({
    $core.Iterable<$core.String>? columns,
    $core.Iterable<LayoutWidth>? widths,
    $core.Iterable<LayoutSort>? sort,
    $core.String? groupBy,
  }) {
    final result = Layout._();
    if (columns != null) result.columns.addAll(columns);
    if (widths != null) result.widths.addAll(widths);
    if (sort != null) result.sort.addAll(sort);
    if (groupBy != null) result.groupBy = groupBy;
    return result;
  }

  Layout._();

  factory Layout.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Layout()..mergeFromBuffer(data, registry);
  factory Layout.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Layout()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Layout',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.savedviews'),
      createEmptyInstance: Layout.$_createMessage)
    ..pPS(1, _omitFieldNames ? '' : 'columns')
    ..pPM<LayoutWidth>(2, _omitFieldNames ? '' : 'widths',
        subBuilder: LayoutWidth.$_createMessage)
    ..pPM<LayoutSort>(3, _omitFieldNames ? '' : 'sort',
        subBuilder: LayoutSort.$_createMessage)
    ..aOS(4, _omitFieldNames ? '' : 'groupBy')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Layout clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Layout copyWith(void Function(Layout) updates) =>
      super.copyWith((message) => updates(message as Layout)) as Layout;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Layout() / Layout.new instead')
  static Layout create() => Layout._();
  static $pb.GeneratedMessage $_createMessage() => Layout._();
  @$core.override
  Layout createEmptyInstance() => Layout._();
  @$core.pragma('dart2js:noInline')
  static Layout getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Layout>(Layout.$_createMessage);
  static Layout? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$core.String> get columns => $_getList(0);

  @$pb.TagNumber(2)
  $pb.PbList<LayoutWidth> get widths => $_getList(1);

  @$pb.TagNumber(3)
  $pb.PbList<LayoutSort> get sort => $_getList(2);

  @$pb.TagNumber(4)
  $core.String get groupBy => $_getSZ(3);
  @$pb.TagNumber(4)
  set groupBy($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasGroupBy() => $_has(3);
  @$pb.TagNumber(4)
  void clearGroupBy() => $_clearField(4);
}

class LayoutResponse extends $pb.GeneratedMessage {
  factory LayoutResponse({
    $core.Iterable<$core.String>? columns,
    $core.Iterable<LayoutWidthResponse>? widths,
    $core.Iterable<LayoutSortResponse>? sort,
    $core.String? groupBy,
  }) {
    final result = LayoutResponse._();
    if (columns != null) result.columns.addAll(columns);
    if (widths != null) result.widths.addAll(widths);
    if (sort != null) result.sort.addAll(sort);
    if (groupBy != null) result.groupBy = groupBy;
    return result;
  }

  LayoutResponse._();

  factory LayoutResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LayoutResponse()..mergeFromBuffer(data, registry);
  factory LayoutResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LayoutResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LayoutResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.savedviews'),
      createEmptyInstance: LayoutResponse.$_createMessage)
    ..pPS(1, _omitFieldNames ? '' : 'columns')
    ..pPM<LayoutWidthResponse>(2, _omitFieldNames ? '' : 'widths',
        subBuilder: LayoutWidthResponse.$_createMessage)
    ..pPM<LayoutSortResponse>(3, _omitFieldNames ? '' : 'sort',
        subBuilder: LayoutSortResponse.$_createMessage)
    ..aOS(4, _omitFieldNames ? '' : 'groupBy')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LayoutResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LayoutResponse copyWith(void Function(LayoutResponse) updates) =>
      super.copyWith((message) => updates(message as LayoutResponse))
          as LayoutResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use LayoutResponse() / LayoutResponse.new instead')
  static LayoutResponse create() => LayoutResponse._();
  static $pb.GeneratedMessage $_createMessage() => LayoutResponse._();
  @$core.override
  LayoutResponse createEmptyInstance() => LayoutResponse._();
  @$core.pragma('dart2js:noInline')
  static LayoutResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LayoutResponse>(
          LayoutResponse.$_createMessage);
  static LayoutResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$core.String> get columns => $_getList(0);

  @$pb.TagNumber(2)
  $pb.PbList<LayoutWidthResponse> get widths => $_getList(1);

  @$pb.TagNumber(3)
  $pb.PbList<LayoutSortResponse> get sort => $_getList(2);

  @$pb.TagNumber(4)
  $core.String get groupBy => $_getSZ(3);
  @$pb.TagNumber(4)
  set groupBy($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasGroupBy() => $_has(3);
  @$pb.TagNumber(4)
  void clearGroupBy() => $_clearField(4);
}

class LayoutSort extends $pb.GeneratedMessage {
  factory LayoutSort({
    $core.String? key,
    $core.bool? desc,
  }) {
    final result = LayoutSort._();
    if (key != null) result.key = key;
    if (desc != null) result.desc = desc;
    return result;
  }

  LayoutSort._();

  factory LayoutSort.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LayoutSort()..mergeFromBuffer(data, registry);
  factory LayoutSort.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LayoutSort()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LayoutSort',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.savedviews'),
      createEmptyInstance: LayoutSort.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'key')
    ..aOB(2, _omitFieldNames ? '' : 'desc')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LayoutSort clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LayoutSort copyWith(void Function(LayoutSort) updates) =>
      super.copyWith((message) => updates(message as LayoutSort)) as LayoutSort;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use LayoutSort() / LayoutSort.new instead')
  static LayoutSort create() => LayoutSort._();
  static $pb.GeneratedMessage $_createMessage() => LayoutSort._();
  @$core.override
  LayoutSort createEmptyInstance() => LayoutSort._();
  @$core.pragma('dart2js:noInline')
  static LayoutSort getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LayoutSort>(LayoutSort.$_createMessage);
  static LayoutSort? _defaultInstance;

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

class LayoutSortResponse extends $pb.GeneratedMessage {
  factory LayoutSortResponse({
    $core.String? key,
    $core.bool? desc,
  }) {
    final result = LayoutSortResponse._();
    if (key != null) result.key = key;
    if (desc != null) result.desc = desc;
    return result;
  }

  LayoutSortResponse._();

  factory LayoutSortResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LayoutSortResponse()..mergeFromBuffer(data, registry);
  factory LayoutSortResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LayoutSortResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LayoutSortResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.savedviews'),
      createEmptyInstance: LayoutSortResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'key')
    ..aOB(2, _omitFieldNames ? '' : 'desc')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LayoutSortResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LayoutSortResponse copyWith(void Function(LayoutSortResponse) updates) =>
      super.copyWith((message) => updates(message as LayoutSortResponse))
          as LayoutSortResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use LayoutSortResponse() / LayoutSortResponse.new instead')
  static LayoutSortResponse create() => LayoutSortResponse._();
  static $pb.GeneratedMessage $_createMessage() => LayoutSortResponse._();
  @$core.override
  LayoutSortResponse createEmptyInstance() => LayoutSortResponse._();
  @$core.pragma('dart2js:noInline')
  static LayoutSortResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LayoutSortResponse>(
          LayoutSortResponse.$_createMessage);
  static LayoutSortResponse? _defaultInstance;

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

class LayoutWidth extends $pb.GeneratedMessage {
  factory LayoutWidth({
    $core.String? column,
    $core.int? width,
  }) {
    final result = LayoutWidth._();
    if (column != null) result.column = column;
    if (width != null) result.width = width;
    return result;
  }

  LayoutWidth._();

  factory LayoutWidth.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LayoutWidth()..mergeFromBuffer(data, registry);
  factory LayoutWidth.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LayoutWidth()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LayoutWidth',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.savedviews'),
      createEmptyInstance: LayoutWidth.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'column')
    ..aI(2, _omitFieldNames ? '' : 'width')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LayoutWidth clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LayoutWidth copyWith(void Function(LayoutWidth) updates) =>
      super.copyWith((message) => updates(message as LayoutWidth))
          as LayoutWidth;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use LayoutWidth() / LayoutWidth.new instead')
  static LayoutWidth create() => LayoutWidth._();
  static $pb.GeneratedMessage $_createMessage() => LayoutWidth._();
  @$core.override
  LayoutWidth createEmptyInstance() => LayoutWidth._();
  @$core.pragma('dart2js:noInline')
  static LayoutWidth getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LayoutWidth>(
          LayoutWidth.$_createMessage);
  static LayoutWidth? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get column => $_getSZ(0);
  @$pb.TagNumber(1)
  set column($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasColumn() => $_has(0);
  @$pb.TagNumber(1)
  void clearColumn() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get width => $_getIZ(1);
  @$pb.TagNumber(2)
  set width($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasWidth() => $_has(1);
  @$pb.TagNumber(2)
  void clearWidth() => $_clearField(2);
}

class LayoutWidthResponse extends $pb.GeneratedMessage {
  factory LayoutWidthResponse({
    $core.String? column,
    $core.int? width,
  }) {
    final result = LayoutWidthResponse._();
    if (column != null) result.column = column;
    if (width != null) result.width = width;
    return result;
  }

  LayoutWidthResponse._();

  factory LayoutWidthResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LayoutWidthResponse()..mergeFromBuffer(data, registry);
  factory LayoutWidthResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LayoutWidthResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LayoutWidthResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.savedviews'),
      createEmptyInstance: LayoutWidthResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'column')
    ..aI(2, _omitFieldNames ? '' : 'width')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LayoutWidthResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LayoutWidthResponse copyWith(void Function(LayoutWidthResponse) updates) =>
      super.copyWith((message) => updates(message as LayoutWidthResponse))
          as LayoutWidthResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core
      .Deprecated('Use LayoutWidthResponse() / LayoutWidthResponse.new instead')
  static LayoutWidthResponse create() => LayoutWidthResponse._();
  static $pb.GeneratedMessage $_createMessage() => LayoutWidthResponse._();
  @$core.override
  LayoutWidthResponse createEmptyInstance() => LayoutWidthResponse._();
  @$core.pragma('dart2js:noInline')
  static LayoutWidthResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LayoutWidthResponse>(
          LayoutWidthResponse.$_createMessage);
  static LayoutWidthResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get column => $_getSZ(0);
  @$pb.TagNumber(1)
  set column($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasColumn() => $_has(0);
  @$pb.TagNumber(1)
  void clearColumn() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get width => $_getIZ(1);
  @$pb.TagNumber(2)
  set width($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasWidth() => $_has(1);
  @$pb.TagNumber(2)
  void clearWidth() => $_clearField(2);
}

class SavedView extends $pb.GeneratedMessage {
  factory SavedView({
    $core.String? id,
    $core.String? projectId,
    $core.String? ownerId,
    $core.String? name,
    $core.String? kind,
    $core.bool? isShared,
    LayoutResponse? layout,
    $core.int? version,
    $core.String? updatedAt,
    BoardLayoutResponse? board,
    CalendarLayoutResponse? calendar,
    FilterLayoutResponse? activeFilter,
  }) {
    final result = SavedView._();
    if (id != null) result.id = id;
    if (projectId != null) result.projectId = projectId;
    if (ownerId != null) result.ownerId = ownerId;
    if (name != null) result.name = name;
    if (kind != null) result.kind = kind;
    if (isShared != null) result.isShared = isShared;
    if (layout != null) result.layout = layout;
    if (version != null) result.version = version;
    if (updatedAt != null) result.updatedAt = updatedAt;
    if (board != null) result.board = board;
    if (calendar != null) result.calendar = calendar;
    if (activeFilter != null) result.activeFilter = activeFilter;
    return result;
  }

  SavedView._();

  factory SavedView.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SavedView()..mergeFromBuffer(data, registry);
  factory SavedView.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SavedView()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SavedView',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.savedviews'),
      createEmptyInstance: SavedView.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..aOS(3, _omitFieldNames ? '' : 'ownerId')
    ..aOS(4, _omitFieldNames ? '' : 'name')
    ..aOS(5, _omitFieldNames ? '' : 'kind')
    ..aOB(6, _omitFieldNames ? '' : 'isShared')
    ..aOM<LayoutResponse>(7, _omitFieldNames ? '' : 'layout',
        subBuilder: LayoutResponse.$_createMessage)
    ..aI(8, _omitFieldNames ? '' : 'version')
    ..aOS(9, _omitFieldNames ? '' : 'updatedAt')
    ..aOM<BoardLayoutResponse>(10, _omitFieldNames ? '' : 'board',
        subBuilder: BoardLayoutResponse.$_createMessage)
    ..aOM<CalendarLayoutResponse>(11, _omitFieldNames ? '' : 'calendar',
        subBuilder: CalendarLayoutResponse.$_createMessage)
    ..aOM<FilterLayoutResponse>(12, _omitFieldNames ? '' : 'activeFilter',
        subBuilder: FilterLayoutResponse.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SavedView clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SavedView copyWith(void Function(SavedView) updates) =>
      super.copyWith((message) => updates(message as SavedView)) as SavedView;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SavedView() / SavedView.new instead')
  static SavedView create() => SavedView._();
  static $pb.GeneratedMessage $_createMessage() => SavedView._();
  @$core.override
  SavedView createEmptyInstance() => SavedView._();
  @$core.pragma('dart2js:noInline')
  static SavedView getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SavedView>(SavedView.$_createMessage);
  static SavedView? _defaultInstance;

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
  $core.String get kind => $_getSZ(4);
  @$pb.TagNumber(5)
  set kind($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasKind() => $_has(4);
  @$pb.TagNumber(5)
  void clearKind() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.bool get isShared => $_getBF(5);
  @$pb.TagNumber(6)
  set isShared($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasIsShared() => $_has(5);
  @$pb.TagNumber(6)
  void clearIsShared() => $_clearField(6);

  @$pb.TagNumber(7)
  LayoutResponse get layout => $_getN(6);
  @$pb.TagNumber(7)
  set layout(LayoutResponse value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasLayout() => $_has(6);
  @$pb.TagNumber(7)
  void clearLayout() => $_clearField(7);
  @$pb.TagNumber(7)
  LayoutResponse ensureLayout() => $_ensure(6);

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

  @$pb.TagNumber(10)
  BoardLayoutResponse get board => $_getN(9);
  @$pb.TagNumber(10)
  set board(BoardLayoutResponse value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasBoard() => $_has(9);
  @$pb.TagNumber(10)
  void clearBoard() => $_clearField(10);
  @$pb.TagNumber(10)
  BoardLayoutResponse ensureBoard() => $_ensure(9);

  @$pb.TagNumber(11)
  CalendarLayoutResponse get calendar => $_getN(10);
  @$pb.TagNumber(11)
  set calendar(CalendarLayoutResponse value) => $_setField(11, value);
  @$pb.TagNumber(11)
  $core.bool hasCalendar() => $_has(10);
  @$pb.TagNumber(11)
  void clearCalendar() => $_clearField(11);
  @$pb.TagNumber(11)
  CalendarLayoutResponse ensureCalendar() => $_ensure(10);

  @$pb.TagNumber(12)
  FilterLayoutResponse get activeFilter => $_getN(11);
  @$pb.TagNumber(12)
  set activeFilter(FilterLayoutResponse value) => $_setField(12, value);
  @$pb.TagNumber(12)
  $core.bool hasActiveFilter() => $_has(11);
  @$pb.TagNumber(12)
  void clearActiveFilter() => $_clearField(12);
  @$pb.TagNumber(12)
  FilterLayoutResponse ensureActiveFilter() => $_ensure(11);
}

class ViewDeleteRequest extends $pb.GeneratedMessage {
  factory ViewDeleteRequest({
    $core.String? workspaceId,
    $core.String? projectId,
    $core.String? id,
  }) {
    final result = ViewDeleteRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (projectId != null) result.projectId = projectId;
    if (id != null) result.id = id;
    return result;
  }

  ViewDeleteRequest._();

  factory ViewDeleteRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ViewDeleteRequest()..mergeFromBuffer(data, registry);
  factory ViewDeleteRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ViewDeleteRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ViewDeleteRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.savedviews'),
      createEmptyInstance: ViewDeleteRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..aOS(3, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ViewDeleteRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ViewDeleteRequest copyWith(void Function(ViewDeleteRequest) updates) =>
      super.copyWith((message) => updates(message as ViewDeleteRequest))
          as ViewDeleteRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ViewDeleteRequest() / ViewDeleteRequest.new instead')
  static ViewDeleteRequest create() => ViewDeleteRequest._();
  static $pb.GeneratedMessage $_createMessage() => ViewDeleteRequest._();
  @$core.override
  ViewDeleteRequest createEmptyInstance() => ViewDeleteRequest._();
  @$core.pragma('dart2js:noInline')
  static ViewDeleteRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ViewDeleteRequest>(
          ViewDeleteRequest.$_createMessage);
  static ViewDeleteRequest? _defaultInstance;

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

class ViewList extends $pb.GeneratedMessage {
  factory ViewList({
    $core.Iterable<SavedView>? views,
  }) {
    final result = ViewList._();
    if (views != null) result.views.addAll(views);
    return result;
  }

  ViewList._();

  factory ViewList.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ViewList()..mergeFromBuffer(data, registry);
  factory ViewList.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ViewList()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ViewList',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.savedviews'),
      createEmptyInstance: ViewList.$_createMessage)
    ..pPM<SavedView>(1, _omitFieldNames ? '' : 'views',
        subBuilder: SavedView.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ViewList clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ViewList copyWith(void Function(ViewList) updates) =>
      super.copyWith((message) => updates(message as ViewList)) as ViewList;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ViewList() / ViewList.new instead')
  static ViewList create() => ViewList._();
  static $pb.GeneratedMessage $_createMessage() => ViewList._();
  @$core.override
  ViewList createEmptyInstance() => ViewList._();
  @$core.pragma('dart2js:noInline')
  static ViewList getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ViewList>(ViewList.$_createMessage);
  static ViewList? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<SavedView> get views => $_getList(0);
}

class ViewListRequest extends $pb.GeneratedMessage {
  factory ViewListRequest({
    $core.String? workspaceId,
    $core.String? projectId,
    $core.String? kind,
  }) {
    final result = ViewListRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (projectId != null) result.projectId = projectId;
    if (kind != null) result.kind = kind;
    return result;
  }

  ViewListRequest._();

  factory ViewListRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ViewListRequest()..mergeFromBuffer(data, registry);
  factory ViewListRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ViewListRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ViewListRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.savedviews'),
      createEmptyInstance: ViewListRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..aOS(3, _omitFieldNames ? '' : 'kind')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ViewListRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ViewListRequest copyWith(void Function(ViewListRequest) updates) =>
      super.copyWith((message) => updates(message as ViewListRequest))
          as ViewListRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ViewListRequest() / ViewListRequest.new instead')
  static ViewListRequest create() => ViewListRequest._();
  static $pb.GeneratedMessage $_createMessage() => ViewListRequest._();
  @$core.override
  ViewListRequest createEmptyInstance() => ViewListRequest._();
  @$core.pragma('dart2js:noInline')
  static ViewListRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ViewListRequest>(
          ViewListRequest.$_createMessage);
  static ViewListRequest? _defaultInstance;

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
  $core.String get kind => $_getSZ(2);
  @$pb.TagNumber(3)
  set kind($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasKind() => $_has(2);
  @$pb.TagNumber(3)
  void clearKind() => $_clearField(3);
}

class ViewSaveRequest extends $pb.GeneratedMessage {
  factory ViewSaveRequest({
    $core.String? workspaceId,
    $core.String? projectId,
    $core.String? id,
    $core.int? expectedVersion,
    $core.String? name,
    $core.String? kind,
    Layout? layout,
    $core.bool? shared,
    BoardLayout? board,
    CalendarLayout? calendar,
    FilterLayout? activeFilter,
  }) {
    final result = ViewSaveRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (projectId != null) result.projectId = projectId;
    if (id != null) result.id = id;
    if (expectedVersion != null) result.expectedVersion = expectedVersion;
    if (name != null) result.name = name;
    if (kind != null) result.kind = kind;
    if (layout != null) result.layout = layout;
    if (shared != null) result.shared = shared;
    if (board != null) result.board = board;
    if (calendar != null) result.calendar = calendar;
    if (activeFilter != null) result.activeFilter = activeFilter;
    return result;
  }

  ViewSaveRequest._();

  factory ViewSaveRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ViewSaveRequest()..mergeFromBuffer(data, registry);
  factory ViewSaveRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ViewSaveRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ViewSaveRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.savedviews'),
      createEmptyInstance: ViewSaveRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..aOS(3, _omitFieldNames ? '' : 'id')
    ..aI(4, _omitFieldNames ? '' : 'expectedVersion')
    ..aOS(5, _omitFieldNames ? '' : 'name')
    ..aOS(6, _omitFieldNames ? '' : 'kind')
    ..aOM<Layout>(7, _omitFieldNames ? '' : 'layout',
        subBuilder: Layout.$_createMessage)
    ..aOB(8, _omitFieldNames ? '' : 'shared')
    ..aOM<BoardLayout>(9, _omitFieldNames ? '' : 'board',
        subBuilder: BoardLayout.$_createMessage)
    ..aOM<CalendarLayout>(10, _omitFieldNames ? '' : 'calendar',
        subBuilder: CalendarLayout.$_createMessage)
    ..aOM<FilterLayout>(11, _omitFieldNames ? '' : 'activeFilter',
        subBuilder: FilterLayout.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ViewSaveRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ViewSaveRequest copyWith(void Function(ViewSaveRequest) updates) =>
      super.copyWith((message) => updates(message as ViewSaveRequest))
          as ViewSaveRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ViewSaveRequest() / ViewSaveRequest.new instead')
  static ViewSaveRequest create() => ViewSaveRequest._();
  static $pb.GeneratedMessage $_createMessage() => ViewSaveRequest._();
  @$core.override
  ViewSaveRequest createEmptyInstance() => ViewSaveRequest._();
  @$core.pragma('dart2js:noInline')
  static ViewSaveRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ViewSaveRequest>(
          ViewSaveRequest.$_createMessage);
  static ViewSaveRequest? _defaultInstance;

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
  $core.String get kind => $_getSZ(5);
  @$pb.TagNumber(6)
  set kind($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasKind() => $_has(5);
  @$pb.TagNumber(6)
  void clearKind() => $_clearField(6);

  @$pb.TagNumber(7)
  Layout get layout => $_getN(6);
  @$pb.TagNumber(7)
  set layout(Layout value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasLayout() => $_has(6);
  @$pb.TagNumber(7)
  void clearLayout() => $_clearField(7);
  @$pb.TagNumber(7)
  Layout ensureLayout() => $_ensure(6);

  @$pb.TagNumber(8)
  $core.bool get shared => $_getBF(7);
  @$pb.TagNumber(8)
  set shared($core.bool value) => $_setBool(7, value);
  @$pb.TagNumber(8)
  $core.bool hasShared() => $_has(7);
  @$pb.TagNumber(8)
  void clearShared() => $_clearField(8);

  @$pb.TagNumber(9)
  BoardLayout get board => $_getN(8);
  @$pb.TagNumber(9)
  set board(BoardLayout value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasBoard() => $_has(8);
  @$pb.TagNumber(9)
  void clearBoard() => $_clearField(9);
  @$pb.TagNumber(9)
  BoardLayout ensureBoard() => $_ensure(8);

  @$pb.TagNumber(10)
  CalendarLayout get calendar => $_getN(9);
  @$pb.TagNumber(10)
  set calendar(CalendarLayout value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasCalendar() => $_has(9);
  @$pb.TagNumber(10)
  void clearCalendar() => $_clearField(10);
  @$pb.TagNumber(10)
  CalendarLayout ensureCalendar() => $_ensure(9);

  @$pb.TagNumber(11)
  FilterLayout get activeFilter => $_getN(10);
  @$pb.TagNumber(11)
  set activeFilter(FilterLayout value) => $_setField(11, value);
  @$pb.TagNumber(11)
  $core.bool hasActiveFilter() => $_has(10);
  @$pb.TagNumber(11)
  void clearActiveFilter() => $_clearField(11);
  @$pb.TagNumber(11)
  FilterLayout ensureActiveFilter() => $_ensure(10);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
