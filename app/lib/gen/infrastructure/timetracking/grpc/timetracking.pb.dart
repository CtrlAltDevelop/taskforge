// This is a generated file - do not edit.
//
// Generated from infrastructure/timetracking/grpc/timetracking.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class EntriesRequest extends $pb.GeneratedMessage {
  factory EntriesRequest({
    $core.String? workspaceId,
    $core.String? projectId,
    $core.String? taskId,
  }) {
    final result = EntriesRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (projectId != null) result.projectId = projectId;
    if (taskId != null) result.taskId = taskId;
    return result;
  }

  EntriesRequest._();

  factory EntriesRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      EntriesRequest()..mergeFromBuffer(data, registry);
  factory EntriesRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      EntriesRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'EntriesRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.timetracking'),
      createEmptyInstance: EntriesRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..aOS(3, _omitFieldNames ? '' : 'taskId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EntriesRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EntriesRequest copyWith(void Function(EntriesRequest) updates) =>
      super.copyWith((message) => updates(message as EntriesRequest))
          as EntriesRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use EntriesRequest() / EntriesRequest.new instead')
  static EntriesRequest create() => EntriesRequest._();
  static $pb.GeneratedMessage $_createMessage() => EntriesRequest._();
  @$core.override
  EntriesRequest createEmptyInstance() => EntriesRequest._();
  @$core.pragma('dart2js:noInline')
  static EntriesRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<EntriesRequest>(
          EntriesRequest.$_createMessage);
  static EntriesRequest? _defaultInstance;

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

class Entry extends $pb.GeneratedMessage {
  factory Entry({
    $core.String? id,
    $core.String? workspaceId,
    $core.String? taskId,
    $core.String? projectId,
    $core.String? key,
    $core.String? title,
    $core.String? userId,
    $core.String? userName,
    $core.String? startedAt,
    $core.String? endedAt,
    $core.int? durationSec,
    $core.String? note,
    $core.bool? billable,
    $core.String? source,
    $core.Iterable<$core.String>? flags,
  }) {
    final result = Entry._();
    if (id != null) result.id = id;
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (taskId != null) result.taskId = taskId;
    if (projectId != null) result.projectId = projectId;
    if (key != null) result.key = key;
    if (title != null) result.title = title;
    if (userId != null) result.userId = userId;
    if (userName != null) result.userName = userName;
    if (startedAt != null) result.startedAt = startedAt;
    if (endedAt != null) result.endedAt = endedAt;
    if (durationSec != null) result.durationSec = durationSec;
    if (note != null) result.note = note;
    if (billable != null) result.billable = billable;
    if (source != null) result.source = source;
    if (flags != null) result.flags.addAll(flags);
    return result;
  }

  Entry._();

  factory Entry.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Entry()..mergeFromBuffer(data, registry);
  factory Entry.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Entry()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Entry',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.timetracking'),
      createEmptyInstance: Entry.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(3, _omitFieldNames ? '' : 'taskId')
    ..aOS(4, _omitFieldNames ? '' : 'projectId')
    ..aOS(5, _omitFieldNames ? '' : 'key')
    ..aOS(6, _omitFieldNames ? '' : 'title')
    ..aOS(7, _omitFieldNames ? '' : 'userId')
    ..aOS(8, _omitFieldNames ? '' : 'userName')
    ..aOS(9, _omitFieldNames ? '' : 'startedAt')
    ..aOS(10, _omitFieldNames ? '' : 'endedAt')
    ..aI(11, _omitFieldNames ? '' : 'durationSec')
    ..aOS(12, _omitFieldNames ? '' : 'note')
    ..aOB(13, _omitFieldNames ? '' : 'billable')
    ..aOS(14, _omitFieldNames ? '' : 'source')
    ..pPS(15, _omitFieldNames ? '' : 'flags')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Entry clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Entry copyWith(void Function(Entry) updates) =>
      super.copyWith((message) => updates(message as Entry)) as Entry;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Entry() / Entry.new instead')
  static Entry create() => Entry._();
  static $pb.GeneratedMessage $_createMessage() => Entry._();
  @$core.override
  Entry createEmptyInstance() => Entry._();
  @$core.pragma('dart2js:noInline')
  static Entry getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Entry>(Entry.$_createMessage);
  static Entry? _defaultInstance;

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
  $core.String get taskId => $_getSZ(2);
  @$pb.TagNumber(3)
  set taskId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTaskId() => $_has(2);
  @$pb.TagNumber(3)
  void clearTaskId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get projectId => $_getSZ(3);
  @$pb.TagNumber(4)
  set projectId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasProjectId() => $_has(3);
  @$pb.TagNumber(4)
  void clearProjectId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get key => $_getSZ(4);
  @$pb.TagNumber(5)
  set key($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasKey() => $_has(4);
  @$pb.TagNumber(5)
  void clearKey() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get title => $_getSZ(5);
  @$pb.TagNumber(6)
  set title($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasTitle() => $_has(5);
  @$pb.TagNumber(6)
  void clearTitle() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get userId => $_getSZ(6);
  @$pb.TagNumber(7)
  set userId($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasUserId() => $_has(6);
  @$pb.TagNumber(7)
  void clearUserId() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get userName => $_getSZ(7);
  @$pb.TagNumber(8)
  set userName($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasUserName() => $_has(7);
  @$pb.TagNumber(8)
  void clearUserName() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get startedAt => $_getSZ(8);
  @$pb.TagNumber(9)
  set startedAt($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasStartedAt() => $_has(8);
  @$pb.TagNumber(9)
  void clearStartedAt() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get endedAt => $_getSZ(9);
  @$pb.TagNumber(10)
  set endedAt($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasEndedAt() => $_has(9);
  @$pb.TagNumber(10)
  void clearEndedAt() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.int get durationSec => $_getIZ(10);
  @$pb.TagNumber(11)
  set durationSec($core.int value) => $_setSignedInt32(10, value);
  @$pb.TagNumber(11)
  $core.bool hasDurationSec() => $_has(10);
  @$pb.TagNumber(11)
  void clearDurationSec() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.String get note => $_getSZ(11);
  @$pb.TagNumber(12)
  set note($core.String value) => $_setString(11, value);
  @$pb.TagNumber(12)
  $core.bool hasNote() => $_has(11);
  @$pb.TagNumber(12)
  void clearNote() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.bool get billable => $_getBF(12);
  @$pb.TagNumber(13)
  set billable($core.bool value) => $_setBool(12, value);
  @$pb.TagNumber(13)
  $core.bool hasBillable() => $_has(12);
  @$pb.TagNumber(13)
  void clearBillable() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.String get source => $_getSZ(13);
  @$pb.TagNumber(14)
  set source($core.String value) => $_setString(13, value);
  @$pb.TagNumber(14)
  $core.bool hasSource() => $_has(13);
  @$pb.TagNumber(14)
  void clearSource() => $_clearField(14);

  @$pb.TagNumber(15)
  $pb.PbList<$core.String> get flags => $_getList(14);
}

class EntryCreateRequest extends $pb.GeneratedMessage {
  factory EntryCreateRequest({
    $core.String? workspaceId,
    $core.String? projectId,
    $core.String? taskId,
    $core.String? startedAt,
    $core.int? durationSec,
    $core.String? note,
    $core.bool? billable,
    $core.String? forUserId,
  }) {
    final result = EntryCreateRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (projectId != null) result.projectId = projectId;
    if (taskId != null) result.taskId = taskId;
    if (startedAt != null) result.startedAt = startedAt;
    if (durationSec != null) result.durationSec = durationSec;
    if (note != null) result.note = note;
    if (billable != null) result.billable = billable;
    if (forUserId != null) result.forUserId = forUserId;
    return result;
  }

  EntryCreateRequest._();

  factory EntryCreateRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      EntryCreateRequest()..mergeFromBuffer(data, registry);
  factory EntryCreateRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      EntryCreateRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'EntryCreateRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.timetracking'),
      createEmptyInstance: EntryCreateRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..aOS(3, _omitFieldNames ? '' : 'taskId')
    ..aOS(4, _omitFieldNames ? '' : 'startedAt')
    ..aI(5, _omitFieldNames ? '' : 'durationSec')
    ..aOS(6, _omitFieldNames ? '' : 'note')
    ..aOB(7, _omitFieldNames ? '' : 'billable')
    ..aOS(8, _omitFieldNames ? '' : 'forUserId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EntryCreateRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EntryCreateRequest copyWith(void Function(EntryCreateRequest) updates) =>
      super.copyWith((message) => updates(message as EntryCreateRequest))
          as EntryCreateRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use EntryCreateRequest() / EntryCreateRequest.new instead')
  static EntryCreateRequest create() => EntryCreateRequest._();
  static $pb.GeneratedMessage $_createMessage() => EntryCreateRequest._();
  @$core.override
  EntryCreateRequest createEmptyInstance() => EntryCreateRequest._();
  @$core.pragma('dart2js:noInline')
  static EntryCreateRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<EntryCreateRequest>(
          EntryCreateRequest.$_createMessage);
  static EntryCreateRequest? _defaultInstance;

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
  $core.String get startedAt => $_getSZ(3);
  @$pb.TagNumber(4)
  set startedAt($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasStartedAt() => $_has(3);
  @$pb.TagNumber(4)
  void clearStartedAt() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get durationSec => $_getIZ(4);
  @$pb.TagNumber(5)
  set durationSec($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasDurationSec() => $_has(4);
  @$pb.TagNumber(5)
  void clearDurationSec() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get note => $_getSZ(5);
  @$pb.TagNumber(6)
  set note($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasNote() => $_has(5);
  @$pb.TagNumber(6)
  void clearNote() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.bool get billable => $_getBF(6);
  @$pb.TagNumber(7)
  set billable($core.bool value) => $_setBool(6, value);
  @$pb.TagNumber(7)
  $core.bool hasBillable() => $_has(6);
  @$pb.TagNumber(7)
  void clearBillable() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get forUserId => $_getSZ(7);
  @$pb.TagNumber(8)
  set forUserId($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasForUserId() => $_has(7);
  @$pb.TagNumber(8)
  void clearForUserId() => $_clearField(8);
}

class EntryDeleteRequest extends $pb.GeneratedMessage {
  factory EntryDeleteRequest({
    $core.String? workspaceId,
    $core.String? id,
  }) {
    final result = EntryDeleteRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (id != null) result.id = id;
    return result;
  }

  EntryDeleteRequest._();

  factory EntryDeleteRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      EntryDeleteRequest()..mergeFromBuffer(data, registry);
  factory EntryDeleteRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      EntryDeleteRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'EntryDeleteRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.timetracking'),
      createEmptyInstance: EntryDeleteRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EntryDeleteRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EntryDeleteRequest copyWith(void Function(EntryDeleteRequest) updates) =>
      super.copyWith((message) => updates(message as EntryDeleteRequest))
          as EntryDeleteRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use EntryDeleteRequest() / EntryDeleteRequest.new instead')
  static EntryDeleteRequest create() => EntryDeleteRequest._();
  static $pb.GeneratedMessage $_createMessage() => EntryDeleteRequest._();
  @$core.override
  EntryDeleteRequest createEmptyInstance() => EntryDeleteRequest._();
  @$core.pragma('dart2js:noInline')
  static EntryDeleteRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<EntryDeleteRequest>(
          EntryDeleteRequest.$_createMessage);
  static EntryDeleteRequest? _defaultInstance;

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

class EntryDeleted extends $pb.GeneratedMessage {
  factory EntryDeleted({
    $core.bool? ok,
  }) {
    final result = EntryDeleted._();
    if (ok != null) result.ok = ok;
    return result;
  }

  EntryDeleted._();

  factory EntryDeleted.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      EntryDeleted()..mergeFromBuffer(data, registry);
  factory EntryDeleted.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      EntryDeleted()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'EntryDeleted',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.timetracking'),
      createEmptyInstance: EntryDeleted.$_createMessage)
    ..aOB(1, _omitFieldNames ? '' : 'ok')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EntryDeleted clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EntryDeleted copyWith(void Function(EntryDeleted) updates) =>
      super.copyWith((message) => updates(message as EntryDeleted))
          as EntryDeleted;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use EntryDeleted() / EntryDeleted.new instead')
  static EntryDeleted create() => EntryDeleted._();
  static $pb.GeneratedMessage $_createMessage() => EntryDeleted._();
  @$core.override
  EntryDeleted createEmptyInstance() => EntryDeleted._();
  @$core.pragma('dart2js:noInline')
  static EntryDeleted getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<EntryDeleted>(
          EntryDeleted.$_createMessage);
  static EntryDeleted? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get ok => $_getBF(0);
  @$pb.TagNumber(1)
  set ok($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasOk() => $_has(0);
  @$pb.TagNumber(1)
  void clearOk() => $_clearField(1);
}

class EntryList extends $pb.GeneratedMessage {
  factory EntryList({
    $core.Iterable<Entry>? entries,
  }) {
    final result = EntryList._();
    if (entries != null) result.entries.addAll(entries);
    return result;
  }

  EntryList._();

  factory EntryList.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      EntryList()..mergeFromBuffer(data, registry);
  factory EntryList.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      EntryList()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'EntryList',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.timetracking'),
      createEmptyInstance: EntryList.$_createMessage)
    ..pPM<Entry>(1, _omitFieldNames ? '' : 'entries',
        subBuilder: Entry.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EntryList clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EntryList copyWith(void Function(EntryList) updates) =>
      super.copyWith((message) => updates(message as EntryList)) as EntryList;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use EntryList() / EntryList.new instead')
  static EntryList create() => EntryList._();
  static $pb.GeneratedMessage $_createMessage() => EntryList._();
  @$core.override
  EntryList createEmptyInstance() => EntryList._();
  @$core.pragma('dart2js:noInline')
  static EntryList getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<EntryList>(EntryList.$_createMessage);
  static EntryList? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Entry> get entries => $_getList(0);
}

class EntryUpdateRequest extends $pb.GeneratedMessage {
  factory EntryUpdateRequest({
    $core.String? workspaceId,
    $core.String? id,
    $core.Iterable<$core.String>? fields,
    $core.String? startedAt,
    $core.int? durationSec,
    $core.String? note,
    $core.bool? billable,
  }) {
    final result = EntryUpdateRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (id != null) result.id = id;
    if (fields != null) result.fields.addAll(fields);
    if (startedAt != null) result.startedAt = startedAt;
    if (durationSec != null) result.durationSec = durationSec;
    if (note != null) result.note = note;
    if (billable != null) result.billable = billable;
    return result;
  }

  EntryUpdateRequest._();

  factory EntryUpdateRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      EntryUpdateRequest()..mergeFromBuffer(data, registry);
  factory EntryUpdateRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      EntryUpdateRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'EntryUpdateRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.timetracking'),
      createEmptyInstance: EntryUpdateRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'id')
    ..pPS(3, _omitFieldNames ? '' : 'fields')
    ..aOS(4, _omitFieldNames ? '' : 'startedAt')
    ..aI(5, _omitFieldNames ? '' : 'durationSec')
    ..aOS(6, _omitFieldNames ? '' : 'note')
    ..aOB(7, _omitFieldNames ? '' : 'billable')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EntryUpdateRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EntryUpdateRequest copyWith(void Function(EntryUpdateRequest) updates) =>
      super.copyWith((message) => updates(message as EntryUpdateRequest))
          as EntryUpdateRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use EntryUpdateRequest() / EntryUpdateRequest.new instead')
  static EntryUpdateRequest create() => EntryUpdateRequest._();
  static $pb.GeneratedMessage $_createMessage() => EntryUpdateRequest._();
  @$core.override
  EntryUpdateRequest createEmptyInstance() => EntryUpdateRequest._();
  @$core.pragma('dart2js:noInline')
  static EntryUpdateRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<EntryUpdateRequest>(
          EntryUpdateRequest.$_createMessage);
  static EntryUpdateRequest? _defaultInstance;

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
  $pb.PbList<$core.String> get fields => $_getList(2);

  @$pb.TagNumber(4)
  $core.String get startedAt => $_getSZ(3);
  @$pb.TagNumber(4)
  set startedAt($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasStartedAt() => $_has(3);
  @$pb.TagNumber(4)
  void clearStartedAt() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get durationSec => $_getIZ(4);
  @$pb.TagNumber(5)
  set durationSec($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasDurationSec() => $_has(4);
  @$pb.TagNumber(5)
  void clearDurationSec() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get note => $_getSZ(5);
  @$pb.TagNumber(6)
  set note($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasNote() => $_has(5);
  @$pb.TagNumber(6)
  void clearNote() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.bool get billable => $_getBF(6);
  @$pb.TagNumber(7)
  set billable($core.bool value) => $_setBool(6, value);
  @$pb.TagNumber(7)
  $core.bool hasBillable() => $_has(6);
  @$pb.TagNumber(7)
  void clearBillable() => $_clearField(7);
}

class EstimateSet extends $pb.GeneratedMessage {
  factory EstimateSet({
    $core.int? estimateSec,
  }) {
    final result = EstimateSet._();
    if (estimateSec != null) result.estimateSec = estimateSec;
    return result;
  }

  EstimateSet._();

  factory EstimateSet.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      EstimateSet()..mergeFromBuffer(data, registry);
  factory EstimateSet.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      EstimateSet()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'EstimateSet',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.timetracking'),
      createEmptyInstance: EstimateSet.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'estimateSec')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EstimateSet clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EstimateSet copyWith(void Function(EstimateSet) updates) =>
      super.copyWith((message) => updates(message as EstimateSet))
          as EstimateSet;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use EstimateSet() / EstimateSet.new instead')
  static EstimateSet create() => EstimateSet._();
  static $pb.GeneratedMessage $_createMessage() => EstimateSet._();
  @$core.override
  EstimateSet createEmptyInstance() => EstimateSet._();
  @$core.pragma('dart2js:noInline')
  static EstimateSet getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<EstimateSet>(
          EstimateSet.$_createMessage);
  static EstimateSet? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get estimateSec => $_getIZ(0);
  @$pb.TagNumber(1)
  set estimateSec($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasEstimateSec() => $_has(0);
  @$pb.TagNumber(1)
  void clearEstimateSec() => $_clearField(1);
}

class EstimateSetRequest extends $pb.GeneratedMessage {
  factory EstimateSetRequest({
    $core.String? workspaceId,
    $core.String? projectId,
    $core.String? taskId,
    $core.int? estimateSec,
    $core.int? expectedVersion,
  }) {
    final result = EstimateSetRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (projectId != null) result.projectId = projectId;
    if (taskId != null) result.taskId = taskId;
    if (estimateSec != null) result.estimateSec = estimateSec;
    if (expectedVersion != null) result.expectedVersion = expectedVersion;
    return result;
  }

  EstimateSetRequest._();

  factory EstimateSetRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      EstimateSetRequest()..mergeFromBuffer(data, registry);
  factory EstimateSetRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      EstimateSetRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'EstimateSetRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.timetracking'),
      createEmptyInstance: EstimateSetRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..aOS(3, _omitFieldNames ? '' : 'taskId')
    ..aI(4, _omitFieldNames ? '' : 'estimateSec')
    ..aI(5, _omitFieldNames ? '' : 'expectedVersion')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EstimateSetRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EstimateSetRequest copyWith(void Function(EstimateSetRequest) updates) =>
      super.copyWith((message) => updates(message as EstimateSetRequest))
          as EstimateSetRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use EstimateSetRequest() / EstimateSetRequest.new instead')
  static EstimateSetRequest create() => EstimateSetRequest._();
  static $pb.GeneratedMessage $_createMessage() => EstimateSetRequest._();
  @$core.override
  EstimateSetRequest createEmptyInstance() => EstimateSetRequest._();
  @$core.pragma('dart2js:noInline')
  static EstimateSetRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<EstimateSetRequest>(
          EstimateSetRequest.$_createMessage);
  static EstimateSetRequest? _defaultInstance;

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
  $core.int get estimateSec => $_getIZ(3);
  @$pb.TagNumber(4)
  set estimateSec($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasEstimateSec() => $_has(3);
  @$pb.TagNumber(4)
  void clearEstimateSec() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get expectedVersion => $_getIZ(4);
  @$pb.TagNumber(5)
  set expectedVersion($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasExpectedVersion() => $_has(4);
  @$pb.TagNumber(5)
  void clearExpectedVersion() => $_clearField(5);
}

class PersonTotal extends $pb.GeneratedMessage {
  factory PersonTotal({
    $core.String? userId,
    $core.String? name,
    $core.int? seconds,
    $core.int? billable,
  }) {
    final result = PersonTotal._();
    if (userId != null) result.userId = userId;
    if (name != null) result.name = name;
    if (seconds != null) result.seconds = seconds;
    if (billable != null) result.billable = billable;
    return result;
  }

  PersonTotal._();

  factory PersonTotal.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PersonTotal()..mergeFromBuffer(data, registry);
  factory PersonTotal.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PersonTotal()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PersonTotal',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.timetracking'),
      createEmptyInstance: PersonTotal.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'userId')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aI(3, _omitFieldNames ? '' : 'seconds')
    ..aI(4, _omitFieldNames ? '' : 'billable')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PersonTotal clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PersonTotal copyWith(void Function(PersonTotal) updates) =>
      super.copyWith((message) => updates(message as PersonTotal))
          as PersonTotal;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use PersonTotal() / PersonTotal.new instead')
  static PersonTotal create() => PersonTotal._();
  static $pb.GeneratedMessage $_createMessage() => PersonTotal._();
  @$core.override
  PersonTotal createEmptyInstance() => PersonTotal._();
  @$core.pragma('dart2js:noInline')
  static PersonTotal getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PersonTotal>(
          PersonTotal.$_createMessage);
  static PersonTotal? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get userId => $_getSZ(0);
  @$pb.TagNumber(1)
  set userId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get seconds => $_getIZ(2);
  @$pb.TagNumber(3)
  set seconds($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSeconds() => $_has(2);
  @$pb.TagNumber(3)
  void clearSeconds() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get billable => $_getIZ(3);
  @$pb.TagNumber(4)
  set billable($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasBillable() => $_has(3);
  @$pb.TagNumber(4)
  void clearBillable() => $_clearField(4);
}

class SheetRow extends $pb.GeneratedMessage {
  factory SheetRow({
    $core.String? taskId,
    $core.String? projectId,
    $core.String? key,
    $core.String? title,
    $core.Iterable<$core.int>? seconds,
    $core.int? total,
    $core.int? billable,
  }) {
    final result = SheetRow._();
    if (taskId != null) result.taskId = taskId;
    if (projectId != null) result.projectId = projectId;
    if (key != null) result.key = key;
    if (title != null) result.title = title;
    if (seconds != null) result.seconds.addAll(seconds);
    if (total != null) result.total = total;
    if (billable != null) result.billable = billable;
    return result;
  }

  SheetRow._();

  factory SheetRow.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SheetRow()..mergeFromBuffer(data, registry);
  factory SheetRow.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SheetRow()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SheetRow',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.timetracking'),
      createEmptyInstance: SheetRow.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'taskId')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..aOS(3, _omitFieldNames ? '' : 'key')
    ..aOS(4, _omitFieldNames ? '' : 'title')
    ..p<$core.int>(5, _omitFieldNames ? '' : 'seconds', $pb.PbFieldType.K3)
    ..aI(6, _omitFieldNames ? '' : 'total')
    ..aI(7, _omitFieldNames ? '' : 'billable')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SheetRow clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SheetRow copyWith(void Function(SheetRow) updates) =>
      super.copyWith((message) => updates(message as SheetRow)) as SheetRow;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SheetRow() / SheetRow.new instead')
  static SheetRow create() => SheetRow._();
  static $pb.GeneratedMessage $_createMessage() => SheetRow._();
  @$core.override
  SheetRow createEmptyInstance() => SheetRow._();
  @$core.pragma('dart2js:noInline')
  static SheetRow getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SheetRow>(SheetRow.$_createMessage);
  static SheetRow? _defaultInstance;

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
  $core.String get key => $_getSZ(2);
  @$pb.TagNumber(3)
  set key($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasKey() => $_has(2);
  @$pb.TagNumber(3)
  void clearKey() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get title => $_getSZ(3);
  @$pb.TagNumber(4)
  set title($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasTitle() => $_has(3);
  @$pb.TagNumber(4)
  void clearTitle() => $_clearField(4);

  @$pb.TagNumber(5)
  $pb.PbList<$core.int> get seconds => $_getList(4);

  @$pb.TagNumber(6)
  $core.int get total => $_getIZ(5);
  @$pb.TagNumber(6)
  set total($core.int value) => $_setSignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasTotal() => $_has(5);
  @$pb.TagNumber(6)
  void clearTotal() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.int get billable => $_getIZ(6);
  @$pb.TagNumber(7)
  set billable($core.int value) => $_setSignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasBillable() => $_has(6);
  @$pb.TagNumber(7)
  void clearBillable() => $_clearField(7);
}

class TimeCurrentRequest extends $pb.GeneratedMessage {
  factory TimeCurrentRequest({
    $core.String? workspaceId,
  }) {
    final result = TimeCurrentRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    return result;
  }

  TimeCurrentRequest._();

  factory TimeCurrentRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TimeCurrentRequest()..mergeFromBuffer(data, registry);
  factory TimeCurrentRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TimeCurrentRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TimeCurrentRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.timetracking'),
      createEmptyInstance: TimeCurrentRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TimeCurrentRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TimeCurrentRequest copyWith(void Function(TimeCurrentRequest) updates) =>
      super.copyWith((message) => updates(message as TimeCurrentRequest))
          as TimeCurrentRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use TimeCurrentRequest() / TimeCurrentRequest.new instead')
  static TimeCurrentRequest create() => TimeCurrentRequest._();
  static $pb.GeneratedMessage $_createMessage() => TimeCurrentRequest._();
  @$core.override
  TimeCurrentRequest createEmptyInstance() => TimeCurrentRequest._();
  @$core.pragma('dart2js:noInline')
  static TimeCurrentRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TimeCurrentRequest>(
          TimeCurrentRequest.$_createMessage);
  static TimeCurrentRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);
}

class TimeStartRequest extends $pb.GeneratedMessage {
  factory TimeStartRequest({
    $core.String? workspaceId,
    $core.String? projectId,
    $core.String? taskId,
    $core.String? note,
  }) {
    final result = TimeStartRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (projectId != null) result.projectId = projectId;
    if (taskId != null) result.taskId = taskId;
    if (note != null) result.note = note;
    return result;
  }

  TimeStartRequest._();

  factory TimeStartRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TimeStartRequest()..mergeFromBuffer(data, registry);
  factory TimeStartRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TimeStartRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TimeStartRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.timetracking'),
      createEmptyInstance: TimeStartRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..aOS(3, _omitFieldNames ? '' : 'taskId')
    ..aOS(4, _omitFieldNames ? '' : 'note')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TimeStartRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TimeStartRequest copyWith(void Function(TimeStartRequest) updates) =>
      super.copyWith((message) => updates(message as TimeStartRequest))
          as TimeStartRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use TimeStartRequest() / TimeStartRequest.new instead')
  static TimeStartRequest create() => TimeStartRequest._();
  static $pb.GeneratedMessage $_createMessage() => TimeStartRequest._();
  @$core.override
  TimeStartRequest createEmptyInstance() => TimeStartRequest._();
  @$core.pragma('dart2js:noInline')
  static TimeStartRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TimeStartRequest>(
          TimeStartRequest.$_createMessage);
  static TimeStartRequest? _defaultInstance;

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
  $core.String get note => $_getSZ(3);
  @$pb.TagNumber(4)
  set note($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasNote() => $_has(3);
  @$pb.TagNumber(4)
  void clearNote() => $_clearField(4);
}

class TimeStopRequest extends $pb.GeneratedMessage {
  factory TimeStopRequest({
    $core.String? workspaceId,
  }) {
    final result = TimeStopRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    return result;
  }

  TimeStopRequest._();

  factory TimeStopRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TimeStopRequest()..mergeFromBuffer(data, registry);
  factory TimeStopRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TimeStopRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TimeStopRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.timetracking'),
      createEmptyInstance: TimeStopRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TimeStopRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TimeStopRequest copyWith(void Function(TimeStopRequest) updates) =>
      super.copyWith((message) => updates(message as TimeStopRequest))
          as TimeStopRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use TimeStopRequest() / TimeStopRequest.new instead')
  static TimeStopRequest create() => TimeStopRequest._();
  static $pb.GeneratedMessage $_createMessage() => TimeStopRequest._();
  @$core.override
  TimeStopRequest createEmptyInstance() => TimeStopRequest._();
  @$core.pragma('dart2js:noInline')
  static TimeStopRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TimeStopRequest>(
          TimeStopRequest.$_createMessage);
  static TimeStopRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);
}

class TimeSummary extends $pb.GeneratedMessage {
  factory TimeSummary({
    $core.int? estimateSec,
    $core.int? loggedSec,
    $core.int? billableSec,
    $core.bool? running,
  }) {
    final result = TimeSummary._();
    if (estimateSec != null) result.estimateSec = estimateSec;
    if (loggedSec != null) result.loggedSec = loggedSec;
    if (billableSec != null) result.billableSec = billableSec;
    if (running != null) result.running = running;
    return result;
  }

  TimeSummary._();

  factory TimeSummary.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TimeSummary()..mergeFromBuffer(data, registry);
  factory TimeSummary.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TimeSummary()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TimeSummary',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.timetracking'),
      createEmptyInstance: TimeSummary.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'estimateSec')
    ..aI(2, _omitFieldNames ? '' : 'loggedSec')
    ..aI(3, _omitFieldNames ? '' : 'billableSec')
    ..aOB(4, _omitFieldNames ? '' : 'running')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TimeSummary clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TimeSummary copyWith(void Function(TimeSummary) updates) =>
      super.copyWith((message) => updates(message as TimeSummary))
          as TimeSummary;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use TimeSummary() / TimeSummary.new instead')
  static TimeSummary create() => TimeSummary._();
  static $pb.GeneratedMessage $_createMessage() => TimeSummary._();
  @$core.override
  TimeSummary createEmptyInstance() => TimeSummary._();
  @$core.pragma('dart2js:noInline')
  static TimeSummary getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TimeSummary>(
          TimeSummary.$_createMessage);
  static TimeSummary? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get estimateSec => $_getIZ(0);
  @$pb.TagNumber(1)
  set estimateSec($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasEstimateSec() => $_has(0);
  @$pb.TagNumber(1)
  void clearEstimateSec() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get loggedSec => $_getIZ(1);
  @$pb.TagNumber(2)
  set loggedSec($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasLoggedSec() => $_has(1);
  @$pb.TagNumber(2)
  void clearLoggedSec() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get billableSec => $_getIZ(2);
  @$pb.TagNumber(3)
  set billableSec($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasBillableSec() => $_has(2);
  @$pb.TagNumber(3)
  void clearBillableSec() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get running => $_getBF(3);
  @$pb.TagNumber(4)
  set running($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasRunning() => $_has(3);
  @$pb.TagNumber(4)
  void clearRunning() => $_clearField(4);
}

class TimeSummaryRequest extends $pb.GeneratedMessage {
  factory TimeSummaryRequest({
    $core.String? workspaceId,
    $core.String? projectId,
    $core.String? taskId,
  }) {
    final result = TimeSummaryRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (projectId != null) result.projectId = projectId;
    if (taskId != null) result.taskId = taskId;
    return result;
  }

  TimeSummaryRequest._();

  factory TimeSummaryRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TimeSummaryRequest()..mergeFromBuffer(data, registry);
  factory TimeSummaryRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TimeSummaryRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TimeSummaryRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.timetracking'),
      createEmptyInstance: TimeSummaryRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..aOS(3, _omitFieldNames ? '' : 'taskId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TimeSummaryRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TimeSummaryRequest copyWith(void Function(TimeSummaryRequest) updates) =>
      super.copyWith((message) => updates(message as TimeSummaryRequest))
          as TimeSummaryRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use TimeSummaryRequest() / TimeSummaryRequest.new instead')
  static TimeSummaryRequest create() => TimeSummaryRequest._();
  static $pb.GeneratedMessage $_createMessage() => TimeSummaryRequest._();
  @$core.override
  TimeSummaryRequest createEmptyInstance() => TimeSummaryRequest._();
  @$core.pragma('dart2js:noInline')
  static TimeSummaryRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TimeSummaryRequest>(
          TimeSummaryRequest.$_createMessage);
  static TimeSummaryRequest? _defaultInstance;

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

class TimerStarted extends $pb.GeneratedMessage {
  factory TimerStarted({
    Entry? entry,
    Entry? stopped,
    $core.String? serverNow,
  }) {
    final result = TimerStarted._();
    if (entry != null) result.entry = entry;
    if (stopped != null) result.stopped = stopped;
    if (serverNow != null) result.serverNow = serverNow;
    return result;
  }

  TimerStarted._();

  factory TimerStarted.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TimerStarted()..mergeFromBuffer(data, registry);
  factory TimerStarted.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TimerStarted()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TimerStarted',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.timetracking'),
      createEmptyInstance: TimerStarted.$_createMessage)
    ..aOM<Entry>(1, _omitFieldNames ? '' : 'entry',
        subBuilder: Entry.$_createMessage)
    ..aOM<Entry>(2, _omitFieldNames ? '' : 'stopped',
        subBuilder: Entry.$_createMessage)
    ..aOS(3, _omitFieldNames ? '' : 'serverNow')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TimerStarted clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TimerStarted copyWith(void Function(TimerStarted) updates) =>
      super.copyWith((message) => updates(message as TimerStarted))
          as TimerStarted;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use TimerStarted() / TimerStarted.new instead')
  static TimerStarted create() => TimerStarted._();
  static $pb.GeneratedMessage $_createMessage() => TimerStarted._();
  @$core.override
  TimerStarted createEmptyInstance() => TimerStarted._();
  @$core.pragma('dart2js:noInline')
  static TimerStarted getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TimerStarted>(
          TimerStarted.$_createMessage);
  static TimerStarted? _defaultInstance;

  @$pb.TagNumber(1)
  Entry get entry => $_getN(0);
  @$pb.TagNumber(1)
  set entry(Entry value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasEntry() => $_has(0);
  @$pb.TagNumber(1)
  void clearEntry() => $_clearField(1);
  @$pb.TagNumber(1)
  Entry ensureEntry() => $_ensure(0);

  @$pb.TagNumber(2)
  Entry get stopped => $_getN(1);
  @$pb.TagNumber(2)
  set stopped(Entry value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasStopped() => $_has(1);
  @$pb.TagNumber(2)
  void clearStopped() => $_clearField(2);
  @$pb.TagNumber(2)
  Entry ensureStopped() => $_ensure(1);

  @$pb.TagNumber(3)
  $core.String get serverNow => $_getSZ(2);
  @$pb.TagNumber(3)
  set serverNow($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasServerNow() => $_has(2);
  @$pb.TagNumber(3)
  void clearServerNow() => $_clearField(3);
}

class TimerState extends $pb.GeneratedMessage {
  factory TimerState({
    $core.bool? running,
    Entry? entry,
    $core.String? serverNow,
  }) {
    final result = TimerState._();
    if (running != null) result.running = running;
    if (entry != null) result.entry = entry;
    if (serverNow != null) result.serverNow = serverNow;
    return result;
  }

  TimerState._();

  factory TimerState.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TimerState()..mergeFromBuffer(data, registry);
  factory TimerState.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TimerState()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TimerState',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.timetracking'),
      createEmptyInstance: TimerState.$_createMessage)
    ..aOB(1, _omitFieldNames ? '' : 'running')
    ..aOM<Entry>(2, _omitFieldNames ? '' : 'entry',
        subBuilder: Entry.$_createMessage)
    ..aOS(3, _omitFieldNames ? '' : 'serverNow')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TimerState clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TimerState copyWith(void Function(TimerState) updates) =>
      super.copyWith((message) => updates(message as TimerState)) as TimerState;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use TimerState() / TimerState.new instead')
  static TimerState create() => TimerState._();
  static $pb.GeneratedMessage $_createMessage() => TimerState._();
  @$core.override
  TimerState createEmptyInstance() => TimerState._();
  @$core.pragma('dart2js:noInline')
  static TimerState getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TimerState>(TimerState.$_createMessage);
  static TimerState? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get running => $_getBF(0);
  @$pb.TagNumber(1)
  set running($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRunning() => $_has(0);
  @$pb.TagNumber(1)
  void clearRunning() => $_clearField(1);

  @$pb.TagNumber(2)
  Entry get entry => $_getN(1);
  @$pb.TagNumber(2)
  set entry(Entry value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasEntry() => $_has(1);
  @$pb.TagNumber(2)
  void clearEntry() => $_clearField(2);
  @$pb.TagNumber(2)
  Entry ensureEntry() => $_ensure(1);

  @$pb.TagNumber(3)
  $core.String get serverNow => $_getSZ(2);
  @$pb.TagNumber(3)
  set serverNow($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasServerNow() => $_has(2);
  @$pb.TagNumber(3)
  void clearServerNow() => $_clearField(3);
}

class TimerStopped extends $pb.GeneratedMessage {
  factory TimerStopped({
    Entry? entry,
    $core.String? serverNow,
  }) {
    final result = TimerStopped._();
    if (entry != null) result.entry = entry;
    if (serverNow != null) result.serverNow = serverNow;
    return result;
  }

  TimerStopped._();

  factory TimerStopped.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TimerStopped()..mergeFromBuffer(data, registry);
  factory TimerStopped.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TimerStopped()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TimerStopped',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.timetracking'),
      createEmptyInstance: TimerStopped.$_createMessage)
    ..aOM<Entry>(1, _omitFieldNames ? '' : 'entry',
        subBuilder: Entry.$_createMessage)
    ..aOS(2, _omitFieldNames ? '' : 'serverNow')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TimerStopped clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TimerStopped copyWith(void Function(TimerStopped) updates) =>
      super.copyWith((message) => updates(message as TimerStopped))
          as TimerStopped;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use TimerStopped() / TimerStopped.new instead')
  static TimerStopped create() => TimerStopped._();
  static $pb.GeneratedMessage $_createMessage() => TimerStopped._();
  @$core.override
  TimerStopped createEmptyInstance() => TimerStopped._();
  @$core.pragma('dart2js:noInline')
  static TimerStopped getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TimerStopped>(
          TimerStopped.$_createMessage);
  static TimerStopped? _defaultInstance;

  @$pb.TagNumber(1)
  Entry get entry => $_getN(0);
  @$pb.TagNumber(1)
  set entry(Entry value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasEntry() => $_has(0);
  @$pb.TagNumber(1)
  void clearEntry() => $_clearField(1);
  @$pb.TagNumber(1)
  Entry ensureEntry() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.String get serverNow => $_getSZ(1);
  @$pb.TagNumber(2)
  set serverNow($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasServerNow() => $_has(1);
  @$pb.TagNumber(2)
  void clearServerNow() => $_clearField(2);
}

class TimesheetAnswer extends $pb.GeneratedMessage {
  factory TimesheetAnswer({
    $core.String? userId,
    $core.String? weekStart,
    $core.Iterable<SheetRow>? rows,
    $core.Iterable<$core.int>? dayTotals,
    $core.int? total,
  }) {
    final result = TimesheetAnswer._();
    if (userId != null) result.userId = userId;
    if (weekStart != null) result.weekStart = weekStart;
    if (rows != null) result.rows.addAll(rows);
    if (dayTotals != null) result.dayTotals.addAll(dayTotals);
    if (total != null) result.total = total;
    return result;
  }

  TimesheetAnswer._();

  factory TimesheetAnswer.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TimesheetAnswer()..mergeFromBuffer(data, registry);
  factory TimesheetAnswer.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TimesheetAnswer()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TimesheetAnswer',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.timetracking'),
      createEmptyInstance: TimesheetAnswer.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'userId')
    ..aOS(2, _omitFieldNames ? '' : 'weekStart')
    ..pPM<SheetRow>(3, _omitFieldNames ? '' : 'rows',
        subBuilder: SheetRow.$_createMessage)
    ..p<$core.int>(4, _omitFieldNames ? '' : 'dayTotals', $pb.PbFieldType.K3)
    ..aI(5, _omitFieldNames ? '' : 'total')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TimesheetAnswer clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TimesheetAnswer copyWith(void Function(TimesheetAnswer) updates) =>
      super.copyWith((message) => updates(message as TimesheetAnswer))
          as TimesheetAnswer;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use TimesheetAnswer() / TimesheetAnswer.new instead')
  static TimesheetAnswer create() => TimesheetAnswer._();
  static $pb.GeneratedMessage $_createMessage() => TimesheetAnswer._();
  @$core.override
  TimesheetAnswer createEmptyInstance() => TimesheetAnswer._();
  @$core.pragma('dart2js:noInline')
  static TimesheetAnswer getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TimesheetAnswer>(
          TimesheetAnswer.$_createMessage);
  static TimesheetAnswer? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get userId => $_getSZ(0);
  @$pb.TagNumber(1)
  set userId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get weekStart => $_getSZ(1);
  @$pb.TagNumber(2)
  set weekStart($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasWeekStart() => $_has(1);
  @$pb.TagNumber(2)
  void clearWeekStart() => $_clearField(2);

  @$pb.TagNumber(3)
  $pb.PbList<SheetRow> get rows => $_getList(2);

  @$pb.TagNumber(4)
  $pb.PbList<$core.int> get dayTotals => $_getList(3);

  @$pb.TagNumber(5)
  $core.int get total => $_getIZ(4);
  @$pb.TagNumber(5)
  set total($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasTotal() => $_has(4);
  @$pb.TagNumber(5)
  void clearTotal() => $_clearField(5);
}

class TimesheetRequest extends $pb.GeneratedMessage {
  factory TimesheetRequest({
    $core.String? workspaceId,
    $core.String? weekStart,
    $core.String? timezone,
    $core.String? userId,
    $core.int? utcOffsetMinutes,
  }) {
    final result = TimesheetRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (weekStart != null) result.weekStart = weekStart;
    if (timezone != null) result.timezone = timezone;
    if (userId != null) result.userId = userId;
    if (utcOffsetMinutes != null) result.utcOffsetMinutes = utcOffsetMinutes;
    return result;
  }

  TimesheetRequest._();

  factory TimesheetRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TimesheetRequest()..mergeFromBuffer(data, registry);
  factory TimesheetRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TimesheetRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TimesheetRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.timetracking'),
      createEmptyInstance: TimesheetRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'weekStart')
    ..aOS(3, _omitFieldNames ? '' : 'timezone')
    ..aOS(4, _omitFieldNames ? '' : 'userId')
    ..aI(5, _omitFieldNames ? '' : 'utcOffsetMinutes')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TimesheetRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TimesheetRequest copyWith(void Function(TimesheetRequest) updates) =>
      super.copyWith((message) => updates(message as TimesheetRequest))
          as TimesheetRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use TimesheetRequest() / TimesheetRequest.new instead')
  static TimesheetRequest create() => TimesheetRequest._();
  static $pb.GeneratedMessage $_createMessage() => TimesheetRequest._();
  @$core.override
  TimesheetRequest createEmptyInstance() => TimesheetRequest._();
  @$core.pragma('dart2js:noInline')
  static TimesheetRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TimesheetRequest>(
          TimesheetRequest.$_createMessage);
  static TimesheetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get weekStart => $_getSZ(1);
  @$pb.TagNumber(2)
  set weekStart($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasWeekStart() => $_has(1);
  @$pb.TagNumber(2)
  void clearWeekStart() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get timezone => $_getSZ(2);
  @$pb.TagNumber(3)
  set timezone($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTimezone() => $_has(2);
  @$pb.TagNumber(3)
  void clearTimezone() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get userId => $_getSZ(3);
  @$pb.TagNumber(4)
  set userId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasUserId() => $_has(3);
  @$pb.TagNumber(4)
  void clearUserId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get utcOffsetMinutes => $_getIZ(4);
  @$pb.TagNumber(5)
  set utcOffsetMinutes($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasUtcOffsetMinutes() => $_has(4);
  @$pb.TagNumber(5)
  void clearUtcOffsetMinutes() => $_clearField(5);
}

class TotalsAnswer extends $pb.GeneratedMessage {
  factory TotalsAnswer({
    $core.Iterable<PersonTotal>? people,
  }) {
    final result = TotalsAnswer._();
    if (people != null) result.people.addAll(people);
    return result;
  }

  TotalsAnswer._();

  factory TotalsAnswer.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TotalsAnswer()..mergeFromBuffer(data, registry);
  factory TotalsAnswer.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TotalsAnswer()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TotalsAnswer',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.timetracking'),
      createEmptyInstance: TotalsAnswer.$_createMessage)
    ..pPM<PersonTotal>(1, _omitFieldNames ? '' : 'people',
        subBuilder: PersonTotal.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TotalsAnswer clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TotalsAnswer copyWith(void Function(TotalsAnswer) updates) =>
      super.copyWith((message) => updates(message as TotalsAnswer))
          as TotalsAnswer;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use TotalsAnswer() / TotalsAnswer.new instead')
  static TotalsAnswer create() => TotalsAnswer._();
  static $pb.GeneratedMessage $_createMessage() => TotalsAnswer._();
  @$core.override
  TotalsAnswer createEmptyInstance() => TotalsAnswer._();
  @$core.pragma('dart2js:noInline')
  static TotalsAnswer getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TotalsAnswer>(
          TotalsAnswer.$_createMessage);
  static TotalsAnswer? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<PersonTotal> get people => $_getList(0);
}

class TotalsRequest extends $pb.GeneratedMessage {
  factory TotalsRequest({
    $core.String? workspaceId,
    $core.String? projectId,
    $core.String? start,
    $core.String? end,
  }) {
    final result = TotalsRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (projectId != null) result.projectId = projectId;
    if (start != null) result.start = start;
    if (end != null) result.end = end;
    return result;
  }

  TotalsRequest._();

  factory TotalsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TotalsRequest()..mergeFromBuffer(data, registry);
  factory TotalsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TotalsRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TotalsRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.timetracking'),
      createEmptyInstance: TotalsRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..aOS(3, _omitFieldNames ? '' : 'start')
    ..aOS(4, _omitFieldNames ? '' : 'end')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TotalsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TotalsRequest copyWith(void Function(TotalsRequest) updates) =>
      super.copyWith((message) => updates(message as TotalsRequest))
          as TotalsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use TotalsRequest() / TotalsRequest.new instead')
  static TotalsRequest create() => TotalsRequest._();
  static $pb.GeneratedMessage $_createMessage() => TotalsRequest._();
  @$core.override
  TotalsRequest createEmptyInstance() => TotalsRequest._();
  @$core.pragma('dart2js:noInline')
  static TotalsRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TotalsRequest>(
          TotalsRequest.$_createMessage);
  static TotalsRequest? _defaultInstance;

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
  $core.String get start => $_getSZ(2);
  @$pb.TagNumber(3)
  set start($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasStart() => $_has(2);
  @$pb.TagNumber(3)
  void clearStart() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get end => $_getSZ(3);
  @$pb.TagNumber(4)
  set end($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasEnd() => $_has(3);
  @$pb.TagNumber(4)
  void clearEnd() => $_clearField(4);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
