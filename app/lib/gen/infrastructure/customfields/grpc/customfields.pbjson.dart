// This is a generated file - do not edit.
//
// Generated from infrastructure/customfields/grpc/customfields.proto.

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

@$core.Deprecated('Use fieldDescriptor instead')
const Field$json = {
  '1': 'Field',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'name', '3': 3, '4': 1, '5': 9, '10': 'name'},
    {'1': 'type', '3': 4, '4': 1, '5': 9, '10': 'type'},
    {
      '1': 'options',
      '3': 5,
      '4': 3,
      '5': 11,
      '6': '.config.customfields.FieldOptionResponse',
      '10': 'options'
    },
    {'1': 'required', '3': 6, '4': 1, '5': 8, '10': 'required'},
    {'1': 'default', '3': 7, '4': 1, '5': 9, '10': 'default'},
    {'1': 'hidden_views', '3': 8, '4': 3, '5': 9, '10': 'hiddenViews'},
    {'1': 'position', '3': 9, '4': 1, '5': 5, '10': 'position'},
    {'1': 'version', '3': 10, '4': 1, '5': 5, '10': 'version'},
    {'1': 'archived_at', '3': 11, '4': 1, '5': 9, '10': 'archivedAt'},
  ],
};

/// Descriptor for `Field`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List fieldDescriptor = $convert.base64Decode(
    'CgVGaWVsZBIOCgJpZBgBIAEoCVICaWQSHQoKcHJvamVjdF9pZBgCIAEoCVIJcHJvamVjdElkEh'
    'IKBG5hbWUYAyABKAlSBG5hbWUSEgoEdHlwZRgEIAEoCVIEdHlwZRJCCgdvcHRpb25zGAUgAygL'
    'MiguY29uZmlnLmN1c3RvbWZpZWxkcy5GaWVsZE9wdGlvblJlc3BvbnNlUgdvcHRpb25zEhoKCH'
    'JlcXVpcmVkGAYgASgIUghyZXF1aXJlZBIYCgdkZWZhdWx0GAcgASgJUgdkZWZhdWx0EiEKDGhp'
    'ZGRlbl92aWV3cxgIIAMoCVILaGlkZGVuVmlld3MSGgoIcG9zaXRpb24YCSABKAVSCHBvc2l0aW'
    '9uEhgKB3ZlcnNpb24YCiABKAVSB3ZlcnNpb24SHwoLYXJjaGl2ZWRfYXQYCyABKAlSCmFyY2hp'
    'dmVkQXQ=');

@$core.Deprecated('Use fieldArchiveRequestDescriptor instead')
const FieldArchiveRequest$json = {
  '1': 'FieldArchiveRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'id', '3': 3, '4': 1, '5': 9, '10': 'id'},
    {'1': 'expected_version', '3': 4, '4': 1, '5': 5, '10': 'expectedVersion'},
  ],
};

/// Descriptor for `FieldArchiveRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List fieldArchiveRequestDescriptor = $convert.base64Decode(
    'ChNGaWVsZEFyY2hpdmVSZXF1ZXN0EiEKDHdvcmtzcGFjZV9pZBgBIAEoCVILd29ya3NwYWNlSW'
    'QSHQoKcHJvamVjdF9pZBgCIAEoCVIJcHJvamVjdElkEg4KAmlkGAMgASgJUgJpZBIpChBleHBl'
    'Y3RlZF92ZXJzaW9uGAQgASgFUg9leHBlY3RlZFZlcnNpb24=');

@$core.Deprecated('Use fieldCreateRequestDescriptor instead')
const FieldCreateRequest$json = {
  '1': 'FieldCreateRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'name', '3': 3, '4': 1, '5': 9, '10': 'name'},
    {'1': 'type', '3': 4, '4': 1, '5': 9, '10': 'type'},
    {
      '1': 'options',
      '3': 5,
      '4': 3,
      '5': 11,
      '6': '.config.customfields.FieldOption',
      '10': 'options'
    },
    {'1': 'required', '3': 6, '4': 1, '5': 8, '10': 'required'},
    {'1': 'default', '3': 7, '4': 1, '5': 9, '10': 'default'},
    {'1': 'hidden_views', '3': 8, '4': 3, '5': 9, '10': 'hiddenViews'},
  ],
};

/// Descriptor for `FieldCreateRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List fieldCreateRequestDescriptor = $convert.base64Decode(
    'ChJGaWVsZENyZWF0ZVJlcXVlc3QSIQoMd29ya3NwYWNlX2lkGAEgASgJUgt3b3Jrc3BhY2VJZB'
    'IdCgpwcm9qZWN0X2lkGAIgASgJUglwcm9qZWN0SWQSEgoEbmFtZRgDIAEoCVIEbmFtZRISCgR0'
    'eXBlGAQgASgJUgR0eXBlEjoKB29wdGlvbnMYBSADKAsyIC5jb25maWcuY3VzdG9tZmllbGRzLk'
    'ZpZWxkT3B0aW9uUgdvcHRpb25zEhoKCHJlcXVpcmVkGAYgASgIUghyZXF1aXJlZBIYCgdkZWZh'
    'dWx0GAcgASgJUgdkZWZhdWx0EiEKDGhpZGRlbl92aWV3cxgIIAMoCVILaGlkZGVuVmlld3M=');

@$core.Deprecated('Use fieldListDescriptor instead')
const FieldList$json = {
  '1': 'FieldList',
  '2': [
    {
      '1': 'fields',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.config.customfields.Field',
      '10': 'fields'
    },
  ],
};

/// Descriptor for `FieldList`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List fieldListDescriptor = $convert.base64Decode(
    'CglGaWVsZExpc3QSMgoGZmllbGRzGAEgAygLMhouY29uZmlnLmN1c3RvbWZpZWxkcy5GaWVsZF'
    'IGZmllbGRz');

@$core.Deprecated('Use fieldListRequestDescriptor instead')
const FieldListRequest$json = {
  '1': 'FieldListRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'include_archived', '3': 3, '4': 1, '5': 8, '10': 'includeArchived'},
  ],
};

/// Descriptor for `FieldListRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List fieldListRequestDescriptor = $convert.base64Decode(
    'ChBGaWVsZExpc3RSZXF1ZXN0EiEKDHdvcmtzcGFjZV9pZBgBIAEoCVILd29ya3NwYWNlSWQSHQ'
    'oKcHJvamVjdF9pZBgCIAEoCVIJcHJvamVjdElkEikKEGluY2x1ZGVfYXJjaGl2ZWQYAyABKAhS'
    'D2luY2x1ZGVBcmNoaXZlZA==');

@$core.Deprecated('Use fieldOptionDescriptor instead')
const FieldOption$json = {
  '1': 'FieldOption',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'label', '3': 2, '4': 1, '5': 9, '10': 'label'},
    {'1': 'color', '3': 3, '4': 1, '5': 9, '10': 'color'},
  ],
};

/// Descriptor for `FieldOption`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List fieldOptionDescriptor = $convert.base64Decode(
    'CgtGaWVsZE9wdGlvbhIOCgJpZBgBIAEoCVICaWQSFAoFbGFiZWwYAiABKAlSBWxhYmVsEhQKBW'
    'NvbG9yGAMgASgJUgVjb2xvcg==');

@$core.Deprecated('Use fieldOptionResponseDescriptor instead')
const FieldOptionResponse$json = {
  '1': 'FieldOptionResponse',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'label', '3': 2, '4': 1, '5': 9, '10': 'label'},
    {'1': 'color', '3': 3, '4': 1, '5': 9, '10': 'color'},
  ],
};

/// Descriptor for `FieldOptionResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List fieldOptionResponseDescriptor = $convert.base64Decode(
    'ChNGaWVsZE9wdGlvblJlc3BvbnNlEg4KAmlkGAEgASgJUgJpZBIUCgVsYWJlbBgCIAEoCVIFbG'
    'FiZWwSFAoFY29sb3IYAyABKAlSBWNvbG9y');

@$core.Deprecated('Use fieldReorderRequestDescriptor instead')
const FieldReorderRequest$json = {
  '1': 'FieldReorderRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'ids', '3': 3, '4': 3, '5': 9, '10': 'ids'},
  ],
};

/// Descriptor for `FieldReorderRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List fieldReorderRequestDescriptor = $convert.base64Decode(
    'ChNGaWVsZFJlb3JkZXJSZXF1ZXN0EiEKDHdvcmtzcGFjZV9pZBgBIAEoCVILd29ya3NwYWNlSW'
    'QSHQoKcHJvamVjdF9pZBgCIAEoCVIJcHJvamVjdElkEhAKA2lkcxgDIAMoCVIDaWRz');

@$core.Deprecated('Use fieldRestoreRequestDescriptor instead')
const FieldRestoreRequest$json = {
  '1': 'FieldRestoreRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'id', '3': 3, '4': 1, '5': 9, '10': 'id'},
    {'1': 'expected_version', '3': 4, '4': 1, '5': 5, '10': 'expectedVersion'},
  ],
};

/// Descriptor for `FieldRestoreRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List fieldRestoreRequestDescriptor = $convert.base64Decode(
    'ChNGaWVsZFJlc3RvcmVSZXF1ZXN0EiEKDHdvcmtzcGFjZV9pZBgBIAEoCVILd29ya3NwYWNlSW'
    'QSHQoKcHJvamVjdF9pZBgCIAEoCVIJcHJvamVjdElkEg4KAmlkGAMgASgJUgJpZBIpChBleHBl'
    'Y3RlZF92ZXJzaW9uGAQgASgFUg9leHBlY3RlZFZlcnNpb24=');

@$core.Deprecated('Use fieldUpdateRequestDescriptor instead')
const FieldUpdateRequest$json = {
  '1': 'FieldUpdateRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'id', '3': 3, '4': 1, '5': 9, '10': 'id'},
    {'1': 'expected_version', '3': 4, '4': 1, '5': 5, '10': 'expectedVersion'},
    {'1': 'name', '3': 5, '4': 1, '5': 9, '9': 0, '10': 'name', '17': true},
    {'1': 'type', '3': 6, '4': 1, '5': 9, '9': 1, '10': 'type', '17': true},
    {
      '1': 'default',
      '3': 7,
      '4': 1,
      '5': 9,
      '9': 2,
      '10': 'default',
      '17': true
    },
    {
      '1': 'required',
      '3': 8,
      '4': 1,
      '5': 8,
      '9': 3,
      '10': 'required',
      '17': true
    },
    {'1': 'set_options', '3': 9, '4': 1, '5': 8, '10': 'setOptions'},
    {
      '1': 'options',
      '3': 10,
      '4': 3,
      '5': 11,
      '6': '.config.customfields.FieldOption',
      '10': 'options'
    },
    {'1': 'set_hidden_views', '3': 11, '4': 1, '5': 8, '10': 'setHiddenViews'},
    {'1': 'hidden_views', '3': 12, '4': 3, '5': 9, '10': 'hiddenViews'},
    {
      '1': 'remaps',
      '3': 13,
      '4': 3,
      '5': 11,
      '6': '.config.customfields.OptionRemap',
      '10': 'remaps'
    },
  ],
  '8': [
    {'1': '_name'},
    {'1': '_type'},
    {'1': '_default'},
    {'1': '_required'},
  ],
};

/// Descriptor for `FieldUpdateRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List fieldUpdateRequestDescriptor = $convert.base64Decode(
    'ChJGaWVsZFVwZGF0ZVJlcXVlc3QSIQoMd29ya3NwYWNlX2lkGAEgASgJUgt3b3Jrc3BhY2VJZB'
    'IdCgpwcm9qZWN0X2lkGAIgASgJUglwcm9qZWN0SWQSDgoCaWQYAyABKAlSAmlkEikKEGV4cGVj'
    'dGVkX3ZlcnNpb24YBCABKAVSD2V4cGVjdGVkVmVyc2lvbhIXCgRuYW1lGAUgASgJSABSBG5hbW'
    'WIAQESFwoEdHlwZRgGIAEoCUgBUgR0eXBliAEBEh0KB2RlZmF1bHQYByABKAlIAlIHZGVmYXVs'
    'dIgBARIfCghyZXF1aXJlZBgIIAEoCEgDUghyZXF1aXJlZIgBARIfCgtzZXRfb3B0aW9ucxgJIA'
    'EoCFIKc2V0T3B0aW9ucxI6CgdvcHRpb25zGAogAygLMiAuY29uZmlnLmN1c3RvbWZpZWxkcy5G'
    'aWVsZE9wdGlvblIHb3B0aW9ucxIoChBzZXRfaGlkZGVuX3ZpZXdzGAsgASgIUg5zZXRIaWRkZW'
    '5WaWV3cxIhCgxoaWRkZW5fdmlld3MYDCADKAlSC2hpZGRlblZpZXdzEjgKBnJlbWFwcxgNIAMo'
    'CzIgLmNvbmZpZy5jdXN0b21maWVsZHMuT3B0aW9uUmVtYXBSBnJlbWFwc0IHCgVfbmFtZUIHCg'
    'VfdHlwZUIKCghfZGVmYXVsdEILCglfcmVxdWlyZWQ=');

@$core.Deprecated('Use optionRemapDescriptor instead')
const OptionRemap$json = {
  '1': 'OptionRemap',
  '2': [
    {'1': 'from_option', '3': 1, '4': 1, '5': 9, '10': 'fromOption'},
    {'1': 'to_option', '3': 2, '4': 1, '5': 9, '10': 'toOption'},
  ],
};

/// Descriptor for `OptionRemap`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List optionRemapDescriptor = $convert.base64Decode(
    'CgtPcHRpb25SZW1hcBIfCgtmcm9tX29wdGlvbhgBIAEoCVIKZnJvbU9wdGlvbhIbCgl0b19vcH'
    'Rpb24YAiABKAlSCHRvT3B0aW9u');
