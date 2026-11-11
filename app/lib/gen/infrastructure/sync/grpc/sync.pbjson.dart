// This is a generated file - do not edit.
//
// Generated from infrastructure/sync/grpc/sync.proto.

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

@$core.Deprecated('Use syncEntryDescriptor instead')
const SyncEntry$json = {
  '1': 'SyncEntry',
  '2': [
    {'1': 'cursor', '3': 1, '4': 1, '5': 9, '10': 'cursor'},
    {'1': 'type', '3': 2, '4': 1, '5': 9, '10': 'type'},
    {'1': 'project_id', '3': 3, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'entity_id', '3': 4, '4': 1, '5': 9, '10': 'entityId'},
    {'1': 'version', '3': 5, '4': 1, '5': 5, '10': 'version'},
    {'1': 'actor', '3': 6, '4': 1, '5': 9, '10': 'actor'},
    {'1': 'at', '3': 7, '4': 1, '5': 9, '10': 'at'},
  ],
};

/// Descriptor for `SyncEntry`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List syncEntryDescriptor = $convert.base64Decode(
    'CglTeW5jRW50cnkSFgoGY3Vyc29yGAEgASgJUgZjdXJzb3ISEgoEdHlwZRgCIAEoCVIEdHlwZR'
    'IdCgpwcm9qZWN0X2lkGAMgASgJUglwcm9qZWN0SWQSGwoJZW50aXR5X2lkGAQgASgJUghlbnRp'
    'dHlJZBIYCgd2ZXJzaW9uGAUgASgFUgd2ZXJzaW9uEhQKBWFjdG9yGAYgASgJUgVhY3RvchIOCg'
    'JhdBgHIAEoCVICYXQ=');

@$core.Deprecated('Use syncHeadDescriptor instead')
const SyncHead$json = {
  '1': 'SyncHead',
  '2': [
    {'1': 'cursor', '3': 1, '4': 1, '5': 9, '10': 'cursor'},
  ],
};

/// Descriptor for `SyncHead`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List syncHeadDescriptor =
    $convert.base64Decode('CghTeW5jSGVhZBIWCgZjdXJzb3IYASABKAlSBmN1cnNvcg==');

@$core.Deprecated('Use syncHeadRequestDescriptor instead')
const SyncHeadRequest$json = {
  '1': 'SyncHeadRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
  ],
};

/// Descriptor for `SyncHeadRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List syncHeadRequestDescriptor = $convert.base64Decode(
    'Cg9TeW5jSGVhZFJlcXVlc3QSIQoMd29ya3NwYWNlX2lkGAEgASgJUgt3b3Jrc3BhY2VJZA==');

@$core.Deprecated('Use syncSinceRequestDescriptor instead')
const SyncSinceRequest$json = {
  '1': 'SyncSinceRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'cursor', '3': 2, '4': 1, '5': 9, '10': 'cursor'},
    {'1': 'limit', '3': 3, '4': 1, '5': 5, '10': 'limit'},
    {'1': 'overlap', '3': 4, '4': 1, '5': 5, '10': 'overlap'},
  ],
};

/// Descriptor for `SyncSinceRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List syncSinceRequestDescriptor = $convert.base64Decode(
    'ChBTeW5jU2luY2VSZXF1ZXN0EiEKDHdvcmtzcGFjZV9pZBgBIAEoCVILd29ya3NwYWNlSWQSFg'
    'oGY3Vyc29yGAIgASgJUgZjdXJzb3ISFAoFbGltaXQYAyABKAVSBWxpbWl0EhgKB292ZXJsYXAY'
    'BCABKAVSB292ZXJsYXA=');
