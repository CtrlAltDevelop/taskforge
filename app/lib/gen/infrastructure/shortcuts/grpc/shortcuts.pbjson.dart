// This is a generated file - do not edit.
//
// Generated from infrastructure/shortcuts/grpc/shortcuts.proto.

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

@$core.Deprecated('Use shortcutDescriptor instead')
const Shortcut$json = {
  '1': 'Shortcut',
  '2': [
    {'1': 'action_id', '3': 1, '4': 1, '5': 9, '10': 'actionId'},
    {'1': 'keys', '3': 2, '4': 1, '5': 9, '10': 'keys'},
  ],
};

/// Descriptor for `Shortcut`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List shortcutDescriptor = $convert.base64Decode(
    'CghTaG9ydGN1dBIbCglhY3Rpb25faWQYASABKAlSCGFjdGlvbklkEhIKBGtleXMYAiABKAlSBG'
    'tleXM=');

@$core.Deprecated('Use shortcutGetRequestDescriptor instead')
const ShortcutGetRequest$json = {
  '1': 'ShortcutGetRequest',
};

/// Descriptor for `ShortcutGetRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List shortcutGetRequestDescriptor =
    $convert.base64Decode('ChJTaG9ydGN1dEdldFJlcXVlc3Q=');

@$core.Deprecated('Use shortcutListDescriptor instead')
const ShortcutList$json = {
  '1': 'ShortcutList',
  '2': [
    {
      '1': 'shortcuts',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.config.shortcuts.Shortcut',
      '10': 'shortcuts'
    },
  ],
};

/// Descriptor for `ShortcutList`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List shortcutListDescriptor = $convert.base64Decode(
    'CgxTaG9ydGN1dExpc3QSOAoJc2hvcnRjdXRzGAEgAygLMhouY29uZmlnLnNob3J0Y3V0cy5TaG'
    '9ydGN1dFIJc2hvcnRjdXRz');

@$core.Deprecated('Use shortcutSetRequestDescriptor instead')
const ShortcutSetRequest$json = {
  '1': 'ShortcutSetRequest',
  '2': [
    {'1': 'action_id', '3': 1, '4': 1, '5': 9, '10': 'actionId'},
    {'1': 'keys', '3': 2, '4': 1, '5': 9, '10': 'keys'},
    {'1': 'reset', '3': 3, '4': 1, '5': 8, '10': 'reset'},
  ],
};

/// Descriptor for `ShortcutSetRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List shortcutSetRequestDescriptor = $convert.base64Decode(
    'ChJTaG9ydGN1dFNldFJlcXVlc3QSGwoJYWN0aW9uX2lkGAEgASgJUghhY3Rpb25JZBISCgRrZX'
    'lzGAIgASgJUgRrZXlzEhQKBXJlc2V0GAMgASgIUgVyZXNldA==');
