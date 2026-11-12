// This is a generated file - do not edit.
//
// Generated from infrastructure/recurrence/grpc/recurrence.proto.

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

@$core.Deprecated('Use ghostDescriptor instead')
const Ghost$json = {
  '1': 'Ghost',
  '2': [
    {'1': 'series_id', '3': 1, '4': 1, '5': 9, '10': 'seriesId'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'title', '3': 3, '4': 1, '5': 9, '10': 'title'},
    {'1': 'due_date', '3': 4, '4': 1, '5': 9, '10': 'dueDate'},
  ],
};

/// Descriptor for `Ghost`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List ghostDescriptor = $convert.base64Decode(
    'CgVHaG9zdBIbCglzZXJpZXNfaWQYASABKAlSCHNlcmllc0lkEh0KCnByb2plY3RfaWQYAiABKA'
    'lSCXByb2plY3RJZBIUCgV0aXRsZRgDIAEoCVIFdGl0bGUSGQoIZHVlX2RhdGUYBCABKAlSB2R1'
    'ZURhdGU=');

@$core.Deprecated('Use recurrenceAnswerDescriptor instead')
const RecurrenceAnswer$json = {
  '1': 'RecurrenceAnswer',
  '2': [
    {'1': 'repeats', '3': 1, '4': 1, '5': 8, '10': 'repeats'},
    {
      '1': 'series',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.config.recurrence.Series',
      '10': 'series'
    },
  ],
};

/// Descriptor for `RecurrenceAnswer`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List recurrenceAnswerDescriptor = $convert.base64Decode(
    'ChBSZWN1cnJlbmNlQW5zd2VyEhgKB3JlcGVhdHMYASABKAhSB3JlcGVhdHMSMQoGc2VyaWVzGA'
    'IgASgLMhkuY29uZmlnLnJlY3VycmVuY2UuU2VyaWVzUgZzZXJpZXM=');

@$core.Deprecated('Use recurrenceClearRequestDescriptor instead')
const RecurrenceClearRequest$json = {
  '1': 'RecurrenceClearRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'task_id', '3': 3, '4': 1, '5': 9, '10': 'taskId'},
  ],
};

/// Descriptor for `RecurrenceClearRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List recurrenceClearRequestDescriptor = $convert.base64Decode(
    'ChZSZWN1cnJlbmNlQ2xlYXJSZXF1ZXN0EiEKDHdvcmtzcGFjZV9pZBgBIAEoCVILd29ya3NwYW'
    'NlSWQSHQoKcHJvamVjdF9pZBgCIAEoCVIJcHJvamVjdElkEhcKB3Rhc2tfaWQYAyABKAlSBnRh'
    'c2tJZA==');

@$core.Deprecated('Use recurrenceClearedDescriptor instead')
const RecurrenceCleared$json = {
  '1': 'RecurrenceCleared',
  '2': [
    {'1': 'task_id', '3': 1, '4': 1, '5': 9, '10': 'taskId'},
  ],
};

/// Descriptor for `RecurrenceCleared`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List recurrenceClearedDescriptor = $convert.base64Decode(
    'ChFSZWN1cnJlbmNlQ2xlYXJlZBIXCgd0YXNrX2lkGAEgASgJUgZ0YXNrSWQ=');

@$core.Deprecated('Use recurrenceFutureUpdatedDescriptor instead')
const RecurrenceFutureUpdated$json = {
  '1': 'RecurrenceFutureUpdated',
  '2': [
    {
      '1': 'series',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.config.recurrence.Series',
      '10': 'series'
    },
    {'1': 'changed', '3': 2, '4': 1, '5': 5, '10': 'changed'},
  ],
};

/// Descriptor for `RecurrenceFutureUpdated`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List recurrenceFutureUpdatedDescriptor =
    $convert.base64Decode(
        'ChdSZWN1cnJlbmNlRnV0dXJlVXBkYXRlZBIxCgZzZXJpZXMYASABKAsyGS5jb25maWcucmVjdX'
        'JyZW5jZS5TZXJpZXNSBnNlcmllcxIYCgdjaGFuZ2VkGAIgASgFUgdjaGFuZ2Vk');

@$core.Deprecated('Use recurrenceGetRequestDescriptor instead')
const RecurrenceGetRequest$json = {
  '1': 'RecurrenceGetRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'task_id', '3': 3, '4': 1, '5': 9, '10': 'taskId'},
  ],
};

/// Descriptor for `RecurrenceGetRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List recurrenceGetRequestDescriptor = $convert.base64Decode(
    'ChRSZWN1cnJlbmNlR2V0UmVxdWVzdBIhCgx3b3Jrc3BhY2VfaWQYASABKAlSC3dvcmtzcGFjZU'
    'lkEh0KCnByb2plY3RfaWQYAiABKAlSCXByb2plY3RJZBIXCgd0YXNrX2lkGAMgASgJUgZ0YXNr'
    'SWQ=');

@$core.Deprecated('Use recurrencePauseRequestDescriptor instead')
const RecurrencePauseRequest$json = {
  '1': 'RecurrencePauseRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'task_id', '3': 3, '4': 1, '5': 9, '10': 'taskId'},
    {'1': 'paused', '3': 4, '4': 1, '5': 8, '10': 'paused'},
  ],
};

/// Descriptor for `RecurrencePauseRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List recurrencePauseRequestDescriptor = $convert.base64Decode(
    'ChZSZWN1cnJlbmNlUGF1c2VSZXF1ZXN0EiEKDHdvcmtzcGFjZV9pZBgBIAEoCVILd29ya3NwYW'
    'NlSWQSHQoKcHJvamVjdF9pZBgCIAEoCVIJcHJvamVjdElkEhcKB3Rhc2tfaWQYAyABKAlSBnRh'
    'c2tJZBIWCgZwYXVzZWQYBCABKAhSBnBhdXNlZA==');

@$core.Deprecated('Use recurrencePreviewDescriptor instead')
const RecurrencePreview$json = {
  '1': 'RecurrencePreview',
  '2': [
    {'1': 'summary', '3': 1, '4': 1, '5': 9, '10': 'summary'},
    {'1': 'dates', '3': 2, '4': 3, '5': 9, '10': 'dates'},
  ],
};

/// Descriptor for `RecurrencePreview`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List recurrencePreviewDescriptor = $convert.base64Decode(
    'ChFSZWN1cnJlbmNlUHJldmlldxIYCgdzdW1tYXJ5GAEgASgJUgdzdW1tYXJ5EhQKBWRhdGVzGA'
    'IgAygJUgVkYXRlcw==');

@$core.Deprecated('Use recurrencePreviewRequestDescriptor instead')
const RecurrencePreviewRequest$json = {
  '1': 'RecurrencePreviewRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'rrule', '3': 2, '4': 1, '5': 9, '10': 'rrule'},
    {'1': 'mode', '3': 3, '4': 1, '5': 9, '10': 'mode'},
    {'1': 'timezone', '3': 4, '4': 1, '5': 9, '10': 'timezone'},
    {'1': 'skip_weekends', '3': 5, '4': 1, '5': 8, '10': 'skipWeekends'},
    {'1': 'ends_on', '3': 6, '4': 1, '5': 9, '10': 'endsOn'},
    {'1': 'starts_on', '3': 7, '4': 1, '5': 9, '10': 'startsOn'},
    {'1': 'count', '3': 8, '4': 1, '5': 5, '10': 'count'},
    {'1': 'after', '3': 9, '4': 1, '5': 9, '10': 'after'},
  ],
};

/// Descriptor for `RecurrencePreviewRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List recurrencePreviewRequestDescriptor = $convert.base64Decode(
    'ChhSZWN1cnJlbmNlUHJldmlld1JlcXVlc3QSIQoMd29ya3NwYWNlX2lkGAEgASgJUgt3b3Jrc3'
    'BhY2VJZBIUCgVycnVsZRgCIAEoCVIFcnJ1bGUSEgoEbW9kZRgDIAEoCVIEbW9kZRIaCgh0aW1l'
    'em9uZRgEIAEoCVIIdGltZXpvbmUSIwoNc2tpcF93ZWVrZW5kcxgFIAEoCFIMc2tpcFdlZWtlbm'
    'RzEhcKB2VuZHNfb24YBiABKAlSBmVuZHNPbhIbCglzdGFydHNfb24YByABKAlSCHN0YXJ0c09u'
    'EhQKBWNvdW50GAggASgFUgVjb3VudBIUCgVhZnRlchgJIAEoCVIFYWZ0ZXI=');

@$core.Deprecated('Use recurrenceSeriesAnswerDescriptor instead')
const RecurrenceSeriesAnswer$json = {
  '1': 'RecurrenceSeriesAnswer',
  '2': [
    {
      '1': 'series',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.config.recurrence.Series',
      '10': 'series'
    },
  ],
};

/// Descriptor for `RecurrenceSeriesAnswer`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List recurrenceSeriesAnswerDescriptor =
    $convert.base64Decode(
        'ChZSZWN1cnJlbmNlU2VyaWVzQW5zd2VyEjEKBnNlcmllcxgBIAEoCzIZLmNvbmZpZy5yZWN1cn'
        'JlbmNlLlNlcmllc1IGc2VyaWVz');

@$core.Deprecated('Use recurrenceSetRequestDescriptor instead')
const RecurrenceSetRequest$json = {
  '1': 'RecurrenceSetRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'task_id', '3': 3, '4': 1, '5': 9, '10': 'taskId'},
    {'1': 'rrule', '3': 4, '4': 1, '5': 9, '10': 'rrule'},
    {'1': 'mode', '3': 5, '4': 1, '5': 9, '10': 'mode'},
    {'1': 'timezone', '3': 6, '4': 1, '5': 9, '10': 'timezone'},
    {'1': 'skip_weekends', '3': 7, '4': 1, '5': 8, '10': 'skipWeekends'},
    {'1': 'ends_on', '3': 8, '4': 1, '5': 9, '10': 'endsOn'},
    {'1': 'at_time', '3': 9, '4': 1, '5': 9, '10': 'atTime'},
    {'1': 'lead_days', '3': 10, '4': 1, '5': 5, '10': 'leadDays'},
  ],
};

/// Descriptor for `RecurrenceSetRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List recurrenceSetRequestDescriptor = $convert.base64Decode(
    'ChRSZWN1cnJlbmNlU2V0UmVxdWVzdBIhCgx3b3Jrc3BhY2VfaWQYASABKAlSC3dvcmtzcGFjZU'
    'lkEh0KCnByb2plY3RfaWQYAiABKAlSCXByb2plY3RJZBIXCgd0YXNrX2lkGAMgASgJUgZ0YXNr'
    'SWQSFAoFcnJ1bGUYBCABKAlSBXJydWxlEhIKBG1vZGUYBSABKAlSBG1vZGUSGgoIdGltZXpvbm'
    'UYBiABKAlSCHRpbWV6b25lEiMKDXNraXBfd2Vla2VuZHMYByABKAhSDHNraXBXZWVrZW5kcxIX'
    'CgdlbmRzX29uGAggASgJUgZlbmRzT24SFwoHYXRfdGltZRgJIAEoCVIGYXRUaW1lEhsKCWxlYW'
    'RfZGF5cxgKIAEoBVIIbGVhZERheXM=');

@$core.Deprecated('Use recurrenceUpcomingDescriptor instead')
const RecurrenceUpcoming$json = {
  '1': 'RecurrenceUpcoming',
  '2': [
    {
      '1': 'ghosts',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.config.recurrence.Ghost',
      '10': 'ghosts'
    },
  ],
};

/// Descriptor for `RecurrenceUpcoming`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List recurrenceUpcomingDescriptor = $convert.base64Decode(
    'ChJSZWN1cnJlbmNlVXBjb21pbmcSMAoGZ2hvc3RzGAEgAygLMhguY29uZmlnLnJlY3VycmVuY2'
    'UuR2hvc3RSBmdob3N0cw==');

@$core.Deprecated('Use recurrenceUpcomingRequestDescriptor instead')
const RecurrenceUpcomingRequest$json = {
  '1': 'RecurrenceUpcomingRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'start', '3': 3, '4': 1, '5': 9, '10': 'start'},
    {'1': 'end', '3': 4, '4': 1, '5': 9, '10': 'end'},
  ],
};

/// Descriptor for `RecurrenceUpcomingRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List recurrenceUpcomingRequestDescriptor = $convert.base64Decode(
    'ChlSZWN1cnJlbmNlVXBjb21pbmdSZXF1ZXN0EiEKDHdvcmtzcGFjZV9pZBgBIAEoCVILd29ya3'
    'NwYWNlSWQSHQoKcHJvamVjdF9pZBgCIAEoCVIJcHJvamVjdElkEhQKBXN0YXJ0GAMgASgJUgVz'
    'dGFydBIQCgNlbmQYBCABKAlSA2VuZA==');

@$core.Deprecated('Use recurrenceUpdateFutureRequestDescriptor instead')
const RecurrenceUpdateFutureRequest$json = {
  '1': 'RecurrenceUpdateFutureRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'task_id', '3': 3, '4': 1, '5': 9, '10': 'taskId'},
  ],
};

/// Descriptor for `RecurrenceUpdateFutureRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List recurrenceUpdateFutureRequestDescriptor =
    $convert.base64Decode(
        'Ch1SZWN1cnJlbmNlVXBkYXRlRnV0dXJlUmVxdWVzdBIhCgx3b3Jrc3BhY2VfaWQYASABKAlSC3'
        'dvcmtzcGFjZUlkEh0KCnByb2plY3RfaWQYAiABKAlSCXByb2plY3RJZBIXCgd0YXNrX2lkGAMg'
        'ASgJUgZ0YXNrSWQ=');

@$core.Deprecated('Use seriesDescriptor instead')
const Series$json = {
  '1': 'Series',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'task_id', '3': 3, '4': 1, '5': 9, '10': 'taskId'},
    {'1': 'rrule', '3': 4, '4': 1, '5': 9, '10': 'rrule'},
    {'1': 'mode', '3': 5, '4': 1, '5': 9, '10': 'mode'},
    {'1': 'timezone', '3': 6, '4': 1, '5': 9, '10': 'timezone'},
    {'1': 'at_time', '3': 7, '4': 1, '5': 9, '10': 'atTime'},
    {'1': 'lead_days', '3': 8, '4': 1, '5': 5, '10': 'leadDays'},
    {'1': 'starts_on', '3': 9, '4': 1, '5': 9, '10': 'startsOn'},
    {'1': 'ends_on', '3': 10, '4': 1, '5': 9, '10': 'endsOn'},
    {'1': 'skip_weekends', '3': 11, '4': 1, '5': 8, '10': 'skipWeekends'},
    {'1': 'paused', '3': 12, '4': 1, '5': 8, '10': 'paused'},
    {'1': 'pause_reason', '3': 13, '4': 1, '5': 9, '10': 'pauseReason'},
    {'1': 'summary', '3': 14, '4': 1, '5': 9, '10': 'summary'},
    {'1': 'next_due_on', '3': 15, '4': 1, '5': 9, '10': 'nextDueOn'},
    {'1': 'next_run_at', '3': 16, '4': 1, '5': 9, '10': 'nextRunAt'},
    {'1': 'next_dates', '3': 17, '4': 3, '5': 9, '10': 'nextDates'},
    {'1': 'instance_count', '3': 18, '4': 1, '5': 5, '10': 'instanceCount'},
    {'1': 'index', '3': 19, '4': 1, '5': 5, '10': 'index'},
    {'1': 'is_template', '3': 20, '4': 1, '5': 8, '10': 'isTemplate'},
    {'1': 'template_missing', '3': 21, '4': 1, '5': 8, '10': 'templateMissing'},
    {'1': 'owner_id', '3': 22, '4': 1, '5': 9, '10': 'ownerId'},
    {'1': 'version', '3': 23, '4': 1, '5': 5, '10': 'version'},
  ],
};

/// Descriptor for `Series`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List seriesDescriptor = $convert.base64Decode(
    'CgZTZXJpZXMSDgoCaWQYASABKAlSAmlkEh0KCnByb2plY3RfaWQYAiABKAlSCXByb2plY3RJZB'
    'IXCgd0YXNrX2lkGAMgASgJUgZ0YXNrSWQSFAoFcnJ1bGUYBCABKAlSBXJydWxlEhIKBG1vZGUY'
    'BSABKAlSBG1vZGUSGgoIdGltZXpvbmUYBiABKAlSCHRpbWV6b25lEhcKB2F0X3RpbWUYByABKA'
    'lSBmF0VGltZRIbCglsZWFkX2RheXMYCCABKAVSCGxlYWREYXlzEhsKCXN0YXJ0c19vbhgJIAEo'
    'CVIIc3RhcnRzT24SFwoHZW5kc19vbhgKIAEoCVIGZW5kc09uEiMKDXNraXBfd2Vla2VuZHMYCy'
    'ABKAhSDHNraXBXZWVrZW5kcxIWCgZwYXVzZWQYDCABKAhSBnBhdXNlZBIhCgxwYXVzZV9yZWFz'
    'b24YDSABKAlSC3BhdXNlUmVhc29uEhgKB3N1bW1hcnkYDiABKAlSB3N1bW1hcnkSHgoLbmV4dF'
    '9kdWVfb24YDyABKAlSCW5leHREdWVPbhIeCgtuZXh0X3J1bl9hdBgQIAEoCVIJbmV4dFJ1bkF0'
    'Eh0KCm5leHRfZGF0ZXMYESADKAlSCW5leHREYXRlcxIlCg5pbnN0YW5jZV9jb3VudBgSIAEoBV'
    'INaW5zdGFuY2VDb3VudBIUCgVpbmRleBgTIAEoBVIFaW5kZXgSHwoLaXNfdGVtcGxhdGUYFCAB'
    'KAhSCmlzVGVtcGxhdGUSKQoQdGVtcGxhdGVfbWlzc2luZxgVIAEoCFIPdGVtcGxhdGVNaXNzaW'
    '5nEhkKCG93bmVyX2lkGBYgASgJUgdvd25lcklkEhgKB3ZlcnNpb24YFyABKAVSB3ZlcnNpb24=');
