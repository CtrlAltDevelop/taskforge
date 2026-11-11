// This is a generated file - do not edit.
//
// Generated from infrastructure/automations/grpc/automations.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class Automation extends $pb.GeneratedMessage {
  factory Automation({
    $core.String? id,
    $core.String? workspaceId,
    $core.String? projectId,
    $core.String? name,
    $core.bool? enabled,
    $core.String? triggerJson,
    $core.String? conditionTfql,
    $core.String? conditionJson,
    $core.String? actionsJson,
    $core.String? ownerId,
    $core.String? disabledReason,
    $core.int? version,
    $core.String? createdAt,
    $core.String? updatedAt,
    $core.String? lastRunAt,
    $core.String? lastRunStatus,
  }) {
    final result = Automation._();
    if (id != null) result.id = id;
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (projectId != null) result.projectId = projectId;
    if (name != null) result.name = name;
    if (enabled != null) result.enabled = enabled;
    if (triggerJson != null) result.triggerJson = triggerJson;
    if (conditionTfql != null) result.conditionTfql = conditionTfql;
    if (conditionJson != null) result.conditionJson = conditionJson;
    if (actionsJson != null) result.actionsJson = actionsJson;
    if (ownerId != null) result.ownerId = ownerId;
    if (disabledReason != null) result.disabledReason = disabledReason;
    if (version != null) result.version = version;
    if (createdAt != null) result.createdAt = createdAt;
    if (updatedAt != null) result.updatedAt = updatedAt;
    if (lastRunAt != null) result.lastRunAt = lastRunAt;
    if (lastRunStatus != null) result.lastRunStatus = lastRunStatus;
    return result;
  }

  Automation._();

  factory Automation.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Automation()..mergeFromBuffer(data, registry);
  factory Automation.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Automation()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Automation',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.automations'),
      createEmptyInstance: Automation.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(3, _omitFieldNames ? '' : 'projectId')
    ..aOS(4, _omitFieldNames ? '' : 'name')
    ..aOB(5, _omitFieldNames ? '' : 'enabled')
    ..aOS(6, _omitFieldNames ? '' : 'triggerJson')
    ..aOS(7, _omitFieldNames ? '' : 'conditionTfql')
    ..aOS(8, _omitFieldNames ? '' : 'conditionJson')
    ..aOS(9, _omitFieldNames ? '' : 'actionsJson')
    ..aOS(10, _omitFieldNames ? '' : 'ownerId')
    ..aOS(11, _omitFieldNames ? '' : 'disabledReason')
    ..aI(12, _omitFieldNames ? '' : 'version')
    ..aOS(13, _omitFieldNames ? '' : 'createdAt')
    ..aOS(14, _omitFieldNames ? '' : 'updatedAt')
    ..aOS(15, _omitFieldNames ? '' : 'lastRunAt')
    ..aOS(16, _omitFieldNames ? '' : 'lastRunStatus')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Automation clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Automation copyWith(void Function(Automation) updates) =>
      super.copyWith((message) => updates(message as Automation)) as Automation;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Automation() / Automation.new instead')
  static Automation create() => Automation._();
  static $pb.GeneratedMessage $_createMessage() => Automation._();
  @$core.override
  Automation createEmptyInstance() => Automation._();
  @$core.pragma('dart2js:noInline')
  static Automation getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Automation>(Automation.$_createMessage);
  static Automation? _defaultInstance;

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
  $core.bool get enabled => $_getBF(4);
  @$pb.TagNumber(5)
  set enabled($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasEnabled() => $_has(4);
  @$pb.TagNumber(5)
  void clearEnabled() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get triggerJson => $_getSZ(5);
  @$pb.TagNumber(6)
  set triggerJson($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasTriggerJson() => $_has(5);
  @$pb.TagNumber(6)
  void clearTriggerJson() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get conditionTfql => $_getSZ(6);
  @$pb.TagNumber(7)
  set conditionTfql($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasConditionTfql() => $_has(6);
  @$pb.TagNumber(7)
  void clearConditionTfql() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get conditionJson => $_getSZ(7);
  @$pb.TagNumber(8)
  set conditionJson($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasConditionJson() => $_has(7);
  @$pb.TagNumber(8)
  void clearConditionJson() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get actionsJson => $_getSZ(8);
  @$pb.TagNumber(9)
  set actionsJson($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasActionsJson() => $_has(8);
  @$pb.TagNumber(9)
  void clearActionsJson() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get ownerId => $_getSZ(9);
  @$pb.TagNumber(10)
  set ownerId($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasOwnerId() => $_has(9);
  @$pb.TagNumber(10)
  void clearOwnerId() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.String get disabledReason => $_getSZ(10);
  @$pb.TagNumber(11)
  set disabledReason($core.String value) => $_setString(10, value);
  @$pb.TagNumber(11)
  $core.bool hasDisabledReason() => $_has(10);
  @$pb.TagNumber(11)
  void clearDisabledReason() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.int get version => $_getIZ(11);
  @$pb.TagNumber(12)
  set version($core.int value) => $_setSignedInt32(11, value);
  @$pb.TagNumber(12)
  $core.bool hasVersion() => $_has(11);
  @$pb.TagNumber(12)
  void clearVersion() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.String get createdAt => $_getSZ(12);
  @$pb.TagNumber(13)
  set createdAt($core.String value) => $_setString(12, value);
  @$pb.TagNumber(13)
  $core.bool hasCreatedAt() => $_has(12);
  @$pb.TagNumber(13)
  void clearCreatedAt() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.String get updatedAt => $_getSZ(13);
  @$pb.TagNumber(14)
  set updatedAt($core.String value) => $_setString(13, value);
  @$pb.TagNumber(14)
  $core.bool hasUpdatedAt() => $_has(13);
  @$pb.TagNumber(14)
  void clearUpdatedAt() => $_clearField(14);

  @$pb.TagNumber(15)
  $core.String get lastRunAt => $_getSZ(14);
  @$pb.TagNumber(15)
  set lastRunAt($core.String value) => $_setString(14, value);
  @$pb.TagNumber(15)
  $core.bool hasLastRunAt() => $_has(14);
  @$pb.TagNumber(15)
  void clearLastRunAt() => $_clearField(15);

  @$pb.TagNumber(16)
  $core.String get lastRunStatus => $_getSZ(15);
  @$pb.TagNumber(16)
  set lastRunStatus($core.String value) => $_setString(15, value);
  @$pb.TagNumber(16)
  $core.bool hasLastRunStatus() => $_has(15);
  @$pb.TagNumber(16)
  void clearLastRunStatus() => $_clearField(16);
}

class AutomationAnswer extends $pb.GeneratedMessage {
  factory AutomationAnswer({
    Automation? automation,
  }) {
    final result = AutomationAnswer._();
    if (automation != null) result.automation = automation;
    return result;
  }

  AutomationAnswer._();

  factory AutomationAnswer.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AutomationAnswer()..mergeFromBuffer(data, registry);
  factory AutomationAnswer.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AutomationAnswer()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AutomationAnswer',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.automations'),
      createEmptyInstance: AutomationAnswer.$_createMessage)
    ..aOM<Automation>(1, _omitFieldNames ? '' : 'automation',
        subBuilder: Automation.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AutomationAnswer clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AutomationAnswer copyWith(void Function(AutomationAnswer) updates) =>
      super.copyWith((message) => updates(message as AutomationAnswer))
          as AutomationAnswer;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use AutomationAnswer() / AutomationAnswer.new instead')
  static AutomationAnswer create() => AutomationAnswer._();
  static $pb.GeneratedMessage $_createMessage() => AutomationAnswer._();
  @$core.override
  AutomationAnswer createEmptyInstance() => AutomationAnswer._();
  @$core.pragma('dart2js:noInline')
  static AutomationAnswer getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AutomationAnswer>(
          AutomationAnswer.$_createMessage);
  static AutomationAnswer? _defaultInstance;

  @$pb.TagNumber(1)
  Automation get automation => $_getN(0);
  @$pb.TagNumber(1)
  set automation(Automation value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasAutomation() => $_has(0);
  @$pb.TagNumber(1)
  void clearAutomation() => $_clearField(1);
  @$pb.TagNumber(1)
  Automation ensureAutomation() => $_ensure(0);
}

class AutomationCreateRequest extends $pb.GeneratedMessage {
  factory AutomationCreateRequest({
    $core.String? workspaceId,
    $core.String? projectId,
    $core.String? name,
    $core.String? triggerJson,
    $core.String? conditionTfql,
    $core.String? actionsJson,
    $core.bool? enabled,
  }) {
    final result = AutomationCreateRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (projectId != null) result.projectId = projectId;
    if (name != null) result.name = name;
    if (triggerJson != null) result.triggerJson = triggerJson;
    if (conditionTfql != null) result.conditionTfql = conditionTfql;
    if (actionsJson != null) result.actionsJson = actionsJson;
    if (enabled != null) result.enabled = enabled;
    return result;
  }

  AutomationCreateRequest._();

  factory AutomationCreateRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AutomationCreateRequest()..mergeFromBuffer(data, registry);
  factory AutomationCreateRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AutomationCreateRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AutomationCreateRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.automations'),
      createEmptyInstance: AutomationCreateRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..aOS(3, _omitFieldNames ? '' : 'name')
    ..aOS(4, _omitFieldNames ? '' : 'triggerJson')
    ..aOS(5, _omitFieldNames ? '' : 'conditionTfql')
    ..aOS(6, _omitFieldNames ? '' : 'actionsJson')
    ..aOB(7, _omitFieldNames ? '' : 'enabled')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AutomationCreateRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AutomationCreateRequest copyWith(
          void Function(AutomationCreateRequest) updates) =>
      super.copyWith((message) => updates(message as AutomationCreateRequest))
          as AutomationCreateRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use AutomationCreateRequest() / AutomationCreateRequest.new instead')
  static AutomationCreateRequest create() => AutomationCreateRequest._();
  static $pb.GeneratedMessage $_createMessage() => AutomationCreateRequest._();
  @$core.override
  AutomationCreateRequest createEmptyInstance() => AutomationCreateRequest._();
  @$core.pragma('dart2js:noInline')
  static AutomationCreateRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AutomationCreateRequest>(
          AutomationCreateRequest.$_createMessage);
  static AutomationCreateRequest? _defaultInstance;

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
  $core.String get triggerJson => $_getSZ(3);
  @$pb.TagNumber(4)
  set triggerJson($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasTriggerJson() => $_has(3);
  @$pb.TagNumber(4)
  void clearTriggerJson() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get conditionTfql => $_getSZ(4);
  @$pb.TagNumber(5)
  set conditionTfql($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasConditionTfql() => $_has(4);
  @$pb.TagNumber(5)
  void clearConditionTfql() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get actionsJson => $_getSZ(5);
  @$pb.TagNumber(6)
  set actionsJson($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasActionsJson() => $_has(5);
  @$pb.TagNumber(6)
  void clearActionsJson() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.bool get enabled => $_getBF(6);
  @$pb.TagNumber(7)
  set enabled($core.bool value) => $_setBool(6, value);
  @$pb.TagNumber(7)
  $core.bool hasEnabled() => $_has(6);
  @$pb.TagNumber(7)
  void clearEnabled() => $_clearField(7);
}

class AutomationDeleteRequest extends $pb.GeneratedMessage {
  factory AutomationDeleteRequest({
    $core.String? workspaceId,
    $core.String? projectId,
    $core.String? automationId,
  }) {
    final result = AutomationDeleteRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (projectId != null) result.projectId = projectId;
    if (automationId != null) result.automationId = automationId;
    return result;
  }

  AutomationDeleteRequest._();

  factory AutomationDeleteRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AutomationDeleteRequest()..mergeFromBuffer(data, registry);
  factory AutomationDeleteRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AutomationDeleteRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AutomationDeleteRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.automations'),
      createEmptyInstance: AutomationDeleteRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..aOS(3, _omitFieldNames ? '' : 'automationId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AutomationDeleteRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AutomationDeleteRequest copyWith(
          void Function(AutomationDeleteRequest) updates) =>
      super.copyWith((message) => updates(message as AutomationDeleteRequest))
          as AutomationDeleteRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use AutomationDeleteRequest() / AutomationDeleteRequest.new instead')
  static AutomationDeleteRequest create() => AutomationDeleteRequest._();
  static $pb.GeneratedMessage $_createMessage() => AutomationDeleteRequest._();
  @$core.override
  AutomationDeleteRequest createEmptyInstance() => AutomationDeleteRequest._();
  @$core.pragma('dart2js:noInline')
  static AutomationDeleteRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AutomationDeleteRequest>(
          AutomationDeleteRequest.$_createMessage);
  static AutomationDeleteRequest? _defaultInstance;

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
  $core.String get automationId => $_getSZ(2);
  @$pb.TagNumber(3)
  set automationId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAutomationId() => $_has(2);
  @$pb.TagNumber(3)
  void clearAutomationId() => $_clearField(3);
}

class AutomationDeleted extends $pb.GeneratedMessage {
  factory AutomationDeleted({
    $core.String? id,
  }) {
    final result = AutomationDeleted._();
    if (id != null) result.id = id;
    return result;
  }

  AutomationDeleted._();

  factory AutomationDeleted.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AutomationDeleted()..mergeFromBuffer(data, registry);
  factory AutomationDeleted.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AutomationDeleted()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AutomationDeleted',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.automations'),
      createEmptyInstance: AutomationDeleted.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AutomationDeleted clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AutomationDeleted copyWith(void Function(AutomationDeleted) updates) =>
      super.copyWith((message) => updates(message as AutomationDeleted))
          as AutomationDeleted;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use AutomationDeleted() / AutomationDeleted.new instead')
  static AutomationDeleted create() => AutomationDeleted._();
  static $pb.GeneratedMessage $_createMessage() => AutomationDeleted._();
  @$core.override
  AutomationDeleted createEmptyInstance() => AutomationDeleted._();
  @$core.pragma('dart2js:noInline')
  static AutomationDeleted getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AutomationDeleted>(
          AutomationDeleted.$_createMessage);
  static AutomationDeleted? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class AutomationDryRunAnswer extends $pb.GeneratedMessage {
  factory AutomationDryRunAnswer({
    $core.bool? wouldRun,
    $core.String? status,
    $core.String? explanation,
    $core.String? error,
    $core.String? stepsJson,
  }) {
    final result = AutomationDryRunAnswer._();
    if (wouldRun != null) result.wouldRun = wouldRun;
    if (status != null) result.status = status;
    if (explanation != null) result.explanation = explanation;
    if (error != null) result.error = error;
    if (stepsJson != null) result.stepsJson = stepsJson;
    return result;
  }

  AutomationDryRunAnswer._();

  factory AutomationDryRunAnswer.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AutomationDryRunAnswer()..mergeFromBuffer(data, registry);
  factory AutomationDryRunAnswer.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AutomationDryRunAnswer()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AutomationDryRunAnswer',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.automations'),
      createEmptyInstance: AutomationDryRunAnswer.$_createMessage)
    ..aOB(1, _omitFieldNames ? '' : 'wouldRun')
    ..aOS(2, _omitFieldNames ? '' : 'status')
    ..aOS(3, _omitFieldNames ? '' : 'explanation')
    ..aOS(4, _omitFieldNames ? '' : 'error')
    ..aOS(5, _omitFieldNames ? '' : 'stepsJson')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AutomationDryRunAnswer clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AutomationDryRunAnswer copyWith(
          void Function(AutomationDryRunAnswer) updates) =>
      super.copyWith((message) => updates(message as AutomationDryRunAnswer))
          as AutomationDryRunAnswer;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use AutomationDryRunAnswer() / AutomationDryRunAnswer.new instead')
  static AutomationDryRunAnswer create() => AutomationDryRunAnswer._();
  static $pb.GeneratedMessage $_createMessage() => AutomationDryRunAnswer._();
  @$core.override
  AutomationDryRunAnswer createEmptyInstance() => AutomationDryRunAnswer._();
  @$core.pragma('dart2js:noInline')
  static AutomationDryRunAnswer getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AutomationDryRunAnswer>(
          AutomationDryRunAnswer.$_createMessage);
  static AutomationDryRunAnswer? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get wouldRun => $_getBF(0);
  @$pb.TagNumber(1)
  set wouldRun($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWouldRun() => $_has(0);
  @$pb.TagNumber(1)
  void clearWouldRun() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get status => $_getSZ(1);
  @$pb.TagNumber(2)
  set status($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasStatus() => $_has(1);
  @$pb.TagNumber(2)
  void clearStatus() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get explanation => $_getSZ(2);
  @$pb.TagNumber(3)
  set explanation($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasExplanation() => $_has(2);
  @$pb.TagNumber(3)
  void clearExplanation() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get error => $_getSZ(3);
  @$pb.TagNumber(4)
  set error($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasError() => $_has(3);
  @$pb.TagNumber(4)
  void clearError() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get stepsJson => $_getSZ(4);
  @$pb.TagNumber(5)
  set stepsJson($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasStepsJson() => $_has(4);
  @$pb.TagNumber(5)
  void clearStepsJson() => $_clearField(5);
}

class AutomationDryRunRequest extends $pb.GeneratedMessage {
  factory AutomationDryRunRequest({
    $core.String? workspaceId,
    $core.String? projectId,
    $core.String? automationId,
    $core.String? taskId,
  }) {
    final result = AutomationDryRunRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (projectId != null) result.projectId = projectId;
    if (automationId != null) result.automationId = automationId;
    if (taskId != null) result.taskId = taskId;
    return result;
  }

  AutomationDryRunRequest._();

  factory AutomationDryRunRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AutomationDryRunRequest()..mergeFromBuffer(data, registry);
  factory AutomationDryRunRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AutomationDryRunRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AutomationDryRunRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.automations'),
      createEmptyInstance: AutomationDryRunRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..aOS(3, _omitFieldNames ? '' : 'automationId')
    ..aOS(4, _omitFieldNames ? '' : 'taskId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AutomationDryRunRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AutomationDryRunRequest copyWith(
          void Function(AutomationDryRunRequest) updates) =>
      super.copyWith((message) => updates(message as AutomationDryRunRequest))
          as AutomationDryRunRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use AutomationDryRunRequest() / AutomationDryRunRequest.new instead')
  static AutomationDryRunRequest create() => AutomationDryRunRequest._();
  static $pb.GeneratedMessage $_createMessage() => AutomationDryRunRequest._();
  @$core.override
  AutomationDryRunRequest createEmptyInstance() => AutomationDryRunRequest._();
  @$core.pragma('dart2js:noInline')
  static AutomationDryRunRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AutomationDryRunRequest>(
          AutomationDryRunRequest.$_createMessage);
  static AutomationDryRunRequest? _defaultInstance;

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
  $core.String get automationId => $_getSZ(2);
  @$pb.TagNumber(3)
  set automationId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAutomationId() => $_has(2);
  @$pb.TagNumber(3)
  void clearAutomationId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get taskId => $_getSZ(3);
  @$pb.TagNumber(4)
  set taskId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasTaskId() => $_has(3);
  @$pb.TagNumber(4)
  void clearTaskId() => $_clearField(4);
}

class AutomationList extends $pb.GeneratedMessage {
  factory AutomationList({
    $core.Iterable<Automation>? automations,
  }) {
    final result = AutomationList._();
    if (automations != null) result.automations.addAll(automations);
    return result;
  }

  AutomationList._();

  factory AutomationList.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AutomationList()..mergeFromBuffer(data, registry);
  factory AutomationList.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AutomationList()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AutomationList',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.automations'),
      createEmptyInstance: AutomationList.$_createMessage)
    ..pPM<Automation>(1, _omitFieldNames ? '' : 'automations',
        subBuilder: Automation.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AutomationList clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AutomationList copyWith(void Function(AutomationList) updates) =>
      super.copyWith((message) => updates(message as AutomationList))
          as AutomationList;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use AutomationList() / AutomationList.new instead')
  static AutomationList create() => AutomationList._();
  static $pb.GeneratedMessage $_createMessage() => AutomationList._();
  @$core.override
  AutomationList createEmptyInstance() => AutomationList._();
  @$core.pragma('dart2js:noInline')
  static AutomationList getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AutomationList>(
          AutomationList.$_createMessage);
  static AutomationList? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Automation> get automations => $_getList(0);
}

class AutomationListRequest extends $pb.GeneratedMessage {
  factory AutomationListRequest({
    $core.String? workspaceId,
    $core.String? projectId,
  }) {
    final result = AutomationListRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (projectId != null) result.projectId = projectId;
    return result;
  }

  AutomationListRequest._();

  factory AutomationListRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AutomationListRequest()..mergeFromBuffer(data, registry);
  factory AutomationListRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AutomationListRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AutomationListRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.automations'),
      createEmptyInstance: AutomationListRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AutomationListRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AutomationListRequest copyWith(
          void Function(AutomationListRequest) updates) =>
      super.copyWith((message) => updates(message as AutomationListRequest))
          as AutomationListRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use AutomationListRequest() / AutomationListRequest.new instead')
  static AutomationListRequest create() => AutomationListRequest._();
  static $pb.GeneratedMessage $_createMessage() => AutomationListRequest._();
  @$core.override
  AutomationListRequest createEmptyInstance() => AutomationListRequest._();
  @$core.pragma('dart2js:noInline')
  static AutomationListRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AutomationListRequest>(
          AutomationListRequest.$_createMessage);
  static AutomationListRequest? _defaultInstance;

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

class AutomationRun extends $pb.GeneratedMessage {
  factory AutomationRun({
    $core.String? id,
    $core.String? automationId,
    $core.String? automationName,
    $core.String? taskId,
    $core.String? taskKey,
    $core.String? status,
    $core.int? depth,
    $core.String? eventKey,
    $core.String? inputJson,
    $core.String? stepsJson,
    $core.String? error,
    $core.String? explanation,
    $core.String? startedAt,
    $core.String? finishedAt,
  }) {
    final result = AutomationRun._();
    if (id != null) result.id = id;
    if (automationId != null) result.automationId = automationId;
    if (automationName != null) result.automationName = automationName;
    if (taskId != null) result.taskId = taskId;
    if (taskKey != null) result.taskKey = taskKey;
    if (status != null) result.status = status;
    if (depth != null) result.depth = depth;
    if (eventKey != null) result.eventKey = eventKey;
    if (inputJson != null) result.inputJson = inputJson;
    if (stepsJson != null) result.stepsJson = stepsJson;
    if (error != null) result.error = error;
    if (explanation != null) result.explanation = explanation;
    if (startedAt != null) result.startedAt = startedAt;
    if (finishedAt != null) result.finishedAt = finishedAt;
    return result;
  }

  AutomationRun._();

  factory AutomationRun.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AutomationRun()..mergeFromBuffer(data, registry);
  factory AutomationRun.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AutomationRun()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AutomationRun',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.automations'),
      createEmptyInstance: AutomationRun.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'automationId')
    ..aOS(3, _omitFieldNames ? '' : 'automationName')
    ..aOS(4, _omitFieldNames ? '' : 'taskId')
    ..aOS(5, _omitFieldNames ? '' : 'taskKey')
    ..aOS(6, _omitFieldNames ? '' : 'status')
    ..aI(7, _omitFieldNames ? '' : 'depth')
    ..aOS(8, _omitFieldNames ? '' : 'eventKey')
    ..aOS(9, _omitFieldNames ? '' : 'inputJson')
    ..aOS(10, _omitFieldNames ? '' : 'stepsJson')
    ..aOS(11, _omitFieldNames ? '' : 'error')
    ..aOS(12, _omitFieldNames ? '' : 'explanation')
    ..aOS(13, _omitFieldNames ? '' : 'startedAt')
    ..aOS(14, _omitFieldNames ? '' : 'finishedAt')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AutomationRun clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AutomationRun copyWith(void Function(AutomationRun) updates) =>
      super.copyWith((message) => updates(message as AutomationRun))
          as AutomationRun;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use AutomationRun() / AutomationRun.new instead')
  static AutomationRun create() => AutomationRun._();
  static $pb.GeneratedMessage $_createMessage() => AutomationRun._();
  @$core.override
  AutomationRun createEmptyInstance() => AutomationRun._();
  @$core.pragma('dart2js:noInline')
  static AutomationRun getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AutomationRun>(
          AutomationRun.$_createMessage);
  static AutomationRun? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get automationId => $_getSZ(1);
  @$pb.TagNumber(2)
  set automationId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAutomationId() => $_has(1);
  @$pb.TagNumber(2)
  void clearAutomationId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get automationName => $_getSZ(2);
  @$pb.TagNumber(3)
  set automationName($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAutomationName() => $_has(2);
  @$pb.TagNumber(3)
  void clearAutomationName() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get taskId => $_getSZ(3);
  @$pb.TagNumber(4)
  set taskId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasTaskId() => $_has(3);
  @$pb.TagNumber(4)
  void clearTaskId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get taskKey => $_getSZ(4);
  @$pb.TagNumber(5)
  set taskKey($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasTaskKey() => $_has(4);
  @$pb.TagNumber(5)
  void clearTaskKey() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get status => $_getSZ(5);
  @$pb.TagNumber(6)
  set status($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasStatus() => $_has(5);
  @$pb.TagNumber(6)
  void clearStatus() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.int get depth => $_getIZ(6);
  @$pb.TagNumber(7)
  set depth($core.int value) => $_setSignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasDepth() => $_has(6);
  @$pb.TagNumber(7)
  void clearDepth() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get eventKey => $_getSZ(7);
  @$pb.TagNumber(8)
  set eventKey($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasEventKey() => $_has(7);
  @$pb.TagNumber(8)
  void clearEventKey() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get inputJson => $_getSZ(8);
  @$pb.TagNumber(9)
  set inputJson($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasInputJson() => $_has(8);
  @$pb.TagNumber(9)
  void clearInputJson() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get stepsJson => $_getSZ(9);
  @$pb.TagNumber(10)
  set stepsJson($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasStepsJson() => $_has(9);
  @$pb.TagNumber(10)
  void clearStepsJson() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.String get error => $_getSZ(10);
  @$pb.TagNumber(11)
  set error($core.String value) => $_setString(10, value);
  @$pb.TagNumber(11)
  $core.bool hasError() => $_has(10);
  @$pb.TagNumber(11)
  void clearError() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.String get explanation => $_getSZ(11);
  @$pb.TagNumber(12)
  set explanation($core.String value) => $_setString(11, value);
  @$pb.TagNumber(12)
  $core.bool hasExplanation() => $_has(11);
  @$pb.TagNumber(12)
  void clearExplanation() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.String get startedAt => $_getSZ(12);
  @$pb.TagNumber(13)
  set startedAt($core.String value) => $_setString(12, value);
  @$pb.TagNumber(13)
  $core.bool hasStartedAt() => $_has(12);
  @$pb.TagNumber(13)
  void clearStartedAt() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.String get finishedAt => $_getSZ(13);
  @$pb.TagNumber(14)
  set finishedAt($core.String value) => $_setString(13, value);
  @$pb.TagNumber(14)
  $core.bool hasFinishedAt() => $_has(13);
  @$pb.TagNumber(14)
  void clearFinishedAt() => $_clearField(14);
}

class AutomationRunAnswer extends $pb.GeneratedMessage {
  factory AutomationRunAnswer({
    AutomationRun? run,
  }) {
    final result = AutomationRunAnswer._();
    if (run != null) result.run = run;
    return result;
  }

  AutomationRunAnswer._();

  factory AutomationRunAnswer.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AutomationRunAnswer()..mergeFromBuffer(data, registry);
  factory AutomationRunAnswer.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AutomationRunAnswer()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AutomationRunAnswer',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.automations'),
      createEmptyInstance: AutomationRunAnswer.$_createMessage)
    ..aOM<AutomationRun>(1, _omitFieldNames ? '' : 'run',
        subBuilder: AutomationRun.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AutomationRunAnswer clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AutomationRunAnswer copyWith(void Function(AutomationRunAnswer) updates) =>
      super.copyWith((message) => updates(message as AutomationRunAnswer))
          as AutomationRunAnswer;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core
      .Deprecated('Use AutomationRunAnswer() / AutomationRunAnswer.new instead')
  static AutomationRunAnswer create() => AutomationRunAnswer._();
  static $pb.GeneratedMessage $_createMessage() => AutomationRunAnswer._();
  @$core.override
  AutomationRunAnswer createEmptyInstance() => AutomationRunAnswer._();
  @$core.pragma('dart2js:noInline')
  static AutomationRunAnswer getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AutomationRunAnswer>(
          AutomationRunAnswer.$_createMessage);
  static AutomationRunAnswer? _defaultInstance;

  @$pb.TagNumber(1)
  AutomationRun get run => $_getN(0);
  @$pb.TagNumber(1)
  set run(AutomationRun value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasRun() => $_has(0);
  @$pb.TagNumber(1)
  void clearRun() => $_clearField(1);
  @$pb.TagNumber(1)
  AutomationRun ensureRun() => $_ensure(0);
}

class AutomationRunGetRequest extends $pb.GeneratedMessage {
  factory AutomationRunGetRequest({
    $core.String? workspaceId,
    $core.String? projectId,
    $core.String? runId,
  }) {
    final result = AutomationRunGetRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (projectId != null) result.projectId = projectId;
    if (runId != null) result.runId = runId;
    return result;
  }

  AutomationRunGetRequest._();

  factory AutomationRunGetRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AutomationRunGetRequest()..mergeFromBuffer(data, registry);
  factory AutomationRunGetRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AutomationRunGetRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AutomationRunGetRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.automations'),
      createEmptyInstance: AutomationRunGetRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..aOS(3, _omitFieldNames ? '' : 'runId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AutomationRunGetRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AutomationRunGetRequest copyWith(
          void Function(AutomationRunGetRequest) updates) =>
      super.copyWith((message) => updates(message as AutomationRunGetRequest))
          as AutomationRunGetRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use AutomationRunGetRequest() / AutomationRunGetRequest.new instead')
  static AutomationRunGetRequest create() => AutomationRunGetRequest._();
  static $pb.GeneratedMessage $_createMessage() => AutomationRunGetRequest._();
  @$core.override
  AutomationRunGetRequest createEmptyInstance() => AutomationRunGetRequest._();
  @$core.pragma('dart2js:noInline')
  static AutomationRunGetRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AutomationRunGetRequest>(
          AutomationRunGetRequest.$_createMessage);
  static AutomationRunGetRequest? _defaultInstance;

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
  $core.String get runId => $_getSZ(2);
  @$pb.TagNumber(3)
  set runId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRunId() => $_has(2);
  @$pb.TagNumber(3)
  void clearRunId() => $_clearField(3);
}

class AutomationRunList extends $pb.GeneratedMessage {
  factory AutomationRunList({
    $core.Iterable<AutomationRun>? runs,
  }) {
    final result = AutomationRunList._();
    if (runs != null) result.runs.addAll(runs);
    return result;
  }

  AutomationRunList._();

  factory AutomationRunList.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AutomationRunList()..mergeFromBuffer(data, registry);
  factory AutomationRunList.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AutomationRunList()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AutomationRunList',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.automations'),
      createEmptyInstance: AutomationRunList.$_createMessage)
    ..pPM<AutomationRun>(1, _omitFieldNames ? '' : 'runs',
        subBuilder: AutomationRun.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AutomationRunList clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AutomationRunList copyWith(void Function(AutomationRunList) updates) =>
      super.copyWith((message) => updates(message as AutomationRunList))
          as AutomationRunList;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use AutomationRunList() / AutomationRunList.new instead')
  static AutomationRunList create() => AutomationRunList._();
  static $pb.GeneratedMessage $_createMessage() => AutomationRunList._();
  @$core.override
  AutomationRunList createEmptyInstance() => AutomationRunList._();
  @$core.pragma('dart2js:noInline')
  static AutomationRunList getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AutomationRunList>(
          AutomationRunList.$_createMessage);
  static AutomationRunList? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<AutomationRun> get runs => $_getList(0);
}

class AutomationRunListRequest extends $pb.GeneratedMessage {
  factory AutomationRunListRequest({
    $core.String? workspaceId,
    $core.String? projectId,
    $core.String? automationId,
    $core.String? taskId,
    $core.String? status,
    $core.String? before,
    $core.int? limit,
  }) {
    final result = AutomationRunListRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (projectId != null) result.projectId = projectId;
    if (automationId != null) result.automationId = automationId;
    if (taskId != null) result.taskId = taskId;
    if (status != null) result.status = status;
    if (before != null) result.before = before;
    if (limit != null) result.limit = limit;
    return result;
  }

  AutomationRunListRequest._();

  factory AutomationRunListRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AutomationRunListRequest()..mergeFromBuffer(data, registry);
  factory AutomationRunListRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AutomationRunListRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AutomationRunListRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.automations'),
      createEmptyInstance: AutomationRunListRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..aOS(3, _omitFieldNames ? '' : 'automationId')
    ..aOS(4, _omitFieldNames ? '' : 'taskId')
    ..aOS(5, _omitFieldNames ? '' : 'status')
    ..aOS(6, _omitFieldNames ? '' : 'before')
    ..aI(7, _omitFieldNames ? '' : 'limit')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AutomationRunListRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AutomationRunListRequest copyWith(
          void Function(AutomationRunListRequest) updates) =>
      super.copyWith((message) => updates(message as AutomationRunListRequest))
          as AutomationRunListRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use AutomationRunListRequest() / AutomationRunListRequest.new instead')
  static AutomationRunListRequest create() => AutomationRunListRequest._();
  static $pb.GeneratedMessage $_createMessage() => AutomationRunListRequest._();
  @$core.override
  AutomationRunListRequest createEmptyInstance() =>
      AutomationRunListRequest._();
  @$core.pragma('dart2js:noInline')
  static AutomationRunListRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AutomationRunListRequest>(
          AutomationRunListRequest.$_createMessage);
  static AutomationRunListRequest? _defaultInstance;

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
  $core.String get automationId => $_getSZ(2);
  @$pb.TagNumber(3)
  set automationId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAutomationId() => $_has(2);
  @$pb.TagNumber(3)
  void clearAutomationId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get taskId => $_getSZ(3);
  @$pb.TagNumber(4)
  set taskId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasTaskId() => $_has(3);
  @$pb.TagNumber(4)
  void clearTaskId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get status => $_getSZ(4);
  @$pb.TagNumber(5)
  set status($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasStatus() => $_has(4);
  @$pb.TagNumber(5)
  void clearStatus() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get before => $_getSZ(5);
  @$pb.TagNumber(6)
  set before($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasBefore() => $_has(5);
  @$pb.TagNumber(6)
  void clearBefore() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.int get limit => $_getIZ(6);
  @$pb.TagNumber(7)
  set limit($core.int value) => $_setSignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasLimit() => $_has(6);
  @$pb.TagNumber(7)
  void clearLimit() => $_clearField(7);
}

class AutomationToggleRequest extends $pb.GeneratedMessage {
  factory AutomationToggleRequest({
    $core.String? workspaceId,
    $core.String? projectId,
    $core.String? automationId,
    $core.bool? enabled,
  }) {
    final result = AutomationToggleRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (projectId != null) result.projectId = projectId;
    if (automationId != null) result.automationId = automationId;
    if (enabled != null) result.enabled = enabled;
    return result;
  }

  AutomationToggleRequest._();

  factory AutomationToggleRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AutomationToggleRequest()..mergeFromBuffer(data, registry);
  factory AutomationToggleRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AutomationToggleRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AutomationToggleRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.automations'),
      createEmptyInstance: AutomationToggleRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..aOS(3, _omitFieldNames ? '' : 'automationId')
    ..aOB(4, _omitFieldNames ? '' : 'enabled')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AutomationToggleRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AutomationToggleRequest copyWith(
          void Function(AutomationToggleRequest) updates) =>
      super.copyWith((message) => updates(message as AutomationToggleRequest))
          as AutomationToggleRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use AutomationToggleRequest() / AutomationToggleRequest.new instead')
  static AutomationToggleRequest create() => AutomationToggleRequest._();
  static $pb.GeneratedMessage $_createMessage() => AutomationToggleRequest._();
  @$core.override
  AutomationToggleRequest createEmptyInstance() => AutomationToggleRequest._();
  @$core.pragma('dart2js:noInline')
  static AutomationToggleRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AutomationToggleRequest>(
          AutomationToggleRequest.$_createMessage);
  static AutomationToggleRequest? _defaultInstance;

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
  $core.String get automationId => $_getSZ(2);
  @$pb.TagNumber(3)
  set automationId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAutomationId() => $_has(2);
  @$pb.TagNumber(3)
  void clearAutomationId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get enabled => $_getBF(3);
  @$pb.TagNumber(4)
  set enabled($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasEnabled() => $_has(3);
  @$pb.TagNumber(4)
  void clearEnabled() => $_clearField(4);
}

class AutomationUpdateRequest extends $pb.GeneratedMessage {
  factory AutomationUpdateRequest({
    $core.String? workspaceId,
    $core.String? projectId,
    $core.String? automationId,
    $core.Iterable<$core.String>? fields,
    $core.int? expectedVersion,
    $core.String? name,
    $core.String? triggerJson,
    $core.String? conditionTfql,
    $core.String? actionsJson,
  }) {
    final result = AutomationUpdateRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (projectId != null) result.projectId = projectId;
    if (automationId != null) result.automationId = automationId;
    if (fields != null) result.fields.addAll(fields);
    if (expectedVersion != null) result.expectedVersion = expectedVersion;
    if (name != null) result.name = name;
    if (triggerJson != null) result.triggerJson = triggerJson;
    if (conditionTfql != null) result.conditionTfql = conditionTfql;
    if (actionsJson != null) result.actionsJson = actionsJson;
    return result;
  }

  AutomationUpdateRequest._();

  factory AutomationUpdateRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AutomationUpdateRequest()..mergeFromBuffer(data, registry);
  factory AutomationUpdateRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AutomationUpdateRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AutomationUpdateRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.automations'),
      createEmptyInstance: AutomationUpdateRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..aOS(3, _omitFieldNames ? '' : 'automationId')
    ..pPS(4, _omitFieldNames ? '' : 'fields')
    ..aI(5, _omitFieldNames ? '' : 'expectedVersion')
    ..aOS(6, _omitFieldNames ? '' : 'name')
    ..aOS(7, _omitFieldNames ? '' : 'triggerJson')
    ..aOS(8, _omitFieldNames ? '' : 'conditionTfql')
    ..aOS(9, _omitFieldNames ? '' : 'actionsJson')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AutomationUpdateRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AutomationUpdateRequest copyWith(
          void Function(AutomationUpdateRequest) updates) =>
      super.copyWith((message) => updates(message as AutomationUpdateRequest))
          as AutomationUpdateRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use AutomationUpdateRequest() / AutomationUpdateRequest.new instead')
  static AutomationUpdateRequest create() => AutomationUpdateRequest._();
  static $pb.GeneratedMessage $_createMessage() => AutomationUpdateRequest._();
  @$core.override
  AutomationUpdateRequest createEmptyInstance() => AutomationUpdateRequest._();
  @$core.pragma('dart2js:noInline')
  static AutomationUpdateRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AutomationUpdateRequest>(
          AutomationUpdateRequest.$_createMessage);
  static AutomationUpdateRequest? _defaultInstance;

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
  $core.String get automationId => $_getSZ(2);
  @$pb.TagNumber(3)
  set automationId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAutomationId() => $_has(2);
  @$pb.TagNumber(3)
  void clearAutomationId() => $_clearField(3);

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
  $core.String get triggerJson => $_getSZ(6);
  @$pb.TagNumber(7)
  set triggerJson($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasTriggerJson() => $_has(6);
  @$pb.TagNumber(7)
  void clearTriggerJson() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get conditionTfql => $_getSZ(7);
  @$pb.TagNumber(8)
  set conditionTfql($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasConditionTfql() => $_has(7);
  @$pb.TagNumber(8)
  void clearConditionTfql() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get actionsJson => $_getSZ(8);
  @$pb.TagNumber(9)
  set actionsJson($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasActionsJson() => $_has(8);
  @$pb.TagNumber(9)
  void clearActionsJson() => $_clearField(9);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
