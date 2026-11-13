// This is a generated file - do not edit.
//
// Generated from infrastructure/developer/grpc/developer.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class ApiToken extends $pb.GeneratedMessage {
  factory ApiToken({
    $core.String? id,
    $core.String? name,
    $core.String? prefix,
    $core.Iterable<$core.String>? scopes,
    $core.String? status,
    $core.String? expiresAt,
    $core.String? lastUsedAt,
    $core.String? revokedAt,
    $core.String? createdAt,
  }) {
    final result = ApiToken._();
    if (id != null) result.id = id;
    if (name != null) result.name = name;
    if (prefix != null) result.prefix = prefix;
    if (scopes != null) result.scopes.addAll(scopes);
    if (status != null) result.status = status;
    if (expiresAt != null) result.expiresAt = expiresAt;
    if (lastUsedAt != null) result.lastUsedAt = lastUsedAt;
    if (revokedAt != null) result.revokedAt = revokedAt;
    if (createdAt != null) result.createdAt = createdAt;
    return result;
  }

  ApiToken._();

  factory ApiToken.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ApiToken()..mergeFromBuffer(data, registry);
  factory ApiToken.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ApiToken()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ApiToken',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.developer'),
      createEmptyInstance: ApiToken.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOS(3, _omitFieldNames ? '' : 'prefix')
    ..pPS(4, _omitFieldNames ? '' : 'scopes')
    ..aOS(5, _omitFieldNames ? '' : 'status')
    ..aOS(6, _omitFieldNames ? '' : 'expiresAt')
    ..aOS(7, _omitFieldNames ? '' : 'lastUsedAt')
    ..aOS(8, _omitFieldNames ? '' : 'revokedAt')
    ..aOS(9, _omitFieldNames ? '' : 'createdAt')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ApiToken clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ApiToken copyWith(void Function(ApiToken) updates) =>
      super.copyWith((message) => updates(message as ApiToken)) as ApiToken;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ApiToken() / ApiToken.new instead')
  static ApiToken create() => ApiToken._();
  static $pb.GeneratedMessage $_createMessage() => ApiToken._();
  @$core.override
  ApiToken createEmptyInstance() => ApiToken._();
  @$core.pragma('dart2js:noInline')
  static ApiToken getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ApiToken>(ApiToken.$_createMessage);
  static ApiToken? _defaultInstance;

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
  $core.String get prefix => $_getSZ(2);
  @$pb.TagNumber(3)
  set prefix($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPrefix() => $_has(2);
  @$pb.TagNumber(3)
  void clearPrefix() => $_clearField(3);

  @$pb.TagNumber(4)
  $pb.PbList<$core.String> get scopes => $_getList(3);

  @$pb.TagNumber(5)
  $core.String get status => $_getSZ(4);
  @$pb.TagNumber(5)
  set status($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasStatus() => $_has(4);
  @$pb.TagNumber(5)
  void clearStatus() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get expiresAt => $_getSZ(5);
  @$pb.TagNumber(6)
  set expiresAt($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasExpiresAt() => $_has(5);
  @$pb.TagNumber(6)
  void clearExpiresAt() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get lastUsedAt => $_getSZ(6);
  @$pb.TagNumber(7)
  set lastUsedAt($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasLastUsedAt() => $_has(6);
  @$pb.TagNumber(7)
  void clearLastUsedAt() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get revokedAt => $_getSZ(7);
  @$pb.TagNumber(8)
  set revokedAt($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasRevokedAt() => $_has(7);
  @$pb.TagNumber(8)
  void clearRevokedAt() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get createdAt => $_getSZ(8);
  @$pb.TagNumber(9)
  set createdAt($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasCreatedAt() => $_has(8);
  @$pb.TagNumber(9)
  void clearCreatedAt() => $_clearField(9);
}

class ApiTokenAnswer extends $pb.GeneratedMessage {
  factory ApiTokenAnswer({
    ApiToken? token,
  }) {
    final result = ApiTokenAnswer._();
    if (token != null) result.token = token;
    return result;
  }

  ApiTokenAnswer._();

  factory ApiTokenAnswer.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ApiTokenAnswer()..mergeFromBuffer(data, registry);
  factory ApiTokenAnswer.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ApiTokenAnswer()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ApiTokenAnswer',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.developer'),
      createEmptyInstance: ApiTokenAnswer.$_createMessage)
    ..aOM<ApiToken>(1, _omitFieldNames ? '' : 'token',
        subBuilder: ApiToken.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ApiTokenAnswer clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ApiTokenAnswer copyWith(void Function(ApiTokenAnswer) updates) =>
      super.copyWith((message) => updates(message as ApiTokenAnswer))
          as ApiTokenAnswer;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ApiTokenAnswer() / ApiTokenAnswer.new instead')
  static ApiTokenAnswer create() => ApiTokenAnswer._();
  static $pb.GeneratedMessage $_createMessage() => ApiTokenAnswer._();
  @$core.override
  ApiTokenAnswer createEmptyInstance() => ApiTokenAnswer._();
  @$core.pragma('dart2js:noInline')
  static ApiTokenAnswer getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ApiTokenAnswer>(
          ApiTokenAnswer.$_createMessage);
  static ApiTokenAnswer? _defaultInstance;

  @$pb.TagNumber(1)
  ApiToken get token => $_getN(0);
  @$pb.TagNumber(1)
  set token(ApiToken value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasToken() => $_has(0);
  @$pb.TagNumber(1)
  void clearToken() => $_clearField(1);
  @$pb.TagNumber(1)
  ApiToken ensureToken() => $_ensure(0);
}

class ApiTokenCreateRequest extends $pb.GeneratedMessage {
  factory ApiTokenCreateRequest({
    $core.String? workspaceId,
    $core.String? name,
    $core.Iterable<$core.String>? scopes,
    $core.int? expiresInDays,
  }) {
    final result = ApiTokenCreateRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (name != null) result.name = name;
    if (scopes != null) result.scopes.addAll(scopes);
    if (expiresInDays != null) result.expiresInDays = expiresInDays;
    return result;
  }

  ApiTokenCreateRequest._();

  factory ApiTokenCreateRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ApiTokenCreateRequest()..mergeFromBuffer(data, registry);
  factory ApiTokenCreateRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ApiTokenCreateRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ApiTokenCreateRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.developer'),
      createEmptyInstance: ApiTokenCreateRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..pPS(3, _omitFieldNames ? '' : 'scopes')
    ..aI(4, _omitFieldNames ? '' : 'expiresInDays')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ApiTokenCreateRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ApiTokenCreateRequest copyWith(
          void Function(ApiTokenCreateRequest) updates) =>
      super.copyWith((message) => updates(message as ApiTokenCreateRequest))
          as ApiTokenCreateRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ApiTokenCreateRequest() / ApiTokenCreateRequest.new instead')
  static ApiTokenCreateRequest create() => ApiTokenCreateRequest._();
  static $pb.GeneratedMessage $_createMessage() => ApiTokenCreateRequest._();
  @$core.override
  ApiTokenCreateRequest createEmptyInstance() => ApiTokenCreateRequest._();
  @$core.pragma('dart2js:noInline')
  static ApiTokenCreateRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ApiTokenCreateRequest>(
          ApiTokenCreateRequest.$_createMessage);
  static ApiTokenCreateRequest? _defaultInstance;

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
  $pb.PbList<$core.String> get scopes => $_getList(2);

  @$pb.TagNumber(4)
  $core.int get expiresInDays => $_getIZ(3);
  @$pb.TagNumber(4)
  set expiresInDays($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasExpiresInDays() => $_has(3);
  @$pb.TagNumber(4)
  void clearExpiresInDays() => $_clearField(4);
}

class ApiTokenCreated extends $pb.GeneratedMessage {
  factory ApiTokenCreated({
    ApiToken? token,
    $core.String? secret,
  }) {
    final result = ApiTokenCreated._();
    if (token != null) result.token = token;
    if (secret != null) result.secret = secret;
    return result;
  }

  ApiTokenCreated._();

  factory ApiTokenCreated.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ApiTokenCreated()..mergeFromBuffer(data, registry);
  factory ApiTokenCreated.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ApiTokenCreated()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ApiTokenCreated',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.developer'),
      createEmptyInstance: ApiTokenCreated.$_createMessage)
    ..aOM<ApiToken>(1, _omitFieldNames ? '' : 'token',
        subBuilder: ApiToken.$_createMessage)
    ..aOS(2, _omitFieldNames ? '' : 'secret')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ApiTokenCreated clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ApiTokenCreated copyWith(void Function(ApiTokenCreated) updates) =>
      super.copyWith((message) => updates(message as ApiTokenCreated))
          as ApiTokenCreated;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ApiTokenCreated() / ApiTokenCreated.new instead')
  static ApiTokenCreated create() => ApiTokenCreated._();
  static $pb.GeneratedMessage $_createMessage() => ApiTokenCreated._();
  @$core.override
  ApiTokenCreated createEmptyInstance() => ApiTokenCreated._();
  @$core.pragma('dart2js:noInline')
  static ApiTokenCreated getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ApiTokenCreated>(
          ApiTokenCreated.$_createMessage);
  static ApiTokenCreated? _defaultInstance;

  @$pb.TagNumber(1)
  ApiToken get token => $_getN(0);
  @$pb.TagNumber(1)
  set token(ApiToken value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasToken() => $_has(0);
  @$pb.TagNumber(1)
  void clearToken() => $_clearField(1);
  @$pb.TagNumber(1)
  ApiToken ensureToken() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.String get secret => $_getSZ(1);
  @$pb.TagNumber(2)
  set secret($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSecret() => $_has(1);
  @$pb.TagNumber(2)
  void clearSecret() => $_clearField(2);
}

class ApiTokenList extends $pb.GeneratedMessage {
  factory ApiTokenList({
    $core.Iterable<ApiToken>? tokens,
  }) {
    final result = ApiTokenList._();
    if (tokens != null) result.tokens.addAll(tokens);
    return result;
  }

  ApiTokenList._();

  factory ApiTokenList.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ApiTokenList()..mergeFromBuffer(data, registry);
  factory ApiTokenList.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ApiTokenList()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ApiTokenList',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.developer'),
      createEmptyInstance: ApiTokenList.$_createMessage)
    ..pPM<ApiToken>(1, _omitFieldNames ? '' : 'tokens',
        subBuilder: ApiToken.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ApiTokenList clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ApiTokenList copyWith(void Function(ApiTokenList) updates) =>
      super.copyWith((message) => updates(message as ApiTokenList))
          as ApiTokenList;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ApiTokenList() / ApiTokenList.new instead')
  static ApiTokenList create() => ApiTokenList._();
  static $pb.GeneratedMessage $_createMessage() => ApiTokenList._();
  @$core.override
  ApiTokenList createEmptyInstance() => ApiTokenList._();
  @$core.pragma('dart2js:noInline')
  static ApiTokenList getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ApiTokenList>(
          ApiTokenList.$_createMessage);
  static ApiTokenList? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<ApiToken> get tokens => $_getList(0);
}

class ApiTokenListRequest extends $pb.GeneratedMessage {
  factory ApiTokenListRequest({
    $core.String? workspaceId,
  }) {
    final result = ApiTokenListRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    return result;
  }

  ApiTokenListRequest._();

  factory ApiTokenListRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ApiTokenListRequest()..mergeFromBuffer(data, registry);
  factory ApiTokenListRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ApiTokenListRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ApiTokenListRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.developer'),
      createEmptyInstance: ApiTokenListRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ApiTokenListRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ApiTokenListRequest copyWith(void Function(ApiTokenListRequest) updates) =>
      super.copyWith((message) => updates(message as ApiTokenListRequest))
          as ApiTokenListRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core
      .Deprecated('Use ApiTokenListRequest() / ApiTokenListRequest.new instead')
  static ApiTokenListRequest create() => ApiTokenListRequest._();
  static $pb.GeneratedMessage $_createMessage() => ApiTokenListRequest._();
  @$core.override
  ApiTokenListRequest createEmptyInstance() => ApiTokenListRequest._();
  @$core.pragma('dart2js:noInline')
  static ApiTokenListRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ApiTokenListRequest>(
          ApiTokenListRequest.$_createMessage);
  static ApiTokenListRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);
}

class ApiTokenRevokeRequest extends $pb.GeneratedMessage {
  factory ApiTokenRevokeRequest({
    $core.String? workspaceId,
    $core.String? tokenId,
  }) {
    final result = ApiTokenRevokeRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (tokenId != null) result.tokenId = tokenId;
    return result;
  }

  ApiTokenRevokeRequest._();

  factory ApiTokenRevokeRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ApiTokenRevokeRequest()..mergeFromBuffer(data, registry);
  factory ApiTokenRevokeRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ApiTokenRevokeRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ApiTokenRevokeRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.developer'),
      createEmptyInstance: ApiTokenRevokeRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'tokenId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ApiTokenRevokeRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ApiTokenRevokeRequest copyWith(
          void Function(ApiTokenRevokeRequest) updates) =>
      super.copyWith((message) => updates(message as ApiTokenRevokeRequest))
          as ApiTokenRevokeRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ApiTokenRevokeRequest() / ApiTokenRevokeRequest.new instead')
  static ApiTokenRevokeRequest create() => ApiTokenRevokeRequest._();
  static $pb.GeneratedMessage $_createMessage() => ApiTokenRevokeRequest._();
  @$core.override
  ApiTokenRevokeRequest createEmptyInstance() => ApiTokenRevokeRequest._();
  @$core.pragma('dart2js:noInline')
  static ApiTokenRevokeRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ApiTokenRevokeRequest>(
          ApiTokenRevokeRequest.$_createMessage);
  static ApiTokenRevokeRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get tokenId => $_getSZ(1);
  @$pb.TagNumber(2)
  set tokenId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTokenId() => $_has(1);
  @$pb.TagNumber(2)
  void clearTokenId() => $_clearField(2);
}

class CatalogAnswer extends $pb.GeneratedMessage {
  factory CatalogAnswer({
    $core.Iterable<CatalogItem>? scopes,
    $core.Iterable<CatalogItem>? events,
  }) {
    final result = CatalogAnswer._();
    if (scopes != null) result.scopes.addAll(scopes);
    if (events != null) result.events.addAll(events);
    return result;
  }

  CatalogAnswer._();

  factory CatalogAnswer.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CatalogAnswer()..mergeFromBuffer(data, registry);
  factory CatalogAnswer.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CatalogAnswer()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CatalogAnswer',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.developer'),
      createEmptyInstance: CatalogAnswer.$_createMessage)
    ..pPM<CatalogItem>(1, _omitFieldNames ? '' : 'scopes',
        subBuilder: CatalogItem.$_createMessage)
    ..pPM<CatalogItem>(2, _omitFieldNames ? '' : 'events',
        subBuilder: CatalogItem.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CatalogAnswer clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CatalogAnswer copyWith(void Function(CatalogAnswer) updates) =>
      super.copyWith((message) => updates(message as CatalogAnswer))
          as CatalogAnswer;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CatalogAnswer() / CatalogAnswer.new instead')
  static CatalogAnswer create() => CatalogAnswer._();
  static $pb.GeneratedMessage $_createMessage() => CatalogAnswer._();
  @$core.override
  CatalogAnswer createEmptyInstance() => CatalogAnswer._();
  @$core.pragma('dart2js:noInline')
  static CatalogAnswer getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CatalogAnswer>(
          CatalogAnswer.$_createMessage);
  static CatalogAnswer? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<CatalogItem> get scopes => $_getList(0);

  @$pb.TagNumber(2)
  $pb.PbList<CatalogItem> get events => $_getList(1);
}

class CatalogItem extends $pb.GeneratedMessage {
  factory CatalogItem({
    $core.String? key,
    $core.String? label,
  }) {
    final result = CatalogItem._();
    if (key != null) result.key = key;
    if (label != null) result.label = label;
    return result;
  }

  CatalogItem._();

  factory CatalogItem.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CatalogItem()..mergeFromBuffer(data, registry);
  factory CatalogItem.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CatalogItem()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CatalogItem',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.developer'),
      createEmptyInstance: CatalogItem.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'key')
    ..aOS(2, _omitFieldNames ? '' : 'label')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CatalogItem clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CatalogItem copyWith(void Function(CatalogItem) updates) =>
      super.copyWith((message) => updates(message as CatalogItem))
          as CatalogItem;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CatalogItem() / CatalogItem.new instead')
  static CatalogItem create() => CatalogItem._();
  static $pb.GeneratedMessage $_createMessage() => CatalogItem._();
  @$core.override
  CatalogItem createEmptyInstance() => CatalogItem._();
  @$core.pragma('dart2js:noInline')
  static CatalogItem getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CatalogItem>(
          CatalogItem.$_createMessage);
  static CatalogItem? _defaultInstance;

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
}

class CatalogRequest extends $pb.GeneratedMessage {
  factory CatalogRequest({
    $core.String? workspaceId,
  }) {
    final result = CatalogRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    return result;
  }

  CatalogRequest._();

  factory CatalogRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CatalogRequest()..mergeFromBuffer(data, registry);
  factory CatalogRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CatalogRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CatalogRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.developer'),
      createEmptyInstance: CatalogRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CatalogRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CatalogRequest copyWith(void Function(CatalogRequest) updates) =>
      super.copyWith((message) => updates(message as CatalogRequest))
          as CatalogRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CatalogRequest() / CatalogRequest.new instead')
  static CatalogRequest create() => CatalogRequest._();
  static $pb.GeneratedMessage $_createMessage() => CatalogRequest._();
  @$core.override
  CatalogRequest createEmptyInstance() => CatalogRequest._();
  @$core.pragma('dart2js:noInline')
  static CatalogRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CatalogRequest>(
          CatalogRequest.$_createMessage);
  static CatalogRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);
}

class DeliveriesRequest extends $pb.GeneratedMessage {
  factory DeliveriesRequest({
    $core.String? workspaceId,
    $core.String? webhookId,
    $core.String? before,
    $core.int? limit,
  }) {
    final result = DeliveriesRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (webhookId != null) result.webhookId = webhookId;
    if (before != null) result.before = before;
    if (limit != null) result.limit = limit;
    return result;
  }

  DeliveriesRequest._();

  factory DeliveriesRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DeliveriesRequest()..mergeFromBuffer(data, registry);
  factory DeliveriesRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DeliveriesRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeliveriesRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.developer'),
      createEmptyInstance: DeliveriesRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'webhookId')
    ..aOS(3, _omitFieldNames ? '' : 'before')
    ..aI(4, _omitFieldNames ? '' : 'limit')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeliveriesRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeliveriesRequest copyWith(void Function(DeliveriesRequest) updates) =>
      super.copyWith((message) => updates(message as DeliveriesRequest))
          as DeliveriesRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use DeliveriesRequest() / DeliveriesRequest.new instead')
  static DeliveriesRequest create() => DeliveriesRequest._();
  static $pb.GeneratedMessage $_createMessage() => DeliveriesRequest._();
  @$core.override
  DeliveriesRequest createEmptyInstance() => DeliveriesRequest._();
  @$core.pragma('dart2js:noInline')
  static DeliveriesRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DeliveriesRequest>(
          DeliveriesRequest.$_createMessage);
  static DeliveriesRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get webhookId => $_getSZ(1);
  @$pb.TagNumber(2)
  set webhookId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasWebhookId() => $_has(1);
  @$pb.TagNumber(2)
  void clearWebhookId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get before => $_getSZ(2);
  @$pb.TagNumber(3)
  set before($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasBefore() => $_has(2);
  @$pb.TagNumber(3)
  void clearBefore() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get limit => $_getIZ(3);
  @$pb.TagNumber(4)
  set limit($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasLimit() => $_has(3);
  @$pb.TagNumber(4)
  void clearLimit() => $_clearField(4);
}

class Delivery extends $pb.GeneratedMessage {
  factory Delivery({
    $core.String? id,
    $core.String? webhookId,
    $core.String? event,
    $core.String? eventId,
    $core.String? status,
    $core.int? statusCode,
    $core.int? attempt,
    $core.String? error,
    $core.String? responseSnippet,
    $core.String? payloadJson,
    $core.String? requestHeadersJson,
    $core.String? nextRetryAt,
    $core.String? createdAt,
    $core.String? at,
    $core.int? durationMs,
    $core.String? resendOf,
  }) {
    final result = Delivery._();
    if (id != null) result.id = id;
    if (webhookId != null) result.webhookId = webhookId;
    if (event != null) result.event = event;
    if (eventId != null) result.eventId = eventId;
    if (status != null) result.status = status;
    if (statusCode != null) result.statusCode = statusCode;
    if (attempt != null) result.attempt = attempt;
    if (error != null) result.error = error;
    if (responseSnippet != null) result.responseSnippet = responseSnippet;
    if (payloadJson != null) result.payloadJson = payloadJson;
    if (requestHeadersJson != null)
      result.requestHeadersJson = requestHeadersJson;
    if (nextRetryAt != null) result.nextRetryAt = nextRetryAt;
    if (createdAt != null) result.createdAt = createdAt;
    if (at != null) result.at = at;
    if (durationMs != null) result.durationMs = durationMs;
    if (resendOf != null) result.resendOf = resendOf;
    return result;
  }

  Delivery._();

  factory Delivery.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Delivery()..mergeFromBuffer(data, registry);
  factory Delivery.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Delivery()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Delivery',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.developer'),
      createEmptyInstance: Delivery.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'webhookId')
    ..aOS(3, _omitFieldNames ? '' : 'event')
    ..aOS(4, _omitFieldNames ? '' : 'eventId')
    ..aOS(5, _omitFieldNames ? '' : 'status')
    ..aI(6, _omitFieldNames ? '' : 'statusCode')
    ..aI(7, _omitFieldNames ? '' : 'attempt')
    ..aOS(8, _omitFieldNames ? '' : 'error')
    ..aOS(9, _omitFieldNames ? '' : 'responseSnippet')
    ..aOS(10, _omitFieldNames ? '' : 'payloadJson')
    ..aOS(11, _omitFieldNames ? '' : 'requestHeadersJson')
    ..aOS(12, _omitFieldNames ? '' : 'nextRetryAt')
    ..aOS(13, _omitFieldNames ? '' : 'createdAt')
    ..aOS(14, _omitFieldNames ? '' : 'at')
    ..aI(15, _omitFieldNames ? '' : 'durationMs')
    ..aOS(16, _omitFieldNames ? '' : 'resendOf')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Delivery clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Delivery copyWith(void Function(Delivery) updates) =>
      super.copyWith((message) => updates(message as Delivery)) as Delivery;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Delivery() / Delivery.new instead')
  static Delivery create() => Delivery._();
  static $pb.GeneratedMessage $_createMessage() => Delivery._();
  @$core.override
  Delivery createEmptyInstance() => Delivery._();
  @$core.pragma('dart2js:noInline')
  static Delivery getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Delivery>(Delivery.$_createMessage);
  static Delivery? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get webhookId => $_getSZ(1);
  @$pb.TagNumber(2)
  set webhookId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasWebhookId() => $_has(1);
  @$pb.TagNumber(2)
  void clearWebhookId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get event => $_getSZ(2);
  @$pb.TagNumber(3)
  set event($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasEvent() => $_has(2);
  @$pb.TagNumber(3)
  void clearEvent() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get eventId => $_getSZ(3);
  @$pb.TagNumber(4)
  set eventId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasEventId() => $_has(3);
  @$pb.TagNumber(4)
  void clearEventId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get status => $_getSZ(4);
  @$pb.TagNumber(5)
  set status($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasStatus() => $_has(4);
  @$pb.TagNumber(5)
  void clearStatus() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get statusCode => $_getIZ(5);
  @$pb.TagNumber(6)
  set statusCode($core.int value) => $_setSignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasStatusCode() => $_has(5);
  @$pb.TagNumber(6)
  void clearStatusCode() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.int get attempt => $_getIZ(6);
  @$pb.TagNumber(7)
  set attempt($core.int value) => $_setSignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasAttempt() => $_has(6);
  @$pb.TagNumber(7)
  void clearAttempt() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get error => $_getSZ(7);
  @$pb.TagNumber(8)
  set error($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasError() => $_has(7);
  @$pb.TagNumber(8)
  void clearError() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get responseSnippet => $_getSZ(8);
  @$pb.TagNumber(9)
  set responseSnippet($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasResponseSnippet() => $_has(8);
  @$pb.TagNumber(9)
  void clearResponseSnippet() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get payloadJson => $_getSZ(9);
  @$pb.TagNumber(10)
  set payloadJson($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasPayloadJson() => $_has(9);
  @$pb.TagNumber(10)
  void clearPayloadJson() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.String get requestHeadersJson => $_getSZ(10);
  @$pb.TagNumber(11)
  set requestHeadersJson($core.String value) => $_setString(10, value);
  @$pb.TagNumber(11)
  $core.bool hasRequestHeadersJson() => $_has(10);
  @$pb.TagNumber(11)
  void clearRequestHeadersJson() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.String get nextRetryAt => $_getSZ(11);
  @$pb.TagNumber(12)
  set nextRetryAt($core.String value) => $_setString(11, value);
  @$pb.TagNumber(12)
  $core.bool hasNextRetryAt() => $_has(11);
  @$pb.TagNumber(12)
  void clearNextRetryAt() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.String get createdAt => $_getSZ(12);
  @$pb.TagNumber(13)
  set createdAt($core.String value) => $_setString(12, value);
  @$pb.TagNumber(13)
  $core.bool hasCreatedAt() => $_has(12);
  @$pb.TagNumber(13)
  void clearCreatedAt() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.String get at => $_getSZ(13);
  @$pb.TagNumber(14)
  set at($core.String value) => $_setString(13, value);
  @$pb.TagNumber(14)
  $core.bool hasAt() => $_has(13);
  @$pb.TagNumber(14)
  void clearAt() => $_clearField(14);

  @$pb.TagNumber(15)
  $core.int get durationMs => $_getIZ(14);
  @$pb.TagNumber(15)
  set durationMs($core.int value) => $_setSignedInt32(14, value);
  @$pb.TagNumber(15)
  $core.bool hasDurationMs() => $_has(14);
  @$pb.TagNumber(15)
  void clearDurationMs() => $_clearField(15);

  @$pb.TagNumber(16)
  $core.String get resendOf => $_getSZ(15);
  @$pb.TagNumber(16)
  set resendOf($core.String value) => $_setString(15, value);
  @$pb.TagNumber(16)
  $core.bool hasResendOf() => $_has(15);
  @$pb.TagNumber(16)
  void clearResendOf() => $_clearField(16);
}

class DeliveryAnswer extends $pb.GeneratedMessage {
  factory DeliveryAnswer({
    Delivery? delivery,
  }) {
    final result = DeliveryAnswer._();
    if (delivery != null) result.delivery = delivery;
    return result;
  }

  DeliveryAnswer._();

  factory DeliveryAnswer.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DeliveryAnswer()..mergeFromBuffer(data, registry);
  factory DeliveryAnswer.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DeliveryAnswer()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeliveryAnswer',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.developer'),
      createEmptyInstance: DeliveryAnswer.$_createMessage)
    ..aOM<Delivery>(1, _omitFieldNames ? '' : 'delivery',
        subBuilder: Delivery.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeliveryAnswer clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeliveryAnswer copyWith(void Function(DeliveryAnswer) updates) =>
      super.copyWith((message) => updates(message as DeliveryAnswer))
          as DeliveryAnswer;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use DeliveryAnswer() / DeliveryAnswer.new instead')
  static DeliveryAnswer create() => DeliveryAnswer._();
  static $pb.GeneratedMessage $_createMessage() => DeliveryAnswer._();
  @$core.override
  DeliveryAnswer createEmptyInstance() => DeliveryAnswer._();
  @$core.pragma('dart2js:noInline')
  static DeliveryAnswer getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DeliveryAnswer>(
          DeliveryAnswer.$_createMessage);
  static DeliveryAnswer? _defaultInstance;

  @$pb.TagNumber(1)
  Delivery get delivery => $_getN(0);
  @$pb.TagNumber(1)
  set delivery(Delivery value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasDelivery() => $_has(0);
  @$pb.TagNumber(1)
  void clearDelivery() => $_clearField(1);
  @$pb.TagNumber(1)
  Delivery ensureDelivery() => $_ensure(0);
}

class DeliveryList extends $pb.GeneratedMessage {
  factory DeliveryList({
    $core.Iterable<Delivery>? deliveries,
    $core.String? cursor,
  }) {
    final result = DeliveryList._();
    if (deliveries != null) result.deliveries.addAll(deliveries);
    if (cursor != null) result.cursor = cursor;
    return result;
  }

  DeliveryList._();

  factory DeliveryList.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DeliveryList()..mergeFromBuffer(data, registry);
  factory DeliveryList.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DeliveryList()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeliveryList',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.developer'),
      createEmptyInstance: DeliveryList.$_createMessage)
    ..pPM<Delivery>(1, _omitFieldNames ? '' : 'deliveries',
        subBuilder: Delivery.$_createMessage)
    ..aOS(2, _omitFieldNames ? '' : 'cursor')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeliveryList clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeliveryList copyWith(void Function(DeliveryList) updates) =>
      super.copyWith((message) => updates(message as DeliveryList))
          as DeliveryList;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use DeliveryList() / DeliveryList.new instead')
  static DeliveryList create() => DeliveryList._();
  static $pb.GeneratedMessage $_createMessage() => DeliveryList._();
  @$core.override
  DeliveryList createEmptyInstance() => DeliveryList._();
  @$core.pragma('dart2js:noInline')
  static DeliveryList getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DeliveryList>(
          DeliveryList.$_createMessage);
  static DeliveryList? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Delivery> get deliveries => $_getList(0);

  @$pb.TagNumber(2)
  $core.String get cursor => $_getSZ(1);
  @$pb.TagNumber(2)
  set cursor($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCursor() => $_has(1);
  @$pb.TagNumber(2)
  void clearCursor() => $_clearField(2);
}

class RedeliverRequest extends $pb.GeneratedMessage {
  factory RedeliverRequest({
    $core.String? workspaceId,
    $core.String? webhookId,
    $core.String? deliveryId,
  }) {
    final result = RedeliverRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (webhookId != null) result.webhookId = webhookId;
    if (deliveryId != null) result.deliveryId = deliveryId;
    return result;
  }

  RedeliverRequest._();

  factory RedeliverRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RedeliverRequest()..mergeFromBuffer(data, registry);
  factory RedeliverRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RedeliverRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RedeliverRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.developer'),
      createEmptyInstance: RedeliverRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'webhookId')
    ..aOS(3, _omitFieldNames ? '' : 'deliveryId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RedeliverRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RedeliverRequest copyWith(void Function(RedeliverRequest) updates) =>
      super.copyWith((message) => updates(message as RedeliverRequest))
          as RedeliverRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use RedeliverRequest() / RedeliverRequest.new instead')
  static RedeliverRequest create() => RedeliverRequest._();
  static $pb.GeneratedMessage $_createMessage() => RedeliverRequest._();
  @$core.override
  RedeliverRequest createEmptyInstance() => RedeliverRequest._();
  @$core.pragma('dart2js:noInline')
  static RedeliverRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RedeliverRequest>(
          RedeliverRequest.$_createMessage);
  static RedeliverRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get webhookId => $_getSZ(1);
  @$pb.TagNumber(2)
  set webhookId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasWebhookId() => $_has(1);
  @$pb.TagNumber(2)
  void clearWebhookId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get deliveryId => $_getSZ(2);
  @$pb.TagNumber(3)
  set deliveryId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDeliveryId() => $_has(2);
  @$pb.TagNumber(3)
  void clearDeliveryId() => $_clearField(3);
}

class Webhook extends $pb.GeneratedMessage {
  factory Webhook({
    $core.String? id,
    $core.String? workspaceId,
    $core.String? projectId,
    $core.String? name,
    $core.String? url,
    $core.String? secret,
    $core.Iterable<$core.String>? events,
    $core.bool? active,
    $core.String? disabledReason,
    $core.int? version,
    $core.String? createdAt,
    $core.String? lastStatus,
    $core.String? lastAt,
  }) {
    final result = Webhook._();
    if (id != null) result.id = id;
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (projectId != null) result.projectId = projectId;
    if (name != null) result.name = name;
    if (url != null) result.url = url;
    if (secret != null) result.secret = secret;
    if (events != null) result.events.addAll(events);
    if (active != null) result.active = active;
    if (disabledReason != null) result.disabledReason = disabledReason;
    if (version != null) result.version = version;
    if (createdAt != null) result.createdAt = createdAt;
    if (lastStatus != null) result.lastStatus = lastStatus;
    if (lastAt != null) result.lastAt = lastAt;
    return result;
  }

  Webhook._();

  factory Webhook.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Webhook()..mergeFromBuffer(data, registry);
  factory Webhook.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Webhook()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Webhook',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.developer'),
      createEmptyInstance: Webhook.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(3, _omitFieldNames ? '' : 'projectId')
    ..aOS(4, _omitFieldNames ? '' : 'name')
    ..aOS(5, _omitFieldNames ? '' : 'url')
    ..aOS(6, _omitFieldNames ? '' : 'secret')
    ..pPS(7, _omitFieldNames ? '' : 'events')
    ..aOB(8, _omitFieldNames ? '' : 'active')
    ..aOS(9, _omitFieldNames ? '' : 'disabledReason')
    ..aI(10, _omitFieldNames ? '' : 'version')
    ..aOS(11, _omitFieldNames ? '' : 'createdAt')
    ..aOS(12, _omitFieldNames ? '' : 'lastStatus')
    ..aOS(13, _omitFieldNames ? '' : 'lastAt')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Webhook clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Webhook copyWith(void Function(Webhook) updates) =>
      super.copyWith((message) => updates(message as Webhook)) as Webhook;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Webhook() / Webhook.new instead')
  static Webhook create() => Webhook._();
  static $pb.GeneratedMessage $_createMessage() => Webhook._();
  @$core.override
  Webhook createEmptyInstance() => Webhook._();
  @$core.pragma('dart2js:noInline')
  static Webhook getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Webhook>(Webhook.$_createMessage);
  static Webhook? _defaultInstance;

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
  $core.String get url => $_getSZ(4);
  @$pb.TagNumber(5)
  set url($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasUrl() => $_has(4);
  @$pb.TagNumber(5)
  void clearUrl() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get secret => $_getSZ(5);
  @$pb.TagNumber(6)
  set secret($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasSecret() => $_has(5);
  @$pb.TagNumber(6)
  void clearSecret() => $_clearField(6);

  @$pb.TagNumber(7)
  $pb.PbList<$core.String> get events => $_getList(6);

  @$pb.TagNumber(8)
  $core.bool get active => $_getBF(7);
  @$pb.TagNumber(8)
  set active($core.bool value) => $_setBool(7, value);
  @$pb.TagNumber(8)
  $core.bool hasActive() => $_has(7);
  @$pb.TagNumber(8)
  void clearActive() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get disabledReason => $_getSZ(8);
  @$pb.TagNumber(9)
  set disabledReason($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasDisabledReason() => $_has(8);
  @$pb.TagNumber(9)
  void clearDisabledReason() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.int get version => $_getIZ(9);
  @$pb.TagNumber(10)
  set version($core.int value) => $_setSignedInt32(9, value);
  @$pb.TagNumber(10)
  $core.bool hasVersion() => $_has(9);
  @$pb.TagNumber(10)
  void clearVersion() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.String get createdAt => $_getSZ(10);
  @$pb.TagNumber(11)
  set createdAt($core.String value) => $_setString(10, value);
  @$pb.TagNumber(11)
  $core.bool hasCreatedAt() => $_has(10);
  @$pb.TagNumber(11)
  void clearCreatedAt() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.String get lastStatus => $_getSZ(11);
  @$pb.TagNumber(12)
  set lastStatus($core.String value) => $_setString(11, value);
  @$pb.TagNumber(12)
  $core.bool hasLastStatus() => $_has(11);
  @$pb.TagNumber(12)
  void clearLastStatus() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.String get lastAt => $_getSZ(12);
  @$pb.TagNumber(13)
  set lastAt($core.String value) => $_setString(12, value);
  @$pb.TagNumber(13)
  $core.bool hasLastAt() => $_has(12);
  @$pb.TagNumber(13)
  void clearLastAt() => $_clearField(13);
}

class WebhookAnswer extends $pb.GeneratedMessage {
  factory WebhookAnswer({
    Webhook? webhook,
  }) {
    final result = WebhookAnswer._();
    if (webhook != null) result.webhook = webhook;
    return result;
  }

  WebhookAnswer._();

  factory WebhookAnswer.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WebhookAnswer()..mergeFromBuffer(data, registry);
  factory WebhookAnswer.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WebhookAnswer()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WebhookAnswer',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.developer'),
      createEmptyInstance: WebhookAnswer.$_createMessage)
    ..aOM<Webhook>(1, _omitFieldNames ? '' : 'webhook',
        subBuilder: Webhook.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WebhookAnswer clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WebhookAnswer copyWith(void Function(WebhookAnswer) updates) =>
      super.copyWith((message) => updates(message as WebhookAnswer))
          as WebhookAnswer;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use WebhookAnswer() / WebhookAnswer.new instead')
  static WebhookAnswer create() => WebhookAnswer._();
  static $pb.GeneratedMessage $_createMessage() => WebhookAnswer._();
  @$core.override
  WebhookAnswer createEmptyInstance() => WebhookAnswer._();
  @$core.pragma('dart2js:noInline')
  static WebhookAnswer getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<WebhookAnswer>(
          WebhookAnswer.$_createMessage);
  static WebhookAnswer? _defaultInstance;

  @$pb.TagNumber(1)
  Webhook get webhook => $_getN(0);
  @$pb.TagNumber(1)
  set webhook(Webhook value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasWebhook() => $_has(0);
  @$pb.TagNumber(1)
  void clearWebhook() => $_clearField(1);
  @$pb.TagNumber(1)
  Webhook ensureWebhook() => $_ensure(0);
}

class WebhookCreateRequest extends $pb.GeneratedMessage {
  factory WebhookCreateRequest({
    $core.String? workspaceId,
    $core.String? name,
    $core.String? url,
    $core.Iterable<$core.String>? events,
    $core.String? projectId,
  }) {
    final result = WebhookCreateRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (name != null) result.name = name;
    if (url != null) result.url = url;
    if (events != null) result.events.addAll(events);
    if (projectId != null) result.projectId = projectId;
    return result;
  }

  WebhookCreateRequest._();

  factory WebhookCreateRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WebhookCreateRequest()..mergeFromBuffer(data, registry);
  factory WebhookCreateRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WebhookCreateRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WebhookCreateRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.developer'),
      createEmptyInstance: WebhookCreateRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOS(3, _omitFieldNames ? '' : 'url')
    ..pPS(4, _omitFieldNames ? '' : 'events')
    ..aOS(5, _omitFieldNames ? '' : 'projectId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WebhookCreateRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WebhookCreateRequest copyWith(void Function(WebhookCreateRequest) updates) =>
      super.copyWith((message) => updates(message as WebhookCreateRequest))
          as WebhookCreateRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use WebhookCreateRequest() / WebhookCreateRequest.new instead')
  static WebhookCreateRequest create() => WebhookCreateRequest._();
  static $pb.GeneratedMessage $_createMessage() => WebhookCreateRequest._();
  @$core.override
  WebhookCreateRequest createEmptyInstance() => WebhookCreateRequest._();
  @$core.pragma('dart2js:noInline')
  static WebhookCreateRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WebhookCreateRequest>(
          WebhookCreateRequest.$_createMessage);
  static WebhookCreateRequest? _defaultInstance;

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
  $core.String get url => $_getSZ(2);
  @$pb.TagNumber(3)
  set url($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasUrl() => $_has(2);
  @$pb.TagNumber(3)
  void clearUrl() => $_clearField(3);

  @$pb.TagNumber(4)
  $pb.PbList<$core.String> get events => $_getList(3);

  @$pb.TagNumber(5)
  $core.String get projectId => $_getSZ(4);
  @$pb.TagNumber(5)
  set projectId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasProjectId() => $_has(4);
  @$pb.TagNumber(5)
  void clearProjectId() => $_clearField(5);
}

class WebhookDeleteRequest extends $pb.GeneratedMessage {
  factory WebhookDeleteRequest({
    $core.String? workspaceId,
    $core.String? webhookId,
  }) {
    final result = WebhookDeleteRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (webhookId != null) result.webhookId = webhookId;
    return result;
  }

  WebhookDeleteRequest._();

  factory WebhookDeleteRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WebhookDeleteRequest()..mergeFromBuffer(data, registry);
  factory WebhookDeleteRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WebhookDeleteRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WebhookDeleteRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.developer'),
      createEmptyInstance: WebhookDeleteRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'webhookId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WebhookDeleteRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WebhookDeleteRequest copyWith(void Function(WebhookDeleteRequest) updates) =>
      super.copyWith((message) => updates(message as WebhookDeleteRequest))
          as WebhookDeleteRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use WebhookDeleteRequest() / WebhookDeleteRequest.new instead')
  static WebhookDeleteRequest create() => WebhookDeleteRequest._();
  static $pb.GeneratedMessage $_createMessage() => WebhookDeleteRequest._();
  @$core.override
  WebhookDeleteRequest createEmptyInstance() => WebhookDeleteRequest._();
  @$core.pragma('dart2js:noInline')
  static WebhookDeleteRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WebhookDeleteRequest>(
          WebhookDeleteRequest.$_createMessage);
  static WebhookDeleteRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get webhookId => $_getSZ(1);
  @$pb.TagNumber(2)
  set webhookId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasWebhookId() => $_has(1);
  @$pb.TagNumber(2)
  void clearWebhookId() => $_clearField(2);
}

class WebhookDeleted extends $pb.GeneratedMessage {
  factory WebhookDeleted({
    $core.String? id,
  }) {
    final result = WebhookDeleted._();
    if (id != null) result.id = id;
    return result;
  }

  WebhookDeleted._();

  factory WebhookDeleted.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WebhookDeleted()..mergeFromBuffer(data, registry);
  factory WebhookDeleted.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WebhookDeleted()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WebhookDeleted',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.developer'),
      createEmptyInstance: WebhookDeleted.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WebhookDeleted clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WebhookDeleted copyWith(void Function(WebhookDeleted) updates) =>
      super.copyWith((message) => updates(message as WebhookDeleted))
          as WebhookDeleted;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use WebhookDeleted() / WebhookDeleted.new instead')
  static WebhookDeleted create() => WebhookDeleted._();
  static $pb.GeneratedMessage $_createMessage() => WebhookDeleted._();
  @$core.override
  WebhookDeleted createEmptyInstance() => WebhookDeleted._();
  @$core.pragma('dart2js:noInline')
  static WebhookDeleted getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<WebhookDeleted>(
          WebhookDeleted.$_createMessage);
  static WebhookDeleted? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class WebhookList extends $pb.GeneratedMessage {
  factory WebhookList({
    $core.Iterable<Webhook>? webhooks,
  }) {
    final result = WebhookList._();
    if (webhooks != null) result.webhooks.addAll(webhooks);
    return result;
  }

  WebhookList._();

  factory WebhookList.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WebhookList()..mergeFromBuffer(data, registry);
  factory WebhookList.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WebhookList()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WebhookList',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.developer'),
      createEmptyInstance: WebhookList.$_createMessage)
    ..pPM<Webhook>(1, _omitFieldNames ? '' : 'webhooks',
        subBuilder: Webhook.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WebhookList clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WebhookList copyWith(void Function(WebhookList) updates) =>
      super.copyWith((message) => updates(message as WebhookList))
          as WebhookList;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use WebhookList() / WebhookList.new instead')
  static WebhookList create() => WebhookList._();
  static $pb.GeneratedMessage $_createMessage() => WebhookList._();
  @$core.override
  WebhookList createEmptyInstance() => WebhookList._();
  @$core.pragma('dart2js:noInline')
  static WebhookList getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<WebhookList>(
          WebhookList.$_createMessage);
  static WebhookList? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Webhook> get webhooks => $_getList(0);
}

class WebhookListRequest extends $pb.GeneratedMessage {
  factory WebhookListRequest({
    $core.String? workspaceId,
  }) {
    final result = WebhookListRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    return result;
  }

  WebhookListRequest._();

  factory WebhookListRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WebhookListRequest()..mergeFromBuffer(data, registry);
  factory WebhookListRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WebhookListRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WebhookListRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.developer'),
      createEmptyInstance: WebhookListRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WebhookListRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WebhookListRequest copyWith(void Function(WebhookListRequest) updates) =>
      super.copyWith((message) => updates(message as WebhookListRequest))
          as WebhookListRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use WebhookListRequest() / WebhookListRequest.new instead')
  static WebhookListRequest create() => WebhookListRequest._();
  static $pb.GeneratedMessage $_createMessage() => WebhookListRequest._();
  @$core.override
  WebhookListRequest createEmptyInstance() => WebhookListRequest._();
  @$core.pragma('dart2js:noInline')
  static WebhookListRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WebhookListRequest>(
          WebhookListRequest.$_createMessage);
  static WebhookListRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);
}

class WebhookTestRequest extends $pb.GeneratedMessage {
  factory WebhookTestRequest({
    $core.String? workspaceId,
    $core.String? webhookId,
  }) {
    final result = WebhookTestRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (webhookId != null) result.webhookId = webhookId;
    return result;
  }

  WebhookTestRequest._();

  factory WebhookTestRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WebhookTestRequest()..mergeFromBuffer(data, registry);
  factory WebhookTestRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WebhookTestRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WebhookTestRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.developer'),
      createEmptyInstance: WebhookTestRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'webhookId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WebhookTestRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WebhookTestRequest copyWith(void Function(WebhookTestRequest) updates) =>
      super.copyWith((message) => updates(message as WebhookTestRequest))
          as WebhookTestRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use WebhookTestRequest() / WebhookTestRequest.new instead')
  static WebhookTestRequest create() => WebhookTestRequest._();
  static $pb.GeneratedMessage $_createMessage() => WebhookTestRequest._();
  @$core.override
  WebhookTestRequest createEmptyInstance() => WebhookTestRequest._();
  @$core.pragma('dart2js:noInline')
  static WebhookTestRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WebhookTestRequest>(
          WebhookTestRequest.$_createMessage);
  static WebhookTestRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get webhookId => $_getSZ(1);
  @$pb.TagNumber(2)
  set webhookId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasWebhookId() => $_has(1);
  @$pb.TagNumber(2)
  void clearWebhookId() => $_clearField(2);
}

class WebhookUpdateRequest extends $pb.GeneratedMessage {
  factory WebhookUpdateRequest({
    $core.String? workspaceId,
    $core.String? webhookId,
    $core.Iterable<$core.String>? fields,
    $core.int? expectedVersion,
    $core.String? name,
    $core.String? url,
    $core.Iterable<$core.String>? events,
    $core.bool? active,
    $core.String? projectId,
  }) {
    final result = WebhookUpdateRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (webhookId != null) result.webhookId = webhookId;
    if (fields != null) result.fields.addAll(fields);
    if (expectedVersion != null) result.expectedVersion = expectedVersion;
    if (name != null) result.name = name;
    if (url != null) result.url = url;
    if (events != null) result.events.addAll(events);
    if (active != null) result.active = active;
    if (projectId != null) result.projectId = projectId;
    return result;
  }

  WebhookUpdateRequest._();

  factory WebhookUpdateRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WebhookUpdateRequest()..mergeFromBuffer(data, registry);
  factory WebhookUpdateRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WebhookUpdateRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WebhookUpdateRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.developer'),
      createEmptyInstance: WebhookUpdateRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'webhookId')
    ..pPS(3, _omitFieldNames ? '' : 'fields')
    ..aI(4, _omitFieldNames ? '' : 'expectedVersion')
    ..aOS(5, _omitFieldNames ? '' : 'name')
    ..aOS(6, _omitFieldNames ? '' : 'url')
    ..pPS(7, _omitFieldNames ? '' : 'events')
    ..aOB(8, _omitFieldNames ? '' : 'active')
    ..aOS(9, _omitFieldNames ? '' : 'projectId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WebhookUpdateRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WebhookUpdateRequest copyWith(void Function(WebhookUpdateRequest) updates) =>
      super.copyWith((message) => updates(message as WebhookUpdateRequest))
          as WebhookUpdateRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use WebhookUpdateRequest() / WebhookUpdateRequest.new instead')
  static WebhookUpdateRequest create() => WebhookUpdateRequest._();
  static $pb.GeneratedMessage $_createMessage() => WebhookUpdateRequest._();
  @$core.override
  WebhookUpdateRequest createEmptyInstance() => WebhookUpdateRequest._();
  @$core.pragma('dart2js:noInline')
  static WebhookUpdateRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WebhookUpdateRequest>(
          WebhookUpdateRequest.$_createMessage);
  static WebhookUpdateRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get webhookId => $_getSZ(1);
  @$pb.TagNumber(2)
  set webhookId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasWebhookId() => $_has(1);
  @$pb.TagNumber(2)
  void clearWebhookId() => $_clearField(2);

  @$pb.TagNumber(3)
  $pb.PbList<$core.String> get fields => $_getList(2);

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
  $core.String get url => $_getSZ(5);
  @$pb.TagNumber(6)
  set url($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasUrl() => $_has(5);
  @$pb.TagNumber(6)
  void clearUrl() => $_clearField(6);

  @$pb.TagNumber(7)
  $pb.PbList<$core.String> get events => $_getList(6);

  @$pb.TagNumber(8)
  $core.bool get active => $_getBF(7);
  @$pb.TagNumber(8)
  set active($core.bool value) => $_setBool(7, value);
  @$pb.TagNumber(8)
  $core.bool hasActive() => $_has(7);
  @$pb.TagNumber(8)
  void clearActive() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get projectId => $_getSZ(8);
  @$pb.TagNumber(9)
  set projectId($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasProjectId() => $_has(8);
  @$pb.TagNumber(9)
  void clearProjectId() => $_clearField(9);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
