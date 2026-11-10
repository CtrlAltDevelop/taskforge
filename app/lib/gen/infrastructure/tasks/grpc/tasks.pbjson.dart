// This is a generated file - do not edit.
//
// Generated from infrastructure/tasks/grpc/tasks.proto.

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

@$core.Deprecated('Use boardColumnDescriptor instead')
const BoardColumn$json = {
  '1': 'BoardColumn',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'count', '3': 3, '4': 1, '5': 5, '10': 'count'},
    {
      '1': 'tasks',
      '3': 4,
      '4': 3,
      '5': 11,
      '6': '.config.tasks.Task',
      '10': 'tasks'
    },
    {'1': 'cursor', '3': 5, '4': 1, '5': 9, '10': 'cursor'},
  ],
};

/// Descriptor for `BoardColumn`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List boardColumnDescriptor = $convert.base64Decode(
    'CgtCb2FyZENvbHVtbhIQCgNrZXkYASABKAlSA2tleRISCgRuYW1lGAIgASgJUgRuYW1lEhQKBW'
    'NvdW50GAMgASgFUgVjb3VudBIoCgV0YXNrcxgEIAMoCzISLmNvbmZpZy50YXNrcy5UYXNrUgV0'
    'YXNrcxIWCgZjdXJzb3IYBSABKAlSBmN1cnNvcg==');

@$core.Deprecated('Use boardGetRequestDescriptor instead')
const BoardGetRequest$json = {
  '1': 'BoardGetRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'group_by', '3': 3, '4': 1, '5': 9, '10': 'groupBy'},
    {'1': 'swimlane', '3': 4, '4': 1, '5': 9, '10': 'swimlane'},
    {'1': 'page_size', '3': 5, '4': 1, '5': 5, '10': 'pageSize'},
    {'1': 'filter_ast', '3': 6, '4': 1, '5': 9, '10': 'filterAst'},
    {'1': 'today', '3': 7, '4': 1, '5': 9, '10': 'today'},
  ],
};

/// Descriptor for `BoardGetRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List boardGetRequestDescriptor = $convert.base64Decode(
    'Cg9Cb2FyZEdldFJlcXVlc3QSIQoMd29ya3NwYWNlX2lkGAEgASgJUgt3b3Jrc3BhY2VJZBIdCg'
    'pwcm9qZWN0X2lkGAIgASgJUglwcm9qZWN0SWQSGQoIZ3JvdXBfYnkYAyABKAlSB2dyb3VwQnkS'
    'GgoIc3dpbWxhbmUYBCABKAlSCHN3aW1sYW5lEhsKCXBhZ2Vfc2l6ZRgFIAEoBVIIcGFnZVNpem'
    'USHQoKZmlsdGVyX2FzdBgGIAEoCVIJZmlsdGVyQXN0EhQKBXRvZGF5GAcgASgJUgV0b2RheQ==');

@$core.Deprecated('Use boardLaneDescriptor instead')
const BoardLane$json = {
  '1': 'BoardLane',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {
      '1': 'columns',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.config.tasks.BoardColumn',
      '10': 'columns'
    },
  ],
};

/// Descriptor for `BoardLane`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List boardLaneDescriptor = $convert.base64Decode(
    'CglCb2FyZExhbmUSEAoDa2V5GAEgASgJUgNrZXkSMwoHY29sdW1ucxgCIAMoCzIZLmNvbmZpZy'
    '50YXNrcy5Cb2FyZENvbHVtblIHY29sdW1ucw==');

@$core.Deprecated('Use boardListColumnRequestDescriptor instead')
const BoardListColumnRequest$json = {
  '1': 'BoardListColumnRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'group_by', '3': 3, '4': 1, '5': 9, '10': 'groupBy'},
    {'1': 'swimlane', '3': 4, '4': 1, '5': 9, '10': 'swimlane'},
    {'1': 'page_size', '3': 5, '4': 1, '5': 5, '10': 'pageSize'},
    {'1': 'column', '3': 6, '4': 1, '5': 9, '10': 'column'},
    {'1': 'lane', '3': 7, '4': 1, '5': 9, '10': 'lane'},
    {'1': 'cursor', '3': 8, '4': 1, '5': 9, '10': 'cursor'},
    {'1': 'filter_ast', '3': 9, '4': 1, '5': 9, '10': 'filterAst'},
    {'1': 'today', '3': 10, '4': 1, '5': 9, '10': 'today'},
  ],
};

/// Descriptor for `BoardListColumnRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List boardListColumnRequestDescriptor = $convert.base64Decode(
    'ChZCb2FyZExpc3RDb2x1bW5SZXF1ZXN0EiEKDHdvcmtzcGFjZV9pZBgBIAEoCVILd29ya3NwYW'
    'NlSWQSHQoKcHJvamVjdF9pZBgCIAEoCVIJcHJvamVjdElkEhkKCGdyb3VwX2J5GAMgASgJUgdn'
    'cm91cEJ5EhoKCHN3aW1sYW5lGAQgASgJUghzd2ltbGFuZRIbCglwYWdlX3NpemUYBSABKAVSCH'
    'BhZ2VTaXplEhYKBmNvbHVtbhgGIAEoCVIGY29sdW1uEhIKBGxhbmUYByABKAlSBGxhbmUSFgoG'
    'Y3Vyc29yGAggASgJUgZjdXJzb3ISHQoKZmlsdGVyX2FzdBgJIAEoCVIJZmlsdGVyQXN0EhQKBX'
    'RvZGF5GAogASgJUgV0b2RheQ==');

@$core.Deprecated('Use boardMoveRequestDescriptor instead')
const BoardMoveRequest$json = {
  '1': 'BoardMoveRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'id', '3': 3, '4': 1, '5': 9, '10': 'id'},
    {'1': 'expected_version', '3': 4, '4': 1, '5': 5, '10': 'expectedVersion'},
    {'1': 'group_by', '3': 5, '4': 1, '5': 9, '10': 'groupBy'},
    {'1': 'column', '3': 6, '4': 1, '5': 9, '10': 'column'},
    {'1': 'before_id', '3': 7, '4': 1, '5': 9, '10': 'beforeId'},
    {'1': 'after_id', '3': 8, '4': 1, '5': 9, '10': 'afterId'},
    {'1': 'include_subtasks', '3': 9, '4': 1, '5': 8, '10': 'includeSubtasks'},
    {'1': 'override_blocked', '3': 10, '4': 1, '5': 8, '10': 'overrideBlocked'},
  ],
};

/// Descriptor for `BoardMoveRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List boardMoveRequestDescriptor = $convert.base64Decode(
    'ChBCb2FyZE1vdmVSZXF1ZXN0EiEKDHdvcmtzcGFjZV9pZBgBIAEoCVILd29ya3NwYWNlSWQSHQ'
    'oKcHJvamVjdF9pZBgCIAEoCVIJcHJvamVjdElkEg4KAmlkGAMgASgJUgJpZBIpChBleHBlY3Rl'
    'ZF92ZXJzaW9uGAQgASgFUg9leHBlY3RlZFZlcnNpb24SGQoIZ3JvdXBfYnkYBSABKAlSB2dyb3'
    'VwQnkSFgoGY29sdW1uGAYgASgJUgZjb2x1bW4SGwoJYmVmb3JlX2lkGAcgASgJUghiZWZvcmVJ'
    'ZBIZCghhZnRlcl9pZBgIIAEoCVIHYWZ0ZXJJZBIpChBpbmNsdWRlX3N1YnRhc2tzGAkgASgIUg'
    '9pbmNsdWRlU3VidGFza3MSKQoQb3ZlcnJpZGVfYmxvY2tlZBgKIAEoCFIPb3ZlcnJpZGVCbG9j'
    'a2Vk');

@$core.Deprecated('Use boardPageDescriptor instead')
const BoardPage$json = {
  '1': 'BoardPage',
  '2': [
    {
      '1': 'tasks',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.config.tasks.Task',
      '10': 'tasks'
    },
    {'1': 'cursor', '3': 2, '4': 1, '5': 9, '10': 'cursor'},
  ],
};

/// Descriptor for `BoardPage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List boardPageDescriptor = $convert.base64Decode(
    'CglCb2FyZFBhZ2USKAoFdGFza3MYASADKAsyEi5jb25maWcudGFza3MuVGFza1IFdGFza3MSFg'
    'oGY3Vyc29yGAIgASgJUgZjdXJzb3I=');

@$core.Deprecated('Use boardViewDescriptor instead')
const BoardView$json = {
  '1': 'BoardView',
  '2': [
    {
      '1': 'lanes',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.config.tasks.BoardLane',
      '10': 'lanes'
    },
  ],
};

/// Descriptor for `BoardView`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List boardViewDescriptor = $convert.base64Decode(
    'CglCb2FyZFZpZXcSLQoFbGFuZXMYASADKAsyFy5jb25maWcudGFza3MuQm9hcmRMYW5lUgVsYW'
    '5lcw==');

@$core.Deprecated('Use bulkResultDescriptor instead')
const BulkResult$json = {
  '1': 'BulkResult',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'ok', '3': 2, '4': 1, '5': 8, '10': 'ok'},
    {'1': 'code', '3': 3, '4': 1, '5': 9, '10': 'code'},
    {'1': 'message', '3': 4, '4': 1, '5': 9, '10': 'message'},
    {'1': 'detail', '3': 5, '4': 1, '5': 9, '10': 'detail'},
    {
      '1': 'task',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.config.tasks.TaskResponse',
      '10': 'task'
    },
  ],
};

/// Descriptor for `BulkResult`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List bulkResultDescriptor = $convert.base64Decode(
    'CgpCdWxrUmVzdWx0Eg4KAmlkGAEgASgJUgJpZBIOCgJvaxgCIAEoCFICb2sSEgoEY29kZRgDIA'
    'EoCVIEY29kZRIYCgdtZXNzYWdlGAQgASgJUgdtZXNzYWdlEhYKBmRldGFpbBgFIAEoCVIGZGV0'
    'YWlsEi4KBHRhc2sYBiABKAsyGi5jb25maWcudGFza3MuVGFza1Jlc3BvbnNlUgR0YXNr');

@$core.Deprecated('Use calendarRangeRequestDescriptor instead')
const CalendarRangeRequest$json = {
  '1': 'CalendarRangeRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'range_start', '3': 3, '4': 1, '5': 9, '10': 'rangeStart'},
    {'1': 'range_end', '3': 4, '4': 1, '5': 9, '10': 'rangeEnd'},
    {'1': 'include_done', '3': 5, '4': 1, '5': 8, '10': 'includeDone'},
    {'1': 'filter_ast', '3': 6, '4': 1, '5': 9, '10': 'filterAst'},
    {'1': 'today', '3': 7, '4': 1, '5': 9, '10': 'today'},
  ],
};

/// Descriptor for `CalendarRangeRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List calendarRangeRequestDescriptor = $convert.base64Decode(
    'ChRDYWxlbmRhclJhbmdlUmVxdWVzdBIhCgx3b3Jrc3BhY2VfaWQYASABKAlSC3dvcmtzcGFjZU'
    'lkEh0KCnByb2plY3RfaWQYAiABKAlSCXByb2plY3RJZBIfCgtyYW5nZV9zdGFydBgDIAEoCVIK'
    'cmFuZ2VTdGFydBIbCglyYW5nZV9lbmQYBCABKAlSCHJhbmdlRW5kEiEKDGluY2x1ZGVfZG9uZR'
    'gFIAEoCFILaW5jbHVkZURvbmUSHQoKZmlsdGVyX2FzdBgGIAEoCVIJZmlsdGVyQXN0EhQKBXRv'
    'ZGF5GAcgASgJUgV0b2RheQ==');

@$core.Deprecated('Use calendarTrayDescriptor instead')
const CalendarTray$json = {
  '1': 'CalendarTray',
  '2': [
    {
      '1': 'tasks',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.config.tasks.Task',
      '10': 'tasks'
    },
    {'1': 'cursor', '3': 2, '4': 1, '5': 9, '10': 'cursor'},
  ],
};

/// Descriptor for `CalendarTray`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List calendarTrayDescriptor = $convert.base64Decode(
    'CgxDYWxlbmRhclRyYXkSKAoFdGFza3MYASADKAsyEi5jb25maWcudGFza3MuVGFza1IFdGFza3'
    'MSFgoGY3Vyc29yGAIgASgJUgZjdXJzb3I=');

@$core.Deprecated('Use calendarTrayRequestDescriptor instead')
const CalendarTrayRequest$json = {
  '1': 'CalendarTrayRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'cursor', '3': 3, '4': 1, '5': 9, '10': 'cursor'},
    {'1': 'page_size', '3': 4, '4': 1, '5': 5, '10': 'pageSize'},
  ],
};

/// Descriptor for `CalendarTrayRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List calendarTrayRequestDescriptor = $convert.base64Decode(
    'ChNDYWxlbmRhclRyYXlSZXF1ZXN0EiEKDHdvcmtzcGFjZV9pZBgBIAEoCVILd29ya3NwYWNlSW'
    'QSHQoKcHJvamVjdF9pZBgCIAEoCVIJcHJvamVjdElkEhYKBmN1cnNvchgDIAEoCVIGY3Vyc29y'
    'EhsKCXBhZ2Vfc2l6ZRgEIAEoBVIIcGFnZVNpemU=');

@$core.Deprecated('Use calendarWorkspaceRangeRequestDescriptor instead')
const CalendarWorkspaceRangeRequest$json = {
  '1': 'CalendarWorkspaceRangeRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'range_start', '3': 2, '4': 1, '5': 9, '10': 'rangeStart'},
    {'1': 'range_end', '3': 3, '4': 1, '5': 9, '10': 'rangeEnd'},
    {'1': 'include_done', '3': 4, '4': 1, '5': 8, '10': 'includeDone'},
    {'1': 'project_ids', '3': 5, '4': 3, '5': 9, '10': 'projectIds'},
    {'1': 'filter_ast', '3': 6, '4': 1, '5': 9, '10': 'filterAst'},
    {'1': 'today', '3': 7, '4': 1, '5': 9, '10': 'today'},
  ],
};

/// Descriptor for `CalendarWorkspaceRangeRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List calendarWorkspaceRangeRequestDescriptor = $convert.base64Decode(
    'Ch1DYWxlbmRhcldvcmtzcGFjZVJhbmdlUmVxdWVzdBIhCgx3b3Jrc3BhY2VfaWQYASABKAlSC3'
    'dvcmtzcGFjZUlkEh8KC3JhbmdlX3N0YXJ0GAIgASgJUgpyYW5nZVN0YXJ0EhsKCXJhbmdlX2Vu'
    'ZBgDIAEoCVIIcmFuZ2VFbmQSIQoMaW5jbHVkZV9kb25lGAQgASgIUgtpbmNsdWRlRG9uZRIfCg'
    'twcm9qZWN0X2lkcxgFIAMoCVIKcHJvamVjdElkcxIdCgpmaWx0ZXJfYXN0GAYgASgJUglmaWx0'
    'ZXJBc3QSFAoFdG9kYXkYByABKAlSBXRvZGF5');

@$core.Deprecated('Use groupCountDescriptor instead')
const GroupCount$json = {
  '1': 'GroupCount',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'count', '3': 2, '4': 1, '5': 5, '10': 'count'},
  ],
};

/// Descriptor for `GroupCount`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List groupCountDescriptor = $convert.base64Decode(
    'CgpHcm91cENvdW50EhAKA2tleRgBIAEoCVIDa2V5EhQKBWNvdW50GAIgASgFUgVjb3VudA==');

@$core.Deprecated('Use linkDescriptor instead')
const Link$json = {
  '1': 'Link',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'kind', '3': 2, '4': 1, '5': 9, '10': 'kind'},
    {'1': 'restricted', '3': 3, '4': 1, '5': 8, '10': 'restricted'},
    {'1': 'other_id', '3': 4, '4': 1, '5': 9, '10': 'otherId'},
    {'1': 'other_project_id', '3': 5, '4': 1, '5': 9, '10': 'otherProjectId'},
    {'1': 'other_display_id', '3': 6, '4': 1, '5': 9, '10': 'otherDisplayId'},
    {'1': 'other_title', '3': 7, '4': 1, '5': 9, '10': 'otherTitle'},
    {'1': 'other_status_name', '3': 8, '4': 1, '5': 9, '10': 'otherStatusName'},
    {
      '1': 'other_status_category',
      '3': 9,
      '4': 1,
      '5': 9,
      '10': 'otherStatusCategory'
    },
  ],
};

/// Descriptor for `Link`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List linkDescriptor = $convert.base64Decode(
    'CgRMaW5rEg4KAmlkGAEgASgJUgJpZBISCgRraW5kGAIgASgJUgRraW5kEh4KCnJlc3RyaWN0ZW'
    'QYAyABKAhSCnJlc3RyaWN0ZWQSGQoIb3RoZXJfaWQYBCABKAlSB290aGVySWQSKAoQb3RoZXJf'
    'cHJvamVjdF9pZBgFIAEoCVIOb3RoZXJQcm9qZWN0SWQSKAoQb3RoZXJfZGlzcGxheV9pZBgGIA'
    'EoCVIOb3RoZXJEaXNwbGF5SWQSHwoLb3RoZXJfdGl0bGUYByABKAlSCm90aGVyVGl0bGUSKgoR'
    'b3RoZXJfc3RhdHVzX25hbWUYCCABKAlSD290aGVyU3RhdHVzTmFtZRIyChVvdGhlcl9zdGF0dX'
    'NfY2F0ZWdvcnkYCSABKAlSE290aGVyU3RhdHVzQ2F0ZWdvcnk=');

@$core.Deprecated('Use linkAddRequestDescriptor instead')
const LinkAddRequest$json = {
  '1': 'LinkAddRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'task_id', '3': 2, '4': 1, '5': 9, '10': 'taskId'},
    {'1': 'other_task_id', '3': 3, '4': 1, '5': 9, '10': 'otherTaskId'},
    {'1': 'kind', '3': 4, '4': 1, '5': 9, '10': 'kind'},
    {'1': 'close_duplicate', '3': 5, '4': 1, '5': 8, '10': 'closeDuplicate'},
  ],
};

/// Descriptor for `LinkAddRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List linkAddRequestDescriptor = $convert.base64Decode(
    'Cg5MaW5rQWRkUmVxdWVzdBIhCgx3b3Jrc3BhY2VfaWQYASABKAlSC3dvcmtzcGFjZUlkEhcKB3'
    'Rhc2tfaWQYAiABKAlSBnRhc2tJZBIiCg1vdGhlcl90YXNrX2lkGAMgASgJUgtvdGhlclRhc2tJ'
    'ZBISCgRraW5kGAQgASgJUgRraW5kEicKD2Nsb3NlX2R1cGxpY2F0ZRgFIAEoCFIOY2xvc2VEdX'
    'BsaWNhdGU=');

@$core.Deprecated('Use linkCandidateDescriptor instead')
const LinkCandidate$json = {
  '1': 'LinkCandidate',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'display_id', '3': 3, '4': 1, '5': 9, '10': 'displayId'},
    {'1': 'title', '3': 4, '4': 1, '5': 9, '10': 'title'},
    {'1': 'status_name', '3': 5, '4': 1, '5': 9, '10': 'statusName'},
    {'1': 'status_category', '3': 6, '4': 1, '5': 9, '10': 'statusCategory'},
  ],
};

/// Descriptor for `LinkCandidate`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List linkCandidateDescriptor = $convert.base64Decode(
    'Cg1MaW5rQ2FuZGlkYXRlEg4KAmlkGAEgASgJUgJpZBIdCgpwcm9qZWN0X2lkGAIgASgJUglwcm'
    '9qZWN0SWQSHQoKZGlzcGxheV9pZBgDIAEoCVIJZGlzcGxheUlkEhQKBXRpdGxlGAQgASgJUgV0'
    'aXRsZRIfCgtzdGF0dXNfbmFtZRgFIAEoCVIKc3RhdHVzTmFtZRInCg9zdGF0dXNfY2F0ZWdvcn'
    'kYBiABKAlSDnN0YXR1c0NhdGVnb3J5');

@$core.Deprecated('Use linkCandidatesDescriptor instead')
const LinkCandidates$json = {
  '1': 'LinkCandidates',
  '2': [
    {
      '1': 'tasks',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.config.tasks.LinkCandidate',
      '10': 'tasks'
    },
  ],
};

/// Descriptor for `LinkCandidates`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List linkCandidatesDescriptor = $convert.base64Decode(
    'Cg5MaW5rQ2FuZGlkYXRlcxIxCgV0YXNrcxgBIAMoCzIbLmNvbmZpZy50YXNrcy5MaW5rQ2FuZG'
    'lkYXRlUgV0YXNrcw==');

@$core.Deprecated('Use linkListDescriptor instead')
const LinkList$json = {
  '1': 'LinkList',
  '2': [
    {
      '1': 'links',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.config.tasks.Link',
      '10': 'links'
    },
  ],
};

/// Descriptor for `LinkList`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List linkListDescriptor = $convert.base64Decode(
    'CghMaW5rTGlzdBIoCgVsaW5rcxgBIAMoCzISLmNvbmZpZy50YXNrcy5MaW5rUgVsaW5rcw==');

@$core.Deprecated('Use linkListForTaskRequestDescriptor instead')
const LinkListForTaskRequest$json = {
  '1': 'LinkListForTaskRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'task_id', '3': 2, '4': 1, '5': 9, '10': 'taskId'},
  ],
};

/// Descriptor for `LinkListForTaskRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List linkListForTaskRequestDescriptor =
    $convert.base64Decode(
        'ChZMaW5rTGlzdEZvclRhc2tSZXF1ZXN0EiEKDHdvcmtzcGFjZV9pZBgBIAEoCVILd29ya3NwYW'
        'NlSWQSFwoHdGFza19pZBgCIAEoCVIGdGFza0lk');

@$core.Deprecated('Use linkRemoveRequestDescriptor instead')
const LinkRemoveRequest$json = {
  '1': 'LinkRemoveRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'task_id', '3': 2, '4': 1, '5': 9, '10': 'taskId'},
    {'1': 'id', '3': 3, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `LinkRemoveRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List linkRemoveRequestDescriptor = $convert.base64Decode(
    'ChFMaW5rUmVtb3ZlUmVxdWVzdBIhCgx3b3Jrc3BhY2VfaWQYASABKAlSC3dvcmtzcGFjZUlkEh'
    'cKB3Rhc2tfaWQYAiABKAlSBnRhc2tJZBIOCgJpZBgDIAEoCVICaWQ=');

@$core.Deprecated('Use linkSearchTasksRequestDescriptor instead')
const LinkSearchTasksRequest$json = {
  '1': 'LinkSearchTasksRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'query', '3': 2, '4': 1, '5': 9, '10': 'query'},
  ],
};

/// Descriptor for `LinkSearchTasksRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List linkSearchTasksRequestDescriptor =
    $convert.base64Decode(
        'ChZMaW5rU2VhcmNoVGFza3NSZXF1ZXN0EiEKDHdvcmtzcGFjZV9pZBgBIAEoCVILd29ya3NwYW'
        'NlSWQSFAoFcXVlcnkYAiABKAlSBXF1ZXJ5');

@$core.Deprecated('Use sortKeyDescriptor instead')
const SortKey$json = {
  '1': 'SortKey',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'desc', '3': 2, '4': 1, '5': 8, '10': 'desc'},
  ],
};

/// Descriptor for `SortKey`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sortKeyDescriptor = $convert.base64Decode(
    'CgdTb3J0S2V5EhAKA2tleRgBIAEoCVIDa2V5EhIKBGRlc2MYAiABKAhSBGRlc2M=');

@$core.Deprecated('Use taskDescriptor instead')
const Task$json = {
  '1': 'Task',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'workspace_id', '3': 2, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'project_id', '3': 3, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'number', '3': 4, '4': 1, '5': 5, '10': 'number'},
    {'1': 'display_id', '3': 5, '4': 1, '5': 9, '10': 'displayId'},
    {'1': 'title', '3': 6, '4': 1, '5': 9, '10': 'title'},
    {'1': 'description', '3': 7, '4': 1, '5': 9, '10': 'description'},
    {'1': 'status', '3': 8, '4': 1, '5': 9, '10': 'status'},
    {'1': 'priority', '3': 9, '4': 1, '5': 9, '10': 'priority'},
    {'1': 'start_date', '3': 10, '4': 1, '5': 9, '10': 'startDate'},
    {'1': 'due_date', '3': 11, '4': 1, '5': 9, '10': 'dueDate'},
    {'1': 'assignee_ids', '3': 12, '4': 3, '5': 9, '10': 'assigneeIds'},
    {'1': 'created_by', '3': 13, '4': 1, '5': 9, '10': 'createdBy'},
    {'1': 'version', '3': 14, '4': 1, '5': 5, '10': 'version'},
    {'1': 'position', '3': 15, '4': 1, '5': 9, '10': 'position'},
    {'1': 'created_at', '3': 16, '4': 1, '5': 9, '10': 'createdAt'},
    {'1': 'updated_at', '3': 17, '4': 1, '5': 9, '10': 'updatedAt'},
    {'1': 'deleted_at', '3': 18, '4': 1, '5': 9, '10': 'deletedAt'},
    {'1': 'status_name', '3': 19, '4': 1, '5': 9, '10': 'statusName'},
    {'1': 'status_category', '3': 20, '4': 1, '5': 9, '10': 'statusCategory'},
    {'1': 'parent_id', '3': 21, '4': 1, '5': 9, '10': 'parentId'},
    {'1': 'depth', '3': 22, '4': 1, '5': 5, '10': 'depth'},
    {'1': 'progress_done', '3': 23, '4': 1, '5': 5, '10': 'progressDone'},
    {'1': 'progress_total', '3': 24, '4': 1, '5': 5, '10': 'progressTotal'},
    {'1': 'is_blocked', '3': 25, '4': 1, '5': 8, '10': 'isBlocked'},
    {'1': 'blocked_by', '3': 26, '4': 3, '5': 9, '10': 'blockedBy'},
    {
      '1': 'fields',
      '3': 27,
      '4': 3,
      '5': 11,
      '6': '.config.tasks.TaskFieldValue',
      '10': 'fields'
    },
    {'1': 'group_key', '3': 28, '4': 1, '5': 9, '10': 'groupKey'},
    {'1': 'due_time', '3': 29, '4': 1, '5': 9, '10': 'dueTime'},
    {'1': 'blockers_due', '3': 30, '4': 1, '5': 9, '10': 'blockersDue'},
    {'1': 'blocks_due', '3': 31, '4': 1, '5': 9, '10': 'blocksDue'},
  ],
};

/// Descriptor for `Task`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List taskDescriptor = $convert.base64Decode(
    'CgRUYXNrEg4KAmlkGAEgASgJUgJpZBIhCgx3b3Jrc3BhY2VfaWQYAiABKAlSC3dvcmtzcGFjZU'
    'lkEh0KCnByb2plY3RfaWQYAyABKAlSCXByb2plY3RJZBIWCgZudW1iZXIYBCABKAVSBm51bWJl'
    'chIdCgpkaXNwbGF5X2lkGAUgASgJUglkaXNwbGF5SWQSFAoFdGl0bGUYBiABKAlSBXRpdGxlEi'
    'AKC2Rlc2NyaXB0aW9uGAcgASgJUgtkZXNjcmlwdGlvbhIWCgZzdGF0dXMYCCABKAlSBnN0YXR1'
    'cxIaCghwcmlvcml0eRgJIAEoCVIIcHJpb3JpdHkSHQoKc3RhcnRfZGF0ZRgKIAEoCVIJc3Rhcn'
    'REYXRlEhkKCGR1ZV9kYXRlGAsgASgJUgdkdWVEYXRlEiEKDGFzc2lnbmVlX2lkcxgMIAMoCVIL'
    'YXNzaWduZWVJZHMSHQoKY3JlYXRlZF9ieRgNIAEoCVIJY3JlYXRlZEJ5EhgKB3ZlcnNpb24YDi'
    'ABKAVSB3ZlcnNpb24SGgoIcG9zaXRpb24YDyABKAlSCHBvc2l0aW9uEh0KCmNyZWF0ZWRfYXQY'
    'ECABKAlSCWNyZWF0ZWRBdBIdCgp1cGRhdGVkX2F0GBEgASgJUgl1cGRhdGVkQXQSHQoKZGVsZX'
    'RlZF9hdBgSIAEoCVIJZGVsZXRlZEF0Eh8KC3N0YXR1c19uYW1lGBMgASgJUgpzdGF0dXNOYW1l'
    'EicKD3N0YXR1c19jYXRlZ29yeRgUIAEoCVIOc3RhdHVzQ2F0ZWdvcnkSGwoJcGFyZW50X2lkGB'
    'UgASgJUghwYXJlbnRJZBIUCgVkZXB0aBgWIAEoBVIFZGVwdGgSIwoNcHJvZ3Jlc3NfZG9uZRgX'
    'IAEoBVIMcHJvZ3Jlc3NEb25lEiUKDnByb2dyZXNzX3RvdGFsGBggASgFUg1wcm9ncmVzc1RvdG'
    'FsEh0KCmlzX2Jsb2NrZWQYGSABKAhSCWlzQmxvY2tlZBIdCgpibG9ja2VkX2J5GBogAygJUgli'
    'bG9ja2VkQnkSNAoGZmllbGRzGBsgAygLMhwuY29uZmlnLnRhc2tzLlRhc2tGaWVsZFZhbHVlUg'
    'ZmaWVsZHMSGwoJZ3JvdXBfa2V5GBwgASgJUghncm91cEtleRIZCghkdWVfdGltZRgdIAEoCVIH'
    'ZHVlVGltZRIhCgxibG9ja2Vyc19kdWUYHiABKAlSC2Jsb2NrZXJzRHVlEh0KCmJsb2Nrc19kdW'
    'UYHyABKAlSCWJsb2Nrc0R1ZQ==');

@$core.Deprecated('Use taskBulkUpdateRequestDescriptor instead')
const TaskBulkUpdateRequest$json = {
  '1': 'TaskBulkUpdateRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'ids', '3': 3, '4': 3, '5': 9, '10': 'ids'},
    {'1': 'status', '3': 4, '4': 1, '5': 9, '9': 0, '10': 'status', '17': true},
    {
      '1': 'priority',
      '3': 5,
      '4': 1,
      '5': 9,
      '9': 1,
      '10': 'priority',
      '17': true
    },
    {'1': 'set_assignees', '3': 6, '4': 1, '5': 8, '10': 'setAssignees'},
    {'1': 'assignee_ids', '3': 7, '4': 3, '5': 9, '10': 'assigneeIds'},
    {'1': 'delete', '3': 8, '4': 1, '5': 8, '10': 'delete'},
    {'1': 'delete_mode', '3': 9, '4': 1, '5': 9, '10': 'deleteMode'},
  ],
  '8': [
    {'1': '_status'},
    {'1': '_priority'},
  ],
};

/// Descriptor for `TaskBulkUpdateRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List taskBulkUpdateRequestDescriptor = $convert.base64Decode(
    'ChVUYXNrQnVsa1VwZGF0ZVJlcXVlc3QSIQoMd29ya3NwYWNlX2lkGAEgASgJUgt3b3Jrc3BhY2'
    'VJZBIdCgpwcm9qZWN0X2lkGAIgASgJUglwcm9qZWN0SWQSEAoDaWRzGAMgAygJUgNpZHMSGwoG'
    'c3RhdHVzGAQgASgJSABSBnN0YXR1c4gBARIfCghwcmlvcml0eRgFIAEoCUgBUghwcmlvcml0eY'
    'gBARIjCg1zZXRfYXNzaWduZWVzGAYgASgIUgxzZXRBc3NpZ25lZXMSIQoMYXNzaWduZWVfaWRz'
    'GAcgAygJUgthc3NpZ25lZUlkcxIWCgZkZWxldGUYCCABKAhSBmRlbGV0ZRIfCgtkZWxldGVfbW'
    '9kZRgJIAEoCVIKZGVsZXRlTW9kZUIJCgdfc3RhdHVzQgsKCV9wcmlvcml0eQ==');

@$core.Deprecated('Use taskChildrenDescriptor instead')
const TaskChildren$json = {
  '1': 'TaskChildren',
  '2': [
    {
      '1': 'tasks',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.config.tasks.Task',
      '10': 'tasks'
    },
  ],
};

/// Descriptor for `TaskChildren`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List taskChildrenDescriptor = $convert.base64Decode(
    'CgxUYXNrQ2hpbGRyZW4SKAoFdGFza3MYASADKAsyEi5jb25maWcudGFza3MuVGFza1IFdGFza3'
    'M=');

@$core.Deprecated('Use taskCreateRequestDescriptor instead')
const TaskCreateRequest$json = {
  '1': 'TaskCreateRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'title', '3': 3, '4': 1, '5': 9, '10': 'title'},
    {'1': 'description', '3': 4, '4': 1, '5': 9, '10': 'description'},
    {'1': 'status', '3': 5, '4': 1, '5': 9, '10': 'status'},
    {'1': 'priority', '3': 6, '4': 1, '5': 9, '10': 'priority'},
    {'1': 'start_date', '3': 7, '4': 1, '5': 9, '10': 'startDate'},
    {'1': 'due_date', '3': 8, '4': 1, '5': 9, '10': 'dueDate'},
    {'1': 'assignee_ids', '3': 9, '4': 3, '5': 9, '10': 'assigneeIds'},
    {'1': 'parent_id', '3': 10, '4': 1, '5': 9, '10': 'parentId'},
    {
      '1': 'field_values',
      '3': 11,
      '4': 3,
      '5': 11,
      '6': '.config.tasks.TaskFieldValue',
      '10': 'fieldValues'
    },
    {'1': 'due_time', '3': 12, '4': 1, '5': 9, '10': 'dueTime'},
  ],
};

/// Descriptor for `TaskCreateRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List taskCreateRequestDescriptor = $convert.base64Decode(
    'ChFUYXNrQ3JlYXRlUmVxdWVzdBIhCgx3b3Jrc3BhY2VfaWQYASABKAlSC3dvcmtzcGFjZUlkEh'
    '0KCnByb2plY3RfaWQYAiABKAlSCXByb2plY3RJZBIUCgV0aXRsZRgDIAEoCVIFdGl0bGUSIAoL'
    'ZGVzY3JpcHRpb24YBCABKAlSC2Rlc2NyaXB0aW9uEhYKBnN0YXR1cxgFIAEoCVIGc3RhdHVzEh'
    'oKCHByaW9yaXR5GAYgASgJUghwcmlvcml0eRIdCgpzdGFydF9kYXRlGAcgASgJUglzdGFydERh'
    'dGUSGQoIZHVlX2RhdGUYCCABKAlSB2R1ZURhdGUSIQoMYXNzaWduZWVfaWRzGAkgAygJUgthc3'
    'NpZ25lZUlkcxIbCglwYXJlbnRfaWQYCiABKAlSCHBhcmVudElkEj8KDGZpZWxkX3ZhbHVlcxgL'
    'IAMoCzIcLmNvbmZpZy50YXNrcy5UYXNrRmllbGRWYWx1ZVILZmllbGRWYWx1ZXMSGQoIZHVlX3'
    'RpbWUYDCABKAlSB2R1ZVRpbWU=');

@$core.Deprecated('Use taskDeleteRequestDescriptor instead')
const TaskDeleteRequest$json = {
  '1': 'TaskDeleteRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'id', '3': 3, '4': 1, '5': 9, '10': 'id'},
    {'1': 'mode', '3': 4, '4': 1, '5': 9, '10': 'mode'},
  ],
};

/// Descriptor for `TaskDeleteRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List taskDeleteRequestDescriptor = $convert.base64Decode(
    'ChFUYXNrRGVsZXRlUmVxdWVzdBIhCgx3b3Jrc3BhY2VfaWQYASABKAlSC3dvcmtzcGFjZUlkEh'
    '0KCnByb2plY3RfaWQYAiABKAlSCXByb2plY3RJZBIOCgJpZBgDIAEoCVICaWQSEgoEbW9kZRgE'
    'IAEoCVIEbW9kZQ==');

@$core.Deprecated('Use taskFieldValueDescriptor instead')
const TaskFieldValue$json = {
  '1': 'TaskFieldValue',
  '2': [
    {'1': 'field_id', '3': 1, '4': 1, '5': 9, '10': 'fieldId'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
};

/// Descriptor for `TaskFieldValue`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List taskFieldValueDescriptor = $convert.base64Decode(
    'Cg5UYXNrRmllbGRWYWx1ZRIZCghmaWVsZF9pZBgBIAEoCVIHZmllbGRJZBIUCgV2YWx1ZRgCIA'
    'EoCVIFdmFsdWU=');

@$core.Deprecated('Use taskFieldValueResponseDescriptor instead')
const TaskFieldValueResponse$json = {
  '1': 'TaskFieldValueResponse',
  '2': [
    {'1': 'field_id', '3': 1, '4': 1, '5': 9, '10': 'fieldId'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
};

/// Descriptor for `TaskFieldValueResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List taskFieldValueResponseDescriptor =
    $convert.base64Decode(
        'ChZUYXNrRmllbGRWYWx1ZVJlc3BvbnNlEhkKCGZpZWxkX2lkGAEgASgJUgdmaWVsZElkEhQKBX'
        'ZhbHVlGAIgASgJUgV2YWx1ZQ==');

@$core.Deprecated('Use taskGetRequestDescriptor instead')
const TaskGetRequest$json = {
  '1': 'TaskGetRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'id', '3': 3, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `TaskGetRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List taskGetRequestDescriptor = $convert.base64Decode(
    'Cg5UYXNrR2V0UmVxdWVzdBIhCgx3b3Jrc3BhY2VfaWQYASABKAlSC3dvcmtzcGFjZUlkEh0KCn'
    'Byb2plY3RfaWQYAiABKAlSCXByb2plY3RJZBIOCgJpZBgDIAEoCVICaWQ=');

@$core.Deprecated('Use taskGroupCountsDescriptor instead')
const TaskGroupCounts$json = {
  '1': 'TaskGroupCounts',
  '2': [
    {
      '1': 'groups',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.config.tasks.GroupCount',
      '10': 'groups'
    },
  ],
};

/// Descriptor for `TaskGroupCounts`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List taskGroupCountsDescriptor = $convert.base64Decode(
    'Cg9UYXNrR3JvdXBDb3VudHMSMAoGZ3JvdXBzGAEgAygLMhguY29uZmlnLnRhc2tzLkdyb3VwQ2'
    '91bnRSBmdyb3Vwcw==');

@$core.Deprecated('Use taskGroupCountsRequestDescriptor instead')
const TaskGroupCountsRequest$json = {
  '1': 'TaskGroupCountsRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'group_by', '3': 3, '4': 1, '5': 9, '10': 'groupBy'},
    {'1': 'status', '3': 4, '4': 1, '5': 9, '10': 'status'},
    {'1': 'assignee_id', '3': 5, '4': 1, '5': 9, '10': 'assigneeId'},
    {'1': 'include_subtasks', '3': 6, '4': 1, '5': 8, '10': 'includeSubtasks'},
    {'1': 'filter_ast', '3': 7, '4': 1, '5': 9, '10': 'filterAst'},
    {'1': 'today', '3': 8, '4': 1, '5': 9, '10': 'today'},
  ],
};

/// Descriptor for `TaskGroupCountsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List taskGroupCountsRequestDescriptor = $convert.base64Decode(
    'ChZUYXNrR3JvdXBDb3VudHNSZXF1ZXN0EiEKDHdvcmtzcGFjZV9pZBgBIAEoCVILd29ya3NwYW'
    'NlSWQSHQoKcHJvamVjdF9pZBgCIAEoCVIJcHJvamVjdElkEhkKCGdyb3VwX2J5GAMgASgJUgdn'
    'cm91cEJ5EhYKBnN0YXR1cxgEIAEoCVIGc3RhdHVzEh8KC2Fzc2lnbmVlX2lkGAUgASgJUgphc3'
    'NpZ25lZUlkEikKEGluY2x1ZGVfc3VidGFza3MYBiABKAhSD2luY2x1ZGVTdWJ0YXNrcxIdCgpm'
    'aWx0ZXJfYXN0GAcgASgJUglmaWx0ZXJBc3QSFAoFdG9kYXkYCCABKAlSBXRvZGF5');

@$core.Deprecated('Use taskListChildrenRequestDescriptor instead')
const TaskListChildrenRequest$json = {
  '1': 'TaskListChildrenRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'id', '3': 3, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `TaskListChildrenRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List taskListChildrenRequestDescriptor = $convert.base64Decode(
    'ChdUYXNrTGlzdENoaWxkcmVuUmVxdWVzdBIhCgx3b3Jrc3BhY2VfaWQYASABKAlSC3dvcmtzcG'
    'FjZUlkEh0KCnByb2plY3RfaWQYAiABKAlSCXByb2plY3RJZBIOCgJpZBgDIAEoCVICaWQ=');

@$core.Deprecated('Use taskListRequestDescriptor instead')
const TaskListRequest$json = {
  '1': 'TaskListRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'status', '3': 3, '4': 1, '5': 9, '10': 'status'},
    {'1': 'assignee_id', '3': 4, '4': 1, '5': 9, '10': 'assigneeId'},
    {'1': 'cursor', '3': 5, '4': 1, '5': 9, '10': 'cursor'},
    {'1': 'page_size', '3': 6, '4': 1, '5': 5, '10': 'pageSize'},
    {'1': 'include_subtasks', '3': 7, '4': 1, '5': 8, '10': 'includeSubtasks'},
    {
      '1': 'sort',
      '3': 8,
      '4': 3,
      '5': 11,
      '6': '.config.tasks.SortKey',
      '10': 'sort'
    },
    {'1': 'group_by', '3': 9, '4': 1, '5': 9, '10': 'groupBy'},
    {'1': 'filter_ast', '3': 10, '4': 1, '5': 9, '10': 'filterAst'},
    {'1': 'today', '3': 11, '4': 1, '5': 9, '10': 'today'},
  ],
};

/// Descriptor for `TaskListRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List taskListRequestDescriptor = $convert.base64Decode(
    'Cg9UYXNrTGlzdFJlcXVlc3QSIQoMd29ya3NwYWNlX2lkGAEgASgJUgt3b3Jrc3BhY2VJZBIdCg'
    'pwcm9qZWN0X2lkGAIgASgJUglwcm9qZWN0SWQSFgoGc3RhdHVzGAMgASgJUgZzdGF0dXMSHwoL'
    'YXNzaWduZWVfaWQYBCABKAlSCmFzc2lnbmVlSWQSFgoGY3Vyc29yGAUgASgJUgZjdXJzb3ISGw'
    'oJcGFnZV9zaXplGAYgASgFUghwYWdlU2l6ZRIpChBpbmNsdWRlX3N1YnRhc2tzGAcgASgIUg9p'
    'bmNsdWRlU3VidGFza3MSKQoEc29ydBgIIAMoCzIVLmNvbmZpZy50YXNrcy5Tb3J0S2V5UgRzb3'
    'J0EhkKCGdyb3VwX2J5GAkgASgJUgdncm91cEJ5Eh0KCmZpbHRlcl9hc3QYCiABKAlSCWZpbHRl'
    'ckFzdBIUCgV0b2RheRgLIAEoCVIFdG9kYXk=');

@$core.Deprecated('Use taskListTrashRequestDescriptor instead')
const TaskListTrashRequest$json = {
  '1': 'TaskListTrashRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
  ],
};

/// Descriptor for `TaskListTrashRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List taskListTrashRequestDescriptor = $convert.base64Decode(
    'ChRUYXNrTGlzdFRyYXNoUmVxdWVzdBIhCgx3b3Jrc3BhY2VfaWQYASABKAlSC3dvcmtzcGFjZU'
    'lkEh0KCnByb2plY3RfaWQYAiABKAlSCXByb2plY3RJZA==');

@$core.Deprecated('Use taskMoveRequestDescriptor instead')
const TaskMoveRequest$json = {
  '1': 'TaskMoveRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'id', '3': 3, '4': 1, '5': 9, '10': 'id'},
    {'1': 'expected_version', '3': 4, '4': 1, '5': 5, '10': 'expectedVersion'},
    {'1': 'status', '3': 5, '4': 1, '5': 9, '10': 'status'},
    {'1': 'include_subtasks', '3': 6, '4': 1, '5': 8, '10': 'includeSubtasks'},
    {'1': 'override_blocked', '3': 7, '4': 1, '5': 8, '10': 'overrideBlocked'},
  ],
};

/// Descriptor for `TaskMoveRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List taskMoveRequestDescriptor = $convert.base64Decode(
    'Cg9UYXNrTW92ZVJlcXVlc3QSIQoMd29ya3NwYWNlX2lkGAEgASgJUgt3b3Jrc3BhY2VJZBIdCg'
    'pwcm9qZWN0X2lkGAIgASgJUglwcm9qZWN0SWQSDgoCaWQYAyABKAlSAmlkEikKEGV4cGVjdGVk'
    'X3ZlcnNpb24YBCABKAVSD2V4cGVjdGVkVmVyc2lvbhIWCgZzdGF0dXMYBSABKAlSBnN0YXR1cx'
    'IpChBpbmNsdWRlX3N1YnRhc2tzGAYgASgIUg9pbmNsdWRlU3VidGFza3MSKQoQb3ZlcnJpZGVf'
    'YmxvY2tlZBgHIAEoCFIPb3ZlcnJpZGVCbG9ja2Vk');

@$core.Deprecated('Use taskResponseDescriptor instead')
const TaskResponse$json = {
  '1': 'TaskResponse',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'workspace_id', '3': 2, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'project_id', '3': 3, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'number', '3': 4, '4': 1, '5': 5, '10': 'number'},
    {'1': 'display_id', '3': 5, '4': 1, '5': 9, '10': 'displayId'},
    {'1': 'title', '3': 6, '4': 1, '5': 9, '10': 'title'},
    {'1': 'description', '3': 7, '4': 1, '5': 9, '10': 'description'},
    {'1': 'status', '3': 8, '4': 1, '5': 9, '10': 'status'},
    {'1': 'status_name', '3': 9, '4': 1, '5': 9, '10': 'statusName'},
    {'1': 'status_category', '3': 10, '4': 1, '5': 9, '10': 'statusCategory'},
    {'1': 'priority', '3': 11, '4': 1, '5': 9, '10': 'priority'},
    {'1': 'start_date', '3': 12, '4': 1, '5': 9, '10': 'startDate'},
    {'1': 'due_date', '3': 13, '4': 1, '5': 9, '10': 'dueDate'},
    {'1': 'assignee_ids', '3': 14, '4': 3, '5': 9, '10': 'assigneeIds'},
    {'1': 'parent_id', '3': 15, '4': 1, '5': 9, '10': 'parentId'},
    {'1': 'depth', '3': 16, '4': 1, '5': 5, '10': 'depth'},
    {'1': 'progress_done', '3': 17, '4': 1, '5': 5, '10': 'progressDone'},
    {'1': 'progress_total', '3': 18, '4': 1, '5': 5, '10': 'progressTotal'},
    {'1': 'created_by', '3': 19, '4': 1, '5': 9, '10': 'createdBy'},
    {'1': 'version', '3': 20, '4': 1, '5': 5, '10': 'version'},
    {'1': 'position', '3': 21, '4': 1, '5': 9, '10': 'position'},
    {'1': 'created_at', '3': 22, '4': 1, '5': 9, '10': 'createdAt'},
    {'1': 'updated_at', '3': 23, '4': 1, '5': 9, '10': 'updatedAt'},
    {'1': 'deleted_at', '3': 24, '4': 1, '5': 9, '10': 'deletedAt'},
    {'1': 'is_blocked', '3': 25, '4': 1, '5': 8, '10': 'isBlocked'},
    {'1': 'blocked_by', '3': 26, '4': 3, '5': 9, '10': 'blockedBy'},
    {
      '1': 'fields',
      '3': 27,
      '4': 3,
      '5': 11,
      '6': '.config.tasks.TaskFieldValueResponse',
      '10': 'fields'
    },
    {'1': 'group_key', '3': 28, '4': 1, '5': 9, '10': 'groupKey'},
    {'1': 'due_time', '3': 29, '4': 1, '5': 9, '10': 'dueTime'},
    {'1': 'blockers_due', '3': 30, '4': 1, '5': 9, '10': 'blockersDue'},
    {'1': 'blocks_due', '3': 31, '4': 1, '5': 9, '10': 'blocksDue'},
  ],
};

/// Descriptor for `TaskResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List taskResponseDescriptor = $convert.base64Decode(
    'CgxUYXNrUmVzcG9uc2USDgoCaWQYASABKAlSAmlkEiEKDHdvcmtzcGFjZV9pZBgCIAEoCVILd2'
    '9ya3NwYWNlSWQSHQoKcHJvamVjdF9pZBgDIAEoCVIJcHJvamVjdElkEhYKBm51bWJlchgEIAEo'
    'BVIGbnVtYmVyEh0KCmRpc3BsYXlfaWQYBSABKAlSCWRpc3BsYXlJZBIUCgV0aXRsZRgGIAEoCV'
    'IFdGl0bGUSIAoLZGVzY3JpcHRpb24YByABKAlSC2Rlc2NyaXB0aW9uEhYKBnN0YXR1cxgIIAEo'
    'CVIGc3RhdHVzEh8KC3N0YXR1c19uYW1lGAkgASgJUgpzdGF0dXNOYW1lEicKD3N0YXR1c19jYX'
    'RlZ29yeRgKIAEoCVIOc3RhdHVzQ2F0ZWdvcnkSGgoIcHJpb3JpdHkYCyABKAlSCHByaW9yaXR5'
    'Eh0KCnN0YXJ0X2RhdGUYDCABKAlSCXN0YXJ0RGF0ZRIZCghkdWVfZGF0ZRgNIAEoCVIHZHVlRG'
    'F0ZRIhCgxhc3NpZ25lZV9pZHMYDiADKAlSC2Fzc2lnbmVlSWRzEhsKCXBhcmVudF9pZBgPIAEo'
    'CVIIcGFyZW50SWQSFAoFZGVwdGgYECABKAVSBWRlcHRoEiMKDXByb2dyZXNzX2RvbmUYESABKA'
    'VSDHByb2dyZXNzRG9uZRIlCg5wcm9ncmVzc190b3RhbBgSIAEoBVINcHJvZ3Jlc3NUb3RhbBId'
    'CgpjcmVhdGVkX2J5GBMgASgJUgljcmVhdGVkQnkSGAoHdmVyc2lvbhgUIAEoBVIHdmVyc2lvbh'
    'IaCghwb3NpdGlvbhgVIAEoCVIIcG9zaXRpb24SHQoKY3JlYXRlZF9hdBgWIAEoCVIJY3JlYXRl'
    'ZEF0Eh0KCnVwZGF0ZWRfYXQYFyABKAlSCXVwZGF0ZWRBdBIdCgpkZWxldGVkX2F0GBggASgJUg'
    'lkZWxldGVkQXQSHQoKaXNfYmxvY2tlZBgZIAEoCFIJaXNCbG9ja2VkEh0KCmJsb2NrZWRfYnkY'
    'GiADKAlSCWJsb2NrZWRCeRI8CgZmaWVsZHMYGyADKAsyJC5jb25maWcudGFza3MuVGFza0ZpZW'
    'xkVmFsdWVSZXNwb25zZVIGZmllbGRzEhsKCWdyb3VwX2tleRgcIAEoCVIIZ3JvdXBLZXkSGQoI'
    'ZHVlX3RpbWUYHSABKAlSB2R1ZVRpbWUSIQoMYmxvY2tlcnNfZHVlGB4gASgJUgtibG9ja2Vyc0'
    'R1ZRIdCgpibG9ja3NfZHVlGB8gASgJUglibG9ja3NEdWU=');

@$core.Deprecated('Use taskRestoreRequestDescriptor instead')
const TaskRestoreRequest$json = {
  '1': 'TaskRestoreRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'id', '3': 3, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `TaskRestoreRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List taskRestoreRequestDescriptor = $convert.base64Decode(
    'ChJUYXNrUmVzdG9yZVJlcXVlc3QSIQoMd29ya3NwYWNlX2lkGAEgASgJUgt3b3Jrc3BhY2VJZB'
    'IdCgpwcm9qZWN0X2lkGAIgASgJUglwcm9qZWN0SWQSDgoCaWQYAyABKAlSAmlk');

@$core.Deprecated('Use taskSetParentRequestDescriptor instead')
const TaskSetParentRequest$json = {
  '1': 'TaskSetParentRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'id', '3': 3, '4': 1, '5': 9, '10': 'id'},
    {'1': 'expected_version', '3': 4, '4': 1, '5': 5, '10': 'expectedVersion'},
    {'1': 'parent_id', '3': 5, '4': 1, '5': 9, '10': 'parentId'},
  ],
};

/// Descriptor for `TaskSetParentRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List taskSetParentRequestDescriptor = $convert.base64Decode(
    'ChRUYXNrU2V0UGFyZW50UmVxdWVzdBIhCgx3b3Jrc3BhY2VfaWQYASABKAlSC3dvcmtzcGFjZU'
    'lkEh0KCnByb2plY3RfaWQYAiABKAlSCXByb2plY3RJZBIOCgJpZBgDIAEoCVICaWQSKQoQZXhw'
    'ZWN0ZWRfdmVyc2lvbhgEIAEoBVIPZXhwZWN0ZWRWZXJzaW9uEhsKCXBhcmVudF9pZBgFIAEoCV'
    'IIcGFyZW50SWQ=');

@$core.Deprecated('Use taskTrashDescriptor instead')
const TaskTrash$json = {
  '1': 'TaskTrash',
  '2': [
    {
      '1': 'tasks',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.config.tasks.Task',
      '10': 'tasks'
    },
  ],
};

/// Descriptor for `TaskTrash`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List taskTrashDescriptor = $convert.base64Decode(
    'CglUYXNrVHJhc2gSKAoFdGFza3MYASADKAsyEi5jb25maWcudGFza3MuVGFza1IFdGFza3M=');

@$core.Deprecated('Use taskUpdateRequestDescriptor instead')
const TaskUpdateRequest$json = {
  '1': 'TaskUpdateRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'id', '3': 3, '4': 1, '5': 9, '10': 'id'},
    {'1': 'expected_version', '3': 4, '4': 1, '5': 5, '10': 'expectedVersion'},
    {'1': 'title', '3': 5, '4': 1, '5': 9, '9': 0, '10': 'title', '17': true},
    {
      '1': 'description',
      '3': 6,
      '4': 1,
      '5': 9,
      '9': 1,
      '10': 'description',
      '17': true
    },
    {'1': 'status', '3': 7, '4': 1, '5': 9, '9': 2, '10': 'status', '17': true},
    {
      '1': 'priority',
      '3': 8,
      '4': 1,
      '5': 9,
      '9': 3,
      '10': 'priority',
      '17': true
    },
    {
      '1': 'start_date',
      '3': 9,
      '4': 1,
      '5': 9,
      '9': 4,
      '10': 'startDate',
      '17': true
    },
    {
      '1': 'due_date',
      '3': 10,
      '4': 1,
      '5': 9,
      '9': 5,
      '10': 'dueDate',
      '17': true
    },
    {'1': 'set_assignees', '3': 11, '4': 1, '5': 8, '10': 'setAssignees'},
    {'1': 'assignee_ids', '3': 12, '4': 3, '5': 9, '10': 'assigneeIds'},
    {'1': 'override_blocked', '3': 13, '4': 1, '5': 8, '10': 'overrideBlocked'},
    {
      '1': 'field_values',
      '3': 14,
      '4': 3,
      '5': 11,
      '6': '.config.tasks.TaskFieldValue',
      '10': 'fieldValues'
    },
    {
      '1': 'due_time',
      '3': 15,
      '4': 1,
      '5': 9,
      '9': 6,
      '10': 'dueTime',
      '17': true
    },
  ],
  '8': [
    {'1': '_title'},
    {'1': '_description'},
    {'1': '_status'},
    {'1': '_priority'},
    {'1': '_start_date'},
    {'1': '_due_date'},
    {'1': '_due_time'},
  ],
};

/// Descriptor for `TaskUpdateRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List taskUpdateRequestDescriptor = $convert.base64Decode(
    'ChFUYXNrVXBkYXRlUmVxdWVzdBIhCgx3b3Jrc3BhY2VfaWQYASABKAlSC3dvcmtzcGFjZUlkEh'
    '0KCnByb2plY3RfaWQYAiABKAlSCXByb2plY3RJZBIOCgJpZBgDIAEoCVICaWQSKQoQZXhwZWN0'
    'ZWRfdmVyc2lvbhgEIAEoBVIPZXhwZWN0ZWRWZXJzaW9uEhkKBXRpdGxlGAUgASgJSABSBXRpdG'
    'xliAEBEiUKC2Rlc2NyaXB0aW9uGAYgASgJSAFSC2Rlc2NyaXB0aW9uiAEBEhsKBnN0YXR1cxgH'
    'IAEoCUgCUgZzdGF0dXOIAQESHwoIcHJpb3JpdHkYCCABKAlIA1IIcHJpb3JpdHmIAQESIgoKc3'
    'RhcnRfZGF0ZRgJIAEoCUgEUglzdGFydERhdGWIAQESHgoIZHVlX2RhdGUYCiABKAlIBVIHZHVl'
    'RGF0ZYgBARIjCg1zZXRfYXNzaWduZWVzGAsgASgIUgxzZXRBc3NpZ25lZXMSIQoMYXNzaWduZW'
    'VfaWRzGAwgAygJUgthc3NpZ25lZUlkcxIpChBvdmVycmlkZV9ibG9ja2VkGA0gASgIUg9vdmVy'
    'cmlkZUJsb2NrZWQSPwoMZmllbGRfdmFsdWVzGA4gAygLMhwuY29uZmlnLnRhc2tzLlRhc2tGaW'
    'VsZFZhbHVlUgtmaWVsZFZhbHVlcxIeCghkdWVfdGltZRgPIAEoCUgGUgdkdWVUaW1liAEBQggK'
    'Bl90aXRsZUIOCgxfZGVzY3JpcHRpb25CCQoHX3N0YXR1c0ILCglfcHJpb3JpdHlCDQoLX3N0YX'
    'J0X2RhdGVCCwoJX2R1ZV9kYXRlQgsKCV9kdWVfdGltZQ==');

@$core.Deprecated('Use timelineAppliedDescriptor instead')
const TimelineApplied$json = {
  '1': 'TimelineApplied',
  '2': [
    {
      '1': 'tasks',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.config.tasks.Task',
      '10': 'tasks'
    },
  ],
};

/// Descriptor for `TimelineApplied`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List timelineAppliedDescriptor = $convert.base64Decode(
    'Cg9UaW1lbGluZUFwcGxpZWQSKAoFdGFza3MYASADKAsyEi5jb25maWcudGFza3MuVGFza1IFdG'
    'Fza3M=');

@$core.Deprecated('Use timelineApplyRequestDescriptor instead')
const TimelineApplyRequest$json = {
  '1': 'TimelineApplyRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'task_id', '3': 3, '4': 1, '5': 9, '10': 'taskId'},
    {'1': 'start_date', '3': 4, '4': 1, '5': 9, '10': 'startDate'},
    {'1': 'due_date', '3': 5, '4': 1, '5': 9, '10': 'dueDate'},
    {'1': 'expected_version', '3': 6, '4': 1, '5': 5, '10': 'expectedVersion'},
    {'1': 'affected_ids', '3': 7, '4': 3, '5': 9, '10': 'affectedIds'},
  ],
};

/// Descriptor for `TimelineApplyRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List timelineApplyRequestDescriptor = $convert.base64Decode(
    'ChRUaW1lbGluZUFwcGx5UmVxdWVzdBIhCgx3b3Jrc3BhY2VfaWQYASABKAlSC3dvcmtzcGFjZU'
    'lkEh0KCnByb2plY3RfaWQYAiABKAlSCXByb2plY3RJZBIXCgd0YXNrX2lkGAMgASgJUgZ0YXNr'
    'SWQSHQoKc3RhcnRfZGF0ZRgEIAEoCVIJc3RhcnREYXRlEhkKCGR1ZV9kYXRlGAUgASgJUgdkdW'
    'VEYXRlEikKEGV4cGVjdGVkX3ZlcnNpb24YBiABKAVSD2V4cGVjdGVkVmVyc2lvbhIhCgxhZmZl'
    'Y3RlZF9pZHMYByADKAlSC2FmZmVjdGVkSWRz');

@$core.Deprecated('Use timelineChunkDescriptor instead')
const TimelineChunk$json = {
  '1': 'TimelineChunk',
  '2': [
    {
      '1': 'tasks',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.config.tasks.Task',
      '10': 'tasks'
    },
    {
      '1': 'links',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.config.tasks.TimelineLink',
      '10': 'links'
    },
  ],
};

/// Descriptor for `TimelineChunk`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List timelineChunkDescriptor = $convert.base64Decode(
    'Cg1UaW1lbGluZUNodW5rEigKBXRhc2tzGAEgAygLMhIuY29uZmlnLnRhc2tzLlRhc2tSBXRhc2'
    'tzEjAKBWxpbmtzGAIgAygLMhouY29uZmlnLnRhc2tzLlRpbWVsaW5lTGlua1IFbGlua3M=');

@$core.Deprecated('Use timelineCriticalPathDescriptor instead')
const TimelineCriticalPath$json = {
  '1': 'TimelineCriticalPath',
  '2': [
    {'1': 'task_ids', '3': 1, '4': 3, '5': 9, '10': 'taskIds'},
  ],
};

/// Descriptor for `TimelineCriticalPath`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List timelineCriticalPathDescriptor =
    $convert.base64Decode(
        'ChRUaW1lbGluZUNyaXRpY2FsUGF0aBIZCgh0YXNrX2lkcxgBIAMoCVIHdGFza0lkcw==');

@$core.Deprecated('Use timelineCriticalPathRequestDescriptor instead')
const TimelineCriticalPathRequest$json = {
  '1': 'TimelineCriticalPathRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
  ],
};

/// Descriptor for `TimelineCriticalPathRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List timelineCriticalPathRequestDescriptor =
    $convert.base64Decode(
        'ChtUaW1lbGluZUNyaXRpY2FsUGF0aFJlcXVlc3QSIQoMd29ya3NwYWNlX2lkGAEgASgJUgt3b3'
        'Jrc3BhY2VJZBIdCgpwcm9qZWN0X2lkGAIgASgJUglwcm9qZWN0SWQ=');

@$core.Deprecated('Use timelineGetRequestDescriptor instead')
const TimelineGetRequest$json = {
  '1': 'TimelineGetRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'range_start', '3': 3, '4': 1, '5': 9, '10': 'rangeStart'},
    {'1': 'range_end', '3': 4, '4': 1, '5': 9, '10': 'rangeEnd'},
    {'1': 'include_done', '3': 5, '4': 1, '5': 8, '10': 'includeDone'},
    {'1': 'filter_ast', '3': 6, '4': 1, '5': 9, '10': 'filterAst'},
    {'1': 'today', '3': 7, '4': 1, '5': 9, '10': 'today'},
  ],
};

/// Descriptor for `TimelineGetRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List timelineGetRequestDescriptor = $convert.base64Decode(
    'ChJUaW1lbGluZUdldFJlcXVlc3QSIQoMd29ya3NwYWNlX2lkGAEgASgJUgt3b3Jrc3BhY2VJZB'
    'IdCgpwcm9qZWN0X2lkGAIgASgJUglwcm9qZWN0SWQSHwoLcmFuZ2Vfc3RhcnQYAyABKAlSCnJh'
    'bmdlU3RhcnQSGwoJcmFuZ2VfZW5kGAQgASgJUghyYW5nZUVuZBIhCgxpbmNsdWRlX2RvbmUYBS'
    'ABKAhSC2luY2x1ZGVEb25lEh0KCmZpbHRlcl9hc3QYBiABKAlSCWZpbHRlckFzdBIUCgV0b2Rh'
    'eRgHIAEoCVIFdG9kYXk=');

@$core.Deprecated('Use timelineLinkDescriptor instead')
const TimelineLink$json = {
  '1': 'TimelineLink',
  '2': [
    {'1': 'from_id', '3': 1, '4': 1, '5': 9, '10': 'fromId'},
    {'1': 'to_id', '3': 2, '4': 1, '5': 9, '10': 'toId'},
  ],
};

/// Descriptor for `TimelineLink`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List timelineLinkDescriptor = $convert.base64Decode(
    'CgxUaW1lbGluZUxpbmsSFwoHZnJvbV9pZBgBIAEoCVIGZnJvbUlkEhMKBXRvX2lkGAIgASgJUg'
    'R0b0lk');

@$core.Deprecated('Use timelinePreviewRequestDescriptor instead')
const TimelinePreviewRequest$json = {
  '1': 'TimelinePreviewRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'task_id', '3': 3, '4': 1, '5': 9, '10': 'taskId'},
    {'1': 'start_date', '3': 4, '4': 1, '5': 9, '10': 'startDate'},
    {'1': 'due_date', '3': 5, '4': 1, '5': 9, '10': 'dueDate'},
  ],
};

/// Descriptor for `TimelinePreviewRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List timelinePreviewRequestDescriptor = $convert.base64Decode(
    'ChZUaW1lbGluZVByZXZpZXdSZXF1ZXN0EiEKDHdvcmtzcGFjZV9pZBgBIAEoCVILd29ya3NwYW'
    'NlSWQSHQoKcHJvamVjdF9pZBgCIAEoCVIJcHJvamVjdElkEhcKB3Rhc2tfaWQYAyABKAlSBnRh'
    'c2tJZBIdCgpzdGFydF9kYXRlGAQgASgJUglzdGFydERhdGUSGQoIZHVlX2RhdGUYBSABKAlSB2'
    'R1ZURhdGU=');

@$core.Deprecated('Use timelineShiftDescriptor instead')
const TimelineShift$json = {
  '1': 'TimelineShift',
  '2': [
    {
      '1': 'task',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.config.tasks.Task',
      '10': 'task'
    },
    {'1': 'new_start', '3': 2, '4': 1, '5': 9, '10': 'newStart'},
    {'1': 'new_due', '3': 3, '4': 1, '5': 9, '10': 'newDue'},
  ],
};

/// Descriptor for `TimelineShift`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List timelineShiftDescriptor = $convert.base64Decode(
    'Cg1UaW1lbGluZVNoaWZ0EiYKBHRhc2sYASABKAsyEi5jb25maWcudGFza3MuVGFza1IEdGFzax'
    'IbCgluZXdfc3RhcnQYAiABKAlSCG5ld1N0YXJ0EhcKB25ld19kdWUYAyABKAlSBm5ld0R1ZQ==');

@$core.Deprecated('Use timelineShiftsDescriptor instead')
const TimelineShifts$json = {
  '1': 'TimelineShifts',
  '2': [
    {
      '1': 'shifts',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.config.tasks.TimelineShift',
      '10': 'shifts'
    },
  ],
};

/// Descriptor for `TimelineShifts`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List timelineShiftsDescriptor = $convert.base64Decode(
    'Cg5UaW1lbGluZVNoaWZ0cxIzCgZzaGlmdHMYASADKAsyGy5jb25maWcudGFza3MuVGltZWxpbm'
    'VTaGlmdFIGc2hpZnRz');

@$core.Deprecated('Use timelineWorkingDaysDescriptor instead')
const TimelineWorkingDays$json = {
  '1': 'TimelineWorkingDays',
  '2': [
    {'1': 'days', '3': 1, '4': 3, '5': 5, '10': 'days'},
    {'1': 'holidays', '3': 2, '4': 3, '5': 9, '10': 'holidays'},
  ],
};

/// Descriptor for `TimelineWorkingDays`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List timelineWorkingDaysDescriptor = $convert.base64Decode(
    'ChNUaW1lbGluZVdvcmtpbmdEYXlzEhIKBGRheXMYASADKAVSBGRheXMSGgoIaG9saWRheXMYAi'
    'ADKAlSCGhvbGlkYXlz');

@$core.Deprecated('Use timelineWorkingDaysGetRequestDescriptor instead')
const TimelineWorkingDaysGetRequest$json = {
  '1': 'TimelineWorkingDaysGetRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
  ],
};

/// Descriptor for `TimelineWorkingDaysGetRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List timelineWorkingDaysGetRequestDescriptor =
    $convert.base64Decode(
        'Ch1UaW1lbGluZVdvcmtpbmdEYXlzR2V0UmVxdWVzdBIhCgx3b3Jrc3BhY2VfaWQYASABKAlSC3'
        'dvcmtzcGFjZUlk');

@$core.Deprecated('Use timelineWorkingDaysSetRequestDescriptor instead')
const TimelineWorkingDaysSetRequest$json = {
  '1': 'TimelineWorkingDaysSetRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'days', '3': 2, '4': 3, '5': 5, '10': 'days'},
    {'1': 'holidays', '3': 3, '4': 3, '5': 9, '10': 'holidays'},
  ],
};

/// Descriptor for `TimelineWorkingDaysSetRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List timelineWorkingDaysSetRequestDescriptor =
    $convert.base64Decode(
        'Ch1UaW1lbGluZVdvcmtpbmdEYXlzU2V0UmVxdWVzdBIhCgx3b3Jrc3BhY2VfaWQYASABKAlSC3'
        'dvcmtzcGFjZUlkEhIKBGRheXMYAiADKAVSBGRheXMSGgoIaG9saWRheXMYAyADKAlSCGhvbGlk'
        'YXlz');
