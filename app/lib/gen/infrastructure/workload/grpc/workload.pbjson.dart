// This is a generated file - do not edit.
//
// Generated from infrastructure/workload/grpc/workload.proto.

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

@$core.Deprecated('Use assigneeEstimateAnswerDescriptor instead')
const AssigneeEstimateAnswer$json = {
  '1': 'AssigneeEstimateAnswer',
  '2': [
    {'1': 'task_id', '3': 1, '4': 1, '5': 9, '10': 'taskId'},
  ],
};

/// Descriptor for `AssigneeEstimateAnswer`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List assigneeEstimateAnswerDescriptor =
    $convert.base64Decode(
        'ChZBc3NpZ25lZUVzdGltYXRlQW5zd2VyEhcKB3Rhc2tfaWQYASABKAlSBnRhc2tJZA==');

@$core.Deprecated('Use assigneeEstimateRequestDescriptor instead')
const AssigneeEstimateRequest$json = {
  '1': 'AssigneeEstimateRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'task_id', '3': 2, '4': 1, '5': 9, '10': 'taskId'},
    {'1': 'user_id', '3': 3, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'estimate_sec', '3': 4, '4': 1, '5': 5, '10': 'estimateSec'},
  ],
};

/// Descriptor for `AssigneeEstimateRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List assigneeEstimateRequestDescriptor = $convert.base64Decode(
    'ChdBc3NpZ25lZUVzdGltYXRlUmVxdWVzdBIhCgx3b3Jrc3BhY2VfaWQYASABKAlSC3dvcmtzcG'
    'FjZUlkEhcKB3Rhc2tfaWQYAiABKAlSBnRhc2tJZBIXCgd1c2VyX2lkGAMgASgJUgZ1c2VySWQS'
    'IQoMZXN0aW1hdGVfc2VjGAQgASgFUgtlc3RpbWF0ZVNlYw==');

@$core.Deprecated('Use assigneeSecondsDescriptor instead')
const AssigneeSeconds$json = {
  '1': 'AssigneeSeconds',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'seconds', '3': 2, '4': 1, '5': 5, '10': 'seconds'},
  ],
};

/// Descriptor for `AssigneeSeconds`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List assigneeSecondsDescriptor = $convert.base64Decode(
    'Cg9Bc3NpZ25lZVNlY29uZHMSFwoHdXNlcl9pZBgBIAEoCVIGdXNlcklkEhgKB3NlY29uZHMYAi'
    'ABKAVSB3NlY29uZHM=');

@$core.Deprecated('Use capacityDescriptor instead')
const Capacity$json = {
  '1': 'Capacity',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'hours_per_day', '3': 2, '4': 1, '5': 9, '10': 'hoursPerDay'},
    {'1': 'working_days', '3': 3, '4': 3, '5': 5, '10': 'workingDays'},
    {'1': 'is_set', '3': 4, '4': 1, '5': 8, '10': 'isSet'},
  ],
};

/// Descriptor for `Capacity`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List capacityDescriptor = $convert.base64Decode(
    'CghDYXBhY2l0eRIXCgd1c2VyX2lkGAEgASgJUgZ1c2VySWQSIgoNaG91cnNfcGVyX2RheRgCIA'
    'EoCVILaG91cnNQZXJEYXkSIQoMd29ya2luZ19kYXlzGAMgAygFUgt3b3JraW5nRGF5cxIVCgZp'
    'c19zZXQYBCABKAhSBWlzU2V0');

@$core.Deprecated('Use capacityAnswerDescriptor instead')
const CapacityAnswer$json = {
  '1': 'CapacityAnswer',
  '2': [
    {
      '1': 'capacity',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.config.workload.Capacity',
      '10': 'capacity'
    },
  ],
};

/// Descriptor for `CapacityAnswer`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List capacityAnswerDescriptor = $convert.base64Decode(
    'Cg5DYXBhY2l0eUFuc3dlchI1CghjYXBhY2l0eRgBIAEoCzIZLmNvbmZpZy53b3JrbG9hZC5DYX'
    'BhY2l0eVIIY2FwYWNpdHk=');

@$core.Deprecated('Use capacityGetRequestDescriptor instead')
const CapacityGetRequest$json = {
  '1': 'CapacityGetRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'user_id', '3': 2, '4': 1, '5': 9, '10': 'userId'},
  ],
};

/// Descriptor for `CapacityGetRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List capacityGetRequestDescriptor = $convert.base64Decode(
    'ChJDYXBhY2l0eUdldFJlcXVlc3QSIQoMd29ya3NwYWNlX2lkGAEgASgJUgt3b3Jrc3BhY2VJZB'
    'IXCgd1c2VyX2lkGAIgASgJUgZ1c2VySWQ=');

@$core.Deprecated('Use capacityListDescriptor instead')
const CapacityList$json = {
  '1': 'CapacityList',
  '2': [
    {
      '1': 'capacities',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.config.workload.Capacity',
      '10': 'capacities'
    },
  ],
};

/// Descriptor for `CapacityList`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List capacityListDescriptor = $convert.base64Decode(
    'CgxDYXBhY2l0eUxpc3QSOQoKY2FwYWNpdGllcxgBIAMoCzIZLmNvbmZpZy53b3JrbG9hZC5DYX'
    'BhY2l0eVIKY2FwYWNpdGllcw==');

@$core.Deprecated('Use capacitySetRequestDescriptor instead')
const CapacitySetRequest$json = {
  '1': 'CapacitySetRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'user_id', '3': 2, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'hours_per_day', '3': 3, '4': 1, '5': 9, '10': 'hoursPerDay'},
    {'1': 'working_days', '3': 4, '4': 3, '5': 5, '10': 'workingDays'},
  ],
};

/// Descriptor for `CapacitySetRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List capacitySetRequestDescriptor = $convert.base64Decode(
    'ChJDYXBhY2l0eVNldFJlcXVlc3QSIQoMd29ya3NwYWNlX2lkGAEgASgJUgt3b3Jrc3BhY2VJZB'
    'IXCgd1c2VyX2lkGAIgASgJUgZ1c2VySWQSIgoNaG91cnNfcGVyX2RheRgDIAEoCVILaG91cnNQ'
    'ZXJEYXkSIQoMd29ya2luZ19kYXlzGAQgAygFUgt3b3JraW5nRGF5cw==');

@$core.Deprecated('Use contributionDescriptor instead')
const Contribution$json = {
  '1': 'Contribution',
  '2': [
    {'1': 'task_id', '3': 1, '4': 1, '5': 9, '10': 'taskId'},
    {'1': 'seconds', '3': 2, '4': 1, '5': 5, '10': 'seconds'},
    {'1': 'warning', '3': 3, '4': 1, '5': 8, '10': 'warning'},
  ],
};

/// Descriptor for `Contribution`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List contributionDescriptor = $convert.base64Decode(
    'CgxDb250cmlidXRpb24SFwoHdGFza19pZBgBIAEoCVIGdGFza0lkEhgKB3NlY29uZHMYAiABKA'
    'VSB3NlY29uZHMSGAoHd2FybmluZxgDIAEoCFIHd2FybmluZw==');

@$core.Deprecated('Use dayCellDescriptor instead')
const DayCell$json = {
  '1': 'DayCell',
  '2': [
    {'1': 'date', '3': 1, '4': 1, '5': 9, '10': 'date'},
    {'1': 'load_sec', '3': 2, '4': 1, '5': 5, '10': 'loadSec'},
    {'1': 'capacity_sec', '3': 3, '4': 1, '5': 5, '10': 'capacitySec'},
    {'1': 'over', '3': 4, '4': 1, '5': 8, '10': 'over'},
    {
      '1': 'contributions',
      '3': 5,
      '4': 3,
      '5': 11,
      '6': '.config.workload.Contribution',
      '10': 'contributions'
    },
  ],
};

/// Descriptor for `DayCell`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List dayCellDescriptor = $convert.base64Decode(
    'CgdEYXlDZWxsEhIKBGRhdGUYASABKAlSBGRhdGUSGQoIbG9hZF9zZWMYAiABKAVSB2xvYWRTZW'
    'MSIQoMY2FwYWNpdHlfc2VjGAMgASgFUgtjYXBhY2l0eVNlYxISCgRvdmVyGAQgASgIUgRvdmVy'
    'EkMKDWNvbnRyaWJ1dGlvbnMYBSADKAsyHS5jb25maWcud29ya2xvYWQuQ29udHJpYnV0aW9uUg'
    '1jb250cmlidXRpb25z');

@$core.Deprecated('Use holidayDescriptor instead')
const Holiday$json = {
  '1': 'Holiday',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'date', '3': 2, '4': 1, '5': 9, '10': 'date'},
    {'1': 'name', '3': 3, '4': 1, '5': 9, '10': 'name'},
  ],
};

/// Descriptor for `Holiday`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List holidayDescriptor = $convert.base64Decode(
    'CgdIb2xpZGF5Eg4KAmlkGAEgASgJUgJpZBISCgRkYXRlGAIgASgJUgRkYXRlEhIKBG5hbWUYAy'
    'ABKAlSBG5hbWU=');

@$core.Deprecated('Use holidayAnswerDescriptor instead')
const HolidayAnswer$json = {
  '1': 'HolidayAnswer',
  '2': [
    {
      '1': 'holiday',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.config.workload.Holiday',
      '10': 'holiday'
    },
  ],
};

/// Descriptor for `HolidayAnswer`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List holidayAnswerDescriptor = $convert.base64Decode(
    'Cg1Ib2xpZGF5QW5zd2VyEjIKB2hvbGlkYXkYASABKAsyGC5jb25maWcud29ya2xvYWQuSG9saW'
    'RheVIHaG9saWRheQ==');

@$core.Deprecated('Use holidayCreateRequestDescriptor instead')
const HolidayCreateRequest$json = {
  '1': 'HolidayCreateRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'date', '3': 2, '4': 1, '5': 9, '10': 'date'},
    {'1': 'name', '3': 3, '4': 1, '5': 9, '10': 'name'},
  ],
};

/// Descriptor for `HolidayCreateRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List holidayCreateRequestDescriptor = $convert.base64Decode(
    'ChRIb2xpZGF5Q3JlYXRlUmVxdWVzdBIhCgx3b3Jrc3BhY2VfaWQYASABKAlSC3dvcmtzcGFjZU'
    'lkEhIKBGRhdGUYAiABKAlSBGRhdGUSEgoEbmFtZRgDIAEoCVIEbmFtZQ==');

@$core.Deprecated('Use holidayDeleteRequestDescriptor instead')
const HolidayDeleteRequest$json = {
  '1': 'HolidayDeleteRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'holiday_id', '3': 2, '4': 1, '5': 9, '10': 'holidayId'},
  ],
};

/// Descriptor for `HolidayDeleteRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List holidayDeleteRequestDescriptor = $convert.base64Decode(
    'ChRIb2xpZGF5RGVsZXRlUmVxdWVzdBIhCgx3b3Jrc3BhY2VfaWQYASABKAlSC3dvcmtzcGFjZU'
    'lkEh0KCmhvbGlkYXlfaWQYAiABKAlSCWhvbGlkYXlJZA==');

@$core.Deprecated('Use holidayDeletedDescriptor instead')
const HolidayDeleted$json = {
  '1': 'HolidayDeleted',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `HolidayDeleted`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List holidayDeletedDescriptor =
    $convert.base64Decode('Cg5Ib2xpZGF5RGVsZXRlZBIOCgJpZBgBIAEoCVICaWQ=');

@$core.Deprecated('Use holidayListDescriptor instead')
const HolidayList$json = {
  '1': 'HolidayList',
  '2': [
    {
      '1': 'holidays',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.config.workload.Holiday',
      '10': 'holidays'
    },
  ],
};

/// Descriptor for `HolidayList`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List holidayListDescriptor = $convert.base64Decode(
    'CgtIb2xpZGF5TGlzdBI0Cghob2xpZGF5cxgBIAMoCzIYLmNvbmZpZy53b3JrbG9hZC5Ib2xpZG'
    'F5Ughob2xpZGF5cw==');

@$core.Deprecated('Use holidayListRequestDescriptor instead')
const HolidayListRequest$json = {
  '1': 'HolidayListRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'range_start', '3': 2, '4': 1, '5': 9, '10': 'rangeStart'},
    {'1': 'range_end', '3': 3, '4': 1, '5': 9, '10': 'rangeEnd'},
  ],
};

/// Descriptor for `HolidayListRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List holidayListRequestDescriptor = $convert.base64Decode(
    'ChJIb2xpZGF5TGlzdFJlcXVlc3QSIQoMd29ya3NwYWNlX2lkGAEgASgJUgt3b3Jrc3BhY2VJZB'
    'IfCgtyYW5nZV9zdGFydBgCIAEoCVIKcmFuZ2VTdGFydBIbCglyYW5nZV9lbmQYAyABKAlSCHJh'
    'bmdlRW5k');

@$core.Deprecated('Use holidayUpdateRequestDescriptor instead')
const HolidayUpdateRequest$json = {
  '1': 'HolidayUpdateRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'holiday_id', '3': 2, '4': 1, '5': 9, '10': 'holidayId'},
    {'1': 'date', '3': 3, '4': 1, '5': 9, '10': 'date'},
    {'1': 'name', '3': 4, '4': 1, '5': 9, '10': 'name'},
  ],
};

/// Descriptor for `HolidayUpdateRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List holidayUpdateRequestDescriptor = $convert.base64Decode(
    'ChRIb2xpZGF5VXBkYXRlUmVxdWVzdBIhCgx3b3Jrc3BhY2VfaWQYASABKAlSC3dvcmtzcGFjZU'
    'lkEh0KCmhvbGlkYXlfaWQYAiABKAlSCWhvbGlkYXlJZBISCgRkYXRlGAMgASgJUgRkYXRlEhIK'
    'BG5hbWUYBCABKAlSBG5hbWU=');

@$core.Deprecated('Use loadTaskDescriptor instead')
const LoadTask$json = {
  '1': 'LoadTask',
  '2': [
    {'1': 'task_id', '3': 1, '4': 1, '5': 9, '10': 'taskId'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'display_id', '3': 3, '4': 1, '5': 9, '10': 'displayId'},
    {'1': 'title', '3': 4, '4': 1, '5': 9, '10': 'title'},
    {'1': 'version', '3': 5, '4': 1, '5': 5, '10': 'version'},
    {'1': 'start_date', '3': 6, '4': 1, '5': 9, '10': 'startDate'},
    {'1': 'due_date', '3': 7, '4': 1, '5': 9, '10': 'dueDate'},
    {'1': 'estimate_sec', '3': 8, '4': 1, '5': 5, '10': 'estimateSec'},
    {'1': 'assignee_ids', '3': 9, '4': 3, '5': 9, '10': 'assigneeIds'},
    {
      '1': 'own',
      '3': 10,
      '4': 3,
      '5': 11,
      '6': '.config.workload.AssigneeSeconds',
      '10': 'own'
    },
    {'1': 'reason', '3': 11, '4': 1, '5': 9, '10': 'reason'},
  ],
};

/// Descriptor for `LoadTask`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List loadTaskDescriptor = $convert.base64Decode(
    'CghMb2FkVGFzaxIXCgd0YXNrX2lkGAEgASgJUgZ0YXNrSWQSHQoKcHJvamVjdF9pZBgCIAEoCV'
    'IJcHJvamVjdElkEh0KCmRpc3BsYXlfaWQYAyABKAlSCWRpc3BsYXlJZBIUCgV0aXRsZRgEIAEo'
    'CVIFdGl0bGUSGAoHdmVyc2lvbhgFIAEoBVIHdmVyc2lvbhIdCgpzdGFydF9kYXRlGAYgASgJUg'
    'lzdGFydERhdGUSGQoIZHVlX2RhdGUYByABKAlSB2R1ZURhdGUSIQoMZXN0aW1hdGVfc2VjGAgg'
    'ASgFUgtlc3RpbWF0ZVNlYxIhCgxhc3NpZ25lZV9pZHMYCSADKAlSC2Fzc2lnbmVlSWRzEjIKA2'
    '93bhgKIAMoCzIgLmNvbmZpZy53b3JrbG9hZC5Bc3NpZ25lZVNlY29uZHNSA293bhIWCgZyZWFz'
    'b24YCyABKAlSBnJlYXNvbg==');

@$core.Deprecated('Use offRangeDescriptor instead')
const OffRange$json = {
  '1': 'OffRange',
  '2': [
    {'1': 'start_date', '3': 1, '4': 1, '5': 9, '10': 'startDate'},
    {'1': 'end_date', '3': 2, '4': 1, '5': 9, '10': 'endDate'},
    {'1': 'kind', '3': 3, '4': 1, '5': 9, '10': 'kind'},
  ],
};

/// Descriptor for `OffRange`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List offRangeDescriptor = $convert.base64Decode(
    'CghPZmZSYW5nZRIdCgpzdGFydF9kYXRlGAEgASgJUglzdGFydERhdGUSGQoIZW5kX2RhdGUYAi'
    'ABKAlSB2VuZERhdGUSEgoEa2luZBgDIAEoCVIEa2luZA==');

@$core.Deprecated('Use personLoadDescriptor instead')
const PersonLoad$json = {
  '1': 'PersonLoad',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
    {
      '1': 'capacity',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.config.workload.Capacity',
      '10': 'capacity'
    },
    {
      '1': 'time_off',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.config.workload.OffRange',
      '10': 'timeOff'
    },
    {
      '1': 'days',
      '3': 4,
      '4': 3,
      '5': 11,
      '6': '.config.workload.DayCell',
      '10': 'days'
    },
    {'1': 'total_load_sec', '3': 5, '4': 1, '5': 5, '10': 'totalLoadSec'},
  ],
};

/// Descriptor for `PersonLoad`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List personLoadDescriptor = $convert.base64Decode(
    'CgpQZXJzb25Mb2FkEhcKB3VzZXJfaWQYASABKAlSBnVzZXJJZBI1CghjYXBhY2l0eRgCIAEoCz'
    'IZLmNvbmZpZy53b3JrbG9hZC5DYXBhY2l0eVIIY2FwYWNpdHkSNAoIdGltZV9vZmYYAyADKAsy'
    'GS5jb25maWcud29ya2xvYWQuT2ZmUmFuZ2VSB3RpbWVPZmYSLAoEZGF5cxgEIAMoCzIYLmNvbm'
    'ZpZy53b3JrbG9hZC5EYXlDZWxsUgRkYXlzEiQKDnRvdGFsX2xvYWRfc2VjGAUgASgFUgx0b3Rh'
    'bExvYWRTZWM=');

@$core.Deprecated('Use timeOffDescriptor instead')
const TimeOff$json = {
  '1': 'TimeOff',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'user_id', '3': 2, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'start_date', '3': 3, '4': 1, '5': 9, '10': 'startDate'},
    {'1': 'end_date', '3': 4, '4': 1, '5': 9, '10': 'endDate'},
    {'1': 'kind', '3': 5, '4': 1, '5': 9, '10': 'kind'},
    {'1': 'note', '3': 6, '4': 1, '5': 9, '10': 'note'},
  ],
};

/// Descriptor for `TimeOff`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List timeOffDescriptor = $convert.base64Decode(
    'CgdUaW1lT2ZmEg4KAmlkGAEgASgJUgJpZBIXCgd1c2VyX2lkGAIgASgJUgZ1c2VySWQSHQoKc3'
    'RhcnRfZGF0ZRgDIAEoCVIJc3RhcnREYXRlEhkKCGVuZF9kYXRlGAQgASgJUgdlbmREYXRlEhIK'
    'BGtpbmQYBSABKAlSBGtpbmQSEgoEbm90ZRgGIAEoCVIEbm90ZQ==');

@$core.Deprecated('Use timeOffAnswerDescriptor instead')
const TimeOffAnswer$json = {
  '1': 'TimeOffAnswer',
  '2': [
    {
      '1': 'entry',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.config.workload.TimeOff',
      '10': 'entry'
    },
  ],
};

/// Descriptor for `TimeOffAnswer`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List timeOffAnswerDescriptor = $convert.base64Decode(
    'Cg1UaW1lT2ZmQW5zd2VyEi4KBWVudHJ5GAEgASgLMhguY29uZmlnLndvcmtsb2FkLlRpbWVPZm'
    'ZSBWVudHJ5');

@$core.Deprecated('Use timeOffCreateRequestDescriptor instead')
const TimeOffCreateRequest$json = {
  '1': 'TimeOffCreateRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'user_id', '3': 2, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'start_date', '3': 3, '4': 1, '5': 9, '10': 'startDate'},
    {'1': 'end_date', '3': 4, '4': 1, '5': 9, '10': 'endDate'},
    {'1': 'kind', '3': 5, '4': 1, '5': 9, '10': 'kind'},
    {'1': 'note', '3': 6, '4': 1, '5': 9, '10': 'note'},
  ],
};

/// Descriptor for `TimeOffCreateRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List timeOffCreateRequestDescriptor = $convert.base64Decode(
    'ChRUaW1lT2ZmQ3JlYXRlUmVxdWVzdBIhCgx3b3Jrc3BhY2VfaWQYASABKAlSC3dvcmtzcGFjZU'
    'lkEhcKB3VzZXJfaWQYAiABKAlSBnVzZXJJZBIdCgpzdGFydF9kYXRlGAMgASgJUglzdGFydERh'
    'dGUSGQoIZW5kX2RhdGUYBCABKAlSB2VuZERhdGUSEgoEa2luZBgFIAEoCVIEa2luZBISCgRub3'
    'RlGAYgASgJUgRub3Rl');

@$core.Deprecated('Use timeOffDeleteRequestDescriptor instead')
const TimeOffDeleteRequest$json = {
  '1': 'TimeOffDeleteRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'time_off_id', '3': 2, '4': 1, '5': 9, '10': 'timeOffId'},
  ],
};

/// Descriptor for `TimeOffDeleteRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List timeOffDeleteRequestDescriptor = $convert.base64Decode(
    'ChRUaW1lT2ZmRGVsZXRlUmVxdWVzdBIhCgx3b3Jrc3BhY2VfaWQYASABKAlSC3dvcmtzcGFjZU'
    'lkEh4KC3RpbWVfb2ZmX2lkGAIgASgJUgl0aW1lT2ZmSWQ=');

@$core.Deprecated('Use timeOffDeletedDescriptor instead')
const TimeOffDeleted$json = {
  '1': 'TimeOffDeleted',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `TimeOffDeleted`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List timeOffDeletedDescriptor =
    $convert.base64Decode('Cg5UaW1lT2ZmRGVsZXRlZBIOCgJpZBgBIAEoCVICaWQ=');

@$core.Deprecated('Use timeOffListDescriptor instead')
const TimeOffList$json = {
  '1': 'TimeOffList',
  '2': [
    {
      '1': 'entries',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.config.workload.TimeOff',
      '10': 'entries'
    },
  ],
};

/// Descriptor for `TimeOffList`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List timeOffListDescriptor = $convert.base64Decode(
    'CgtUaW1lT2ZmTGlzdBIyCgdlbnRyaWVzGAEgAygLMhguY29uZmlnLndvcmtsb2FkLlRpbWVPZm'
    'ZSB2VudHJpZXM=');

@$core.Deprecated('Use timeOffListRequestDescriptor instead')
const TimeOffListRequest$json = {
  '1': 'TimeOffListRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'user_id', '3': 2, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'range_start', '3': 3, '4': 1, '5': 9, '10': 'rangeStart'},
    {'1': 'range_end', '3': 4, '4': 1, '5': 9, '10': 'rangeEnd'},
  ],
};

/// Descriptor for `TimeOffListRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List timeOffListRequestDescriptor = $convert.base64Decode(
    'ChJUaW1lT2ZmTGlzdFJlcXVlc3QSIQoMd29ya3NwYWNlX2lkGAEgASgJUgt3b3Jrc3BhY2VJZB'
    'IXCgd1c2VyX2lkGAIgASgJUgZ1c2VySWQSHwoLcmFuZ2Vfc3RhcnQYAyABKAlSCnJhbmdlU3Rh'
    'cnQSGwoJcmFuZ2VfZW5kGAQgASgJUghyYW5nZUVuZA==');

@$core.Deprecated('Use timeOffUpdateRequestDescriptor instead')
const TimeOffUpdateRequest$json = {
  '1': 'TimeOffUpdateRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'time_off_id', '3': 2, '4': 1, '5': 9, '10': 'timeOffId'},
    {'1': 'start_date', '3': 3, '4': 1, '5': 9, '10': 'startDate'},
    {'1': 'end_date', '3': 4, '4': 1, '5': 9, '10': 'endDate'},
    {'1': 'kind', '3': 5, '4': 1, '5': 9, '10': 'kind'},
    {'1': 'note', '3': 6, '4': 1, '5': 9, '10': 'note'},
  ],
};

/// Descriptor for `TimeOffUpdateRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List timeOffUpdateRequestDescriptor = $convert.base64Decode(
    'ChRUaW1lT2ZmVXBkYXRlUmVxdWVzdBIhCgx3b3Jrc3BhY2VfaWQYASABKAlSC3dvcmtzcGFjZU'
    'lkEh4KC3RpbWVfb2ZmX2lkGAIgASgJUgl0aW1lT2ZmSWQSHQoKc3RhcnRfZGF0ZRgDIAEoCVIJ'
    'c3RhcnREYXRlEhkKCGVuZF9kYXRlGAQgASgJUgdlbmREYXRlEhIKBGtpbmQYBSABKAlSBGtpbm'
    'QSEgoEbm90ZRgGIAEoCVIEbm90ZQ==');

@$core.Deprecated('Use workloadAnswerDescriptor instead')
const WorkloadAnswer$json = {
  '1': 'WorkloadAnswer',
  '2': [
    {'1': 'range_start', '3': 1, '4': 1, '5': 9, '10': 'rangeStart'},
    {'1': 'range_end', '3': 2, '4': 1, '5': 9, '10': 'rangeEnd'},
    {'1': 'can_see_all', '3': 3, '4': 1, '5': 8, '10': 'canSeeAll'},
    {
      '1': 'people',
      '3': 4,
      '4': 3,
      '5': 11,
      '6': '.config.workload.PersonLoad',
      '10': 'people'
    },
    {
      '1': 'tasks',
      '3': 5,
      '4': 3,
      '5': 11,
      '6': '.config.workload.LoadTask',
      '10': 'tasks'
    },
    {
      '1': 'unestimated',
      '3': 6,
      '4': 3,
      '5': 11,
      '6': '.config.workload.LoadTask',
      '10': 'unestimated'
    },
    {'1': 'holidays', '3': 7, '4': 3, '5': 9, '10': 'holidays'},
    {'1': 'truncated', '3': 8, '4': 1, '5': 8, '10': 'truncated'},
  ],
};

/// Descriptor for `WorkloadAnswer`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List workloadAnswerDescriptor = $convert.base64Decode(
    'Cg5Xb3JrbG9hZEFuc3dlchIfCgtyYW5nZV9zdGFydBgBIAEoCVIKcmFuZ2VTdGFydBIbCglyYW'
    '5nZV9lbmQYAiABKAlSCHJhbmdlRW5kEh4KC2Nhbl9zZWVfYWxsGAMgASgIUgljYW5TZWVBbGwS'
    'MwoGcGVvcGxlGAQgAygLMhsuY29uZmlnLndvcmtsb2FkLlBlcnNvbkxvYWRSBnBlb3BsZRIvCg'
    'V0YXNrcxgFIAMoCzIZLmNvbmZpZy53b3JrbG9hZC5Mb2FkVGFza1IFdGFza3MSOwoLdW5lc3Rp'
    'bWF0ZWQYBiADKAsyGS5jb25maWcud29ya2xvYWQuTG9hZFRhc2tSC3VuZXN0aW1hdGVkEhoKCG'
    'hvbGlkYXlzGAcgAygJUghob2xpZGF5cxIcCgl0cnVuY2F0ZWQYCCABKAhSCXRydW5jYXRlZA==');

@$core.Deprecated('Use workloadGetRequestDescriptor instead')
const WorkloadGetRequest$json = {
  '1': 'WorkloadGetRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'range_start', '3': 2, '4': 1, '5': 9, '10': 'rangeStart'},
    {'1': 'range_end', '3': 3, '4': 1, '5': 9, '10': 'rangeEnd'},
    {'1': 'project_ids', '3': 4, '4': 3, '5': 9, '10': 'projectIds'},
    {'1': 'user_ids', '3': 5, '4': 3, '5': 9, '10': 'userIds'},
  ],
};

/// Descriptor for `WorkloadGetRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List workloadGetRequestDescriptor = $convert.base64Decode(
    'ChJXb3JrbG9hZEdldFJlcXVlc3QSIQoMd29ya3NwYWNlX2lkGAEgASgJUgt3b3Jrc3BhY2VJZB'
    'IfCgtyYW5nZV9zdGFydBgCIAEoCVIKcmFuZ2VTdGFydBIbCglyYW5nZV9lbmQYAyABKAlSCHJh'
    'bmdlRW5kEh8KC3Byb2plY3RfaWRzGAQgAygJUgpwcm9qZWN0SWRzEhkKCHVzZXJfaWRzGAUgAy'
    'gJUgd1c2VySWRz');
