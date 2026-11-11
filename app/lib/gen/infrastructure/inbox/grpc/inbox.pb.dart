// This is a generated file - do not edit.
//
// Generated from infrastructure/inbox/grpc/inbox.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class ArchiveRequest extends $pb.GeneratedMessage {
  factory ArchiveRequest({
    $core.String? workspaceId,
    $core.Iterable<$core.String>? ids,
    $core.bool? archived,
  }) {
    final result = ArchiveRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (ids != null) result.ids.addAll(ids);
    if (archived != null) result.archived = archived;
    return result;
  }

  ArchiveRequest._();

  factory ArchiveRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ArchiveRequest()..mergeFromBuffer(data, registry);
  factory ArchiveRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ArchiveRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ArchiveRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.inbox'),
      createEmptyInstance: ArchiveRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..pPS(2, _omitFieldNames ? '' : 'ids')
    ..aOB(3, _omitFieldNames ? '' : 'archived')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ArchiveRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ArchiveRequest copyWith(void Function(ArchiveRequest) updates) =>
      super.copyWith((message) => updates(message as ArchiveRequest))
          as ArchiveRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ArchiveRequest() / ArchiveRequest.new instead')
  static ArchiveRequest create() => ArchiveRequest._();
  static $pb.GeneratedMessage $_createMessage() => ArchiveRequest._();
  @$core.override
  ArchiveRequest createEmptyInstance() => ArchiveRequest._();
  @$core.pragma('dart2js:noInline')
  static ArchiveRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ArchiveRequest>(
          ArchiveRequest.$_createMessage);
  static ArchiveRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<$core.String> get ids => $_getList(1);

  @$pb.TagNumber(3)
  $core.bool get archived => $_getBF(2);
  @$pb.TagNumber(3)
  set archived($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasArchived() => $_has(2);
  @$pb.TagNumber(3)
  void clearArchived() => $_clearField(3);
}

class DeviceAnswer extends $pb.GeneratedMessage {
  factory DeviceAnswer({
    $core.bool? registered,
  }) {
    final result = DeviceAnswer._();
    if (registered != null) result.registered = registered;
    return result;
  }

  DeviceAnswer._();

  factory DeviceAnswer.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DeviceAnswer()..mergeFromBuffer(data, registry);
  factory DeviceAnswer.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DeviceAnswer()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeviceAnswer',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.inbox'),
      createEmptyInstance: DeviceAnswer.$_createMessage)
    ..aOB(1, _omitFieldNames ? '' : 'registered')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeviceAnswer clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeviceAnswer copyWith(void Function(DeviceAnswer) updates) =>
      super.copyWith((message) => updates(message as DeviceAnswer))
          as DeviceAnswer;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use DeviceAnswer() / DeviceAnswer.new instead')
  static DeviceAnswer create() => DeviceAnswer._();
  static $pb.GeneratedMessage $_createMessage() => DeviceAnswer._();
  @$core.override
  DeviceAnswer createEmptyInstance() => DeviceAnswer._();
  @$core.pragma('dart2js:noInline')
  static DeviceAnswer getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DeviceAnswer>(
          DeviceAnswer.$_createMessage);
  static DeviceAnswer? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get registered => $_getBF(0);
  @$pb.TagNumber(1)
  set registered($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRegistered() => $_has(0);
  @$pb.TagNumber(1)
  void clearRegistered() => $_clearField(1);
}

class DeviceRegisterRequest extends $pb.GeneratedMessage {
  factory DeviceRegisterRequest({
    $core.String? platform,
    $core.String? token,
  }) {
    final result = DeviceRegisterRequest._();
    if (platform != null) result.platform = platform;
    if (token != null) result.token = token;
    return result;
  }

  DeviceRegisterRequest._();

  factory DeviceRegisterRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DeviceRegisterRequest()..mergeFromBuffer(data, registry);
  factory DeviceRegisterRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DeviceRegisterRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeviceRegisterRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.inbox'),
      createEmptyInstance: DeviceRegisterRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'platform')
    ..aOS(2, _omitFieldNames ? '' : 'token')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeviceRegisterRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeviceRegisterRequest copyWith(
          void Function(DeviceRegisterRequest) updates) =>
      super.copyWith((message) => updates(message as DeviceRegisterRequest))
          as DeviceRegisterRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use DeviceRegisterRequest() / DeviceRegisterRequest.new instead')
  static DeviceRegisterRequest create() => DeviceRegisterRequest._();
  static $pb.GeneratedMessage $_createMessage() => DeviceRegisterRequest._();
  @$core.override
  DeviceRegisterRequest createEmptyInstance() => DeviceRegisterRequest._();
  @$core.pragma('dart2js:noInline')
  static DeviceRegisterRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeviceRegisterRequest>(
          DeviceRegisterRequest.$_createMessage);
  static DeviceRegisterRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get platform => $_getSZ(0);
  @$pb.TagNumber(1)
  set platform($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPlatform() => $_has(0);
  @$pb.TagNumber(1)
  void clearPlatform() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get token => $_getSZ(1);
  @$pb.TagNumber(2)
  set token($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasToken() => $_has(1);
  @$pb.TagNumber(2)
  void clearToken() => $_clearField(2);
}

class DeviceUnregisterRequest extends $pb.GeneratedMessage {
  factory DeviceUnregisterRequest({
    $core.String? token,
  }) {
    final result = DeviceUnregisterRequest._();
    if (token != null) result.token = token;
    return result;
  }

  DeviceUnregisterRequest._();

  factory DeviceUnregisterRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DeviceUnregisterRequest()..mergeFromBuffer(data, registry);
  factory DeviceUnregisterRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DeviceUnregisterRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeviceUnregisterRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.inbox'),
      createEmptyInstance: DeviceUnregisterRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'token')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeviceUnregisterRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeviceUnregisterRequest copyWith(
          void Function(DeviceUnregisterRequest) updates) =>
      super.copyWith((message) => updates(message as DeviceUnregisterRequest))
          as DeviceUnregisterRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use DeviceUnregisterRequest() / DeviceUnregisterRequest.new instead')
  static DeviceUnregisterRequest create() => DeviceUnregisterRequest._();
  static $pb.GeneratedMessage $_createMessage() => DeviceUnregisterRequest._();
  @$core.override
  DeviceUnregisterRequest createEmptyInstance() => DeviceUnregisterRequest._();
  @$core.pragma('dart2js:noInline')
  static DeviceUnregisterRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeviceUnregisterRequest>(
          DeviceUnregisterRequest.$_createMessage);
  static DeviceUnregisterRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get token => $_getSZ(0);
  @$pb.TagNumber(1)
  set token($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasToken() => $_has(0);
  @$pb.TagNumber(1)
  void clearToken() => $_clearField(1);
}

class InboxListRequest extends $pb.GeneratedMessage {
  factory InboxListRequest({
    $core.String? workspaceId,
    $core.String? filter,
    $core.String? before,
    $core.int? pageSize,
  }) {
    final result = InboxListRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (filter != null) result.filter = filter;
    if (before != null) result.before = before;
    if (pageSize != null) result.pageSize = pageSize;
    return result;
  }

  InboxListRequest._();

  factory InboxListRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      InboxListRequest()..mergeFromBuffer(data, registry);
  factory InboxListRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      InboxListRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'InboxListRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.inbox'),
      createEmptyInstance: InboxListRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'filter')
    ..aOS(3, _omitFieldNames ? '' : 'before')
    ..aI(4, _omitFieldNames ? '' : 'pageSize')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InboxListRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InboxListRequest copyWith(void Function(InboxListRequest) updates) =>
      super.copyWith((message) => updates(message as InboxListRequest))
          as InboxListRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use InboxListRequest() / InboxListRequest.new instead')
  static InboxListRequest create() => InboxListRequest._();
  static $pb.GeneratedMessage $_createMessage() => InboxListRequest._();
  @$core.override
  InboxListRequest createEmptyInstance() => InboxListRequest._();
  @$core.pragma('dart2js:noInline')
  static InboxListRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<InboxListRequest>(
          InboxListRequest.$_createMessage);
  static InboxListRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get filter => $_getSZ(1);
  @$pb.TagNumber(2)
  set filter($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFilter() => $_has(1);
  @$pb.TagNumber(2)
  void clearFilter() => $_clearField(2);

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
}

class InboxPage extends $pb.GeneratedMessage {
  factory InboxPage({
    $core.Iterable<Notification>? notifications,
    $core.String? cursor,
    $core.int? unreadCount,
  }) {
    final result = InboxPage._();
    if (notifications != null) result.notifications.addAll(notifications);
    if (cursor != null) result.cursor = cursor;
    if (unreadCount != null) result.unreadCount = unreadCount;
    return result;
  }

  InboxPage._();

  factory InboxPage.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      InboxPage()..mergeFromBuffer(data, registry);
  factory InboxPage.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      InboxPage()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'InboxPage',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.inbox'),
      createEmptyInstance: InboxPage.$_createMessage)
    ..pPM<Notification>(1, _omitFieldNames ? '' : 'notifications',
        subBuilder: Notification.$_createMessage)
    ..aOS(2, _omitFieldNames ? '' : 'cursor')
    ..aI(3, _omitFieldNames ? '' : 'unreadCount')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InboxPage clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InboxPage copyWith(void Function(InboxPage) updates) =>
      super.copyWith((message) => updates(message as InboxPage)) as InboxPage;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use InboxPage() / InboxPage.new instead')
  static InboxPage create() => InboxPage._();
  static $pb.GeneratedMessage $_createMessage() => InboxPage._();
  @$core.override
  InboxPage createEmptyInstance() => InboxPage._();
  @$core.pragma('dart2js:noInline')
  static InboxPage getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<InboxPage>(InboxPage.$_createMessage);
  static InboxPage? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Notification> get notifications => $_getList(0);

  @$pb.TagNumber(2)
  $core.String get cursor => $_getSZ(1);
  @$pb.TagNumber(2)
  set cursor($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCursor() => $_has(1);
  @$pb.TagNumber(2)
  void clearCursor() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get unreadCount => $_getIZ(2);
  @$pb.TagNumber(3)
  set unreadCount($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasUnreadCount() => $_has(2);
  @$pb.TagNumber(3)
  void clearUnreadCount() => $_clearField(3);
}

class InboxSettings extends $pb.GeneratedMessage {
  factory InboxSettings({
    $core.String? timezone,
    $core.String? quietStart,
    $core.String? quietEnd,
    $core.int? digestHour,
  }) {
    final result = InboxSettings._();
    if (timezone != null) result.timezone = timezone;
    if (quietStart != null) result.quietStart = quietStart;
    if (quietEnd != null) result.quietEnd = quietEnd;
    if (digestHour != null) result.digestHour = digestHour;
    return result;
  }

  InboxSettings._();

  factory InboxSettings.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      InboxSettings()..mergeFromBuffer(data, registry);
  factory InboxSettings.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      InboxSettings()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'InboxSettings',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.inbox'),
      createEmptyInstance: InboxSettings.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'timezone')
    ..aOS(2, _omitFieldNames ? '' : 'quietStart')
    ..aOS(3, _omitFieldNames ? '' : 'quietEnd')
    ..aI(4, _omitFieldNames ? '' : 'digestHour')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InboxSettings clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InboxSettings copyWith(void Function(InboxSettings) updates) =>
      super.copyWith((message) => updates(message as InboxSettings))
          as InboxSettings;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use InboxSettings() / InboxSettings.new instead')
  static InboxSettings create() => InboxSettings._();
  static $pb.GeneratedMessage $_createMessage() => InboxSettings._();
  @$core.override
  InboxSettings createEmptyInstance() => InboxSettings._();
  @$core.pragma('dart2js:noInline')
  static InboxSettings getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<InboxSettings>(
          InboxSettings.$_createMessage);
  static InboxSettings? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get timezone => $_getSZ(0);
  @$pb.TagNumber(1)
  set timezone($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTimezone() => $_has(0);
  @$pb.TagNumber(1)
  void clearTimezone() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get quietStart => $_getSZ(1);
  @$pb.TagNumber(2)
  set quietStart($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasQuietStart() => $_has(1);
  @$pb.TagNumber(2)
  void clearQuietStart() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get quietEnd => $_getSZ(2);
  @$pb.TagNumber(3)
  set quietEnd($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasQuietEnd() => $_has(2);
  @$pb.TagNumber(3)
  void clearQuietEnd() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get digestHour => $_getIZ(3);
  @$pb.TagNumber(4)
  set digestHour($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasDigestHour() => $_has(3);
  @$pb.TagNumber(4)
  void clearDigestHour() => $_clearField(4);
}

class MarkReadRequest extends $pb.GeneratedMessage {
  factory MarkReadRequest({
    $core.String? workspaceId,
    $core.Iterable<$core.String>? ids,
    $core.bool? all,
    $core.bool? read,
  }) {
    final result = MarkReadRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (ids != null) result.ids.addAll(ids);
    if (all != null) result.all = all;
    if (read != null) result.read = read;
    return result;
  }

  MarkReadRequest._();

  factory MarkReadRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MarkReadRequest()..mergeFromBuffer(data, registry);
  factory MarkReadRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MarkReadRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MarkReadRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.inbox'),
      createEmptyInstance: MarkReadRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..pPS(2, _omitFieldNames ? '' : 'ids')
    ..aOB(3, _omitFieldNames ? '' : 'all')
    ..aOB(4, _omitFieldNames ? '' : 'read')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MarkReadRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MarkReadRequest copyWith(void Function(MarkReadRequest) updates) =>
      super.copyWith((message) => updates(message as MarkReadRequest))
          as MarkReadRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use MarkReadRequest() / MarkReadRequest.new instead')
  static MarkReadRequest create() => MarkReadRequest._();
  static $pb.GeneratedMessage $_createMessage() => MarkReadRequest._();
  @$core.override
  MarkReadRequest createEmptyInstance() => MarkReadRequest._();
  @$core.pragma('dart2js:noInline')
  static MarkReadRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MarkReadRequest>(
          MarkReadRequest.$_createMessage);
  static MarkReadRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<$core.String> get ids => $_getList(1);

  @$pb.TagNumber(3)
  $core.bool get all => $_getBF(2);
  @$pb.TagNumber(3)
  set all($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAll() => $_has(2);
  @$pb.TagNumber(3)
  void clearAll() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get read => $_getBF(3);
  @$pb.TagNumber(4)
  set read($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasRead() => $_has(3);
  @$pb.TagNumber(4)
  void clearRead() => $_clearField(4);
}

class Notification extends $pb.GeneratedMessage {
  factory Notification({
    $core.String? id,
    $core.String? workspaceId,
    $core.String? type,
    $core.String? taskId,
    $core.String? projectId,
    $core.String? actorId,
    $core.String? actorName,
    $core.String? payload,
    $core.int? count,
    $core.String? createdAt,
    $core.String? updatedAt,
    $core.String? readAt,
    $core.String? snoozedUntil,
    $core.String? archivedAt,
  }) {
    final result = Notification._();
    if (id != null) result.id = id;
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (type != null) result.type = type;
    if (taskId != null) result.taskId = taskId;
    if (projectId != null) result.projectId = projectId;
    if (actorId != null) result.actorId = actorId;
    if (actorName != null) result.actorName = actorName;
    if (payload != null) result.payload = payload;
    if (count != null) result.count = count;
    if (createdAt != null) result.createdAt = createdAt;
    if (updatedAt != null) result.updatedAt = updatedAt;
    if (readAt != null) result.readAt = readAt;
    if (snoozedUntil != null) result.snoozedUntil = snoozedUntil;
    if (archivedAt != null) result.archivedAt = archivedAt;
    return result;
  }

  Notification._();

  factory Notification.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Notification()..mergeFromBuffer(data, registry);
  factory Notification.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Notification()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Notification',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.inbox'),
      createEmptyInstance: Notification.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(3, _omitFieldNames ? '' : 'type')
    ..aOS(4, _omitFieldNames ? '' : 'taskId')
    ..aOS(5, _omitFieldNames ? '' : 'projectId')
    ..aOS(6, _omitFieldNames ? '' : 'actorId')
    ..aOS(7, _omitFieldNames ? '' : 'actorName')
    ..aOS(8, _omitFieldNames ? '' : 'payload')
    ..aI(9, _omitFieldNames ? '' : 'count')
    ..aOS(10, _omitFieldNames ? '' : 'createdAt')
    ..aOS(11, _omitFieldNames ? '' : 'updatedAt')
    ..aOS(12, _omitFieldNames ? '' : 'readAt')
    ..aOS(13, _omitFieldNames ? '' : 'snoozedUntil')
    ..aOS(14, _omitFieldNames ? '' : 'archivedAt')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Notification clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Notification copyWith(void Function(Notification) updates) =>
      super.copyWith((message) => updates(message as Notification))
          as Notification;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Notification() / Notification.new instead')
  static Notification create() => Notification._();
  static $pb.GeneratedMessage $_createMessage() => Notification._();
  @$core.override
  Notification createEmptyInstance() => Notification._();
  @$core.pragma('dart2js:noInline')
  static Notification getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Notification>(
          Notification.$_createMessage);
  static Notification? _defaultInstance;

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
  $core.String get type => $_getSZ(2);
  @$pb.TagNumber(3)
  set type($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasType() => $_has(2);
  @$pb.TagNumber(3)
  void clearType() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get taskId => $_getSZ(3);
  @$pb.TagNumber(4)
  set taskId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasTaskId() => $_has(3);
  @$pb.TagNumber(4)
  void clearTaskId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get projectId => $_getSZ(4);
  @$pb.TagNumber(5)
  set projectId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasProjectId() => $_has(4);
  @$pb.TagNumber(5)
  void clearProjectId() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get actorId => $_getSZ(5);
  @$pb.TagNumber(6)
  set actorId($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasActorId() => $_has(5);
  @$pb.TagNumber(6)
  void clearActorId() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get actorName => $_getSZ(6);
  @$pb.TagNumber(7)
  set actorName($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasActorName() => $_has(6);
  @$pb.TagNumber(7)
  void clearActorName() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get payload => $_getSZ(7);
  @$pb.TagNumber(8)
  set payload($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasPayload() => $_has(7);
  @$pb.TagNumber(8)
  void clearPayload() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.int get count => $_getIZ(8);
  @$pb.TagNumber(9)
  set count($core.int value) => $_setSignedInt32(8, value);
  @$pb.TagNumber(9)
  $core.bool hasCount() => $_has(8);
  @$pb.TagNumber(9)
  void clearCount() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get createdAt => $_getSZ(9);
  @$pb.TagNumber(10)
  set createdAt($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasCreatedAt() => $_has(9);
  @$pb.TagNumber(10)
  void clearCreatedAt() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.String get updatedAt => $_getSZ(10);
  @$pb.TagNumber(11)
  set updatedAt($core.String value) => $_setString(10, value);
  @$pb.TagNumber(11)
  $core.bool hasUpdatedAt() => $_has(10);
  @$pb.TagNumber(11)
  void clearUpdatedAt() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.String get readAt => $_getSZ(11);
  @$pb.TagNumber(12)
  set readAt($core.String value) => $_setString(11, value);
  @$pb.TagNumber(12)
  $core.bool hasReadAt() => $_has(11);
  @$pb.TagNumber(12)
  void clearReadAt() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.String get snoozedUntil => $_getSZ(12);
  @$pb.TagNumber(13)
  set snoozedUntil($core.String value) => $_setString(12, value);
  @$pb.TagNumber(13)
  $core.bool hasSnoozedUntil() => $_has(12);
  @$pb.TagNumber(13)
  void clearSnoozedUntil() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.String get archivedAt => $_getSZ(13);
  @$pb.TagNumber(14)
  set archivedAt($core.String value) => $_setString(13, value);
  @$pb.TagNumber(14)
  $core.bool hasArchivedAt() => $_has(13);
  @$pb.TagNumber(14)
  void clearArchivedAt() => $_clearField(14);
}

class PrefRow extends $pb.GeneratedMessage {
  factory PrefRow({
    $core.String? eventType,
    $core.String? label,
    $core.bool? inbox,
    $core.bool? push,
    $core.String? emailMode,
  }) {
    final result = PrefRow._();
    if (eventType != null) result.eventType = eventType;
    if (label != null) result.label = label;
    if (inbox != null) result.inbox = inbox;
    if (push != null) result.push = push;
    if (emailMode != null) result.emailMode = emailMode;
    return result;
  }

  PrefRow._();

  factory PrefRow.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PrefRow()..mergeFromBuffer(data, registry);
  factory PrefRow.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PrefRow()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PrefRow',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.inbox'),
      createEmptyInstance: PrefRow.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'eventType')
    ..aOS(2, _omitFieldNames ? '' : 'label')
    ..aOB(3, _omitFieldNames ? '' : 'inbox')
    ..aOB(4, _omitFieldNames ? '' : 'push')
    ..aOS(5, _omitFieldNames ? '' : 'emailMode')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PrefRow clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PrefRow copyWith(void Function(PrefRow) updates) =>
      super.copyWith((message) => updates(message as PrefRow)) as PrefRow;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use PrefRow() / PrefRow.new instead')
  static PrefRow create() => PrefRow._();
  static $pb.GeneratedMessage $_createMessage() => PrefRow._();
  @$core.override
  PrefRow createEmptyInstance() => PrefRow._();
  @$core.pragma('dart2js:noInline')
  static PrefRow getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PrefRow>(PrefRow.$_createMessage);
  static PrefRow? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get eventType => $_getSZ(0);
  @$pb.TagNumber(1)
  set eventType($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasEventType() => $_has(0);
  @$pb.TagNumber(1)
  void clearEventType() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get label => $_getSZ(1);
  @$pb.TagNumber(2)
  set label($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasLabel() => $_has(1);
  @$pb.TagNumber(2)
  void clearLabel() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get inbox => $_getBF(2);
  @$pb.TagNumber(3)
  set inbox($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasInbox() => $_has(2);
  @$pb.TagNumber(3)
  void clearInbox() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get push => $_getBF(3);
  @$pb.TagNumber(4)
  set push($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasPush() => $_has(3);
  @$pb.TagNumber(4)
  void clearPush() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get emailMode => $_getSZ(4);
  @$pb.TagNumber(5)
  set emailMode($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasEmailMode() => $_has(4);
  @$pb.TagNumber(5)
  void clearEmailMode() => $_clearField(5);
}

class PrefSetRequest extends $pb.GeneratedMessage {
  factory PrefSetRequest({
    $core.String? eventType,
    $core.bool? inbox,
    $core.bool? push,
    $core.String? emailMode,
  }) {
    final result = PrefSetRequest._();
    if (eventType != null) result.eventType = eventType;
    if (inbox != null) result.inbox = inbox;
    if (push != null) result.push = push;
    if (emailMode != null) result.emailMode = emailMode;
    return result;
  }

  PrefSetRequest._();

  factory PrefSetRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PrefSetRequest()..mergeFromBuffer(data, registry);
  factory PrefSetRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PrefSetRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PrefSetRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.inbox'),
      createEmptyInstance: PrefSetRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'eventType')
    ..aOB(2, _omitFieldNames ? '' : 'inbox')
    ..aOB(3, _omitFieldNames ? '' : 'push')
    ..aOS(4, _omitFieldNames ? '' : 'emailMode')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PrefSetRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PrefSetRequest copyWith(void Function(PrefSetRequest) updates) =>
      super.copyWith((message) => updates(message as PrefSetRequest))
          as PrefSetRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use PrefSetRequest() / PrefSetRequest.new instead')
  static PrefSetRequest create() => PrefSetRequest._();
  static $pb.GeneratedMessage $_createMessage() => PrefSetRequest._();
  @$core.override
  PrefSetRequest createEmptyInstance() => PrefSetRequest._();
  @$core.pragma('dart2js:noInline')
  static PrefSetRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PrefSetRequest>(
          PrefSetRequest.$_createMessage);
  static PrefSetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get eventType => $_getSZ(0);
  @$pb.TagNumber(1)
  set eventType($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasEventType() => $_has(0);
  @$pb.TagNumber(1)
  void clearEventType() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get inbox => $_getBF(1);
  @$pb.TagNumber(2)
  set inbox($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasInbox() => $_has(1);
  @$pb.TagNumber(2)
  void clearInbox() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get push => $_getBF(2);
  @$pb.TagNumber(3)
  set push($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPush() => $_has(2);
  @$pb.TagNumber(3)
  void clearPush() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get emailMode => $_getSZ(3);
  @$pb.TagNumber(4)
  set emailMode($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasEmailMode() => $_has(3);
  @$pb.TagNumber(4)
  void clearEmailMode() => $_clearField(4);
}

class PrefsAnswer extends $pb.GeneratedMessage {
  factory PrefsAnswer({
    $core.Iterable<PrefRow>? prefs,
    InboxSettings? settings,
  }) {
    final result = PrefsAnswer._();
    if (prefs != null) result.prefs.addAll(prefs);
    if (settings != null) result.settings = settings;
    return result;
  }

  PrefsAnswer._();

  factory PrefsAnswer.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PrefsAnswer()..mergeFromBuffer(data, registry);
  factory PrefsAnswer.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PrefsAnswer()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PrefsAnswer',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.inbox'),
      createEmptyInstance: PrefsAnswer.$_createMessage)
    ..pPM<PrefRow>(1, _omitFieldNames ? '' : 'prefs',
        subBuilder: PrefRow.$_createMessage)
    ..aOM<InboxSettings>(2, _omitFieldNames ? '' : 'settings',
        subBuilder: InboxSettings.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PrefsAnswer clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PrefsAnswer copyWith(void Function(PrefsAnswer) updates) =>
      super.copyWith((message) => updates(message as PrefsAnswer))
          as PrefsAnswer;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use PrefsAnswer() / PrefsAnswer.new instead')
  static PrefsAnswer create() => PrefsAnswer._();
  static $pb.GeneratedMessage $_createMessage() => PrefsAnswer._();
  @$core.override
  PrefsAnswer createEmptyInstance() => PrefsAnswer._();
  @$core.pragma('dart2js:noInline')
  static PrefsAnswer getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PrefsAnswer>(
          PrefsAnswer.$_createMessage);
  static PrefsAnswer? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<PrefRow> get prefs => $_getList(0);

  @$pb.TagNumber(2)
  InboxSettings get settings => $_getN(1);
  @$pb.TagNumber(2)
  set settings(InboxSettings value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasSettings() => $_has(1);
  @$pb.TagNumber(2)
  void clearSettings() => $_clearField(2);
  @$pb.TagNumber(2)
  InboxSettings ensureSettings() => $_ensure(1);
}

class PrefsGetRequest extends $pb.GeneratedMessage {
  factory PrefsGetRequest() => PrefsGetRequest._();

  PrefsGetRequest._();

  factory PrefsGetRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PrefsGetRequest()..mergeFromBuffer(data, registry);
  factory PrefsGetRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PrefsGetRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PrefsGetRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.inbox'),
      createEmptyInstance: PrefsGetRequest.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PrefsGetRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PrefsGetRequest copyWith(void Function(PrefsGetRequest) updates) =>
      super.copyWith((message) => updates(message as PrefsGetRequest))
          as PrefsGetRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use PrefsGetRequest() / PrefsGetRequest.new instead')
  static PrefsGetRequest create() => PrefsGetRequest._();
  static $pb.GeneratedMessage $_createMessage() => PrefsGetRequest._();
  @$core.override
  PrefsGetRequest createEmptyInstance() => PrefsGetRequest._();
  @$core.pragma('dart2js:noInline')
  static PrefsGetRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PrefsGetRequest>(
          PrefsGetRequest.$_createMessage);
  static PrefsGetRequest? _defaultInstance;
}

class SettingsSetRequest extends $pb.GeneratedMessage {
  factory SettingsSetRequest({
    $core.String? timezone,
    $core.String? quietStart,
    $core.String? quietEnd,
    $core.int? digestHour,
  }) {
    final result = SettingsSetRequest._();
    if (timezone != null) result.timezone = timezone;
    if (quietStart != null) result.quietStart = quietStart;
    if (quietEnd != null) result.quietEnd = quietEnd;
    if (digestHour != null) result.digestHour = digestHour;
    return result;
  }

  SettingsSetRequest._();

  factory SettingsSetRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SettingsSetRequest()..mergeFromBuffer(data, registry);
  factory SettingsSetRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SettingsSetRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SettingsSetRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.inbox'),
      createEmptyInstance: SettingsSetRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'timezone')
    ..aOS(2, _omitFieldNames ? '' : 'quietStart')
    ..aOS(3, _omitFieldNames ? '' : 'quietEnd')
    ..aI(4, _omitFieldNames ? '' : 'digestHour')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SettingsSetRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SettingsSetRequest copyWith(void Function(SettingsSetRequest) updates) =>
      super.copyWith((message) => updates(message as SettingsSetRequest))
          as SettingsSetRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SettingsSetRequest() / SettingsSetRequest.new instead')
  static SettingsSetRequest create() => SettingsSetRequest._();
  static $pb.GeneratedMessage $_createMessage() => SettingsSetRequest._();
  @$core.override
  SettingsSetRequest createEmptyInstance() => SettingsSetRequest._();
  @$core.pragma('dart2js:noInline')
  static SettingsSetRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SettingsSetRequest>(
          SettingsSetRequest.$_createMessage);
  static SettingsSetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get timezone => $_getSZ(0);
  @$pb.TagNumber(1)
  set timezone($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTimezone() => $_has(0);
  @$pb.TagNumber(1)
  void clearTimezone() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get quietStart => $_getSZ(1);
  @$pb.TagNumber(2)
  set quietStart($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasQuietStart() => $_has(1);
  @$pb.TagNumber(2)
  void clearQuietStart() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get quietEnd => $_getSZ(2);
  @$pb.TagNumber(3)
  set quietEnd($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasQuietEnd() => $_has(2);
  @$pb.TagNumber(3)
  void clearQuietEnd() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get digestHour => $_getIZ(3);
  @$pb.TagNumber(4)
  set digestHour($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasDigestHour() => $_has(3);
  @$pb.TagNumber(4)
  void clearDigestHour() => $_clearField(4);
}

class SnoozeRequest extends $pb.GeneratedMessage {
  factory SnoozeRequest({
    $core.String? workspaceId,
    $core.String? id,
    $core.String? until,
  }) {
    final result = SnoozeRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (id != null) result.id = id;
    if (until != null) result.until = until;
    return result;
  }

  SnoozeRequest._();

  factory SnoozeRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SnoozeRequest()..mergeFromBuffer(data, registry);
  factory SnoozeRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SnoozeRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SnoozeRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.inbox'),
      createEmptyInstance: SnoozeRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'id')
    ..aOS(3, _omitFieldNames ? '' : 'until')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SnoozeRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SnoozeRequest copyWith(void Function(SnoozeRequest) updates) =>
      super.copyWith((message) => updates(message as SnoozeRequest))
          as SnoozeRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SnoozeRequest() / SnoozeRequest.new instead')
  static SnoozeRequest create() => SnoozeRequest._();
  static $pb.GeneratedMessage $_createMessage() => SnoozeRequest._();
  @$core.override
  SnoozeRequest createEmptyInstance() => SnoozeRequest._();
  @$core.pragma('dart2js:noInline')
  static SnoozeRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SnoozeRequest>(
          SnoozeRequest.$_createMessage);
  static SnoozeRequest? _defaultInstance;

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
  $core.String get until => $_getSZ(2);
  @$pb.TagNumber(3)
  set until($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasUntil() => $_has(2);
  @$pb.TagNumber(3)
  void clearUntil() => $_clearField(3);
}

class UnreadCountRequest extends $pb.GeneratedMessage {
  factory UnreadCountRequest({
    $core.String? workspaceId,
  }) {
    final result = UnreadCountRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    return result;
  }

  UnreadCountRequest._();

  factory UnreadCountRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UnreadCountRequest()..mergeFromBuffer(data, registry);
  factory UnreadCountRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UnreadCountRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UnreadCountRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.inbox'),
      createEmptyInstance: UnreadCountRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UnreadCountRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UnreadCountRequest copyWith(void Function(UnreadCountRequest) updates) =>
      super.copyWith((message) => updates(message as UnreadCountRequest))
          as UnreadCountRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use UnreadCountRequest() / UnreadCountRequest.new instead')
  static UnreadCountRequest create() => UnreadCountRequest._();
  static $pb.GeneratedMessage $_createMessage() => UnreadCountRequest._();
  @$core.override
  UnreadCountRequest createEmptyInstance() => UnreadCountRequest._();
  @$core.pragma('dart2js:noInline')
  static UnreadCountRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UnreadCountRequest>(
          UnreadCountRequest.$_createMessage);
  static UnreadCountRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);
}

class UnreadTotal extends $pb.GeneratedMessage {
  factory UnreadTotal({
    $core.int? count,
  }) {
    final result = UnreadTotal._();
    if (count != null) result.count = count;
    return result;
  }

  UnreadTotal._();

  factory UnreadTotal.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UnreadTotal()..mergeFromBuffer(data, registry);
  factory UnreadTotal.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UnreadTotal()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UnreadTotal',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.inbox'),
      createEmptyInstance: UnreadTotal.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'count')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UnreadTotal clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UnreadTotal copyWith(void Function(UnreadTotal) updates) =>
      super.copyWith((message) => updates(message as UnreadTotal))
          as UnreadTotal;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use UnreadTotal() / UnreadTotal.new instead')
  static UnreadTotal create() => UnreadTotal._();
  static $pb.GeneratedMessage $_createMessage() => UnreadTotal._();
  @$core.override
  UnreadTotal createEmptyInstance() => UnreadTotal._();
  @$core.pragma('dart2js:noInline')
  static UnreadTotal getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UnreadTotal>(
          UnreadTotal.$_createMessage);
  static UnreadTotal? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get count => $_getIZ(0);
  @$pb.TagNumber(1)
  set count($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCount() => $_has(0);
  @$pb.TagNumber(1)
  void clearCount() => $_clearField(1);
}

class WatchAddRequest extends $pb.GeneratedMessage {
  factory WatchAddRequest({
    $core.String? workspaceId,
    $core.String? projectId,
    $core.String? taskId,
  }) {
    final result = WatchAddRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (projectId != null) result.projectId = projectId;
    if (taskId != null) result.taskId = taskId;
    return result;
  }

  WatchAddRequest._();

  factory WatchAddRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WatchAddRequest()..mergeFromBuffer(data, registry);
  factory WatchAddRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WatchAddRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WatchAddRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.inbox'),
      createEmptyInstance: WatchAddRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..aOS(3, _omitFieldNames ? '' : 'taskId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WatchAddRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WatchAddRequest copyWith(void Function(WatchAddRequest) updates) =>
      super.copyWith((message) => updates(message as WatchAddRequest))
          as WatchAddRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use WatchAddRequest() / WatchAddRequest.new instead')
  static WatchAddRequest create() => WatchAddRequest._();
  static $pb.GeneratedMessage $_createMessage() => WatchAddRequest._();
  @$core.override
  WatchAddRequest createEmptyInstance() => WatchAddRequest._();
  @$core.pragma('dart2js:noInline')
  static WatchAddRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<WatchAddRequest>(
          WatchAddRequest.$_createMessage);
  static WatchAddRequest? _defaultInstance;

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
}

class WatchGetRequest extends $pb.GeneratedMessage {
  factory WatchGetRequest({
    $core.String? workspaceId,
    $core.String? projectId,
    $core.String? taskId,
  }) {
    final result = WatchGetRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (projectId != null) result.projectId = projectId;
    if (taskId != null) result.taskId = taskId;
    return result;
  }

  WatchGetRequest._();

  factory WatchGetRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WatchGetRequest()..mergeFromBuffer(data, registry);
  factory WatchGetRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WatchGetRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WatchGetRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.inbox'),
      createEmptyInstance: WatchGetRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..aOS(3, _omitFieldNames ? '' : 'taskId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WatchGetRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WatchGetRequest copyWith(void Function(WatchGetRequest) updates) =>
      super.copyWith((message) => updates(message as WatchGetRequest))
          as WatchGetRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use WatchGetRequest() / WatchGetRequest.new instead')
  static WatchGetRequest create() => WatchGetRequest._();
  static $pb.GeneratedMessage $_createMessage() => WatchGetRequest._();
  @$core.override
  WatchGetRequest createEmptyInstance() => WatchGetRequest._();
  @$core.pragma('dart2js:noInline')
  static WatchGetRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<WatchGetRequest>(
          WatchGetRequest.$_createMessage);
  static WatchGetRequest? _defaultInstance;

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
}

class WatchRemoveRequest extends $pb.GeneratedMessage {
  factory WatchRemoveRequest({
    $core.String? workspaceId,
    $core.String? projectId,
    $core.String? taskId,
  }) {
    final result = WatchRemoveRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (projectId != null) result.projectId = projectId;
    if (taskId != null) result.taskId = taskId;
    return result;
  }

  WatchRemoveRequest._();

  factory WatchRemoveRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WatchRemoveRequest()..mergeFromBuffer(data, registry);
  factory WatchRemoveRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WatchRemoveRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WatchRemoveRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.inbox'),
      createEmptyInstance: WatchRemoveRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..aOS(3, _omitFieldNames ? '' : 'taskId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WatchRemoveRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WatchRemoveRequest copyWith(void Function(WatchRemoveRequest) updates) =>
      super.copyWith((message) => updates(message as WatchRemoveRequest))
          as WatchRemoveRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use WatchRemoveRequest() / WatchRemoveRequest.new instead')
  static WatchRemoveRequest create() => WatchRemoveRequest._();
  static $pb.GeneratedMessage $_createMessage() => WatchRemoveRequest._();
  @$core.override
  WatchRemoveRequest createEmptyInstance() => WatchRemoveRequest._();
  @$core.pragma('dart2js:noInline')
  static WatchRemoveRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WatchRemoveRequest>(
          WatchRemoveRequest.$_createMessage);
  static WatchRemoveRequest? _defaultInstance;

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
}

class WatchState extends $pb.GeneratedMessage {
  factory WatchState({
    $core.bool? watching,
    $core.int? watcherCount,
  }) {
    final result = WatchState._();
    if (watching != null) result.watching = watching;
    if (watcherCount != null) result.watcherCount = watcherCount;
    return result;
  }

  WatchState._();

  factory WatchState.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WatchState()..mergeFromBuffer(data, registry);
  factory WatchState.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WatchState()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WatchState',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.inbox'),
      createEmptyInstance: WatchState.$_createMessage)
    ..aOB(1, _omitFieldNames ? '' : 'watching')
    ..aI(2, _omitFieldNames ? '' : 'watcherCount')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WatchState clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WatchState copyWith(void Function(WatchState) updates) =>
      super.copyWith((message) => updates(message as WatchState)) as WatchState;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use WatchState() / WatchState.new instead')
  static WatchState create() => WatchState._();
  static $pb.GeneratedMessage $_createMessage() => WatchState._();
  @$core.override
  WatchState createEmptyInstance() => WatchState._();
  @$core.pragma('dart2js:noInline')
  static WatchState getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WatchState>(WatchState.$_createMessage);
  static WatchState? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get watching => $_getBF(0);
  @$pb.TagNumber(1)
  set watching($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWatching() => $_has(0);
  @$pb.TagNumber(1)
  void clearWatching() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get watcherCount => $_getIZ(1);
  @$pb.TagNumber(2)
  set watcherCount($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasWatcherCount() => $_has(1);
  @$pb.TagNumber(2)
  void clearWatcherCount() => $_clearField(2);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
