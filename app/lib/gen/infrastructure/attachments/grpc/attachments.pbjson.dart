// This is a generated file - do not edit.
//
// Generated from infrastructure/attachments/grpc/attachments.proto.

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

@$core.Deprecated('Use attachmentDescriptor instead')
const Attachment$json = {
  '1': 'Attachment',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'task_id', '3': 2, '4': 1, '5': 9, '10': 'taskId'},
    {'1': 'comment_id', '3': 3, '4': 1, '5': 9, '10': 'commentId'},
    {'1': 'uploader_id', '3': 4, '4': 1, '5': 9, '10': 'uploaderId'},
    {'1': 'filename', '3': 5, '4': 1, '5': 9, '10': 'filename'},
    {'1': 'mime', '3': 6, '4': 1, '5': 9, '10': 'mime'},
    {'1': 'size', '3': 7, '4': 1, '5': 3, '10': 'size'},
    {'1': 'has_thumb', '3': 8, '4': 1, '5': 8, '10': 'hasThumb'},
    {'1': 'created_at', '3': 9, '4': 1, '5': 9, '10': 'createdAt'},
  ],
};

/// Descriptor for `Attachment`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List attachmentDescriptor = $convert.base64Decode(
    'CgpBdHRhY2htZW50Eg4KAmlkGAEgASgJUgJpZBIXCgd0YXNrX2lkGAIgASgJUgZ0YXNrSWQSHQ'
    'oKY29tbWVudF9pZBgDIAEoCVIJY29tbWVudElkEh8KC3VwbG9hZGVyX2lkGAQgASgJUgp1cGxv'
    'YWRlcklkEhoKCGZpbGVuYW1lGAUgASgJUghmaWxlbmFtZRISCgRtaW1lGAYgASgJUgRtaW1lEh'
    'IKBHNpemUYByABKANSBHNpemUSGwoJaGFzX3RodW1iGAggASgIUghoYXNUaHVtYhIdCgpjcmVh'
    'dGVkX2F0GAkgASgJUgljcmVhdGVkQXQ=');

@$core.Deprecated('Use attachmentDeleteRequestDescriptor instead')
const AttachmentDeleteRequest$json = {
  '1': 'AttachmentDeleteRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'id', '3': 3, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `AttachmentDeleteRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List attachmentDeleteRequestDescriptor = $convert.base64Decode(
    'ChdBdHRhY2htZW50RGVsZXRlUmVxdWVzdBIhCgx3b3Jrc3BhY2VfaWQYASABKAlSC3dvcmtzcG'
    'FjZUlkEh0KCnByb2plY3RfaWQYAiABKAlSCXByb2plY3RJZBIOCgJpZBgDIAEoCVICaWQ=');

@$core.Deprecated('Use attachmentListDescriptor instead')
const AttachmentList$json = {
  '1': 'AttachmentList',
  '2': [
    {
      '1': 'attachments',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.config.attachments.Attachment',
      '10': 'attachments'
    },
  ],
};

/// Descriptor for `AttachmentList`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List attachmentListDescriptor = $convert.base64Decode(
    'Cg5BdHRhY2htZW50TGlzdBJACgthdHRhY2htZW50cxgBIAMoCzIeLmNvbmZpZy5hdHRhY2htZW'
    '50cy5BdHRhY2htZW50UgthdHRhY2htZW50cw==');

@$core.Deprecated('Use attachmentListRequestDescriptor instead')
const AttachmentListRequest$json = {
  '1': 'AttachmentListRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'task_id', '3': 3, '4': 1, '5': 9, '10': 'taskId'},
  ],
};

/// Descriptor for `AttachmentListRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List attachmentListRequestDescriptor = $convert.base64Decode(
    'ChVBdHRhY2htZW50TGlzdFJlcXVlc3QSIQoMd29ya3NwYWNlX2lkGAEgASgJUgt3b3Jrc3BhY2'
    'VJZBIdCgpwcm9qZWN0X2lkGAIgASgJUglwcm9qZWN0SWQSFwoHdGFza19pZBgDIAEoCVIGdGFz'
    'a0lk');

@$core.Deprecated('Use storageUsageDescriptor instead')
const StorageUsage$json = {
  '1': 'StorageUsage',
  '2': [
    {'1': 'used_bytes', '3': 1, '4': 1, '5': 3, '10': 'usedBytes'},
    {'1': 'quota_bytes', '3': 2, '4': 1, '5': 3, '10': 'quotaBytes'},
    {'1': 'file_count', '3': 3, '4': 1, '5': 5, '10': 'fileCount'},
    {'1': 'max_file_bytes', '3': 4, '4': 1, '5': 3, '10': 'maxFileBytes'},
  ],
};

/// Descriptor for `StorageUsage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List storageUsageDescriptor = $convert.base64Decode(
    'CgxTdG9yYWdlVXNhZ2USHQoKdXNlZF9ieXRlcxgBIAEoA1IJdXNlZEJ5dGVzEh8KC3F1b3RhX2'
    'J5dGVzGAIgASgDUgpxdW90YUJ5dGVzEh0KCmZpbGVfY291bnQYAyABKAVSCWZpbGVDb3VudBIk'
    'Cg5tYXhfZmlsZV9ieXRlcxgEIAEoA1IMbWF4RmlsZUJ5dGVz');

@$core.Deprecated('Use usageRequestDescriptor instead')
const UsageRequest$json = {
  '1': 'UsageRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
  ],
};

/// Descriptor for `UsageRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List usageRequestDescriptor = $convert.base64Decode(
    'CgxVc2FnZVJlcXVlc3QSIQoMd29ya3NwYWNlX2lkGAEgASgJUgt3b3Jrc3BhY2VJZA==');
