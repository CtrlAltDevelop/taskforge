// This is a generated file - do not edit.
//
// Generated from infrastructure/home/grpc/home.proto.

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

@$core.Deprecated('Use homeDayDescriptor instead')
const HomeDay$json = {
  '1': 'HomeDay',
  '2': [
    {'1': 'date', '3': 1, '4': 1, '5': 9, '10': 'date'},
    {'1': 'seconds', '3': 2, '4': 1, '5': 5, '10': 'seconds'},
  ],
};

/// Descriptor for `HomeDay`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List homeDayDescriptor = $convert.base64Decode(
    'CgdIb21lRGF5EhIKBGRhdGUYASABKAlSBGRhdGUSGAoHc2Vjb25kcxgCIAEoBVIHc2Vjb25kcw'
    '==');

@$core.Deprecated('Use homeMentionDescriptor instead')
const HomeMention$json = {
  '1': 'HomeMention',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'type', '3': 2, '4': 1, '5': 9, '10': 'type'},
    {'1': 'task_id', '3': 3, '4': 1, '5': 9, '10': 'taskId'},
    {'1': 'actor_id', '3': 4, '4': 1, '5': 9, '10': 'actorId'},
    {'1': 'created_at', '3': 5, '4': 1, '5': 9, '10': 'createdAt'},
    {'1': 'read', '3': 6, '4': 1, '5': 8, '10': 'read'},
    {'1': 'payload_json', '3': 7, '4': 1, '5': 9, '10': 'payloadJson'},
  ],
};

/// Descriptor for `HomeMention`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List homeMentionDescriptor = $convert.base64Decode(
    'CgtIb21lTWVudGlvbhIOCgJpZBgBIAEoCVICaWQSEgoEdHlwZRgCIAEoCVIEdHlwZRIXCgd0YX'
    'NrX2lkGAMgASgJUgZ0YXNrSWQSGQoIYWN0b3JfaWQYBCABKAlSB2FjdG9ySWQSHQoKY3JlYXRl'
    'ZF9hdBgFIAEoCVIJY3JlYXRlZEF0EhIKBHJlYWQYBiABKAhSBHJlYWQSIQoMcGF5bG9hZF9qc2'
    '9uGAcgASgJUgtwYXlsb2FkSnNvbg==');

@$core.Deprecated('Use homeMyWorkDescriptor instead')
const HomeMyWork$json = {
  '1': 'HomeMyWork',
  '2': [
    {
      '1': 'tasks',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.config.home.MyWorkTask',
      '10': 'tasks'
    },
    {'1': 'next_cursor', '3': 2, '4': 1, '5': 9, '10': 'nextCursor'},
  ],
};

/// Descriptor for `HomeMyWork`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List homeMyWorkDescriptor = $convert.base64Decode(
    'CgpIb21lTXlXb3JrEi0KBXRhc2tzGAEgAygLMhcuY29uZmlnLmhvbWUuTXlXb3JrVGFza1IFdG'
    'Fza3MSHwoLbmV4dF9jdXJzb3IYAiABKAlSCm5leHRDdXJzb3I=');

@$core.Deprecated('Use homeMyWorkRequestDescriptor instead')
const HomeMyWorkRequest$json = {
  '1': 'HomeMyWorkRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'relation', '3': 2, '4': 1, '5': 9, '10': 'relation'},
    {'1': 'include_done', '3': 3, '4': 1, '5': 8, '10': 'includeDone'},
    {'1': 'filter_ast', '3': 4, '4': 1, '5': 9, '10': 'filterAst'},
    {'1': 'today', '3': 5, '4': 1, '5': 9, '10': 'today'},
    {'1': 'cursor', '3': 6, '4': 1, '5': 9, '10': 'cursor'},
    {'1': 'limit', '3': 7, '4': 1, '5': 5, '10': 'limit'},
  ],
};

/// Descriptor for `HomeMyWorkRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List homeMyWorkRequestDescriptor = $convert.base64Decode(
    'ChFIb21lTXlXb3JrUmVxdWVzdBIhCgx3b3Jrc3BhY2VfaWQYASABKAlSC3dvcmtzcGFjZUlkEh'
    'oKCHJlbGF0aW9uGAIgASgJUghyZWxhdGlvbhIhCgxpbmNsdWRlX2RvbmUYAyABKAhSC2luY2x1'
    'ZGVEb25lEh0KCmZpbHRlcl9hc3QYBCABKAlSCWZpbHRlckFzdBIUCgV0b2RheRgFIAEoCVIFdG'
    '9kYXkSFgoGY3Vyc29yGAYgASgJUgZjdXJzb3ISFAoFbGltaXQYByABKAVSBWxpbWl0');

@$core.Deprecated('Use homePinDescriptor instead')
const HomePin$json = {
  '1': 'HomePin',
  '2': [
    {'1': 'dashboard_id', '3': 1, '4': 1, '5': 9, '10': 'dashboardId'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'project_id', '3': 3, '4': 1, '5': 9, '10': 'projectId'},
  ],
};

/// Descriptor for `HomePin`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List homePinDescriptor = $convert.base64Decode(
    'CgdIb21lUGluEiEKDGRhc2hib2FyZF9pZBgBIAEoCVILZGFzaGJvYXJkSWQSEgoEbmFtZRgCIA'
    'EoCVIEbmFtZRIdCgpwcm9qZWN0X2lkGAMgASgJUglwcm9qZWN0SWQ=');

@$core.Deprecated('Use homePinDashboardRequestDescriptor instead')
const HomePinDashboardRequest$json = {
  '1': 'HomePinDashboardRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'dashboard_id', '3': 2, '4': 1, '5': 9, '10': 'dashboardId'},
    {'1': 'pinned', '3': 3, '4': 1, '5': 8, '10': 'pinned'},
  ],
};

/// Descriptor for `HomePinDashboardRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List homePinDashboardRequestDescriptor = $convert.base64Decode(
    'ChdIb21lUGluRGFzaGJvYXJkUmVxdWVzdBIhCgx3b3Jrc3BhY2VfaWQYASABKAlSC3dvcmtzcG'
    'FjZUlkEiEKDGRhc2hib2FyZF9pZBgCIAEoCVILZGFzaGJvYXJkSWQSFgoGcGlubmVkGAMgASgI'
    'UgZwaW5uZWQ=');

@$core.Deprecated('Use homePinnedDescriptor instead')
const HomePinned$json = {
  '1': 'HomePinned',
};

/// Descriptor for `HomePinned`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List homePinnedDescriptor =
    $convert.base64Decode('CgpIb21lUGlubmVk');

@$core.Deprecated('Use homeRecordRecentRequestDescriptor instead')
const HomeRecordRecentRequest$json = {
  '1': 'HomeRecordRecentRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'task_id', '3': 2, '4': 1, '5': 9, '10': 'taskId'},
  ],
};

/// Descriptor for `HomeRecordRecentRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List homeRecordRecentRequestDescriptor =
    $convert.base64Decode(
        'ChdIb21lUmVjb3JkUmVjZW50UmVxdWVzdBIhCgx3b3Jrc3BhY2VfaWQYASABKAlSC3dvcmtzcG'
        'FjZUlkEhcKB3Rhc2tfaWQYAiABKAlSBnRhc2tJZA==');

@$core.Deprecated('Use homeRecordedDescriptor instead')
const HomeRecorded$json = {
  '1': 'HomeRecorded',
};

/// Descriptor for `HomeRecorded`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List homeRecordedDescriptor =
    $convert.base64Decode('CgxIb21lUmVjb3JkZWQ=');

@$core.Deprecated('Use homeSummaryDescriptor instead')
const HomeSummary$json = {
  '1': 'HomeSummary',
  '2': [
    {'1': 'today_count', '3': 1, '4': 1, '5': 5, '10': 'todayCount'},
    {'1': 'overdue_count', '3': 2, '4': 1, '5': 5, '10': 'overdueCount'},
    {'1': 'in_progress_count', '3': 3, '4': 1, '5': 5, '10': 'inProgressCount'},
    {
      '1': 'due_items',
      '3': 4,
      '4': 3,
      '5': 11,
      '6': '.config.home.HomeTask',
      '10': 'dueItems'
    },
    {
      '1': 'in_progress_items',
      '3': 5,
      '4': 3,
      '5': 11,
      '6': '.config.home.HomeTask',
      '10': 'inProgressItems'
    },
    {
      '1': 'recent',
      '3': 6,
      '4': 3,
      '5': 11,
      '6': '.config.home.HomeTask',
      '10': 'recent'
    },
    {
      '1': 'mentions',
      '3': 7,
      '4': 3,
      '5': 11,
      '6': '.config.home.HomeMention',
      '10': 'mentions'
    },
    {
      '1': 'unread_notifications',
      '3': 8,
      '4': 1,
      '5': 5,
      '10': 'unreadNotifications'
    },
    {'1': 'unread_chat', '3': 9, '4': 1, '5': 5, '10': 'unreadChat'},
    {
      '1': 'week',
      '3': 10,
      '4': 3,
      '5': 11,
      '6': '.config.home.HomeDay',
      '10': 'week'
    },
    {
      '1': 'pinned_dashboards',
      '3': 11,
      '4': 3,
      '5': 11,
      '6': '.config.home.HomePin',
      '10': 'pinnedDashboards'
    },
    {'1': 'computed_at', '3': 12, '4': 1, '5': 9, '10': 'computedAt'},
  ],
};

/// Descriptor for `HomeSummary`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List homeSummaryDescriptor = $convert.base64Decode(
    'CgtIb21lU3VtbWFyeRIfCgt0b2RheV9jb3VudBgBIAEoBVIKdG9kYXlDb3VudBIjCg1vdmVyZH'
    'VlX2NvdW50GAIgASgFUgxvdmVyZHVlQ291bnQSKgoRaW5fcHJvZ3Jlc3NfY291bnQYAyABKAVS'
    'D2luUHJvZ3Jlc3NDb3VudBIyCglkdWVfaXRlbXMYBCADKAsyFS5jb25maWcuaG9tZS5Ib21lVG'
    'Fza1IIZHVlSXRlbXMSQQoRaW5fcHJvZ3Jlc3NfaXRlbXMYBSADKAsyFS5jb25maWcuaG9tZS5I'
    'b21lVGFza1IPaW5Qcm9ncmVzc0l0ZW1zEi0KBnJlY2VudBgGIAMoCzIVLmNvbmZpZy5ob21lLk'
    'hvbWVUYXNrUgZyZWNlbnQSNAoIbWVudGlvbnMYByADKAsyGC5jb25maWcuaG9tZS5Ib21lTWVu'
    'dGlvblIIbWVudGlvbnMSMQoUdW5yZWFkX25vdGlmaWNhdGlvbnMYCCABKAVSE3VucmVhZE5vdG'
    'lmaWNhdGlvbnMSHwoLdW5yZWFkX2NoYXQYCSABKAVSCnVucmVhZENoYXQSKAoEd2VlaxgKIAMo'
    'CzIULmNvbmZpZy5ob21lLkhvbWVEYXlSBHdlZWsSQQoRcGlubmVkX2Rhc2hib2FyZHMYCyADKA'
    'syFC5jb25maWcuaG9tZS5Ib21lUGluUhBwaW5uZWREYXNoYm9hcmRzEh8KC2NvbXB1dGVkX2F0'
    'GAwgASgJUgpjb21wdXRlZEF0');

@$core.Deprecated('Use homeSummaryRequestDescriptor instead')
const HomeSummaryRequest$json = {
  '1': 'HomeSummaryRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'today', '3': 2, '4': 1, '5': 9, '10': 'today'},
    {
      '1': 'utc_offset_minutes',
      '3': 3,
      '4': 1,
      '5': 5,
      '10': 'utcOffsetMinutes'
    },
  ],
};

/// Descriptor for `HomeSummaryRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List homeSummaryRequestDescriptor = $convert.base64Decode(
    'ChJIb21lU3VtbWFyeVJlcXVlc3QSIQoMd29ya3NwYWNlX2lkGAEgASgJUgt3b3Jrc3BhY2VJZB'
    'IUCgV0b2RheRgCIAEoCVIFdG9kYXkSLAoSdXRjX29mZnNldF9taW51dGVzGAMgASgFUhB1dGNP'
    'ZmZzZXRNaW51dGVz');

@$core.Deprecated('Use homeTaskDescriptor instead')
const HomeTask$json = {
  '1': 'HomeTask',
  '2': [
    {'1': 'task_id', '3': 1, '4': 1, '5': 9, '10': 'taskId'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'project_key', '3': 3, '4': 1, '5': 9, '10': 'projectKey'},
    {'1': 'number', '3': 4, '4': 1, '5': 5, '10': 'number'},
    {'1': 'title', '3': 5, '4': 1, '5': 9, '10': 'title'},
    {'1': 'status_name', '3': 6, '4': 1, '5': 9, '10': 'statusName'},
    {'1': 'status_category', '3': 7, '4': 1, '5': 9, '10': 'statusCategory'},
    {'1': 'priority', '3': 8, '4': 1, '5': 9, '10': 'priority'},
    {'1': 'due_date', '3': 9, '4': 1, '5': 9, '10': 'dueDate'},
  ],
};

/// Descriptor for `HomeTask`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List homeTaskDescriptor = $convert.base64Decode(
    'CghIb21lVGFzaxIXCgd0YXNrX2lkGAEgASgJUgZ0YXNrSWQSHQoKcHJvamVjdF9pZBgCIAEoCV'
    'IJcHJvamVjdElkEh8KC3Byb2plY3Rfa2V5GAMgASgJUgpwcm9qZWN0S2V5EhYKBm51bWJlchgE'
    'IAEoBVIGbnVtYmVyEhQKBXRpdGxlGAUgASgJUgV0aXRsZRIfCgtzdGF0dXNfbmFtZRgGIAEoCV'
    'IKc3RhdHVzTmFtZRInCg9zdGF0dXNfY2F0ZWdvcnkYByABKAlSDnN0YXR1c0NhdGVnb3J5EhoK'
    'CHByaW9yaXR5GAggASgJUghwcmlvcml0eRIZCghkdWVfZGF0ZRgJIAEoCVIHZHVlRGF0ZQ==');

@$core.Deprecated('Use myWorkTaskDescriptor instead')
const MyWorkTask$json = {
  '1': 'MyWorkTask',
  '2': [
    {
      '1': 'task',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.config.home.HomeTask',
      '10': 'task'
    },
    {'1': 'assigned', '3': 2, '4': 1, '5': 8, '10': 'assigned'},
    {'1': 'watching', '3': 3, '4': 1, '5': 8, '10': 'watching'},
  ],
};

/// Descriptor for `MyWorkTask`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List myWorkTaskDescriptor = $convert.base64Decode(
    'CgpNeVdvcmtUYXNrEikKBHRhc2sYASABKAsyFS5jb25maWcuaG9tZS5Ib21lVGFza1IEdGFzax'
    'IaCghhc3NpZ25lZBgCIAEoCFIIYXNzaWduZWQSGgoId2F0Y2hpbmcYAyABKAhSCHdhdGNoaW5n');

@$core.Deprecated('Use onboardingApplyStarterRequestDescriptor instead')
const OnboardingApplyStarterRequest$json = {
  '1': 'OnboardingApplyStarterRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'starter', '3': 2, '4': 1, '5': 9, '10': 'starter'},
    {'1': 'name', '3': 3, '4': 1, '5': 9, '10': 'name'},
    {'1': 'key', '3': 4, '4': 1, '5': 9, '10': 'key'},
  ],
};

/// Descriptor for `OnboardingApplyStarterRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List onboardingApplyStarterRequestDescriptor =
    $convert.base64Decode(
        'Ch1PbmJvYXJkaW5nQXBwbHlTdGFydGVyUmVxdWVzdBIhCgx3b3Jrc3BhY2VfaWQYASABKAlSC3'
        'dvcmtzcGFjZUlkEhgKB3N0YXJ0ZXIYAiABKAlSB3N0YXJ0ZXISEgoEbmFtZRgDIAEoCVIEbmFt'
        'ZRIQCgNrZXkYBCABKAlSA2tleQ==');

@$core.Deprecated('Use onboardingCompleteStepRequestDescriptor instead')
const OnboardingCompleteStepRequest$json = {
  '1': 'OnboardingCompleteStepRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'step', '3': 2, '4': 1, '5': 9, '10': 'step'},
  ],
};

/// Descriptor for `OnboardingCompleteStepRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List onboardingCompleteStepRequestDescriptor =
    $convert.base64Decode(
        'Ch1PbmJvYXJkaW5nQ29tcGxldGVTdGVwUmVxdWVzdBIhCgx3b3Jrc3BhY2VfaWQYASABKAlSC3'
        'dvcmtzcGFjZUlkEhIKBHN0ZXAYAiABKAlSBHN0ZXA=');

@$core.Deprecated('Use onboardingDeleteSamplesRequestDescriptor instead')
const OnboardingDeleteSamplesRequest$json = {
  '1': 'OnboardingDeleteSamplesRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
  ],
};

/// Descriptor for `OnboardingDeleteSamplesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List onboardingDeleteSamplesRequestDescriptor =
    $convert.base64Decode(
        'Ch5PbmJvYXJkaW5nRGVsZXRlU2FtcGxlc1JlcXVlc3QSIQoMd29ya3NwYWNlX2lkGAEgASgJUg'
        't3b3Jrc3BhY2VJZA==');

@$core.Deprecated('Use onboardingDismissRequestDescriptor instead')
const OnboardingDismissRequest$json = {
  '1': 'OnboardingDismissRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
  ],
};

/// Descriptor for `OnboardingDismissRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List onboardingDismissRequestDescriptor =
    $convert.base64Decode(
        'ChhPbmJvYXJkaW5nRGlzbWlzc1JlcXVlc3QSIQoMd29ya3NwYWNlX2lkGAEgASgJUgt3b3Jrc3'
        'BhY2VJZA==');

@$core.Deprecated('Use onboardingGetRequestDescriptor instead')
const OnboardingGetRequest$json = {
  '1': 'OnboardingGetRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
  ],
};

/// Descriptor for `OnboardingGetRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List onboardingGetRequestDescriptor = $convert.base64Decode(
    'ChRPbmJvYXJkaW5nR2V0UmVxdWVzdBIhCgx3b3Jrc3BhY2VfaWQYASABKAlSC3dvcmtzcGFjZU'
    'lk');

@$core.Deprecated('Use onboardingSamplesDeletedDescriptor instead')
const OnboardingSamplesDeleted$json = {
  '1': 'OnboardingSamplesDeleted',
  '2': [
    {'1': 'deleted', '3': 1, '4': 1, '5': 5, '10': 'deleted'},
  ],
};

/// Descriptor for `OnboardingSamplesDeleted`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List onboardingSamplesDeletedDescriptor =
    $convert.base64Decode(
        'ChhPbmJvYXJkaW5nU2FtcGxlc0RlbGV0ZWQSGAoHZGVsZXRlZBgBIAEoBVIHZGVsZXRlZA==');

@$core.Deprecated('Use onboardingStarterDescriptor instead')
const OnboardingStarter$json = {
  '1': 'OnboardingStarter',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'description', '3': 3, '4': 1, '5': 9, '10': 'description'},
  ],
};

/// Descriptor for `OnboardingStarter`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List onboardingStarterDescriptor = $convert.base64Decode(
    'ChFPbmJvYXJkaW5nU3RhcnRlchIQCgNrZXkYASABKAlSA2tleRISCgRuYW1lGAIgASgJUgRuYW'
    '1lEiAKC2Rlc2NyaXB0aW9uGAMgASgJUgtkZXNjcmlwdGlvbg==');

@$core.Deprecated('Use onboardingStarterAppliedDescriptor instead')
const OnboardingStarterApplied$json = {
  '1': 'OnboardingStarterApplied',
  '2': [
    {'1': 'project_id', '3': 1, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'task_count', '3': 2, '4': 1, '5': 5, '10': 'taskCount'},
  ],
};

/// Descriptor for `OnboardingStarterApplied`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List onboardingStarterAppliedDescriptor =
    $convert.base64Decode(
        'ChhPbmJvYXJkaW5nU3RhcnRlckFwcGxpZWQSHQoKcHJvamVjdF9pZBgBIAEoCVIJcHJvamVjdE'
        'lkEh0KCnRhc2tfY291bnQYAiABKAVSCXRhc2tDb3VudA==');

@$core.Deprecated('Use onboardingStateDescriptor instead')
const OnboardingState$json = {
  '1': 'OnboardingState',
  '2': [
    {
      '1': 'steps',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.config.home.OnboardingStep',
      '10': 'steps'
    },
    {'1': 'dismissed', '3': 2, '4': 1, '5': 8, '10': 'dismissed'},
    {'1': 'complete', '3': 3, '4': 1, '5': 8, '10': 'complete'},
    {'1': 'visible', '3': 4, '4': 1, '5': 8, '10': 'visible'},
    {'1': 'sample_project_id', '3': 5, '4': 1, '5': 9, '10': 'sampleProjectId'},
    {'1': 'sample_count', '3': 6, '4': 1, '5': 5, '10': 'sampleCount'},
    {
      '1': 'starters',
      '3': 7,
      '4': 3,
      '5': 11,
      '6': '.config.home.OnboardingStarter',
      '10': 'starters'
    },
  ],
};

/// Descriptor for `OnboardingState`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List onboardingStateDescriptor = $convert.base64Decode(
    'Cg9PbmJvYXJkaW5nU3RhdGUSMQoFc3RlcHMYASADKAsyGy5jb25maWcuaG9tZS5PbmJvYXJkaW'
    '5nU3RlcFIFc3RlcHMSHAoJZGlzbWlzc2VkGAIgASgIUglkaXNtaXNzZWQSGgoIY29tcGxldGUY'
    'AyABKAhSCGNvbXBsZXRlEhgKB3Zpc2libGUYBCABKAhSB3Zpc2libGUSKgoRc2FtcGxlX3Byb2'
    'plY3RfaWQYBSABKAlSD3NhbXBsZVByb2plY3RJZBIhCgxzYW1wbGVfY291bnQYBiABKAVSC3Nh'
    'bXBsZUNvdW50EjoKCHN0YXJ0ZXJzGAcgAygLMh4uY29uZmlnLmhvbWUuT25ib2FyZGluZ1N0YX'
    'J0ZXJSCHN0YXJ0ZXJz');

@$core.Deprecated('Use onboardingStepDescriptor instead')
const OnboardingStep$json = {
  '1': 'OnboardingStep',
  '2': [
    {'1': 'step', '3': 1, '4': 1, '5': 9, '10': 'step'},
    {'1': 'done', '3': 2, '4': 1, '5': 8, '10': 'done'},
  ],
};

/// Descriptor for `OnboardingStep`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List onboardingStepDescriptor = $convert.base64Decode(
    'Cg5PbmJvYXJkaW5nU3RlcBISCgRzdGVwGAEgASgJUgRzdGVwEhIKBGRvbmUYAiABKAhSBGRvbm'
    'U=');
