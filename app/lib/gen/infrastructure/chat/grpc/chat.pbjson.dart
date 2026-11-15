// This is a generated file - do not edit.
//
// Generated from infrastructure/chat/grpc/chat.proto.

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

@$core.Deprecated('Use chatAddMembersRequestDescriptor instead')
const ChatAddMembersRequest$json = {
  '1': 'ChatAddMembersRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'space_id', '3': 2, '4': 1, '5': 9, '10': 'spaceId'},
    {'1': 'user_ids', '3': 3, '4': 3, '5': 9, '10': 'userIds'},
  ],
};

/// Descriptor for `ChatAddMembersRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List chatAddMembersRequestDescriptor = $convert.base64Decode(
    'ChVDaGF0QWRkTWVtYmVyc1JlcXVlc3QSIQoMd29ya3NwYWNlX2lkGAEgASgJUgt3b3Jrc3BhY2'
    'VJZBIZCghzcGFjZV9pZBgCIAEoCVIHc3BhY2VJZBIZCgh1c2VyX2lkcxgDIAMoCVIHdXNlcklk'
    'cw==');

@$core.Deprecated('Use chatCreateSpaceRequestDescriptor instead')
const ChatCreateSpaceRequest$json = {
  '1': 'ChatCreateSpaceRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'kind', '3': 2, '4': 1, '5': 9, '10': 'kind'},
    {'1': 'name', '3': 3, '4': 1, '5': 9, '10': 'name'},
    {'1': 'member_ids', '3': 4, '4': 3, '5': 9, '10': 'memberIds'},
  ],
};

/// Descriptor for `ChatCreateSpaceRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List chatCreateSpaceRequestDescriptor = $convert.base64Decode(
    'ChZDaGF0Q3JlYXRlU3BhY2VSZXF1ZXN0EiEKDHdvcmtzcGFjZV9pZBgBIAEoCVILd29ya3NwYW'
    'NlSWQSEgoEa2luZBgCIAEoCVIEa2luZBISCgRuYW1lGAMgASgJUgRuYW1lEh0KCm1lbWJlcl9p'
    'ZHMYBCADKAlSCW1lbWJlcklkcw==');

@$core.Deprecated('Use chatDeleteRequestDescriptor instead')
const ChatDeleteRequest$json = {
  '1': 'ChatDeleteRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'space_id', '3': 2, '4': 1, '5': 9, '10': 'spaceId'},
    {'1': 'id', '3': 3, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `ChatDeleteRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List chatDeleteRequestDescriptor = $convert.base64Decode(
    'ChFDaGF0RGVsZXRlUmVxdWVzdBIhCgx3b3Jrc3BhY2VfaWQYASABKAlSC3dvcmtzcGFjZUlkEh'
    'kKCHNwYWNlX2lkGAIgASgJUgdzcGFjZUlkEg4KAmlkGAMgASgJUgJpZA==');

@$core.Deprecated('Use chatDoneDescriptor instead')
const ChatDone$json = {
  '1': 'ChatDone',
  '2': [
    {'1': 'ok', '3': 1, '4': 1, '5': 8, '10': 'ok'},
  ],
};

/// Descriptor for `ChatDone`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List chatDoneDescriptor =
    $convert.base64Decode('CghDaGF0RG9uZRIOCgJvaxgBIAEoCFICb2s=');

@$core.Deprecated('Use chatEditRequestDescriptor instead')
const ChatEditRequest$json = {
  '1': 'ChatEditRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'space_id', '3': 2, '4': 1, '5': 9, '10': 'spaceId'},
    {'1': 'id', '3': 3, '4': 1, '5': 9, '10': 'id'},
    {'1': 'expected_version', '3': 4, '4': 1, '5': 5, '10': 'expectedVersion'},
    {'1': 'body', '3': 5, '4': 1, '5': 9, '10': 'body'},
    {
      '1': 'confirm_broadcast',
      '3': 6,
      '4': 1,
      '5': 8,
      '10': 'confirmBroadcast'
    },
    {'1': 'grant_access', '3': 7, '4': 1, '5': 8, '10': 'grantAccess'},
  ],
};

/// Descriptor for `ChatEditRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List chatEditRequestDescriptor = $convert.base64Decode(
    'Cg9DaGF0RWRpdFJlcXVlc3QSIQoMd29ya3NwYWNlX2lkGAEgASgJUgt3b3Jrc3BhY2VJZBIZCg'
    'hzcGFjZV9pZBgCIAEoCVIHc3BhY2VJZBIOCgJpZBgDIAEoCVICaWQSKQoQZXhwZWN0ZWRfdmVy'
    'c2lvbhgEIAEoBVIPZXhwZWN0ZWRWZXJzaW9uEhIKBGJvZHkYBSABKAlSBGJvZHkSKwoRY29uZm'
    'lybV9icm9hZGNhc3QYBiABKAhSEGNvbmZpcm1Ccm9hZGNhc3QSIQoMZ3JhbnRfYWNjZXNzGAcg'
    'ASgIUgtncmFudEFjY2Vzcw==');

@$core.Deprecated('Use chatJoinRequestDescriptor instead')
const ChatJoinRequest$json = {
  '1': 'ChatJoinRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'space_id', '3': 2, '4': 1, '5': 9, '10': 'spaceId'},
  ],
};

/// Descriptor for `ChatJoinRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List chatJoinRequestDescriptor = $convert.base64Decode(
    'Cg9DaGF0Sm9pblJlcXVlc3QSIQoMd29ya3NwYWNlX2lkGAEgASgJUgt3b3Jrc3BhY2VJZBIZCg'
    'hzcGFjZV9pZBgCIAEoCVIHc3BhY2VJZA==');

@$core.Deprecated('Use chatLeaveRequestDescriptor instead')
const ChatLeaveRequest$json = {
  '1': 'ChatLeaveRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'space_id', '3': 2, '4': 1, '5': 9, '10': 'spaceId'},
  ],
};

/// Descriptor for `ChatLeaveRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List chatLeaveRequestDescriptor = $convert.base64Decode(
    'ChBDaGF0TGVhdmVSZXF1ZXN0EiEKDHdvcmtzcGFjZV9pZBgBIAEoCVILd29ya3NwYWNlSWQSGQ'
    'oIc3BhY2VfaWQYAiABKAlSB3NwYWNlSWQ=');

@$core.Deprecated('Use chatListMessagesRequestDescriptor instead')
const ChatListMessagesRequest$json = {
  '1': 'ChatListMessagesRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'space_id', '3': 2, '4': 1, '5': 9, '10': 'spaceId'},
    {'1': 'before', '3': 3, '4': 1, '5': 9, '10': 'before'},
    {'1': 'page_size', '3': 4, '4': 1, '5': 5, '10': 'pageSize'},
    {'1': 'thread_id', '3': 5, '4': 1, '5': 9, '10': 'threadId'},
  ],
};

/// Descriptor for `ChatListMessagesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List chatListMessagesRequestDescriptor = $convert.base64Decode(
    'ChdDaGF0TGlzdE1lc3NhZ2VzUmVxdWVzdBIhCgx3b3Jrc3BhY2VfaWQYASABKAlSC3dvcmtzcG'
    'FjZUlkEhkKCHNwYWNlX2lkGAIgASgJUgdzcGFjZUlkEhYKBmJlZm9yZRgDIAEoCVIGYmVmb3Jl'
    'EhsKCXBhZ2Vfc2l6ZRgEIAEoBVIIcGFnZVNpemUSGwoJdGhyZWFkX2lkGAUgASgJUgh0aHJlYW'
    'RJZA==');

@$core.Deprecated('Use chatListSpacesRequestDescriptor instead')
const ChatListSpacesRequest$json = {
  '1': 'ChatListSpacesRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'query', '3': 2, '4': 1, '5': 9, '10': 'query'},
    {'1': 'include_archived', '3': 3, '4': 1, '5': 8, '10': 'includeArchived'},
  ],
};

/// Descriptor for `ChatListSpacesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List chatListSpacesRequestDescriptor = $convert.base64Decode(
    'ChVDaGF0TGlzdFNwYWNlc1JlcXVlc3QSIQoMd29ya3NwYWNlX2lkGAEgASgJUgt3b3Jrc3BhY2'
    'VJZBIUCgVxdWVyeRgCIAEoCVIFcXVlcnkSKQoQaW5jbHVkZV9hcmNoaXZlZBgDIAEoCFIPaW5j'
    'bHVkZUFyY2hpdmVk');

@$core.Deprecated('Use chatMarkReadRequestDescriptor instead')
const ChatMarkReadRequest$json = {
  '1': 'ChatMarkReadRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'space_id', '3': 2, '4': 1, '5': 9, '10': 'spaceId'},
    {'1': 'message_id', '3': 3, '4': 1, '5': 9, '10': 'messageId'},
  ],
};

/// Descriptor for `ChatMarkReadRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List chatMarkReadRequestDescriptor = $convert.base64Decode(
    'ChNDaGF0TWFya1JlYWRSZXF1ZXN0EiEKDHdvcmtzcGFjZV9pZBgBIAEoCVILd29ya3NwYWNlSW'
    'QSGQoIc3BhY2VfaWQYAiABKAlSB3NwYWNlSWQSHQoKbWVzc2FnZV9pZBgDIAEoCVIJbWVzc2Fn'
    'ZUlk');

@$core.Deprecated('Use chatMentionableDescriptor instead')
const ChatMentionable$json = {
  '1': 'ChatMentionable',
  '2': [
    {
      '1': 'people',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.config.chat.Person',
      '10': 'people'
    },
    {'1': 'member_count', '3': 2, '4': 1, '5': 5, '10': 'memberCount'},
  ],
};

/// Descriptor for `ChatMentionable`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List chatMentionableDescriptor = $convert.base64Decode(
    'Cg9DaGF0TWVudGlvbmFibGUSKwoGcGVvcGxlGAEgAygLMhMuY29uZmlnLmNoYXQuUGVyc29uUg'
    'ZwZW9wbGUSIQoMbWVtYmVyX2NvdW50GAIgASgFUgttZW1iZXJDb3VudA==');

@$core.Deprecated('Use chatMentionableRequestDescriptor instead')
const ChatMentionableRequest$json = {
  '1': 'ChatMentionableRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'space_id', '3': 2, '4': 1, '5': 9, '10': 'spaceId'},
    {'1': 'query', '3': 3, '4': 1, '5': 9, '10': 'query'},
  ],
};

/// Descriptor for `ChatMentionableRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List chatMentionableRequestDescriptor = $convert.base64Decode(
    'ChZDaGF0TWVudGlvbmFibGVSZXF1ZXN0EiEKDHdvcmtzcGFjZV9pZBgBIAEoCVILd29ya3NwYW'
    'NlSWQSGQoIc3BhY2VfaWQYAiABKAlSB3NwYWNlSWQSFAoFcXVlcnkYAyABKAlSBXF1ZXJ5');

@$core.Deprecated('Use chatMessagePageDescriptor instead')
const ChatMessagePage$json = {
  '1': 'ChatMessagePage',
  '2': [
    {
      '1': 'messages',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.config.chat.Message',
      '10': 'messages'
    },
    {'1': 'cursor', '3': 2, '4': 1, '5': 9, '10': 'cursor'},
  ],
};

/// Descriptor for `ChatMessagePage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List chatMessagePageDescriptor = $convert.base64Decode(
    'Cg9DaGF0TWVzc2FnZVBhZ2USMAoIbWVzc2FnZXMYASADKAsyFC5jb25maWcuY2hhdC5NZXNzYW'
    'dlUghtZXNzYWdlcxIWCgZjdXJzb3IYAiABKAlSBmN1cnNvcg==');

@$core.Deprecated('Use chatMuteRequestDescriptor instead')
const ChatMuteRequest$json = {
  '1': 'ChatMuteRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'space_id', '3': 2, '4': 1, '5': 9, '10': 'spaceId'},
    {'1': 'until', '3': 3, '4': 1, '5': 9, '10': 'until'},
    {'1': 'forever', '3': 4, '4': 1, '5': 8, '10': 'forever'},
    {'1': 'completely', '3': 5, '4': 1, '5': 8, '10': 'completely'},
  ],
};

/// Descriptor for `ChatMuteRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List chatMuteRequestDescriptor = $convert.base64Decode(
    'Cg9DaGF0TXV0ZVJlcXVlc3QSIQoMd29ya3NwYWNlX2lkGAEgASgJUgt3b3Jrc3BhY2VJZBIZCg'
    'hzcGFjZV9pZBgCIAEoCVIHc3BhY2VJZBIUCgV1bnRpbBgDIAEoCVIFdW50aWwSGAoHZm9yZXZl'
    'chgEIAEoCFIHZm9yZXZlchIeCgpjb21wbGV0ZWx5GAUgASgIUgpjb21wbGV0ZWx5');

@$core.Deprecated('Use chatNotifyRequestDescriptor instead')
const ChatNotifyRequest$json = {
  '1': 'ChatNotifyRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'space_id', '3': 2, '4': 1, '5': 9, '10': 'spaceId'},
    {'1': 'all_messages', '3': 3, '4': 1, '5': 8, '10': 'allMessages'},
  ],
};

/// Descriptor for `ChatNotifyRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List chatNotifyRequestDescriptor = $convert.base64Decode(
    'ChFDaGF0Tm90aWZ5UmVxdWVzdBIhCgx3b3Jrc3BhY2VfaWQYASABKAlSC3dvcmtzcGFjZUlkEh'
    'kKCHNwYWNlX2lkGAIgASgJUgdzcGFjZUlkEiEKDGFsbF9tZXNzYWdlcxgDIAEoCFILYWxsTWVz'
    'c2FnZXM=');

@$core.Deprecated('Use chatOpenDmRequestDescriptor instead')
const ChatOpenDmRequest$json = {
  '1': 'ChatOpenDmRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'user_id', '3': 2, '4': 1, '5': 9, '10': 'userId'},
  ],
};

/// Descriptor for `ChatOpenDmRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List chatOpenDmRequestDescriptor = $convert.base64Decode(
    'ChFDaGF0T3BlbkRtUmVxdWVzdBIhCgx3b3Jrc3BhY2VfaWQYASABKAlSC3dvcmtzcGFjZUlkEh'
    'cKB3VzZXJfaWQYAiABKAlSBnVzZXJJZA==');

@$core.Deprecated('Use chatReactRequestDescriptor instead')
const ChatReactRequest$json = {
  '1': 'ChatReactRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'space_id', '3': 2, '4': 1, '5': 9, '10': 'spaceId'},
    {'1': 'id', '3': 3, '4': 1, '5': 9, '10': 'id'},
    {'1': 'emoji', '3': 4, '4': 1, '5': 9, '10': 'emoji'},
    {'1': 'on', '3': 5, '4': 1, '5': 8, '10': 'on'},
  ],
};

/// Descriptor for `ChatReactRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List chatReactRequestDescriptor = $convert.base64Decode(
    'ChBDaGF0UmVhY3RSZXF1ZXN0EiEKDHdvcmtzcGFjZV9pZBgBIAEoCVILd29ya3NwYWNlSWQSGQ'
    'oIc3BhY2VfaWQYAiABKAlSB3NwYWNlSWQSDgoCaWQYAyABKAlSAmlkEhQKBWVtb2ppGAQgASgJ'
    'UgVlbW9qaRIOCgJvbhgFIAEoCFICb24=');

@$core.Deprecated('Use chatRemoveMemberRequestDescriptor instead')
const ChatRemoveMemberRequest$json = {
  '1': 'ChatRemoveMemberRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'space_id', '3': 2, '4': 1, '5': 9, '10': 'spaceId'},
    {'1': 'user_id', '3': 3, '4': 1, '5': 9, '10': 'userId'},
  ],
};

/// Descriptor for `ChatRemoveMemberRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List chatRemoveMemberRequestDescriptor = $convert.base64Decode(
    'ChdDaGF0UmVtb3ZlTWVtYmVyUmVxdWVzdBIhCgx3b3Jrc3BhY2VfaWQYASABKAlSC3dvcmtzcG'
    'FjZUlkEhkKCHNwYWNlX2lkGAIgASgJUgdzcGFjZUlkEhcKB3VzZXJfaWQYAyABKAlSBnVzZXJJ'
    'ZA==');

@$core.Deprecated('Use chatSendRequestDescriptor instead')
const ChatSendRequest$json = {
  '1': 'ChatSendRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'space_id', '3': 2, '4': 1, '5': 9, '10': 'spaceId'},
    {'1': 'body', '3': 3, '4': 1, '5': 9, '10': 'body'},
    {'1': 'parent_id', '3': 4, '4': 1, '5': 9, '10': 'parentId'},
    {'1': 'client_id', '3': 5, '4': 1, '5': 9, '10': 'clientId'},
    {
      '1': 'client_mutation_id',
      '3': 6,
      '4': 1,
      '5': 9,
      '10': 'clientMutationId'
    },
    {
      '1': 'confirm_broadcast',
      '3': 7,
      '4': 1,
      '5': 8,
      '10': 'confirmBroadcast'
    },
    {'1': 'grant_access', '3': 8, '4': 1, '5': 8, '10': 'grantAccess'},
  ],
};

/// Descriptor for `ChatSendRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List chatSendRequestDescriptor = $convert.base64Decode(
    'Cg9DaGF0U2VuZFJlcXVlc3QSIQoMd29ya3NwYWNlX2lkGAEgASgJUgt3b3Jrc3BhY2VJZBIZCg'
    'hzcGFjZV9pZBgCIAEoCVIHc3BhY2VJZBISCgRib2R5GAMgASgJUgRib2R5EhsKCXBhcmVudF9p'
    'ZBgEIAEoCVIIcGFyZW50SWQSGwoJY2xpZW50X2lkGAUgASgJUghjbGllbnRJZBIsChJjbGllbn'
    'RfbXV0YXRpb25faWQYBiABKAlSEGNsaWVudE11dGF0aW9uSWQSKwoRY29uZmlybV9icm9hZGNh'
    'c3QYByABKAhSEGNvbmZpcm1Ccm9hZGNhc3QSIQoMZ3JhbnRfYWNjZXNzGAggASgIUgtncmFudE'
    'FjY2Vzcw==');

@$core.Deprecated('Use chatSpaceListDescriptor instead')
const ChatSpaceList$json = {
  '1': 'ChatSpaceList',
  '2': [
    {
      '1': 'channels',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.config.chat.Space',
      '10': 'channels'
    },
    {
      '1': 'groups',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.config.chat.Space',
      '10': 'groups'
    },
    {
      '1': 'dms',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.config.chat.Space',
      '10': 'dms'
    },
    {
      '1': 'task_chats',
      '3': 4,
      '4': 3,
      '5': 11,
      '6': '.config.chat.TaskChat',
      '10': 'taskChats'
    },
  ],
};

/// Descriptor for `ChatSpaceList`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List chatSpaceListDescriptor = $convert.base64Decode(
    'Cg1DaGF0U3BhY2VMaXN0Ei4KCGNoYW5uZWxzGAEgAygLMhIuY29uZmlnLmNoYXQuU3BhY2VSCG'
    'NoYW5uZWxzEioKBmdyb3VwcxgCIAMoCzISLmNvbmZpZy5jaGF0LlNwYWNlUgZncm91cHMSJAoD'
    'ZG1zGAMgAygLMhIuY29uZmlnLmNoYXQuU3BhY2VSA2RtcxI0Cgp0YXNrX2NoYXRzGAQgAygLMh'
    'UuY29uZmlnLmNoYXQuVGFza0NoYXRSCXRhc2tDaGF0cw==');

@$core.Deprecated('Use chatUpdateSpaceRequestDescriptor instead')
const ChatUpdateSpaceRequest$json = {
  '1': 'ChatUpdateSpaceRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'space_id', '3': 2, '4': 1, '5': 9, '10': 'spaceId'},
    {'1': 'name', '3': 3, '4': 1, '5': 9, '10': 'name'},
    {'1': 'set_archived', '3': 4, '4': 1, '5': 8, '10': 'setArchived'},
    {'1': 'archived', '3': 5, '4': 1, '5': 8, '10': 'archived'},
  ],
};

/// Descriptor for `ChatUpdateSpaceRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List chatUpdateSpaceRequestDescriptor = $convert.base64Decode(
    'ChZDaGF0VXBkYXRlU3BhY2VSZXF1ZXN0EiEKDHdvcmtzcGFjZV9pZBgBIAEoCVILd29ya3NwYW'
    'NlSWQSGQoIc3BhY2VfaWQYAiABKAlSB3NwYWNlSWQSEgoEbmFtZRgDIAEoCVIEbmFtZRIhCgxz'
    'ZXRfYXJjaGl2ZWQYBCABKAhSC3NldEFyY2hpdmVkEhoKCGFyY2hpdmVkGAUgASgIUghhcmNoaX'
    'ZlZA==');

@$core.Deprecated('Use messageDescriptor instead')
const Message$json = {
  '1': 'Message',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'space_id', '3': 2, '4': 1, '5': 9, '10': 'spaceId'},
    {'1': 'author_id', '3': 3, '4': 1, '5': 9, '10': 'authorId'},
    {'1': 'author_name', '3': 4, '4': 1, '5': 9, '10': 'authorName'},
    {'1': 'parent_id', '3': 5, '4': 1, '5': 9, '10': 'parentId'},
    {'1': 'body', '3': 6, '4': 1, '5': 9, '10': 'body'},
    {'1': 'created_at', '3': 7, '4': 1, '5': 9, '10': 'createdAt'},
    {'1': 'edited_at', '3': 8, '4': 1, '5': 9, '10': 'editedAt'},
    {'1': 'deleted', '3': 9, '4': 1, '5': 8, '10': 'deleted'},
    {'1': 'version', '3': 10, '4': 1, '5': 5, '10': 'version'},
    {
      '1': 'reactions',
      '3': 11,
      '4': 3,
      '5': 11,
      '6': '.config.chat.ReactionResponse',
      '10': 'reactions'
    },
  ],
};

/// Descriptor for `Message`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List messageDescriptor = $convert.base64Decode(
    'CgdNZXNzYWdlEg4KAmlkGAEgASgJUgJpZBIZCghzcGFjZV9pZBgCIAEoCVIHc3BhY2VJZBIbCg'
    'lhdXRob3JfaWQYAyABKAlSCGF1dGhvcklkEh8KC2F1dGhvcl9uYW1lGAQgASgJUgphdXRob3JO'
    'YW1lEhsKCXBhcmVudF9pZBgFIAEoCVIIcGFyZW50SWQSEgoEYm9keRgGIAEoCVIEYm9keRIdCg'
    'pjcmVhdGVkX2F0GAcgASgJUgljcmVhdGVkQXQSGwoJZWRpdGVkX2F0GAggASgJUghlZGl0ZWRB'
    'dBIYCgdkZWxldGVkGAkgASgIUgdkZWxldGVkEhgKB3ZlcnNpb24YCiABKAVSB3ZlcnNpb24SOw'
    'oJcmVhY3Rpb25zGAsgAygLMh0uY29uZmlnLmNoYXQuUmVhY3Rpb25SZXNwb25zZVIJcmVhY3Rp'
    'b25z');

@$core.Deprecated('Use personDescriptor instead')
const Person$json = {
  '1': 'Person',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'display_name', '3': 2, '4': 1, '5': 9, '10': 'displayName'},
  ],
};

/// Descriptor for `Person`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List personDescriptor = $convert.base64Decode(
    'CgZQZXJzb24SFwoHdXNlcl9pZBgBIAEoCVIGdXNlcklkEiEKDGRpc3BsYXlfbmFtZRgCIAEoCV'
    'ILZGlzcGxheU5hbWU=');

@$core.Deprecated('Use reactionDescriptor instead')
const Reaction$json = {
  '1': 'Reaction',
  '2': [
    {'1': 'emoji', '3': 1, '4': 1, '5': 9, '10': 'emoji'},
    {'1': 'user_ids', '3': 2, '4': 3, '5': 9, '10': 'userIds'},
  ],
};

/// Descriptor for `Reaction`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List reactionDescriptor = $convert.base64Decode(
    'CghSZWFjdGlvbhIUCgVlbW9qaRgBIAEoCVIFZW1vamkSGQoIdXNlcl9pZHMYAiADKAlSB3VzZX'
    'JJZHM=');

@$core.Deprecated('Use reactionResponseDescriptor instead')
const ReactionResponse$json = {
  '1': 'ReactionResponse',
  '2': [
    {'1': 'emoji', '3': 1, '4': 1, '5': 9, '10': 'emoji'},
    {'1': 'user_ids', '3': 2, '4': 3, '5': 9, '10': 'userIds'},
  ],
};

/// Descriptor for `ReactionResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List reactionResponseDescriptor = $convert.base64Decode(
    'ChBSZWFjdGlvblJlc3BvbnNlEhQKBWVtb2ppGAEgASgJUgVlbW9qaRIZCgh1c2VyX2lkcxgCIA'
    'MoCVIHdXNlcklkcw==');

@$core.Deprecated('Use spaceDescriptor instead')
const Space$json = {
  '1': 'Space',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'kind', '3': 2, '4': 1, '5': 9, '10': 'kind'},
    {'1': 'name', '3': 3, '4': 1, '5': 9, '10': 'name'},
    {'1': 'project_id', '3': 4, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'is_default', '3': 5, '4': 1, '5': 8, '10': 'isDefault'},
    {'1': 'archived', '3': 6, '4': 1, '5': 8, '10': 'archived'},
    {'1': 'joined', '3': 7, '4': 1, '5': 8, '10': 'joined'},
    {'1': 'role', '3': 8, '4': 1, '5': 9, '10': 'role'},
    {'1': 'unread_count', '3': 9, '4': 1, '5': 5, '10': 'unreadCount'},
    {'1': 'last_message_at', '3': 10, '4': 1, '5': 9, '10': 'lastMessageAt'},
    {'1': 'last_read_at', '3': 11, '4': 1, '5': 9, '10': 'lastReadAt'},
    {'1': 'member_count', '3': 12, '4': 1, '5': 5, '10': 'memberCount'},
    {'1': 'muted_until', '3': 13, '4': 1, '5': 9, '10': 'mutedUntil'},
    {'1': 'muted_completely', '3': 14, '4': 1, '5': 8, '10': 'mutedCompletely'},
    {'1': 'notify_all', '3': 15, '4': 1, '5': 8, '10': 'notifyAll'},
    {'1': 'read_only', '3': 16, '4': 1, '5': 8, '10': 'readOnly'},
    {'1': 'peer_id', '3': 17, '4': 1, '5': 9, '10': 'peerId'},
    {'1': 'version', '3': 18, '4': 1, '5': 5, '10': 'version'},
    {'1': 'created_at', '3': 19, '4': 1, '5': 9, '10': 'createdAt'},
    {'1': 'created_by', '3': 20, '4': 1, '5': 9, '10': 'createdBy'},
  ],
};

/// Descriptor for `Space`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List spaceDescriptor = $convert.base64Decode(
    'CgVTcGFjZRIOCgJpZBgBIAEoCVICaWQSEgoEa2luZBgCIAEoCVIEa2luZBISCgRuYW1lGAMgAS'
    'gJUgRuYW1lEh0KCnByb2plY3RfaWQYBCABKAlSCXByb2plY3RJZBIdCgppc19kZWZhdWx0GAUg'
    'ASgIUglpc0RlZmF1bHQSGgoIYXJjaGl2ZWQYBiABKAhSCGFyY2hpdmVkEhYKBmpvaW5lZBgHIA'
    'EoCFIGam9pbmVkEhIKBHJvbGUYCCABKAlSBHJvbGUSIQoMdW5yZWFkX2NvdW50GAkgASgFUgt1'
    'bnJlYWRDb3VudBImCg9sYXN0X21lc3NhZ2VfYXQYCiABKAlSDWxhc3RNZXNzYWdlQXQSIAoMbG'
    'FzdF9yZWFkX2F0GAsgASgJUgpsYXN0UmVhZEF0EiEKDG1lbWJlcl9jb3VudBgMIAEoBVILbWVt'
    'YmVyQ291bnQSHwoLbXV0ZWRfdW50aWwYDSABKAlSCm11dGVkVW50aWwSKQoQbXV0ZWRfY29tcG'
    'xldGVseRgOIAEoCFIPbXV0ZWRDb21wbGV0ZWx5Eh0KCm5vdGlmeV9hbGwYDyABKAhSCW5vdGlm'
    'eUFsbBIbCglyZWFkX29ubHkYECABKAhSCHJlYWRPbmx5EhcKB3BlZXJfaWQYESABKAlSBnBlZX'
    'JJZBIYCgd2ZXJzaW9uGBIgASgFUgd2ZXJzaW9uEh0KCmNyZWF0ZWRfYXQYEyABKAlSCWNyZWF0'
    'ZWRBdBIdCgpjcmVhdGVkX2J5GBQgASgJUgljcmVhdGVkQnk=');

@$core.Deprecated('Use taskChatDescriptor instead')
const TaskChat$json = {
  '1': 'TaskChat',
  '2': [
    {'1': 'task_id', '3': 1, '4': 1, '5': 9, '10': 'taskId'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'display_id', '3': 3, '4': 1, '5': 9, '10': 'displayId'},
    {'1': 'title', '3': 4, '4': 1, '5': 9, '10': 'title'},
    {'1': 'last_message_at', '3': 5, '4': 1, '5': 9, '10': 'lastMessageAt'},
  ],
};

/// Descriptor for `TaskChat`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List taskChatDescriptor = $convert.base64Decode(
    'CghUYXNrQ2hhdBIXCgd0YXNrX2lkGAEgASgJUgZ0YXNrSWQSHQoKcHJvamVjdF9pZBgCIAEoCV'
    'IJcHJvamVjdElkEh0KCmRpc3BsYXlfaWQYAyABKAlSCWRpc3BsYXlJZBIUCgV0aXRsZRgEIAEo'
    'CVIFdGl0bGUSJgoPbGFzdF9tZXNzYWdlX2F0GAUgASgJUg1sYXN0TWVzc2FnZUF0');
