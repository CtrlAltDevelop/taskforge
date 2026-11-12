// This is a generated file - do not edit.
//
// Generated from infrastructure/dashboards/grpc/dashboards.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class Bucket extends $pb.GeneratedMessage {
  factory Bucket({
    $core.String? key,
    $core.String? label,
    $core.String? value,
  }) {
    final result = Bucket._();
    if (key != null) result.key = key;
    if (label != null) result.label = label;
    if (value != null) result.value = value;
    return result;
  }

  Bucket._();

  factory Bucket.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Bucket()..mergeFromBuffer(data, registry);
  factory Bucket.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Bucket()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Bucket',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.dashboards'),
      createEmptyInstance: Bucket.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'key')
    ..aOS(2, _omitFieldNames ? '' : 'label')
    ..aOS(3, _omitFieldNames ? '' : 'value')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Bucket clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Bucket copyWith(void Function(Bucket) updates) =>
      super.copyWith((message) => updates(message as Bucket)) as Bucket;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Bucket() / Bucket.new instead')
  static Bucket create() => Bucket._();
  static $pb.GeneratedMessage $_createMessage() => Bucket._();
  @$core.override
  Bucket createEmptyInstance() => Bucket._();
  @$core.pragma('dart2js:noInline')
  static Bucket getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Bucket>(Bucket.$_createMessage);
  static Bucket? _defaultInstance;

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
  $core.String get value => $_getSZ(2);
  @$pb.TagNumber(3)
  set value($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasValue() => $_has(2);
  @$pb.TagNumber(3)
  void clearValue() => $_clearField(3);
}

class Dashboard extends $pb.GeneratedMessage {
  factory Dashboard({
    $core.String? id,
    $core.String? workspaceId,
    $core.String? projectId,
    $core.String? ownerId,
    $core.String? name,
    $core.String? visibility,
    $core.String? layoutJson,
    $core.int? version,
    $core.bool? canEdit,
    $core.Iterable<Widget>? widgets,
    $core.String? updatedAt,
  }) {
    final result = Dashboard._();
    if (id != null) result.id = id;
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (projectId != null) result.projectId = projectId;
    if (ownerId != null) result.ownerId = ownerId;
    if (name != null) result.name = name;
    if (visibility != null) result.visibility = visibility;
    if (layoutJson != null) result.layoutJson = layoutJson;
    if (version != null) result.version = version;
    if (canEdit != null) result.canEdit = canEdit;
    if (widgets != null) result.widgets.addAll(widgets);
    if (updatedAt != null) result.updatedAt = updatedAt;
    return result;
  }

  Dashboard._();

  factory Dashboard.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Dashboard()..mergeFromBuffer(data, registry);
  factory Dashboard.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Dashboard()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Dashboard',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.dashboards'),
      createEmptyInstance: Dashboard.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(3, _omitFieldNames ? '' : 'projectId')
    ..aOS(4, _omitFieldNames ? '' : 'ownerId')
    ..aOS(5, _omitFieldNames ? '' : 'name')
    ..aOS(6, _omitFieldNames ? '' : 'visibility')
    ..aOS(7, _omitFieldNames ? '' : 'layoutJson')
    ..aI(8, _omitFieldNames ? '' : 'version')
    ..aOB(9, _omitFieldNames ? '' : 'canEdit')
    ..pPM<Widget>(10, _omitFieldNames ? '' : 'widgets',
        subBuilder: Widget.$_createMessage)
    ..aOS(11, _omitFieldNames ? '' : 'updatedAt')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Dashboard clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Dashboard copyWith(void Function(Dashboard) updates) =>
      super.copyWith((message) => updates(message as Dashboard)) as Dashboard;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Dashboard() / Dashboard.new instead')
  static Dashboard create() => Dashboard._();
  static $pb.GeneratedMessage $_createMessage() => Dashboard._();
  @$core.override
  Dashboard createEmptyInstance() => Dashboard._();
  @$core.pragma('dart2js:noInline')
  static Dashboard getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Dashboard>(Dashboard.$_createMessage);
  static Dashboard? _defaultInstance;

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
  $core.String get ownerId => $_getSZ(3);
  @$pb.TagNumber(4)
  set ownerId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasOwnerId() => $_has(3);
  @$pb.TagNumber(4)
  void clearOwnerId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get name => $_getSZ(4);
  @$pb.TagNumber(5)
  set name($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasName() => $_has(4);
  @$pb.TagNumber(5)
  void clearName() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get visibility => $_getSZ(5);
  @$pb.TagNumber(6)
  set visibility($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasVisibility() => $_has(5);
  @$pb.TagNumber(6)
  void clearVisibility() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get layoutJson => $_getSZ(6);
  @$pb.TagNumber(7)
  set layoutJson($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasLayoutJson() => $_has(6);
  @$pb.TagNumber(7)
  void clearLayoutJson() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.int get version => $_getIZ(7);
  @$pb.TagNumber(8)
  set version($core.int value) => $_setSignedInt32(7, value);
  @$pb.TagNumber(8)
  $core.bool hasVersion() => $_has(7);
  @$pb.TagNumber(8)
  void clearVersion() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.bool get canEdit => $_getBF(8);
  @$pb.TagNumber(9)
  set canEdit($core.bool value) => $_setBool(8, value);
  @$pb.TagNumber(9)
  $core.bool hasCanEdit() => $_has(8);
  @$pb.TagNumber(9)
  void clearCanEdit() => $_clearField(9);

  @$pb.TagNumber(10)
  $pb.PbList<Widget> get widgets => $_getList(9);

  @$pb.TagNumber(11)
  $core.String get updatedAt => $_getSZ(10);
  @$pb.TagNumber(11)
  set updatedAt($core.String value) => $_setString(10, value);
  @$pb.TagNumber(11)
  $core.bool hasUpdatedAt() => $_has(10);
  @$pb.TagNumber(11)
  void clearUpdatedAt() => $_clearField(11);
}

class DashboardAnswer extends $pb.GeneratedMessage {
  factory DashboardAnswer({
    Dashboard? dashboard,
  }) {
    final result = DashboardAnswer._();
    if (dashboard != null) result.dashboard = dashboard;
    return result;
  }

  DashboardAnswer._();

  factory DashboardAnswer.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DashboardAnswer()..mergeFromBuffer(data, registry);
  factory DashboardAnswer.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DashboardAnswer()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DashboardAnswer',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.dashboards'),
      createEmptyInstance: DashboardAnswer.$_createMessage)
    ..aOM<Dashboard>(1, _omitFieldNames ? '' : 'dashboard',
        subBuilder: Dashboard.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DashboardAnswer clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DashboardAnswer copyWith(void Function(DashboardAnswer) updates) =>
      super.copyWith((message) => updates(message as DashboardAnswer))
          as DashboardAnswer;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use DashboardAnswer() / DashboardAnswer.new instead')
  static DashboardAnswer create() => DashboardAnswer._();
  static $pb.GeneratedMessage $_createMessage() => DashboardAnswer._();
  @$core.override
  DashboardAnswer createEmptyInstance() => DashboardAnswer._();
  @$core.pragma('dart2js:noInline')
  static DashboardAnswer getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DashboardAnswer>(
          DashboardAnswer.$_createMessage);
  static DashboardAnswer? _defaultInstance;

  @$pb.TagNumber(1)
  Dashboard get dashboard => $_getN(0);
  @$pb.TagNumber(1)
  set dashboard(Dashboard value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasDashboard() => $_has(0);
  @$pb.TagNumber(1)
  void clearDashboard() => $_clearField(1);
  @$pb.TagNumber(1)
  Dashboard ensureDashboard() => $_ensure(0);
}

class DashboardDeleteRequest extends $pb.GeneratedMessage {
  factory DashboardDeleteRequest({
    $core.String? workspaceId,
    $core.String? id,
  }) {
    final result = DashboardDeleteRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (id != null) result.id = id;
    return result;
  }

  DashboardDeleteRequest._();

  factory DashboardDeleteRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DashboardDeleteRequest()..mergeFromBuffer(data, registry);
  factory DashboardDeleteRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DashboardDeleteRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DashboardDeleteRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.dashboards'),
      createEmptyInstance: DashboardDeleteRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DashboardDeleteRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DashboardDeleteRequest copyWith(
          void Function(DashboardDeleteRequest) updates) =>
      super.copyWith((message) => updates(message as DashboardDeleteRequest))
          as DashboardDeleteRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use DashboardDeleteRequest() / DashboardDeleteRequest.new instead')
  static DashboardDeleteRequest create() => DashboardDeleteRequest._();
  static $pb.GeneratedMessage $_createMessage() => DashboardDeleteRequest._();
  @$core.override
  DashboardDeleteRequest createEmptyInstance() => DashboardDeleteRequest._();
  @$core.pragma('dart2js:noInline')
  static DashboardDeleteRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DashboardDeleteRequest>(
          DashboardDeleteRequest.$_createMessage);
  static DashboardDeleteRequest? _defaultInstance;

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

class DashboardDeleted extends $pb.GeneratedMessage {
  factory DashboardDeleted({
    $core.String? id,
  }) {
    final result = DashboardDeleted._();
    if (id != null) result.id = id;
    return result;
  }

  DashboardDeleted._();

  factory DashboardDeleted.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DashboardDeleted()..mergeFromBuffer(data, registry);
  factory DashboardDeleted.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DashboardDeleted()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DashboardDeleted',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.dashboards'),
      createEmptyInstance: DashboardDeleted.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DashboardDeleted clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DashboardDeleted copyWith(void Function(DashboardDeleted) updates) =>
      super.copyWith((message) => updates(message as DashboardDeleted))
          as DashboardDeleted;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use DashboardDeleted() / DashboardDeleted.new instead')
  static DashboardDeleted create() => DashboardDeleted._();
  static $pb.GeneratedMessage $_createMessage() => DashboardDeleted._();
  @$core.override
  DashboardDeleted createEmptyInstance() => DashboardDeleted._();
  @$core.pragma('dart2js:noInline')
  static DashboardDeleted getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DashboardDeleted>(
          DashboardDeleted.$_createMessage);
  static DashboardDeleted? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class DashboardFromTemplateRequest extends $pb.GeneratedMessage {
  factory DashboardFromTemplateRequest({
    $core.String? workspaceId,
    $core.String? template,
    $core.String? projectId,
  }) {
    final result = DashboardFromTemplateRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (template != null) result.template = template;
    if (projectId != null) result.projectId = projectId;
    return result;
  }

  DashboardFromTemplateRequest._();

  factory DashboardFromTemplateRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DashboardFromTemplateRequest()..mergeFromBuffer(data, registry);
  factory DashboardFromTemplateRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DashboardFromTemplateRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DashboardFromTemplateRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.dashboards'),
      createEmptyInstance: DashboardFromTemplateRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'template')
    ..aOS(3, _omitFieldNames ? '' : 'projectId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DashboardFromTemplateRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DashboardFromTemplateRequest copyWith(
          void Function(DashboardFromTemplateRequest) updates) =>
      super.copyWith(
              (message) => updates(message as DashboardFromTemplateRequest))
          as DashboardFromTemplateRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use DashboardFromTemplateRequest() / DashboardFromTemplateRequest.new instead')
  static DashboardFromTemplateRequest create() =>
      DashboardFromTemplateRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      DashboardFromTemplateRequest._();
  @$core.override
  DashboardFromTemplateRequest createEmptyInstance() =>
      DashboardFromTemplateRequest._();
  @$core.pragma('dart2js:noInline')
  static DashboardFromTemplateRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DashboardFromTemplateRequest>(
          DashboardFromTemplateRequest.$_createMessage);
  static DashboardFromTemplateRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get template => $_getSZ(1);
  @$pb.TagNumber(2)
  set template($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTemplate() => $_has(1);
  @$pb.TagNumber(2)
  void clearTemplate() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get projectId => $_getSZ(2);
  @$pb.TagNumber(3)
  set projectId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasProjectId() => $_has(2);
  @$pb.TagNumber(3)
  void clearProjectId() => $_clearField(3);
}

class DashboardGetRequest extends $pb.GeneratedMessage {
  factory DashboardGetRequest({
    $core.String? workspaceId,
    $core.String? id,
  }) {
    final result = DashboardGetRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (id != null) result.id = id;
    return result;
  }

  DashboardGetRequest._();

  factory DashboardGetRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DashboardGetRequest()..mergeFromBuffer(data, registry);
  factory DashboardGetRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DashboardGetRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DashboardGetRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.dashboards'),
      createEmptyInstance: DashboardGetRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DashboardGetRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DashboardGetRequest copyWith(void Function(DashboardGetRequest) updates) =>
      super.copyWith((message) => updates(message as DashboardGetRequest))
          as DashboardGetRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core
      .Deprecated('Use DashboardGetRequest() / DashboardGetRequest.new instead')
  static DashboardGetRequest create() => DashboardGetRequest._();
  static $pb.GeneratedMessage $_createMessage() => DashboardGetRequest._();
  @$core.override
  DashboardGetRequest createEmptyInstance() => DashboardGetRequest._();
  @$core.pragma('dart2js:noInline')
  static DashboardGetRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DashboardGetRequest>(
          DashboardGetRequest.$_createMessage);
  static DashboardGetRequest? _defaultInstance;

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

class DashboardList extends $pb.GeneratedMessage {
  factory DashboardList({
    $core.Iterable<Dashboard>? dashboards,
  }) {
    final result = DashboardList._();
    if (dashboards != null) result.dashboards.addAll(dashboards);
    return result;
  }

  DashboardList._();

  factory DashboardList.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DashboardList()..mergeFromBuffer(data, registry);
  factory DashboardList.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DashboardList()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DashboardList',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.dashboards'),
      createEmptyInstance: DashboardList.$_createMessage)
    ..pPM<Dashboard>(1, _omitFieldNames ? '' : 'dashboards',
        subBuilder: Dashboard.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DashboardList clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DashboardList copyWith(void Function(DashboardList) updates) =>
      super.copyWith((message) => updates(message as DashboardList))
          as DashboardList;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use DashboardList() / DashboardList.new instead')
  static DashboardList create() => DashboardList._();
  static $pb.GeneratedMessage $_createMessage() => DashboardList._();
  @$core.override
  DashboardList createEmptyInstance() => DashboardList._();
  @$core.pragma('dart2js:noInline')
  static DashboardList getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DashboardList>(
          DashboardList.$_createMessage);
  static DashboardList? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Dashboard> get dashboards => $_getList(0);
}

class DashboardListRequest extends $pb.GeneratedMessage {
  factory DashboardListRequest({
    $core.String? workspaceId,
    $core.String? projectId,
  }) {
    final result = DashboardListRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (projectId != null) result.projectId = projectId;
    return result;
  }

  DashboardListRequest._();

  factory DashboardListRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DashboardListRequest()..mergeFromBuffer(data, registry);
  factory DashboardListRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DashboardListRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DashboardListRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.dashboards'),
      createEmptyInstance: DashboardListRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DashboardListRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DashboardListRequest copyWith(void Function(DashboardListRequest) updates) =>
      super.copyWith((message) => updates(message as DashboardListRequest))
          as DashboardListRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use DashboardListRequest() / DashboardListRequest.new instead')
  static DashboardListRequest create() => DashboardListRequest._();
  static $pb.GeneratedMessage $_createMessage() => DashboardListRequest._();
  @$core.override
  DashboardListRequest createEmptyInstance() => DashboardListRequest._();
  @$core.pragma('dart2js:noInline')
  static DashboardListRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DashboardListRequest>(
          DashboardListRequest.$_createMessage);
  static DashboardListRequest? _defaultInstance;

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

class DashboardSaveRequest extends $pb.GeneratedMessage {
  factory DashboardSaveRequest({
    $core.String? workspaceId,
    $core.String? id,
    $core.String? name,
    $core.String? visibility,
    $core.String? projectId,
    $core.Iterable<WidgetInput>? widgets,
    $core.String? layoutJson,
    $core.int? expectedVersion,
  }) {
    final result = DashboardSaveRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (id != null) result.id = id;
    if (name != null) result.name = name;
    if (visibility != null) result.visibility = visibility;
    if (projectId != null) result.projectId = projectId;
    if (widgets != null) result.widgets.addAll(widgets);
    if (layoutJson != null) result.layoutJson = layoutJson;
    if (expectedVersion != null) result.expectedVersion = expectedVersion;
    return result;
  }

  DashboardSaveRequest._();

  factory DashboardSaveRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DashboardSaveRequest()..mergeFromBuffer(data, registry);
  factory DashboardSaveRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DashboardSaveRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DashboardSaveRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.dashboards'),
      createEmptyInstance: DashboardSaveRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'id')
    ..aOS(3, _omitFieldNames ? '' : 'name')
    ..aOS(4, _omitFieldNames ? '' : 'visibility')
    ..aOS(5, _omitFieldNames ? '' : 'projectId')
    ..pPM<WidgetInput>(6, _omitFieldNames ? '' : 'widgets',
        subBuilder: WidgetInput.$_createMessage)
    ..aOS(7, _omitFieldNames ? '' : 'layoutJson')
    ..aI(8, _omitFieldNames ? '' : 'expectedVersion')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DashboardSaveRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DashboardSaveRequest copyWith(void Function(DashboardSaveRequest) updates) =>
      super.copyWith((message) => updates(message as DashboardSaveRequest))
          as DashboardSaveRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use DashboardSaveRequest() / DashboardSaveRequest.new instead')
  static DashboardSaveRequest create() => DashboardSaveRequest._();
  static $pb.GeneratedMessage $_createMessage() => DashboardSaveRequest._();
  @$core.override
  DashboardSaveRequest createEmptyInstance() => DashboardSaveRequest._();
  @$core.pragma('dart2js:noInline')
  static DashboardSaveRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DashboardSaveRequest>(
          DashboardSaveRequest.$_createMessage);
  static DashboardSaveRequest? _defaultInstance;

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
  $core.String get name => $_getSZ(2);
  @$pb.TagNumber(3)
  set name($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasName() => $_has(2);
  @$pb.TagNumber(3)
  void clearName() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get visibility => $_getSZ(3);
  @$pb.TagNumber(4)
  set visibility($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasVisibility() => $_has(3);
  @$pb.TagNumber(4)
  void clearVisibility() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get projectId => $_getSZ(4);
  @$pb.TagNumber(5)
  set projectId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasProjectId() => $_has(4);
  @$pb.TagNumber(5)
  void clearProjectId() => $_clearField(5);

  @$pb.TagNumber(6)
  $pb.PbList<WidgetInput> get widgets => $_getList(5);

  @$pb.TagNumber(7)
  $core.String get layoutJson => $_getSZ(6);
  @$pb.TagNumber(7)
  set layoutJson($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasLayoutJson() => $_has(6);
  @$pb.TagNumber(7)
  void clearLayoutJson() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.int get expectedVersion => $_getIZ(7);
  @$pb.TagNumber(8)
  set expectedVersion($core.int value) => $_setSignedInt32(7, value);
  @$pb.TagNumber(8)
  $core.bool hasExpectedVersion() => $_has(7);
  @$pb.TagNumber(8)
  void clearExpectedVersion() => $_clearField(8);
}

class DrillTask extends $pb.GeneratedMessage {
  factory DrillTask({
    $core.String? id,
    $core.String? projectId,
    $core.String? displayId,
    $core.String? title,
    $core.String? statusName,
    $core.String? statusCategory,
    $core.String? priority,
    $core.String? dueDate,
    $core.String? points,
    $core.Iterable<$core.String>? assigneeIds,
  }) {
    final result = DrillTask._();
    if (id != null) result.id = id;
    if (projectId != null) result.projectId = projectId;
    if (displayId != null) result.displayId = displayId;
    if (title != null) result.title = title;
    if (statusName != null) result.statusName = statusName;
    if (statusCategory != null) result.statusCategory = statusCategory;
    if (priority != null) result.priority = priority;
    if (dueDate != null) result.dueDate = dueDate;
    if (points != null) result.points = points;
    if (assigneeIds != null) result.assigneeIds.addAll(assigneeIds);
    return result;
  }

  DrillTask._();

  factory DrillTask.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DrillTask()..mergeFromBuffer(data, registry);
  factory DrillTask.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DrillTask()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DrillTask',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.dashboards'),
      createEmptyInstance: DrillTask.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..aOS(3, _omitFieldNames ? '' : 'displayId')
    ..aOS(4, _omitFieldNames ? '' : 'title')
    ..aOS(5, _omitFieldNames ? '' : 'statusName')
    ..aOS(6, _omitFieldNames ? '' : 'statusCategory')
    ..aOS(7, _omitFieldNames ? '' : 'priority')
    ..aOS(8, _omitFieldNames ? '' : 'dueDate')
    ..aOS(9, _omitFieldNames ? '' : 'points')
    ..pPS(10, _omitFieldNames ? '' : 'assigneeIds')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DrillTask clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DrillTask copyWith(void Function(DrillTask) updates) =>
      super.copyWith((message) => updates(message as DrillTask)) as DrillTask;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use DrillTask() / DrillTask.new instead')
  static DrillTask create() => DrillTask._();
  static $pb.GeneratedMessage $_createMessage() => DrillTask._();
  @$core.override
  DrillTask createEmptyInstance() => DrillTask._();
  @$core.pragma('dart2js:noInline')
  static DrillTask getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DrillTask>(DrillTask.$_createMessage);
  static DrillTask? _defaultInstance;

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
  $core.String get statusName => $_getSZ(4);
  @$pb.TagNumber(5)
  set statusName($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasStatusName() => $_has(4);
  @$pb.TagNumber(5)
  void clearStatusName() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get statusCategory => $_getSZ(5);
  @$pb.TagNumber(6)
  set statusCategory($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasStatusCategory() => $_has(5);
  @$pb.TagNumber(6)
  void clearStatusCategory() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get priority => $_getSZ(6);
  @$pb.TagNumber(7)
  set priority($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasPriority() => $_has(6);
  @$pb.TagNumber(7)
  void clearPriority() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get dueDate => $_getSZ(7);
  @$pb.TagNumber(8)
  set dueDate($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasDueDate() => $_has(7);
  @$pb.TagNumber(8)
  void clearDueDate() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get points => $_getSZ(8);
  @$pb.TagNumber(9)
  set points($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasPoints() => $_has(8);
  @$pb.TagNumber(9)
  void clearPoints() => $_clearField(9);

  @$pb.TagNumber(10)
  $pb.PbList<$core.String> get assigneeIds => $_getList(9);
}

class DrilledTask extends $pb.GeneratedMessage {
  factory DrilledTask({
    DrillTask? task,
    $core.bool? truncated,
  }) {
    final result = DrilledTask._();
    if (task != null) result.task = task;
    if (truncated != null) result.truncated = truncated;
    return result;
  }

  DrilledTask._();

  factory DrilledTask.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DrilledTask()..mergeFromBuffer(data, registry);
  factory DrilledTask.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DrilledTask()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DrilledTask',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.dashboards'),
      createEmptyInstance: DrilledTask.$_createMessage)
    ..aOM<DrillTask>(1, _omitFieldNames ? '' : 'task',
        subBuilder: DrillTask.$_createMessage)
    ..aOB(2, _omitFieldNames ? '' : 'truncated')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DrilledTask clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DrilledTask copyWith(void Function(DrilledTask) updates) =>
      super.copyWith((message) => updates(message as DrilledTask))
          as DrilledTask;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use DrilledTask() / DrilledTask.new instead')
  static DrilledTask create() => DrilledTask._();
  static $pb.GeneratedMessage $_createMessage() => DrilledTask._();
  @$core.override
  DrilledTask createEmptyInstance() => DrilledTask._();
  @$core.pragma('dart2js:noInline')
  static DrilledTask getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DrilledTask>(
          DrilledTask.$_createMessage);
  static DrilledTask? _defaultInstance;

  @$pb.TagNumber(1)
  DrillTask get task => $_getN(0);
  @$pb.TagNumber(1)
  set task(DrillTask value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasTask() => $_has(0);
  @$pb.TagNumber(1)
  void clearTask() => $_clearField(1);
  @$pb.TagNumber(1)
  DrillTask ensureTask() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.bool get truncated => $_getBF(1);
  @$pb.TagNumber(2)
  set truncated($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTruncated() => $_has(1);
  @$pb.TagNumber(2)
  void clearTruncated() => $_clearField(2);
}

class Point extends $pb.GeneratedMessage {
  factory Point({
    $core.String? x,
    $core.String? y,
  }) {
    final result = Point._();
    if (x != null) result.x = x;
    if (y != null) result.y = y;
    return result;
  }

  Point._();

  factory Point.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Point()..mergeFromBuffer(data, registry);
  factory Point.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Point()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Point',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.dashboards'),
      createEmptyInstance: Point.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'x')
    ..aOS(2, _omitFieldNames ? '' : 'y')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Point clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Point copyWith(void Function(Point) updates) =>
      super.copyWith((message) => updates(message as Point)) as Point;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Point() / Point.new instead')
  static Point create() => Point._();
  static $pb.GeneratedMessage $_createMessage() => Point._();
  @$core.override
  Point createEmptyInstance() => Point._();
  @$core.pragma('dart2js:noInline')
  static Point getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Point>(Point.$_createMessage);
  static Point? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get x => $_getSZ(0);
  @$pb.TagNumber(1)
  set x($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasX() => $_has(0);
  @$pb.TagNumber(1)
  void clearX() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get y => $_getSZ(1);
  @$pb.TagNumber(2)
  set y($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasY() => $_has(1);
  @$pb.TagNumber(2)
  void clearY() => $_clearField(2);
}

class Series extends $pb.GeneratedMessage {
  factory Series({
    $core.String? name,
    $core.Iterable<Point>? points,
  }) {
    final result = Series._();
    if (name != null) result.name = name;
    if (points != null) result.points.addAll(points);
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
          const $pb.PackageName(_omitMessageNames ? '' : 'config.dashboards'),
      createEmptyInstance: Series.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..pPM<Point>(2, _omitFieldNames ? '' : 'points',
        subBuilder: Point.$_createMessage)
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
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<Point> get points => $_getList(1);
}

class Widget extends $pb.GeneratedMessage {
  factory Widget({
    $core.String? id,
    $core.String? type,
    $core.String? title,
    $core.String? configJson,
    $core.int? version,
  }) {
    final result = Widget._();
    if (id != null) result.id = id;
    if (type != null) result.type = type;
    if (title != null) result.title = title;
    if (configJson != null) result.configJson = configJson;
    if (version != null) result.version = version;
    return result;
  }

  Widget._();

  factory Widget.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Widget()..mergeFromBuffer(data, registry);
  factory Widget.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Widget()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Widget',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.dashboards'),
      createEmptyInstance: Widget.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'type')
    ..aOS(3, _omitFieldNames ? '' : 'title')
    ..aOS(4, _omitFieldNames ? '' : 'configJson')
    ..aI(5, _omitFieldNames ? '' : 'version')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Widget clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Widget copyWith(void Function(Widget) updates) =>
      super.copyWith((message) => updates(message as Widget)) as Widget;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Widget() / Widget.new instead')
  static Widget create() => Widget._();
  static $pb.GeneratedMessage $_createMessage() => Widget._();
  @$core.override
  Widget createEmptyInstance() => Widget._();
  @$core.pragma('dart2js:noInline')
  static Widget getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Widget>(Widget.$_createMessage);
  static Widget? _defaultInstance;

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
  $core.String get title => $_getSZ(2);
  @$pb.TagNumber(3)
  set title($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTitle() => $_has(2);
  @$pb.TagNumber(3)
  void clearTitle() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get configJson => $_getSZ(3);
  @$pb.TagNumber(4)
  set configJson($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasConfigJson() => $_has(3);
  @$pb.TagNumber(4)
  void clearConfigJson() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get version => $_getIZ(4);
  @$pb.TagNumber(5)
  set version($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasVersion() => $_has(4);
  @$pb.TagNumber(5)
  void clearVersion() => $_clearField(5);
}

class WidgetData extends $pb.GeneratedMessage {
  factory WidgetData({
    $core.String? widgetId,
    $core.String? total,
    $core.Iterable<Bucket>? buckets,
    $core.Iterable<Series>? series,
    $core.bool? truncated,
    $core.String? computedAt,
    $core.bool? cached,
  }) {
    final result = WidgetData._();
    if (widgetId != null) result.widgetId = widgetId;
    if (total != null) result.total = total;
    if (buckets != null) result.buckets.addAll(buckets);
    if (series != null) result.series.addAll(series);
    if (truncated != null) result.truncated = truncated;
    if (computedAt != null) result.computedAt = computedAt;
    if (cached != null) result.cached = cached;
    return result;
  }

  WidgetData._();

  factory WidgetData.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WidgetData()..mergeFromBuffer(data, registry);
  factory WidgetData.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WidgetData()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WidgetData',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.dashboards'),
      createEmptyInstance: WidgetData.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'widgetId')
    ..aOS(2, _omitFieldNames ? '' : 'total')
    ..pPM<Bucket>(3, _omitFieldNames ? '' : 'buckets',
        subBuilder: Bucket.$_createMessage)
    ..pPM<Series>(4, _omitFieldNames ? '' : 'series',
        subBuilder: Series.$_createMessage)
    ..aOB(5, _omitFieldNames ? '' : 'truncated')
    ..aOS(6, _omitFieldNames ? '' : 'computedAt')
    ..aOB(7, _omitFieldNames ? '' : 'cached')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WidgetData clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WidgetData copyWith(void Function(WidgetData) updates) =>
      super.copyWith((message) => updates(message as WidgetData)) as WidgetData;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use WidgetData() / WidgetData.new instead')
  static WidgetData create() => WidgetData._();
  static $pb.GeneratedMessage $_createMessage() => WidgetData._();
  @$core.override
  WidgetData createEmptyInstance() => WidgetData._();
  @$core.pragma('dart2js:noInline')
  static WidgetData getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WidgetData>(WidgetData.$_createMessage);
  static WidgetData? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get widgetId => $_getSZ(0);
  @$pb.TagNumber(1)
  set widgetId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWidgetId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWidgetId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get total => $_getSZ(1);
  @$pb.TagNumber(2)
  set total($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTotal() => $_has(1);
  @$pb.TagNumber(2)
  void clearTotal() => $_clearField(2);

  @$pb.TagNumber(3)
  $pb.PbList<Bucket> get buckets => $_getList(2);

  @$pb.TagNumber(4)
  $pb.PbList<Series> get series => $_getList(3);

  @$pb.TagNumber(5)
  $core.bool get truncated => $_getBF(4);
  @$pb.TagNumber(5)
  set truncated($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasTruncated() => $_has(4);
  @$pb.TagNumber(5)
  void clearTruncated() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get computedAt => $_getSZ(5);
  @$pb.TagNumber(6)
  set computedAt($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasComputedAt() => $_has(5);
  @$pb.TagNumber(6)
  void clearComputedAt() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.bool get cached => $_getBF(6);
  @$pb.TagNumber(7)
  set cached($core.bool value) => $_setBool(6, value);
  @$pb.TagNumber(7)
  $core.bool hasCached() => $_has(6);
  @$pb.TagNumber(7)
  void clearCached() => $_clearField(7);
}

class WidgetDataRequest extends $pb.GeneratedMessage {
  factory WidgetDataRequest({
    $core.String? workspaceId,
    $core.String? widgetId,
    $core.String? today,
    $core.int? utcOffsetMinutes,
    $core.bool? refresh,
  }) {
    final result = WidgetDataRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (widgetId != null) result.widgetId = widgetId;
    if (today != null) result.today = today;
    if (utcOffsetMinutes != null) result.utcOffsetMinutes = utcOffsetMinutes;
    if (refresh != null) result.refresh = refresh;
    return result;
  }

  WidgetDataRequest._();

  factory WidgetDataRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WidgetDataRequest()..mergeFromBuffer(data, registry);
  factory WidgetDataRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WidgetDataRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WidgetDataRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.dashboards'),
      createEmptyInstance: WidgetDataRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'widgetId')
    ..aOS(3, _omitFieldNames ? '' : 'today')
    ..aI(4, _omitFieldNames ? '' : 'utcOffsetMinutes')
    ..aOB(5, _omitFieldNames ? '' : 'refresh')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WidgetDataRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WidgetDataRequest copyWith(void Function(WidgetDataRequest) updates) =>
      super.copyWith((message) => updates(message as WidgetDataRequest))
          as WidgetDataRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use WidgetDataRequest() / WidgetDataRequest.new instead')
  static WidgetDataRequest create() => WidgetDataRequest._();
  static $pb.GeneratedMessage $_createMessage() => WidgetDataRequest._();
  @$core.override
  WidgetDataRequest createEmptyInstance() => WidgetDataRequest._();
  @$core.pragma('dart2js:noInline')
  static WidgetDataRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<WidgetDataRequest>(
          WidgetDataRequest.$_createMessage);
  static WidgetDataRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get widgetId => $_getSZ(1);
  @$pb.TagNumber(2)
  set widgetId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasWidgetId() => $_has(1);
  @$pb.TagNumber(2)
  void clearWidgetId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get today => $_getSZ(2);
  @$pb.TagNumber(3)
  set today($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasToday() => $_has(2);
  @$pb.TagNumber(3)
  void clearToday() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get utcOffsetMinutes => $_getIZ(3);
  @$pb.TagNumber(4)
  set utcOffsetMinutes($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasUtcOffsetMinutes() => $_has(3);
  @$pb.TagNumber(4)
  void clearUtcOffsetMinutes() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.bool get refresh => $_getBF(4);
  @$pb.TagNumber(5)
  set refresh($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasRefresh() => $_has(4);
  @$pb.TagNumber(5)
  void clearRefresh() => $_clearField(5);
}

class WidgetDrilldownRequest extends $pb.GeneratedMessage {
  factory WidgetDrilldownRequest({
    $core.String? workspaceId,
    $core.String? widgetId,
    $core.String? bucket,
    $core.String? today,
    $core.int? utcOffsetMinutes,
  }) {
    final result = WidgetDrilldownRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (widgetId != null) result.widgetId = widgetId;
    if (bucket != null) result.bucket = bucket;
    if (today != null) result.today = today;
    if (utcOffsetMinutes != null) result.utcOffsetMinutes = utcOffsetMinutes;
    return result;
  }

  WidgetDrilldownRequest._();

  factory WidgetDrilldownRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WidgetDrilldownRequest()..mergeFromBuffer(data, registry);
  factory WidgetDrilldownRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WidgetDrilldownRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WidgetDrilldownRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.dashboards'),
      createEmptyInstance: WidgetDrilldownRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'widgetId')
    ..aOS(3, _omitFieldNames ? '' : 'bucket')
    ..aOS(4, _omitFieldNames ? '' : 'today')
    ..aI(5, _omitFieldNames ? '' : 'utcOffsetMinutes')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WidgetDrilldownRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WidgetDrilldownRequest copyWith(
          void Function(WidgetDrilldownRequest) updates) =>
      super.copyWith((message) => updates(message as WidgetDrilldownRequest))
          as WidgetDrilldownRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use WidgetDrilldownRequest() / WidgetDrilldownRequest.new instead')
  static WidgetDrilldownRequest create() => WidgetDrilldownRequest._();
  static $pb.GeneratedMessage $_createMessage() => WidgetDrilldownRequest._();
  @$core.override
  WidgetDrilldownRequest createEmptyInstance() => WidgetDrilldownRequest._();
  @$core.pragma('dart2js:noInline')
  static WidgetDrilldownRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WidgetDrilldownRequest>(
          WidgetDrilldownRequest.$_createMessage);
  static WidgetDrilldownRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get widgetId => $_getSZ(1);
  @$pb.TagNumber(2)
  set widgetId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasWidgetId() => $_has(1);
  @$pb.TagNumber(2)
  void clearWidgetId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get bucket => $_getSZ(2);
  @$pb.TagNumber(3)
  set bucket($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasBucket() => $_has(2);
  @$pb.TagNumber(3)
  void clearBucket() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get today => $_getSZ(3);
  @$pb.TagNumber(4)
  set today($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasToday() => $_has(3);
  @$pb.TagNumber(4)
  void clearToday() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get utcOffsetMinutes => $_getIZ(4);
  @$pb.TagNumber(5)
  set utcOffsetMinutes($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasUtcOffsetMinutes() => $_has(4);
  @$pb.TagNumber(5)
  void clearUtcOffsetMinutes() => $_clearField(5);
}

class WidgetExport extends $pb.GeneratedMessage {
  factory WidgetExport({
    $core.String? csv,
  }) {
    final result = WidgetExport._();
    if (csv != null) result.csv = csv;
    return result;
  }

  WidgetExport._();

  factory WidgetExport.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WidgetExport()..mergeFromBuffer(data, registry);
  factory WidgetExport.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WidgetExport()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WidgetExport',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.dashboards'),
      createEmptyInstance: WidgetExport.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'csv')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WidgetExport clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WidgetExport copyWith(void Function(WidgetExport) updates) =>
      super.copyWith((message) => updates(message as WidgetExport))
          as WidgetExport;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use WidgetExport() / WidgetExport.new instead')
  static WidgetExport create() => WidgetExport._();
  static $pb.GeneratedMessage $_createMessage() => WidgetExport._();
  @$core.override
  WidgetExport createEmptyInstance() => WidgetExport._();
  @$core.pragma('dart2js:noInline')
  static WidgetExport getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<WidgetExport>(
          WidgetExport.$_createMessage);
  static WidgetExport? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get csv => $_getSZ(0);
  @$pb.TagNumber(1)
  set csv($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCsv() => $_has(0);
  @$pb.TagNumber(1)
  void clearCsv() => $_clearField(1);
}

class WidgetExportRequest extends $pb.GeneratedMessage {
  factory WidgetExportRequest({
    $core.String? workspaceId,
    $core.String? widgetId,
    $core.String? today,
    $core.int? utcOffsetMinutes,
  }) {
    final result = WidgetExportRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (widgetId != null) result.widgetId = widgetId;
    if (today != null) result.today = today;
    if (utcOffsetMinutes != null) result.utcOffsetMinutes = utcOffsetMinutes;
    return result;
  }

  WidgetExportRequest._();

  factory WidgetExportRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WidgetExportRequest()..mergeFromBuffer(data, registry);
  factory WidgetExportRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WidgetExportRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WidgetExportRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.dashboards'),
      createEmptyInstance: WidgetExportRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'widgetId')
    ..aOS(3, _omitFieldNames ? '' : 'today')
    ..aI(4, _omitFieldNames ? '' : 'utcOffsetMinutes')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WidgetExportRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WidgetExportRequest copyWith(void Function(WidgetExportRequest) updates) =>
      super.copyWith((message) => updates(message as WidgetExportRequest))
          as WidgetExportRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core
      .Deprecated('Use WidgetExportRequest() / WidgetExportRequest.new instead')
  static WidgetExportRequest create() => WidgetExportRequest._();
  static $pb.GeneratedMessage $_createMessage() => WidgetExportRequest._();
  @$core.override
  WidgetExportRequest createEmptyInstance() => WidgetExportRequest._();
  @$core.pragma('dart2js:noInline')
  static WidgetExportRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WidgetExportRequest>(
          WidgetExportRequest.$_createMessage);
  static WidgetExportRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get widgetId => $_getSZ(1);
  @$pb.TagNumber(2)
  set widgetId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasWidgetId() => $_has(1);
  @$pb.TagNumber(2)
  void clearWidgetId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get today => $_getSZ(2);
  @$pb.TagNumber(3)
  set today($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasToday() => $_has(2);
  @$pb.TagNumber(3)
  void clearToday() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get utcOffsetMinutes => $_getIZ(3);
  @$pb.TagNumber(4)
  set utcOffsetMinutes($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasUtcOffsetMinutes() => $_has(3);
  @$pb.TagNumber(4)
  void clearUtcOffsetMinutes() => $_clearField(4);
}

class WidgetInput extends $pb.GeneratedMessage {
  factory WidgetInput({
    $core.String? id,
    $core.String? type,
    $core.String? title,
    $core.String? configJson,
  }) {
    final result = WidgetInput._();
    if (id != null) result.id = id;
    if (type != null) result.type = type;
    if (title != null) result.title = title;
    if (configJson != null) result.configJson = configJson;
    return result;
  }

  WidgetInput._();

  factory WidgetInput.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WidgetInput()..mergeFromBuffer(data, registry);
  factory WidgetInput.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WidgetInput()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WidgetInput',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.dashboards'),
      createEmptyInstance: WidgetInput.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'type')
    ..aOS(3, _omitFieldNames ? '' : 'title')
    ..aOS(4, _omitFieldNames ? '' : 'configJson')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WidgetInput clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WidgetInput copyWith(void Function(WidgetInput) updates) =>
      super.copyWith((message) => updates(message as WidgetInput))
          as WidgetInput;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use WidgetInput() / WidgetInput.new instead')
  static WidgetInput create() => WidgetInput._();
  static $pb.GeneratedMessage $_createMessage() => WidgetInput._();
  @$core.override
  WidgetInput createEmptyInstance() => WidgetInput._();
  @$core.pragma('dart2js:noInline')
  static WidgetInput getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<WidgetInput>(
          WidgetInput.$_createMessage);
  static WidgetInput? _defaultInstance;

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
  $core.String get title => $_getSZ(2);
  @$pb.TagNumber(3)
  set title($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTitle() => $_has(2);
  @$pb.TagNumber(3)
  void clearTitle() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get configJson => $_getSZ(3);
  @$pb.TagNumber(4)
  set configJson($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasConfigJson() => $_has(3);
  @$pb.TagNumber(4)
  void clearConfigJson() => $_clearField(4);
}

class WidgetPreviewRequest extends $pb.GeneratedMessage {
  factory WidgetPreviewRequest({
    $core.String? workspaceId,
    $core.String? projectId,
    $core.String? type,
    $core.String? configJson,
    $core.String? today,
    $core.int? utcOffsetMinutes,
  }) {
    final result = WidgetPreviewRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (projectId != null) result.projectId = projectId;
    if (type != null) result.type = type;
    if (configJson != null) result.configJson = configJson;
    if (today != null) result.today = today;
    if (utcOffsetMinutes != null) result.utcOffsetMinutes = utcOffsetMinutes;
    return result;
  }

  WidgetPreviewRequest._();

  factory WidgetPreviewRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WidgetPreviewRequest()..mergeFromBuffer(data, registry);
  factory WidgetPreviewRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WidgetPreviewRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WidgetPreviewRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.dashboards'),
      createEmptyInstance: WidgetPreviewRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..aOS(3, _omitFieldNames ? '' : 'type')
    ..aOS(4, _omitFieldNames ? '' : 'configJson')
    ..aOS(5, _omitFieldNames ? '' : 'today')
    ..aI(6, _omitFieldNames ? '' : 'utcOffsetMinutes')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WidgetPreviewRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WidgetPreviewRequest copyWith(void Function(WidgetPreviewRequest) updates) =>
      super.copyWith((message) => updates(message as WidgetPreviewRequest))
          as WidgetPreviewRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use WidgetPreviewRequest() / WidgetPreviewRequest.new instead')
  static WidgetPreviewRequest create() => WidgetPreviewRequest._();
  static $pb.GeneratedMessage $_createMessage() => WidgetPreviewRequest._();
  @$core.override
  WidgetPreviewRequest createEmptyInstance() => WidgetPreviewRequest._();
  @$core.pragma('dart2js:noInline')
  static WidgetPreviewRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WidgetPreviewRequest>(
          WidgetPreviewRequest.$_createMessage);
  static WidgetPreviewRequest? _defaultInstance;

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
  $core.String get type => $_getSZ(2);
  @$pb.TagNumber(3)
  set type($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasType() => $_has(2);
  @$pb.TagNumber(3)
  void clearType() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get configJson => $_getSZ(3);
  @$pb.TagNumber(4)
  set configJson($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasConfigJson() => $_has(3);
  @$pb.TagNumber(4)
  void clearConfigJson() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get today => $_getSZ(4);
  @$pb.TagNumber(5)
  set today($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasToday() => $_has(4);
  @$pb.TagNumber(5)
  void clearToday() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get utcOffsetMinutes => $_getIZ(5);
  @$pb.TagNumber(6)
  set utcOffsetMinutes($core.int value) => $_setSignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasUtcOffsetMinutes() => $_has(5);
  @$pb.TagNumber(6)
  void clearUtcOffsetMinutes() => $_clearField(6);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
