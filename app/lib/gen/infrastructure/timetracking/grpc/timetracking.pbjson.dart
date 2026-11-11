// This is a generated file - do not edit.
//
// Generated from infrastructure/timetracking/grpc/timetracking.proto.

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

@$core.Deprecated('Use entriesRequestDescriptor instead')
const EntriesRequest$json = {
  '1': 'EntriesRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'task_id', '3': 3, '4': 1, '5': 9, '10': 'taskId'},
  ],
};

/// Descriptor for `EntriesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List entriesRequestDescriptor = $convert.base64Decode(
    'Cg5FbnRyaWVzUmVxdWVzdBIhCgx3b3Jrc3BhY2VfaWQYASABKAlSC3dvcmtzcGFjZUlkEh0KCn'
    'Byb2plY3RfaWQYAiABKAlSCXByb2plY3RJZBIXCgd0YXNrX2lkGAMgASgJUgZ0YXNrSWQ=');

@$core.Deprecated('Use entryDescriptor instead')
const Entry$json = {
  '1': 'Entry',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'workspace_id', '3': 2, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'task_id', '3': 3, '4': 1, '5': 9, '10': 'taskId'},
    {'1': 'project_id', '3': 4, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'key', '3': 5, '4': 1, '5': 9, '10': 'key'},
    {'1': 'title', '3': 6, '4': 1, '5': 9, '10': 'title'},
    {'1': 'user_id', '3': 7, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'user_name', '3': 8, '4': 1, '5': 9, '10': 'userName'},
    {'1': 'started_at', '3': 9, '4': 1, '5': 9, '10': 'startedAt'},
    {'1': 'ended_at', '3': 10, '4': 1, '5': 9, '10': 'endedAt'},
    {'1': 'duration_sec', '3': 11, '4': 1, '5': 5, '10': 'durationSec'},
    {'1': 'note', '3': 12, '4': 1, '5': 9, '10': 'note'},
    {'1': 'billable', '3': 13, '4': 1, '5': 8, '10': 'billable'},
    {'1': 'source', '3': 14, '4': 1, '5': 9, '10': 'source'},
    {'1': 'flags', '3': 15, '4': 3, '5': 9, '10': 'flags'},
  ],
};

/// Descriptor for `Entry`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List entryDescriptor = $convert.base64Decode(
    'CgVFbnRyeRIOCgJpZBgBIAEoCVICaWQSIQoMd29ya3NwYWNlX2lkGAIgASgJUgt3b3Jrc3BhY2'
    'VJZBIXCgd0YXNrX2lkGAMgASgJUgZ0YXNrSWQSHQoKcHJvamVjdF9pZBgEIAEoCVIJcHJvamVj'
    'dElkEhAKA2tleRgFIAEoCVIDa2V5EhQKBXRpdGxlGAYgASgJUgV0aXRsZRIXCgd1c2VyX2lkGA'
    'cgASgJUgZ1c2VySWQSGwoJdXNlcl9uYW1lGAggASgJUgh1c2VyTmFtZRIdCgpzdGFydGVkX2F0'
    'GAkgASgJUglzdGFydGVkQXQSGQoIZW5kZWRfYXQYCiABKAlSB2VuZGVkQXQSIQoMZHVyYXRpb2'
    '5fc2VjGAsgASgFUgtkdXJhdGlvblNlYxISCgRub3RlGAwgASgJUgRub3RlEhoKCGJpbGxhYmxl'
    'GA0gASgIUghiaWxsYWJsZRIWCgZzb3VyY2UYDiABKAlSBnNvdXJjZRIUCgVmbGFncxgPIAMoCV'
    'IFZmxhZ3M=');

@$core.Deprecated('Use entryCreateRequestDescriptor instead')
const EntryCreateRequest$json = {
  '1': 'EntryCreateRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'task_id', '3': 3, '4': 1, '5': 9, '10': 'taskId'},
    {'1': 'started_at', '3': 4, '4': 1, '5': 9, '10': 'startedAt'},
    {'1': 'duration_sec', '3': 5, '4': 1, '5': 5, '10': 'durationSec'},
    {'1': 'note', '3': 6, '4': 1, '5': 9, '10': 'note'},
    {'1': 'billable', '3': 7, '4': 1, '5': 8, '10': 'billable'},
    {'1': 'for_user_id', '3': 8, '4': 1, '5': 9, '10': 'forUserId'},
  ],
};

/// Descriptor for `EntryCreateRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List entryCreateRequestDescriptor = $convert.base64Decode(
    'ChJFbnRyeUNyZWF0ZVJlcXVlc3QSIQoMd29ya3NwYWNlX2lkGAEgASgJUgt3b3Jrc3BhY2VJZB'
    'IdCgpwcm9qZWN0X2lkGAIgASgJUglwcm9qZWN0SWQSFwoHdGFza19pZBgDIAEoCVIGdGFza0lk'
    'Eh0KCnN0YXJ0ZWRfYXQYBCABKAlSCXN0YXJ0ZWRBdBIhCgxkdXJhdGlvbl9zZWMYBSABKAVSC2'
    'R1cmF0aW9uU2VjEhIKBG5vdGUYBiABKAlSBG5vdGUSGgoIYmlsbGFibGUYByABKAhSCGJpbGxh'
    'YmxlEh4KC2Zvcl91c2VyX2lkGAggASgJUglmb3JVc2VySWQ=');

@$core.Deprecated('Use entryDeleteRequestDescriptor instead')
const EntryDeleteRequest$json = {
  '1': 'EntryDeleteRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'id', '3': 2, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `EntryDeleteRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List entryDeleteRequestDescriptor = $convert.base64Decode(
    'ChJFbnRyeURlbGV0ZVJlcXVlc3QSIQoMd29ya3NwYWNlX2lkGAEgASgJUgt3b3Jrc3BhY2VJZB'
    'IOCgJpZBgCIAEoCVICaWQ=');

@$core.Deprecated('Use entryDeletedDescriptor instead')
const EntryDeleted$json = {
  '1': 'EntryDeleted',
  '2': [
    {'1': 'ok', '3': 1, '4': 1, '5': 8, '10': 'ok'},
  ],
};

/// Descriptor for `EntryDeleted`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List entryDeletedDescriptor =
    $convert.base64Decode('CgxFbnRyeURlbGV0ZWQSDgoCb2sYASABKAhSAm9r');

@$core.Deprecated('Use entryListDescriptor instead')
const EntryList$json = {
  '1': 'EntryList',
  '2': [
    {
      '1': 'entries',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.config.timetracking.Entry',
      '10': 'entries'
    },
  ],
};

/// Descriptor for `EntryList`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List entryListDescriptor = $convert.base64Decode(
    'CglFbnRyeUxpc3QSNAoHZW50cmllcxgBIAMoCzIaLmNvbmZpZy50aW1ldHJhY2tpbmcuRW50cn'
    'lSB2VudHJpZXM=');

@$core.Deprecated('Use entryUpdateRequestDescriptor instead')
const EntryUpdateRequest$json = {
  '1': 'EntryUpdateRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'id', '3': 2, '4': 1, '5': 9, '10': 'id'},
    {'1': 'fields', '3': 3, '4': 3, '5': 9, '10': 'fields'},
    {'1': 'started_at', '3': 4, '4': 1, '5': 9, '10': 'startedAt'},
    {'1': 'duration_sec', '3': 5, '4': 1, '5': 5, '10': 'durationSec'},
    {'1': 'note', '3': 6, '4': 1, '5': 9, '10': 'note'},
    {'1': 'billable', '3': 7, '4': 1, '5': 8, '10': 'billable'},
  ],
};

/// Descriptor for `EntryUpdateRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List entryUpdateRequestDescriptor = $convert.base64Decode(
    'ChJFbnRyeVVwZGF0ZVJlcXVlc3QSIQoMd29ya3NwYWNlX2lkGAEgASgJUgt3b3Jrc3BhY2VJZB'
    'IOCgJpZBgCIAEoCVICaWQSFgoGZmllbGRzGAMgAygJUgZmaWVsZHMSHQoKc3RhcnRlZF9hdBgE'
    'IAEoCVIJc3RhcnRlZEF0EiEKDGR1cmF0aW9uX3NlYxgFIAEoBVILZHVyYXRpb25TZWMSEgoEbm'
    '90ZRgGIAEoCVIEbm90ZRIaCghiaWxsYWJsZRgHIAEoCFIIYmlsbGFibGU=');

@$core.Deprecated('Use estimateSetDescriptor instead')
const EstimateSet$json = {
  '1': 'EstimateSet',
  '2': [
    {'1': 'estimate_sec', '3': 1, '4': 1, '5': 5, '10': 'estimateSec'},
  ],
};

/// Descriptor for `EstimateSet`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List estimateSetDescriptor = $convert.base64Decode(
    'CgtFc3RpbWF0ZVNldBIhCgxlc3RpbWF0ZV9zZWMYASABKAVSC2VzdGltYXRlU2Vj');

@$core.Deprecated('Use estimateSetRequestDescriptor instead')
const EstimateSetRequest$json = {
  '1': 'EstimateSetRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'task_id', '3': 3, '4': 1, '5': 9, '10': 'taskId'},
    {'1': 'estimate_sec', '3': 4, '4': 1, '5': 5, '10': 'estimateSec'},
    {'1': 'expected_version', '3': 5, '4': 1, '5': 5, '10': 'expectedVersion'},
  ],
};

/// Descriptor for `EstimateSetRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List estimateSetRequestDescriptor = $convert.base64Decode(
    'ChJFc3RpbWF0ZVNldFJlcXVlc3QSIQoMd29ya3NwYWNlX2lkGAEgASgJUgt3b3Jrc3BhY2VJZB'
    'IdCgpwcm9qZWN0X2lkGAIgASgJUglwcm9qZWN0SWQSFwoHdGFza19pZBgDIAEoCVIGdGFza0lk'
    'EiEKDGVzdGltYXRlX3NlYxgEIAEoBVILZXN0aW1hdGVTZWMSKQoQZXhwZWN0ZWRfdmVyc2lvbh'
    'gFIAEoBVIPZXhwZWN0ZWRWZXJzaW9u');

@$core.Deprecated('Use personTotalDescriptor instead')
const PersonTotal$json = {
  '1': 'PersonTotal',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'seconds', '3': 3, '4': 1, '5': 5, '10': 'seconds'},
    {'1': 'billable', '3': 4, '4': 1, '5': 5, '10': 'billable'},
  ],
};

/// Descriptor for `PersonTotal`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List personTotalDescriptor = $convert.base64Decode(
    'CgtQZXJzb25Ub3RhbBIXCgd1c2VyX2lkGAEgASgJUgZ1c2VySWQSEgoEbmFtZRgCIAEoCVIEbm'
    'FtZRIYCgdzZWNvbmRzGAMgASgFUgdzZWNvbmRzEhoKCGJpbGxhYmxlGAQgASgFUghiaWxsYWJs'
    'ZQ==');

@$core.Deprecated('Use sheetRowDescriptor instead')
const SheetRow$json = {
  '1': 'SheetRow',
  '2': [
    {'1': 'task_id', '3': 1, '4': 1, '5': 9, '10': 'taskId'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'key', '3': 3, '4': 1, '5': 9, '10': 'key'},
    {'1': 'title', '3': 4, '4': 1, '5': 9, '10': 'title'},
    {'1': 'seconds', '3': 5, '4': 3, '5': 5, '10': 'seconds'},
    {'1': 'total', '3': 6, '4': 1, '5': 5, '10': 'total'},
    {'1': 'billable', '3': 7, '4': 1, '5': 5, '10': 'billable'},
  ],
};

/// Descriptor for `SheetRow`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sheetRowDescriptor = $convert.base64Decode(
    'CghTaGVldFJvdxIXCgd0YXNrX2lkGAEgASgJUgZ0YXNrSWQSHQoKcHJvamVjdF9pZBgCIAEoCV'
    'IJcHJvamVjdElkEhAKA2tleRgDIAEoCVIDa2V5EhQKBXRpdGxlGAQgASgJUgV0aXRsZRIYCgdz'
    'ZWNvbmRzGAUgAygFUgdzZWNvbmRzEhQKBXRvdGFsGAYgASgFUgV0b3RhbBIaCghiaWxsYWJsZR'
    'gHIAEoBVIIYmlsbGFibGU=');

@$core.Deprecated('Use timeCurrentRequestDescriptor instead')
const TimeCurrentRequest$json = {
  '1': 'TimeCurrentRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
  ],
};

/// Descriptor for `TimeCurrentRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List timeCurrentRequestDescriptor = $convert.base64Decode(
    'ChJUaW1lQ3VycmVudFJlcXVlc3QSIQoMd29ya3NwYWNlX2lkGAEgASgJUgt3b3Jrc3BhY2VJZA'
    '==');

@$core.Deprecated('Use timeStartRequestDescriptor instead')
const TimeStartRequest$json = {
  '1': 'TimeStartRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'task_id', '3': 3, '4': 1, '5': 9, '10': 'taskId'},
    {'1': 'note', '3': 4, '4': 1, '5': 9, '10': 'note'},
  ],
};

/// Descriptor for `TimeStartRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List timeStartRequestDescriptor = $convert.base64Decode(
    'ChBUaW1lU3RhcnRSZXF1ZXN0EiEKDHdvcmtzcGFjZV9pZBgBIAEoCVILd29ya3NwYWNlSWQSHQ'
    'oKcHJvamVjdF9pZBgCIAEoCVIJcHJvamVjdElkEhcKB3Rhc2tfaWQYAyABKAlSBnRhc2tJZBIS'
    'CgRub3RlGAQgASgJUgRub3Rl');

@$core.Deprecated('Use timeStopRequestDescriptor instead')
const TimeStopRequest$json = {
  '1': 'TimeStopRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
  ],
};

/// Descriptor for `TimeStopRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List timeStopRequestDescriptor = $convert.base64Decode(
    'Cg9UaW1lU3RvcFJlcXVlc3QSIQoMd29ya3NwYWNlX2lkGAEgASgJUgt3b3Jrc3BhY2VJZA==');

@$core.Deprecated('Use timeSummaryDescriptor instead')
const TimeSummary$json = {
  '1': 'TimeSummary',
  '2': [
    {'1': 'estimate_sec', '3': 1, '4': 1, '5': 5, '10': 'estimateSec'},
    {'1': 'logged_sec', '3': 2, '4': 1, '5': 5, '10': 'loggedSec'},
    {'1': 'billable_sec', '3': 3, '4': 1, '5': 5, '10': 'billableSec'},
    {'1': 'running', '3': 4, '4': 1, '5': 8, '10': 'running'},
  ],
};

/// Descriptor for `TimeSummary`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List timeSummaryDescriptor = $convert.base64Decode(
    'CgtUaW1lU3VtbWFyeRIhCgxlc3RpbWF0ZV9zZWMYASABKAVSC2VzdGltYXRlU2VjEh0KCmxvZ2'
    'dlZF9zZWMYAiABKAVSCWxvZ2dlZFNlYxIhCgxiaWxsYWJsZV9zZWMYAyABKAVSC2JpbGxhYmxl'
    'U2VjEhgKB3J1bm5pbmcYBCABKAhSB3J1bm5pbmc=');

@$core.Deprecated('Use timeSummaryRequestDescriptor instead')
const TimeSummaryRequest$json = {
  '1': 'TimeSummaryRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'task_id', '3': 3, '4': 1, '5': 9, '10': 'taskId'},
  ],
};

/// Descriptor for `TimeSummaryRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List timeSummaryRequestDescriptor = $convert.base64Decode(
    'ChJUaW1lU3VtbWFyeVJlcXVlc3QSIQoMd29ya3NwYWNlX2lkGAEgASgJUgt3b3Jrc3BhY2VJZB'
    'IdCgpwcm9qZWN0X2lkGAIgASgJUglwcm9qZWN0SWQSFwoHdGFza19pZBgDIAEoCVIGdGFza0lk');

@$core.Deprecated('Use timerStartedDescriptor instead')
const TimerStarted$json = {
  '1': 'TimerStarted',
  '2': [
    {
      '1': 'entry',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.config.timetracking.Entry',
      '10': 'entry'
    },
    {
      '1': 'stopped',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.config.timetracking.Entry',
      '10': 'stopped'
    },
    {'1': 'server_now', '3': 3, '4': 1, '5': 9, '10': 'serverNow'},
  ],
};

/// Descriptor for `TimerStarted`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List timerStartedDescriptor = $convert.base64Decode(
    'CgxUaW1lclN0YXJ0ZWQSMAoFZW50cnkYASABKAsyGi5jb25maWcudGltZXRyYWNraW5nLkVudH'
    'J5UgVlbnRyeRI0CgdzdG9wcGVkGAIgASgLMhouY29uZmlnLnRpbWV0cmFja2luZy5FbnRyeVIH'
    'c3RvcHBlZBIdCgpzZXJ2ZXJfbm93GAMgASgJUglzZXJ2ZXJOb3c=');

@$core.Deprecated('Use timerStateDescriptor instead')
const TimerState$json = {
  '1': 'TimerState',
  '2': [
    {'1': 'running', '3': 1, '4': 1, '5': 8, '10': 'running'},
    {
      '1': 'entry',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.config.timetracking.Entry',
      '10': 'entry'
    },
    {'1': 'server_now', '3': 3, '4': 1, '5': 9, '10': 'serverNow'},
  ],
};

/// Descriptor for `TimerState`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List timerStateDescriptor = $convert.base64Decode(
    'CgpUaW1lclN0YXRlEhgKB3J1bm5pbmcYASABKAhSB3J1bm5pbmcSMAoFZW50cnkYAiABKAsyGi'
    '5jb25maWcudGltZXRyYWNraW5nLkVudHJ5UgVlbnRyeRIdCgpzZXJ2ZXJfbm93GAMgASgJUglz'
    'ZXJ2ZXJOb3c=');

@$core.Deprecated('Use timerStoppedDescriptor instead')
const TimerStopped$json = {
  '1': 'TimerStopped',
  '2': [
    {
      '1': 'entry',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.config.timetracking.Entry',
      '10': 'entry'
    },
    {'1': 'server_now', '3': 2, '4': 1, '5': 9, '10': 'serverNow'},
  ],
};

/// Descriptor for `TimerStopped`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List timerStoppedDescriptor = $convert.base64Decode(
    'CgxUaW1lclN0b3BwZWQSMAoFZW50cnkYASABKAsyGi5jb25maWcudGltZXRyYWNraW5nLkVudH'
    'J5UgVlbnRyeRIdCgpzZXJ2ZXJfbm93GAIgASgJUglzZXJ2ZXJOb3c=');

@$core.Deprecated('Use timesheetAnswerDescriptor instead')
const TimesheetAnswer$json = {
  '1': 'TimesheetAnswer',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'week_start', '3': 2, '4': 1, '5': 9, '10': 'weekStart'},
    {
      '1': 'rows',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.config.timetracking.SheetRow',
      '10': 'rows'
    },
    {'1': 'day_totals', '3': 4, '4': 3, '5': 5, '10': 'dayTotals'},
    {'1': 'total', '3': 5, '4': 1, '5': 5, '10': 'total'},
  ],
};

/// Descriptor for `TimesheetAnswer`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List timesheetAnswerDescriptor = $convert.base64Decode(
    'Cg9UaW1lc2hlZXRBbnN3ZXISFwoHdXNlcl9pZBgBIAEoCVIGdXNlcklkEh0KCndlZWtfc3Rhcn'
    'QYAiABKAlSCXdlZWtTdGFydBIxCgRyb3dzGAMgAygLMh0uY29uZmlnLnRpbWV0cmFja2luZy5T'
    'aGVldFJvd1IEcm93cxIdCgpkYXlfdG90YWxzGAQgAygFUglkYXlUb3RhbHMSFAoFdG90YWwYBS'
    'ABKAVSBXRvdGFs');

@$core.Deprecated('Use timesheetRequestDescriptor instead')
const TimesheetRequest$json = {
  '1': 'TimesheetRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'week_start', '3': 2, '4': 1, '5': 9, '10': 'weekStart'},
    {'1': 'timezone', '3': 3, '4': 1, '5': 9, '10': 'timezone'},
    {'1': 'user_id', '3': 4, '4': 1, '5': 9, '10': 'userId'},
    {
      '1': 'utc_offset_minutes',
      '3': 5,
      '4': 1,
      '5': 5,
      '10': 'utcOffsetMinutes'
    },
  ],
};

/// Descriptor for `TimesheetRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List timesheetRequestDescriptor = $convert.base64Decode(
    'ChBUaW1lc2hlZXRSZXF1ZXN0EiEKDHdvcmtzcGFjZV9pZBgBIAEoCVILd29ya3NwYWNlSWQSHQ'
    'oKd2Vla19zdGFydBgCIAEoCVIJd2Vla1N0YXJ0EhoKCHRpbWV6b25lGAMgASgJUgh0aW1lem9u'
    'ZRIXCgd1c2VyX2lkGAQgASgJUgZ1c2VySWQSLAoSdXRjX29mZnNldF9taW51dGVzGAUgASgFUh'
    'B1dGNPZmZzZXRNaW51dGVz');

@$core.Deprecated('Use totalsAnswerDescriptor instead')
const TotalsAnswer$json = {
  '1': 'TotalsAnswer',
  '2': [
    {
      '1': 'people',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.config.timetracking.PersonTotal',
      '10': 'people'
    },
  ],
};

/// Descriptor for `TotalsAnswer`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List totalsAnswerDescriptor = $convert.base64Decode(
    'CgxUb3RhbHNBbnN3ZXISOAoGcGVvcGxlGAEgAygLMiAuY29uZmlnLnRpbWV0cmFja2luZy5QZX'
    'Jzb25Ub3RhbFIGcGVvcGxl');

@$core.Deprecated('Use totalsRequestDescriptor instead')
const TotalsRequest$json = {
  '1': 'TotalsRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'start', '3': 3, '4': 1, '5': 9, '10': 'start'},
    {'1': 'end', '3': 4, '4': 1, '5': 9, '10': 'end'},
  ],
};

/// Descriptor for `TotalsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List totalsRequestDescriptor = $convert.base64Decode(
    'Cg1Ub3RhbHNSZXF1ZXN0EiEKDHdvcmtzcGFjZV9pZBgBIAEoCVILd29ya3NwYWNlSWQSHQoKcH'
    'JvamVjdF9pZBgCIAEoCVIJcHJvamVjdElkEhQKBXN0YXJ0GAMgASgJUgVzdGFydBIQCgNlbmQY'
    'BCABKAlSA2VuZA==');
