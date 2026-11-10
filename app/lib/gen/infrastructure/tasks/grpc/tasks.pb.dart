// This is a generated file - do not edit.
//
// Generated from infrastructure/tasks/grpc/tasks.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class Link extends $pb.GeneratedMessage {
  factory Link({
    $core.String? id,
    $core.String? kind,
    $core.bool? restricted,
    $core.String? otherId,
    $core.String? otherProjectId,
    $core.String? otherDisplayId,
    $core.String? otherTitle,
    $core.String? otherStatusName,
    $core.String? otherStatusCategory,
  }) {
    final result = Link._();
    if (id != null) result.id = id;
    if (kind != null) result.kind = kind;
    if (restricted != null) result.restricted = restricted;
    if (otherId != null) result.otherId = otherId;
    if (otherProjectId != null) result.otherProjectId = otherProjectId;
    if (otherDisplayId != null) result.otherDisplayId = otherDisplayId;
    if (otherTitle != null) result.otherTitle = otherTitle;
    if (otherStatusName != null) result.otherStatusName = otherStatusName;
    if (otherStatusCategory != null)
      result.otherStatusCategory = otherStatusCategory;
    return result;
  }

  Link._();

  factory Link.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Link()..mergeFromBuffer(data, registry);
  factory Link.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Link()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Link',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.tasks'),
      createEmptyInstance: Link.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'kind')
    ..aOB(3, _omitFieldNames ? '' : 'restricted')
    ..aOS(4, _omitFieldNames ? '' : 'otherId')
    ..aOS(5, _omitFieldNames ? '' : 'otherProjectId')
    ..aOS(6, _omitFieldNames ? '' : 'otherDisplayId')
    ..aOS(7, _omitFieldNames ? '' : 'otherTitle')
    ..aOS(8, _omitFieldNames ? '' : 'otherStatusName')
    ..aOS(9, _omitFieldNames ? '' : 'otherStatusCategory')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Link clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Link copyWith(void Function(Link) updates) =>
      super.copyWith((message) => updates(message as Link)) as Link;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Link() / Link.new instead')
  static Link create() => Link._();
  static $pb.GeneratedMessage $_createMessage() => Link._();
  @$core.override
  Link createEmptyInstance() => Link._();
  @$core.pragma('dart2js:noInline')
  static Link getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Link>(Link.$_createMessage);
  static Link? _defaultInstance;

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
  $core.bool get restricted => $_getBF(2);
  @$pb.TagNumber(3)
  set restricted($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRestricted() => $_has(2);
  @$pb.TagNumber(3)
  void clearRestricted() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get otherId => $_getSZ(3);
  @$pb.TagNumber(4)
  set otherId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasOtherId() => $_has(3);
  @$pb.TagNumber(4)
  void clearOtherId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get otherProjectId => $_getSZ(4);
  @$pb.TagNumber(5)
  set otherProjectId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasOtherProjectId() => $_has(4);
  @$pb.TagNumber(5)
  void clearOtherProjectId() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get otherDisplayId => $_getSZ(5);
  @$pb.TagNumber(6)
  set otherDisplayId($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasOtherDisplayId() => $_has(5);
  @$pb.TagNumber(6)
  void clearOtherDisplayId() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get otherTitle => $_getSZ(6);
  @$pb.TagNumber(7)
  set otherTitle($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasOtherTitle() => $_has(6);
  @$pb.TagNumber(7)
  void clearOtherTitle() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get otherStatusName => $_getSZ(7);
  @$pb.TagNumber(8)
  set otherStatusName($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasOtherStatusName() => $_has(7);
  @$pb.TagNumber(8)
  void clearOtherStatusName() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get otherStatusCategory => $_getSZ(8);
  @$pb.TagNumber(9)
  set otherStatusCategory($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasOtherStatusCategory() => $_has(8);
  @$pb.TagNumber(9)
  void clearOtherStatusCategory() => $_clearField(9);
}

class LinkAddRequest extends $pb.GeneratedMessage {
  factory LinkAddRequest({
    $core.String? workspaceId,
    $core.String? taskId,
    $core.String? otherTaskId,
    $core.String? kind,
    $core.bool? closeDuplicate,
  }) {
    final result = LinkAddRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (taskId != null) result.taskId = taskId;
    if (otherTaskId != null) result.otherTaskId = otherTaskId;
    if (kind != null) result.kind = kind;
    if (closeDuplicate != null) result.closeDuplicate = closeDuplicate;
    return result;
  }

  LinkAddRequest._();

  factory LinkAddRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LinkAddRequest()..mergeFromBuffer(data, registry);
  factory LinkAddRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LinkAddRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LinkAddRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.tasks'),
      createEmptyInstance: LinkAddRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'taskId')
    ..aOS(3, _omitFieldNames ? '' : 'otherTaskId')
    ..aOS(4, _omitFieldNames ? '' : 'kind')
    ..aOB(5, _omitFieldNames ? '' : 'closeDuplicate')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LinkAddRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LinkAddRequest copyWith(void Function(LinkAddRequest) updates) =>
      super.copyWith((message) => updates(message as LinkAddRequest))
          as LinkAddRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use LinkAddRequest() / LinkAddRequest.new instead')
  static LinkAddRequest create() => LinkAddRequest._();
  static $pb.GeneratedMessage $_createMessage() => LinkAddRequest._();
  @$core.override
  LinkAddRequest createEmptyInstance() => LinkAddRequest._();
  @$core.pragma('dart2js:noInline')
  static LinkAddRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LinkAddRequest>(
          LinkAddRequest.$_createMessage);
  static LinkAddRequest? _defaultInstance;

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
  $core.String get otherTaskId => $_getSZ(2);
  @$pb.TagNumber(3)
  set otherTaskId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasOtherTaskId() => $_has(2);
  @$pb.TagNumber(3)
  void clearOtherTaskId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get kind => $_getSZ(3);
  @$pb.TagNumber(4)
  set kind($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasKind() => $_has(3);
  @$pb.TagNumber(4)
  void clearKind() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.bool get closeDuplicate => $_getBF(4);
  @$pb.TagNumber(5)
  set closeDuplicate($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasCloseDuplicate() => $_has(4);
  @$pb.TagNumber(5)
  void clearCloseDuplicate() => $_clearField(5);
}

class LinkCandidate extends $pb.GeneratedMessage {
  factory LinkCandidate({
    $core.String? id,
    $core.String? projectId,
    $core.String? displayId,
    $core.String? title,
    $core.String? statusName,
    $core.String? statusCategory,
  }) {
    final result = LinkCandidate._();
    if (id != null) result.id = id;
    if (projectId != null) result.projectId = projectId;
    if (displayId != null) result.displayId = displayId;
    if (title != null) result.title = title;
    if (statusName != null) result.statusName = statusName;
    if (statusCategory != null) result.statusCategory = statusCategory;
    return result;
  }

  LinkCandidate._();

  factory LinkCandidate.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LinkCandidate()..mergeFromBuffer(data, registry);
  factory LinkCandidate.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LinkCandidate()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LinkCandidate',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.tasks'),
      createEmptyInstance: LinkCandidate.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..aOS(3, _omitFieldNames ? '' : 'displayId')
    ..aOS(4, _omitFieldNames ? '' : 'title')
    ..aOS(5, _omitFieldNames ? '' : 'statusName')
    ..aOS(6, _omitFieldNames ? '' : 'statusCategory')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LinkCandidate clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LinkCandidate copyWith(void Function(LinkCandidate) updates) =>
      super.copyWith((message) => updates(message as LinkCandidate))
          as LinkCandidate;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use LinkCandidate() / LinkCandidate.new instead')
  static LinkCandidate create() => LinkCandidate._();
  static $pb.GeneratedMessage $_createMessage() => LinkCandidate._();
  @$core.override
  LinkCandidate createEmptyInstance() => LinkCandidate._();
  @$core.pragma('dart2js:noInline')
  static LinkCandidate getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LinkCandidate>(
          LinkCandidate.$_createMessage);
  static LinkCandidate? _defaultInstance;

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
}

class LinkCandidates extends $pb.GeneratedMessage {
  factory LinkCandidates({
    $core.Iterable<LinkCandidate>? tasks,
  }) {
    final result = LinkCandidates._();
    if (tasks != null) result.tasks.addAll(tasks);
    return result;
  }

  LinkCandidates._();

  factory LinkCandidates.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LinkCandidates()..mergeFromBuffer(data, registry);
  factory LinkCandidates.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LinkCandidates()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LinkCandidates',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.tasks'),
      createEmptyInstance: LinkCandidates.$_createMessage)
    ..pPM<LinkCandidate>(1, _omitFieldNames ? '' : 'tasks',
        subBuilder: LinkCandidate.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LinkCandidates clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LinkCandidates copyWith(void Function(LinkCandidates) updates) =>
      super.copyWith((message) => updates(message as LinkCandidates))
          as LinkCandidates;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use LinkCandidates() / LinkCandidates.new instead')
  static LinkCandidates create() => LinkCandidates._();
  static $pb.GeneratedMessage $_createMessage() => LinkCandidates._();
  @$core.override
  LinkCandidates createEmptyInstance() => LinkCandidates._();
  @$core.pragma('dart2js:noInline')
  static LinkCandidates getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LinkCandidates>(
          LinkCandidates.$_createMessage);
  static LinkCandidates? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<LinkCandidate> get tasks => $_getList(0);
}

class LinkList extends $pb.GeneratedMessage {
  factory LinkList({
    $core.Iterable<Link>? links,
  }) {
    final result = LinkList._();
    if (links != null) result.links.addAll(links);
    return result;
  }

  LinkList._();

  factory LinkList.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LinkList()..mergeFromBuffer(data, registry);
  factory LinkList.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LinkList()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LinkList',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.tasks'),
      createEmptyInstance: LinkList.$_createMessage)
    ..pPM<Link>(1, _omitFieldNames ? '' : 'links',
        subBuilder: Link.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LinkList clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LinkList copyWith(void Function(LinkList) updates) =>
      super.copyWith((message) => updates(message as LinkList)) as LinkList;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use LinkList() / LinkList.new instead')
  static LinkList create() => LinkList._();
  static $pb.GeneratedMessage $_createMessage() => LinkList._();
  @$core.override
  LinkList createEmptyInstance() => LinkList._();
  @$core.pragma('dart2js:noInline')
  static LinkList getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LinkList>(LinkList.$_createMessage);
  static LinkList? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Link> get links => $_getList(0);
}

class LinkListForTaskRequest extends $pb.GeneratedMessage {
  factory LinkListForTaskRequest({
    $core.String? workspaceId,
    $core.String? taskId,
  }) {
    final result = LinkListForTaskRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (taskId != null) result.taskId = taskId;
    return result;
  }

  LinkListForTaskRequest._();

  factory LinkListForTaskRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LinkListForTaskRequest()..mergeFromBuffer(data, registry);
  factory LinkListForTaskRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LinkListForTaskRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LinkListForTaskRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.tasks'),
      createEmptyInstance: LinkListForTaskRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'taskId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LinkListForTaskRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LinkListForTaskRequest copyWith(
          void Function(LinkListForTaskRequest) updates) =>
      super.copyWith((message) => updates(message as LinkListForTaskRequest))
          as LinkListForTaskRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use LinkListForTaskRequest() / LinkListForTaskRequest.new instead')
  static LinkListForTaskRequest create() => LinkListForTaskRequest._();
  static $pb.GeneratedMessage $_createMessage() => LinkListForTaskRequest._();
  @$core.override
  LinkListForTaskRequest createEmptyInstance() => LinkListForTaskRequest._();
  @$core.pragma('dart2js:noInline')
  static LinkListForTaskRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LinkListForTaskRequest>(
          LinkListForTaskRequest.$_createMessage);
  static LinkListForTaskRequest? _defaultInstance;

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

class LinkRemoveRequest extends $pb.GeneratedMessage {
  factory LinkRemoveRequest({
    $core.String? workspaceId,
    $core.String? taskId,
    $core.String? id,
  }) {
    final result = LinkRemoveRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (taskId != null) result.taskId = taskId;
    if (id != null) result.id = id;
    return result;
  }

  LinkRemoveRequest._();

  factory LinkRemoveRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LinkRemoveRequest()..mergeFromBuffer(data, registry);
  factory LinkRemoveRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LinkRemoveRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LinkRemoveRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.tasks'),
      createEmptyInstance: LinkRemoveRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'taskId')
    ..aOS(3, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LinkRemoveRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LinkRemoveRequest copyWith(void Function(LinkRemoveRequest) updates) =>
      super.copyWith((message) => updates(message as LinkRemoveRequest))
          as LinkRemoveRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use LinkRemoveRequest() / LinkRemoveRequest.new instead')
  static LinkRemoveRequest create() => LinkRemoveRequest._();
  static $pb.GeneratedMessage $_createMessage() => LinkRemoveRequest._();
  @$core.override
  LinkRemoveRequest createEmptyInstance() => LinkRemoveRequest._();
  @$core.pragma('dart2js:noInline')
  static LinkRemoveRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LinkRemoveRequest>(
          LinkRemoveRequest.$_createMessage);
  static LinkRemoveRequest? _defaultInstance;

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
  $core.String get id => $_getSZ(2);
  @$pb.TagNumber(3)
  set id($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasId() => $_has(2);
  @$pb.TagNumber(3)
  void clearId() => $_clearField(3);
}

class LinkSearchTasksRequest extends $pb.GeneratedMessage {
  factory LinkSearchTasksRequest({
    $core.String? workspaceId,
    $core.String? query,
  }) {
    final result = LinkSearchTasksRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (query != null) result.query = query;
    return result;
  }

  LinkSearchTasksRequest._();

  factory LinkSearchTasksRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LinkSearchTasksRequest()..mergeFromBuffer(data, registry);
  factory LinkSearchTasksRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LinkSearchTasksRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LinkSearchTasksRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.tasks'),
      createEmptyInstance: LinkSearchTasksRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'query')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LinkSearchTasksRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LinkSearchTasksRequest copyWith(
          void Function(LinkSearchTasksRequest) updates) =>
      super.copyWith((message) => updates(message as LinkSearchTasksRequest))
          as LinkSearchTasksRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use LinkSearchTasksRequest() / LinkSearchTasksRequest.new instead')
  static LinkSearchTasksRequest create() => LinkSearchTasksRequest._();
  static $pb.GeneratedMessage $_createMessage() => LinkSearchTasksRequest._();
  @$core.override
  LinkSearchTasksRequest createEmptyInstance() => LinkSearchTasksRequest._();
  @$core.pragma('dart2js:noInline')
  static LinkSearchTasksRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LinkSearchTasksRequest>(
          LinkSearchTasksRequest.$_createMessage);
  static LinkSearchTasksRequest? _defaultInstance;

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
}

class Task extends $pb.GeneratedMessage {
  factory Task({
    $core.String? id,
    $core.String? workspaceId,
    $core.String? projectId,
    $core.int? number,
    $core.String? displayId,
    $core.String? title,
    $core.String? description,
    $core.String? status,
    $core.String? priority,
    $core.String? startDate,
    $core.String? dueDate,
    $core.Iterable<$core.String>? assigneeIds,
    $core.String? createdBy,
    $core.int? version,
    $core.String? position,
    $core.String? createdAt,
    $core.String? updatedAt,
    $core.String? deletedAt,
    $core.String? statusName,
    $core.String? statusCategory,
    $core.String? parentId,
    $core.int? depth,
    $core.int? progressDone,
    $core.int? progressTotal,
    $core.bool? isBlocked,
    $core.Iterable<$core.String>? blockedBy,
  }) {
    final result = Task._();
    if (id != null) result.id = id;
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (projectId != null) result.projectId = projectId;
    if (number != null) result.number = number;
    if (displayId != null) result.displayId = displayId;
    if (title != null) result.title = title;
    if (description != null) result.description = description;
    if (status != null) result.status = status;
    if (priority != null) result.priority = priority;
    if (startDate != null) result.startDate = startDate;
    if (dueDate != null) result.dueDate = dueDate;
    if (assigneeIds != null) result.assigneeIds.addAll(assigneeIds);
    if (createdBy != null) result.createdBy = createdBy;
    if (version != null) result.version = version;
    if (position != null) result.position = position;
    if (createdAt != null) result.createdAt = createdAt;
    if (updatedAt != null) result.updatedAt = updatedAt;
    if (deletedAt != null) result.deletedAt = deletedAt;
    if (statusName != null) result.statusName = statusName;
    if (statusCategory != null) result.statusCategory = statusCategory;
    if (parentId != null) result.parentId = parentId;
    if (depth != null) result.depth = depth;
    if (progressDone != null) result.progressDone = progressDone;
    if (progressTotal != null) result.progressTotal = progressTotal;
    if (isBlocked != null) result.isBlocked = isBlocked;
    if (blockedBy != null) result.blockedBy.addAll(blockedBy);
    return result;
  }

  Task._();

  factory Task.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Task()..mergeFromBuffer(data, registry);
  factory Task.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Task()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Task',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.tasks'),
      createEmptyInstance: Task.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(3, _omitFieldNames ? '' : 'projectId')
    ..aI(4, _omitFieldNames ? '' : 'number')
    ..aOS(5, _omitFieldNames ? '' : 'displayId')
    ..aOS(6, _omitFieldNames ? '' : 'title')
    ..aOS(7, _omitFieldNames ? '' : 'description')
    ..aOS(8, _omitFieldNames ? '' : 'status')
    ..aOS(9, _omitFieldNames ? '' : 'priority')
    ..aOS(10, _omitFieldNames ? '' : 'startDate')
    ..aOS(11, _omitFieldNames ? '' : 'dueDate')
    ..pPS(12, _omitFieldNames ? '' : 'assigneeIds')
    ..aOS(13, _omitFieldNames ? '' : 'createdBy')
    ..aI(14, _omitFieldNames ? '' : 'version')
    ..aOS(15, _omitFieldNames ? '' : 'position')
    ..aOS(16, _omitFieldNames ? '' : 'createdAt')
    ..aOS(17, _omitFieldNames ? '' : 'updatedAt')
    ..aOS(18, _omitFieldNames ? '' : 'deletedAt')
    ..aOS(19, _omitFieldNames ? '' : 'statusName')
    ..aOS(20, _omitFieldNames ? '' : 'statusCategory')
    ..aOS(21, _omitFieldNames ? '' : 'parentId')
    ..aI(22, _omitFieldNames ? '' : 'depth')
    ..aI(23, _omitFieldNames ? '' : 'progressDone')
    ..aI(24, _omitFieldNames ? '' : 'progressTotal')
    ..aOB(25, _omitFieldNames ? '' : 'isBlocked')
    ..pPS(26, _omitFieldNames ? '' : 'blockedBy')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Task clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Task copyWith(void Function(Task) updates) =>
      super.copyWith((message) => updates(message as Task)) as Task;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Task() / Task.new instead')
  static Task create() => Task._();
  static $pb.GeneratedMessage $_createMessage() => Task._();
  @$core.override
  Task createEmptyInstance() => Task._();
  @$core.pragma('dart2js:noInline')
  static Task getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Task>(Task.$_createMessage);
  static Task? _defaultInstance;

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
  $core.int get number => $_getIZ(3);
  @$pb.TagNumber(4)
  set number($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasNumber() => $_has(3);
  @$pb.TagNumber(4)
  void clearNumber() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get displayId => $_getSZ(4);
  @$pb.TagNumber(5)
  set displayId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasDisplayId() => $_has(4);
  @$pb.TagNumber(5)
  void clearDisplayId() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get title => $_getSZ(5);
  @$pb.TagNumber(6)
  set title($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasTitle() => $_has(5);
  @$pb.TagNumber(6)
  void clearTitle() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get description => $_getSZ(6);
  @$pb.TagNumber(7)
  set description($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasDescription() => $_has(6);
  @$pb.TagNumber(7)
  void clearDescription() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get status => $_getSZ(7);
  @$pb.TagNumber(8)
  set status($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasStatus() => $_has(7);
  @$pb.TagNumber(8)
  void clearStatus() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get priority => $_getSZ(8);
  @$pb.TagNumber(9)
  set priority($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasPriority() => $_has(8);
  @$pb.TagNumber(9)
  void clearPriority() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get startDate => $_getSZ(9);
  @$pb.TagNumber(10)
  set startDate($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasStartDate() => $_has(9);
  @$pb.TagNumber(10)
  void clearStartDate() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.String get dueDate => $_getSZ(10);
  @$pb.TagNumber(11)
  set dueDate($core.String value) => $_setString(10, value);
  @$pb.TagNumber(11)
  $core.bool hasDueDate() => $_has(10);
  @$pb.TagNumber(11)
  void clearDueDate() => $_clearField(11);

  @$pb.TagNumber(12)
  $pb.PbList<$core.String> get assigneeIds => $_getList(11);

  @$pb.TagNumber(13)
  $core.String get createdBy => $_getSZ(12);
  @$pb.TagNumber(13)
  set createdBy($core.String value) => $_setString(12, value);
  @$pb.TagNumber(13)
  $core.bool hasCreatedBy() => $_has(12);
  @$pb.TagNumber(13)
  void clearCreatedBy() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.int get version => $_getIZ(13);
  @$pb.TagNumber(14)
  set version($core.int value) => $_setSignedInt32(13, value);
  @$pb.TagNumber(14)
  $core.bool hasVersion() => $_has(13);
  @$pb.TagNumber(14)
  void clearVersion() => $_clearField(14);

  @$pb.TagNumber(15)
  $core.String get position => $_getSZ(14);
  @$pb.TagNumber(15)
  set position($core.String value) => $_setString(14, value);
  @$pb.TagNumber(15)
  $core.bool hasPosition() => $_has(14);
  @$pb.TagNumber(15)
  void clearPosition() => $_clearField(15);

  @$pb.TagNumber(16)
  $core.String get createdAt => $_getSZ(15);
  @$pb.TagNumber(16)
  set createdAt($core.String value) => $_setString(15, value);
  @$pb.TagNumber(16)
  $core.bool hasCreatedAt() => $_has(15);
  @$pb.TagNumber(16)
  void clearCreatedAt() => $_clearField(16);

  @$pb.TagNumber(17)
  $core.String get updatedAt => $_getSZ(16);
  @$pb.TagNumber(17)
  set updatedAt($core.String value) => $_setString(16, value);
  @$pb.TagNumber(17)
  $core.bool hasUpdatedAt() => $_has(16);
  @$pb.TagNumber(17)
  void clearUpdatedAt() => $_clearField(17);

  @$pb.TagNumber(18)
  $core.String get deletedAt => $_getSZ(17);
  @$pb.TagNumber(18)
  set deletedAt($core.String value) => $_setString(17, value);
  @$pb.TagNumber(18)
  $core.bool hasDeletedAt() => $_has(17);
  @$pb.TagNumber(18)
  void clearDeletedAt() => $_clearField(18);

  @$pb.TagNumber(19)
  $core.String get statusName => $_getSZ(18);
  @$pb.TagNumber(19)
  set statusName($core.String value) => $_setString(18, value);
  @$pb.TagNumber(19)
  $core.bool hasStatusName() => $_has(18);
  @$pb.TagNumber(19)
  void clearStatusName() => $_clearField(19);

  @$pb.TagNumber(20)
  $core.String get statusCategory => $_getSZ(19);
  @$pb.TagNumber(20)
  set statusCategory($core.String value) => $_setString(19, value);
  @$pb.TagNumber(20)
  $core.bool hasStatusCategory() => $_has(19);
  @$pb.TagNumber(20)
  void clearStatusCategory() => $_clearField(20);

  @$pb.TagNumber(21)
  $core.String get parentId => $_getSZ(20);
  @$pb.TagNumber(21)
  set parentId($core.String value) => $_setString(20, value);
  @$pb.TagNumber(21)
  $core.bool hasParentId() => $_has(20);
  @$pb.TagNumber(21)
  void clearParentId() => $_clearField(21);

  @$pb.TagNumber(22)
  $core.int get depth => $_getIZ(21);
  @$pb.TagNumber(22)
  set depth($core.int value) => $_setSignedInt32(21, value);
  @$pb.TagNumber(22)
  $core.bool hasDepth() => $_has(21);
  @$pb.TagNumber(22)
  void clearDepth() => $_clearField(22);

  @$pb.TagNumber(23)
  $core.int get progressDone => $_getIZ(22);
  @$pb.TagNumber(23)
  set progressDone($core.int value) => $_setSignedInt32(22, value);
  @$pb.TagNumber(23)
  $core.bool hasProgressDone() => $_has(22);
  @$pb.TagNumber(23)
  void clearProgressDone() => $_clearField(23);

  @$pb.TagNumber(24)
  $core.int get progressTotal => $_getIZ(23);
  @$pb.TagNumber(24)
  set progressTotal($core.int value) => $_setSignedInt32(23, value);
  @$pb.TagNumber(24)
  $core.bool hasProgressTotal() => $_has(23);
  @$pb.TagNumber(24)
  void clearProgressTotal() => $_clearField(24);

  @$pb.TagNumber(25)
  $core.bool get isBlocked => $_getBF(24);
  @$pb.TagNumber(25)
  set isBlocked($core.bool value) => $_setBool(24, value);
  @$pb.TagNumber(25)
  $core.bool hasIsBlocked() => $_has(24);
  @$pb.TagNumber(25)
  void clearIsBlocked() => $_clearField(25);

  @$pb.TagNumber(26)
  $pb.PbList<$core.String> get blockedBy => $_getList(25);
}

class TaskChildren extends $pb.GeneratedMessage {
  factory TaskChildren({
    $core.Iterable<Task>? tasks,
  }) {
    final result = TaskChildren._();
    if (tasks != null) result.tasks.addAll(tasks);
    return result;
  }

  TaskChildren._();

  factory TaskChildren.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TaskChildren()..mergeFromBuffer(data, registry);
  factory TaskChildren.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TaskChildren()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TaskChildren',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.tasks'),
      createEmptyInstance: TaskChildren.$_createMessage)
    ..pPM<Task>(1, _omitFieldNames ? '' : 'tasks',
        subBuilder: Task.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TaskChildren clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TaskChildren copyWith(void Function(TaskChildren) updates) =>
      super.copyWith((message) => updates(message as TaskChildren))
          as TaskChildren;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use TaskChildren() / TaskChildren.new instead')
  static TaskChildren create() => TaskChildren._();
  static $pb.GeneratedMessage $_createMessage() => TaskChildren._();
  @$core.override
  TaskChildren createEmptyInstance() => TaskChildren._();
  @$core.pragma('dart2js:noInline')
  static TaskChildren getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TaskChildren>(
          TaskChildren.$_createMessage);
  static TaskChildren? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Task> get tasks => $_getList(0);
}

class TaskCreateRequest extends $pb.GeneratedMessage {
  factory TaskCreateRequest({
    $core.String? workspaceId,
    $core.String? projectId,
    $core.String? title,
    $core.String? description,
    $core.String? status,
    $core.String? priority,
    $core.String? startDate,
    $core.String? dueDate,
    $core.Iterable<$core.String>? assigneeIds,
    $core.String? parentId,
  }) {
    final result = TaskCreateRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (projectId != null) result.projectId = projectId;
    if (title != null) result.title = title;
    if (description != null) result.description = description;
    if (status != null) result.status = status;
    if (priority != null) result.priority = priority;
    if (startDate != null) result.startDate = startDate;
    if (dueDate != null) result.dueDate = dueDate;
    if (assigneeIds != null) result.assigneeIds.addAll(assigneeIds);
    if (parentId != null) result.parentId = parentId;
    return result;
  }

  TaskCreateRequest._();

  factory TaskCreateRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TaskCreateRequest()..mergeFromBuffer(data, registry);
  factory TaskCreateRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TaskCreateRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TaskCreateRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.tasks'),
      createEmptyInstance: TaskCreateRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..aOS(3, _omitFieldNames ? '' : 'title')
    ..aOS(4, _omitFieldNames ? '' : 'description')
    ..aOS(5, _omitFieldNames ? '' : 'status')
    ..aOS(6, _omitFieldNames ? '' : 'priority')
    ..aOS(7, _omitFieldNames ? '' : 'startDate')
    ..aOS(8, _omitFieldNames ? '' : 'dueDate')
    ..pPS(9, _omitFieldNames ? '' : 'assigneeIds')
    ..aOS(10, _omitFieldNames ? '' : 'parentId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TaskCreateRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TaskCreateRequest copyWith(void Function(TaskCreateRequest) updates) =>
      super.copyWith((message) => updates(message as TaskCreateRequest))
          as TaskCreateRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use TaskCreateRequest() / TaskCreateRequest.new instead')
  static TaskCreateRequest create() => TaskCreateRequest._();
  static $pb.GeneratedMessage $_createMessage() => TaskCreateRequest._();
  @$core.override
  TaskCreateRequest createEmptyInstance() => TaskCreateRequest._();
  @$core.pragma('dart2js:noInline')
  static TaskCreateRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TaskCreateRequest>(
          TaskCreateRequest.$_createMessage);
  static TaskCreateRequest? _defaultInstance;

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
  $core.String get title => $_getSZ(2);
  @$pb.TagNumber(3)
  set title($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTitle() => $_has(2);
  @$pb.TagNumber(3)
  void clearTitle() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get description => $_getSZ(3);
  @$pb.TagNumber(4)
  set description($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasDescription() => $_has(3);
  @$pb.TagNumber(4)
  void clearDescription() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get status => $_getSZ(4);
  @$pb.TagNumber(5)
  set status($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasStatus() => $_has(4);
  @$pb.TagNumber(5)
  void clearStatus() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get priority => $_getSZ(5);
  @$pb.TagNumber(6)
  set priority($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasPriority() => $_has(5);
  @$pb.TagNumber(6)
  void clearPriority() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get startDate => $_getSZ(6);
  @$pb.TagNumber(7)
  set startDate($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasStartDate() => $_has(6);
  @$pb.TagNumber(7)
  void clearStartDate() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get dueDate => $_getSZ(7);
  @$pb.TagNumber(8)
  set dueDate($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasDueDate() => $_has(7);
  @$pb.TagNumber(8)
  void clearDueDate() => $_clearField(8);

  @$pb.TagNumber(9)
  $pb.PbList<$core.String> get assigneeIds => $_getList(8);

  @$pb.TagNumber(10)
  $core.String get parentId => $_getSZ(9);
  @$pb.TagNumber(10)
  set parentId($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasParentId() => $_has(9);
  @$pb.TagNumber(10)
  void clearParentId() => $_clearField(10);
}

class TaskDeleteRequest extends $pb.GeneratedMessage {
  factory TaskDeleteRequest({
    $core.String? workspaceId,
    $core.String? projectId,
    $core.String? id,
    $core.String? mode,
  }) {
    final result = TaskDeleteRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (projectId != null) result.projectId = projectId;
    if (id != null) result.id = id;
    if (mode != null) result.mode = mode;
    return result;
  }

  TaskDeleteRequest._();

  factory TaskDeleteRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TaskDeleteRequest()..mergeFromBuffer(data, registry);
  factory TaskDeleteRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TaskDeleteRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TaskDeleteRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.tasks'),
      createEmptyInstance: TaskDeleteRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..aOS(3, _omitFieldNames ? '' : 'id')
    ..aOS(4, _omitFieldNames ? '' : 'mode')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TaskDeleteRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TaskDeleteRequest copyWith(void Function(TaskDeleteRequest) updates) =>
      super.copyWith((message) => updates(message as TaskDeleteRequest))
          as TaskDeleteRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use TaskDeleteRequest() / TaskDeleteRequest.new instead')
  static TaskDeleteRequest create() => TaskDeleteRequest._();
  static $pb.GeneratedMessage $_createMessage() => TaskDeleteRequest._();
  @$core.override
  TaskDeleteRequest createEmptyInstance() => TaskDeleteRequest._();
  @$core.pragma('dart2js:noInline')
  static TaskDeleteRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TaskDeleteRequest>(
          TaskDeleteRequest.$_createMessage);
  static TaskDeleteRequest? _defaultInstance;

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
  $core.String get id => $_getSZ(2);
  @$pb.TagNumber(3)
  set id($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasId() => $_has(2);
  @$pb.TagNumber(3)
  void clearId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get mode => $_getSZ(3);
  @$pb.TagNumber(4)
  set mode($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasMode() => $_has(3);
  @$pb.TagNumber(4)
  void clearMode() => $_clearField(4);
}

class TaskGetRequest extends $pb.GeneratedMessage {
  factory TaskGetRequest({
    $core.String? workspaceId,
    $core.String? projectId,
    $core.String? id,
  }) {
    final result = TaskGetRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (projectId != null) result.projectId = projectId;
    if (id != null) result.id = id;
    return result;
  }

  TaskGetRequest._();

  factory TaskGetRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TaskGetRequest()..mergeFromBuffer(data, registry);
  factory TaskGetRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TaskGetRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TaskGetRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.tasks'),
      createEmptyInstance: TaskGetRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..aOS(3, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TaskGetRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TaskGetRequest copyWith(void Function(TaskGetRequest) updates) =>
      super.copyWith((message) => updates(message as TaskGetRequest))
          as TaskGetRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use TaskGetRequest() / TaskGetRequest.new instead')
  static TaskGetRequest create() => TaskGetRequest._();
  static $pb.GeneratedMessage $_createMessage() => TaskGetRequest._();
  @$core.override
  TaskGetRequest createEmptyInstance() => TaskGetRequest._();
  @$core.pragma('dart2js:noInline')
  static TaskGetRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TaskGetRequest>(
          TaskGetRequest.$_createMessage);
  static TaskGetRequest? _defaultInstance;

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
  $core.String get id => $_getSZ(2);
  @$pb.TagNumber(3)
  set id($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasId() => $_has(2);
  @$pb.TagNumber(3)
  void clearId() => $_clearField(3);
}

class TaskListChildrenRequest extends $pb.GeneratedMessage {
  factory TaskListChildrenRequest({
    $core.String? workspaceId,
    $core.String? projectId,
    $core.String? id,
  }) {
    final result = TaskListChildrenRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (projectId != null) result.projectId = projectId;
    if (id != null) result.id = id;
    return result;
  }

  TaskListChildrenRequest._();

  factory TaskListChildrenRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TaskListChildrenRequest()..mergeFromBuffer(data, registry);
  factory TaskListChildrenRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TaskListChildrenRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TaskListChildrenRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.tasks'),
      createEmptyInstance: TaskListChildrenRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..aOS(3, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TaskListChildrenRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TaskListChildrenRequest copyWith(
          void Function(TaskListChildrenRequest) updates) =>
      super.copyWith((message) => updates(message as TaskListChildrenRequest))
          as TaskListChildrenRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use TaskListChildrenRequest() / TaskListChildrenRequest.new instead')
  static TaskListChildrenRequest create() => TaskListChildrenRequest._();
  static $pb.GeneratedMessage $_createMessage() => TaskListChildrenRequest._();
  @$core.override
  TaskListChildrenRequest createEmptyInstance() => TaskListChildrenRequest._();
  @$core.pragma('dart2js:noInline')
  static TaskListChildrenRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TaskListChildrenRequest>(
          TaskListChildrenRequest.$_createMessage);
  static TaskListChildrenRequest? _defaultInstance;

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
  $core.String get id => $_getSZ(2);
  @$pb.TagNumber(3)
  set id($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasId() => $_has(2);
  @$pb.TagNumber(3)
  void clearId() => $_clearField(3);
}

class TaskListRequest extends $pb.GeneratedMessage {
  factory TaskListRequest({
    $core.String? workspaceId,
    $core.String? projectId,
    $core.String? status,
    $core.String? assigneeId,
    $core.String? cursor,
    $core.int? pageSize,
    $core.bool? includeSubtasks,
  }) {
    final result = TaskListRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (projectId != null) result.projectId = projectId;
    if (status != null) result.status = status;
    if (assigneeId != null) result.assigneeId = assigneeId;
    if (cursor != null) result.cursor = cursor;
    if (pageSize != null) result.pageSize = pageSize;
    if (includeSubtasks != null) result.includeSubtasks = includeSubtasks;
    return result;
  }

  TaskListRequest._();

  factory TaskListRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TaskListRequest()..mergeFromBuffer(data, registry);
  factory TaskListRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TaskListRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TaskListRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.tasks'),
      createEmptyInstance: TaskListRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..aOS(3, _omitFieldNames ? '' : 'status')
    ..aOS(4, _omitFieldNames ? '' : 'assigneeId')
    ..aOS(5, _omitFieldNames ? '' : 'cursor')
    ..aI(6, _omitFieldNames ? '' : 'pageSize')
    ..aOB(7, _omitFieldNames ? '' : 'includeSubtasks')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TaskListRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TaskListRequest copyWith(void Function(TaskListRequest) updates) =>
      super.copyWith((message) => updates(message as TaskListRequest))
          as TaskListRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use TaskListRequest() / TaskListRequest.new instead')
  static TaskListRequest create() => TaskListRequest._();
  static $pb.GeneratedMessage $_createMessage() => TaskListRequest._();
  @$core.override
  TaskListRequest createEmptyInstance() => TaskListRequest._();
  @$core.pragma('dart2js:noInline')
  static TaskListRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TaskListRequest>(
          TaskListRequest.$_createMessage);
  static TaskListRequest? _defaultInstance;

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
  $core.String get status => $_getSZ(2);
  @$pb.TagNumber(3)
  set status($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasStatus() => $_has(2);
  @$pb.TagNumber(3)
  void clearStatus() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get assigneeId => $_getSZ(3);
  @$pb.TagNumber(4)
  set assigneeId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasAssigneeId() => $_has(3);
  @$pb.TagNumber(4)
  void clearAssigneeId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get cursor => $_getSZ(4);
  @$pb.TagNumber(5)
  set cursor($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasCursor() => $_has(4);
  @$pb.TagNumber(5)
  void clearCursor() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get pageSize => $_getIZ(5);
  @$pb.TagNumber(6)
  set pageSize($core.int value) => $_setSignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasPageSize() => $_has(5);
  @$pb.TagNumber(6)
  void clearPageSize() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.bool get includeSubtasks => $_getBF(6);
  @$pb.TagNumber(7)
  set includeSubtasks($core.bool value) => $_setBool(6, value);
  @$pb.TagNumber(7)
  $core.bool hasIncludeSubtasks() => $_has(6);
  @$pb.TagNumber(7)
  void clearIncludeSubtasks() => $_clearField(7);
}

class TaskListTrashRequest extends $pb.GeneratedMessage {
  factory TaskListTrashRequest({
    $core.String? workspaceId,
    $core.String? projectId,
  }) {
    final result = TaskListTrashRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (projectId != null) result.projectId = projectId;
    return result;
  }

  TaskListTrashRequest._();

  factory TaskListTrashRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TaskListTrashRequest()..mergeFromBuffer(data, registry);
  factory TaskListTrashRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TaskListTrashRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TaskListTrashRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.tasks'),
      createEmptyInstance: TaskListTrashRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TaskListTrashRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TaskListTrashRequest copyWith(void Function(TaskListTrashRequest) updates) =>
      super.copyWith((message) => updates(message as TaskListTrashRequest))
          as TaskListTrashRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use TaskListTrashRequest() / TaskListTrashRequest.new instead')
  static TaskListTrashRequest create() => TaskListTrashRequest._();
  static $pb.GeneratedMessage $_createMessage() => TaskListTrashRequest._();
  @$core.override
  TaskListTrashRequest createEmptyInstance() => TaskListTrashRequest._();
  @$core.pragma('dart2js:noInline')
  static TaskListTrashRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TaskListTrashRequest>(
          TaskListTrashRequest.$_createMessage);
  static TaskListTrashRequest? _defaultInstance;

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

class TaskMoveRequest extends $pb.GeneratedMessage {
  factory TaskMoveRequest({
    $core.String? workspaceId,
    $core.String? projectId,
    $core.String? id,
    $core.int? expectedVersion,
    $core.String? status,
    $core.bool? includeSubtasks,
    $core.bool? overrideBlocked,
  }) {
    final result = TaskMoveRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (projectId != null) result.projectId = projectId;
    if (id != null) result.id = id;
    if (expectedVersion != null) result.expectedVersion = expectedVersion;
    if (status != null) result.status = status;
    if (includeSubtasks != null) result.includeSubtasks = includeSubtasks;
    if (overrideBlocked != null) result.overrideBlocked = overrideBlocked;
    return result;
  }

  TaskMoveRequest._();

  factory TaskMoveRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TaskMoveRequest()..mergeFromBuffer(data, registry);
  factory TaskMoveRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TaskMoveRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TaskMoveRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.tasks'),
      createEmptyInstance: TaskMoveRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..aOS(3, _omitFieldNames ? '' : 'id')
    ..aI(4, _omitFieldNames ? '' : 'expectedVersion')
    ..aOS(5, _omitFieldNames ? '' : 'status')
    ..aOB(6, _omitFieldNames ? '' : 'includeSubtasks')
    ..aOB(7, _omitFieldNames ? '' : 'overrideBlocked')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TaskMoveRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TaskMoveRequest copyWith(void Function(TaskMoveRequest) updates) =>
      super.copyWith((message) => updates(message as TaskMoveRequest))
          as TaskMoveRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use TaskMoveRequest() / TaskMoveRequest.new instead')
  static TaskMoveRequest create() => TaskMoveRequest._();
  static $pb.GeneratedMessage $_createMessage() => TaskMoveRequest._();
  @$core.override
  TaskMoveRequest createEmptyInstance() => TaskMoveRequest._();
  @$core.pragma('dart2js:noInline')
  static TaskMoveRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TaskMoveRequest>(
          TaskMoveRequest.$_createMessage);
  static TaskMoveRequest? _defaultInstance;

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
  $core.String get id => $_getSZ(2);
  @$pb.TagNumber(3)
  set id($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasId() => $_has(2);
  @$pb.TagNumber(3)
  void clearId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get expectedVersion => $_getIZ(3);
  @$pb.TagNumber(4)
  set expectedVersion($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasExpectedVersion() => $_has(3);
  @$pb.TagNumber(4)
  void clearExpectedVersion() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get status => $_getSZ(4);
  @$pb.TagNumber(5)
  set status($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasStatus() => $_has(4);
  @$pb.TagNumber(5)
  void clearStatus() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.bool get includeSubtasks => $_getBF(5);
  @$pb.TagNumber(6)
  set includeSubtasks($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasIncludeSubtasks() => $_has(5);
  @$pb.TagNumber(6)
  void clearIncludeSubtasks() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.bool get overrideBlocked => $_getBF(6);
  @$pb.TagNumber(7)
  set overrideBlocked($core.bool value) => $_setBool(6, value);
  @$pb.TagNumber(7)
  $core.bool hasOverrideBlocked() => $_has(6);
  @$pb.TagNumber(7)
  void clearOverrideBlocked() => $_clearField(7);
}

class TaskRestoreRequest extends $pb.GeneratedMessage {
  factory TaskRestoreRequest({
    $core.String? workspaceId,
    $core.String? projectId,
    $core.String? id,
  }) {
    final result = TaskRestoreRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (projectId != null) result.projectId = projectId;
    if (id != null) result.id = id;
    return result;
  }

  TaskRestoreRequest._();

  factory TaskRestoreRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TaskRestoreRequest()..mergeFromBuffer(data, registry);
  factory TaskRestoreRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TaskRestoreRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TaskRestoreRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.tasks'),
      createEmptyInstance: TaskRestoreRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..aOS(3, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TaskRestoreRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TaskRestoreRequest copyWith(void Function(TaskRestoreRequest) updates) =>
      super.copyWith((message) => updates(message as TaskRestoreRequest))
          as TaskRestoreRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use TaskRestoreRequest() / TaskRestoreRequest.new instead')
  static TaskRestoreRequest create() => TaskRestoreRequest._();
  static $pb.GeneratedMessage $_createMessage() => TaskRestoreRequest._();
  @$core.override
  TaskRestoreRequest createEmptyInstance() => TaskRestoreRequest._();
  @$core.pragma('dart2js:noInline')
  static TaskRestoreRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TaskRestoreRequest>(
          TaskRestoreRequest.$_createMessage);
  static TaskRestoreRequest? _defaultInstance;

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
  $core.String get id => $_getSZ(2);
  @$pb.TagNumber(3)
  set id($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasId() => $_has(2);
  @$pb.TagNumber(3)
  void clearId() => $_clearField(3);
}

class TaskSetParentRequest extends $pb.GeneratedMessage {
  factory TaskSetParentRequest({
    $core.String? workspaceId,
    $core.String? projectId,
    $core.String? id,
    $core.int? expectedVersion,
    $core.String? parentId,
  }) {
    final result = TaskSetParentRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (projectId != null) result.projectId = projectId;
    if (id != null) result.id = id;
    if (expectedVersion != null) result.expectedVersion = expectedVersion;
    if (parentId != null) result.parentId = parentId;
    return result;
  }

  TaskSetParentRequest._();

  factory TaskSetParentRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TaskSetParentRequest()..mergeFromBuffer(data, registry);
  factory TaskSetParentRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TaskSetParentRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TaskSetParentRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.tasks'),
      createEmptyInstance: TaskSetParentRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..aOS(3, _omitFieldNames ? '' : 'id')
    ..aI(4, _omitFieldNames ? '' : 'expectedVersion')
    ..aOS(5, _omitFieldNames ? '' : 'parentId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TaskSetParentRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TaskSetParentRequest copyWith(void Function(TaskSetParentRequest) updates) =>
      super.copyWith((message) => updates(message as TaskSetParentRequest))
          as TaskSetParentRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use TaskSetParentRequest() / TaskSetParentRequest.new instead')
  static TaskSetParentRequest create() => TaskSetParentRequest._();
  static $pb.GeneratedMessage $_createMessage() => TaskSetParentRequest._();
  @$core.override
  TaskSetParentRequest createEmptyInstance() => TaskSetParentRequest._();
  @$core.pragma('dart2js:noInline')
  static TaskSetParentRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TaskSetParentRequest>(
          TaskSetParentRequest.$_createMessage);
  static TaskSetParentRequest? _defaultInstance;

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
  $core.String get id => $_getSZ(2);
  @$pb.TagNumber(3)
  set id($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasId() => $_has(2);
  @$pb.TagNumber(3)
  void clearId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get expectedVersion => $_getIZ(3);
  @$pb.TagNumber(4)
  set expectedVersion($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasExpectedVersion() => $_has(3);
  @$pb.TagNumber(4)
  void clearExpectedVersion() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get parentId => $_getSZ(4);
  @$pb.TagNumber(5)
  set parentId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasParentId() => $_has(4);
  @$pb.TagNumber(5)
  void clearParentId() => $_clearField(5);
}

class TaskTrash extends $pb.GeneratedMessage {
  factory TaskTrash({
    $core.Iterable<Task>? tasks,
  }) {
    final result = TaskTrash._();
    if (tasks != null) result.tasks.addAll(tasks);
    return result;
  }

  TaskTrash._();

  factory TaskTrash.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TaskTrash()..mergeFromBuffer(data, registry);
  factory TaskTrash.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TaskTrash()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TaskTrash',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.tasks'),
      createEmptyInstance: TaskTrash.$_createMessage)
    ..pPM<Task>(1, _omitFieldNames ? '' : 'tasks',
        subBuilder: Task.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TaskTrash clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TaskTrash copyWith(void Function(TaskTrash) updates) =>
      super.copyWith((message) => updates(message as TaskTrash)) as TaskTrash;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use TaskTrash() / TaskTrash.new instead')
  static TaskTrash create() => TaskTrash._();
  static $pb.GeneratedMessage $_createMessage() => TaskTrash._();
  @$core.override
  TaskTrash createEmptyInstance() => TaskTrash._();
  @$core.pragma('dart2js:noInline')
  static TaskTrash getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TaskTrash>(TaskTrash.$_createMessage);
  static TaskTrash? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Task> get tasks => $_getList(0);
}

class TaskUpdateRequest extends $pb.GeneratedMessage {
  factory TaskUpdateRequest({
    $core.String? workspaceId,
    $core.String? projectId,
    $core.String? id,
    $core.int? expectedVersion,
    $core.String? title,
    $core.String? description,
    $core.String? status,
    $core.String? priority,
    $core.String? startDate,
    $core.String? dueDate,
    $core.bool? setAssignees,
    $core.Iterable<$core.String>? assigneeIds,
    $core.bool? overrideBlocked,
  }) {
    final result = TaskUpdateRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (projectId != null) result.projectId = projectId;
    if (id != null) result.id = id;
    if (expectedVersion != null) result.expectedVersion = expectedVersion;
    if (title != null) result.title = title;
    if (description != null) result.description = description;
    if (status != null) result.status = status;
    if (priority != null) result.priority = priority;
    if (startDate != null) result.startDate = startDate;
    if (dueDate != null) result.dueDate = dueDate;
    if (setAssignees != null) result.setAssignees = setAssignees;
    if (assigneeIds != null) result.assigneeIds.addAll(assigneeIds);
    if (overrideBlocked != null) result.overrideBlocked = overrideBlocked;
    return result;
  }

  TaskUpdateRequest._();

  factory TaskUpdateRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TaskUpdateRequest()..mergeFromBuffer(data, registry);
  factory TaskUpdateRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TaskUpdateRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TaskUpdateRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.tasks'),
      createEmptyInstance: TaskUpdateRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..aOS(3, _omitFieldNames ? '' : 'id')
    ..aI(4, _omitFieldNames ? '' : 'expectedVersion')
    ..aOS(5, _omitFieldNames ? '' : 'title')
    ..aOS(6, _omitFieldNames ? '' : 'description')
    ..aOS(7, _omitFieldNames ? '' : 'status')
    ..aOS(8, _omitFieldNames ? '' : 'priority')
    ..aOS(9, _omitFieldNames ? '' : 'startDate')
    ..aOS(10, _omitFieldNames ? '' : 'dueDate')
    ..aOB(11, _omitFieldNames ? '' : 'setAssignees')
    ..pPS(12, _omitFieldNames ? '' : 'assigneeIds')
    ..aOB(13, _omitFieldNames ? '' : 'overrideBlocked')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TaskUpdateRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TaskUpdateRequest copyWith(void Function(TaskUpdateRequest) updates) =>
      super.copyWith((message) => updates(message as TaskUpdateRequest))
          as TaskUpdateRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use TaskUpdateRequest() / TaskUpdateRequest.new instead')
  static TaskUpdateRequest create() => TaskUpdateRequest._();
  static $pb.GeneratedMessage $_createMessage() => TaskUpdateRequest._();
  @$core.override
  TaskUpdateRequest createEmptyInstance() => TaskUpdateRequest._();
  @$core.pragma('dart2js:noInline')
  static TaskUpdateRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TaskUpdateRequest>(
          TaskUpdateRequest.$_createMessage);
  static TaskUpdateRequest? _defaultInstance;

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
  $core.String get id => $_getSZ(2);
  @$pb.TagNumber(3)
  set id($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasId() => $_has(2);
  @$pb.TagNumber(3)
  void clearId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get expectedVersion => $_getIZ(3);
  @$pb.TagNumber(4)
  set expectedVersion($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasExpectedVersion() => $_has(3);
  @$pb.TagNumber(4)
  void clearExpectedVersion() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get title => $_getSZ(4);
  @$pb.TagNumber(5)
  set title($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasTitle() => $_has(4);
  @$pb.TagNumber(5)
  void clearTitle() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get description => $_getSZ(5);
  @$pb.TagNumber(6)
  set description($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasDescription() => $_has(5);
  @$pb.TagNumber(6)
  void clearDescription() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get status => $_getSZ(6);
  @$pb.TagNumber(7)
  set status($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasStatus() => $_has(6);
  @$pb.TagNumber(7)
  void clearStatus() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get priority => $_getSZ(7);
  @$pb.TagNumber(8)
  set priority($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasPriority() => $_has(7);
  @$pb.TagNumber(8)
  void clearPriority() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get startDate => $_getSZ(8);
  @$pb.TagNumber(9)
  set startDate($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasStartDate() => $_has(8);
  @$pb.TagNumber(9)
  void clearStartDate() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get dueDate => $_getSZ(9);
  @$pb.TagNumber(10)
  set dueDate($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasDueDate() => $_has(9);
  @$pb.TagNumber(10)
  void clearDueDate() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.bool get setAssignees => $_getBF(10);
  @$pb.TagNumber(11)
  set setAssignees($core.bool value) => $_setBool(10, value);
  @$pb.TagNumber(11)
  $core.bool hasSetAssignees() => $_has(10);
  @$pb.TagNumber(11)
  void clearSetAssignees() => $_clearField(11);

  @$pb.TagNumber(12)
  $pb.PbList<$core.String> get assigneeIds => $_getList(11);

  @$pb.TagNumber(13)
  $core.bool get overrideBlocked => $_getBF(12);
  @$pb.TagNumber(13)
  set overrideBlocked($core.bool value) => $_setBool(12, value);
  @$pb.TagNumber(13)
  $core.bool hasOverrideBlocked() => $_has(12);
  @$pb.TagNumber(13)
  void clearOverrideBlocked() => $_clearField(13);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
