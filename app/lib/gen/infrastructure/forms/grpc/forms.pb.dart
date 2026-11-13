// This is a generated file - do not edit.
//
// Generated from infrastructure/forms/grpc/forms.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class FormAnswer extends $pb.GeneratedMessage {
  factory FormAnswer({
    IntakeForm? form,
  }) {
    final result = FormAnswer._();
    if (form != null) result.form = form;
    return result;
  }

  FormAnswer._();

  factory FormAnswer.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FormAnswer()..mergeFromBuffer(data, registry);
  factory FormAnswer.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FormAnswer()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FormAnswer',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.forms'),
      createEmptyInstance: FormAnswer.$_createMessage)
    ..aOM<IntakeForm>(1, _omitFieldNames ? '' : 'form',
        subBuilder: IntakeForm.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FormAnswer clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FormAnswer copyWith(void Function(FormAnswer) updates) =>
      super.copyWith((message) => updates(message as FormAnswer)) as FormAnswer;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use FormAnswer() / FormAnswer.new instead')
  static FormAnswer create() => FormAnswer._();
  static $pb.GeneratedMessage $_createMessage() => FormAnswer._();
  @$core.override
  FormAnswer createEmptyInstance() => FormAnswer._();
  @$core.pragma('dart2js:noInline')
  static FormAnswer getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FormAnswer>(FormAnswer.$_createMessage);
  static FormAnswer? _defaultInstance;

  @$pb.TagNumber(1)
  IntakeForm get form => $_getN(0);
  @$pb.TagNumber(1)
  set form(IntakeForm value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasForm() => $_has(0);
  @$pb.TagNumber(1)
  void clearForm() => $_clearField(1);
  @$pb.TagNumber(1)
  IntakeForm ensureForm() => $_ensure(0);
}

class FormCreateRequest extends $pb.GeneratedMessage {
  factory FormCreateRequest({
    $core.String? workspaceId,
    $core.String? projectId,
    $core.String? name,
    $core.String? description,
    $core.Iterable<IntakeField>? formFields,
    $core.String? statusId,
    $core.String? priority,
    $core.Iterable<$core.String>? assigneeIds,
    $core.bool? enabled,
    $core.bool? requireEmail,
    $core.bool? sendConfirmation,
    $core.bool? notifyStatus,
    $core.String? brandColor,
    $core.String? logoUrl,
  }) {
    final result = FormCreateRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (projectId != null) result.projectId = projectId;
    if (name != null) result.name = name;
    if (description != null) result.description = description;
    if (formFields != null) result.formFields.addAll(formFields);
    if (statusId != null) result.statusId = statusId;
    if (priority != null) result.priority = priority;
    if (assigneeIds != null) result.assigneeIds.addAll(assigneeIds);
    if (enabled != null) result.enabled = enabled;
    if (requireEmail != null) result.requireEmail = requireEmail;
    if (sendConfirmation != null) result.sendConfirmation = sendConfirmation;
    if (notifyStatus != null) result.notifyStatus = notifyStatus;
    if (brandColor != null) result.brandColor = brandColor;
    if (logoUrl != null) result.logoUrl = logoUrl;
    return result;
  }

  FormCreateRequest._();

  factory FormCreateRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FormCreateRequest()..mergeFromBuffer(data, registry);
  factory FormCreateRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FormCreateRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FormCreateRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.forms'),
      createEmptyInstance: FormCreateRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..aOS(3, _omitFieldNames ? '' : 'name')
    ..aOS(4, _omitFieldNames ? '' : 'description')
    ..pPM<IntakeField>(5, _omitFieldNames ? '' : 'formFields',
        subBuilder: IntakeField.$_createMessage)
    ..aOS(6, _omitFieldNames ? '' : 'statusId')
    ..aOS(7, _omitFieldNames ? '' : 'priority')
    ..pPS(8, _omitFieldNames ? '' : 'assigneeIds')
    ..aOB(9, _omitFieldNames ? '' : 'enabled')
    ..aOB(10, _omitFieldNames ? '' : 'requireEmail')
    ..aOB(11, _omitFieldNames ? '' : 'sendConfirmation')
    ..aOB(12, _omitFieldNames ? '' : 'notifyStatus')
    ..aOS(13, _omitFieldNames ? '' : 'brandColor')
    ..aOS(14, _omitFieldNames ? '' : 'logoUrl')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FormCreateRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FormCreateRequest copyWith(void Function(FormCreateRequest) updates) =>
      super.copyWith((message) => updates(message as FormCreateRequest))
          as FormCreateRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use FormCreateRequest() / FormCreateRequest.new instead')
  static FormCreateRequest create() => FormCreateRequest._();
  static $pb.GeneratedMessage $_createMessage() => FormCreateRequest._();
  @$core.override
  FormCreateRequest createEmptyInstance() => FormCreateRequest._();
  @$core.pragma('dart2js:noInline')
  static FormCreateRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<FormCreateRequest>(
          FormCreateRequest.$_createMessage);
  static FormCreateRequest? _defaultInstance;

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
  $core.String get name => $_getSZ(2);
  @$pb.TagNumber(3)
  set name($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasName() => $_has(2);
  @$pb.TagNumber(3)
  void clearName() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get description => $_getSZ(3);
  @$pb.TagNumber(4)
  set description($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasDescription() => $_has(3);
  @$pb.TagNumber(4)
  void clearDescription() => $_clearField(4);

  @$pb.TagNumber(5)
  $pb.PbList<IntakeField> get formFields => $_getList(4);

  @$pb.TagNumber(6)
  $core.String get statusId => $_getSZ(5);
  @$pb.TagNumber(6)
  set statusId($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasStatusId() => $_has(5);
  @$pb.TagNumber(6)
  void clearStatusId() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get priority => $_getSZ(6);
  @$pb.TagNumber(7)
  set priority($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasPriority() => $_has(6);
  @$pb.TagNumber(7)
  void clearPriority() => $_clearField(7);

  @$pb.TagNumber(8)
  $pb.PbList<$core.String> get assigneeIds => $_getList(7);

  @$pb.TagNumber(9)
  $core.bool get enabled => $_getBF(8);
  @$pb.TagNumber(9)
  set enabled($core.bool value) => $_setBool(8, value);
  @$pb.TagNumber(9)
  $core.bool hasEnabled() => $_has(8);
  @$pb.TagNumber(9)
  void clearEnabled() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.bool get requireEmail => $_getBF(9);
  @$pb.TagNumber(10)
  set requireEmail($core.bool value) => $_setBool(9, value);
  @$pb.TagNumber(10)
  $core.bool hasRequireEmail() => $_has(9);
  @$pb.TagNumber(10)
  void clearRequireEmail() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.bool get sendConfirmation => $_getBF(10);
  @$pb.TagNumber(11)
  set sendConfirmation($core.bool value) => $_setBool(10, value);
  @$pb.TagNumber(11)
  $core.bool hasSendConfirmation() => $_has(10);
  @$pb.TagNumber(11)
  void clearSendConfirmation() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.bool get notifyStatus => $_getBF(11);
  @$pb.TagNumber(12)
  set notifyStatus($core.bool value) => $_setBool(11, value);
  @$pb.TagNumber(12)
  $core.bool hasNotifyStatus() => $_has(11);
  @$pb.TagNumber(12)
  void clearNotifyStatus() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.String get brandColor => $_getSZ(12);
  @$pb.TagNumber(13)
  set brandColor($core.String value) => $_setString(12, value);
  @$pb.TagNumber(13)
  $core.bool hasBrandColor() => $_has(12);
  @$pb.TagNumber(13)
  void clearBrandColor() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.String get logoUrl => $_getSZ(13);
  @$pb.TagNumber(14)
  set logoUrl($core.String value) => $_setString(13, value);
  @$pb.TagNumber(14)
  $core.bool hasLogoUrl() => $_has(13);
  @$pb.TagNumber(14)
  void clearLogoUrl() => $_clearField(14);
}

class FormDeleteRequest extends $pb.GeneratedMessage {
  factory FormDeleteRequest({
    $core.String? workspaceId,
    $core.String? formId,
  }) {
    final result = FormDeleteRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (formId != null) result.formId = formId;
    return result;
  }

  FormDeleteRequest._();

  factory FormDeleteRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FormDeleteRequest()..mergeFromBuffer(data, registry);
  factory FormDeleteRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FormDeleteRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FormDeleteRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.forms'),
      createEmptyInstance: FormDeleteRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'formId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FormDeleteRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FormDeleteRequest copyWith(void Function(FormDeleteRequest) updates) =>
      super.copyWith((message) => updates(message as FormDeleteRequest))
          as FormDeleteRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use FormDeleteRequest() / FormDeleteRequest.new instead')
  static FormDeleteRequest create() => FormDeleteRequest._();
  static $pb.GeneratedMessage $_createMessage() => FormDeleteRequest._();
  @$core.override
  FormDeleteRequest createEmptyInstance() => FormDeleteRequest._();
  @$core.pragma('dart2js:noInline')
  static FormDeleteRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<FormDeleteRequest>(
          FormDeleteRequest.$_createMessage);
  static FormDeleteRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get formId => $_getSZ(1);
  @$pb.TagNumber(2)
  set formId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFormId() => $_has(1);
  @$pb.TagNumber(2)
  void clearFormId() => $_clearField(2);
}

class FormDeleted extends $pb.GeneratedMessage {
  factory FormDeleted({
    $core.String? id,
  }) {
    final result = FormDeleted._();
    if (id != null) result.id = id;
    return result;
  }

  FormDeleted._();

  factory FormDeleted.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FormDeleted()..mergeFromBuffer(data, registry);
  factory FormDeleted.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FormDeleted()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FormDeleted',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.forms'),
      createEmptyInstance: FormDeleted.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FormDeleted clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FormDeleted copyWith(void Function(FormDeleted) updates) =>
      super.copyWith((message) => updates(message as FormDeleted))
          as FormDeleted;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use FormDeleted() / FormDeleted.new instead')
  static FormDeleted create() => FormDeleted._();
  static $pb.GeneratedMessage $_createMessage() => FormDeleted._();
  @$core.override
  FormDeleted createEmptyInstance() => FormDeleted._();
  @$core.pragma('dart2js:noInline')
  static FormDeleted getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<FormDeleted>(
          FormDeleted.$_createMessage);
  static FormDeleted? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class FormList extends $pb.GeneratedMessage {
  factory FormList({
    $core.Iterable<IntakeForm>? forms,
  }) {
    final result = FormList._();
    if (forms != null) result.forms.addAll(forms);
    return result;
  }

  FormList._();

  factory FormList.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FormList()..mergeFromBuffer(data, registry);
  factory FormList.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FormList()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FormList',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.forms'),
      createEmptyInstance: FormList.$_createMessage)
    ..pPM<IntakeForm>(1, _omitFieldNames ? '' : 'forms',
        subBuilder: IntakeForm.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FormList clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FormList copyWith(void Function(FormList) updates) =>
      super.copyWith((message) => updates(message as FormList)) as FormList;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use FormList() / FormList.new instead')
  static FormList create() => FormList._();
  static $pb.GeneratedMessage $_createMessage() => FormList._();
  @$core.override
  FormList createEmptyInstance() => FormList._();
  @$core.pragma('dart2js:noInline')
  static FormList getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FormList>(FormList.$_createMessage);
  static FormList? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<IntakeForm> get forms => $_getList(0);
}

class FormListRequest extends $pb.GeneratedMessage {
  factory FormListRequest({
    $core.String? workspaceId,
    $core.String? projectId,
  }) {
    final result = FormListRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (projectId != null) result.projectId = projectId;
    return result;
  }

  FormListRequest._();

  factory FormListRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FormListRequest()..mergeFromBuffer(data, registry);
  factory FormListRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FormListRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FormListRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.forms'),
      createEmptyInstance: FormListRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FormListRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FormListRequest copyWith(void Function(FormListRequest) updates) =>
      super.copyWith((message) => updates(message as FormListRequest))
          as FormListRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use FormListRequest() / FormListRequest.new instead')
  static FormListRequest create() => FormListRequest._();
  static $pb.GeneratedMessage $_createMessage() => FormListRequest._();
  @$core.override
  FormListRequest createEmptyInstance() => FormListRequest._();
  @$core.pragma('dart2js:noInline')
  static FormListRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<FormListRequest>(
          FormListRequest.$_createMessage);
  static FormListRequest? _defaultInstance;

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

class FormUpdateRequest extends $pb.GeneratedMessage {
  factory FormUpdateRequest({
    $core.String? workspaceId,
    $core.String? formId,
    $core.Iterable<$core.String>? changed,
    $core.int? expectedVersion,
    $core.bool? rotateToken,
    $core.String? name,
    $core.String? description,
    $core.Iterable<IntakeField>? formFields,
    $core.String? statusId,
    $core.String? priority,
    $core.Iterable<$core.String>? assigneeIds,
    $core.bool? enabled,
    $core.bool? requireEmail,
    $core.bool? sendConfirmation,
    $core.bool? notifyStatus,
    $core.String? brandColor,
    $core.String? logoUrl,
  }) {
    final result = FormUpdateRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (formId != null) result.formId = formId;
    if (changed != null) result.changed.addAll(changed);
    if (expectedVersion != null) result.expectedVersion = expectedVersion;
    if (rotateToken != null) result.rotateToken = rotateToken;
    if (name != null) result.name = name;
    if (description != null) result.description = description;
    if (formFields != null) result.formFields.addAll(formFields);
    if (statusId != null) result.statusId = statusId;
    if (priority != null) result.priority = priority;
    if (assigneeIds != null) result.assigneeIds.addAll(assigneeIds);
    if (enabled != null) result.enabled = enabled;
    if (requireEmail != null) result.requireEmail = requireEmail;
    if (sendConfirmation != null) result.sendConfirmation = sendConfirmation;
    if (notifyStatus != null) result.notifyStatus = notifyStatus;
    if (brandColor != null) result.brandColor = brandColor;
    if (logoUrl != null) result.logoUrl = logoUrl;
    return result;
  }

  FormUpdateRequest._();

  factory FormUpdateRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FormUpdateRequest()..mergeFromBuffer(data, registry);
  factory FormUpdateRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FormUpdateRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FormUpdateRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.forms'),
      createEmptyInstance: FormUpdateRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'formId')
    ..pPS(3, _omitFieldNames ? '' : 'changed')
    ..aI(4, _omitFieldNames ? '' : 'expectedVersion')
    ..aOB(5, _omitFieldNames ? '' : 'rotateToken')
    ..aOS(6, _omitFieldNames ? '' : 'name')
    ..aOS(7, _omitFieldNames ? '' : 'description')
    ..pPM<IntakeField>(8, _omitFieldNames ? '' : 'formFields',
        subBuilder: IntakeField.$_createMessage)
    ..aOS(9, _omitFieldNames ? '' : 'statusId')
    ..aOS(10, _omitFieldNames ? '' : 'priority')
    ..pPS(11, _omitFieldNames ? '' : 'assigneeIds')
    ..aOB(12, _omitFieldNames ? '' : 'enabled')
    ..aOB(13, _omitFieldNames ? '' : 'requireEmail')
    ..aOB(14, _omitFieldNames ? '' : 'sendConfirmation')
    ..aOB(15, _omitFieldNames ? '' : 'notifyStatus')
    ..aOS(16, _omitFieldNames ? '' : 'brandColor')
    ..aOS(17, _omitFieldNames ? '' : 'logoUrl')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FormUpdateRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FormUpdateRequest copyWith(void Function(FormUpdateRequest) updates) =>
      super.copyWith((message) => updates(message as FormUpdateRequest))
          as FormUpdateRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use FormUpdateRequest() / FormUpdateRequest.new instead')
  static FormUpdateRequest create() => FormUpdateRequest._();
  static $pb.GeneratedMessage $_createMessage() => FormUpdateRequest._();
  @$core.override
  FormUpdateRequest createEmptyInstance() => FormUpdateRequest._();
  @$core.pragma('dart2js:noInline')
  static FormUpdateRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<FormUpdateRequest>(
          FormUpdateRequest.$_createMessage);
  static FormUpdateRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get formId => $_getSZ(1);
  @$pb.TagNumber(2)
  set formId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFormId() => $_has(1);
  @$pb.TagNumber(2)
  void clearFormId() => $_clearField(2);

  @$pb.TagNumber(3)
  $pb.PbList<$core.String> get changed => $_getList(2);

  @$pb.TagNumber(4)
  $core.int get expectedVersion => $_getIZ(3);
  @$pb.TagNumber(4)
  set expectedVersion($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasExpectedVersion() => $_has(3);
  @$pb.TagNumber(4)
  void clearExpectedVersion() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.bool get rotateToken => $_getBF(4);
  @$pb.TagNumber(5)
  set rotateToken($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasRotateToken() => $_has(4);
  @$pb.TagNumber(5)
  void clearRotateToken() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get name => $_getSZ(5);
  @$pb.TagNumber(6)
  set name($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasName() => $_has(5);
  @$pb.TagNumber(6)
  void clearName() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get description => $_getSZ(6);
  @$pb.TagNumber(7)
  set description($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasDescription() => $_has(6);
  @$pb.TagNumber(7)
  void clearDescription() => $_clearField(7);

  @$pb.TagNumber(8)
  $pb.PbList<IntakeField> get formFields => $_getList(7);

  @$pb.TagNumber(9)
  $core.String get statusId => $_getSZ(8);
  @$pb.TagNumber(9)
  set statusId($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasStatusId() => $_has(8);
  @$pb.TagNumber(9)
  void clearStatusId() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get priority => $_getSZ(9);
  @$pb.TagNumber(10)
  set priority($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasPriority() => $_has(9);
  @$pb.TagNumber(10)
  void clearPriority() => $_clearField(10);

  @$pb.TagNumber(11)
  $pb.PbList<$core.String> get assigneeIds => $_getList(10);

  @$pb.TagNumber(12)
  $core.bool get enabled => $_getBF(11);
  @$pb.TagNumber(12)
  set enabled($core.bool value) => $_setBool(11, value);
  @$pb.TagNumber(12)
  $core.bool hasEnabled() => $_has(11);
  @$pb.TagNumber(12)
  void clearEnabled() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.bool get requireEmail => $_getBF(12);
  @$pb.TagNumber(13)
  set requireEmail($core.bool value) => $_setBool(12, value);
  @$pb.TagNumber(13)
  $core.bool hasRequireEmail() => $_has(12);
  @$pb.TagNumber(13)
  void clearRequireEmail() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.bool get sendConfirmation => $_getBF(13);
  @$pb.TagNumber(14)
  set sendConfirmation($core.bool value) => $_setBool(13, value);
  @$pb.TagNumber(14)
  $core.bool hasSendConfirmation() => $_has(13);
  @$pb.TagNumber(14)
  void clearSendConfirmation() => $_clearField(14);

  @$pb.TagNumber(15)
  $core.bool get notifyStatus => $_getBF(14);
  @$pb.TagNumber(15)
  set notifyStatus($core.bool value) => $_setBool(14, value);
  @$pb.TagNumber(15)
  $core.bool hasNotifyStatus() => $_has(14);
  @$pb.TagNumber(15)
  void clearNotifyStatus() => $_clearField(15);

  @$pb.TagNumber(16)
  $core.String get brandColor => $_getSZ(15);
  @$pb.TagNumber(16)
  set brandColor($core.String value) => $_setString(15, value);
  @$pb.TagNumber(16)
  $core.bool hasBrandColor() => $_has(15);
  @$pb.TagNumber(16)
  void clearBrandColor() => $_clearField(16);

  @$pb.TagNumber(17)
  $core.String get logoUrl => $_getSZ(16);
  @$pb.TagNumber(17)
  set logoUrl($core.String value) => $_setString(16, value);
  @$pb.TagNumber(17)
  $core.bool hasLogoUrl() => $_has(16);
  @$pb.TagNumber(17)
  void clearLogoUrl() => $_clearField(17);
}

class IntakeField extends $pb.GeneratedMessage {
  factory IntakeField({
    $core.String? id,
    $core.String? kind,
    $core.String? label,
    $core.String? help,
    $core.bool? required,
    $core.String? customFieldId,
    $core.int? maxFiles,
  }) {
    final result = IntakeField._();
    if (id != null) result.id = id;
    if (kind != null) result.kind = kind;
    if (label != null) result.label = label;
    if (help != null) result.help = help;
    if (required != null) result.required = required;
    if (customFieldId != null) result.customFieldId = customFieldId;
    if (maxFiles != null) result.maxFiles = maxFiles;
    return result;
  }

  IntakeField._();

  factory IntakeField.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      IntakeField()..mergeFromBuffer(data, registry);
  factory IntakeField.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      IntakeField()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'IntakeField',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.forms'),
      createEmptyInstance: IntakeField.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'kind')
    ..aOS(3, _omitFieldNames ? '' : 'label')
    ..aOS(4, _omitFieldNames ? '' : 'help')
    ..aOB(5, _omitFieldNames ? '' : 'required')
    ..aOS(6, _omitFieldNames ? '' : 'customFieldId')
    ..aI(7, _omitFieldNames ? '' : 'maxFiles')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  IntakeField clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  IntakeField copyWith(void Function(IntakeField) updates) =>
      super.copyWith((message) => updates(message as IntakeField))
          as IntakeField;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use IntakeField() / IntakeField.new instead')
  static IntakeField create() => IntakeField._();
  static $pb.GeneratedMessage $_createMessage() => IntakeField._();
  @$core.override
  IntakeField createEmptyInstance() => IntakeField._();
  @$core.pragma('dart2js:noInline')
  static IntakeField getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<IntakeField>(
          IntakeField.$_createMessage);
  static IntakeField? _defaultInstance;

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
  $core.String get label => $_getSZ(2);
  @$pb.TagNumber(3)
  set label($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasLabel() => $_has(2);
  @$pb.TagNumber(3)
  void clearLabel() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get help => $_getSZ(3);
  @$pb.TagNumber(4)
  set help($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasHelp() => $_has(3);
  @$pb.TagNumber(4)
  void clearHelp() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.bool get required => $_getBF(4);
  @$pb.TagNumber(5)
  set required($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasRequired() => $_has(4);
  @$pb.TagNumber(5)
  void clearRequired() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get customFieldId => $_getSZ(5);
  @$pb.TagNumber(6)
  set customFieldId($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasCustomFieldId() => $_has(5);
  @$pb.TagNumber(6)
  void clearCustomFieldId() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.int get maxFiles => $_getIZ(6);
  @$pb.TagNumber(7)
  set maxFiles($core.int value) => $_setSignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasMaxFiles() => $_has(6);
  @$pb.TagNumber(7)
  void clearMaxFiles() => $_clearField(7);
}

class IntakeForm extends $pb.GeneratedMessage {
  factory IntakeForm({
    $core.String? id,
    $core.String? workspaceId,
    $core.String? projectId,
    $core.String? name,
    $core.String? description,
    $core.String? token,
    $core.Iterable<IntakeField>? formFields,
    $core.String? statusId,
    $core.String? priority,
    $core.Iterable<$core.String>? assigneeIds,
    $core.bool? enabled,
    $core.bool? requireEmail,
    $core.bool? sendConfirmation,
    $core.bool? notifyStatus,
    $core.String? brandColor,
    $core.String? logoUrl,
    $core.int? version,
    $core.int? submissionCount,
    $core.String? problem,
    $core.String? ownerId,
    $core.String? createdAt,
    $core.String? updatedAt,
  }) {
    final result = IntakeForm._();
    if (id != null) result.id = id;
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (projectId != null) result.projectId = projectId;
    if (name != null) result.name = name;
    if (description != null) result.description = description;
    if (token != null) result.token = token;
    if (formFields != null) result.formFields.addAll(formFields);
    if (statusId != null) result.statusId = statusId;
    if (priority != null) result.priority = priority;
    if (assigneeIds != null) result.assigneeIds.addAll(assigneeIds);
    if (enabled != null) result.enabled = enabled;
    if (requireEmail != null) result.requireEmail = requireEmail;
    if (sendConfirmation != null) result.sendConfirmation = sendConfirmation;
    if (notifyStatus != null) result.notifyStatus = notifyStatus;
    if (brandColor != null) result.brandColor = brandColor;
    if (logoUrl != null) result.logoUrl = logoUrl;
    if (version != null) result.version = version;
    if (submissionCount != null) result.submissionCount = submissionCount;
    if (problem != null) result.problem = problem;
    if (ownerId != null) result.ownerId = ownerId;
    if (createdAt != null) result.createdAt = createdAt;
    if (updatedAt != null) result.updatedAt = updatedAt;
    return result;
  }

  IntakeForm._();

  factory IntakeForm.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      IntakeForm()..mergeFromBuffer(data, registry);
  factory IntakeForm.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      IntakeForm()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'IntakeForm',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.forms'),
      createEmptyInstance: IntakeForm.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(3, _omitFieldNames ? '' : 'projectId')
    ..aOS(4, _omitFieldNames ? '' : 'name')
    ..aOS(5, _omitFieldNames ? '' : 'description')
    ..aOS(6, _omitFieldNames ? '' : 'token')
    ..pPM<IntakeField>(7, _omitFieldNames ? '' : 'formFields',
        subBuilder: IntakeField.$_createMessage)
    ..aOS(8, _omitFieldNames ? '' : 'statusId')
    ..aOS(9, _omitFieldNames ? '' : 'priority')
    ..pPS(10, _omitFieldNames ? '' : 'assigneeIds')
    ..aOB(11, _omitFieldNames ? '' : 'enabled')
    ..aOB(12, _omitFieldNames ? '' : 'requireEmail')
    ..aOB(13, _omitFieldNames ? '' : 'sendConfirmation')
    ..aOB(14, _omitFieldNames ? '' : 'notifyStatus')
    ..aOS(15, _omitFieldNames ? '' : 'brandColor')
    ..aOS(16, _omitFieldNames ? '' : 'logoUrl')
    ..aI(17, _omitFieldNames ? '' : 'version')
    ..aI(18, _omitFieldNames ? '' : 'submissionCount')
    ..aOS(19, _omitFieldNames ? '' : 'problem')
    ..aOS(20, _omitFieldNames ? '' : 'ownerId')
    ..aOS(21, _omitFieldNames ? '' : 'createdAt')
    ..aOS(22, _omitFieldNames ? '' : 'updatedAt')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  IntakeForm clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  IntakeForm copyWith(void Function(IntakeForm) updates) =>
      super.copyWith((message) => updates(message as IntakeForm)) as IntakeForm;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use IntakeForm() / IntakeForm.new instead')
  static IntakeForm create() => IntakeForm._();
  static $pb.GeneratedMessage $_createMessage() => IntakeForm._();
  @$core.override
  IntakeForm createEmptyInstance() => IntakeForm._();
  @$core.pragma('dart2js:noInline')
  static IntakeForm getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<IntakeForm>(IntakeForm.$_createMessage);
  static IntakeForm? _defaultInstance;

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
  $core.String get description => $_getSZ(4);
  @$pb.TagNumber(5)
  set description($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasDescription() => $_has(4);
  @$pb.TagNumber(5)
  void clearDescription() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get token => $_getSZ(5);
  @$pb.TagNumber(6)
  set token($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasToken() => $_has(5);
  @$pb.TagNumber(6)
  void clearToken() => $_clearField(6);

  @$pb.TagNumber(7)
  $pb.PbList<IntakeField> get formFields => $_getList(6);

  @$pb.TagNumber(8)
  $core.String get statusId => $_getSZ(7);
  @$pb.TagNumber(8)
  set statusId($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasStatusId() => $_has(7);
  @$pb.TagNumber(8)
  void clearStatusId() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get priority => $_getSZ(8);
  @$pb.TagNumber(9)
  set priority($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasPriority() => $_has(8);
  @$pb.TagNumber(9)
  void clearPriority() => $_clearField(9);

  @$pb.TagNumber(10)
  $pb.PbList<$core.String> get assigneeIds => $_getList(9);

  @$pb.TagNumber(11)
  $core.bool get enabled => $_getBF(10);
  @$pb.TagNumber(11)
  set enabled($core.bool value) => $_setBool(10, value);
  @$pb.TagNumber(11)
  $core.bool hasEnabled() => $_has(10);
  @$pb.TagNumber(11)
  void clearEnabled() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.bool get requireEmail => $_getBF(11);
  @$pb.TagNumber(12)
  set requireEmail($core.bool value) => $_setBool(11, value);
  @$pb.TagNumber(12)
  $core.bool hasRequireEmail() => $_has(11);
  @$pb.TagNumber(12)
  void clearRequireEmail() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.bool get sendConfirmation => $_getBF(12);
  @$pb.TagNumber(13)
  set sendConfirmation($core.bool value) => $_setBool(12, value);
  @$pb.TagNumber(13)
  $core.bool hasSendConfirmation() => $_has(12);
  @$pb.TagNumber(13)
  void clearSendConfirmation() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.bool get notifyStatus => $_getBF(13);
  @$pb.TagNumber(14)
  set notifyStatus($core.bool value) => $_setBool(13, value);
  @$pb.TagNumber(14)
  $core.bool hasNotifyStatus() => $_has(13);
  @$pb.TagNumber(14)
  void clearNotifyStatus() => $_clearField(14);

  @$pb.TagNumber(15)
  $core.String get brandColor => $_getSZ(14);
  @$pb.TagNumber(15)
  set brandColor($core.String value) => $_setString(14, value);
  @$pb.TagNumber(15)
  $core.bool hasBrandColor() => $_has(14);
  @$pb.TagNumber(15)
  void clearBrandColor() => $_clearField(15);

  @$pb.TagNumber(16)
  $core.String get logoUrl => $_getSZ(15);
  @$pb.TagNumber(16)
  set logoUrl($core.String value) => $_setString(15, value);
  @$pb.TagNumber(16)
  $core.bool hasLogoUrl() => $_has(15);
  @$pb.TagNumber(16)
  void clearLogoUrl() => $_clearField(16);

  @$pb.TagNumber(17)
  $core.int get version => $_getIZ(16);
  @$pb.TagNumber(17)
  set version($core.int value) => $_setSignedInt32(16, value);
  @$pb.TagNumber(17)
  $core.bool hasVersion() => $_has(16);
  @$pb.TagNumber(17)
  void clearVersion() => $_clearField(17);

  @$pb.TagNumber(18)
  $core.int get submissionCount => $_getIZ(17);
  @$pb.TagNumber(18)
  set submissionCount($core.int value) => $_setSignedInt32(17, value);
  @$pb.TagNumber(18)
  $core.bool hasSubmissionCount() => $_has(17);
  @$pb.TagNumber(18)
  void clearSubmissionCount() => $_clearField(18);

  @$pb.TagNumber(19)
  $core.String get problem => $_getSZ(18);
  @$pb.TagNumber(19)
  set problem($core.String value) => $_setString(18, value);
  @$pb.TagNumber(19)
  $core.bool hasProblem() => $_has(18);
  @$pb.TagNumber(19)
  void clearProblem() => $_clearField(19);

  @$pb.TagNumber(20)
  $core.String get ownerId => $_getSZ(19);
  @$pb.TagNumber(20)
  set ownerId($core.String value) => $_setString(19, value);
  @$pb.TagNumber(20)
  $core.bool hasOwnerId() => $_has(19);
  @$pb.TagNumber(20)
  void clearOwnerId() => $_clearField(20);

  @$pb.TagNumber(21)
  $core.String get createdAt => $_getSZ(20);
  @$pb.TagNumber(21)
  set createdAt($core.String value) => $_setString(20, value);
  @$pb.TagNumber(21)
  $core.bool hasCreatedAt() => $_has(20);
  @$pb.TagNumber(21)
  void clearCreatedAt() => $_clearField(21);

  @$pb.TagNumber(22)
  $core.String get updatedAt => $_getSZ(21);
  @$pb.TagNumber(22)
  set updatedAt($core.String value) => $_setString(21, value);
  @$pb.TagNumber(22)
  $core.bool hasUpdatedAt() => $_has(21);
  @$pb.TagNumber(22)
  void clearUpdatedAt() => $_clearField(22);
}

class IntakeSubmission extends $pb.GeneratedMessage {
  factory IntakeSubmission({
    $core.String? id,
    $core.String? formId,
    $core.String? reference,
    $core.String? projectId,
    $core.String? taskId,
    $core.String? taskKey,
    $core.String? taskTitle,
    $core.String? statusName,
    $core.String? submitterEmail,
    $core.String? at,
  }) {
    final result = IntakeSubmission._();
    if (id != null) result.id = id;
    if (formId != null) result.formId = formId;
    if (reference != null) result.reference = reference;
    if (projectId != null) result.projectId = projectId;
    if (taskId != null) result.taskId = taskId;
    if (taskKey != null) result.taskKey = taskKey;
    if (taskTitle != null) result.taskTitle = taskTitle;
    if (statusName != null) result.statusName = statusName;
    if (submitterEmail != null) result.submitterEmail = submitterEmail;
    if (at != null) result.at = at;
    return result;
  }

  IntakeSubmission._();

  factory IntakeSubmission.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      IntakeSubmission()..mergeFromBuffer(data, registry);
  factory IntakeSubmission.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      IntakeSubmission()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'IntakeSubmission',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.forms'),
      createEmptyInstance: IntakeSubmission.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'formId')
    ..aOS(3, _omitFieldNames ? '' : 'reference')
    ..aOS(4, _omitFieldNames ? '' : 'projectId')
    ..aOS(5, _omitFieldNames ? '' : 'taskId')
    ..aOS(6, _omitFieldNames ? '' : 'taskKey')
    ..aOS(7, _omitFieldNames ? '' : 'taskTitle')
    ..aOS(8, _omitFieldNames ? '' : 'statusName')
    ..aOS(9, _omitFieldNames ? '' : 'submitterEmail')
    ..aOS(10, _omitFieldNames ? '' : 'at')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  IntakeSubmission clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  IntakeSubmission copyWith(void Function(IntakeSubmission) updates) =>
      super.copyWith((message) => updates(message as IntakeSubmission))
          as IntakeSubmission;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use IntakeSubmission() / IntakeSubmission.new instead')
  static IntakeSubmission create() => IntakeSubmission._();
  static $pb.GeneratedMessage $_createMessage() => IntakeSubmission._();
  @$core.override
  IntakeSubmission createEmptyInstance() => IntakeSubmission._();
  @$core.pragma('dart2js:noInline')
  static IntakeSubmission getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<IntakeSubmission>(
          IntakeSubmission.$_createMessage);
  static IntakeSubmission? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get formId => $_getSZ(1);
  @$pb.TagNumber(2)
  set formId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFormId() => $_has(1);
  @$pb.TagNumber(2)
  void clearFormId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get reference => $_getSZ(2);
  @$pb.TagNumber(3)
  set reference($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasReference() => $_has(2);
  @$pb.TagNumber(3)
  void clearReference() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get projectId => $_getSZ(3);
  @$pb.TagNumber(4)
  set projectId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasProjectId() => $_has(3);
  @$pb.TagNumber(4)
  void clearProjectId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get taskId => $_getSZ(4);
  @$pb.TagNumber(5)
  set taskId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasTaskId() => $_has(4);
  @$pb.TagNumber(5)
  void clearTaskId() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get taskKey => $_getSZ(5);
  @$pb.TagNumber(6)
  set taskKey($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasTaskKey() => $_has(5);
  @$pb.TagNumber(6)
  void clearTaskKey() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get taskTitle => $_getSZ(6);
  @$pb.TagNumber(7)
  set taskTitle($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasTaskTitle() => $_has(6);
  @$pb.TagNumber(7)
  void clearTaskTitle() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get statusName => $_getSZ(7);
  @$pb.TagNumber(8)
  set statusName($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasStatusName() => $_has(7);
  @$pb.TagNumber(8)
  void clearStatusName() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get submitterEmail => $_getSZ(8);
  @$pb.TagNumber(9)
  set submitterEmail($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasSubmitterEmail() => $_has(8);
  @$pb.TagNumber(9)
  void clearSubmitterEmail() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get at => $_getSZ(9);
  @$pb.TagNumber(10)
  set at($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasAt() => $_has(9);
  @$pb.TagNumber(10)
  void clearAt() => $_clearField(10);
}

class SubmissionList extends $pb.GeneratedMessage {
  factory SubmissionList({
    $core.Iterable<IntakeSubmission>? submissions,
    $core.String? cursor,
  }) {
    final result = SubmissionList._();
    if (submissions != null) result.submissions.addAll(submissions);
    if (cursor != null) result.cursor = cursor;
    return result;
  }

  SubmissionList._();

  factory SubmissionList.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SubmissionList()..mergeFromBuffer(data, registry);
  factory SubmissionList.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SubmissionList()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SubmissionList',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.forms'),
      createEmptyInstance: SubmissionList.$_createMessage)
    ..pPM<IntakeSubmission>(1, _omitFieldNames ? '' : 'submissions',
        subBuilder: IntakeSubmission.$_createMessage)
    ..aOS(2, _omitFieldNames ? '' : 'cursor')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SubmissionList clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SubmissionList copyWith(void Function(SubmissionList) updates) =>
      super.copyWith((message) => updates(message as SubmissionList))
          as SubmissionList;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SubmissionList() / SubmissionList.new instead')
  static SubmissionList create() => SubmissionList._();
  static $pb.GeneratedMessage $_createMessage() => SubmissionList._();
  @$core.override
  SubmissionList createEmptyInstance() => SubmissionList._();
  @$core.pragma('dart2js:noInline')
  static SubmissionList getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SubmissionList>(
          SubmissionList.$_createMessage);
  static SubmissionList? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<IntakeSubmission> get submissions => $_getList(0);

  @$pb.TagNumber(2)
  $core.String get cursor => $_getSZ(1);
  @$pb.TagNumber(2)
  set cursor($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCursor() => $_has(1);
  @$pb.TagNumber(2)
  void clearCursor() => $_clearField(2);
}

class SubmissionsRequest extends $pb.GeneratedMessage {
  factory SubmissionsRequest({
    $core.String? workspaceId,
    $core.String? formId,
    $core.String? before,
    $core.int? limit,
  }) {
    final result = SubmissionsRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (formId != null) result.formId = formId;
    if (before != null) result.before = before;
    if (limit != null) result.limit = limit;
    return result;
  }

  SubmissionsRequest._();

  factory SubmissionsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SubmissionsRequest()..mergeFromBuffer(data, registry);
  factory SubmissionsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SubmissionsRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SubmissionsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.forms'),
      createEmptyInstance: SubmissionsRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'formId')
    ..aOS(3, _omitFieldNames ? '' : 'before')
    ..aI(4, _omitFieldNames ? '' : 'limit')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SubmissionsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SubmissionsRequest copyWith(void Function(SubmissionsRequest) updates) =>
      super.copyWith((message) => updates(message as SubmissionsRequest))
          as SubmissionsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SubmissionsRequest() / SubmissionsRequest.new instead')
  static SubmissionsRequest create() => SubmissionsRequest._();
  static $pb.GeneratedMessage $_createMessage() => SubmissionsRequest._();
  @$core.override
  SubmissionsRequest createEmptyInstance() => SubmissionsRequest._();
  @$core.pragma('dart2js:noInline')
  static SubmissionsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SubmissionsRequest>(
          SubmissionsRequest.$_createMessage);
  static SubmissionsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get formId => $_getSZ(1);
  @$pb.TagNumber(2)
  set formId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFormId() => $_has(1);
  @$pb.TagNumber(2)
  void clearFormId() => $_clearField(2);

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

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
