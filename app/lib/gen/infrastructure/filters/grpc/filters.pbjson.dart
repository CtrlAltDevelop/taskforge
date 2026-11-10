// This is a generated file - do not edit.
//
// Generated from infrastructure/filters/grpc/filters.proto.

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

@$core.Deprecated('Use filterDescriptor instead')
const Filter$json = {
  '1': 'Filter',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'owner_id', '3': 3, '4': 1, '5': 9, '10': 'ownerId'},
    {'1': 'name', '3': 4, '4': 1, '5': 9, '10': 'name'},
    {'1': 'visibility', '3': 5, '4': 1, '5': 9, '10': 'visibility'},
    {'1': 'ast_json', '3': 6, '4': 1, '5': 9, '10': 'astJson'},
    {'1': 'tfql', '3': 7, '4': 1, '5': 9, '10': 'tfql'},
    {'1': 'version', '3': 8, '4': 1, '5': 5, '10': 'version'},
    {'1': 'updated_at', '3': 9, '4': 1, '5': 9, '10': 'updatedAt'},
  ],
};

/// Descriptor for `Filter`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List filterDescriptor = $convert.base64Decode(
    'CgZGaWx0ZXISDgoCaWQYASABKAlSAmlkEh0KCnByb2plY3RfaWQYAiABKAlSCXByb2plY3RJZB'
    'IZCghvd25lcl9pZBgDIAEoCVIHb3duZXJJZBISCgRuYW1lGAQgASgJUgRuYW1lEh4KCnZpc2li'
    'aWxpdHkYBSABKAlSCnZpc2liaWxpdHkSGQoIYXN0X2pzb24YBiABKAlSB2FzdEpzb24SEgoEdG'
    'ZxbBgHIAEoCVIEdGZxbBIYCgd2ZXJzaW9uGAggASgFUgd2ZXJzaW9uEh0KCnVwZGF0ZWRfYXQY'
    'CSABKAlSCXVwZGF0ZWRBdA==');

@$core.Deprecated('Use filterDeleteRequestDescriptor instead')
const FilterDeleteRequest$json = {
  '1': 'FilterDeleteRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'id', '3': 3, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `FilterDeleteRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List filterDeleteRequestDescriptor = $convert.base64Decode(
    'ChNGaWx0ZXJEZWxldGVSZXF1ZXN0EiEKDHdvcmtzcGFjZV9pZBgBIAEoCVILd29ya3NwYWNlSW'
    'QSHQoKcHJvamVjdF9pZBgCIAEoCVIJcHJvamVjdElkEg4KAmlkGAMgASgJUgJpZA==');

@$core.Deprecated('Use filterListDescriptor instead')
const FilterList$json = {
  '1': 'FilterList',
  '2': [
    {
      '1': 'filters',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.config.filters.Filter',
      '10': 'filters'
    },
  ],
};

/// Descriptor for `FilterList`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List filterListDescriptor = $convert.base64Decode(
    'CgpGaWx0ZXJMaXN0EjAKB2ZpbHRlcnMYASADKAsyFi5jb25maWcuZmlsdGVycy5GaWx0ZXJSB2'
    'ZpbHRlcnM=');

@$core.Deprecated('Use filterListRequestDescriptor instead')
const FilterListRequest$json = {
  '1': 'FilterListRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
  ],
};

/// Descriptor for `FilterListRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List filterListRequestDescriptor = $convert.base64Decode(
    'ChFGaWx0ZXJMaXN0UmVxdWVzdBIhCgx3b3Jrc3BhY2VfaWQYASABKAlSC3dvcmtzcGFjZUlkEh'
    '0KCnByb2plY3RfaWQYAiABKAlSCXByb2plY3RJZA==');

@$core.Deprecated('Use filterSaveRequestDescriptor instead')
const FilterSaveRequest$json = {
  '1': 'FilterSaveRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'id', '3': 3, '4': 1, '5': 9, '10': 'id'},
    {'1': 'expected_version', '3': 4, '4': 1, '5': 5, '10': 'expectedVersion'},
    {'1': 'name', '3': 5, '4': 1, '5': 9, '10': 'name'},
    {'1': 'tfql', '3': 6, '4': 1, '5': 9, '10': 'tfql'},
    {'1': 'ast_json', '3': 7, '4': 1, '5': 9, '10': 'astJson'},
    {'1': 'visibility', '3': 8, '4': 1, '5': 9, '10': 'visibility'},
  ],
};

/// Descriptor for `FilterSaveRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List filterSaveRequestDescriptor = $convert.base64Decode(
    'ChFGaWx0ZXJTYXZlUmVxdWVzdBIhCgx3b3Jrc3BhY2VfaWQYASABKAlSC3dvcmtzcGFjZUlkEh'
    '0KCnByb2plY3RfaWQYAiABKAlSCXByb2plY3RJZBIOCgJpZBgDIAEoCVICaWQSKQoQZXhwZWN0'
    'ZWRfdmVyc2lvbhgEIAEoBVIPZXhwZWN0ZWRWZXJzaW9uEhIKBG5hbWUYBSABKAlSBG5hbWUSEg'
    'oEdGZxbBgGIAEoCVIEdGZxbBIZCghhc3RfanNvbhgHIAEoCVIHYXN0SnNvbhIeCgp2aXNpYmls'
    'aXR5GAggASgJUgp2aXNpYmlsaXR5');

@$core.Deprecated('Use queryCheckedDescriptor instead')
const QueryChecked$json = {
  '1': 'QueryChecked',
  '2': [
    {'1': 'ok', '3': 1, '4': 1, '5': 8, '10': 'ok'},
    {'1': 'ast_json', '3': 2, '4': 1, '5': 9, '10': 'astJson'},
    {'1': 'tfql', '3': 3, '4': 1, '5': 9, '10': 'tfql'},
    {
      '1': 'errors',
      '3': 4,
      '4': 3,
      '5': 11,
      '6': '.config.filters.QueryProblem',
      '10': 'errors'
    },
  ],
};

/// Descriptor for `QueryChecked`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List queryCheckedDescriptor = $convert.base64Decode(
    'CgxRdWVyeUNoZWNrZWQSDgoCb2sYASABKAhSAm9rEhkKCGFzdF9qc29uGAIgASgJUgdhc3RKc2'
    '9uEhIKBHRmcWwYAyABKAlSBHRmcWwSNAoGZXJyb3JzGAQgAygLMhwuY29uZmlnLmZpbHRlcnMu'
    'UXVlcnlQcm9ibGVtUgZlcnJvcnM=');

@$core.Deprecated('Use queryProblemDescriptor instead')
const QueryProblem$json = {
  '1': 'QueryProblem',
  '2': [
    {'1': 'position', '3': 1, '4': 1, '5': 5, '10': 'position'},
    {'1': 'length', '3': 2, '4': 1, '5': 5, '10': 'length'},
    {'1': 'message', '3': 3, '4': 1, '5': 9, '10': 'message'},
  ],
};

/// Descriptor for `QueryProblem`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List queryProblemDescriptor = $convert.base64Decode(
    'CgxRdWVyeVByb2JsZW0SGgoIcG9zaXRpb24YASABKAVSCHBvc2l0aW9uEhYKBmxlbmd0aBgCIA'
    'EoBVIGbGVuZ3RoEhgKB21lc3NhZ2UYAyABKAlSB21lc3NhZ2U=');

@$core.Deprecated('Use querySuggestRequestDescriptor instead')
const QuerySuggestRequest$json = {
  '1': 'QuerySuggestRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'partial', '3': 3, '4': 1, '5': 9, '10': 'partial'},
    {'1': 'cursor', '3': 4, '4': 1, '5': 5, '10': 'cursor'},
  ],
};

/// Descriptor for `QuerySuggestRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List querySuggestRequestDescriptor = $convert.base64Decode(
    'ChNRdWVyeVN1Z2dlc3RSZXF1ZXN0EiEKDHdvcmtzcGFjZV9pZBgBIAEoCVILd29ya3NwYWNlSW'
    'QSHQoKcHJvamVjdF9pZBgCIAEoCVIJcHJvamVjdElkEhgKB3BhcnRpYWwYAyABKAlSB3BhcnRp'
    'YWwSFgoGY3Vyc29yGAQgASgFUgZjdXJzb3I=');

@$core.Deprecated('Use querySuggestionDescriptor instead')
const QuerySuggestion$json = {
  '1': 'QuerySuggestion',
  '2': [
    {'1': 'text', '3': 1, '4': 1, '5': 9, '10': 'text'},
    {'1': 'kind', '3': 2, '4': 1, '5': 9, '10': 'kind'},
    {'1': 'start', '3': 3, '4': 1, '5': 5, '10': 'start'},
    {'1': 'label', '3': 4, '4': 1, '5': 9, '10': 'label'},
  ],
};

/// Descriptor for `QuerySuggestion`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List querySuggestionDescriptor = $convert.base64Decode(
    'Cg9RdWVyeVN1Z2dlc3Rpb24SEgoEdGV4dBgBIAEoCVIEdGV4dBISCgRraW5kGAIgASgJUgRraW'
    '5kEhQKBXN0YXJ0GAMgASgFUgVzdGFydBIUCgVsYWJlbBgEIAEoCVIFbGFiZWw=');

@$core.Deprecated('Use querySuggestionsDescriptor instead')
const QuerySuggestions$json = {
  '1': 'QuerySuggestions',
  '2': [
    {
      '1': 'items',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.config.filters.QuerySuggestion',
      '10': 'items'
    },
  ],
};

/// Descriptor for `QuerySuggestions`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List querySuggestionsDescriptor = $convert.base64Decode(
    'ChBRdWVyeVN1Z2dlc3Rpb25zEjUKBWl0ZW1zGAEgAygLMh8uY29uZmlnLmZpbHRlcnMuUXVlcn'
    'lTdWdnZXN0aW9uUgVpdGVtcw==');

@$core.Deprecated('Use queryValidateRequestDescriptor instead')
const QueryValidateRequest$json = {
  '1': 'QueryValidateRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'tfql', '3': 3, '4': 1, '5': 9, '10': 'tfql'},
    {'1': 'ast_json', '3': 4, '4': 1, '5': 9, '10': 'astJson'},
  ],
};

/// Descriptor for `QueryValidateRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List queryValidateRequestDescriptor = $convert.base64Decode(
    'ChRRdWVyeVZhbGlkYXRlUmVxdWVzdBIhCgx3b3Jrc3BhY2VfaWQYASABKAlSC3dvcmtzcGFjZU'
    'lkEh0KCnByb2plY3RfaWQYAiABKAlSCXByb2plY3RJZBISCgR0ZnFsGAMgASgJUgR0ZnFsEhkK'
    'CGFzdF9qc29uGAQgASgJUgdhc3RKc29u');
