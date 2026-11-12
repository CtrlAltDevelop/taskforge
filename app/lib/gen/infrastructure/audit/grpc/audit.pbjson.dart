// This is a generated file - do not edit.
//
// Generated from infrastructure/audit/grpc/audit.proto.

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

@$core.Deprecated('Use activityForTaskRequestDescriptor instead')
const ActivityForTaskRequest$json = {
  '1': 'ActivityForTaskRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'task_id', '3': 3, '4': 1, '5': 9, '10': 'taskId'},
    {'1': 'before', '3': 4, '4': 1, '5': 3, '10': 'before'},
    {'1': 'limit', '3': 5, '4': 1, '5': 5, '10': 'limit'},
  ],
};

/// Descriptor for `ActivityForTaskRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List activityForTaskRequestDescriptor = $convert.base64Decode(
    'ChZBY3Rpdml0eUZvclRhc2tSZXF1ZXN0EiEKDHdvcmtzcGFjZV9pZBgBIAEoCVILd29ya3NwYW'
    'NlSWQSHQoKcHJvamVjdF9pZBgCIAEoCVIJcHJvamVjdElkEhcKB3Rhc2tfaWQYAyABKAlSBnRh'
    'c2tJZBIWCgZiZWZvcmUYBCABKANSBmJlZm9yZRIUCgVsaW1pdBgFIAEoBVIFbGltaXQ=');

@$core.Deprecated('Use auditEntryDescriptor instead')
const AuditEntry$json = {
  '1': 'AuditEntry',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 3, '10': 'id'},
    {'1': 'at', '3': 2, '4': 1, '5': 9, '10': 'at'},
    {'1': 'actor', '3': 3, '4': 1, '5': 9, '10': 'actor'},
    {'1': 'actor_name', '3': 4, '4': 1, '5': 9, '10': 'actorName'},
    {'1': 'actor_type', '3': 5, '4': 1, '5': 9, '10': 'actorType'},
    {'1': 'action', '3': 6, '4': 1, '5': 9, '10': 'action'},
    {'1': 'target_type', '3': 7, '4': 1, '5': 9, '10': 'targetType'},
    {'1': 'target_id', '3': 8, '4': 1, '5': 9, '10': 'targetId'},
    {'1': 'project_id', '3': 9, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'batch_id', '3': 10, '4': 1, '5': 9, '10': 'batchId'},
    {'1': 'ip', '3': 11, '4': 1, '5': 9, '10': 'ip'},
    {'1': 'user_agent', '3': 12, '4': 1, '5': 9, '10': 'userAgent'},
    {'1': 'changes_json', '3': 13, '4': 1, '5': 9, '10': 'changesJson'},
  ],
};

/// Descriptor for `AuditEntry`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List auditEntryDescriptor = $convert.base64Decode(
    'CgpBdWRpdEVudHJ5Eg4KAmlkGAEgASgDUgJpZBIOCgJhdBgCIAEoCVICYXQSFAoFYWN0b3IYAy'
    'ABKAlSBWFjdG9yEh0KCmFjdG9yX25hbWUYBCABKAlSCWFjdG9yTmFtZRIdCgphY3Rvcl90eXBl'
    'GAUgASgJUglhY3RvclR5cGUSFgoGYWN0aW9uGAYgASgJUgZhY3Rpb24SHwoLdGFyZ2V0X3R5cG'
    'UYByABKAlSCnRhcmdldFR5cGUSGwoJdGFyZ2V0X2lkGAggASgJUgh0YXJnZXRJZBIdCgpwcm9q'
    'ZWN0X2lkGAkgASgJUglwcm9qZWN0SWQSGQoIYmF0Y2hfaWQYCiABKAlSB2JhdGNoSWQSDgoCaX'
    'AYCyABKAlSAmlwEh0KCnVzZXJfYWdlbnQYDCABKAlSCXVzZXJBZ2VudBIhCgxjaGFuZ2VzX2pz'
    'b24YDSABKAlSC2NoYW5nZXNKc29u');

@$core.Deprecated('Use auditExportChunkDescriptor instead')
const AuditExportChunk$json = {
  '1': 'AuditExportChunk',
  '2': [
    {'1': 'csv', '3': 1, '4': 1, '5': 9, '10': 'csv'},
  ],
};

/// Descriptor for `AuditExportChunk`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List auditExportChunkDescriptor =
    $convert.base64Decode('ChBBdWRpdEV4cG9ydENodW5rEhAKA2NzdhgBIAEoCVIDY3N2');

@$core.Deprecated('Use auditExportRequestDescriptor instead')
const AuditExportRequest$json = {
  '1': 'AuditExportRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'actor', '3': 2, '4': 1, '5': 9, '10': 'actor'},
    {'1': 'action', '3': 3, '4': 1, '5': 9, '10': 'action'},
    {'1': 'target_type', '3': 4, '4': 1, '5': 9, '10': 'targetType'},
    {'1': 'target_id', '3': 5, '4': 1, '5': 9, '10': 'targetId'},
    {'1': 'project_id', '3': 6, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'since', '3': 7, '4': 1, '5': 9, '10': 'since'},
    {'1': 'until', '3': 8, '4': 1, '5': 9, '10': 'until'},
  ],
};

/// Descriptor for `AuditExportRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List auditExportRequestDescriptor = $convert.base64Decode(
    'ChJBdWRpdEV4cG9ydFJlcXVlc3QSIQoMd29ya3NwYWNlX2lkGAEgASgJUgt3b3Jrc3BhY2VJZB'
    'IUCgVhY3RvchgCIAEoCVIFYWN0b3ISFgoGYWN0aW9uGAMgASgJUgZhY3Rpb24SHwoLdGFyZ2V0'
    'X3R5cGUYBCABKAlSCnRhcmdldFR5cGUSGwoJdGFyZ2V0X2lkGAUgASgJUgh0YXJnZXRJZBIdCg'
    'pwcm9qZWN0X2lkGAYgASgJUglwcm9qZWN0SWQSFAoFc2luY2UYByABKAlSBXNpbmNlEhQKBXVu'
    'dGlsGAggASgJUgV1bnRpbA==');

@$core.Deprecated('Use auditListRequestDescriptor instead')
const AuditListRequest$json = {
  '1': 'AuditListRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'actor', '3': 2, '4': 1, '5': 9, '10': 'actor'},
    {'1': 'action', '3': 3, '4': 1, '5': 9, '10': 'action'},
    {'1': 'target_type', '3': 4, '4': 1, '5': 9, '10': 'targetType'},
    {'1': 'target_id', '3': 5, '4': 1, '5': 9, '10': 'targetId'},
    {'1': 'project_id', '3': 6, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'since', '3': 7, '4': 1, '5': 9, '10': 'since'},
    {'1': 'until', '3': 8, '4': 1, '5': 9, '10': 'until'},
    {'1': 'before', '3': 9, '4': 1, '5': 3, '10': 'before'},
    {'1': 'limit', '3': 10, '4': 1, '5': 5, '10': 'limit'},
  ],
};

/// Descriptor for `AuditListRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List auditListRequestDescriptor = $convert.base64Decode(
    'ChBBdWRpdExpc3RSZXF1ZXN0EiEKDHdvcmtzcGFjZV9pZBgBIAEoCVILd29ya3NwYWNlSWQSFA'
    'oFYWN0b3IYAiABKAlSBWFjdG9yEhYKBmFjdGlvbhgDIAEoCVIGYWN0aW9uEh8KC3RhcmdldF90'
    'eXBlGAQgASgJUgp0YXJnZXRUeXBlEhsKCXRhcmdldF9pZBgFIAEoCVIIdGFyZ2V0SWQSHQoKcH'
    'JvamVjdF9pZBgGIAEoCVIJcHJvamVjdElkEhQKBXNpbmNlGAcgASgJUgVzaW5jZRIUCgV1bnRp'
    'bBgIIAEoCVIFdW50aWwSFgoGYmVmb3JlGAkgASgDUgZiZWZvcmUSFAoFbGltaXQYCiABKAVSBW'
    'xpbWl0');

@$core.Deprecated('Use auditPageDescriptor instead')
const AuditPage$json = {
  '1': 'AuditPage',
  '2': [
    {
      '1': 'entries',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.config.audit.AuditEntry',
      '10': 'entries'
    },
    {
      '1': 'labels',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.config.audit.Label',
      '10': 'labels'
    },
    {'1': 'next_before', '3': 3, '4': 1, '5': 3, '10': 'nextBefore'},
  ],
};

/// Descriptor for `AuditPage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List auditPageDescriptor = $convert.base64Decode(
    'CglBdWRpdFBhZ2USMgoHZW50cmllcxgBIAMoCzIYLmNvbmZpZy5hdWRpdC5BdWRpdEVudHJ5Ug'
    'dlbnRyaWVzEisKBmxhYmVscxgCIAMoCzITLmNvbmZpZy5hdWRpdC5MYWJlbFIGbGFiZWxzEh8K'
    'C25leHRfYmVmb3JlGAMgASgDUgpuZXh0QmVmb3Jl');

@$core.Deprecated('Use labelDescriptor instead')
const Label$json = {
  '1': 'Label',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
  ],
};

/// Descriptor for `Label`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List labelDescriptor = $convert.base64Decode(
    'CgVMYWJlbBIOCgJpZBgBIAEoCVICaWQSEgoEbmFtZRgCIAEoCVIEbmFtZQ==');
