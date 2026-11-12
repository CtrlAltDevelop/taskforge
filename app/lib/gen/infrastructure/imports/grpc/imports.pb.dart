// This is a generated file - do not edit.
//
// Generated from infrastructure/imports/grpc/imports.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class ExportJob extends $pb.GeneratedMessage {
  factory ExportJob({
    $core.String? id,
    $core.String? scope,
    $core.String? projectId,
    $core.String? status,
    $core.String? filename,
    $core.int? size,
    $core.String? statsJson,
    $core.String? error,
    $core.String? downloadPath,
    $core.String? createdAt,
  }) {
    final result = ExportJob._();
    if (id != null) result.id = id;
    if (scope != null) result.scope = scope;
    if (projectId != null) result.projectId = projectId;
    if (status != null) result.status = status;
    if (filename != null) result.filename = filename;
    if (size != null) result.size = size;
    if (statsJson != null) result.statsJson = statsJson;
    if (error != null) result.error = error;
    if (downloadPath != null) result.downloadPath = downloadPath;
    if (createdAt != null) result.createdAt = createdAt;
    return result;
  }

  ExportJob._();

  factory ExportJob.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ExportJob()..mergeFromBuffer(data, registry);
  factory ExportJob.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ExportJob()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ExportJob',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.imports'),
      createEmptyInstance: ExportJob.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'scope')
    ..aOS(3, _omitFieldNames ? '' : 'projectId')
    ..aOS(4, _omitFieldNames ? '' : 'status')
    ..aOS(5, _omitFieldNames ? '' : 'filename')
    ..aI(6, _omitFieldNames ? '' : 'size')
    ..aOS(7, _omitFieldNames ? '' : 'statsJson')
    ..aOS(8, _omitFieldNames ? '' : 'error')
    ..aOS(9, _omitFieldNames ? '' : 'downloadPath')
    ..aOS(10, _omitFieldNames ? '' : 'createdAt')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExportJob clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExportJob copyWith(void Function(ExportJob) updates) =>
      super.copyWith((message) => updates(message as ExportJob)) as ExportJob;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ExportJob() / ExportJob.new instead')
  static ExportJob create() => ExportJob._();
  static $pb.GeneratedMessage $_createMessage() => ExportJob._();
  @$core.override
  ExportJob createEmptyInstance() => ExportJob._();
  @$core.pragma('dart2js:noInline')
  static ExportJob getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ExportJob>(ExportJob.$_createMessage);
  static ExportJob? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get scope => $_getSZ(1);
  @$pb.TagNumber(2)
  set scope($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasScope() => $_has(1);
  @$pb.TagNumber(2)
  void clearScope() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get projectId => $_getSZ(2);
  @$pb.TagNumber(3)
  set projectId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasProjectId() => $_has(2);
  @$pb.TagNumber(3)
  void clearProjectId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get status => $_getSZ(3);
  @$pb.TagNumber(4)
  set status($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasStatus() => $_has(3);
  @$pb.TagNumber(4)
  void clearStatus() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get filename => $_getSZ(4);
  @$pb.TagNumber(5)
  set filename($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasFilename() => $_has(4);
  @$pb.TagNumber(5)
  void clearFilename() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get size => $_getIZ(5);
  @$pb.TagNumber(6)
  set size($core.int value) => $_setSignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasSize() => $_has(5);
  @$pb.TagNumber(6)
  void clearSize() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get statsJson => $_getSZ(6);
  @$pb.TagNumber(7)
  set statsJson($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasStatsJson() => $_has(6);
  @$pb.TagNumber(7)
  void clearStatsJson() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get error => $_getSZ(7);
  @$pb.TagNumber(8)
  set error($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasError() => $_has(7);
  @$pb.TagNumber(8)
  void clearError() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get downloadPath => $_getSZ(8);
  @$pb.TagNumber(9)
  set downloadPath($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasDownloadPath() => $_has(8);
  @$pb.TagNumber(9)
  void clearDownloadPath() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get createdAt => $_getSZ(9);
  @$pb.TagNumber(10)
  set createdAt($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasCreatedAt() => $_has(9);
  @$pb.TagNumber(10)
  void clearCreatedAt() => $_clearField(10);
}

class ExportStartRequest extends $pb.GeneratedMessage {
  factory ExportStartRequest({
    $core.String? workspaceId,
    $core.String? projectId,
  }) {
    final result = ExportStartRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (projectId != null) result.projectId = projectId;
    return result;
  }

  ExportStartRequest._();

  factory ExportStartRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ExportStartRequest()..mergeFromBuffer(data, registry);
  factory ExportStartRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ExportStartRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ExportStartRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.imports'),
      createEmptyInstance: ExportStartRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExportStartRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExportStartRequest copyWith(void Function(ExportStartRequest) updates) =>
      super.copyWith((message) => updates(message as ExportStartRequest))
          as ExportStartRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ExportStartRequest() / ExportStartRequest.new instead')
  static ExportStartRequest create() => ExportStartRequest._();
  static $pb.GeneratedMessage $_createMessage() => ExportStartRequest._();
  @$core.override
  ExportStartRequest createEmptyInstance() => ExportStartRequest._();
  @$core.pragma('dart2js:noInline')
  static ExportStartRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ExportStartRequest>(
          ExportStartRequest.$_createMessage);
  static ExportStartRequest? _defaultInstance;

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

class ExportStarted extends $pb.GeneratedMessage {
  factory ExportStarted({
    ExportJob? export,
  }) {
    final result = ExportStarted._();
    if (export != null) result.export = export;
    return result;
  }

  ExportStarted._();

  factory ExportStarted.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ExportStarted()..mergeFromBuffer(data, registry);
  factory ExportStarted.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ExportStarted()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ExportStarted',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.imports'),
      createEmptyInstance: ExportStarted.$_createMessage)
    ..aOM<ExportJob>(1, _omitFieldNames ? '' : 'export',
        subBuilder: ExportJob.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExportStarted clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExportStarted copyWith(void Function(ExportStarted) updates) =>
      super.copyWith((message) => updates(message as ExportStarted))
          as ExportStarted;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ExportStarted() / ExportStarted.new instead')
  static ExportStarted create() => ExportStarted._();
  static $pb.GeneratedMessage $_createMessage() => ExportStarted._();
  @$core.override
  ExportStarted createEmptyInstance() => ExportStarted._();
  @$core.pragma('dart2js:noInline')
  static ExportStarted getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ExportStarted>(
          ExportStarted.$_createMessage);
  static ExportStarted? _defaultInstance;

  @$pb.TagNumber(1)
  ExportJob get export => $_getN(0);
  @$pb.TagNumber(1)
  set export(ExportJob value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasExport() => $_has(0);
  @$pb.TagNumber(1)
  void clearExport() => $_clearField(1);
  @$pb.TagNumber(1)
  ExportJob ensureExport() => $_ensure(0);
}

class ExportStatus extends $pb.GeneratedMessage {
  factory ExportStatus({
    ExportJob? export,
  }) {
    final result = ExportStatus._();
    if (export != null) result.export = export;
    return result;
  }

  ExportStatus._();

  factory ExportStatus.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ExportStatus()..mergeFromBuffer(data, registry);
  factory ExportStatus.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ExportStatus()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ExportStatus',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.imports'),
      createEmptyInstance: ExportStatus.$_createMessage)
    ..aOM<ExportJob>(1, _omitFieldNames ? '' : 'export',
        subBuilder: ExportJob.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExportStatus clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExportStatus copyWith(void Function(ExportStatus) updates) =>
      super.copyWith((message) => updates(message as ExportStatus))
          as ExportStatus;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ExportStatus() / ExportStatus.new instead')
  static ExportStatus create() => ExportStatus._();
  static $pb.GeneratedMessage $_createMessage() => ExportStatus._();
  @$core.override
  ExportStatus createEmptyInstance() => ExportStatus._();
  @$core.pragma('dart2js:noInline')
  static ExportStatus getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ExportStatus>(
          ExportStatus.$_createMessage);
  static ExportStatus? _defaultInstance;

  @$pb.TagNumber(1)
  ExportJob get export => $_getN(0);
  @$pb.TagNumber(1)
  set export(ExportJob value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasExport() => $_has(0);
  @$pb.TagNumber(1)
  void clearExport() => $_clearField(1);
  @$pb.TagNumber(1)
  ExportJob ensureExport() => $_ensure(0);
}

class ExportStatusRequest extends $pb.GeneratedMessage {
  factory ExportStatusRequest({
    $core.String? workspaceId,
    $core.String? exportId,
  }) {
    final result = ExportStatusRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (exportId != null) result.exportId = exportId;
    return result;
  }

  ExportStatusRequest._();

  factory ExportStatusRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ExportStatusRequest()..mergeFromBuffer(data, registry);
  factory ExportStatusRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ExportStatusRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ExportStatusRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.imports'),
      createEmptyInstance: ExportStatusRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'exportId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExportStatusRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExportStatusRequest copyWith(void Function(ExportStatusRequest) updates) =>
      super.copyWith((message) => updates(message as ExportStatusRequest))
          as ExportStatusRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core
      .Deprecated('Use ExportStatusRequest() / ExportStatusRequest.new instead')
  static ExportStatusRequest create() => ExportStatusRequest._();
  static $pb.GeneratedMessage $_createMessage() => ExportStatusRequest._();
  @$core.override
  ExportStatusRequest createEmptyInstance() => ExportStatusRequest._();
  @$core.pragma('dart2js:noInline')
  static ExportStatusRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ExportStatusRequest>(
          ExportStatusRequest.$_createMessage);
  static ExportStatusRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get exportId => $_getSZ(1);
  @$pb.TagNumber(2)
  set exportId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasExportId() => $_has(1);
  @$pb.TagNumber(2)
  void clearExportId() => $_clearField(2);
}

class ImportAnalyzeRequest extends $pb.GeneratedMessage {
  factory ImportAnalyzeRequest({
    $core.String? workspaceId,
    $core.String? jobId,
    $core.String? source,
    $core.String? member,
  }) {
    final result = ImportAnalyzeRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (jobId != null) result.jobId = jobId;
    if (source != null) result.source = source;
    if (member != null) result.member = member;
    return result;
  }

  ImportAnalyzeRequest._();

  factory ImportAnalyzeRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ImportAnalyzeRequest()..mergeFromBuffer(data, registry);
  factory ImportAnalyzeRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ImportAnalyzeRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ImportAnalyzeRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.imports'),
      createEmptyInstance: ImportAnalyzeRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'jobId')
    ..aOS(3, _omitFieldNames ? '' : 'source')
    ..aOS(4, _omitFieldNames ? '' : 'member')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ImportAnalyzeRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ImportAnalyzeRequest copyWith(void Function(ImportAnalyzeRequest) updates) =>
      super.copyWith((message) => updates(message as ImportAnalyzeRequest))
          as ImportAnalyzeRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ImportAnalyzeRequest() / ImportAnalyzeRequest.new instead')
  static ImportAnalyzeRequest create() => ImportAnalyzeRequest._();
  static $pb.GeneratedMessage $_createMessage() => ImportAnalyzeRequest._();
  @$core.override
  ImportAnalyzeRequest createEmptyInstance() => ImportAnalyzeRequest._();
  @$core.pragma('dart2js:noInline')
  static ImportAnalyzeRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ImportAnalyzeRequest>(
          ImportAnalyzeRequest.$_createMessage);
  static ImportAnalyzeRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get jobId => $_getSZ(1);
  @$pb.TagNumber(2)
  set jobId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasJobId() => $_has(1);
  @$pb.TagNumber(2)
  void clearJobId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get source => $_getSZ(2);
  @$pb.TagNumber(3)
  set source($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSource() => $_has(2);
  @$pb.TagNumber(3)
  void clearSource() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get member => $_getSZ(3);
  @$pb.TagNumber(4)
  set member($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasMember() => $_has(3);
  @$pb.TagNumber(4)
  void clearMember() => $_clearField(4);
}

class ImportCancelRequest extends $pb.GeneratedMessage {
  factory ImportCancelRequest({
    $core.String? workspaceId,
    $core.String? jobId,
  }) {
    final result = ImportCancelRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (jobId != null) result.jobId = jobId;
    return result;
  }

  ImportCancelRequest._();

  factory ImportCancelRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ImportCancelRequest()..mergeFromBuffer(data, registry);
  factory ImportCancelRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ImportCancelRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ImportCancelRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.imports'),
      createEmptyInstance: ImportCancelRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'jobId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ImportCancelRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ImportCancelRequest copyWith(void Function(ImportCancelRequest) updates) =>
      super.copyWith((message) => updates(message as ImportCancelRequest))
          as ImportCancelRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core
      .Deprecated('Use ImportCancelRequest() / ImportCancelRequest.new instead')
  static ImportCancelRequest create() => ImportCancelRequest._();
  static $pb.GeneratedMessage $_createMessage() => ImportCancelRequest._();
  @$core.override
  ImportCancelRequest createEmptyInstance() => ImportCancelRequest._();
  @$core.pragma('dart2js:noInline')
  static ImportCancelRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ImportCancelRequest>(
          ImportCancelRequest.$_createMessage);
  static ImportCancelRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get jobId => $_getSZ(1);
  @$pb.TagNumber(2)
  set jobId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasJobId() => $_has(1);
  @$pb.TagNumber(2)
  void clearJobId() => $_clearField(2);
}

class ImportCancelled extends $pb.GeneratedMessage {
  factory ImportCancelled({
    Job? job,
  }) {
    final result = ImportCancelled._();
    if (job != null) result.job = job;
    return result;
  }

  ImportCancelled._();

  factory ImportCancelled.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ImportCancelled()..mergeFromBuffer(data, registry);
  factory ImportCancelled.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ImportCancelled()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ImportCancelled',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.imports'),
      createEmptyInstance: ImportCancelled.$_createMessage)
    ..aOM<Job>(1, _omitFieldNames ? '' : 'job', subBuilder: Job.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ImportCancelled clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ImportCancelled copyWith(void Function(ImportCancelled) updates) =>
      super.copyWith((message) => updates(message as ImportCancelled))
          as ImportCancelled;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ImportCancelled() / ImportCancelled.new instead')
  static ImportCancelled create() => ImportCancelled._();
  static $pb.GeneratedMessage $_createMessage() => ImportCancelled._();
  @$core.override
  ImportCancelled createEmptyInstance() => ImportCancelled._();
  @$core.pragma('dart2js:noInline')
  static ImportCancelled getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ImportCancelled>(
          ImportCancelled.$_createMessage);
  static ImportCancelled? _defaultInstance;

  @$pb.TagNumber(1)
  Job get job => $_getN(0);
  @$pb.TagNumber(1)
  set job(Job value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasJob() => $_has(0);
  @$pb.TagNumber(1)
  void clearJob() => $_clearField(1);
  @$pb.TagNumber(1)
  Job ensureJob() => $_ensure(0);
}

class ImportDetail extends $pb.GeneratedMessage {
  factory ImportDetail({
    Job? job,
    $core.Iterable<Problem>? problems,
    $core.String? mappingJson,
    $core.String? analysisJson,
  }) {
    final result = ImportDetail._();
    if (job != null) result.job = job;
    if (problems != null) result.problems.addAll(problems);
    if (mappingJson != null) result.mappingJson = mappingJson;
    if (analysisJson != null) result.analysisJson = analysisJson;
    return result;
  }

  ImportDetail._();

  factory ImportDetail.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ImportDetail()..mergeFromBuffer(data, registry);
  factory ImportDetail.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ImportDetail()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ImportDetail',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.imports'),
      createEmptyInstance: ImportDetail.$_createMessage)
    ..aOM<Job>(1, _omitFieldNames ? '' : 'job', subBuilder: Job.$_createMessage)
    ..pPM<Problem>(2, _omitFieldNames ? '' : 'problems',
        subBuilder: Problem.$_createMessage)
    ..aOS(3, _omitFieldNames ? '' : 'mappingJson')
    ..aOS(4, _omitFieldNames ? '' : 'analysisJson')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ImportDetail clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ImportDetail copyWith(void Function(ImportDetail) updates) =>
      super.copyWith((message) => updates(message as ImportDetail))
          as ImportDetail;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ImportDetail() / ImportDetail.new instead')
  static ImportDetail create() => ImportDetail._();
  static $pb.GeneratedMessage $_createMessage() => ImportDetail._();
  @$core.override
  ImportDetail createEmptyInstance() => ImportDetail._();
  @$core.pragma('dart2js:noInline')
  static ImportDetail getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ImportDetail>(
          ImportDetail.$_createMessage);
  static ImportDetail? _defaultInstance;

  @$pb.TagNumber(1)
  Job get job => $_getN(0);
  @$pb.TagNumber(1)
  set job(Job value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasJob() => $_has(0);
  @$pb.TagNumber(1)
  void clearJob() => $_clearField(1);
  @$pb.TagNumber(1)
  Job ensureJob() => $_ensure(0);

  @$pb.TagNumber(2)
  $pb.PbList<Problem> get problems => $_getList(1);

  @$pb.TagNumber(3)
  $core.String get mappingJson => $_getSZ(2);
  @$pb.TagNumber(3)
  set mappingJson($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasMappingJson() => $_has(2);
  @$pb.TagNumber(3)
  void clearMappingJson() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get analysisJson => $_getSZ(3);
  @$pb.TagNumber(4)
  set analysisJson($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasAnalysisJson() => $_has(3);
  @$pb.TagNumber(4)
  void clearAnalysisJson() => $_clearField(4);
}

class ImportDiscardRequest extends $pb.GeneratedMessage {
  factory ImportDiscardRequest({
    $core.String? workspaceId,
    $core.String? jobId,
  }) {
    final result = ImportDiscardRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (jobId != null) result.jobId = jobId;
    return result;
  }

  ImportDiscardRequest._();

  factory ImportDiscardRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ImportDiscardRequest()..mergeFromBuffer(data, registry);
  factory ImportDiscardRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ImportDiscardRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ImportDiscardRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.imports'),
      createEmptyInstance: ImportDiscardRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'jobId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ImportDiscardRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ImportDiscardRequest copyWith(void Function(ImportDiscardRequest) updates) =>
      super.copyWith((message) => updates(message as ImportDiscardRequest))
          as ImportDiscardRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ImportDiscardRequest() / ImportDiscardRequest.new instead')
  static ImportDiscardRequest create() => ImportDiscardRequest._();
  static $pb.GeneratedMessage $_createMessage() => ImportDiscardRequest._();
  @$core.override
  ImportDiscardRequest createEmptyInstance() => ImportDiscardRequest._();
  @$core.pragma('dart2js:noInline')
  static ImportDiscardRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ImportDiscardRequest>(
          ImportDiscardRequest.$_createMessage);
  static ImportDiscardRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get jobId => $_getSZ(1);
  @$pb.TagNumber(2)
  set jobId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasJobId() => $_has(1);
  @$pb.TagNumber(2)
  void clearJobId() => $_clearField(2);
}

class ImportDiscarded extends $pb.GeneratedMessage {
  factory ImportDiscarded({
    $core.String? jobId,
  }) {
    final result = ImportDiscarded._();
    if (jobId != null) result.jobId = jobId;
    return result;
  }

  ImportDiscarded._();

  factory ImportDiscarded.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ImportDiscarded()..mergeFromBuffer(data, registry);
  factory ImportDiscarded.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ImportDiscarded()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ImportDiscarded',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.imports'),
      createEmptyInstance: ImportDiscarded.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'jobId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ImportDiscarded clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ImportDiscarded copyWith(void Function(ImportDiscarded) updates) =>
      super.copyWith((message) => updates(message as ImportDiscarded))
          as ImportDiscarded;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ImportDiscarded() / ImportDiscarded.new instead')
  static ImportDiscarded create() => ImportDiscarded._();
  static $pb.GeneratedMessage $_createMessage() => ImportDiscarded._();
  @$core.override
  ImportDiscarded createEmptyInstance() => ImportDiscarded._();
  @$core.pragma('dart2js:noInline')
  static ImportDiscarded getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ImportDiscarded>(
          ImportDiscarded.$_createMessage);
  static ImportDiscarded? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get jobId => $_getSZ(0);
  @$pb.TagNumber(1)
  set jobId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasJobId() => $_has(0);
  @$pb.TagNumber(1)
  void clearJobId() => $_clearField(1);
}

class ImportDryRunRequest extends $pb.GeneratedMessage {
  factory ImportDryRunRequest({
    $core.String? workspaceId,
    $core.String? jobId,
    $core.String? mappingJson,
  }) {
    final result = ImportDryRunRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (jobId != null) result.jobId = jobId;
    if (mappingJson != null) result.mappingJson = mappingJson;
    return result;
  }

  ImportDryRunRequest._();

  factory ImportDryRunRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ImportDryRunRequest()..mergeFromBuffer(data, registry);
  factory ImportDryRunRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ImportDryRunRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ImportDryRunRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.imports'),
      createEmptyInstance: ImportDryRunRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'jobId')
    ..aOS(3, _omitFieldNames ? '' : 'mappingJson')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ImportDryRunRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ImportDryRunRequest copyWith(void Function(ImportDryRunRequest) updates) =>
      super.copyWith((message) => updates(message as ImportDryRunRequest))
          as ImportDryRunRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core
      .Deprecated('Use ImportDryRunRequest() / ImportDryRunRequest.new instead')
  static ImportDryRunRequest create() => ImportDryRunRequest._();
  static $pb.GeneratedMessage $_createMessage() => ImportDryRunRequest._();
  @$core.override
  ImportDryRunRequest createEmptyInstance() => ImportDryRunRequest._();
  @$core.pragma('dart2js:noInline')
  static ImportDryRunRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ImportDryRunRequest>(
          ImportDryRunRequest.$_createMessage);
  static ImportDryRunRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get jobId => $_getSZ(1);
  @$pb.TagNumber(2)
  set jobId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasJobId() => $_has(1);
  @$pb.TagNumber(2)
  void clearJobId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get mappingJson => $_getSZ(2);
  @$pb.TagNumber(3)
  set mappingJson($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasMappingJson() => $_has(2);
  @$pb.TagNumber(3)
  void clearMappingJson() => $_clearField(3);
}

class ImportGetRequest extends $pb.GeneratedMessage {
  factory ImportGetRequest({
    $core.String? workspaceId,
    $core.String? jobId,
  }) {
    final result = ImportGetRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (jobId != null) result.jobId = jobId;
    return result;
  }

  ImportGetRequest._();

  factory ImportGetRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ImportGetRequest()..mergeFromBuffer(data, registry);
  factory ImportGetRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ImportGetRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ImportGetRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.imports'),
      createEmptyInstance: ImportGetRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'jobId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ImportGetRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ImportGetRequest copyWith(void Function(ImportGetRequest) updates) =>
      super.copyWith((message) => updates(message as ImportGetRequest))
          as ImportGetRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ImportGetRequest() / ImportGetRequest.new instead')
  static ImportGetRequest create() => ImportGetRequest._();
  static $pb.GeneratedMessage $_createMessage() => ImportGetRequest._();
  @$core.override
  ImportGetRequest createEmptyInstance() => ImportGetRequest._();
  @$core.pragma('dart2js:noInline')
  static ImportGetRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ImportGetRequest>(
          ImportGetRequest.$_createMessage);
  static ImportGetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get jobId => $_getSZ(1);
  @$pb.TagNumber(2)
  set jobId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasJobId() => $_has(1);
  @$pb.TagNumber(2)
  void clearJobId() => $_clearField(2);
}

class ImportList extends $pb.GeneratedMessage {
  factory ImportList({
    $core.Iterable<Job>? jobs,
  }) {
    final result = ImportList._();
    if (jobs != null) result.jobs.addAll(jobs);
    return result;
  }

  ImportList._();

  factory ImportList.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ImportList()..mergeFromBuffer(data, registry);
  factory ImportList.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ImportList()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ImportList',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.imports'),
      createEmptyInstance: ImportList.$_createMessage)
    ..pPM<Job>(1, _omitFieldNames ? '' : 'jobs',
        subBuilder: Job.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ImportList clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ImportList copyWith(void Function(ImportList) updates) =>
      super.copyWith((message) => updates(message as ImportList)) as ImportList;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ImportList() / ImportList.new instead')
  static ImportList create() => ImportList._();
  static $pb.GeneratedMessage $_createMessage() => ImportList._();
  @$core.override
  ImportList createEmptyInstance() => ImportList._();
  @$core.pragma('dart2js:noInline')
  static ImportList getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ImportList>(ImportList.$_createMessage);
  static ImportList? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Job> get jobs => $_getList(0);
}

class ImportListRequest extends $pb.GeneratedMessage {
  factory ImportListRequest({
    $core.String? workspaceId,
  }) {
    final result = ImportListRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    return result;
  }

  ImportListRequest._();

  factory ImportListRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ImportListRequest()..mergeFromBuffer(data, registry);
  factory ImportListRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ImportListRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ImportListRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.imports'),
      createEmptyInstance: ImportListRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ImportListRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ImportListRequest copyWith(void Function(ImportListRequest) updates) =>
      super.copyWith((message) => updates(message as ImportListRequest))
          as ImportListRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ImportListRequest() / ImportListRequest.new instead')
  static ImportListRequest create() => ImportListRequest._();
  static $pb.GeneratedMessage $_createMessage() => ImportListRequest._();
  @$core.override
  ImportListRequest createEmptyInstance() => ImportListRequest._();
  @$core.pragma('dart2js:noInline')
  static ImportListRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ImportListRequest>(
          ImportListRequest.$_createMessage);
  static ImportListRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);
}

class ImportProgress extends $pb.GeneratedMessage {
  factory ImportProgress({
    Job? job,
  }) {
    final result = ImportProgress._();
    if (job != null) result.job = job;
    return result;
  }

  ImportProgress._();

  factory ImportProgress.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ImportProgress()..mergeFromBuffer(data, registry);
  factory ImportProgress.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ImportProgress()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ImportProgress',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.imports'),
      createEmptyInstance: ImportProgress.$_createMessage)
    ..aOM<Job>(1, _omitFieldNames ? '' : 'job', subBuilder: Job.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ImportProgress clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ImportProgress copyWith(void Function(ImportProgress) updates) =>
      super.copyWith((message) => updates(message as ImportProgress))
          as ImportProgress;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ImportProgress() / ImportProgress.new instead')
  static ImportProgress create() => ImportProgress._();
  static $pb.GeneratedMessage $_createMessage() => ImportProgress._();
  @$core.override
  ImportProgress createEmptyInstance() => ImportProgress._();
  @$core.pragma('dart2js:noInline')
  static ImportProgress getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ImportProgress>(
          ImportProgress.$_createMessage);
  static ImportProgress? _defaultInstance;

  @$pb.TagNumber(1)
  Job get job => $_getN(0);
  @$pb.TagNumber(1)
  set job(Job value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasJob() => $_has(0);
  @$pb.TagNumber(1)
  void clearJob() => $_clearField(1);
  @$pb.TagNumber(1)
  Job ensureJob() => $_ensure(0);
}

class ImportProgressRequest extends $pb.GeneratedMessage {
  factory ImportProgressRequest({
    $core.String? workspaceId,
    $core.String? jobId,
  }) {
    final result = ImportProgressRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (jobId != null) result.jobId = jobId;
    return result;
  }

  ImportProgressRequest._();

  factory ImportProgressRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ImportProgressRequest()..mergeFromBuffer(data, registry);
  factory ImportProgressRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ImportProgressRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ImportProgressRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.imports'),
      createEmptyInstance: ImportProgressRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'jobId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ImportProgressRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ImportProgressRequest copyWith(
          void Function(ImportProgressRequest) updates) =>
      super.copyWith((message) => updates(message as ImportProgressRequest))
          as ImportProgressRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ImportProgressRequest() / ImportProgressRequest.new instead')
  static ImportProgressRequest create() => ImportProgressRequest._();
  static $pb.GeneratedMessage $_createMessage() => ImportProgressRequest._();
  @$core.override
  ImportProgressRequest createEmptyInstance() => ImportProgressRequest._();
  @$core.pragma('dart2js:noInline')
  static ImportProgressRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ImportProgressRequest>(
          ImportProgressRequest.$_createMessage);
  static ImportProgressRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get jobId => $_getSZ(1);
  @$pb.TagNumber(2)
  set jobId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasJobId() => $_has(1);
  @$pb.TagNumber(2)
  void clearJobId() => $_clearField(2);
}

class ImportProposal extends $pb.GeneratedMessage {
  factory ImportProposal({
    Job? job,
    $core.String? mappingJson,
    $core.String? analysisJson,
    $core.Iterable<$core.String>? members,
  }) {
    final result = ImportProposal._();
    if (job != null) result.job = job;
    if (mappingJson != null) result.mappingJson = mappingJson;
    if (analysisJson != null) result.analysisJson = analysisJson;
    if (members != null) result.members.addAll(members);
    return result;
  }

  ImportProposal._();

  factory ImportProposal.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ImportProposal()..mergeFromBuffer(data, registry);
  factory ImportProposal.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ImportProposal()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ImportProposal',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.imports'),
      createEmptyInstance: ImportProposal.$_createMessage)
    ..aOM<Job>(1, _omitFieldNames ? '' : 'job', subBuilder: Job.$_createMessage)
    ..aOS(2, _omitFieldNames ? '' : 'mappingJson')
    ..aOS(3, _omitFieldNames ? '' : 'analysisJson')
    ..pPS(4, _omitFieldNames ? '' : 'members')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ImportProposal clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ImportProposal copyWith(void Function(ImportProposal) updates) =>
      super.copyWith((message) => updates(message as ImportProposal))
          as ImportProposal;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ImportProposal() / ImportProposal.new instead')
  static ImportProposal create() => ImportProposal._();
  static $pb.GeneratedMessage $_createMessage() => ImportProposal._();
  @$core.override
  ImportProposal createEmptyInstance() => ImportProposal._();
  @$core.pragma('dart2js:noInline')
  static ImportProposal getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ImportProposal>(
          ImportProposal.$_createMessage);
  static ImportProposal? _defaultInstance;

  @$pb.TagNumber(1)
  Job get job => $_getN(0);
  @$pb.TagNumber(1)
  set job(Job value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasJob() => $_has(0);
  @$pb.TagNumber(1)
  void clearJob() => $_clearField(1);
  @$pb.TagNumber(1)
  Job ensureJob() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.String get mappingJson => $_getSZ(1);
  @$pb.TagNumber(2)
  set mappingJson($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMappingJson() => $_has(1);
  @$pb.TagNumber(2)
  void clearMappingJson() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get analysisJson => $_getSZ(2);
  @$pb.TagNumber(3)
  set analysisJson($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAnalysisJson() => $_has(2);
  @$pb.TagNumber(3)
  void clearAnalysisJson() => $_clearField(3);

  @$pb.TagNumber(4)
  $pb.PbList<$core.String> get members => $_getList(3);
}

class ImportReport extends $pb.GeneratedMessage {
  factory ImportReport({
    $core.String? countsJson,
    $core.Iterable<Problem>? warnings,
    $core.int? errors,
    $core.int? warningTotal,
    $core.int? alreadyImported,
  }) {
    final result = ImportReport._();
    if (countsJson != null) result.countsJson = countsJson;
    if (warnings != null) result.warnings.addAll(warnings);
    if (errors != null) result.errors = errors;
    if (warningTotal != null) result.warningTotal = warningTotal;
    if (alreadyImported != null) result.alreadyImported = alreadyImported;
    return result;
  }

  ImportReport._();

  factory ImportReport.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ImportReport()..mergeFromBuffer(data, registry);
  factory ImportReport.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ImportReport()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ImportReport',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.imports'),
      createEmptyInstance: ImportReport.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'countsJson')
    ..pPM<Problem>(2, _omitFieldNames ? '' : 'warnings',
        subBuilder: Problem.$_createMessage)
    ..aI(3, _omitFieldNames ? '' : 'errors')
    ..aI(4, _omitFieldNames ? '' : 'warningTotal')
    ..aI(5, _omitFieldNames ? '' : 'alreadyImported')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ImportReport clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ImportReport copyWith(void Function(ImportReport) updates) =>
      super.copyWith((message) => updates(message as ImportReport))
          as ImportReport;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ImportReport() / ImportReport.new instead')
  static ImportReport create() => ImportReport._();
  static $pb.GeneratedMessage $_createMessage() => ImportReport._();
  @$core.override
  ImportReport createEmptyInstance() => ImportReport._();
  @$core.pragma('dart2js:noInline')
  static ImportReport getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ImportReport>(
          ImportReport.$_createMessage);
  static ImportReport? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get countsJson => $_getSZ(0);
  @$pb.TagNumber(1)
  set countsJson($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCountsJson() => $_has(0);
  @$pb.TagNumber(1)
  void clearCountsJson() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<Problem> get warnings => $_getList(1);

  @$pb.TagNumber(3)
  $core.int get errors => $_getIZ(2);
  @$pb.TagNumber(3)
  set errors($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasErrors() => $_has(2);
  @$pb.TagNumber(3)
  void clearErrors() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get warningTotal => $_getIZ(3);
  @$pb.TagNumber(4)
  set warningTotal($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasWarningTotal() => $_has(3);
  @$pb.TagNumber(4)
  void clearWarningTotal() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get alreadyImported => $_getIZ(4);
  @$pb.TagNumber(5)
  set alreadyImported($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasAlreadyImported() => $_has(4);
  @$pb.TagNumber(5)
  void clearAlreadyImported() => $_clearField(5);
}

class ImportStartRequest extends $pb.GeneratedMessage {
  factory ImportStartRequest({
    $core.String? workspaceId,
    $core.String? jobId,
    $core.String? mappingJson,
  }) {
    final result = ImportStartRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (jobId != null) result.jobId = jobId;
    if (mappingJson != null) result.mappingJson = mappingJson;
    return result;
  }

  ImportStartRequest._();

  factory ImportStartRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ImportStartRequest()..mergeFromBuffer(data, registry);
  factory ImportStartRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ImportStartRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ImportStartRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.imports'),
      createEmptyInstance: ImportStartRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'jobId')
    ..aOS(3, _omitFieldNames ? '' : 'mappingJson')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ImportStartRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ImportStartRequest copyWith(void Function(ImportStartRequest) updates) =>
      super.copyWith((message) => updates(message as ImportStartRequest))
          as ImportStartRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ImportStartRequest() / ImportStartRequest.new instead')
  static ImportStartRequest create() => ImportStartRequest._();
  static $pb.GeneratedMessage $_createMessage() => ImportStartRequest._();
  @$core.override
  ImportStartRequest createEmptyInstance() => ImportStartRequest._();
  @$core.pragma('dart2js:noInline')
  static ImportStartRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ImportStartRequest>(
          ImportStartRequest.$_createMessage);
  static ImportStartRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get jobId => $_getSZ(1);
  @$pb.TagNumber(2)
  set jobId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasJobId() => $_has(1);
  @$pb.TagNumber(2)
  void clearJobId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get mappingJson => $_getSZ(2);
  @$pb.TagNumber(3)
  set mappingJson($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasMappingJson() => $_has(2);
  @$pb.TagNumber(3)
  void clearMappingJson() => $_clearField(3);
}

class ImportStarted extends $pb.GeneratedMessage {
  factory ImportStarted({
    Job? job,
  }) {
    final result = ImportStarted._();
    if (job != null) result.job = job;
    return result;
  }

  ImportStarted._();

  factory ImportStarted.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ImportStarted()..mergeFromBuffer(data, registry);
  factory ImportStarted.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ImportStarted()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ImportStarted',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.imports'),
      createEmptyInstance: ImportStarted.$_createMessage)
    ..aOM<Job>(1, _omitFieldNames ? '' : 'job', subBuilder: Job.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ImportStarted clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ImportStarted copyWith(void Function(ImportStarted) updates) =>
      super.copyWith((message) => updates(message as ImportStarted))
          as ImportStarted;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ImportStarted() / ImportStarted.new instead')
  static ImportStarted create() => ImportStarted._();
  static $pb.GeneratedMessage $_createMessage() => ImportStarted._();
  @$core.override
  ImportStarted createEmptyInstance() => ImportStarted._();
  @$core.pragma('dart2js:noInline')
  static ImportStarted getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ImportStarted>(
          ImportStarted.$_createMessage);
  static ImportStarted? _defaultInstance;

  @$pb.TagNumber(1)
  Job get job => $_getN(0);
  @$pb.TagNumber(1)
  set job(Job value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasJob() => $_has(0);
  @$pb.TagNumber(1)
  void clearJob() => $_clearField(1);
  @$pb.TagNumber(1)
  Job ensureJob() => $_ensure(0);
}

class ImportUndoRequest extends $pb.GeneratedMessage {
  factory ImportUndoRequest({
    $core.String? workspaceId,
    $core.String? jobId,
  }) {
    final result = ImportUndoRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (jobId != null) result.jobId = jobId;
    return result;
  }

  ImportUndoRequest._();

  factory ImportUndoRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ImportUndoRequest()..mergeFromBuffer(data, registry);
  factory ImportUndoRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ImportUndoRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ImportUndoRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.imports'),
      createEmptyInstance: ImportUndoRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'jobId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ImportUndoRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ImportUndoRequest copyWith(void Function(ImportUndoRequest) updates) =>
      super.copyWith((message) => updates(message as ImportUndoRequest))
          as ImportUndoRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ImportUndoRequest() / ImportUndoRequest.new instead')
  static ImportUndoRequest create() => ImportUndoRequest._();
  static $pb.GeneratedMessage $_createMessage() => ImportUndoRequest._();
  @$core.override
  ImportUndoRequest createEmptyInstance() => ImportUndoRequest._();
  @$core.pragma('dart2js:noInline')
  static ImportUndoRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ImportUndoRequest>(
          ImportUndoRequest.$_createMessage);
  static ImportUndoRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get jobId => $_getSZ(1);
  @$pb.TagNumber(2)
  set jobId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasJobId() => $_has(1);
  @$pb.TagNumber(2)
  void clearJobId() => $_clearField(2);
}

class ImportUndone extends $pb.GeneratedMessage {
  factory ImportUndone({
    Job? job,
    $core.String? removedJson,
  }) {
    final result = ImportUndone._();
    if (job != null) result.job = job;
    if (removedJson != null) result.removedJson = removedJson;
    return result;
  }

  ImportUndone._();

  factory ImportUndone.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ImportUndone()..mergeFromBuffer(data, registry);
  factory ImportUndone.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ImportUndone()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ImportUndone',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.imports'),
      createEmptyInstance: ImportUndone.$_createMessage)
    ..aOM<Job>(1, _omitFieldNames ? '' : 'job', subBuilder: Job.$_createMessage)
    ..aOS(2, _omitFieldNames ? '' : 'removedJson')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ImportUndone clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ImportUndone copyWith(void Function(ImportUndone) updates) =>
      super.copyWith((message) => updates(message as ImportUndone))
          as ImportUndone;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ImportUndone() / ImportUndone.new instead')
  static ImportUndone create() => ImportUndone._();
  static $pb.GeneratedMessage $_createMessage() => ImportUndone._();
  @$core.override
  ImportUndone createEmptyInstance() => ImportUndone._();
  @$core.pragma('dart2js:noInline')
  static ImportUndone getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ImportUndone>(
          ImportUndone.$_createMessage);
  static ImportUndone? _defaultInstance;

  @$pb.TagNumber(1)
  Job get job => $_getN(0);
  @$pb.TagNumber(1)
  set job(Job value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasJob() => $_has(0);
  @$pb.TagNumber(1)
  void clearJob() => $_clearField(1);
  @$pb.TagNumber(1)
  Job ensureJob() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.String get removedJson => $_getSZ(1);
  @$pb.TagNumber(2)
  set removedJson($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRemovedJson() => $_has(1);
  @$pb.TagNumber(2)
  void clearRemovedJson() => $_clearField(2);
}

class Job extends $pb.GeneratedMessage {
  factory Job({
    $core.String? id,
    $core.String? source,
    $core.String? status,
    $core.String? filename,
    $core.String? projectId,
    $core.int? total,
    $core.int? done,
    $core.String? phase,
    $core.String? error,
    $core.String? statsJson,
    $core.int? problemCount,
    $core.String? createdAt,
    $core.String? startedAt,
    $core.String? finishedAt,
    $core.int? version,
  }) {
    final result = Job._();
    if (id != null) result.id = id;
    if (source != null) result.source = source;
    if (status != null) result.status = status;
    if (filename != null) result.filename = filename;
    if (projectId != null) result.projectId = projectId;
    if (total != null) result.total = total;
    if (done != null) result.done = done;
    if (phase != null) result.phase = phase;
    if (error != null) result.error = error;
    if (statsJson != null) result.statsJson = statsJson;
    if (problemCount != null) result.problemCount = problemCount;
    if (createdAt != null) result.createdAt = createdAt;
    if (startedAt != null) result.startedAt = startedAt;
    if (finishedAt != null) result.finishedAt = finishedAt;
    if (version != null) result.version = version;
    return result;
  }

  Job._();

  factory Job.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Job()..mergeFromBuffer(data, registry);
  factory Job.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Job()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Job',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.imports'),
      createEmptyInstance: Job.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'source')
    ..aOS(3, _omitFieldNames ? '' : 'status')
    ..aOS(4, _omitFieldNames ? '' : 'filename')
    ..aOS(5, _omitFieldNames ? '' : 'projectId')
    ..aI(6, _omitFieldNames ? '' : 'total')
    ..aI(7, _omitFieldNames ? '' : 'done')
    ..aOS(8, _omitFieldNames ? '' : 'phase')
    ..aOS(9, _omitFieldNames ? '' : 'error')
    ..aOS(10, _omitFieldNames ? '' : 'statsJson')
    ..aI(11, _omitFieldNames ? '' : 'problemCount')
    ..aOS(12, _omitFieldNames ? '' : 'createdAt')
    ..aOS(13, _omitFieldNames ? '' : 'startedAt')
    ..aOS(14, _omitFieldNames ? '' : 'finishedAt')
    ..aI(15, _omitFieldNames ? '' : 'version')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Job clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Job copyWith(void Function(Job) updates) =>
      super.copyWith((message) => updates(message as Job)) as Job;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Job() / Job.new instead')
  static Job create() => Job._();
  static $pb.GeneratedMessage $_createMessage() => Job._();
  @$core.override
  Job createEmptyInstance() => Job._();
  @$core.pragma('dart2js:noInline')
  static Job getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Job>(Job.$_createMessage);
  static Job? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get source => $_getSZ(1);
  @$pb.TagNumber(2)
  set source($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSource() => $_has(1);
  @$pb.TagNumber(2)
  void clearSource() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get status => $_getSZ(2);
  @$pb.TagNumber(3)
  set status($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasStatus() => $_has(2);
  @$pb.TagNumber(3)
  void clearStatus() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get filename => $_getSZ(3);
  @$pb.TagNumber(4)
  set filename($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasFilename() => $_has(3);
  @$pb.TagNumber(4)
  void clearFilename() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get projectId => $_getSZ(4);
  @$pb.TagNumber(5)
  set projectId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasProjectId() => $_has(4);
  @$pb.TagNumber(5)
  void clearProjectId() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get total => $_getIZ(5);
  @$pb.TagNumber(6)
  set total($core.int value) => $_setSignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasTotal() => $_has(5);
  @$pb.TagNumber(6)
  void clearTotal() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.int get done => $_getIZ(6);
  @$pb.TagNumber(7)
  set done($core.int value) => $_setSignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasDone() => $_has(6);
  @$pb.TagNumber(7)
  void clearDone() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get phase => $_getSZ(7);
  @$pb.TagNumber(8)
  set phase($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasPhase() => $_has(7);
  @$pb.TagNumber(8)
  void clearPhase() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get error => $_getSZ(8);
  @$pb.TagNumber(9)
  set error($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasError() => $_has(8);
  @$pb.TagNumber(9)
  void clearError() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get statsJson => $_getSZ(9);
  @$pb.TagNumber(10)
  set statsJson($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasStatsJson() => $_has(9);
  @$pb.TagNumber(10)
  void clearStatsJson() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.int get problemCount => $_getIZ(10);
  @$pb.TagNumber(11)
  set problemCount($core.int value) => $_setSignedInt32(10, value);
  @$pb.TagNumber(11)
  $core.bool hasProblemCount() => $_has(10);
  @$pb.TagNumber(11)
  void clearProblemCount() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.String get createdAt => $_getSZ(11);
  @$pb.TagNumber(12)
  set createdAt($core.String value) => $_setString(11, value);
  @$pb.TagNumber(12)
  $core.bool hasCreatedAt() => $_has(11);
  @$pb.TagNumber(12)
  void clearCreatedAt() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.String get startedAt => $_getSZ(12);
  @$pb.TagNumber(13)
  set startedAt($core.String value) => $_setString(12, value);
  @$pb.TagNumber(13)
  $core.bool hasStartedAt() => $_has(12);
  @$pb.TagNumber(13)
  void clearStartedAt() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.String get finishedAt => $_getSZ(13);
  @$pb.TagNumber(14)
  set finishedAt($core.String value) => $_setString(13, value);
  @$pb.TagNumber(14)
  $core.bool hasFinishedAt() => $_has(13);
  @$pb.TagNumber(14)
  void clearFinishedAt() => $_clearField(14);

  @$pb.TagNumber(15)
  $core.int get version => $_getIZ(14);
  @$pb.TagNumber(15)
  set version($core.int value) => $_setSignedInt32(14, value);
  @$pb.TagNumber(15)
  $core.bool hasVersion() => $_has(14);
  @$pb.TagNumber(15)
  void clearVersion() => $_clearField(15);
}

class Placeholder extends $pb.GeneratedMessage {
  factory Placeholder({
    $core.String? id,
    $core.String? name,
    $core.String? email,
    $core.int? tasks,
  }) {
    final result = Placeholder._();
    if (id != null) result.id = id;
    if (name != null) result.name = name;
    if (email != null) result.email = email;
    if (tasks != null) result.tasks = tasks;
    return result;
  }

  Placeholder._();

  factory Placeholder.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Placeholder()..mergeFromBuffer(data, registry);
  factory Placeholder.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Placeholder()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Placeholder',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.imports'),
      createEmptyInstance: Placeholder.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOS(3, _omitFieldNames ? '' : 'email')
    ..aI(4, _omitFieldNames ? '' : 'tasks')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Placeholder clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Placeholder copyWith(void Function(Placeholder) updates) =>
      super.copyWith((message) => updates(message as Placeholder))
          as Placeholder;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Placeholder() / Placeholder.new instead')
  static Placeholder create() => Placeholder._();
  static $pb.GeneratedMessage $_createMessage() => Placeholder._();
  @$core.override
  Placeholder createEmptyInstance() => Placeholder._();
  @$core.pragma('dart2js:noInline')
  static Placeholder getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Placeholder>(
          Placeholder.$_createMessage);
  static Placeholder? _defaultInstance;

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
  $core.String get email => $_getSZ(2);
  @$pb.TagNumber(3)
  set email($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasEmail() => $_has(2);
  @$pb.TagNumber(3)
  void clearEmail() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get tasks => $_getIZ(3);
  @$pb.TagNumber(4)
  set tasks($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasTasks() => $_has(3);
  @$pb.TagNumber(4)
  void clearTasks() => $_clearField(4);
}

class PlaceholderClaimRequest extends $pb.GeneratedMessage {
  factory PlaceholderClaimRequest({
    $core.String? workspaceId,
    $core.String? placeholderId,
    $core.String? userId,
  }) {
    final result = PlaceholderClaimRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (placeholderId != null) result.placeholderId = placeholderId;
    if (userId != null) result.userId = userId;
    return result;
  }

  PlaceholderClaimRequest._();

  factory PlaceholderClaimRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PlaceholderClaimRequest()..mergeFromBuffer(data, registry);
  factory PlaceholderClaimRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PlaceholderClaimRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PlaceholderClaimRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.imports'),
      createEmptyInstance: PlaceholderClaimRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'placeholderId')
    ..aOS(3, _omitFieldNames ? '' : 'userId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PlaceholderClaimRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PlaceholderClaimRequest copyWith(
          void Function(PlaceholderClaimRequest) updates) =>
      super.copyWith((message) => updates(message as PlaceholderClaimRequest))
          as PlaceholderClaimRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use PlaceholderClaimRequest() / PlaceholderClaimRequest.new instead')
  static PlaceholderClaimRequest create() => PlaceholderClaimRequest._();
  static $pb.GeneratedMessage $_createMessage() => PlaceholderClaimRequest._();
  @$core.override
  PlaceholderClaimRequest createEmptyInstance() => PlaceholderClaimRequest._();
  @$core.pragma('dart2js:noInline')
  static PlaceholderClaimRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PlaceholderClaimRequest>(
          PlaceholderClaimRequest.$_createMessage);
  static PlaceholderClaimRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get placeholderId => $_getSZ(1);
  @$pb.TagNumber(2)
  set placeholderId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPlaceholderId() => $_has(1);
  @$pb.TagNumber(2)
  void clearPlaceholderId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get userId => $_getSZ(2);
  @$pb.TagNumber(3)
  set userId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasUserId() => $_has(2);
  @$pb.TagNumber(3)
  void clearUserId() => $_clearField(3);
}

class PlaceholderClaimed extends $pb.GeneratedMessage {
  factory PlaceholderClaimed({
    $core.int? assigned,
  }) {
    final result = PlaceholderClaimed._();
    if (assigned != null) result.assigned = assigned;
    return result;
  }

  PlaceholderClaimed._();

  factory PlaceholderClaimed.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PlaceholderClaimed()..mergeFromBuffer(data, registry);
  factory PlaceholderClaimed.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PlaceholderClaimed()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PlaceholderClaimed',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.imports'),
      createEmptyInstance: PlaceholderClaimed.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'assigned')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PlaceholderClaimed clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PlaceholderClaimed copyWith(void Function(PlaceholderClaimed) updates) =>
      super.copyWith((message) => updates(message as PlaceholderClaimed))
          as PlaceholderClaimed;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use PlaceholderClaimed() / PlaceholderClaimed.new instead')
  static PlaceholderClaimed create() => PlaceholderClaimed._();
  static $pb.GeneratedMessage $_createMessage() => PlaceholderClaimed._();
  @$core.override
  PlaceholderClaimed createEmptyInstance() => PlaceholderClaimed._();
  @$core.pragma('dart2js:noInline')
  static PlaceholderClaimed getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PlaceholderClaimed>(
          PlaceholderClaimed.$_createMessage);
  static PlaceholderClaimed? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get assigned => $_getIZ(0);
  @$pb.TagNumber(1)
  set assigned($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAssigned() => $_has(0);
  @$pb.TagNumber(1)
  void clearAssigned() => $_clearField(1);
}

class PlaceholderList extends $pb.GeneratedMessage {
  factory PlaceholderList({
    $core.Iterable<Placeholder>? placeholders,
  }) {
    final result = PlaceholderList._();
    if (placeholders != null) result.placeholders.addAll(placeholders);
    return result;
  }

  PlaceholderList._();

  factory PlaceholderList.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PlaceholderList()..mergeFromBuffer(data, registry);
  factory PlaceholderList.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PlaceholderList()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PlaceholderList',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.imports'),
      createEmptyInstance: PlaceholderList.$_createMessage)
    ..pPM<Placeholder>(1, _omitFieldNames ? '' : 'placeholders',
        subBuilder: Placeholder.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PlaceholderList clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PlaceholderList copyWith(void Function(PlaceholderList) updates) =>
      super.copyWith((message) => updates(message as PlaceholderList))
          as PlaceholderList;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use PlaceholderList() / PlaceholderList.new instead')
  static PlaceholderList create() => PlaceholderList._();
  static $pb.GeneratedMessage $_createMessage() => PlaceholderList._();
  @$core.override
  PlaceholderList createEmptyInstance() => PlaceholderList._();
  @$core.pragma('dart2js:noInline')
  static PlaceholderList getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PlaceholderList>(
          PlaceholderList.$_createMessage);
  static PlaceholderList? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Placeholder> get placeholders => $_getList(0);
}

class PlaceholderListRequest extends $pb.GeneratedMessage {
  factory PlaceholderListRequest({
    $core.String? workspaceId,
  }) {
    final result = PlaceholderListRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    return result;
  }

  PlaceholderListRequest._();

  factory PlaceholderListRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PlaceholderListRequest()..mergeFromBuffer(data, registry);
  factory PlaceholderListRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PlaceholderListRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PlaceholderListRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.imports'),
      createEmptyInstance: PlaceholderListRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PlaceholderListRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PlaceholderListRequest copyWith(
          void Function(PlaceholderListRequest) updates) =>
      super.copyWith((message) => updates(message as PlaceholderListRequest))
          as PlaceholderListRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use PlaceholderListRequest() / PlaceholderListRequest.new instead')
  static PlaceholderListRequest create() => PlaceholderListRequest._();
  static $pb.GeneratedMessage $_createMessage() => PlaceholderListRequest._();
  @$core.override
  PlaceholderListRequest createEmptyInstance() => PlaceholderListRequest._();
  @$core.pragma('dart2js:noInline')
  static PlaceholderListRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PlaceholderListRequest>(
          PlaceholderListRequest.$_createMessage);
  static PlaceholderListRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);
}

class Problem extends $pb.GeneratedMessage {
  factory Problem({
    $core.int? line,
    $core.String? message,
    $core.String? level,
  }) {
    final result = Problem._();
    if (line != null) result.line = line;
    if (message != null) result.message = message;
    if (level != null) result.level = level;
    return result;
  }

  Problem._();

  factory Problem.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Problem()..mergeFromBuffer(data, registry);
  factory Problem.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Problem()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Problem',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.imports'),
      createEmptyInstance: Problem.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'line')
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..aOS(3, _omitFieldNames ? '' : 'level')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Problem clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Problem copyWith(void Function(Problem) updates) =>
      super.copyWith((message) => updates(message as Problem)) as Problem;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Problem() / Problem.new instead')
  static Problem create() => Problem._();
  static $pb.GeneratedMessage $_createMessage() => Problem._();
  @$core.override
  Problem createEmptyInstance() => Problem._();
  @$core.pragma('dart2js:noInline')
  static Problem getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Problem>(Problem.$_createMessage);
  static Problem? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get line => $_getIZ(0);
  @$pb.TagNumber(1)
  set line($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasLine() => $_has(0);
  @$pb.TagNumber(1)
  void clearLine() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get level => $_getSZ(2);
  @$pb.TagNumber(3)
  set level($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasLevel() => $_has(2);
  @$pb.TagNumber(3)
  void clearLevel() => $_clearField(3);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
