// This is a generated file - do not edit.
//
// Generated from infrastructure/sprints/grpc/sprints.proto.

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

@$core.Deprecated('Use backlogListDescriptor instead')
const BacklogList$json = {
  '1': 'BacklogList',
  '2': [
    {
      '1': 'tasks',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.config.sprints.SprintTask',
      '10': 'tasks'
    },
    {'1': 'total', '3': 2, '4': 1, '5': 5, '10': 'total'},
  ],
};

/// Descriptor for `BacklogList`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List backlogListDescriptor = $convert.base64Decode(
    'CgtCYWNrbG9nTGlzdBIwCgV0YXNrcxgBIAMoCzIaLmNvbmZpZy5zcHJpbnRzLlNwcmludFRhc2'
    'tSBXRhc2tzEhQKBXRvdGFsGAIgASgFUgV0b3RhbA==');

@$core.Deprecated('Use backlogListRequestDescriptor instead')
const BacklogListRequest$json = {
  '1': 'BacklogListRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'limit', '3': 3, '4': 1, '5': 5, '10': 'limit'},
  ],
};

/// Descriptor for `BacklogListRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List backlogListRequestDescriptor = $convert.base64Decode(
    'ChJCYWNrbG9nTGlzdFJlcXVlc3QSIQoMd29ya3NwYWNlX2lkGAEgASgJUgt3b3Jrc3BhY2VJZB'
    'IdCgpwcm9qZWN0X2lkGAIgASgJUglwcm9qZWN0SWQSFAoFbGltaXQYAyABKAVSBWxpbWl0');

@$core.Deprecated('Use burndownAnswerDescriptor instead')
const BurndownAnswer$json = {
  '1': 'BurndownAnswer',
  '2': [
    {
      '1': 'sprint',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.config.sprints.Sprint',
      '10': 'sprint'
    },
    {'1': 'baseline_points', '3': 2, '4': 1, '5': 1, '10': 'baselinePoints'},
    {'1': 'baseline_tasks', '3': 3, '4': 1, '5': 5, '10': 'baselineTasks'},
    {
      '1': 'days',
      '3': 4,
      '4': 3,
      '5': 11,
      '6': '.config.sprints.BurndownDay',
      '10': 'days'
    },
    {
      '1': 'scope_changes',
      '3': 5,
      '4': 3,
      '5': 11,
      '6': '.config.sprints.ScopeChange',
      '10': 'scopeChanges'
    },
    {
      '1': 'velocity',
      '3': 6,
      '4': 3,
      '5': 11,
      '6': '.config.sprints.VelocityItem',
      '10': 'velocity'
    },
    {'1': 'average_velocity', '3': 7, '4': 1, '5': 1, '10': 'averageVelocity'},
    {'1': 'server_now', '3': 8, '4': 1, '5': 9, '10': 'serverNow'},
  ],
};

/// Descriptor for `BurndownAnswer`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List burndownAnswerDescriptor = $convert.base64Decode(
    'Cg5CdXJuZG93bkFuc3dlchIuCgZzcHJpbnQYASABKAsyFi5jb25maWcuc3ByaW50cy5TcHJpbn'
    'RSBnNwcmludBInCg9iYXNlbGluZV9wb2ludHMYAiABKAFSDmJhc2VsaW5lUG9pbnRzEiUKDmJh'
    'c2VsaW5lX3Rhc2tzGAMgASgFUg1iYXNlbGluZVRhc2tzEi8KBGRheXMYBCADKAsyGy5jb25maW'
    'cuc3ByaW50cy5CdXJuZG93bkRheVIEZGF5cxJACg1zY29wZV9jaGFuZ2VzGAUgAygLMhsuY29u'
    'ZmlnLnNwcmludHMuU2NvcGVDaGFuZ2VSDHNjb3BlQ2hhbmdlcxI4Cgh2ZWxvY2l0eRgGIAMoCz'
    'IcLmNvbmZpZy5zcHJpbnRzLlZlbG9jaXR5SXRlbVIIdmVsb2NpdHkSKQoQYXZlcmFnZV92ZWxv'
    'Y2l0eRgHIAEoAVIPYXZlcmFnZVZlbG9jaXR5Eh0KCnNlcnZlcl9ub3cYCCABKAlSCXNlcnZlck'
    '5vdw==');

@$core.Deprecated('Use burndownDayDescriptor instead')
const BurndownDay$json = {
  '1': 'BurndownDay',
  '2': [
    {'1': 'date', '3': 1, '4': 1, '5': 9, '10': 'date'},
    {'1': 'ideal_points', '3': 2, '4': 1, '5': 1, '10': 'idealPoints'},
    {'1': 'ideal_tasks', '3': 3, '4': 1, '5': 1, '10': 'idealTasks'},
    {'1': 'has_actual', '3': 4, '4': 1, '5': 8, '10': 'hasActual'},
    {'1': 'live', '3': 5, '4': 1, '5': 8, '10': 'live'},
    {'1': 'backfilled', '3': 6, '4': 1, '5': 8, '10': 'backfilled'},
    {'1': 'remaining_points', '3': 7, '4': 1, '5': 1, '10': 'remainingPoints'},
    {'1': 'remaining_tasks', '3': 8, '4': 1, '5': 5, '10': 'remainingTasks'},
    {'1': 'scope_points', '3': 9, '4': 1, '5': 1, '10': 'scopePoints'},
    {'1': 'scope_tasks', '3': 10, '4': 1, '5': 5, '10': 'scopeTasks'},
  ],
};

/// Descriptor for `BurndownDay`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List burndownDayDescriptor = $convert.base64Decode(
    'CgtCdXJuZG93bkRheRISCgRkYXRlGAEgASgJUgRkYXRlEiEKDGlkZWFsX3BvaW50cxgCIAEoAV'
    'ILaWRlYWxQb2ludHMSHwoLaWRlYWxfdGFza3MYAyABKAFSCmlkZWFsVGFza3MSHQoKaGFzX2Fj'
    'dHVhbBgEIAEoCFIJaGFzQWN0dWFsEhIKBGxpdmUYBSABKAhSBGxpdmUSHgoKYmFja2ZpbGxlZB'
    'gGIAEoCFIKYmFja2ZpbGxlZBIpChByZW1haW5pbmdfcG9pbnRzGAcgASgBUg9yZW1haW5pbmdQ'
    'b2ludHMSJwoPcmVtYWluaW5nX3Rhc2tzGAggASgFUg5yZW1haW5pbmdUYXNrcxIhCgxzY29wZV'
    '9wb2ludHMYCSABKAFSC3Njb3BlUG9pbnRzEh8KC3Njb3BlX3Rhc2tzGAogASgFUgpzY29wZVRh'
    'c2tz');

@$core.Deprecated('Use burndownRequestDescriptor instead')
const BurndownRequest$json = {
  '1': 'BurndownRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'sprint_id', '3': 3, '4': 1, '5': 9, '10': 'sprintId'},
  ],
};

/// Descriptor for `BurndownRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List burndownRequestDescriptor = $convert.base64Decode(
    'Cg9CdXJuZG93blJlcXVlc3QSIQoMd29ya3NwYWNlX2lkGAEgASgJUgt3b3Jrc3BhY2VJZBIdCg'
    'pwcm9qZWN0X2lkGAIgASgJUglwcm9qZWN0SWQSGwoJc3ByaW50X2lkGAMgASgJUghzcHJpbnRJ'
    'ZA==');

@$core.Deprecated('Use pointsSetRequestDescriptor instead')
const PointsSetRequest$json = {
  '1': 'PointsSetRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'task_id', '3': 3, '4': 1, '5': 9, '10': 'taskId'},
    {'1': 'points', '3': 4, '4': 1, '5': 9, '10': 'points'},
    {'1': 'expected_version', '3': 5, '4': 1, '5': 5, '10': 'expectedVersion'},
  ],
};

/// Descriptor for `PointsSetRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pointsSetRequestDescriptor = $convert.base64Decode(
    'ChBQb2ludHNTZXRSZXF1ZXN0EiEKDHdvcmtzcGFjZV9pZBgBIAEoCVILd29ya3NwYWNlSWQSHQ'
    'oKcHJvamVjdF9pZBgCIAEoCVIJcHJvamVjdElkEhcKB3Rhc2tfaWQYAyABKAlSBnRhc2tJZBIW'
    'CgZwb2ludHMYBCABKAlSBnBvaW50cxIpChBleHBlY3RlZF92ZXJzaW9uGAUgASgFUg9leHBlY3'
    'RlZFZlcnNpb24=');

@$core.Deprecated('Use scopeChangeDescriptor instead')
const ScopeChange$json = {
  '1': 'ScopeChange',
  '2': [
    {'1': 'date', '3': 1, '4': 1, '5': 9, '10': 'date'},
    {'1': 'points', '3': 2, '4': 1, '5': 1, '10': 'points'},
    {'1': 'tasks', '3': 3, '4': 1, '5': 5, '10': 'tasks'},
  ],
};

/// Descriptor for `ScopeChange`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List scopeChangeDescriptor = $convert.base64Decode(
    'CgtTY29wZUNoYW5nZRISCgRkYXRlGAEgASgJUgRkYXRlEhYKBnBvaW50cxgCIAEoAVIGcG9pbn'
    'RzEhQKBXRhc2tzGAMgASgFUgV0YXNrcw==');

@$core.Deprecated('Use sprintDescriptor instead')
const Sprint$json = {
  '1': 'Sprint',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'workspace_id', '3': 2, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'project_id', '3': 3, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'name', '3': 4, '4': 1, '5': 9, '10': 'name'},
    {'1': 'goal', '3': 5, '4': 1, '5': 9, '10': 'goal'},
    {'1': 'start_date', '3': 6, '4': 1, '5': 9, '10': 'startDate'},
    {'1': 'end_date', '3': 7, '4': 1, '5': 9, '10': 'endDate'},
    {'1': 'state', '3': 8, '4': 1, '5': 9, '10': 'state'},
    {'1': 'started_at', '3': 9, '4': 1, '5': 9, '10': 'startedAt'},
    {'1': 'completed_at', '3': 10, '4': 1, '5': 9, '10': 'completedAt'},
    {'1': 'baseline_points', '3': 11, '4': 1, '5': 1, '10': 'baselinePoints'},
    {'1': 'baseline_tasks', '3': 12, '4': 1, '5': 5, '10': 'baselineTasks'},
    {'1': 'completed_points', '3': 13, '4': 1, '5': 1, '10': 'completedPoints'},
    {'1': 'completed_tasks', '3': 14, '4': 1, '5': 5, '10': 'completedTasks'},
    {'1': 'unfinished_tasks', '3': 15, '4': 1, '5': 5, '10': 'unfinishedTasks'},
    {'1': 'version', '3': 16, '4': 1, '5': 5, '10': 'version'},
    {'1': 'task_count', '3': 17, '4': 1, '5': 5, '10': 'taskCount'},
    {'1': 'points_total', '3': 18, '4': 1, '5': 1, '10': 'pointsTotal'},
    {'1': 'open_tasks', '3': 19, '4': 1, '5': 5, '10': 'openTasks'},
    {'1': 'open_points', '3': 20, '4': 1, '5': 1, '10': 'openPoints'},
    {'1': 'done_tasks', '3': 21, '4': 1, '5': 5, '10': 'doneTasks'},
    {'1': 'done_points', '3': 22, '4': 1, '5': 1, '10': 'donePoints'},
    {
      '1': 'estimate_sec_total',
      '3': 23,
      '4': 1,
      '5': 5,
      '10': 'estimateSecTotal'
    },
  ],
};

/// Descriptor for `Sprint`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sprintDescriptor = $convert.base64Decode(
    'CgZTcHJpbnQSDgoCaWQYASABKAlSAmlkEiEKDHdvcmtzcGFjZV9pZBgCIAEoCVILd29ya3NwYW'
    'NlSWQSHQoKcHJvamVjdF9pZBgDIAEoCVIJcHJvamVjdElkEhIKBG5hbWUYBCABKAlSBG5hbWUS'
    'EgoEZ29hbBgFIAEoCVIEZ29hbBIdCgpzdGFydF9kYXRlGAYgASgJUglzdGFydERhdGUSGQoIZW'
    '5kX2RhdGUYByABKAlSB2VuZERhdGUSFAoFc3RhdGUYCCABKAlSBXN0YXRlEh0KCnN0YXJ0ZWRf'
    'YXQYCSABKAlSCXN0YXJ0ZWRBdBIhCgxjb21wbGV0ZWRfYXQYCiABKAlSC2NvbXBsZXRlZEF0Ei'
    'cKD2Jhc2VsaW5lX3BvaW50cxgLIAEoAVIOYmFzZWxpbmVQb2ludHMSJQoOYmFzZWxpbmVfdGFz'
    'a3MYDCABKAVSDWJhc2VsaW5lVGFza3MSKQoQY29tcGxldGVkX3BvaW50cxgNIAEoAVIPY29tcG'
    'xldGVkUG9pbnRzEicKD2NvbXBsZXRlZF90YXNrcxgOIAEoBVIOY29tcGxldGVkVGFza3MSKQoQ'
    'dW5maW5pc2hlZF90YXNrcxgPIAEoBVIPdW5maW5pc2hlZFRhc2tzEhgKB3ZlcnNpb24YECABKA'
    'VSB3ZlcnNpb24SHQoKdGFza19jb3VudBgRIAEoBVIJdGFza0NvdW50EiEKDHBvaW50c190b3Rh'
    'bBgSIAEoAVILcG9pbnRzVG90YWwSHQoKb3Blbl90YXNrcxgTIAEoBVIJb3BlblRhc2tzEh8KC2'
    '9wZW5fcG9pbnRzGBQgASgBUgpvcGVuUG9pbnRzEh0KCmRvbmVfdGFza3MYFSABKAVSCWRvbmVU'
    'YXNrcxIfCgtkb25lX3BvaW50cxgWIAEoAVIKZG9uZVBvaW50cxIsChJlc3RpbWF0ZV9zZWNfdG'
    '90YWwYFyABKAVSEGVzdGltYXRlU2VjVG90YWw=');

@$core.Deprecated('Use sprintAnswerDescriptor instead')
const SprintAnswer$json = {
  '1': 'SprintAnswer',
  '2': [
    {
      '1': 'sprint',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.config.sprints.Sprint',
      '10': 'sprint'
    },
    {'1': 'warnings', '3': 2, '4': 3, '5': 9, '10': 'warnings'},
  ],
};

/// Descriptor for `SprintAnswer`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sprintAnswerDescriptor = $convert.base64Decode(
    'CgxTcHJpbnRBbnN3ZXISLgoGc3ByaW50GAEgASgLMhYuY29uZmlnLnNwcmludHMuU3ByaW50Ug'
    'ZzcHJpbnQSGgoId2FybmluZ3MYAiADKAlSCHdhcm5pbmdz');

@$core.Deprecated('Use sprintCompleteRequestDescriptor instead')
const SprintCompleteRequest$json = {
  '1': 'SprintCompleteRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'sprint_id', '3': 3, '4': 1, '5': 9, '10': 'sprintId'},
    {'1': 'carry_over', '3': 4, '4': 1, '5': 9, '10': 'carryOver'},
    {'1': 'next_sprint_id', '3': 5, '4': 1, '5': 9, '10': 'nextSprintId'},
  ],
};

/// Descriptor for `SprintCompleteRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sprintCompleteRequestDescriptor = $convert.base64Decode(
    'ChVTcHJpbnRDb21wbGV0ZVJlcXVlc3QSIQoMd29ya3NwYWNlX2lkGAEgASgJUgt3b3Jrc3BhY2'
    'VJZBIdCgpwcm9qZWN0X2lkGAIgASgJUglwcm9qZWN0SWQSGwoJc3ByaW50X2lkGAMgASgJUghz'
    'cHJpbnRJZBIdCgpjYXJyeV9vdmVyGAQgASgJUgljYXJyeU92ZXISJAoObmV4dF9zcHJpbnRfaW'
    'QYBSABKAlSDG5leHRTcHJpbnRJZA==');

@$core.Deprecated('Use sprintCreateRequestDescriptor instead')
const SprintCreateRequest$json = {
  '1': 'SprintCreateRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'name', '3': 3, '4': 1, '5': 9, '10': 'name'},
    {'1': 'goal', '3': 4, '4': 1, '5': 9, '10': 'goal'},
    {'1': 'start_date', '3': 5, '4': 1, '5': 9, '10': 'startDate'},
    {'1': 'end_date', '3': 6, '4': 1, '5': 9, '10': 'endDate'},
  ],
};

/// Descriptor for `SprintCreateRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sprintCreateRequestDescriptor = $convert.base64Decode(
    'ChNTcHJpbnRDcmVhdGVSZXF1ZXN0EiEKDHdvcmtzcGFjZV9pZBgBIAEoCVILd29ya3NwYWNlSW'
    'QSHQoKcHJvamVjdF9pZBgCIAEoCVIJcHJvamVjdElkEhIKBG5hbWUYAyABKAlSBG5hbWUSEgoE'
    'Z29hbBgEIAEoCVIEZ29hbBIdCgpzdGFydF9kYXRlGAUgASgJUglzdGFydERhdGUSGQoIZW5kX2'
    'RhdGUYBiABKAlSB2VuZERhdGU=');

@$core.Deprecated('Use sprintListDescriptor instead')
const SprintList$json = {
  '1': 'SprintList',
  '2': [
    {
      '1': 'sprints',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.config.sprints.Sprint',
      '10': 'sprints'
    },
  ],
};

/// Descriptor for `SprintList`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sprintListDescriptor = $convert.base64Decode(
    'CgpTcHJpbnRMaXN0EjAKB3NwcmludHMYASADKAsyFi5jb25maWcuc3ByaW50cy5TcHJpbnRSB3'
    'NwcmludHM=');

@$core.Deprecated('Use sprintListRequestDescriptor instead')
const SprintListRequest$json = {
  '1': 'SprintListRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'states', '3': 3, '4': 3, '5': 9, '10': 'states'},
  ],
};

/// Descriptor for `SprintListRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sprintListRequestDescriptor = $convert.base64Decode(
    'ChFTcHJpbnRMaXN0UmVxdWVzdBIhCgx3b3Jrc3BhY2VfaWQYASABKAlSC3dvcmtzcGFjZUlkEh'
    '0KCnByb2plY3RfaWQYAiABKAlSCXByb2plY3RJZBIWCgZzdGF0ZXMYAyADKAlSBnN0YXRlcw==');

@$core.Deprecated('Use sprintStartRequestDescriptor instead')
const SprintStartRequest$json = {
  '1': 'SprintStartRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'sprint_id', '3': 3, '4': 1, '5': 9, '10': 'sprintId'},
  ],
};

/// Descriptor for `SprintStartRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sprintStartRequestDescriptor = $convert.base64Decode(
    'ChJTcHJpbnRTdGFydFJlcXVlc3QSIQoMd29ya3NwYWNlX2lkGAEgASgJUgt3b3Jrc3BhY2VJZB'
    'IdCgpwcm9qZWN0X2lkGAIgASgJUglwcm9qZWN0SWQSGwoJc3ByaW50X2lkGAMgASgJUghzcHJp'
    'bnRJZA==');

@$core.Deprecated('Use sprintTaskDescriptor instead')
const SprintTask$json = {
  '1': 'SprintTask',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'key', '3': 3, '4': 1, '5': 9, '10': 'key'},
    {'1': 'title', '3': 4, '4': 1, '5': 9, '10': 'title'},
    {'1': 'status_id', '3': 5, '4': 1, '5': 9, '10': 'statusId'},
    {'1': 'status_name', '3': 6, '4': 1, '5': 9, '10': 'statusName'},
    {'1': 'status_category', '3': 7, '4': 1, '5': 9, '10': 'statusCategory'},
    {'1': 'priority', '3': 8, '4': 1, '5': 9, '10': 'priority'},
    {'1': 'points', '3': 9, '4': 1, '5': 1, '10': 'points'},
    {'1': 'has_points', '3': 10, '4': 1, '5': 8, '10': 'hasPoints'},
    {'1': 'estimate_sec', '3': 11, '4': 1, '5': 5, '10': 'estimateSec'},
    {'1': 'sprint_id', '3': 12, '4': 1, '5': 9, '10': 'sprintId'},
    {'1': 'version', '3': 13, '4': 1, '5': 5, '10': 'version'},
    {'1': 'position', '3': 14, '4': 1, '5': 9, '10': 'position'},
    {'1': 'late', '3': 15, '4': 1, '5': 8, '10': 'late'},
  ],
};

/// Descriptor for `SprintTask`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sprintTaskDescriptor = $convert.base64Decode(
    'CgpTcHJpbnRUYXNrEg4KAmlkGAEgASgJUgJpZBIdCgpwcm9qZWN0X2lkGAIgASgJUglwcm9qZW'
    'N0SWQSEAoDa2V5GAMgASgJUgNrZXkSFAoFdGl0bGUYBCABKAlSBXRpdGxlEhsKCXN0YXR1c19p'
    'ZBgFIAEoCVIIc3RhdHVzSWQSHwoLc3RhdHVzX25hbWUYBiABKAlSCnN0YXR1c05hbWUSJwoPc3'
    'RhdHVzX2NhdGVnb3J5GAcgASgJUg5zdGF0dXNDYXRlZ29yeRIaCghwcmlvcml0eRgIIAEoCVII'
    'cHJpb3JpdHkSFgoGcG9pbnRzGAkgASgBUgZwb2ludHMSHQoKaGFzX3BvaW50cxgKIAEoCFIJaG'
    'FzUG9pbnRzEiEKDGVzdGltYXRlX3NlYxgLIAEoBVILZXN0aW1hdGVTZWMSGwoJc3ByaW50X2lk'
    'GAwgASgJUghzcHJpbnRJZBIYCgd2ZXJzaW9uGA0gASgFUgd2ZXJzaW9uEhoKCHBvc2l0aW9uGA'
    '4gASgJUghwb3NpdGlvbhISCgRsYXRlGA8gASgIUgRsYXRl');

@$core.Deprecated('Use sprintTaskListDescriptor instead')
const SprintTaskList$json = {
  '1': 'SprintTaskList',
  '2': [
    {
      '1': 'tasks',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.config.sprints.SprintTask',
      '10': 'tasks'
    },
  ],
};

/// Descriptor for `SprintTaskList`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sprintTaskListDescriptor = $convert.base64Decode(
    'Cg5TcHJpbnRUYXNrTGlzdBIwCgV0YXNrcxgBIAMoCzIaLmNvbmZpZy5zcHJpbnRzLlNwcmludF'
    'Rhc2tSBXRhc2tz');

@$core.Deprecated('Use sprintTasksChangeRequestDescriptor instead')
const SprintTasksChangeRequest$json = {
  '1': 'SprintTasksChangeRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'sprint_id', '3': 3, '4': 1, '5': 9, '10': 'sprintId'},
    {'1': 'task_ids', '3': 4, '4': 3, '5': 9, '10': 'taskIds'},
  ],
};

/// Descriptor for `SprintTasksChangeRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sprintTasksChangeRequestDescriptor = $convert.base64Decode(
    'ChhTcHJpbnRUYXNrc0NoYW5nZVJlcXVlc3QSIQoMd29ya3NwYWNlX2lkGAEgASgJUgt3b3Jrc3'
    'BhY2VJZBIdCgpwcm9qZWN0X2lkGAIgASgJUglwcm9qZWN0SWQSGwoJc3ByaW50X2lkGAMgASgJ'
    'UghzcHJpbnRJZBIZCgh0YXNrX2lkcxgEIAMoCVIHdGFza0lkcw==');

@$core.Deprecated('Use sprintTasksChangedDescriptor instead')
const SprintTasksChanged$json = {
  '1': 'SprintTasksChanged',
  '2': [
    {
      '1': 'sprint',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.config.sprints.Sprint',
      '10': 'sprint'
    },
    {'1': 'changed', '3': 2, '4': 1, '5': 5, '10': 'changed'},
    {'1': 'added_after_start', '3': 3, '4': 1, '5': 5, '10': 'addedAfterStart'},
  ],
};

/// Descriptor for `SprintTasksChanged`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sprintTasksChangedDescriptor = $convert.base64Decode(
    'ChJTcHJpbnRUYXNrc0NoYW5nZWQSLgoGc3ByaW50GAEgASgLMhYuY29uZmlnLnNwcmludHMuU3'
    'ByaW50UgZzcHJpbnQSGAoHY2hhbmdlZBgCIAEoBVIHY2hhbmdlZBIqChFhZGRlZF9hZnRlcl9z'
    'dGFydBgDIAEoBVIPYWRkZWRBZnRlclN0YXJ0');

@$core.Deprecated('Use sprintTasksRequestDescriptor instead')
const SprintTasksRequest$json = {
  '1': 'SprintTasksRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'sprint_id', '3': 3, '4': 1, '5': 9, '10': 'sprintId'},
  ],
};

/// Descriptor for `SprintTasksRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sprintTasksRequestDescriptor = $convert.base64Decode(
    'ChJTcHJpbnRUYXNrc1JlcXVlc3QSIQoMd29ya3NwYWNlX2lkGAEgASgJUgt3b3Jrc3BhY2VJZB'
    'IdCgpwcm9qZWN0X2lkGAIgASgJUglwcm9qZWN0SWQSGwoJc3ByaW50X2lkGAMgASgJUghzcHJp'
    'bnRJZA==');

@$core.Deprecated('Use sprintUpdateRequestDescriptor instead')
const SprintUpdateRequest$json = {
  '1': 'SprintUpdateRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'sprint_id', '3': 3, '4': 1, '5': 9, '10': 'sprintId'},
    {'1': 'fields', '3': 4, '4': 3, '5': 9, '10': 'fields'},
    {'1': 'expected_version', '3': 5, '4': 1, '5': 5, '10': 'expectedVersion'},
    {'1': 'name', '3': 6, '4': 1, '5': 9, '10': 'name'},
    {'1': 'goal', '3': 7, '4': 1, '5': 9, '10': 'goal'},
    {'1': 'start_date', '3': 8, '4': 1, '5': 9, '10': 'startDate'},
    {'1': 'end_date', '3': 9, '4': 1, '5': 9, '10': 'endDate'},
  ],
};

/// Descriptor for `SprintUpdateRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sprintUpdateRequestDescriptor = $convert.base64Decode(
    'ChNTcHJpbnRVcGRhdGVSZXF1ZXN0EiEKDHdvcmtzcGFjZV9pZBgBIAEoCVILd29ya3NwYWNlSW'
    'QSHQoKcHJvamVjdF9pZBgCIAEoCVIJcHJvamVjdElkEhsKCXNwcmludF9pZBgDIAEoCVIIc3By'
    'aW50SWQSFgoGZmllbGRzGAQgAygJUgZmaWVsZHMSKQoQZXhwZWN0ZWRfdmVyc2lvbhgFIAEoBV'
    'IPZXhwZWN0ZWRWZXJzaW9uEhIKBG5hbWUYBiABKAlSBG5hbWUSEgoEZ29hbBgHIAEoCVIEZ29h'
    'bBIdCgpzdGFydF9kYXRlGAggASgJUglzdGFydERhdGUSGQoIZW5kX2RhdGUYCSABKAlSB2VuZE'
    'RhdGU=');

@$core.Deprecated('Use velocityItemDescriptor instead')
const VelocityItem$json = {
  '1': 'VelocityItem',
  '2': [
    {'1': 'sprint_id', '3': 1, '4': 1, '5': 9, '10': 'sprintId'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'start_date', '3': 3, '4': 1, '5': 9, '10': 'startDate'},
    {'1': 'end_date', '3': 4, '4': 1, '5': 9, '10': 'endDate'},
    {'1': 'committed_points', '3': 5, '4': 1, '5': 1, '10': 'committedPoints'},
    {'1': 'completed_points', '3': 6, '4': 1, '5': 1, '10': 'completedPoints'},
    {'1': 'committed_tasks', '3': 7, '4': 1, '5': 5, '10': 'committedTasks'},
    {'1': 'completed_tasks', '3': 8, '4': 1, '5': 5, '10': 'completedTasks'},
  ],
};

/// Descriptor for `VelocityItem`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List velocityItemDescriptor = $convert.base64Decode(
    'CgxWZWxvY2l0eUl0ZW0SGwoJc3ByaW50X2lkGAEgASgJUghzcHJpbnRJZBISCgRuYW1lGAIgAS'
    'gJUgRuYW1lEh0KCnN0YXJ0X2RhdGUYAyABKAlSCXN0YXJ0RGF0ZRIZCghlbmRfZGF0ZRgEIAEo'
    'CVIHZW5kRGF0ZRIpChBjb21taXR0ZWRfcG9pbnRzGAUgASgBUg9jb21taXR0ZWRQb2ludHMSKQ'
    'oQY29tcGxldGVkX3BvaW50cxgGIAEoAVIPY29tcGxldGVkUG9pbnRzEicKD2NvbW1pdHRlZF90'
    'YXNrcxgHIAEoBVIOY29tbWl0dGVkVGFza3MSJwoPY29tcGxldGVkX3Rhc2tzGAggASgFUg5jb2'
    '1wbGV0ZWRUYXNrcw==');
