// This is a generated file - do not edit.
//
// Generated from infrastructure/system/grpc/system.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class SystemInfo extends $pb.GeneratedMessage {
  factory SystemInfo({
    $core.String? version,
    $core.String? minClientVersion,
    $core.String? api,
    $core.String? commit,
    $core.String? redis,
    $core.String? broker,
    $core.bool? eager,
    $core.int? workers,
    $core.Iterable<$core.MapEntry<$core.String, $core.int>>? backlog,
  }) {
    final result = SystemInfo._();
    if (version != null) result.version = version;
    if (minClientVersion != null) result.minClientVersion = minClientVersion;
    if (api != null) result.api = api;
    if (commit != null) result.commit = commit;
    if (redis != null) result.redis = redis;
    if (broker != null) result.broker = broker;
    if (eager != null) result.eager = eager;
    if (workers != null) result.workers = workers;
    if (backlog != null) result.backlog.addEntries(backlog);
    return result;
  }

  SystemInfo._();

  factory SystemInfo.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SystemInfo()..mergeFromBuffer(data, registry);
  factory SystemInfo.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SystemInfo()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SystemInfo',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.system'),
      createEmptyInstance: SystemInfo.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'version')
    ..aOS(2, _omitFieldNames ? '' : 'minClientVersion')
    ..aOS(3, _omitFieldNames ? '' : 'api')
    ..aOS(4, _omitFieldNames ? '' : 'commit')
    ..aOS(5, _omitFieldNames ? '' : 'redis')
    ..aOS(6, _omitFieldNames ? '' : 'broker')
    ..aOB(7, _omitFieldNames ? '' : 'eager')
    ..aI(8, _omitFieldNames ? '' : 'workers')
    ..m<$core.String, $core.int>(9, _omitFieldNames ? '' : 'backlog',
        entryClassName: 'SystemInfo.BacklogEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.O3,
        packageName: const $pb.PackageName('config.system'))
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SystemInfo clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SystemInfo copyWith(void Function(SystemInfo) updates) =>
      super.copyWith((message) => updates(message as SystemInfo)) as SystemInfo;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SystemInfo() / SystemInfo.new instead')
  static SystemInfo create() => SystemInfo._();
  static $pb.GeneratedMessage $_createMessage() => SystemInfo._();
  @$core.override
  SystemInfo createEmptyInstance() => SystemInfo._();
  @$core.pragma('dart2js:noInline')
  static SystemInfo getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SystemInfo>(SystemInfo.$_createMessage);
  static SystemInfo? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get version => $_getSZ(0);
  @$pb.TagNumber(1)
  set version($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasVersion() => $_has(0);
  @$pb.TagNumber(1)
  void clearVersion() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get minClientVersion => $_getSZ(1);
  @$pb.TagNumber(2)
  set minClientVersion($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMinClientVersion() => $_has(1);
  @$pb.TagNumber(2)
  void clearMinClientVersion() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get api => $_getSZ(2);
  @$pb.TagNumber(3)
  set api($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasApi() => $_has(2);
  @$pb.TagNumber(3)
  void clearApi() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get commit => $_getSZ(3);
  @$pb.TagNumber(4)
  set commit($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasCommit() => $_has(3);
  @$pb.TagNumber(4)
  void clearCommit() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get redis => $_getSZ(4);
  @$pb.TagNumber(5)
  set redis($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasRedis() => $_has(4);
  @$pb.TagNumber(5)
  void clearRedis() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get broker => $_getSZ(5);
  @$pb.TagNumber(6)
  set broker($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasBroker() => $_has(5);
  @$pb.TagNumber(6)
  void clearBroker() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.bool get eager => $_getBF(6);
  @$pb.TagNumber(7)
  set eager($core.bool value) => $_setBool(6, value);
  @$pb.TagNumber(7)
  $core.bool hasEager() => $_has(6);
  @$pb.TagNumber(7)
  void clearEager() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.int get workers => $_getIZ(7);
  @$pb.TagNumber(8)
  set workers($core.int value) => $_setSignedInt32(7, value);
  @$pb.TagNumber(8)
  $core.bool hasWorkers() => $_has(7);
  @$pb.TagNumber(8)
  void clearWorkers() => $_clearField(8);

  @$pb.TagNumber(9)
  $pb.PbMap<$core.String, $core.int> get backlog => $_getMap(8);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
