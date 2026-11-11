// This is a generated file - do not edit.
//
// Generated from infrastructure/sprints/grpc/sprints.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class BacklogList extends $pb.GeneratedMessage {
  factory BacklogList({
    $core.Iterable<SprintTask>? tasks,
    $core.int? total,
  }) {
    final result = BacklogList._();
    if (tasks != null) result.tasks.addAll(tasks);
    if (total != null) result.total = total;
    return result;
  }

  BacklogList._();

  factory BacklogList.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BacklogList()..mergeFromBuffer(data, registry);
  factory BacklogList.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BacklogList()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'BacklogList',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.sprints'),
      createEmptyInstance: BacklogList.$_createMessage)
    ..pPM<SprintTask>(1, _omitFieldNames ? '' : 'tasks',
        subBuilder: SprintTask.$_createMessage)
    ..aI(2, _omitFieldNames ? '' : 'total')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BacklogList clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BacklogList copyWith(void Function(BacklogList) updates) =>
      super.copyWith((message) => updates(message as BacklogList))
          as BacklogList;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use BacklogList() / BacklogList.new instead')
  static BacklogList create() => BacklogList._();
  static $pb.GeneratedMessage $_createMessage() => BacklogList._();
  @$core.override
  BacklogList createEmptyInstance() => BacklogList._();
  @$core.pragma('dart2js:noInline')
  static BacklogList getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<BacklogList>(
          BacklogList.$_createMessage);
  static BacklogList? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<SprintTask> get tasks => $_getList(0);

  @$pb.TagNumber(2)
  $core.int get total => $_getIZ(1);
  @$pb.TagNumber(2)
  set total($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTotal() => $_has(1);
  @$pb.TagNumber(2)
  void clearTotal() => $_clearField(2);
}

class BacklogListRequest extends $pb.GeneratedMessage {
  factory BacklogListRequest({
    $core.String? workspaceId,
    $core.String? projectId,
    $core.int? limit,
  }) {
    final result = BacklogListRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (projectId != null) result.projectId = projectId;
    if (limit != null) result.limit = limit;
    return result;
  }

  BacklogListRequest._();

  factory BacklogListRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BacklogListRequest()..mergeFromBuffer(data, registry);
  factory BacklogListRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BacklogListRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'BacklogListRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.sprints'),
      createEmptyInstance: BacklogListRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..aI(3, _omitFieldNames ? '' : 'limit')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BacklogListRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BacklogListRequest copyWith(void Function(BacklogListRequest) updates) =>
      super.copyWith((message) => updates(message as BacklogListRequest))
          as BacklogListRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use BacklogListRequest() / BacklogListRequest.new instead')
  static BacklogListRequest create() => BacklogListRequest._();
  static $pb.GeneratedMessage $_createMessage() => BacklogListRequest._();
  @$core.override
  BacklogListRequest createEmptyInstance() => BacklogListRequest._();
  @$core.pragma('dart2js:noInline')
  static BacklogListRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<BacklogListRequest>(
          BacklogListRequest.$_createMessage);
  static BacklogListRequest? _defaultInstance;

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
  $core.int get limit => $_getIZ(2);
  @$pb.TagNumber(3)
  set limit($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasLimit() => $_has(2);
  @$pb.TagNumber(3)
  void clearLimit() => $_clearField(3);
}

class BurndownAnswer extends $pb.GeneratedMessage {
  factory BurndownAnswer({
    Sprint? sprint,
    $core.double? baselinePoints,
    $core.int? baselineTasks,
    $core.Iterable<BurndownDay>? days,
    $core.Iterable<ScopeChange>? scopeChanges,
    $core.Iterable<VelocityItem>? velocity,
    $core.double? averageVelocity,
    $core.String? serverNow,
  }) {
    final result = BurndownAnswer._();
    if (sprint != null) result.sprint = sprint;
    if (baselinePoints != null) result.baselinePoints = baselinePoints;
    if (baselineTasks != null) result.baselineTasks = baselineTasks;
    if (days != null) result.days.addAll(days);
    if (scopeChanges != null) result.scopeChanges.addAll(scopeChanges);
    if (velocity != null) result.velocity.addAll(velocity);
    if (averageVelocity != null) result.averageVelocity = averageVelocity;
    if (serverNow != null) result.serverNow = serverNow;
    return result;
  }

  BurndownAnswer._();

  factory BurndownAnswer.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BurndownAnswer()..mergeFromBuffer(data, registry);
  factory BurndownAnswer.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BurndownAnswer()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'BurndownAnswer',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.sprints'),
      createEmptyInstance: BurndownAnswer.$_createMessage)
    ..aOM<Sprint>(1, _omitFieldNames ? '' : 'sprint',
        subBuilder: Sprint.$_createMessage)
    ..aD(2, _omitFieldNames ? '' : 'baselinePoints')
    ..aI(3, _omitFieldNames ? '' : 'baselineTasks')
    ..pPM<BurndownDay>(4, _omitFieldNames ? '' : 'days',
        subBuilder: BurndownDay.$_createMessage)
    ..pPM<ScopeChange>(5, _omitFieldNames ? '' : 'scopeChanges',
        subBuilder: ScopeChange.$_createMessage)
    ..pPM<VelocityItem>(6, _omitFieldNames ? '' : 'velocity',
        subBuilder: VelocityItem.$_createMessage)
    ..aD(7, _omitFieldNames ? '' : 'averageVelocity')
    ..aOS(8, _omitFieldNames ? '' : 'serverNow')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BurndownAnswer clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BurndownAnswer copyWith(void Function(BurndownAnswer) updates) =>
      super.copyWith((message) => updates(message as BurndownAnswer))
          as BurndownAnswer;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use BurndownAnswer() / BurndownAnswer.new instead')
  static BurndownAnswer create() => BurndownAnswer._();
  static $pb.GeneratedMessage $_createMessage() => BurndownAnswer._();
  @$core.override
  BurndownAnswer createEmptyInstance() => BurndownAnswer._();
  @$core.pragma('dart2js:noInline')
  static BurndownAnswer getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<BurndownAnswer>(
          BurndownAnswer.$_createMessage);
  static BurndownAnswer? _defaultInstance;

  @$pb.TagNumber(1)
  Sprint get sprint => $_getN(0);
  @$pb.TagNumber(1)
  set sprint(Sprint value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSprint() => $_has(0);
  @$pb.TagNumber(1)
  void clearSprint() => $_clearField(1);
  @$pb.TagNumber(1)
  Sprint ensureSprint() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.double get baselinePoints => $_getN(1);
  @$pb.TagNumber(2)
  set baselinePoints($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasBaselinePoints() => $_has(1);
  @$pb.TagNumber(2)
  void clearBaselinePoints() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get baselineTasks => $_getIZ(2);
  @$pb.TagNumber(3)
  set baselineTasks($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasBaselineTasks() => $_has(2);
  @$pb.TagNumber(3)
  void clearBaselineTasks() => $_clearField(3);

  @$pb.TagNumber(4)
  $pb.PbList<BurndownDay> get days => $_getList(3);

  @$pb.TagNumber(5)
  $pb.PbList<ScopeChange> get scopeChanges => $_getList(4);

  @$pb.TagNumber(6)
  $pb.PbList<VelocityItem> get velocity => $_getList(5);

  @$pb.TagNumber(7)
  $core.double get averageVelocity => $_getN(6);
  @$pb.TagNumber(7)
  set averageVelocity($core.double value) => $_setDouble(6, value);
  @$pb.TagNumber(7)
  $core.bool hasAverageVelocity() => $_has(6);
  @$pb.TagNumber(7)
  void clearAverageVelocity() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get serverNow => $_getSZ(7);
  @$pb.TagNumber(8)
  set serverNow($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasServerNow() => $_has(7);
  @$pb.TagNumber(8)
  void clearServerNow() => $_clearField(8);
}

class BurndownDay extends $pb.GeneratedMessage {
  factory BurndownDay({
    $core.String? date,
    $core.double? idealPoints,
    $core.double? idealTasks,
    $core.bool? hasActual,
    $core.bool? live,
    $core.bool? backfilled,
    $core.double? remainingPoints,
    $core.int? remainingTasks,
    $core.double? scopePoints,
    $core.int? scopeTasks,
  }) {
    final result = BurndownDay._();
    if (date != null) result.date = date;
    if (idealPoints != null) result.idealPoints = idealPoints;
    if (idealTasks != null) result.idealTasks = idealTasks;
    if (hasActual != null) result.hasActual = hasActual;
    if (live != null) result.live = live;
    if (backfilled != null) result.backfilled = backfilled;
    if (remainingPoints != null) result.remainingPoints = remainingPoints;
    if (remainingTasks != null) result.remainingTasks = remainingTasks;
    if (scopePoints != null) result.scopePoints = scopePoints;
    if (scopeTasks != null) result.scopeTasks = scopeTasks;
    return result;
  }

  BurndownDay._();

  factory BurndownDay.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BurndownDay()..mergeFromBuffer(data, registry);
  factory BurndownDay.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BurndownDay()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'BurndownDay',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.sprints'),
      createEmptyInstance: BurndownDay.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'date')
    ..aD(2, _omitFieldNames ? '' : 'idealPoints')
    ..aD(3, _omitFieldNames ? '' : 'idealTasks')
    ..aOB(4, _omitFieldNames ? '' : 'hasActual')
    ..aOB(5, _omitFieldNames ? '' : 'live')
    ..aOB(6, _omitFieldNames ? '' : 'backfilled')
    ..aD(7, _omitFieldNames ? '' : 'remainingPoints')
    ..aI(8, _omitFieldNames ? '' : 'remainingTasks')
    ..aD(9, _omitFieldNames ? '' : 'scopePoints')
    ..aI(10, _omitFieldNames ? '' : 'scopeTasks')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BurndownDay clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BurndownDay copyWith(void Function(BurndownDay) updates) =>
      super.copyWith((message) => updates(message as BurndownDay))
          as BurndownDay;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use BurndownDay() / BurndownDay.new instead')
  static BurndownDay create() => BurndownDay._();
  static $pb.GeneratedMessage $_createMessage() => BurndownDay._();
  @$core.override
  BurndownDay createEmptyInstance() => BurndownDay._();
  @$core.pragma('dart2js:noInline')
  static BurndownDay getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<BurndownDay>(
          BurndownDay.$_createMessage);
  static BurndownDay? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get date => $_getSZ(0);
  @$pb.TagNumber(1)
  set date($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDate() => $_has(0);
  @$pb.TagNumber(1)
  void clearDate() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get idealPoints => $_getN(1);
  @$pb.TagNumber(2)
  set idealPoints($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasIdealPoints() => $_has(1);
  @$pb.TagNumber(2)
  void clearIdealPoints() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get idealTasks => $_getN(2);
  @$pb.TagNumber(3)
  set idealTasks($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasIdealTasks() => $_has(2);
  @$pb.TagNumber(3)
  void clearIdealTasks() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get hasActual => $_getBF(3);
  @$pb.TagNumber(4)
  set hasActual($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasHasActual() => $_has(3);
  @$pb.TagNumber(4)
  void clearHasActual() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.bool get live => $_getBF(4);
  @$pb.TagNumber(5)
  set live($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasLive() => $_has(4);
  @$pb.TagNumber(5)
  void clearLive() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.bool get backfilled => $_getBF(5);
  @$pb.TagNumber(6)
  set backfilled($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasBackfilled() => $_has(5);
  @$pb.TagNumber(6)
  void clearBackfilled() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.double get remainingPoints => $_getN(6);
  @$pb.TagNumber(7)
  set remainingPoints($core.double value) => $_setDouble(6, value);
  @$pb.TagNumber(7)
  $core.bool hasRemainingPoints() => $_has(6);
  @$pb.TagNumber(7)
  void clearRemainingPoints() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.int get remainingTasks => $_getIZ(7);
  @$pb.TagNumber(8)
  set remainingTasks($core.int value) => $_setSignedInt32(7, value);
  @$pb.TagNumber(8)
  $core.bool hasRemainingTasks() => $_has(7);
  @$pb.TagNumber(8)
  void clearRemainingTasks() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.double get scopePoints => $_getN(8);
  @$pb.TagNumber(9)
  set scopePoints($core.double value) => $_setDouble(8, value);
  @$pb.TagNumber(9)
  $core.bool hasScopePoints() => $_has(8);
  @$pb.TagNumber(9)
  void clearScopePoints() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.int get scopeTasks => $_getIZ(9);
  @$pb.TagNumber(10)
  set scopeTasks($core.int value) => $_setSignedInt32(9, value);
  @$pb.TagNumber(10)
  $core.bool hasScopeTasks() => $_has(9);
  @$pb.TagNumber(10)
  void clearScopeTasks() => $_clearField(10);
}

class BurndownRequest extends $pb.GeneratedMessage {
  factory BurndownRequest({
    $core.String? workspaceId,
    $core.String? projectId,
    $core.String? sprintId,
  }) {
    final result = BurndownRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (projectId != null) result.projectId = projectId;
    if (sprintId != null) result.sprintId = sprintId;
    return result;
  }

  BurndownRequest._();

  factory BurndownRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BurndownRequest()..mergeFromBuffer(data, registry);
  factory BurndownRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BurndownRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'BurndownRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.sprints'),
      createEmptyInstance: BurndownRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..aOS(3, _omitFieldNames ? '' : 'sprintId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BurndownRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BurndownRequest copyWith(void Function(BurndownRequest) updates) =>
      super.copyWith((message) => updates(message as BurndownRequest))
          as BurndownRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use BurndownRequest() / BurndownRequest.new instead')
  static BurndownRequest create() => BurndownRequest._();
  static $pb.GeneratedMessage $_createMessage() => BurndownRequest._();
  @$core.override
  BurndownRequest createEmptyInstance() => BurndownRequest._();
  @$core.pragma('dart2js:noInline')
  static BurndownRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<BurndownRequest>(
          BurndownRequest.$_createMessage);
  static BurndownRequest? _defaultInstance;

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
  $core.String get sprintId => $_getSZ(2);
  @$pb.TagNumber(3)
  set sprintId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSprintId() => $_has(2);
  @$pb.TagNumber(3)
  void clearSprintId() => $_clearField(3);
}

class PointsSetRequest extends $pb.GeneratedMessage {
  factory PointsSetRequest({
    $core.String? workspaceId,
    $core.String? projectId,
    $core.String? taskId,
    $core.String? points,
    $core.int? expectedVersion,
  }) {
    final result = PointsSetRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (projectId != null) result.projectId = projectId;
    if (taskId != null) result.taskId = taskId;
    if (points != null) result.points = points;
    if (expectedVersion != null) result.expectedVersion = expectedVersion;
    return result;
  }

  PointsSetRequest._();

  factory PointsSetRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PointsSetRequest()..mergeFromBuffer(data, registry);
  factory PointsSetRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PointsSetRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PointsSetRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.sprints'),
      createEmptyInstance: PointsSetRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..aOS(3, _omitFieldNames ? '' : 'taskId')
    ..aOS(4, _omitFieldNames ? '' : 'points')
    ..aI(5, _omitFieldNames ? '' : 'expectedVersion')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PointsSetRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PointsSetRequest copyWith(void Function(PointsSetRequest) updates) =>
      super.copyWith((message) => updates(message as PointsSetRequest))
          as PointsSetRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use PointsSetRequest() / PointsSetRequest.new instead')
  static PointsSetRequest create() => PointsSetRequest._();
  static $pb.GeneratedMessage $_createMessage() => PointsSetRequest._();
  @$core.override
  PointsSetRequest createEmptyInstance() => PointsSetRequest._();
  @$core.pragma('dart2js:noInline')
  static PointsSetRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PointsSetRequest>(
          PointsSetRequest.$_createMessage);
  static PointsSetRequest? _defaultInstance;

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
  $core.String get points => $_getSZ(3);
  @$pb.TagNumber(4)
  set points($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasPoints() => $_has(3);
  @$pb.TagNumber(4)
  void clearPoints() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get expectedVersion => $_getIZ(4);
  @$pb.TagNumber(5)
  set expectedVersion($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasExpectedVersion() => $_has(4);
  @$pb.TagNumber(5)
  void clearExpectedVersion() => $_clearField(5);
}

class ScopeChange extends $pb.GeneratedMessage {
  factory ScopeChange({
    $core.String? date,
    $core.double? points,
    $core.int? tasks,
  }) {
    final result = ScopeChange._();
    if (date != null) result.date = date;
    if (points != null) result.points = points;
    if (tasks != null) result.tasks = tasks;
    return result;
  }

  ScopeChange._();

  factory ScopeChange.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ScopeChange()..mergeFromBuffer(data, registry);
  factory ScopeChange.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ScopeChange()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ScopeChange',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.sprints'),
      createEmptyInstance: ScopeChange.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'date')
    ..aD(2, _omitFieldNames ? '' : 'points')
    ..aI(3, _omitFieldNames ? '' : 'tasks')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ScopeChange clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ScopeChange copyWith(void Function(ScopeChange) updates) =>
      super.copyWith((message) => updates(message as ScopeChange))
          as ScopeChange;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ScopeChange() / ScopeChange.new instead')
  static ScopeChange create() => ScopeChange._();
  static $pb.GeneratedMessage $_createMessage() => ScopeChange._();
  @$core.override
  ScopeChange createEmptyInstance() => ScopeChange._();
  @$core.pragma('dart2js:noInline')
  static ScopeChange getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ScopeChange>(
          ScopeChange.$_createMessage);
  static ScopeChange? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get date => $_getSZ(0);
  @$pb.TagNumber(1)
  set date($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDate() => $_has(0);
  @$pb.TagNumber(1)
  void clearDate() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get points => $_getN(1);
  @$pb.TagNumber(2)
  set points($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPoints() => $_has(1);
  @$pb.TagNumber(2)
  void clearPoints() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get tasks => $_getIZ(2);
  @$pb.TagNumber(3)
  set tasks($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTasks() => $_has(2);
  @$pb.TagNumber(3)
  void clearTasks() => $_clearField(3);
}

class Sprint extends $pb.GeneratedMessage {
  factory Sprint({
    $core.String? id,
    $core.String? workspaceId,
    $core.String? projectId,
    $core.String? name,
    $core.String? goal,
    $core.String? startDate,
    $core.String? endDate,
    $core.String? state,
    $core.String? startedAt,
    $core.String? completedAt,
    $core.double? baselinePoints,
    $core.int? baselineTasks,
    $core.double? completedPoints,
    $core.int? completedTasks,
    $core.int? unfinishedTasks,
    $core.int? version,
    $core.int? taskCount,
    $core.double? pointsTotal,
    $core.int? openTasks,
    $core.double? openPoints,
    $core.int? doneTasks,
    $core.double? donePoints,
    $core.int? estimateSecTotal,
  }) {
    final result = Sprint._();
    if (id != null) result.id = id;
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (projectId != null) result.projectId = projectId;
    if (name != null) result.name = name;
    if (goal != null) result.goal = goal;
    if (startDate != null) result.startDate = startDate;
    if (endDate != null) result.endDate = endDate;
    if (state != null) result.state = state;
    if (startedAt != null) result.startedAt = startedAt;
    if (completedAt != null) result.completedAt = completedAt;
    if (baselinePoints != null) result.baselinePoints = baselinePoints;
    if (baselineTasks != null) result.baselineTasks = baselineTasks;
    if (completedPoints != null) result.completedPoints = completedPoints;
    if (completedTasks != null) result.completedTasks = completedTasks;
    if (unfinishedTasks != null) result.unfinishedTasks = unfinishedTasks;
    if (version != null) result.version = version;
    if (taskCount != null) result.taskCount = taskCount;
    if (pointsTotal != null) result.pointsTotal = pointsTotal;
    if (openTasks != null) result.openTasks = openTasks;
    if (openPoints != null) result.openPoints = openPoints;
    if (doneTasks != null) result.doneTasks = doneTasks;
    if (donePoints != null) result.donePoints = donePoints;
    if (estimateSecTotal != null) result.estimateSecTotal = estimateSecTotal;
    return result;
  }

  Sprint._();

  factory Sprint.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Sprint()..mergeFromBuffer(data, registry);
  factory Sprint.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Sprint()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Sprint',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.sprints'),
      createEmptyInstance: Sprint.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(3, _omitFieldNames ? '' : 'projectId')
    ..aOS(4, _omitFieldNames ? '' : 'name')
    ..aOS(5, _omitFieldNames ? '' : 'goal')
    ..aOS(6, _omitFieldNames ? '' : 'startDate')
    ..aOS(7, _omitFieldNames ? '' : 'endDate')
    ..aOS(8, _omitFieldNames ? '' : 'state')
    ..aOS(9, _omitFieldNames ? '' : 'startedAt')
    ..aOS(10, _omitFieldNames ? '' : 'completedAt')
    ..aD(11, _omitFieldNames ? '' : 'baselinePoints')
    ..aI(12, _omitFieldNames ? '' : 'baselineTasks')
    ..aD(13, _omitFieldNames ? '' : 'completedPoints')
    ..aI(14, _omitFieldNames ? '' : 'completedTasks')
    ..aI(15, _omitFieldNames ? '' : 'unfinishedTasks')
    ..aI(16, _omitFieldNames ? '' : 'version')
    ..aI(17, _omitFieldNames ? '' : 'taskCount')
    ..aD(18, _omitFieldNames ? '' : 'pointsTotal')
    ..aI(19, _omitFieldNames ? '' : 'openTasks')
    ..aD(20, _omitFieldNames ? '' : 'openPoints')
    ..aI(21, _omitFieldNames ? '' : 'doneTasks')
    ..aD(22, _omitFieldNames ? '' : 'donePoints')
    ..aI(23, _omitFieldNames ? '' : 'estimateSecTotal')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Sprint clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Sprint copyWith(void Function(Sprint) updates) =>
      super.copyWith((message) => updates(message as Sprint)) as Sprint;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Sprint() / Sprint.new instead')
  static Sprint create() => Sprint._();
  static $pb.GeneratedMessage $_createMessage() => Sprint._();
  @$core.override
  Sprint createEmptyInstance() => Sprint._();
  @$core.pragma('dart2js:noInline')
  static Sprint getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Sprint>(Sprint.$_createMessage);
  static Sprint? _defaultInstance;

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
  $core.String get name => $_getSZ(3);
  @$pb.TagNumber(4)
  set name($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasName() => $_has(3);
  @$pb.TagNumber(4)
  void clearName() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get goal => $_getSZ(4);
  @$pb.TagNumber(5)
  set goal($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasGoal() => $_has(4);
  @$pb.TagNumber(5)
  void clearGoal() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get startDate => $_getSZ(5);
  @$pb.TagNumber(6)
  set startDate($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasStartDate() => $_has(5);
  @$pb.TagNumber(6)
  void clearStartDate() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get endDate => $_getSZ(6);
  @$pb.TagNumber(7)
  set endDate($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasEndDate() => $_has(6);
  @$pb.TagNumber(7)
  void clearEndDate() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get state => $_getSZ(7);
  @$pb.TagNumber(8)
  set state($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasState() => $_has(7);
  @$pb.TagNumber(8)
  void clearState() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get startedAt => $_getSZ(8);
  @$pb.TagNumber(9)
  set startedAt($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasStartedAt() => $_has(8);
  @$pb.TagNumber(9)
  void clearStartedAt() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get completedAt => $_getSZ(9);
  @$pb.TagNumber(10)
  set completedAt($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasCompletedAt() => $_has(9);
  @$pb.TagNumber(10)
  void clearCompletedAt() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.double get baselinePoints => $_getN(10);
  @$pb.TagNumber(11)
  set baselinePoints($core.double value) => $_setDouble(10, value);
  @$pb.TagNumber(11)
  $core.bool hasBaselinePoints() => $_has(10);
  @$pb.TagNumber(11)
  void clearBaselinePoints() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.int get baselineTasks => $_getIZ(11);
  @$pb.TagNumber(12)
  set baselineTasks($core.int value) => $_setSignedInt32(11, value);
  @$pb.TagNumber(12)
  $core.bool hasBaselineTasks() => $_has(11);
  @$pb.TagNumber(12)
  void clearBaselineTasks() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.double get completedPoints => $_getN(12);
  @$pb.TagNumber(13)
  set completedPoints($core.double value) => $_setDouble(12, value);
  @$pb.TagNumber(13)
  $core.bool hasCompletedPoints() => $_has(12);
  @$pb.TagNumber(13)
  void clearCompletedPoints() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.int get completedTasks => $_getIZ(13);
  @$pb.TagNumber(14)
  set completedTasks($core.int value) => $_setSignedInt32(13, value);
  @$pb.TagNumber(14)
  $core.bool hasCompletedTasks() => $_has(13);
  @$pb.TagNumber(14)
  void clearCompletedTasks() => $_clearField(14);

  @$pb.TagNumber(15)
  $core.int get unfinishedTasks => $_getIZ(14);
  @$pb.TagNumber(15)
  set unfinishedTasks($core.int value) => $_setSignedInt32(14, value);
  @$pb.TagNumber(15)
  $core.bool hasUnfinishedTasks() => $_has(14);
  @$pb.TagNumber(15)
  void clearUnfinishedTasks() => $_clearField(15);

  @$pb.TagNumber(16)
  $core.int get version => $_getIZ(15);
  @$pb.TagNumber(16)
  set version($core.int value) => $_setSignedInt32(15, value);
  @$pb.TagNumber(16)
  $core.bool hasVersion() => $_has(15);
  @$pb.TagNumber(16)
  void clearVersion() => $_clearField(16);

  @$pb.TagNumber(17)
  $core.int get taskCount => $_getIZ(16);
  @$pb.TagNumber(17)
  set taskCount($core.int value) => $_setSignedInt32(16, value);
  @$pb.TagNumber(17)
  $core.bool hasTaskCount() => $_has(16);
  @$pb.TagNumber(17)
  void clearTaskCount() => $_clearField(17);

  @$pb.TagNumber(18)
  $core.double get pointsTotal => $_getN(17);
  @$pb.TagNumber(18)
  set pointsTotal($core.double value) => $_setDouble(17, value);
  @$pb.TagNumber(18)
  $core.bool hasPointsTotal() => $_has(17);
  @$pb.TagNumber(18)
  void clearPointsTotal() => $_clearField(18);

  @$pb.TagNumber(19)
  $core.int get openTasks => $_getIZ(18);
  @$pb.TagNumber(19)
  set openTasks($core.int value) => $_setSignedInt32(18, value);
  @$pb.TagNumber(19)
  $core.bool hasOpenTasks() => $_has(18);
  @$pb.TagNumber(19)
  void clearOpenTasks() => $_clearField(19);

  @$pb.TagNumber(20)
  $core.double get openPoints => $_getN(19);
  @$pb.TagNumber(20)
  set openPoints($core.double value) => $_setDouble(19, value);
  @$pb.TagNumber(20)
  $core.bool hasOpenPoints() => $_has(19);
  @$pb.TagNumber(20)
  void clearOpenPoints() => $_clearField(20);

  @$pb.TagNumber(21)
  $core.int get doneTasks => $_getIZ(20);
  @$pb.TagNumber(21)
  set doneTasks($core.int value) => $_setSignedInt32(20, value);
  @$pb.TagNumber(21)
  $core.bool hasDoneTasks() => $_has(20);
  @$pb.TagNumber(21)
  void clearDoneTasks() => $_clearField(21);

  @$pb.TagNumber(22)
  $core.double get donePoints => $_getN(21);
  @$pb.TagNumber(22)
  set donePoints($core.double value) => $_setDouble(21, value);
  @$pb.TagNumber(22)
  $core.bool hasDonePoints() => $_has(21);
  @$pb.TagNumber(22)
  void clearDonePoints() => $_clearField(22);

  @$pb.TagNumber(23)
  $core.int get estimateSecTotal => $_getIZ(22);
  @$pb.TagNumber(23)
  set estimateSecTotal($core.int value) => $_setSignedInt32(22, value);
  @$pb.TagNumber(23)
  $core.bool hasEstimateSecTotal() => $_has(22);
  @$pb.TagNumber(23)
  void clearEstimateSecTotal() => $_clearField(23);
}

class SprintAnswer extends $pb.GeneratedMessage {
  factory SprintAnswer({
    Sprint? sprint,
    $core.Iterable<$core.String>? warnings,
  }) {
    final result = SprintAnswer._();
    if (sprint != null) result.sprint = sprint;
    if (warnings != null) result.warnings.addAll(warnings);
    return result;
  }

  SprintAnswer._();

  factory SprintAnswer.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SprintAnswer()..mergeFromBuffer(data, registry);
  factory SprintAnswer.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SprintAnswer()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SprintAnswer',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.sprints'),
      createEmptyInstance: SprintAnswer.$_createMessage)
    ..aOM<Sprint>(1, _omitFieldNames ? '' : 'sprint',
        subBuilder: Sprint.$_createMessage)
    ..pPS(2, _omitFieldNames ? '' : 'warnings')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SprintAnswer clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SprintAnswer copyWith(void Function(SprintAnswer) updates) =>
      super.copyWith((message) => updates(message as SprintAnswer))
          as SprintAnswer;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SprintAnswer() / SprintAnswer.new instead')
  static SprintAnswer create() => SprintAnswer._();
  static $pb.GeneratedMessage $_createMessage() => SprintAnswer._();
  @$core.override
  SprintAnswer createEmptyInstance() => SprintAnswer._();
  @$core.pragma('dart2js:noInline')
  static SprintAnswer getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SprintAnswer>(
          SprintAnswer.$_createMessage);
  static SprintAnswer? _defaultInstance;

  @$pb.TagNumber(1)
  Sprint get sprint => $_getN(0);
  @$pb.TagNumber(1)
  set sprint(Sprint value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSprint() => $_has(0);
  @$pb.TagNumber(1)
  void clearSprint() => $_clearField(1);
  @$pb.TagNumber(1)
  Sprint ensureSprint() => $_ensure(0);

  @$pb.TagNumber(2)
  $pb.PbList<$core.String> get warnings => $_getList(1);
}

class SprintCompleteRequest extends $pb.GeneratedMessage {
  factory SprintCompleteRequest({
    $core.String? workspaceId,
    $core.String? projectId,
    $core.String? sprintId,
    $core.String? carryOver,
    $core.String? nextSprintId,
  }) {
    final result = SprintCompleteRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (projectId != null) result.projectId = projectId;
    if (sprintId != null) result.sprintId = sprintId;
    if (carryOver != null) result.carryOver = carryOver;
    if (nextSprintId != null) result.nextSprintId = nextSprintId;
    return result;
  }

  SprintCompleteRequest._();

  factory SprintCompleteRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SprintCompleteRequest()..mergeFromBuffer(data, registry);
  factory SprintCompleteRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SprintCompleteRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SprintCompleteRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.sprints'),
      createEmptyInstance: SprintCompleteRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..aOS(3, _omitFieldNames ? '' : 'sprintId')
    ..aOS(4, _omitFieldNames ? '' : 'carryOver')
    ..aOS(5, _omitFieldNames ? '' : 'nextSprintId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SprintCompleteRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SprintCompleteRequest copyWith(
          void Function(SprintCompleteRequest) updates) =>
      super.copyWith((message) => updates(message as SprintCompleteRequest))
          as SprintCompleteRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use SprintCompleteRequest() / SprintCompleteRequest.new instead')
  static SprintCompleteRequest create() => SprintCompleteRequest._();
  static $pb.GeneratedMessage $_createMessage() => SprintCompleteRequest._();
  @$core.override
  SprintCompleteRequest createEmptyInstance() => SprintCompleteRequest._();
  @$core.pragma('dart2js:noInline')
  static SprintCompleteRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SprintCompleteRequest>(
          SprintCompleteRequest.$_createMessage);
  static SprintCompleteRequest? _defaultInstance;

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
  $core.String get sprintId => $_getSZ(2);
  @$pb.TagNumber(3)
  set sprintId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSprintId() => $_has(2);
  @$pb.TagNumber(3)
  void clearSprintId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get carryOver => $_getSZ(3);
  @$pb.TagNumber(4)
  set carryOver($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasCarryOver() => $_has(3);
  @$pb.TagNumber(4)
  void clearCarryOver() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get nextSprintId => $_getSZ(4);
  @$pb.TagNumber(5)
  set nextSprintId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasNextSprintId() => $_has(4);
  @$pb.TagNumber(5)
  void clearNextSprintId() => $_clearField(5);
}

class SprintCreateRequest extends $pb.GeneratedMessage {
  factory SprintCreateRequest({
    $core.String? workspaceId,
    $core.String? projectId,
    $core.String? name,
    $core.String? goal,
    $core.String? startDate,
    $core.String? endDate,
  }) {
    final result = SprintCreateRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (projectId != null) result.projectId = projectId;
    if (name != null) result.name = name;
    if (goal != null) result.goal = goal;
    if (startDate != null) result.startDate = startDate;
    if (endDate != null) result.endDate = endDate;
    return result;
  }

  SprintCreateRequest._();

  factory SprintCreateRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SprintCreateRequest()..mergeFromBuffer(data, registry);
  factory SprintCreateRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SprintCreateRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SprintCreateRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.sprints'),
      createEmptyInstance: SprintCreateRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..aOS(3, _omitFieldNames ? '' : 'name')
    ..aOS(4, _omitFieldNames ? '' : 'goal')
    ..aOS(5, _omitFieldNames ? '' : 'startDate')
    ..aOS(6, _omitFieldNames ? '' : 'endDate')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SprintCreateRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SprintCreateRequest copyWith(void Function(SprintCreateRequest) updates) =>
      super.copyWith((message) => updates(message as SprintCreateRequest))
          as SprintCreateRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core
      .Deprecated('Use SprintCreateRequest() / SprintCreateRequest.new instead')
  static SprintCreateRequest create() => SprintCreateRequest._();
  static $pb.GeneratedMessage $_createMessage() => SprintCreateRequest._();
  @$core.override
  SprintCreateRequest createEmptyInstance() => SprintCreateRequest._();
  @$core.pragma('dart2js:noInline')
  static SprintCreateRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SprintCreateRequest>(
          SprintCreateRequest.$_createMessage);
  static SprintCreateRequest? _defaultInstance;

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
  $core.String get goal => $_getSZ(3);
  @$pb.TagNumber(4)
  set goal($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasGoal() => $_has(3);
  @$pb.TagNumber(4)
  void clearGoal() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get startDate => $_getSZ(4);
  @$pb.TagNumber(5)
  set startDate($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasStartDate() => $_has(4);
  @$pb.TagNumber(5)
  void clearStartDate() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get endDate => $_getSZ(5);
  @$pb.TagNumber(6)
  set endDate($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasEndDate() => $_has(5);
  @$pb.TagNumber(6)
  void clearEndDate() => $_clearField(6);
}

class SprintList extends $pb.GeneratedMessage {
  factory SprintList({
    $core.Iterable<Sprint>? sprints,
  }) {
    final result = SprintList._();
    if (sprints != null) result.sprints.addAll(sprints);
    return result;
  }

  SprintList._();

  factory SprintList.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SprintList()..mergeFromBuffer(data, registry);
  factory SprintList.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SprintList()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SprintList',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.sprints'),
      createEmptyInstance: SprintList.$_createMessage)
    ..pPM<Sprint>(1, _omitFieldNames ? '' : 'sprints',
        subBuilder: Sprint.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SprintList clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SprintList copyWith(void Function(SprintList) updates) =>
      super.copyWith((message) => updates(message as SprintList)) as SprintList;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SprintList() / SprintList.new instead')
  static SprintList create() => SprintList._();
  static $pb.GeneratedMessage $_createMessage() => SprintList._();
  @$core.override
  SprintList createEmptyInstance() => SprintList._();
  @$core.pragma('dart2js:noInline')
  static SprintList getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SprintList>(SprintList.$_createMessage);
  static SprintList? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Sprint> get sprints => $_getList(0);
}

class SprintListRequest extends $pb.GeneratedMessage {
  factory SprintListRequest({
    $core.String? workspaceId,
    $core.String? projectId,
    $core.Iterable<$core.String>? states,
  }) {
    final result = SprintListRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (projectId != null) result.projectId = projectId;
    if (states != null) result.states.addAll(states);
    return result;
  }

  SprintListRequest._();

  factory SprintListRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SprintListRequest()..mergeFromBuffer(data, registry);
  factory SprintListRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SprintListRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SprintListRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.sprints'),
      createEmptyInstance: SprintListRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..pPS(3, _omitFieldNames ? '' : 'states')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SprintListRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SprintListRequest copyWith(void Function(SprintListRequest) updates) =>
      super.copyWith((message) => updates(message as SprintListRequest))
          as SprintListRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SprintListRequest() / SprintListRequest.new instead')
  static SprintListRequest create() => SprintListRequest._();
  static $pb.GeneratedMessage $_createMessage() => SprintListRequest._();
  @$core.override
  SprintListRequest createEmptyInstance() => SprintListRequest._();
  @$core.pragma('dart2js:noInline')
  static SprintListRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SprintListRequest>(
          SprintListRequest.$_createMessage);
  static SprintListRequest? _defaultInstance;

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
  $pb.PbList<$core.String> get states => $_getList(2);
}

class SprintStartRequest extends $pb.GeneratedMessage {
  factory SprintStartRequest({
    $core.String? workspaceId,
    $core.String? projectId,
    $core.String? sprintId,
  }) {
    final result = SprintStartRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (projectId != null) result.projectId = projectId;
    if (sprintId != null) result.sprintId = sprintId;
    return result;
  }

  SprintStartRequest._();

  factory SprintStartRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SprintStartRequest()..mergeFromBuffer(data, registry);
  factory SprintStartRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SprintStartRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SprintStartRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.sprints'),
      createEmptyInstance: SprintStartRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..aOS(3, _omitFieldNames ? '' : 'sprintId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SprintStartRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SprintStartRequest copyWith(void Function(SprintStartRequest) updates) =>
      super.copyWith((message) => updates(message as SprintStartRequest))
          as SprintStartRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SprintStartRequest() / SprintStartRequest.new instead')
  static SprintStartRequest create() => SprintStartRequest._();
  static $pb.GeneratedMessage $_createMessage() => SprintStartRequest._();
  @$core.override
  SprintStartRequest createEmptyInstance() => SprintStartRequest._();
  @$core.pragma('dart2js:noInline')
  static SprintStartRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SprintStartRequest>(
          SprintStartRequest.$_createMessage);
  static SprintStartRequest? _defaultInstance;

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
  $core.String get sprintId => $_getSZ(2);
  @$pb.TagNumber(3)
  set sprintId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSprintId() => $_has(2);
  @$pb.TagNumber(3)
  void clearSprintId() => $_clearField(3);
}

class SprintTask extends $pb.GeneratedMessage {
  factory SprintTask({
    $core.String? id,
    $core.String? projectId,
    $core.String? key,
    $core.String? title,
    $core.String? statusId,
    $core.String? statusName,
    $core.String? statusCategory,
    $core.String? priority,
    $core.double? points,
    $core.bool? hasPoints_10,
    $core.int? estimateSec,
    $core.String? sprintId,
    $core.int? version,
    $core.String? position,
    $core.bool? late,
  }) {
    final result = SprintTask._();
    if (id != null) result.id = id;
    if (projectId != null) result.projectId = projectId;
    if (key != null) result.key = key;
    if (title != null) result.title = title;
    if (statusId != null) result.statusId = statusId;
    if (statusName != null) result.statusName = statusName;
    if (statusCategory != null) result.statusCategory = statusCategory;
    if (priority != null) result.priority = priority;
    if (points != null) result.points = points;
    if (hasPoints_10 != null) result.hasPoints_10 = hasPoints_10;
    if (estimateSec != null) result.estimateSec = estimateSec;
    if (sprintId != null) result.sprintId = sprintId;
    if (version != null) result.version = version;
    if (position != null) result.position = position;
    if (late != null) result.late = late;
    return result;
  }

  SprintTask._();

  factory SprintTask.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SprintTask()..mergeFromBuffer(data, registry);
  factory SprintTask.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SprintTask()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SprintTask',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.sprints'),
      createEmptyInstance: SprintTask.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..aOS(3, _omitFieldNames ? '' : 'key')
    ..aOS(4, _omitFieldNames ? '' : 'title')
    ..aOS(5, _omitFieldNames ? '' : 'statusId')
    ..aOS(6, _omitFieldNames ? '' : 'statusName')
    ..aOS(7, _omitFieldNames ? '' : 'statusCategory')
    ..aOS(8, _omitFieldNames ? '' : 'priority')
    ..aD(9, _omitFieldNames ? '' : 'points')
    ..aOB(10, _omitFieldNames ? '' : 'hasPoints')
    ..aI(11, _omitFieldNames ? '' : 'estimateSec')
    ..aOS(12, _omitFieldNames ? '' : 'sprintId')
    ..aI(13, _omitFieldNames ? '' : 'version')
    ..aOS(14, _omitFieldNames ? '' : 'position')
    ..aOB(15, _omitFieldNames ? '' : 'late')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SprintTask clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SprintTask copyWith(void Function(SprintTask) updates) =>
      super.copyWith((message) => updates(message as SprintTask)) as SprintTask;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SprintTask() / SprintTask.new instead')
  static SprintTask create() => SprintTask._();
  static $pb.GeneratedMessage $_createMessage() => SprintTask._();
  @$core.override
  SprintTask createEmptyInstance() => SprintTask._();
  @$core.pragma('dart2js:noInline')
  static SprintTask getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SprintTask>(SprintTask.$_createMessage);
  static SprintTask? _defaultInstance;

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
  $core.String get key => $_getSZ(2);
  @$pb.TagNumber(3)
  set key($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasKey() => $_has(2);
  @$pb.TagNumber(3)
  void clearKey() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get title => $_getSZ(3);
  @$pb.TagNumber(4)
  set title($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasTitle() => $_has(3);
  @$pb.TagNumber(4)
  void clearTitle() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get statusId => $_getSZ(4);
  @$pb.TagNumber(5)
  set statusId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasStatusId() => $_has(4);
  @$pb.TagNumber(5)
  void clearStatusId() => $_clearField(5);

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
  $core.double get points => $_getN(8);
  @$pb.TagNumber(9)
  set points($core.double value) => $_setDouble(8, value);
  @$pb.TagNumber(9)
  $core.bool hasPoints() => $_has(8);
  @$pb.TagNumber(9)
  void clearPoints() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.bool get hasPoints_10 => $_getBF(9);
  @$pb.TagNumber(10)
  set hasPoints_10($core.bool value) => $_setBool(9, value);
  @$pb.TagNumber(10)
  $core.bool hasHasPoints_10() => $_has(9);
  @$pb.TagNumber(10)
  void clearHasPoints_10() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.int get estimateSec => $_getIZ(10);
  @$pb.TagNumber(11)
  set estimateSec($core.int value) => $_setSignedInt32(10, value);
  @$pb.TagNumber(11)
  $core.bool hasEstimateSec() => $_has(10);
  @$pb.TagNumber(11)
  void clearEstimateSec() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.String get sprintId => $_getSZ(11);
  @$pb.TagNumber(12)
  set sprintId($core.String value) => $_setString(11, value);
  @$pb.TagNumber(12)
  $core.bool hasSprintId() => $_has(11);
  @$pb.TagNumber(12)
  void clearSprintId() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.int get version => $_getIZ(12);
  @$pb.TagNumber(13)
  set version($core.int value) => $_setSignedInt32(12, value);
  @$pb.TagNumber(13)
  $core.bool hasVersion() => $_has(12);
  @$pb.TagNumber(13)
  void clearVersion() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.String get position => $_getSZ(13);
  @$pb.TagNumber(14)
  set position($core.String value) => $_setString(13, value);
  @$pb.TagNumber(14)
  $core.bool hasPosition() => $_has(13);
  @$pb.TagNumber(14)
  void clearPosition() => $_clearField(14);

  @$pb.TagNumber(15)
  $core.bool get late => $_getBF(14);
  @$pb.TagNumber(15)
  set late($core.bool value) => $_setBool(14, value);
  @$pb.TagNumber(15)
  $core.bool hasLate() => $_has(14);
  @$pb.TagNumber(15)
  void clearLate() => $_clearField(15);
}

class SprintTaskList extends $pb.GeneratedMessage {
  factory SprintTaskList({
    $core.Iterable<SprintTask>? tasks,
  }) {
    final result = SprintTaskList._();
    if (tasks != null) result.tasks.addAll(tasks);
    return result;
  }

  SprintTaskList._();

  factory SprintTaskList.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SprintTaskList()..mergeFromBuffer(data, registry);
  factory SprintTaskList.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SprintTaskList()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SprintTaskList',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.sprints'),
      createEmptyInstance: SprintTaskList.$_createMessage)
    ..pPM<SprintTask>(1, _omitFieldNames ? '' : 'tasks',
        subBuilder: SprintTask.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SprintTaskList clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SprintTaskList copyWith(void Function(SprintTaskList) updates) =>
      super.copyWith((message) => updates(message as SprintTaskList))
          as SprintTaskList;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SprintTaskList() / SprintTaskList.new instead')
  static SprintTaskList create() => SprintTaskList._();
  static $pb.GeneratedMessage $_createMessage() => SprintTaskList._();
  @$core.override
  SprintTaskList createEmptyInstance() => SprintTaskList._();
  @$core.pragma('dart2js:noInline')
  static SprintTaskList getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SprintTaskList>(
          SprintTaskList.$_createMessage);
  static SprintTaskList? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<SprintTask> get tasks => $_getList(0);
}

class SprintTasksChangeRequest extends $pb.GeneratedMessage {
  factory SprintTasksChangeRequest({
    $core.String? workspaceId,
    $core.String? projectId,
    $core.String? sprintId,
    $core.Iterable<$core.String>? taskIds,
  }) {
    final result = SprintTasksChangeRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (projectId != null) result.projectId = projectId;
    if (sprintId != null) result.sprintId = sprintId;
    if (taskIds != null) result.taskIds.addAll(taskIds);
    return result;
  }

  SprintTasksChangeRequest._();

  factory SprintTasksChangeRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SprintTasksChangeRequest()..mergeFromBuffer(data, registry);
  factory SprintTasksChangeRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SprintTasksChangeRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SprintTasksChangeRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.sprints'),
      createEmptyInstance: SprintTasksChangeRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..aOS(3, _omitFieldNames ? '' : 'sprintId')
    ..pPS(4, _omitFieldNames ? '' : 'taskIds')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SprintTasksChangeRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SprintTasksChangeRequest copyWith(
          void Function(SprintTasksChangeRequest) updates) =>
      super.copyWith((message) => updates(message as SprintTasksChangeRequest))
          as SprintTasksChangeRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use SprintTasksChangeRequest() / SprintTasksChangeRequest.new instead')
  static SprintTasksChangeRequest create() => SprintTasksChangeRequest._();
  static $pb.GeneratedMessage $_createMessage() => SprintTasksChangeRequest._();
  @$core.override
  SprintTasksChangeRequest createEmptyInstance() =>
      SprintTasksChangeRequest._();
  @$core.pragma('dart2js:noInline')
  static SprintTasksChangeRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SprintTasksChangeRequest>(
          SprintTasksChangeRequest.$_createMessage);
  static SprintTasksChangeRequest? _defaultInstance;

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
  $core.String get sprintId => $_getSZ(2);
  @$pb.TagNumber(3)
  set sprintId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSprintId() => $_has(2);
  @$pb.TagNumber(3)
  void clearSprintId() => $_clearField(3);

  @$pb.TagNumber(4)
  $pb.PbList<$core.String> get taskIds => $_getList(3);
}

class SprintTasksChanged extends $pb.GeneratedMessage {
  factory SprintTasksChanged({
    Sprint? sprint,
    $core.int? changed,
    $core.int? addedAfterStart,
  }) {
    final result = SprintTasksChanged._();
    if (sprint != null) result.sprint = sprint;
    if (changed != null) result.changed = changed;
    if (addedAfterStart != null) result.addedAfterStart = addedAfterStart;
    return result;
  }

  SprintTasksChanged._();

  factory SprintTasksChanged.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SprintTasksChanged()..mergeFromBuffer(data, registry);
  factory SprintTasksChanged.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SprintTasksChanged()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SprintTasksChanged',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.sprints'),
      createEmptyInstance: SprintTasksChanged.$_createMessage)
    ..aOM<Sprint>(1, _omitFieldNames ? '' : 'sprint',
        subBuilder: Sprint.$_createMessage)
    ..aI(2, _omitFieldNames ? '' : 'changed')
    ..aI(3, _omitFieldNames ? '' : 'addedAfterStart')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SprintTasksChanged clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SprintTasksChanged copyWith(void Function(SprintTasksChanged) updates) =>
      super.copyWith((message) => updates(message as SprintTasksChanged))
          as SprintTasksChanged;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SprintTasksChanged() / SprintTasksChanged.new instead')
  static SprintTasksChanged create() => SprintTasksChanged._();
  static $pb.GeneratedMessage $_createMessage() => SprintTasksChanged._();
  @$core.override
  SprintTasksChanged createEmptyInstance() => SprintTasksChanged._();
  @$core.pragma('dart2js:noInline')
  static SprintTasksChanged getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SprintTasksChanged>(
          SprintTasksChanged.$_createMessage);
  static SprintTasksChanged? _defaultInstance;

  @$pb.TagNumber(1)
  Sprint get sprint => $_getN(0);
  @$pb.TagNumber(1)
  set sprint(Sprint value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSprint() => $_has(0);
  @$pb.TagNumber(1)
  void clearSprint() => $_clearField(1);
  @$pb.TagNumber(1)
  Sprint ensureSprint() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.int get changed => $_getIZ(1);
  @$pb.TagNumber(2)
  set changed($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasChanged() => $_has(1);
  @$pb.TagNumber(2)
  void clearChanged() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get addedAfterStart => $_getIZ(2);
  @$pb.TagNumber(3)
  set addedAfterStart($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAddedAfterStart() => $_has(2);
  @$pb.TagNumber(3)
  void clearAddedAfterStart() => $_clearField(3);
}

class SprintTasksRequest extends $pb.GeneratedMessage {
  factory SprintTasksRequest({
    $core.String? workspaceId,
    $core.String? projectId,
    $core.String? sprintId,
  }) {
    final result = SprintTasksRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (projectId != null) result.projectId = projectId;
    if (sprintId != null) result.sprintId = sprintId;
    return result;
  }

  SprintTasksRequest._();

  factory SprintTasksRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SprintTasksRequest()..mergeFromBuffer(data, registry);
  factory SprintTasksRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SprintTasksRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SprintTasksRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.sprints'),
      createEmptyInstance: SprintTasksRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..aOS(3, _omitFieldNames ? '' : 'sprintId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SprintTasksRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SprintTasksRequest copyWith(void Function(SprintTasksRequest) updates) =>
      super.copyWith((message) => updates(message as SprintTasksRequest))
          as SprintTasksRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SprintTasksRequest() / SprintTasksRequest.new instead')
  static SprintTasksRequest create() => SprintTasksRequest._();
  static $pb.GeneratedMessage $_createMessage() => SprintTasksRequest._();
  @$core.override
  SprintTasksRequest createEmptyInstance() => SprintTasksRequest._();
  @$core.pragma('dart2js:noInline')
  static SprintTasksRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SprintTasksRequest>(
          SprintTasksRequest.$_createMessage);
  static SprintTasksRequest? _defaultInstance;

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
  $core.String get sprintId => $_getSZ(2);
  @$pb.TagNumber(3)
  set sprintId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSprintId() => $_has(2);
  @$pb.TagNumber(3)
  void clearSprintId() => $_clearField(3);
}

class SprintUpdateRequest extends $pb.GeneratedMessage {
  factory SprintUpdateRequest({
    $core.String? workspaceId,
    $core.String? projectId,
    $core.String? sprintId,
    $core.Iterable<$core.String>? fields,
    $core.int? expectedVersion,
    $core.String? name,
    $core.String? goal,
    $core.String? startDate,
    $core.String? endDate,
  }) {
    final result = SprintUpdateRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (projectId != null) result.projectId = projectId;
    if (sprintId != null) result.sprintId = sprintId;
    if (fields != null) result.fields.addAll(fields);
    if (expectedVersion != null) result.expectedVersion = expectedVersion;
    if (name != null) result.name = name;
    if (goal != null) result.goal = goal;
    if (startDate != null) result.startDate = startDate;
    if (endDate != null) result.endDate = endDate;
    return result;
  }

  SprintUpdateRequest._();

  factory SprintUpdateRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SprintUpdateRequest()..mergeFromBuffer(data, registry);
  factory SprintUpdateRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SprintUpdateRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SprintUpdateRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.sprints'),
      createEmptyInstance: SprintUpdateRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..aOS(3, _omitFieldNames ? '' : 'sprintId')
    ..pPS(4, _omitFieldNames ? '' : 'fields')
    ..aI(5, _omitFieldNames ? '' : 'expectedVersion')
    ..aOS(6, _omitFieldNames ? '' : 'name')
    ..aOS(7, _omitFieldNames ? '' : 'goal')
    ..aOS(8, _omitFieldNames ? '' : 'startDate')
    ..aOS(9, _omitFieldNames ? '' : 'endDate')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SprintUpdateRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SprintUpdateRequest copyWith(void Function(SprintUpdateRequest) updates) =>
      super.copyWith((message) => updates(message as SprintUpdateRequest))
          as SprintUpdateRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core
      .Deprecated('Use SprintUpdateRequest() / SprintUpdateRequest.new instead')
  static SprintUpdateRequest create() => SprintUpdateRequest._();
  static $pb.GeneratedMessage $_createMessage() => SprintUpdateRequest._();
  @$core.override
  SprintUpdateRequest createEmptyInstance() => SprintUpdateRequest._();
  @$core.pragma('dart2js:noInline')
  static SprintUpdateRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SprintUpdateRequest>(
          SprintUpdateRequest.$_createMessage);
  static SprintUpdateRequest? _defaultInstance;

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
  $core.String get sprintId => $_getSZ(2);
  @$pb.TagNumber(3)
  set sprintId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSprintId() => $_has(2);
  @$pb.TagNumber(3)
  void clearSprintId() => $_clearField(3);

  @$pb.TagNumber(4)
  $pb.PbList<$core.String> get fields => $_getList(3);

  @$pb.TagNumber(5)
  $core.int get expectedVersion => $_getIZ(4);
  @$pb.TagNumber(5)
  set expectedVersion($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasExpectedVersion() => $_has(4);
  @$pb.TagNumber(5)
  void clearExpectedVersion() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get name => $_getSZ(5);
  @$pb.TagNumber(6)
  set name($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasName() => $_has(5);
  @$pb.TagNumber(6)
  void clearName() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get goal => $_getSZ(6);
  @$pb.TagNumber(7)
  set goal($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasGoal() => $_has(6);
  @$pb.TagNumber(7)
  void clearGoal() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get startDate => $_getSZ(7);
  @$pb.TagNumber(8)
  set startDate($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasStartDate() => $_has(7);
  @$pb.TagNumber(8)
  void clearStartDate() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get endDate => $_getSZ(8);
  @$pb.TagNumber(9)
  set endDate($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasEndDate() => $_has(8);
  @$pb.TagNumber(9)
  void clearEndDate() => $_clearField(9);
}

class VelocityItem extends $pb.GeneratedMessage {
  factory VelocityItem({
    $core.String? sprintId,
    $core.String? name,
    $core.String? startDate,
    $core.String? endDate,
    $core.double? committedPoints,
    $core.double? completedPoints,
    $core.int? committedTasks,
    $core.int? completedTasks,
  }) {
    final result = VelocityItem._();
    if (sprintId != null) result.sprintId = sprintId;
    if (name != null) result.name = name;
    if (startDate != null) result.startDate = startDate;
    if (endDate != null) result.endDate = endDate;
    if (committedPoints != null) result.committedPoints = committedPoints;
    if (completedPoints != null) result.completedPoints = completedPoints;
    if (committedTasks != null) result.committedTasks = committedTasks;
    if (completedTasks != null) result.completedTasks = completedTasks;
    return result;
  }

  VelocityItem._();

  factory VelocityItem.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      VelocityItem()..mergeFromBuffer(data, registry);
  factory VelocityItem.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      VelocityItem()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'VelocityItem',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.sprints'),
      createEmptyInstance: VelocityItem.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'sprintId')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOS(3, _omitFieldNames ? '' : 'startDate')
    ..aOS(4, _omitFieldNames ? '' : 'endDate')
    ..aD(5, _omitFieldNames ? '' : 'committedPoints')
    ..aD(6, _omitFieldNames ? '' : 'completedPoints')
    ..aI(7, _omitFieldNames ? '' : 'committedTasks')
    ..aI(8, _omitFieldNames ? '' : 'completedTasks')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  VelocityItem clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  VelocityItem copyWith(void Function(VelocityItem) updates) =>
      super.copyWith((message) => updates(message as VelocityItem))
          as VelocityItem;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use VelocityItem() / VelocityItem.new instead')
  static VelocityItem create() => VelocityItem._();
  static $pb.GeneratedMessage $_createMessage() => VelocityItem._();
  @$core.override
  VelocityItem createEmptyInstance() => VelocityItem._();
  @$core.pragma('dart2js:noInline')
  static VelocityItem getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<VelocityItem>(
          VelocityItem.$_createMessage);
  static VelocityItem? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get sprintId => $_getSZ(0);
  @$pb.TagNumber(1)
  set sprintId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSprintId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSprintId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get startDate => $_getSZ(2);
  @$pb.TagNumber(3)
  set startDate($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasStartDate() => $_has(2);
  @$pb.TagNumber(3)
  void clearStartDate() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get endDate => $_getSZ(3);
  @$pb.TagNumber(4)
  set endDate($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasEndDate() => $_has(3);
  @$pb.TagNumber(4)
  void clearEndDate() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.double get committedPoints => $_getN(4);
  @$pb.TagNumber(5)
  set committedPoints($core.double value) => $_setDouble(4, value);
  @$pb.TagNumber(5)
  $core.bool hasCommittedPoints() => $_has(4);
  @$pb.TagNumber(5)
  void clearCommittedPoints() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.double get completedPoints => $_getN(5);
  @$pb.TagNumber(6)
  set completedPoints($core.double value) => $_setDouble(5, value);
  @$pb.TagNumber(6)
  $core.bool hasCompletedPoints() => $_has(5);
  @$pb.TagNumber(6)
  void clearCompletedPoints() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.int get committedTasks => $_getIZ(6);
  @$pb.TagNumber(7)
  set committedTasks($core.int value) => $_setSignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasCommittedTasks() => $_has(6);
  @$pb.TagNumber(7)
  void clearCommittedTasks() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.int get completedTasks => $_getIZ(7);
  @$pb.TagNumber(8)
  set completedTasks($core.int value) => $_setSignedInt32(7, value);
  @$pb.TagNumber(8)
  $core.bool hasCompletedTasks() => $_has(7);
  @$pb.TagNumber(8)
  void clearCompletedTasks() => $_clearField(8);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
