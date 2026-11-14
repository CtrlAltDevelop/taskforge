// This is a generated file - do not edit.
//
// Generated from infrastructure/system/grpc/system.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports
// ignore_for_file: unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use setCollectDeviceInfoRequestDescriptor instead')
const SetCollectDeviceInfoRequest$json = {
  '1': 'SetCollectDeviceInfoRequest',
  '2': [
    {'1': 'enabled', '3': 1, '4': 1, '5': 8, '10': 'enabled'},
  ],
};

/// Descriptor for `SetCollectDeviceInfoRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setCollectDeviceInfoRequestDescriptor =
    $convert.base64Decode(
        'ChtTZXRDb2xsZWN0RGV2aWNlSW5mb1JlcXVlc3QSGAoHZW5hYmxlZBgBIAEoCFIHZW5hYmxlZA'
        '==');

@$core.Deprecated('Use systemInfoDescriptor instead')
const SystemInfo$json = {
  '1': 'SystemInfo',
  '2': [
    {'1': 'version', '3': 1, '4': 1, '5': 9, '10': 'version'},
    {
      '1': 'min_client_version',
      '3': 2,
      '4': 1,
      '5': 9,
      '10': 'minClientVersion'
    },
    {'1': 'api', '3': 3, '4': 1, '5': 9, '10': 'api'},
    {'1': 'commit', '3': 4, '4': 1, '5': 9, '10': 'commit'},
    {'1': 'redis', '3': 5, '4': 1, '5': 9, '10': 'redis'},
    {'1': 'broker', '3': 6, '4': 1, '5': 9, '10': 'broker'},
    {'1': 'eager', '3': 7, '4': 1, '5': 8, '10': 'eager'},
    {'1': 'workers', '3': 8, '4': 1, '5': 5, '10': 'workers'},
    {
      '1': 'backlog',
      '3': 9,
      '4': 3,
      '5': 11,
      '6': '.config.system.SystemInfo.BacklogEntry',
      '10': 'backlog'
    },
    {
      '1': 'collect_device_info',
      '3': 10,
      '4': 1,
      '5': 8,
      '10': 'collectDeviceInfo'
    },
    {
      '1': 'device_pepper_set',
      '3': 11,
      '4': 1,
      '5': 8,
      '10': 'devicePepperSet'
    },
  ],
  '3': [SystemInfo_BacklogEntry$json],
};

@$core.Deprecated('Use systemInfoDescriptor instead')
const SystemInfo_BacklogEntry$json = {
  '1': 'BacklogEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 5, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `SystemInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List systemInfoDescriptor = $convert.base64Decode(
    'CgpTeXN0ZW1JbmZvEhgKB3ZlcnNpb24YASABKAlSB3ZlcnNpb24SLAoSbWluX2NsaWVudF92ZX'
    'JzaW9uGAIgASgJUhBtaW5DbGllbnRWZXJzaW9uEhAKA2FwaRgDIAEoCVIDYXBpEhYKBmNvbW1p'
    'dBgEIAEoCVIGY29tbWl0EhQKBXJlZGlzGAUgASgJUgVyZWRpcxIWCgZicm9rZXIYBiABKAlSBm'
    'Jyb2tlchIUCgVlYWdlchgHIAEoCFIFZWFnZXISGAoHd29ya2VycxgIIAEoBVIHd29ya2VycxJA'
    'CgdiYWNrbG9nGAkgAygLMiYuY29uZmlnLnN5c3RlbS5TeXN0ZW1JbmZvLkJhY2tsb2dFbnRyeV'
    'IHYmFja2xvZxIuChNjb2xsZWN0X2RldmljZV9pbmZvGAogASgIUhFjb2xsZWN0RGV2aWNlSW5m'
    'bxIqChFkZXZpY2VfcGVwcGVyX3NldBgLIAEoCFIPZGV2aWNlUGVwcGVyU2V0GjoKDEJhY2tsb2'
    'dFbnRyeRIQCgNrZXkYASABKAlSA2tleRIUCgV2YWx1ZRgCIAEoBVIFdmFsdWU6AjgB');
