// This is a generated file - do not edit.
//
// Generated from infrastructure/imports/grpc/imports.proto.

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

@$core.Deprecated('Use exportJobDescriptor instead')
const ExportJob$json = {
  '1': 'ExportJob',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'scope', '3': 2, '4': 1, '5': 9, '10': 'scope'},
    {'1': 'project_id', '3': 3, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'status', '3': 4, '4': 1, '5': 9, '10': 'status'},
    {'1': 'filename', '3': 5, '4': 1, '5': 9, '10': 'filename'},
    {'1': 'size', '3': 6, '4': 1, '5': 5, '10': 'size'},
    {'1': 'stats_json', '3': 7, '4': 1, '5': 9, '10': 'statsJson'},
    {'1': 'error', '3': 8, '4': 1, '5': 9, '10': 'error'},
    {'1': 'download_path', '3': 9, '4': 1, '5': 9, '10': 'downloadPath'},
    {'1': 'created_at', '3': 10, '4': 1, '5': 9, '10': 'createdAt'},
  ],
};

/// Descriptor for `ExportJob`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List exportJobDescriptor = $convert.base64Decode(
    'CglFeHBvcnRKb2ISDgoCaWQYASABKAlSAmlkEhQKBXNjb3BlGAIgASgJUgVzY29wZRIdCgpwcm'
    '9qZWN0X2lkGAMgASgJUglwcm9qZWN0SWQSFgoGc3RhdHVzGAQgASgJUgZzdGF0dXMSGgoIZmls'
    'ZW5hbWUYBSABKAlSCGZpbGVuYW1lEhIKBHNpemUYBiABKAVSBHNpemUSHQoKc3RhdHNfanNvbh'
    'gHIAEoCVIJc3RhdHNKc29uEhQKBWVycm9yGAggASgJUgVlcnJvchIjCg1kb3dubG9hZF9wYXRo'
    'GAkgASgJUgxkb3dubG9hZFBhdGgSHQoKY3JlYXRlZF9hdBgKIAEoCVIJY3JlYXRlZEF0');

@$core.Deprecated('Use exportStartRequestDescriptor instead')
const ExportStartRequest$json = {
  '1': 'ExportStartRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
  ],
};

/// Descriptor for `ExportStartRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List exportStartRequestDescriptor = $convert.base64Decode(
    'ChJFeHBvcnRTdGFydFJlcXVlc3QSIQoMd29ya3NwYWNlX2lkGAEgASgJUgt3b3Jrc3BhY2VJZB'
    'IdCgpwcm9qZWN0X2lkGAIgASgJUglwcm9qZWN0SWQ=');

@$core.Deprecated('Use exportStartedDescriptor instead')
const ExportStarted$json = {
  '1': 'ExportStarted',
  '2': [
    {
      '1': 'export',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.config.imports.ExportJob',
      '10': 'export'
    },
  ],
};

/// Descriptor for `ExportStarted`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List exportStartedDescriptor = $convert.base64Decode(
    'Cg1FeHBvcnRTdGFydGVkEjEKBmV4cG9ydBgBIAEoCzIZLmNvbmZpZy5pbXBvcnRzLkV4cG9ydE'
    'pvYlIGZXhwb3J0');

@$core.Deprecated('Use exportStatusDescriptor instead')
const ExportStatus$json = {
  '1': 'ExportStatus',
  '2': [
    {
      '1': 'export',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.config.imports.ExportJob',
      '10': 'export'
    },
  ],
};

/// Descriptor for `ExportStatus`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List exportStatusDescriptor = $convert.base64Decode(
    'CgxFeHBvcnRTdGF0dXMSMQoGZXhwb3J0GAEgASgLMhkuY29uZmlnLmltcG9ydHMuRXhwb3J0Sm'
    '9iUgZleHBvcnQ=');

@$core.Deprecated('Use exportStatusRequestDescriptor instead')
const ExportStatusRequest$json = {
  '1': 'ExportStatusRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'export_id', '3': 2, '4': 1, '5': 9, '10': 'exportId'},
  ],
};

/// Descriptor for `ExportStatusRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List exportStatusRequestDescriptor = $convert.base64Decode(
    'ChNFeHBvcnRTdGF0dXNSZXF1ZXN0EiEKDHdvcmtzcGFjZV9pZBgBIAEoCVILd29ya3NwYWNlSW'
    'QSGwoJZXhwb3J0X2lkGAIgASgJUghleHBvcnRJZA==');

@$core.Deprecated('Use importAnalyzeRequestDescriptor instead')
const ImportAnalyzeRequest$json = {
  '1': 'ImportAnalyzeRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'job_id', '3': 2, '4': 1, '5': 9, '10': 'jobId'},
    {'1': 'source', '3': 3, '4': 1, '5': 9, '10': 'source'},
    {'1': 'member', '3': 4, '4': 1, '5': 9, '10': 'member'},
  ],
};

/// Descriptor for `ImportAnalyzeRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List importAnalyzeRequestDescriptor = $convert.base64Decode(
    'ChRJbXBvcnRBbmFseXplUmVxdWVzdBIhCgx3b3Jrc3BhY2VfaWQYASABKAlSC3dvcmtzcGFjZU'
    'lkEhUKBmpvYl9pZBgCIAEoCVIFam9iSWQSFgoGc291cmNlGAMgASgJUgZzb3VyY2USFgoGbWVt'
    'YmVyGAQgASgJUgZtZW1iZXI=');

@$core.Deprecated('Use importCancelRequestDescriptor instead')
const ImportCancelRequest$json = {
  '1': 'ImportCancelRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'job_id', '3': 2, '4': 1, '5': 9, '10': 'jobId'},
  ],
};

/// Descriptor for `ImportCancelRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List importCancelRequestDescriptor = $convert.base64Decode(
    'ChNJbXBvcnRDYW5jZWxSZXF1ZXN0EiEKDHdvcmtzcGFjZV9pZBgBIAEoCVILd29ya3NwYWNlSW'
    'QSFQoGam9iX2lkGAIgASgJUgVqb2JJZA==');

@$core.Deprecated('Use importCancelledDescriptor instead')
const ImportCancelled$json = {
  '1': 'ImportCancelled',
  '2': [
    {
      '1': 'job',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.config.imports.Job',
      '10': 'job'
    },
  ],
};

/// Descriptor for `ImportCancelled`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List importCancelledDescriptor = $convert.base64Decode(
    'Cg9JbXBvcnRDYW5jZWxsZWQSJQoDam9iGAEgASgLMhMuY29uZmlnLmltcG9ydHMuSm9iUgNqb2'
    'I=');

@$core.Deprecated('Use importDetailDescriptor instead')
const ImportDetail$json = {
  '1': 'ImportDetail',
  '2': [
    {
      '1': 'job',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.config.imports.Job',
      '10': 'job'
    },
    {
      '1': 'problems',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.config.imports.Problem',
      '10': 'problems'
    },
    {'1': 'mapping_json', '3': 3, '4': 1, '5': 9, '10': 'mappingJson'},
    {'1': 'analysis_json', '3': 4, '4': 1, '5': 9, '10': 'analysisJson'},
  ],
};

/// Descriptor for `ImportDetail`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List importDetailDescriptor = $convert.base64Decode(
    'CgxJbXBvcnREZXRhaWwSJQoDam9iGAEgASgLMhMuY29uZmlnLmltcG9ydHMuSm9iUgNqb2ISMw'
    'oIcHJvYmxlbXMYAiADKAsyFy5jb25maWcuaW1wb3J0cy5Qcm9ibGVtUghwcm9ibGVtcxIhCgxt'
    'YXBwaW5nX2pzb24YAyABKAlSC21hcHBpbmdKc29uEiMKDWFuYWx5c2lzX2pzb24YBCABKAlSDG'
    'FuYWx5c2lzSnNvbg==');

@$core.Deprecated('Use importDiscardRequestDescriptor instead')
const ImportDiscardRequest$json = {
  '1': 'ImportDiscardRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'job_id', '3': 2, '4': 1, '5': 9, '10': 'jobId'},
  ],
};

/// Descriptor for `ImportDiscardRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List importDiscardRequestDescriptor = $convert.base64Decode(
    'ChRJbXBvcnREaXNjYXJkUmVxdWVzdBIhCgx3b3Jrc3BhY2VfaWQYASABKAlSC3dvcmtzcGFjZU'
    'lkEhUKBmpvYl9pZBgCIAEoCVIFam9iSWQ=');

@$core.Deprecated('Use importDiscardedDescriptor instead')
const ImportDiscarded$json = {
  '1': 'ImportDiscarded',
  '2': [
    {'1': 'job_id', '3': 1, '4': 1, '5': 9, '10': 'jobId'},
  ],
};

/// Descriptor for `ImportDiscarded`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List importDiscardedDescriptor = $convert
    .base64Decode('Cg9JbXBvcnREaXNjYXJkZWQSFQoGam9iX2lkGAEgASgJUgVqb2JJZA==');

@$core.Deprecated('Use importDryRunRequestDescriptor instead')
const ImportDryRunRequest$json = {
  '1': 'ImportDryRunRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'job_id', '3': 2, '4': 1, '5': 9, '10': 'jobId'},
    {'1': 'mapping_json', '3': 3, '4': 1, '5': 9, '10': 'mappingJson'},
  ],
};

/// Descriptor for `ImportDryRunRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List importDryRunRequestDescriptor = $convert.base64Decode(
    'ChNJbXBvcnREcnlSdW5SZXF1ZXN0EiEKDHdvcmtzcGFjZV9pZBgBIAEoCVILd29ya3NwYWNlSW'
    'QSFQoGam9iX2lkGAIgASgJUgVqb2JJZBIhCgxtYXBwaW5nX2pzb24YAyABKAlSC21hcHBpbmdK'
    'c29u');

@$core.Deprecated('Use importGetRequestDescriptor instead')
const ImportGetRequest$json = {
  '1': 'ImportGetRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'job_id', '3': 2, '4': 1, '5': 9, '10': 'jobId'},
  ],
};

/// Descriptor for `ImportGetRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List importGetRequestDescriptor = $convert.base64Decode(
    'ChBJbXBvcnRHZXRSZXF1ZXN0EiEKDHdvcmtzcGFjZV9pZBgBIAEoCVILd29ya3NwYWNlSWQSFQ'
    'oGam9iX2lkGAIgASgJUgVqb2JJZA==');

@$core.Deprecated('Use importListDescriptor instead')
const ImportList$json = {
  '1': 'ImportList',
  '2': [
    {
      '1': 'jobs',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.config.imports.Job',
      '10': 'jobs'
    },
  ],
};

/// Descriptor for `ImportList`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List importListDescriptor = $convert.base64Decode(
    'CgpJbXBvcnRMaXN0EicKBGpvYnMYASADKAsyEy5jb25maWcuaW1wb3J0cy5Kb2JSBGpvYnM=');

@$core.Deprecated('Use importListRequestDescriptor instead')
const ImportListRequest$json = {
  '1': 'ImportListRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
  ],
};

/// Descriptor for `ImportListRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List importListRequestDescriptor = $convert.base64Decode(
    'ChFJbXBvcnRMaXN0UmVxdWVzdBIhCgx3b3Jrc3BhY2VfaWQYASABKAlSC3dvcmtzcGFjZUlk');

@$core.Deprecated('Use importProgressDescriptor instead')
const ImportProgress$json = {
  '1': 'ImportProgress',
  '2': [
    {
      '1': 'job',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.config.imports.Job',
      '10': 'job'
    },
  ],
};

/// Descriptor for `ImportProgress`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List importProgressDescriptor = $convert.base64Decode(
    'Cg5JbXBvcnRQcm9ncmVzcxIlCgNqb2IYASABKAsyEy5jb25maWcuaW1wb3J0cy5Kb2JSA2pvYg'
    '==');

@$core.Deprecated('Use importProgressRequestDescriptor instead')
const ImportProgressRequest$json = {
  '1': 'ImportProgressRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'job_id', '3': 2, '4': 1, '5': 9, '10': 'jobId'},
  ],
};

/// Descriptor for `ImportProgressRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List importProgressRequestDescriptor = $convert.base64Decode(
    'ChVJbXBvcnRQcm9ncmVzc1JlcXVlc3QSIQoMd29ya3NwYWNlX2lkGAEgASgJUgt3b3Jrc3BhY2'
    'VJZBIVCgZqb2JfaWQYAiABKAlSBWpvYklk');

@$core.Deprecated('Use importProposalDescriptor instead')
const ImportProposal$json = {
  '1': 'ImportProposal',
  '2': [
    {
      '1': 'job',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.config.imports.Job',
      '10': 'job'
    },
    {'1': 'mapping_json', '3': 2, '4': 1, '5': 9, '10': 'mappingJson'},
    {'1': 'analysis_json', '3': 3, '4': 1, '5': 9, '10': 'analysisJson'},
    {'1': 'members', '3': 4, '4': 3, '5': 9, '10': 'members'},
  ],
};

/// Descriptor for `ImportProposal`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List importProposalDescriptor = $convert.base64Decode(
    'Cg5JbXBvcnRQcm9wb3NhbBIlCgNqb2IYASABKAsyEy5jb25maWcuaW1wb3J0cy5Kb2JSA2pvYh'
    'IhCgxtYXBwaW5nX2pzb24YAiABKAlSC21hcHBpbmdKc29uEiMKDWFuYWx5c2lzX2pzb24YAyAB'
    'KAlSDGFuYWx5c2lzSnNvbhIYCgdtZW1iZXJzGAQgAygJUgdtZW1iZXJz');

@$core.Deprecated('Use importReportDescriptor instead')
const ImportReport$json = {
  '1': 'ImportReport',
  '2': [
    {'1': 'counts_json', '3': 1, '4': 1, '5': 9, '10': 'countsJson'},
    {
      '1': 'warnings',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.config.imports.Problem',
      '10': 'warnings'
    },
    {'1': 'errors', '3': 3, '4': 1, '5': 5, '10': 'errors'},
    {'1': 'warning_total', '3': 4, '4': 1, '5': 5, '10': 'warningTotal'},
    {'1': 'already_imported', '3': 5, '4': 1, '5': 5, '10': 'alreadyImported'},
  ],
};

/// Descriptor for `ImportReport`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List importReportDescriptor = $convert.base64Decode(
    'CgxJbXBvcnRSZXBvcnQSHwoLY291bnRzX2pzb24YASABKAlSCmNvdW50c0pzb24SMwoId2Fybm'
    'luZ3MYAiADKAsyFy5jb25maWcuaW1wb3J0cy5Qcm9ibGVtUgh3YXJuaW5ncxIWCgZlcnJvcnMY'
    'AyABKAVSBmVycm9ycxIjCg13YXJuaW5nX3RvdGFsGAQgASgFUgx3YXJuaW5nVG90YWwSKQoQYW'
    'xyZWFkeV9pbXBvcnRlZBgFIAEoBVIPYWxyZWFkeUltcG9ydGVk');

@$core.Deprecated('Use importStartRequestDescriptor instead')
const ImportStartRequest$json = {
  '1': 'ImportStartRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'job_id', '3': 2, '4': 1, '5': 9, '10': 'jobId'},
    {'1': 'mapping_json', '3': 3, '4': 1, '5': 9, '10': 'mappingJson'},
  ],
};

/// Descriptor for `ImportStartRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List importStartRequestDescriptor = $convert.base64Decode(
    'ChJJbXBvcnRTdGFydFJlcXVlc3QSIQoMd29ya3NwYWNlX2lkGAEgASgJUgt3b3Jrc3BhY2VJZB'
    'IVCgZqb2JfaWQYAiABKAlSBWpvYklkEiEKDG1hcHBpbmdfanNvbhgDIAEoCVILbWFwcGluZ0pz'
    'b24=');

@$core.Deprecated('Use importStartedDescriptor instead')
const ImportStarted$json = {
  '1': 'ImportStarted',
  '2': [
    {
      '1': 'job',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.config.imports.Job',
      '10': 'job'
    },
  ],
};

/// Descriptor for `ImportStarted`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List importStartedDescriptor = $convert.base64Decode(
    'Cg1JbXBvcnRTdGFydGVkEiUKA2pvYhgBIAEoCzITLmNvbmZpZy5pbXBvcnRzLkpvYlIDam9i');

@$core.Deprecated('Use importUndoRequestDescriptor instead')
const ImportUndoRequest$json = {
  '1': 'ImportUndoRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'job_id', '3': 2, '4': 1, '5': 9, '10': 'jobId'},
  ],
};

/// Descriptor for `ImportUndoRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List importUndoRequestDescriptor = $convert.base64Decode(
    'ChFJbXBvcnRVbmRvUmVxdWVzdBIhCgx3b3Jrc3BhY2VfaWQYASABKAlSC3dvcmtzcGFjZUlkEh'
    'UKBmpvYl9pZBgCIAEoCVIFam9iSWQ=');

@$core.Deprecated('Use importUndoneDescriptor instead')
const ImportUndone$json = {
  '1': 'ImportUndone',
  '2': [
    {
      '1': 'job',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.config.imports.Job',
      '10': 'job'
    },
    {'1': 'removed_json', '3': 2, '4': 1, '5': 9, '10': 'removedJson'},
  ],
};

/// Descriptor for `ImportUndone`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List importUndoneDescriptor = $convert.base64Decode(
    'CgxJbXBvcnRVbmRvbmUSJQoDam9iGAEgASgLMhMuY29uZmlnLmltcG9ydHMuSm9iUgNqb2ISIQ'
    'oMcmVtb3ZlZF9qc29uGAIgASgJUgtyZW1vdmVkSnNvbg==');

@$core.Deprecated('Use jobDescriptor instead')
const Job$json = {
  '1': 'Job',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'source', '3': 2, '4': 1, '5': 9, '10': 'source'},
    {'1': 'status', '3': 3, '4': 1, '5': 9, '10': 'status'},
    {'1': 'filename', '3': 4, '4': 1, '5': 9, '10': 'filename'},
    {'1': 'project_id', '3': 5, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'total', '3': 6, '4': 1, '5': 5, '10': 'total'},
    {'1': 'done', '3': 7, '4': 1, '5': 5, '10': 'done'},
    {'1': 'phase', '3': 8, '4': 1, '5': 9, '10': 'phase'},
    {'1': 'error', '3': 9, '4': 1, '5': 9, '10': 'error'},
    {'1': 'stats_json', '3': 10, '4': 1, '5': 9, '10': 'statsJson'},
    {'1': 'problem_count', '3': 11, '4': 1, '5': 5, '10': 'problemCount'},
    {'1': 'created_at', '3': 12, '4': 1, '5': 9, '10': 'createdAt'},
    {'1': 'started_at', '3': 13, '4': 1, '5': 9, '10': 'startedAt'},
    {'1': 'finished_at', '3': 14, '4': 1, '5': 9, '10': 'finishedAt'},
    {'1': 'version', '3': 15, '4': 1, '5': 5, '10': 'version'},
  ],
};

/// Descriptor for `Job`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List jobDescriptor = $convert.base64Decode(
    'CgNKb2ISDgoCaWQYASABKAlSAmlkEhYKBnNvdXJjZRgCIAEoCVIGc291cmNlEhYKBnN0YXR1cx'
    'gDIAEoCVIGc3RhdHVzEhoKCGZpbGVuYW1lGAQgASgJUghmaWxlbmFtZRIdCgpwcm9qZWN0X2lk'
    'GAUgASgJUglwcm9qZWN0SWQSFAoFdG90YWwYBiABKAVSBXRvdGFsEhIKBGRvbmUYByABKAVSBG'
    'RvbmUSFAoFcGhhc2UYCCABKAlSBXBoYXNlEhQKBWVycm9yGAkgASgJUgVlcnJvchIdCgpzdGF0'
    'c19qc29uGAogASgJUglzdGF0c0pzb24SIwoNcHJvYmxlbV9jb3VudBgLIAEoBVIMcHJvYmxlbU'
    'NvdW50Eh0KCmNyZWF0ZWRfYXQYDCABKAlSCWNyZWF0ZWRBdBIdCgpzdGFydGVkX2F0GA0gASgJ'
    'UglzdGFydGVkQXQSHwoLZmluaXNoZWRfYXQYDiABKAlSCmZpbmlzaGVkQXQSGAoHdmVyc2lvbh'
    'gPIAEoBVIHdmVyc2lvbg==');

@$core.Deprecated('Use placeholderDescriptor instead')
const Placeholder$json = {
  '1': 'Placeholder',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'email', '3': 3, '4': 1, '5': 9, '10': 'email'},
    {'1': 'tasks', '3': 4, '4': 1, '5': 5, '10': 'tasks'},
  ],
};

/// Descriptor for `Placeholder`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List placeholderDescriptor = $convert.base64Decode(
    'CgtQbGFjZWhvbGRlchIOCgJpZBgBIAEoCVICaWQSEgoEbmFtZRgCIAEoCVIEbmFtZRIUCgVlbW'
    'FpbBgDIAEoCVIFZW1haWwSFAoFdGFza3MYBCABKAVSBXRhc2tz');

@$core.Deprecated('Use placeholderClaimRequestDescriptor instead')
const PlaceholderClaimRequest$json = {
  '1': 'PlaceholderClaimRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'placeholder_id', '3': 2, '4': 1, '5': 9, '10': 'placeholderId'},
    {'1': 'user_id', '3': 3, '4': 1, '5': 9, '10': 'userId'},
  ],
};

/// Descriptor for `PlaceholderClaimRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List placeholderClaimRequestDescriptor = $convert.base64Decode(
    'ChdQbGFjZWhvbGRlckNsYWltUmVxdWVzdBIhCgx3b3Jrc3BhY2VfaWQYASABKAlSC3dvcmtzcG'
    'FjZUlkEiUKDnBsYWNlaG9sZGVyX2lkGAIgASgJUg1wbGFjZWhvbGRlcklkEhcKB3VzZXJfaWQY'
    'AyABKAlSBnVzZXJJZA==');

@$core.Deprecated('Use placeholderClaimedDescriptor instead')
const PlaceholderClaimed$json = {
  '1': 'PlaceholderClaimed',
  '2': [
    {'1': 'assigned', '3': 1, '4': 1, '5': 5, '10': 'assigned'},
  ],
};

/// Descriptor for `PlaceholderClaimed`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List placeholderClaimedDescriptor =
    $convert.base64Decode(
        'ChJQbGFjZWhvbGRlckNsYWltZWQSGgoIYXNzaWduZWQYASABKAVSCGFzc2lnbmVk');

@$core.Deprecated('Use placeholderListDescriptor instead')
const PlaceholderList$json = {
  '1': 'PlaceholderList',
  '2': [
    {
      '1': 'placeholders',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.config.imports.Placeholder',
      '10': 'placeholders'
    },
  ],
};

/// Descriptor for `PlaceholderList`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List placeholderListDescriptor = $convert.base64Decode(
    'Cg9QbGFjZWhvbGRlckxpc3QSPwoMcGxhY2Vob2xkZXJzGAEgAygLMhsuY29uZmlnLmltcG9ydH'
    'MuUGxhY2Vob2xkZXJSDHBsYWNlaG9sZGVycw==');

@$core.Deprecated('Use placeholderListRequestDescriptor instead')
const PlaceholderListRequest$json = {
  '1': 'PlaceholderListRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
  ],
};

/// Descriptor for `PlaceholderListRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List placeholderListRequestDescriptor =
    $convert.base64Decode(
        'ChZQbGFjZWhvbGRlckxpc3RSZXF1ZXN0EiEKDHdvcmtzcGFjZV9pZBgBIAEoCVILd29ya3NwYW'
        'NlSWQ=');

@$core.Deprecated('Use problemDescriptor instead')
const Problem$json = {
  '1': 'Problem',
  '2': [
    {'1': 'line', '3': 1, '4': 1, '5': 5, '10': 'line'},
    {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
    {'1': 'level', '3': 3, '4': 1, '5': 9, '10': 'level'},
  ],
};

/// Descriptor for `Problem`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List problemDescriptor = $convert.base64Decode(
    'CgdQcm9ibGVtEhIKBGxpbmUYASABKAVSBGxpbmUSGAoHbWVzc2FnZRgCIAEoCVIHbWVzc2FnZR'
    'IUCgVsZXZlbBgDIAEoCVIFbGV2ZWw=');
