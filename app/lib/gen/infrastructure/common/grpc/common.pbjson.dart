// This is a generated file - do not edit.
//
// Generated from infrastructure/common/grpc/common.proto.

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

@$core.Deprecated('Use healthDescriptor instead')
const Health$json = {
  '1': 'Health',
  '2': [
    {'1': 'status', '3': 1, '4': 1, '5': 9, '10': 'status'},
    {'1': 'is_ready', '3': 2, '4': 1, '5': 8, '10': 'isReady'},
    {
      '1': 'checks',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.config.common.Health.ChecksEntry',
      '10': 'checks'
    },
  ],
  '3': [Health_ChecksEntry$json],
};

@$core.Deprecated('Use healthDescriptor instead')
const Health_ChecksEntry$json = {
  '1': 'ChecksEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `Health`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List healthDescriptor = $convert.base64Decode(
    'CgZIZWFsdGgSFgoGc3RhdHVzGAEgASgJUgZzdGF0dXMSGQoIaXNfcmVhZHkYAiABKAhSB2lzUm'
    'VhZHkSOQoGY2hlY2tzGAMgAygLMiEuY29uZmlnLmNvbW1vbi5IZWFsdGguQ2hlY2tzRW50cnlS'
    'BmNoZWNrcxo5CgtDaGVja3NFbnRyeRIQCgNrZXkYASABKAlSA2tleRIUCgV2YWx1ZRgCIAEoCV'
    'IFdmFsdWU6AjgB');
