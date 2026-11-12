// This is a generated file - do not edit.
//
// Generated from infrastructure/dashboards/grpc/dashboards.proto.

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

@$core.Deprecated('Use bucketDescriptor instead')
const Bucket$json = {
  '1': 'Bucket',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'label', '3': 2, '4': 1, '5': 9, '10': 'label'},
    {'1': 'value', '3': 3, '4': 1, '5': 9, '10': 'value'},
  ],
};

/// Descriptor for `Bucket`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List bucketDescriptor = $convert.base64Decode(
    'CgZCdWNrZXQSEAoDa2V5GAEgASgJUgNrZXkSFAoFbGFiZWwYAiABKAlSBWxhYmVsEhQKBXZhbH'
    'VlGAMgASgJUgV2YWx1ZQ==');

@$core.Deprecated('Use dashboardDescriptor instead')
const Dashboard$json = {
  '1': 'Dashboard',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'workspace_id', '3': 2, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'project_id', '3': 3, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'owner_id', '3': 4, '4': 1, '5': 9, '10': 'ownerId'},
    {'1': 'name', '3': 5, '4': 1, '5': 9, '10': 'name'},
    {'1': 'visibility', '3': 6, '4': 1, '5': 9, '10': 'visibility'},
    {'1': 'layout_json', '3': 7, '4': 1, '5': 9, '10': 'layoutJson'},
    {'1': 'version', '3': 8, '4': 1, '5': 5, '10': 'version'},
    {'1': 'can_edit', '3': 9, '4': 1, '5': 8, '10': 'canEdit'},
    {
      '1': 'widgets',
      '3': 10,
      '4': 3,
      '5': 11,
      '6': '.config.dashboards.Widget',
      '10': 'widgets'
    },
    {'1': 'updated_at', '3': 11, '4': 1, '5': 9, '10': 'updatedAt'},
  ],
};

/// Descriptor for `Dashboard`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List dashboardDescriptor = $convert.base64Decode(
    'CglEYXNoYm9hcmQSDgoCaWQYASABKAlSAmlkEiEKDHdvcmtzcGFjZV9pZBgCIAEoCVILd29ya3'
    'NwYWNlSWQSHQoKcHJvamVjdF9pZBgDIAEoCVIJcHJvamVjdElkEhkKCG93bmVyX2lkGAQgASgJ'
    'Ugdvd25lcklkEhIKBG5hbWUYBSABKAlSBG5hbWUSHgoKdmlzaWJpbGl0eRgGIAEoCVIKdmlzaW'
    'JpbGl0eRIfCgtsYXlvdXRfanNvbhgHIAEoCVIKbGF5b3V0SnNvbhIYCgd2ZXJzaW9uGAggASgF'
    'Ugd2ZXJzaW9uEhkKCGNhbl9lZGl0GAkgASgIUgdjYW5FZGl0EjMKB3dpZGdldHMYCiADKAsyGS'
    '5jb25maWcuZGFzaGJvYXJkcy5XaWRnZXRSB3dpZGdldHMSHQoKdXBkYXRlZF9hdBgLIAEoCVIJ'
    'dXBkYXRlZEF0');

@$core.Deprecated('Use dashboardAnswerDescriptor instead')
const DashboardAnswer$json = {
  '1': 'DashboardAnswer',
  '2': [
    {
      '1': 'dashboard',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.config.dashboards.Dashboard',
      '10': 'dashboard'
    },
  ],
};

/// Descriptor for `DashboardAnswer`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List dashboardAnswerDescriptor = $convert.base64Decode(
    'Cg9EYXNoYm9hcmRBbnN3ZXISOgoJZGFzaGJvYXJkGAEgASgLMhwuY29uZmlnLmRhc2hib2FyZH'
    'MuRGFzaGJvYXJkUglkYXNoYm9hcmQ=');

@$core.Deprecated('Use dashboardDeleteRequestDescriptor instead')
const DashboardDeleteRequest$json = {
  '1': 'DashboardDeleteRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'id', '3': 2, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `DashboardDeleteRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List dashboardDeleteRequestDescriptor =
    $convert.base64Decode(
        'ChZEYXNoYm9hcmREZWxldGVSZXF1ZXN0EiEKDHdvcmtzcGFjZV9pZBgBIAEoCVILd29ya3NwYW'
        'NlSWQSDgoCaWQYAiABKAlSAmlk');

@$core.Deprecated('Use dashboardDeletedDescriptor instead')
const DashboardDeleted$json = {
  '1': 'DashboardDeleted',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `DashboardDeleted`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List dashboardDeletedDescriptor =
    $convert.base64Decode('ChBEYXNoYm9hcmREZWxldGVkEg4KAmlkGAEgASgJUgJpZA==');

@$core.Deprecated('Use dashboardFromTemplateRequestDescriptor instead')
const DashboardFromTemplateRequest$json = {
  '1': 'DashboardFromTemplateRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'template', '3': 2, '4': 1, '5': 9, '10': 'template'},
    {'1': 'project_id', '3': 3, '4': 1, '5': 9, '10': 'projectId'},
  ],
};

/// Descriptor for `DashboardFromTemplateRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List dashboardFromTemplateRequestDescriptor =
    $convert.base64Decode(
        'ChxEYXNoYm9hcmRGcm9tVGVtcGxhdGVSZXF1ZXN0EiEKDHdvcmtzcGFjZV9pZBgBIAEoCVILd2'
        '9ya3NwYWNlSWQSGgoIdGVtcGxhdGUYAiABKAlSCHRlbXBsYXRlEh0KCnByb2plY3RfaWQYAyAB'
        'KAlSCXByb2plY3RJZA==');

@$core.Deprecated('Use dashboardGetRequestDescriptor instead')
const DashboardGetRequest$json = {
  '1': 'DashboardGetRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'id', '3': 2, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `DashboardGetRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List dashboardGetRequestDescriptor = $convert.base64Decode(
    'ChNEYXNoYm9hcmRHZXRSZXF1ZXN0EiEKDHdvcmtzcGFjZV9pZBgBIAEoCVILd29ya3NwYWNlSW'
    'QSDgoCaWQYAiABKAlSAmlk');

@$core.Deprecated('Use dashboardListDescriptor instead')
const DashboardList$json = {
  '1': 'DashboardList',
  '2': [
    {
      '1': 'dashboards',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.config.dashboards.Dashboard',
      '10': 'dashboards'
    },
  ],
};

/// Descriptor for `DashboardList`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List dashboardListDescriptor = $convert.base64Decode(
    'Cg1EYXNoYm9hcmRMaXN0EjwKCmRhc2hib2FyZHMYASADKAsyHC5jb25maWcuZGFzaGJvYXJkcy'
    '5EYXNoYm9hcmRSCmRhc2hib2FyZHM=');

@$core.Deprecated('Use dashboardListRequestDescriptor instead')
const DashboardListRequest$json = {
  '1': 'DashboardListRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
  ],
};

/// Descriptor for `DashboardListRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List dashboardListRequestDescriptor = $convert.base64Decode(
    'ChREYXNoYm9hcmRMaXN0UmVxdWVzdBIhCgx3b3Jrc3BhY2VfaWQYASABKAlSC3dvcmtzcGFjZU'
    'lkEh0KCnByb2plY3RfaWQYAiABKAlSCXByb2plY3RJZA==');

@$core.Deprecated('Use dashboardSaveRequestDescriptor instead')
const DashboardSaveRequest$json = {
  '1': 'DashboardSaveRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'id', '3': 2, '4': 1, '5': 9, '10': 'id'},
    {'1': 'name', '3': 3, '4': 1, '5': 9, '10': 'name'},
    {'1': 'visibility', '3': 4, '4': 1, '5': 9, '10': 'visibility'},
    {'1': 'project_id', '3': 5, '4': 1, '5': 9, '10': 'projectId'},
    {
      '1': 'widgets',
      '3': 6,
      '4': 3,
      '5': 11,
      '6': '.config.dashboards.WidgetInput',
      '10': 'widgets'
    },
    {'1': 'layout_json', '3': 7, '4': 1, '5': 9, '10': 'layoutJson'},
    {'1': 'expected_version', '3': 8, '4': 1, '5': 5, '10': 'expectedVersion'},
  ],
};

/// Descriptor for `DashboardSaveRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List dashboardSaveRequestDescriptor = $convert.base64Decode(
    'ChREYXNoYm9hcmRTYXZlUmVxdWVzdBIhCgx3b3Jrc3BhY2VfaWQYASABKAlSC3dvcmtzcGFjZU'
    'lkEg4KAmlkGAIgASgJUgJpZBISCgRuYW1lGAMgASgJUgRuYW1lEh4KCnZpc2liaWxpdHkYBCAB'
    'KAlSCnZpc2liaWxpdHkSHQoKcHJvamVjdF9pZBgFIAEoCVIJcHJvamVjdElkEjgKB3dpZGdldH'
    'MYBiADKAsyHi5jb25maWcuZGFzaGJvYXJkcy5XaWRnZXRJbnB1dFIHd2lkZ2V0cxIfCgtsYXlv'
    'dXRfanNvbhgHIAEoCVIKbGF5b3V0SnNvbhIpChBleHBlY3RlZF92ZXJzaW9uGAggASgFUg9leH'
    'BlY3RlZFZlcnNpb24=');

@$core.Deprecated('Use drillTaskDescriptor instead')
const DrillTask$json = {
  '1': 'DrillTask',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'display_id', '3': 3, '4': 1, '5': 9, '10': 'displayId'},
    {'1': 'title', '3': 4, '4': 1, '5': 9, '10': 'title'},
    {'1': 'status_name', '3': 5, '4': 1, '5': 9, '10': 'statusName'},
    {'1': 'status_category', '3': 6, '4': 1, '5': 9, '10': 'statusCategory'},
    {'1': 'priority', '3': 7, '4': 1, '5': 9, '10': 'priority'},
    {'1': 'due_date', '3': 8, '4': 1, '5': 9, '10': 'dueDate'},
    {'1': 'points', '3': 9, '4': 1, '5': 9, '10': 'points'},
    {'1': 'assignee_ids', '3': 10, '4': 3, '5': 9, '10': 'assigneeIds'},
  ],
};

/// Descriptor for `DrillTask`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List drillTaskDescriptor = $convert.base64Decode(
    'CglEcmlsbFRhc2sSDgoCaWQYASABKAlSAmlkEh0KCnByb2plY3RfaWQYAiABKAlSCXByb2plY3'
    'RJZBIdCgpkaXNwbGF5X2lkGAMgASgJUglkaXNwbGF5SWQSFAoFdGl0bGUYBCABKAlSBXRpdGxl'
    'Eh8KC3N0YXR1c19uYW1lGAUgASgJUgpzdGF0dXNOYW1lEicKD3N0YXR1c19jYXRlZ29yeRgGIA'
    'EoCVIOc3RhdHVzQ2F0ZWdvcnkSGgoIcHJpb3JpdHkYByABKAlSCHByaW9yaXR5EhkKCGR1ZV9k'
    'YXRlGAggASgJUgdkdWVEYXRlEhYKBnBvaW50cxgJIAEoCVIGcG9pbnRzEiEKDGFzc2lnbmVlX2'
    'lkcxgKIAMoCVILYXNzaWduZWVJZHM=');

@$core.Deprecated('Use drilledTaskDescriptor instead')
const DrilledTask$json = {
  '1': 'DrilledTask',
  '2': [
    {
      '1': 'task',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.config.dashboards.DrillTask',
      '10': 'task'
    },
    {'1': 'truncated', '3': 2, '4': 1, '5': 8, '10': 'truncated'},
  ],
};

/// Descriptor for `DrilledTask`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List drilledTaskDescriptor = $convert.base64Decode(
    'CgtEcmlsbGVkVGFzaxIwCgR0YXNrGAEgASgLMhwuY29uZmlnLmRhc2hib2FyZHMuRHJpbGxUYX'
    'NrUgR0YXNrEhwKCXRydW5jYXRlZBgCIAEoCFIJdHJ1bmNhdGVk');

@$core.Deprecated('Use pointDescriptor instead')
const Point$json = {
  '1': 'Point',
  '2': [
    {'1': 'x', '3': 1, '4': 1, '5': 9, '10': 'x'},
    {'1': 'y', '3': 2, '4': 1, '5': 9, '10': 'y'},
  ],
};

/// Descriptor for `Point`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pointDescriptor =
    $convert.base64Decode('CgVQb2ludBIMCgF4GAEgASgJUgF4EgwKAXkYAiABKAlSAXk=');

@$core.Deprecated('Use seriesDescriptor instead')
const Series$json = {
  '1': 'Series',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    {
      '1': 'points',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.config.dashboards.Point',
      '10': 'points'
    },
  ],
};

/// Descriptor for `Series`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List seriesDescriptor = $convert.base64Decode(
    'CgZTZXJpZXMSEgoEbmFtZRgBIAEoCVIEbmFtZRIwCgZwb2ludHMYAiADKAsyGC5jb25maWcuZG'
    'FzaGJvYXJkcy5Qb2ludFIGcG9pbnRz');

@$core.Deprecated('Use widgetDescriptor instead')
const Widget$json = {
  '1': 'Widget',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'type', '3': 2, '4': 1, '5': 9, '10': 'type'},
    {'1': 'title', '3': 3, '4': 1, '5': 9, '10': 'title'},
    {'1': 'config_json', '3': 4, '4': 1, '5': 9, '10': 'configJson'},
    {'1': 'version', '3': 5, '4': 1, '5': 5, '10': 'version'},
  ],
};

/// Descriptor for `Widget`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List widgetDescriptor = $convert.base64Decode(
    'CgZXaWRnZXQSDgoCaWQYASABKAlSAmlkEhIKBHR5cGUYAiABKAlSBHR5cGUSFAoFdGl0bGUYAy'
    'ABKAlSBXRpdGxlEh8KC2NvbmZpZ19qc29uGAQgASgJUgpjb25maWdKc29uEhgKB3ZlcnNpb24Y'
    'BSABKAVSB3ZlcnNpb24=');

@$core.Deprecated('Use widgetDataDescriptor instead')
const WidgetData$json = {
  '1': 'WidgetData',
  '2': [
    {'1': 'widget_id', '3': 1, '4': 1, '5': 9, '10': 'widgetId'},
    {'1': 'total', '3': 2, '4': 1, '5': 9, '10': 'total'},
    {
      '1': 'buckets',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.config.dashboards.Bucket',
      '10': 'buckets'
    },
    {
      '1': 'series',
      '3': 4,
      '4': 3,
      '5': 11,
      '6': '.config.dashboards.Series',
      '10': 'series'
    },
    {'1': 'truncated', '3': 5, '4': 1, '5': 8, '10': 'truncated'},
    {'1': 'computed_at', '3': 6, '4': 1, '5': 9, '10': 'computedAt'},
    {'1': 'cached', '3': 7, '4': 1, '5': 8, '10': 'cached'},
  ],
};

/// Descriptor for `WidgetData`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List widgetDataDescriptor = $convert.base64Decode(
    'CgpXaWRnZXREYXRhEhsKCXdpZGdldF9pZBgBIAEoCVIId2lkZ2V0SWQSFAoFdG90YWwYAiABKA'
    'lSBXRvdGFsEjMKB2J1Y2tldHMYAyADKAsyGS5jb25maWcuZGFzaGJvYXJkcy5CdWNrZXRSB2J1'
    'Y2tldHMSMQoGc2VyaWVzGAQgAygLMhkuY29uZmlnLmRhc2hib2FyZHMuU2VyaWVzUgZzZXJpZX'
    'MSHAoJdHJ1bmNhdGVkGAUgASgIUgl0cnVuY2F0ZWQSHwoLY29tcHV0ZWRfYXQYBiABKAlSCmNv'
    'bXB1dGVkQXQSFgoGY2FjaGVkGAcgASgIUgZjYWNoZWQ=');

@$core.Deprecated('Use widgetDataRequestDescriptor instead')
const WidgetDataRequest$json = {
  '1': 'WidgetDataRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'widget_id', '3': 2, '4': 1, '5': 9, '10': 'widgetId'},
    {'1': 'today', '3': 3, '4': 1, '5': 9, '10': 'today'},
    {
      '1': 'utc_offset_minutes',
      '3': 4,
      '4': 1,
      '5': 5,
      '10': 'utcOffsetMinutes'
    },
    {'1': 'refresh', '3': 5, '4': 1, '5': 8, '10': 'refresh'},
  ],
};

/// Descriptor for `WidgetDataRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List widgetDataRequestDescriptor = $convert.base64Decode(
    'ChFXaWRnZXREYXRhUmVxdWVzdBIhCgx3b3Jrc3BhY2VfaWQYASABKAlSC3dvcmtzcGFjZUlkEh'
    'sKCXdpZGdldF9pZBgCIAEoCVIId2lkZ2V0SWQSFAoFdG9kYXkYAyABKAlSBXRvZGF5EiwKEnV0'
    'Y19vZmZzZXRfbWludXRlcxgEIAEoBVIQdXRjT2Zmc2V0TWludXRlcxIYCgdyZWZyZXNoGAUgAS'
    'gIUgdyZWZyZXNo');

@$core.Deprecated('Use widgetDrilldownRequestDescriptor instead')
const WidgetDrilldownRequest$json = {
  '1': 'WidgetDrilldownRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'widget_id', '3': 2, '4': 1, '5': 9, '10': 'widgetId'},
    {'1': 'bucket', '3': 3, '4': 1, '5': 9, '10': 'bucket'},
    {'1': 'today', '3': 4, '4': 1, '5': 9, '10': 'today'},
    {
      '1': 'utc_offset_minutes',
      '3': 5,
      '4': 1,
      '5': 5,
      '10': 'utcOffsetMinutes'
    },
  ],
};

/// Descriptor for `WidgetDrilldownRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List widgetDrilldownRequestDescriptor = $convert.base64Decode(
    'ChZXaWRnZXREcmlsbGRvd25SZXF1ZXN0EiEKDHdvcmtzcGFjZV9pZBgBIAEoCVILd29ya3NwYW'
    'NlSWQSGwoJd2lkZ2V0X2lkGAIgASgJUgh3aWRnZXRJZBIWCgZidWNrZXQYAyABKAlSBmJ1Y2tl'
    'dBIUCgV0b2RheRgEIAEoCVIFdG9kYXkSLAoSdXRjX29mZnNldF9taW51dGVzGAUgASgFUhB1dG'
    'NPZmZzZXRNaW51dGVz');

@$core.Deprecated('Use widgetExportDescriptor instead')
const WidgetExport$json = {
  '1': 'WidgetExport',
  '2': [
    {'1': 'csv', '3': 1, '4': 1, '5': 9, '10': 'csv'},
  ],
};

/// Descriptor for `WidgetExport`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List widgetExportDescriptor =
    $convert.base64Decode('CgxXaWRnZXRFeHBvcnQSEAoDY3N2GAEgASgJUgNjc3Y=');

@$core.Deprecated('Use widgetExportRequestDescriptor instead')
const WidgetExportRequest$json = {
  '1': 'WidgetExportRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'widget_id', '3': 2, '4': 1, '5': 9, '10': 'widgetId'},
    {'1': 'today', '3': 3, '4': 1, '5': 9, '10': 'today'},
    {
      '1': 'utc_offset_minutes',
      '3': 4,
      '4': 1,
      '5': 5,
      '10': 'utcOffsetMinutes'
    },
  ],
};

/// Descriptor for `WidgetExportRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List widgetExportRequestDescriptor = $convert.base64Decode(
    'ChNXaWRnZXRFeHBvcnRSZXF1ZXN0EiEKDHdvcmtzcGFjZV9pZBgBIAEoCVILd29ya3NwYWNlSW'
    'QSGwoJd2lkZ2V0X2lkGAIgASgJUgh3aWRnZXRJZBIUCgV0b2RheRgDIAEoCVIFdG9kYXkSLAoS'
    'dXRjX29mZnNldF9taW51dGVzGAQgASgFUhB1dGNPZmZzZXRNaW51dGVz');

@$core.Deprecated('Use widgetInputDescriptor instead')
const WidgetInput$json = {
  '1': 'WidgetInput',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'type', '3': 2, '4': 1, '5': 9, '10': 'type'},
    {'1': 'title', '3': 3, '4': 1, '5': 9, '10': 'title'},
    {'1': 'config_json', '3': 4, '4': 1, '5': 9, '10': 'configJson'},
  ],
};

/// Descriptor for `WidgetInput`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List widgetInputDescriptor = $convert.base64Decode(
    'CgtXaWRnZXRJbnB1dBIOCgJpZBgBIAEoCVICaWQSEgoEdHlwZRgCIAEoCVIEdHlwZRIUCgV0aX'
    'RsZRgDIAEoCVIFdGl0bGUSHwoLY29uZmlnX2pzb24YBCABKAlSCmNvbmZpZ0pzb24=');

@$core.Deprecated('Use widgetPreviewRequestDescriptor instead')
const WidgetPreviewRequest$json = {
  '1': 'WidgetPreviewRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'type', '3': 3, '4': 1, '5': 9, '10': 'type'},
    {'1': 'config_json', '3': 4, '4': 1, '5': 9, '10': 'configJson'},
    {'1': 'today', '3': 5, '4': 1, '5': 9, '10': 'today'},
    {
      '1': 'utc_offset_minutes',
      '3': 6,
      '4': 1,
      '5': 5,
      '10': 'utcOffsetMinutes'
    },
  ],
};

/// Descriptor for `WidgetPreviewRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List widgetPreviewRequestDescriptor = $convert.base64Decode(
    'ChRXaWRnZXRQcmV2aWV3UmVxdWVzdBIhCgx3b3Jrc3BhY2VfaWQYASABKAlSC3dvcmtzcGFjZU'
    'lkEh0KCnByb2plY3RfaWQYAiABKAlSCXByb2plY3RJZBISCgR0eXBlGAMgASgJUgR0eXBlEh8K'
    'C2NvbmZpZ19qc29uGAQgASgJUgpjb25maWdKc29uEhQKBXRvZGF5GAUgASgJUgV0b2RheRIsCh'
    'J1dGNfb2Zmc2V0X21pbnV0ZXMYBiABKAVSEHV0Y09mZnNldE1pbnV0ZXM=');
