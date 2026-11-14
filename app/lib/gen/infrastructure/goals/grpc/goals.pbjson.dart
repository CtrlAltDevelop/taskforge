// This is a generated file - do not edit.
//
// Generated from infrastructure/goals/grpc/goals.proto.

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

@$core.Deprecated('Use checkInDescriptor instead')
const CheckIn$json = {
  '1': 'CheckIn',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'kr_id', '3': 2, '4': 1, '5': 9, '10': 'krId'},
    {'1': 'user_id', '3': 3, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'value', '3': 4, '4': 1, '5': 9, '10': 'value'},
    {'1': 'previous_value', '3': 5, '4': 1, '5': 9, '10': 'previousValue'},
    {'1': 'progress', '3': 6, '4': 1, '5': 2, '10': 'progress'},
    {'1': 'note', '3': 7, '4': 1, '5': 9, '10': 'note'},
    {'1': 'at', '3': 8, '4': 1, '5': 9, '10': 'at'},
  ],
};

/// Descriptor for `CheckIn`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List checkInDescriptor = $convert.base64Decode(
    'CgdDaGVja0luEg4KAmlkGAEgASgJUgJpZBITCgVrcl9pZBgCIAEoCVIEa3JJZBIXCgd1c2VyX2'
    'lkGAMgASgJUgZ1c2VySWQSFAoFdmFsdWUYBCABKAlSBXZhbHVlEiUKDnByZXZpb3VzX3ZhbHVl'
    'GAUgASgJUg1wcmV2aW91c1ZhbHVlEhoKCHByb2dyZXNzGAYgASgCUghwcm9ncmVzcxISCgRub3'
    'RlGAcgASgJUgRub3RlEg4KAmF0GAggASgJUgJhdA==');

@$core.Deprecated('Use checkInAddRequestDescriptor instead')
const CheckInAddRequest$json = {
  '1': 'CheckInAddRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'kr_id', '3': 2, '4': 1, '5': 9, '10': 'krId'},
    {'1': 'value', '3': 3, '4': 1, '5': 9, '10': 'value'},
    {'1': 'note', '3': 4, '4': 1, '5': 9, '10': 'note'},
  ],
};

/// Descriptor for `CheckInAddRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List checkInAddRequestDescriptor = $convert.base64Decode(
    'ChFDaGVja0luQWRkUmVxdWVzdBIhCgx3b3Jrc3BhY2VfaWQYASABKAlSC3dvcmtzcGFjZUlkEh'
    'MKBWtyX2lkGAIgASgJUgRrcklkEhQKBXZhbHVlGAMgASgJUgV2YWx1ZRISCgRub3RlGAQgASgJ'
    'UgRub3Rl');

@$core.Deprecated('Use checkInAnswerDescriptor instead')
const CheckInAnswer$json = {
  '1': 'CheckInAnswer',
  '2': [
    {
      '1': 'check_in',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.config.goals.CheckIn',
      '10': 'checkIn'
    },
    {
      '1': 'goal',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.config.goals.Goal',
      '10': 'goal'
    },
  ],
};

/// Descriptor for `CheckInAnswer`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List checkInAnswerDescriptor = $convert.base64Decode(
    'Cg1DaGVja0luQW5zd2VyEjAKCGNoZWNrX2luGAEgASgLMhUuY29uZmlnLmdvYWxzLkNoZWNrSW'
    '5SB2NoZWNrSW4SJgoEZ29hbBgCIAEoCzISLmNvbmZpZy5nb2Fscy5Hb2FsUgRnb2Fs');

@$core.Deprecated('Use checkInListDescriptor instead')
const CheckInList$json = {
  '1': 'CheckInList',
  '2': [
    {
      '1': 'check_ins',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.config.goals.CheckIn',
      '10': 'checkIns'
    },
  ],
};

/// Descriptor for `CheckInList`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List checkInListDescriptor = $convert.base64Decode(
    'CgtDaGVja0luTGlzdBIyCgljaGVja19pbnMYASADKAsyFS5jb25maWcuZ29hbHMuQ2hlY2tJbl'
    'IIY2hlY2tJbnM=');

@$core.Deprecated('Use checkInListRequestDescriptor instead')
const CheckInListRequest$json = {
  '1': 'CheckInListRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'kr_id', '3': 2, '4': 1, '5': 9, '10': 'krId'},
    {'1': 'limit', '3': 3, '4': 1, '5': 5, '10': 'limit'},
  ],
};

/// Descriptor for `CheckInListRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List checkInListRequestDescriptor = $convert.base64Decode(
    'ChJDaGVja0luTGlzdFJlcXVlc3QSIQoMd29ya3NwYWNlX2lkGAEgASgJUgt3b3Jrc3BhY2VJZB'
    'ITCgVrcl9pZBgCIAEoCVIEa3JJZBIUCgVsaW1pdBgDIAEoBVIFbGltaXQ=');

@$core.Deprecated('Use contributionDescriptor instead')
const Contribution$json = {
  '1': 'Contribution',
  '2': [
    {'1': 'goal_id', '3': 1, '4': 1, '5': 9, '10': 'goalId'},
    {'1': 'goal_name', '3': 2, '4': 1, '5': 9, '10': 'goalName'},
    {'1': 'kr_id', '3': 3, '4': 1, '5': 9, '10': 'krId'},
    {'1': 'kr_name', '3': 4, '4': 1, '5': 9, '10': 'krName'},
  ],
};

/// Descriptor for `Contribution`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List contributionDescriptor = $convert.base64Decode(
    'CgxDb250cmlidXRpb24SFwoHZ29hbF9pZBgBIAEoCVIGZ29hbElkEhsKCWdvYWxfbmFtZRgCIA'
    'EoCVIIZ29hbE5hbWUSEwoFa3JfaWQYAyABKAlSBGtySWQSFwoHa3JfbmFtZRgEIAEoCVIGa3JO'
    'YW1l');

@$core.Deprecated('Use folderDescriptor instead')
const Folder$json = {
  '1': 'Folder',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'position', '3': 3, '4': 1, '5': 5, '10': 'position'},
  ],
};

/// Descriptor for `Folder`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List folderDescriptor = $convert.base64Decode(
    'CgZGb2xkZXISDgoCaWQYASABKAlSAmlkEhIKBG5hbWUYAiABKAlSBG5hbWUSGgoIcG9zaXRpb2'
    '4YAyABKAVSCHBvc2l0aW9u');

@$core.Deprecated('Use folderAnswerDescriptor instead')
const FolderAnswer$json = {
  '1': 'FolderAnswer',
  '2': [
    {
      '1': 'folder',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.config.goals.Folder',
      '10': 'folder'
    },
  ],
};

/// Descriptor for `FolderAnswer`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List folderAnswerDescriptor = $convert.base64Decode(
    'CgxGb2xkZXJBbnN3ZXISLAoGZm9sZGVyGAEgASgLMhQuY29uZmlnLmdvYWxzLkZvbGRlclIGZm'
    '9sZGVy');

@$core.Deprecated('Use folderDeleteRequestDescriptor instead')
const FolderDeleteRequest$json = {
  '1': 'FolderDeleteRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'folder_id', '3': 2, '4': 1, '5': 9, '10': 'folderId'},
  ],
};

/// Descriptor for `FolderDeleteRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List folderDeleteRequestDescriptor = $convert.base64Decode(
    'ChNGb2xkZXJEZWxldGVSZXF1ZXN0EiEKDHdvcmtzcGFjZV9pZBgBIAEoCVILd29ya3NwYWNlSW'
    'QSGwoJZm9sZGVyX2lkGAIgASgJUghmb2xkZXJJZA==');

@$core.Deprecated('Use folderDeletedDescriptor instead')
const FolderDeleted$json = {
  '1': 'FolderDeleted',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `FolderDeleted`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List folderDeletedDescriptor =
    $convert.base64Decode('Cg1Gb2xkZXJEZWxldGVkEg4KAmlkGAEgASgJUgJpZA==');

@$core.Deprecated('Use folderSaveRequestDescriptor instead')
const FolderSaveRequest$json = {
  '1': 'FolderSaveRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'folder_id', '3': 2, '4': 1, '5': 9, '10': 'folderId'},
    {'1': 'name', '3': 3, '4': 1, '5': 9, '10': 'name'},
  ],
};

/// Descriptor for `FolderSaveRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List folderSaveRequestDescriptor = $convert.base64Decode(
    'ChFGb2xkZXJTYXZlUmVxdWVzdBIhCgx3b3Jrc3BhY2VfaWQYASABKAlSC3dvcmtzcGFjZUlkEh'
    'sKCWZvbGRlcl9pZBgCIAEoCVIIZm9sZGVySWQSEgoEbmFtZRgDIAEoCVIEbmFtZQ==');

@$core.Deprecated('Use forTaskListDescriptor instead')
const ForTaskList$json = {
  '1': 'ForTaskList',
  '2': [
    {
      '1': 'contributions',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.config.goals.Contribution',
      '10': 'contributions'
    },
  ],
};

/// Descriptor for `ForTaskList`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List forTaskListDescriptor = $convert.base64Decode(
    'CgtGb3JUYXNrTGlzdBJACg1jb250cmlidXRpb25zGAEgAygLMhouY29uZmlnLmdvYWxzLkNvbn'
    'RyaWJ1dGlvblINY29udHJpYnV0aW9ucw==');

@$core.Deprecated('Use forTaskRequestDescriptor instead')
const ForTaskRequest$json = {
  '1': 'ForTaskRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'task_id', '3': 2, '4': 1, '5': 9, '10': 'taskId'},
  ],
};

/// Descriptor for `ForTaskRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List forTaskRequestDescriptor = $convert.base64Decode(
    'Cg5Gb3JUYXNrUmVxdWVzdBIhCgx3b3Jrc3BhY2VfaWQYASABKAlSC3dvcmtzcGFjZUlkEhcKB3'
    'Rhc2tfaWQYAiABKAlSBnRhc2tJZA==');

@$core.Deprecated('Use goalDescriptor instead')
const Goal$json = {
  '1': 'Goal',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'workspace_id', '3': 2, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'parent_id', '3': 3, '4': 1, '5': 9, '10': 'parentId'},
    {'1': 'folder_id', '3': 4, '4': 1, '5': 9, '10': 'folderId'},
    {'1': 'name', '3': 5, '4': 1, '5': 9, '10': 'name'},
    {'1': 'description', '3': 6, '4': 1, '5': 9, '10': 'description'},
    {'1': 'owner_id', '3': 7, '4': 1, '5': 9, '10': 'ownerId'},
    {'1': 'private', '3': 8, '4': 1, '5': 8, '10': 'private'},
    {'1': 'period_start', '3': 9, '4': 1, '5': 9, '10': 'periodStart'},
    {'1': 'period_end', '3': 10, '4': 1, '5': 9, '10': 'periodEnd'},
    {'1': 'status_override', '3': 11, '4': 1, '5': 9, '10': 'statusOverride'},
    {'1': 'status', '3': 12, '4': 1, '5': 9, '10': 'status'},
    {'1': 'status_hint', '3': 13, '4': 1, '5': 9, '10': 'statusHint'},
    {'1': 'weight', '3': 14, '4': 1, '5': 9, '10': 'weight'},
    {'1': 'progress', '3': 15, '4': 1, '5': 2, '10': 'progress'},
    {'1': 'version', '3': 16, '4': 1, '5': 5, '10': 'version'},
    {'1': 'can_edit', '3': 17, '4': 1, '5': 8, '10': 'canEdit'},
    {'1': 'can_check_in', '3': 18, '4': 1, '5': 8, '10': 'canCheckIn'},
    {'1': 'contributor_ids', '3': 19, '4': 3, '5': 9, '10': 'contributorIds'},
    {'1': 'child_ids', '3': 20, '4': 3, '5': 9, '10': 'childIds'},
    {
      '1': 'key_results',
      '3': 21,
      '4': 3,
      '5': 11,
      '6': '.config.goals.KeyResult',
      '10': 'keyResults'
    },
    {'1': 'created_at', '3': 22, '4': 1, '5': 9, '10': 'createdAt'},
  ],
};

/// Descriptor for `Goal`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List goalDescriptor = $convert.base64Decode(
    'CgRHb2FsEg4KAmlkGAEgASgJUgJpZBIhCgx3b3Jrc3BhY2VfaWQYAiABKAlSC3dvcmtzcGFjZU'
    'lkEhsKCXBhcmVudF9pZBgDIAEoCVIIcGFyZW50SWQSGwoJZm9sZGVyX2lkGAQgASgJUghmb2xk'
    'ZXJJZBISCgRuYW1lGAUgASgJUgRuYW1lEiAKC2Rlc2NyaXB0aW9uGAYgASgJUgtkZXNjcmlwdG'
    'lvbhIZCghvd25lcl9pZBgHIAEoCVIHb3duZXJJZBIYCgdwcml2YXRlGAggASgIUgdwcml2YXRl'
    'EiEKDHBlcmlvZF9zdGFydBgJIAEoCVILcGVyaW9kU3RhcnQSHQoKcGVyaW9kX2VuZBgKIAEoCV'
    'IJcGVyaW9kRW5kEicKD3N0YXR1c19vdmVycmlkZRgLIAEoCVIOc3RhdHVzT3ZlcnJpZGUSFgoG'
    'c3RhdHVzGAwgASgJUgZzdGF0dXMSHwoLc3RhdHVzX2hpbnQYDSABKAlSCnN0YXR1c0hpbnQSFg'
    'oGd2VpZ2h0GA4gASgJUgZ3ZWlnaHQSGgoIcHJvZ3Jlc3MYDyABKAJSCHByb2dyZXNzEhgKB3Zl'
    'cnNpb24YECABKAVSB3ZlcnNpb24SGQoIY2FuX2VkaXQYESABKAhSB2NhbkVkaXQSIAoMY2FuX2'
    'NoZWNrX2luGBIgASgIUgpjYW5DaGVja0luEicKD2NvbnRyaWJ1dG9yX2lkcxgTIAMoCVIOY29u'
    'dHJpYnV0b3JJZHMSGwoJY2hpbGRfaWRzGBQgAygJUghjaGlsZElkcxI4CgtrZXlfcmVzdWx0cx'
    'gVIAMoCzIXLmNvbmZpZy5nb2Fscy5LZXlSZXN1bHRSCmtleVJlc3VsdHMSHQoKY3JlYXRlZF9h'
    'dBgWIAEoCVIJY3JlYXRlZEF0');

@$core.Deprecated('Use goalAnswerDescriptor instead')
const GoalAnswer$json = {
  '1': 'GoalAnswer',
  '2': [
    {
      '1': 'goal',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.config.goals.Goal',
      '10': 'goal'
    },
  ],
};

/// Descriptor for `GoalAnswer`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List goalAnswerDescriptor = $convert.base64Decode(
    'CgpHb2FsQW5zd2VyEiYKBGdvYWwYASABKAsyEi5jb25maWcuZ29hbHMuR29hbFIEZ29hbA==');

@$core.Deprecated('Use goalCreateRequestDescriptor instead')
const GoalCreateRequest$json = {
  '1': 'GoalCreateRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'description', '3': 3, '4': 1, '5': 9, '10': 'description'},
    {'1': 'owner_id', '3': 4, '4': 1, '5': 9, '10': 'ownerId'},
    {'1': 'parent_id', '3': 5, '4': 1, '5': 9, '10': 'parentId'},
    {'1': 'folder_id', '3': 6, '4': 1, '5': 9, '10': 'folderId'},
    {'1': 'private', '3': 7, '4': 1, '5': 8, '10': 'private'},
    {'1': 'period_start', '3': 8, '4': 1, '5': 9, '10': 'periodStart'},
    {'1': 'period_end', '3': 9, '4': 1, '5': 9, '10': 'periodEnd'},
    {'1': 'status_override', '3': 10, '4': 1, '5': 9, '10': 'statusOverride'},
    {'1': 'weight', '3': 11, '4': 1, '5': 9, '10': 'weight'},
    {'1': 'contributor_ids', '3': 12, '4': 3, '5': 9, '10': 'contributorIds'},
  ],
};

/// Descriptor for `GoalCreateRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List goalCreateRequestDescriptor = $convert.base64Decode(
    'ChFHb2FsQ3JlYXRlUmVxdWVzdBIhCgx3b3Jrc3BhY2VfaWQYASABKAlSC3dvcmtzcGFjZUlkEh'
    'IKBG5hbWUYAiABKAlSBG5hbWUSIAoLZGVzY3JpcHRpb24YAyABKAlSC2Rlc2NyaXB0aW9uEhkK'
    'CG93bmVyX2lkGAQgASgJUgdvd25lcklkEhsKCXBhcmVudF9pZBgFIAEoCVIIcGFyZW50SWQSGw'
    'oJZm9sZGVyX2lkGAYgASgJUghmb2xkZXJJZBIYCgdwcml2YXRlGAcgASgIUgdwcml2YXRlEiEK'
    'DHBlcmlvZF9zdGFydBgIIAEoCVILcGVyaW9kU3RhcnQSHQoKcGVyaW9kX2VuZBgJIAEoCVIJcG'
    'VyaW9kRW5kEicKD3N0YXR1c19vdmVycmlkZRgKIAEoCVIOc3RhdHVzT3ZlcnJpZGUSFgoGd2Vp'
    'Z2h0GAsgASgJUgZ3ZWlnaHQSJwoPY29udHJpYnV0b3JfaWRzGAwgAygJUg5jb250cmlidXRvck'
    'lkcw==');

@$core.Deprecated('Use goalDeleteRequestDescriptor instead')
const GoalDeleteRequest$json = {
  '1': 'GoalDeleteRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'goal_id', '3': 2, '4': 1, '5': 9, '10': 'goalId'},
  ],
};

/// Descriptor for `GoalDeleteRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List goalDeleteRequestDescriptor = $convert.base64Decode(
    'ChFHb2FsRGVsZXRlUmVxdWVzdBIhCgx3b3Jrc3BhY2VfaWQYASABKAlSC3dvcmtzcGFjZUlkEh'
    'cKB2dvYWxfaWQYAiABKAlSBmdvYWxJZA==');

@$core.Deprecated('Use goalDeletedDescriptor instead')
const GoalDeleted$json = {
  '1': 'GoalDeleted',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `GoalDeleted`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List goalDeletedDescriptor =
    $convert.base64Decode('CgtHb2FsRGVsZXRlZBIOCgJpZBgBIAEoCVICaWQ=');

@$core.Deprecated('Use goalGetRequestDescriptor instead')
const GoalGetRequest$json = {
  '1': 'GoalGetRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'goal_id', '3': 2, '4': 1, '5': 9, '10': 'goalId'},
  ],
};

/// Descriptor for `GoalGetRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List goalGetRequestDescriptor = $convert.base64Decode(
    'Cg5Hb2FsR2V0UmVxdWVzdBIhCgx3b3Jrc3BhY2VfaWQYASABKAlSC3dvcmtzcGFjZUlkEhcKB2'
    'dvYWxfaWQYAiABKAlSBmdvYWxJZA==');

@$core.Deprecated('Use goalListDescriptor instead')
const GoalList$json = {
  '1': 'GoalList',
  '2': [
    {
      '1': 'goals',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.config.goals.Goal',
      '10': 'goals'
    },
    {
      '1': 'folders',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.config.goals.Folder',
      '10': 'folders'
    },
  ],
};

/// Descriptor for `GoalList`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List goalListDescriptor = $convert.base64Decode(
    'CghHb2FsTGlzdBIoCgVnb2FscxgBIAMoCzISLmNvbmZpZy5nb2Fscy5Hb2FsUgVnb2FscxIuCg'
    'dmb2xkZXJzGAIgAygLMhQuY29uZmlnLmdvYWxzLkZvbGRlclIHZm9sZGVycw==');

@$core.Deprecated('Use goalListRequestDescriptor instead')
const GoalListRequest$json = {
  '1': 'GoalListRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
  ],
};

/// Descriptor for `GoalListRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List goalListRequestDescriptor = $convert.base64Decode(
    'Cg9Hb2FsTGlzdFJlcXVlc3QSIQoMd29ya3NwYWNlX2lkGAEgASgJUgt3b3Jrc3BhY2VJZA==');

@$core.Deprecated('Use goalUpdateRequestDescriptor instead')
const GoalUpdateRequest$json = {
  '1': 'GoalUpdateRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'goal_id', '3': 2, '4': 1, '5': 9, '10': 'goalId'},
    {'1': 'changed', '3': 3, '4': 3, '5': 9, '10': 'changed'},
    {'1': 'expected_version', '3': 4, '4': 1, '5': 5, '10': 'expectedVersion'},
    {'1': 'name', '3': 5, '4': 1, '5': 9, '10': 'name'},
    {'1': 'description', '3': 6, '4': 1, '5': 9, '10': 'description'},
    {'1': 'owner_id', '3': 7, '4': 1, '5': 9, '10': 'ownerId'},
    {'1': 'parent_id', '3': 8, '4': 1, '5': 9, '10': 'parentId'},
    {'1': 'folder_id', '3': 9, '4': 1, '5': 9, '10': 'folderId'},
    {'1': 'private', '3': 10, '4': 1, '5': 8, '10': 'private'},
    {'1': 'period_start', '3': 11, '4': 1, '5': 9, '10': 'periodStart'},
    {'1': 'period_end', '3': 12, '4': 1, '5': 9, '10': 'periodEnd'},
    {'1': 'status_override', '3': 13, '4': 1, '5': 9, '10': 'statusOverride'},
    {'1': 'weight', '3': 14, '4': 1, '5': 9, '10': 'weight'},
    {'1': 'contributor_ids', '3': 15, '4': 3, '5': 9, '10': 'contributorIds'},
  ],
};

/// Descriptor for `GoalUpdateRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List goalUpdateRequestDescriptor = $convert.base64Decode(
    'ChFHb2FsVXBkYXRlUmVxdWVzdBIhCgx3b3Jrc3BhY2VfaWQYASABKAlSC3dvcmtzcGFjZUlkEh'
    'cKB2dvYWxfaWQYAiABKAlSBmdvYWxJZBIYCgdjaGFuZ2VkGAMgAygJUgdjaGFuZ2VkEikKEGV4'
    'cGVjdGVkX3ZlcnNpb24YBCABKAVSD2V4cGVjdGVkVmVyc2lvbhISCgRuYW1lGAUgASgJUgRuYW'
    '1lEiAKC2Rlc2NyaXB0aW9uGAYgASgJUgtkZXNjcmlwdGlvbhIZCghvd25lcl9pZBgHIAEoCVIH'
    'b3duZXJJZBIbCglwYXJlbnRfaWQYCCABKAlSCHBhcmVudElkEhsKCWZvbGRlcl9pZBgJIAEoCV'
    'IIZm9sZGVySWQSGAoHcHJpdmF0ZRgKIAEoCFIHcHJpdmF0ZRIhCgxwZXJpb2Rfc3RhcnQYCyAB'
    'KAlSC3BlcmlvZFN0YXJ0Eh0KCnBlcmlvZF9lbmQYDCABKAlSCXBlcmlvZEVuZBInCg9zdGF0dX'
    'Nfb3ZlcnJpZGUYDSABKAlSDnN0YXR1c092ZXJyaWRlEhYKBndlaWdodBgOIAEoCVIGd2VpZ2h0'
    'EicKD2NvbnRyaWJ1dG9yX2lkcxgPIAMoCVIOY29udHJpYnV0b3JJZHM=');

@$core.Deprecated('Use keyResultDescriptor instead')
const KeyResult$json = {
  '1': 'KeyResult',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'goal_id', '3': 2, '4': 1, '5': 9, '10': 'goalId'},
    {'1': 'name', '3': 3, '4': 1, '5': 9, '10': 'name'},
    {'1': 'type', '3': 4, '4': 1, '5': 9, '10': 'type'},
    {'1': 'start_value', '3': 5, '4': 1, '5': 9, '10': 'startValue'},
    {'1': 'target_value', '3': 6, '4': 1, '5': 9, '10': 'targetValue'},
    {'1': 'current_value', '3': 7, '4': 1, '5': 9, '10': 'currentValue'},
    {'1': 'filter_text', '3': 8, '4': 1, '5': 9, '10': 'filterText'},
    {'1': 'task_ids', '3': 9, '4': 3, '5': 9, '10': 'taskIds'},
    {'1': 'weight', '3': 10, '4': 1, '5': 9, '10': 'weight'},
    {'1': 'linked_done', '3': 11, '4': 1, '5': 5, '10': 'linkedDone'},
    {'1': 'linked_total', '3': 12, '4': 1, '5': 5, '10': 'linkedTotal'},
    {'1': 'progress', '3': 13, '4': 1, '5': 2, '10': 'progress'},
    {'1': 'position', '3': 14, '4': 1, '5': 5, '10': 'position'},
    {'1': 'version', '3': 15, '4': 1, '5': 5, '10': 'version'},
  ],
};

/// Descriptor for `KeyResult`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List keyResultDescriptor = $convert.base64Decode(
    'CglLZXlSZXN1bHQSDgoCaWQYASABKAlSAmlkEhcKB2dvYWxfaWQYAiABKAlSBmdvYWxJZBISCg'
    'RuYW1lGAMgASgJUgRuYW1lEhIKBHR5cGUYBCABKAlSBHR5cGUSHwoLc3RhcnRfdmFsdWUYBSAB'
    'KAlSCnN0YXJ0VmFsdWUSIQoMdGFyZ2V0X3ZhbHVlGAYgASgJUgt0YXJnZXRWYWx1ZRIjCg1jdX'
    'JyZW50X3ZhbHVlGAcgASgJUgxjdXJyZW50VmFsdWUSHwoLZmlsdGVyX3RleHQYCCABKAlSCmZp'
    'bHRlclRleHQSGQoIdGFza19pZHMYCSADKAlSB3Rhc2tJZHMSFgoGd2VpZ2h0GAogASgJUgZ3ZW'
    'lnaHQSHwoLbGlua2VkX2RvbmUYCyABKAVSCmxpbmtlZERvbmUSIQoMbGlua2VkX3RvdGFsGAwg'
    'ASgFUgtsaW5rZWRUb3RhbBIaCghwcm9ncmVzcxgNIAEoAlIIcHJvZ3Jlc3MSGgoIcG9zaXRpb2'
    '4YDiABKAVSCHBvc2l0aW9uEhgKB3ZlcnNpb24YDyABKAVSB3ZlcnNpb24=');

@$core.Deprecated('Use keyResultCreateRequestDescriptor instead')
const KeyResultCreateRequest$json = {
  '1': 'KeyResultCreateRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'goal_id', '3': 2, '4': 1, '5': 9, '10': 'goalId'},
    {'1': 'type', '3': 3, '4': 1, '5': 9, '10': 'type'},
    {'1': 'current_value', '3': 4, '4': 1, '5': 9, '10': 'currentValue'},
    {'1': 'name', '3': 5, '4': 1, '5': 9, '10': 'name'},
    {'1': 'start_value', '3': 6, '4': 1, '5': 9, '10': 'startValue'},
    {'1': 'target_value', '3': 7, '4': 1, '5': 9, '10': 'targetValue'},
    {'1': 'weight', '3': 8, '4': 1, '5': 9, '10': 'weight'},
    {'1': 'filter_text', '3': 9, '4': 1, '5': 9, '10': 'filterText'},
    {'1': 'task_ids', '3': 10, '4': 3, '5': 9, '10': 'taskIds'},
    {'1': 'position', '3': 11, '4': 1, '5': 5, '10': 'position'},
  ],
};

/// Descriptor for `KeyResultCreateRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List keyResultCreateRequestDescriptor = $convert.base64Decode(
    'ChZLZXlSZXN1bHRDcmVhdGVSZXF1ZXN0EiEKDHdvcmtzcGFjZV9pZBgBIAEoCVILd29ya3NwYW'
    'NlSWQSFwoHZ29hbF9pZBgCIAEoCVIGZ29hbElkEhIKBHR5cGUYAyABKAlSBHR5cGUSIwoNY3Vy'
    'cmVudF92YWx1ZRgEIAEoCVIMY3VycmVudFZhbHVlEhIKBG5hbWUYBSABKAlSBG5hbWUSHwoLc3'
    'RhcnRfdmFsdWUYBiABKAlSCnN0YXJ0VmFsdWUSIQoMdGFyZ2V0X3ZhbHVlGAcgASgJUgt0YXJn'
    'ZXRWYWx1ZRIWCgZ3ZWlnaHQYCCABKAlSBndlaWdodBIfCgtmaWx0ZXJfdGV4dBgJIAEoCVIKZm'
    'lsdGVyVGV4dBIZCgh0YXNrX2lkcxgKIAMoCVIHdGFza0lkcxIaCghwb3NpdGlvbhgLIAEoBVII'
    'cG9zaXRpb24=');

@$core.Deprecated('Use keyResultDeleteRequestDescriptor instead')
const KeyResultDeleteRequest$json = {
  '1': 'KeyResultDeleteRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'kr_id', '3': 2, '4': 1, '5': 9, '10': 'krId'},
  ],
};

/// Descriptor for `KeyResultDeleteRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List keyResultDeleteRequestDescriptor =
    $convert.base64Decode(
        'ChZLZXlSZXN1bHREZWxldGVSZXF1ZXN0EiEKDHdvcmtzcGFjZV9pZBgBIAEoCVILd29ya3NwYW'
        'NlSWQSEwoFa3JfaWQYAiABKAlSBGtySWQ=');

@$core.Deprecated('Use keyResultUpdateRequestDescriptor instead')
const KeyResultUpdateRequest$json = {
  '1': 'KeyResultUpdateRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'kr_id', '3': 2, '4': 1, '5': 9, '10': 'krId'},
    {'1': 'changed', '3': 3, '4': 3, '5': 9, '10': 'changed'},
    {'1': 'expected_version', '3': 4, '4': 1, '5': 5, '10': 'expectedVersion'},
    {'1': 'name', '3': 5, '4': 1, '5': 9, '10': 'name'},
    {'1': 'start_value', '3': 6, '4': 1, '5': 9, '10': 'startValue'},
    {'1': 'target_value', '3': 7, '4': 1, '5': 9, '10': 'targetValue'},
    {'1': 'weight', '3': 8, '4': 1, '5': 9, '10': 'weight'},
    {'1': 'filter_text', '3': 9, '4': 1, '5': 9, '10': 'filterText'},
    {'1': 'task_ids', '3': 10, '4': 3, '5': 9, '10': 'taskIds'},
    {'1': 'position', '3': 11, '4': 1, '5': 5, '10': 'position'},
  ],
};

/// Descriptor for `KeyResultUpdateRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List keyResultUpdateRequestDescriptor = $convert.base64Decode(
    'ChZLZXlSZXN1bHRVcGRhdGVSZXF1ZXN0EiEKDHdvcmtzcGFjZV9pZBgBIAEoCVILd29ya3NwYW'
    'NlSWQSEwoFa3JfaWQYAiABKAlSBGtySWQSGAoHY2hhbmdlZBgDIAMoCVIHY2hhbmdlZBIpChBl'
    'eHBlY3RlZF92ZXJzaW9uGAQgASgFUg9leHBlY3RlZFZlcnNpb24SEgoEbmFtZRgFIAEoCVIEbm'
    'FtZRIfCgtzdGFydF92YWx1ZRgGIAEoCVIKc3RhcnRWYWx1ZRIhCgx0YXJnZXRfdmFsdWUYByAB'
    'KAlSC3RhcmdldFZhbHVlEhYKBndlaWdodBgIIAEoCVIGd2VpZ2h0Eh8KC2ZpbHRlcl90ZXh0GA'
    'kgASgJUgpmaWx0ZXJUZXh0EhkKCHRhc2tfaWRzGAogAygJUgd0YXNrSWRzEhoKCHBvc2l0aW9u'
    'GAsgASgFUghwb3NpdGlvbg==');
