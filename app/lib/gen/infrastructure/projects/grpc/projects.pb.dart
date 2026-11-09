// This is a generated file - do not edit.
//
// Generated from infrastructure/projects/grpc/projects.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class Feature extends $pb.GeneratedMessage {
  factory Feature({
    $core.String? key,
    $core.bool? enabled,
  }) {
    final result = Feature._();
    if (key != null) result.key = key;
    if (enabled != null) result.enabled = enabled;
    return result;
  }

  Feature._();

  factory Feature.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Feature()..mergeFromBuffer(data, registry);
  factory Feature.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Feature()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Feature',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.projects'),
      createEmptyInstance: Feature.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'key')
    ..aOB(2, _omitFieldNames ? '' : 'enabled')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Feature clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Feature copyWith(void Function(Feature) updates) =>
      super.copyWith((message) => updates(message as Feature)) as Feature;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Feature() / Feature.new instead')
  static Feature create() => Feature._();
  static $pb.GeneratedMessage $_createMessage() => Feature._();
  @$core.override
  Feature createEmptyInstance() => Feature._();
  @$core.pragma('dart2js:noInline')
  static Feature getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Feature>(Feature.$_createMessage);
  static Feature? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get key => $_getSZ(0);
  @$pb.TagNumber(1)
  set key($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasKey() => $_has(0);
  @$pb.TagNumber(1)
  void clearKey() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get enabled => $_getBF(1);
  @$pb.TagNumber(2)
  set enabled($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasEnabled() => $_has(1);
  @$pb.TagNumber(2)
  void clearEnabled() => $_clearField(2);
}

class FeatureInfo extends $pb.GeneratedMessage {
  factory FeatureInfo({
    $core.String? key,
    $core.String? label,
    $core.String? description,
  }) {
    final result = FeatureInfo._();
    if (key != null) result.key = key;
    if (label != null) result.label = label;
    if (description != null) result.description = description;
    return result;
  }

  FeatureInfo._();

  factory FeatureInfo.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FeatureInfo()..mergeFromBuffer(data, registry);
  factory FeatureInfo.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FeatureInfo()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FeatureInfo',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.projects'),
      createEmptyInstance: FeatureInfo.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'key')
    ..aOS(2, _omitFieldNames ? '' : 'label')
    ..aOS(3, _omitFieldNames ? '' : 'description')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FeatureInfo clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FeatureInfo copyWith(void Function(FeatureInfo) updates) =>
      super.copyWith((message) => updates(message as FeatureInfo))
          as FeatureInfo;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use FeatureInfo() / FeatureInfo.new instead')
  static FeatureInfo create() => FeatureInfo._();
  static $pb.GeneratedMessage $_createMessage() => FeatureInfo._();
  @$core.override
  FeatureInfo createEmptyInstance() => FeatureInfo._();
  @$core.pragma('dart2js:noInline')
  static FeatureInfo getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<FeatureInfo>(
          FeatureInfo.$_createMessage);
  static FeatureInfo? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get key => $_getSZ(0);
  @$pb.TagNumber(1)
  set key($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasKey() => $_has(0);
  @$pb.TagNumber(1)
  void clearKey() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get label => $_getSZ(1);
  @$pb.TagNumber(2)
  set label($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasLabel() => $_has(1);
  @$pb.TagNumber(2)
  void clearLabel() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get description => $_getSZ(2);
  @$pb.TagNumber(3)
  set description($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDescription() => $_has(2);
  @$pb.TagNumber(3)
  void clearDescription() => $_clearField(3);
}

class FeatureResponse extends $pb.GeneratedMessage {
  factory FeatureResponse({
    $core.String? key,
    $core.bool? enabled,
  }) {
    final result = FeatureResponse._();
    if (key != null) result.key = key;
    if (enabled != null) result.enabled = enabled;
    return result;
  }

  FeatureResponse._();

  factory FeatureResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FeatureResponse()..mergeFromBuffer(data, registry);
  factory FeatureResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FeatureResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FeatureResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.projects'),
      createEmptyInstance: FeatureResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'key')
    ..aOB(2, _omitFieldNames ? '' : 'enabled')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FeatureResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FeatureResponse copyWith(void Function(FeatureResponse) updates) =>
      super.copyWith((message) => updates(message as FeatureResponse))
          as FeatureResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use FeatureResponse() / FeatureResponse.new instead')
  static FeatureResponse create() => FeatureResponse._();
  static $pb.GeneratedMessage $_createMessage() => FeatureResponse._();
  @$core.override
  FeatureResponse createEmptyInstance() => FeatureResponse._();
  @$core.pragma('dart2js:noInline')
  static FeatureResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<FeatureResponse>(
          FeatureResponse.$_createMessage);
  static FeatureResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get key => $_getSZ(0);
  @$pb.TagNumber(1)
  set key($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasKey() => $_has(0);
  @$pb.TagNumber(1)
  void clearKey() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get enabled => $_getBF(1);
  @$pb.TagNumber(2)
  set enabled($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasEnabled() => $_has(1);
  @$pb.TagNumber(2)
  void clearEnabled() => $_clearField(2);
}

class PrivateProjectList extends $pb.GeneratedMessage {
  factory PrivateProjectList({
    $core.Iterable<Project>? projects,
  }) {
    final result = PrivateProjectList._();
    if (projects != null) result.projects.addAll(projects);
    return result;
  }

  PrivateProjectList._();

  factory PrivateProjectList.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PrivateProjectList()..mergeFromBuffer(data, registry);
  factory PrivateProjectList.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PrivateProjectList()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PrivateProjectList',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.projects'),
      createEmptyInstance: PrivateProjectList.$_createMessage)
    ..pPM<Project>(1, _omitFieldNames ? '' : 'projects',
        subBuilder: Project.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PrivateProjectList clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PrivateProjectList copyWith(void Function(PrivateProjectList) updates) =>
      super.copyWith((message) => updates(message as PrivateProjectList))
          as PrivateProjectList;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use PrivateProjectList() / PrivateProjectList.new instead')
  static PrivateProjectList create() => PrivateProjectList._();
  static $pb.GeneratedMessage $_createMessage() => PrivateProjectList._();
  @$core.override
  PrivateProjectList createEmptyInstance() => PrivateProjectList._();
  @$core.pragma('dart2js:noInline')
  static PrivateProjectList getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PrivateProjectList>(
          PrivateProjectList.$_createMessage);
  static PrivateProjectList? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Project> get projects => $_getList(0);
}

class Project extends $pb.GeneratedMessage {
  factory Project({
    $core.String? id,
    $core.String? workspaceId,
    $core.String? name,
    $core.String? key,
    $core.String? description,
    $core.String? icon,
    $core.String? color,
    $core.String? visibility,
    $core.String? archivedAt,
    $core.int? version,
    $core.int? taskCounter,
    $core.Iterable<Feature>? features,
    $core.bool? isFavorite,
    $core.int? memberCount,
    $core.bool? isMember,
    $core.bool? canOpen,
    $core.String? createdBy,
  }) {
    final result = Project._();
    if (id != null) result.id = id;
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (name != null) result.name = name;
    if (key != null) result.key = key;
    if (description != null) result.description = description;
    if (icon != null) result.icon = icon;
    if (color != null) result.color = color;
    if (visibility != null) result.visibility = visibility;
    if (archivedAt != null) result.archivedAt = archivedAt;
    if (version != null) result.version = version;
    if (taskCounter != null) result.taskCounter = taskCounter;
    if (features != null) result.features.addAll(features);
    if (isFavorite != null) result.isFavorite = isFavorite;
    if (memberCount != null) result.memberCount = memberCount;
    if (isMember != null) result.isMember = isMember;
    if (canOpen != null) result.canOpen = canOpen;
    if (createdBy != null) result.createdBy = createdBy;
    return result;
  }

  Project._();

  factory Project.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Project()..mergeFromBuffer(data, registry);
  factory Project.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Project()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Project',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.projects'),
      createEmptyInstance: Project.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(3, _omitFieldNames ? '' : 'name')
    ..aOS(4, _omitFieldNames ? '' : 'key')
    ..aOS(5, _omitFieldNames ? '' : 'description')
    ..aOS(6, _omitFieldNames ? '' : 'icon')
    ..aOS(7, _omitFieldNames ? '' : 'color')
    ..aOS(8, _omitFieldNames ? '' : 'visibility')
    ..aOS(9, _omitFieldNames ? '' : 'archivedAt')
    ..aI(10, _omitFieldNames ? '' : 'version')
    ..aI(11, _omitFieldNames ? '' : 'taskCounter')
    ..pPM<Feature>(12, _omitFieldNames ? '' : 'features',
        subBuilder: Feature.$_createMessage)
    ..aOB(13, _omitFieldNames ? '' : 'isFavorite')
    ..aI(14, _omitFieldNames ? '' : 'memberCount')
    ..aOB(15, _omitFieldNames ? '' : 'isMember')
    ..aOB(16, _omitFieldNames ? '' : 'canOpen')
    ..aOS(17, _omitFieldNames ? '' : 'createdBy')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Project clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Project copyWith(void Function(Project) updates) =>
      super.copyWith((message) => updates(message as Project)) as Project;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Project() / Project.new instead')
  static Project create() => Project._();
  static $pb.GeneratedMessage $_createMessage() => Project._();
  @$core.override
  Project createEmptyInstance() => Project._();
  @$core.pragma('dart2js:noInline')
  static Project getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Project>(Project.$_createMessage);
  static Project? _defaultInstance;

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

  @$pb.TagNumber(5)
  $core.String get description => $_getSZ(4);
  @$pb.TagNumber(5)
  set description($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasDescription() => $_has(4);
  @$pb.TagNumber(5)
  void clearDescription() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get icon => $_getSZ(5);
  @$pb.TagNumber(6)
  set icon($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasIcon() => $_has(5);
  @$pb.TagNumber(6)
  void clearIcon() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get color => $_getSZ(6);
  @$pb.TagNumber(7)
  set color($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasColor() => $_has(6);
  @$pb.TagNumber(7)
  void clearColor() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get visibility => $_getSZ(7);
  @$pb.TagNumber(8)
  set visibility($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasVisibility() => $_has(7);
  @$pb.TagNumber(8)
  void clearVisibility() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get archivedAt => $_getSZ(8);
  @$pb.TagNumber(9)
  set archivedAt($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasArchivedAt() => $_has(8);
  @$pb.TagNumber(9)
  void clearArchivedAt() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.int get version => $_getIZ(9);
  @$pb.TagNumber(10)
  set version($core.int value) => $_setSignedInt32(9, value);
  @$pb.TagNumber(10)
  $core.bool hasVersion() => $_has(9);
  @$pb.TagNumber(10)
  void clearVersion() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.int get taskCounter => $_getIZ(10);
  @$pb.TagNumber(11)
  set taskCounter($core.int value) => $_setSignedInt32(10, value);
  @$pb.TagNumber(11)
  $core.bool hasTaskCounter() => $_has(10);
  @$pb.TagNumber(11)
  void clearTaskCounter() => $_clearField(11);

  @$pb.TagNumber(12)
  $pb.PbList<Feature> get features => $_getList(11);

  @$pb.TagNumber(13)
  $core.bool get isFavorite => $_getBF(12);
  @$pb.TagNumber(13)
  set isFavorite($core.bool value) => $_setBool(12, value);
  @$pb.TagNumber(13)
  $core.bool hasIsFavorite() => $_has(12);
  @$pb.TagNumber(13)
  void clearIsFavorite() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.int get memberCount => $_getIZ(13);
  @$pb.TagNumber(14)
  set memberCount($core.int value) => $_setSignedInt32(13, value);
  @$pb.TagNumber(14)
  $core.bool hasMemberCount() => $_has(13);
  @$pb.TagNumber(14)
  void clearMemberCount() => $_clearField(14);

  @$pb.TagNumber(15)
  $core.bool get isMember => $_getBF(14);
  @$pb.TagNumber(15)
  set isMember($core.bool value) => $_setBool(14, value);
  @$pb.TagNumber(15)
  $core.bool hasIsMember() => $_has(14);
  @$pb.TagNumber(15)
  void clearIsMember() => $_clearField(15);

  @$pb.TagNumber(16)
  $core.bool get canOpen => $_getBF(15);
  @$pb.TagNumber(16)
  set canOpen($core.bool value) => $_setBool(15, value);
  @$pb.TagNumber(16)
  $core.bool hasCanOpen() => $_has(15);
  @$pb.TagNumber(16)
  void clearCanOpen() => $_clearField(16);

  @$pb.TagNumber(17)
  $core.String get createdBy => $_getSZ(16);
  @$pb.TagNumber(17)
  set createdBy($core.String value) => $_setString(16, value);
  @$pb.TagNumber(17)
  $core.bool hasCreatedBy() => $_has(16);
  @$pb.TagNumber(17)
  void clearCreatedBy() => $_clearField(17);
}

class ProjectAddMemberRequest extends $pb.GeneratedMessage {
  factory ProjectAddMemberRequest({
    $core.String? workspaceId,
    $core.String? projectId,
    $core.String? userId,
  }) {
    final result = ProjectAddMemberRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (projectId != null) result.projectId = projectId;
    if (userId != null) result.userId = userId;
    return result;
  }

  ProjectAddMemberRequest._();

  factory ProjectAddMemberRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ProjectAddMemberRequest()..mergeFromBuffer(data, registry);
  factory ProjectAddMemberRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ProjectAddMemberRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ProjectAddMemberRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.projects'),
      createEmptyInstance: ProjectAddMemberRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..aOS(3, _omitFieldNames ? '' : 'userId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProjectAddMemberRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProjectAddMemberRequest copyWith(
          void Function(ProjectAddMemberRequest) updates) =>
      super.copyWith((message) => updates(message as ProjectAddMemberRequest))
          as ProjectAddMemberRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ProjectAddMemberRequest() / ProjectAddMemberRequest.new instead')
  static ProjectAddMemberRequest create() => ProjectAddMemberRequest._();
  static $pb.GeneratedMessage $_createMessage() => ProjectAddMemberRequest._();
  @$core.override
  ProjectAddMemberRequest createEmptyInstance() => ProjectAddMemberRequest._();
  @$core.pragma('dart2js:noInline')
  static ProjectAddMemberRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ProjectAddMemberRequest>(
          ProjectAddMemberRequest.$_createMessage);
  static ProjectAddMemberRequest? _defaultInstance;

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
  $core.String get userId => $_getSZ(2);
  @$pb.TagNumber(3)
  set userId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasUserId() => $_has(2);
  @$pb.TagNumber(3)
  void clearUserId() => $_clearField(3);
}

class ProjectArchiveRequest extends $pb.GeneratedMessage {
  factory ProjectArchiveRequest({
    $core.String? workspaceId,
    $core.String? id,
    $core.int? expectedVersion,
  }) {
    final result = ProjectArchiveRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (id != null) result.id = id;
    if (expectedVersion != null) result.expectedVersion = expectedVersion;
    return result;
  }

  ProjectArchiveRequest._();

  factory ProjectArchiveRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ProjectArchiveRequest()..mergeFromBuffer(data, registry);
  factory ProjectArchiveRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ProjectArchiveRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ProjectArchiveRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.projects'),
      createEmptyInstance: ProjectArchiveRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'id')
    ..aI(3, _omitFieldNames ? '' : 'expectedVersion')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProjectArchiveRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProjectArchiveRequest copyWith(
          void Function(ProjectArchiveRequest) updates) =>
      super.copyWith((message) => updates(message as ProjectArchiveRequest))
          as ProjectArchiveRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ProjectArchiveRequest() / ProjectArchiveRequest.new instead')
  static ProjectArchiveRequest create() => ProjectArchiveRequest._();
  static $pb.GeneratedMessage $_createMessage() => ProjectArchiveRequest._();
  @$core.override
  ProjectArchiveRequest createEmptyInstance() => ProjectArchiveRequest._();
  @$core.pragma('dart2js:noInline')
  static ProjectArchiveRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ProjectArchiveRequest>(
          ProjectArchiveRequest.$_createMessage);
  static ProjectArchiveRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get id => $_getSZ(1);
  @$pb.TagNumber(2)
  set id($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasId() => $_has(1);
  @$pb.TagNumber(2)
  void clearId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get expectedVersion => $_getIZ(2);
  @$pb.TagNumber(3)
  set expectedVersion($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasExpectedVersion() => $_has(2);
  @$pb.TagNumber(3)
  void clearExpectedVersion() => $_clearField(3);
}

class ProjectCreateRequest extends $pb.GeneratedMessage {
  factory ProjectCreateRequest({
    $core.String? workspaceId,
    $core.String? name,
    $core.String? key,
    $core.String? description,
    $core.String? icon,
    $core.String? color,
    $core.String? visibility,
  }) {
    final result = ProjectCreateRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (name != null) result.name = name;
    if (key != null) result.key = key;
    if (description != null) result.description = description;
    if (icon != null) result.icon = icon;
    if (color != null) result.color = color;
    if (visibility != null) result.visibility = visibility;
    return result;
  }

  ProjectCreateRequest._();

  factory ProjectCreateRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ProjectCreateRequest()..mergeFromBuffer(data, registry);
  factory ProjectCreateRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ProjectCreateRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ProjectCreateRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.projects'),
      createEmptyInstance: ProjectCreateRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOS(3, _omitFieldNames ? '' : 'key')
    ..aOS(4, _omitFieldNames ? '' : 'description')
    ..aOS(5, _omitFieldNames ? '' : 'icon')
    ..aOS(6, _omitFieldNames ? '' : 'color')
    ..aOS(7, _omitFieldNames ? '' : 'visibility')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProjectCreateRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProjectCreateRequest copyWith(void Function(ProjectCreateRequest) updates) =>
      super.copyWith((message) => updates(message as ProjectCreateRequest))
          as ProjectCreateRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ProjectCreateRequest() / ProjectCreateRequest.new instead')
  static ProjectCreateRequest create() => ProjectCreateRequest._();
  static $pb.GeneratedMessage $_createMessage() => ProjectCreateRequest._();
  @$core.override
  ProjectCreateRequest createEmptyInstance() => ProjectCreateRequest._();
  @$core.pragma('dart2js:noInline')
  static ProjectCreateRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ProjectCreateRequest>(
          ProjectCreateRequest.$_createMessage);
  static ProjectCreateRequest? _defaultInstance;

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
  $core.String get key => $_getSZ(2);
  @$pb.TagNumber(3)
  set key($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasKey() => $_has(2);
  @$pb.TagNumber(3)
  void clearKey() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get description => $_getSZ(3);
  @$pb.TagNumber(4)
  set description($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasDescription() => $_has(3);
  @$pb.TagNumber(4)
  void clearDescription() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get icon => $_getSZ(4);
  @$pb.TagNumber(5)
  set icon($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasIcon() => $_has(4);
  @$pb.TagNumber(5)
  void clearIcon() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get color => $_getSZ(5);
  @$pb.TagNumber(6)
  set color($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasColor() => $_has(5);
  @$pb.TagNumber(6)
  void clearColor() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get visibility => $_getSZ(6);
  @$pb.TagNumber(7)
  set visibility($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasVisibility() => $_has(6);
  @$pb.TagNumber(7)
  void clearVisibility() => $_clearField(7);
}

class ProjectEmpty extends $pb.GeneratedMessage {
  factory ProjectEmpty() => ProjectEmpty._();

  ProjectEmpty._();

  factory ProjectEmpty.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ProjectEmpty()..mergeFromBuffer(data, registry);
  factory ProjectEmpty.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ProjectEmpty()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ProjectEmpty',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.projects'),
      createEmptyInstance: ProjectEmpty.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProjectEmpty clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProjectEmpty copyWith(void Function(ProjectEmpty) updates) =>
      super.copyWith((message) => updates(message as ProjectEmpty))
          as ProjectEmpty;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ProjectEmpty() / ProjectEmpty.new instead')
  static ProjectEmpty create() => ProjectEmpty._();
  static $pb.GeneratedMessage $_createMessage() => ProjectEmpty._();
  @$core.override
  ProjectEmpty createEmptyInstance() => ProjectEmpty._();
  @$core.pragma('dart2js:noInline')
  static ProjectEmpty getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ProjectEmpty>(
          ProjectEmpty.$_createMessage);
  static ProjectEmpty? _defaultInstance;
}

class ProjectFavoriteRequest extends $pb.GeneratedMessage {
  factory ProjectFavoriteRequest({
    $core.String? workspaceId,
    $core.String? projectId,
    $core.bool? favorite,
  }) {
    final result = ProjectFavoriteRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (projectId != null) result.projectId = projectId;
    if (favorite != null) result.favorite = favorite;
    return result;
  }

  ProjectFavoriteRequest._();

  factory ProjectFavoriteRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ProjectFavoriteRequest()..mergeFromBuffer(data, registry);
  factory ProjectFavoriteRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ProjectFavoriteRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ProjectFavoriteRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.projects'),
      createEmptyInstance: ProjectFavoriteRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..aOB(3, _omitFieldNames ? '' : 'favorite')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProjectFavoriteRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProjectFavoriteRequest copyWith(
          void Function(ProjectFavoriteRequest) updates) =>
      super.copyWith((message) => updates(message as ProjectFavoriteRequest))
          as ProjectFavoriteRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ProjectFavoriteRequest() / ProjectFavoriteRequest.new instead')
  static ProjectFavoriteRequest create() => ProjectFavoriteRequest._();
  static $pb.GeneratedMessage $_createMessage() => ProjectFavoriteRequest._();
  @$core.override
  ProjectFavoriteRequest createEmptyInstance() => ProjectFavoriteRequest._();
  @$core.pragma('dart2js:noInline')
  static ProjectFavoriteRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ProjectFavoriteRequest>(
          ProjectFavoriteRequest.$_createMessage);
  static ProjectFavoriteRequest? _defaultInstance;

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
  $core.bool get favorite => $_getBF(2);
  @$pb.TagNumber(3)
  set favorite($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFavorite() => $_has(2);
  @$pb.TagNumber(3)
  void clearFavorite() => $_clearField(3);
}

class ProjectGetRequest extends $pb.GeneratedMessage {
  factory ProjectGetRequest({
    $core.String? workspaceId,
    $core.String? id,
  }) {
    final result = ProjectGetRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (id != null) result.id = id;
    return result;
  }

  ProjectGetRequest._();

  factory ProjectGetRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ProjectGetRequest()..mergeFromBuffer(data, registry);
  factory ProjectGetRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ProjectGetRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ProjectGetRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.projects'),
      createEmptyInstance: ProjectGetRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProjectGetRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProjectGetRequest copyWith(void Function(ProjectGetRequest) updates) =>
      super.copyWith((message) => updates(message as ProjectGetRequest))
          as ProjectGetRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ProjectGetRequest() / ProjectGetRequest.new instead')
  static ProjectGetRequest create() => ProjectGetRequest._();
  static $pb.GeneratedMessage $_createMessage() => ProjectGetRequest._();
  @$core.override
  ProjectGetRequest createEmptyInstance() => ProjectGetRequest._();
  @$core.pragma('dart2js:noInline')
  static ProjectGetRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ProjectGetRequest>(
          ProjectGetRequest.$_createMessage);
  static ProjectGetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get id => $_getSZ(1);
  @$pb.TagNumber(2)
  set id($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasId() => $_has(1);
  @$pb.TagNumber(2)
  void clearId() => $_clearField(2);
}

class ProjectList extends $pb.GeneratedMessage {
  factory ProjectList({
    $core.Iterable<Project>? projects,
    $core.Iterable<FeatureInfo>? featureInfo,
  }) {
    final result = ProjectList._();
    if (projects != null) result.projects.addAll(projects);
    if (featureInfo != null) result.featureInfo.addAll(featureInfo);
    return result;
  }

  ProjectList._();

  factory ProjectList.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ProjectList()..mergeFromBuffer(data, registry);
  factory ProjectList.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ProjectList()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ProjectList',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.projects'),
      createEmptyInstance: ProjectList.$_createMessage)
    ..pPM<Project>(1, _omitFieldNames ? '' : 'projects',
        subBuilder: Project.$_createMessage)
    ..pPM<FeatureInfo>(2, _omitFieldNames ? '' : 'featureInfo',
        subBuilder: FeatureInfo.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProjectList clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProjectList copyWith(void Function(ProjectList) updates) =>
      super.copyWith((message) => updates(message as ProjectList))
          as ProjectList;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ProjectList() / ProjectList.new instead')
  static ProjectList create() => ProjectList._();
  static $pb.GeneratedMessage $_createMessage() => ProjectList._();
  @$core.override
  ProjectList createEmptyInstance() => ProjectList._();
  @$core.pragma('dart2js:noInline')
  static ProjectList getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ProjectList>(
          ProjectList.$_createMessage);
  static ProjectList? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Project> get projects => $_getList(0);

  @$pb.TagNumber(2)
  $pb.PbList<FeatureInfo> get featureInfo => $_getList(1);
}

class ProjectListMembersRequest extends $pb.GeneratedMessage {
  factory ProjectListMembersRequest({
    $core.String? workspaceId,
    $core.String? projectId,
  }) {
    final result = ProjectListMembersRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (projectId != null) result.projectId = projectId;
    return result;
  }

  ProjectListMembersRequest._();

  factory ProjectListMembersRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ProjectListMembersRequest()..mergeFromBuffer(data, registry);
  factory ProjectListMembersRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ProjectListMembersRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ProjectListMembersRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.projects'),
      createEmptyInstance: ProjectListMembersRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProjectListMembersRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProjectListMembersRequest copyWith(
          void Function(ProjectListMembersRequest) updates) =>
      super.copyWith((message) => updates(message as ProjectListMembersRequest))
          as ProjectListMembersRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ProjectListMembersRequest() / ProjectListMembersRequest.new instead')
  static ProjectListMembersRequest create() => ProjectListMembersRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      ProjectListMembersRequest._();
  @$core.override
  ProjectListMembersRequest createEmptyInstance() =>
      ProjectListMembersRequest._();
  @$core.pragma('dart2js:noInline')
  static ProjectListMembersRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ProjectListMembersRequest>(
          ProjectListMembersRequest.$_createMessage);
  static ProjectListMembersRequest? _defaultInstance;

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

class ProjectListPrivateRequest extends $pb.GeneratedMessage {
  factory ProjectListPrivateRequest({
    $core.String? workspaceId,
  }) {
    final result = ProjectListPrivateRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    return result;
  }

  ProjectListPrivateRequest._();

  factory ProjectListPrivateRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ProjectListPrivateRequest()..mergeFromBuffer(data, registry);
  factory ProjectListPrivateRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ProjectListPrivateRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ProjectListPrivateRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.projects'),
      createEmptyInstance: ProjectListPrivateRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProjectListPrivateRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProjectListPrivateRequest copyWith(
          void Function(ProjectListPrivateRequest) updates) =>
      super.copyWith((message) => updates(message as ProjectListPrivateRequest))
          as ProjectListPrivateRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ProjectListPrivateRequest() / ProjectListPrivateRequest.new instead')
  static ProjectListPrivateRequest create() => ProjectListPrivateRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      ProjectListPrivateRequest._();
  @$core.override
  ProjectListPrivateRequest createEmptyInstance() =>
      ProjectListPrivateRequest._();
  @$core.pragma('dart2js:noInline')
  static ProjectListPrivateRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ProjectListPrivateRequest>(
          ProjectListPrivateRequest.$_createMessage);
  static ProjectListPrivateRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);
}

class ProjectListRequest extends $pb.GeneratedMessage {
  factory ProjectListRequest({
    $core.String? workspaceId,
    $core.bool? includeArchived,
  }) {
    final result = ProjectListRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (includeArchived != null) result.includeArchived = includeArchived;
    return result;
  }

  ProjectListRequest._();

  factory ProjectListRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ProjectListRequest()..mergeFromBuffer(data, registry);
  factory ProjectListRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ProjectListRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ProjectListRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.projects'),
      createEmptyInstance: ProjectListRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOB(2, _omitFieldNames ? '' : 'includeArchived')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProjectListRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProjectListRequest copyWith(void Function(ProjectListRequest) updates) =>
      super.copyWith((message) => updates(message as ProjectListRequest))
          as ProjectListRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ProjectListRequest() / ProjectListRequest.new instead')
  static ProjectListRequest create() => ProjectListRequest._();
  static $pb.GeneratedMessage $_createMessage() => ProjectListRequest._();
  @$core.override
  ProjectListRequest createEmptyInstance() => ProjectListRequest._();
  @$core.pragma('dart2js:noInline')
  static ProjectListRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ProjectListRequest>(
          ProjectListRequest.$_createMessage);
  static ProjectListRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get includeArchived => $_getBF(1);
  @$pb.TagNumber(2)
  set includeArchived($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasIncludeArchived() => $_has(1);
  @$pb.TagNumber(2)
  void clearIncludeArchived() => $_clearField(2);
}

class ProjectMember extends $pb.GeneratedMessage {
  factory ProjectMember({
    $core.String? userId,
    $core.String? displayName,
    $core.String? email,
    $core.String? addedAt,
  }) {
    final result = ProjectMember._();
    if (userId != null) result.userId = userId;
    if (displayName != null) result.displayName = displayName;
    if (email != null) result.email = email;
    if (addedAt != null) result.addedAt = addedAt;
    return result;
  }

  ProjectMember._();

  factory ProjectMember.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ProjectMember()..mergeFromBuffer(data, registry);
  factory ProjectMember.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ProjectMember()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ProjectMember',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.projects'),
      createEmptyInstance: ProjectMember.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'userId')
    ..aOS(2, _omitFieldNames ? '' : 'displayName')
    ..aOS(3, _omitFieldNames ? '' : 'email')
    ..aOS(4, _omitFieldNames ? '' : 'addedAt')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProjectMember clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProjectMember copyWith(void Function(ProjectMember) updates) =>
      super.copyWith((message) => updates(message as ProjectMember))
          as ProjectMember;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ProjectMember() / ProjectMember.new instead')
  static ProjectMember create() => ProjectMember._();
  static $pb.GeneratedMessage $_createMessage() => ProjectMember._();
  @$core.override
  ProjectMember createEmptyInstance() => ProjectMember._();
  @$core.pragma('dart2js:noInline')
  static ProjectMember getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ProjectMember>(
          ProjectMember.$_createMessage);
  static ProjectMember? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get userId => $_getSZ(0);
  @$pb.TagNumber(1)
  set userId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get displayName => $_getSZ(1);
  @$pb.TagNumber(2)
  set displayName($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDisplayName() => $_has(1);
  @$pb.TagNumber(2)
  void clearDisplayName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get email => $_getSZ(2);
  @$pb.TagNumber(3)
  set email($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasEmail() => $_has(2);
  @$pb.TagNumber(3)
  void clearEmail() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get addedAt => $_getSZ(3);
  @$pb.TagNumber(4)
  set addedAt($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasAddedAt() => $_has(3);
  @$pb.TagNumber(4)
  void clearAddedAt() => $_clearField(4);
}

class ProjectMemberList extends $pb.GeneratedMessage {
  factory ProjectMemberList({
    $core.Iterable<ProjectMember>? members,
  }) {
    final result = ProjectMemberList._();
    if (members != null) result.members.addAll(members);
    return result;
  }

  ProjectMemberList._();

  factory ProjectMemberList.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ProjectMemberList()..mergeFromBuffer(data, registry);
  factory ProjectMemberList.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ProjectMemberList()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ProjectMemberList',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.projects'),
      createEmptyInstance: ProjectMemberList.$_createMessage)
    ..pPM<ProjectMember>(1, _omitFieldNames ? '' : 'members',
        subBuilder: ProjectMember.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProjectMemberList clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProjectMemberList copyWith(void Function(ProjectMemberList) updates) =>
      super.copyWith((message) => updates(message as ProjectMemberList))
          as ProjectMemberList;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ProjectMemberList() / ProjectMemberList.new instead')
  static ProjectMemberList create() => ProjectMemberList._();
  static $pb.GeneratedMessage $_createMessage() => ProjectMemberList._();
  @$core.override
  ProjectMemberList createEmptyInstance() => ProjectMemberList._();
  @$core.pragma('dart2js:noInline')
  static ProjectMemberList getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ProjectMemberList>(
          ProjectMemberList.$_createMessage);
  static ProjectMemberList? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<ProjectMember> get members => $_getList(0);
}

class ProjectRemoveMemberRequest extends $pb.GeneratedMessage {
  factory ProjectRemoveMemberRequest({
    $core.String? workspaceId,
    $core.String? projectId,
    $core.String? userId,
  }) {
    final result = ProjectRemoveMemberRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (projectId != null) result.projectId = projectId;
    if (userId != null) result.userId = userId;
    return result;
  }

  ProjectRemoveMemberRequest._();

  factory ProjectRemoveMemberRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ProjectRemoveMemberRequest()..mergeFromBuffer(data, registry);
  factory ProjectRemoveMemberRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ProjectRemoveMemberRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ProjectRemoveMemberRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.projects'),
      createEmptyInstance: ProjectRemoveMemberRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..aOS(3, _omitFieldNames ? '' : 'userId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProjectRemoveMemberRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProjectRemoveMemberRequest copyWith(
          void Function(ProjectRemoveMemberRequest) updates) =>
      super.copyWith(
              (message) => updates(message as ProjectRemoveMemberRequest))
          as ProjectRemoveMemberRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ProjectRemoveMemberRequest() / ProjectRemoveMemberRequest.new instead')
  static ProjectRemoveMemberRequest create() => ProjectRemoveMemberRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      ProjectRemoveMemberRequest._();
  @$core.override
  ProjectRemoveMemberRequest createEmptyInstance() =>
      ProjectRemoveMemberRequest._();
  @$core.pragma('dart2js:noInline')
  static ProjectRemoveMemberRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ProjectRemoveMemberRequest>(
          ProjectRemoveMemberRequest.$_createMessage);
  static ProjectRemoveMemberRequest? _defaultInstance;

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
  $core.String get userId => $_getSZ(2);
  @$pb.TagNumber(3)
  set userId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasUserId() => $_has(2);
  @$pb.TagNumber(3)
  void clearUserId() => $_clearField(3);
}

class ProjectRestoreRequest extends $pb.GeneratedMessage {
  factory ProjectRestoreRequest({
    $core.String? workspaceId,
    $core.String? id,
    $core.int? expectedVersion,
  }) {
    final result = ProjectRestoreRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (id != null) result.id = id;
    if (expectedVersion != null) result.expectedVersion = expectedVersion;
    return result;
  }

  ProjectRestoreRequest._();

  factory ProjectRestoreRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ProjectRestoreRequest()..mergeFromBuffer(data, registry);
  factory ProjectRestoreRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ProjectRestoreRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ProjectRestoreRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.projects'),
      createEmptyInstance: ProjectRestoreRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'id')
    ..aI(3, _omitFieldNames ? '' : 'expectedVersion')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProjectRestoreRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProjectRestoreRequest copyWith(
          void Function(ProjectRestoreRequest) updates) =>
      super.copyWith((message) => updates(message as ProjectRestoreRequest))
          as ProjectRestoreRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ProjectRestoreRequest() / ProjectRestoreRequest.new instead')
  static ProjectRestoreRequest create() => ProjectRestoreRequest._();
  static $pb.GeneratedMessage $_createMessage() => ProjectRestoreRequest._();
  @$core.override
  ProjectRestoreRequest createEmptyInstance() => ProjectRestoreRequest._();
  @$core.pragma('dart2js:noInline')
  static ProjectRestoreRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ProjectRestoreRequest>(
          ProjectRestoreRequest.$_createMessage);
  static ProjectRestoreRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get id => $_getSZ(1);
  @$pb.TagNumber(2)
  set id($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasId() => $_has(1);
  @$pb.TagNumber(2)
  void clearId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get expectedVersion => $_getIZ(2);
  @$pb.TagNumber(3)
  set expectedVersion($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasExpectedVersion() => $_has(2);
  @$pb.TagNumber(3)
  void clearExpectedVersion() => $_clearField(3);
}

class ProjectSetFeaturesRequest extends $pb.GeneratedMessage {
  factory ProjectSetFeaturesRequest({
    $core.String? workspaceId,
    $core.String? projectId,
    $core.Iterable<$core.String>? enabledKeys,
    $core.int? expectedVersion,
  }) {
    final result = ProjectSetFeaturesRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (projectId != null) result.projectId = projectId;
    if (enabledKeys != null) result.enabledKeys.addAll(enabledKeys);
    if (expectedVersion != null) result.expectedVersion = expectedVersion;
    return result;
  }

  ProjectSetFeaturesRequest._();

  factory ProjectSetFeaturesRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ProjectSetFeaturesRequest()..mergeFromBuffer(data, registry);
  factory ProjectSetFeaturesRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ProjectSetFeaturesRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ProjectSetFeaturesRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.projects'),
      createEmptyInstance: ProjectSetFeaturesRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..pPS(3, _omitFieldNames ? '' : 'enabledKeys')
    ..aI(4, _omitFieldNames ? '' : 'expectedVersion')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProjectSetFeaturesRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProjectSetFeaturesRequest copyWith(
          void Function(ProjectSetFeaturesRequest) updates) =>
      super.copyWith((message) => updates(message as ProjectSetFeaturesRequest))
          as ProjectSetFeaturesRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ProjectSetFeaturesRequest() / ProjectSetFeaturesRequest.new instead')
  static ProjectSetFeaturesRequest create() => ProjectSetFeaturesRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      ProjectSetFeaturesRequest._();
  @$core.override
  ProjectSetFeaturesRequest createEmptyInstance() =>
      ProjectSetFeaturesRequest._();
  @$core.pragma('dart2js:noInline')
  static ProjectSetFeaturesRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ProjectSetFeaturesRequest>(
          ProjectSetFeaturesRequest.$_createMessage);
  static ProjectSetFeaturesRequest? _defaultInstance;

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
  $pb.PbList<$core.String> get enabledKeys => $_getList(2);

  @$pb.TagNumber(4)
  $core.int get expectedVersion => $_getIZ(3);
  @$pb.TagNumber(4)
  set expectedVersion($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasExpectedVersion() => $_has(3);
  @$pb.TagNumber(4)
  void clearExpectedVersion() => $_clearField(4);
}

class ProjectUpdateRequest extends $pb.GeneratedMessage {
  factory ProjectUpdateRequest({
    $core.String? workspaceId,
    $core.String? id,
    $core.int? expectedVersion,
    $core.String? name,
    $core.String? key,
    $core.String? description,
    $core.String? icon,
    $core.String? color,
    $core.String? visibility,
  }) {
    final result = ProjectUpdateRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (id != null) result.id = id;
    if (expectedVersion != null) result.expectedVersion = expectedVersion;
    if (name != null) result.name = name;
    if (key != null) result.key = key;
    if (description != null) result.description = description;
    if (icon != null) result.icon = icon;
    if (color != null) result.color = color;
    if (visibility != null) result.visibility = visibility;
    return result;
  }

  ProjectUpdateRequest._();

  factory ProjectUpdateRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ProjectUpdateRequest()..mergeFromBuffer(data, registry);
  factory ProjectUpdateRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ProjectUpdateRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ProjectUpdateRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.projects'),
      createEmptyInstance: ProjectUpdateRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'id')
    ..aI(3, _omitFieldNames ? '' : 'expectedVersion')
    ..aOS(4, _omitFieldNames ? '' : 'name')
    ..aOS(5, _omitFieldNames ? '' : 'key')
    ..aOS(6, _omitFieldNames ? '' : 'description')
    ..aOS(7, _omitFieldNames ? '' : 'icon')
    ..aOS(8, _omitFieldNames ? '' : 'color')
    ..aOS(9, _omitFieldNames ? '' : 'visibility')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProjectUpdateRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProjectUpdateRequest copyWith(void Function(ProjectUpdateRequest) updates) =>
      super.copyWith((message) => updates(message as ProjectUpdateRequest))
          as ProjectUpdateRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ProjectUpdateRequest() / ProjectUpdateRequest.new instead')
  static ProjectUpdateRequest create() => ProjectUpdateRequest._();
  static $pb.GeneratedMessage $_createMessage() => ProjectUpdateRequest._();
  @$core.override
  ProjectUpdateRequest createEmptyInstance() => ProjectUpdateRequest._();
  @$core.pragma('dart2js:noInline')
  static ProjectUpdateRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ProjectUpdateRequest>(
          ProjectUpdateRequest.$_createMessage);
  static ProjectUpdateRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get id => $_getSZ(1);
  @$pb.TagNumber(2)
  set id($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasId() => $_has(1);
  @$pb.TagNumber(2)
  void clearId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get expectedVersion => $_getIZ(2);
  @$pb.TagNumber(3)
  set expectedVersion($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasExpectedVersion() => $_has(2);
  @$pb.TagNumber(3)
  void clearExpectedVersion() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get name => $_getSZ(3);
  @$pb.TagNumber(4)
  set name($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasName() => $_has(3);
  @$pb.TagNumber(4)
  void clearName() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get key => $_getSZ(4);
  @$pb.TagNumber(5)
  set key($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasKey() => $_has(4);
  @$pb.TagNumber(5)
  void clearKey() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get description => $_getSZ(5);
  @$pb.TagNumber(6)
  set description($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasDescription() => $_has(5);
  @$pb.TagNumber(6)
  void clearDescription() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get icon => $_getSZ(6);
  @$pb.TagNumber(7)
  set icon($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasIcon() => $_has(6);
  @$pb.TagNumber(7)
  void clearIcon() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get color => $_getSZ(7);
  @$pb.TagNumber(8)
  set color($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasColor() => $_has(7);
  @$pb.TagNumber(8)
  void clearColor() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get visibility => $_getSZ(8);
  @$pb.TagNumber(9)
  set visibility($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasVisibility() => $_has(8);
  @$pb.TagNumber(9)
  void clearVisibility() => $_clearField(9);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
