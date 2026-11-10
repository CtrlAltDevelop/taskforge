// This is a generated file - do not edit.
//
// Generated from infrastructure/workflows/grpc/workflows.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class MigrationInput extends $pb.GeneratedMessage {
  factory MigrationInput({
    $core.String? fromKey,
    $core.String? toKey,
  }) {
    final result = MigrationInput._();
    if (fromKey != null) result.fromKey = fromKey;
    if (toKey != null) result.toKey = toKey;
    return result;
  }

  MigrationInput._();

  factory MigrationInput.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MigrationInput()..mergeFromBuffer(data, registry);
  factory MigrationInput.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MigrationInput()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MigrationInput',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.workflows'),
      createEmptyInstance: MigrationInput.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'fromKey')
    ..aOS(2, _omitFieldNames ? '' : 'toKey')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MigrationInput clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MigrationInput copyWith(void Function(MigrationInput) updates) =>
      super.copyWith((message) => updates(message as MigrationInput))
          as MigrationInput;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use MigrationInput() / MigrationInput.new instead')
  static MigrationInput create() => MigrationInput._();
  static $pb.GeneratedMessage $_createMessage() => MigrationInput._();
  @$core.override
  MigrationInput createEmptyInstance() => MigrationInput._();
  @$core.pragma('dart2js:noInline')
  static MigrationInput getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MigrationInput>(
          MigrationInput.$_createMessage);
  static MigrationInput? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get fromKey => $_getSZ(0);
  @$pb.TagNumber(1)
  set fromKey($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFromKey() => $_has(0);
  @$pb.TagNumber(1)
  void clearFromKey() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get toKey => $_getSZ(1);
  @$pb.TagNumber(2)
  set toKey($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasToKey() => $_has(1);
  @$pb.TagNumber(2)
  void clearToKey() => $_clearField(2);
}

class StatusInput extends $pb.GeneratedMessage {
  factory StatusInput({
    $core.String? key,
    $core.String? name,
    $core.String? color,
    $core.String? category,
    $core.bool? isDefault,
  }) {
    final result = StatusInput._();
    if (key != null) result.key = key;
    if (name != null) result.name = name;
    if (color != null) result.color = color;
    if (category != null) result.category = category;
    if (isDefault != null) result.isDefault = isDefault;
    return result;
  }

  StatusInput._();

  factory StatusInput.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      StatusInput()..mergeFromBuffer(data, registry);
  factory StatusInput.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      StatusInput()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'StatusInput',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.workflows'),
      createEmptyInstance: StatusInput.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'key')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOS(3, _omitFieldNames ? '' : 'color')
    ..aOS(4, _omitFieldNames ? '' : 'category')
    ..aOB(5, _omitFieldNames ? '' : 'isDefault')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StatusInput clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StatusInput copyWith(void Function(StatusInput) updates) =>
      super.copyWith((message) => updates(message as StatusInput))
          as StatusInput;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use StatusInput() / StatusInput.new instead')
  static StatusInput create() => StatusInput._();
  static $pb.GeneratedMessage $_createMessage() => StatusInput._();
  @$core.override
  StatusInput createEmptyInstance() => StatusInput._();
  @$core.pragma('dart2js:noInline')
  static StatusInput getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<StatusInput>(
          StatusInput.$_createMessage);
  static StatusInput? _defaultInstance;

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
  $core.String get color => $_getSZ(2);
  @$pb.TagNumber(3)
  set color($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasColor() => $_has(2);
  @$pb.TagNumber(3)
  void clearColor() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get category => $_getSZ(3);
  @$pb.TagNumber(4)
  set category($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasCategory() => $_has(3);
  @$pb.TagNumber(4)
  void clearCategory() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.bool get isDefault => $_getBF(4);
  @$pb.TagNumber(5)
  set isDefault($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasIsDefault() => $_has(4);
  @$pb.TagNumber(5)
  void clearIsDefault() => $_clearField(5);
}

class StatusResponse extends $pb.GeneratedMessage {
  factory StatusResponse({
    $core.String? id,
    $core.String? name,
    $core.String? color,
    $core.String? category,
    $core.int? position,
    $core.bool? isDefault,
    $core.int? taskCount,
  }) {
    final result = StatusResponse._();
    if (id != null) result.id = id;
    if (name != null) result.name = name;
    if (color != null) result.color = color;
    if (category != null) result.category = category;
    if (position != null) result.position = position;
    if (isDefault != null) result.isDefault = isDefault;
    if (taskCount != null) result.taskCount = taskCount;
    return result;
  }

  StatusResponse._();

  factory StatusResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      StatusResponse()..mergeFromBuffer(data, registry);
  factory StatusResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      StatusResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'StatusResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.workflows'),
      createEmptyInstance: StatusResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOS(3, _omitFieldNames ? '' : 'color')
    ..aOS(4, _omitFieldNames ? '' : 'category')
    ..aI(5, _omitFieldNames ? '' : 'position')
    ..aOB(6, _omitFieldNames ? '' : 'isDefault')
    ..aI(7, _omitFieldNames ? '' : 'taskCount')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StatusResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StatusResponse copyWith(void Function(StatusResponse) updates) =>
      super.copyWith((message) => updates(message as StatusResponse))
          as StatusResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use StatusResponse() / StatusResponse.new instead')
  static StatusResponse create() => StatusResponse._();
  static $pb.GeneratedMessage $_createMessage() => StatusResponse._();
  @$core.override
  StatusResponse createEmptyInstance() => StatusResponse._();
  @$core.pragma('dart2js:noInline')
  static StatusResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<StatusResponse>(
          StatusResponse.$_createMessage);
  static StatusResponse? _defaultInstance;

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
  $core.String get color => $_getSZ(2);
  @$pb.TagNumber(3)
  set color($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasColor() => $_has(2);
  @$pb.TagNumber(3)
  void clearColor() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get category => $_getSZ(3);
  @$pb.TagNumber(4)
  set category($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasCategory() => $_has(3);
  @$pb.TagNumber(4)
  void clearCategory() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get position => $_getIZ(4);
  @$pb.TagNumber(5)
  set position($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasPosition() => $_has(4);
  @$pb.TagNumber(5)
  void clearPosition() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.bool get isDefault => $_getBF(5);
  @$pb.TagNumber(6)
  set isDefault($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasIsDefault() => $_has(5);
  @$pb.TagNumber(6)
  void clearIsDefault() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.int get taskCount => $_getIZ(6);
  @$pb.TagNumber(7)
  set taskCount($core.int value) => $_setSignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasTaskCount() => $_has(6);
  @$pb.TagNumber(7)
  void clearTaskCount() => $_clearField(7);
}

class TransitionInput extends $pb.GeneratedMessage {
  factory TransitionInput({
    $core.String? fromKey,
    $core.String? toKey,
    $core.String? requiredRoleId,
    $core.bool? requireAssignee,
    $core.bool? requireSubtasksDone,
  }) {
    final result = TransitionInput._();
    if (fromKey != null) result.fromKey = fromKey;
    if (toKey != null) result.toKey = toKey;
    if (requiredRoleId != null) result.requiredRoleId = requiredRoleId;
    if (requireAssignee != null) result.requireAssignee = requireAssignee;
    if (requireSubtasksDone != null)
      result.requireSubtasksDone = requireSubtasksDone;
    return result;
  }

  TransitionInput._();

  factory TransitionInput.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TransitionInput()..mergeFromBuffer(data, registry);
  factory TransitionInput.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TransitionInput()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TransitionInput',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.workflows'),
      createEmptyInstance: TransitionInput.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'fromKey')
    ..aOS(2, _omitFieldNames ? '' : 'toKey')
    ..aOS(3, _omitFieldNames ? '' : 'requiredRoleId')
    ..aOB(4, _omitFieldNames ? '' : 'requireAssignee')
    ..aOB(5, _omitFieldNames ? '' : 'requireSubtasksDone')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TransitionInput clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TransitionInput copyWith(void Function(TransitionInput) updates) =>
      super.copyWith((message) => updates(message as TransitionInput))
          as TransitionInput;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use TransitionInput() / TransitionInput.new instead')
  static TransitionInput create() => TransitionInput._();
  static $pb.GeneratedMessage $_createMessage() => TransitionInput._();
  @$core.override
  TransitionInput createEmptyInstance() => TransitionInput._();
  @$core.pragma('dart2js:noInline')
  static TransitionInput getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TransitionInput>(
          TransitionInput.$_createMessage);
  static TransitionInput? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get fromKey => $_getSZ(0);
  @$pb.TagNumber(1)
  set fromKey($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFromKey() => $_has(0);
  @$pb.TagNumber(1)
  void clearFromKey() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get toKey => $_getSZ(1);
  @$pb.TagNumber(2)
  set toKey($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasToKey() => $_has(1);
  @$pb.TagNumber(2)
  void clearToKey() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get requiredRoleId => $_getSZ(2);
  @$pb.TagNumber(3)
  set requiredRoleId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRequiredRoleId() => $_has(2);
  @$pb.TagNumber(3)
  void clearRequiredRoleId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get requireAssignee => $_getBF(3);
  @$pb.TagNumber(4)
  set requireAssignee($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasRequireAssignee() => $_has(3);
  @$pb.TagNumber(4)
  void clearRequireAssignee() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.bool get requireSubtasksDone => $_getBF(4);
  @$pb.TagNumber(5)
  set requireSubtasksDone($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasRequireSubtasksDone() => $_has(4);
  @$pb.TagNumber(5)
  void clearRequireSubtasksDone() => $_clearField(5);
}

class TransitionResponse extends $pb.GeneratedMessage {
  factory TransitionResponse({
    $core.String? fromStatus,
    $core.String? toStatus,
    $core.String? requiredRoleId,
    $core.bool? requireAssignee,
    $core.bool? requireSubtasksDone,
  }) {
    final result = TransitionResponse._();
    if (fromStatus != null) result.fromStatus = fromStatus;
    if (toStatus != null) result.toStatus = toStatus;
    if (requiredRoleId != null) result.requiredRoleId = requiredRoleId;
    if (requireAssignee != null) result.requireAssignee = requireAssignee;
    if (requireSubtasksDone != null)
      result.requireSubtasksDone = requireSubtasksDone;
    return result;
  }

  TransitionResponse._();

  factory TransitionResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TransitionResponse()..mergeFromBuffer(data, registry);
  factory TransitionResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TransitionResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TransitionResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.workflows'),
      createEmptyInstance: TransitionResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'fromStatus')
    ..aOS(2, _omitFieldNames ? '' : 'toStatus')
    ..aOS(3, _omitFieldNames ? '' : 'requiredRoleId')
    ..aOB(4, _omitFieldNames ? '' : 'requireAssignee')
    ..aOB(5, _omitFieldNames ? '' : 'requireSubtasksDone')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TransitionResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TransitionResponse copyWith(void Function(TransitionResponse) updates) =>
      super.copyWith((message) => updates(message as TransitionResponse))
          as TransitionResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use TransitionResponse() / TransitionResponse.new instead')
  static TransitionResponse create() => TransitionResponse._();
  static $pb.GeneratedMessage $_createMessage() => TransitionResponse._();
  @$core.override
  TransitionResponse createEmptyInstance() => TransitionResponse._();
  @$core.pragma('dart2js:noInline')
  static TransitionResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TransitionResponse>(
          TransitionResponse.$_createMessage);
  static TransitionResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get fromStatus => $_getSZ(0);
  @$pb.TagNumber(1)
  set fromStatus($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFromStatus() => $_has(0);
  @$pb.TagNumber(1)
  void clearFromStatus() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get toStatus => $_getSZ(1);
  @$pb.TagNumber(2)
  set toStatus($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasToStatus() => $_has(1);
  @$pb.TagNumber(2)
  void clearToStatus() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get requiredRoleId => $_getSZ(2);
  @$pb.TagNumber(3)
  set requiredRoleId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRequiredRoleId() => $_has(2);
  @$pb.TagNumber(3)
  void clearRequiredRoleId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get requireAssignee => $_getBF(3);
  @$pb.TagNumber(4)
  set requireAssignee($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasRequireAssignee() => $_has(3);
  @$pb.TagNumber(4)
  void clearRequireAssignee() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.bool get requireSubtasksDone => $_getBF(4);
  @$pb.TagNumber(5)
  set requireSubtasksDone($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasRequireSubtasksDone() => $_has(4);
  @$pb.TagNumber(5)
  void clearRequireSubtasksDone() => $_clearField(5);
}

class Workflow extends $pb.GeneratedMessage {
  factory Workflow({
    $core.String? projectId,
    $core.bool? restrictTransitions,
    $core.int? version,
    $core.Iterable<StatusResponse>? statuses,
    $core.Iterable<TransitionResponse>? transitions,
    $core.bool? restrictCreation,
  }) {
    final result = Workflow._();
    if (projectId != null) result.projectId = projectId;
    if (restrictTransitions != null)
      result.restrictTransitions = restrictTransitions;
    if (version != null) result.version = version;
    if (statuses != null) result.statuses.addAll(statuses);
    if (transitions != null) result.transitions.addAll(transitions);
    if (restrictCreation != null) result.restrictCreation = restrictCreation;
    return result;
  }

  Workflow._();

  factory Workflow.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Workflow()..mergeFromBuffer(data, registry);
  factory Workflow.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Workflow()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Workflow',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.workflows'),
      createEmptyInstance: Workflow.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'projectId')
    ..aOB(2, _omitFieldNames ? '' : 'restrictTransitions')
    ..aI(3, _omitFieldNames ? '' : 'version')
    ..pPM<StatusResponse>(4, _omitFieldNames ? '' : 'statuses',
        subBuilder: StatusResponse.$_createMessage)
    ..pPM<TransitionResponse>(5, _omitFieldNames ? '' : 'transitions',
        subBuilder: TransitionResponse.$_createMessage)
    ..aOB(6, _omitFieldNames ? '' : 'restrictCreation')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Workflow clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Workflow copyWith(void Function(Workflow) updates) =>
      super.copyWith((message) => updates(message as Workflow)) as Workflow;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Workflow() / Workflow.new instead')
  static Workflow create() => Workflow._();
  static $pb.GeneratedMessage $_createMessage() => Workflow._();
  @$core.override
  Workflow createEmptyInstance() => Workflow._();
  @$core.pragma('dart2js:noInline')
  static Workflow getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Workflow>(Workflow.$_createMessage);
  static Workflow? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get projectId => $_getSZ(0);
  @$pb.TagNumber(1)
  set projectId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasProjectId() => $_has(0);
  @$pb.TagNumber(1)
  void clearProjectId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get restrictTransitions => $_getBF(1);
  @$pb.TagNumber(2)
  set restrictTransitions($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRestrictTransitions() => $_has(1);
  @$pb.TagNumber(2)
  void clearRestrictTransitions() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get version => $_getIZ(2);
  @$pb.TagNumber(3)
  set version($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasVersion() => $_has(2);
  @$pb.TagNumber(3)
  void clearVersion() => $_clearField(3);

  @$pb.TagNumber(4)
  $pb.PbList<StatusResponse> get statuses => $_getList(3);

  @$pb.TagNumber(5)
  $pb.PbList<TransitionResponse> get transitions => $_getList(4);

  @$pb.TagNumber(6)
  $core.bool get restrictCreation => $_getBF(5);
  @$pb.TagNumber(6)
  set restrictCreation($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasRestrictCreation() => $_has(5);
  @$pb.TagNumber(6)
  void clearRestrictCreation() => $_clearField(6);
}

class WorkflowGetRequest extends $pb.GeneratedMessage {
  factory WorkflowGetRequest({
    $core.String? workspaceId,
    $core.String? projectId,
  }) {
    final result = WorkflowGetRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (projectId != null) result.projectId = projectId;
    return result;
  }

  WorkflowGetRequest._();

  factory WorkflowGetRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WorkflowGetRequest()..mergeFromBuffer(data, registry);
  factory WorkflowGetRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WorkflowGetRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WorkflowGetRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.workflows'),
      createEmptyInstance: WorkflowGetRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WorkflowGetRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WorkflowGetRequest copyWith(void Function(WorkflowGetRequest) updates) =>
      super.copyWith((message) => updates(message as WorkflowGetRequest))
          as WorkflowGetRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use WorkflowGetRequest() / WorkflowGetRequest.new instead')
  static WorkflowGetRequest create() => WorkflowGetRequest._();
  static $pb.GeneratedMessage $_createMessage() => WorkflowGetRequest._();
  @$core.override
  WorkflowGetRequest createEmptyInstance() => WorkflowGetRequest._();
  @$core.pragma('dart2js:noInline')
  static WorkflowGetRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WorkflowGetRequest>(
          WorkflowGetRequest.$_createMessage);
  static WorkflowGetRequest? _defaultInstance;

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

class WorkflowProblem extends $pb.GeneratedMessage {
  factory WorkflowProblem({
    $core.String? code,
    $core.String? message,
    $core.String? statusKey,
  }) {
    final result = WorkflowProblem._();
    if (code != null) result.code = code;
    if (message != null) result.message = message;
    if (statusKey != null) result.statusKey = statusKey;
    return result;
  }

  WorkflowProblem._();

  factory WorkflowProblem.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WorkflowProblem()..mergeFromBuffer(data, registry);
  factory WorkflowProblem.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WorkflowProblem()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WorkflowProblem',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.workflows'),
      createEmptyInstance: WorkflowProblem.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'code')
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..aOS(3, _omitFieldNames ? '' : 'statusKey')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WorkflowProblem clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WorkflowProblem copyWith(void Function(WorkflowProblem) updates) =>
      super.copyWith((message) => updates(message as WorkflowProblem))
          as WorkflowProblem;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use WorkflowProblem() / WorkflowProblem.new instead')
  static WorkflowProblem create() => WorkflowProblem._();
  static $pb.GeneratedMessage $_createMessage() => WorkflowProblem._();
  @$core.override
  WorkflowProblem createEmptyInstance() => WorkflowProblem._();
  @$core.pragma('dart2js:noInline')
  static WorkflowProblem getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<WorkflowProblem>(
          WorkflowProblem.$_createMessage);
  static WorkflowProblem? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get code => $_getSZ(0);
  @$pb.TagNumber(1)
  set code($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCode() => $_has(0);
  @$pb.TagNumber(1)
  void clearCode() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get statusKey => $_getSZ(2);
  @$pb.TagNumber(3)
  set statusKey($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasStatusKey() => $_has(2);
  @$pb.TagNumber(3)
  void clearStatusKey() => $_clearField(3);
}

class WorkflowProblems extends $pb.GeneratedMessage {
  factory WorkflowProblems({
    $core.Iterable<WorkflowProblem>? problems,
  }) {
    final result = WorkflowProblems._();
    if (problems != null) result.problems.addAll(problems);
    return result;
  }

  WorkflowProblems._();

  factory WorkflowProblems.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WorkflowProblems()..mergeFromBuffer(data, registry);
  factory WorkflowProblems.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WorkflowProblems()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WorkflowProblems',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.workflows'),
      createEmptyInstance: WorkflowProblems.$_createMessage)
    ..pPM<WorkflowProblem>(1, _omitFieldNames ? '' : 'problems',
        subBuilder: WorkflowProblem.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WorkflowProblems clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WorkflowProblems copyWith(void Function(WorkflowProblems) updates) =>
      super.copyWith((message) => updates(message as WorkflowProblems))
          as WorkflowProblems;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use WorkflowProblems() / WorkflowProblems.new instead')
  static WorkflowProblems create() => WorkflowProblems._();
  static $pb.GeneratedMessage $_createMessage() => WorkflowProblems._();
  @$core.override
  WorkflowProblems createEmptyInstance() => WorkflowProblems._();
  @$core.pragma('dart2js:noInline')
  static WorkflowProblems getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<WorkflowProblems>(
          WorkflowProblems.$_createMessage);
  static WorkflowProblems? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<WorkflowProblem> get problems => $_getList(0);
}

class WorkflowUpdateRequest extends $pb.GeneratedMessage {
  factory WorkflowUpdateRequest({
    $core.String? workspaceId,
    $core.String? projectId,
    $core.int? expectedVersion,
    $core.bool? restrictTransitions,
    $core.Iterable<StatusInput>? statuses,
    $core.Iterable<TransitionInput>? transitions,
    $core.Iterable<MigrationInput>? migrations,
    $core.bool? restrictCreation,
  }) {
    final result = WorkflowUpdateRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (projectId != null) result.projectId = projectId;
    if (expectedVersion != null) result.expectedVersion = expectedVersion;
    if (restrictTransitions != null)
      result.restrictTransitions = restrictTransitions;
    if (statuses != null) result.statuses.addAll(statuses);
    if (transitions != null) result.transitions.addAll(transitions);
    if (migrations != null) result.migrations.addAll(migrations);
    if (restrictCreation != null) result.restrictCreation = restrictCreation;
    return result;
  }

  WorkflowUpdateRequest._();

  factory WorkflowUpdateRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WorkflowUpdateRequest()..mergeFromBuffer(data, registry);
  factory WorkflowUpdateRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WorkflowUpdateRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WorkflowUpdateRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.workflows'),
      createEmptyInstance: WorkflowUpdateRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..aI(3, _omitFieldNames ? '' : 'expectedVersion')
    ..aOB(4, _omitFieldNames ? '' : 'restrictTransitions')
    ..pPM<StatusInput>(5, _omitFieldNames ? '' : 'statuses',
        subBuilder: StatusInput.$_createMessage)
    ..pPM<TransitionInput>(6, _omitFieldNames ? '' : 'transitions',
        subBuilder: TransitionInput.$_createMessage)
    ..pPM<MigrationInput>(7, _omitFieldNames ? '' : 'migrations',
        subBuilder: MigrationInput.$_createMessage)
    ..aOB(8, _omitFieldNames ? '' : 'restrictCreation')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WorkflowUpdateRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WorkflowUpdateRequest copyWith(
          void Function(WorkflowUpdateRequest) updates) =>
      super.copyWith((message) => updates(message as WorkflowUpdateRequest))
          as WorkflowUpdateRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use WorkflowUpdateRequest() / WorkflowUpdateRequest.new instead')
  static WorkflowUpdateRequest create() => WorkflowUpdateRequest._();
  static $pb.GeneratedMessage $_createMessage() => WorkflowUpdateRequest._();
  @$core.override
  WorkflowUpdateRequest createEmptyInstance() => WorkflowUpdateRequest._();
  @$core.pragma('dart2js:noInline')
  static WorkflowUpdateRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WorkflowUpdateRequest>(
          WorkflowUpdateRequest.$_createMessage);
  static WorkflowUpdateRequest? _defaultInstance;

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
  $core.int get expectedVersion => $_getIZ(2);
  @$pb.TagNumber(3)
  set expectedVersion($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasExpectedVersion() => $_has(2);
  @$pb.TagNumber(3)
  void clearExpectedVersion() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get restrictTransitions => $_getBF(3);
  @$pb.TagNumber(4)
  set restrictTransitions($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasRestrictTransitions() => $_has(3);
  @$pb.TagNumber(4)
  void clearRestrictTransitions() => $_clearField(4);

  @$pb.TagNumber(5)
  $pb.PbList<StatusInput> get statuses => $_getList(4);

  @$pb.TagNumber(6)
  $pb.PbList<TransitionInput> get transitions => $_getList(5);

  @$pb.TagNumber(7)
  $pb.PbList<MigrationInput> get migrations => $_getList(6);

  @$pb.TagNumber(8)
  $core.bool get restrictCreation => $_getBF(7);
  @$pb.TagNumber(8)
  set restrictCreation($core.bool value) => $_setBool(7, value);
  @$pb.TagNumber(8)
  $core.bool hasRestrictCreation() => $_has(7);
  @$pb.TagNumber(8)
  void clearRestrictCreation() => $_clearField(8);
}

class WorkflowValidateRequest extends $pb.GeneratedMessage {
  factory WorkflowValidateRequest({
    $core.String? workspaceId,
    $core.String? projectId,
    $core.bool? restrictTransitions,
    $core.Iterable<StatusInput>? statuses,
    $core.Iterable<TransitionInput>? transitions,
    $core.Iterable<MigrationInput>? migrations,
    $core.bool? restrictCreation,
  }) {
    final result = WorkflowValidateRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (projectId != null) result.projectId = projectId;
    if (restrictTransitions != null)
      result.restrictTransitions = restrictTransitions;
    if (statuses != null) result.statuses.addAll(statuses);
    if (transitions != null) result.transitions.addAll(transitions);
    if (migrations != null) result.migrations.addAll(migrations);
    if (restrictCreation != null) result.restrictCreation = restrictCreation;
    return result;
  }

  WorkflowValidateRequest._();

  factory WorkflowValidateRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WorkflowValidateRequest()..mergeFromBuffer(data, registry);
  factory WorkflowValidateRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WorkflowValidateRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WorkflowValidateRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.workflows'),
      createEmptyInstance: WorkflowValidateRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..aOB(3, _omitFieldNames ? '' : 'restrictTransitions')
    ..pPM<StatusInput>(4, _omitFieldNames ? '' : 'statuses',
        subBuilder: StatusInput.$_createMessage)
    ..pPM<TransitionInput>(5, _omitFieldNames ? '' : 'transitions',
        subBuilder: TransitionInput.$_createMessage)
    ..pPM<MigrationInput>(6, _omitFieldNames ? '' : 'migrations',
        subBuilder: MigrationInput.$_createMessage)
    ..aOB(7, _omitFieldNames ? '' : 'restrictCreation')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WorkflowValidateRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WorkflowValidateRequest copyWith(
          void Function(WorkflowValidateRequest) updates) =>
      super.copyWith((message) => updates(message as WorkflowValidateRequest))
          as WorkflowValidateRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use WorkflowValidateRequest() / WorkflowValidateRequest.new instead')
  static WorkflowValidateRequest create() => WorkflowValidateRequest._();
  static $pb.GeneratedMessage $_createMessage() => WorkflowValidateRequest._();
  @$core.override
  WorkflowValidateRequest createEmptyInstance() => WorkflowValidateRequest._();
  @$core.pragma('dart2js:noInline')
  static WorkflowValidateRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WorkflowValidateRequest>(
          WorkflowValidateRequest.$_createMessage);
  static WorkflowValidateRequest? _defaultInstance;

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
  $core.bool get restrictTransitions => $_getBF(2);
  @$pb.TagNumber(3)
  set restrictTransitions($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRestrictTransitions() => $_has(2);
  @$pb.TagNumber(3)
  void clearRestrictTransitions() => $_clearField(3);

  @$pb.TagNumber(4)
  $pb.PbList<StatusInput> get statuses => $_getList(3);

  @$pb.TagNumber(5)
  $pb.PbList<TransitionInput> get transitions => $_getList(4);

  @$pb.TagNumber(6)
  $pb.PbList<MigrationInput> get migrations => $_getList(5);

  @$pb.TagNumber(7)
  $core.bool get restrictCreation => $_getBF(6);
  @$pb.TagNumber(7)
  set restrictCreation($core.bool value) => $_setBool(6, value);
  @$pb.TagNumber(7)
  $core.bool hasRestrictCreation() => $_has(6);
  @$pb.TagNumber(7)
  void clearRestrictCreation() => $_clearField(7);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
