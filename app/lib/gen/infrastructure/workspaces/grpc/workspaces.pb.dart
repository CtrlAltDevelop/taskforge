// This is a generated file - do not edit.
//
// Generated from infrastructure/workspaces/grpc/workspaces.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class Invitation extends $pb.GeneratedMessage {
  factory Invitation({
    $core.String? id,
    $core.String? workspaceId,
    $core.String? email,
    $core.bool? isLink,
    $core.String? createdBy,
    $core.String? createdByName,
    $core.String? createdAt,
    $core.String? expiresAt,
    $core.int? maxUses,
    $core.int? uses,
    $core.String? state,
    $core.String? token,
    $core.String? roleId,
    $core.String? roleName,
  }) {
    final result = Invitation._();
    if (id != null) result.id = id;
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (email != null) result.email = email;
    if (isLink != null) result.isLink = isLink;
    if (createdBy != null) result.createdBy = createdBy;
    if (createdByName != null) result.createdByName = createdByName;
    if (createdAt != null) result.createdAt = createdAt;
    if (expiresAt != null) result.expiresAt = expiresAt;
    if (maxUses != null) result.maxUses = maxUses;
    if (uses != null) result.uses = uses;
    if (state != null) result.state = state;
    if (token != null) result.token = token;
    if (roleId != null) result.roleId = roleId;
    if (roleName != null) result.roleName = roleName;
    return result;
  }

  Invitation._();

  factory Invitation.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Invitation()..mergeFromBuffer(data, registry);
  factory Invitation.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Invitation()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Invitation',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.workspaces'),
      createEmptyInstance: Invitation.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(3, _omitFieldNames ? '' : 'email')
    ..aOB(4, _omitFieldNames ? '' : 'isLink')
    ..aOS(5, _omitFieldNames ? '' : 'createdBy')
    ..aOS(6, _omitFieldNames ? '' : 'createdByName')
    ..aOS(7, _omitFieldNames ? '' : 'createdAt')
    ..aOS(8, _omitFieldNames ? '' : 'expiresAt')
    ..aI(9, _omitFieldNames ? '' : 'maxUses')
    ..aI(10, _omitFieldNames ? '' : 'uses')
    ..aOS(11, _omitFieldNames ? '' : 'state')
    ..aOS(12, _omitFieldNames ? '' : 'token')
    ..aOS(13, _omitFieldNames ? '' : 'roleId')
    ..aOS(14, _omitFieldNames ? '' : 'roleName')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Invitation clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Invitation copyWith(void Function(Invitation) updates) =>
      super.copyWith((message) => updates(message as Invitation)) as Invitation;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Invitation() / Invitation.new instead')
  static Invitation create() => Invitation._();
  static $pb.GeneratedMessage $_createMessage() => Invitation._();
  @$core.override
  Invitation createEmptyInstance() => Invitation._();
  @$core.pragma('dart2js:noInline')
  static Invitation getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Invitation>(Invitation.$_createMessage);
  static Invitation? _defaultInstance;

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
  $core.String get email => $_getSZ(2);
  @$pb.TagNumber(3)
  set email($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasEmail() => $_has(2);
  @$pb.TagNumber(3)
  void clearEmail() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get isLink => $_getBF(3);
  @$pb.TagNumber(4)
  set isLink($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasIsLink() => $_has(3);
  @$pb.TagNumber(4)
  void clearIsLink() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get createdBy => $_getSZ(4);
  @$pb.TagNumber(5)
  set createdBy($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasCreatedBy() => $_has(4);
  @$pb.TagNumber(5)
  void clearCreatedBy() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get createdByName => $_getSZ(5);
  @$pb.TagNumber(6)
  set createdByName($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasCreatedByName() => $_has(5);
  @$pb.TagNumber(6)
  void clearCreatedByName() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get createdAt => $_getSZ(6);
  @$pb.TagNumber(7)
  set createdAt($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasCreatedAt() => $_has(6);
  @$pb.TagNumber(7)
  void clearCreatedAt() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get expiresAt => $_getSZ(7);
  @$pb.TagNumber(8)
  set expiresAt($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasExpiresAt() => $_has(7);
  @$pb.TagNumber(8)
  void clearExpiresAt() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.int get maxUses => $_getIZ(8);
  @$pb.TagNumber(9)
  set maxUses($core.int value) => $_setSignedInt32(8, value);
  @$pb.TagNumber(9)
  $core.bool hasMaxUses() => $_has(8);
  @$pb.TagNumber(9)
  void clearMaxUses() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.int get uses => $_getIZ(9);
  @$pb.TagNumber(10)
  set uses($core.int value) => $_setSignedInt32(9, value);
  @$pb.TagNumber(10)
  $core.bool hasUses() => $_has(9);
  @$pb.TagNumber(10)
  void clearUses() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.String get state => $_getSZ(10);
  @$pb.TagNumber(11)
  set state($core.String value) => $_setString(10, value);
  @$pb.TagNumber(11)
  $core.bool hasState() => $_has(10);
  @$pb.TagNumber(11)
  void clearState() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.String get token => $_getSZ(11);
  @$pb.TagNumber(12)
  set token($core.String value) => $_setString(11, value);
  @$pb.TagNumber(12)
  $core.bool hasToken() => $_has(11);
  @$pb.TagNumber(12)
  void clearToken() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.String get roleId => $_getSZ(12);
  @$pb.TagNumber(13)
  set roleId($core.String value) => $_setString(12, value);
  @$pb.TagNumber(13)
  $core.bool hasRoleId() => $_has(12);
  @$pb.TagNumber(13)
  void clearRoleId() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.String get roleName => $_getSZ(13);
  @$pb.TagNumber(14)
  set roleName($core.String value) => $_setString(13, value);
  @$pb.TagNumber(14)
  $core.bool hasRoleName() => $_has(13);
  @$pb.TagNumber(14)
  void clearRoleName() => $_clearField(14);
}

class InvitationAcceptRequest extends $pb.GeneratedMessage {
  factory InvitationAcceptRequest({
    $core.String? token,
  }) {
    final result = InvitationAcceptRequest._();
    if (token != null) result.token = token;
    return result;
  }

  InvitationAcceptRequest._();

  factory InvitationAcceptRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      InvitationAcceptRequest()..mergeFromBuffer(data, registry);
  factory InvitationAcceptRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      InvitationAcceptRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'InvitationAcceptRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.workspaces'),
      createEmptyInstance: InvitationAcceptRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'token')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InvitationAcceptRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InvitationAcceptRequest copyWith(
          void Function(InvitationAcceptRequest) updates) =>
      super.copyWith((message) => updates(message as InvitationAcceptRequest))
          as InvitationAcceptRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use InvitationAcceptRequest() / InvitationAcceptRequest.new instead')
  static InvitationAcceptRequest create() => InvitationAcceptRequest._();
  static $pb.GeneratedMessage $_createMessage() => InvitationAcceptRequest._();
  @$core.override
  InvitationAcceptRequest createEmptyInstance() => InvitationAcceptRequest._();
  @$core.pragma('dart2js:noInline')
  static InvitationAcceptRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<InvitationAcceptRequest>(
          InvitationAcceptRequest.$_createMessage);
  static InvitationAcceptRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get token => $_getSZ(0);
  @$pb.TagNumber(1)
  set token($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasToken() => $_has(0);
  @$pb.TagNumber(1)
  void clearToken() => $_clearField(1);
}

class InvitationCreateLinkRequest extends $pb.GeneratedMessage {
  factory InvitationCreateLinkRequest({
    $core.String? workspaceId,
    $core.int? expiresIn,
    $core.int? maxUses,
    $core.String? roleId,
  }) {
    final result = InvitationCreateLinkRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (expiresIn != null) result.expiresIn = expiresIn;
    if (maxUses != null) result.maxUses = maxUses;
    if (roleId != null) result.roleId = roleId;
    return result;
  }

  InvitationCreateLinkRequest._();

  factory InvitationCreateLinkRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      InvitationCreateLinkRequest()..mergeFromBuffer(data, registry);
  factory InvitationCreateLinkRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      InvitationCreateLinkRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'InvitationCreateLinkRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.workspaces'),
      createEmptyInstance: InvitationCreateLinkRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aI(2, _omitFieldNames ? '' : 'expiresIn')
    ..aI(3, _omitFieldNames ? '' : 'maxUses')
    ..aOS(4, _omitFieldNames ? '' : 'roleId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InvitationCreateLinkRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InvitationCreateLinkRequest copyWith(
          void Function(InvitationCreateLinkRequest) updates) =>
      super.copyWith(
              (message) => updates(message as InvitationCreateLinkRequest))
          as InvitationCreateLinkRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use InvitationCreateLinkRequest() / InvitationCreateLinkRequest.new instead')
  static InvitationCreateLinkRequest create() =>
      InvitationCreateLinkRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      InvitationCreateLinkRequest._();
  @$core.override
  InvitationCreateLinkRequest createEmptyInstance() =>
      InvitationCreateLinkRequest._();
  @$core.pragma('dart2js:noInline')
  static InvitationCreateLinkRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<InvitationCreateLinkRequest>(
          InvitationCreateLinkRequest.$_createMessage);
  static InvitationCreateLinkRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get expiresIn => $_getIZ(1);
  @$pb.TagNumber(2)
  set expiresIn($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasExpiresIn() => $_has(1);
  @$pb.TagNumber(2)
  void clearExpiresIn() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get maxUses => $_getIZ(2);
  @$pb.TagNumber(3)
  set maxUses($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasMaxUses() => $_has(2);
  @$pb.TagNumber(3)
  void clearMaxUses() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get roleId => $_getSZ(3);
  @$pb.TagNumber(4)
  set roleId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasRoleId() => $_has(3);
  @$pb.TagNumber(4)
  void clearRoleId() => $_clearField(4);
}

class InvitationCreateRequest extends $pb.GeneratedMessage {
  factory InvitationCreateRequest({
    $core.String? workspaceId,
    $core.Iterable<$core.String>? emails,
    $core.String? roleId,
  }) {
    final result = InvitationCreateRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (emails != null) result.emails.addAll(emails);
    if (roleId != null) result.roleId = roleId;
    return result;
  }

  InvitationCreateRequest._();

  factory InvitationCreateRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      InvitationCreateRequest()..mergeFromBuffer(data, registry);
  factory InvitationCreateRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      InvitationCreateRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'InvitationCreateRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.workspaces'),
      createEmptyInstance: InvitationCreateRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..pPS(2, _omitFieldNames ? '' : 'emails')
    ..aOS(3, _omitFieldNames ? '' : 'roleId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InvitationCreateRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InvitationCreateRequest copyWith(
          void Function(InvitationCreateRequest) updates) =>
      super.copyWith((message) => updates(message as InvitationCreateRequest))
          as InvitationCreateRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use InvitationCreateRequest() / InvitationCreateRequest.new instead')
  static InvitationCreateRequest create() => InvitationCreateRequest._();
  static $pb.GeneratedMessage $_createMessage() => InvitationCreateRequest._();
  @$core.override
  InvitationCreateRequest createEmptyInstance() => InvitationCreateRequest._();
  @$core.pragma('dart2js:noInline')
  static InvitationCreateRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<InvitationCreateRequest>(
          InvitationCreateRequest.$_createMessage);
  static InvitationCreateRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<$core.String> get emails => $_getList(1);

  @$pb.TagNumber(3)
  $core.String get roleId => $_getSZ(2);
  @$pb.TagNumber(3)
  set roleId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRoleId() => $_has(2);
  @$pb.TagNumber(3)
  void clearRoleId() => $_clearField(3);
}

class InvitationCreateResponse extends $pb.GeneratedMessage {
  factory InvitationCreateResponse({
    $core.Iterable<Invitation>? invitations,
    $core.Iterable<$core.String>? skippedEmails,
    $core.Iterable<$core.String>? undeliveredEmails,
  }) {
    final result = InvitationCreateResponse._();
    if (invitations != null) result.invitations.addAll(invitations);
    if (skippedEmails != null) result.skippedEmails.addAll(skippedEmails);
    if (undeliveredEmails != null)
      result.undeliveredEmails.addAll(undeliveredEmails);
    return result;
  }

  InvitationCreateResponse._();

  factory InvitationCreateResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      InvitationCreateResponse()..mergeFromBuffer(data, registry);
  factory InvitationCreateResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      InvitationCreateResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'InvitationCreateResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.workspaces'),
      createEmptyInstance: InvitationCreateResponse.$_createMessage)
    ..pPM<Invitation>(1, _omitFieldNames ? '' : 'invitations',
        subBuilder: Invitation.$_createMessage)
    ..pPS(2, _omitFieldNames ? '' : 'skippedEmails')
    ..pPS(3, _omitFieldNames ? '' : 'undeliveredEmails')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InvitationCreateResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InvitationCreateResponse copyWith(
          void Function(InvitationCreateResponse) updates) =>
      super.copyWith((message) => updates(message as InvitationCreateResponse))
          as InvitationCreateResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use InvitationCreateResponse() / InvitationCreateResponse.new instead')
  static InvitationCreateResponse create() => InvitationCreateResponse._();
  static $pb.GeneratedMessage $_createMessage() => InvitationCreateResponse._();
  @$core.override
  InvitationCreateResponse createEmptyInstance() =>
      InvitationCreateResponse._();
  @$core.pragma('dart2js:noInline')
  static InvitationCreateResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<InvitationCreateResponse>(
          InvitationCreateResponse.$_createMessage);
  static InvitationCreateResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Invitation> get invitations => $_getList(0);

  @$pb.TagNumber(2)
  $pb.PbList<$core.String> get skippedEmails => $_getList(1);

  @$pb.TagNumber(3)
  $pb.PbList<$core.String> get undeliveredEmails => $_getList(2);
}

class InvitationDeclineRequest extends $pb.GeneratedMessage {
  factory InvitationDeclineRequest({
    $core.String? token,
  }) {
    final result = InvitationDeclineRequest._();
    if (token != null) result.token = token;
    return result;
  }

  InvitationDeclineRequest._();

  factory InvitationDeclineRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      InvitationDeclineRequest()..mergeFromBuffer(data, registry);
  factory InvitationDeclineRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      InvitationDeclineRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'InvitationDeclineRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.workspaces'),
      createEmptyInstance: InvitationDeclineRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'token')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InvitationDeclineRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InvitationDeclineRequest copyWith(
          void Function(InvitationDeclineRequest) updates) =>
      super.copyWith((message) => updates(message as InvitationDeclineRequest))
          as InvitationDeclineRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use InvitationDeclineRequest() / InvitationDeclineRequest.new instead')
  static InvitationDeclineRequest create() => InvitationDeclineRequest._();
  static $pb.GeneratedMessage $_createMessage() => InvitationDeclineRequest._();
  @$core.override
  InvitationDeclineRequest createEmptyInstance() =>
      InvitationDeclineRequest._();
  @$core.pragma('dart2js:noInline')
  static InvitationDeclineRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<InvitationDeclineRequest>(
          InvitationDeclineRequest.$_createMessage);
  static InvitationDeclineRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get token => $_getSZ(0);
  @$pb.TagNumber(1)
  set token($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasToken() => $_has(0);
  @$pb.TagNumber(1)
  void clearToken() => $_clearField(1);
}

class InvitationEmpty extends $pb.GeneratedMessage {
  factory InvitationEmpty() => InvitationEmpty._();

  InvitationEmpty._();

  factory InvitationEmpty.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      InvitationEmpty()..mergeFromBuffer(data, registry);
  factory InvitationEmpty.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      InvitationEmpty()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'InvitationEmpty',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.workspaces'),
      createEmptyInstance: InvitationEmpty.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InvitationEmpty clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InvitationEmpty copyWith(void Function(InvitationEmpty) updates) =>
      super.copyWith((message) => updates(message as InvitationEmpty))
          as InvitationEmpty;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use InvitationEmpty() / InvitationEmpty.new instead')
  static InvitationEmpty create() => InvitationEmpty._();
  static $pb.GeneratedMessage $_createMessage() => InvitationEmpty._();
  @$core.override
  InvitationEmpty createEmptyInstance() => InvitationEmpty._();
  @$core.pragma('dart2js:noInline')
  static InvitationEmpty getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<InvitationEmpty>(
          InvitationEmpty.$_createMessage);
  static InvitationEmpty? _defaultInstance;
}

class InvitationList extends $pb.GeneratedMessage {
  factory InvitationList({
    $core.Iterable<Invitation>? invitations,
  }) {
    final result = InvitationList._();
    if (invitations != null) result.invitations.addAll(invitations);
    return result;
  }

  InvitationList._();

  factory InvitationList.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      InvitationList()..mergeFromBuffer(data, registry);
  factory InvitationList.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      InvitationList()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'InvitationList',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.workspaces'),
      createEmptyInstance: InvitationList.$_createMessage)
    ..pPM<Invitation>(1, _omitFieldNames ? '' : 'invitations',
        subBuilder: Invitation.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InvitationList clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InvitationList copyWith(void Function(InvitationList) updates) =>
      super.copyWith((message) => updates(message as InvitationList))
          as InvitationList;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use InvitationList() / InvitationList.new instead')
  static InvitationList create() => InvitationList._();
  static $pb.GeneratedMessage $_createMessage() => InvitationList._();
  @$core.override
  InvitationList createEmptyInstance() => InvitationList._();
  @$core.pragma('dart2js:noInline')
  static InvitationList getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<InvitationList>(
          InvitationList.$_createMessage);
  static InvitationList? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Invitation> get invitations => $_getList(0);
}

class InvitationListRequest extends $pb.GeneratedMessage {
  factory InvitationListRequest({
    $core.String? workspaceId,
  }) {
    final result = InvitationListRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    return result;
  }

  InvitationListRequest._();

  factory InvitationListRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      InvitationListRequest()..mergeFromBuffer(data, registry);
  factory InvitationListRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      InvitationListRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'InvitationListRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.workspaces'),
      createEmptyInstance: InvitationListRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InvitationListRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InvitationListRequest copyWith(
          void Function(InvitationListRequest) updates) =>
      super.copyWith((message) => updates(message as InvitationListRequest))
          as InvitationListRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use InvitationListRequest() / InvitationListRequest.new instead')
  static InvitationListRequest create() => InvitationListRequest._();
  static $pb.GeneratedMessage $_createMessage() => InvitationListRequest._();
  @$core.override
  InvitationListRequest createEmptyInstance() => InvitationListRequest._();
  @$core.pragma('dart2js:noInline')
  static InvitationListRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<InvitationListRequest>(
          InvitationListRequest.$_createMessage);
  static InvitationListRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);
}

class InvitationResendRequest extends $pb.GeneratedMessage {
  factory InvitationResendRequest({
    $core.String? workspaceId,
    $core.String? id,
  }) {
    final result = InvitationResendRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (id != null) result.id = id;
    return result;
  }

  InvitationResendRequest._();

  factory InvitationResendRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      InvitationResendRequest()..mergeFromBuffer(data, registry);
  factory InvitationResendRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      InvitationResendRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'InvitationResendRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.workspaces'),
      createEmptyInstance: InvitationResendRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InvitationResendRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InvitationResendRequest copyWith(
          void Function(InvitationResendRequest) updates) =>
      super.copyWith((message) => updates(message as InvitationResendRequest))
          as InvitationResendRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use InvitationResendRequest() / InvitationResendRequest.new instead')
  static InvitationResendRequest create() => InvitationResendRequest._();
  static $pb.GeneratedMessage $_createMessage() => InvitationResendRequest._();
  @$core.override
  InvitationResendRequest createEmptyInstance() => InvitationResendRequest._();
  @$core.pragma('dart2js:noInline')
  static InvitationResendRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<InvitationResendRequest>(
          InvitationResendRequest.$_createMessage);
  static InvitationResendRequest? _defaultInstance;

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

class InvitationRevokeRequest extends $pb.GeneratedMessage {
  factory InvitationRevokeRequest({
    $core.String? workspaceId,
    $core.String? id,
  }) {
    final result = InvitationRevokeRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (id != null) result.id = id;
    return result;
  }

  InvitationRevokeRequest._();

  factory InvitationRevokeRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      InvitationRevokeRequest()..mergeFromBuffer(data, registry);
  factory InvitationRevokeRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      InvitationRevokeRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'InvitationRevokeRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.workspaces'),
      createEmptyInstance: InvitationRevokeRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InvitationRevokeRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InvitationRevokeRequest copyWith(
          void Function(InvitationRevokeRequest) updates) =>
      super.copyWith((message) => updates(message as InvitationRevokeRequest))
          as InvitationRevokeRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use InvitationRevokeRequest() / InvitationRevokeRequest.new instead')
  static InvitationRevokeRequest create() => InvitationRevokeRequest._();
  static $pb.GeneratedMessage $_createMessage() => InvitationRevokeRequest._();
  @$core.override
  InvitationRevokeRequest createEmptyInstance() => InvitationRevokeRequest._();
  @$core.pragma('dart2js:noInline')
  static InvitationRevokeRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<InvitationRevokeRequest>(
          InvitationRevokeRequest.$_createMessage);
  static InvitationRevokeRequest? _defaultInstance;

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

class Member extends $pb.GeneratedMessage {
  factory Member({
    $core.String? userId,
    $core.String? displayName,
    $core.String? email,
    $core.String? joinedAt,
    $core.bool? isOwner,
    $core.String? status,
    $core.String? roleId,
    $core.String? roleName,
  }) {
    final result = Member._();
    if (userId != null) result.userId = userId;
    if (displayName != null) result.displayName = displayName;
    if (email != null) result.email = email;
    if (joinedAt != null) result.joinedAt = joinedAt;
    if (isOwner != null) result.isOwner = isOwner;
    if (status != null) result.status = status;
    if (roleId != null) result.roleId = roleId;
    if (roleName != null) result.roleName = roleName;
    return result;
  }

  Member._();

  factory Member.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Member()..mergeFromBuffer(data, registry);
  factory Member.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Member()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Member',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.workspaces'),
      createEmptyInstance: Member.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'userId')
    ..aOS(2, _omitFieldNames ? '' : 'displayName')
    ..aOS(3, _omitFieldNames ? '' : 'email')
    ..aOS(4, _omitFieldNames ? '' : 'joinedAt')
    ..aOB(5, _omitFieldNames ? '' : 'isOwner')
    ..aOS(6, _omitFieldNames ? '' : 'status')
    ..aOS(7, _omitFieldNames ? '' : 'roleId')
    ..aOS(8, _omitFieldNames ? '' : 'roleName')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Member clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Member copyWith(void Function(Member) updates) =>
      super.copyWith((message) => updates(message as Member)) as Member;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Member() / Member.new instead')
  static Member create() => Member._();
  static $pb.GeneratedMessage $_createMessage() => Member._();
  @$core.override
  Member createEmptyInstance() => Member._();
  @$core.pragma('dart2js:noInline')
  static Member getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Member>(Member.$_createMessage);
  static Member? _defaultInstance;

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
  $core.String get joinedAt => $_getSZ(3);
  @$pb.TagNumber(4)
  set joinedAt($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasJoinedAt() => $_has(3);
  @$pb.TagNumber(4)
  void clearJoinedAt() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.bool get isOwner => $_getBF(4);
  @$pb.TagNumber(5)
  set isOwner($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasIsOwner() => $_has(4);
  @$pb.TagNumber(5)
  void clearIsOwner() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get status => $_getSZ(5);
  @$pb.TagNumber(6)
  set status($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasStatus() => $_has(5);
  @$pb.TagNumber(6)
  void clearStatus() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get roleId => $_getSZ(6);
  @$pb.TagNumber(7)
  set roleId($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasRoleId() => $_has(6);
  @$pb.TagNumber(7)
  void clearRoleId() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get roleName => $_getSZ(7);
  @$pb.TagNumber(8)
  set roleName($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasRoleName() => $_has(7);
  @$pb.TagNumber(8)
  void clearRoleName() => $_clearField(8);
}

class MemberEmpty extends $pb.GeneratedMessage {
  factory MemberEmpty() => MemberEmpty._();

  MemberEmpty._();

  factory MemberEmpty.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MemberEmpty()..mergeFromBuffer(data, registry);
  factory MemberEmpty.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MemberEmpty()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MemberEmpty',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.workspaces'),
      createEmptyInstance: MemberEmpty.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MemberEmpty clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MemberEmpty copyWith(void Function(MemberEmpty) updates) =>
      super.copyWith((message) => updates(message as MemberEmpty))
          as MemberEmpty;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use MemberEmpty() / MemberEmpty.new instead')
  static MemberEmpty create() => MemberEmpty._();
  static $pb.GeneratedMessage $_createMessage() => MemberEmpty._();
  @$core.override
  MemberEmpty createEmptyInstance() => MemberEmpty._();
  @$core.pragma('dart2js:noInline')
  static MemberEmpty getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MemberEmpty>(
          MemberEmpty.$_createMessage);
  static MemberEmpty? _defaultInstance;
}

class MemberLeaveRequest extends $pb.GeneratedMessage {
  factory MemberLeaveRequest({
    $core.String? workspaceId,
  }) {
    final result = MemberLeaveRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    return result;
  }

  MemberLeaveRequest._();

  factory MemberLeaveRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MemberLeaveRequest()..mergeFromBuffer(data, registry);
  factory MemberLeaveRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MemberLeaveRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MemberLeaveRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.workspaces'),
      createEmptyInstance: MemberLeaveRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MemberLeaveRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MemberLeaveRequest copyWith(void Function(MemberLeaveRequest) updates) =>
      super.copyWith((message) => updates(message as MemberLeaveRequest))
          as MemberLeaveRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use MemberLeaveRequest() / MemberLeaveRequest.new instead')
  static MemberLeaveRequest create() => MemberLeaveRequest._();
  static $pb.GeneratedMessage $_createMessage() => MemberLeaveRequest._();
  @$core.override
  MemberLeaveRequest createEmptyInstance() => MemberLeaveRequest._();
  @$core.pragma('dart2js:noInline')
  static MemberLeaveRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MemberLeaveRequest>(
          MemberLeaveRequest.$_createMessage);
  static MemberLeaveRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);
}

class MemberList extends $pb.GeneratedMessage {
  factory MemberList({
    $core.Iterable<Member>? members,
  }) {
    final result = MemberList._();
    if (members != null) result.members.addAll(members);
    return result;
  }

  MemberList._();

  factory MemberList.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MemberList()..mergeFromBuffer(data, registry);
  factory MemberList.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MemberList()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MemberList',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.workspaces'),
      createEmptyInstance: MemberList.$_createMessage)
    ..pPM<Member>(1, _omitFieldNames ? '' : 'members',
        subBuilder: Member.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MemberList clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MemberList copyWith(void Function(MemberList) updates) =>
      super.copyWith((message) => updates(message as MemberList)) as MemberList;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use MemberList() / MemberList.new instead')
  static MemberList create() => MemberList._();
  static $pb.GeneratedMessage $_createMessage() => MemberList._();
  @$core.override
  MemberList createEmptyInstance() => MemberList._();
  @$core.pragma('dart2js:noInline')
  static MemberList getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MemberList>(MemberList.$_createMessage);
  static MemberList? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Member> get members => $_getList(0);
}

class MemberListRequest extends $pb.GeneratedMessage {
  factory MemberListRequest({
    $core.String? workspaceId,
  }) {
    final result = MemberListRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    return result;
  }

  MemberListRequest._();

  factory MemberListRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MemberListRequest()..mergeFromBuffer(data, registry);
  factory MemberListRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MemberListRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MemberListRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.workspaces'),
      createEmptyInstance: MemberListRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MemberListRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MemberListRequest copyWith(void Function(MemberListRequest) updates) =>
      super.copyWith((message) => updates(message as MemberListRequest))
          as MemberListRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use MemberListRequest() / MemberListRequest.new instead')
  static MemberListRequest create() => MemberListRequest._();
  static $pb.GeneratedMessage $_createMessage() => MemberListRequest._();
  @$core.override
  MemberListRequest createEmptyInstance() => MemberListRequest._();
  @$core.pragma('dart2js:noInline')
  static MemberListRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MemberListRequest>(
          MemberListRequest.$_createMessage);
  static MemberListRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);
}

class MemberRemoveRequest extends $pb.GeneratedMessage {
  factory MemberRemoveRequest({
    $core.String? workspaceId,
    $core.String? userId,
  }) {
    final result = MemberRemoveRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (userId != null) result.userId = userId;
    return result;
  }

  MemberRemoveRequest._();

  factory MemberRemoveRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MemberRemoveRequest()..mergeFromBuffer(data, registry);
  factory MemberRemoveRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MemberRemoveRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MemberRemoveRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.workspaces'),
      createEmptyInstance: MemberRemoveRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'userId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MemberRemoveRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MemberRemoveRequest copyWith(void Function(MemberRemoveRequest) updates) =>
      super.copyWith((message) => updates(message as MemberRemoveRequest))
          as MemberRemoveRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core
      .Deprecated('Use MemberRemoveRequest() / MemberRemoveRequest.new instead')
  static MemberRemoveRequest create() => MemberRemoveRequest._();
  static $pb.GeneratedMessage $_createMessage() => MemberRemoveRequest._();
  @$core.override
  MemberRemoveRequest createEmptyInstance() => MemberRemoveRequest._();
  @$core.pragma('dart2js:noInline')
  static MemberRemoveRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MemberRemoveRequest>(
          MemberRemoveRequest.$_createMessage);
  static MemberRemoveRequest? _defaultInstance;

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

class MemberSetRoleRequest extends $pb.GeneratedMessage {
  factory MemberSetRoleRequest({
    $core.String? workspaceId,
    $core.String? userId,
    $core.String? roleId,
  }) {
    final result = MemberSetRoleRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (userId != null) result.userId = userId;
    if (roleId != null) result.roleId = roleId;
    return result;
  }

  MemberSetRoleRequest._();

  factory MemberSetRoleRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MemberSetRoleRequest()..mergeFromBuffer(data, registry);
  factory MemberSetRoleRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MemberSetRoleRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MemberSetRoleRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.workspaces'),
      createEmptyInstance: MemberSetRoleRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'userId')
    ..aOS(3, _omitFieldNames ? '' : 'roleId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MemberSetRoleRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MemberSetRoleRequest copyWith(void Function(MemberSetRoleRequest) updates) =>
      super.copyWith((message) => updates(message as MemberSetRoleRequest))
          as MemberSetRoleRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use MemberSetRoleRequest() / MemberSetRoleRequest.new instead')
  static MemberSetRoleRequest create() => MemberSetRoleRequest._();
  static $pb.GeneratedMessage $_createMessage() => MemberSetRoleRequest._();
  @$core.override
  MemberSetRoleRequest createEmptyInstance() => MemberSetRoleRequest._();
  @$core.pragma('dart2js:noInline')
  static MemberSetRoleRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MemberSetRoleRequest>(
          MemberSetRoleRequest.$_createMessage);
  static MemberSetRoleRequest? _defaultInstance;

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

  @$pb.TagNumber(3)
  $core.String get roleId => $_getSZ(2);
  @$pb.TagNumber(3)
  set roleId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRoleId() => $_has(2);
  @$pb.TagNumber(3)
  void clearRoleId() => $_clearField(3);
}

class PermissionAnswer extends $pb.GeneratedMessage {
  factory PermissionAnswer({
    $core.String? key,
    $core.bool? allowed,
  }) {
    final result = PermissionAnswer._();
    if (key != null) result.key = key;
    if (allowed != null) result.allowed = allowed;
    return result;
  }

  PermissionAnswer._();

  factory PermissionAnswer.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PermissionAnswer()..mergeFromBuffer(data, registry);
  factory PermissionAnswer.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PermissionAnswer()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PermissionAnswer',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.workspaces'),
      createEmptyInstance: PermissionAnswer.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'key')
    ..aOB(2, _omitFieldNames ? '' : 'allowed')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PermissionAnswer clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PermissionAnswer copyWith(void Function(PermissionAnswer) updates) =>
      super.copyWith((message) => updates(message as PermissionAnswer))
          as PermissionAnswer;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use PermissionAnswer() / PermissionAnswer.new instead')
  static PermissionAnswer create() => PermissionAnswer._();
  static $pb.GeneratedMessage $_createMessage() => PermissionAnswer._();
  @$core.override
  PermissionAnswer createEmptyInstance() => PermissionAnswer._();
  @$core.pragma('dart2js:noInline')
  static PermissionAnswer getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PermissionAnswer>(
          PermissionAnswer.$_createMessage);
  static PermissionAnswer? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get key => $_getSZ(0);
  @$pb.TagNumber(1)
  set key($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasKey() => $_has(0);
  @$pb.TagNumber(1)
  void clearKey() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get allowed => $_getBF(1);
  @$pb.TagNumber(2)
  set allowed($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAllowed() => $_has(1);
  @$pb.TagNumber(2)
  void clearAllowed() => $_clearField(2);
}

class PermissionArea extends $pb.GeneratedMessage {
  factory PermissionArea({
    $core.String? area,
    $core.Iterable<PermissionInfo>? permissions,
  }) {
    final result = PermissionArea._();
    if (area != null) result.area = area;
    if (permissions != null) result.permissions.addAll(permissions);
    return result;
  }

  PermissionArea._();

  factory PermissionArea.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PermissionArea()..mergeFromBuffer(data, registry);
  factory PermissionArea.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PermissionArea()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PermissionArea',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.workspaces'),
      createEmptyInstance: PermissionArea.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'area')
    ..pPM<PermissionInfo>(2, _omitFieldNames ? '' : 'permissions',
        subBuilder: PermissionInfo.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PermissionArea clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PermissionArea copyWith(void Function(PermissionArea) updates) =>
      super.copyWith((message) => updates(message as PermissionArea))
          as PermissionArea;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use PermissionArea() / PermissionArea.new instead')
  static PermissionArea create() => PermissionArea._();
  static $pb.GeneratedMessage $_createMessage() => PermissionArea._();
  @$core.override
  PermissionArea createEmptyInstance() => PermissionArea._();
  @$core.pragma('dart2js:noInline')
  static PermissionArea getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PermissionArea>(
          PermissionArea.$_createMessage);
  static PermissionArea? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get area => $_getSZ(0);
  @$pb.TagNumber(1)
  set area($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasArea() => $_has(0);
  @$pb.TagNumber(1)
  void clearArea() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<PermissionInfo> get permissions => $_getList(1);
}

class PermissionCheckRequest extends $pb.GeneratedMessage {
  factory PermissionCheckRequest({
    $core.String? workspaceId,
    $core.Iterable<$core.String>? keys,
  }) {
    final result = PermissionCheckRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (keys != null) result.keys.addAll(keys);
    return result;
  }

  PermissionCheckRequest._();

  factory PermissionCheckRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PermissionCheckRequest()..mergeFromBuffer(data, registry);
  factory PermissionCheckRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PermissionCheckRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PermissionCheckRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.workspaces'),
      createEmptyInstance: PermissionCheckRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..pPS(2, _omitFieldNames ? '' : 'keys')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PermissionCheckRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PermissionCheckRequest copyWith(
          void Function(PermissionCheckRequest) updates) =>
      super.copyWith((message) => updates(message as PermissionCheckRequest))
          as PermissionCheckRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use PermissionCheckRequest() / PermissionCheckRequest.new instead')
  static PermissionCheckRequest create() => PermissionCheckRequest._();
  static $pb.GeneratedMessage $_createMessage() => PermissionCheckRequest._();
  @$core.override
  PermissionCheckRequest createEmptyInstance() => PermissionCheckRequest._();
  @$core.pragma('dart2js:noInline')
  static PermissionCheckRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PermissionCheckRequest>(
          PermissionCheckRequest.$_createMessage);
  static PermissionCheckRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<$core.String> get keys => $_getList(1);
}

class PermissionCheckResponse extends $pb.GeneratedMessage {
  factory PermissionCheckResponse({
    $core.Iterable<PermissionAnswer>? answers,
    $core.String? roleId,
    $core.String? roleName,
  }) {
    final result = PermissionCheckResponse._();
    if (answers != null) result.answers.addAll(answers);
    if (roleId != null) result.roleId = roleId;
    if (roleName != null) result.roleName = roleName;
    return result;
  }

  PermissionCheckResponse._();

  factory PermissionCheckResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PermissionCheckResponse()..mergeFromBuffer(data, registry);
  factory PermissionCheckResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PermissionCheckResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PermissionCheckResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.workspaces'),
      createEmptyInstance: PermissionCheckResponse.$_createMessage)
    ..pPM<PermissionAnswer>(1, _omitFieldNames ? '' : 'answers',
        subBuilder: PermissionAnswer.$_createMessage)
    ..aOS(2, _omitFieldNames ? '' : 'roleId')
    ..aOS(3, _omitFieldNames ? '' : 'roleName')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PermissionCheckResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PermissionCheckResponse copyWith(
          void Function(PermissionCheckResponse) updates) =>
      super.copyWith((message) => updates(message as PermissionCheckResponse))
          as PermissionCheckResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use PermissionCheckResponse() / PermissionCheckResponse.new instead')
  static PermissionCheckResponse create() => PermissionCheckResponse._();
  static $pb.GeneratedMessage $_createMessage() => PermissionCheckResponse._();
  @$core.override
  PermissionCheckResponse createEmptyInstance() => PermissionCheckResponse._();
  @$core.pragma('dart2js:noInline')
  static PermissionCheckResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PermissionCheckResponse>(
          PermissionCheckResponse.$_createMessage);
  static PermissionCheckResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<PermissionAnswer> get answers => $_getList(0);

  @$pb.TagNumber(2)
  $core.String get roleId => $_getSZ(1);
  @$pb.TagNumber(2)
  set roleId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRoleId() => $_has(1);
  @$pb.TagNumber(2)
  void clearRoleId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get roleName => $_getSZ(2);
  @$pb.TagNumber(3)
  set roleName($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRoleName() => $_has(2);
  @$pb.TagNumber(3)
  void clearRoleName() => $_clearField(3);
}

class PermissionInfo extends $pb.GeneratedMessage {
  factory PermissionInfo({
    $core.String? key,
    $core.String? label,
  }) {
    final result = PermissionInfo._();
    if (key != null) result.key = key;
    if (label != null) result.label = label;
    return result;
  }

  PermissionInfo._();

  factory PermissionInfo.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PermissionInfo()..mergeFromBuffer(data, registry);
  factory PermissionInfo.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PermissionInfo()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PermissionInfo',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.workspaces'),
      createEmptyInstance: PermissionInfo.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'key')
    ..aOS(2, _omitFieldNames ? '' : 'label')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PermissionInfo clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PermissionInfo copyWith(void Function(PermissionInfo) updates) =>
      super.copyWith((message) => updates(message as PermissionInfo))
          as PermissionInfo;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use PermissionInfo() / PermissionInfo.new instead')
  static PermissionInfo create() => PermissionInfo._();
  static $pb.GeneratedMessage $_createMessage() => PermissionInfo._();
  @$core.override
  PermissionInfo createEmptyInstance() => PermissionInfo._();
  @$core.pragma('dart2js:noInline')
  static PermissionInfo getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PermissionInfo>(
          PermissionInfo.$_createMessage);
  static PermissionInfo? _defaultInstance;

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

class Role extends $pb.GeneratedMessage {
  factory Role({
    $core.String? id,
    $core.String? name,
    $core.bool? isBuiltin,
    $core.Iterable<$core.String>? permissions,
    $core.int? memberCount,
    $core.int? version,
  }) {
    final result = Role._();
    if (id != null) result.id = id;
    if (name != null) result.name = name;
    if (isBuiltin != null) result.isBuiltin = isBuiltin;
    if (permissions != null) result.permissions.addAll(permissions);
    if (memberCount != null) result.memberCount = memberCount;
    if (version != null) result.version = version;
    return result;
  }

  Role._();

  factory Role.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Role()..mergeFromBuffer(data, registry);
  factory Role.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Role()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Role',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.workspaces'),
      createEmptyInstance: Role.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOB(3, _omitFieldNames ? '' : 'isBuiltin')
    ..pPS(4, _omitFieldNames ? '' : 'permissions')
    ..aI(5, _omitFieldNames ? '' : 'memberCount')
    ..aI(6, _omitFieldNames ? '' : 'version')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Role clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Role copyWith(void Function(Role) updates) =>
      super.copyWith((message) => updates(message as Role)) as Role;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Role() / Role.new instead')
  static Role create() => Role._();
  static $pb.GeneratedMessage $_createMessage() => Role._();
  @$core.override
  Role createEmptyInstance() => Role._();
  @$core.pragma('dart2js:noInline')
  static Role getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Role>(Role.$_createMessage);
  static Role? _defaultInstance;

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
  $core.bool get isBuiltin => $_getBF(2);
  @$pb.TagNumber(3)
  set isBuiltin($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasIsBuiltin() => $_has(2);
  @$pb.TagNumber(3)
  void clearIsBuiltin() => $_clearField(3);

  @$pb.TagNumber(4)
  $pb.PbList<$core.String> get permissions => $_getList(3);

  @$pb.TagNumber(5)
  $core.int get memberCount => $_getIZ(4);
  @$pb.TagNumber(5)
  set memberCount($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasMemberCount() => $_has(4);
  @$pb.TagNumber(5)
  void clearMemberCount() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get version => $_getIZ(5);
  @$pb.TagNumber(6)
  set version($core.int value) => $_setSignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasVersion() => $_has(5);
  @$pb.TagNumber(6)
  void clearVersion() => $_clearField(6);
}

class RoleCreateRequest extends $pb.GeneratedMessage {
  factory RoleCreateRequest({
    $core.String? workspaceId,
    $core.String? name,
    $core.Iterable<$core.String>? permissions,
  }) {
    final result = RoleCreateRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (name != null) result.name = name;
    if (permissions != null) result.permissions.addAll(permissions);
    return result;
  }

  RoleCreateRequest._();

  factory RoleCreateRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RoleCreateRequest()..mergeFromBuffer(data, registry);
  factory RoleCreateRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RoleCreateRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RoleCreateRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.workspaces'),
      createEmptyInstance: RoleCreateRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..pPS(3, _omitFieldNames ? '' : 'permissions')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RoleCreateRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RoleCreateRequest copyWith(void Function(RoleCreateRequest) updates) =>
      super.copyWith((message) => updates(message as RoleCreateRequest))
          as RoleCreateRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use RoleCreateRequest() / RoleCreateRequest.new instead')
  static RoleCreateRequest create() => RoleCreateRequest._();
  static $pb.GeneratedMessage $_createMessage() => RoleCreateRequest._();
  @$core.override
  RoleCreateRequest createEmptyInstance() => RoleCreateRequest._();
  @$core.pragma('dart2js:noInline')
  static RoleCreateRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RoleCreateRequest>(
          RoleCreateRequest.$_createMessage);
  static RoleCreateRequest? _defaultInstance;

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
  $pb.PbList<$core.String> get permissions => $_getList(2);
}

class RoleDeleteRequest extends $pb.GeneratedMessage {
  factory RoleDeleteRequest({
    $core.String? workspaceId,
    $core.String? id,
    $core.String? reassignTo,
  }) {
    final result = RoleDeleteRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (id != null) result.id = id;
    if (reassignTo != null) result.reassignTo = reassignTo;
    return result;
  }

  RoleDeleteRequest._();

  factory RoleDeleteRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RoleDeleteRequest()..mergeFromBuffer(data, registry);
  factory RoleDeleteRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RoleDeleteRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RoleDeleteRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.workspaces'),
      createEmptyInstance: RoleDeleteRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'id')
    ..aOS(3, _omitFieldNames ? '' : 'reassignTo')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RoleDeleteRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RoleDeleteRequest copyWith(void Function(RoleDeleteRequest) updates) =>
      super.copyWith((message) => updates(message as RoleDeleteRequest))
          as RoleDeleteRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use RoleDeleteRequest() / RoleDeleteRequest.new instead')
  static RoleDeleteRequest create() => RoleDeleteRequest._();
  static $pb.GeneratedMessage $_createMessage() => RoleDeleteRequest._();
  @$core.override
  RoleDeleteRequest createEmptyInstance() => RoleDeleteRequest._();
  @$core.pragma('dart2js:noInline')
  static RoleDeleteRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RoleDeleteRequest>(
          RoleDeleteRequest.$_createMessage);
  static RoleDeleteRequest? _defaultInstance;

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
  $core.String get reassignTo => $_getSZ(2);
  @$pb.TagNumber(3)
  set reassignTo($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasReassignTo() => $_has(2);
  @$pb.TagNumber(3)
  void clearReassignTo() => $_clearField(3);
}

class RoleEmpty extends $pb.GeneratedMessage {
  factory RoleEmpty() => RoleEmpty._();

  RoleEmpty._();

  factory RoleEmpty.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RoleEmpty()..mergeFromBuffer(data, registry);
  factory RoleEmpty.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RoleEmpty()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RoleEmpty',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.workspaces'),
      createEmptyInstance: RoleEmpty.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RoleEmpty clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RoleEmpty copyWith(void Function(RoleEmpty) updates) =>
      super.copyWith((message) => updates(message as RoleEmpty)) as RoleEmpty;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use RoleEmpty() / RoleEmpty.new instead')
  static RoleEmpty create() => RoleEmpty._();
  static $pb.GeneratedMessage $_createMessage() => RoleEmpty._();
  @$core.override
  RoleEmpty createEmptyInstance() => RoleEmpty._();
  @$core.pragma('dart2js:noInline')
  static RoleEmpty getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RoleEmpty>(RoleEmpty.$_createMessage);
  static RoleEmpty? _defaultInstance;
}

class RoleList extends $pb.GeneratedMessage {
  factory RoleList({
    $core.Iterable<Role>? roles,
    $core.Iterable<PermissionArea>? registry,
  }) {
    final result = RoleList._();
    if (roles != null) result.roles.addAll(roles);
    if (registry != null) result.registry.addAll(registry);
    return result;
  }

  RoleList._();

  factory RoleList.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RoleList()..mergeFromBuffer(data, registry);
  factory RoleList.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RoleList()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RoleList',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.workspaces'),
      createEmptyInstance: RoleList.$_createMessage)
    ..pPM<Role>(1, _omitFieldNames ? '' : 'roles',
        subBuilder: Role.$_createMessage)
    ..pPM<PermissionArea>(2, _omitFieldNames ? '' : 'registry',
        subBuilder: PermissionArea.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RoleList clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RoleList copyWith(void Function(RoleList) updates) =>
      super.copyWith((message) => updates(message as RoleList)) as RoleList;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use RoleList() / RoleList.new instead')
  static RoleList create() => RoleList._();
  static $pb.GeneratedMessage $_createMessage() => RoleList._();
  @$core.override
  RoleList createEmptyInstance() => RoleList._();
  @$core.pragma('dart2js:noInline')
  static RoleList getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RoleList>(RoleList.$_createMessage);
  static RoleList? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Role> get roles => $_getList(0);

  @$pb.TagNumber(2)
  $pb.PbList<PermissionArea> get registry => $_getList(1);
}

class RoleListRequest extends $pb.GeneratedMessage {
  factory RoleListRequest({
    $core.String? workspaceId,
  }) {
    final result = RoleListRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    return result;
  }

  RoleListRequest._();

  factory RoleListRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RoleListRequest()..mergeFromBuffer(data, registry);
  factory RoleListRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RoleListRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RoleListRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.workspaces'),
      createEmptyInstance: RoleListRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RoleListRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RoleListRequest copyWith(void Function(RoleListRequest) updates) =>
      super.copyWith((message) => updates(message as RoleListRequest))
          as RoleListRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use RoleListRequest() / RoleListRequest.new instead')
  static RoleListRequest create() => RoleListRequest._();
  static $pb.GeneratedMessage $_createMessage() => RoleListRequest._();
  @$core.override
  RoleListRequest createEmptyInstance() => RoleListRequest._();
  @$core.pragma('dart2js:noInline')
  static RoleListRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RoleListRequest>(
          RoleListRequest.$_createMessage);
  static RoleListRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);
}

class RoleUpdateRequest extends $pb.GeneratedMessage {
  factory RoleUpdateRequest({
    $core.String? workspaceId,
    $core.String? id,
    $core.String? name,
    $core.Iterable<$core.String>? permissions,
    $core.int? expectedVersion,
  }) {
    final result = RoleUpdateRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (id != null) result.id = id;
    if (name != null) result.name = name;
    if (permissions != null) result.permissions.addAll(permissions);
    if (expectedVersion != null) result.expectedVersion = expectedVersion;
    return result;
  }

  RoleUpdateRequest._();

  factory RoleUpdateRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RoleUpdateRequest()..mergeFromBuffer(data, registry);
  factory RoleUpdateRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RoleUpdateRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RoleUpdateRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.workspaces'),
      createEmptyInstance: RoleUpdateRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'id')
    ..aOS(3, _omitFieldNames ? '' : 'name')
    ..pPS(4, _omitFieldNames ? '' : 'permissions')
    ..aI(5, _omitFieldNames ? '' : 'expectedVersion')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RoleUpdateRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RoleUpdateRequest copyWith(void Function(RoleUpdateRequest) updates) =>
      super.copyWith((message) => updates(message as RoleUpdateRequest))
          as RoleUpdateRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use RoleUpdateRequest() / RoleUpdateRequest.new instead')
  static RoleUpdateRequest create() => RoleUpdateRequest._();
  static $pb.GeneratedMessage $_createMessage() => RoleUpdateRequest._();
  @$core.override
  RoleUpdateRequest createEmptyInstance() => RoleUpdateRequest._();
  @$core.pragma('dart2js:noInline')
  static RoleUpdateRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RoleUpdateRequest>(
          RoleUpdateRequest.$_createMessage);
  static RoleUpdateRequest? _defaultInstance;

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
  $pb.PbList<$core.String> get permissions => $_getList(3);

  @$pb.TagNumber(5)
  $core.int get expectedVersion => $_getIZ(4);
  @$pb.TagNumber(5)
  set expectedVersion($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasExpectedVersion() => $_has(4);
  @$pb.TagNumber(5)
  void clearExpectedVersion() => $_clearField(5);
}

class Workspace extends $pb.GeneratedMessage {
  factory Workspace({
    $core.String? id,
    $core.String? name,
    $core.String? slug,
    $core.String? logo,
    $core.String? createdBy,
    $core.String? createdAt,
    $core.String? deletedAt,
    $core.int? version,
    $core.bool? isOwner,
  }) {
    final result = Workspace._();
    if (id != null) result.id = id;
    if (name != null) result.name = name;
    if (slug != null) result.slug = slug;
    if (logo != null) result.logo = logo;
    if (createdBy != null) result.createdBy = createdBy;
    if (createdAt != null) result.createdAt = createdAt;
    if (deletedAt != null) result.deletedAt = deletedAt;
    if (version != null) result.version = version;
    if (isOwner != null) result.isOwner = isOwner;
    return result;
  }

  Workspace._();

  factory Workspace.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Workspace()..mergeFromBuffer(data, registry);
  factory Workspace.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Workspace()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Workspace',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.workspaces'),
      createEmptyInstance: Workspace.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOS(3, _omitFieldNames ? '' : 'slug')
    ..aOS(4, _omitFieldNames ? '' : 'logo')
    ..aOS(5, _omitFieldNames ? '' : 'createdBy')
    ..aOS(6, _omitFieldNames ? '' : 'createdAt')
    ..aOS(7, _omitFieldNames ? '' : 'deletedAt')
    ..aI(8, _omitFieldNames ? '' : 'version')
    ..aOB(9, _omitFieldNames ? '' : 'isOwner')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Workspace clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Workspace copyWith(void Function(Workspace) updates) =>
      super.copyWith((message) => updates(message as Workspace)) as Workspace;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Workspace() / Workspace.new instead')
  static Workspace create() => Workspace._();
  static $pb.GeneratedMessage $_createMessage() => Workspace._();
  @$core.override
  Workspace createEmptyInstance() => Workspace._();
  @$core.pragma('dart2js:noInline')
  static Workspace getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Workspace>(Workspace.$_createMessage);
  static Workspace? _defaultInstance;

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
  $core.String get slug => $_getSZ(2);
  @$pb.TagNumber(3)
  set slug($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSlug() => $_has(2);
  @$pb.TagNumber(3)
  void clearSlug() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get logo => $_getSZ(3);
  @$pb.TagNumber(4)
  set logo($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasLogo() => $_has(3);
  @$pb.TagNumber(4)
  void clearLogo() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get createdBy => $_getSZ(4);
  @$pb.TagNumber(5)
  set createdBy($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasCreatedBy() => $_has(4);
  @$pb.TagNumber(5)
  void clearCreatedBy() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get createdAt => $_getSZ(5);
  @$pb.TagNumber(6)
  set createdAt($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasCreatedAt() => $_has(5);
  @$pb.TagNumber(6)
  void clearCreatedAt() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get deletedAt => $_getSZ(6);
  @$pb.TagNumber(7)
  set deletedAt($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasDeletedAt() => $_has(6);
  @$pb.TagNumber(7)
  void clearDeletedAt() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.int get version => $_getIZ(7);
  @$pb.TagNumber(8)
  set version($core.int value) => $_setSignedInt32(7, value);
  @$pb.TagNumber(8)
  $core.bool hasVersion() => $_has(7);
  @$pb.TagNumber(8)
  void clearVersion() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.bool get isOwner => $_getBF(8);
  @$pb.TagNumber(9)
  set isOwner($core.bool value) => $_setBool(8, value);
  @$pb.TagNumber(9)
  $core.bool hasIsOwner() => $_has(8);
  @$pb.TagNumber(9)
  void clearIsOwner() => $_clearField(9);
}

class WorkspaceCreateRequest extends $pb.GeneratedMessage {
  factory WorkspaceCreateRequest({
    $core.String? name,
    $core.String? slug,
  }) {
    final result = WorkspaceCreateRequest._();
    if (name != null) result.name = name;
    if (slug != null) result.slug = slug;
    return result;
  }

  WorkspaceCreateRequest._();

  factory WorkspaceCreateRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WorkspaceCreateRequest()..mergeFromBuffer(data, registry);
  factory WorkspaceCreateRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WorkspaceCreateRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WorkspaceCreateRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.workspaces'),
      createEmptyInstance: WorkspaceCreateRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aOS(2, _omitFieldNames ? '' : 'slug')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WorkspaceCreateRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WorkspaceCreateRequest copyWith(
          void Function(WorkspaceCreateRequest) updates) =>
      super.copyWith((message) => updates(message as WorkspaceCreateRequest))
          as WorkspaceCreateRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use WorkspaceCreateRequest() / WorkspaceCreateRequest.new instead')
  static WorkspaceCreateRequest create() => WorkspaceCreateRequest._();
  static $pb.GeneratedMessage $_createMessage() => WorkspaceCreateRequest._();
  @$core.override
  WorkspaceCreateRequest createEmptyInstance() => WorkspaceCreateRequest._();
  @$core.pragma('dart2js:noInline')
  static WorkspaceCreateRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WorkspaceCreateRequest>(
          WorkspaceCreateRequest.$_createMessage);
  static WorkspaceCreateRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get slug => $_getSZ(1);
  @$pb.TagNumber(2)
  set slug($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSlug() => $_has(1);
  @$pb.TagNumber(2)
  void clearSlug() => $_clearField(2);
}

class WorkspaceDeleteRequest extends $pb.GeneratedMessage {
  factory WorkspaceDeleteRequest({
    $core.String? id,
    $core.String? confirmation,
  }) {
    final result = WorkspaceDeleteRequest._();
    if (id != null) result.id = id;
    if (confirmation != null) result.confirmation = confirmation;
    return result;
  }

  WorkspaceDeleteRequest._();

  factory WorkspaceDeleteRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WorkspaceDeleteRequest()..mergeFromBuffer(data, registry);
  factory WorkspaceDeleteRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WorkspaceDeleteRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WorkspaceDeleteRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.workspaces'),
      createEmptyInstance: WorkspaceDeleteRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'confirmation')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WorkspaceDeleteRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WorkspaceDeleteRequest copyWith(
          void Function(WorkspaceDeleteRequest) updates) =>
      super.copyWith((message) => updates(message as WorkspaceDeleteRequest))
          as WorkspaceDeleteRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use WorkspaceDeleteRequest() / WorkspaceDeleteRequest.new instead')
  static WorkspaceDeleteRequest create() => WorkspaceDeleteRequest._();
  static $pb.GeneratedMessage $_createMessage() => WorkspaceDeleteRequest._();
  @$core.override
  WorkspaceDeleteRequest createEmptyInstance() => WorkspaceDeleteRequest._();
  @$core.pragma('dart2js:noInline')
  static WorkspaceDeleteRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WorkspaceDeleteRequest>(
          WorkspaceDeleteRequest.$_createMessage);
  static WorkspaceDeleteRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get confirmation => $_getSZ(1);
  @$pb.TagNumber(2)
  set confirmation($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasConfirmation() => $_has(1);
  @$pb.TagNumber(2)
  void clearConfirmation() => $_clearField(2);
}

class WorkspaceList extends $pb.GeneratedMessage {
  factory WorkspaceList({
    $core.Iterable<Workspace>? workspaces,
  }) {
    final result = WorkspaceList._();
    if (workspaces != null) result.workspaces.addAll(workspaces);
    return result;
  }

  WorkspaceList._();

  factory WorkspaceList.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WorkspaceList()..mergeFromBuffer(data, registry);
  factory WorkspaceList.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WorkspaceList()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WorkspaceList',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.workspaces'),
      createEmptyInstance: WorkspaceList.$_createMessage)
    ..pPM<Workspace>(1, _omitFieldNames ? '' : 'workspaces',
        subBuilder: Workspace.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WorkspaceList clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WorkspaceList copyWith(void Function(WorkspaceList) updates) =>
      super.copyWith((message) => updates(message as WorkspaceList))
          as WorkspaceList;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use WorkspaceList() / WorkspaceList.new instead')
  static WorkspaceList create() => WorkspaceList._();
  static $pb.GeneratedMessage $_createMessage() => WorkspaceList._();
  @$core.override
  WorkspaceList createEmptyInstance() => WorkspaceList._();
  @$core.pragma('dart2js:noInline')
  static WorkspaceList getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<WorkspaceList>(
          WorkspaceList.$_createMessage);
  static WorkspaceList? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Workspace> get workspaces => $_getList(0);
}

class WorkspaceRestoreRequest extends $pb.GeneratedMessage {
  factory WorkspaceRestoreRequest({
    $core.String? id,
  }) {
    final result = WorkspaceRestoreRequest._();
    if (id != null) result.id = id;
    return result;
  }

  WorkspaceRestoreRequest._();

  factory WorkspaceRestoreRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WorkspaceRestoreRequest()..mergeFromBuffer(data, registry);
  factory WorkspaceRestoreRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WorkspaceRestoreRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WorkspaceRestoreRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.workspaces'),
      createEmptyInstance: WorkspaceRestoreRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WorkspaceRestoreRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WorkspaceRestoreRequest copyWith(
          void Function(WorkspaceRestoreRequest) updates) =>
      super.copyWith((message) => updates(message as WorkspaceRestoreRequest))
          as WorkspaceRestoreRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use WorkspaceRestoreRequest() / WorkspaceRestoreRequest.new instead')
  static WorkspaceRestoreRequest create() => WorkspaceRestoreRequest._();
  static $pb.GeneratedMessage $_createMessage() => WorkspaceRestoreRequest._();
  @$core.override
  WorkspaceRestoreRequest createEmptyInstance() => WorkspaceRestoreRequest._();
  @$core.pragma('dart2js:noInline')
  static WorkspaceRestoreRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WorkspaceRestoreRequest>(
          WorkspaceRestoreRequest.$_createMessage);
  static WorkspaceRestoreRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class WorkspaceUpdateRequest extends $pb.GeneratedMessage {
  factory WorkspaceUpdateRequest({
    $core.String? id,
    $core.int? expectedVersion,
    $core.String? name,
    $core.String? slug,
  }) {
    final result = WorkspaceUpdateRequest._();
    if (id != null) result.id = id;
    if (expectedVersion != null) result.expectedVersion = expectedVersion;
    if (name != null) result.name = name;
    if (slug != null) result.slug = slug;
    return result;
  }

  WorkspaceUpdateRequest._();

  factory WorkspaceUpdateRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WorkspaceUpdateRequest()..mergeFromBuffer(data, registry);
  factory WorkspaceUpdateRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WorkspaceUpdateRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WorkspaceUpdateRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.workspaces'),
      createEmptyInstance: WorkspaceUpdateRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aI(2, _omitFieldNames ? '' : 'expectedVersion')
    ..aOS(3, _omitFieldNames ? '' : 'name')
    ..aOS(4, _omitFieldNames ? '' : 'slug')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WorkspaceUpdateRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WorkspaceUpdateRequest copyWith(
          void Function(WorkspaceUpdateRequest) updates) =>
      super.copyWith((message) => updates(message as WorkspaceUpdateRequest))
          as WorkspaceUpdateRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use WorkspaceUpdateRequest() / WorkspaceUpdateRequest.new instead')
  static WorkspaceUpdateRequest create() => WorkspaceUpdateRequest._();
  static $pb.GeneratedMessage $_createMessage() => WorkspaceUpdateRequest._();
  @$core.override
  WorkspaceUpdateRequest createEmptyInstance() => WorkspaceUpdateRequest._();
  @$core.pragma('dart2js:noInline')
  static WorkspaceUpdateRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WorkspaceUpdateRequest>(
          WorkspaceUpdateRequest.$_createMessage);
  static WorkspaceUpdateRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get expectedVersion => $_getIZ(1);
  @$pb.TagNumber(2)
  set expectedVersion($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasExpectedVersion() => $_has(1);
  @$pb.TagNumber(2)
  void clearExpectedVersion() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get name => $_getSZ(2);
  @$pb.TagNumber(3)
  set name($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasName() => $_has(2);
  @$pb.TagNumber(3)
  void clearName() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get slug => $_getSZ(3);
  @$pb.TagNumber(4)
  set slug($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSlug() => $_has(3);
  @$pb.TagNumber(4)
  void clearSlug() => $_clearField(4);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
