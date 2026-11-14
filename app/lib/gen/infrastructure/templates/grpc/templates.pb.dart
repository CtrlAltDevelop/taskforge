// This is a generated file - do not edit.
//
// Generated from infrastructure/templates/grpc/templates.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class Template extends $pb.GeneratedMessage {
  factory Template({
    $core.String? id,
    $core.String? kind,
    $core.String? name,
    $core.String? description,
    $core.String? visibility,
    $core.bool? builtin,
    $core.String? createdBy,
    $core.String? createdAt,
    $core.String? updatedAt,
    $core.int? version,
    $core.int? taskCount,
    $core.Iterable<$core.String>? variables,
    $core.Iterable<$core.String>? includes,
    $core.Iterable<$core.String>? statusNames,
    $core.bool? canEdit,
    $core.String? contentJson,
  }) {
    final result = Template._();
    if (id != null) result.id = id;
    if (kind != null) result.kind = kind;
    if (name != null) result.name = name;
    if (description != null) result.description = description;
    if (visibility != null) result.visibility = visibility;
    if (builtin != null) result.builtin = builtin;
    if (createdBy != null) result.createdBy = createdBy;
    if (createdAt != null) result.createdAt = createdAt;
    if (updatedAt != null) result.updatedAt = updatedAt;
    if (version != null) result.version = version;
    if (taskCount != null) result.taskCount = taskCount;
    if (variables != null) result.variables.addAll(variables);
    if (includes != null) result.includes.addAll(includes);
    if (statusNames != null) result.statusNames.addAll(statusNames);
    if (canEdit != null) result.canEdit = canEdit;
    if (contentJson != null) result.contentJson = contentJson;
    return result;
  }

  Template._();

  factory Template.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Template()..mergeFromBuffer(data, registry);
  factory Template.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Template()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Template',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.templates'),
      createEmptyInstance: Template.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'kind')
    ..aOS(3, _omitFieldNames ? '' : 'name')
    ..aOS(4, _omitFieldNames ? '' : 'description')
    ..aOS(5, _omitFieldNames ? '' : 'visibility')
    ..aOB(6, _omitFieldNames ? '' : 'builtin')
    ..aOS(7, _omitFieldNames ? '' : 'createdBy')
    ..aOS(8, _omitFieldNames ? '' : 'createdAt')
    ..aOS(9, _omitFieldNames ? '' : 'updatedAt')
    ..aI(10, _omitFieldNames ? '' : 'version')
    ..aI(11, _omitFieldNames ? '' : 'taskCount')
    ..pPS(12, _omitFieldNames ? '' : 'variables')
    ..pPS(13, _omitFieldNames ? '' : 'includes')
    ..pPS(14, _omitFieldNames ? '' : 'statusNames')
    ..aOB(15, _omitFieldNames ? '' : 'canEdit')
    ..aOS(16, _omitFieldNames ? '' : 'contentJson')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Template clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Template copyWith(void Function(Template) updates) =>
      super.copyWith((message) => updates(message as Template)) as Template;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Template() / Template.new instead')
  static Template create() => Template._();
  static $pb.GeneratedMessage $_createMessage() => Template._();
  @$core.override
  Template createEmptyInstance() => Template._();
  @$core.pragma('dart2js:noInline')
  static Template getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Template>(Template.$_createMessage);
  static Template? _defaultInstance;

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
  $core.String get name => $_getSZ(2);
  @$pb.TagNumber(3)
  set name($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasName() => $_has(2);
  @$pb.TagNumber(3)
  void clearName() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get description => $_getSZ(3);
  @$pb.TagNumber(4)
  set description($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasDescription() => $_has(3);
  @$pb.TagNumber(4)
  void clearDescription() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get visibility => $_getSZ(4);
  @$pb.TagNumber(5)
  set visibility($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasVisibility() => $_has(4);
  @$pb.TagNumber(5)
  void clearVisibility() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.bool get builtin => $_getBF(5);
  @$pb.TagNumber(6)
  set builtin($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasBuiltin() => $_has(5);
  @$pb.TagNumber(6)
  void clearBuiltin() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get createdBy => $_getSZ(6);
  @$pb.TagNumber(7)
  set createdBy($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasCreatedBy() => $_has(6);
  @$pb.TagNumber(7)
  void clearCreatedBy() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get createdAt => $_getSZ(7);
  @$pb.TagNumber(8)
  set createdAt($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasCreatedAt() => $_has(7);
  @$pb.TagNumber(8)
  void clearCreatedAt() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get updatedAt => $_getSZ(8);
  @$pb.TagNumber(9)
  set updatedAt($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasUpdatedAt() => $_has(8);
  @$pb.TagNumber(9)
  void clearUpdatedAt() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.int get version => $_getIZ(9);
  @$pb.TagNumber(10)
  set version($core.int value) => $_setSignedInt32(9, value);
  @$pb.TagNumber(10)
  $core.bool hasVersion() => $_has(9);
  @$pb.TagNumber(10)
  void clearVersion() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.int get taskCount => $_getIZ(10);
  @$pb.TagNumber(11)
  set taskCount($core.int value) => $_setSignedInt32(10, value);
  @$pb.TagNumber(11)
  $core.bool hasTaskCount() => $_has(10);
  @$pb.TagNumber(11)
  void clearTaskCount() => $_clearField(11);

  @$pb.TagNumber(12)
  $pb.PbList<$core.String> get variables => $_getList(11);

  @$pb.TagNumber(13)
  $pb.PbList<$core.String> get includes => $_getList(12);

  @$pb.TagNumber(14)
  $pb.PbList<$core.String> get statusNames => $_getList(13);

  @$pb.TagNumber(15)
  $core.bool get canEdit => $_getBF(14);
  @$pb.TagNumber(15)
  set canEdit($core.bool value) => $_setBool(14, value);
  @$pb.TagNumber(15)
  $core.bool hasCanEdit() => $_has(14);
  @$pb.TagNumber(15)
  void clearCanEdit() => $_clearField(15);

  @$pb.TagNumber(16)
  $core.String get contentJson => $_getSZ(15);
  @$pb.TagNumber(16)
  set contentJson($core.String value) => $_setString(15, value);
  @$pb.TagNumber(16)
  $core.bool hasContentJson() => $_has(15);
  @$pb.TagNumber(16)
  void clearContentJson() => $_clearField(16);
}

class TemplateAnswer extends $pb.GeneratedMessage {
  factory TemplateAnswer({
    Template? template,
  }) {
    final result = TemplateAnswer._();
    if (template != null) result.template = template;
    return result;
  }

  TemplateAnswer._();

  factory TemplateAnswer.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TemplateAnswer()..mergeFromBuffer(data, registry);
  factory TemplateAnswer.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TemplateAnswer()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TemplateAnswer',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.templates'),
      createEmptyInstance: TemplateAnswer.$_createMessage)
    ..aOM<Template>(1, _omitFieldNames ? '' : 'template',
        subBuilder: Template.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TemplateAnswer clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TemplateAnswer copyWith(void Function(TemplateAnswer) updates) =>
      super.copyWith((message) => updates(message as TemplateAnswer))
          as TemplateAnswer;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use TemplateAnswer() / TemplateAnswer.new instead')
  static TemplateAnswer create() => TemplateAnswer._();
  static $pb.GeneratedMessage $_createMessage() => TemplateAnswer._();
  @$core.override
  TemplateAnswer createEmptyInstance() => TemplateAnswer._();
  @$core.pragma('dart2js:noInline')
  static TemplateAnswer getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TemplateAnswer>(
          TemplateAnswer.$_createMessage);
  static TemplateAnswer? _defaultInstance;

  @$pb.TagNumber(1)
  Template get template => $_getN(0);
  @$pb.TagNumber(1)
  set template(Template value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasTemplate() => $_has(0);
  @$pb.TagNumber(1)
  void clearTemplate() => $_clearField(1);
  @$pb.TagNumber(1)
  Template ensureTemplate() => $_ensure(0);
}

class TemplateApplied extends $pb.GeneratedMessage {
  factory TemplateApplied({
    $core.String? projectId,
    $core.Iterable<$core.String>? taskIds,
    $core.Iterable<Warning>? warnings,
  }) {
    final result = TemplateApplied._();
    if (projectId != null) result.projectId = projectId;
    if (taskIds != null) result.taskIds.addAll(taskIds);
    if (warnings != null) result.warnings.addAll(warnings);
    return result;
  }

  TemplateApplied._();

  factory TemplateApplied.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TemplateApplied()..mergeFromBuffer(data, registry);
  factory TemplateApplied.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TemplateApplied()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TemplateApplied',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.templates'),
      createEmptyInstance: TemplateApplied.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'projectId')
    ..pPS(2, _omitFieldNames ? '' : 'taskIds')
    ..pPM<Warning>(3, _omitFieldNames ? '' : 'warnings',
        subBuilder: Warning.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TemplateApplied clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TemplateApplied copyWith(void Function(TemplateApplied) updates) =>
      super.copyWith((message) => updates(message as TemplateApplied))
          as TemplateApplied;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use TemplateApplied() / TemplateApplied.new instead')
  static TemplateApplied create() => TemplateApplied._();
  static $pb.GeneratedMessage $_createMessage() => TemplateApplied._();
  @$core.override
  TemplateApplied createEmptyInstance() => TemplateApplied._();
  @$core.pragma('dart2js:noInline')
  static TemplateApplied getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TemplateApplied>(
          TemplateApplied.$_createMessage);
  static TemplateApplied? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get projectId => $_getSZ(0);
  @$pb.TagNumber(1)
  set projectId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasProjectId() => $_has(0);
  @$pb.TagNumber(1)
  void clearProjectId() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<$core.String> get taskIds => $_getList(1);

  @$pb.TagNumber(3)
  $pb.PbList<Warning> get warnings => $_getList(2);
}

class TemplateApplyRequest extends $pb.GeneratedMessage {
  factory TemplateApplyRequest({
    $core.String? workspaceId,
    $core.String? templateId,
    $core.String? projectId,
    $core.String? parentTaskId,
    $core.String? projectName,
    $core.String? projectKey,
    $core.String? projectDescription,
    $core.String? projectIcon,
    $core.String? projectColor,
    $core.String? projectVisibility,
    $core.String? startDate,
    $core.Iterable<Variable>? variables,
  }) {
    final result = TemplateApplyRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (templateId != null) result.templateId = templateId;
    if (projectId != null) result.projectId = projectId;
    if (parentTaskId != null) result.parentTaskId = parentTaskId;
    if (projectName != null) result.projectName = projectName;
    if (projectKey != null) result.projectKey = projectKey;
    if (projectDescription != null)
      result.projectDescription = projectDescription;
    if (projectIcon != null) result.projectIcon = projectIcon;
    if (projectColor != null) result.projectColor = projectColor;
    if (projectVisibility != null) result.projectVisibility = projectVisibility;
    if (startDate != null) result.startDate = startDate;
    if (variables != null) result.variables.addAll(variables);
    return result;
  }

  TemplateApplyRequest._();

  factory TemplateApplyRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TemplateApplyRequest()..mergeFromBuffer(data, registry);
  factory TemplateApplyRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TemplateApplyRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TemplateApplyRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.templates'),
      createEmptyInstance: TemplateApplyRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'templateId')
    ..aOS(3, _omitFieldNames ? '' : 'projectId')
    ..aOS(4, _omitFieldNames ? '' : 'parentTaskId')
    ..aOS(5, _omitFieldNames ? '' : 'projectName')
    ..aOS(6, _omitFieldNames ? '' : 'projectKey')
    ..aOS(7, _omitFieldNames ? '' : 'projectDescription')
    ..aOS(8, _omitFieldNames ? '' : 'projectIcon')
    ..aOS(9, _omitFieldNames ? '' : 'projectColor')
    ..aOS(10, _omitFieldNames ? '' : 'projectVisibility')
    ..aOS(11, _omitFieldNames ? '' : 'startDate')
    ..pPM<Variable>(12, _omitFieldNames ? '' : 'variables',
        subBuilder: Variable.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TemplateApplyRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TemplateApplyRequest copyWith(void Function(TemplateApplyRequest) updates) =>
      super.copyWith((message) => updates(message as TemplateApplyRequest))
          as TemplateApplyRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use TemplateApplyRequest() / TemplateApplyRequest.new instead')
  static TemplateApplyRequest create() => TemplateApplyRequest._();
  static $pb.GeneratedMessage $_createMessage() => TemplateApplyRequest._();
  @$core.override
  TemplateApplyRequest createEmptyInstance() => TemplateApplyRequest._();
  @$core.pragma('dart2js:noInline')
  static TemplateApplyRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TemplateApplyRequest>(
          TemplateApplyRequest.$_createMessage);
  static TemplateApplyRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get templateId => $_getSZ(1);
  @$pb.TagNumber(2)
  set templateId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTemplateId() => $_has(1);
  @$pb.TagNumber(2)
  void clearTemplateId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get projectId => $_getSZ(2);
  @$pb.TagNumber(3)
  set projectId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasProjectId() => $_has(2);
  @$pb.TagNumber(3)
  void clearProjectId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get parentTaskId => $_getSZ(3);
  @$pb.TagNumber(4)
  set parentTaskId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasParentTaskId() => $_has(3);
  @$pb.TagNumber(4)
  void clearParentTaskId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get projectName => $_getSZ(4);
  @$pb.TagNumber(5)
  set projectName($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasProjectName() => $_has(4);
  @$pb.TagNumber(5)
  void clearProjectName() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get projectKey => $_getSZ(5);
  @$pb.TagNumber(6)
  set projectKey($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasProjectKey() => $_has(5);
  @$pb.TagNumber(6)
  void clearProjectKey() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get projectDescription => $_getSZ(6);
  @$pb.TagNumber(7)
  set projectDescription($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasProjectDescription() => $_has(6);
  @$pb.TagNumber(7)
  void clearProjectDescription() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get projectIcon => $_getSZ(7);
  @$pb.TagNumber(8)
  set projectIcon($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasProjectIcon() => $_has(7);
  @$pb.TagNumber(8)
  void clearProjectIcon() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get projectColor => $_getSZ(8);
  @$pb.TagNumber(9)
  set projectColor($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasProjectColor() => $_has(8);
  @$pb.TagNumber(9)
  void clearProjectColor() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get projectVisibility => $_getSZ(9);
  @$pb.TagNumber(10)
  set projectVisibility($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasProjectVisibility() => $_has(9);
  @$pb.TagNumber(10)
  void clearProjectVisibility() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.String get startDate => $_getSZ(10);
  @$pb.TagNumber(11)
  set startDate($core.String value) => $_setString(10, value);
  @$pb.TagNumber(11)
  $core.bool hasStartDate() => $_has(10);
  @$pb.TagNumber(11)
  void clearStartDate() => $_clearField(11);

  @$pb.TagNumber(12)
  $pb.PbList<Variable> get variables => $_getList(11);
}

class TemplateCreateRequest extends $pb.GeneratedMessage {
  factory TemplateCreateRequest({
    $core.String? workspaceId,
    $core.String? kind,
    $core.String? name,
    $core.String? description,
    $core.String? visibility,
    $core.String? contentJson,
  }) {
    final result = TemplateCreateRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (kind != null) result.kind = kind;
    if (name != null) result.name = name;
    if (description != null) result.description = description;
    if (visibility != null) result.visibility = visibility;
    if (contentJson != null) result.contentJson = contentJson;
    return result;
  }

  TemplateCreateRequest._();

  factory TemplateCreateRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TemplateCreateRequest()..mergeFromBuffer(data, registry);
  factory TemplateCreateRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TemplateCreateRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TemplateCreateRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.templates'),
      createEmptyInstance: TemplateCreateRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'kind')
    ..aOS(3, _omitFieldNames ? '' : 'name')
    ..aOS(4, _omitFieldNames ? '' : 'description')
    ..aOS(5, _omitFieldNames ? '' : 'visibility')
    ..aOS(6, _omitFieldNames ? '' : 'contentJson')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TemplateCreateRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TemplateCreateRequest copyWith(
          void Function(TemplateCreateRequest) updates) =>
      super.copyWith((message) => updates(message as TemplateCreateRequest))
          as TemplateCreateRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use TemplateCreateRequest() / TemplateCreateRequest.new instead')
  static TemplateCreateRequest create() => TemplateCreateRequest._();
  static $pb.GeneratedMessage $_createMessage() => TemplateCreateRequest._();
  @$core.override
  TemplateCreateRequest createEmptyInstance() => TemplateCreateRequest._();
  @$core.pragma('dart2js:noInline')
  static TemplateCreateRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TemplateCreateRequest>(
          TemplateCreateRequest.$_createMessage);
  static TemplateCreateRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get kind => $_getSZ(1);
  @$pb.TagNumber(2)
  set kind($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasKind() => $_has(1);
  @$pb.TagNumber(2)
  void clearKind() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get name => $_getSZ(2);
  @$pb.TagNumber(3)
  set name($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasName() => $_has(2);
  @$pb.TagNumber(3)
  void clearName() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get description => $_getSZ(3);
  @$pb.TagNumber(4)
  set description($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasDescription() => $_has(3);
  @$pb.TagNumber(4)
  void clearDescription() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get visibility => $_getSZ(4);
  @$pb.TagNumber(5)
  set visibility($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasVisibility() => $_has(4);
  @$pb.TagNumber(5)
  void clearVisibility() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get contentJson => $_getSZ(5);
  @$pb.TagNumber(6)
  set contentJson($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasContentJson() => $_has(5);
  @$pb.TagNumber(6)
  void clearContentJson() => $_clearField(6);
}

class TemplateDeleteRequest extends $pb.GeneratedMessage {
  factory TemplateDeleteRequest({
    $core.String? workspaceId,
    $core.String? templateId,
  }) {
    final result = TemplateDeleteRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (templateId != null) result.templateId = templateId;
    return result;
  }

  TemplateDeleteRequest._();

  factory TemplateDeleteRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TemplateDeleteRequest()..mergeFromBuffer(data, registry);
  factory TemplateDeleteRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TemplateDeleteRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TemplateDeleteRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.templates'),
      createEmptyInstance: TemplateDeleteRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'templateId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TemplateDeleteRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TemplateDeleteRequest copyWith(
          void Function(TemplateDeleteRequest) updates) =>
      super.copyWith((message) => updates(message as TemplateDeleteRequest))
          as TemplateDeleteRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use TemplateDeleteRequest() / TemplateDeleteRequest.new instead')
  static TemplateDeleteRequest create() => TemplateDeleteRequest._();
  static $pb.GeneratedMessage $_createMessage() => TemplateDeleteRequest._();
  @$core.override
  TemplateDeleteRequest createEmptyInstance() => TemplateDeleteRequest._();
  @$core.pragma('dart2js:noInline')
  static TemplateDeleteRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TemplateDeleteRequest>(
          TemplateDeleteRequest.$_createMessage);
  static TemplateDeleteRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get templateId => $_getSZ(1);
  @$pb.TagNumber(2)
  set templateId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTemplateId() => $_has(1);
  @$pb.TagNumber(2)
  void clearTemplateId() => $_clearField(2);
}

class TemplateDeleted extends $pb.GeneratedMessage {
  factory TemplateDeleted({
    $core.String? id,
  }) {
    final result = TemplateDeleted._();
    if (id != null) result.id = id;
    return result;
  }

  TemplateDeleted._();

  factory TemplateDeleted.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TemplateDeleted()..mergeFromBuffer(data, registry);
  factory TemplateDeleted.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TemplateDeleted()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TemplateDeleted',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.templates'),
      createEmptyInstance: TemplateDeleted.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TemplateDeleted clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TemplateDeleted copyWith(void Function(TemplateDeleted) updates) =>
      super.copyWith((message) => updates(message as TemplateDeleted))
          as TemplateDeleted;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use TemplateDeleted() / TemplateDeleted.new instead')
  static TemplateDeleted create() => TemplateDeleted._();
  static $pb.GeneratedMessage $_createMessage() => TemplateDeleted._();
  @$core.override
  TemplateDeleted createEmptyInstance() => TemplateDeleted._();
  @$core.pragma('dart2js:noInline')
  static TemplateDeleted getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TemplateDeleted>(
          TemplateDeleted.$_createMessage);
  static TemplateDeleted? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class TemplateGetRequest extends $pb.GeneratedMessage {
  factory TemplateGetRequest({
    $core.String? workspaceId,
    $core.String? templateId,
  }) {
    final result = TemplateGetRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (templateId != null) result.templateId = templateId;
    return result;
  }

  TemplateGetRequest._();

  factory TemplateGetRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TemplateGetRequest()..mergeFromBuffer(data, registry);
  factory TemplateGetRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TemplateGetRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TemplateGetRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.templates'),
      createEmptyInstance: TemplateGetRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'templateId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TemplateGetRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TemplateGetRequest copyWith(void Function(TemplateGetRequest) updates) =>
      super.copyWith((message) => updates(message as TemplateGetRequest))
          as TemplateGetRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use TemplateGetRequest() / TemplateGetRequest.new instead')
  static TemplateGetRequest create() => TemplateGetRequest._();
  static $pb.GeneratedMessage $_createMessage() => TemplateGetRequest._();
  @$core.override
  TemplateGetRequest createEmptyInstance() => TemplateGetRequest._();
  @$core.pragma('dart2js:noInline')
  static TemplateGetRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TemplateGetRequest>(
          TemplateGetRequest.$_createMessage);
  static TemplateGetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get templateId => $_getSZ(1);
  @$pb.TagNumber(2)
  set templateId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTemplateId() => $_has(1);
  @$pb.TagNumber(2)
  void clearTemplateId() => $_clearField(2);
}

class TemplateList extends $pb.GeneratedMessage {
  factory TemplateList({
    $core.Iterable<Template>? templates,
  }) {
    final result = TemplateList._();
    if (templates != null) result.templates.addAll(templates);
    return result;
  }

  TemplateList._();

  factory TemplateList.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TemplateList()..mergeFromBuffer(data, registry);
  factory TemplateList.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TemplateList()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TemplateList',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.templates'),
      createEmptyInstance: TemplateList.$_createMessage)
    ..pPM<Template>(1, _omitFieldNames ? '' : 'templates',
        subBuilder: Template.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TemplateList clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TemplateList copyWith(void Function(TemplateList) updates) =>
      super.copyWith((message) => updates(message as TemplateList))
          as TemplateList;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use TemplateList() / TemplateList.new instead')
  static TemplateList create() => TemplateList._();
  static $pb.GeneratedMessage $_createMessage() => TemplateList._();
  @$core.override
  TemplateList createEmptyInstance() => TemplateList._();
  @$core.pragma('dart2js:noInline')
  static TemplateList getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TemplateList>(
          TemplateList.$_createMessage);
  static TemplateList? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Template> get templates => $_getList(0);
}

class TemplateListRequest extends $pb.GeneratedMessage {
  factory TemplateListRequest({
    $core.String? workspaceId,
    $core.String? query,
    $core.String? kind,
  }) {
    final result = TemplateListRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (query != null) result.query = query;
    if (kind != null) result.kind = kind;
    return result;
  }

  TemplateListRequest._();

  factory TemplateListRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TemplateListRequest()..mergeFromBuffer(data, registry);
  factory TemplateListRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TemplateListRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TemplateListRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.templates'),
      createEmptyInstance: TemplateListRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'query')
    ..aOS(3, _omitFieldNames ? '' : 'kind')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TemplateListRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TemplateListRequest copyWith(void Function(TemplateListRequest) updates) =>
      super.copyWith((message) => updates(message as TemplateListRequest))
          as TemplateListRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core
      .Deprecated('Use TemplateListRequest() / TemplateListRequest.new instead')
  static TemplateListRequest create() => TemplateListRequest._();
  static $pb.GeneratedMessage $_createMessage() => TemplateListRequest._();
  @$core.override
  TemplateListRequest createEmptyInstance() => TemplateListRequest._();
  @$core.pragma('dart2js:noInline')
  static TemplateListRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TemplateListRequest>(
          TemplateListRequest.$_createMessage);
  static TemplateListRequest? _defaultInstance;

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

  @$pb.TagNumber(3)
  $core.String get kind => $_getSZ(2);
  @$pb.TagNumber(3)
  set kind($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasKind() => $_has(2);
  @$pb.TagNumber(3)
  void clearKind() => $_clearField(3);
}

class TemplateSaveFromProjectRequest extends $pb.GeneratedMessage {
  factory TemplateSaveFromProjectRequest({
    $core.String? workspaceId,
    $core.String? projectId,
    $core.String? name,
    $core.String? description,
    $core.String? visibility,
    $core.Iterable<$core.String>? include,
    $core.bool? includeAssignees,
  }) {
    final result = TemplateSaveFromProjectRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (projectId != null) result.projectId = projectId;
    if (name != null) result.name = name;
    if (description != null) result.description = description;
    if (visibility != null) result.visibility = visibility;
    if (include != null) result.include.addAll(include);
    if (includeAssignees != null) result.includeAssignees = includeAssignees;
    return result;
  }

  TemplateSaveFromProjectRequest._();

  factory TemplateSaveFromProjectRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TemplateSaveFromProjectRequest()..mergeFromBuffer(data, registry);
  factory TemplateSaveFromProjectRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TemplateSaveFromProjectRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TemplateSaveFromProjectRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.templates'),
      createEmptyInstance: TemplateSaveFromProjectRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..aOS(3, _omitFieldNames ? '' : 'name')
    ..aOS(4, _omitFieldNames ? '' : 'description')
    ..aOS(5, _omitFieldNames ? '' : 'visibility')
    ..pPS(6, _omitFieldNames ? '' : 'include')
    ..aOB(7, _omitFieldNames ? '' : 'includeAssignees')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TemplateSaveFromProjectRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TemplateSaveFromProjectRequest copyWith(
          void Function(TemplateSaveFromProjectRequest) updates) =>
      super.copyWith(
              (message) => updates(message as TemplateSaveFromProjectRequest))
          as TemplateSaveFromProjectRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use TemplateSaveFromProjectRequest() / TemplateSaveFromProjectRequest.new instead')
  static TemplateSaveFromProjectRequest create() =>
      TemplateSaveFromProjectRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      TemplateSaveFromProjectRequest._();
  @$core.override
  TemplateSaveFromProjectRequest createEmptyInstance() =>
      TemplateSaveFromProjectRequest._();
  @$core.pragma('dart2js:noInline')
  static TemplateSaveFromProjectRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TemplateSaveFromProjectRequest>(
          TemplateSaveFromProjectRequest.$_createMessage);
  static TemplateSaveFromProjectRequest? _defaultInstance;

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
  $core.String get description => $_getSZ(3);
  @$pb.TagNumber(4)
  set description($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasDescription() => $_has(3);
  @$pb.TagNumber(4)
  void clearDescription() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get visibility => $_getSZ(4);
  @$pb.TagNumber(5)
  set visibility($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasVisibility() => $_has(4);
  @$pb.TagNumber(5)
  void clearVisibility() => $_clearField(5);

  @$pb.TagNumber(6)
  $pb.PbList<$core.String> get include => $_getList(5);

  @$pb.TagNumber(7)
  $core.bool get includeAssignees => $_getBF(6);
  @$pb.TagNumber(7)
  set includeAssignees($core.bool value) => $_setBool(6, value);
  @$pb.TagNumber(7)
  $core.bool hasIncludeAssignees() => $_has(6);
  @$pb.TagNumber(7)
  void clearIncludeAssignees() => $_clearField(7);
}

class TemplateSaveFromTaskRequest extends $pb.GeneratedMessage {
  factory TemplateSaveFromTaskRequest({
    $core.String? workspaceId,
    $core.String? projectId,
    $core.String? taskId,
    $core.String? name,
    $core.String? description,
    $core.String? visibility,
    $core.bool? includeAssignees,
  }) {
    final result = TemplateSaveFromTaskRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (projectId != null) result.projectId = projectId;
    if (taskId != null) result.taskId = taskId;
    if (name != null) result.name = name;
    if (description != null) result.description = description;
    if (visibility != null) result.visibility = visibility;
    if (includeAssignees != null) result.includeAssignees = includeAssignees;
    return result;
  }

  TemplateSaveFromTaskRequest._();

  factory TemplateSaveFromTaskRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TemplateSaveFromTaskRequest()..mergeFromBuffer(data, registry);
  factory TemplateSaveFromTaskRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TemplateSaveFromTaskRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TemplateSaveFromTaskRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.templates'),
      createEmptyInstance: TemplateSaveFromTaskRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..aOS(3, _omitFieldNames ? '' : 'taskId')
    ..aOS(4, _omitFieldNames ? '' : 'name')
    ..aOS(5, _omitFieldNames ? '' : 'description')
    ..aOS(6, _omitFieldNames ? '' : 'visibility')
    ..aOB(7, _omitFieldNames ? '' : 'includeAssignees')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TemplateSaveFromTaskRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TemplateSaveFromTaskRequest copyWith(
          void Function(TemplateSaveFromTaskRequest) updates) =>
      super.copyWith(
              (message) => updates(message as TemplateSaveFromTaskRequest))
          as TemplateSaveFromTaskRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use TemplateSaveFromTaskRequest() / TemplateSaveFromTaskRequest.new instead')
  static TemplateSaveFromTaskRequest create() =>
      TemplateSaveFromTaskRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      TemplateSaveFromTaskRequest._();
  @$core.override
  TemplateSaveFromTaskRequest createEmptyInstance() =>
      TemplateSaveFromTaskRequest._();
  @$core.pragma('dart2js:noInline')
  static TemplateSaveFromTaskRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TemplateSaveFromTaskRequest>(
          TemplateSaveFromTaskRequest.$_createMessage);
  static TemplateSaveFromTaskRequest? _defaultInstance;

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
  $core.String get name => $_getSZ(3);
  @$pb.TagNumber(4)
  set name($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasName() => $_has(3);
  @$pb.TagNumber(4)
  void clearName() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get description => $_getSZ(4);
  @$pb.TagNumber(5)
  set description($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasDescription() => $_has(4);
  @$pb.TagNumber(5)
  void clearDescription() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get visibility => $_getSZ(5);
  @$pb.TagNumber(6)
  set visibility($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasVisibility() => $_has(5);
  @$pb.TagNumber(6)
  void clearVisibility() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.bool get includeAssignees => $_getBF(6);
  @$pb.TagNumber(7)
  set includeAssignees($core.bool value) => $_setBool(6, value);
  @$pb.TagNumber(7)
  $core.bool hasIncludeAssignees() => $_has(6);
  @$pb.TagNumber(7)
  void clearIncludeAssignees() => $_clearField(7);
}

class TemplateUpdateRequest extends $pb.GeneratedMessage {
  factory TemplateUpdateRequest({
    $core.String? workspaceId,
    $core.String? templateId,
    $core.Iterable<$core.String>? changed,
    $core.int? expectedVersion,
    $core.String? name,
    $core.String? description,
    $core.String? visibility,
    $core.String? contentJson,
  }) {
    final result = TemplateUpdateRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (templateId != null) result.templateId = templateId;
    if (changed != null) result.changed.addAll(changed);
    if (expectedVersion != null) result.expectedVersion = expectedVersion;
    if (name != null) result.name = name;
    if (description != null) result.description = description;
    if (visibility != null) result.visibility = visibility;
    if (contentJson != null) result.contentJson = contentJson;
    return result;
  }

  TemplateUpdateRequest._();

  factory TemplateUpdateRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TemplateUpdateRequest()..mergeFromBuffer(data, registry);
  factory TemplateUpdateRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TemplateUpdateRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TemplateUpdateRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.templates'),
      createEmptyInstance: TemplateUpdateRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'templateId')
    ..pPS(3, _omitFieldNames ? '' : 'changed')
    ..aI(4, _omitFieldNames ? '' : 'expectedVersion')
    ..aOS(5, _omitFieldNames ? '' : 'name')
    ..aOS(6, _omitFieldNames ? '' : 'description')
    ..aOS(7, _omitFieldNames ? '' : 'visibility')
    ..aOS(8, _omitFieldNames ? '' : 'contentJson')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TemplateUpdateRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TemplateUpdateRequest copyWith(
          void Function(TemplateUpdateRequest) updates) =>
      super.copyWith((message) => updates(message as TemplateUpdateRequest))
          as TemplateUpdateRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use TemplateUpdateRequest() / TemplateUpdateRequest.new instead')
  static TemplateUpdateRequest create() => TemplateUpdateRequest._();
  static $pb.GeneratedMessage $_createMessage() => TemplateUpdateRequest._();
  @$core.override
  TemplateUpdateRequest createEmptyInstance() => TemplateUpdateRequest._();
  @$core.pragma('dart2js:noInline')
  static TemplateUpdateRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TemplateUpdateRequest>(
          TemplateUpdateRequest.$_createMessage);
  static TemplateUpdateRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get templateId => $_getSZ(1);
  @$pb.TagNumber(2)
  set templateId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTemplateId() => $_has(1);
  @$pb.TagNumber(2)
  void clearTemplateId() => $_clearField(2);

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
  $core.String get visibility => $_getSZ(6);
  @$pb.TagNumber(7)
  set visibility($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasVisibility() => $_has(6);
  @$pb.TagNumber(7)
  void clearVisibility() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get contentJson => $_getSZ(7);
  @$pb.TagNumber(8)
  set contentJson($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasContentJson() => $_has(7);
  @$pb.TagNumber(8)
  void clearContentJson() => $_clearField(8);
}

class Variable extends $pb.GeneratedMessage {
  factory Variable({
    $core.String? name,
    $core.String? value,
  }) {
    final result = Variable._();
    if (name != null) result.name = name;
    if (value != null) result.value = value;
    return result;
  }

  Variable._();

  factory Variable.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Variable()..mergeFromBuffer(data, registry);
  factory Variable.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Variable()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Variable',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.templates'),
      createEmptyInstance: Variable.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aOS(2, _omitFieldNames ? '' : 'value')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Variable clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Variable copyWith(void Function(Variable) updates) =>
      super.copyWith((message) => updates(message as Variable)) as Variable;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Variable() / Variable.new instead')
  static Variable create() => Variable._();
  static $pb.GeneratedMessage $_createMessage() => Variable._();
  @$core.override
  Variable createEmptyInstance() => Variable._();
  @$core.pragma('dart2js:noInline')
  static Variable getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Variable>(Variable.$_createMessage);
  static Variable? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get value => $_getSZ(1);
  @$pb.TagNumber(2)
  set value($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasValue() => $_has(1);
  @$pb.TagNumber(2)
  void clearValue() => $_clearField(2);
}

class Warning extends $pb.GeneratedMessage {
  factory Warning({
    $core.String? code,
    $core.String? message,
  }) {
    final result = Warning._();
    if (code != null) result.code = code;
    if (message != null) result.message = message;
    return result;
  }

  Warning._();

  factory Warning.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Warning()..mergeFromBuffer(data, registry);
  factory Warning.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Warning()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Warning',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.templates'),
      createEmptyInstance: Warning.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'code')
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Warning clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Warning copyWith(void Function(Warning) updates) =>
      super.copyWith((message) => updates(message as Warning)) as Warning;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Warning() / Warning.new instead')
  static Warning create() => Warning._();
  static $pb.GeneratedMessage $_createMessage() => Warning._();
  @$core.override
  Warning createEmptyInstance() => Warning._();
  @$core.pragma('dart2js:noInline')
  static Warning getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Warning>(Warning.$_createMessage);
  static Warning? _defaultInstance;

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
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
