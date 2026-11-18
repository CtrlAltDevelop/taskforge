// This is a generated file - do not edit.
//
// Generated from infrastructure/home/grpc/home.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class HomeDay extends $pb.GeneratedMessage {
  factory HomeDay({
    $core.String? date,
    $core.int? seconds,
  }) {
    final result = HomeDay._();
    if (date != null) result.date = date;
    if (seconds != null) result.seconds = seconds;
    return result;
  }

  HomeDay._();

  factory HomeDay.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      HomeDay()..mergeFromBuffer(data, registry);
  factory HomeDay.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      HomeDay()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'HomeDay',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.home'),
      createEmptyInstance: HomeDay.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'date')
    ..aI(2, _omitFieldNames ? '' : 'seconds')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HomeDay clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HomeDay copyWith(void Function(HomeDay) updates) =>
      super.copyWith((message) => updates(message as HomeDay)) as HomeDay;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use HomeDay() / HomeDay.new instead')
  static HomeDay create() => HomeDay._();
  static $pb.GeneratedMessage $_createMessage() => HomeDay._();
  @$core.override
  HomeDay createEmptyInstance() => HomeDay._();
  @$core.pragma('dart2js:noInline')
  static HomeDay getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<HomeDay>(HomeDay.$_createMessage);
  static HomeDay? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get date => $_getSZ(0);
  @$pb.TagNumber(1)
  set date($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDate() => $_has(0);
  @$pb.TagNumber(1)
  void clearDate() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get seconds => $_getIZ(1);
  @$pb.TagNumber(2)
  set seconds($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSeconds() => $_has(1);
  @$pb.TagNumber(2)
  void clearSeconds() => $_clearField(2);
}

class HomeMention extends $pb.GeneratedMessage {
  factory HomeMention({
    $core.String? id,
    $core.String? type,
    $core.String? taskId,
    $core.String? actorId,
    $core.String? createdAt,
    $core.bool? read,
    $core.String? payloadJson,
  }) {
    final result = HomeMention._();
    if (id != null) result.id = id;
    if (type != null) result.type = type;
    if (taskId != null) result.taskId = taskId;
    if (actorId != null) result.actorId = actorId;
    if (createdAt != null) result.createdAt = createdAt;
    if (read != null) result.read = read;
    if (payloadJson != null) result.payloadJson = payloadJson;
    return result;
  }

  HomeMention._();

  factory HomeMention.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      HomeMention()..mergeFromBuffer(data, registry);
  factory HomeMention.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      HomeMention()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'HomeMention',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.home'),
      createEmptyInstance: HomeMention.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'type')
    ..aOS(3, _omitFieldNames ? '' : 'taskId')
    ..aOS(4, _omitFieldNames ? '' : 'actorId')
    ..aOS(5, _omitFieldNames ? '' : 'createdAt')
    ..aOB(6, _omitFieldNames ? '' : 'read')
    ..aOS(7, _omitFieldNames ? '' : 'payloadJson')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HomeMention clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HomeMention copyWith(void Function(HomeMention) updates) =>
      super.copyWith((message) => updates(message as HomeMention))
          as HomeMention;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use HomeMention() / HomeMention.new instead')
  static HomeMention create() => HomeMention._();
  static $pb.GeneratedMessage $_createMessage() => HomeMention._();
  @$core.override
  HomeMention createEmptyInstance() => HomeMention._();
  @$core.pragma('dart2js:noInline')
  static HomeMention getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<HomeMention>(
          HomeMention.$_createMessage);
  static HomeMention? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get type => $_getSZ(1);
  @$pb.TagNumber(2)
  set type($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasType() => $_has(1);
  @$pb.TagNumber(2)
  void clearType() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get taskId => $_getSZ(2);
  @$pb.TagNumber(3)
  set taskId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTaskId() => $_has(2);
  @$pb.TagNumber(3)
  void clearTaskId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get actorId => $_getSZ(3);
  @$pb.TagNumber(4)
  set actorId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasActorId() => $_has(3);
  @$pb.TagNumber(4)
  void clearActorId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get createdAt => $_getSZ(4);
  @$pb.TagNumber(5)
  set createdAt($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasCreatedAt() => $_has(4);
  @$pb.TagNumber(5)
  void clearCreatedAt() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.bool get read => $_getBF(5);
  @$pb.TagNumber(6)
  set read($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasRead() => $_has(5);
  @$pb.TagNumber(6)
  void clearRead() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get payloadJson => $_getSZ(6);
  @$pb.TagNumber(7)
  set payloadJson($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasPayloadJson() => $_has(6);
  @$pb.TagNumber(7)
  void clearPayloadJson() => $_clearField(7);
}

class HomeMyWork extends $pb.GeneratedMessage {
  factory HomeMyWork({
    $core.Iterable<MyWorkTask>? tasks,
    $core.String? nextCursor,
  }) {
    final result = HomeMyWork._();
    if (tasks != null) result.tasks.addAll(tasks);
    if (nextCursor != null) result.nextCursor = nextCursor;
    return result;
  }

  HomeMyWork._();

  factory HomeMyWork.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      HomeMyWork()..mergeFromBuffer(data, registry);
  factory HomeMyWork.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      HomeMyWork()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'HomeMyWork',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.home'),
      createEmptyInstance: HomeMyWork.$_createMessage)
    ..pPM<MyWorkTask>(1, _omitFieldNames ? '' : 'tasks',
        subBuilder: MyWorkTask.$_createMessage)
    ..aOS(2, _omitFieldNames ? '' : 'nextCursor')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HomeMyWork clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HomeMyWork copyWith(void Function(HomeMyWork) updates) =>
      super.copyWith((message) => updates(message as HomeMyWork)) as HomeMyWork;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use HomeMyWork() / HomeMyWork.new instead')
  static HomeMyWork create() => HomeMyWork._();
  static $pb.GeneratedMessage $_createMessage() => HomeMyWork._();
  @$core.override
  HomeMyWork createEmptyInstance() => HomeMyWork._();
  @$core.pragma('dart2js:noInline')
  static HomeMyWork getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<HomeMyWork>(HomeMyWork.$_createMessage);
  static HomeMyWork? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<MyWorkTask> get tasks => $_getList(0);

  @$pb.TagNumber(2)
  $core.String get nextCursor => $_getSZ(1);
  @$pb.TagNumber(2)
  set nextCursor($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasNextCursor() => $_has(1);
  @$pb.TagNumber(2)
  void clearNextCursor() => $_clearField(2);
}

class HomeMyWorkRequest extends $pb.GeneratedMessage {
  factory HomeMyWorkRequest({
    $core.String? workspaceId,
    $core.String? relation,
    $core.bool? includeDone,
    $core.String? filterAst,
    $core.String? today,
    $core.String? cursor,
    $core.int? limit,
  }) {
    final result = HomeMyWorkRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (relation != null) result.relation = relation;
    if (includeDone != null) result.includeDone = includeDone;
    if (filterAst != null) result.filterAst = filterAst;
    if (today != null) result.today = today;
    if (cursor != null) result.cursor = cursor;
    if (limit != null) result.limit = limit;
    return result;
  }

  HomeMyWorkRequest._();

  factory HomeMyWorkRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      HomeMyWorkRequest()..mergeFromBuffer(data, registry);
  factory HomeMyWorkRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      HomeMyWorkRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'HomeMyWorkRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.home'),
      createEmptyInstance: HomeMyWorkRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'relation')
    ..aOB(3, _omitFieldNames ? '' : 'includeDone')
    ..aOS(4, _omitFieldNames ? '' : 'filterAst')
    ..aOS(5, _omitFieldNames ? '' : 'today')
    ..aOS(6, _omitFieldNames ? '' : 'cursor')
    ..aI(7, _omitFieldNames ? '' : 'limit')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HomeMyWorkRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HomeMyWorkRequest copyWith(void Function(HomeMyWorkRequest) updates) =>
      super.copyWith((message) => updates(message as HomeMyWorkRequest))
          as HomeMyWorkRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use HomeMyWorkRequest() / HomeMyWorkRequest.new instead')
  static HomeMyWorkRequest create() => HomeMyWorkRequest._();
  static $pb.GeneratedMessage $_createMessage() => HomeMyWorkRequest._();
  @$core.override
  HomeMyWorkRequest createEmptyInstance() => HomeMyWorkRequest._();
  @$core.pragma('dart2js:noInline')
  static HomeMyWorkRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<HomeMyWorkRequest>(
          HomeMyWorkRequest.$_createMessage);
  static HomeMyWorkRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get relation => $_getSZ(1);
  @$pb.TagNumber(2)
  set relation($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRelation() => $_has(1);
  @$pb.TagNumber(2)
  void clearRelation() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get includeDone => $_getBF(2);
  @$pb.TagNumber(3)
  set includeDone($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasIncludeDone() => $_has(2);
  @$pb.TagNumber(3)
  void clearIncludeDone() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get filterAst => $_getSZ(3);
  @$pb.TagNumber(4)
  set filterAst($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasFilterAst() => $_has(3);
  @$pb.TagNumber(4)
  void clearFilterAst() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get today => $_getSZ(4);
  @$pb.TagNumber(5)
  set today($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasToday() => $_has(4);
  @$pb.TagNumber(5)
  void clearToday() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get cursor => $_getSZ(5);
  @$pb.TagNumber(6)
  set cursor($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasCursor() => $_has(5);
  @$pb.TagNumber(6)
  void clearCursor() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.int get limit => $_getIZ(6);
  @$pb.TagNumber(7)
  set limit($core.int value) => $_setSignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasLimit() => $_has(6);
  @$pb.TagNumber(7)
  void clearLimit() => $_clearField(7);
}

class HomePin extends $pb.GeneratedMessage {
  factory HomePin({
    $core.String? dashboardId,
    $core.String? name,
    $core.String? projectId,
  }) {
    final result = HomePin._();
    if (dashboardId != null) result.dashboardId = dashboardId;
    if (name != null) result.name = name;
    if (projectId != null) result.projectId = projectId;
    return result;
  }

  HomePin._();

  factory HomePin.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      HomePin()..mergeFromBuffer(data, registry);
  factory HomePin.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      HomePin()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'HomePin',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.home'),
      createEmptyInstance: HomePin.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'dashboardId')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOS(3, _omitFieldNames ? '' : 'projectId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HomePin clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HomePin copyWith(void Function(HomePin) updates) =>
      super.copyWith((message) => updates(message as HomePin)) as HomePin;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use HomePin() / HomePin.new instead')
  static HomePin create() => HomePin._();
  static $pb.GeneratedMessage $_createMessage() => HomePin._();
  @$core.override
  HomePin createEmptyInstance() => HomePin._();
  @$core.pragma('dart2js:noInline')
  static HomePin getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<HomePin>(HomePin.$_createMessage);
  static HomePin? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get dashboardId => $_getSZ(0);
  @$pb.TagNumber(1)
  set dashboardId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDashboardId() => $_has(0);
  @$pb.TagNumber(1)
  void clearDashboardId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get projectId => $_getSZ(2);
  @$pb.TagNumber(3)
  set projectId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasProjectId() => $_has(2);
  @$pb.TagNumber(3)
  void clearProjectId() => $_clearField(3);
}

class HomePinDashboardRequest extends $pb.GeneratedMessage {
  factory HomePinDashboardRequest({
    $core.String? workspaceId,
    $core.String? dashboardId,
    $core.bool? pinned,
  }) {
    final result = HomePinDashboardRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (dashboardId != null) result.dashboardId = dashboardId;
    if (pinned != null) result.pinned = pinned;
    return result;
  }

  HomePinDashboardRequest._();

  factory HomePinDashboardRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      HomePinDashboardRequest()..mergeFromBuffer(data, registry);
  factory HomePinDashboardRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      HomePinDashboardRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'HomePinDashboardRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.home'),
      createEmptyInstance: HomePinDashboardRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'dashboardId')
    ..aOB(3, _omitFieldNames ? '' : 'pinned')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HomePinDashboardRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HomePinDashboardRequest copyWith(
          void Function(HomePinDashboardRequest) updates) =>
      super.copyWith((message) => updates(message as HomePinDashboardRequest))
          as HomePinDashboardRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use HomePinDashboardRequest() / HomePinDashboardRequest.new instead')
  static HomePinDashboardRequest create() => HomePinDashboardRequest._();
  static $pb.GeneratedMessage $_createMessage() => HomePinDashboardRequest._();
  @$core.override
  HomePinDashboardRequest createEmptyInstance() => HomePinDashboardRequest._();
  @$core.pragma('dart2js:noInline')
  static HomePinDashboardRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<HomePinDashboardRequest>(
          HomePinDashboardRequest.$_createMessage);
  static HomePinDashboardRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get dashboardId => $_getSZ(1);
  @$pb.TagNumber(2)
  set dashboardId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDashboardId() => $_has(1);
  @$pb.TagNumber(2)
  void clearDashboardId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get pinned => $_getBF(2);
  @$pb.TagNumber(3)
  set pinned($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPinned() => $_has(2);
  @$pb.TagNumber(3)
  void clearPinned() => $_clearField(3);
}

class HomePinned extends $pb.GeneratedMessage {
  factory HomePinned() => HomePinned._();

  HomePinned._();

  factory HomePinned.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      HomePinned()..mergeFromBuffer(data, registry);
  factory HomePinned.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      HomePinned()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'HomePinned',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.home'),
      createEmptyInstance: HomePinned.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HomePinned clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HomePinned copyWith(void Function(HomePinned) updates) =>
      super.copyWith((message) => updates(message as HomePinned)) as HomePinned;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use HomePinned() / HomePinned.new instead')
  static HomePinned create() => HomePinned._();
  static $pb.GeneratedMessage $_createMessage() => HomePinned._();
  @$core.override
  HomePinned createEmptyInstance() => HomePinned._();
  @$core.pragma('dart2js:noInline')
  static HomePinned getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<HomePinned>(HomePinned.$_createMessage);
  static HomePinned? _defaultInstance;
}

class HomeRecordRecentRequest extends $pb.GeneratedMessage {
  factory HomeRecordRecentRequest({
    $core.String? workspaceId,
    $core.String? taskId,
  }) {
    final result = HomeRecordRecentRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (taskId != null) result.taskId = taskId;
    return result;
  }

  HomeRecordRecentRequest._();

  factory HomeRecordRecentRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      HomeRecordRecentRequest()..mergeFromBuffer(data, registry);
  factory HomeRecordRecentRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      HomeRecordRecentRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'HomeRecordRecentRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.home'),
      createEmptyInstance: HomeRecordRecentRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'taskId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HomeRecordRecentRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HomeRecordRecentRequest copyWith(
          void Function(HomeRecordRecentRequest) updates) =>
      super.copyWith((message) => updates(message as HomeRecordRecentRequest))
          as HomeRecordRecentRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use HomeRecordRecentRequest() / HomeRecordRecentRequest.new instead')
  static HomeRecordRecentRequest create() => HomeRecordRecentRequest._();
  static $pb.GeneratedMessage $_createMessage() => HomeRecordRecentRequest._();
  @$core.override
  HomeRecordRecentRequest createEmptyInstance() => HomeRecordRecentRequest._();
  @$core.pragma('dart2js:noInline')
  static HomeRecordRecentRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<HomeRecordRecentRequest>(
          HomeRecordRecentRequest.$_createMessage);
  static HomeRecordRecentRequest? _defaultInstance;

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

class HomeRecorded extends $pb.GeneratedMessage {
  factory HomeRecorded() => HomeRecorded._();

  HomeRecorded._();

  factory HomeRecorded.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      HomeRecorded()..mergeFromBuffer(data, registry);
  factory HomeRecorded.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      HomeRecorded()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'HomeRecorded',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.home'),
      createEmptyInstance: HomeRecorded.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HomeRecorded clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HomeRecorded copyWith(void Function(HomeRecorded) updates) =>
      super.copyWith((message) => updates(message as HomeRecorded))
          as HomeRecorded;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use HomeRecorded() / HomeRecorded.new instead')
  static HomeRecorded create() => HomeRecorded._();
  static $pb.GeneratedMessage $_createMessage() => HomeRecorded._();
  @$core.override
  HomeRecorded createEmptyInstance() => HomeRecorded._();
  @$core.pragma('dart2js:noInline')
  static HomeRecorded getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<HomeRecorded>(
          HomeRecorded.$_createMessage);
  static HomeRecorded? _defaultInstance;
}

class HomeSummary extends $pb.GeneratedMessage {
  factory HomeSummary({
    $core.int? todayCount,
    $core.int? overdueCount,
    $core.int? inProgressCount,
    $core.Iterable<HomeTask>? dueItems,
    $core.Iterable<HomeTask>? inProgressItems,
    $core.Iterable<HomeTask>? recent,
    $core.Iterable<HomeMention>? mentions,
    $core.int? unreadNotifications,
    $core.int? unreadChat,
    $core.Iterable<HomeDay>? week,
    $core.Iterable<HomePin>? pinnedDashboards,
    $core.String? computedAt,
  }) {
    final result = HomeSummary._();
    if (todayCount != null) result.todayCount = todayCount;
    if (overdueCount != null) result.overdueCount = overdueCount;
    if (inProgressCount != null) result.inProgressCount = inProgressCount;
    if (dueItems != null) result.dueItems.addAll(dueItems);
    if (inProgressItems != null) result.inProgressItems.addAll(inProgressItems);
    if (recent != null) result.recent.addAll(recent);
    if (mentions != null) result.mentions.addAll(mentions);
    if (unreadNotifications != null)
      result.unreadNotifications = unreadNotifications;
    if (unreadChat != null) result.unreadChat = unreadChat;
    if (week != null) result.week.addAll(week);
    if (pinnedDashboards != null)
      result.pinnedDashboards.addAll(pinnedDashboards);
    if (computedAt != null) result.computedAt = computedAt;
    return result;
  }

  HomeSummary._();

  factory HomeSummary.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      HomeSummary()..mergeFromBuffer(data, registry);
  factory HomeSummary.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      HomeSummary()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'HomeSummary',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.home'),
      createEmptyInstance: HomeSummary.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'todayCount')
    ..aI(2, _omitFieldNames ? '' : 'overdueCount')
    ..aI(3, _omitFieldNames ? '' : 'inProgressCount')
    ..pPM<HomeTask>(4, _omitFieldNames ? '' : 'dueItems',
        subBuilder: HomeTask.$_createMessage)
    ..pPM<HomeTask>(5, _omitFieldNames ? '' : 'inProgressItems',
        subBuilder: HomeTask.$_createMessage)
    ..pPM<HomeTask>(6, _omitFieldNames ? '' : 'recent',
        subBuilder: HomeTask.$_createMessage)
    ..pPM<HomeMention>(7, _omitFieldNames ? '' : 'mentions',
        subBuilder: HomeMention.$_createMessage)
    ..aI(8, _omitFieldNames ? '' : 'unreadNotifications')
    ..aI(9, _omitFieldNames ? '' : 'unreadChat')
    ..pPM<HomeDay>(10, _omitFieldNames ? '' : 'week',
        subBuilder: HomeDay.$_createMessage)
    ..pPM<HomePin>(11, _omitFieldNames ? '' : 'pinnedDashboards',
        subBuilder: HomePin.$_createMessage)
    ..aOS(12, _omitFieldNames ? '' : 'computedAt')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HomeSummary clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HomeSummary copyWith(void Function(HomeSummary) updates) =>
      super.copyWith((message) => updates(message as HomeSummary))
          as HomeSummary;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use HomeSummary() / HomeSummary.new instead')
  static HomeSummary create() => HomeSummary._();
  static $pb.GeneratedMessage $_createMessage() => HomeSummary._();
  @$core.override
  HomeSummary createEmptyInstance() => HomeSummary._();
  @$core.pragma('dart2js:noInline')
  static HomeSummary getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<HomeSummary>(
          HomeSummary.$_createMessage);
  static HomeSummary? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get todayCount => $_getIZ(0);
  @$pb.TagNumber(1)
  set todayCount($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTodayCount() => $_has(0);
  @$pb.TagNumber(1)
  void clearTodayCount() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get overdueCount => $_getIZ(1);
  @$pb.TagNumber(2)
  set overdueCount($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasOverdueCount() => $_has(1);
  @$pb.TagNumber(2)
  void clearOverdueCount() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get inProgressCount => $_getIZ(2);
  @$pb.TagNumber(3)
  set inProgressCount($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasInProgressCount() => $_has(2);
  @$pb.TagNumber(3)
  void clearInProgressCount() => $_clearField(3);

  @$pb.TagNumber(4)
  $pb.PbList<HomeTask> get dueItems => $_getList(3);

  @$pb.TagNumber(5)
  $pb.PbList<HomeTask> get inProgressItems => $_getList(4);

  @$pb.TagNumber(6)
  $pb.PbList<HomeTask> get recent => $_getList(5);

  @$pb.TagNumber(7)
  $pb.PbList<HomeMention> get mentions => $_getList(6);

  @$pb.TagNumber(8)
  $core.int get unreadNotifications => $_getIZ(7);
  @$pb.TagNumber(8)
  set unreadNotifications($core.int value) => $_setSignedInt32(7, value);
  @$pb.TagNumber(8)
  $core.bool hasUnreadNotifications() => $_has(7);
  @$pb.TagNumber(8)
  void clearUnreadNotifications() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.int get unreadChat => $_getIZ(8);
  @$pb.TagNumber(9)
  set unreadChat($core.int value) => $_setSignedInt32(8, value);
  @$pb.TagNumber(9)
  $core.bool hasUnreadChat() => $_has(8);
  @$pb.TagNumber(9)
  void clearUnreadChat() => $_clearField(9);

  @$pb.TagNumber(10)
  $pb.PbList<HomeDay> get week => $_getList(9);

  @$pb.TagNumber(11)
  $pb.PbList<HomePin> get pinnedDashboards => $_getList(10);

  @$pb.TagNumber(12)
  $core.String get computedAt => $_getSZ(11);
  @$pb.TagNumber(12)
  set computedAt($core.String value) => $_setString(11, value);
  @$pb.TagNumber(12)
  $core.bool hasComputedAt() => $_has(11);
  @$pb.TagNumber(12)
  void clearComputedAt() => $_clearField(12);
}

class HomeSummaryRequest extends $pb.GeneratedMessage {
  factory HomeSummaryRequest({
    $core.String? workspaceId,
    $core.String? today,
    $core.int? utcOffsetMinutes,
  }) {
    final result = HomeSummaryRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (today != null) result.today = today;
    if (utcOffsetMinutes != null) result.utcOffsetMinutes = utcOffsetMinutes;
    return result;
  }

  HomeSummaryRequest._();

  factory HomeSummaryRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      HomeSummaryRequest()..mergeFromBuffer(data, registry);
  factory HomeSummaryRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      HomeSummaryRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'HomeSummaryRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.home'),
      createEmptyInstance: HomeSummaryRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'today')
    ..aI(3, _omitFieldNames ? '' : 'utcOffsetMinutes')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HomeSummaryRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HomeSummaryRequest copyWith(void Function(HomeSummaryRequest) updates) =>
      super.copyWith((message) => updates(message as HomeSummaryRequest))
          as HomeSummaryRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use HomeSummaryRequest() / HomeSummaryRequest.new instead')
  static HomeSummaryRequest create() => HomeSummaryRequest._();
  static $pb.GeneratedMessage $_createMessage() => HomeSummaryRequest._();
  @$core.override
  HomeSummaryRequest createEmptyInstance() => HomeSummaryRequest._();
  @$core.pragma('dart2js:noInline')
  static HomeSummaryRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<HomeSummaryRequest>(
          HomeSummaryRequest.$_createMessage);
  static HomeSummaryRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get today => $_getSZ(1);
  @$pb.TagNumber(2)
  set today($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasToday() => $_has(1);
  @$pb.TagNumber(2)
  void clearToday() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get utcOffsetMinutes => $_getIZ(2);
  @$pb.TagNumber(3)
  set utcOffsetMinutes($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasUtcOffsetMinutes() => $_has(2);
  @$pb.TagNumber(3)
  void clearUtcOffsetMinutes() => $_clearField(3);
}

class HomeTask extends $pb.GeneratedMessage {
  factory HomeTask({
    $core.String? taskId,
    $core.String? projectId,
    $core.String? projectKey,
    $core.int? number,
    $core.String? title,
    $core.String? statusName,
    $core.String? statusCategory,
    $core.String? priority,
    $core.String? dueDate,
  }) {
    final result = HomeTask._();
    if (taskId != null) result.taskId = taskId;
    if (projectId != null) result.projectId = projectId;
    if (projectKey != null) result.projectKey = projectKey;
    if (number != null) result.number = number;
    if (title != null) result.title = title;
    if (statusName != null) result.statusName = statusName;
    if (statusCategory != null) result.statusCategory = statusCategory;
    if (priority != null) result.priority = priority;
    if (dueDate != null) result.dueDate = dueDate;
    return result;
  }

  HomeTask._();

  factory HomeTask.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      HomeTask()..mergeFromBuffer(data, registry);
  factory HomeTask.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      HomeTask()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'HomeTask',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.home'),
      createEmptyInstance: HomeTask.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'taskId')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..aOS(3, _omitFieldNames ? '' : 'projectKey')
    ..aI(4, _omitFieldNames ? '' : 'number')
    ..aOS(5, _omitFieldNames ? '' : 'title')
    ..aOS(6, _omitFieldNames ? '' : 'statusName')
    ..aOS(7, _omitFieldNames ? '' : 'statusCategory')
    ..aOS(8, _omitFieldNames ? '' : 'priority')
    ..aOS(9, _omitFieldNames ? '' : 'dueDate')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HomeTask clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HomeTask copyWith(void Function(HomeTask) updates) =>
      super.copyWith((message) => updates(message as HomeTask)) as HomeTask;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use HomeTask() / HomeTask.new instead')
  static HomeTask create() => HomeTask._();
  static $pb.GeneratedMessage $_createMessage() => HomeTask._();
  @$core.override
  HomeTask createEmptyInstance() => HomeTask._();
  @$core.pragma('dart2js:noInline')
  static HomeTask getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<HomeTask>(HomeTask.$_createMessage);
  static HomeTask? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get taskId => $_getSZ(0);
  @$pb.TagNumber(1)
  set taskId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTaskId() => $_has(0);
  @$pb.TagNumber(1)
  void clearTaskId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get projectId => $_getSZ(1);
  @$pb.TagNumber(2)
  set projectId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasProjectId() => $_has(1);
  @$pb.TagNumber(2)
  void clearProjectId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get projectKey => $_getSZ(2);
  @$pb.TagNumber(3)
  set projectKey($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasProjectKey() => $_has(2);
  @$pb.TagNumber(3)
  void clearProjectKey() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get number => $_getIZ(3);
  @$pb.TagNumber(4)
  set number($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasNumber() => $_has(3);
  @$pb.TagNumber(4)
  void clearNumber() => $_clearField(4);

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

  @$pb.TagNumber(9)
  $core.String get dueDate => $_getSZ(8);
  @$pb.TagNumber(9)
  set dueDate($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasDueDate() => $_has(8);
  @$pb.TagNumber(9)
  void clearDueDate() => $_clearField(9);
}

class MyWorkTask extends $pb.GeneratedMessage {
  factory MyWorkTask({
    HomeTask? task,
    $core.bool? assigned,
    $core.bool? watching,
  }) {
    final result = MyWorkTask._();
    if (task != null) result.task = task;
    if (assigned != null) result.assigned = assigned;
    if (watching != null) result.watching = watching;
    return result;
  }

  MyWorkTask._();

  factory MyWorkTask.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MyWorkTask()..mergeFromBuffer(data, registry);
  factory MyWorkTask.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MyWorkTask()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MyWorkTask',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.home'),
      createEmptyInstance: MyWorkTask.$_createMessage)
    ..aOM<HomeTask>(1, _omitFieldNames ? '' : 'task',
        subBuilder: HomeTask.$_createMessage)
    ..aOB(2, _omitFieldNames ? '' : 'assigned')
    ..aOB(3, _omitFieldNames ? '' : 'watching')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MyWorkTask clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MyWorkTask copyWith(void Function(MyWorkTask) updates) =>
      super.copyWith((message) => updates(message as MyWorkTask)) as MyWorkTask;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use MyWorkTask() / MyWorkTask.new instead')
  static MyWorkTask create() => MyWorkTask._();
  static $pb.GeneratedMessage $_createMessage() => MyWorkTask._();
  @$core.override
  MyWorkTask createEmptyInstance() => MyWorkTask._();
  @$core.pragma('dart2js:noInline')
  static MyWorkTask getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MyWorkTask>(MyWorkTask.$_createMessage);
  static MyWorkTask? _defaultInstance;

  @$pb.TagNumber(1)
  HomeTask get task => $_getN(0);
  @$pb.TagNumber(1)
  set task(HomeTask value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasTask() => $_has(0);
  @$pb.TagNumber(1)
  void clearTask() => $_clearField(1);
  @$pb.TagNumber(1)
  HomeTask ensureTask() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.bool get assigned => $_getBF(1);
  @$pb.TagNumber(2)
  set assigned($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAssigned() => $_has(1);
  @$pb.TagNumber(2)
  void clearAssigned() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get watching => $_getBF(2);
  @$pb.TagNumber(3)
  set watching($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasWatching() => $_has(2);
  @$pb.TagNumber(3)
  void clearWatching() => $_clearField(3);
}

class OnboardingApplyStarterRequest extends $pb.GeneratedMessage {
  factory OnboardingApplyStarterRequest({
    $core.String? workspaceId,
    $core.String? starter,
    $core.String? name,
    $core.String? key,
  }) {
    final result = OnboardingApplyStarterRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (starter != null) result.starter = starter;
    if (name != null) result.name = name;
    if (key != null) result.key = key;
    return result;
  }

  OnboardingApplyStarterRequest._();

  factory OnboardingApplyStarterRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      OnboardingApplyStarterRequest()..mergeFromBuffer(data, registry);
  factory OnboardingApplyStarterRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      OnboardingApplyStarterRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'OnboardingApplyStarterRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.home'),
      createEmptyInstance: OnboardingApplyStarterRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'starter')
    ..aOS(3, _omitFieldNames ? '' : 'name')
    ..aOS(4, _omitFieldNames ? '' : 'key')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OnboardingApplyStarterRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OnboardingApplyStarterRequest copyWith(
          void Function(OnboardingApplyStarterRequest) updates) =>
      super.copyWith(
              (message) => updates(message as OnboardingApplyStarterRequest))
          as OnboardingApplyStarterRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use OnboardingApplyStarterRequest() / OnboardingApplyStarterRequest.new instead')
  static OnboardingApplyStarterRequest create() =>
      OnboardingApplyStarterRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      OnboardingApplyStarterRequest._();
  @$core.override
  OnboardingApplyStarterRequest createEmptyInstance() =>
      OnboardingApplyStarterRequest._();
  @$core.pragma('dart2js:noInline')
  static OnboardingApplyStarterRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<OnboardingApplyStarterRequest>(
          OnboardingApplyStarterRequest.$_createMessage);
  static OnboardingApplyStarterRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get starter => $_getSZ(1);
  @$pb.TagNumber(2)
  set starter($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasStarter() => $_has(1);
  @$pb.TagNumber(2)
  void clearStarter() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get name => $_getSZ(2);
  @$pb.TagNumber(3)
  set name($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasName() => $_has(2);
  @$pb.TagNumber(3)
  void clearName() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get key => $_getSZ(3);
  @$pb.TagNumber(4)
  set key($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasKey() => $_has(3);
  @$pb.TagNumber(4)
  void clearKey() => $_clearField(4);
}

class OnboardingCompleteStepRequest extends $pb.GeneratedMessage {
  factory OnboardingCompleteStepRequest({
    $core.String? workspaceId,
    $core.String? step,
  }) {
    final result = OnboardingCompleteStepRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (step != null) result.step = step;
    return result;
  }

  OnboardingCompleteStepRequest._();

  factory OnboardingCompleteStepRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      OnboardingCompleteStepRequest()..mergeFromBuffer(data, registry);
  factory OnboardingCompleteStepRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      OnboardingCompleteStepRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'OnboardingCompleteStepRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.home'),
      createEmptyInstance: OnboardingCompleteStepRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'step')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OnboardingCompleteStepRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OnboardingCompleteStepRequest copyWith(
          void Function(OnboardingCompleteStepRequest) updates) =>
      super.copyWith(
              (message) => updates(message as OnboardingCompleteStepRequest))
          as OnboardingCompleteStepRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use OnboardingCompleteStepRequest() / OnboardingCompleteStepRequest.new instead')
  static OnboardingCompleteStepRequest create() =>
      OnboardingCompleteStepRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      OnboardingCompleteStepRequest._();
  @$core.override
  OnboardingCompleteStepRequest createEmptyInstance() =>
      OnboardingCompleteStepRequest._();
  @$core.pragma('dart2js:noInline')
  static OnboardingCompleteStepRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<OnboardingCompleteStepRequest>(
          OnboardingCompleteStepRequest.$_createMessage);
  static OnboardingCompleteStepRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get step => $_getSZ(1);
  @$pb.TagNumber(2)
  set step($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasStep() => $_has(1);
  @$pb.TagNumber(2)
  void clearStep() => $_clearField(2);
}

class OnboardingDeleteSamplesRequest extends $pb.GeneratedMessage {
  factory OnboardingDeleteSamplesRequest({
    $core.String? workspaceId,
  }) {
    final result = OnboardingDeleteSamplesRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    return result;
  }

  OnboardingDeleteSamplesRequest._();

  factory OnboardingDeleteSamplesRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      OnboardingDeleteSamplesRequest()..mergeFromBuffer(data, registry);
  factory OnboardingDeleteSamplesRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      OnboardingDeleteSamplesRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'OnboardingDeleteSamplesRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.home'),
      createEmptyInstance: OnboardingDeleteSamplesRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OnboardingDeleteSamplesRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OnboardingDeleteSamplesRequest copyWith(
          void Function(OnboardingDeleteSamplesRequest) updates) =>
      super.copyWith(
              (message) => updates(message as OnboardingDeleteSamplesRequest))
          as OnboardingDeleteSamplesRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use OnboardingDeleteSamplesRequest() / OnboardingDeleteSamplesRequest.new instead')
  static OnboardingDeleteSamplesRequest create() =>
      OnboardingDeleteSamplesRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      OnboardingDeleteSamplesRequest._();
  @$core.override
  OnboardingDeleteSamplesRequest createEmptyInstance() =>
      OnboardingDeleteSamplesRequest._();
  @$core.pragma('dart2js:noInline')
  static OnboardingDeleteSamplesRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<OnboardingDeleteSamplesRequest>(
          OnboardingDeleteSamplesRequest.$_createMessage);
  static OnboardingDeleteSamplesRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);
}

class OnboardingDismissRequest extends $pb.GeneratedMessage {
  factory OnboardingDismissRequest({
    $core.String? workspaceId,
  }) {
    final result = OnboardingDismissRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    return result;
  }

  OnboardingDismissRequest._();

  factory OnboardingDismissRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      OnboardingDismissRequest()..mergeFromBuffer(data, registry);
  factory OnboardingDismissRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      OnboardingDismissRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'OnboardingDismissRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.home'),
      createEmptyInstance: OnboardingDismissRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OnboardingDismissRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OnboardingDismissRequest copyWith(
          void Function(OnboardingDismissRequest) updates) =>
      super.copyWith((message) => updates(message as OnboardingDismissRequest))
          as OnboardingDismissRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use OnboardingDismissRequest() / OnboardingDismissRequest.new instead')
  static OnboardingDismissRequest create() => OnboardingDismissRequest._();
  static $pb.GeneratedMessage $_createMessage() => OnboardingDismissRequest._();
  @$core.override
  OnboardingDismissRequest createEmptyInstance() =>
      OnboardingDismissRequest._();
  @$core.pragma('dart2js:noInline')
  static OnboardingDismissRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<OnboardingDismissRequest>(
          OnboardingDismissRequest.$_createMessage);
  static OnboardingDismissRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);
}

class OnboardingGetRequest extends $pb.GeneratedMessage {
  factory OnboardingGetRequest({
    $core.String? workspaceId,
  }) {
    final result = OnboardingGetRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    return result;
  }

  OnboardingGetRequest._();

  factory OnboardingGetRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      OnboardingGetRequest()..mergeFromBuffer(data, registry);
  factory OnboardingGetRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      OnboardingGetRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'OnboardingGetRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.home'),
      createEmptyInstance: OnboardingGetRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OnboardingGetRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OnboardingGetRequest copyWith(void Function(OnboardingGetRequest) updates) =>
      super.copyWith((message) => updates(message as OnboardingGetRequest))
          as OnboardingGetRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use OnboardingGetRequest() / OnboardingGetRequest.new instead')
  static OnboardingGetRequest create() => OnboardingGetRequest._();
  static $pb.GeneratedMessage $_createMessage() => OnboardingGetRequest._();
  @$core.override
  OnboardingGetRequest createEmptyInstance() => OnboardingGetRequest._();
  @$core.pragma('dart2js:noInline')
  static OnboardingGetRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<OnboardingGetRequest>(
          OnboardingGetRequest.$_createMessage);
  static OnboardingGetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);
}

class OnboardingSamplesDeleted extends $pb.GeneratedMessage {
  factory OnboardingSamplesDeleted({
    $core.int? deleted,
  }) {
    final result = OnboardingSamplesDeleted._();
    if (deleted != null) result.deleted = deleted;
    return result;
  }

  OnboardingSamplesDeleted._();

  factory OnboardingSamplesDeleted.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      OnboardingSamplesDeleted()..mergeFromBuffer(data, registry);
  factory OnboardingSamplesDeleted.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      OnboardingSamplesDeleted()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'OnboardingSamplesDeleted',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.home'),
      createEmptyInstance: OnboardingSamplesDeleted.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'deleted')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OnboardingSamplesDeleted clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OnboardingSamplesDeleted copyWith(
          void Function(OnboardingSamplesDeleted) updates) =>
      super.copyWith((message) => updates(message as OnboardingSamplesDeleted))
          as OnboardingSamplesDeleted;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use OnboardingSamplesDeleted() / OnboardingSamplesDeleted.new instead')
  static OnboardingSamplesDeleted create() => OnboardingSamplesDeleted._();
  static $pb.GeneratedMessage $_createMessage() => OnboardingSamplesDeleted._();
  @$core.override
  OnboardingSamplesDeleted createEmptyInstance() =>
      OnboardingSamplesDeleted._();
  @$core.pragma('dart2js:noInline')
  static OnboardingSamplesDeleted getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<OnboardingSamplesDeleted>(
          OnboardingSamplesDeleted.$_createMessage);
  static OnboardingSamplesDeleted? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get deleted => $_getIZ(0);
  @$pb.TagNumber(1)
  set deleted($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDeleted() => $_has(0);
  @$pb.TagNumber(1)
  void clearDeleted() => $_clearField(1);
}

class OnboardingStarter extends $pb.GeneratedMessage {
  factory OnboardingStarter({
    $core.String? key,
    $core.String? name,
    $core.String? description,
  }) {
    final result = OnboardingStarter._();
    if (key != null) result.key = key;
    if (name != null) result.name = name;
    if (description != null) result.description = description;
    return result;
  }

  OnboardingStarter._();

  factory OnboardingStarter.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      OnboardingStarter()..mergeFromBuffer(data, registry);
  factory OnboardingStarter.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      OnboardingStarter()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'OnboardingStarter',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.home'),
      createEmptyInstance: OnboardingStarter.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'key')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOS(3, _omitFieldNames ? '' : 'description')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OnboardingStarter clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OnboardingStarter copyWith(void Function(OnboardingStarter) updates) =>
      super.copyWith((message) => updates(message as OnboardingStarter))
          as OnboardingStarter;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use OnboardingStarter() / OnboardingStarter.new instead')
  static OnboardingStarter create() => OnboardingStarter._();
  static $pb.GeneratedMessage $_createMessage() => OnboardingStarter._();
  @$core.override
  OnboardingStarter createEmptyInstance() => OnboardingStarter._();
  @$core.pragma('dart2js:noInline')
  static OnboardingStarter getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<OnboardingStarter>(
          OnboardingStarter.$_createMessage);
  static OnboardingStarter? _defaultInstance;

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
  $core.String get description => $_getSZ(2);
  @$pb.TagNumber(3)
  set description($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDescription() => $_has(2);
  @$pb.TagNumber(3)
  void clearDescription() => $_clearField(3);
}

class OnboardingStarterApplied extends $pb.GeneratedMessage {
  factory OnboardingStarterApplied({
    $core.String? projectId,
    $core.int? taskCount,
  }) {
    final result = OnboardingStarterApplied._();
    if (projectId != null) result.projectId = projectId;
    if (taskCount != null) result.taskCount = taskCount;
    return result;
  }

  OnboardingStarterApplied._();

  factory OnboardingStarterApplied.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      OnboardingStarterApplied()..mergeFromBuffer(data, registry);
  factory OnboardingStarterApplied.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      OnboardingStarterApplied()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'OnboardingStarterApplied',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.home'),
      createEmptyInstance: OnboardingStarterApplied.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'projectId')
    ..aI(2, _omitFieldNames ? '' : 'taskCount')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OnboardingStarterApplied clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OnboardingStarterApplied copyWith(
          void Function(OnboardingStarterApplied) updates) =>
      super.copyWith((message) => updates(message as OnboardingStarterApplied))
          as OnboardingStarterApplied;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use OnboardingStarterApplied() / OnboardingStarterApplied.new instead')
  static OnboardingStarterApplied create() => OnboardingStarterApplied._();
  static $pb.GeneratedMessage $_createMessage() => OnboardingStarterApplied._();
  @$core.override
  OnboardingStarterApplied createEmptyInstance() =>
      OnboardingStarterApplied._();
  @$core.pragma('dart2js:noInline')
  static OnboardingStarterApplied getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<OnboardingStarterApplied>(
          OnboardingStarterApplied.$_createMessage);
  static OnboardingStarterApplied? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get projectId => $_getSZ(0);
  @$pb.TagNumber(1)
  set projectId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasProjectId() => $_has(0);
  @$pb.TagNumber(1)
  void clearProjectId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get taskCount => $_getIZ(1);
  @$pb.TagNumber(2)
  set taskCount($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTaskCount() => $_has(1);
  @$pb.TagNumber(2)
  void clearTaskCount() => $_clearField(2);
}

class OnboardingState extends $pb.GeneratedMessage {
  factory OnboardingState({
    $core.Iterable<OnboardingStep>? steps,
    $core.bool? dismissed,
    $core.bool? complete,
    $core.bool? visible,
    $core.String? sampleProjectId,
    $core.int? sampleCount,
    $core.Iterable<OnboardingStarter>? starters,
  }) {
    final result = OnboardingState._();
    if (steps != null) result.steps.addAll(steps);
    if (dismissed != null) result.dismissed = dismissed;
    if (complete != null) result.complete = complete;
    if (visible != null) result.visible = visible;
    if (sampleProjectId != null) result.sampleProjectId = sampleProjectId;
    if (sampleCount != null) result.sampleCount = sampleCount;
    if (starters != null) result.starters.addAll(starters);
    return result;
  }

  OnboardingState._();

  factory OnboardingState.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      OnboardingState()..mergeFromBuffer(data, registry);
  factory OnboardingState.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      OnboardingState()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'OnboardingState',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.home'),
      createEmptyInstance: OnboardingState.$_createMessage)
    ..pPM<OnboardingStep>(1, _omitFieldNames ? '' : 'steps',
        subBuilder: OnboardingStep.$_createMessage)
    ..aOB(2, _omitFieldNames ? '' : 'dismissed')
    ..aOB(3, _omitFieldNames ? '' : 'complete')
    ..aOB(4, _omitFieldNames ? '' : 'visible')
    ..aOS(5, _omitFieldNames ? '' : 'sampleProjectId')
    ..aI(6, _omitFieldNames ? '' : 'sampleCount')
    ..pPM<OnboardingStarter>(7, _omitFieldNames ? '' : 'starters',
        subBuilder: OnboardingStarter.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OnboardingState clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OnboardingState copyWith(void Function(OnboardingState) updates) =>
      super.copyWith((message) => updates(message as OnboardingState))
          as OnboardingState;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use OnboardingState() / OnboardingState.new instead')
  static OnboardingState create() => OnboardingState._();
  static $pb.GeneratedMessage $_createMessage() => OnboardingState._();
  @$core.override
  OnboardingState createEmptyInstance() => OnboardingState._();
  @$core.pragma('dart2js:noInline')
  static OnboardingState getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<OnboardingState>(
          OnboardingState.$_createMessage);
  static OnboardingState? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<OnboardingStep> get steps => $_getList(0);

  @$pb.TagNumber(2)
  $core.bool get dismissed => $_getBF(1);
  @$pb.TagNumber(2)
  set dismissed($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDismissed() => $_has(1);
  @$pb.TagNumber(2)
  void clearDismissed() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get complete => $_getBF(2);
  @$pb.TagNumber(3)
  set complete($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasComplete() => $_has(2);
  @$pb.TagNumber(3)
  void clearComplete() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get visible => $_getBF(3);
  @$pb.TagNumber(4)
  set visible($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasVisible() => $_has(3);
  @$pb.TagNumber(4)
  void clearVisible() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get sampleProjectId => $_getSZ(4);
  @$pb.TagNumber(5)
  set sampleProjectId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasSampleProjectId() => $_has(4);
  @$pb.TagNumber(5)
  void clearSampleProjectId() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get sampleCount => $_getIZ(5);
  @$pb.TagNumber(6)
  set sampleCount($core.int value) => $_setSignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasSampleCount() => $_has(5);
  @$pb.TagNumber(6)
  void clearSampleCount() => $_clearField(6);

  @$pb.TagNumber(7)
  $pb.PbList<OnboardingStarter> get starters => $_getList(6);
}

class OnboardingStep extends $pb.GeneratedMessage {
  factory OnboardingStep({
    $core.String? step,
    $core.bool? done,
  }) {
    final result = OnboardingStep._();
    if (step != null) result.step = step;
    if (done != null) result.done = done;
    return result;
  }

  OnboardingStep._();

  factory OnboardingStep.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      OnboardingStep()..mergeFromBuffer(data, registry);
  factory OnboardingStep.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      OnboardingStep()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'OnboardingStep',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.home'),
      createEmptyInstance: OnboardingStep.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'step')
    ..aOB(2, _omitFieldNames ? '' : 'done')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OnboardingStep clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OnboardingStep copyWith(void Function(OnboardingStep) updates) =>
      super.copyWith((message) => updates(message as OnboardingStep))
          as OnboardingStep;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use OnboardingStep() / OnboardingStep.new instead')
  static OnboardingStep create() => OnboardingStep._();
  static $pb.GeneratedMessage $_createMessage() => OnboardingStep._();
  @$core.override
  OnboardingStep createEmptyInstance() => OnboardingStep._();
  @$core.pragma('dart2js:noInline')
  static OnboardingStep getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<OnboardingStep>(
          OnboardingStep.$_createMessage);
  static OnboardingStep? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get step => $_getSZ(0);
  @$pb.TagNumber(1)
  set step($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasStep() => $_has(0);
  @$pb.TagNumber(1)
  void clearStep() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get done => $_getBF(1);
  @$pb.TagNumber(2)
  set done($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDone() => $_has(1);
  @$pb.TagNumber(2)
  void clearDone() => $_clearField(2);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
