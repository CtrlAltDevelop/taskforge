// This is a generated file - do not edit.
//
// Generated from infrastructure/oauth/rotation/grpc/oauth_rotation.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class Credentials extends $pb.GeneratedMessage {
  factory Credentials({
    $core.String? tokenType,
    $core.String? accessToken,
    $core.String? refreshToken,
    $core.int? expiresIn,
    $core.String? sessionId,
  }) {
    final result = Credentials._();
    if (tokenType != null) result.tokenType = tokenType;
    if (accessToken != null) result.accessToken = accessToken;
    if (refreshToken != null) result.refreshToken = refreshToken;
    if (expiresIn != null) result.expiresIn = expiresIn;
    if (sessionId != null) result.sessionId = sessionId;
    return result;
  }

  Credentials._();

  factory Credentials.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Credentials()..mergeFromBuffer(data, registry);
  factory Credentials.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Credentials()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Credentials',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'config.oauth_rotation'),
      createEmptyInstance: Credentials.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'tokenType')
    ..aOS(2, _omitFieldNames ? '' : 'accessToken')
    ..aOS(3, _omitFieldNames ? '' : 'refreshToken')
    ..aI(4, _omitFieldNames ? '' : 'expiresIn')
    ..aOS(5, _omitFieldNames ? '' : 'sessionId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Credentials clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Credentials copyWith(void Function(Credentials) updates) =>
      super.copyWith((message) => updates(message as Credentials))
          as Credentials;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Credentials() / Credentials.new instead')
  static Credentials create() => Credentials._();
  static $pb.GeneratedMessage $_createMessage() => Credentials._();
  @$core.override
  Credentials createEmptyInstance() => Credentials._();
  @$core.pragma('dart2js:noInline')
  static Credentials getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Credentials>(
          Credentials.$_createMessage);
  static Credentials? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get tokenType => $_getSZ(0);
  @$pb.TagNumber(1)
  set tokenType($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTokenType() => $_has(0);
  @$pb.TagNumber(1)
  void clearTokenType() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get accessToken => $_getSZ(1);
  @$pb.TagNumber(2)
  set accessToken($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAccessToken() => $_has(1);
  @$pb.TagNumber(2)
  void clearAccessToken() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get refreshToken => $_getSZ(2);
  @$pb.TagNumber(3)
  set refreshToken($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRefreshToken() => $_has(2);
  @$pb.TagNumber(3)
  void clearRefreshToken() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get expiresIn => $_getIZ(3);
  @$pb.TagNumber(4)
  set expiresIn($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasExpiresIn() => $_has(3);
  @$pb.TagNumber(4)
  void clearExpiresIn() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get sessionId => $_getSZ(4);
  @$pb.TagNumber(5)
  set sessionId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasSessionId() => $_has(4);
  @$pb.TagNumber(5)
  void clearSessionId() => $_clearField(5);
}

class EndSessionRequest extends $pb.GeneratedMessage {
  factory EndSessionRequest({
    $core.String? sessionId,
  }) {
    final result = EndSessionRequest._();
    if (sessionId != null) result.sessionId = sessionId;
    return result;
  }

  EndSessionRequest._();

  factory EndSessionRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      EndSessionRequest()..mergeFromBuffer(data, registry);
  factory EndSessionRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      EndSessionRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'EndSessionRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'config.oauth_rotation'),
      createEmptyInstance: EndSessionRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'sessionId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EndSessionRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EndSessionRequest copyWith(void Function(EndSessionRequest) updates) =>
      super.copyWith((message) => updates(message as EndSessionRequest))
          as EndSessionRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use EndSessionRequest() / EndSessionRequest.new instead')
  static EndSessionRequest create() => EndSessionRequest._();
  static $pb.GeneratedMessage $_createMessage() => EndSessionRequest._();
  @$core.override
  EndSessionRequest createEmptyInstance() => EndSessionRequest._();
  @$core.pragma('dart2js:noInline')
  static EndSessionRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<EndSessionRequest>(
          EndSessionRequest.$_createMessage);
  static EndSessionRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get sessionId => $_getSZ(0);
  @$pb.TagNumber(1)
  set sessionId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSessionId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSessionId() => $_clearField(1);
}

class Message extends $pb.GeneratedMessage {
  factory Message({
    $core.String? detail,
  }) {
    final result = Message._();
    if (detail != null) result.detail = detail;
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
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'config.oauth_rotation'),
      createEmptyInstance: Message.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'detail')
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
  $core.String get detail => $_getSZ(0);
  @$pb.TagNumber(1)
  set detail($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDetail() => $_has(0);
  @$pb.TagNumber(1)
  void clearDetail() => $_clearField(1);
}

class RefreshRequest extends $pb.GeneratedMessage {
  factory RefreshRequest({
    $core.String? refreshToken,
  }) {
    final result = RefreshRequest._();
    if (refreshToken != null) result.refreshToken = refreshToken;
    return result;
  }

  RefreshRequest._();

  factory RefreshRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RefreshRequest()..mergeFromBuffer(data, registry);
  factory RefreshRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RefreshRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RefreshRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'config.oauth_rotation'),
      createEmptyInstance: RefreshRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'refreshToken')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RefreshRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RefreshRequest copyWith(void Function(RefreshRequest) updates) =>
      super.copyWith((message) => updates(message as RefreshRequest))
          as RefreshRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use RefreshRequest() / RefreshRequest.new instead')
  static RefreshRequest create() => RefreshRequest._();
  static $pb.GeneratedMessage $_createMessage() => RefreshRequest._();
  @$core.override
  RefreshRequest createEmptyInstance() => RefreshRequest._();
  @$core.pragma('dart2js:noInline')
  static RefreshRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RefreshRequest>(
          RefreshRequest.$_createMessage);
  static RefreshRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get refreshToken => $_getSZ(0);
  @$pb.TagNumber(1)
  set refreshToken($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRefreshToken() => $_has(0);
  @$pb.TagNumber(1)
  void clearRefreshToken() => $_clearField(1);
}

class RevokeRequest extends $pb.GeneratedMessage {
  factory RevokeRequest({
    $core.String? token,
  }) {
    final result = RevokeRequest._();
    if (token != null) result.token = token;
    return result;
  }

  RevokeRequest._();

  factory RevokeRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RevokeRequest()..mergeFromBuffer(data, registry);
  factory RevokeRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RevokeRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RevokeRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'config.oauth_rotation'),
      createEmptyInstance: RevokeRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'token')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RevokeRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RevokeRequest copyWith(void Function(RevokeRequest) updates) =>
      super.copyWith((message) => updates(message as RevokeRequest))
          as RevokeRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use RevokeRequest() / RevokeRequest.new instead')
  static RevokeRequest create() => RevokeRequest._();
  static $pb.GeneratedMessage $_createMessage() => RevokeRequest._();
  @$core.override
  RevokeRequest createEmptyInstance() => RevokeRequest._();
  @$core.pragma('dart2js:noInline')
  static RevokeRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RevokeRequest>(
          RevokeRequest.$_createMessage);
  static RevokeRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get token => $_getSZ(0);
  @$pb.TagNumber(1)
  set token($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasToken() => $_has(0);
  @$pb.TagNumber(1)
  void clearToken() => $_clearField(1);
}

class Session extends $pb.GeneratedMessage {
  factory Session({
    $core.String? sessionId,
    $core.String? createdAt,
    $core.String? lastUsedAt,
    $core.String? expiresAt,
    $core.String? ipAddress,
    $core.String? userAgent,
    $core.String? authMethod,
    $core.bool? current,
    $core.bool? dpopBound,
  }) {
    final result = Session._();
    if (sessionId != null) result.sessionId = sessionId;
    if (createdAt != null) result.createdAt = createdAt;
    if (lastUsedAt != null) result.lastUsedAt = lastUsedAt;
    if (expiresAt != null) result.expiresAt = expiresAt;
    if (ipAddress != null) result.ipAddress = ipAddress;
    if (userAgent != null) result.userAgent = userAgent;
    if (authMethod != null) result.authMethod = authMethod;
    if (current != null) result.current = current;
    if (dpopBound != null) result.dpopBound = dpopBound;
    return result;
  }

  Session._();

  factory Session.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Session()..mergeFromBuffer(data, registry);
  factory Session.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Session()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Session',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'config.oauth_rotation'),
      createEmptyInstance: Session.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'sessionId')
    ..aOS(2, _omitFieldNames ? '' : 'createdAt')
    ..aOS(3, _omitFieldNames ? '' : 'lastUsedAt')
    ..aOS(4, _omitFieldNames ? '' : 'expiresAt')
    ..aOS(5, _omitFieldNames ? '' : 'ipAddress')
    ..aOS(6, _omitFieldNames ? '' : 'userAgent')
    ..aOS(7, _omitFieldNames ? '' : 'authMethod')
    ..aOB(8, _omitFieldNames ? '' : 'current')
    ..aOB(9, _omitFieldNames ? '' : 'dpopBound')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Session clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Session copyWith(void Function(Session) updates) =>
      super.copyWith((message) => updates(message as Session)) as Session;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Session() / Session.new instead')
  static Session create() => Session._();
  static $pb.GeneratedMessage $_createMessage() => Session._();
  @$core.override
  Session createEmptyInstance() => Session._();
  @$core.pragma('dart2js:noInline')
  static Session getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Session>(Session.$_createMessage);
  static Session? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get sessionId => $_getSZ(0);
  @$pb.TagNumber(1)
  set sessionId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSessionId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSessionId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get createdAt => $_getSZ(1);
  @$pb.TagNumber(2)
  set createdAt($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCreatedAt() => $_has(1);
  @$pb.TagNumber(2)
  void clearCreatedAt() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get lastUsedAt => $_getSZ(2);
  @$pb.TagNumber(3)
  set lastUsedAt($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasLastUsedAt() => $_has(2);
  @$pb.TagNumber(3)
  void clearLastUsedAt() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get expiresAt => $_getSZ(3);
  @$pb.TagNumber(4)
  set expiresAt($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasExpiresAt() => $_has(3);
  @$pb.TagNumber(4)
  void clearExpiresAt() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get ipAddress => $_getSZ(4);
  @$pb.TagNumber(5)
  set ipAddress($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasIpAddress() => $_has(4);
  @$pb.TagNumber(5)
  void clearIpAddress() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get userAgent => $_getSZ(5);
  @$pb.TagNumber(6)
  set userAgent($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasUserAgent() => $_has(5);
  @$pb.TagNumber(6)
  void clearUserAgent() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get authMethod => $_getSZ(6);
  @$pb.TagNumber(7)
  set authMethod($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasAuthMethod() => $_has(6);
  @$pb.TagNumber(7)
  void clearAuthMethod() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.bool get current => $_getBF(7);
  @$pb.TagNumber(8)
  set current($core.bool value) => $_setBool(7, value);
  @$pb.TagNumber(8)
  $core.bool hasCurrent() => $_has(7);
  @$pb.TagNumber(8)
  void clearCurrent() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.bool get dpopBound => $_getBF(8);
  @$pb.TagNumber(9)
  set dpopBound($core.bool value) => $_setBool(8, value);
  @$pb.TagNumber(9)
  $core.bool hasDpopBound() => $_has(8);
  @$pb.TagNumber(9)
  void clearDpopBound() => $_clearField(9);
}

class SessionList extends $pb.GeneratedMessage {
  factory SessionList({
    $core.String? mode,
    $core.Iterable<Session>? sessions,
  }) {
    final result = SessionList._();
    if (mode != null) result.mode = mode;
    if (sessions != null) result.sessions.addAll(sessions);
    return result;
  }

  SessionList._();

  factory SessionList.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SessionList()..mergeFromBuffer(data, registry);
  factory SessionList.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SessionList()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SessionList',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'config.oauth_rotation'),
      createEmptyInstance: SessionList.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'mode')
    ..pPM<Session>(2, _omitFieldNames ? '' : 'sessions',
        subBuilder: Session.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SessionList clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SessionList copyWith(void Function(SessionList) updates) =>
      super.copyWith((message) => updates(message as SessionList))
          as SessionList;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SessionList() / SessionList.new instead')
  static SessionList create() => SessionList._();
  static $pb.GeneratedMessage $_createMessage() => SessionList._();
  @$core.override
  SessionList createEmptyInstance() => SessionList._();
  @$core.pragma('dart2js:noInline')
  static SessionList getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SessionList>(
          SessionList.$_createMessage);
  static SessionList? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get mode => $_getSZ(0);
  @$pb.TagNumber(1)
  set mode($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMode() => $_has(0);
  @$pb.TagNumber(1)
  void clearMode() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<Session> get sessions => $_getList(1);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
