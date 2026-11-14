// This is a generated file - do not edit.
//
// Generated from infrastructure/security/grpc/security.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class PolicyAnswer extends $pb.GeneratedMessage {
  factory PolicyAnswer({
    $core.bool? require2fa,
    $core.int? graceDays,
    $core.String? enforcedFrom,
    $core.bool? inGrace,
    $core.bool? enrolled,
    $core.bool? blocked,
    $core.int? version,
  }) {
    final result = PolicyAnswer._();
    if (require2fa != null) result.require2fa = require2fa;
    if (graceDays != null) result.graceDays = graceDays;
    if (enforcedFrom != null) result.enforcedFrom = enforcedFrom;
    if (inGrace != null) result.inGrace = inGrace;
    if (enrolled != null) result.enrolled = enrolled;
    if (blocked != null) result.blocked = blocked;
    if (version != null) result.version = version;
    return result;
  }

  PolicyAnswer._();

  factory PolicyAnswer.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PolicyAnswer()..mergeFromBuffer(data, registry);
  factory PolicyAnswer.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PolicyAnswer()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PolicyAnswer',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.security'),
      createEmptyInstance: PolicyAnswer.$_createMessage)
    ..aOB(1, _omitFieldNames ? '' : 'require2fa', protoName: 'require_2fa')
    ..aI(2, _omitFieldNames ? '' : 'graceDays')
    ..aOS(3, _omitFieldNames ? '' : 'enforcedFrom')
    ..aOB(4, _omitFieldNames ? '' : 'inGrace')
    ..aOB(5, _omitFieldNames ? '' : 'enrolled')
    ..aOB(6, _omitFieldNames ? '' : 'blocked')
    ..aI(7, _omitFieldNames ? '' : 'version')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PolicyAnswer clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PolicyAnswer copyWith(void Function(PolicyAnswer) updates) =>
      super.copyWith((message) => updates(message as PolicyAnswer))
          as PolicyAnswer;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use PolicyAnswer() / PolicyAnswer.new instead')
  static PolicyAnswer create() => PolicyAnswer._();
  static $pb.GeneratedMessage $_createMessage() => PolicyAnswer._();
  @$core.override
  PolicyAnswer createEmptyInstance() => PolicyAnswer._();
  @$core.pragma('dart2js:noInline')
  static PolicyAnswer getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PolicyAnswer>(
          PolicyAnswer.$_createMessage);
  static PolicyAnswer? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get require2fa => $_getBF(0);
  @$pb.TagNumber(1)
  set require2fa($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRequire2fa() => $_has(0);
  @$pb.TagNumber(1)
  void clearRequire2fa() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get graceDays => $_getIZ(1);
  @$pb.TagNumber(2)
  set graceDays($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasGraceDays() => $_has(1);
  @$pb.TagNumber(2)
  void clearGraceDays() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get enforcedFrom => $_getSZ(2);
  @$pb.TagNumber(3)
  set enforcedFrom($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasEnforcedFrom() => $_has(2);
  @$pb.TagNumber(3)
  void clearEnforcedFrom() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get inGrace => $_getBF(3);
  @$pb.TagNumber(4)
  set inGrace($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasInGrace() => $_has(3);
  @$pb.TagNumber(4)
  void clearInGrace() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.bool get enrolled => $_getBF(4);
  @$pb.TagNumber(5)
  set enrolled($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasEnrolled() => $_has(4);
  @$pb.TagNumber(5)
  void clearEnrolled() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.bool get blocked => $_getBF(5);
  @$pb.TagNumber(6)
  set blocked($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasBlocked() => $_has(5);
  @$pb.TagNumber(6)
  void clearBlocked() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.int get version => $_getIZ(6);
  @$pb.TagNumber(7)
  set version($core.int value) => $_setSignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasVersion() => $_has(6);
  @$pb.TagNumber(7)
  void clearVersion() => $_clearField(7);
}

class PolicyGetRequest extends $pb.GeneratedMessage {
  factory PolicyGetRequest({
    $core.String? workspaceId,
  }) {
    final result = PolicyGetRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    return result;
  }

  PolicyGetRequest._();

  factory PolicyGetRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PolicyGetRequest()..mergeFromBuffer(data, registry);
  factory PolicyGetRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PolicyGetRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PolicyGetRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.security'),
      createEmptyInstance: PolicyGetRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PolicyGetRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PolicyGetRequest copyWith(void Function(PolicyGetRequest) updates) =>
      super.copyWith((message) => updates(message as PolicyGetRequest))
          as PolicyGetRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use PolicyGetRequest() / PolicyGetRequest.new instead')
  static PolicyGetRequest create() => PolicyGetRequest._();
  static $pb.GeneratedMessage $_createMessage() => PolicyGetRequest._();
  @$core.override
  PolicyGetRequest createEmptyInstance() => PolicyGetRequest._();
  @$core.pragma('dart2js:noInline')
  static PolicyGetRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PolicyGetRequest>(
          PolicyGetRequest.$_createMessage);
  static PolicyGetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);
}

class PolicySetRequest extends $pb.GeneratedMessage {
  factory PolicySetRequest({
    $core.String? workspaceId,
    $core.bool? require2fa,
    $core.int? graceDays,
    $core.int? expectedVersion,
  }) {
    final result = PolicySetRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (require2fa != null) result.require2fa = require2fa;
    if (graceDays != null) result.graceDays = graceDays;
    if (expectedVersion != null) result.expectedVersion = expectedVersion;
    return result;
  }

  PolicySetRequest._();

  factory PolicySetRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PolicySetRequest()..mergeFromBuffer(data, registry);
  factory PolicySetRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PolicySetRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PolicySetRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.security'),
      createEmptyInstance: PolicySetRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOB(2, _omitFieldNames ? '' : 'require2fa', protoName: 'require_2fa')
    ..aI(3, _omitFieldNames ? '' : 'graceDays')
    ..aI(4, _omitFieldNames ? '' : 'expectedVersion')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PolicySetRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PolicySetRequest copyWith(void Function(PolicySetRequest) updates) =>
      super.copyWith((message) => updates(message as PolicySetRequest))
          as PolicySetRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use PolicySetRequest() / PolicySetRequest.new instead')
  static PolicySetRequest create() => PolicySetRequest._();
  static $pb.GeneratedMessage $_createMessage() => PolicySetRequest._();
  @$core.override
  PolicySetRequest createEmptyInstance() => PolicySetRequest._();
  @$core.pragma('dart2js:noInline')
  static PolicySetRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PolicySetRequest>(
          PolicySetRequest.$_createMessage);
  static PolicySetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get require2fa => $_getBF(1);
  @$pb.TagNumber(2)
  set require2fa($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRequire2fa() => $_has(1);
  @$pb.TagNumber(2)
  void clearRequire2fa() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get graceDays => $_getIZ(2);
  @$pb.TagNumber(3)
  set graceDays($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasGraceDays() => $_has(2);
  @$pb.TagNumber(3)
  void clearGraceDays() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get expectedVersion => $_getIZ(3);
  @$pb.TagNumber(4)
  set expectedVersion($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasExpectedVersion() => $_has(3);
  @$pb.TagNumber(4)
  void clearExpectedVersion() => $_clearField(4);
}

class Provider extends $pb.GeneratedMessage {
  factory Provider({
    $core.bool? configured,
    $core.String? name,
    $core.String? issuer,
    $core.String? clientId,
    $core.bool? hasSecret,
    $core.String? scopes,
    $core.Iterable<$core.String>? allowedDomains,
    $core.String? groupClaim,
    $core.Iterable<RoleMapping>? groupRoles,
    $core.String? defaultRoleId,
    $core.bool? autoCreateUsers,
    $core.bool? enabled,
    $core.bool? enforceSso,
    $core.int? version,
    $core.String? redirectUri,
  }) {
    final result = Provider._();
    if (configured != null) result.configured = configured;
    if (name != null) result.name = name;
    if (issuer != null) result.issuer = issuer;
    if (clientId != null) result.clientId = clientId;
    if (hasSecret != null) result.hasSecret = hasSecret;
    if (scopes != null) result.scopes = scopes;
    if (allowedDomains != null) result.allowedDomains.addAll(allowedDomains);
    if (groupClaim != null) result.groupClaim = groupClaim;
    if (groupRoles != null) result.groupRoles.addAll(groupRoles);
    if (defaultRoleId != null) result.defaultRoleId = defaultRoleId;
    if (autoCreateUsers != null) result.autoCreateUsers = autoCreateUsers;
    if (enabled != null) result.enabled = enabled;
    if (enforceSso != null) result.enforceSso = enforceSso;
    if (version != null) result.version = version;
    if (redirectUri != null) result.redirectUri = redirectUri;
    return result;
  }

  Provider._();

  factory Provider.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Provider()..mergeFromBuffer(data, registry);
  factory Provider.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Provider()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Provider',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.security'),
      createEmptyInstance: Provider.$_createMessage)
    ..aOB(1, _omitFieldNames ? '' : 'configured')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOS(3, _omitFieldNames ? '' : 'issuer')
    ..aOS(4, _omitFieldNames ? '' : 'clientId')
    ..aOB(5, _omitFieldNames ? '' : 'hasSecret')
    ..aOS(6, _omitFieldNames ? '' : 'scopes')
    ..pPS(7, _omitFieldNames ? '' : 'allowedDomains')
    ..aOS(8, _omitFieldNames ? '' : 'groupClaim')
    ..pPM<RoleMapping>(9, _omitFieldNames ? '' : 'groupRoles',
        subBuilder: RoleMapping.$_createMessage)
    ..aOS(10, _omitFieldNames ? '' : 'defaultRoleId')
    ..aOB(11, _omitFieldNames ? '' : 'autoCreateUsers')
    ..aOB(12, _omitFieldNames ? '' : 'enabled')
    ..aOB(13, _omitFieldNames ? '' : 'enforceSso')
    ..aI(14, _omitFieldNames ? '' : 'version')
    ..aOS(15, _omitFieldNames ? '' : 'redirectUri')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Provider clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Provider copyWith(void Function(Provider) updates) =>
      super.copyWith((message) => updates(message as Provider)) as Provider;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Provider() / Provider.new instead')
  static Provider create() => Provider._();
  static $pb.GeneratedMessage $_createMessage() => Provider._();
  @$core.override
  Provider createEmptyInstance() => Provider._();
  @$core.pragma('dart2js:noInline')
  static Provider getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Provider>(Provider.$_createMessage);
  static Provider? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get configured => $_getBF(0);
  @$pb.TagNumber(1)
  set configured($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasConfigured() => $_has(0);
  @$pb.TagNumber(1)
  void clearConfigured() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get issuer => $_getSZ(2);
  @$pb.TagNumber(3)
  set issuer($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasIssuer() => $_has(2);
  @$pb.TagNumber(3)
  void clearIssuer() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get clientId => $_getSZ(3);
  @$pb.TagNumber(4)
  set clientId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasClientId() => $_has(3);
  @$pb.TagNumber(4)
  void clearClientId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.bool get hasSecret => $_getBF(4);
  @$pb.TagNumber(5)
  set hasSecret($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasHasSecret() => $_has(4);
  @$pb.TagNumber(5)
  void clearHasSecret() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get scopes => $_getSZ(5);
  @$pb.TagNumber(6)
  set scopes($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasScopes() => $_has(5);
  @$pb.TagNumber(6)
  void clearScopes() => $_clearField(6);

  @$pb.TagNumber(7)
  $pb.PbList<$core.String> get allowedDomains => $_getList(6);

  @$pb.TagNumber(8)
  $core.String get groupClaim => $_getSZ(7);
  @$pb.TagNumber(8)
  set groupClaim($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasGroupClaim() => $_has(7);
  @$pb.TagNumber(8)
  void clearGroupClaim() => $_clearField(8);

  @$pb.TagNumber(9)
  $pb.PbList<RoleMapping> get groupRoles => $_getList(8);

  @$pb.TagNumber(10)
  $core.String get defaultRoleId => $_getSZ(9);
  @$pb.TagNumber(10)
  set defaultRoleId($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasDefaultRoleId() => $_has(9);
  @$pb.TagNumber(10)
  void clearDefaultRoleId() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.bool get autoCreateUsers => $_getBF(10);
  @$pb.TagNumber(11)
  set autoCreateUsers($core.bool value) => $_setBool(10, value);
  @$pb.TagNumber(11)
  $core.bool hasAutoCreateUsers() => $_has(10);
  @$pb.TagNumber(11)
  void clearAutoCreateUsers() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.bool get enabled => $_getBF(11);
  @$pb.TagNumber(12)
  set enabled($core.bool value) => $_setBool(11, value);
  @$pb.TagNumber(12)
  $core.bool hasEnabled() => $_has(11);
  @$pb.TagNumber(12)
  void clearEnabled() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.bool get enforceSso => $_getBF(12);
  @$pb.TagNumber(13)
  set enforceSso($core.bool value) => $_setBool(12, value);
  @$pb.TagNumber(13)
  $core.bool hasEnforceSso() => $_has(12);
  @$pb.TagNumber(13)
  void clearEnforceSso() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.int get version => $_getIZ(13);
  @$pb.TagNumber(14)
  set version($core.int value) => $_setSignedInt32(13, value);
  @$pb.TagNumber(14)
  $core.bool hasVersion() => $_has(13);
  @$pb.TagNumber(14)
  void clearVersion() => $_clearField(14);

  @$pb.TagNumber(15)
  $core.String get redirectUri => $_getSZ(14);
  @$pb.TagNumber(15)
  set redirectUri($core.String value) => $_setString(14, value);
  @$pb.TagNumber(15)
  $core.bool hasRedirectUri() => $_has(14);
  @$pb.TagNumber(15)
  void clearRedirectUri() => $_clearField(15);
}

class ProviderAnswer extends $pb.GeneratedMessage {
  factory ProviderAnswer({
    Provider? provider,
  }) {
    final result = ProviderAnswer._();
    if (provider != null) result.provider = provider;
    return result;
  }

  ProviderAnswer._();

  factory ProviderAnswer.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ProviderAnswer()..mergeFromBuffer(data, registry);
  factory ProviderAnswer.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ProviderAnswer()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ProviderAnswer',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.security'),
      createEmptyInstance: ProviderAnswer.$_createMessage)
    ..aOM<Provider>(1, _omitFieldNames ? '' : 'provider',
        subBuilder: Provider.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProviderAnswer clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProviderAnswer copyWith(void Function(ProviderAnswer) updates) =>
      super.copyWith((message) => updates(message as ProviderAnswer))
          as ProviderAnswer;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ProviderAnswer() / ProviderAnswer.new instead')
  static ProviderAnswer create() => ProviderAnswer._();
  static $pb.GeneratedMessage $_createMessage() => ProviderAnswer._();
  @$core.override
  ProviderAnswer createEmptyInstance() => ProviderAnswer._();
  @$core.pragma('dart2js:noInline')
  static ProviderAnswer getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ProviderAnswer>(
          ProviderAnswer.$_createMessage);
  static ProviderAnswer? _defaultInstance;

  @$pb.TagNumber(1)
  Provider get provider => $_getN(0);
  @$pb.TagNumber(1)
  set provider(Provider value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasProvider() => $_has(0);
  @$pb.TagNumber(1)
  void clearProvider() => $_clearField(1);
  @$pb.TagNumber(1)
  Provider ensureProvider() => $_ensure(0);
}

class RevokeDeviceAnswer extends $pb.GeneratedMessage {
  factory RevokeDeviceAnswer({
    $core.int? revoked,
  }) {
    final result = RevokeDeviceAnswer._();
    if (revoked != null) result.revoked = revoked;
    return result;
  }

  RevokeDeviceAnswer._();

  factory RevokeDeviceAnswer.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RevokeDeviceAnswer()..mergeFromBuffer(data, registry);
  factory RevokeDeviceAnswer.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RevokeDeviceAnswer()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RevokeDeviceAnswer',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.security'),
      createEmptyInstance: RevokeDeviceAnswer.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'revoked')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RevokeDeviceAnswer clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RevokeDeviceAnswer copyWith(void Function(RevokeDeviceAnswer) updates) =>
      super.copyWith((message) => updates(message as RevokeDeviceAnswer))
          as RevokeDeviceAnswer;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use RevokeDeviceAnswer() / RevokeDeviceAnswer.new instead')
  static RevokeDeviceAnswer create() => RevokeDeviceAnswer._();
  static $pb.GeneratedMessage $_createMessage() => RevokeDeviceAnswer._();
  @$core.override
  RevokeDeviceAnswer createEmptyInstance() => RevokeDeviceAnswer._();
  @$core.pragma('dart2js:noInline')
  static RevokeDeviceAnswer getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RevokeDeviceAnswer>(
          RevokeDeviceAnswer.$_createMessage);
  static RevokeDeviceAnswer? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get revoked => $_getIZ(0);
  @$pb.TagNumber(1)
  set revoked($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRevoked() => $_has(0);
  @$pb.TagNumber(1)
  void clearRevoked() => $_clearField(1);
}

class RevokeDeviceRequest extends $pb.GeneratedMessage {
  factory RevokeDeviceRequest({
    $core.String? deviceId,
  }) {
    final result = RevokeDeviceRequest._();
    if (deviceId != null) result.deviceId = deviceId;
    return result;
  }

  RevokeDeviceRequest._();

  factory RevokeDeviceRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RevokeDeviceRequest()..mergeFromBuffer(data, registry);
  factory RevokeDeviceRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RevokeDeviceRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RevokeDeviceRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.security'),
      createEmptyInstance: RevokeDeviceRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'deviceId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RevokeDeviceRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RevokeDeviceRequest copyWith(void Function(RevokeDeviceRequest) updates) =>
      super.copyWith((message) => updates(message as RevokeDeviceRequest))
          as RevokeDeviceRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core
      .Deprecated('Use RevokeDeviceRequest() / RevokeDeviceRequest.new instead')
  static RevokeDeviceRequest create() => RevokeDeviceRequest._();
  static $pb.GeneratedMessage $_createMessage() => RevokeDeviceRequest._();
  @$core.override
  RevokeDeviceRequest createEmptyInstance() => RevokeDeviceRequest._();
  @$core.pragma('dart2js:noInline')
  static RevokeDeviceRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RevokeDeviceRequest>(
          RevokeDeviceRequest.$_createMessage);
  static RevokeDeviceRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get deviceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set deviceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDeviceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearDeviceId() => $_clearField(1);
}

class RoleMapping extends $pb.GeneratedMessage {
  factory RoleMapping({
    $core.String? group,
    $core.String? roleId,
  }) {
    final result = RoleMapping._();
    if (group != null) result.group = group;
    if (roleId != null) result.roleId = roleId;
    return result;
  }

  RoleMapping._();

  factory RoleMapping.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RoleMapping()..mergeFromBuffer(data, registry);
  factory RoleMapping.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RoleMapping()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RoleMapping',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.security'),
      createEmptyInstance: RoleMapping.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'group')
    ..aOS(2, _omitFieldNames ? '' : 'roleId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RoleMapping clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RoleMapping copyWith(void Function(RoleMapping) updates) =>
      super.copyWith((message) => updates(message as RoleMapping))
          as RoleMapping;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use RoleMapping() / RoleMapping.new instead')
  static RoleMapping create() => RoleMapping._();
  static $pb.GeneratedMessage $_createMessage() => RoleMapping._();
  @$core.override
  RoleMapping createEmptyInstance() => RoleMapping._();
  @$core.pragma('dart2js:noInline')
  static RoleMapping getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RoleMapping>(
          RoleMapping.$_createMessage);
  static RoleMapping? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get group => $_getSZ(0);
  @$pb.TagNumber(1)
  set group($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasGroup() => $_has(0);
  @$pb.TagNumber(1)
  void clearGroup() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get roleId => $_getSZ(1);
  @$pb.TagNumber(2)
  set roleId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRoleId() => $_has(1);
  @$pb.TagNumber(2)
  void clearRoleId() => $_clearField(2);
}

class SecondFactorBeginRequest extends $pb.GeneratedMessage {
  factory SecondFactorBeginRequest() => SecondFactorBeginRequest._();

  SecondFactorBeginRequest._();

  factory SecondFactorBeginRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SecondFactorBeginRequest()..mergeFromBuffer(data, registry);
  factory SecondFactorBeginRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SecondFactorBeginRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SecondFactorBeginRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.security'),
      createEmptyInstance: SecondFactorBeginRequest.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SecondFactorBeginRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SecondFactorBeginRequest copyWith(
          void Function(SecondFactorBeginRequest) updates) =>
      super.copyWith((message) => updates(message as SecondFactorBeginRequest))
          as SecondFactorBeginRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use SecondFactorBeginRequest() / SecondFactorBeginRequest.new instead')
  static SecondFactorBeginRequest create() => SecondFactorBeginRequest._();
  static $pb.GeneratedMessage $_createMessage() => SecondFactorBeginRequest._();
  @$core.override
  SecondFactorBeginRequest createEmptyInstance() =>
      SecondFactorBeginRequest._();
  @$core.pragma('dart2js:noInline')
  static SecondFactorBeginRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SecondFactorBeginRequest>(
          SecondFactorBeginRequest.$_createMessage);
  static SecondFactorBeginRequest? _defaultInstance;
}

class SecondFactorConfirmRequest extends $pb.GeneratedMessage {
  factory SecondFactorConfirmRequest({
    $core.String? code,
  }) {
    final result = SecondFactorConfirmRequest._();
    if (code != null) result.code = code;
    return result;
  }

  SecondFactorConfirmRequest._();

  factory SecondFactorConfirmRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SecondFactorConfirmRequest()..mergeFromBuffer(data, registry);
  factory SecondFactorConfirmRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SecondFactorConfirmRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SecondFactorConfirmRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.security'),
      createEmptyInstance: SecondFactorConfirmRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'code')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SecondFactorConfirmRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SecondFactorConfirmRequest copyWith(
          void Function(SecondFactorConfirmRequest) updates) =>
      super.copyWith(
              (message) => updates(message as SecondFactorConfirmRequest))
          as SecondFactorConfirmRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use SecondFactorConfirmRequest() / SecondFactorConfirmRequest.new instead')
  static SecondFactorConfirmRequest create() => SecondFactorConfirmRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      SecondFactorConfirmRequest._();
  @$core.override
  SecondFactorConfirmRequest createEmptyInstance() =>
      SecondFactorConfirmRequest._();
  @$core.pragma('dart2js:noInline')
  static SecondFactorConfirmRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SecondFactorConfirmRequest>(
          SecondFactorConfirmRequest.$_createMessage);
  static SecondFactorConfirmRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get code => $_getSZ(0);
  @$pb.TagNumber(1)
  set code($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCode() => $_has(0);
  @$pb.TagNumber(1)
  void clearCode() => $_clearField(1);
}

class SecondFactorConfirmed extends $pb.GeneratedMessage {
  factory SecondFactorConfirmed({
    $core.Iterable<$core.String>? recoveryCodes,
  }) {
    final result = SecondFactorConfirmed._();
    if (recoveryCodes != null) result.recoveryCodes.addAll(recoveryCodes);
    return result;
  }

  SecondFactorConfirmed._();

  factory SecondFactorConfirmed.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SecondFactorConfirmed()..mergeFromBuffer(data, registry);
  factory SecondFactorConfirmed.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SecondFactorConfirmed()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SecondFactorConfirmed',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.security'),
      createEmptyInstance: SecondFactorConfirmed.$_createMessage)
    ..pPS(1, _omitFieldNames ? '' : 'recoveryCodes')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SecondFactorConfirmed clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SecondFactorConfirmed copyWith(
          void Function(SecondFactorConfirmed) updates) =>
      super.copyWith((message) => updates(message as SecondFactorConfirmed))
          as SecondFactorConfirmed;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use SecondFactorConfirmed() / SecondFactorConfirmed.new instead')
  static SecondFactorConfirmed create() => SecondFactorConfirmed._();
  static $pb.GeneratedMessage $_createMessage() => SecondFactorConfirmed._();
  @$core.override
  SecondFactorConfirmed createEmptyInstance() => SecondFactorConfirmed._();
  @$core.pragma('dart2js:noInline')
  static SecondFactorConfirmed getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SecondFactorConfirmed>(
          SecondFactorConfirmed.$_createMessage);
  static SecondFactorConfirmed? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$core.String> get recoveryCodes => $_getList(0);
}

class SecondFactorDisableRequest extends $pb.GeneratedMessage {
  factory SecondFactorDisableRequest({
    $core.String? code,
  }) {
    final result = SecondFactorDisableRequest._();
    if (code != null) result.code = code;
    return result;
  }

  SecondFactorDisableRequest._();

  factory SecondFactorDisableRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SecondFactorDisableRequest()..mergeFromBuffer(data, registry);
  factory SecondFactorDisableRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SecondFactorDisableRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SecondFactorDisableRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.security'),
      createEmptyInstance: SecondFactorDisableRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'code')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SecondFactorDisableRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SecondFactorDisableRequest copyWith(
          void Function(SecondFactorDisableRequest) updates) =>
      super.copyWith(
              (message) => updates(message as SecondFactorDisableRequest))
          as SecondFactorDisableRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use SecondFactorDisableRequest() / SecondFactorDisableRequest.new instead')
  static SecondFactorDisableRequest create() => SecondFactorDisableRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      SecondFactorDisableRequest._();
  @$core.override
  SecondFactorDisableRequest createEmptyInstance() =>
      SecondFactorDisableRequest._();
  @$core.pragma('dart2js:noInline')
  static SecondFactorDisableRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SecondFactorDisableRequest>(
          SecondFactorDisableRequest.$_createMessage);
  static SecondFactorDisableRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get code => $_getSZ(0);
  @$pb.TagNumber(1)
  set code($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCode() => $_has(0);
  @$pb.TagNumber(1)
  void clearCode() => $_clearField(1);
}

class SecondFactorDisabled extends $pb.GeneratedMessage {
  factory SecondFactorDisabled({
    $core.bool? enabled,
  }) {
    final result = SecondFactorDisabled._();
    if (enabled != null) result.enabled = enabled;
    return result;
  }

  SecondFactorDisabled._();

  factory SecondFactorDisabled.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SecondFactorDisabled()..mergeFromBuffer(data, registry);
  factory SecondFactorDisabled.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SecondFactorDisabled()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SecondFactorDisabled',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.security'),
      createEmptyInstance: SecondFactorDisabled.$_createMessage)
    ..aOB(1, _omitFieldNames ? '' : 'enabled')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SecondFactorDisabled clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SecondFactorDisabled copyWith(void Function(SecondFactorDisabled) updates) =>
      super.copyWith((message) => updates(message as SecondFactorDisabled))
          as SecondFactorDisabled;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use SecondFactorDisabled() / SecondFactorDisabled.new instead')
  static SecondFactorDisabled create() => SecondFactorDisabled._();
  static $pb.GeneratedMessage $_createMessage() => SecondFactorDisabled._();
  @$core.override
  SecondFactorDisabled createEmptyInstance() => SecondFactorDisabled._();
  @$core.pragma('dart2js:noInline')
  static SecondFactorDisabled getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SecondFactorDisabled>(
          SecondFactorDisabled.$_createMessage);
  static SecondFactorDisabled? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get enabled => $_getBF(0);
  @$pb.TagNumber(1)
  set enabled($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasEnabled() => $_has(0);
  @$pb.TagNumber(1)
  void clearEnabled() => $_clearField(1);
}

class SecondFactorEnrolment extends $pb.GeneratedMessage {
  factory SecondFactorEnrolment({
    $core.String? secret,
    $core.String? otpauthUri,
  }) {
    final result = SecondFactorEnrolment._();
    if (secret != null) result.secret = secret;
    if (otpauthUri != null) result.otpauthUri = otpauthUri;
    return result;
  }

  SecondFactorEnrolment._();

  factory SecondFactorEnrolment.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SecondFactorEnrolment()..mergeFromBuffer(data, registry);
  factory SecondFactorEnrolment.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SecondFactorEnrolment()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SecondFactorEnrolment',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.security'),
      createEmptyInstance: SecondFactorEnrolment.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'secret')
    ..aOS(2, _omitFieldNames ? '' : 'otpauthUri')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SecondFactorEnrolment clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SecondFactorEnrolment copyWith(
          void Function(SecondFactorEnrolment) updates) =>
      super.copyWith((message) => updates(message as SecondFactorEnrolment))
          as SecondFactorEnrolment;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use SecondFactorEnrolment() / SecondFactorEnrolment.new instead')
  static SecondFactorEnrolment create() => SecondFactorEnrolment._();
  static $pb.GeneratedMessage $_createMessage() => SecondFactorEnrolment._();
  @$core.override
  SecondFactorEnrolment createEmptyInstance() => SecondFactorEnrolment._();
  @$core.pragma('dart2js:noInline')
  static SecondFactorEnrolment getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SecondFactorEnrolment>(
          SecondFactorEnrolment.$_createMessage);
  static SecondFactorEnrolment? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get secret => $_getSZ(0);
  @$pb.TagNumber(1)
  set secret($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSecret() => $_has(0);
  @$pb.TagNumber(1)
  void clearSecret() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get otpauthUri => $_getSZ(1);
  @$pb.TagNumber(2)
  set otpauthUri($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasOtpauthUri() => $_has(1);
  @$pb.TagNumber(2)
  void clearOtpauthUri() => $_clearField(2);
}

class SecondFactorRegenerateRequest extends $pb.GeneratedMessage {
  factory SecondFactorRegenerateRequest({
    $core.String? code,
  }) {
    final result = SecondFactorRegenerateRequest._();
    if (code != null) result.code = code;
    return result;
  }

  SecondFactorRegenerateRequest._();

  factory SecondFactorRegenerateRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SecondFactorRegenerateRequest()..mergeFromBuffer(data, registry);
  factory SecondFactorRegenerateRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SecondFactorRegenerateRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SecondFactorRegenerateRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.security'),
      createEmptyInstance: SecondFactorRegenerateRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'code')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SecondFactorRegenerateRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SecondFactorRegenerateRequest copyWith(
          void Function(SecondFactorRegenerateRequest) updates) =>
      super.copyWith(
              (message) => updates(message as SecondFactorRegenerateRequest))
          as SecondFactorRegenerateRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use SecondFactorRegenerateRequest() / SecondFactorRegenerateRequest.new instead')
  static SecondFactorRegenerateRequest create() =>
      SecondFactorRegenerateRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      SecondFactorRegenerateRequest._();
  @$core.override
  SecondFactorRegenerateRequest createEmptyInstance() =>
      SecondFactorRegenerateRequest._();
  @$core.pragma('dart2js:noInline')
  static SecondFactorRegenerateRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SecondFactorRegenerateRequest>(
          SecondFactorRegenerateRequest.$_createMessage);
  static SecondFactorRegenerateRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get code => $_getSZ(0);
  @$pb.TagNumber(1)
  set code($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCode() => $_has(0);
  @$pb.TagNumber(1)
  void clearCode() => $_clearField(1);
}

class SecondFactorRegenerated extends $pb.GeneratedMessage {
  factory SecondFactorRegenerated({
    $core.Iterable<$core.String>? recoveryCodes,
  }) {
    final result = SecondFactorRegenerated._();
    if (recoveryCodes != null) result.recoveryCodes.addAll(recoveryCodes);
    return result;
  }

  SecondFactorRegenerated._();

  factory SecondFactorRegenerated.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SecondFactorRegenerated()..mergeFromBuffer(data, registry);
  factory SecondFactorRegenerated.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SecondFactorRegenerated()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SecondFactorRegenerated',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.security'),
      createEmptyInstance: SecondFactorRegenerated.$_createMessage)
    ..pPS(1, _omitFieldNames ? '' : 'recoveryCodes')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SecondFactorRegenerated clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SecondFactorRegenerated copyWith(
          void Function(SecondFactorRegenerated) updates) =>
      super.copyWith((message) => updates(message as SecondFactorRegenerated))
          as SecondFactorRegenerated;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use SecondFactorRegenerated() / SecondFactorRegenerated.new instead')
  static SecondFactorRegenerated create() => SecondFactorRegenerated._();
  static $pb.GeneratedMessage $_createMessage() => SecondFactorRegenerated._();
  @$core.override
  SecondFactorRegenerated createEmptyInstance() => SecondFactorRegenerated._();
  @$core.pragma('dart2js:noInline')
  static SecondFactorRegenerated getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SecondFactorRegenerated>(
          SecondFactorRegenerated.$_createMessage);
  static SecondFactorRegenerated? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$core.String> get recoveryCodes => $_getList(0);
}

class SecondFactorStatus extends $pb.GeneratedMessage {
  factory SecondFactorStatus({
    $core.bool? enabled,
    $core.int? unusedRecoveryCodes,
    $core.Iterable<TrustedDevice>? trustedDevices,
  }) {
    final result = SecondFactorStatus._();
    if (enabled != null) result.enabled = enabled;
    if (unusedRecoveryCodes != null)
      result.unusedRecoveryCodes = unusedRecoveryCodes;
    if (trustedDevices != null) result.trustedDevices.addAll(trustedDevices);
    return result;
  }

  SecondFactorStatus._();

  factory SecondFactorStatus.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SecondFactorStatus()..mergeFromBuffer(data, registry);
  factory SecondFactorStatus.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SecondFactorStatus()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SecondFactorStatus',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.security'),
      createEmptyInstance: SecondFactorStatus.$_createMessage)
    ..aOB(1, _omitFieldNames ? '' : 'enabled')
    ..aI(2, _omitFieldNames ? '' : 'unusedRecoveryCodes')
    ..pPM<TrustedDevice>(3, _omitFieldNames ? '' : 'trustedDevices',
        subBuilder: TrustedDevice.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SecondFactorStatus clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SecondFactorStatus copyWith(void Function(SecondFactorStatus) updates) =>
      super.copyWith((message) => updates(message as SecondFactorStatus))
          as SecondFactorStatus;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SecondFactorStatus() / SecondFactorStatus.new instead')
  static SecondFactorStatus create() => SecondFactorStatus._();
  static $pb.GeneratedMessage $_createMessage() => SecondFactorStatus._();
  @$core.override
  SecondFactorStatus createEmptyInstance() => SecondFactorStatus._();
  @$core.pragma('dart2js:noInline')
  static SecondFactorStatus getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SecondFactorStatus>(
          SecondFactorStatus.$_createMessage);
  static SecondFactorStatus? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get enabled => $_getBF(0);
  @$pb.TagNumber(1)
  set enabled($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasEnabled() => $_has(0);
  @$pb.TagNumber(1)
  void clearEnabled() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get unusedRecoveryCodes => $_getIZ(1);
  @$pb.TagNumber(2)
  set unusedRecoveryCodes($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUnusedRecoveryCodes() => $_has(1);
  @$pb.TagNumber(2)
  void clearUnusedRecoveryCodes() => $_clearField(2);

  @$pb.TagNumber(3)
  $pb.PbList<TrustedDevice> get trustedDevices => $_getList(2);
}

class SecondFactorStatusRequest extends $pb.GeneratedMessage {
  factory SecondFactorStatusRequest() => SecondFactorStatusRequest._();

  SecondFactorStatusRequest._();

  factory SecondFactorStatusRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SecondFactorStatusRequest()..mergeFromBuffer(data, registry);
  factory SecondFactorStatusRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SecondFactorStatusRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SecondFactorStatusRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.security'),
      createEmptyInstance: SecondFactorStatusRequest.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SecondFactorStatusRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SecondFactorStatusRequest copyWith(
          void Function(SecondFactorStatusRequest) updates) =>
      super.copyWith((message) => updates(message as SecondFactorStatusRequest))
          as SecondFactorStatusRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use SecondFactorStatusRequest() / SecondFactorStatusRequest.new instead')
  static SecondFactorStatusRequest create() => SecondFactorStatusRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      SecondFactorStatusRequest._();
  @$core.override
  SecondFactorStatusRequest createEmptyInstance() =>
      SecondFactorStatusRequest._();
  @$core.pragma('dart2js:noInline')
  static SecondFactorStatusRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SecondFactorStatusRequest>(
          SecondFactorStatusRequest.$_createMessage);
  static SecondFactorStatusRequest? _defaultInstance;
}

class SsoDeleteRequest extends $pb.GeneratedMessage {
  factory SsoDeleteRequest({
    $core.String? workspaceId,
  }) {
    final result = SsoDeleteRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    return result;
  }

  SsoDeleteRequest._();

  factory SsoDeleteRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SsoDeleteRequest()..mergeFromBuffer(data, registry);
  factory SsoDeleteRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SsoDeleteRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SsoDeleteRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.security'),
      createEmptyInstance: SsoDeleteRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SsoDeleteRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SsoDeleteRequest copyWith(void Function(SsoDeleteRequest) updates) =>
      super.copyWith((message) => updates(message as SsoDeleteRequest))
          as SsoDeleteRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SsoDeleteRequest() / SsoDeleteRequest.new instead')
  static SsoDeleteRequest create() => SsoDeleteRequest._();
  static $pb.GeneratedMessage $_createMessage() => SsoDeleteRequest._();
  @$core.override
  SsoDeleteRequest createEmptyInstance() => SsoDeleteRequest._();
  @$core.pragma('dart2js:noInline')
  static SsoDeleteRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SsoDeleteRequest>(
          SsoDeleteRequest.$_createMessage);
  static SsoDeleteRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);
}

class SsoDeleted extends $pb.GeneratedMessage {
  factory SsoDeleted({
    $core.bool? deleted,
  }) {
    final result = SsoDeleted._();
    if (deleted != null) result.deleted = deleted;
    return result;
  }

  SsoDeleted._();

  factory SsoDeleted.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SsoDeleted()..mergeFromBuffer(data, registry);
  factory SsoDeleted.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SsoDeleted()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SsoDeleted',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.security'),
      createEmptyInstance: SsoDeleted.$_createMessage)
    ..aOB(1, _omitFieldNames ? '' : 'deleted')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SsoDeleted clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SsoDeleted copyWith(void Function(SsoDeleted) updates) =>
      super.copyWith((message) => updates(message as SsoDeleted)) as SsoDeleted;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SsoDeleted() / SsoDeleted.new instead')
  static SsoDeleted create() => SsoDeleted._();
  static $pb.GeneratedMessage $_createMessage() => SsoDeleted._();
  @$core.override
  SsoDeleted createEmptyInstance() => SsoDeleted._();
  @$core.pragma('dart2js:noInline')
  static SsoDeleted getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SsoDeleted>(SsoDeleted.$_createMessage);
  static SsoDeleted? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get deleted => $_getBF(0);
  @$pb.TagNumber(1)
  set deleted($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDeleted() => $_has(0);
  @$pb.TagNumber(1)
  void clearDeleted() => $_clearField(1);
}

class SsoGetRequest extends $pb.GeneratedMessage {
  factory SsoGetRequest({
    $core.String? workspaceId,
  }) {
    final result = SsoGetRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    return result;
  }

  SsoGetRequest._();

  factory SsoGetRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SsoGetRequest()..mergeFromBuffer(data, registry);
  factory SsoGetRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SsoGetRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SsoGetRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.security'),
      createEmptyInstance: SsoGetRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SsoGetRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SsoGetRequest copyWith(void Function(SsoGetRequest) updates) =>
      super.copyWith((message) => updates(message as SsoGetRequest))
          as SsoGetRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SsoGetRequest() / SsoGetRequest.new instead')
  static SsoGetRequest create() => SsoGetRequest._();
  static $pb.GeneratedMessage $_createMessage() => SsoGetRequest._();
  @$core.override
  SsoGetRequest createEmptyInstance() => SsoGetRequest._();
  @$core.pragma('dart2js:noInline')
  static SsoGetRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SsoGetRequest>(
          SsoGetRequest.$_createMessage);
  static SsoGetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);
}

class SsoSaveRequest extends $pb.GeneratedMessage {
  factory SsoSaveRequest({
    $core.String? workspaceId,
    $core.String? name,
    $core.String? issuer,
    $core.String? clientId,
    $core.String? clientSecret,
    $core.String? scopes,
    $core.Iterable<$core.String>? allowedDomains,
    $core.String? groupClaim,
    $core.Iterable<RoleMapping>? groupRoles,
    $core.String? defaultRoleId,
    $core.bool? autoCreateUsers,
    $core.bool? enabled,
    $core.bool? enforceSso,
    $core.int? expectedVersion,
  }) {
    final result = SsoSaveRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (name != null) result.name = name;
    if (issuer != null) result.issuer = issuer;
    if (clientId != null) result.clientId = clientId;
    if (clientSecret != null) result.clientSecret = clientSecret;
    if (scopes != null) result.scopes = scopes;
    if (allowedDomains != null) result.allowedDomains.addAll(allowedDomains);
    if (groupClaim != null) result.groupClaim = groupClaim;
    if (groupRoles != null) result.groupRoles.addAll(groupRoles);
    if (defaultRoleId != null) result.defaultRoleId = defaultRoleId;
    if (autoCreateUsers != null) result.autoCreateUsers = autoCreateUsers;
    if (enabled != null) result.enabled = enabled;
    if (enforceSso != null) result.enforceSso = enforceSso;
    if (expectedVersion != null) result.expectedVersion = expectedVersion;
    return result;
  }

  SsoSaveRequest._();

  factory SsoSaveRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SsoSaveRequest()..mergeFromBuffer(data, registry);
  factory SsoSaveRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SsoSaveRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SsoSaveRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.security'),
      createEmptyInstance: SsoSaveRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOS(3, _omitFieldNames ? '' : 'issuer')
    ..aOS(4, _omitFieldNames ? '' : 'clientId')
    ..aOS(5, _omitFieldNames ? '' : 'clientSecret')
    ..aOS(6, _omitFieldNames ? '' : 'scopes')
    ..pPS(7, _omitFieldNames ? '' : 'allowedDomains')
    ..aOS(8, _omitFieldNames ? '' : 'groupClaim')
    ..pPM<RoleMapping>(9, _omitFieldNames ? '' : 'groupRoles',
        subBuilder: RoleMapping.$_createMessage)
    ..aOS(10, _omitFieldNames ? '' : 'defaultRoleId')
    ..aOB(11, _omitFieldNames ? '' : 'autoCreateUsers')
    ..aOB(12, _omitFieldNames ? '' : 'enabled')
    ..aOB(13, _omitFieldNames ? '' : 'enforceSso')
    ..aI(14, _omitFieldNames ? '' : 'expectedVersion')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SsoSaveRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SsoSaveRequest copyWith(void Function(SsoSaveRequest) updates) =>
      super.copyWith((message) => updates(message as SsoSaveRequest))
          as SsoSaveRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SsoSaveRequest() / SsoSaveRequest.new instead')
  static SsoSaveRequest create() => SsoSaveRequest._();
  static $pb.GeneratedMessage $_createMessage() => SsoSaveRequest._();
  @$core.override
  SsoSaveRequest createEmptyInstance() => SsoSaveRequest._();
  @$core.pragma('dart2js:noInline')
  static SsoSaveRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SsoSaveRequest>(
          SsoSaveRequest.$_createMessage);
  static SsoSaveRequest? _defaultInstance;

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
  $core.String get issuer => $_getSZ(2);
  @$pb.TagNumber(3)
  set issuer($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasIssuer() => $_has(2);
  @$pb.TagNumber(3)
  void clearIssuer() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get clientId => $_getSZ(3);
  @$pb.TagNumber(4)
  set clientId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasClientId() => $_has(3);
  @$pb.TagNumber(4)
  void clearClientId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get clientSecret => $_getSZ(4);
  @$pb.TagNumber(5)
  set clientSecret($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasClientSecret() => $_has(4);
  @$pb.TagNumber(5)
  void clearClientSecret() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get scopes => $_getSZ(5);
  @$pb.TagNumber(6)
  set scopes($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasScopes() => $_has(5);
  @$pb.TagNumber(6)
  void clearScopes() => $_clearField(6);

  @$pb.TagNumber(7)
  $pb.PbList<$core.String> get allowedDomains => $_getList(6);

  @$pb.TagNumber(8)
  $core.String get groupClaim => $_getSZ(7);
  @$pb.TagNumber(8)
  set groupClaim($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasGroupClaim() => $_has(7);
  @$pb.TagNumber(8)
  void clearGroupClaim() => $_clearField(8);

  @$pb.TagNumber(9)
  $pb.PbList<RoleMapping> get groupRoles => $_getList(8);

  @$pb.TagNumber(10)
  $core.String get defaultRoleId => $_getSZ(9);
  @$pb.TagNumber(10)
  set defaultRoleId($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasDefaultRoleId() => $_has(9);
  @$pb.TagNumber(10)
  void clearDefaultRoleId() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.bool get autoCreateUsers => $_getBF(10);
  @$pb.TagNumber(11)
  set autoCreateUsers($core.bool value) => $_setBool(10, value);
  @$pb.TagNumber(11)
  $core.bool hasAutoCreateUsers() => $_has(10);
  @$pb.TagNumber(11)
  void clearAutoCreateUsers() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.bool get enabled => $_getBF(11);
  @$pb.TagNumber(12)
  set enabled($core.bool value) => $_setBool(11, value);
  @$pb.TagNumber(12)
  $core.bool hasEnabled() => $_has(11);
  @$pb.TagNumber(12)
  void clearEnabled() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.bool get enforceSso => $_getBF(12);
  @$pb.TagNumber(13)
  set enforceSso($core.bool value) => $_setBool(12, value);
  @$pb.TagNumber(13)
  $core.bool hasEnforceSso() => $_has(12);
  @$pb.TagNumber(13)
  void clearEnforceSso() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.int get expectedVersion => $_getIZ(13);
  @$pb.TagNumber(14)
  set expectedVersion($core.int value) => $_setSignedInt32(13, value);
  @$pb.TagNumber(14)
  $core.bool hasExpectedVersion() => $_has(13);
  @$pb.TagNumber(14)
  void clearExpectedVersion() => $_clearField(14);
}

class SsoTestAnswer extends $pb.GeneratedMessage {
  factory SsoTestAnswer({
    $core.bool? ok,
    $core.String? message,
    $core.String? redirectUri,
    $core.String? authorizationEndpoint,
    $core.String? tokenEndpoint,
    $core.String? jwksUri,
    $core.int? keys,
  }) {
    final result = SsoTestAnswer._();
    if (ok != null) result.ok = ok;
    if (message != null) result.message = message;
    if (redirectUri != null) result.redirectUri = redirectUri;
    if (authorizationEndpoint != null)
      result.authorizationEndpoint = authorizationEndpoint;
    if (tokenEndpoint != null) result.tokenEndpoint = tokenEndpoint;
    if (jwksUri != null) result.jwksUri = jwksUri;
    if (keys != null) result.keys = keys;
    return result;
  }

  SsoTestAnswer._();

  factory SsoTestAnswer.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SsoTestAnswer()..mergeFromBuffer(data, registry);
  factory SsoTestAnswer.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SsoTestAnswer()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SsoTestAnswer',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.security'),
      createEmptyInstance: SsoTestAnswer.$_createMessage)
    ..aOB(1, _omitFieldNames ? '' : 'ok')
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..aOS(3, _omitFieldNames ? '' : 'redirectUri')
    ..aOS(4, _omitFieldNames ? '' : 'authorizationEndpoint')
    ..aOS(5, _omitFieldNames ? '' : 'tokenEndpoint')
    ..aOS(6, _omitFieldNames ? '' : 'jwksUri')
    ..aI(7, _omitFieldNames ? '' : 'keys')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SsoTestAnswer clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SsoTestAnswer copyWith(void Function(SsoTestAnswer) updates) =>
      super.copyWith((message) => updates(message as SsoTestAnswer))
          as SsoTestAnswer;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SsoTestAnswer() / SsoTestAnswer.new instead')
  static SsoTestAnswer create() => SsoTestAnswer._();
  static $pb.GeneratedMessage $_createMessage() => SsoTestAnswer._();
  @$core.override
  SsoTestAnswer createEmptyInstance() => SsoTestAnswer._();
  @$core.pragma('dart2js:noInline')
  static SsoTestAnswer getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SsoTestAnswer>(
          SsoTestAnswer.$_createMessage);
  static SsoTestAnswer? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get ok => $_getBF(0);
  @$pb.TagNumber(1)
  set ok($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasOk() => $_has(0);
  @$pb.TagNumber(1)
  void clearOk() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get redirectUri => $_getSZ(2);
  @$pb.TagNumber(3)
  set redirectUri($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRedirectUri() => $_has(2);
  @$pb.TagNumber(3)
  void clearRedirectUri() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get authorizationEndpoint => $_getSZ(3);
  @$pb.TagNumber(4)
  set authorizationEndpoint($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasAuthorizationEndpoint() => $_has(3);
  @$pb.TagNumber(4)
  void clearAuthorizationEndpoint() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get tokenEndpoint => $_getSZ(4);
  @$pb.TagNumber(5)
  set tokenEndpoint($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasTokenEndpoint() => $_has(4);
  @$pb.TagNumber(5)
  void clearTokenEndpoint() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get jwksUri => $_getSZ(5);
  @$pb.TagNumber(6)
  set jwksUri($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasJwksUri() => $_has(5);
  @$pb.TagNumber(6)
  void clearJwksUri() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.int get keys => $_getIZ(6);
  @$pb.TagNumber(7)
  set keys($core.int value) => $_setSignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasKeys() => $_has(6);
  @$pb.TagNumber(7)
  void clearKeys() => $_clearField(7);
}

class SsoTestRequest extends $pb.GeneratedMessage {
  factory SsoTestRequest({
    $core.String? workspaceId,
  }) {
    final result = SsoTestRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    return result;
  }

  SsoTestRequest._();

  factory SsoTestRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SsoTestRequest()..mergeFromBuffer(data, registry);
  factory SsoTestRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SsoTestRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SsoTestRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.security'),
      createEmptyInstance: SsoTestRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SsoTestRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SsoTestRequest copyWith(void Function(SsoTestRequest) updates) =>
      super.copyWith((message) => updates(message as SsoTestRequest))
          as SsoTestRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SsoTestRequest() / SsoTestRequest.new instead')
  static SsoTestRequest create() => SsoTestRequest._();
  static $pb.GeneratedMessage $_createMessage() => SsoTestRequest._();
  @$core.override
  SsoTestRequest createEmptyInstance() => SsoTestRequest._();
  @$core.pragma('dart2js:noInline')
  static SsoTestRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SsoTestRequest>(
          SsoTestRequest.$_createMessage);
  static SsoTestRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);
}

class TrustedDevice extends $pb.GeneratedMessage {
  factory TrustedDevice({
    $core.String? id,
    $core.String? label,
    $core.String? createdAt,
    $core.String? lastUsedAt,
    $core.String? expiresAt,
  }) {
    final result = TrustedDevice._();
    if (id != null) result.id = id;
    if (label != null) result.label = label;
    if (createdAt != null) result.createdAt = createdAt;
    if (lastUsedAt != null) result.lastUsedAt = lastUsedAt;
    if (expiresAt != null) result.expiresAt = expiresAt;
    return result;
  }

  TrustedDevice._();

  factory TrustedDevice.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TrustedDevice()..mergeFromBuffer(data, registry);
  factory TrustedDevice.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TrustedDevice()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TrustedDevice',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.security'),
      createEmptyInstance: TrustedDevice.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'label')
    ..aOS(3, _omitFieldNames ? '' : 'createdAt')
    ..aOS(4, _omitFieldNames ? '' : 'lastUsedAt')
    ..aOS(5, _omitFieldNames ? '' : 'expiresAt')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TrustedDevice clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TrustedDevice copyWith(void Function(TrustedDevice) updates) =>
      super.copyWith((message) => updates(message as TrustedDevice))
          as TrustedDevice;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use TrustedDevice() / TrustedDevice.new instead')
  static TrustedDevice create() => TrustedDevice._();
  static $pb.GeneratedMessage $_createMessage() => TrustedDevice._();
  @$core.override
  TrustedDevice createEmptyInstance() => TrustedDevice._();
  @$core.pragma('dart2js:noInline')
  static TrustedDevice getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TrustedDevice>(
          TrustedDevice.$_createMessage);
  static TrustedDevice? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get label => $_getSZ(1);
  @$pb.TagNumber(2)
  set label($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasLabel() => $_has(1);
  @$pb.TagNumber(2)
  void clearLabel() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get createdAt => $_getSZ(2);
  @$pb.TagNumber(3)
  set createdAt($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasCreatedAt() => $_has(2);
  @$pb.TagNumber(3)
  void clearCreatedAt() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get lastUsedAt => $_getSZ(3);
  @$pb.TagNumber(4)
  set lastUsedAt($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasLastUsedAt() => $_has(3);
  @$pb.TagNumber(4)
  void clearLastUsedAt() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get expiresAt => $_getSZ(4);
  @$pb.TagNumber(5)
  set expiresAt($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasExpiresAt() => $_has(4);
  @$pb.TagNumber(5)
  void clearExpiresAt() => $_clearField(5);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
