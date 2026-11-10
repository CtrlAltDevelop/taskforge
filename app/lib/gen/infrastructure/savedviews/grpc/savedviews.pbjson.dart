// This is a generated file - do not edit.
//
// Generated from infrastructure/savedviews/grpc/savedviews.proto.

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

@$core.Deprecated('Use boardLayoutDescriptor instead')
const BoardLayout$json = {
  '1': 'BoardLayout',
  '2': [
    {'1': 'group_by', '3': 1, '4': 1, '5': 9, '10': 'groupBy'},
    {'1': 'swimlane', '3': 2, '4': 1, '5': 9, '10': 'swimlane'},
    {'1': 'card_fields', '3': 3, '4': 3, '5': 9, '10': 'cardFields'},
    {
      '1': 'limits',
      '3': 4,
      '4': 3,
      '5': 11,
      '6': '.config.savedviews.BoardLimit',
      '10': 'limits'
    },
  ],
};

/// Descriptor for `BoardLayout`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List boardLayoutDescriptor = $convert.base64Decode(
    'CgtCb2FyZExheW91dBIZCghncm91cF9ieRgBIAEoCVIHZ3JvdXBCeRIaCghzd2ltbGFuZRgCIA'
    'EoCVIIc3dpbWxhbmUSHwoLY2FyZF9maWVsZHMYAyADKAlSCmNhcmRGaWVsZHMSNQoGbGltaXRz'
    'GAQgAygLMh0uY29uZmlnLnNhdmVkdmlld3MuQm9hcmRMaW1pdFIGbGltaXRz');

@$core.Deprecated('Use boardLayoutResponseDescriptor instead')
const BoardLayoutResponse$json = {
  '1': 'BoardLayoutResponse',
  '2': [
    {'1': 'group_by', '3': 1, '4': 1, '5': 9, '10': 'groupBy'},
    {'1': 'swimlane', '3': 2, '4': 1, '5': 9, '10': 'swimlane'},
    {'1': 'card_fields', '3': 3, '4': 3, '5': 9, '10': 'cardFields'},
    {
      '1': 'limits',
      '3': 4,
      '4': 3,
      '5': 11,
      '6': '.config.savedviews.BoardLimitResponse',
      '10': 'limits'
    },
  ],
};

/// Descriptor for `BoardLayoutResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List boardLayoutResponseDescriptor = $convert.base64Decode(
    'ChNCb2FyZExheW91dFJlc3BvbnNlEhkKCGdyb3VwX2J5GAEgASgJUgdncm91cEJ5EhoKCHN3aW'
    '1sYW5lGAIgASgJUghzd2ltbGFuZRIfCgtjYXJkX2ZpZWxkcxgDIAMoCVIKY2FyZEZpZWxkcxI9'
    'CgZsaW1pdHMYBCADKAsyJS5jb25maWcuc2F2ZWR2aWV3cy5Cb2FyZExpbWl0UmVzcG9uc2VSBm'
    'xpbWl0cw==');

@$core.Deprecated('Use boardLimitDescriptor instead')
const BoardLimit$json = {
  '1': 'BoardLimit',
  '2': [
    {'1': 'column', '3': 1, '4': 1, '5': 9, '10': 'column'},
    {'1': 'limit', '3': 2, '4': 1, '5': 5, '10': 'limit'},
  ],
};

/// Descriptor for `BoardLimit`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List boardLimitDescriptor = $convert.base64Decode(
    'CgpCb2FyZExpbWl0EhYKBmNvbHVtbhgBIAEoCVIGY29sdW1uEhQKBWxpbWl0GAIgASgFUgVsaW'
    '1pdA==');

@$core.Deprecated('Use boardLimitResponseDescriptor instead')
const BoardLimitResponse$json = {
  '1': 'BoardLimitResponse',
  '2': [
    {'1': 'column', '3': 1, '4': 1, '5': 9, '10': 'column'},
    {'1': 'limit', '3': 2, '4': 1, '5': 5, '10': 'limit'},
  ],
};

/// Descriptor for `BoardLimitResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List boardLimitResponseDescriptor = $convert.base64Decode(
    'ChJCb2FyZExpbWl0UmVzcG9uc2USFgoGY29sdW1uGAEgASgJUgZjb2x1bW4SFAoFbGltaXQYAi'
    'ABKAVSBWxpbWl0');

@$core.Deprecated('Use layoutDescriptor instead')
const Layout$json = {
  '1': 'Layout',
  '2': [
    {'1': 'columns', '3': 1, '4': 3, '5': 9, '10': 'columns'},
    {
      '1': 'widths',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.config.savedviews.LayoutWidth',
      '10': 'widths'
    },
    {
      '1': 'sort',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.config.savedviews.LayoutSort',
      '10': 'sort'
    },
    {'1': 'group_by', '3': 4, '4': 1, '5': 9, '10': 'groupBy'},
  ],
};

/// Descriptor for `Layout`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List layoutDescriptor = $convert.base64Decode(
    'CgZMYXlvdXQSGAoHY29sdW1ucxgBIAMoCVIHY29sdW1ucxI2CgZ3aWR0aHMYAiADKAsyHi5jb2'
    '5maWcuc2F2ZWR2aWV3cy5MYXlvdXRXaWR0aFIGd2lkdGhzEjEKBHNvcnQYAyADKAsyHS5jb25m'
    'aWcuc2F2ZWR2aWV3cy5MYXlvdXRTb3J0UgRzb3J0EhkKCGdyb3VwX2J5GAQgASgJUgdncm91cE'
    'J5');

@$core.Deprecated('Use layoutResponseDescriptor instead')
const LayoutResponse$json = {
  '1': 'LayoutResponse',
  '2': [
    {'1': 'columns', '3': 1, '4': 3, '5': 9, '10': 'columns'},
    {
      '1': 'widths',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.config.savedviews.LayoutWidthResponse',
      '10': 'widths'
    },
    {
      '1': 'sort',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.config.savedviews.LayoutSortResponse',
      '10': 'sort'
    },
    {'1': 'group_by', '3': 4, '4': 1, '5': 9, '10': 'groupBy'},
  ],
};

/// Descriptor for `LayoutResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List layoutResponseDescriptor = $convert.base64Decode(
    'Cg5MYXlvdXRSZXNwb25zZRIYCgdjb2x1bW5zGAEgAygJUgdjb2x1bW5zEj4KBndpZHRocxgCIA'
    'MoCzImLmNvbmZpZy5zYXZlZHZpZXdzLkxheW91dFdpZHRoUmVzcG9uc2VSBndpZHRocxI5CgRz'
    'b3J0GAMgAygLMiUuY29uZmlnLnNhdmVkdmlld3MuTGF5b3V0U29ydFJlc3BvbnNlUgRzb3J0Eh'
    'kKCGdyb3VwX2J5GAQgASgJUgdncm91cEJ5');

@$core.Deprecated('Use layoutSortDescriptor instead')
const LayoutSort$json = {
  '1': 'LayoutSort',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'desc', '3': 2, '4': 1, '5': 8, '10': 'desc'},
  ],
};

/// Descriptor for `LayoutSort`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List layoutSortDescriptor = $convert.base64Decode(
    'CgpMYXlvdXRTb3J0EhAKA2tleRgBIAEoCVIDa2V5EhIKBGRlc2MYAiABKAhSBGRlc2M=');

@$core.Deprecated('Use layoutSortResponseDescriptor instead')
const LayoutSortResponse$json = {
  '1': 'LayoutSortResponse',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'desc', '3': 2, '4': 1, '5': 8, '10': 'desc'},
  ],
};

/// Descriptor for `LayoutSortResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List layoutSortResponseDescriptor = $convert.base64Decode(
    'ChJMYXlvdXRTb3J0UmVzcG9uc2USEAoDa2V5GAEgASgJUgNrZXkSEgoEZGVzYxgCIAEoCFIEZG'
    'VzYw==');

@$core.Deprecated('Use layoutWidthDescriptor instead')
const LayoutWidth$json = {
  '1': 'LayoutWidth',
  '2': [
    {'1': 'column', '3': 1, '4': 1, '5': 9, '10': 'column'},
    {'1': 'width', '3': 2, '4': 1, '5': 5, '10': 'width'},
  ],
};

/// Descriptor for `LayoutWidth`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List layoutWidthDescriptor = $convert.base64Decode(
    'CgtMYXlvdXRXaWR0aBIWCgZjb2x1bW4YASABKAlSBmNvbHVtbhIUCgV3aWR0aBgCIAEoBVIFd2'
    'lkdGg=');

@$core.Deprecated('Use layoutWidthResponseDescriptor instead')
const LayoutWidthResponse$json = {
  '1': 'LayoutWidthResponse',
  '2': [
    {'1': 'column', '3': 1, '4': 1, '5': 9, '10': 'column'},
    {'1': 'width', '3': 2, '4': 1, '5': 5, '10': 'width'},
  ],
};

/// Descriptor for `LayoutWidthResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List layoutWidthResponseDescriptor = $convert.base64Decode(
    'ChNMYXlvdXRXaWR0aFJlc3BvbnNlEhYKBmNvbHVtbhgBIAEoCVIGY29sdW1uEhQKBXdpZHRoGA'
    'IgASgFUgV3aWR0aA==');

@$core.Deprecated('Use savedViewDescriptor instead')
const SavedView$json = {
  '1': 'SavedView',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'owner_id', '3': 3, '4': 1, '5': 9, '10': 'ownerId'},
    {'1': 'name', '3': 4, '4': 1, '5': 9, '10': 'name'},
    {'1': 'kind', '3': 5, '4': 1, '5': 9, '10': 'kind'},
    {'1': 'is_shared', '3': 6, '4': 1, '5': 8, '10': 'isShared'},
    {
      '1': 'layout',
      '3': 7,
      '4': 1,
      '5': 11,
      '6': '.config.savedviews.LayoutResponse',
      '10': 'layout'
    },
    {'1': 'version', '3': 8, '4': 1, '5': 5, '10': 'version'},
    {'1': 'updated_at', '3': 9, '4': 1, '5': 9, '10': 'updatedAt'},
    {
      '1': 'board',
      '3': 10,
      '4': 1,
      '5': 11,
      '6': '.config.savedviews.BoardLayoutResponse',
      '10': 'board'
    },
  ],
};

/// Descriptor for `SavedView`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List savedViewDescriptor = $convert.base64Decode(
    'CglTYXZlZFZpZXcSDgoCaWQYASABKAlSAmlkEh0KCnByb2plY3RfaWQYAiABKAlSCXByb2plY3'
    'RJZBIZCghvd25lcl9pZBgDIAEoCVIHb3duZXJJZBISCgRuYW1lGAQgASgJUgRuYW1lEhIKBGtp'
    'bmQYBSABKAlSBGtpbmQSGwoJaXNfc2hhcmVkGAYgASgIUghpc1NoYXJlZBI5CgZsYXlvdXQYBy'
    'ABKAsyIS5jb25maWcuc2F2ZWR2aWV3cy5MYXlvdXRSZXNwb25zZVIGbGF5b3V0EhgKB3ZlcnNp'
    'b24YCCABKAVSB3ZlcnNpb24SHQoKdXBkYXRlZF9hdBgJIAEoCVIJdXBkYXRlZEF0EjwKBWJvYX'
    'JkGAogASgLMiYuY29uZmlnLnNhdmVkdmlld3MuQm9hcmRMYXlvdXRSZXNwb25zZVIFYm9hcmQ=');

@$core.Deprecated('Use viewDeleteRequestDescriptor instead')
const ViewDeleteRequest$json = {
  '1': 'ViewDeleteRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'id', '3': 3, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `ViewDeleteRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List viewDeleteRequestDescriptor = $convert.base64Decode(
    'ChFWaWV3RGVsZXRlUmVxdWVzdBIhCgx3b3Jrc3BhY2VfaWQYASABKAlSC3dvcmtzcGFjZUlkEh'
    '0KCnByb2plY3RfaWQYAiABKAlSCXByb2plY3RJZBIOCgJpZBgDIAEoCVICaWQ=');

@$core.Deprecated('Use viewListDescriptor instead')
const ViewList$json = {
  '1': 'ViewList',
  '2': [
    {
      '1': 'views',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.config.savedviews.SavedView',
      '10': 'views'
    },
  ],
};

/// Descriptor for `ViewList`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List viewListDescriptor = $convert.base64Decode(
    'CghWaWV3TGlzdBIyCgV2aWV3cxgBIAMoCzIcLmNvbmZpZy5zYXZlZHZpZXdzLlNhdmVkVmlld1'
    'IFdmlld3M=');

@$core.Deprecated('Use viewListRequestDescriptor instead')
const ViewListRequest$json = {
  '1': 'ViewListRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'kind', '3': 3, '4': 1, '5': 9, '10': 'kind'},
  ],
};

/// Descriptor for `ViewListRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List viewListRequestDescriptor = $convert.base64Decode(
    'Cg9WaWV3TGlzdFJlcXVlc3QSIQoMd29ya3NwYWNlX2lkGAEgASgJUgt3b3Jrc3BhY2VJZBIdCg'
    'pwcm9qZWN0X2lkGAIgASgJUglwcm9qZWN0SWQSEgoEa2luZBgDIAEoCVIEa2luZA==');

@$core.Deprecated('Use viewSaveRequestDescriptor instead')
const ViewSaveRequest$json = {
  '1': 'ViewSaveRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'id', '3': 3, '4': 1, '5': 9, '10': 'id'},
    {'1': 'expected_version', '3': 4, '4': 1, '5': 5, '10': 'expectedVersion'},
    {'1': 'name', '3': 5, '4': 1, '5': 9, '10': 'name'},
    {'1': 'kind', '3': 6, '4': 1, '5': 9, '10': 'kind'},
    {
      '1': 'layout',
      '3': 7,
      '4': 1,
      '5': 11,
      '6': '.config.savedviews.Layout',
      '10': 'layout'
    },
    {'1': 'shared', '3': 8, '4': 1, '5': 8, '10': 'shared'},
    {
      '1': 'board',
      '3': 9,
      '4': 1,
      '5': 11,
      '6': '.config.savedviews.BoardLayout',
      '10': 'board'
    },
  ],
};

/// Descriptor for `ViewSaveRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List viewSaveRequestDescriptor = $convert.base64Decode(
    'Cg9WaWV3U2F2ZVJlcXVlc3QSIQoMd29ya3NwYWNlX2lkGAEgASgJUgt3b3Jrc3BhY2VJZBIdCg'
    'pwcm9qZWN0X2lkGAIgASgJUglwcm9qZWN0SWQSDgoCaWQYAyABKAlSAmlkEikKEGV4cGVjdGVk'
    'X3ZlcnNpb24YBCABKAVSD2V4cGVjdGVkVmVyc2lvbhISCgRuYW1lGAUgASgJUgRuYW1lEhIKBG'
    'tpbmQYBiABKAlSBGtpbmQSMQoGbGF5b3V0GAcgASgLMhkuY29uZmlnLnNhdmVkdmlld3MuTGF5'
    'b3V0UgZsYXlvdXQSFgoGc2hhcmVkGAggASgIUgZzaGFyZWQSNAoFYm9hcmQYCSABKAsyHi5jb2'
    '5maWcuc2F2ZWR2aWV3cy5Cb2FyZExheW91dFIFYm9hcmQ=');
