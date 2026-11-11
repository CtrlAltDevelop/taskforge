// This is a generated file - do not edit.
//
// Generated from infrastructure/inbox/grpc/inbox.proto.

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

@$core.Deprecated('Use archiveRequestDescriptor instead')
const ArchiveRequest$json = {
  '1': 'ArchiveRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'ids', '3': 2, '4': 3, '5': 9, '10': 'ids'},
    {'1': 'archived', '3': 3, '4': 1, '5': 8, '10': 'archived'},
  ],
};

/// Descriptor for `ArchiveRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List archiveRequestDescriptor = $convert.base64Decode(
    'Cg5BcmNoaXZlUmVxdWVzdBIhCgx3b3Jrc3BhY2VfaWQYASABKAlSC3dvcmtzcGFjZUlkEhAKA2'
    'lkcxgCIAMoCVIDaWRzEhoKCGFyY2hpdmVkGAMgASgIUghhcmNoaXZlZA==');

@$core.Deprecated('Use deviceAnswerDescriptor instead')
const DeviceAnswer$json = {
  '1': 'DeviceAnswer',
  '2': [
    {'1': 'registered', '3': 1, '4': 1, '5': 8, '10': 'registered'},
  ],
};

/// Descriptor for `DeviceAnswer`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deviceAnswerDescriptor = $convert.base64Decode(
    'CgxEZXZpY2VBbnN3ZXISHgoKcmVnaXN0ZXJlZBgBIAEoCFIKcmVnaXN0ZXJlZA==');

@$core.Deprecated('Use deviceRegisterRequestDescriptor instead')
const DeviceRegisterRequest$json = {
  '1': 'DeviceRegisterRequest',
  '2': [
    {'1': 'platform', '3': 1, '4': 1, '5': 9, '10': 'platform'},
    {'1': 'token', '3': 2, '4': 1, '5': 9, '10': 'token'},
  ],
};

/// Descriptor for `DeviceRegisterRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deviceRegisterRequestDescriptor = $convert.base64Decode(
    'ChVEZXZpY2VSZWdpc3RlclJlcXVlc3QSGgoIcGxhdGZvcm0YASABKAlSCHBsYXRmb3JtEhQKBX'
    'Rva2VuGAIgASgJUgV0b2tlbg==');

@$core.Deprecated('Use deviceUnregisterRequestDescriptor instead')
const DeviceUnregisterRequest$json = {
  '1': 'DeviceUnregisterRequest',
  '2': [
    {'1': 'token', '3': 1, '4': 1, '5': 9, '10': 'token'},
  ],
};

/// Descriptor for `DeviceUnregisterRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deviceUnregisterRequestDescriptor =
    $convert.base64Decode(
        'ChdEZXZpY2VVbnJlZ2lzdGVyUmVxdWVzdBIUCgV0b2tlbhgBIAEoCVIFdG9rZW4=');

@$core.Deprecated('Use inboxListRequestDescriptor instead')
const InboxListRequest$json = {
  '1': 'InboxListRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'filter', '3': 2, '4': 1, '5': 9, '10': 'filter'},
    {'1': 'before', '3': 3, '4': 1, '5': 9, '10': 'before'},
    {'1': 'page_size', '3': 4, '4': 1, '5': 5, '10': 'pageSize'},
  ],
};

/// Descriptor for `InboxListRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List inboxListRequestDescriptor = $convert.base64Decode(
    'ChBJbmJveExpc3RSZXF1ZXN0EiEKDHdvcmtzcGFjZV9pZBgBIAEoCVILd29ya3NwYWNlSWQSFg'
    'oGZmlsdGVyGAIgASgJUgZmaWx0ZXISFgoGYmVmb3JlGAMgASgJUgZiZWZvcmUSGwoJcGFnZV9z'
    'aXplGAQgASgFUghwYWdlU2l6ZQ==');

@$core.Deprecated('Use inboxPageDescriptor instead')
const InboxPage$json = {
  '1': 'InboxPage',
  '2': [
    {
      '1': 'notifications',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.config.inbox.Notification',
      '10': 'notifications'
    },
    {'1': 'cursor', '3': 2, '4': 1, '5': 9, '10': 'cursor'},
    {'1': 'unread_count', '3': 3, '4': 1, '5': 5, '10': 'unreadCount'},
  ],
};

/// Descriptor for `InboxPage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List inboxPageDescriptor = $convert.base64Decode(
    'CglJbmJveFBhZ2USQAoNbm90aWZpY2F0aW9ucxgBIAMoCzIaLmNvbmZpZy5pbmJveC5Ob3RpZm'
    'ljYXRpb25SDW5vdGlmaWNhdGlvbnMSFgoGY3Vyc29yGAIgASgJUgZjdXJzb3ISIQoMdW5yZWFk'
    'X2NvdW50GAMgASgFUgt1bnJlYWRDb3VudA==');

@$core.Deprecated('Use inboxSettingsDescriptor instead')
const InboxSettings$json = {
  '1': 'InboxSettings',
  '2': [
    {'1': 'timezone', '3': 1, '4': 1, '5': 9, '10': 'timezone'},
    {'1': 'quiet_start', '3': 2, '4': 1, '5': 9, '10': 'quietStart'},
    {'1': 'quiet_end', '3': 3, '4': 1, '5': 9, '10': 'quietEnd'},
    {'1': 'digest_hour', '3': 4, '4': 1, '5': 5, '10': 'digestHour'},
  ],
};

/// Descriptor for `InboxSettings`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List inboxSettingsDescriptor = $convert.base64Decode(
    'Cg1JbmJveFNldHRpbmdzEhoKCHRpbWV6b25lGAEgASgJUgh0aW1lem9uZRIfCgtxdWlldF9zdG'
    'FydBgCIAEoCVIKcXVpZXRTdGFydBIbCglxdWlldF9lbmQYAyABKAlSCHF1aWV0RW5kEh8KC2Rp'
    'Z2VzdF9ob3VyGAQgASgFUgpkaWdlc3RIb3Vy');

@$core.Deprecated('Use markReadRequestDescriptor instead')
const MarkReadRequest$json = {
  '1': 'MarkReadRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'ids', '3': 2, '4': 3, '5': 9, '10': 'ids'},
    {'1': 'all', '3': 3, '4': 1, '5': 8, '10': 'all'},
    {'1': 'read', '3': 4, '4': 1, '5': 8, '10': 'read'},
  ],
};

/// Descriptor for `MarkReadRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List markReadRequestDescriptor = $convert.base64Decode(
    'Cg9NYXJrUmVhZFJlcXVlc3QSIQoMd29ya3NwYWNlX2lkGAEgASgJUgt3b3Jrc3BhY2VJZBIQCg'
    'NpZHMYAiADKAlSA2lkcxIQCgNhbGwYAyABKAhSA2FsbBISCgRyZWFkGAQgASgIUgRyZWFk');

@$core.Deprecated('Use notificationDescriptor instead')
const Notification$json = {
  '1': 'Notification',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'workspace_id', '3': 2, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'type', '3': 3, '4': 1, '5': 9, '10': 'type'},
    {'1': 'task_id', '3': 4, '4': 1, '5': 9, '10': 'taskId'},
    {'1': 'project_id', '3': 5, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'actor_id', '3': 6, '4': 1, '5': 9, '10': 'actorId'},
    {'1': 'actor_name', '3': 7, '4': 1, '5': 9, '10': 'actorName'},
    {'1': 'payload', '3': 8, '4': 1, '5': 9, '10': 'payload'},
    {'1': 'count', '3': 9, '4': 1, '5': 5, '10': 'count'},
    {'1': 'created_at', '3': 10, '4': 1, '5': 9, '10': 'createdAt'},
    {'1': 'updated_at', '3': 11, '4': 1, '5': 9, '10': 'updatedAt'},
    {'1': 'read_at', '3': 12, '4': 1, '5': 9, '10': 'readAt'},
    {'1': 'snoozed_until', '3': 13, '4': 1, '5': 9, '10': 'snoozedUntil'},
    {'1': 'archived_at', '3': 14, '4': 1, '5': 9, '10': 'archivedAt'},
  ],
};

/// Descriptor for `Notification`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List notificationDescriptor = $convert.base64Decode(
    'CgxOb3RpZmljYXRpb24SDgoCaWQYASABKAlSAmlkEiEKDHdvcmtzcGFjZV9pZBgCIAEoCVILd2'
    '9ya3NwYWNlSWQSEgoEdHlwZRgDIAEoCVIEdHlwZRIXCgd0YXNrX2lkGAQgASgJUgZ0YXNrSWQS'
    'HQoKcHJvamVjdF9pZBgFIAEoCVIJcHJvamVjdElkEhkKCGFjdG9yX2lkGAYgASgJUgdhY3Rvck'
    'lkEh0KCmFjdG9yX25hbWUYByABKAlSCWFjdG9yTmFtZRIYCgdwYXlsb2FkGAggASgJUgdwYXls'
    'b2FkEhQKBWNvdW50GAkgASgFUgVjb3VudBIdCgpjcmVhdGVkX2F0GAogASgJUgljcmVhdGVkQX'
    'QSHQoKdXBkYXRlZF9hdBgLIAEoCVIJdXBkYXRlZEF0EhcKB3JlYWRfYXQYDCABKAlSBnJlYWRB'
    'dBIjCg1zbm9vemVkX3VudGlsGA0gASgJUgxzbm9vemVkVW50aWwSHwoLYXJjaGl2ZWRfYXQYDi'
    'ABKAlSCmFyY2hpdmVkQXQ=');

@$core.Deprecated('Use prefRowDescriptor instead')
const PrefRow$json = {
  '1': 'PrefRow',
  '2': [
    {'1': 'event_type', '3': 1, '4': 1, '5': 9, '10': 'eventType'},
    {'1': 'label', '3': 2, '4': 1, '5': 9, '10': 'label'},
    {'1': 'inbox', '3': 3, '4': 1, '5': 8, '10': 'inbox'},
    {'1': 'push', '3': 4, '4': 1, '5': 8, '10': 'push'},
    {'1': 'email_mode', '3': 5, '4': 1, '5': 9, '10': 'emailMode'},
  ],
};

/// Descriptor for `PrefRow`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List prefRowDescriptor = $convert.base64Decode(
    'CgdQcmVmUm93Eh0KCmV2ZW50X3R5cGUYASABKAlSCWV2ZW50VHlwZRIUCgVsYWJlbBgCIAEoCV'
    'IFbGFiZWwSFAoFaW5ib3gYAyABKAhSBWluYm94EhIKBHB1c2gYBCABKAhSBHB1c2gSHQoKZW1h'
    'aWxfbW9kZRgFIAEoCVIJZW1haWxNb2Rl');

@$core.Deprecated('Use prefSetRequestDescriptor instead')
const PrefSetRequest$json = {
  '1': 'PrefSetRequest',
  '2': [
    {'1': 'event_type', '3': 1, '4': 1, '5': 9, '10': 'eventType'},
    {'1': 'inbox', '3': 2, '4': 1, '5': 8, '10': 'inbox'},
    {'1': 'push', '3': 3, '4': 1, '5': 8, '10': 'push'},
    {'1': 'email_mode', '3': 4, '4': 1, '5': 9, '10': 'emailMode'},
  ],
};

/// Descriptor for `PrefSetRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List prefSetRequestDescriptor = $convert.base64Decode(
    'Cg5QcmVmU2V0UmVxdWVzdBIdCgpldmVudF90eXBlGAEgASgJUglldmVudFR5cGUSFAoFaW5ib3'
    'gYAiABKAhSBWluYm94EhIKBHB1c2gYAyABKAhSBHB1c2gSHQoKZW1haWxfbW9kZRgEIAEoCVIJ'
    'ZW1haWxNb2Rl');

@$core.Deprecated('Use prefsAnswerDescriptor instead')
const PrefsAnswer$json = {
  '1': 'PrefsAnswer',
  '2': [
    {
      '1': 'prefs',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.config.inbox.PrefRow',
      '10': 'prefs'
    },
    {
      '1': 'settings',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.config.inbox.InboxSettings',
      '10': 'settings'
    },
  ],
};

/// Descriptor for `PrefsAnswer`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List prefsAnswerDescriptor = $convert.base64Decode(
    'CgtQcmVmc0Fuc3dlchIrCgVwcmVmcxgBIAMoCzIVLmNvbmZpZy5pbmJveC5QcmVmUm93UgVwcm'
    'VmcxI3CghzZXR0aW5ncxgCIAEoCzIbLmNvbmZpZy5pbmJveC5JbmJveFNldHRpbmdzUghzZXR0'
    'aW5ncw==');

@$core.Deprecated('Use prefsGetRequestDescriptor instead')
const PrefsGetRequest$json = {
  '1': 'PrefsGetRequest',
};

/// Descriptor for `PrefsGetRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List prefsGetRequestDescriptor =
    $convert.base64Decode('Cg9QcmVmc0dldFJlcXVlc3Q=');

@$core.Deprecated('Use settingsSetRequestDescriptor instead')
const SettingsSetRequest$json = {
  '1': 'SettingsSetRequest',
  '2': [
    {'1': 'timezone', '3': 1, '4': 1, '5': 9, '10': 'timezone'},
    {'1': 'quiet_start', '3': 2, '4': 1, '5': 9, '10': 'quietStart'},
    {'1': 'quiet_end', '3': 3, '4': 1, '5': 9, '10': 'quietEnd'},
    {'1': 'digest_hour', '3': 4, '4': 1, '5': 5, '10': 'digestHour'},
  ],
};

/// Descriptor for `SettingsSetRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List settingsSetRequestDescriptor = $convert.base64Decode(
    'ChJTZXR0aW5nc1NldFJlcXVlc3QSGgoIdGltZXpvbmUYASABKAlSCHRpbWV6b25lEh8KC3F1aW'
    'V0X3N0YXJ0GAIgASgJUgpxdWlldFN0YXJ0EhsKCXF1aWV0X2VuZBgDIAEoCVIIcXVpZXRFbmQS'
    'HwoLZGlnZXN0X2hvdXIYBCABKAVSCmRpZ2VzdEhvdXI=');

@$core.Deprecated('Use snoozeRequestDescriptor instead')
const SnoozeRequest$json = {
  '1': 'SnoozeRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'id', '3': 2, '4': 1, '5': 9, '10': 'id'},
    {'1': 'until', '3': 3, '4': 1, '5': 9, '10': 'until'},
  ],
};

/// Descriptor for `SnoozeRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List snoozeRequestDescriptor = $convert.base64Decode(
    'Cg1Tbm9vemVSZXF1ZXN0EiEKDHdvcmtzcGFjZV9pZBgBIAEoCVILd29ya3NwYWNlSWQSDgoCaW'
    'QYAiABKAlSAmlkEhQKBXVudGlsGAMgASgJUgV1bnRpbA==');

@$core.Deprecated('Use unreadCountRequestDescriptor instead')
const UnreadCountRequest$json = {
  '1': 'UnreadCountRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
  ],
};

/// Descriptor for `UnreadCountRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List unreadCountRequestDescriptor = $convert.base64Decode(
    'ChJVbnJlYWRDb3VudFJlcXVlc3QSIQoMd29ya3NwYWNlX2lkGAEgASgJUgt3b3Jrc3BhY2VJZA'
    '==');

@$core.Deprecated('Use unreadTotalDescriptor instead')
const UnreadTotal$json = {
  '1': 'UnreadTotal',
  '2': [
    {'1': 'count', '3': 1, '4': 1, '5': 5, '10': 'count'},
  ],
};

/// Descriptor for `UnreadTotal`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List unreadTotalDescriptor =
    $convert.base64Decode('CgtVbnJlYWRUb3RhbBIUCgVjb3VudBgBIAEoBVIFY291bnQ=');

@$core.Deprecated('Use watchAddRequestDescriptor instead')
const WatchAddRequest$json = {
  '1': 'WatchAddRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'task_id', '3': 3, '4': 1, '5': 9, '10': 'taskId'},
  ],
};

/// Descriptor for `WatchAddRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List watchAddRequestDescriptor = $convert.base64Decode(
    'Cg9XYXRjaEFkZFJlcXVlc3QSIQoMd29ya3NwYWNlX2lkGAEgASgJUgt3b3Jrc3BhY2VJZBIdCg'
    'pwcm9qZWN0X2lkGAIgASgJUglwcm9qZWN0SWQSFwoHdGFza19pZBgDIAEoCVIGdGFza0lk');

@$core.Deprecated('Use watchGetRequestDescriptor instead')
const WatchGetRequest$json = {
  '1': 'WatchGetRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'task_id', '3': 3, '4': 1, '5': 9, '10': 'taskId'},
  ],
};

/// Descriptor for `WatchGetRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List watchGetRequestDescriptor = $convert.base64Decode(
    'Cg9XYXRjaEdldFJlcXVlc3QSIQoMd29ya3NwYWNlX2lkGAEgASgJUgt3b3Jrc3BhY2VJZBIdCg'
    'pwcm9qZWN0X2lkGAIgASgJUglwcm9qZWN0SWQSFwoHdGFza19pZBgDIAEoCVIGdGFza0lk');

@$core.Deprecated('Use watchRemoveRequestDescriptor instead')
const WatchRemoveRequest$json = {
  '1': 'WatchRemoveRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'task_id', '3': 3, '4': 1, '5': 9, '10': 'taskId'},
  ],
};

/// Descriptor for `WatchRemoveRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List watchRemoveRequestDescriptor = $convert.base64Decode(
    'ChJXYXRjaFJlbW92ZVJlcXVlc3QSIQoMd29ya3NwYWNlX2lkGAEgASgJUgt3b3Jrc3BhY2VJZB'
    'IdCgpwcm9qZWN0X2lkGAIgASgJUglwcm9qZWN0SWQSFwoHdGFza19pZBgDIAEoCVIGdGFza0lk');

@$core.Deprecated('Use watchStateDescriptor instead')
const WatchState$json = {
  '1': 'WatchState',
  '2': [
    {'1': 'watching', '3': 1, '4': 1, '5': 8, '10': 'watching'},
    {'1': 'watcher_count', '3': 2, '4': 1, '5': 5, '10': 'watcherCount'},
  ],
};

/// Descriptor for `WatchState`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List watchStateDescriptor = $convert.base64Decode(
    'CgpXYXRjaFN0YXRlEhoKCHdhdGNoaW5nGAEgASgIUgh3YXRjaGluZxIjCg13YXRjaGVyX2NvdW'
    '50GAIgASgFUgx3YXRjaGVyQ291bnQ=');
