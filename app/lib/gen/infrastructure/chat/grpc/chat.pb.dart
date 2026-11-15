// This is a generated file - do not edit.
//
// Generated from infrastructure/chat/grpc/chat.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class ChatAddMembersRequest extends $pb.GeneratedMessage {
  factory ChatAddMembersRequest({
    $core.String? workspaceId,
    $core.String? spaceId,
    $core.Iterable<$core.String>? userIds,
  }) {
    final result = ChatAddMembersRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (spaceId != null) result.spaceId = spaceId;
    if (userIds != null) result.userIds.addAll(userIds);
    return result;
  }

  ChatAddMembersRequest._();

  factory ChatAddMembersRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ChatAddMembersRequest()..mergeFromBuffer(data, registry);
  factory ChatAddMembersRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ChatAddMembersRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ChatAddMembersRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.chat'),
      createEmptyInstance: ChatAddMembersRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'spaceId')
    ..pPS(3, _omitFieldNames ? '' : 'userIds')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChatAddMembersRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChatAddMembersRequest copyWith(
          void Function(ChatAddMembersRequest) updates) =>
      super.copyWith((message) => updates(message as ChatAddMembersRequest))
          as ChatAddMembersRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ChatAddMembersRequest() / ChatAddMembersRequest.new instead')
  static ChatAddMembersRequest create() => ChatAddMembersRequest._();
  static $pb.GeneratedMessage $_createMessage() => ChatAddMembersRequest._();
  @$core.override
  ChatAddMembersRequest createEmptyInstance() => ChatAddMembersRequest._();
  @$core.pragma('dart2js:noInline')
  static ChatAddMembersRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ChatAddMembersRequest>(
          ChatAddMembersRequest.$_createMessage);
  static ChatAddMembersRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get spaceId => $_getSZ(1);
  @$pb.TagNumber(2)
  set spaceId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSpaceId() => $_has(1);
  @$pb.TagNumber(2)
  void clearSpaceId() => $_clearField(2);

  @$pb.TagNumber(3)
  $pb.PbList<$core.String> get userIds => $_getList(2);
}

class ChatCreateSpaceRequest extends $pb.GeneratedMessage {
  factory ChatCreateSpaceRequest({
    $core.String? workspaceId,
    $core.String? kind,
    $core.String? name,
    $core.Iterable<$core.String>? memberIds,
  }) {
    final result = ChatCreateSpaceRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (kind != null) result.kind = kind;
    if (name != null) result.name = name;
    if (memberIds != null) result.memberIds.addAll(memberIds);
    return result;
  }

  ChatCreateSpaceRequest._();

  factory ChatCreateSpaceRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ChatCreateSpaceRequest()..mergeFromBuffer(data, registry);
  factory ChatCreateSpaceRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ChatCreateSpaceRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ChatCreateSpaceRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.chat'),
      createEmptyInstance: ChatCreateSpaceRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'kind')
    ..aOS(3, _omitFieldNames ? '' : 'name')
    ..pPS(4, _omitFieldNames ? '' : 'memberIds')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChatCreateSpaceRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChatCreateSpaceRequest copyWith(
          void Function(ChatCreateSpaceRequest) updates) =>
      super.copyWith((message) => updates(message as ChatCreateSpaceRequest))
          as ChatCreateSpaceRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ChatCreateSpaceRequest() / ChatCreateSpaceRequest.new instead')
  static ChatCreateSpaceRequest create() => ChatCreateSpaceRequest._();
  static $pb.GeneratedMessage $_createMessage() => ChatCreateSpaceRequest._();
  @$core.override
  ChatCreateSpaceRequest createEmptyInstance() => ChatCreateSpaceRequest._();
  @$core.pragma('dart2js:noInline')
  static ChatCreateSpaceRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ChatCreateSpaceRequest>(
          ChatCreateSpaceRequest.$_createMessage);
  static ChatCreateSpaceRequest? _defaultInstance;

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
  $pb.PbList<$core.String> get memberIds => $_getList(3);
}

class ChatDeleteRequest extends $pb.GeneratedMessage {
  factory ChatDeleteRequest({
    $core.String? workspaceId,
    $core.String? spaceId,
    $core.String? id,
  }) {
    final result = ChatDeleteRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (spaceId != null) result.spaceId = spaceId;
    if (id != null) result.id = id;
    return result;
  }

  ChatDeleteRequest._();

  factory ChatDeleteRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ChatDeleteRequest()..mergeFromBuffer(data, registry);
  factory ChatDeleteRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ChatDeleteRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ChatDeleteRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.chat'),
      createEmptyInstance: ChatDeleteRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'spaceId')
    ..aOS(3, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChatDeleteRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChatDeleteRequest copyWith(void Function(ChatDeleteRequest) updates) =>
      super.copyWith((message) => updates(message as ChatDeleteRequest))
          as ChatDeleteRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ChatDeleteRequest() / ChatDeleteRequest.new instead')
  static ChatDeleteRequest create() => ChatDeleteRequest._();
  static $pb.GeneratedMessage $_createMessage() => ChatDeleteRequest._();
  @$core.override
  ChatDeleteRequest createEmptyInstance() => ChatDeleteRequest._();
  @$core.pragma('dart2js:noInline')
  static ChatDeleteRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ChatDeleteRequest>(
          ChatDeleteRequest.$_createMessage);
  static ChatDeleteRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get spaceId => $_getSZ(1);
  @$pb.TagNumber(2)
  set spaceId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSpaceId() => $_has(1);
  @$pb.TagNumber(2)
  void clearSpaceId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get id => $_getSZ(2);
  @$pb.TagNumber(3)
  set id($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasId() => $_has(2);
  @$pb.TagNumber(3)
  void clearId() => $_clearField(3);
}

class ChatDone extends $pb.GeneratedMessage {
  factory ChatDone({
    $core.bool? ok,
  }) {
    final result = ChatDone._();
    if (ok != null) result.ok = ok;
    return result;
  }

  ChatDone._();

  factory ChatDone.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ChatDone()..mergeFromBuffer(data, registry);
  factory ChatDone.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ChatDone()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ChatDone',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.chat'),
      createEmptyInstance: ChatDone.$_createMessage)
    ..aOB(1, _omitFieldNames ? '' : 'ok')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChatDone clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChatDone copyWith(void Function(ChatDone) updates) =>
      super.copyWith((message) => updates(message as ChatDone)) as ChatDone;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ChatDone() / ChatDone.new instead')
  static ChatDone create() => ChatDone._();
  static $pb.GeneratedMessage $_createMessage() => ChatDone._();
  @$core.override
  ChatDone createEmptyInstance() => ChatDone._();
  @$core.pragma('dart2js:noInline')
  static ChatDone getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ChatDone>(ChatDone.$_createMessage);
  static ChatDone? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get ok => $_getBF(0);
  @$pb.TagNumber(1)
  set ok($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasOk() => $_has(0);
  @$pb.TagNumber(1)
  void clearOk() => $_clearField(1);
}

class ChatEditRequest extends $pb.GeneratedMessage {
  factory ChatEditRequest({
    $core.String? workspaceId,
    $core.String? spaceId,
    $core.String? id,
    $core.int? expectedVersion,
    $core.String? body,
    $core.bool? confirmBroadcast,
    $core.bool? grantAccess,
  }) {
    final result = ChatEditRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (spaceId != null) result.spaceId = spaceId;
    if (id != null) result.id = id;
    if (expectedVersion != null) result.expectedVersion = expectedVersion;
    if (body != null) result.body = body;
    if (confirmBroadcast != null) result.confirmBroadcast = confirmBroadcast;
    if (grantAccess != null) result.grantAccess = grantAccess;
    return result;
  }

  ChatEditRequest._();

  factory ChatEditRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ChatEditRequest()..mergeFromBuffer(data, registry);
  factory ChatEditRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ChatEditRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ChatEditRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.chat'),
      createEmptyInstance: ChatEditRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'spaceId')
    ..aOS(3, _omitFieldNames ? '' : 'id')
    ..aI(4, _omitFieldNames ? '' : 'expectedVersion')
    ..aOS(5, _omitFieldNames ? '' : 'body')
    ..aOB(6, _omitFieldNames ? '' : 'confirmBroadcast')
    ..aOB(7, _omitFieldNames ? '' : 'grantAccess')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChatEditRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChatEditRequest copyWith(void Function(ChatEditRequest) updates) =>
      super.copyWith((message) => updates(message as ChatEditRequest))
          as ChatEditRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ChatEditRequest() / ChatEditRequest.new instead')
  static ChatEditRequest create() => ChatEditRequest._();
  static $pb.GeneratedMessage $_createMessage() => ChatEditRequest._();
  @$core.override
  ChatEditRequest createEmptyInstance() => ChatEditRequest._();
  @$core.pragma('dart2js:noInline')
  static ChatEditRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ChatEditRequest>(
          ChatEditRequest.$_createMessage);
  static ChatEditRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get spaceId => $_getSZ(1);
  @$pb.TagNumber(2)
  set spaceId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSpaceId() => $_has(1);
  @$pb.TagNumber(2)
  void clearSpaceId() => $_clearField(2);

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
  $core.bool get confirmBroadcast => $_getBF(5);
  @$pb.TagNumber(6)
  set confirmBroadcast($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasConfirmBroadcast() => $_has(5);
  @$pb.TagNumber(6)
  void clearConfirmBroadcast() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.bool get grantAccess => $_getBF(6);
  @$pb.TagNumber(7)
  set grantAccess($core.bool value) => $_setBool(6, value);
  @$pb.TagNumber(7)
  $core.bool hasGrantAccess() => $_has(6);
  @$pb.TagNumber(7)
  void clearGrantAccess() => $_clearField(7);
}

class ChatJoinRequest extends $pb.GeneratedMessage {
  factory ChatJoinRequest({
    $core.String? workspaceId,
    $core.String? spaceId,
  }) {
    final result = ChatJoinRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (spaceId != null) result.spaceId = spaceId;
    return result;
  }

  ChatJoinRequest._();

  factory ChatJoinRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ChatJoinRequest()..mergeFromBuffer(data, registry);
  factory ChatJoinRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ChatJoinRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ChatJoinRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.chat'),
      createEmptyInstance: ChatJoinRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'spaceId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChatJoinRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChatJoinRequest copyWith(void Function(ChatJoinRequest) updates) =>
      super.copyWith((message) => updates(message as ChatJoinRequest))
          as ChatJoinRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ChatJoinRequest() / ChatJoinRequest.new instead')
  static ChatJoinRequest create() => ChatJoinRequest._();
  static $pb.GeneratedMessage $_createMessage() => ChatJoinRequest._();
  @$core.override
  ChatJoinRequest createEmptyInstance() => ChatJoinRequest._();
  @$core.pragma('dart2js:noInline')
  static ChatJoinRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ChatJoinRequest>(
          ChatJoinRequest.$_createMessage);
  static ChatJoinRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get spaceId => $_getSZ(1);
  @$pb.TagNumber(2)
  set spaceId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSpaceId() => $_has(1);
  @$pb.TagNumber(2)
  void clearSpaceId() => $_clearField(2);
}

class ChatLeaveRequest extends $pb.GeneratedMessage {
  factory ChatLeaveRequest({
    $core.String? workspaceId,
    $core.String? spaceId,
  }) {
    final result = ChatLeaveRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (spaceId != null) result.spaceId = spaceId;
    return result;
  }

  ChatLeaveRequest._();

  factory ChatLeaveRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ChatLeaveRequest()..mergeFromBuffer(data, registry);
  factory ChatLeaveRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ChatLeaveRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ChatLeaveRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.chat'),
      createEmptyInstance: ChatLeaveRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'spaceId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChatLeaveRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChatLeaveRequest copyWith(void Function(ChatLeaveRequest) updates) =>
      super.copyWith((message) => updates(message as ChatLeaveRequest))
          as ChatLeaveRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ChatLeaveRequest() / ChatLeaveRequest.new instead')
  static ChatLeaveRequest create() => ChatLeaveRequest._();
  static $pb.GeneratedMessage $_createMessage() => ChatLeaveRequest._();
  @$core.override
  ChatLeaveRequest createEmptyInstance() => ChatLeaveRequest._();
  @$core.pragma('dart2js:noInline')
  static ChatLeaveRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ChatLeaveRequest>(
          ChatLeaveRequest.$_createMessage);
  static ChatLeaveRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get spaceId => $_getSZ(1);
  @$pb.TagNumber(2)
  set spaceId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSpaceId() => $_has(1);
  @$pb.TagNumber(2)
  void clearSpaceId() => $_clearField(2);
}

class ChatListMessagesRequest extends $pb.GeneratedMessage {
  factory ChatListMessagesRequest({
    $core.String? workspaceId,
    $core.String? spaceId,
    $core.String? before,
    $core.int? pageSize,
    $core.String? threadId,
  }) {
    final result = ChatListMessagesRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (spaceId != null) result.spaceId = spaceId;
    if (before != null) result.before = before;
    if (pageSize != null) result.pageSize = pageSize;
    if (threadId != null) result.threadId = threadId;
    return result;
  }

  ChatListMessagesRequest._();

  factory ChatListMessagesRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ChatListMessagesRequest()..mergeFromBuffer(data, registry);
  factory ChatListMessagesRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ChatListMessagesRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ChatListMessagesRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.chat'),
      createEmptyInstance: ChatListMessagesRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'spaceId')
    ..aOS(3, _omitFieldNames ? '' : 'before')
    ..aI(4, _omitFieldNames ? '' : 'pageSize')
    ..aOS(5, _omitFieldNames ? '' : 'threadId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChatListMessagesRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChatListMessagesRequest copyWith(
          void Function(ChatListMessagesRequest) updates) =>
      super.copyWith((message) => updates(message as ChatListMessagesRequest))
          as ChatListMessagesRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ChatListMessagesRequest() / ChatListMessagesRequest.new instead')
  static ChatListMessagesRequest create() => ChatListMessagesRequest._();
  static $pb.GeneratedMessage $_createMessage() => ChatListMessagesRequest._();
  @$core.override
  ChatListMessagesRequest createEmptyInstance() => ChatListMessagesRequest._();
  @$core.pragma('dart2js:noInline')
  static ChatListMessagesRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ChatListMessagesRequest>(
          ChatListMessagesRequest.$_createMessage);
  static ChatListMessagesRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get spaceId => $_getSZ(1);
  @$pb.TagNumber(2)
  set spaceId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSpaceId() => $_has(1);
  @$pb.TagNumber(2)
  void clearSpaceId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get before => $_getSZ(2);
  @$pb.TagNumber(3)
  set before($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasBefore() => $_has(2);
  @$pb.TagNumber(3)
  void clearBefore() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get pageSize => $_getIZ(3);
  @$pb.TagNumber(4)
  set pageSize($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasPageSize() => $_has(3);
  @$pb.TagNumber(4)
  void clearPageSize() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get threadId => $_getSZ(4);
  @$pb.TagNumber(5)
  set threadId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasThreadId() => $_has(4);
  @$pb.TagNumber(5)
  void clearThreadId() => $_clearField(5);
}

class ChatListSpacesRequest extends $pb.GeneratedMessage {
  factory ChatListSpacesRequest({
    $core.String? workspaceId,
    $core.String? query,
    $core.bool? includeArchived,
  }) {
    final result = ChatListSpacesRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (query != null) result.query = query;
    if (includeArchived != null) result.includeArchived = includeArchived;
    return result;
  }

  ChatListSpacesRequest._();

  factory ChatListSpacesRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ChatListSpacesRequest()..mergeFromBuffer(data, registry);
  factory ChatListSpacesRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ChatListSpacesRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ChatListSpacesRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.chat'),
      createEmptyInstance: ChatListSpacesRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'query')
    ..aOB(3, _omitFieldNames ? '' : 'includeArchived')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChatListSpacesRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChatListSpacesRequest copyWith(
          void Function(ChatListSpacesRequest) updates) =>
      super.copyWith((message) => updates(message as ChatListSpacesRequest))
          as ChatListSpacesRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ChatListSpacesRequest() / ChatListSpacesRequest.new instead')
  static ChatListSpacesRequest create() => ChatListSpacesRequest._();
  static $pb.GeneratedMessage $_createMessage() => ChatListSpacesRequest._();
  @$core.override
  ChatListSpacesRequest createEmptyInstance() => ChatListSpacesRequest._();
  @$core.pragma('dart2js:noInline')
  static ChatListSpacesRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ChatListSpacesRequest>(
          ChatListSpacesRequest.$_createMessage);
  static ChatListSpacesRequest? _defaultInstance;

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
  $core.bool get includeArchived => $_getBF(2);
  @$pb.TagNumber(3)
  set includeArchived($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasIncludeArchived() => $_has(2);
  @$pb.TagNumber(3)
  void clearIncludeArchived() => $_clearField(3);
}

class ChatMarkReadRequest extends $pb.GeneratedMessage {
  factory ChatMarkReadRequest({
    $core.String? workspaceId,
    $core.String? spaceId,
    $core.String? messageId,
  }) {
    final result = ChatMarkReadRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (spaceId != null) result.spaceId = spaceId;
    if (messageId != null) result.messageId = messageId;
    return result;
  }

  ChatMarkReadRequest._();

  factory ChatMarkReadRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ChatMarkReadRequest()..mergeFromBuffer(data, registry);
  factory ChatMarkReadRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ChatMarkReadRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ChatMarkReadRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.chat'),
      createEmptyInstance: ChatMarkReadRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'spaceId')
    ..aOS(3, _omitFieldNames ? '' : 'messageId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChatMarkReadRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChatMarkReadRequest copyWith(void Function(ChatMarkReadRequest) updates) =>
      super.copyWith((message) => updates(message as ChatMarkReadRequest))
          as ChatMarkReadRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core
      .Deprecated('Use ChatMarkReadRequest() / ChatMarkReadRequest.new instead')
  static ChatMarkReadRequest create() => ChatMarkReadRequest._();
  static $pb.GeneratedMessage $_createMessage() => ChatMarkReadRequest._();
  @$core.override
  ChatMarkReadRequest createEmptyInstance() => ChatMarkReadRequest._();
  @$core.pragma('dart2js:noInline')
  static ChatMarkReadRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ChatMarkReadRequest>(
          ChatMarkReadRequest.$_createMessage);
  static ChatMarkReadRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get spaceId => $_getSZ(1);
  @$pb.TagNumber(2)
  set spaceId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSpaceId() => $_has(1);
  @$pb.TagNumber(2)
  void clearSpaceId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get messageId => $_getSZ(2);
  @$pb.TagNumber(3)
  set messageId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasMessageId() => $_has(2);
  @$pb.TagNumber(3)
  void clearMessageId() => $_clearField(3);
}

class ChatMentionable extends $pb.GeneratedMessage {
  factory ChatMentionable({
    $core.Iterable<Person>? people,
    $core.int? memberCount,
  }) {
    final result = ChatMentionable._();
    if (people != null) result.people.addAll(people);
    if (memberCount != null) result.memberCount = memberCount;
    return result;
  }

  ChatMentionable._();

  factory ChatMentionable.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ChatMentionable()..mergeFromBuffer(data, registry);
  factory ChatMentionable.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ChatMentionable()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ChatMentionable',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.chat'),
      createEmptyInstance: ChatMentionable.$_createMessage)
    ..pPM<Person>(1, _omitFieldNames ? '' : 'people',
        subBuilder: Person.$_createMessage)
    ..aI(2, _omitFieldNames ? '' : 'memberCount')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChatMentionable clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChatMentionable copyWith(void Function(ChatMentionable) updates) =>
      super.copyWith((message) => updates(message as ChatMentionable))
          as ChatMentionable;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ChatMentionable() / ChatMentionable.new instead')
  static ChatMentionable create() => ChatMentionable._();
  static $pb.GeneratedMessage $_createMessage() => ChatMentionable._();
  @$core.override
  ChatMentionable createEmptyInstance() => ChatMentionable._();
  @$core.pragma('dart2js:noInline')
  static ChatMentionable getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ChatMentionable>(
          ChatMentionable.$_createMessage);
  static ChatMentionable? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Person> get people => $_getList(0);

  @$pb.TagNumber(2)
  $core.int get memberCount => $_getIZ(1);
  @$pb.TagNumber(2)
  set memberCount($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMemberCount() => $_has(1);
  @$pb.TagNumber(2)
  void clearMemberCount() => $_clearField(2);
}

class ChatMentionableRequest extends $pb.GeneratedMessage {
  factory ChatMentionableRequest({
    $core.String? workspaceId,
    $core.String? spaceId,
    $core.String? query,
  }) {
    final result = ChatMentionableRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (spaceId != null) result.spaceId = spaceId;
    if (query != null) result.query = query;
    return result;
  }

  ChatMentionableRequest._();

  factory ChatMentionableRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ChatMentionableRequest()..mergeFromBuffer(data, registry);
  factory ChatMentionableRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ChatMentionableRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ChatMentionableRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.chat'),
      createEmptyInstance: ChatMentionableRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'spaceId')
    ..aOS(3, _omitFieldNames ? '' : 'query')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChatMentionableRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChatMentionableRequest copyWith(
          void Function(ChatMentionableRequest) updates) =>
      super.copyWith((message) => updates(message as ChatMentionableRequest))
          as ChatMentionableRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ChatMentionableRequest() / ChatMentionableRequest.new instead')
  static ChatMentionableRequest create() => ChatMentionableRequest._();
  static $pb.GeneratedMessage $_createMessage() => ChatMentionableRequest._();
  @$core.override
  ChatMentionableRequest createEmptyInstance() => ChatMentionableRequest._();
  @$core.pragma('dart2js:noInline')
  static ChatMentionableRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ChatMentionableRequest>(
          ChatMentionableRequest.$_createMessage);
  static ChatMentionableRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get spaceId => $_getSZ(1);
  @$pb.TagNumber(2)
  set spaceId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSpaceId() => $_has(1);
  @$pb.TagNumber(2)
  void clearSpaceId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get query => $_getSZ(2);
  @$pb.TagNumber(3)
  set query($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasQuery() => $_has(2);
  @$pb.TagNumber(3)
  void clearQuery() => $_clearField(3);
}

class ChatMessagePage extends $pb.GeneratedMessage {
  factory ChatMessagePage({
    $core.Iterable<Message>? messages,
    $core.String? cursor,
  }) {
    final result = ChatMessagePage._();
    if (messages != null) result.messages.addAll(messages);
    if (cursor != null) result.cursor = cursor;
    return result;
  }

  ChatMessagePage._();

  factory ChatMessagePage.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ChatMessagePage()..mergeFromBuffer(data, registry);
  factory ChatMessagePage.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ChatMessagePage()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ChatMessagePage',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.chat'),
      createEmptyInstance: ChatMessagePage.$_createMessage)
    ..pPM<Message>(1, _omitFieldNames ? '' : 'messages',
        subBuilder: Message.$_createMessage)
    ..aOS(2, _omitFieldNames ? '' : 'cursor')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChatMessagePage clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChatMessagePage copyWith(void Function(ChatMessagePage) updates) =>
      super.copyWith((message) => updates(message as ChatMessagePage))
          as ChatMessagePage;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ChatMessagePage() / ChatMessagePage.new instead')
  static ChatMessagePage create() => ChatMessagePage._();
  static $pb.GeneratedMessage $_createMessage() => ChatMessagePage._();
  @$core.override
  ChatMessagePage createEmptyInstance() => ChatMessagePage._();
  @$core.pragma('dart2js:noInline')
  static ChatMessagePage getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ChatMessagePage>(
          ChatMessagePage.$_createMessage);
  static ChatMessagePage? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Message> get messages => $_getList(0);

  @$pb.TagNumber(2)
  $core.String get cursor => $_getSZ(1);
  @$pb.TagNumber(2)
  set cursor($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCursor() => $_has(1);
  @$pb.TagNumber(2)
  void clearCursor() => $_clearField(2);
}

class ChatMuteRequest extends $pb.GeneratedMessage {
  factory ChatMuteRequest({
    $core.String? workspaceId,
    $core.String? spaceId,
    $core.String? until,
    $core.bool? forever,
    $core.bool? completely,
  }) {
    final result = ChatMuteRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (spaceId != null) result.spaceId = spaceId;
    if (until != null) result.until = until;
    if (forever != null) result.forever = forever;
    if (completely != null) result.completely = completely;
    return result;
  }

  ChatMuteRequest._();

  factory ChatMuteRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ChatMuteRequest()..mergeFromBuffer(data, registry);
  factory ChatMuteRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ChatMuteRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ChatMuteRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.chat'),
      createEmptyInstance: ChatMuteRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'spaceId')
    ..aOS(3, _omitFieldNames ? '' : 'until')
    ..aOB(4, _omitFieldNames ? '' : 'forever')
    ..aOB(5, _omitFieldNames ? '' : 'completely')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChatMuteRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChatMuteRequest copyWith(void Function(ChatMuteRequest) updates) =>
      super.copyWith((message) => updates(message as ChatMuteRequest))
          as ChatMuteRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ChatMuteRequest() / ChatMuteRequest.new instead')
  static ChatMuteRequest create() => ChatMuteRequest._();
  static $pb.GeneratedMessage $_createMessage() => ChatMuteRequest._();
  @$core.override
  ChatMuteRequest createEmptyInstance() => ChatMuteRequest._();
  @$core.pragma('dart2js:noInline')
  static ChatMuteRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ChatMuteRequest>(
          ChatMuteRequest.$_createMessage);
  static ChatMuteRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get spaceId => $_getSZ(1);
  @$pb.TagNumber(2)
  set spaceId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSpaceId() => $_has(1);
  @$pb.TagNumber(2)
  void clearSpaceId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get until => $_getSZ(2);
  @$pb.TagNumber(3)
  set until($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasUntil() => $_has(2);
  @$pb.TagNumber(3)
  void clearUntil() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get forever => $_getBF(3);
  @$pb.TagNumber(4)
  set forever($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasForever() => $_has(3);
  @$pb.TagNumber(4)
  void clearForever() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.bool get completely => $_getBF(4);
  @$pb.TagNumber(5)
  set completely($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasCompletely() => $_has(4);
  @$pb.TagNumber(5)
  void clearCompletely() => $_clearField(5);
}

class ChatNotifyRequest extends $pb.GeneratedMessage {
  factory ChatNotifyRequest({
    $core.String? workspaceId,
    $core.String? spaceId,
    $core.bool? allMessages,
  }) {
    final result = ChatNotifyRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (spaceId != null) result.spaceId = spaceId;
    if (allMessages != null) result.allMessages = allMessages;
    return result;
  }

  ChatNotifyRequest._();

  factory ChatNotifyRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ChatNotifyRequest()..mergeFromBuffer(data, registry);
  factory ChatNotifyRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ChatNotifyRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ChatNotifyRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.chat'),
      createEmptyInstance: ChatNotifyRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'spaceId')
    ..aOB(3, _omitFieldNames ? '' : 'allMessages')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChatNotifyRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChatNotifyRequest copyWith(void Function(ChatNotifyRequest) updates) =>
      super.copyWith((message) => updates(message as ChatNotifyRequest))
          as ChatNotifyRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ChatNotifyRequest() / ChatNotifyRequest.new instead')
  static ChatNotifyRequest create() => ChatNotifyRequest._();
  static $pb.GeneratedMessage $_createMessage() => ChatNotifyRequest._();
  @$core.override
  ChatNotifyRequest createEmptyInstance() => ChatNotifyRequest._();
  @$core.pragma('dart2js:noInline')
  static ChatNotifyRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ChatNotifyRequest>(
          ChatNotifyRequest.$_createMessage);
  static ChatNotifyRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get spaceId => $_getSZ(1);
  @$pb.TagNumber(2)
  set spaceId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSpaceId() => $_has(1);
  @$pb.TagNumber(2)
  void clearSpaceId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get allMessages => $_getBF(2);
  @$pb.TagNumber(3)
  set allMessages($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAllMessages() => $_has(2);
  @$pb.TagNumber(3)
  void clearAllMessages() => $_clearField(3);
}

class ChatOpenDmRequest extends $pb.GeneratedMessage {
  factory ChatOpenDmRequest({
    $core.String? workspaceId,
    $core.String? userId,
  }) {
    final result = ChatOpenDmRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (userId != null) result.userId = userId;
    return result;
  }

  ChatOpenDmRequest._();

  factory ChatOpenDmRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ChatOpenDmRequest()..mergeFromBuffer(data, registry);
  factory ChatOpenDmRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ChatOpenDmRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ChatOpenDmRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.chat'),
      createEmptyInstance: ChatOpenDmRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'userId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChatOpenDmRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChatOpenDmRequest copyWith(void Function(ChatOpenDmRequest) updates) =>
      super.copyWith((message) => updates(message as ChatOpenDmRequest))
          as ChatOpenDmRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ChatOpenDmRequest() / ChatOpenDmRequest.new instead')
  static ChatOpenDmRequest create() => ChatOpenDmRequest._();
  static $pb.GeneratedMessage $_createMessage() => ChatOpenDmRequest._();
  @$core.override
  ChatOpenDmRequest createEmptyInstance() => ChatOpenDmRequest._();
  @$core.pragma('dart2js:noInline')
  static ChatOpenDmRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ChatOpenDmRequest>(
          ChatOpenDmRequest.$_createMessage);
  static ChatOpenDmRequest? _defaultInstance;

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

class ChatReactRequest extends $pb.GeneratedMessage {
  factory ChatReactRequest({
    $core.String? workspaceId,
    $core.String? spaceId,
    $core.String? id,
    $core.String? emoji,
    $core.bool? on,
  }) {
    final result = ChatReactRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (spaceId != null) result.spaceId = spaceId;
    if (id != null) result.id = id;
    if (emoji != null) result.emoji = emoji;
    if (on != null) result.on = on;
    return result;
  }

  ChatReactRequest._();

  factory ChatReactRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ChatReactRequest()..mergeFromBuffer(data, registry);
  factory ChatReactRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ChatReactRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ChatReactRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.chat'),
      createEmptyInstance: ChatReactRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'spaceId')
    ..aOS(3, _omitFieldNames ? '' : 'id')
    ..aOS(4, _omitFieldNames ? '' : 'emoji')
    ..aOB(5, _omitFieldNames ? '' : 'on')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChatReactRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChatReactRequest copyWith(void Function(ChatReactRequest) updates) =>
      super.copyWith((message) => updates(message as ChatReactRequest))
          as ChatReactRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ChatReactRequest() / ChatReactRequest.new instead')
  static ChatReactRequest create() => ChatReactRequest._();
  static $pb.GeneratedMessage $_createMessage() => ChatReactRequest._();
  @$core.override
  ChatReactRequest createEmptyInstance() => ChatReactRequest._();
  @$core.pragma('dart2js:noInline')
  static ChatReactRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ChatReactRequest>(
          ChatReactRequest.$_createMessage);
  static ChatReactRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get spaceId => $_getSZ(1);
  @$pb.TagNumber(2)
  set spaceId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSpaceId() => $_has(1);
  @$pb.TagNumber(2)
  void clearSpaceId() => $_clearField(2);

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

class ChatRemoveMemberRequest extends $pb.GeneratedMessage {
  factory ChatRemoveMemberRequest({
    $core.String? workspaceId,
    $core.String? spaceId,
    $core.String? userId,
  }) {
    final result = ChatRemoveMemberRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (spaceId != null) result.spaceId = spaceId;
    if (userId != null) result.userId = userId;
    return result;
  }

  ChatRemoveMemberRequest._();

  factory ChatRemoveMemberRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ChatRemoveMemberRequest()..mergeFromBuffer(data, registry);
  factory ChatRemoveMemberRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ChatRemoveMemberRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ChatRemoveMemberRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.chat'),
      createEmptyInstance: ChatRemoveMemberRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'spaceId')
    ..aOS(3, _omitFieldNames ? '' : 'userId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChatRemoveMemberRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChatRemoveMemberRequest copyWith(
          void Function(ChatRemoveMemberRequest) updates) =>
      super.copyWith((message) => updates(message as ChatRemoveMemberRequest))
          as ChatRemoveMemberRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ChatRemoveMemberRequest() / ChatRemoveMemberRequest.new instead')
  static ChatRemoveMemberRequest create() => ChatRemoveMemberRequest._();
  static $pb.GeneratedMessage $_createMessage() => ChatRemoveMemberRequest._();
  @$core.override
  ChatRemoveMemberRequest createEmptyInstance() => ChatRemoveMemberRequest._();
  @$core.pragma('dart2js:noInline')
  static ChatRemoveMemberRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ChatRemoveMemberRequest>(
          ChatRemoveMemberRequest.$_createMessage);
  static ChatRemoveMemberRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get spaceId => $_getSZ(1);
  @$pb.TagNumber(2)
  set spaceId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSpaceId() => $_has(1);
  @$pb.TagNumber(2)
  void clearSpaceId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get userId => $_getSZ(2);
  @$pb.TagNumber(3)
  set userId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasUserId() => $_has(2);
  @$pb.TagNumber(3)
  void clearUserId() => $_clearField(3);
}

class ChatSendRequest extends $pb.GeneratedMessage {
  factory ChatSendRequest({
    $core.String? workspaceId,
    $core.String? spaceId,
    $core.String? body,
    $core.String? parentId,
    $core.String? clientId,
    $core.String? clientMutationId,
    $core.bool? confirmBroadcast,
    $core.bool? grantAccess,
  }) {
    final result = ChatSendRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (spaceId != null) result.spaceId = spaceId;
    if (body != null) result.body = body;
    if (parentId != null) result.parentId = parentId;
    if (clientId != null) result.clientId = clientId;
    if (clientMutationId != null) result.clientMutationId = clientMutationId;
    if (confirmBroadcast != null) result.confirmBroadcast = confirmBroadcast;
    if (grantAccess != null) result.grantAccess = grantAccess;
    return result;
  }

  ChatSendRequest._();

  factory ChatSendRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ChatSendRequest()..mergeFromBuffer(data, registry);
  factory ChatSendRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ChatSendRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ChatSendRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.chat'),
      createEmptyInstance: ChatSendRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'spaceId')
    ..aOS(3, _omitFieldNames ? '' : 'body')
    ..aOS(4, _omitFieldNames ? '' : 'parentId')
    ..aOS(5, _omitFieldNames ? '' : 'clientId')
    ..aOS(6, _omitFieldNames ? '' : 'clientMutationId')
    ..aOB(7, _omitFieldNames ? '' : 'confirmBroadcast')
    ..aOB(8, _omitFieldNames ? '' : 'grantAccess')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChatSendRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChatSendRequest copyWith(void Function(ChatSendRequest) updates) =>
      super.copyWith((message) => updates(message as ChatSendRequest))
          as ChatSendRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ChatSendRequest() / ChatSendRequest.new instead')
  static ChatSendRequest create() => ChatSendRequest._();
  static $pb.GeneratedMessage $_createMessage() => ChatSendRequest._();
  @$core.override
  ChatSendRequest createEmptyInstance() => ChatSendRequest._();
  @$core.pragma('dart2js:noInline')
  static ChatSendRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ChatSendRequest>(
          ChatSendRequest.$_createMessage);
  static ChatSendRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get spaceId => $_getSZ(1);
  @$pb.TagNumber(2)
  set spaceId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSpaceId() => $_has(1);
  @$pb.TagNumber(2)
  void clearSpaceId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get body => $_getSZ(2);
  @$pb.TagNumber(3)
  set body($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasBody() => $_has(2);
  @$pb.TagNumber(3)
  void clearBody() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get parentId => $_getSZ(3);
  @$pb.TagNumber(4)
  set parentId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasParentId() => $_has(3);
  @$pb.TagNumber(4)
  void clearParentId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get clientId => $_getSZ(4);
  @$pb.TagNumber(5)
  set clientId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasClientId() => $_has(4);
  @$pb.TagNumber(5)
  void clearClientId() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get clientMutationId => $_getSZ(5);
  @$pb.TagNumber(6)
  set clientMutationId($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasClientMutationId() => $_has(5);
  @$pb.TagNumber(6)
  void clearClientMutationId() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.bool get confirmBroadcast => $_getBF(6);
  @$pb.TagNumber(7)
  set confirmBroadcast($core.bool value) => $_setBool(6, value);
  @$pb.TagNumber(7)
  $core.bool hasConfirmBroadcast() => $_has(6);
  @$pb.TagNumber(7)
  void clearConfirmBroadcast() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.bool get grantAccess => $_getBF(7);
  @$pb.TagNumber(8)
  set grantAccess($core.bool value) => $_setBool(7, value);
  @$pb.TagNumber(8)
  $core.bool hasGrantAccess() => $_has(7);
  @$pb.TagNumber(8)
  void clearGrantAccess() => $_clearField(8);
}

class ChatSpaceList extends $pb.GeneratedMessage {
  factory ChatSpaceList({
    $core.Iterable<Space>? channels,
    $core.Iterable<Space>? groups,
    $core.Iterable<Space>? dms,
    $core.Iterable<TaskChat>? taskChats,
  }) {
    final result = ChatSpaceList._();
    if (channels != null) result.channels.addAll(channels);
    if (groups != null) result.groups.addAll(groups);
    if (dms != null) result.dms.addAll(dms);
    if (taskChats != null) result.taskChats.addAll(taskChats);
    return result;
  }

  ChatSpaceList._();

  factory ChatSpaceList.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ChatSpaceList()..mergeFromBuffer(data, registry);
  factory ChatSpaceList.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ChatSpaceList()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ChatSpaceList',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.chat'),
      createEmptyInstance: ChatSpaceList.$_createMessage)
    ..pPM<Space>(1, _omitFieldNames ? '' : 'channels',
        subBuilder: Space.$_createMessage)
    ..pPM<Space>(2, _omitFieldNames ? '' : 'groups',
        subBuilder: Space.$_createMessage)
    ..pPM<Space>(3, _omitFieldNames ? '' : 'dms',
        subBuilder: Space.$_createMessage)
    ..pPM<TaskChat>(4, _omitFieldNames ? '' : 'taskChats',
        subBuilder: TaskChat.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChatSpaceList clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChatSpaceList copyWith(void Function(ChatSpaceList) updates) =>
      super.copyWith((message) => updates(message as ChatSpaceList))
          as ChatSpaceList;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ChatSpaceList() / ChatSpaceList.new instead')
  static ChatSpaceList create() => ChatSpaceList._();
  static $pb.GeneratedMessage $_createMessage() => ChatSpaceList._();
  @$core.override
  ChatSpaceList createEmptyInstance() => ChatSpaceList._();
  @$core.pragma('dart2js:noInline')
  static ChatSpaceList getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ChatSpaceList>(
          ChatSpaceList.$_createMessage);
  static ChatSpaceList? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Space> get channels => $_getList(0);

  @$pb.TagNumber(2)
  $pb.PbList<Space> get groups => $_getList(1);

  @$pb.TagNumber(3)
  $pb.PbList<Space> get dms => $_getList(2);

  @$pb.TagNumber(4)
  $pb.PbList<TaskChat> get taskChats => $_getList(3);
}

class ChatUpdateSpaceRequest extends $pb.GeneratedMessage {
  factory ChatUpdateSpaceRequest({
    $core.String? workspaceId,
    $core.String? spaceId,
    $core.String? name,
    $core.bool? setArchived,
    $core.bool? archived,
  }) {
    final result = ChatUpdateSpaceRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (spaceId != null) result.spaceId = spaceId;
    if (name != null) result.name = name;
    if (setArchived != null) result.setArchived = setArchived;
    if (archived != null) result.archived = archived;
    return result;
  }

  ChatUpdateSpaceRequest._();

  factory ChatUpdateSpaceRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ChatUpdateSpaceRequest()..mergeFromBuffer(data, registry);
  factory ChatUpdateSpaceRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ChatUpdateSpaceRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ChatUpdateSpaceRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.chat'),
      createEmptyInstance: ChatUpdateSpaceRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'spaceId')
    ..aOS(3, _omitFieldNames ? '' : 'name')
    ..aOB(4, _omitFieldNames ? '' : 'setArchived')
    ..aOB(5, _omitFieldNames ? '' : 'archived')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChatUpdateSpaceRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChatUpdateSpaceRequest copyWith(
          void Function(ChatUpdateSpaceRequest) updates) =>
      super.copyWith((message) => updates(message as ChatUpdateSpaceRequest))
          as ChatUpdateSpaceRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ChatUpdateSpaceRequest() / ChatUpdateSpaceRequest.new instead')
  static ChatUpdateSpaceRequest create() => ChatUpdateSpaceRequest._();
  static $pb.GeneratedMessage $_createMessage() => ChatUpdateSpaceRequest._();
  @$core.override
  ChatUpdateSpaceRequest createEmptyInstance() => ChatUpdateSpaceRequest._();
  @$core.pragma('dart2js:noInline')
  static ChatUpdateSpaceRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ChatUpdateSpaceRequest>(
          ChatUpdateSpaceRequest.$_createMessage);
  static ChatUpdateSpaceRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get spaceId => $_getSZ(1);
  @$pb.TagNumber(2)
  set spaceId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSpaceId() => $_has(1);
  @$pb.TagNumber(2)
  void clearSpaceId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get name => $_getSZ(2);
  @$pb.TagNumber(3)
  set name($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasName() => $_has(2);
  @$pb.TagNumber(3)
  void clearName() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get setArchived => $_getBF(3);
  @$pb.TagNumber(4)
  set setArchived($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSetArchived() => $_has(3);
  @$pb.TagNumber(4)
  void clearSetArchived() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.bool get archived => $_getBF(4);
  @$pb.TagNumber(5)
  set archived($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasArchived() => $_has(4);
  @$pb.TagNumber(5)
  void clearArchived() => $_clearField(5);
}

class Message extends $pb.GeneratedMessage {
  factory Message({
    $core.String? id,
    $core.String? spaceId,
    $core.String? authorId,
    $core.String? authorName,
    $core.String? parentId,
    $core.String? body,
    $core.String? createdAt,
    $core.String? editedAt,
    $core.bool? deleted,
    $core.int? version,
    $core.Iterable<ReactionResponse>? reactions,
  }) {
    final result = Message._();
    if (id != null) result.id = id;
    if (spaceId != null) result.spaceId = spaceId;
    if (authorId != null) result.authorId = authorId;
    if (authorName != null) result.authorName = authorName;
    if (parentId != null) result.parentId = parentId;
    if (body != null) result.body = body;
    if (createdAt != null) result.createdAt = createdAt;
    if (editedAt != null) result.editedAt = editedAt;
    if (deleted != null) result.deleted = deleted;
    if (version != null) result.version = version;
    if (reactions != null) result.reactions.addAll(reactions);
    return result;
  }

  Message._();

  factory Message.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Message()..mergeFromBuffer(data, registry);
  factory Message.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Message()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Message',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.chat'),
      createEmptyInstance: Message.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'spaceId')
    ..aOS(3, _omitFieldNames ? '' : 'authorId')
    ..aOS(4, _omitFieldNames ? '' : 'authorName')
    ..aOS(5, _omitFieldNames ? '' : 'parentId')
    ..aOS(6, _omitFieldNames ? '' : 'body')
    ..aOS(7, _omitFieldNames ? '' : 'createdAt')
    ..aOS(8, _omitFieldNames ? '' : 'editedAt')
    ..aOB(9, _omitFieldNames ? '' : 'deleted')
    ..aI(10, _omitFieldNames ? '' : 'version')
    ..pPM<ReactionResponse>(11, _omitFieldNames ? '' : 'reactions',
        subBuilder: ReactionResponse.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Message clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Message copyWith(void Function(Message) updates) =>
      super.copyWith((message) => updates(message as Message)) as Message;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Message() / Message.new instead')
  static Message create() => Message._();
  static $pb.GeneratedMessage $_createMessage() => Message._();
  @$core.override
  Message createEmptyInstance() => Message._();
  @$core.pragma('dart2js:noInline')
  static Message getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Message>(Message.$_createMessage);
  static Message? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get spaceId => $_getSZ(1);
  @$pb.TagNumber(2)
  set spaceId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSpaceId() => $_has(1);
  @$pb.TagNumber(2)
  void clearSpaceId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get authorId => $_getSZ(2);
  @$pb.TagNumber(3)
  set authorId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAuthorId() => $_has(2);
  @$pb.TagNumber(3)
  void clearAuthorId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get authorName => $_getSZ(3);
  @$pb.TagNumber(4)
  set authorName($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasAuthorName() => $_has(3);
  @$pb.TagNumber(4)
  void clearAuthorName() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get parentId => $_getSZ(4);
  @$pb.TagNumber(5)
  set parentId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasParentId() => $_has(4);
  @$pb.TagNumber(5)
  void clearParentId() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get body => $_getSZ(5);
  @$pb.TagNumber(6)
  set body($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasBody() => $_has(5);
  @$pb.TagNumber(6)
  void clearBody() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get createdAt => $_getSZ(6);
  @$pb.TagNumber(7)
  set createdAt($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasCreatedAt() => $_has(6);
  @$pb.TagNumber(7)
  void clearCreatedAt() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get editedAt => $_getSZ(7);
  @$pb.TagNumber(8)
  set editedAt($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasEditedAt() => $_has(7);
  @$pb.TagNumber(8)
  void clearEditedAt() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.bool get deleted => $_getBF(8);
  @$pb.TagNumber(9)
  set deleted($core.bool value) => $_setBool(8, value);
  @$pb.TagNumber(9)
  $core.bool hasDeleted() => $_has(8);
  @$pb.TagNumber(9)
  void clearDeleted() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.int get version => $_getIZ(9);
  @$pb.TagNumber(10)
  set version($core.int value) => $_setSignedInt32(9, value);
  @$pb.TagNumber(10)
  $core.bool hasVersion() => $_has(9);
  @$pb.TagNumber(10)
  void clearVersion() => $_clearField(10);

  @$pb.TagNumber(11)
  $pb.PbList<ReactionResponse> get reactions => $_getList(10);
}

class Person extends $pb.GeneratedMessage {
  factory Person({
    $core.String? userId,
    $core.String? displayName,
  }) {
    final result = Person._();
    if (userId != null) result.userId = userId;
    if (displayName != null) result.displayName = displayName;
    return result;
  }

  Person._();

  factory Person.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Person()..mergeFromBuffer(data, registry);
  factory Person.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Person()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Person',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.chat'),
      createEmptyInstance: Person.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'userId')
    ..aOS(2, _omitFieldNames ? '' : 'displayName')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Person clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Person copyWith(void Function(Person) updates) =>
      super.copyWith((message) => updates(message as Person)) as Person;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Person() / Person.new instead')
  static Person create() => Person._();
  static $pb.GeneratedMessage $_createMessage() => Person._();
  @$core.override
  Person createEmptyInstance() => Person._();
  @$core.pragma('dart2js:noInline')
  static Person getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Person>(Person.$_createMessage);
  static Person? _defaultInstance;

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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.chat'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.chat'),
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

class Space extends $pb.GeneratedMessage {
  factory Space({
    $core.String? id,
    $core.String? kind,
    $core.String? name,
    $core.String? projectId,
    $core.bool? isDefault,
    $core.bool? archived,
    $core.bool? joined,
    $core.String? role,
    $core.int? unreadCount,
    $core.String? lastMessageAt,
    $core.String? lastReadAt,
    $core.int? memberCount,
    $core.String? mutedUntil,
    $core.bool? mutedCompletely,
    $core.bool? notifyAll,
    $core.bool? readOnly,
    $core.String? peerId,
    $core.int? version,
    $core.String? createdAt,
    $core.String? createdBy,
  }) {
    final result = Space._();
    if (id != null) result.id = id;
    if (kind != null) result.kind = kind;
    if (name != null) result.name = name;
    if (projectId != null) result.projectId = projectId;
    if (isDefault != null) result.isDefault = isDefault;
    if (archived != null) result.archived = archived;
    if (joined != null) result.joined = joined;
    if (role != null) result.role = role;
    if (unreadCount != null) result.unreadCount = unreadCount;
    if (lastMessageAt != null) result.lastMessageAt = lastMessageAt;
    if (lastReadAt != null) result.lastReadAt = lastReadAt;
    if (memberCount != null) result.memberCount = memberCount;
    if (mutedUntil != null) result.mutedUntil = mutedUntil;
    if (mutedCompletely != null) result.mutedCompletely = mutedCompletely;
    if (notifyAll != null) result.notifyAll = notifyAll;
    if (readOnly != null) result.readOnly = readOnly;
    if (peerId != null) result.peerId = peerId;
    if (version != null) result.version = version;
    if (createdAt != null) result.createdAt = createdAt;
    if (createdBy != null) result.createdBy = createdBy;
    return result;
  }

  Space._();

  factory Space.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Space()..mergeFromBuffer(data, registry);
  factory Space.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Space()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Space',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.chat'),
      createEmptyInstance: Space.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'kind')
    ..aOS(3, _omitFieldNames ? '' : 'name')
    ..aOS(4, _omitFieldNames ? '' : 'projectId')
    ..aOB(5, _omitFieldNames ? '' : 'isDefault')
    ..aOB(6, _omitFieldNames ? '' : 'archived')
    ..aOB(7, _omitFieldNames ? '' : 'joined')
    ..aOS(8, _omitFieldNames ? '' : 'role')
    ..aI(9, _omitFieldNames ? '' : 'unreadCount')
    ..aOS(10, _omitFieldNames ? '' : 'lastMessageAt')
    ..aOS(11, _omitFieldNames ? '' : 'lastReadAt')
    ..aI(12, _omitFieldNames ? '' : 'memberCount')
    ..aOS(13, _omitFieldNames ? '' : 'mutedUntil')
    ..aOB(14, _omitFieldNames ? '' : 'mutedCompletely')
    ..aOB(15, _omitFieldNames ? '' : 'notifyAll')
    ..aOB(16, _omitFieldNames ? '' : 'readOnly')
    ..aOS(17, _omitFieldNames ? '' : 'peerId')
    ..aI(18, _omitFieldNames ? '' : 'version')
    ..aOS(19, _omitFieldNames ? '' : 'createdAt')
    ..aOS(20, _omitFieldNames ? '' : 'createdBy')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Space clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Space copyWith(void Function(Space) updates) =>
      super.copyWith((message) => updates(message as Space)) as Space;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Space() / Space.new instead')
  static Space create() => Space._();
  static $pb.GeneratedMessage $_createMessage() => Space._();
  @$core.override
  Space createEmptyInstance() => Space._();
  @$core.pragma('dart2js:noInline')
  static Space getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Space>(Space.$_createMessage);
  static Space? _defaultInstance;

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
  $core.String get projectId => $_getSZ(3);
  @$pb.TagNumber(4)
  set projectId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasProjectId() => $_has(3);
  @$pb.TagNumber(4)
  void clearProjectId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.bool get isDefault => $_getBF(4);
  @$pb.TagNumber(5)
  set isDefault($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasIsDefault() => $_has(4);
  @$pb.TagNumber(5)
  void clearIsDefault() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.bool get archived => $_getBF(5);
  @$pb.TagNumber(6)
  set archived($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasArchived() => $_has(5);
  @$pb.TagNumber(6)
  void clearArchived() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.bool get joined => $_getBF(6);
  @$pb.TagNumber(7)
  set joined($core.bool value) => $_setBool(6, value);
  @$pb.TagNumber(7)
  $core.bool hasJoined() => $_has(6);
  @$pb.TagNumber(7)
  void clearJoined() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get role => $_getSZ(7);
  @$pb.TagNumber(8)
  set role($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasRole() => $_has(7);
  @$pb.TagNumber(8)
  void clearRole() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.int get unreadCount => $_getIZ(8);
  @$pb.TagNumber(9)
  set unreadCount($core.int value) => $_setSignedInt32(8, value);
  @$pb.TagNumber(9)
  $core.bool hasUnreadCount() => $_has(8);
  @$pb.TagNumber(9)
  void clearUnreadCount() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get lastMessageAt => $_getSZ(9);
  @$pb.TagNumber(10)
  set lastMessageAt($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasLastMessageAt() => $_has(9);
  @$pb.TagNumber(10)
  void clearLastMessageAt() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.String get lastReadAt => $_getSZ(10);
  @$pb.TagNumber(11)
  set lastReadAt($core.String value) => $_setString(10, value);
  @$pb.TagNumber(11)
  $core.bool hasLastReadAt() => $_has(10);
  @$pb.TagNumber(11)
  void clearLastReadAt() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.int get memberCount => $_getIZ(11);
  @$pb.TagNumber(12)
  set memberCount($core.int value) => $_setSignedInt32(11, value);
  @$pb.TagNumber(12)
  $core.bool hasMemberCount() => $_has(11);
  @$pb.TagNumber(12)
  void clearMemberCount() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.String get mutedUntil => $_getSZ(12);
  @$pb.TagNumber(13)
  set mutedUntil($core.String value) => $_setString(12, value);
  @$pb.TagNumber(13)
  $core.bool hasMutedUntil() => $_has(12);
  @$pb.TagNumber(13)
  void clearMutedUntil() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.bool get mutedCompletely => $_getBF(13);
  @$pb.TagNumber(14)
  set mutedCompletely($core.bool value) => $_setBool(13, value);
  @$pb.TagNumber(14)
  $core.bool hasMutedCompletely() => $_has(13);
  @$pb.TagNumber(14)
  void clearMutedCompletely() => $_clearField(14);

  @$pb.TagNumber(15)
  $core.bool get notifyAll => $_getBF(14);
  @$pb.TagNumber(15)
  set notifyAll($core.bool value) => $_setBool(14, value);
  @$pb.TagNumber(15)
  $core.bool hasNotifyAll() => $_has(14);
  @$pb.TagNumber(15)
  void clearNotifyAll() => $_clearField(15);

  @$pb.TagNumber(16)
  $core.bool get readOnly => $_getBF(15);
  @$pb.TagNumber(16)
  set readOnly($core.bool value) => $_setBool(15, value);
  @$pb.TagNumber(16)
  $core.bool hasReadOnly() => $_has(15);
  @$pb.TagNumber(16)
  void clearReadOnly() => $_clearField(16);

  @$pb.TagNumber(17)
  $core.String get peerId => $_getSZ(16);
  @$pb.TagNumber(17)
  set peerId($core.String value) => $_setString(16, value);
  @$pb.TagNumber(17)
  $core.bool hasPeerId() => $_has(16);
  @$pb.TagNumber(17)
  void clearPeerId() => $_clearField(17);

  @$pb.TagNumber(18)
  $core.int get version => $_getIZ(17);
  @$pb.TagNumber(18)
  set version($core.int value) => $_setSignedInt32(17, value);
  @$pb.TagNumber(18)
  $core.bool hasVersion() => $_has(17);
  @$pb.TagNumber(18)
  void clearVersion() => $_clearField(18);

  @$pb.TagNumber(19)
  $core.String get createdAt => $_getSZ(18);
  @$pb.TagNumber(19)
  set createdAt($core.String value) => $_setString(18, value);
  @$pb.TagNumber(19)
  $core.bool hasCreatedAt() => $_has(18);
  @$pb.TagNumber(19)
  void clearCreatedAt() => $_clearField(19);

  @$pb.TagNumber(20)
  $core.String get createdBy => $_getSZ(19);
  @$pb.TagNumber(20)
  set createdBy($core.String value) => $_setString(19, value);
  @$pb.TagNumber(20)
  $core.bool hasCreatedBy() => $_has(19);
  @$pb.TagNumber(20)
  void clearCreatedBy() => $_clearField(20);
}

class TaskChat extends $pb.GeneratedMessage {
  factory TaskChat({
    $core.String? taskId,
    $core.String? projectId,
    $core.String? displayId,
    $core.String? title,
    $core.String? lastMessageAt,
  }) {
    final result = TaskChat._();
    if (taskId != null) result.taskId = taskId;
    if (projectId != null) result.projectId = projectId;
    if (displayId != null) result.displayId = displayId;
    if (title != null) result.title = title;
    if (lastMessageAt != null) result.lastMessageAt = lastMessageAt;
    return result;
  }

  TaskChat._();

  factory TaskChat.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TaskChat()..mergeFromBuffer(data, registry);
  factory TaskChat.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TaskChat()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TaskChat',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.chat'),
      createEmptyInstance: TaskChat.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'taskId')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..aOS(3, _omitFieldNames ? '' : 'displayId')
    ..aOS(4, _omitFieldNames ? '' : 'title')
    ..aOS(5, _omitFieldNames ? '' : 'lastMessageAt')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TaskChat clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TaskChat copyWith(void Function(TaskChat) updates) =>
      super.copyWith((message) => updates(message as TaskChat)) as TaskChat;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use TaskChat() / TaskChat.new instead')
  static TaskChat create() => TaskChat._();
  static $pb.GeneratedMessage $_createMessage() => TaskChat._();
  @$core.override
  TaskChat createEmptyInstance() => TaskChat._();
  @$core.pragma('dart2js:noInline')
  static TaskChat getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TaskChat>(TaskChat.$_createMessage);
  static TaskChat? _defaultInstance;

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
  $core.String get lastMessageAt => $_getSZ(4);
  @$pb.TagNumber(5)
  set lastMessageAt($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasLastMessageAt() => $_has(4);
  @$pb.TagNumber(5)
  void clearLastMessageAt() => $_clearField(5);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
