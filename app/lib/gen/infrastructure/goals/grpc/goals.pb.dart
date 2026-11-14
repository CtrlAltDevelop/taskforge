// This is a generated file - do not edit.
//
// Generated from infrastructure/goals/grpc/goals.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class CheckIn extends $pb.GeneratedMessage {
  factory CheckIn({
    $core.String? id,
    $core.String? krId,
    $core.String? userId,
    $core.String? value,
    $core.String? previousValue,
    $core.double? progress,
    $core.String? note,
    $core.String? at,
  }) {
    final result = CheckIn._();
    if (id != null) result.id = id;
    if (krId != null) result.krId = krId;
    if (userId != null) result.userId = userId;
    if (value != null) result.value = value;
    if (previousValue != null) result.previousValue = previousValue;
    if (progress != null) result.progress = progress;
    if (note != null) result.note = note;
    if (at != null) result.at = at;
    return result;
  }

  CheckIn._();

  factory CheckIn.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CheckIn()..mergeFromBuffer(data, registry);
  factory CheckIn.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CheckIn()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CheckIn',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.goals'),
      createEmptyInstance: CheckIn.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'krId')
    ..aOS(3, _omitFieldNames ? '' : 'userId')
    ..aOS(4, _omitFieldNames ? '' : 'value')
    ..aOS(5, _omitFieldNames ? '' : 'previousValue')
    ..aD(6, _omitFieldNames ? '' : 'progress', fieldType: $pb.PbFieldType.OF)
    ..aOS(7, _omitFieldNames ? '' : 'note')
    ..aOS(8, _omitFieldNames ? '' : 'at')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CheckIn clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CheckIn copyWith(void Function(CheckIn) updates) =>
      super.copyWith((message) => updates(message as CheckIn)) as CheckIn;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CheckIn() / CheckIn.new instead')
  static CheckIn create() => CheckIn._();
  static $pb.GeneratedMessage $_createMessage() => CheckIn._();
  @$core.override
  CheckIn createEmptyInstance() => CheckIn._();
  @$core.pragma('dart2js:noInline')
  static CheckIn getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CheckIn>(CheckIn.$_createMessage);
  static CheckIn? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get krId => $_getSZ(1);
  @$pb.TagNumber(2)
  set krId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasKrId() => $_has(1);
  @$pb.TagNumber(2)
  void clearKrId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get userId => $_getSZ(2);
  @$pb.TagNumber(3)
  set userId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasUserId() => $_has(2);
  @$pb.TagNumber(3)
  void clearUserId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get value => $_getSZ(3);
  @$pb.TagNumber(4)
  set value($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasValue() => $_has(3);
  @$pb.TagNumber(4)
  void clearValue() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get previousValue => $_getSZ(4);
  @$pb.TagNumber(5)
  set previousValue($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasPreviousValue() => $_has(4);
  @$pb.TagNumber(5)
  void clearPreviousValue() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.double get progress => $_getN(5);
  @$pb.TagNumber(6)
  set progress($core.double value) => $_setFloat(5, value);
  @$pb.TagNumber(6)
  $core.bool hasProgress() => $_has(5);
  @$pb.TagNumber(6)
  void clearProgress() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get note => $_getSZ(6);
  @$pb.TagNumber(7)
  set note($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasNote() => $_has(6);
  @$pb.TagNumber(7)
  void clearNote() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get at => $_getSZ(7);
  @$pb.TagNumber(8)
  set at($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasAt() => $_has(7);
  @$pb.TagNumber(8)
  void clearAt() => $_clearField(8);
}

class CheckInAddRequest extends $pb.GeneratedMessage {
  factory CheckInAddRequest({
    $core.String? workspaceId,
    $core.String? krId,
    $core.String? value,
    $core.String? note,
  }) {
    final result = CheckInAddRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (krId != null) result.krId = krId;
    if (value != null) result.value = value;
    if (note != null) result.note = note;
    return result;
  }

  CheckInAddRequest._();

  factory CheckInAddRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CheckInAddRequest()..mergeFromBuffer(data, registry);
  factory CheckInAddRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CheckInAddRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CheckInAddRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.goals'),
      createEmptyInstance: CheckInAddRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'krId')
    ..aOS(3, _omitFieldNames ? '' : 'value')
    ..aOS(4, _omitFieldNames ? '' : 'note')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CheckInAddRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CheckInAddRequest copyWith(void Function(CheckInAddRequest) updates) =>
      super.copyWith((message) => updates(message as CheckInAddRequest))
          as CheckInAddRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CheckInAddRequest() / CheckInAddRequest.new instead')
  static CheckInAddRequest create() => CheckInAddRequest._();
  static $pb.GeneratedMessage $_createMessage() => CheckInAddRequest._();
  @$core.override
  CheckInAddRequest createEmptyInstance() => CheckInAddRequest._();
  @$core.pragma('dart2js:noInline')
  static CheckInAddRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CheckInAddRequest>(
          CheckInAddRequest.$_createMessage);
  static CheckInAddRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get krId => $_getSZ(1);
  @$pb.TagNumber(2)
  set krId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasKrId() => $_has(1);
  @$pb.TagNumber(2)
  void clearKrId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get value => $_getSZ(2);
  @$pb.TagNumber(3)
  set value($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasValue() => $_has(2);
  @$pb.TagNumber(3)
  void clearValue() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get note => $_getSZ(3);
  @$pb.TagNumber(4)
  set note($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasNote() => $_has(3);
  @$pb.TagNumber(4)
  void clearNote() => $_clearField(4);
}

class CheckInAnswer extends $pb.GeneratedMessage {
  factory CheckInAnswer({
    CheckIn? checkIn,
    Goal? goal,
  }) {
    final result = CheckInAnswer._();
    if (checkIn != null) result.checkIn = checkIn;
    if (goal != null) result.goal = goal;
    return result;
  }

  CheckInAnswer._();

  factory CheckInAnswer.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CheckInAnswer()..mergeFromBuffer(data, registry);
  factory CheckInAnswer.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CheckInAnswer()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CheckInAnswer',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.goals'),
      createEmptyInstance: CheckInAnswer.$_createMessage)
    ..aOM<CheckIn>(1, _omitFieldNames ? '' : 'checkIn',
        subBuilder: CheckIn.$_createMessage)
    ..aOM<Goal>(2, _omitFieldNames ? '' : 'goal',
        subBuilder: Goal.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CheckInAnswer clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CheckInAnswer copyWith(void Function(CheckInAnswer) updates) =>
      super.copyWith((message) => updates(message as CheckInAnswer))
          as CheckInAnswer;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CheckInAnswer() / CheckInAnswer.new instead')
  static CheckInAnswer create() => CheckInAnswer._();
  static $pb.GeneratedMessage $_createMessage() => CheckInAnswer._();
  @$core.override
  CheckInAnswer createEmptyInstance() => CheckInAnswer._();
  @$core.pragma('dart2js:noInline')
  static CheckInAnswer getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CheckInAnswer>(
          CheckInAnswer.$_createMessage);
  static CheckInAnswer? _defaultInstance;

  @$pb.TagNumber(1)
  CheckIn get checkIn => $_getN(0);
  @$pb.TagNumber(1)
  set checkIn(CheckIn value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasCheckIn() => $_has(0);
  @$pb.TagNumber(1)
  void clearCheckIn() => $_clearField(1);
  @$pb.TagNumber(1)
  CheckIn ensureCheckIn() => $_ensure(0);

  @$pb.TagNumber(2)
  Goal get goal => $_getN(1);
  @$pb.TagNumber(2)
  set goal(Goal value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasGoal() => $_has(1);
  @$pb.TagNumber(2)
  void clearGoal() => $_clearField(2);
  @$pb.TagNumber(2)
  Goal ensureGoal() => $_ensure(1);
}

class CheckInList extends $pb.GeneratedMessage {
  factory CheckInList({
    $core.Iterable<CheckIn>? checkIns,
  }) {
    final result = CheckInList._();
    if (checkIns != null) result.checkIns.addAll(checkIns);
    return result;
  }

  CheckInList._();

  factory CheckInList.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CheckInList()..mergeFromBuffer(data, registry);
  factory CheckInList.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CheckInList()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CheckInList',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.goals'),
      createEmptyInstance: CheckInList.$_createMessage)
    ..pPM<CheckIn>(1, _omitFieldNames ? '' : 'checkIns',
        subBuilder: CheckIn.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CheckInList clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CheckInList copyWith(void Function(CheckInList) updates) =>
      super.copyWith((message) => updates(message as CheckInList))
          as CheckInList;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CheckInList() / CheckInList.new instead')
  static CheckInList create() => CheckInList._();
  static $pb.GeneratedMessage $_createMessage() => CheckInList._();
  @$core.override
  CheckInList createEmptyInstance() => CheckInList._();
  @$core.pragma('dart2js:noInline')
  static CheckInList getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CheckInList>(
          CheckInList.$_createMessage);
  static CheckInList? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<CheckIn> get checkIns => $_getList(0);
}

class CheckInListRequest extends $pb.GeneratedMessage {
  factory CheckInListRequest({
    $core.String? workspaceId,
    $core.String? krId,
    $core.int? limit,
  }) {
    final result = CheckInListRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (krId != null) result.krId = krId;
    if (limit != null) result.limit = limit;
    return result;
  }

  CheckInListRequest._();

  factory CheckInListRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CheckInListRequest()..mergeFromBuffer(data, registry);
  factory CheckInListRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CheckInListRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CheckInListRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.goals'),
      createEmptyInstance: CheckInListRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'krId')
    ..aI(3, _omitFieldNames ? '' : 'limit')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CheckInListRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CheckInListRequest copyWith(void Function(CheckInListRequest) updates) =>
      super.copyWith((message) => updates(message as CheckInListRequest))
          as CheckInListRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CheckInListRequest() / CheckInListRequest.new instead')
  static CheckInListRequest create() => CheckInListRequest._();
  static $pb.GeneratedMessage $_createMessage() => CheckInListRequest._();
  @$core.override
  CheckInListRequest createEmptyInstance() => CheckInListRequest._();
  @$core.pragma('dart2js:noInline')
  static CheckInListRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CheckInListRequest>(
          CheckInListRequest.$_createMessage);
  static CheckInListRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get krId => $_getSZ(1);
  @$pb.TagNumber(2)
  set krId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasKrId() => $_has(1);
  @$pb.TagNumber(2)
  void clearKrId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get limit => $_getIZ(2);
  @$pb.TagNumber(3)
  set limit($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasLimit() => $_has(2);
  @$pb.TagNumber(3)
  void clearLimit() => $_clearField(3);
}

class Contribution extends $pb.GeneratedMessage {
  factory Contribution({
    $core.String? goalId,
    $core.String? goalName,
    $core.String? krId,
    $core.String? krName,
  }) {
    final result = Contribution._();
    if (goalId != null) result.goalId = goalId;
    if (goalName != null) result.goalName = goalName;
    if (krId != null) result.krId = krId;
    if (krName != null) result.krName = krName;
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.goals'),
      createEmptyInstance: Contribution.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'goalId')
    ..aOS(2, _omitFieldNames ? '' : 'goalName')
    ..aOS(3, _omitFieldNames ? '' : 'krId')
    ..aOS(4, _omitFieldNames ? '' : 'krName')
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
  $core.String get goalId => $_getSZ(0);
  @$pb.TagNumber(1)
  set goalId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasGoalId() => $_has(0);
  @$pb.TagNumber(1)
  void clearGoalId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get goalName => $_getSZ(1);
  @$pb.TagNumber(2)
  set goalName($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasGoalName() => $_has(1);
  @$pb.TagNumber(2)
  void clearGoalName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get krId => $_getSZ(2);
  @$pb.TagNumber(3)
  set krId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasKrId() => $_has(2);
  @$pb.TagNumber(3)
  void clearKrId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get krName => $_getSZ(3);
  @$pb.TagNumber(4)
  set krName($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasKrName() => $_has(3);
  @$pb.TagNumber(4)
  void clearKrName() => $_clearField(4);
}

class Folder extends $pb.GeneratedMessage {
  factory Folder({
    $core.String? id,
    $core.String? name,
    $core.int? position,
  }) {
    final result = Folder._();
    if (id != null) result.id = id;
    if (name != null) result.name = name;
    if (position != null) result.position = position;
    return result;
  }

  Folder._();

  factory Folder.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Folder()..mergeFromBuffer(data, registry);
  factory Folder.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Folder()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Folder',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.goals'),
      createEmptyInstance: Folder.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aI(3, _omitFieldNames ? '' : 'position')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Folder clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Folder copyWith(void Function(Folder) updates) =>
      super.copyWith((message) => updates(message as Folder)) as Folder;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Folder() / Folder.new instead')
  static Folder create() => Folder._();
  static $pb.GeneratedMessage $_createMessage() => Folder._();
  @$core.override
  Folder createEmptyInstance() => Folder._();
  @$core.pragma('dart2js:noInline')
  static Folder getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Folder>(Folder.$_createMessage);
  static Folder? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get position => $_getIZ(2);
  @$pb.TagNumber(3)
  set position($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPosition() => $_has(2);
  @$pb.TagNumber(3)
  void clearPosition() => $_clearField(3);
}

class FolderAnswer extends $pb.GeneratedMessage {
  factory FolderAnswer({
    Folder? folder,
  }) {
    final result = FolderAnswer._();
    if (folder != null) result.folder = folder;
    return result;
  }

  FolderAnswer._();

  factory FolderAnswer.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FolderAnswer()..mergeFromBuffer(data, registry);
  factory FolderAnswer.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FolderAnswer()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FolderAnswer',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.goals'),
      createEmptyInstance: FolderAnswer.$_createMessage)
    ..aOM<Folder>(1, _omitFieldNames ? '' : 'folder',
        subBuilder: Folder.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FolderAnswer clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FolderAnswer copyWith(void Function(FolderAnswer) updates) =>
      super.copyWith((message) => updates(message as FolderAnswer))
          as FolderAnswer;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use FolderAnswer() / FolderAnswer.new instead')
  static FolderAnswer create() => FolderAnswer._();
  static $pb.GeneratedMessage $_createMessage() => FolderAnswer._();
  @$core.override
  FolderAnswer createEmptyInstance() => FolderAnswer._();
  @$core.pragma('dart2js:noInline')
  static FolderAnswer getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<FolderAnswer>(
          FolderAnswer.$_createMessage);
  static FolderAnswer? _defaultInstance;

  @$pb.TagNumber(1)
  Folder get folder => $_getN(0);
  @$pb.TagNumber(1)
  set folder(Folder value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasFolder() => $_has(0);
  @$pb.TagNumber(1)
  void clearFolder() => $_clearField(1);
  @$pb.TagNumber(1)
  Folder ensureFolder() => $_ensure(0);
}

class FolderDeleteRequest extends $pb.GeneratedMessage {
  factory FolderDeleteRequest({
    $core.String? workspaceId,
    $core.String? folderId,
  }) {
    final result = FolderDeleteRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (folderId != null) result.folderId = folderId;
    return result;
  }

  FolderDeleteRequest._();

  factory FolderDeleteRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FolderDeleteRequest()..mergeFromBuffer(data, registry);
  factory FolderDeleteRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FolderDeleteRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FolderDeleteRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.goals'),
      createEmptyInstance: FolderDeleteRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'folderId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FolderDeleteRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FolderDeleteRequest copyWith(void Function(FolderDeleteRequest) updates) =>
      super.copyWith((message) => updates(message as FolderDeleteRequest))
          as FolderDeleteRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core
      .Deprecated('Use FolderDeleteRequest() / FolderDeleteRequest.new instead')
  static FolderDeleteRequest create() => FolderDeleteRequest._();
  static $pb.GeneratedMessage $_createMessage() => FolderDeleteRequest._();
  @$core.override
  FolderDeleteRequest createEmptyInstance() => FolderDeleteRequest._();
  @$core.pragma('dart2js:noInline')
  static FolderDeleteRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FolderDeleteRequest>(
          FolderDeleteRequest.$_createMessage);
  static FolderDeleteRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get folderId => $_getSZ(1);
  @$pb.TagNumber(2)
  set folderId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFolderId() => $_has(1);
  @$pb.TagNumber(2)
  void clearFolderId() => $_clearField(2);
}

class FolderDeleted extends $pb.GeneratedMessage {
  factory FolderDeleted({
    $core.String? id,
  }) {
    final result = FolderDeleted._();
    if (id != null) result.id = id;
    return result;
  }

  FolderDeleted._();

  factory FolderDeleted.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FolderDeleted()..mergeFromBuffer(data, registry);
  factory FolderDeleted.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FolderDeleted()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FolderDeleted',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.goals'),
      createEmptyInstance: FolderDeleted.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FolderDeleted clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FolderDeleted copyWith(void Function(FolderDeleted) updates) =>
      super.copyWith((message) => updates(message as FolderDeleted))
          as FolderDeleted;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use FolderDeleted() / FolderDeleted.new instead')
  static FolderDeleted create() => FolderDeleted._();
  static $pb.GeneratedMessage $_createMessage() => FolderDeleted._();
  @$core.override
  FolderDeleted createEmptyInstance() => FolderDeleted._();
  @$core.pragma('dart2js:noInline')
  static FolderDeleted getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<FolderDeleted>(
          FolderDeleted.$_createMessage);
  static FolderDeleted? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class FolderSaveRequest extends $pb.GeneratedMessage {
  factory FolderSaveRequest({
    $core.String? workspaceId,
    $core.String? folderId,
    $core.String? name,
  }) {
    final result = FolderSaveRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (folderId != null) result.folderId = folderId;
    if (name != null) result.name = name;
    return result;
  }

  FolderSaveRequest._();

  factory FolderSaveRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FolderSaveRequest()..mergeFromBuffer(data, registry);
  factory FolderSaveRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FolderSaveRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FolderSaveRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.goals'),
      createEmptyInstance: FolderSaveRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'folderId')
    ..aOS(3, _omitFieldNames ? '' : 'name')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FolderSaveRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FolderSaveRequest copyWith(void Function(FolderSaveRequest) updates) =>
      super.copyWith((message) => updates(message as FolderSaveRequest))
          as FolderSaveRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use FolderSaveRequest() / FolderSaveRequest.new instead')
  static FolderSaveRequest create() => FolderSaveRequest._();
  static $pb.GeneratedMessage $_createMessage() => FolderSaveRequest._();
  @$core.override
  FolderSaveRequest createEmptyInstance() => FolderSaveRequest._();
  @$core.pragma('dart2js:noInline')
  static FolderSaveRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<FolderSaveRequest>(
          FolderSaveRequest.$_createMessage);
  static FolderSaveRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get folderId => $_getSZ(1);
  @$pb.TagNumber(2)
  set folderId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFolderId() => $_has(1);
  @$pb.TagNumber(2)
  void clearFolderId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get name => $_getSZ(2);
  @$pb.TagNumber(3)
  set name($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasName() => $_has(2);
  @$pb.TagNumber(3)
  void clearName() => $_clearField(3);
}

class ForTaskList extends $pb.GeneratedMessage {
  factory ForTaskList({
    $core.Iterable<Contribution>? contributions,
  }) {
    final result = ForTaskList._();
    if (contributions != null) result.contributions.addAll(contributions);
    return result;
  }

  ForTaskList._();

  factory ForTaskList.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ForTaskList()..mergeFromBuffer(data, registry);
  factory ForTaskList.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ForTaskList()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ForTaskList',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.goals'),
      createEmptyInstance: ForTaskList.$_createMessage)
    ..pPM<Contribution>(1, _omitFieldNames ? '' : 'contributions',
        subBuilder: Contribution.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ForTaskList clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ForTaskList copyWith(void Function(ForTaskList) updates) =>
      super.copyWith((message) => updates(message as ForTaskList))
          as ForTaskList;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ForTaskList() / ForTaskList.new instead')
  static ForTaskList create() => ForTaskList._();
  static $pb.GeneratedMessage $_createMessage() => ForTaskList._();
  @$core.override
  ForTaskList createEmptyInstance() => ForTaskList._();
  @$core.pragma('dart2js:noInline')
  static ForTaskList getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ForTaskList>(
          ForTaskList.$_createMessage);
  static ForTaskList? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Contribution> get contributions => $_getList(0);
}

class ForTaskRequest extends $pb.GeneratedMessage {
  factory ForTaskRequest({
    $core.String? workspaceId,
    $core.String? taskId,
  }) {
    final result = ForTaskRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (taskId != null) result.taskId = taskId;
    return result;
  }

  ForTaskRequest._();

  factory ForTaskRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ForTaskRequest()..mergeFromBuffer(data, registry);
  factory ForTaskRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ForTaskRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ForTaskRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.goals'),
      createEmptyInstance: ForTaskRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'taskId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ForTaskRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ForTaskRequest copyWith(void Function(ForTaskRequest) updates) =>
      super.copyWith((message) => updates(message as ForTaskRequest))
          as ForTaskRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ForTaskRequest() / ForTaskRequest.new instead')
  static ForTaskRequest create() => ForTaskRequest._();
  static $pb.GeneratedMessage $_createMessage() => ForTaskRequest._();
  @$core.override
  ForTaskRequest createEmptyInstance() => ForTaskRequest._();
  @$core.pragma('dart2js:noInline')
  static ForTaskRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ForTaskRequest>(
          ForTaskRequest.$_createMessage);
  static ForTaskRequest? _defaultInstance;

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

class Goal extends $pb.GeneratedMessage {
  factory Goal({
    $core.String? id,
    $core.String? workspaceId,
    $core.String? parentId,
    $core.String? folderId,
    $core.String? name,
    $core.String? description,
    $core.String? ownerId,
    $core.bool? private,
    $core.String? periodStart,
    $core.String? periodEnd,
    $core.String? statusOverride,
    $core.String? status,
    $core.String? statusHint,
    $core.String? weight,
    $core.double? progress,
    $core.int? version,
    $core.bool? canEdit,
    $core.bool? canCheckIn,
    $core.Iterable<$core.String>? contributorIds,
    $core.Iterable<$core.String>? childIds,
    $core.Iterable<KeyResult>? keyResults,
    $core.String? createdAt,
  }) {
    final result = Goal._();
    if (id != null) result.id = id;
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (parentId != null) result.parentId = parentId;
    if (folderId != null) result.folderId = folderId;
    if (name != null) result.name = name;
    if (description != null) result.description = description;
    if (ownerId != null) result.ownerId = ownerId;
    if (private != null) result.private = private;
    if (periodStart != null) result.periodStart = periodStart;
    if (periodEnd != null) result.periodEnd = periodEnd;
    if (statusOverride != null) result.statusOverride = statusOverride;
    if (status != null) result.status = status;
    if (statusHint != null) result.statusHint = statusHint;
    if (weight != null) result.weight = weight;
    if (progress != null) result.progress = progress;
    if (version != null) result.version = version;
    if (canEdit != null) result.canEdit = canEdit;
    if (canCheckIn != null) result.canCheckIn = canCheckIn;
    if (contributorIds != null) result.contributorIds.addAll(contributorIds);
    if (childIds != null) result.childIds.addAll(childIds);
    if (keyResults != null) result.keyResults.addAll(keyResults);
    if (createdAt != null) result.createdAt = createdAt;
    return result;
  }

  Goal._();

  factory Goal.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Goal()..mergeFromBuffer(data, registry);
  factory Goal.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Goal()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Goal',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.goals'),
      createEmptyInstance: Goal.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(3, _omitFieldNames ? '' : 'parentId')
    ..aOS(4, _omitFieldNames ? '' : 'folderId')
    ..aOS(5, _omitFieldNames ? '' : 'name')
    ..aOS(6, _omitFieldNames ? '' : 'description')
    ..aOS(7, _omitFieldNames ? '' : 'ownerId')
    ..aOB(8, _omitFieldNames ? '' : 'private')
    ..aOS(9, _omitFieldNames ? '' : 'periodStart')
    ..aOS(10, _omitFieldNames ? '' : 'periodEnd')
    ..aOS(11, _omitFieldNames ? '' : 'statusOverride')
    ..aOS(12, _omitFieldNames ? '' : 'status')
    ..aOS(13, _omitFieldNames ? '' : 'statusHint')
    ..aOS(14, _omitFieldNames ? '' : 'weight')
    ..aD(15, _omitFieldNames ? '' : 'progress', fieldType: $pb.PbFieldType.OF)
    ..aI(16, _omitFieldNames ? '' : 'version')
    ..aOB(17, _omitFieldNames ? '' : 'canEdit')
    ..aOB(18, _omitFieldNames ? '' : 'canCheckIn')
    ..pPS(19, _omitFieldNames ? '' : 'contributorIds')
    ..pPS(20, _omitFieldNames ? '' : 'childIds')
    ..pPM<KeyResult>(21, _omitFieldNames ? '' : 'keyResults',
        subBuilder: KeyResult.$_createMessage)
    ..aOS(22, _omitFieldNames ? '' : 'createdAt')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Goal clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Goal copyWith(void Function(Goal) updates) =>
      super.copyWith((message) => updates(message as Goal)) as Goal;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Goal() / Goal.new instead')
  static Goal create() => Goal._();
  static $pb.GeneratedMessage $_createMessage() => Goal._();
  @$core.override
  Goal createEmptyInstance() => Goal._();
  @$core.pragma('dart2js:noInline')
  static Goal getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Goal>(Goal.$_createMessage);
  static Goal? _defaultInstance;

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
  $core.String get parentId => $_getSZ(2);
  @$pb.TagNumber(3)
  set parentId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasParentId() => $_has(2);
  @$pb.TagNumber(3)
  void clearParentId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get folderId => $_getSZ(3);
  @$pb.TagNumber(4)
  set folderId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasFolderId() => $_has(3);
  @$pb.TagNumber(4)
  void clearFolderId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get name => $_getSZ(4);
  @$pb.TagNumber(5)
  set name($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasName() => $_has(4);
  @$pb.TagNumber(5)
  void clearName() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get description => $_getSZ(5);
  @$pb.TagNumber(6)
  set description($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasDescription() => $_has(5);
  @$pb.TagNumber(6)
  void clearDescription() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get ownerId => $_getSZ(6);
  @$pb.TagNumber(7)
  set ownerId($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasOwnerId() => $_has(6);
  @$pb.TagNumber(7)
  void clearOwnerId() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.bool get private => $_getBF(7);
  @$pb.TagNumber(8)
  set private($core.bool value) => $_setBool(7, value);
  @$pb.TagNumber(8)
  $core.bool hasPrivate() => $_has(7);
  @$pb.TagNumber(8)
  void clearPrivate() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get periodStart => $_getSZ(8);
  @$pb.TagNumber(9)
  set periodStart($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasPeriodStart() => $_has(8);
  @$pb.TagNumber(9)
  void clearPeriodStart() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get periodEnd => $_getSZ(9);
  @$pb.TagNumber(10)
  set periodEnd($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasPeriodEnd() => $_has(9);
  @$pb.TagNumber(10)
  void clearPeriodEnd() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.String get statusOverride => $_getSZ(10);
  @$pb.TagNumber(11)
  set statusOverride($core.String value) => $_setString(10, value);
  @$pb.TagNumber(11)
  $core.bool hasStatusOverride() => $_has(10);
  @$pb.TagNumber(11)
  void clearStatusOverride() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.String get status => $_getSZ(11);
  @$pb.TagNumber(12)
  set status($core.String value) => $_setString(11, value);
  @$pb.TagNumber(12)
  $core.bool hasStatus() => $_has(11);
  @$pb.TagNumber(12)
  void clearStatus() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.String get statusHint => $_getSZ(12);
  @$pb.TagNumber(13)
  set statusHint($core.String value) => $_setString(12, value);
  @$pb.TagNumber(13)
  $core.bool hasStatusHint() => $_has(12);
  @$pb.TagNumber(13)
  void clearStatusHint() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.String get weight => $_getSZ(13);
  @$pb.TagNumber(14)
  set weight($core.String value) => $_setString(13, value);
  @$pb.TagNumber(14)
  $core.bool hasWeight() => $_has(13);
  @$pb.TagNumber(14)
  void clearWeight() => $_clearField(14);

  @$pb.TagNumber(15)
  $core.double get progress => $_getN(14);
  @$pb.TagNumber(15)
  set progress($core.double value) => $_setFloat(14, value);
  @$pb.TagNumber(15)
  $core.bool hasProgress() => $_has(14);
  @$pb.TagNumber(15)
  void clearProgress() => $_clearField(15);

  @$pb.TagNumber(16)
  $core.int get version => $_getIZ(15);
  @$pb.TagNumber(16)
  set version($core.int value) => $_setSignedInt32(15, value);
  @$pb.TagNumber(16)
  $core.bool hasVersion() => $_has(15);
  @$pb.TagNumber(16)
  void clearVersion() => $_clearField(16);

  @$pb.TagNumber(17)
  $core.bool get canEdit => $_getBF(16);
  @$pb.TagNumber(17)
  set canEdit($core.bool value) => $_setBool(16, value);
  @$pb.TagNumber(17)
  $core.bool hasCanEdit() => $_has(16);
  @$pb.TagNumber(17)
  void clearCanEdit() => $_clearField(17);

  @$pb.TagNumber(18)
  $core.bool get canCheckIn => $_getBF(17);
  @$pb.TagNumber(18)
  set canCheckIn($core.bool value) => $_setBool(17, value);
  @$pb.TagNumber(18)
  $core.bool hasCanCheckIn() => $_has(17);
  @$pb.TagNumber(18)
  void clearCanCheckIn() => $_clearField(18);

  @$pb.TagNumber(19)
  $pb.PbList<$core.String> get contributorIds => $_getList(18);

  @$pb.TagNumber(20)
  $pb.PbList<$core.String> get childIds => $_getList(19);

  @$pb.TagNumber(21)
  $pb.PbList<KeyResult> get keyResults => $_getList(20);

  @$pb.TagNumber(22)
  $core.String get createdAt => $_getSZ(21);
  @$pb.TagNumber(22)
  set createdAt($core.String value) => $_setString(21, value);
  @$pb.TagNumber(22)
  $core.bool hasCreatedAt() => $_has(21);
  @$pb.TagNumber(22)
  void clearCreatedAt() => $_clearField(22);
}

class GoalAnswer extends $pb.GeneratedMessage {
  factory GoalAnswer({
    Goal? goal,
  }) {
    final result = GoalAnswer._();
    if (goal != null) result.goal = goal;
    return result;
  }

  GoalAnswer._();

  factory GoalAnswer.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GoalAnswer()..mergeFromBuffer(data, registry);
  factory GoalAnswer.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GoalAnswer()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GoalAnswer',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.goals'),
      createEmptyInstance: GoalAnswer.$_createMessage)
    ..aOM<Goal>(1, _omitFieldNames ? '' : 'goal',
        subBuilder: Goal.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GoalAnswer clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GoalAnswer copyWith(void Function(GoalAnswer) updates) =>
      super.copyWith((message) => updates(message as GoalAnswer)) as GoalAnswer;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GoalAnswer() / GoalAnswer.new instead')
  static GoalAnswer create() => GoalAnswer._();
  static $pb.GeneratedMessage $_createMessage() => GoalAnswer._();
  @$core.override
  GoalAnswer createEmptyInstance() => GoalAnswer._();
  @$core.pragma('dart2js:noInline')
  static GoalAnswer getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GoalAnswer>(GoalAnswer.$_createMessage);
  static GoalAnswer? _defaultInstance;

  @$pb.TagNumber(1)
  Goal get goal => $_getN(0);
  @$pb.TagNumber(1)
  set goal(Goal value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasGoal() => $_has(0);
  @$pb.TagNumber(1)
  void clearGoal() => $_clearField(1);
  @$pb.TagNumber(1)
  Goal ensureGoal() => $_ensure(0);
}

class GoalCreateRequest extends $pb.GeneratedMessage {
  factory GoalCreateRequest({
    $core.String? workspaceId,
    $core.String? name,
    $core.String? description,
    $core.String? ownerId,
    $core.String? parentId,
    $core.String? folderId,
    $core.bool? private,
    $core.String? periodStart,
    $core.String? periodEnd,
    $core.String? statusOverride,
    $core.String? weight,
    $core.Iterable<$core.String>? contributorIds,
  }) {
    final result = GoalCreateRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (name != null) result.name = name;
    if (description != null) result.description = description;
    if (ownerId != null) result.ownerId = ownerId;
    if (parentId != null) result.parentId = parentId;
    if (folderId != null) result.folderId = folderId;
    if (private != null) result.private = private;
    if (periodStart != null) result.periodStart = periodStart;
    if (periodEnd != null) result.periodEnd = periodEnd;
    if (statusOverride != null) result.statusOverride = statusOverride;
    if (weight != null) result.weight = weight;
    if (contributorIds != null) result.contributorIds.addAll(contributorIds);
    return result;
  }

  GoalCreateRequest._();

  factory GoalCreateRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GoalCreateRequest()..mergeFromBuffer(data, registry);
  factory GoalCreateRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GoalCreateRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GoalCreateRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.goals'),
      createEmptyInstance: GoalCreateRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOS(3, _omitFieldNames ? '' : 'description')
    ..aOS(4, _omitFieldNames ? '' : 'ownerId')
    ..aOS(5, _omitFieldNames ? '' : 'parentId')
    ..aOS(6, _omitFieldNames ? '' : 'folderId')
    ..aOB(7, _omitFieldNames ? '' : 'private')
    ..aOS(8, _omitFieldNames ? '' : 'periodStart')
    ..aOS(9, _omitFieldNames ? '' : 'periodEnd')
    ..aOS(10, _omitFieldNames ? '' : 'statusOverride')
    ..aOS(11, _omitFieldNames ? '' : 'weight')
    ..pPS(12, _omitFieldNames ? '' : 'contributorIds')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GoalCreateRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GoalCreateRequest copyWith(void Function(GoalCreateRequest) updates) =>
      super.copyWith((message) => updates(message as GoalCreateRequest))
          as GoalCreateRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GoalCreateRequest() / GoalCreateRequest.new instead')
  static GoalCreateRequest create() => GoalCreateRequest._();
  static $pb.GeneratedMessage $_createMessage() => GoalCreateRequest._();
  @$core.override
  GoalCreateRequest createEmptyInstance() => GoalCreateRequest._();
  @$core.pragma('dart2js:noInline')
  static GoalCreateRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GoalCreateRequest>(
          GoalCreateRequest.$_createMessage);
  static GoalCreateRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);

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

  @$pb.TagNumber(4)
  $core.String get ownerId => $_getSZ(3);
  @$pb.TagNumber(4)
  set ownerId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasOwnerId() => $_has(3);
  @$pb.TagNumber(4)
  void clearOwnerId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get parentId => $_getSZ(4);
  @$pb.TagNumber(5)
  set parentId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasParentId() => $_has(4);
  @$pb.TagNumber(5)
  void clearParentId() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get folderId => $_getSZ(5);
  @$pb.TagNumber(6)
  set folderId($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasFolderId() => $_has(5);
  @$pb.TagNumber(6)
  void clearFolderId() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.bool get private => $_getBF(6);
  @$pb.TagNumber(7)
  set private($core.bool value) => $_setBool(6, value);
  @$pb.TagNumber(7)
  $core.bool hasPrivate() => $_has(6);
  @$pb.TagNumber(7)
  void clearPrivate() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get periodStart => $_getSZ(7);
  @$pb.TagNumber(8)
  set periodStart($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasPeriodStart() => $_has(7);
  @$pb.TagNumber(8)
  void clearPeriodStart() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get periodEnd => $_getSZ(8);
  @$pb.TagNumber(9)
  set periodEnd($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasPeriodEnd() => $_has(8);
  @$pb.TagNumber(9)
  void clearPeriodEnd() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get statusOverride => $_getSZ(9);
  @$pb.TagNumber(10)
  set statusOverride($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasStatusOverride() => $_has(9);
  @$pb.TagNumber(10)
  void clearStatusOverride() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.String get weight => $_getSZ(10);
  @$pb.TagNumber(11)
  set weight($core.String value) => $_setString(10, value);
  @$pb.TagNumber(11)
  $core.bool hasWeight() => $_has(10);
  @$pb.TagNumber(11)
  void clearWeight() => $_clearField(11);

  @$pb.TagNumber(12)
  $pb.PbList<$core.String> get contributorIds => $_getList(11);
}

class GoalDeleteRequest extends $pb.GeneratedMessage {
  factory GoalDeleteRequest({
    $core.String? workspaceId,
    $core.String? goalId,
  }) {
    final result = GoalDeleteRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (goalId != null) result.goalId = goalId;
    return result;
  }

  GoalDeleteRequest._();

  factory GoalDeleteRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GoalDeleteRequest()..mergeFromBuffer(data, registry);
  factory GoalDeleteRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GoalDeleteRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GoalDeleteRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.goals'),
      createEmptyInstance: GoalDeleteRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'goalId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GoalDeleteRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GoalDeleteRequest copyWith(void Function(GoalDeleteRequest) updates) =>
      super.copyWith((message) => updates(message as GoalDeleteRequest))
          as GoalDeleteRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GoalDeleteRequest() / GoalDeleteRequest.new instead')
  static GoalDeleteRequest create() => GoalDeleteRequest._();
  static $pb.GeneratedMessage $_createMessage() => GoalDeleteRequest._();
  @$core.override
  GoalDeleteRequest createEmptyInstance() => GoalDeleteRequest._();
  @$core.pragma('dart2js:noInline')
  static GoalDeleteRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GoalDeleteRequest>(
          GoalDeleteRequest.$_createMessage);
  static GoalDeleteRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get goalId => $_getSZ(1);
  @$pb.TagNumber(2)
  set goalId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasGoalId() => $_has(1);
  @$pb.TagNumber(2)
  void clearGoalId() => $_clearField(2);
}

class GoalDeleted extends $pb.GeneratedMessage {
  factory GoalDeleted({
    $core.String? id,
  }) {
    final result = GoalDeleted._();
    if (id != null) result.id = id;
    return result;
  }

  GoalDeleted._();

  factory GoalDeleted.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GoalDeleted()..mergeFromBuffer(data, registry);
  factory GoalDeleted.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GoalDeleted()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GoalDeleted',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.goals'),
      createEmptyInstance: GoalDeleted.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GoalDeleted clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GoalDeleted copyWith(void Function(GoalDeleted) updates) =>
      super.copyWith((message) => updates(message as GoalDeleted))
          as GoalDeleted;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GoalDeleted() / GoalDeleted.new instead')
  static GoalDeleted create() => GoalDeleted._();
  static $pb.GeneratedMessage $_createMessage() => GoalDeleted._();
  @$core.override
  GoalDeleted createEmptyInstance() => GoalDeleted._();
  @$core.pragma('dart2js:noInline')
  static GoalDeleted getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GoalDeleted>(
          GoalDeleted.$_createMessage);
  static GoalDeleted? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class GoalGetRequest extends $pb.GeneratedMessage {
  factory GoalGetRequest({
    $core.String? workspaceId,
    $core.String? goalId,
  }) {
    final result = GoalGetRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (goalId != null) result.goalId = goalId;
    return result;
  }

  GoalGetRequest._();

  factory GoalGetRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GoalGetRequest()..mergeFromBuffer(data, registry);
  factory GoalGetRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GoalGetRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GoalGetRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.goals'),
      createEmptyInstance: GoalGetRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'goalId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GoalGetRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GoalGetRequest copyWith(void Function(GoalGetRequest) updates) =>
      super.copyWith((message) => updates(message as GoalGetRequest))
          as GoalGetRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GoalGetRequest() / GoalGetRequest.new instead')
  static GoalGetRequest create() => GoalGetRequest._();
  static $pb.GeneratedMessage $_createMessage() => GoalGetRequest._();
  @$core.override
  GoalGetRequest createEmptyInstance() => GoalGetRequest._();
  @$core.pragma('dart2js:noInline')
  static GoalGetRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GoalGetRequest>(
          GoalGetRequest.$_createMessage);
  static GoalGetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get goalId => $_getSZ(1);
  @$pb.TagNumber(2)
  set goalId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasGoalId() => $_has(1);
  @$pb.TagNumber(2)
  void clearGoalId() => $_clearField(2);
}

class GoalList extends $pb.GeneratedMessage {
  factory GoalList({
    $core.Iterable<Goal>? goals,
    $core.Iterable<Folder>? folders,
  }) {
    final result = GoalList._();
    if (goals != null) result.goals.addAll(goals);
    if (folders != null) result.folders.addAll(folders);
    return result;
  }

  GoalList._();

  factory GoalList.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GoalList()..mergeFromBuffer(data, registry);
  factory GoalList.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GoalList()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GoalList',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.goals'),
      createEmptyInstance: GoalList.$_createMessage)
    ..pPM<Goal>(1, _omitFieldNames ? '' : 'goals',
        subBuilder: Goal.$_createMessage)
    ..pPM<Folder>(2, _omitFieldNames ? '' : 'folders',
        subBuilder: Folder.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GoalList clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GoalList copyWith(void Function(GoalList) updates) =>
      super.copyWith((message) => updates(message as GoalList)) as GoalList;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GoalList() / GoalList.new instead')
  static GoalList create() => GoalList._();
  static $pb.GeneratedMessage $_createMessage() => GoalList._();
  @$core.override
  GoalList createEmptyInstance() => GoalList._();
  @$core.pragma('dart2js:noInline')
  static GoalList getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GoalList>(GoalList.$_createMessage);
  static GoalList? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Goal> get goals => $_getList(0);

  @$pb.TagNumber(2)
  $pb.PbList<Folder> get folders => $_getList(1);
}

class GoalListRequest extends $pb.GeneratedMessage {
  factory GoalListRequest({
    $core.String? workspaceId,
  }) {
    final result = GoalListRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    return result;
  }

  GoalListRequest._();

  factory GoalListRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GoalListRequest()..mergeFromBuffer(data, registry);
  factory GoalListRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GoalListRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GoalListRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.goals'),
      createEmptyInstance: GoalListRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GoalListRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GoalListRequest copyWith(void Function(GoalListRequest) updates) =>
      super.copyWith((message) => updates(message as GoalListRequest))
          as GoalListRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GoalListRequest() / GoalListRequest.new instead')
  static GoalListRequest create() => GoalListRequest._();
  static $pb.GeneratedMessage $_createMessage() => GoalListRequest._();
  @$core.override
  GoalListRequest createEmptyInstance() => GoalListRequest._();
  @$core.pragma('dart2js:noInline')
  static GoalListRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GoalListRequest>(
          GoalListRequest.$_createMessage);
  static GoalListRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);
}

class GoalUpdateRequest extends $pb.GeneratedMessage {
  factory GoalUpdateRequest({
    $core.String? workspaceId,
    $core.String? goalId,
    $core.Iterable<$core.String>? changed,
    $core.int? expectedVersion,
    $core.String? name,
    $core.String? description,
    $core.String? ownerId,
    $core.String? parentId,
    $core.String? folderId,
    $core.bool? private,
    $core.String? periodStart,
    $core.String? periodEnd,
    $core.String? statusOverride,
    $core.String? weight,
    $core.Iterable<$core.String>? contributorIds,
  }) {
    final result = GoalUpdateRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (goalId != null) result.goalId = goalId;
    if (changed != null) result.changed.addAll(changed);
    if (expectedVersion != null) result.expectedVersion = expectedVersion;
    if (name != null) result.name = name;
    if (description != null) result.description = description;
    if (ownerId != null) result.ownerId = ownerId;
    if (parentId != null) result.parentId = parentId;
    if (folderId != null) result.folderId = folderId;
    if (private != null) result.private = private;
    if (periodStart != null) result.periodStart = periodStart;
    if (periodEnd != null) result.periodEnd = periodEnd;
    if (statusOverride != null) result.statusOverride = statusOverride;
    if (weight != null) result.weight = weight;
    if (contributorIds != null) result.contributorIds.addAll(contributorIds);
    return result;
  }

  GoalUpdateRequest._();

  factory GoalUpdateRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GoalUpdateRequest()..mergeFromBuffer(data, registry);
  factory GoalUpdateRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GoalUpdateRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GoalUpdateRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.goals'),
      createEmptyInstance: GoalUpdateRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'goalId')
    ..pPS(3, _omitFieldNames ? '' : 'changed')
    ..aI(4, _omitFieldNames ? '' : 'expectedVersion')
    ..aOS(5, _omitFieldNames ? '' : 'name')
    ..aOS(6, _omitFieldNames ? '' : 'description')
    ..aOS(7, _omitFieldNames ? '' : 'ownerId')
    ..aOS(8, _omitFieldNames ? '' : 'parentId')
    ..aOS(9, _omitFieldNames ? '' : 'folderId')
    ..aOB(10, _omitFieldNames ? '' : 'private')
    ..aOS(11, _omitFieldNames ? '' : 'periodStart')
    ..aOS(12, _omitFieldNames ? '' : 'periodEnd')
    ..aOS(13, _omitFieldNames ? '' : 'statusOverride')
    ..aOS(14, _omitFieldNames ? '' : 'weight')
    ..pPS(15, _omitFieldNames ? '' : 'contributorIds')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GoalUpdateRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GoalUpdateRequest copyWith(void Function(GoalUpdateRequest) updates) =>
      super.copyWith((message) => updates(message as GoalUpdateRequest))
          as GoalUpdateRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GoalUpdateRequest() / GoalUpdateRequest.new instead')
  static GoalUpdateRequest create() => GoalUpdateRequest._();
  static $pb.GeneratedMessage $_createMessage() => GoalUpdateRequest._();
  @$core.override
  GoalUpdateRequest createEmptyInstance() => GoalUpdateRequest._();
  @$core.pragma('dart2js:noInline')
  static GoalUpdateRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GoalUpdateRequest>(
          GoalUpdateRequest.$_createMessage);
  static GoalUpdateRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get goalId => $_getSZ(1);
  @$pb.TagNumber(2)
  set goalId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasGoalId() => $_has(1);
  @$pb.TagNumber(2)
  void clearGoalId() => $_clearField(2);

  @$pb.TagNumber(3)
  $pb.PbList<$core.String> get changed => $_getList(2);

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
  $core.String get description => $_getSZ(5);
  @$pb.TagNumber(6)
  set description($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasDescription() => $_has(5);
  @$pb.TagNumber(6)
  void clearDescription() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get ownerId => $_getSZ(6);
  @$pb.TagNumber(7)
  set ownerId($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasOwnerId() => $_has(6);
  @$pb.TagNumber(7)
  void clearOwnerId() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get parentId => $_getSZ(7);
  @$pb.TagNumber(8)
  set parentId($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasParentId() => $_has(7);
  @$pb.TagNumber(8)
  void clearParentId() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get folderId => $_getSZ(8);
  @$pb.TagNumber(9)
  set folderId($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasFolderId() => $_has(8);
  @$pb.TagNumber(9)
  void clearFolderId() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.bool get private => $_getBF(9);
  @$pb.TagNumber(10)
  set private($core.bool value) => $_setBool(9, value);
  @$pb.TagNumber(10)
  $core.bool hasPrivate() => $_has(9);
  @$pb.TagNumber(10)
  void clearPrivate() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.String get periodStart => $_getSZ(10);
  @$pb.TagNumber(11)
  set periodStart($core.String value) => $_setString(10, value);
  @$pb.TagNumber(11)
  $core.bool hasPeriodStart() => $_has(10);
  @$pb.TagNumber(11)
  void clearPeriodStart() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.String get periodEnd => $_getSZ(11);
  @$pb.TagNumber(12)
  set periodEnd($core.String value) => $_setString(11, value);
  @$pb.TagNumber(12)
  $core.bool hasPeriodEnd() => $_has(11);
  @$pb.TagNumber(12)
  void clearPeriodEnd() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.String get statusOverride => $_getSZ(12);
  @$pb.TagNumber(13)
  set statusOverride($core.String value) => $_setString(12, value);
  @$pb.TagNumber(13)
  $core.bool hasStatusOverride() => $_has(12);
  @$pb.TagNumber(13)
  void clearStatusOverride() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.String get weight => $_getSZ(13);
  @$pb.TagNumber(14)
  set weight($core.String value) => $_setString(13, value);
  @$pb.TagNumber(14)
  $core.bool hasWeight() => $_has(13);
  @$pb.TagNumber(14)
  void clearWeight() => $_clearField(14);

  @$pb.TagNumber(15)
  $pb.PbList<$core.String> get contributorIds => $_getList(14);
}

class KeyResult extends $pb.GeneratedMessage {
  factory KeyResult({
    $core.String? id,
    $core.String? goalId,
    $core.String? name,
    $core.String? type,
    $core.String? startValue,
    $core.String? targetValue,
    $core.String? currentValue,
    $core.String? filterText,
    $core.Iterable<$core.String>? taskIds,
    $core.String? weight,
    $core.int? linkedDone,
    $core.int? linkedTotal,
    $core.double? progress,
    $core.int? position,
    $core.int? version,
  }) {
    final result = KeyResult._();
    if (id != null) result.id = id;
    if (goalId != null) result.goalId = goalId;
    if (name != null) result.name = name;
    if (type != null) result.type = type;
    if (startValue != null) result.startValue = startValue;
    if (targetValue != null) result.targetValue = targetValue;
    if (currentValue != null) result.currentValue = currentValue;
    if (filterText != null) result.filterText = filterText;
    if (taskIds != null) result.taskIds.addAll(taskIds);
    if (weight != null) result.weight = weight;
    if (linkedDone != null) result.linkedDone = linkedDone;
    if (linkedTotal != null) result.linkedTotal = linkedTotal;
    if (progress != null) result.progress = progress;
    if (position != null) result.position = position;
    if (version != null) result.version = version;
    return result;
  }

  KeyResult._();

  factory KeyResult.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      KeyResult()..mergeFromBuffer(data, registry);
  factory KeyResult.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      KeyResult()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'KeyResult',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.goals'),
      createEmptyInstance: KeyResult.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'goalId')
    ..aOS(3, _omitFieldNames ? '' : 'name')
    ..aOS(4, _omitFieldNames ? '' : 'type')
    ..aOS(5, _omitFieldNames ? '' : 'startValue')
    ..aOS(6, _omitFieldNames ? '' : 'targetValue')
    ..aOS(7, _omitFieldNames ? '' : 'currentValue')
    ..aOS(8, _omitFieldNames ? '' : 'filterText')
    ..pPS(9, _omitFieldNames ? '' : 'taskIds')
    ..aOS(10, _omitFieldNames ? '' : 'weight')
    ..aI(11, _omitFieldNames ? '' : 'linkedDone')
    ..aI(12, _omitFieldNames ? '' : 'linkedTotal')
    ..aD(13, _omitFieldNames ? '' : 'progress', fieldType: $pb.PbFieldType.OF)
    ..aI(14, _omitFieldNames ? '' : 'position')
    ..aI(15, _omitFieldNames ? '' : 'version')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  KeyResult clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  KeyResult copyWith(void Function(KeyResult) updates) =>
      super.copyWith((message) => updates(message as KeyResult)) as KeyResult;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use KeyResult() / KeyResult.new instead')
  static KeyResult create() => KeyResult._();
  static $pb.GeneratedMessage $_createMessage() => KeyResult._();
  @$core.override
  KeyResult createEmptyInstance() => KeyResult._();
  @$core.pragma('dart2js:noInline')
  static KeyResult getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<KeyResult>(KeyResult.$_createMessage);
  static KeyResult? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get goalId => $_getSZ(1);
  @$pb.TagNumber(2)
  set goalId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasGoalId() => $_has(1);
  @$pb.TagNumber(2)
  void clearGoalId() => $_clearField(2);

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
  $core.String get startValue => $_getSZ(4);
  @$pb.TagNumber(5)
  set startValue($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasStartValue() => $_has(4);
  @$pb.TagNumber(5)
  void clearStartValue() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get targetValue => $_getSZ(5);
  @$pb.TagNumber(6)
  set targetValue($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasTargetValue() => $_has(5);
  @$pb.TagNumber(6)
  void clearTargetValue() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get currentValue => $_getSZ(6);
  @$pb.TagNumber(7)
  set currentValue($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasCurrentValue() => $_has(6);
  @$pb.TagNumber(7)
  void clearCurrentValue() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get filterText => $_getSZ(7);
  @$pb.TagNumber(8)
  set filterText($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasFilterText() => $_has(7);
  @$pb.TagNumber(8)
  void clearFilterText() => $_clearField(8);

  @$pb.TagNumber(9)
  $pb.PbList<$core.String> get taskIds => $_getList(8);

  @$pb.TagNumber(10)
  $core.String get weight => $_getSZ(9);
  @$pb.TagNumber(10)
  set weight($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasWeight() => $_has(9);
  @$pb.TagNumber(10)
  void clearWeight() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.int get linkedDone => $_getIZ(10);
  @$pb.TagNumber(11)
  set linkedDone($core.int value) => $_setSignedInt32(10, value);
  @$pb.TagNumber(11)
  $core.bool hasLinkedDone() => $_has(10);
  @$pb.TagNumber(11)
  void clearLinkedDone() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.int get linkedTotal => $_getIZ(11);
  @$pb.TagNumber(12)
  set linkedTotal($core.int value) => $_setSignedInt32(11, value);
  @$pb.TagNumber(12)
  $core.bool hasLinkedTotal() => $_has(11);
  @$pb.TagNumber(12)
  void clearLinkedTotal() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.double get progress => $_getN(12);
  @$pb.TagNumber(13)
  set progress($core.double value) => $_setFloat(12, value);
  @$pb.TagNumber(13)
  $core.bool hasProgress() => $_has(12);
  @$pb.TagNumber(13)
  void clearProgress() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.int get position => $_getIZ(13);
  @$pb.TagNumber(14)
  set position($core.int value) => $_setSignedInt32(13, value);
  @$pb.TagNumber(14)
  $core.bool hasPosition() => $_has(13);
  @$pb.TagNumber(14)
  void clearPosition() => $_clearField(14);

  @$pb.TagNumber(15)
  $core.int get version => $_getIZ(14);
  @$pb.TagNumber(15)
  set version($core.int value) => $_setSignedInt32(14, value);
  @$pb.TagNumber(15)
  $core.bool hasVersion() => $_has(14);
  @$pb.TagNumber(15)
  void clearVersion() => $_clearField(15);
}

class KeyResultCreateRequest extends $pb.GeneratedMessage {
  factory KeyResultCreateRequest({
    $core.String? workspaceId,
    $core.String? goalId,
    $core.String? type,
    $core.String? currentValue,
    $core.String? name,
    $core.String? startValue,
    $core.String? targetValue,
    $core.String? weight,
    $core.String? filterText,
    $core.Iterable<$core.String>? taskIds,
    $core.int? position,
  }) {
    final result = KeyResultCreateRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (goalId != null) result.goalId = goalId;
    if (type != null) result.type = type;
    if (currentValue != null) result.currentValue = currentValue;
    if (name != null) result.name = name;
    if (startValue != null) result.startValue = startValue;
    if (targetValue != null) result.targetValue = targetValue;
    if (weight != null) result.weight = weight;
    if (filterText != null) result.filterText = filterText;
    if (taskIds != null) result.taskIds.addAll(taskIds);
    if (position != null) result.position = position;
    return result;
  }

  KeyResultCreateRequest._();

  factory KeyResultCreateRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      KeyResultCreateRequest()..mergeFromBuffer(data, registry);
  factory KeyResultCreateRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      KeyResultCreateRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'KeyResultCreateRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.goals'),
      createEmptyInstance: KeyResultCreateRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'goalId')
    ..aOS(3, _omitFieldNames ? '' : 'type')
    ..aOS(4, _omitFieldNames ? '' : 'currentValue')
    ..aOS(5, _omitFieldNames ? '' : 'name')
    ..aOS(6, _omitFieldNames ? '' : 'startValue')
    ..aOS(7, _omitFieldNames ? '' : 'targetValue')
    ..aOS(8, _omitFieldNames ? '' : 'weight')
    ..aOS(9, _omitFieldNames ? '' : 'filterText')
    ..pPS(10, _omitFieldNames ? '' : 'taskIds')
    ..aI(11, _omitFieldNames ? '' : 'position')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  KeyResultCreateRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  KeyResultCreateRequest copyWith(
          void Function(KeyResultCreateRequest) updates) =>
      super.copyWith((message) => updates(message as KeyResultCreateRequest))
          as KeyResultCreateRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use KeyResultCreateRequest() / KeyResultCreateRequest.new instead')
  static KeyResultCreateRequest create() => KeyResultCreateRequest._();
  static $pb.GeneratedMessage $_createMessage() => KeyResultCreateRequest._();
  @$core.override
  KeyResultCreateRequest createEmptyInstance() => KeyResultCreateRequest._();
  @$core.pragma('dart2js:noInline')
  static KeyResultCreateRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<KeyResultCreateRequest>(
          KeyResultCreateRequest.$_createMessage);
  static KeyResultCreateRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get goalId => $_getSZ(1);
  @$pb.TagNumber(2)
  set goalId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasGoalId() => $_has(1);
  @$pb.TagNumber(2)
  void clearGoalId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get type => $_getSZ(2);
  @$pb.TagNumber(3)
  set type($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasType() => $_has(2);
  @$pb.TagNumber(3)
  void clearType() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get currentValue => $_getSZ(3);
  @$pb.TagNumber(4)
  set currentValue($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasCurrentValue() => $_has(3);
  @$pb.TagNumber(4)
  void clearCurrentValue() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get name => $_getSZ(4);
  @$pb.TagNumber(5)
  set name($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasName() => $_has(4);
  @$pb.TagNumber(5)
  void clearName() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get startValue => $_getSZ(5);
  @$pb.TagNumber(6)
  set startValue($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasStartValue() => $_has(5);
  @$pb.TagNumber(6)
  void clearStartValue() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get targetValue => $_getSZ(6);
  @$pb.TagNumber(7)
  set targetValue($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasTargetValue() => $_has(6);
  @$pb.TagNumber(7)
  void clearTargetValue() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get weight => $_getSZ(7);
  @$pb.TagNumber(8)
  set weight($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasWeight() => $_has(7);
  @$pb.TagNumber(8)
  void clearWeight() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get filterText => $_getSZ(8);
  @$pb.TagNumber(9)
  set filterText($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasFilterText() => $_has(8);
  @$pb.TagNumber(9)
  void clearFilterText() => $_clearField(9);

  @$pb.TagNumber(10)
  $pb.PbList<$core.String> get taskIds => $_getList(9);

  @$pb.TagNumber(11)
  $core.int get position => $_getIZ(10);
  @$pb.TagNumber(11)
  set position($core.int value) => $_setSignedInt32(10, value);
  @$pb.TagNumber(11)
  $core.bool hasPosition() => $_has(10);
  @$pb.TagNumber(11)
  void clearPosition() => $_clearField(11);
}

class KeyResultDeleteRequest extends $pb.GeneratedMessage {
  factory KeyResultDeleteRequest({
    $core.String? workspaceId,
    $core.String? krId,
  }) {
    final result = KeyResultDeleteRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (krId != null) result.krId = krId;
    return result;
  }

  KeyResultDeleteRequest._();

  factory KeyResultDeleteRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      KeyResultDeleteRequest()..mergeFromBuffer(data, registry);
  factory KeyResultDeleteRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      KeyResultDeleteRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'KeyResultDeleteRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.goals'),
      createEmptyInstance: KeyResultDeleteRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'krId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  KeyResultDeleteRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  KeyResultDeleteRequest copyWith(
          void Function(KeyResultDeleteRequest) updates) =>
      super.copyWith((message) => updates(message as KeyResultDeleteRequest))
          as KeyResultDeleteRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use KeyResultDeleteRequest() / KeyResultDeleteRequest.new instead')
  static KeyResultDeleteRequest create() => KeyResultDeleteRequest._();
  static $pb.GeneratedMessage $_createMessage() => KeyResultDeleteRequest._();
  @$core.override
  KeyResultDeleteRequest createEmptyInstance() => KeyResultDeleteRequest._();
  @$core.pragma('dart2js:noInline')
  static KeyResultDeleteRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<KeyResultDeleteRequest>(
          KeyResultDeleteRequest.$_createMessage);
  static KeyResultDeleteRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get krId => $_getSZ(1);
  @$pb.TagNumber(2)
  set krId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasKrId() => $_has(1);
  @$pb.TagNumber(2)
  void clearKrId() => $_clearField(2);
}

class KeyResultUpdateRequest extends $pb.GeneratedMessage {
  factory KeyResultUpdateRequest({
    $core.String? workspaceId,
    $core.String? krId,
    $core.Iterable<$core.String>? changed,
    $core.int? expectedVersion,
    $core.String? name,
    $core.String? startValue,
    $core.String? targetValue,
    $core.String? weight,
    $core.String? filterText,
    $core.Iterable<$core.String>? taskIds,
    $core.int? position,
  }) {
    final result = KeyResultUpdateRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (krId != null) result.krId = krId;
    if (changed != null) result.changed.addAll(changed);
    if (expectedVersion != null) result.expectedVersion = expectedVersion;
    if (name != null) result.name = name;
    if (startValue != null) result.startValue = startValue;
    if (targetValue != null) result.targetValue = targetValue;
    if (weight != null) result.weight = weight;
    if (filterText != null) result.filterText = filterText;
    if (taskIds != null) result.taskIds.addAll(taskIds);
    if (position != null) result.position = position;
    return result;
  }

  KeyResultUpdateRequest._();

  factory KeyResultUpdateRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      KeyResultUpdateRequest()..mergeFromBuffer(data, registry);
  factory KeyResultUpdateRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      KeyResultUpdateRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'KeyResultUpdateRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.goals'),
      createEmptyInstance: KeyResultUpdateRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'krId')
    ..pPS(3, _omitFieldNames ? '' : 'changed')
    ..aI(4, _omitFieldNames ? '' : 'expectedVersion')
    ..aOS(5, _omitFieldNames ? '' : 'name')
    ..aOS(6, _omitFieldNames ? '' : 'startValue')
    ..aOS(7, _omitFieldNames ? '' : 'targetValue')
    ..aOS(8, _omitFieldNames ? '' : 'weight')
    ..aOS(9, _omitFieldNames ? '' : 'filterText')
    ..pPS(10, _omitFieldNames ? '' : 'taskIds')
    ..aI(11, _omitFieldNames ? '' : 'position')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  KeyResultUpdateRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  KeyResultUpdateRequest copyWith(
          void Function(KeyResultUpdateRequest) updates) =>
      super.copyWith((message) => updates(message as KeyResultUpdateRequest))
          as KeyResultUpdateRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use KeyResultUpdateRequest() / KeyResultUpdateRequest.new instead')
  static KeyResultUpdateRequest create() => KeyResultUpdateRequest._();
  static $pb.GeneratedMessage $_createMessage() => KeyResultUpdateRequest._();
  @$core.override
  KeyResultUpdateRequest createEmptyInstance() => KeyResultUpdateRequest._();
  @$core.pragma('dart2js:noInline')
  static KeyResultUpdateRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<KeyResultUpdateRequest>(
          KeyResultUpdateRequest.$_createMessage);
  static KeyResultUpdateRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get krId => $_getSZ(1);
  @$pb.TagNumber(2)
  set krId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasKrId() => $_has(1);
  @$pb.TagNumber(2)
  void clearKrId() => $_clearField(2);

  @$pb.TagNumber(3)
  $pb.PbList<$core.String> get changed => $_getList(2);

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
  $core.String get startValue => $_getSZ(5);
  @$pb.TagNumber(6)
  set startValue($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasStartValue() => $_has(5);
  @$pb.TagNumber(6)
  void clearStartValue() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get targetValue => $_getSZ(6);
  @$pb.TagNumber(7)
  set targetValue($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasTargetValue() => $_has(6);
  @$pb.TagNumber(7)
  void clearTargetValue() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get weight => $_getSZ(7);
  @$pb.TagNumber(8)
  set weight($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasWeight() => $_has(7);
  @$pb.TagNumber(8)
  void clearWeight() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get filterText => $_getSZ(8);
  @$pb.TagNumber(9)
  set filterText($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasFilterText() => $_has(8);
  @$pb.TagNumber(9)
  void clearFilterText() => $_clearField(9);

  @$pb.TagNumber(10)
  $pb.PbList<$core.String> get taskIds => $_getList(9);

  @$pb.TagNumber(11)
  $core.int get position => $_getIZ(10);
  @$pb.TagNumber(11)
  set position($core.int value) => $_setSignedInt32(10, value);
  @$pb.TagNumber(11)
  $core.bool hasPosition() => $_has(10);
  @$pb.TagNumber(11)
  void clearPosition() => $_clearField(11);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
