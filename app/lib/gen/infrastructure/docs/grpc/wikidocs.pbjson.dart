// This is a generated file - do not edit.
//
// Generated from infrastructure/docs/grpc/wikidocs.proto.

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

@$core.Deprecated('Use docAnswerDescriptor instead')
const DocAnswer$json = {
  '1': 'DocAnswer',
  '2': [
    {
      '1': 'doc',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.config.wikidocs.DocNode',
      '10': 'doc'
    },
    {'1': 'version', '3': 2, '4': 1, '5': 5, '10': 'version'},
    {'1': 'schema_version', '3': 3, '4': 1, '5': 5, '10': 'schemaVersion'},
    {'1': 'blocks_json', '3': 4, '4': 1, '5': 9, '10': 'blocksJson'},
    {'1': 'updated_by', '3': 5, '4': 1, '5': 9, '10': 'updatedBy'},
    {
      '1': 'editing',
      '3': 6,
      '4': 3,
      '5': 11,
      '6': '.config.wikidocs.Editor',
      '10': 'editing'
    },
    {
      '1': 'cards',
      '3': 7,
      '4': 3,
      '5': 11,
      '6': '.config.wikidocs.TaskCard',
      '10': 'cards'
    },
    {'1': 'can_edit', '3': 8, '4': 1, '5': 8, '10': 'canEdit'},
    {'1': 'can_manage', '3': 9, '4': 1, '5': 8, '10': 'canManage'},
    {'1': 'access_user_ids', '3': 10, '4': 3, '5': 9, '10': 'accessUserIds'},
  ],
};

/// Descriptor for `DocAnswer`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List docAnswerDescriptor = $convert.base64Decode(
    'CglEb2NBbnN3ZXISKgoDZG9jGAEgASgLMhguY29uZmlnLndpa2lkb2NzLkRvY05vZGVSA2RvYx'
    'IYCgd2ZXJzaW9uGAIgASgFUgd2ZXJzaW9uEiUKDnNjaGVtYV92ZXJzaW9uGAMgASgFUg1zY2hl'
    'bWFWZXJzaW9uEh8KC2Jsb2Nrc19qc29uGAQgASgJUgpibG9ja3NKc29uEh0KCnVwZGF0ZWRfYn'
    'kYBSABKAlSCXVwZGF0ZWRCeRIxCgdlZGl0aW5nGAYgAygLMhcuY29uZmlnLndpa2lkb2NzLkVk'
    'aXRvclIHZWRpdGluZxIvCgVjYXJkcxgHIAMoCzIZLmNvbmZpZy53aWtpZG9jcy5UYXNrQ2FyZF'
    'IFY2FyZHMSGQoIY2FuX2VkaXQYCCABKAhSB2NhbkVkaXQSHQoKY2FuX21hbmFnZRgJIAEoCFIJ'
    'Y2FuTWFuYWdlEiYKD2FjY2Vzc191c2VyX2lkcxgKIAMoCVINYWNjZXNzVXNlcklkcw==');

@$core.Deprecated('Use docArchiveRequestDescriptor instead')
const DocArchiveRequest$json = {
  '1': 'DocArchiveRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'doc_id', '3': 2, '4': 1, '5': 9, '10': 'docId'},
  ],
};

/// Descriptor for `DocArchiveRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List docArchiveRequestDescriptor = $convert.base64Decode(
    'ChFEb2NBcmNoaXZlUmVxdWVzdBIhCgx3b3Jrc3BhY2VfaWQYASABKAlSC3dvcmtzcGFjZUlkEh'
    'UKBmRvY19pZBgCIAEoCVIFZG9jSWQ=');

@$core.Deprecated('Use docBacklinksRequestDescriptor instead')
const DocBacklinksRequest$json = {
  '1': 'DocBacklinksRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'doc_id', '3': 2, '4': 1, '5': 9, '10': 'docId'},
  ],
};

/// Descriptor for `DocBacklinksRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List docBacklinksRequestDescriptor = $convert.base64Decode(
    'ChNEb2NCYWNrbGlua3NSZXF1ZXN0EiEKDHdvcmtzcGFjZV9pZBgBIAEoCVILd29ya3NwYWNlSW'
    'QSFQoGZG9jX2lkGAIgASgJUgVkb2NJZA==');

@$core.Deprecated('Use docCreateRequestDescriptor instead')
const DocCreateRequest$json = {
  '1': 'DocCreateRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'parent_id', '3': 3, '4': 1, '5': 9, '10': 'parentId'},
    {'1': 'title', '3': 4, '4': 1, '5': 9, '10': 'title'},
    {'1': 'icon', '3': 5, '4': 1, '5': 9, '10': 'icon'},
    {'1': 'blocks_json', '3': 6, '4': 1, '5': 9, '10': 'blocksJson'},
  ],
};

/// Descriptor for `DocCreateRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List docCreateRequestDescriptor = $convert.base64Decode(
    'ChBEb2NDcmVhdGVSZXF1ZXN0EiEKDHdvcmtzcGFjZV9pZBgBIAEoCVILd29ya3NwYWNlSWQSHQ'
    'oKcHJvamVjdF9pZBgCIAEoCVIJcHJvamVjdElkEhsKCXBhcmVudF9pZBgDIAEoCVIIcGFyZW50'
    'SWQSFAoFdGl0bGUYBCABKAlSBXRpdGxlEhIKBGljb24YBSABKAlSBGljb24SHwoLYmxvY2tzX2'
    'pzb24YBiABKAlSCmJsb2Nrc0pzb24=');

@$core.Deprecated('Use docExportRequestDescriptor instead')
const DocExportRequest$json = {
  '1': 'DocExportRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'doc_id', '3': 2, '4': 1, '5': 9, '10': 'docId'},
  ],
};

/// Descriptor for `DocExportRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List docExportRequestDescriptor = $convert.base64Decode(
    'ChBEb2NFeHBvcnRSZXF1ZXN0EiEKDHdvcmtzcGFjZV9pZBgBIAEoCVILd29ya3NwYWNlSWQSFQ'
    'oGZG9jX2lkGAIgASgJUgVkb2NJZA==');

@$core.Deprecated('Use docForTaskRequestDescriptor instead')
const DocForTaskRequest$json = {
  '1': 'DocForTaskRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'task_id', '3': 3, '4': 1, '5': 9, '10': 'taskId'},
  ],
};

/// Descriptor for `DocForTaskRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List docForTaskRequestDescriptor = $convert.base64Decode(
    'ChFEb2NGb3JUYXNrUmVxdWVzdBIhCgx3b3Jrc3BhY2VfaWQYASABKAlSC3dvcmtzcGFjZUlkEh'
    '0KCnByb2plY3RfaWQYAiABKAlSCXByb2plY3RJZBIXCgd0YXNrX2lkGAMgASgJUgZ0YXNrSWQ=');

@$core.Deprecated('Use docGetRequestDescriptor instead')
const DocGetRequest$json = {
  '1': 'DocGetRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'doc_id', '3': 2, '4': 1, '5': 9, '10': 'docId'},
  ],
};

/// Descriptor for `DocGetRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List docGetRequestDescriptor = $convert.base64Decode(
    'Cg1Eb2NHZXRSZXF1ZXN0EiEKDHdvcmtzcGFjZV9pZBgBIAEoCVILd29ya3NwYWNlSWQSFQoGZG'
    '9jX2lkGAIgASgJUgVkb2NJZA==');

@$core.Deprecated('Use docLinkTaskRequestDescriptor instead')
const DocLinkTaskRequest$json = {
  '1': 'DocLinkTaskRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'task_id', '3': 3, '4': 1, '5': 9, '10': 'taskId'},
    {'1': 'doc_id', '3': 4, '4': 1, '5': 9, '10': 'docId'},
  ],
};

/// Descriptor for `DocLinkTaskRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List docLinkTaskRequestDescriptor = $convert.base64Decode(
    'ChJEb2NMaW5rVGFza1JlcXVlc3QSIQoMd29ya3NwYWNlX2lkGAEgASgJUgt3b3Jrc3BhY2VJZB'
    'IdCgpwcm9qZWN0X2lkGAIgASgJUglwcm9qZWN0SWQSFwoHdGFza19pZBgDIAEoCVIGdGFza0lk'
    'EhUKBmRvY19pZBgEIAEoCVIFZG9jSWQ=');

@$core.Deprecated('Use docMarkdownDescriptor instead')
const DocMarkdown$json = {
  '1': 'DocMarkdown',
  '2': [
    {'1': 'title', '3': 1, '4': 1, '5': 9, '10': 'title'},
    {'1': 'markdown', '3': 2, '4': 1, '5': 9, '10': 'markdown'},
  ],
};

/// Descriptor for `DocMarkdown`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List docMarkdownDescriptor = $convert.base64Decode(
    'CgtEb2NNYXJrZG93bhIUCgV0aXRsZRgBIAEoCVIFdGl0bGUSGgoIbWFya2Rvd24YAiABKAlSCG'
    '1hcmtkb3du');

@$core.Deprecated('Use docMoveRequestDescriptor instead')
const DocMoveRequest$json = {
  '1': 'DocMoveRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'doc_id', '3': 2, '4': 1, '5': 9, '10': 'docId'},
    {'1': 'parent_id', '3': 3, '4': 1, '5': 9, '10': 'parentId'},
    {'1': 'index', '3': 4, '4': 1, '5': 5, '10': 'index'},
  ],
};

/// Descriptor for `DocMoveRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List docMoveRequestDescriptor = $convert.base64Decode(
    'Cg5Eb2NNb3ZlUmVxdWVzdBIhCgx3b3Jrc3BhY2VfaWQYASABKAlSC3dvcmtzcGFjZUlkEhUKBm'
    'RvY19pZBgCIAEoCVIFZG9jSWQSGwoJcGFyZW50X2lkGAMgASgJUghwYXJlbnRJZBIUCgVpbmRl'
    'eBgEIAEoBVIFaW5kZXg=');

@$core.Deprecated('Use docNodeDescriptor instead')
const DocNode$json = {
  '1': 'DocNode',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'workspace_id', '3': 2, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'project_id', '3': 3, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'parent_id', '3': 4, '4': 1, '5': 9, '10': 'parentId'},
    {'1': 'title', '3': 5, '4': 1, '5': 9, '10': 'title'},
    {'1': 'icon', '3': 6, '4': 1, '5': 9, '10': 'icon'},
    {'1': 'position', '3': 7, '4': 1, '5': 5, '10': 'position'},
    {'1': 'restricted', '3': 8, '4': 1, '5': 8, '10': 'restricted'},
    {'1': 'archived', '3': 9, '4': 1, '5': 8, '10': 'archived'},
    {'1': 'created_by', '3': 10, '4': 1, '5': 9, '10': 'createdBy'},
    {'1': 'created_at', '3': 11, '4': 1, '5': 9, '10': 'createdAt'},
    {'1': 'updated_at', '3': 12, '4': 1, '5': 9, '10': 'updatedAt'},
  ],
};

/// Descriptor for `DocNode`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List docNodeDescriptor = $convert.base64Decode(
    'CgdEb2NOb2RlEg4KAmlkGAEgASgJUgJpZBIhCgx3b3Jrc3BhY2VfaWQYAiABKAlSC3dvcmtzcG'
    'FjZUlkEh0KCnByb2plY3RfaWQYAyABKAlSCXByb2plY3RJZBIbCglwYXJlbnRfaWQYBCABKAlS'
    'CHBhcmVudElkEhQKBXRpdGxlGAUgASgJUgV0aXRsZRISCgRpY29uGAYgASgJUgRpY29uEhoKCH'
    'Bvc2l0aW9uGAcgASgFUghwb3NpdGlvbhIeCgpyZXN0cmljdGVkGAggASgIUgpyZXN0cmljdGVk'
    'EhoKCGFyY2hpdmVkGAkgASgIUghhcmNoaXZlZBIdCgpjcmVhdGVkX2J5GAogASgJUgljcmVhdG'
    'VkQnkSHQoKY3JlYXRlZF9hdBgLIAEoCVIJY3JlYXRlZEF0Eh0KCnVwZGF0ZWRfYXQYDCABKAlS'
    'CXVwZGF0ZWRBdA==');

@$core.Deprecated('Use docPresenceDescriptor instead')
const DocPresence$json = {
  '1': 'DocPresence',
  '2': [
    {
      '1': 'editing',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.config.wikidocs.Editor',
      '10': 'editing'
    },
  ],
};

/// Descriptor for `DocPresence`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List docPresenceDescriptor = $convert.base64Decode(
    'CgtEb2NQcmVzZW5jZRIxCgdlZGl0aW5nGAEgAygLMhcuY29uZmlnLndpa2lkb2NzLkVkaXRvcl'
    'IHZWRpdGluZw==');

@$core.Deprecated('Use docPresenceRequestDescriptor instead')
const DocPresenceRequest$json = {
  '1': 'DocPresenceRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'doc_id', '3': 2, '4': 1, '5': 9, '10': 'docId'},
    {'1': 'state', '3': 3, '4': 1, '5': 9, '10': 'state'},
  ],
};

/// Descriptor for `DocPresenceRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List docPresenceRequestDescriptor = $convert.base64Decode(
    'ChJEb2NQcmVzZW5jZVJlcXVlc3QSIQoMd29ya3NwYWNlX2lkGAEgASgJUgt3b3Jrc3BhY2VJZB'
    'IVCgZkb2NfaWQYAiABKAlSBWRvY0lkEhQKBXN0YXRlGAMgASgJUgVzdGF0ZQ==');

@$core.Deprecated('Use docRestoreRequestDescriptor instead')
const DocRestoreRequest$json = {
  '1': 'DocRestoreRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'doc_id', '3': 2, '4': 1, '5': 9, '10': 'docId'},
  ],
};

/// Descriptor for `DocRestoreRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List docRestoreRequestDescriptor = $convert.base64Decode(
    'ChFEb2NSZXN0b3JlUmVxdWVzdBIhCgx3b3Jrc3BhY2VfaWQYASABKAlSC3dvcmtzcGFjZUlkEh'
    'UKBmRvY19pZBgCIAEoCVIFZG9jSWQ=');

@$core.Deprecated('Use docRevisionAnswerDescriptor instead')
const DocRevisionAnswer$json = {
  '1': 'DocRevisionAnswer',
  '2': [
    {
      '1': 'revision',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.config.wikidocs.RevisionInfo',
      '10': 'revision'
    },
    {'1': 'blocks_json', '3': 2, '4': 1, '5': 9, '10': 'blocksJson'},
  ],
};

/// Descriptor for `DocRevisionAnswer`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List docRevisionAnswerDescriptor = $convert.base64Decode(
    'ChFEb2NSZXZpc2lvbkFuc3dlchI5CghyZXZpc2lvbhgBIAEoCzIdLmNvbmZpZy53aWtpZG9jcy'
    '5SZXZpc2lvbkluZm9SCHJldmlzaW9uEh8KC2Jsb2Nrc19qc29uGAIgASgJUgpibG9ja3NKc29u');

@$core.Deprecated('Use docRevisionGetRequestDescriptor instead')
const DocRevisionGetRequest$json = {
  '1': 'DocRevisionGetRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'doc_id', '3': 2, '4': 1, '5': 9, '10': 'docId'},
    {'1': 'revision_id', '3': 3, '4': 1, '5': 3, '10': 'revisionId'},
  ],
};

/// Descriptor for `DocRevisionGetRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List docRevisionGetRequestDescriptor = $convert.base64Decode(
    'ChVEb2NSZXZpc2lvbkdldFJlcXVlc3QSIQoMd29ya3NwYWNlX2lkGAEgASgJUgt3b3Jrc3BhY2'
    'VJZBIVCgZkb2NfaWQYAiABKAlSBWRvY0lkEh8KC3JldmlzaW9uX2lkGAMgASgDUgpyZXZpc2lv'
    'bklk');

@$core.Deprecated('Use docRevisionListDescriptor instead')
const DocRevisionList$json = {
  '1': 'DocRevisionList',
  '2': [
    {
      '1': 'revisions',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.config.wikidocs.RevisionInfo',
      '10': 'revisions'
    },
  ],
};

/// Descriptor for `DocRevisionList`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List docRevisionListDescriptor = $convert.base64Decode(
    'Cg9Eb2NSZXZpc2lvbkxpc3QSOwoJcmV2aXNpb25zGAEgAygLMh0uY29uZmlnLndpa2lkb2NzLl'
    'JldmlzaW9uSW5mb1IJcmV2aXNpb25z');

@$core.Deprecated('Use docRevisionListRequestDescriptor instead')
const DocRevisionListRequest$json = {
  '1': 'DocRevisionListRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'doc_id', '3': 2, '4': 1, '5': 9, '10': 'docId'},
  ],
};

/// Descriptor for `DocRevisionListRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List docRevisionListRequestDescriptor =
    $convert.base64Decode(
        'ChZEb2NSZXZpc2lvbkxpc3RSZXF1ZXN0EiEKDHdvcmtzcGFjZV9pZBgBIAEoCVILd29ya3NwYW'
        'NlSWQSFQoGZG9jX2lkGAIgASgJUgVkb2NJZA==');

@$core.Deprecated('Use docRevisionRestoreRequestDescriptor instead')
const DocRevisionRestoreRequest$json = {
  '1': 'DocRevisionRestoreRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'doc_id', '3': 2, '4': 1, '5': 9, '10': 'docId'},
    {'1': 'revision_id', '3': 3, '4': 1, '5': 3, '10': 'revisionId'},
    {'1': 'expected_version', '3': 4, '4': 1, '5': 5, '10': 'expectedVersion'},
  ],
};

/// Descriptor for `DocRevisionRestoreRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List docRevisionRestoreRequestDescriptor = $convert.base64Decode(
    'ChlEb2NSZXZpc2lvblJlc3RvcmVSZXF1ZXN0EiEKDHdvcmtzcGFjZV9pZBgBIAEoCVILd29ya3'
    'NwYWNlSWQSFQoGZG9jX2lkGAIgASgJUgVkb2NJZBIfCgtyZXZpc2lvbl9pZBgDIAEoA1IKcmV2'
    'aXNpb25JZBIpChBleHBlY3RlZF92ZXJzaW9uGAQgASgFUg9leHBlY3RlZFZlcnNpb24=');

@$core.Deprecated('Use docSetAccessRequestDescriptor instead')
const DocSetAccessRequest$json = {
  '1': 'DocSetAccessRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'doc_id', '3': 2, '4': 1, '5': 9, '10': 'docId'},
    {'1': 'restricted', '3': 3, '4': 1, '5': 8, '10': 'restricted'},
    {'1': 'user_ids', '3': 4, '4': 3, '5': 9, '10': 'userIds'},
  ],
};

/// Descriptor for `DocSetAccessRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List docSetAccessRequestDescriptor = $convert.base64Decode(
    'ChNEb2NTZXRBY2Nlc3NSZXF1ZXN0EiEKDHdvcmtzcGFjZV9pZBgBIAEoCVILd29ya3NwYWNlSW'
    'QSFQoGZG9jX2lkGAIgASgJUgVkb2NJZBIeCgpyZXN0cmljdGVkGAMgASgIUgpyZXN0cmljdGVk'
    'EhkKCHVzZXJfaWRzGAQgAygJUgd1c2VySWRz');

@$core.Deprecated('Use docTaskCardsDescriptor instead')
const DocTaskCards$json = {
  '1': 'DocTaskCards',
  '2': [
    {
      '1': 'cards',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.config.wikidocs.TaskCard',
      '10': 'cards'
    },
  ],
};

/// Descriptor for `DocTaskCards`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List docTaskCardsDescriptor = $convert.base64Decode(
    'CgxEb2NUYXNrQ2FyZHMSLwoFY2FyZHMYASADKAsyGS5jb25maWcud2lraWRvY3MuVGFza0Nhcm'
    'RSBWNhcmRz');

@$core.Deprecated('Use docTaskCardsRequestDescriptor instead')
const DocTaskCardsRequest$json = {
  '1': 'DocTaskCardsRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'task_ids', '3': 2, '4': 3, '5': 9, '10': 'taskIds'},
  ],
};

/// Descriptor for `DocTaskCardsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List docTaskCardsRequestDescriptor = $convert.base64Decode(
    'ChNEb2NUYXNrQ2FyZHNSZXF1ZXN0EiEKDHdvcmtzcGFjZV9pZBgBIAEoCVILd29ya3NwYWNlSW'
    'QSGQoIdGFza19pZHMYAiADKAlSB3Rhc2tJZHM=');

@$core.Deprecated('Use docTreeDescriptor instead')
const DocTree$json = {
  '1': 'DocTree',
  '2': [
    {
      '1': 'docs',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.config.wikidocs.DocNode',
      '10': 'docs'
    },
  ],
};

/// Descriptor for `DocTree`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List docTreeDescriptor = $convert.base64Decode(
    'CgdEb2NUcmVlEiwKBGRvY3MYASADKAsyGC5jb25maWcud2lraWRvY3MuRG9jTm9kZVIEZG9jcw'
    '==');

@$core.Deprecated('Use docTreeRequestDescriptor instead')
const DocTreeRequest$json = {
  '1': 'DocTreeRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'include_archived', '3': 3, '4': 1, '5': 8, '10': 'includeArchived'},
  ],
};

/// Descriptor for `DocTreeRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List docTreeRequestDescriptor = $convert.base64Decode(
    'Cg5Eb2NUcmVlUmVxdWVzdBIhCgx3b3Jrc3BhY2VfaWQYASABKAlSC3dvcmtzcGFjZUlkEh0KCn'
    'Byb2plY3RfaWQYAiABKAlSCXByb2plY3RJZBIpChBpbmNsdWRlX2FyY2hpdmVkGAMgASgIUg9p'
    'bmNsdWRlQXJjaGl2ZWQ=');

@$core.Deprecated('Use docUpdateRequestDescriptor instead')
const DocUpdateRequest$json = {
  '1': 'DocUpdateRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'doc_id', '3': 2, '4': 1, '5': 9, '10': 'docId'},
    {'1': 'expected_version', '3': 3, '4': 1, '5': 5, '10': 'expectedVersion'},
    {'1': 'fields', '3': 4, '4': 3, '5': 9, '10': 'fields'},
    {'1': 'title', '3': 5, '4': 1, '5': 9, '10': 'title'},
    {'1': 'icon', '3': 6, '4': 1, '5': 9, '10': 'icon'},
    {'1': 'blocks_json', '3': 7, '4': 1, '5': 9, '10': 'blocksJson'},
    {'1': 'schema_version', '3': 8, '4': 1, '5': 5, '10': 'schemaVersion'},
  ],
};

/// Descriptor for `DocUpdateRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List docUpdateRequestDescriptor = $convert.base64Decode(
    'ChBEb2NVcGRhdGVSZXF1ZXN0EiEKDHdvcmtzcGFjZV9pZBgBIAEoCVILd29ya3NwYWNlSWQSFQ'
    'oGZG9jX2lkGAIgASgJUgVkb2NJZBIpChBleHBlY3RlZF92ZXJzaW9uGAMgASgFUg9leHBlY3Rl'
    'ZFZlcnNpb24SFgoGZmllbGRzGAQgAygJUgZmaWVsZHMSFAoFdGl0bGUYBSABKAlSBXRpdGxlEh'
    'IKBGljb24YBiABKAlSBGljb24SHwoLYmxvY2tzX2pzb24YByABKAlSCmJsb2Nrc0pzb24SJQoO'
    'c2NoZW1hX3ZlcnNpb24YCCABKAVSDXNjaGVtYVZlcnNpb24=');

@$core.Deprecated('Use editorDescriptor instead')
const Editor$json = {
  '1': 'Editor',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'editing', '3': 2, '4': 1, '5': 8, '10': 'editing'},
  ],
};

/// Descriptor for `Editor`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List editorDescriptor = $convert.base64Decode(
    'CgZFZGl0b3ISFwoHdXNlcl9pZBgBIAEoCVIGdXNlcklkEhgKB2VkaXRpbmcYAiABKAhSB2VkaX'
    'Rpbmc=');

@$core.Deprecated('Use relatedDocDescriptor instead')
const RelatedDoc$json = {
  '1': 'RelatedDoc',
  '2': [
    {
      '1': 'doc',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.config.wikidocs.DocNode',
      '10': 'doc'
    },
    {'1': 'kind', '3': 2, '4': 1, '5': 9, '10': 'kind'},
  ],
};

/// Descriptor for `RelatedDoc`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List relatedDocDescriptor = $convert.base64Decode(
    'CgpSZWxhdGVkRG9jEioKA2RvYxgBIAEoCzIYLmNvbmZpZy53aWtpZG9jcy5Eb2NOb2RlUgNkb2'
    'MSEgoEa2luZBgCIAEoCVIEa2luZA==');

@$core.Deprecated('Use relatedDocsDescriptor instead')
const RelatedDocs$json = {
  '1': 'RelatedDocs',
  '2': [
    {
      '1': 'docs',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.config.wikidocs.RelatedDoc',
      '10': 'docs'
    },
  ],
};

/// Descriptor for `RelatedDocs`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List relatedDocsDescriptor = $convert.base64Decode(
    'CgtSZWxhdGVkRG9jcxIvCgRkb2NzGAEgAygLMhsuY29uZmlnLndpa2lkb2NzLlJlbGF0ZWREb2'
    'NSBGRvY3M=');

@$core.Deprecated('Use revisionInfoDescriptor instead')
const RevisionInfo$json = {
  '1': 'RevisionInfo',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 5, '10': 'id'},
    {'1': 'version', '3': 2, '4': 1, '5': 5, '10': 'version'},
    {'1': 'title', '3': 3, '4': 1, '5': 9, '10': 'title'},
    {'1': 'author_id', '3': 4, '4': 1, '5': 9, '10': 'authorId'},
    {'1': 'at', '3': 5, '4': 1, '5': 9, '10': 'at'},
    {'1': 'saved_at', '3': 6, '4': 1, '5': 9, '10': 'savedAt'},
  ],
};

/// Descriptor for `RevisionInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List revisionInfoDescriptor = $convert.base64Decode(
    'CgxSZXZpc2lvbkluZm8SDgoCaWQYASABKAVSAmlkEhgKB3ZlcnNpb24YAiABKAVSB3ZlcnNpb2'
    '4SFAoFdGl0bGUYAyABKAlSBXRpdGxlEhsKCWF1dGhvcl9pZBgEIAEoCVIIYXV0aG9ySWQSDgoC'
    'YXQYBSABKAlSAmF0EhkKCHNhdmVkX2F0GAYgASgJUgdzYXZlZEF0');

@$core.Deprecated('Use taskCardDescriptor instead')
const TaskCard$json = {
  '1': 'TaskCard',
  '2': [
    {'1': 'task_id', '3': 1, '4': 1, '5': 9, '10': 'taskId'},
    {'1': 'hidden', '3': 2, '4': 1, '5': 8, '10': 'hidden'},
    {'1': 'project_id', '3': 3, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'key', '3': 4, '4': 1, '5': 9, '10': 'key'},
    {'1': 'title', '3': 5, '4': 1, '5': 9, '10': 'title'},
    {'1': 'status_name', '3': 6, '4': 1, '5': 9, '10': 'statusName'},
    {'1': 'status_category', '3': 7, '4': 1, '5': 9, '10': 'statusCategory'},
    {'1': 'priority', '3': 8, '4': 1, '5': 9, '10': 'priority'},
  ],
};

/// Descriptor for `TaskCard`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List taskCardDescriptor = $convert.base64Decode(
    'CghUYXNrQ2FyZBIXCgd0YXNrX2lkGAEgASgJUgZ0YXNrSWQSFgoGaGlkZGVuGAIgASgIUgZoaW'
    'RkZW4SHQoKcHJvamVjdF9pZBgDIAEoCVIJcHJvamVjdElkEhAKA2tleRgEIAEoCVIDa2V5EhQK'
    'BXRpdGxlGAUgASgJUgV0aXRsZRIfCgtzdGF0dXNfbmFtZRgGIAEoCVIKc3RhdHVzTmFtZRInCg'
    '9zdGF0dXNfY2F0ZWdvcnkYByABKAlSDnN0YXR1c0NhdGVnb3J5EhoKCHByaW9yaXR5GAggASgJ'
    'Ughwcmlvcml0eQ==');
