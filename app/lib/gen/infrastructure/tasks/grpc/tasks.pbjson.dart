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
    'Fs');

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
  ],
};

/// Descriptor for `TaskCreateRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List taskCreateRequestDescriptor = $convert.base64Decode(
    'ChFUYXNrQ3JlYXRlUmVxdWVzdBIhCgx3b3Jrc3BhY2VfaWQYASABKAlSC3dvcmtzcGFjZUlkEh'
    '0KCnByb2plY3RfaWQYAiABKAlSCXByb2plY3RJZBIUCgV0aXRsZRgDIAEoCVIFdGl0bGUSIAoL'
    'ZGVzY3JpcHRpb24YBCABKAlSC2Rlc2NyaXB0aW9uEhYKBnN0YXR1cxgFIAEoCVIGc3RhdHVzEh'
    'oKCHByaW9yaXR5GAYgASgJUghwcmlvcml0eRIdCgpzdGFydF9kYXRlGAcgASgJUglzdGFydERh'
    'dGUSGQoIZHVlX2RhdGUYCCABKAlSB2R1ZURhdGUSIQoMYXNzaWduZWVfaWRzGAkgAygJUgthc3'
    'NpZ25lZUlkcxIbCglwYXJlbnRfaWQYCiABKAlSCHBhcmVudElk');

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
  ],
};

/// Descriptor for `TaskListRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List taskListRequestDescriptor = $convert.base64Decode(
    'Cg9UYXNrTGlzdFJlcXVlc3QSIQoMd29ya3NwYWNlX2lkGAEgASgJUgt3b3Jrc3BhY2VJZBIdCg'
    'pwcm9qZWN0X2lkGAIgASgJUglwcm9qZWN0SWQSFgoGc3RhdHVzGAMgASgJUgZzdGF0dXMSHwoL'
    'YXNzaWduZWVfaWQYBCABKAlSCmFzc2lnbmVlSWQSFgoGY3Vyc29yGAUgASgJUgZjdXJzb3ISGw'
    'oJcGFnZV9zaXplGAYgASgFUghwYWdlU2l6ZRIpChBpbmNsdWRlX3N1YnRhc2tzGAcgASgIUg9p'
    'bmNsdWRlU3VidGFza3M=');

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
  ],
};

/// Descriptor for `TaskMoveRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List taskMoveRequestDescriptor = $convert.base64Decode(
    'Cg9UYXNrTW92ZVJlcXVlc3QSIQoMd29ya3NwYWNlX2lkGAEgASgJUgt3b3Jrc3BhY2VJZBIdCg'
    'pwcm9qZWN0X2lkGAIgASgJUglwcm9qZWN0SWQSDgoCaWQYAyABKAlSAmlkEikKEGV4cGVjdGVk'
    'X3ZlcnNpb24YBCABKAVSD2V4cGVjdGVkVmVyc2lvbhIWCgZzdGF0dXMYBSABKAlSBnN0YXR1cx'
    'IpChBpbmNsdWRlX3N1YnRhc2tzGAYgASgIUg9pbmNsdWRlU3VidGFza3M=');

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
  ],
  '8': [
    {'1': '_title'},
    {'1': '_description'},
    {'1': '_status'},
    {'1': '_priority'},
    {'1': '_start_date'},
    {'1': '_due_date'},
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
    'VfaWRzGAwgAygJUgthc3NpZ25lZUlkc0IICgZfdGl0bGVCDgoMX2Rlc2NyaXB0aW9uQgkKB19z'
    'dGF0dXNCCwoJX3ByaW9yaXR5Qg0KC19zdGFydF9kYXRlQgsKCV9kdWVfZGF0ZQ==');
