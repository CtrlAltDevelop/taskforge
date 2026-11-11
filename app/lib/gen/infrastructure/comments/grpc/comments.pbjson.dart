// This is a generated file - do not edit.
//
// Generated from infrastructure/comments/grpc/comments.proto.

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

@$core.Deprecated('Use commentDescriptor instead')
const Comment$json = {
  '1': 'Comment',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'task_id', '3': 2, '4': 1, '5': 9, '10': 'taskId'},
    {'1': 'author_id', '3': 3, '4': 1, '5': 9, '10': 'authorId'},
    {'1': 'parent_id', '3': 4, '4': 1, '5': 9, '10': 'parentId'},
    {'1': 'body', '3': 5, '4': 1, '5': 9, '10': 'body'},
    {'1': 'created_at', '3': 6, '4': 1, '5': 9, '10': 'createdAt'},
    {'1': 'edited_at', '3': 7, '4': 1, '5': 9, '10': 'editedAt'},
    {'1': 'deleted', '3': 8, '4': 1, '5': 8, '10': 'deleted'},
    {'1': 'pinned', '3': 9, '4': 1, '5': 8, '10': 'pinned'},
    {'1': 'version', '3': 10, '4': 1, '5': 5, '10': 'version'},
    {'1': 'mention_ids', '3': 11, '4': 3, '5': 9, '10': 'mentionIds'},
    {
      '1': 'reactions',
      '3': 12,
      '4': 3,
      '5': 11,
      '6': '.config.comments.ReactionResponse',
      '10': 'reactions'
    },
    {'1': 'edit_count', '3': 13, '4': 1, '5': 5, '10': 'editCount'},
  ],
};

/// Descriptor for `Comment`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List commentDescriptor = $convert.base64Decode(
    'CgdDb21tZW50Eg4KAmlkGAEgASgJUgJpZBIXCgd0YXNrX2lkGAIgASgJUgZ0YXNrSWQSGwoJYX'
    'V0aG9yX2lkGAMgASgJUghhdXRob3JJZBIbCglwYXJlbnRfaWQYBCABKAlSCHBhcmVudElkEhIK'
    'BGJvZHkYBSABKAlSBGJvZHkSHQoKY3JlYXRlZF9hdBgGIAEoCVIJY3JlYXRlZEF0EhsKCWVkaX'
    'RlZF9hdBgHIAEoCVIIZWRpdGVkQXQSGAoHZGVsZXRlZBgIIAEoCFIHZGVsZXRlZBIWCgZwaW5u'
    'ZWQYCSABKAhSBnBpbm5lZBIYCgd2ZXJzaW9uGAogASgFUgd2ZXJzaW9uEh8KC21lbnRpb25faW'
    'RzGAsgAygJUgptZW50aW9uSWRzEj8KCXJlYWN0aW9ucxgMIAMoCzIhLmNvbmZpZy5jb21tZW50'
    'cy5SZWFjdGlvblJlc3BvbnNlUglyZWFjdGlvbnMSHQoKZWRpdF9jb3VudBgNIAEoBVIJZWRpdE'
    'NvdW50');

@$core.Deprecated('Use commentCreateRequestDescriptor instead')
const CommentCreateRequest$json = {
  '1': 'CommentCreateRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'task_id', '3': 3, '4': 1, '5': 9, '10': 'taskId'},
    {'1': 'body', '3': 4, '4': 1, '5': 9, '10': 'body'},
    {'1': 'parent_id', '3': 5, '4': 1, '5': 9, '10': 'parentId'},
    {'1': 'grant_access', '3': 6, '4': 1, '5': 8, '10': 'grantAccess'},
  ],
};

/// Descriptor for `CommentCreateRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List commentCreateRequestDescriptor = $convert.base64Decode(
    'ChRDb21tZW50Q3JlYXRlUmVxdWVzdBIhCgx3b3Jrc3BhY2VfaWQYASABKAlSC3dvcmtzcGFjZU'
    'lkEh0KCnByb2plY3RfaWQYAiABKAlSCXByb2plY3RJZBIXCgd0YXNrX2lkGAMgASgJUgZ0YXNr'
    'SWQSEgoEYm9keRgEIAEoCVIEYm9keRIbCglwYXJlbnRfaWQYBSABKAlSCHBhcmVudElkEiEKDG'
    'dyYW50X2FjY2VzcxgGIAEoCFILZ3JhbnRBY2Nlc3M=');

@$core.Deprecated('Use commentDeleteRequestDescriptor instead')
const CommentDeleteRequest$json = {
  '1': 'CommentDeleteRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'id', '3': 3, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `CommentDeleteRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List commentDeleteRequestDescriptor = $convert.base64Decode(
    'ChRDb21tZW50RGVsZXRlUmVxdWVzdBIhCgx3b3Jrc3BhY2VfaWQYASABKAlSC3dvcmtzcGFjZU'
    'lkEh0KCnByb2plY3RfaWQYAiABKAlSCXByb2plY3RJZBIOCgJpZBgDIAEoCVICaWQ=');

@$core.Deprecated('Use commentEditRequestDescriptor instead')
const CommentEditRequest$json = {
  '1': 'CommentEditRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'id', '3': 3, '4': 1, '5': 9, '10': 'id'},
    {'1': 'expected_version', '3': 4, '4': 1, '5': 5, '10': 'expectedVersion'},
    {'1': 'body', '3': 5, '4': 1, '5': 9, '10': 'body'},
    {'1': 'grant_access', '3': 6, '4': 1, '5': 8, '10': 'grantAccess'},
  ],
};

/// Descriptor for `CommentEditRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List commentEditRequestDescriptor = $convert.base64Decode(
    'ChJDb21tZW50RWRpdFJlcXVlc3QSIQoMd29ya3NwYWNlX2lkGAEgASgJUgt3b3Jrc3BhY2VJZB'
    'IdCgpwcm9qZWN0X2lkGAIgASgJUglwcm9qZWN0SWQSDgoCaWQYAyABKAlSAmlkEikKEGV4cGVj'
    'dGVkX3ZlcnNpb24YBCABKAVSD2V4cGVjdGVkVmVyc2lvbhISCgRib2R5GAUgASgJUgRib2R5Ei'
    'EKDGdyYW50X2FjY2VzcxgGIAEoCFILZ3JhbnRBY2Nlc3M=');

@$core.Deprecated('Use commentHistoryDescriptor instead')
const CommentHistory$json = {
  '1': 'CommentHistory',
  '2': [
    {
      '1': 'revisions',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.config.comments.CommentRevision',
      '10': 'revisions'
    },
  ],
};

/// Descriptor for `CommentHistory`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List commentHistoryDescriptor = $convert.base64Decode(
    'Cg5Db21tZW50SGlzdG9yeRI+CglyZXZpc2lvbnMYASADKAsyIC5jb25maWcuY29tbWVudHMuQ2'
    '9tbWVudFJldmlzaW9uUglyZXZpc2lvbnM=');

@$core.Deprecated('Use commentHistoryRequestDescriptor instead')
const CommentHistoryRequest$json = {
  '1': 'CommentHistoryRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'id', '3': 3, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `CommentHistoryRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List commentHistoryRequestDescriptor = $convert.base64Decode(
    'ChVDb21tZW50SGlzdG9yeVJlcXVlc3QSIQoMd29ya3NwYWNlX2lkGAEgASgJUgt3b3Jrc3BhY2'
    'VJZBIdCgpwcm9qZWN0X2lkGAIgASgJUglwcm9qZWN0SWQSDgoCaWQYAyABKAlSAmlk');

@$core.Deprecated('Use commentListRequestDescriptor instead')
const CommentListRequest$json = {
  '1': 'CommentListRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'task_id', '3': 3, '4': 1, '5': 9, '10': 'taskId'},
    {'1': 'before', '3': 4, '4': 1, '5': 9, '10': 'before'},
    {'1': 'page_size', '3': 5, '4': 1, '5': 5, '10': 'pageSize'},
  ],
};

/// Descriptor for `CommentListRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List commentListRequestDescriptor = $convert.base64Decode(
    'ChJDb21tZW50TGlzdFJlcXVlc3QSIQoMd29ya3NwYWNlX2lkGAEgASgJUgt3b3Jrc3BhY2VJZB'
    'IdCgpwcm9qZWN0X2lkGAIgASgJUglwcm9qZWN0SWQSFwoHdGFza19pZBgDIAEoCVIGdGFza0lk'
    'EhYKBmJlZm9yZRgEIAEoCVIGYmVmb3JlEhsKCXBhZ2Vfc2l6ZRgFIAEoBVIIcGFnZVNpemU=');

@$core.Deprecated('Use commentMentionableDescriptor instead')
const CommentMentionable$json = {
  '1': 'CommentMentionable',
  '2': [
    {
      '1': 'people',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.config.comments.Mentionable',
      '10': 'people'
    },
  ],
};

/// Descriptor for `CommentMentionable`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List commentMentionableDescriptor = $convert.base64Decode(
    'ChJDb21tZW50TWVudGlvbmFibGUSNAoGcGVvcGxlGAEgAygLMhwuY29uZmlnLmNvbW1lbnRzLk'
    '1lbnRpb25hYmxlUgZwZW9wbGU=');

@$core.Deprecated('Use commentMentionableRequestDescriptor instead')
const CommentMentionableRequest$json = {
  '1': 'CommentMentionableRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'task_id', '3': 3, '4': 1, '5': 9, '10': 'taskId'},
    {'1': 'query', '3': 4, '4': 1, '5': 9, '10': 'query'},
  ],
};

/// Descriptor for `CommentMentionableRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List commentMentionableRequestDescriptor = $convert.base64Decode(
    'ChlDb21tZW50TWVudGlvbmFibGVSZXF1ZXN0EiEKDHdvcmtzcGFjZV9pZBgBIAEoCVILd29ya3'
    'NwYWNlSWQSHQoKcHJvamVjdF9pZBgCIAEoCVIJcHJvamVjdElkEhcKB3Rhc2tfaWQYAyABKAlS'
    'BnRhc2tJZBIUCgVxdWVyeRgEIAEoCVIFcXVlcnk=');

@$core.Deprecated('Use commentPageDescriptor instead')
const CommentPage$json = {
  '1': 'CommentPage',
  '2': [
    {
      '1': 'comments',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.config.comments.Comment',
      '10': 'comments'
    },
    {'1': 'cursor', '3': 2, '4': 1, '5': 9, '10': 'cursor'},
  ],
};

/// Descriptor for `CommentPage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List commentPageDescriptor = $convert.base64Decode(
    'CgtDb21tZW50UGFnZRI0Cghjb21tZW50cxgBIAMoCzIYLmNvbmZpZy5jb21tZW50cy5Db21tZW'
    '50Ughjb21tZW50cxIWCgZjdXJzb3IYAiABKAlSBmN1cnNvcg==');

@$core.Deprecated('Use commentPinRequestDescriptor instead')
const CommentPinRequest$json = {
  '1': 'CommentPinRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'id', '3': 3, '4': 1, '5': 9, '10': 'id'},
    {'1': 'pinned', '3': 4, '4': 1, '5': 8, '10': 'pinned'},
  ],
};

/// Descriptor for `CommentPinRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List commentPinRequestDescriptor = $convert.base64Decode(
    'ChFDb21tZW50UGluUmVxdWVzdBIhCgx3b3Jrc3BhY2VfaWQYASABKAlSC3dvcmtzcGFjZUlkEh'
    '0KCnByb2plY3RfaWQYAiABKAlSCXByb2plY3RJZBIOCgJpZBgDIAEoCVICaWQSFgoGcGlubmVk'
    'GAQgASgIUgZwaW5uZWQ=');

@$core.Deprecated('Use commentReactRequestDescriptor instead')
const CommentReactRequest$json = {
  '1': 'CommentReactRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'id', '3': 3, '4': 1, '5': 9, '10': 'id'},
    {'1': 'emoji', '3': 4, '4': 1, '5': 9, '10': 'emoji'},
    {'1': 'on', '3': 5, '4': 1, '5': 8, '10': 'on'},
  ],
};

/// Descriptor for `CommentReactRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List commentReactRequestDescriptor = $convert.base64Decode(
    'ChNDb21tZW50UmVhY3RSZXF1ZXN0EiEKDHdvcmtzcGFjZV9pZBgBIAEoCVILd29ya3NwYWNlSW'
    'QSHQoKcHJvamVjdF9pZBgCIAEoCVIJcHJvamVjdElkEg4KAmlkGAMgASgJUgJpZBIUCgVlbW9q'
    'aRgEIAEoCVIFZW1vamkSDgoCb24YBSABKAhSAm9u');

@$core.Deprecated('Use commentRevisionDescriptor instead')
const CommentRevision$json = {
  '1': 'CommentRevision',
  '2': [
    {'1': 'body', '3': 1, '4': 1, '5': 9, '10': 'body'},
    {'1': 'at', '3': 2, '4': 1, '5': 9, '10': 'at'},
    {'1': 'current', '3': 3, '4': 1, '5': 8, '10': 'current'},
  ],
};

/// Descriptor for `CommentRevision`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List commentRevisionDescriptor = $convert.base64Decode(
    'Cg9Db21tZW50UmV2aXNpb24SEgoEYm9keRgBIAEoCVIEYm9keRIOCgJhdBgCIAEoCVICYXQSGA'
    'oHY3VycmVudBgDIAEoCFIHY3VycmVudA==');

@$core.Deprecated('Use commentSubtaskDescriptor instead')
const CommentSubtask$json = {
  '1': 'CommentSubtask',
  '2': [
    {'1': 'task_id', '3': 1, '4': 1, '5': 9, '10': 'taskId'},
  ],
};

/// Descriptor for `CommentSubtask`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List commentSubtaskDescriptor = $convert
    .base64Decode('Cg5Db21tZW50U3VidGFzaxIXCgd0YXNrX2lkGAEgASgJUgZ0YXNrSWQ=');

@$core.Deprecated('Use commentToSubtaskRequestDescriptor instead')
const CommentToSubtaskRequest$json = {
  '1': 'CommentToSubtaskRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'id', '3': 3, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `CommentToSubtaskRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List commentToSubtaskRequestDescriptor = $convert.base64Decode(
    'ChdDb21tZW50VG9TdWJ0YXNrUmVxdWVzdBIhCgx3b3Jrc3BhY2VfaWQYASABKAlSC3dvcmtzcG'
    'FjZUlkEh0KCnByb2plY3RfaWQYAiABKAlSCXByb2plY3RJZBIOCgJpZBgDIAEoCVICaWQ=');

@$core.Deprecated('Use mentionableDescriptor instead')
const Mentionable$json = {
  '1': 'Mentionable',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'display_name', '3': 2, '4': 1, '5': 9, '10': 'displayName'},
  ],
};

/// Descriptor for `Mentionable`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List mentionableDescriptor = $convert.base64Decode(
    'CgtNZW50aW9uYWJsZRIXCgd1c2VyX2lkGAEgASgJUgZ1c2VySWQSIQoMZGlzcGxheV9uYW1lGA'
    'IgASgJUgtkaXNwbGF5TmFtZQ==');

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
