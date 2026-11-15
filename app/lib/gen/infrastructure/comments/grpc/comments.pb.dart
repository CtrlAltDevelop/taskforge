// This is a generated file - do not edit.
//
// Generated from infrastructure/comments/grpc/comments.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class Comment extends $pb.GeneratedMessage {
  factory Comment({
    $core.String? id,
    $core.String? taskId,
    $core.String? authorId,
    $core.String? parentId,
    $core.String? body,
    $core.String? createdAt,
    $core.String? editedAt,
    $core.bool? deleted,
    $core.bool? pinned,
    $core.int? version,
    $core.Iterable<$core.String>? mentionIds,
    $core.Iterable<ReactionResponse>? reactions,
    $core.int? editCount,
    $core.String? kind,
    $core.String? event,
  }) {
    final result = Comment._();
    if (id != null) result.id = id;
    if (taskId != null) result.taskId = taskId;
    if (authorId != null) result.authorId = authorId;
    if (parentId != null) result.parentId = parentId;
    if (body != null) result.body = body;
    if (createdAt != null) result.createdAt = createdAt;
    if (editedAt != null) result.editedAt = editedAt;
    if (deleted != null) result.deleted = deleted;
    if (pinned != null) result.pinned = pinned;
    if (version != null) result.version = version;
    if (mentionIds != null) result.mentionIds.addAll(mentionIds);
    if (reactions != null) result.reactions.addAll(reactions);
    if (editCount != null) result.editCount = editCount;
    if (kind != null) result.kind = kind;
    if (event != null) result.event = event;
    return result;
  }

  Comment._();

  factory Comment.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Comment()..mergeFromBuffer(data, registry);
  factory Comment.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Comment()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Comment',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.comments'),
      createEmptyInstance: Comment.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'taskId')
    ..aOS(3, _omitFieldNames ? '' : 'authorId')
    ..aOS(4, _omitFieldNames ? '' : 'parentId')
    ..aOS(5, _omitFieldNames ? '' : 'body')
    ..aOS(6, _omitFieldNames ? '' : 'createdAt')
    ..aOS(7, _omitFieldNames ? '' : 'editedAt')
    ..aOB(8, _omitFieldNames ? '' : 'deleted')
    ..aOB(9, _omitFieldNames ? '' : 'pinned')
    ..aI(10, _omitFieldNames ? '' : 'version')
    ..pPS(11, _omitFieldNames ? '' : 'mentionIds')
    ..pPM<ReactionResponse>(12, _omitFieldNames ? '' : 'reactions',
        subBuilder: ReactionResponse.$_createMessage)
    ..aI(13, _omitFieldNames ? '' : 'editCount')
    ..aOS(14, _omitFieldNames ? '' : 'kind')
    ..aOS(15, _omitFieldNames ? '' : 'event')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Comment clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Comment copyWith(void Function(Comment) updates) =>
      super.copyWith((message) => updates(message as Comment)) as Comment;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Comment() / Comment.new instead')
  static Comment create() => Comment._();
  static $pb.GeneratedMessage $_createMessage() => Comment._();
  @$core.override
  Comment createEmptyInstance() => Comment._();
  @$core.pragma('dart2js:noInline')
  static Comment getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Comment>(Comment.$_createMessage);
  static Comment? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get taskId => $_getSZ(1);
  @$pb.TagNumber(2)
  set taskId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTaskId() => $_has(1);
  @$pb.TagNumber(2)
  void clearTaskId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get authorId => $_getSZ(2);
  @$pb.TagNumber(3)
  set authorId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAuthorId() => $_has(2);
  @$pb.TagNumber(3)
  void clearAuthorId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get parentId => $_getSZ(3);
  @$pb.TagNumber(4)
  set parentId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasParentId() => $_has(3);
  @$pb.TagNumber(4)
  void clearParentId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get body => $_getSZ(4);
  @$pb.TagNumber(5)
  set body($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasBody() => $_has(4);
  @$pb.TagNumber(5)
  void clearBody() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get createdAt => $_getSZ(5);
  @$pb.TagNumber(6)
  set createdAt($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasCreatedAt() => $_has(5);
  @$pb.TagNumber(6)
  void clearCreatedAt() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get editedAt => $_getSZ(6);
  @$pb.TagNumber(7)
  set editedAt($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasEditedAt() => $_has(6);
  @$pb.TagNumber(7)
  void clearEditedAt() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.bool get deleted => $_getBF(7);
  @$pb.TagNumber(8)
  set deleted($core.bool value) => $_setBool(7, value);
  @$pb.TagNumber(8)
  $core.bool hasDeleted() => $_has(7);
  @$pb.TagNumber(8)
  void clearDeleted() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.bool get pinned => $_getBF(8);
  @$pb.TagNumber(9)
  set pinned($core.bool value) => $_setBool(8, value);
  @$pb.TagNumber(9)
  $core.bool hasPinned() => $_has(8);
  @$pb.TagNumber(9)
  void clearPinned() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.int get version => $_getIZ(9);
  @$pb.TagNumber(10)
  set version($core.int value) => $_setSignedInt32(9, value);
  @$pb.TagNumber(10)
  $core.bool hasVersion() => $_has(9);
  @$pb.TagNumber(10)
  void clearVersion() => $_clearField(10);

  @$pb.TagNumber(11)
  $pb.PbList<$core.String> get mentionIds => $_getList(10);

  @$pb.TagNumber(12)
  $pb.PbList<ReactionResponse> get reactions => $_getList(11);

  @$pb.TagNumber(13)
  $core.int get editCount => $_getIZ(12);
  @$pb.TagNumber(13)
  set editCount($core.int value) => $_setSignedInt32(12, value);
  @$pb.TagNumber(13)
  $core.bool hasEditCount() => $_has(12);
  @$pb.TagNumber(13)
  void clearEditCount() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.String get kind => $_getSZ(13);
  @$pb.TagNumber(14)
  set kind($core.String value) => $_setString(13, value);
  @$pb.TagNumber(14)
  $core.bool hasKind() => $_has(13);
  @$pb.TagNumber(14)
  void clearKind() => $_clearField(14);

  @$pb.TagNumber(15)
  $core.String get event => $_getSZ(14);
  @$pb.TagNumber(15)
  set event($core.String value) => $_setString(14, value);
  @$pb.TagNumber(15)
  $core.bool hasEvent() => $_has(14);
  @$pb.TagNumber(15)
  void clearEvent() => $_clearField(15);
}

class CommentCreateRequest extends $pb.GeneratedMessage {
  factory CommentCreateRequest({
    $core.String? workspaceId,
    $core.String? projectId,
    $core.String? taskId,
    $core.String? body,
    $core.String? parentId,
    $core.bool? grantAccess,
    $core.String? clientId,
    $core.String? clientMutationId,
  }) {
    final result = CommentCreateRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (projectId != null) result.projectId = projectId;
    if (taskId != null) result.taskId = taskId;
    if (body != null) result.body = body;
    if (parentId != null) result.parentId = parentId;
    if (grantAccess != null) result.grantAccess = grantAccess;
    if (clientId != null) result.clientId = clientId;
    if (clientMutationId != null) result.clientMutationId = clientMutationId;
    return result;
  }

  CommentCreateRequest._();

  factory CommentCreateRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CommentCreateRequest()..mergeFromBuffer(data, registry);
  factory CommentCreateRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CommentCreateRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CommentCreateRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.comments'),
      createEmptyInstance: CommentCreateRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..aOS(3, _omitFieldNames ? '' : 'taskId')
    ..aOS(4, _omitFieldNames ? '' : 'body')
    ..aOS(5, _omitFieldNames ? '' : 'parentId')
    ..aOB(6, _omitFieldNames ? '' : 'grantAccess')
    ..aOS(7, _omitFieldNames ? '' : 'clientId')
    ..aOS(8, _omitFieldNames ? '' : 'clientMutationId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CommentCreateRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CommentCreateRequest copyWith(void Function(CommentCreateRequest) updates) =>
      super.copyWith((message) => updates(message as CommentCreateRequest))
          as CommentCreateRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use CommentCreateRequest() / CommentCreateRequest.new instead')
  static CommentCreateRequest create() => CommentCreateRequest._();
  static $pb.GeneratedMessage $_createMessage() => CommentCreateRequest._();
  @$core.override
  CommentCreateRequest createEmptyInstance() => CommentCreateRequest._();
  @$core.pragma('dart2js:noInline')
  static CommentCreateRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CommentCreateRequest>(
          CommentCreateRequest.$_createMessage);
  static CommentCreateRequest? _defaultInstance;

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
  $core.String get body => $_getSZ(3);
  @$pb.TagNumber(4)
  set body($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasBody() => $_has(3);
  @$pb.TagNumber(4)
  void clearBody() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get parentId => $_getSZ(4);
  @$pb.TagNumber(5)
  set parentId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasParentId() => $_has(4);
  @$pb.TagNumber(5)
  void clearParentId() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.bool get grantAccess => $_getBF(5);
  @$pb.TagNumber(6)
  set grantAccess($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasGrantAccess() => $_has(5);
  @$pb.TagNumber(6)
  void clearGrantAccess() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get clientId => $_getSZ(6);
  @$pb.TagNumber(7)
  set clientId($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasClientId() => $_has(6);
  @$pb.TagNumber(7)
  void clearClientId() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get clientMutationId => $_getSZ(7);
  @$pb.TagNumber(8)
  set clientMutationId($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasClientMutationId() => $_has(7);
  @$pb.TagNumber(8)
  void clearClientMutationId() => $_clearField(8);
}

class CommentDeleteRequest extends $pb.GeneratedMessage {
  factory CommentDeleteRequest({
    $core.String? workspaceId,
    $core.String? projectId,
    $core.String? id,
  }) {
    final result = CommentDeleteRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (projectId != null) result.projectId = projectId;
    if (id != null) result.id = id;
    return result;
  }

  CommentDeleteRequest._();

  factory CommentDeleteRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CommentDeleteRequest()..mergeFromBuffer(data, registry);
  factory CommentDeleteRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CommentDeleteRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CommentDeleteRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.comments'),
      createEmptyInstance: CommentDeleteRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..aOS(3, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CommentDeleteRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CommentDeleteRequest copyWith(void Function(CommentDeleteRequest) updates) =>
      super.copyWith((message) => updates(message as CommentDeleteRequest))
          as CommentDeleteRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use CommentDeleteRequest() / CommentDeleteRequest.new instead')
  static CommentDeleteRequest create() => CommentDeleteRequest._();
  static $pb.GeneratedMessage $_createMessage() => CommentDeleteRequest._();
  @$core.override
  CommentDeleteRequest createEmptyInstance() => CommentDeleteRequest._();
  @$core.pragma('dart2js:noInline')
  static CommentDeleteRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CommentDeleteRequest>(
          CommentDeleteRequest.$_createMessage);
  static CommentDeleteRequest? _defaultInstance;

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

class CommentEditRequest extends $pb.GeneratedMessage {
  factory CommentEditRequest({
    $core.String? workspaceId,
    $core.String? projectId,
    $core.String? id,
    $core.int? expectedVersion,
    $core.String? body,
    $core.bool? grantAccess,
  }) {
    final result = CommentEditRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (projectId != null) result.projectId = projectId;
    if (id != null) result.id = id;
    if (expectedVersion != null) result.expectedVersion = expectedVersion;
    if (body != null) result.body = body;
    if (grantAccess != null) result.grantAccess = grantAccess;
    return result;
  }

  CommentEditRequest._();

  factory CommentEditRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CommentEditRequest()..mergeFromBuffer(data, registry);
  factory CommentEditRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CommentEditRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CommentEditRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.comments'),
      createEmptyInstance: CommentEditRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..aOS(3, _omitFieldNames ? '' : 'id')
    ..aI(4, _omitFieldNames ? '' : 'expectedVersion')
    ..aOS(5, _omitFieldNames ? '' : 'body')
    ..aOB(6, _omitFieldNames ? '' : 'grantAccess')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CommentEditRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CommentEditRequest copyWith(void Function(CommentEditRequest) updates) =>
      super.copyWith((message) => updates(message as CommentEditRequest))
          as CommentEditRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CommentEditRequest() / CommentEditRequest.new instead')
  static CommentEditRequest create() => CommentEditRequest._();
  static $pb.GeneratedMessage $_createMessage() => CommentEditRequest._();
  @$core.override
  CommentEditRequest createEmptyInstance() => CommentEditRequest._();
  @$core.pragma('dart2js:noInline')
  static CommentEditRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CommentEditRequest>(
          CommentEditRequest.$_createMessage);
  static CommentEditRequest? _defaultInstance;

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
  $core.String get body => $_getSZ(4);
  @$pb.TagNumber(5)
  set body($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasBody() => $_has(4);
  @$pb.TagNumber(5)
  void clearBody() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.bool get grantAccess => $_getBF(5);
  @$pb.TagNumber(6)
  set grantAccess($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasGrantAccess() => $_has(5);
  @$pb.TagNumber(6)
  void clearGrantAccess() => $_clearField(6);
}

class CommentHistory extends $pb.GeneratedMessage {
  factory CommentHistory({
    $core.Iterable<CommentRevision>? revisions,
  }) {
    final result = CommentHistory._();
    if (revisions != null) result.revisions.addAll(revisions);
    return result;
  }

  CommentHistory._();

  factory CommentHistory.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CommentHistory()..mergeFromBuffer(data, registry);
  factory CommentHistory.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CommentHistory()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CommentHistory',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.comments'),
      createEmptyInstance: CommentHistory.$_createMessage)
    ..pPM<CommentRevision>(1, _omitFieldNames ? '' : 'revisions',
        subBuilder: CommentRevision.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CommentHistory clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CommentHistory copyWith(void Function(CommentHistory) updates) =>
      super.copyWith((message) => updates(message as CommentHistory))
          as CommentHistory;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CommentHistory() / CommentHistory.new instead')
  static CommentHistory create() => CommentHistory._();
  static $pb.GeneratedMessage $_createMessage() => CommentHistory._();
  @$core.override
  CommentHistory createEmptyInstance() => CommentHistory._();
  @$core.pragma('dart2js:noInline')
  static CommentHistory getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CommentHistory>(
          CommentHistory.$_createMessage);
  static CommentHistory? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<CommentRevision> get revisions => $_getList(0);
}

class CommentHistoryRequest extends $pb.GeneratedMessage {
  factory CommentHistoryRequest({
    $core.String? workspaceId,
    $core.String? projectId,
    $core.String? id,
  }) {
    final result = CommentHistoryRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (projectId != null) result.projectId = projectId;
    if (id != null) result.id = id;
    return result;
  }

  CommentHistoryRequest._();

  factory CommentHistoryRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CommentHistoryRequest()..mergeFromBuffer(data, registry);
  factory CommentHistoryRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CommentHistoryRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CommentHistoryRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.comments'),
      createEmptyInstance: CommentHistoryRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..aOS(3, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CommentHistoryRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CommentHistoryRequest copyWith(
          void Function(CommentHistoryRequest) updates) =>
      super.copyWith((message) => updates(message as CommentHistoryRequest))
          as CommentHistoryRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use CommentHistoryRequest() / CommentHistoryRequest.new instead')
  static CommentHistoryRequest create() => CommentHistoryRequest._();
  static $pb.GeneratedMessage $_createMessage() => CommentHistoryRequest._();
  @$core.override
  CommentHistoryRequest createEmptyInstance() => CommentHistoryRequest._();
  @$core.pragma('dart2js:noInline')
  static CommentHistoryRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CommentHistoryRequest>(
          CommentHistoryRequest.$_createMessage);
  static CommentHistoryRequest? _defaultInstance;

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

class CommentListRequest extends $pb.GeneratedMessage {
  factory CommentListRequest({
    $core.String? workspaceId,
    $core.String? projectId,
    $core.String? taskId,
    $core.String? before,
    $core.int? pageSize,
  }) {
    final result = CommentListRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (projectId != null) result.projectId = projectId;
    if (taskId != null) result.taskId = taskId;
    if (before != null) result.before = before;
    if (pageSize != null) result.pageSize = pageSize;
    return result;
  }

  CommentListRequest._();

  factory CommentListRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CommentListRequest()..mergeFromBuffer(data, registry);
  factory CommentListRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CommentListRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CommentListRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.comments'),
      createEmptyInstance: CommentListRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..aOS(3, _omitFieldNames ? '' : 'taskId')
    ..aOS(4, _omitFieldNames ? '' : 'before')
    ..aI(5, _omitFieldNames ? '' : 'pageSize')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CommentListRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CommentListRequest copyWith(void Function(CommentListRequest) updates) =>
      super.copyWith((message) => updates(message as CommentListRequest))
          as CommentListRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CommentListRequest() / CommentListRequest.new instead')
  static CommentListRequest create() => CommentListRequest._();
  static $pb.GeneratedMessage $_createMessage() => CommentListRequest._();
  @$core.override
  CommentListRequest createEmptyInstance() => CommentListRequest._();
  @$core.pragma('dart2js:noInline')
  static CommentListRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CommentListRequest>(
          CommentListRequest.$_createMessage);
  static CommentListRequest? _defaultInstance;

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
  $core.String get before => $_getSZ(3);
  @$pb.TagNumber(4)
  set before($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasBefore() => $_has(3);
  @$pb.TagNumber(4)
  void clearBefore() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get pageSize => $_getIZ(4);
  @$pb.TagNumber(5)
  set pageSize($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasPageSize() => $_has(4);
  @$pb.TagNumber(5)
  void clearPageSize() => $_clearField(5);
}

class CommentMentionable extends $pb.GeneratedMessage {
  factory CommentMentionable({
    $core.Iterable<Mentionable>? people,
  }) {
    final result = CommentMentionable._();
    if (people != null) result.people.addAll(people);
    return result;
  }

  CommentMentionable._();

  factory CommentMentionable.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CommentMentionable()..mergeFromBuffer(data, registry);
  factory CommentMentionable.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CommentMentionable()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CommentMentionable',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.comments'),
      createEmptyInstance: CommentMentionable.$_createMessage)
    ..pPM<Mentionable>(1, _omitFieldNames ? '' : 'people',
        subBuilder: Mentionable.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CommentMentionable clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CommentMentionable copyWith(void Function(CommentMentionable) updates) =>
      super.copyWith((message) => updates(message as CommentMentionable))
          as CommentMentionable;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CommentMentionable() / CommentMentionable.new instead')
  static CommentMentionable create() => CommentMentionable._();
  static $pb.GeneratedMessage $_createMessage() => CommentMentionable._();
  @$core.override
  CommentMentionable createEmptyInstance() => CommentMentionable._();
  @$core.pragma('dart2js:noInline')
  static CommentMentionable getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CommentMentionable>(
          CommentMentionable.$_createMessage);
  static CommentMentionable? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Mentionable> get people => $_getList(0);
}

class CommentMentionableRequest extends $pb.GeneratedMessage {
  factory CommentMentionableRequest({
    $core.String? workspaceId,
    $core.String? projectId,
    $core.String? taskId,
    $core.String? query,
  }) {
    final result = CommentMentionableRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (projectId != null) result.projectId = projectId;
    if (taskId != null) result.taskId = taskId;
    if (query != null) result.query = query;
    return result;
  }

  CommentMentionableRequest._();

  factory CommentMentionableRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CommentMentionableRequest()..mergeFromBuffer(data, registry);
  factory CommentMentionableRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CommentMentionableRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CommentMentionableRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.comments'),
      createEmptyInstance: CommentMentionableRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..aOS(3, _omitFieldNames ? '' : 'taskId')
    ..aOS(4, _omitFieldNames ? '' : 'query')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CommentMentionableRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CommentMentionableRequest copyWith(
          void Function(CommentMentionableRequest) updates) =>
      super.copyWith((message) => updates(message as CommentMentionableRequest))
          as CommentMentionableRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use CommentMentionableRequest() / CommentMentionableRequest.new instead')
  static CommentMentionableRequest create() => CommentMentionableRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      CommentMentionableRequest._();
  @$core.override
  CommentMentionableRequest createEmptyInstance() =>
      CommentMentionableRequest._();
  @$core.pragma('dart2js:noInline')
  static CommentMentionableRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CommentMentionableRequest>(
          CommentMentionableRequest.$_createMessage);
  static CommentMentionableRequest? _defaultInstance;

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
  $core.String get query => $_getSZ(3);
  @$pb.TagNumber(4)
  set query($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasQuery() => $_has(3);
  @$pb.TagNumber(4)
  void clearQuery() => $_clearField(4);
}

class CommentPage extends $pb.GeneratedMessage {
  factory CommentPage({
    $core.Iterable<Comment>? comments,
    $core.String? cursor,
  }) {
    final result = CommentPage._();
    if (comments != null) result.comments.addAll(comments);
    if (cursor != null) result.cursor = cursor;
    return result;
  }

  CommentPage._();

  factory CommentPage.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CommentPage()..mergeFromBuffer(data, registry);
  factory CommentPage.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CommentPage()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CommentPage',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.comments'),
      createEmptyInstance: CommentPage.$_createMessage)
    ..pPM<Comment>(1, _omitFieldNames ? '' : 'comments',
        subBuilder: Comment.$_createMessage)
    ..aOS(2, _omitFieldNames ? '' : 'cursor')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CommentPage clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CommentPage copyWith(void Function(CommentPage) updates) =>
      super.copyWith((message) => updates(message as CommentPage))
          as CommentPage;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CommentPage() / CommentPage.new instead')
  static CommentPage create() => CommentPage._();
  static $pb.GeneratedMessage $_createMessage() => CommentPage._();
  @$core.override
  CommentPage createEmptyInstance() => CommentPage._();
  @$core.pragma('dart2js:noInline')
  static CommentPage getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CommentPage>(
          CommentPage.$_createMessage);
  static CommentPage? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Comment> get comments => $_getList(0);

  @$pb.TagNumber(2)
  $core.String get cursor => $_getSZ(1);
  @$pb.TagNumber(2)
  set cursor($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCursor() => $_has(1);
  @$pb.TagNumber(2)
  void clearCursor() => $_clearField(2);
}

class CommentPinRequest extends $pb.GeneratedMessage {
  factory CommentPinRequest({
    $core.String? workspaceId,
    $core.String? projectId,
    $core.String? id,
    $core.bool? pinned,
  }) {
    final result = CommentPinRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (projectId != null) result.projectId = projectId;
    if (id != null) result.id = id;
    if (pinned != null) result.pinned = pinned;
    return result;
  }

  CommentPinRequest._();

  factory CommentPinRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CommentPinRequest()..mergeFromBuffer(data, registry);
  factory CommentPinRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CommentPinRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CommentPinRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.comments'),
      createEmptyInstance: CommentPinRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..aOS(3, _omitFieldNames ? '' : 'id')
    ..aOB(4, _omitFieldNames ? '' : 'pinned')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CommentPinRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CommentPinRequest copyWith(void Function(CommentPinRequest) updates) =>
      super.copyWith((message) => updates(message as CommentPinRequest))
          as CommentPinRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CommentPinRequest() / CommentPinRequest.new instead')
  static CommentPinRequest create() => CommentPinRequest._();
  static $pb.GeneratedMessage $_createMessage() => CommentPinRequest._();
  @$core.override
  CommentPinRequest createEmptyInstance() => CommentPinRequest._();
  @$core.pragma('dart2js:noInline')
  static CommentPinRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CommentPinRequest>(
          CommentPinRequest.$_createMessage);
  static CommentPinRequest? _defaultInstance;

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
  $core.bool get pinned => $_getBF(3);
  @$pb.TagNumber(4)
  set pinned($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasPinned() => $_has(3);
  @$pb.TagNumber(4)
  void clearPinned() => $_clearField(4);
}

class CommentReactRequest extends $pb.GeneratedMessage {
  factory CommentReactRequest({
    $core.String? workspaceId,
    $core.String? projectId,
    $core.String? id,
    $core.String? emoji,
    $core.bool? on,
  }) {
    final result = CommentReactRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (projectId != null) result.projectId = projectId;
    if (id != null) result.id = id;
    if (emoji != null) result.emoji = emoji;
    if (on != null) result.on = on;
    return result;
  }

  CommentReactRequest._();

  factory CommentReactRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CommentReactRequest()..mergeFromBuffer(data, registry);
  factory CommentReactRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CommentReactRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CommentReactRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.comments'),
      createEmptyInstance: CommentReactRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..aOS(3, _omitFieldNames ? '' : 'id')
    ..aOS(4, _omitFieldNames ? '' : 'emoji')
    ..aOB(5, _omitFieldNames ? '' : 'on')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CommentReactRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CommentReactRequest copyWith(void Function(CommentReactRequest) updates) =>
      super.copyWith((message) => updates(message as CommentReactRequest))
          as CommentReactRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core
      .Deprecated('Use CommentReactRequest() / CommentReactRequest.new instead')
  static CommentReactRequest create() => CommentReactRequest._();
  static $pb.GeneratedMessage $_createMessage() => CommentReactRequest._();
  @$core.override
  CommentReactRequest createEmptyInstance() => CommentReactRequest._();
  @$core.pragma('dart2js:noInline')
  static CommentReactRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CommentReactRequest>(
          CommentReactRequest.$_createMessage);
  static CommentReactRequest? _defaultInstance;

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
  $core.String get emoji => $_getSZ(3);
  @$pb.TagNumber(4)
  set emoji($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasEmoji() => $_has(3);
  @$pb.TagNumber(4)
  void clearEmoji() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.bool get on => $_getBF(4);
  @$pb.TagNumber(5)
  set on($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasOn() => $_has(4);
  @$pb.TagNumber(5)
  void clearOn() => $_clearField(5);
}

class CommentRevision extends $pb.GeneratedMessage {
  factory CommentRevision({
    $core.String? body,
    $core.String? at,
    $core.bool? current,
  }) {
    final result = CommentRevision._();
    if (body != null) result.body = body;
    if (at != null) result.at = at;
    if (current != null) result.current = current;
    return result;
  }

  CommentRevision._();

  factory CommentRevision.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CommentRevision()..mergeFromBuffer(data, registry);
  factory CommentRevision.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CommentRevision()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CommentRevision',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.comments'),
      createEmptyInstance: CommentRevision.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'body')
    ..aOS(2, _omitFieldNames ? '' : 'at')
    ..aOB(3, _omitFieldNames ? '' : 'current')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CommentRevision clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CommentRevision copyWith(void Function(CommentRevision) updates) =>
      super.copyWith((message) => updates(message as CommentRevision))
          as CommentRevision;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CommentRevision() / CommentRevision.new instead')
  static CommentRevision create() => CommentRevision._();
  static $pb.GeneratedMessage $_createMessage() => CommentRevision._();
  @$core.override
  CommentRevision createEmptyInstance() => CommentRevision._();
  @$core.pragma('dart2js:noInline')
  static CommentRevision getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CommentRevision>(
          CommentRevision.$_createMessage);
  static CommentRevision? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get body => $_getSZ(0);
  @$pb.TagNumber(1)
  set body($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasBody() => $_has(0);
  @$pb.TagNumber(1)
  void clearBody() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get at => $_getSZ(1);
  @$pb.TagNumber(2)
  set at($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAt() => $_has(1);
  @$pb.TagNumber(2)
  void clearAt() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get current => $_getBF(2);
  @$pb.TagNumber(3)
  set current($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasCurrent() => $_has(2);
  @$pb.TagNumber(3)
  void clearCurrent() => $_clearField(3);
}

class CommentSubtask extends $pb.GeneratedMessage {
  factory CommentSubtask({
    $core.String? taskId,
  }) {
    final result = CommentSubtask._();
    if (taskId != null) result.taskId = taskId;
    return result;
  }

  CommentSubtask._();

  factory CommentSubtask.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CommentSubtask()..mergeFromBuffer(data, registry);
  factory CommentSubtask.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CommentSubtask()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CommentSubtask',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.comments'),
      createEmptyInstance: CommentSubtask.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'taskId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CommentSubtask clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CommentSubtask copyWith(void Function(CommentSubtask) updates) =>
      super.copyWith((message) => updates(message as CommentSubtask))
          as CommentSubtask;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CommentSubtask() / CommentSubtask.new instead')
  static CommentSubtask create() => CommentSubtask._();
  static $pb.GeneratedMessage $_createMessage() => CommentSubtask._();
  @$core.override
  CommentSubtask createEmptyInstance() => CommentSubtask._();
  @$core.pragma('dart2js:noInline')
  static CommentSubtask getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CommentSubtask>(
          CommentSubtask.$_createMessage);
  static CommentSubtask? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get taskId => $_getSZ(0);
  @$pb.TagNumber(1)
  set taskId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTaskId() => $_has(0);
  @$pb.TagNumber(1)
  void clearTaskId() => $_clearField(1);
}

class CommentToSubtaskRequest extends $pb.GeneratedMessage {
  factory CommentToSubtaskRequest({
    $core.String? workspaceId,
    $core.String? projectId,
    $core.String? id,
  }) {
    final result = CommentToSubtaskRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (projectId != null) result.projectId = projectId;
    if (id != null) result.id = id;
    return result;
  }

  CommentToSubtaskRequest._();

  factory CommentToSubtaskRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CommentToSubtaskRequest()..mergeFromBuffer(data, registry);
  factory CommentToSubtaskRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CommentToSubtaskRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CommentToSubtaskRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.comments'),
      createEmptyInstance: CommentToSubtaskRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..aOS(3, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CommentToSubtaskRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CommentToSubtaskRequest copyWith(
          void Function(CommentToSubtaskRequest) updates) =>
      super.copyWith((message) => updates(message as CommentToSubtaskRequest))
          as CommentToSubtaskRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use CommentToSubtaskRequest() / CommentToSubtaskRequest.new instead')
  static CommentToSubtaskRequest create() => CommentToSubtaskRequest._();
  static $pb.GeneratedMessage $_createMessage() => CommentToSubtaskRequest._();
  @$core.override
  CommentToSubtaskRequest createEmptyInstance() => CommentToSubtaskRequest._();
  @$core.pragma('dart2js:noInline')
  static CommentToSubtaskRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CommentToSubtaskRequest>(
          CommentToSubtaskRequest.$_createMessage);
  static CommentToSubtaskRequest? _defaultInstance;

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

class Mentionable extends $pb.GeneratedMessage {
  factory Mentionable({
    $core.String? userId,
    $core.String? displayName,
  }) {
    final result = Mentionable._();
    if (userId != null) result.userId = userId;
    if (displayName != null) result.displayName = displayName;
    return result;
  }

  Mentionable._();

  factory Mentionable.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Mentionable()..mergeFromBuffer(data, registry);
  factory Mentionable.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Mentionable()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Mentionable',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.comments'),
      createEmptyInstance: Mentionable.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'userId')
    ..aOS(2, _omitFieldNames ? '' : 'displayName')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Mentionable clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Mentionable copyWith(void Function(Mentionable) updates) =>
      super.copyWith((message) => updates(message as Mentionable))
          as Mentionable;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Mentionable() / Mentionable.new instead')
  static Mentionable create() => Mentionable._();
  static $pb.GeneratedMessage $_createMessage() => Mentionable._();
  @$core.override
  Mentionable createEmptyInstance() => Mentionable._();
  @$core.pragma('dart2js:noInline')
  static Mentionable getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Mentionable>(
          Mentionable.$_createMessage);
  static Mentionable? _defaultInstance;

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
}

class Reaction extends $pb.GeneratedMessage {
  factory Reaction({
    $core.String? emoji,
    $core.Iterable<$core.String>? userIds,
  }) {
    final result = Reaction._();
    if (emoji != null) result.emoji = emoji;
    if (userIds != null) result.userIds.addAll(userIds);
    return result;
  }

  Reaction._();

  factory Reaction.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Reaction()..mergeFromBuffer(data, registry);
  factory Reaction.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Reaction()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Reaction',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.comments'),
      createEmptyInstance: Reaction.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'emoji')
    ..pPS(2, _omitFieldNames ? '' : 'userIds')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Reaction clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Reaction copyWith(void Function(Reaction) updates) =>
      super.copyWith((message) => updates(message as Reaction)) as Reaction;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Reaction() / Reaction.new instead')
  static Reaction create() => Reaction._();
  static $pb.GeneratedMessage $_createMessage() => Reaction._();
  @$core.override
  Reaction createEmptyInstance() => Reaction._();
  @$core.pragma('dart2js:noInline')
  static Reaction getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Reaction>(Reaction.$_createMessage);
  static Reaction? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get emoji => $_getSZ(0);
  @$pb.TagNumber(1)
  set emoji($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasEmoji() => $_has(0);
  @$pb.TagNumber(1)
  void clearEmoji() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<$core.String> get userIds => $_getList(1);
}

class ReactionResponse extends $pb.GeneratedMessage {
  factory ReactionResponse({
    $core.String? emoji,
    $core.Iterable<$core.String>? userIds,
  }) {
    final result = ReactionResponse._();
    if (emoji != null) result.emoji = emoji;
    if (userIds != null) result.userIds.addAll(userIds);
    return result;
  }

  ReactionResponse._();

  factory ReactionResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ReactionResponse()..mergeFromBuffer(data, registry);
  factory ReactionResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ReactionResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ReactionResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.comments'),
      createEmptyInstance: ReactionResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'emoji')
    ..pPS(2, _omitFieldNames ? '' : 'userIds')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReactionResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReactionResponse copyWith(void Function(ReactionResponse) updates) =>
      super.copyWith((message) => updates(message as ReactionResponse))
          as ReactionResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ReactionResponse() / ReactionResponse.new instead')
  static ReactionResponse create() => ReactionResponse._();
  static $pb.GeneratedMessage $_createMessage() => ReactionResponse._();
  @$core.override
  ReactionResponse createEmptyInstance() => ReactionResponse._();
  @$core.pragma('dart2js:noInline')
  static ReactionResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ReactionResponse>(
          ReactionResponse.$_createMessage);
  static ReactionResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get emoji => $_getSZ(0);
  @$pb.TagNumber(1)
  set emoji($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasEmoji() => $_has(0);
  @$pb.TagNumber(1)
  void clearEmoji() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<$core.String> get userIds => $_getList(1);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
