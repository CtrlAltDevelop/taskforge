// This is a generated file - do not edit.
//
// Generated from infrastructure/workload/grpc/workload.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class AssigneeEstimateAnswer extends $pb.GeneratedMessage {
  factory AssigneeEstimateAnswer({
    $core.String? taskId,
  }) {
    final result = AssigneeEstimateAnswer._();
    if (taskId != null) result.taskId = taskId;
    return result;
  }

  AssigneeEstimateAnswer._();

  factory AssigneeEstimateAnswer.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AssigneeEstimateAnswer()..mergeFromBuffer(data, registry);
  factory AssigneeEstimateAnswer.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AssigneeEstimateAnswer()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AssigneeEstimateAnswer',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.workload'),
      createEmptyInstance: AssigneeEstimateAnswer.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'taskId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AssigneeEstimateAnswer clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AssigneeEstimateAnswer copyWith(
          void Function(AssigneeEstimateAnswer) updates) =>
      super.copyWith((message) => updates(message as AssigneeEstimateAnswer))
          as AssigneeEstimateAnswer;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use AssigneeEstimateAnswer() / AssigneeEstimateAnswer.new instead')
  static AssigneeEstimateAnswer create() => AssigneeEstimateAnswer._();
  static $pb.GeneratedMessage $_createMessage() => AssigneeEstimateAnswer._();
  @$core.override
  AssigneeEstimateAnswer createEmptyInstance() => AssigneeEstimateAnswer._();
  @$core.pragma('dart2js:noInline')
  static AssigneeEstimateAnswer getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AssigneeEstimateAnswer>(
          AssigneeEstimateAnswer.$_createMessage);
  static AssigneeEstimateAnswer? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get taskId => $_getSZ(0);
  @$pb.TagNumber(1)
  set taskId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTaskId() => $_has(0);
  @$pb.TagNumber(1)
  void clearTaskId() => $_clearField(1);
}

class AssigneeEstimateRequest extends $pb.GeneratedMessage {
  factory AssigneeEstimateRequest({
    $core.String? workspaceId,
    $core.String? taskId,
    $core.String? userId,
    $core.int? estimateSec,
  }) {
    final result = AssigneeEstimateRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (taskId != null) result.taskId = taskId;
    if (userId != null) result.userId = userId;
    if (estimateSec != null) result.estimateSec = estimateSec;
    return result;
  }

  AssigneeEstimateRequest._();

  factory AssigneeEstimateRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AssigneeEstimateRequest()..mergeFromBuffer(data, registry);
  factory AssigneeEstimateRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AssigneeEstimateRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AssigneeEstimateRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.workload'),
      createEmptyInstance: AssigneeEstimateRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'taskId')
    ..aOS(3, _omitFieldNames ? '' : 'userId')
    ..aI(4, _omitFieldNames ? '' : 'estimateSec')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AssigneeEstimateRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AssigneeEstimateRequest copyWith(
          void Function(AssigneeEstimateRequest) updates) =>
      super.copyWith((message) => updates(message as AssigneeEstimateRequest))
          as AssigneeEstimateRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use AssigneeEstimateRequest() / AssigneeEstimateRequest.new instead')
  static AssigneeEstimateRequest create() => AssigneeEstimateRequest._();
  static $pb.GeneratedMessage $_createMessage() => AssigneeEstimateRequest._();
  @$core.override
  AssigneeEstimateRequest createEmptyInstance() => AssigneeEstimateRequest._();
  @$core.pragma('dart2js:noInline')
  static AssigneeEstimateRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AssigneeEstimateRequest>(
          AssigneeEstimateRequest.$_createMessage);
  static AssigneeEstimateRequest? _defaultInstance;

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
  $core.String get userId => $_getSZ(2);
  @$pb.TagNumber(3)
  set userId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasUserId() => $_has(2);
  @$pb.TagNumber(3)
  void clearUserId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get estimateSec => $_getIZ(3);
  @$pb.TagNumber(4)
  set estimateSec($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasEstimateSec() => $_has(3);
  @$pb.TagNumber(4)
  void clearEstimateSec() => $_clearField(4);
}

class AssigneeSeconds extends $pb.GeneratedMessage {
  factory AssigneeSeconds({
    $core.String? userId,
    $core.int? seconds,
  }) {
    final result = AssigneeSeconds._();
    if (userId != null) result.userId = userId;
    if (seconds != null) result.seconds = seconds;
    return result;
  }

  AssigneeSeconds._();

  factory AssigneeSeconds.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AssigneeSeconds()..mergeFromBuffer(data, registry);
  factory AssigneeSeconds.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AssigneeSeconds()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AssigneeSeconds',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.workload'),
      createEmptyInstance: AssigneeSeconds.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'userId')
    ..aI(2, _omitFieldNames ? '' : 'seconds')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AssigneeSeconds clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AssigneeSeconds copyWith(void Function(AssigneeSeconds) updates) =>
      super.copyWith((message) => updates(message as AssigneeSeconds))
          as AssigneeSeconds;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use AssigneeSeconds() / AssigneeSeconds.new instead')
  static AssigneeSeconds create() => AssigneeSeconds._();
  static $pb.GeneratedMessage $_createMessage() => AssigneeSeconds._();
  @$core.override
  AssigneeSeconds createEmptyInstance() => AssigneeSeconds._();
  @$core.pragma('dart2js:noInline')
  static AssigneeSeconds getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AssigneeSeconds>(
          AssigneeSeconds.$_createMessage);
  static AssigneeSeconds? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get userId => $_getSZ(0);
  @$pb.TagNumber(1)
  set userId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get seconds => $_getIZ(1);
  @$pb.TagNumber(2)
  set seconds($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSeconds() => $_has(1);
  @$pb.TagNumber(2)
  void clearSeconds() => $_clearField(2);
}

class Capacity extends $pb.GeneratedMessage {
  factory Capacity({
    $core.String? userId,
    $core.String? hoursPerDay,
    $core.Iterable<$core.int>? workingDays,
    $core.bool? isSet,
  }) {
    final result = Capacity._();
    if (userId != null) result.userId = userId;
    if (hoursPerDay != null) result.hoursPerDay = hoursPerDay;
    if (workingDays != null) result.workingDays.addAll(workingDays);
    if (isSet != null) result.isSet = isSet;
    return result;
  }

  Capacity._();

  factory Capacity.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Capacity()..mergeFromBuffer(data, registry);
  factory Capacity.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Capacity()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Capacity',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.workload'),
      createEmptyInstance: Capacity.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'userId')
    ..aOS(2, _omitFieldNames ? '' : 'hoursPerDay')
    ..p<$core.int>(3, _omitFieldNames ? '' : 'workingDays', $pb.PbFieldType.K3)
    ..aOB(4, _omitFieldNames ? '' : 'isSet')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Capacity clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Capacity copyWith(void Function(Capacity) updates) =>
      super.copyWith((message) => updates(message as Capacity)) as Capacity;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Capacity() / Capacity.new instead')
  static Capacity create() => Capacity._();
  static $pb.GeneratedMessage $_createMessage() => Capacity._();
  @$core.override
  Capacity createEmptyInstance() => Capacity._();
  @$core.pragma('dart2js:noInline')
  static Capacity getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Capacity>(Capacity.$_createMessage);
  static Capacity? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get userId => $_getSZ(0);
  @$pb.TagNumber(1)
  set userId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get hoursPerDay => $_getSZ(1);
  @$pb.TagNumber(2)
  set hoursPerDay($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasHoursPerDay() => $_has(1);
  @$pb.TagNumber(2)
  void clearHoursPerDay() => $_clearField(2);

  @$pb.TagNumber(3)
  $pb.PbList<$core.int> get workingDays => $_getList(2);

  @$pb.TagNumber(4)
  $core.bool get isSet => $_getBF(3);
  @$pb.TagNumber(4)
  set isSet($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasIsSet() => $_has(3);
  @$pb.TagNumber(4)
  void clearIsSet() => $_clearField(4);
}

class CapacityAnswer extends $pb.GeneratedMessage {
  factory CapacityAnswer({
    Capacity? capacity,
  }) {
    final result = CapacityAnswer._();
    if (capacity != null) result.capacity = capacity;
    return result;
  }

  CapacityAnswer._();

  factory CapacityAnswer.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CapacityAnswer()..mergeFromBuffer(data, registry);
  factory CapacityAnswer.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CapacityAnswer()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CapacityAnswer',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.workload'),
      createEmptyInstance: CapacityAnswer.$_createMessage)
    ..aOM<Capacity>(1, _omitFieldNames ? '' : 'capacity',
        subBuilder: Capacity.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CapacityAnswer clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CapacityAnswer copyWith(void Function(CapacityAnswer) updates) =>
      super.copyWith((message) => updates(message as CapacityAnswer))
          as CapacityAnswer;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CapacityAnswer() / CapacityAnswer.new instead')
  static CapacityAnswer create() => CapacityAnswer._();
  static $pb.GeneratedMessage $_createMessage() => CapacityAnswer._();
  @$core.override
  CapacityAnswer createEmptyInstance() => CapacityAnswer._();
  @$core.pragma('dart2js:noInline')
  static CapacityAnswer getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CapacityAnswer>(
          CapacityAnswer.$_createMessage);
  static CapacityAnswer? _defaultInstance;

  @$pb.TagNumber(1)
  Capacity get capacity => $_getN(0);
  @$pb.TagNumber(1)
  set capacity(Capacity value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasCapacity() => $_has(0);
  @$pb.TagNumber(1)
  void clearCapacity() => $_clearField(1);
  @$pb.TagNumber(1)
  Capacity ensureCapacity() => $_ensure(0);
}

class CapacityGetRequest extends $pb.GeneratedMessage {
  factory CapacityGetRequest({
    $core.String? workspaceId,
    $core.String? userId,
  }) {
    final result = CapacityGetRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (userId != null) result.userId = userId;
    return result;
  }

  CapacityGetRequest._();

  factory CapacityGetRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CapacityGetRequest()..mergeFromBuffer(data, registry);
  factory CapacityGetRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CapacityGetRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CapacityGetRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.workload'),
      createEmptyInstance: CapacityGetRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'userId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CapacityGetRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CapacityGetRequest copyWith(void Function(CapacityGetRequest) updates) =>
      super.copyWith((message) => updates(message as CapacityGetRequest))
          as CapacityGetRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CapacityGetRequest() / CapacityGetRequest.new instead')
  static CapacityGetRequest create() => CapacityGetRequest._();
  static $pb.GeneratedMessage $_createMessage() => CapacityGetRequest._();
  @$core.override
  CapacityGetRequest createEmptyInstance() => CapacityGetRequest._();
  @$core.pragma('dart2js:noInline')
  static CapacityGetRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CapacityGetRequest>(
          CapacityGetRequest.$_createMessage);
  static CapacityGetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get userId => $_getSZ(1);
  @$pb.TagNumber(2)
  set userId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUserId() => $_has(1);
  @$pb.TagNumber(2)
  void clearUserId() => $_clearField(2);
}

class CapacityList extends $pb.GeneratedMessage {
  factory CapacityList({
    $core.Iterable<Capacity>? capacities,
  }) {
    final result = CapacityList._();
    if (capacities != null) result.capacities.addAll(capacities);
    return result;
  }

  CapacityList._();

  factory CapacityList.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CapacityList()..mergeFromBuffer(data, registry);
  factory CapacityList.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CapacityList()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CapacityList',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.workload'),
      createEmptyInstance: CapacityList.$_createMessage)
    ..pPM<Capacity>(1, _omitFieldNames ? '' : 'capacities',
        subBuilder: Capacity.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CapacityList clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CapacityList copyWith(void Function(CapacityList) updates) =>
      super.copyWith((message) => updates(message as CapacityList))
          as CapacityList;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CapacityList() / CapacityList.new instead')
  static CapacityList create() => CapacityList._();
  static $pb.GeneratedMessage $_createMessage() => CapacityList._();
  @$core.override
  CapacityList createEmptyInstance() => CapacityList._();
  @$core.pragma('dart2js:noInline')
  static CapacityList getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CapacityList>(
          CapacityList.$_createMessage);
  static CapacityList? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Capacity> get capacities => $_getList(0);
}

class CapacitySetRequest extends $pb.GeneratedMessage {
  factory CapacitySetRequest({
    $core.String? workspaceId,
    $core.String? userId,
    $core.String? hoursPerDay,
    $core.Iterable<$core.int>? workingDays,
  }) {
    final result = CapacitySetRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (userId != null) result.userId = userId;
    if (hoursPerDay != null) result.hoursPerDay = hoursPerDay;
    if (workingDays != null) result.workingDays.addAll(workingDays);
    return result;
  }

  CapacitySetRequest._();

  factory CapacitySetRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CapacitySetRequest()..mergeFromBuffer(data, registry);
  factory CapacitySetRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CapacitySetRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CapacitySetRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.workload'),
      createEmptyInstance: CapacitySetRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'userId')
    ..aOS(3, _omitFieldNames ? '' : 'hoursPerDay')
    ..p<$core.int>(4, _omitFieldNames ? '' : 'workingDays', $pb.PbFieldType.K3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CapacitySetRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CapacitySetRequest copyWith(void Function(CapacitySetRequest) updates) =>
      super.copyWith((message) => updates(message as CapacitySetRequest))
          as CapacitySetRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CapacitySetRequest() / CapacitySetRequest.new instead')
  static CapacitySetRequest create() => CapacitySetRequest._();
  static $pb.GeneratedMessage $_createMessage() => CapacitySetRequest._();
  @$core.override
  CapacitySetRequest createEmptyInstance() => CapacitySetRequest._();
  @$core.pragma('dart2js:noInline')
  static CapacitySetRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CapacitySetRequest>(
          CapacitySetRequest.$_createMessage);
  static CapacitySetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get userId => $_getSZ(1);
  @$pb.TagNumber(2)
  set userId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUserId() => $_has(1);
  @$pb.TagNumber(2)
  void clearUserId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get hoursPerDay => $_getSZ(2);
  @$pb.TagNumber(3)
  set hoursPerDay($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasHoursPerDay() => $_has(2);
  @$pb.TagNumber(3)
  void clearHoursPerDay() => $_clearField(3);

  @$pb.TagNumber(4)
  $pb.PbList<$core.int> get workingDays => $_getList(3);
}

class Contribution extends $pb.GeneratedMessage {
  factory Contribution({
    $core.String? taskId,
    $core.int? seconds,
    $core.bool? warning,
  }) {
    final result = Contribution._();
    if (taskId != null) result.taskId = taskId;
    if (seconds != null) result.seconds = seconds;
    if (warning != null) result.warning = warning;
    return result;
  }

  Contribution._();

  factory Contribution.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Contribution()..mergeFromBuffer(data, registry);
  factory Contribution.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Contribution()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Contribution',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.workload'),
      createEmptyInstance: Contribution.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'taskId')
    ..aI(2, _omitFieldNames ? '' : 'seconds')
    ..aOB(3, _omitFieldNames ? '' : 'warning')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Contribution clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Contribution copyWith(void Function(Contribution) updates) =>
      super.copyWith((message) => updates(message as Contribution))
          as Contribution;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Contribution() / Contribution.new instead')
  static Contribution create() => Contribution._();
  static $pb.GeneratedMessage $_createMessage() => Contribution._();
  @$core.override
  Contribution createEmptyInstance() => Contribution._();
  @$core.pragma('dart2js:noInline')
  static Contribution getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Contribution>(
          Contribution.$_createMessage);
  static Contribution? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get taskId => $_getSZ(0);
  @$pb.TagNumber(1)
  set taskId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTaskId() => $_has(0);
  @$pb.TagNumber(1)
  void clearTaskId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get seconds => $_getIZ(1);
  @$pb.TagNumber(2)
  set seconds($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSeconds() => $_has(1);
  @$pb.TagNumber(2)
  void clearSeconds() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get warning => $_getBF(2);
  @$pb.TagNumber(3)
  set warning($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasWarning() => $_has(2);
  @$pb.TagNumber(3)
  void clearWarning() => $_clearField(3);
}

class DayCell extends $pb.GeneratedMessage {
  factory DayCell({
    $core.String? date,
    $core.int? loadSec,
    $core.int? capacitySec,
    $core.bool? over,
    $core.Iterable<Contribution>? contributions,
  }) {
    final result = DayCell._();
    if (date != null) result.date = date;
    if (loadSec != null) result.loadSec = loadSec;
    if (capacitySec != null) result.capacitySec = capacitySec;
    if (over != null) result.over = over;
    if (contributions != null) result.contributions.addAll(contributions);
    return result;
  }

  DayCell._();

  factory DayCell.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DayCell()..mergeFromBuffer(data, registry);
  factory DayCell.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DayCell()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DayCell',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.workload'),
      createEmptyInstance: DayCell.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'date')
    ..aI(2, _omitFieldNames ? '' : 'loadSec')
    ..aI(3, _omitFieldNames ? '' : 'capacitySec')
    ..aOB(4, _omitFieldNames ? '' : 'over')
    ..pPM<Contribution>(5, _omitFieldNames ? '' : 'contributions',
        subBuilder: Contribution.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DayCell clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DayCell copyWith(void Function(DayCell) updates) =>
      super.copyWith((message) => updates(message as DayCell)) as DayCell;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use DayCell() / DayCell.new instead')
  static DayCell create() => DayCell._();
  static $pb.GeneratedMessage $_createMessage() => DayCell._();
  @$core.override
  DayCell createEmptyInstance() => DayCell._();
  @$core.pragma('dart2js:noInline')
  static DayCell getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DayCell>(DayCell.$_createMessage);
  static DayCell? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get date => $_getSZ(0);
  @$pb.TagNumber(1)
  set date($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDate() => $_has(0);
  @$pb.TagNumber(1)
  void clearDate() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get loadSec => $_getIZ(1);
  @$pb.TagNumber(2)
  set loadSec($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasLoadSec() => $_has(1);
  @$pb.TagNumber(2)
  void clearLoadSec() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get capacitySec => $_getIZ(2);
  @$pb.TagNumber(3)
  set capacitySec($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasCapacitySec() => $_has(2);
  @$pb.TagNumber(3)
  void clearCapacitySec() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get over => $_getBF(3);
  @$pb.TagNumber(4)
  set over($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasOver() => $_has(3);
  @$pb.TagNumber(4)
  void clearOver() => $_clearField(4);

  @$pb.TagNumber(5)
  $pb.PbList<Contribution> get contributions => $_getList(4);
}

class Holiday extends $pb.GeneratedMessage {
  factory Holiday({
    $core.String? id,
    $core.String? date,
    $core.String? name,
  }) {
    final result = Holiday._();
    if (id != null) result.id = id;
    if (date != null) result.date = date;
    if (name != null) result.name = name;
    return result;
  }

  Holiday._();

  factory Holiday.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Holiday()..mergeFromBuffer(data, registry);
  factory Holiday.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Holiday()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Holiday',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.workload'),
      createEmptyInstance: Holiday.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'date')
    ..aOS(3, _omitFieldNames ? '' : 'name')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Holiday clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Holiday copyWith(void Function(Holiday) updates) =>
      super.copyWith((message) => updates(message as Holiday)) as Holiday;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Holiday() / Holiday.new instead')
  static Holiday create() => Holiday._();
  static $pb.GeneratedMessage $_createMessage() => Holiday._();
  @$core.override
  Holiday createEmptyInstance() => Holiday._();
  @$core.pragma('dart2js:noInline')
  static Holiday getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Holiday>(Holiday.$_createMessage);
  static Holiday? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get date => $_getSZ(1);
  @$pb.TagNumber(2)
  set date($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDate() => $_has(1);
  @$pb.TagNumber(2)
  void clearDate() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get name => $_getSZ(2);
  @$pb.TagNumber(3)
  set name($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasName() => $_has(2);
  @$pb.TagNumber(3)
  void clearName() => $_clearField(3);
}

class HolidayAnswer extends $pb.GeneratedMessage {
  factory HolidayAnswer({
    Holiday? holiday,
  }) {
    final result = HolidayAnswer._();
    if (holiday != null) result.holiday = holiday;
    return result;
  }

  HolidayAnswer._();

  factory HolidayAnswer.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      HolidayAnswer()..mergeFromBuffer(data, registry);
  factory HolidayAnswer.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      HolidayAnswer()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'HolidayAnswer',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.workload'),
      createEmptyInstance: HolidayAnswer.$_createMessage)
    ..aOM<Holiday>(1, _omitFieldNames ? '' : 'holiday',
        subBuilder: Holiday.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HolidayAnswer clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HolidayAnswer copyWith(void Function(HolidayAnswer) updates) =>
      super.copyWith((message) => updates(message as HolidayAnswer))
          as HolidayAnswer;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use HolidayAnswer() / HolidayAnswer.new instead')
  static HolidayAnswer create() => HolidayAnswer._();
  static $pb.GeneratedMessage $_createMessage() => HolidayAnswer._();
  @$core.override
  HolidayAnswer createEmptyInstance() => HolidayAnswer._();
  @$core.pragma('dart2js:noInline')
  static HolidayAnswer getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<HolidayAnswer>(
          HolidayAnswer.$_createMessage);
  static HolidayAnswer? _defaultInstance;

  @$pb.TagNumber(1)
  Holiday get holiday => $_getN(0);
  @$pb.TagNumber(1)
  set holiday(Holiday value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasHoliday() => $_has(0);
  @$pb.TagNumber(1)
  void clearHoliday() => $_clearField(1);
  @$pb.TagNumber(1)
  Holiday ensureHoliday() => $_ensure(0);
}

class HolidayCreateRequest extends $pb.GeneratedMessage {
  factory HolidayCreateRequest({
    $core.String? workspaceId,
    $core.String? date,
    $core.String? name,
  }) {
    final result = HolidayCreateRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (date != null) result.date = date;
    if (name != null) result.name = name;
    return result;
  }

  HolidayCreateRequest._();

  factory HolidayCreateRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      HolidayCreateRequest()..mergeFromBuffer(data, registry);
  factory HolidayCreateRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      HolidayCreateRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'HolidayCreateRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.workload'),
      createEmptyInstance: HolidayCreateRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'date')
    ..aOS(3, _omitFieldNames ? '' : 'name')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HolidayCreateRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HolidayCreateRequest copyWith(void Function(HolidayCreateRequest) updates) =>
      super.copyWith((message) => updates(message as HolidayCreateRequest))
          as HolidayCreateRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use HolidayCreateRequest() / HolidayCreateRequest.new instead')
  static HolidayCreateRequest create() => HolidayCreateRequest._();
  static $pb.GeneratedMessage $_createMessage() => HolidayCreateRequest._();
  @$core.override
  HolidayCreateRequest createEmptyInstance() => HolidayCreateRequest._();
  @$core.pragma('dart2js:noInline')
  static HolidayCreateRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<HolidayCreateRequest>(
          HolidayCreateRequest.$_createMessage);
  static HolidayCreateRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get date => $_getSZ(1);
  @$pb.TagNumber(2)
  set date($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDate() => $_has(1);
  @$pb.TagNumber(2)
  void clearDate() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get name => $_getSZ(2);
  @$pb.TagNumber(3)
  set name($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasName() => $_has(2);
  @$pb.TagNumber(3)
  void clearName() => $_clearField(3);
}

class HolidayDeleteRequest extends $pb.GeneratedMessage {
  factory HolidayDeleteRequest({
    $core.String? workspaceId,
    $core.String? holidayId,
  }) {
    final result = HolidayDeleteRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (holidayId != null) result.holidayId = holidayId;
    return result;
  }

  HolidayDeleteRequest._();

  factory HolidayDeleteRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      HolidayDeleteRequest()..mergeFromBuffer(data, registry);
  factory HolidayDeleteRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      HolidayDeleteRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'HolidayDeleteRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.workload'),
      createEmptyInstance: HolidayDeleteRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'holidayId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HolidayDeleteRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HolidayDeleteRequest copyWith(void Function(HolidayDeleteRequest) updates) =>
      super.copyWith((message) => updates(message as HolidayDeleteRequest))
          as HolidayDeleteRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use HolidayDeleteRequest() / HolidayDeleteRequest.new instead')
  static HolidayDeleteRequest create() => HolidayDeleteRequest._();
  static $pb.GeneratedMessage $_createMessage() => HolidayDeleteRequest._();
  @$core.override
  HolidayDeleteRequest createEmptyInstance() => HolidayDeleteRequest._();
  @$core.pragma('dart2js:noInline')
  static HolidayDeleteRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<HolidayDeleteRequest>(
          HolidayDeleteRequest.$_createMessage);
  static HolidayDeleteRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get holidayId => $_getSZ(1);
  @$pb.TagNumber(2)
  set holidayId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasHolidayId() => $_has(1);
  @$pb.TagNumber(2)
  void clearHolidayId() => $_clearField(2);
}

class HolidayDeleted extends $pb.GeneratedMessage {
  factory HolidayDeleted({
    $core.String? id,
  }) {
    final result = HolidayDeleted._();
    if (id != null) result.id = id;
    return result;
  }

  HolidayDeleted._();

  factory HolidayDeleted.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      HolidayDeleted()..mergeFromBuffer(data, registry);
  factory HolidayDeleted.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      HolidayDeleted()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'HolidayDeleted',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.workload'),
      createEmptyInstance: HolidayDeleted.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HolidayDeleted clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HolidayDeleted copyWith(void Function(HolidayDeleted) updates) =>
      super.copyWith((message) => updates(message as HolidayDeleted))
          as HolidayDeleted;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use HolidayDeleted() / HolidayDeleted.new instead')
  static HolidayDeleted create() => HolidayDeleted._();
  static $pb.GeneratedMessage $_createMessage() => HolidayDeleted._();
  @$core.override
  HolidayDeleted createEmptyInstance() => HolidayDeleted._();
  @$core.pragma('dart2js:noInline')
  static HolidayDeleted getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<HolidayDeleted>(
          HolidayDeleted.$_createMessage);
  static HolidayDeleted? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class HolidayList extends $pb.GeneratedMessage {
  factory HolidayList({
    $core.Iterable<Holiday>? holidays,
  }) {
    final result = HolidayList._();
    if (holidays != null) result.holidays.addAll(holidays);
    return result;
  }

  HolidayList._();

  factory HolidayList.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      HolidayList()..mergeFromBuffer(data, registry);
  factory HolidayList.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      HolidayList()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'HolidayList',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.workload'),
      createEmptyInstance: HolidayList.$_createMessage)
    ..pPM<Holiday>(1, _omitFieldNames ? '' : 'holidays',
        subBuilder: Holiday.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HolidayList clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HolidayList copyWith(void Function(HolidayList) updates) =>
      super.copyWith((message) => updates(message as HolidayList))
          as HolidayList;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use HolidayList() / HolidayList.new instead')
  static HolidayList create() => HolidayList._();
  static $pb.GeneratedMessage $_createMessage() => HolidayList._();
  @$core.override
  HolidayList createEmptyInstance() => HolidayList._();
  @$core.pragma('dart2js:noInline')
  static HolidayList getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<HolidayList>(
          HolidayList.$_createMessage);
  static HolidayList? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Holiday> get holidays => $_getList(0);
}

class HolidayListRequest extends $pb.GeneratedMessage {
  factory HolidayListRequest({
    $core.String? workspaceId,
    $core.String? rangeStart,
    $core.String? rangeEnd,
  }) {
    final result = HolidayListRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (rangeStart != null) result.rangeStart = rangeStart;
    if (rangeEnd != null) result.rangeEnd = rangeEnd;
    return result;
  }

  HolidayListRequest._();

  factory HolidayListRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      HolidayListRequest()..mergeFromBuffer(data, registry);
  factory HolidayListRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      HolidayListRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'HolidayListRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.workload'),
      createEmptyInstance: HolidayListRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'rangeStart')
    ..aOS(3, _omitFieldNames ? '' : 'rangeEnd')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HolidayListRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HolidayListRequest copyWith(void Function(HolidayListRequest) updates) =>
      super.copyWith((message) => updates(message as HolidayListRequest))
          as HolidayListRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use HolidayListRequest() / HolidayListRequest.new instead')
  static HolidayListRequest create() => HolidayListRequest._();
  static $pb.GeneratedMessage $_createMessage() => HolidayListRequest._();
  @$core.override
  HolidayListRequest createEmptyInstance() => HolidayListRequest._();
  @$core.pragma('dart2js:noInline')
  static HolidayListRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<HolidayListRequest>(
          HolidayListRequest.$_createMessage);
  static HolidayListRequest? _defaultInstance;

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
}

class HolidayUpdateRequest extends $pb.GeneratedMessage {
  factory HolidayUpdateRequest({
    $core.String? workspaceId,
    $core.String? holidayId,
    $core.String? date,
    $core.String? name,
  }) {
    final result = HolidayUpdateRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (holidayId != null) result.holidayId = holidayId;
    if (date != null) result.date = date;
    if (name != null) result.name = name;
    return result;
  }

  HolidayUpdateRequest._();

  factory HolidayUpdateRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      HolidayUpdateRequest()..mergeFromBuffer(data, registry);
  factory HolidayUpdateRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      HolidayUpdateRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'HolidayUpdateRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.workload'),
      createEmptyInstance: HolidayUpdateRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'holidayId')
    ..aOS(3, _omitFieldNames ? '' : 'date')
    ..aOS(4, _omitFieldNames ? '' : 'name')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HolidayUpdateRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HolidayUpdateRequest copyWith(void Function(HolidayUpdateRequest) updates) =>
      super.copyWith((message) => updates(message as HolidayUpdateRequest))
          as HolidayUpdateRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use HolidayUpdateRequest() / HolidayUpdateRequest.new instead')
  static HolidayUpdateRequest create() => HolidayUpdateRequest._();
  static $pb.GeneratedMessage $_createMessage() => HolidayUpdateRequest._();
  @$core.override
  HolidayUpdateRequest createEmptyInstance() => HolidayUpdateRequest._();
  @$core.pragma('dart2js:noInline')
  static HolidayUpdateRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<HolidayUpdateRequest>(
          HolidayUpdateRequest.$_createMessage);
  static HolidayUpdateRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get holidayId => $_getSZ(1);
  @$pb.TagNumber(2)
  set holidayId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasHolidayId() => $_has(1);
  @$pb.TagNumber(2)
  void clearHolidayId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get date => $_getSZ(2);
  @$pb.TagNumber(3)
  set date($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDate() => $_has(2);
  @$pb.TagNumber(3)
  void clearDate() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get name => $_getSZ(3);
  @$pb.TagNumber(4)
  set name($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasName() => $_has(3);
  @$pb.TagNumber(4)
  void clearName() => $_clearField(4);
}

class LoadTask extends $pb.GeneratedMessage {
  factory LoadTask({
    $core.String? taskId,
    $core.String? projectId,
    $core.String? displayId,
    $core.String? title,
    $core.int? version,
    $core.String? startDate,
    $core.String? dueDate,
    $core.int? estimateSec,
    $core.Iterable<$core.String>? assigneeIds,
    $core.Iterable<AssigneeSeconds>? own,
    $core.String? reason,
  }) {
    final result = LoadTask._();
    if (taskId != null) result.taskId = taskId;
    if (projectId != null) result.projectId = projectId;
    if (displayId != null) result.displayId = displayId;
    if (title != null) result.title = title;
    if (version != null) result.version = version;
    if (startDate != null) result.startDate = startDate;
    if (dueDate != null) result.dueDate = dueDate;
    if (estimateSec != null) result.estimateSec = estimateSec;
    if (assigneeIds != null) result.assigneeIds.addAll(assigneeIds);
    if (own != null) result.own.addAll(own);
    if (reason != null) result.reason = reason;
    return result;
  }

  LoadTask._();

  factory LoadTask.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoadTask()..mergeFromBuffer(data, registry);
  factory LoadTask.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoadTask()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LoadTask',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.workload'),
      createEmptyInstance: LoadTask.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'taskId')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..aOS(3, _omitFieldNames ? '' : 'displayId')
    ..aOS(4, _omitFieldNames ? '' : 'title')
    ..aI(5, _omitFieldNames ? '' : 'version')
    ..aOS(6, _omitFieldNames ? '' : 'startDate')
    ..aOS(7, _omitFieldNames ? '' : 'dueDate')
    ..aI(8, _omitFieldNames ? '' : 'estimateSec')
    ..pPS(9, _omitFieldNames ? '' : 'assigneeIds')
    ..pPM<AssigneeSeconds>(10, _omitFieldNames ? '' : 'own',
        subBuilder: AssigneeSeconds.$_createMessage)
    ..aOS(11, _omitFieldNames ? '' : 'reason')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoadTask clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoadTask copyWith(void Function(LoadTask) updates) =>
      super.copyWith((message) => updates(message as LoadTask)) as LoadTask;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use LoadTask() / LoadTask.new instead')
  static LoadTask create() => LoadTask._();
  static $pb.GeneratedMessage $_createMessage() => LoadTask._();
  @$core.override
  LoadTask createEmptyInstance() => LoadTask._();
  @$core.pragma('dart2js:noInline')
  static LoadTask getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LoadTask>(LoadTask.$_createMessage);
  static LoadTask? _defaultInstance;

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
  $core.int get version => $_getIZ(4);
  @$pb.TagNumber(5)
  set version($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasVersion() => $_has(4);
  @$pb.TagNumber(5)
  void clearVersion() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get startDate => $_getSZ(5);
  @$pb.TagNumber(6)
  set startDate($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasStartDate() => $_has(5);
  @$pb.TagNumber(6)
  void clearStartDate() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get dueDate => $_getSZ(6);
  @$pb.TagNumber(7)
  set dueDate($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasDueDate() => $_has(6);
  @$pb.TagNumber(7)
  void clearDueDate() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.int get estimateSec => $_getIZ(7);
  @$pb.TagNumber(8)
  set estimateSec($core.int value) => $_setSignedInt32(7, value);
  @$pb.TagNumber(8)
  $core.bool hasEstimateSec() => $_has(7);
  @$pb.TagNumber(8)
  void clearEstimateSec() => $_clearField(8);

  @$pb.TagNumber(9)
  $pb.PbList<$core.String> get assigneeIds => $_getList(8);

  @$pb.TagNumber(10)
  $pb.PbList<AssigneeSeconds> get own => $_getList(9);

  @$pb.TagNumber(11)
  $core.String get reason => $_getSZ(10);
  @$pb.TagNumber(11)
  set reason($core.String value) => $_setString(10, value);
  @$pb.TagNumber(11)
  $core.bool hasReason() => $_has(10);
  @$pb.TagNumber(11)
  void clearReason() => $_clearField(11);
}

class OffRange extends $pb.GeneratedMessage {
  factory OffRange({
    $core.String? startDate,
    $core.String? endDate,
    $core.String? kind,
  }) {
    final result = OffRange._();
    if (startDate != null) result.startDate = startDate;
    if (endDate != null) result.endDate = endDate;
    if (kind != null) result.kind = kind;
    return result;
  }

  OffRange._();

  factory OffRange.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      OffRange()..mergeFromBuffer(data, registry);
  factory OffRange.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      OffRange()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'OffRange',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.workload'),
      createEmptyInstance: OffRange.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'startDate')
    ..aOS(2, _omitFieldNames ? '' : 'endDate')
    ..aOS(3, _omitFieldNames ? '' : 'kind')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OffRange clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OffRange copyWith(void Function(OffRange) updates) =>
      super.copyWith((message) => updates(message as OffRange)) as OffRange;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use OffRange() / OffRange.new instead')
  static OffRange create() => OffRange._();
  static $pb.GeneratedMessage $_createMessage() => OffRange._();
  @$core.override
  OffRange createEmptyInstance() => OffRange._();
  @$core.pragma('dart2js:noInline')
  static OffRange getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<OffRange>(OffRange.$_createMessage);
  static OffRange? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get startDate => $_getSZ(0);
  @$pb.TagNumber(1)
  set startDate($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasStartDate() => $_has(0);
  @$pb.TagNumber(1)
  void clearStartDate() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get endDate => $_getSZ(1);
  @$pb.TagNumber(2)
  set endDate($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasEndDate() => $_has(1);
  @$pb.TagNumber(2)
  void clearEndDate() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get kind => $_getSZ(2);
  @$pb.TagNumber(3)
  set kind($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasKind() => $_has(2);
  @$pb.TagNumber(3)
  void clearKind() => $_clearField(3);
}

class PersonLoad extends $pb.GeneratedMessage {
  factory PersonLoad({
    $core.String? userId,
    Capacity? capacity,
    $core.Iterable<OffRange>? timeOff,
    $core.Iterable<DayCell>? days,
    $core.int? totalLoadSec,
  }) {
    final result = PersonLoad._();
    if (userId != null) result.userId = userId;
    if (capacity != null) result.capacity = capacity;
    if (timeOff != null) result.timeOff.addAll(timeOff);
    if (days != null) result.days.addAll(days);
    if (totalLoadSec != null) result.totalLoadSec = totalLoadSec;
    return result;
  }

  PersonLoad._();

  factory PersonLoad.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PersonLoad()..mergeFromBuffer(data, registry);
  factory PersonLoad.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PersonLoad()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PersonLoad',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.workload'),
      createEmptyInstance: PersonLoad.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'userId')
    ..aOM<Capacity>(2, _omitFieldNames ? '' : 'capacity',
        subBuilder: Capacity.$_createMessage)
    ..pPM<OffRange>(3, _omitFieldNames ? '' : 'timeOff',
        subBuilder: OffRange.$_createMessage)
    ..pPM<DayCell>(4, _omitFieldNames ? '' : 'days',
        subBuilder: DayCell.$_createMessage)
    ..aI(5, _omitFieldNames ? '' : 'totalLoadSec')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PersonLoad clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PersonLoad copyWith(void Function(PersonLoad) updates) =>
      super.copyWith((message) => updates(message as PersonLoad)) as PersonLoad;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use PersonLoad() / PersonLoad.new instead')
  static PersonLoad create() => PersonLoad._();
  static $pb.GeneratedMessage $_createMessage() => PersonLoad._();
  @$core.override
  PersonLoad createEmptyInstance() => PersonLoad._();
  @$core.pragma('dart2js:noInline')
  static PersonLoad getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PersonLoad>(PersonLoad.$_createMessage);
  static PersonLoad? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get userId => $_getSZ(0);
  @$pb.TagNumber(1)
  set userId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => $_clearField(1);

  @$pb.TagNumber(2)
  Capacity get capacity => $_getN(1);
  @$pb.TagNumber(2)
  set capacity(Capacity value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasCapacity() => $_has(1);
  @$pb.TagNumber(2)
  void clearCapacity() => $_clearField(2);
  @$pb.TagNumber(2)
  Capacity ensureCapacity() => $_ensure(1);

  @$pb.TagNumber(3)
  $pb.PbList<OffRange> get timeOff => $_getList(2);

  @$pb.TagNumber(4)
  $pb.PbList<DayCell> get days => $_getList(3);

  @$pb.TagNumber(5)
  $core.int get totalLoadSec => $_getIZ(4);
  @$pb.TagNumber(5)
  set totalLoadSec($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasTotalLoadSec() => $_has(4);
  @$pb.TagNumber(5)
  void clearTotalLoadSec() => $_clearField(5);
}

class TimeOff extends $pb.GeneratedMessage {
  factory TimeOff({
    $core.String? id,
    $core.String? userId,
    $core.String? startDate,
    $core.String? endDate,
    $core.String? kind,
    $core.String? note,
  }) {
    final result = TimeOff._();
    if (id != null) result.id = id;
    if (userId != null) result.userId = userId;
    if (startDate != null) result.startDate = startDate;
    if (endDate != null) result.endDate = endDate;
    if (kind != null) result.kind = kind;
    if (note != null) result.note = note;
    return result;
  }

  TimeOff._();

  factory TimeOff.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TimeOff()..mergeFromBuffer(data, registry);
  factory TimeOff.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TimeOff()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TimeOff',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.workload'),
      createEmptyInstance: TimeOff.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'userId')
    ..aOS(3, _omitFieldNames ? '' : 'startDate')
    ..aOS(4, _omitFieldNames ? '' : 'endDate')
    ..aOS(5, _omitFieldNames ? '' : 'kind')
    ..aOS(6, _omitFieldNames ? '' : 'note')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TimeOff clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TimeOff copyWith(void Function(TimeOff) updates) =>
      super.copyWith((message) => updates(message as TimeOff)) as TimeOff;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use TimeOff() / TimeOff.new instead')
  static TimeOff create() => TimeOff._();
  static $pb.GeneratedMessage $_createMessage() => TimeOff._();
  @$core.override
  TimeOff createEmptyInstance() => TimeOff._();
  @$core.pragma('dart2js:noInline')
  static TimeOff getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TimeOff>(TimeOff.$_createMessage);
  static TimeOff? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get userId => $_getSZ(1);
  @$pb.TagNumber(2)
  set userId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUserId() => $_has(1);
  @$pb.TagNumber(2)
  void clearUserId() => $_clearField(2);

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
  $core.String get kind => $_getSZ(4);
  @$pb.TagNumber(5)
  set kind($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasKind() => $_has(4);
  @$pb.TagNumber(5)
  void clearKind() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get note => $_getSZ(5);
  @$pb.TagNumber(6)
  set note($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasNote() => $_has(5);
  @$pb.TagNumber(6)
  void clearNote() => $_clearField(6);
}

class TimeOffAnswer extends $pb.GeneratedMessage {
  factory TimeOffAnswer({
    TimeOff? entry,
  }) {
    final result = TimeOffAnswer._();
    if (entry != null) result.entry = entry;
    return result;
  }

  TimeOffAnswer._();

  factory TimeOffAnswer.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TimeOffAnswer()..mergeFromBuffer(data, registry);
  factory TimeOffAnswer.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TimeOffAnswer()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TimeOffAnswer',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.workload'),
      createEmptyInstance: TimeOffAnswer.$_createMessage)
    ..aOM<TimeOff>(1, _omitFieldNames ? '' : 'entry',
        subBuilder: TimeOff.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TimeOffAnswer clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TimeOffAnswer copyWith(void Function(TimeOffAnswer) updates) =>
      super.copyWith((message) => updates(message as TimeOffAnswer))
          as TimeOffAnswer;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use TimeOffAnswer() / TimeOffAnswer.new instead')
  static TimeOffAnswer create() => TimeOffAnswer._();
  static $pb.GeneratedMessage $_createMessage() => TimeOffAnswer._();
  @$core.override
  TimeOffAnswer createEmptyInstance() => TimeOffAnswer._();
  @$core.pragma('dart2js:noInline')
  static TimeOffAnswer getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TimeOffAnswer>(
          TimeOffAnswer.$_createMessage);
  static TimeOffAnswer? _defaultInstance;

  @$pb.TagNumber(1)
  TimeOff get entry => $_getN(0);
  @$pb.TagNumber(1)
  set entry(TimeOff value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasEntry() => $_has(0);
  @$pb.TagNumber(1)
  void clearEntry() => $_clearField(1);
  @$pb.TagNumber(1)
  TimeOff ensureEntry() => $_ensure(0);
}

class TimeOffCreateRequest extends $pb.GeneratedMessage {
  factory TimeOffCreateRequest({
    $core.String? workspaceId,
    $core.String? userId,
    $core.String? startDate,
    $core.String? endDate,
    $core.String? kind,
    $core.String? note,
  }) {
    final result = TimeOffCreateRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (userId != null) result.userId = userId;
    if (startDate != null) result.startDate = startDate;
    if (endDate != null) result.endDate = endDate;
    if (kind != null) result.kind = kind;
    if (note != null) result.note = note;
    return result;
  }

  TimeOffCreateRequest._();

  factory TimeOffCreateRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TimeOffCreateRequest()..mergeFromBuffer(data, registry);
  factory TimeOffCreateRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TimeOffCreateRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TimeOffCreateRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.workload'),
      createEmptyInstance: TimeOffCreateRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'userId')
    ..aOS(3, _omitFieldNames ? '' : 'startDate')
    ..aOS(4, _omitFieldNames ? '' : 'endDate')
    ..aOS(5, _omitFieldNames ? '' : 'kind')
    ..aOS(6, _omitFieldNames ? '' : 'note')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TimeOffCreateRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TimeOffCreateRequest copyWith(void Function(TimeOffCreateRequest) updates) =>
      super.copyWith((message) => updates(message as TimeOffCreateRequest))
          as TimeOffCreateRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use TimeOffCreateRequest() / TimeOffCreateRequest.new instead')
  static TimeOffCreateRequest create() => TimeOffCreateRequest._();
  static $pb.GeneratedMessage $_createMessage() => TimeOffCreateRequest._();
  @$core.override
  TimeOffCreateRequest createEmptyInstance() => TimeOffCreateRequest._();
  @$core.pragma('dart2js:noInline')
  static TimeOffCreateRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TimeOffCreateRequest>(
          TimeOffCreateRequest.$_createMessage);
  static TimeOffCreateRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get userId => $_getSZ(1);
  @$pb.TagNumber(2)
  set userId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUserId() => $_has(1);
  @$pb.TagNumber(2)
  void clearUserId() => $_clearField(2);

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
  $core.String get kind => $_getSZ(4);
  @$pb.TagNumber(5)
  set kind($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasKind() => $_has(4);
  @$pb.TagNumber(5)
  void clearKind() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get note => $_getSZ(5);
  @$pb.TagNumber(6)
  set note($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasNote() => $_has(5);
  @$pb.TagNumber(6)
  void clearNote() => $_clearField(6);
}

class TimeOffDeleteRequest extends $pb.GeneratedMessage {
  factory TimeOffDeleteRequest({
    $core.String? workspaceId,
    $core.String? timeOffId,
  }) {
    final result = TimeOffDeleteRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (timeOffId != null) result.timeOffId = timeOffId;
    return result;
  }

  TimeOffDeleteRequest._();

  factory TimeOffDeleteRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TimeOffDeleteRequest()..mergeFromBuffer(data, registry);
  factory TimeOffDeleteRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TimeOffDeleteRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TimeOffDeleteRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.workload'),
      createEmptyInstance: TimeOffDeleteRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'timeOffId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TimeOffDeleteRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TimeOffDeleteRequest copyWith(void Function(TimeOffDeleteRequest) updates) =>
      super.copyWith((message) => updates(message as TimeOffDeleteRequest))
          as TimeOffDeleteRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use TimeOffDeleteRequest() / TimeOffDeleteRequest.new instead')
  static TimeOffDeleteRequest create() => TimeOffDeleteRequest._();
  static $pb.GeneratedMessage $_createMessage() => TimeOffDeleteRequest._();
  @$core.override
  TimeOffDeleteRequest createEmptyInstance() => TimeOffDeleteRequest._();
  @$core.pragma('dart2js:noInline')
  static TimeOffDeleteRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TimeOffDeleteRequest>(
          TimeOffDeleteRequest.$_createMessage);
  static TimeOffDeleteRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get timeOffId => $_getSZ(1);
  @$pb.TagNumber(2)
  set timeOffId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTimeOffId() => $_has(1);
  @$pb.TagNumber(2)
  void clearTimeOffId() => $_clearField(2);
}

class TimeOffDeleted extends $pb.GeneratedMessage {
  factory TimeOffDeleted({
    $core.String? id,
  }) {
    final result = TimeOffDeleted._();
    if (id != null) result.id = id;
    return result;
  }

  TimeOffDeleted._();

  factory TimeOffDeleted.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TimeOffDeleted()..mergeFromBuffer(data, registry);
  factory TimeOffDeleted.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TimeOffDeleted()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TimeOffDeleted',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.workload'),
      createEmptyInstance: TimeOffDeleted.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TimeOffDeleted clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TimeOffDeleted copyWith(void Function(TimeOffDeleted) updates) =>
      super.copyWith((message) => updates(message as TimeOffDeleted))
          as TimeOffDeleted;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use TimeOffDeleted() / TimeOffDeleted.new instead')
  static TimeOffDeleted create() => TimeOffDeleted._();
  static $pb.GeneratedMessage $_createMessage() => TimeOffDeleted._();
  @$core.override
  TimeOffDeleted createEmptyInstance() => TimeOffDeleted._();
  @$core.pragma('dart2js:noInline')
  static TimeOffDeleted getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TimeOffDeleted>(
          TimeOffDeleted.$_createMessage);
  static TimeOffDeleted? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class TimeOffList extends $pb.GeneratedMessage {
  factory TimeOffList({
    $core.Iterable<TimeOff>? entries,
  }) {
    final result = TimeOffList._();
    if (entries != null) result.entries.addAll(entries);
    return result;
  }

  TimeOffList._();

  factory TimeOffList.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TimeOffList()..mergeFromBuffer(data, registry);
  factory TimeOffList.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TimeOffList()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TimeOffList',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.workload'),
      createEmptyInstance: TimeOffList.$_createMessage)
    ..pPM<TimeOff>(1, _omitFieldNames ? '' : 'entries',
        subBuilder: TimeOff.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TimeOffList clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TimeOffList copyWith(void Function(TimeOffList) updates) =>
      super.copyWith((message) => updates(message as TimeOffList))
          as TimeOffList;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use TimeOffList() / TimeOffList.new instead')
  static TimeOffList create() => TimeOffList._();
  static $pb.GeneratedMessage $_createMessage() => TimeOffList._();
  @$core.override
  TimeOffList createEmptyInstance() => TimeOffList._();
  @$core.pragma('dart2js:noInline')
  static TimeOffList getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TimeOffList>(
          TimeOffList.$_createMessage);
  static TimeOffList? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<TimeOff> get entries => $_getList(0);
}

class TimeOffListRequest extends $pb.GeneratedMessage {
  factory TimeOffListRequest({
    $core.String? workspaceId,
    $core.String? userId,
    $core.String? rangeStart,
    $core.String? rangeEnd,
  }) {
    final result = TimeOffListRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (userId != null) result.userId = userId;
    if (rangeStart != null) result.rangeStart = rangeStart;
    if (rangeEnd != null) result.rangeEnd = rangeEnd;
    return result;
  }

  TimeOffListRequest._();

  factory TimeOffListRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TimeOffListRequest()..mergeFromBuffer(data, registry);
  factory TimeOffListRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TimeOffListRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TimeOffListRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.workload'),
      createEmptyInstance: TimeOffListRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'userId')
    ..aOS(3, _omitFieldNames ? '' : 'rangeStart')
    ..aOS(4, _omitFieldNames ? '' : 'rangeEnd')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TimeOffListRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TimeOffListRequest copyWith(void Function(TimeOffListRequest) updates) =>
      super.copyWith((message) => updates(message as TimeOffListRequest))
          as TimeOffListRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use TimeOffListRequest() / TimeOffListRequest.new instead')
  static TimeOffListRequest create() => TimeOffListRequest._();
  static $pb.GeneratedMessage $_createMessage() => TimeOffListRequest._();
  @$core.override
  TimeOffListRequest createEmptyInstance() => TimeOffListRequest._();
  @$core.pragma('dart2js:noInline')
  static TimeOffListRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TimeOffListRequest>(
          TimeOffListRequest.$_createMessage);
  static TimeOffListRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get userId => $_getSZ(1);
  @$pb.TagNumber(2)
  set userId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUserId() => $_has(1);
  @$pb.TagNumber(2)
  void clearUserId() => $_clearField(2);

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
}

class TimeOffUpdateRequest extends $pb.GeneratedMessage {
  factory TimeOffUpdateRequest({
    $core.String? workspaceId,
    $core.String? timeOffId,
    $core.String? startDate,
    $core.String? endDate,
    $core.String? kind,
    $core.String? note,
  }) {
    final result = TimeOffUpdateRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (timeOffId != null) result.timeOffId = timeOffId;
    if (startDate != null) result.startDate = startDate;
    if (endDate != null) result.endDate = endDate;
    if (kind != null) result.kind = kind;
    if (note != null) result.note = note;
    return result;
  }

  TimeOffUpdateRequest._();

  factory TimeOffUpdateRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TimeOffUpdateRequest()..mergeFromBuffer(data, registry);
  factory TimeOffUpdateRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TimeOffUpdateRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TimeOffUpdateRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.workload'),
      createEmptyInstance: TimeOffUpdateRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'timeOffId')
    ..aOS(3, _omitFieldNames ? '' : 'startDate')
    ..aOS(4, _omitFieldNames ? '' : 'endDate')
    ..aOS(5, _omitFieldNames ? '' : 'kind')
    ..aOS(6, _omitFieldNames ? '' : 'note')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TimeOffUpdateRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TimeOffUpdateRequest copyWith(void Function(TimeOffUpdateRequest) updates) =>
      super.copyWith((message) => updates(message as TimeOffUpdateRequest))
          as TimeOffUpdateRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use TimeOffUpdateRequest() / TimeOffUpdateRequest.new instead')
  static TimeOffUpdateRequest create() => TimeOffUpdateRequest._();
  static $pb.GeneratedMessage $_createMessage() => TimeOffUpdateRequest._();
  @$core.override
  TimeOffUpdateRequest createEmptyInstance() => TimeOffUpdateRequest._();
  @$core.pragma('dart2js:noInline')
  static TimeOffUpdateRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TimeOffUpdateRequest>(
          TimeOffUpdateRequest.$_createMessage);
  static TimeOffUpdateRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get timeOffId => $_getSZ(1);
  @$pb.TagNumber(2)
  set timeOffId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTimeOffId() => $_has(1);
  @$pb.TagNumber(2)
  void clearTimeOffId() => $_clearField(2);

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
  $core.String get kind => $_getSZ(4);
  @$pb.TagNumber(5)
  set kind($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasKind() => $_has(4);
  @$pb.TagNumber(5)
  void clearKind() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get note => $_getSZ(5);
  @$pb.TagNumber(6)
  set note($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasNote() => $_has(5);
  @$pb.TagNumber(6)
  void clearNote() => $_clearField(6);
}

class WorkloadAnswer extends $pb.GeneratedMessage {
  factory WorkloadAnswer({
    $core.String? rangeStart,
    $core.String? rangeEnd,
    $core.bool? canSeeAll,
    $core.Iterable<PersonLoad>? people,
    $core.Iterable<LoadTask>? tasks,
    $core.Iterable<LoadTask>? unestimated,
    $core.Iterable<$core.String>? holidays,
    $core.bool? truncated,
  }) {
    final result = WorkloadAnswer._();
    if (rangeStart != null) result.rangeStart = rangeStart;
    if (rangeEnd != null) result.rangeEnd = rangeEnd;
    if (canSeeAll != null) result.canSeeAll = canSeeAll;
    if (people != null) result.people.addAll(people);
    if (tasks != null) result.tasks.addAll(tasks);
    if (unestimated != null) result.unestimated.addAll(unestimated);
    if (holidays != null) result.holidays.addAll(holidays);
    if (truncated != null) result.truncated = truncated;
    return result;
  }

  WorkloadAnswer._();

  factory WorkloadAnswer.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WorkloadAnswer()..mergeFromBuffer(data, registry);
  factory WorkloadAnswer.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WorkloadAnswer()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WorkloadAnswer',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.workload'),
      createEmptyInstance: WorkloadAnswer.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'rangeStart')
    ..aOS(2, _omitFieldNames ? '' : 'rangeEnd')
    ..aOB(3, _omitFieldNames ? '' : 'canSeeAll')
    ..pPM<PersonLoad>(4, _omitFieldNames ? '' : 'people',
        subBuilder: PersonLoad.$_createMessage)
    ..pPM<LoadTask>(5, _omitFieldNames ? '' : 'tasks',
        subBuilder: LoadTask.$_createMessage)
    ..pPM<LoadTask>(6, _omitFieldNames ? '' : 'unestimated',
        subBuilder: LoadTask.$_createMessage)
    ..pPS(7, _omitFieldNames ? '' : 'holidays')
    ..aOB(8, _omitFieldNames ? '' : 'truncated')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WorkloadAnswer clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WorkloadAnswer copyWith(void Function(WorkloadAnswer) updates) =>
      super.copyWith((message) => updates(message as WorkloadAnswer))
          as WorkloadAnswer;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use WorkloadAnswer() / WorkloadAnswer.new instead')
  static WorkloadAnswer create() => WorkloadAnswer._();
  static $pb.GeneratedMessage $_createMessage() => WorkloadAnswer._();
  @$core.override
  WorkloadAnswer createEmptyInstance() => WorkloadAnswer._();
  @$core.pragma('dart2js:noInline')
  static WorkloadAnswer getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<WorkloadAnswer>(
          WorkloadAnswer.$_createMessage);
  static WorkloadAnswer? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get rangeStart => $_getSZ(0);
  @$pb.TagNumber(1)
  set rangeStart($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRangeStart() => $_has(0);
  @$pb.TagNumber(1)
  void clearRangeStart() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get rangeEnd => $_getSZ(1);
  @$pb.TagNumber(2)
  set rangeEnd($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRangeEnd() => $_has(1);
  @$pb.TagNumber(2)
  void clearRangeEnd() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get canSeeAll => $_getBF(2);
  @$pb.TagNumber(3)
  set canSeeAll($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasCanSeeAll() => $_has(2);
  @$pb.TagNumber(3)
  void clearCanSeeAll() => $_clearField(3);

  @$pb.TagNumber(4)
  $pb.PbList<PersonLoad> get people => $_getList(3);

  @$pb.TagNumber(5)
  $pb.PbList<LoadTask> get tasks => $_getList(4);

  @$pb.TagNumber(6)
  $pb.PbList<LoadTask> get unestimated => $_getList(5);

  @$pb.TagNumber(7)
  $pb.PbList<$core.String> get holidays => $_getList(6);

  @$pb.TagNumber(8)
  $core.bool get truncated => $_getBF(7);
  @$pb.TagNumber(8)
  set truncated($core.bool value) => $_setBool(7, value);
  @$pb.TagNumber(8)
  $core.bool hasTruncated() => $_has(7);
  @$pb.TagNumber(8)
  void clearTruncated() => $_clearField(8);
}

class WorkloadGetRequest extends $pb.GeneratedMessage {
  factory WorkloadGetRequest({
    $core.String? workspaceId,
    $core.String? rangeStart,
    $core.String? rangeEnd,
    $core.Iterable<$core.String>? projectIds,
    $core.Iterable<$core.String>? userIds,
  }) {
    final result = WorkloadGetRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (rangeStart != null) result.rangeStart = rangeStart;
    if (rangeEnd != null) result.rangeEnd = rangeEnd;
    if (projectIds != null) result.projectIds.addAll(projectIds);
    if (userIds != null) result.userIds.addAll(userIds);
    return result;
  }

  WorkloadGetRequest._();

  factory WorkloadGetRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WorkloadGetRequest()..mergeFromBuffer(data, registry);
  factory WorkloadGetRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WorkloadGetRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WorkloadGetRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.workload'),
      createEmptyInstance: WorkloadGetRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'rangeStart')
    ..aOS(3, _omitFieldNames ? '' : 'rangeEnd')
    ..pPS(4, _omitFieldNames ? '' : 'projectIds')
    ..pPS(5, _omitFieldNames ? '' : 'userIds')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WorkloadGetRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WorkloadGetRequest copyWith(void Function(WorkloadGetRequest) updates) =>
      super.copyWith((message) => updates(message as WorkloadGetRequest))
          as WorkloadGetRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use WorkloadGetRequest() / WorkloadGetRequest.new instead')
  static WorkloadGetRequest create() => WorkloadGetRequest._();
  static $pb.GeneratedMessage $_createMessage() => WorkloadGetRequest._();
  @$core.override
  WorkloadGetRequest createEmptyInstance() => WorkloadGetRequest._();
  @$core.pragma('dart2js:noInline')
  static WorkloadGetRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WorkloadGetRequest>(
          WorkloadGetRequest.$_createMessage);
  static WorkloadGetRequest? _defaultInstance;

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
  $pb.PbList<$core.String> get projectIds => $_getList(3);

  @$pb.TagNumber(5)
  $pb.PbList<$core.String> get userIds => $_getList(4);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
