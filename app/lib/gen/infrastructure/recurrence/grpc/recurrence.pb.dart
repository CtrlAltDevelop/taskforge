// This is a generated file - do not edit.
//
// Generated from infrastructure/recurrence/grpc/recurrence.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class Ghost extends $pb.GeneratedMessage {
  factory Ghost({
    $core.String? seriesId,
    $core.String? projectId,
    $core.String? title,
    $core.String? dueDate,
  }) {
    final result = Ghost._();
    if (seriesId != null) result.seriesId = seriesId;
    if (projectId != null) result.projectId = projectId;
    if (title != null) result.title = title;
    if (dueDate != null) result.dueDate = dueDate;
    return result;
  }

  Ghost._();

  factory Ghost.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Ghost()..mergeFromBuffer(data, registry);
  factory Ghost.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Ghost()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Ghost',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.recurrence'),
      createEmptyInstance: Ghost.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'seriesId')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..aOS(3, _omitFieldNames ? '' : 'title')
    ..aOS(4, _omitFieldNames ? '' : 'dueDate')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Ghost clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Ghost copyWith(void Function(Ghost) updates) =>
      super.copyWith((message) => updates(message as Ghost)) as Ghost;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Ghost() / Ghost.new instead')
  static Ghost create() => Ghost._();
  static $pb.GeneratedMessage $_createMessage() => Ghost._();
  @$core.override
  Ghost createEmptyInstance() => Ghost._();
  @$core.pragma('dart2js:noInline')
  static Ghost getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Ghost>(Ghost.$_createMessage);
  static Ghost? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get seriesId => $_getSZ(0);
  @$pb.TagNumber(1)
  set seriesId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSeriesId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSeriesId() => $_clearField(1);

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
  $core.String get dueDate => $_getSZ(3);
  @$pb.TagNumber(4)
  set dueDate($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasDueDate() => $_has(3);
  @$pb.TagNumber(4)
  void clearDueDate() => $_clearField(4);
}

class RecurrenceAnswer extends $pb.GeneratedMessage {
  factory RecurrenceAnswer({
    $core.bool? repeats,
    Series? series,
  }) {
    final result = RecurrenceAnswer._();
    if (repeats != null) result.repeats = repeats;
    if (series != null) result.series = series;
    return result;
  }

  RecurrenceAnswer._();

  factory RecurrenceAnswer.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RecurrenceAnswer()..mergeFromBuffer(data, registry);
  factory RecurrenceAnswer.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RecurrenceAnswer()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RecurrenceAnswer',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.recurrence'),
      createEmptyInstance: RecurrenceAnswer.$_createMessage)
    ..aOB(1, _omitFieldNames ? '' : 'repeats')
    ..aOM<Series>(2, _omitFieldNames ? '' : 'series',
        subBuilder: Series.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RecurrenceAnswer clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RecurrenceAnswer copyWith(void Function(RecurrenceAnswer) updates) =>
      super.copyWith((message) => updates(message as RecurrenceAnswer))
          as RecurrenceAnswer;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use RecurrenceAnswer() / RecurrenceAnswer.new instead')
  static RecurrenceAnswer create() => RecurrenceAnswer._();
  static $pb.GeneratedMessage $_createMessage() => RecurrenceAnswer._();
  @$core.override
  RecurrenceAnswer createEmptyInstance() => RecurrenceAnswer._();
  @$core.pragma('dart2js:noInline')
  static RecurrenceAnswer getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RecurrenceAnswer>(
          RecurrenceAnswer.$_createMessage);
  static RecurrenceAnswer? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get repeats => $_getBF(0);
  @$pb.TagNumber(1)
  set repeats($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRepeats() => $_has(0);
  @$pb.TagNumber(1)
  void clearRepeats() => $_clearField(1);

  @$pb.TagNumber(2)
  Series get series => $_getN(1);
  @$pb.TagNumber(2)
  set series(Series value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasSeries() => $_has(1);
  @$pb.TagNumber(2)
  void clearSeries() => $_clearField(2);
  @$pb.TagNumber(2)
  Series ensureSeries() => $_ensure(1);
}

class RecurrenceClearRequest extends $pb.GeneratedMessage {
  factory RecurrenceClearRequest({
    $core.String? workspaceId,
    $core.String? projectId,
    $core.String? taskId,
  }) {
    final result = RecurrenceClearRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (projectId != null) result.projectId = projectId;
    if (taskId != null) result.taskId = taskId;
    return result;
  }

  RecurrenceClearRequest._();

  factory RecurrenceClearRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RecurrenceClearRequest()..mergeFromBuffer(data, registry);
  factory RecurrenceClearRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RecurrenceClearRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RecurrenceClearRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.recurrence'),
      createEmptyInstance: RecurrenceClearRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..aOS(3, _omitFieldNames ? '' : 'taskId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RecurrenceClearRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RecurrenceClearRequest copyWith(
          void Function(RecurrenceClearRequest) updates) =>
      super.copyWith((message) => updates(message as RecurrenceClearRequest))
          as RecurrenceClearRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use RecurrenceClearRequest() / RecurrenceClearRequest.new instead')
  static RecurrenceClearRequest create() => RecurrenceClearRequest._();
  static $pb.GeneratedMessage $_createMessage() => RecurrenceClearRequest._();
  @$core.override
  RecurrenceClearRequest createEmptyInstance() => RecurrenceClearRequest._();
  @$core.pragma('dart2js:noInline')
  static RecurrenceClearRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RecurrenceClearRequest>(
          RecurrenceClearRequest.$_createMessage);
  static RecurrenceClearRequest? _defaultInstance;

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

class RecurrenceCleared extends $pb.GeneratedMessage {
  factory RecurrenceCleared({
    $core.String? taskId,
  }) {
    final result = RecurrenceCleared._();
    if (taskId != null) result.taskId = taskId;
    return result;
  }

  RecurrenceCleared._();

  factory RecurrenceCleared.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RecurrenceCleared()..mergeFromBuffer(data, registry);
  factory RecurrenceCleared.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RecurrenceCleared()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RecurrenceCleared',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.recurrence'),
      createEmptyInstance: RecurrenceCleared.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'taskId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RecurrenceCleared clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RecurrenceCleared copyWith(void Function(RecurrenceCleared) updates) =>
      super.copyWith((message) => updates(message as RecurrenceCleared))
          as RecurrenceCleared;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use RecurrenceCleared() / RecurrenceCleared.new instead')
  static RecurrenceCleared create() => RecurrenceCleared._();
  static $pb.GeneratedMessage $_createMessage() => RecurrenceCleared._();
  @$core.override
  RecurrenceCleared createEmptyInstance() => RecurrenceCleared._();
  @$core.pragma('dart2js:noInline')
  static RecurrenceCleared getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RecurrenceCleared>(
          RecurrenceCleared.$_createMessage);
  static RecurrenceCleared? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get taskId => $_getSZ(0);
  @$pb.TagNumber(1)
  set taskId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTaskId() => $_has(0);
  @$pb.TagNumber(1)
  void clearTaskId() => $_clearField(1);
}

class RecurrenceFutureUpdated extends $pb.GeneratedMessage {
  factory RecurrenceFutureUpdated({
    Series? series,
    $core.int? changed,
  }) {
    final result = RecurrenceFutureUpdated._();
    if (series != null) result.series = series;
    if (changed != null) result.changed = changed;
    return result;
  }

  RecurrenceFutureUpdated._();

  factory RecurrenceFutureUpdated.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RecurrenceFutureUpdated()..mergeFromBuffer(data, registry);
  factory RecurrenceFutureUpdated.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RecurrenceFutureUpdated()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RecurrenceFutureUpdated',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.recurrence'),
      createEmptyInstance: RecurrenceFutureUpdated.$_createMessage)
    ..aOM<Series>(1, _omitFieldNames ? '' : 'series',
        subBuilder: Series.$_createMessage)
    ..aI(2, _omitFieldNames ? '' : 'changed')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RecurrenceFutureUpdated clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RecurrenceFutureUpdated copyWith(
          void Function(RecurrenceFutureUpdated) updates) =>
      super.copyWith((message) => updates(message as RecurrenceFutureUpdated))
          as RecurrenceFutureUpdated;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use RecurrenceFutureUpdated() / RecurrenceFutureUpdated.new instead')
  static RecurrenceFutureUpdated create() => RecurrenceFutureUpdated._();
  static $pb.GeneratedMessage $_createMessage() => RecurrenceFutureUpdated._();
  @$core.override
  RecurrenceFutureUpdated createEmptyInstance() => RecurrenceFutureUpdated._();
  @$core.pragma('dart2js:noInline')
  static RecurrenceFutureUpdated getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RecurrenceFutureUpdated>(
          RecurrenceFutureUpdated.$_createMessage);
  static RecurrenceFutureUpdated? _defaultInstance;

  @$pb.TagNumber(1)
  Series get series => $_getN(0);
  @$pb.TagNumber(1)
  set series(Series value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSeries() => $_has(0);
  @$pb.TagNumber(1)
  void clearSeries() => $_clearField(1);
  @$pb.TagNumber(1)
  Series ensureSeries() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.int get changed => $_getIZ(1);
  @$pb.TagNumber(2)
  set changed($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasChanged() => $_has(1);
  @$pb.TagNumber(2)
  void clearChanged() => $_clearField(2);
}

class RecurrenceGetRequest extends $pb.GeneratedMessage {
  factory RecurrenceGetRequest({
    $core.String? workspaceId,
    $core.String? projectId,
    $core.String? taskId,
  }) {
    final result = RecurrenceGetRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (projectId != null) result.projectId = projectId;
    if (taskId != null) result.taskId = taskId;
    return result;
  }

  RecurrenceGetRequest._();

  factory RecurrenceGetRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RecurrenceGetRequest()..mergeFromBuffer(data, registry);
  factory RecurrenceGetRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RecurrenceGetRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RecurrenceGetRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.recurrence'),
      createEmptyInstance: RecurrenceGetRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..aOS(3, _omitFieldNames ? '' : 'taskId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RecurrenceGetRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RecurrenceGetRequest copyWith(void Function(RecurrenceGetRequest) updates) =>
      super.copyWith((message) => updates(message as RecurrenceGetRequest))
          as RecurrenceGetRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use RecurrenceGetRequest() / RecurrenceGetRequest.new instead')
  static RecurrenceGetRequest create() => RecurrenceGetRequest._();
  static $pb.GeneratedMessage $_createMessage() => RecurrenceGetRequest._();
  @$core.override
  RecurrenceGetRequest createEmptyInstance() => RecurrenceGetRequest._();
  @$core.pragma('dart2js:noInline')
  static RecurrenceGetRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RecurrenceGetRequest>(
          RecurrenceGetRequest.$_createMessage);
  static RecurrenceGetRequest? _defaultInstance;

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

class RecurrencePauseRequest extends $pb.GeneratedMessage {
  factory RecurrencePauseRequest({
    $core.String? workspaceId,
    $core.String? projectId,
    $core.String? taskId,
    $core.bool? paused,
  }) {
    final result = RecurrencePauseRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (projectId != null) result.projectId = projectId;
    if (taskId != null) result.taskId = taskId;
    if (paused != null) result.paused = paused;
    return result;
  }

  RecurrencePauseRequest._();

  factory RecurrencePauseRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RecurrencePauseRequest()..mergeFromBuffer(data, registry);
  factory RecurrencePauseRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RecurrencePauseRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RecurrencePauseRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.recurrence'),
      createEmptyInstance: RecurrencePauseRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..aOS(3, _omitFieldNames ? '' : 'taskId')
    ..aOB(4, _omitFieldNames ? '' : 'paused')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RecurrencePauseRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RecurrencePauseRequest copyWith(
          void Function(RecurrencePauseRequest) updates) =>
      super.copyWith((message) => updates(message as RecurrencePauseRequest))
          as RecurrencePauseRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use RecurrencePauseRequest() / RecurrencePauseRequest.new instead')
  static RecurrencePauseRequest create() => RecurrencePauseRequest._();
  static $pb.GeneratedMessage $_createMessage() => RecurrencePauseRequest._();
  @$core.override
  RecurrencePauseRequest createEmptyInstance() => RecurrencePauseRequest._();
  @$core.pragma('dart2js:noInline')
  static RecurrencePauseRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RecurrencePauseRequest>(
          RecurrencePauseRequest.$_createMessage);
  static RecurrencePauseRequest? _defaultInstance;

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
  $core.bool get paused => $_getBF(3);
  @$pb.TagNumber(4)
  set paused($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasPaused() => $_has(3);
  @$pb.TagNumber(4)
  void clearPaused() => $_clearField(4);
}

class RecurrencePreview extends $pb.GeneratedMessage {
  factory RecurrencePreview({
    $core.String? summary,
    $core.Iterable<$core.String>? dates,
  }) {
    final result = RecurrencePreview._();
    if (summary != null) result.summary = summary;
    if (dates != null) result.dates.addAll(dates);
    return result;
  }

  RecurrencePreview._();

  factory RecurrencePreview.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RecurrencePreview()..mergeFromBuffer(data, registry);
  factory RecurrencePreview.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RecurrencePreview()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RecurrencePreview',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.recurrence'),
      createEmptyInstance: RecurrencePreview.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'summary')
    ..pPS(2, _omitFieldNames ? '' : 'dates')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RecurrencePreview clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RecurrencePreview copyWith(void Function(RecurrencePreview) updates) =>
      super.copyWith((message) => updates(message as RecurrencePreview))
          as RecurrencePreview;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use RecurrencePreview() / RecurrencePreview.new instead')
  static RecurrencePreview create() => RecurrencePreview._();
  static $pb.GeneratedMessage $_createMessage() => RecurrencePreview._();
  @$core.override
  RecurrencePreview createEmptyInstance() => RecurrencePreview._();
  @$core.pragma('dart2js:noInline')
  static RecurrencePreview getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RecurrencePreview>(
          RecurrencePreview.$_createMessage);
  static RecurrencePreview? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get summary => $_getSZ(0);
  @$pb.TagNumber(1)
  set summary($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSummary() => $_has(0);
  @$pb.TagNumber(1)
  void clearSummary() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<$core.String> get dates => $_getList(1);
}

class RecurrencePreviewRequest extends $pb.GeneratedMessage {
  factory RecurrencePreviewRequest({
    $core.String? workspaceId,
    $core.String? rrule,
    $core.String? mode,
    $core.String? timezone,
    $core.bool? skipWeekends,
    $core.String? endsOn,
    $core.String? startsOn,
    $core.int? count,
    $core.String? after,
  }) {
    final result = RecurrencePreviewRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (rrule != null) result.rrule = rrule;
    if (mode != null) result.mode = mode;
    if (timezone != null) result.timezone = timezone;
    if (skipWeekends != null) result.skipWeekends = skipWeekends;
    if (endsOn != null) result.endsOn = endsOn;
    if (startsOn != null) result.startsOn = startsOn;
    if (count != null) result.count = count;
    if (after != null) result.after = after;
    return result;
  }

  RecurrencePreviewRequest._();

  factory RecurrencePreviewRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RecurrencePreviewRequest()..mergeFromBuffer(data, registry);
  factory RecurrencePreviewRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RecurrencePreviewRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RecurrencePreviewRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.recurrence'),
      createEmptyInstance: RecurrencePreviewRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'rrule')
    ..aOS(3, _omitFieldNames ? '' : 'mode')
    ..aOS(4, _omitFieldNames ? '' : 'timezone')
    ..aOB(5, _omitFieldNames ? '' : 'skipWeekends')
    ..aOS(6, _omitFieldNames ? '' : 'endsOn')
    ..aOS(7, _omitFieldNames ? '' : 'startsOn')
    ..aI(8, _omitFieldNames ? '' : 'count')
    ..aOS(9, _omitFieldNames ? '' : 'after')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RecurrencePreviewRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RecurrencePreviewRequest copyWith(
          void Function(RecurrencePreviewRequest) updates) =>
      super.copyWith((message) => updates(message as RecurrencePreviewRequest))
          as RecurrencePreviewRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use RecurrencePreviewRequest() / RecurrencePreviewRequest.new instead')
  static RecurrencePreviewRequest create() => RecurrencePreviewRequest._();
  static $pb.GeneratedMessage $_createMessage() => RecurrencePreviewRequest._();
  @$core.override
  RecurrencePreviewRequest createEmptyInstance() =>
      RecurrencePreviewRequest._();
  @$core.pragma('dart2js:noInline')
  static RecurrencePreviewRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RecurrencePreviewRequest>(
          RecurrencePreviewRequest.$_createMessage);
  static RecurrencePreviewRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get rrule => $_getSZ(1);
  @$pb.TagNumber(2)
  set rrule($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRrule() => $_has(1);
  @$pb.TagNumber(2)
  void clearRrule() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get mode => $_getSZ(2);
  @$pb.TagNumber(3)
  set mode($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasMode() => $_has(2);
  @$pb.TagNumber(3)
  void clearMode() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get timezone => $_getSZ(3);
  @$pb.TagNumber(4)
  set timezone($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasTimezone() => $_has(3);
  @$pb.TagNumber(4)
  void clearTimezone() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.bool get skipWeekends => $_getBF(4);
  @$pb.TagNumber(5)
  set skipWeekends($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasSkipWeekends() => $_has(4);
  @$pb.TagNumber(5)
  void clearSkipWeekends() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get endsOn => $_getSZ(5);
  @$pb.TagNumber(6)
  set endsOn($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasEndsOn() => $_has(5);
  @$pb.TagNumber(6)
  void clearEndsOn() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get startsOn => $_getSZ(6);
  @$pb.TagNumber(7)
  set startsOn($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasStartsOn() => $_has(6);
  @$pb.TagNumber(7)
  void clearStartsOn() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.int get count => $_getIZ(7);
  @$pb.TagNumber(8)
  set count($core.int value) => $_setSignedInt32(7, value);
  @$pb.TagNumber(8)
  $core.bool hasCount() => $_has(7);
  @$pb.TagNumber(8)
  void clearCount() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get after => $_getSZ(8);
  @$pb.TagNumber(9)
  set after($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasAfter() => $_has(8);
  @$pb.TagNumber(9)
  void clearAfter() => $_clearField(9);
}

class RecurrenceSeriesAnswer extends $pb.GeneratedMessage {
  factory RecurrenceSeriesAnswer({
    Series? series,
  }) {
    final result = RecurrenceSeriesAnswer._();
    if (series != null) result.series = series;
    return result;
  }

  RecurrenceSeriesAnswer._();

  factory RecurrenceSeriesAnswer.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RecurrenceSeriesAnswer()..mergeFromBuffer(data, registry);
  factory RecurrenceSeriesAnswer.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RecurrenceSeriesAnswer()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RecurrenceSeriesAnswer',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.recurrence'),
      createEmptyInstance: RecurrenceSeriesAnswer.$_createMessage)
    ..aOM<Series>(1, _omitFieldNames ? '' : 'series',
        subBuilder: Series.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RecurrenceSeriesAnswer clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RecurrenceSeriesAnswer copyWith(
          void Function(RecurrenceSeriesAnswer) updates) =>
      super.copyWith((message) => updates(message as RecurrenceSeriesAnswer))
          as RecurrenceSeriesAnswer;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use RecurrenceSeriesAnswer() / RecurrenceSeriesAnswer.new instead')
  static RecurrenceSeriesAnswer create() => RecurrenceSeriesAnswer._();
  static $pb.GeneratedMessage $_createMessage() => RecurrenceSeriesAnswer._();
  @$core.override
  RecurrenceSeriesAnswer createEmptyInstance() => RecurrenceSeriesAnswer._();
  @$core.pragma('dart2js:noInline')
  static RecurrenceSeriesAnswer getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RecurrenceSeriesAnswer>(
          RecurrenceSeriesAnswer.$_createMessage);
  static RecurrenceSeriesAnswer? _defaultInstance;

  @$pb.TagNumber(1)
  Series get series => $_getN(0);
  @$pb.TagNumber(1)
  set series(Series value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSeries() => $_has(0);
  @$pb.TagNumber(1)
  void clearSeries() => $_clearField(1);
  @$pb.TagNumber(1)
  Series ensureSeries() => $_ensure(0);
}

class RecurrenceSetRequest extends $pb.GeneratedMessage {
  factory RecurrenceSetRequest({
    $core.String? workspaceId,
    $core.String? projectId,
    $core.String? taskId,
    $core.String? rrule,
    $core.String? mode,
    $core.String? timezone,
    $core.bool? skipWeekends,
    $core.String? endsOn,
    $core.String? atTime,
    $core.int? leadDays,
  }) {
    final result = RecurrenceSetRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (projectId != null) result.projectId = projectId;
    if (taskId != null) result.taskId = taskId;
    if (rrule != null) result.rrule = rrule;
    if (mode != null) result.mode = mode;
    if (timezone != null) result.timezone = timezone;
    if (skipWeekends != null) result.skipWeekends = skipWeekends;
    if (endsOn != null) result.endsOn = endsOn;
    if (atTime != null) result.atTime = atTime;
    if (leadDays != null) result.leadDays = leadDays;
    return result;
  }

  RecurrenceSetRequest._();

  factory RecurrenceSetRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RecurrenceSetRequest()..mergeFromBuffer(data, registry);
  factory RecurrenceSetRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RecurrenceSetRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RecurrenceSetRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.recurrence'),
      createEmptyInstance: RecurrenceSetRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..aOS(3, _omitFieldNames ? '' : 'taskId')
    ..aOS(4, _omitFieldNames ? '' : 'rrule')
    ..aOS(5, _omitFieldNames ? '' : 'mode')
    ..aOS(6, _omitFieldNames ? '' : 'timezone')
    ..aOB(7, _omitFieldNames ? '' : 'skipWeekends')
    ..aOS(8, _omitFieldNames ? '' : 'endsOn')
    ..aOS(9, _omitFieldNames ? '' : 'atTime')
    ..aI(10, _omitFieldNames ? '' : 'leadDays')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RecurrenceSetRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RecurrenceSetRequest copyWith(void Function(RecurrenceSetRequest) updates) =>
      super.copyWith((message) => updates(message as RecurrenceSetRequest))
          as RecurrenceSetRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use RecurrenceSetRequest() / RecurrenceSetRequest.new instead')
  static RecurrenceSetRequest create() => RecurrenceSetRequest._();
  static $pb.GeneratedMessage $_createMessage() => RecurrenceSetRequest._();
  @$core.override
  RecurrenceSetRequest createEmptyInstance() => RecurrenceSetRequest._();
  @$core.pragma('dart2js:noInline')
  static RecurrenceSetRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RecurrenceSetRequest>(
          RecurrenceSetRequest.$_createMessage);
  static RecurrenceSetRequest? _defaultInstance;

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
  $core.String get rrule => $_getSZ(3);
  @$pb.TagNumber(4)
  set rrule($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasRrule() => $_has(3);
  @$pb.TagNumber(4)
  void clearRrule() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get mode => $_getSZ(4);
  @$pb.TagNumber(5)
  set mode($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasMode() => $_has(4);
  @$pb.TagNumber(5)
  void clearMode() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get timezone => $_getSZ(5);
  @$pb.TagNumber(6)
  set timezone($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasTimezone() => $_has(5);
  @$pb.TagNumber(6)
  void clearTimezone() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.bool get skipWeekends => $_getBF(6);
  @$pb.TagNumber(7)
  set skipWeekends($core.bool value) => $_setBool(6, value);
  @$pb.TagNumber(7)
  $core.bool hasSkipWeekends() => $_has(6);
  @$pb.TagNumber(7)
  void clearSkipWeekends() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get endsOn => $_getSZ(7);
  @$pb.TagNumber(8)
  set endsOn($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasEndsOn() => $_has(7);
  @$pb.TagNumber(8)
  void clearEndsOn() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get atTime => $_getSZ(8);
  @$pb.TagNumber(9)
  set atTime($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasAtTime() => $_has(8);
  @$pb.TagNumber(9)
  void clearAtTime() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.int get leadDays => $_getIZ(9);
  @$pb.TagNumber(10)
  set leadDays($core.int value) => $_setSignedInt32(9, value);
  @$pb.TagNumber(10)
  $core.bool hasLeadDays() => $_has(9);
  @$pb.TagNumber(10)
  void clearLeadDays() => $_clearField(10);
}

class RecurrenceUpcoming extends $pb.GeneratedMessage {
  factory RecurrenceUpcoming({
    $core.Iterable<Ghost>? ghosts,
  }) {
    final result = RecurrenceUpcoming._();
    if (ghosts != null) result.ghosts.addAll(ghosts);
    return result;
  }

  RecurrenceUpcoming._();

  factory RecurrenceUpcoming.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RecurrenceUpcoming()..mergeFromBuffer(data, registry);
  factory RecurrenceUpcoming.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RecurrenceUpcoming()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RecurrenceUpcoming',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.recurrence'),
      createEmptyInstance: RecurrenceUpcoming.$_createMessage)
    ..pPM<Ghost>(1, _omitFieldNames ? '' : 'ghosts',
        subBuilder: Ghost.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RecurrenceUpcoming clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RecurrenceUpcoming copyWith(void Function(RecurrenceUpcoming) updates) =>
      super.copyWith((message) => updates(message as RecurrenceUpcoming))
          as RecurrenceUpcoming;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use RecurrenceUpcoming() / RecurrenceUpcoming.new instead')
  static RecurrenceUpcoming create() => RecurrenceUpcoming._();
  static $pb.GeneratedMessage $_createMessage() => RecurrenceUpcoming._();
  @$core.override
  RecurrenceUpcoming createEmptyInstance() => RecurrenceUpcoming._();
  @$core.pragma('dart2js:noInline')
  static RecurrenceUpcoming getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RecurrenceUpcoming>(
          RecurrenceUpcoming.$_createMessage);
  static RecurrenceUpcoming? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Ghost> get ghosts => $_getList(0);
}

class RecurrenceUpcomingRequest extends $pb.GeneratedMessage {
  factory RecurrenceUpcomingRequest({
    $core.String? workspaceId,
    $core.String? projectId,
    $core.String? start,
    $core.String? end,
  }) {
    final result = RecurrenceUpcomingRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (projectId != null) result.projectId = projectId;
    if (start != null) result.start = start;
    if (end != null) result.end = end;
    return result;
  }

  RecurrenceUpcomingRequest._();

  factory RecurrenceUpcomingRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RecurrenceUpcomingRequest()..mergeFromBuffer(data, registry);
  factory RecurrenceUpcomingRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RecurrenceUpcomingRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RecurrenceUpcomingRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.recurrence'),
      createEmptyInstance: RecurrenceUpcomingRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..aOS(3, _omitFieldNames ? '' : 'start')
    ..aOS(4, _omitFieldNames ? '' : 'end')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RecurrenceUpcomingRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RecurrenceUpcomingRequest copyWith(
          void Function(RecurrenceUpcomingRequest) updates) =>
      super.copyWith((message) => updates(message as RecurrenceUpcomingRequest))
          as RecurrenceUpcomingRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use RecurrenceUpcomingRequest() / RecurrenceUpcomingRequest.new instead')
  static RecurrenceUpcomingRequest create() => RecurrenceUpcomingRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      RecurrenceUpcomingRequest._();
  @$core.override
  RecurrenceUpcomingRequest createEmptyInstance() =>
      RecurrenceUpcomingRequest._();
  @$core.pragma('dart2js:noInline')
  static RecurrenceUpcomingRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RecurrenceUpcomingRequest>(
          RecurrenceUpcomingRequest.$_createMessage);
  static RecurrenceUpcomingRequest? _defaultInstance;

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
  $core.String get start => $_getSZ(2);
  @$pb.TagNumber(3)
  set start($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasStart() => $_has(2);
  @$pb.TagNumber(3)
  void clearStart() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get end => $_getSZ(3);
  @$pb.TagNumber(4)
  set end($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasEnd() => $_has(3);
  @$pb.TagNumber(4)
  void clearEnd() => $_clearField(4);
}

class RecurrenceUpdateFutureRequest extends $pb.GeneratedMessage {
  factory RecurrenceUpdateFutureRequest({
    $core.String? workspaceId,
    $core.String? projectId,
    $core.String? taskId,
  }) {
    final result = RecurrenceUpdateFutureRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (projectId != null) result.projectId = projectId;
    if (taskId != null) result.taskId = taskId;
    return result;
  }

  RecurrenceUpdateFutureRequest._();

  factory RecurrenceUpdateFutureRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RecurrenceUpdateFutureRequest()..mergeFromBuffer(data, registry);
  factory RecurrenceUpdateFutureRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RecurrenceUpdateFutureRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RecurrenceUpdateFutureRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.recurrence'),
      createEmptyInstance: RecurrenceUpdateFutureRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..aOS(3, _omitFieldNames ? '' : 'taskId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RecurrenceUpdateFutureRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RecurrenceUpdateFutureRequest copyWith(
          void Function(RecurrenceUpdateFutureRequest) updates) =>
      super.copyWith(
              (message) => updates(message as RecurrenceUpdateFutureRequest))
          as RecurrenceUpdateFutureRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use RecurrenceUpdateFutureRequest() / RecurrenceUpdateFutureRequest.new instead')
  static RecurrenceUpdateFutureRequest create() =>
      RecurrenceUpdateFutureRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      RecurrenceUpdateFutureRequest._();
  @$core.override
  RecurrenceUpdateFutureRequest createEmptyInstance() =>
      RecurrenceUpdateFutureRequest._();
  @$core.pragma('dart2js:noInline')
  static RecurrenceUpdateFutureRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RecurrenceUpdateFutureRequest>(
          RecurrenceUpdateFutureRequest.$_createMessage);
  static RecurrenceUpdateFutureRequest? _defaultInstance;

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

class Series extends $pb.GeneratedMessage {
  factory Series({
    $core.String? id,
    $core.String? projectId,
    $core.String? taskId,
    $core.String? rrule,
    $core.String? mode,
    $core.String? timezone,
    $core.String? atTime,
    $core.int? leadDays,
    $core.String? startsOn,
    $core.String? endsOn,
    $core.bool? skipWeekends,
    $core.bool? paused,
    $core.String? pauseReason,
    $core.String? summary,
    $core.String? nextDueOn,
    $core.String? nextRunAt,
    $core.Iterable<$core.String>? nextDates,
    $core.int? instanceCount,
    $core.int? index,
    $core.bool? isTemplate,
    $core.bool? templateMissing,
    $core.String? ownerId,
    $core.int? version,
  }) {
    final result = Series._();
    if (id != null) result.id = id;
    if (projectId != null) result.projectId = projectId;
    if (taskId != null) result.taskId = taskId;
    if (rrule != null) result.rrule = rrule;
    if (mode != null) result.mode = mode;
    if (timezone != null) result.timezone = timezone;
    if (atTime != null) result.atTime = atTime;
    if (leadDays != null) result.leadDays = leadDays;
    if (startsOn != null) result.startsOn = startsOn;
    if (endsOn != null) result.endsOn = endsOn;
    if (skipWeekends != null) result.skipWeekends = skipWeekends;
    if (paused != null) result.paused = paused;
    if (pauseReason != null) result.pauseReason = pauseReason;
    if (summary != null) result.summary = summary;
    if (nextDueOn != null) result.nextDueOn = nextDueOn;
    if (nextRunAt != null) result.nextRunAt = nextRunAt;
    if (nextDates != null) result.nextDates.addAll(nextDates);
    if (instanceCount != null) result.instanceCount = instanceCount;
    if (index != null) result.index = index;
    if (isTemplate != null) result.isTemplate = isTemplate;
    if (templateMissing != null) result.templateMissing = templateMissing;
    if (ownerId != null) result.ownerId = ownerId;
    if (version != null) result.version = version;
    return result;
  }

  Series._();

  factory Series.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Series()..mergeFromBuffer(data, registry);
  factory Series.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Series()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Series',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.recurrence'),
      createEmptyInstance: Series.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..aOS(3, _omitFieldNames ? '' : 'taskId')
    ..aOS(4, _omitFieldNames ? '' : 'rrule')
    ..aOS(5, _omitFieldNames ? '' : 'mode')
    ..aOS(6, _omitFieldNames ? '' : 'timezone')
    ..aOS(7, _omitFieldNames ? '' : 'atTime')
    ..aI(8, _omitFieldNames ? '' : 'leadDays')
    ..aOS(9, _omitFieldNames ? '' : 'startsOn')
    ..aOS(10, _omitFieldNames ? '' : 'endsOn')
    ..aOB(11, _omitFieldNames ? '' : 'skipWeekends')
    ..aOB(12, _omitFieldNames ? '' : 'paused')
    ..aOS(13, _omitFieldNames ? '' : 'pauseReason')
    ..aOS(14, _omitFieldNames ? '' : 'summary')
    ..aOS(15, _omitFieldNames ? '' : 'nextDueOn')
    ..aOS(16, _omitFieldNames ? '' : 'nextRunAt')
    ..pPS(17, _omitFieldNames ? '' : 'nextDates')
    ..aI(18, _omitFieldNames ? '' : 'instanceCount')
    ..aI(19, _omitFieldNames ? '' : 'index')
    ..aOB(20, _omitFieldNames ? '' : 'isTemplate')
    ..aOB(21, _omitFieldNames ? '' : 'templateMissing')
    ..aOS(22, _omitFieldNames ? '' : 'ownerId')
    ..aI(23, _omitFieldNames ? '' : 'version')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Series clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Series copyWith(void Function(Series) updates) =>
      super.copyWith((message) => updates(message as Series)) as Series;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Series() / Series.new instead')
  static Series create() => Series._();
  static $pb.GeneratedMessage $_createMessage() => Series._();
  @$core.override
  Series createEmptyInstance() => Series._();
  @$core.pragma('dart2js:noInline')
  static Series getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Series>(Series.$_createMessage);
  static Series? _defaultInstance;

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
  $core.String get taskId => $_getSZ(2);
  @$pb.TagNumber(3)
  set taskId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTaskId() => $_has(2);
  @$pb.TagNumber(3)
  void clearTaskId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get rrule => $_getSZ(3);
  @$pb.TagNumber(4)
  set rrule($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasRrule() => $_has(3);
  @$pb.TagNumber(4)
  void clearRrule() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get mode => $_getSZ(4);
  @$pb.TagNumber(5)
  set mode($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasMode() => $_has(4);
  @$pb.TagNumber(5)
  void clearMode() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get timezone => $_getSZ(5);
  @$pb.TagNumber(6)
  set timezone($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasTimezone() => $_has(5);
  @$pb.TagNumber(6)
  void clearTimezone() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get atTime => $_getSZ(6);
  @$pb.TagNumber(7)
  set atTime($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasAtTime() => $_has(6);
  @$pb.TagNumber(7)
  void clearAtTime() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.int get leadDays => $_getIZ(7);
  @$pb.TagNumber(8)
  set leadDays($core.int value) => $_setSignedInt32(7, value);
  @$pb.TagNumber(8)
  $core.bool hasLeadDays() => $_has(7);
  @$pb.TagNumber(8)
  void clearLeadDays() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get startsOn => $_getSZ(8);
  @$pb.TagNumber(9)
  set startsOn($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasStartsOn() => $_has(8);
  @$pb.TagNumber(9)
  void clearStartsOn() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get endsOn => $_getSZ(9);
  @$pb.TagNumber(10)
  set endsOn($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasEndsOn() => $_has(9);
  @$pb.TagNumber(10)
  void clearEndsOn() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.bool get skipWeekends => $_getBF(10);
  @$pb.TagNumber(11)
  set skipWeekends($core.bool value) => $_setBool(10, value);
  @$pb.TagNumber(11)
  $core.bool hasSkipWeekends() => $_has(10);
  @$pb.TagNumber(11)
  void clearSkipWeekends() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.bool get paused => $_getBF(11);
  @$pb.TagNumber(12)
  set paused($core.bool value) => $_setBool(11, value);
  @$pb.TagNumber(12)
  $core.bool hasPaused() => $_has(11);
  @$pb.TagNumber(12)
  void clearPaused() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.String get pauseReason => $_getSZ(12);
  @$pb.TagNumber(13)
  set pauseReason($core.String value) => $_setString(12, value);
  @$pb.TagNumber(13)
  $core.bool hasPauseReason() => $_has(12);
  @$pb.TagNumber(13)
  void clearPauseReason() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.String get summary => $_getSZ(13);
  @$pb.TagNumber(14)
  set summary($core.String value) => $_setString(13, value);
  @$pb.TagNumber(14)
  $core.bool hasSummary() => $_has(13);
  @$pb.TagNumber(14)
  void clearSummary() => $_clearField(14);

  @$pb.TagNumber(15)
  $core.String get nextDueOn => $_getSZ(14);
  @$pb.TagNumber(15)
  set nextDueOn($core.String value) => $_setString(14, value);
  @$pb.TagNumber(15)
  $core.bool hasNextDueOn() => $_has(14);
  @$pb.TagNumber(15)
  void clearNextDueOn() => $_clearField(15);

  @$pb.TagNumber(16)
  $core.String get nextRunAt => $_getSZ(15);
  @$pb.TagNumber(16)
  set nextRunAt($core.String value) => $_setString(15, value);
  @$pb.TagNumber(16)
  $core.bool hasNextRunAt() => $_has(15);
  @$pb.TagNumber(16)
  void clearNextRunAt() => $_clearField(16);

  @$pb.TagNumber(17)
  $pb.PbList<$core.String> get nextDates => $_getList(16);

  @$pb.TagNumber(18)
  $core.int get instanceCount => $_getIZ(17);
  @$pb.TagNumber(18)
  set instanceCount($core.int value) => $_setSignedInt32(17, value);
  @$pb.TagNumber(18)
  $core.bool hasInstanceCount() => $_has(17);
  @$pb.TagNumber(18)
  void clearInstanceCount() => $_clearField(18);

  @$pb.TagNumber(19)
  $core.int get index => $_getIZ(18);
  @$pb.TagNumber(19)
  set index($core.int value) => $_setSignedInt32(18, value);
  @$pb.TagNumber(19)
  $core.bool hasIndex() => $_has(18);
  @$pb.TagNumber(19)
  void clearIndex() => $_clearField(19);

  @$pb.TagNumber(20)
  $core.bool get isTemplate => $_getBF(19);
  @$pb.TagNumber(20)
  set isTemplate($core.bool value) => $_setBool(19, value);
  @$pb.TagNumber(20)
  $core.bool hasIsTemplate() => $_has(19);
  @$pb.TagNumber(20)
  void clearIsTemplate() => $_clearField(20);

  @$pb.TagNumber(21)
  $core.bool get templateMissing => $_getBF(20);
  @$pb.TagNumber(21)
  set templateMissing($core.bool value) => $_setBool(20, value);
  @$pb.TagNumber(21)
  $core.bool hasTemplateMissing() => $_has(20);
  @$pb.TagNumber(21)
  void clearTemplateMissing() => $_clearField(21);

  @$pb.TagNumber(22)
  $core.String get ownerId => $_getSZ(21);
  @$pb.TagNumber(22)
  set ownerId($core.String value) => $_setString(21, value);
  @$pb.TagNumber(22)
  $core.bool hasOwnerId() => $_has(21);
  @$pb.TagNumber(22)
  void clearOwnerId() => $_clearField(22);

  @$pb.TagNumber(23)
  $core.int get version => $_getIZ(22);
  @$pb.TagNumber(23)
  set version($core.int value) => $_setSignedInt32(22, value);
  @$pb.TagNumber(23)
  $core.bool hasVersion() => $_has(22);
  @$pb.TagNumber(23)
  void clearVersion() => $_clearField(23);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
