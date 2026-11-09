// This is a generated file - do not edit.
//
// Generated from infrastructure/workspaces/grpc/workspaces.proto.

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

@$core.Deprecated('Use invitationDescriptor instead')
const Invitation$json = {
  '1': 'Invitation',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'workspace_id', '3': 2, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'email', '3': 3, '4': 1, '5': 9, '10': 'email'},
    {'1': 'is_link', '3': 4, '4': 1, '5': 8, '10': 'isLink'},
    {'1': 'created_by', '3': 5, '4': 1, '5': 9, '10': 'createdBy'},
    {'1': 'created_by_name', '3': 6, '4': 1, '5': 9, '10': 'createdByName'},
    {'1': 'created_at', '3': 7, '4': 1, '5': 9, '10': 'createdAt'},
    {'1': 'expires_at', '3': 8, '4': 1, '5': 9, '10': 'expiresAt'},
    {'1': 'max_uses', '3': 9, '4': 1, '5': 5, '10': 'maxUses'},
    {'1': 'uses', '3': 10, '4': 1, '5': 5, '10': 'uses'},
    {'1': 'state', '3': 11, '4': 1, '5': 9, '10': 'state'},
    {'1': 'token', '3': 12, '4': 1, '5': 9, '10': 'token'},
    {'1': 'role_id', '3': 13, '4': 1, '5': 9, '10': 'roleId'},
    {'1': 'role_name', '3': 14, '4': 1, '5': 9, '10': 'roleName'},
  ],
};

/// Descriptor for `Invitation`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List invitationDescriptor = $convert.base64Decode(
    'CgpJbnZpdGF0aW9uEg4KAmlkGAEgASgJUgJpZBIhCgx3b3Jrc3BhY2VfaWQYAiABKAlSC3dvcm'
    'tzcGFjZUlkEhQKBWVtYWlsGAMgASgJUgVlbWFpbBIXCgdpc19saW5rGAQgASgIUgZpc0xpbmsS'
    'HQoKY3JlYXRlZF9ieRgFIAEoCVIJY3JlYXRlZEJ5EiYKD2NyZWF0ZWRfYnlfbmFtZRgGIAEoCV'
    'INY3JlYXRlZEJ5TmFtZRIdCgpjcmVhdGVkX2F0GAcgASgJUgljcmVhdGVkQXQSHQoKZXhwaXJl'
    'c19hdBgIIAEoCVIJZXhwaXJlc0F0EhkKCG1heF91c2VzGAkgASgFUgdtYXhVc2VzEhIKBHVzZX'
    'MYCiABKAVSBHVzZXMSFAoFc3RhdGUYCyABKAlSBXN0YXRlEhQKBXRva2VuGAwgASgJUgV0b2tl'
    'bhIXCgdyb2xlX2lkGA0gASgJUgZyb2xlSWQSGwoJcm9sZV9uYW1lGA4gASgJUghyb2xlTmFtZQ'
    '==');

@$core.Deprecated('Use invitationAcceptRequestDescriptor instead')
const InvitationAcceptRequest$json = {
  '1': 'InvitationAcceptRequest',
  '2': [
    {'1': 'token', '3': 1, '4': 1, '5': 9, '10': 'token'},
  ],
};

/// Descriptor for `InvitationAcceptRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List invitationAcceptRequestDescriptor =
    $convert.base64Decode(
        'ChdJbnZpdGF0aW9uQWNjZXB0UmVxdWVzdBIUCgV0b2tlbhgBIAEoCVIFdG9rZW4=');

@$core.Deprecated('Use invitationCreateLinkRequestDescriptor instead')
const InvitationCreateLinkRequest$json = {
  '1': 'InvitationCreateLinkRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'expires_in', '3': 2, '4': 1, '5': 5, '10': 'expiresIn'},
    {'1': 'max_uses', '3': 3, '4': 1, '5': 5, '10': 'maxUses'},
    {'1': 'role_id', '3': 4, '4': 1, '5': 9, '10': 'roleId'},
  ],
};

/// Descriptor for `InvitationCreateLinkRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List invitationCreateLinkRequestDescriptor =
    $convert.base64Decode(
        'ChtJbnZpdGF0aW9uQ3JlYXRlTGlua1JlcXVlc3QSIQoMd29ya3NwYWNlX2lkGAEgASgJUgt3b3'
        'Jrc3BhY2VJZBIdCgpleHBpcmVzX2luGAIgASgFUglleHBpcmVzSW4SGQoIbWF4X3VzZXMYAyAB'
        'KAVSB21heFVzZXMSFwoHcm9sZV9pZBgEIAEoCVIGcm9sZUlk');

@$core.Deprecated('Use invitationCreateRequestDescriptor instead')
const InvitationCreateRequest$json = {
  '1': 'InvitationCreateRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'emails', '3': 2, '4': 3, '5': 9, '10': 'emails'},
    {'1': 'role_id', '3': 3, '4': 1, '5': 9, '10': 'roleId'},
  ],
};

/// Descriptor for `InvitationCreateRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List invitationCreateRequestDescriptor = $convert.base64Decode(
    'ChdJbnZpdGF0aW9uQ3JlYXRlUmVxdWVzdBIhCgx3b3Jrc3BhY2VfaWQYASABKAlSC3dvcmtzcG'
    'FjZUlkEhYKBmVtYWlscxgCIAMoCVIGZW1haWxzEhcKB3JvbGVfaWQYAyABKAlSBnJvbGVJZA==');

@$core.Deprecated('Use invitationCreateResponseDescriptor instead')
const InvitationCreateResponse$json = {
  '1': 'InvitationCreateResponse',
  '2': [
    {
      '1': 'invitations',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.config.workspaces.Invitation',
      '10': 'invitations'
    },
    {'1': 'skipped_emails', '3': 2, '4': 3, '5': 9, '10': 'skippedEmails'},
    {
      '1': 'undelivered_emails',
      '3': 3,
      '4': 3,
      '5': 9,
      '10': 'undeliveredEmails'
    },
  ],
};

/// Descriptor for `InvitationCreateResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List invitationCreateResponseDescriptor = $convert.base64Decode(
    'ChhJbnZpdGF0aW9uQ3JlYXRlUmVzcG9uc2USPwoLaW52aXRhdGlvbnMYASADKAsyHS5jb25maW'
    'cud29ya3NwYWNlcy5JbnZpdGF0aW9uUgtpbnZpdGF0aW9ucxIlCg5za2lwcGVkX2VtYWlscxgC'
    'IAMoCVINc2tpcHBlZEVtYWlscxItChJ1bmRlbGl2ZXJlZF9lbWFpbHMYAyADKAlSEXVuZGVsaX'
    'ZlcmVkRW1haWxz');

@$core.Deprecated('Use invitationDeclineRequestDescriptor instead')
const InvitationDeclineRequest$json = {
  '1': 'InvitationDeclineRequest',
  '2': [
    {'1': 'token', '3': 1, '4': 1, '5': 9, '10': 'token'},
  ],
};

/// Descriptor for `InvitationDeclineRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List invitationDeclineRequestDescriptor =
    $convert.base64Decode(
        'ChhJbnZpdGF0aW9uRGVjbGluZVJlcXVlc3QSFAoFdG9rZW4YASABKAlSBXRva2Vu');

@$core.Deprecated('Use invitationEmptyDescriptor instead')
const InvitationEmpty$json = {
  '1': 'InvitationEmpty',
};

/// Descriptor for `InvitationEmpty`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List invitationEmptyDescriptor =
    $convert.base64Decode('Cg9JbnZpdGF0aW9uRW1wdHk=');

@$core.Deprecated('Use invitationListDescriptor instead')
const InvitationList$json = {
  '1': 'InvitationList',
  '2': [
    {
      '1': 'invitations',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.config.workspaces.Invitation',
      '10': 'invitations'
    },
  ],
};

/// Descriptor for `InvitationList`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List invitationListDescriptor = $convert.base64Decode(
    'Cg5JbnZpdGF0aW9uTGlzdBI/CgtpbnZpdGF0aW9ucxgBIAMoCzIdLmNvbmZpZy53b3Jrc3BhY2'
    'VzLkludml0YXRpb25SC2ludml0YXRpb25z');

@$core.Deprecated('Use invitationListRequestDescriptor instead')
const InvitationListRequest$json = {
  '1': 'InvitationListRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
  ],
};

/// Descriptor for `InvitationListRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List invitationListRequestDescriptor = $convert.base64Decode(
    'ChVJbnZpdGF0aW9uTGlzdFJlcXVlc3QSIQoMd29ya3NwYWNlX2lkGAEgASgJUgt3b3Jrc3BhY2'
    'VJZA==');

@$core.Deprecated('Use invitationResendRequestDescriptor instead')
const InvitationResendRequest$json = {
  '1': 'InvitationResendRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'id', '3': 2, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `InvitationResendRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List invitationResendRequestDescriptor =
    $convert.base64Decode(
        'ChdJbnZpdGF0aW9uUmVzZW5kUmVxdWVzdBIhCgx3b3Jrc3BhY2VfaWQYASABKAlSC3dvcmtzcG'
        'FjZUlkEg4KAmlkGAIgASgJUgJpZA==');

@$core.Deprecated('Use invitationRevokeRequestDescriptor instead')
const InvitationRevokeRequest$json = {
  '1': 'InvitationRevokeRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'id', '3': 2, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `InvitationRevokeRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List invitationRevokeRequestDescriptor =
    $convert.base64Decode(
        'ChdJbnZpdGF0aW9uUmV2b2tlUmVxdWVzdBIhCgx3b3Jrc3BhY2VfaWQYASABKAlSC3dvcmtzcG'
        'FjZUlkEg4KAmlkGAIgASgJUgJpZA==');

@$core.Deprecated('Use memberDescriptor instead')
const Member$json = {
  '1': 'Member',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'display_name', '3': 2, '4': 1, '5': 9, '10': 'displayName'},
    {'1': 'email', '3': 3, '4': 1, '5': 9, '10': 'email'},
    {'1': 'joined_at', '3': 4, '4': 1, '5': 9, '10': 'joinedAt'},
    {'1': 'is_owner', '3': 5, '4': 1, '5': 8, '10': 'isOwner'},
    {'1': 'status', '3': 6, '4': 1, '5': 9, '10': 'status'},
    {'1': 'role_id', '3': 7, '4': 1, '5': 9, '10': 'roleId'},
    {'1': 'role_name', '3': 8, '4': 1, '5': 9, '10': 'roleName'},
  ],
};

/// Descriptor for `Member`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List memberDescriptor = $convert.base64Decode(
    'CgZNZW1iZXISFwoHdXNlcl9pZBgBIAEoCVIGdXNlcklkEiEKDGRpc3BsYXlfbmFtZRgCIAEoCV'
    'ILZGlzcGxheU5hbWUSFAoFZW1haWwYAyABKAlSBWVtYWlsEhsKCWpvaW5lZF9hdBgEIAEoCVII'
    'am9pbmVkQXQSGQoIaXNfb3duZXIYBSABKAhSB2lzT3duZXISFgoGc3RhdHVzGAYgASgJUgZzdG'
    'F0dXMSFwoHcm9sZV9pZBgHIAEoCVIGcm9sZUlkEhsKCXJvbGVfbmFtZRgIIAEoCVIIcm9sZU5h'
    'bWU=');

@$core.Deprecated('Use memberEmptyDescriptor instead')
const MemberEmpty$json = {
  '1': 'MemberEmpty',
};

/// Descriptor for `MemberEmpty`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List memberEmptyDescriptor =
    $convert.base64Decode('CgtNZW1iZXJFbXB0eQ==');

@$core.Deprecated('Use memberLeaveRequestDescriptor instead')
const MemberLeaveRequest$json = {
  '1': 'MemberLeaveRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
  ],
};

/// Descriptor for `MemberLeaveRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List memberLeaveRequestDescriptor = $convert.base64Decode(
    'ChJNZW1iZXJMZWF2ZVJlcXVlc3QSIQoMd29ya3NwYWNlX2lkGAEgASgJUgt3b3Jrc3BhY2VJZA'
    '==');

@$core.Deprecated('Use memberListDescriptor instead')
const MemberList$json = {
  '1': 'MemberList',
  '2': [
    {
      '1': 'members',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.config.workspaces.Member',
      '10': 'members'
    },
  ],
};

/// Descriptor for `MemberList`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List memberListDescriptor = $convert.base64Decode(
    'CgpNZW1iZXJMaXN0EjMKB21lbWJlcnMYASADKAsyGS5jb25maWcud29ya3NwYWNlcy5NZW1iZX'
    'JSB21lbWJlcnM=');

@$core.Deprecated('Use memberListRequestDescriptor instead')
const MemberListRequest$json = {
  '1': 'MemberListRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
  ],
};

/// Descriptor for `MemberListRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List memberListRequestDescriptor = $convert.base64Decode(
    'ChFNZW1iZXJMaXN0UmVxdWVzdBIhCgx3b3Jrc3BhY2VfaWQYASABKAlSC3dvcmtzcGFjZUlk');

@$core.Deprecated('Use memberRemoveRequestDescriptor instead')
const MemberRemoveRequest$json = {
  '1': 'MemberRemoveRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'user_id', '3': 2, '4': 1, '5': 9, '10': 'userId'},
  ],
};

/// Descriptor for `MemberRemoveRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List memberRemoveRequestDescriptor = $convert.base64Decode(
    'ChNNZW1iZXJSZW1vdmVSZXF1ZXN0EiEKDHdvcmtzcGFjZV9pZBgBIAEoCVILd29ya3NwYWNlSW'
    'QSFwoHdXNlcl9pZBgCIAEoCVIGdXNlcklk');

@$core.Deprecated('Use memberSetRoleRequestDescriptor instead')
const MemberSetRoleRequest$json = {
  '1': 'MemberSetRoleRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'user_id', '3': 2, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'role_id', '3': 3, '4': 1, '5': 9, '10': 'roleId'},
  ],
};

/// Descriptor for `MemberSetRoleRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List memberSetRoleRequestDescriptor = $convert.base64Decode(
    'ChRNZW1iZXJTZXRSb2xlUmVxdWVzdBIhCgx3b3Jrc3BhY2VfaWQYASABKAlSC3dvcmtzcGFjZU'
    'lkEhcKB3VzZXJfaWQYAiABKAlSBnVzZXJJZBIXCgdyb2xlX2lkGAMgASgJUgZyb2xlSWQ=');

@$core.Deprecated('Use permissionAnswerDescriptor instead')
const PermissionAnswer$json = {
  '1': 'PermissionAnswer',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'allowed', '3': 2, '4': 1, '5': 8, '10': 'allowed'},
  ],
};

/// Descriptor for `PermissionAnswer`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List permissionAnswerDescriptor = $convert.base64Decode(
    'ChBQZXJtaXNzaW9uQW5zd2VyEhAKA2tleRgBIAEoCVIDa2V5EhgKB2FsbG93ZWQYAiABKAhSB2'
    'FsbG93ZWQ=');

@$core.Deprecated('Use permissionAreaDescriptor instead')
const PermissionArea$json = {
  '1': 'PermissionArea',
  '2': [
    {'1': 'area', '3': 1, '4': 1, '5': 9, '10': 'area'},
    {
      '1': 'permissions',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.config.workspaces.PermissionInfo',
      '10': 'permissions'
    },
  ],
};

/// Descriptor for `PermissionArea`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List permissionAreaDescriptor = $convert.base64Decode(
    'Cg5QZXJtaXNzaW9uQXJlYRISCgRhcmVhGAEgASgJUgRhcmVhEkMKC3Blcm1pc3Npb25zGAIgAy'
    'gLMiEuY29uZmlnLndvcmtzcGFjZXMuUGVybWlzc2lvbkluZm9SC3Blcm1pc3Npb25z');

@$core.Deprecated('Use permissionCheckRequestDescriptor instead')
const PermissionCheckRequest$json = {
  '1': 'PermissionCheckRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'keys', '3': 2, '4': 3, '5': 9, '10': 'keys'},
  ],
};

/// Descriptor for `PermissionCheckRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List permissionCheckRequestDescriptor =
    $convert.base64Decode(
        'ChZQZXJtaXNzaW9uQ2hlY2tSZXF1ZXN0EiEKDHdvcmtzcGFjZV9pZBgBIAEoCVILd29ya3NwYW'
        'NlSWQSEgoEa2V5cxgCIAMoCVIEa2V5cw==');

@$core.Deprecated('Use permissionCheckResponseDescriptor instead')
const PermissionCheckResponse$json = {
  '1': 'PermissionCheckResponse',
  '2': [
    {
      '1': 'answers',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.config.workspaces.PermissionAnswer',
      '10': 'answers'
    },
    {'1': 'role_id', '3': 2, '4': 1, '5': 9, '10': 'roleId'},
    {'1': 'role_name', '3': 3, '4': 1, '5': 9, '10': 'roleName'},
  ],
};

/// Descriptor for `PermissionCheckResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List permissionCheckResponseDescriptor = $convert.base64Decode(
    'ChdQZXJtaXNzaW9uQ2hlY2tSZXNwb25zZRI9CgdhbnN3ZXJzGAEgAygLMiMuY29uZmlnLndvcm'
    'tzcGFjZXMuUGVybWlzc2lvbkFuc3dlclIHYW5zd2VycxIXCgdyb2xlX2lkGAIgASgJUgZyb2xl'
    'SWQSGwoJcm9sZV9uYW1lGAMgASgJUghyb2xlTmFtZQ==');

@$core.Deprecated('Use permissionInfoDescriptor instead')
const PermissionInfo$json = {
  '1': 'PermissionInfo',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'label', '3': 2, '4': 1, '5': 9, '10': 'label'},
  ],
};

/// Descriptor for `PermissionInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List permissionInfoDescriptor = $convert.base64Decode(
    'Cg5QZXJtaXNzaW9uSW5mbxIQCgNrZXkYASABKAlSA2tleRIUCgVsYWJlbBgCIAEoCVIFbGFiZW'
    'w=');

@$core.Deprecated('Use roleDescriptor instead')
const Role$json = {
  '1': 'Role',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'is_builtin', '3': 3, '4': 1, '5': 8, '10': 'isBuiltin'},
    {'1': 'permissions', '3': 4, '4': 3, '5': 9, '10': 'permissions'},
    {'1': 'member_count', '3': 5, '4': 1, '5': 5, '10': 'memberCount'},
    {'1': 'version', '3': 6, '4': 1, '5': 5, '10': 'version'},
  ],
};

/// Descriptor for `Role`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List roleDescriptor = $convert.base64Decode(
    'CgRSb2xlEg4KAmlkGAEgASgJUgJpZBISCgRuYW1lGAIgASgJUgRuYW1lEh0KCmlzX2J1aWx0aW'
    '4YAyABKAhSCWlzQnVpbHRpbhIgCgtwZXJtaXNzaW9ucxgEIAMoCVILcGVybWlzc2lvbnMSIQoM'
    'bWVtYmVyX2NvdW50GAUgASgFUgttZW1iZXJDb3VudBIYCgd2ZXJzaW9uGAYgASgFUgd2ZXJzaW'
    '9u');

@$core.Deprecated('Use roleCreateRequestDescriptor instead')
const RoleCreateRequest$json = {
  '1': 'RoleCreateRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'permissions', '3': 3, '4': 3, '5': 9, '10': 'permissions'},
  ],
};

/// Descriptor for `RoleCreateRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List roleCreateRequestDescriptor = $convert.base64Decode(
    'ChFSb2xlQ3JlYXRlUmVxdWVzdBIhCgx3b3Jrc3BhY2VfaWQYASABKAlSC3dvcmtzcGFjZUlkEh'
    'IKBG5hbWUYAiABKAlSBG5hbWUSIAoLcGVybWlzc2lvbnMYAyADKAlSC3Blcm1pc3Npb25z');

@$core.Deprecated('Use roleDeleteRequestDescriptor instead')
const RoleDeleteRequest$json = {
  '1': 'RoleDeleteRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'id', '3': 2, '4': 1, '5': 9, '10': 'id'},
    {'1': 'reassign_to', '3': 3, '4': 1, '5': 9, '10': 'reassignTo'},
  ],
};

/// Descriptor for `RoleDeleteRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List roleDeleteRequestDescriptor = $convert.base64Decode(
    'ChFSb2xlRGVsZXRlUmVxdWVzdBIhCgx3b3Jrc3BhY2VfaWQYASABKAlSC3dvcmtzcGFjZUlkEg'
    '4KAmlkGAIgASgJUgJpZBIfCgtyZWFzc2lnbl90bxgDIAEoCVIKcmVhc3NpZ25Ubw==');

@$core.Deprecated('Use roleEmptyDescriptor instead')
const RoleEmpty$json = {
  '1': 'RoleEmpty',
};

/// Descriptor for `RoleEmpty`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List roleEmptyDescriptor =
    $convert.base64Decode('CglSb2xlRW1wdHk=');

@$core.Deprecated('Use roleListDescriptor instead')
const RoleList$json = {
  '1': 'RoleList',
  '2': [
    {
      '1': 'roles',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.config.workspaces.Role',
      '10': 'roles'
    },
    {
      '1': 'registry',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.config.workspaces.PermissionArea',
      '10': 'registry'
    },
  ],
};

/// Descriptor for `RoleList`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List roleListDescriptor = $convert.base64Decode(
    'CghSb2xlTGlzdBItCgVyb2xlcxgBIAMoCzIXLmNvbmZpZy53b3Jrc3BhY2VzLlJvbGVSBXJvbG'
    'VzEj0KCHJlZ2lzdHJ5GAIgAygLMiEuY29uZmlnLndvcmtzcGFjZXMuUGVybWlzc2lvbkFyZWFS'
    'CHJlZ2lzdHJ5');

@$core.Deprecated('Use roleListRequestDescriptor instead')
const RoleListRequest$json = {
  '1': 'RoleListRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
  ],
};

/// Descriptor for `RoleListRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List roleListRequestDescriptor = $convert.base64Decode(
    'Cg9Sb2xlTGlzdFJlcXVlc3QSIQoMd29ya3NwYWNlX2lkGAEgASgJUgt3b3Jrc3BhY2VJZA==');

@$core.Deprecated('Use roleUpdateRequestDescriptor instead')
const RoleUpdateRequest$json = {
  '1': 'RoleUpdateRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'id', '3': 2, '4': 1, '5': 9, '10': 'id'},
    {'1': 'name', '3': 3, '4': 1, '5': 9, '10': 'name'},
    {'1': 'permissions', '3': 4, '4': 3, '5': 9, '10': 'permissions'},
    {'1': 'expected_version', '3': 5, '4': 1, '5': 5, '10': 'expectedVersion'},
  ],
};

/// Descriptor for `RoleUpdateRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List roleUpdateRequestDescriptor = $convert.base64Decode(
    'ChFSb2xlVXBkYXRlUmVxdWVzdBIhCgx3b3Jrc3BhY2VfaWQYASABKAlSC3dvcmtzcGFjZUlkEg'
    '4KAmlkGAIgASgJUgJpZBISCgRuYW1lGAMgASgJUgRuYW1lEiAKC3Blcm1pc3Npb25zGAQgAygJ'
    'UgtwZXJtaXNzaW9ucxIpChBleHBlY3RlZF92ZXJzaW9uGAUgASgFUg9leHBlY3RlZFZlcnNpb2'
    '4=');

@$core.Deprecated('Use workspaceDescriptor instead')
const Workspace$json = {
  '1': 'Workspace',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'slug', '3': 3, '4': 1, '5': 9, '10': 'slug'},
    {'1': 'logo', '3': 4, '4': 1, '5': 9, '10': 'logo'},
    {'1': 'created_by', '3': 5, '4': 1, '5': 9, '10': 'createdBy'},
    {'1': 'created_at', '3': 6, '4': 1, '5': 9, '10': 'createdAt'},
    {'1': 'deleted_at', '3': 7, '4': 1, '5': 9, '10': 'deletedAt'},
    {'1': 'version', '3': 8, '4': 1, '5': 5, '10': 'version'},
    {'1': 'is_owner', '3': 9, '4': 1, '5': 8, '10': 'isOwner'},
  ],
};

/// Descriptor for `Workspace`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List workspaceDescriptor = $convert.base64Decode(
    'CglXb3Jrc3BhY2USDgoCaWQYASABKAlSAmlkEhIKBG5hbWUYAiABKAlSBG5hbWUSEgoEc2x1Zx'
    'gDIAEoCVIEc2x1ZxISCgRsb2dvGAQgASgJUgRsb2dvEh0KCmNyZWF0ZWRfYnkYBSABKAlSCWNy'
    'ZWF0ZWRCeRIdCgpjcmVhdGVkX2F0GAYgASgJUgljcmVhdGVkQXQSHQoKZGVsZXRlZF9hdBgHIA'
    'EoCVIJZGVsZXRlZEF0EhgKB3ZlcnNpb24YCCABKAVSB3ZlcnNpb24SGQoIaXNfb3duZXIYCSAB'
    'KAhSB2lzT3duZXI=');

@$core.Deprecated('Use workspaceCreateRequestDescriptor instead')
const WorkspaceCreateRequest$json = {
  '1': 'WorkspaceCreateRequest',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    {'1': 'slug', '3': 2, '4': 1, '5': 9, '10': 'slug'},
  ],
};

/// Descriptor for `WorkspaceCreateRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List workspaceCreateRequestDescriptor =
    $convert.base64Decode(
        'ChZXb3Jrc3BhY2VDcmVhdGVSZXF1ZXN0EhIKBG5hbWUYASABKAlSBG5hbWUSEgoEc2x1ZxgCIA'
        'EoCVIEc2x1Zw==');

@$core.Deprecated('Use workspaceDeleteRequestDescriptor instead')
const WorkspaceDeleteRequest$json = {
  '1': 'WorkspaceDeleteRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'confirmation', '3': 2, '4': 1, '5': 9, '10': 'confirmation'},
  ],
};

/// Descriptor for `WorkspaceDeleteRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List workspaceDeleteRequestDescriptor =
    $convert.base64Decode(
        'ChZXb3Jrc3BhY2VEZWxldGVSZXF1ZXN0Eg4KAmlkGAEgASgJUgJpZBIiCgxjb25maXJtYXRpb2'
        '4YAiABKAlSDGNvbmZpcm1hdGlvbg==');

@$core.Deprecated('Use workspaceListDescriptor instead')
const WorkspaceList$json = {
  '1': 'WorkspaceList',
  '2': [
    {
      '1': 'workspaces',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.config.workspaces.Workspace',
      '10': 'workspaces'
    },
  ],
};

/// Descriptor for `WorkspaceList`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List workspaceListDescriptor = $convert.base64Decode(
    'Cg1Xb3Jrc3BhY2VMaXN0EjwKCndvcmtzcGFjZXMYASADKAsyHC5jb25maWcud29ya3NwYWNlcy'
    '5Xb3Jrc3BhY2VSCndvcmtzcGFjZXM=');

@$core.Deprecated('Use workspaceRestoreRequestDescriptor instead')
const WorkspaceRestoreRequest$json = {
  '1': 'WorkspaceRestoreRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `WorkspaceRestoreRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List workspaceRestoreRequestDescriptor = $convert
    .base64Decode('ChdXb3Jrc3BhY2VSZXN0b3JlUmVxdWVzdBIOCgJpZBgBIAEoCVICaWQ=');

@$core.Deprecated('Use workspaceUpdateRequestDescriptor instead')
const WorkspaceUpdateRequest$json = {
  '1': 'WorkspaceUpdateRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'expected_version', '3': 2, '4': 1, '5': 5, '10': 'expectedVersion'},
    {'1': 'name', '3': 3, '4': 1, '5': 9, '9': 0, '10': 'name', '17': true},
    {'1': 'slug', '3': 4, '4': 1, '5': 9, '9': 1, '10': 'slug', '17': true},
  ],
  '8': [
    {'1': '_name'},
    {'1': '_slug'},
  ],
};

/// Descriptor for `WorkspaceUpdateRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List workspaceUpdateRequestDescriptor = $convert.base64Decode(
    'ChZXb3Jrc3BhY2VVcGRhdGVSZXF1ZXN0Eg4KAmlkGAEgASgJUgJpZBIpChBleHBlY3RlZF92ZX'
    'JzaW9uGAIgASgFUg9leHBlY3RlZFZlcnNpb24SFwoEbmFtZRgDIAEoCUgAUgRuYW1liAEBEhcK'
    'BHNsdWcYBCABKAlIAVIEc2x1Z4gBAUIHCgVfbmFtZUIHCgVfc2x1Zw==');
