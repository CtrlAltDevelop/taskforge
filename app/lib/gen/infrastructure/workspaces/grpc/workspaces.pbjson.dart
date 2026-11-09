// This is a generated file - do not edit.
//
// Generated from infrastructure/workspaces/grpc/workspaces.proto.

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

@$core.Deprecated('Use workspaceDescriptor instead')
const Workspace$json = {
  '1': 'Workspace',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'slug', '3': 3, '4': 1, '5': 9, '10': 'slug'},
    {'1': 'logo', '3': 4, '4': 1, '5': 9, '10': 'logo'},
    {'1': 'created_by', '3': 5, '4': 1, '5': 9, '10': 'createdBy'},
    {'1': 'created_at', '3': 6, '4': 1, '5': 9, '10': 'createdAt'},
    {'1': 'deleted_at', '3': 7, '4': 1, '5': 9, '10': 'deletedAt'},
    {'1': 'version', '3': 8, '4': 1, '5': 5, '10': 'version'},
    {'1': 'is_owner', '3': 9, '4': 1, '5': 8, '10': 'isOwner'},
  ],
};

/// Descriptor for `Workspace`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List workspaceDescriptor = $convert.base64Decode(
    'CglXb3Jrc3BhY2USDgoCaWQYASABKAlSAmlkEhIKBG5hbWUYAiABKAlSBG5hbWUSEgoEc2x1Zx'
    'gDIAEoCVIEc2x1ZxISCgRsb2dvGAQgASgJUgRsb2dvEh0KCmNyZWF0ZWRfYnkYBSABKAlSCWNy'
    'ZWF0ZWRCeRIdCgpjcmVhdGVkX2F0GAYgASgJUgljcmVhdGVkQXQSHQoKZGVsZXRlZF9hdBgHIA'
    'EoCVIJZGVsZXRlZEF0EhgKB3ZlcnNpb24YCCABKAVSB3ZlcnNpb24SGQoIaXNfb3duZXIYCSAB'
    'KAhSB2lzT3duZXI=');

@$core.Deprecated('Use workspaceCreateRequestDescriptor instead')
const WorkspaceCreateRequest$json = {
  '1': 'WorkspaceCreateRequest',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    {'1': 'slug', '3': 2, '4': 1, '5': 9, '10': 'slug'},
  ],
};

/// Descriptor for `WorkspaceCreateRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List workspaceCreateRequestDescriptor =
    $convert.base64Decode(
        'ChZXb3Jrc3BhY2VDcmVhdGVSZXF1ZXN0EhIKBG5hbWUYASABKAlSBG5hbWUSEgoEc2x1ZxgCIA'
        'EoCVIEc2x1Zw==');

@$core.Deprecated('Use workspaceDeleteRequestDescriptor instead')
const WorkspaceDeleteRequest$json = {
  '1': 'WorkspaceDeleteRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'confirmation', '3': 2, '4': 1, '5': 9, '10': 'confirmation'},
  ],
};

/// Descriptor for `WorkspaceDeleteRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List workspaceDeleteRequestDescriptor =
    $convert.base64Decode(
        'ChZXb3Jrc3BhY2VEZWxldGVSZXF1ZXN0Eg4KAmlkGAEgASgJUgJpZBIiCgxjb25maXJtYXRpb2'
        '4YAiABKAlSDGNvbmZpcm1hdGlvbg==');

@$core.Deprecated('Use workspaceListDescriptor instead')
const WorkspaceList$json = {
  '1': 'WorkspaceList',
  '2': [
    {
      '1': 'workspaces',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.config.workspaces.Workspace',
      '10': 'workspaces'
    },
  ],
};

/// Descriptor for `WorkspaceList`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List workspaceListDescriptor = $convert.base64Decode(
    'Cg1Xb3Jrc3BhY2VMaXN0EjwKCndvcmtzcGFjZXMYASADKAsyHC5jb25maWcud29ya3NwYWNlcy'
    '5Xb3Jrc3BhY2VSCndvcmtzcGFjZXM=');

@$core.Deprecated('Use workspaceRestoreRequestDescriptor instead')
const WorkspaceRestoreRequest$json = {
  '1': 'WorkspaceRestoreRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `WorkspaceRestoreRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List workspaceRestoreRequestDescriptor = $convert
    .base64Decode('ChdXb3Jrc3BhY2VSZXN0b3JlUmVxdWVzdBIOCgJpZBgBIAEoCVICaWQ=');

@$core.Deprecated('Use workspaceUpdateRequestDescriptor instead')
const WorkspaceUpdateRequest$json = {
  '1': 'WorkspaceUpdateRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'expected_version', '3': 2, '4': 1, '5': 5, '10': 'expectedVersion'},
    {'1': 'name', '3': 3, '4': 1, '5': 9, '9': 0, '10': 'name', '17': true},
    {'1': 'slug', '3': 4, '4': 1, '5': 9, '9': 1, '10': 'slug', '17': true},
  ],
  '8': [
    {'1': '_name'},
    {'1': '_slug'},
  ],
};

/// Descriptor for `WorkspaceUpdateRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List workspaceUpdateRequestDescriptor = $convert.base64Decode(
    'ChZXb3Jrc3BhY2VVcGRhdGVSZXF1ZXN0Eg4KAmlkGAEgASgJUgJpZBIpChBleHBlY3RlZF92ZX'
    'JzaW9uGAIgASgFUg9leHBlY3RlZFZlcnNpb24SFwoEbmFtZRgDIAEoCUgAUgRuYW1liAEBEhcK'
    'BHNsdWcYBCABKAlIAVIEc2x1Z4gBAUIHCgVfbmFtZUIHCgVfc2x1Zw==');
