// This is a generated file - do not edit.
//
// Generated from infrastructure/common/grpc/common.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class Health extends $pb.GeneratedMessage {
  factory Health({
    $core.String? status,
    $core.bool? isReady,
    $core.Iterable<$core.MapEntry<$core.String, $core.String>>? checks,
  }) {
    final result = Health._();
    if (status != null) result.status = status;
    if (isReady != null) result.isReady = isReady;
    if (checks != null) result.checks.addEntries(checks);
    return result;
  }

  Health._();

  factory Health.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Health()..mergeFromBuffer(data, registry);
  factory Health.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Health()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Health',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.common'),
      createEmptyInstance: Health.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'status')
    ..aOB(2, _omitFieldNames ? '' : 'isReady')
    ..m<$core.String, $core.String>(3, _omitFieldNames ? '' : 'checks',
        entryClassName: 'Health.ChecksEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OS,
        packageName: const $pb.PackageName('config.common'))
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Health clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Health copyWith(void Function(Health) updates) =>
      super.copyWith((message) => updates(message as Health)) as Health;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Health() / Health.new instead')
  static Health create() => Health._();
  static $pb.GeneratedMessage $_createMessage() => Health._();
  @$core.override
  Health createEmptyInstance() => Health._();
  @$core.pragma('dart2js:noInline')
  static Health getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Health>(Health.$_createMessage);
  static Health? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get status => $_getSZ(0);
  @$pb.TagNumber(1)
  set status($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasStatus() => $_has(0);
  @$pb.TagNumber(1)
  void clearStatus() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get isReady => $_getBF(1);
  @$pb.TagNumber(2)
  set isReady($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasIsReady() => $_has(1);
  @$pb.TagNumber(2)
  void clearIsReady() => $_clearField(2);

  @$pb.TagNumber(3)
  $pb.PbMap<$core.String, $core.String> get checks => $_getMap(2);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
