// This is a generated file - do not edit.
//
// Generated from infrastructure/search/grpc/search.proto.

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

@$core.Deprecated('Use hitDescriptor instead')
const Hit$json = {
  '1': 'Hit',
  '2': [
    {'1': 'kind', '3': 1, '4': 1, '5': 9, '10': 'kind'},
    {'1': 'id', '3': 2, '4': 1, '5': 9, '10': 'id'},
    {'1': 'task_id', '3': 3, '4': 1, '5': 9, '10': 'taskId'},
    {'1': 'project_id', '3': 4, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'key', '3': 5, '4': 1, '5': 9, '10': 'key'},
    {'1': 'title', '3': 6, '4': 1, '5': 9, '10': 'title'},
    {
      '1': 'title_marks',
      '3': 7,
      '4': 3,
      '5': 11,
      '6': '.config.search.Span',
      '10': 'titleMarks'
    },
    {'1': 'snippet', '3': 8, '4': 1, '5': 9, '10': 'snippet'},
    {
      '1': 'snippet_marks',
      '3': 9,
      '4': 3,
      '5': 11,
      '6': '.config.search.Span',
      '10': 'snippetMarks'
    },
    {'1': 'project_name', '3': 10, '4': 1, '5': 9, '10': 'projectName'},
    {'1': 'status', '3': 11, '4': 1, '5': 9, '10': 'status'},
    {'1': 'author', '3': 12, '4': 1, '5': 9, '10': 'author'},
    {'1': 'updated_at', '3': 13, '4': 1, '5': 9, '10': 'updatedAt'},
  ],
};

/// Descriptor for `Hit`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List hitDescriptor = $convert.base64Decode(
    'CgNIaXQSEgoEa2luZBgBIAEoCVIEa2luZBIOCgJpZBgCIAEoCVICaWQSFwoHdGFza19pZBgDIA'
    'EoCVIGdGFza0lkEh0KCnByb2plY3RfaWQYBCABKAlSCXByb2plY3RJZBIQCgNrZXkYBSABKAlS'
    'A2tleRIUCgV0aXRsZRgGIAEoCVIFdGl0bGUSNAoLdGl0bGVfbWFya3MYByADKAsyEy5jb25maW'
    'cuc2VhcmNoLlNwYW5SCnRpdGxlTWFya3MSGAoHc25pcHBldBgIIAEoCVIHc25pcHBldBI4Cg1z'
    'bmlwcGV0X21hcmtzGAkgAygLMhMuY29uZmlnLnNlYXJjaC5TcGFuUgxzbmlwcGV0TWFya3MSIQ'
    'oMcHJvamVjdF9uYW1lGAogASgJUgtwcm9qZWN0TmFtZRIWCgZzdGF0dXMYCyABKAlSBnN0YXR1'
    'cxIWCgZhdXRob3IYDCABKAlSBmF1dGhvchIdCgp1cGRhdGVkX2F0GA0gASgJUgl1cGRhdGVkQX'
    'Q=');

@$core.Deprecated('Use searchQueryRequestDescriptor instead')
const SearchQueryRequest$json = {
  '1': 'SearchQueryRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'text', '3': 2, '4': 1, '5': 9, '10': 'text'},
    {'1': 'types', '3': 3, '4': 3, '5': 9, '10': 'types'},
    {'1': 'cursor', '3': 4, '4': 1, '5': 9, '10': 'cursor'},
    {'1': 'page_size', '3': 5, '4': 1, '5': 5, '10': 'pageSize'},
  ],
};

/// Descriptor for `SearchQueryRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List searchQueryRequestDescriptor = $convert.base64Decode(
    'ChJTZWFyY2hRdWVyeVJlcXVlc3QSIQoMd29ya3NwYWNlX2lkGAEgASgJUgt3b3Jrc3BhY2VJZB'
    'ISCgR0ZXh0GAIgASgJUgR0ZXh0EhQKBXR5cGVzGAMgAygJUgV0eXBlcxIWCgZjdXJzb3IYBCAB'
    'KAlSBmN1cnNvchIbCglwYWdlX3NpemUYBSABKAVSCHBhZ2VTaXpl');

@$core.Deprecated('Use searchRecentDescriptor instead')
const SearchRecent$json = {
  '1': 'SearchRecent',
  '2': [
    {'1': 'queries', '3': 1, '4': 3, '5': 9, '10': 'queries'},
  ],
};

/// Descriptor for `SearchRecent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List searchRecentDescriptor = $convert
    .base64Decode('CgxTZWFyY2hSZWNlbnQSGAoHcXVlcmllcxgBIAMoCVIHcXVlcmllcw==');

@$core.Deprecated('Use searchRecentRequestDescriptor instead')
const SearchRecentRequest$json = {
  '1': 'SearchRecentRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
  ],
};

/// Descriptor for `SearchRecentRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List searchRecentRequestDescriptor = $convert.base64Decode(
    'ChNTZWFyY2hSZWNlbnRSZXF1ZXN0EiEKDHdvcmtzcGFjZV9pZBgBIAEoCVILd29ya3NwYWNlSW'
    'Q=');

@$core.Deprecated('Use searchRememberRequestDescriptor instead')
const SearchRememberRequest$json = {
  '1': 'SearchRememberRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'text', '3': 2, '4': 1, '5': 9, '10': 'text'},
  ],
};

/// Descriptor for `SearchRememberRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List searchRememberRequestDescriptor = $convert.base64Decode(
    'ChVTZWFyY2hSZW1lbWJlclJlcXVlc3QSIQoMd29ya3NwYWNlX2lkGAEgASgJUgt3b3Jrc3BhY2'
    'VJZBISCgR0ZXh0GAIgASgJUgR0ZXh0');

@$core.Deprecated('Use searchRememberedDescriptor instead')
const SearchRemembered$json = {
  '1': 'SearchRemembered',
  '2': [
    {'1': 'ok', '3': 1, '4': 1, '5': 8, '10': 'ok'},
  ],
};

/// Descriptor for `SearchRemembered`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List searchRememberedDescriptor =
    $convert.base64Decode('ChBTZWFyY2hSZW1lbWJlcmVkEg4KAm9rGAEgASgIUgJvaw==');

@$core.Deprecated('Use searchResultsDescriptor instead')
const SearchResults$json = {
  '1': 'SearchResults',
  '2': [
    {
      '1': 'tasks',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.config.search.Hit',
      '10': 'tasks'
    },
    {
      '1': 'comments',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.config.search.Hit',
      '10': 'comments'
    },
    {
      '1': 'projects',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.config.search.Hit',
      '10': 'projects'
    },
    {
      '1': 'members',
      '3': 4,
      '4': 3,
      '5': 11,
      '6': '.config.search.Hit',
      '10': 'members'
    },
    {
      '1': 'jump',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.config.search.Hit',
      '10': 'jump'
    },
    {'1': 'next_cursor', '3': 6, '4': 1, '5': 9, '10': 'nextCursor'},
    {
      '1': 'docs',
      '3': 7,
      '4': 3,
      '5': 11,
      '6': '.config.search.Hit',
      '10': 'docs'
    },
  ],
};

/// Descriptor for `SearchResults`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List searchResultsDescriptor = $convert.base64Decode(
    'Cg1TZWFyY2hSZXN1bHRzEigKBXRhc2tzGAEgAygLMhIuY29uZmlnLnNlYXJjaC5IaXRSBXRhc2'
    'tzEi4KCGNvbW1lbnRzGAIgAygLMhIuY29uZmlnLnNlYXJjaC5IaXRSCGNvbW1lbnRzEi4KCHBy'
    'b2plY3RzGAMgAygLMhIuY29uZmlnLnNlYXJjaC5IaXRSCHByb2plY3RzEiwKB21lbWJlcnMYBC'
    'ADKAsyEi5jb25maWcuc2VhcmNoLkhpdFIHbWVtYmVycxImCgRqdW1wGAUgASgLMhIuY29uZmln'
    'LnNlYXJjaC5IaXRSBGp1bXASHwoLbmV4dF9jdXJzb3IYBiABKAlSCm5leHRDdXJzb3ISJgoEZG'
    '9jcxgHIAMoCzISLmNvbmZpZy5zZWFyY2guSGl0UgRkb2Nz');

@$core.Deprecated('Use spanDescriptor instead')
const Span$json = {
  '1': 'Span',
  '2': [
    {'1': 'start', '3': 1, '4': 1, '5': 5, '10': 'start'},
    {'1': 'end', '3': 2, '4': 1, '5': 5, '10': 'end'},
  ],
};

/// Descriptor for `Span`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List spanDescriptor = $convert.base64Decode(
    'CgRTcGFuEhQKBXN0YXJ0GAEgASgFUgVzdGFydBIQCgNlbmQYAiABKAVSA2VuZA==');
