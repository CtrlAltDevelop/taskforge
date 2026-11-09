// This is a generated file - do not edit.
//
// Generated from infrastructure/projects/grpc/projects.proto.

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

@$core.Deprecated('Use featureDescriptor instead')
const Feature$json = {
  '1': 'Feature',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'enabled', '3': 2, '4': 1, '5': 8, '10': 'enabled'},
  ],
};

/// Descriptor for `Feature`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List featureDescriptor = $convert.base64Decode(
    'CgdGZWF0dXJlEhAKA2tleRgBIAEoCVIDa2V5EhgKB2VuYWJsZWQYAiABKAhSB2VuYWJsZWQ=');

@$core.Deprecated('Use featureInfoDescriptor instead')
const FeatureInfo$json = {
  '1': 'FeatureInfo',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'label', '3': 2, '4': 1, '5': 9, '10': 'label'},
    {'1': 'description', '3': 3, '4': 1, '5': 9, '10': 'description'},
  ],
};

/// Descriptor for `FeatureInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List featureInfoDescriptor = $convert.base64Decode(
    'CgtGZWF0dXJlSW5mbxIQCgNrZXkYASABKAlSA2tleRIUCgVsYWJlbBgCIAEoCVIFbGFiZWwSIA'
    'oLZGVzY3JpcHRpb24YAyABKAlSC2Rlc2NyaXB0aW9u');

@$core.Deprecated('Use featureResponseDescriptor instead')
const FeatureResponse$json = {
  '1': 'FeatureResponse',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'enabled', '3': 2, '4': 1, '5': 8, '10': 'enabled'},
  ],
};

/// Descriptor for `FeatureResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List featureResponseDescriptor = $convert.base64Decode(
    'Cg9GZWF0dXJlUmVzcG9uc2USEAoDa2V5GAEgASgJUgNrZXkSGAoHZW5hYmxlZBgCIAEoCFIHZW'
    '5hYmxlZA==');

@$core.Deprecated('Use privateProjectListDescriptor instead')
const PrivateProjectList$json = {
  '1': 'PrivateProjectList',
  '2': [
    {
      '1': 'projects',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.config.projects.Project',
      '10': 'projects'
    },
  ],
};

/// Descriptor for `PrivateProjectList`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List privateProjectListDescriptor = $convert.base64Decode(
    'ChJQcml2YXRlUHJvamVjdExpc3QSNAoIcHJvamVjdHMYASADKAsyGC5jb25maWcucHJvamVjdH'
    'MuUHJvamVjdFIIcHJvamVjdHM=');

@$core.Deprecated('Use projectDescriptor instead')
const Project$json = {
  '1': 'Project',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'workspace_id', '3': 2, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'name', '3': 3, '4': 1, '5': 9, '10': 'name'},
    {'1': 'key', '3': 4, '4': 1, '5': 9, '10': 'key'},
    {'1': 'description', '3': 5, '4': 1, '5': 9, '10': 'description'},
    {'1': 'icon', '3': 6, '4': 1, '5': 9, '10': 'icon'},
    {'1': 'color', '3': 7, '4': 1, '5': 9, '10': 'color'},
    {'1': 'visibility', '3': 8, '4': 1, '5': 9, '10': 'visibility'},
    {'1': 'archived_at', '3': 9, '4': 1, '5': 9, '10': 'archivedAt'},
    {'1': 'version', '3': 10, '4': 1, '5': 5, '10': 'version'},
    {'1': 'task_counter', '3': 11, '4': 1, '5': 5, '10': 'taskCounter'},
    {
      '1': 'features',
      '3': 12,
      '4': 3,
      '5': 11,
      '6': '.config.projects.Feature',
      '10': 'features'
    },
    {'1': 'is_favorite', '3': 13, '4': 1, '5': 8, '10': 'isFavorite'},
    {'1': 'member_count', '3': 14, '4': 1, '5': 5, '10': 'memberCount'},
    {'1': 'is_member', '3': 15, '4': 1, '5': 8, '10': 'isMember'},
    {'1': 'can_open', '3': 16, '4': 1, '5': 8, '10': 'canOpen'},
    {'1': 'created_by', '3': 17, '4': 1, '5': 9, '10': 'createdBy'},
  ],
};

/// Descriptor for `Project`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List projectDescriptor = $convert.base64Decode(
    'CgdQcm9qZWN0Eg4KAmlkGAEgASgJUgJpZBIhCgx3b3Jrc3BhY2VfaWQYAiABKAlSC3dvcmtzcG'
    'FjZUlkEhIKBG5hbWUYAyABKAlSBG5hbWUSEAoDa2V5GAQgASgJUgNrZXkSIAoLZGVzY3JpcHRp'
    'b24YBSABKAlSC2Rlc2NyaXB0aW9uEhIKBGljb24YBiABKAlSBGljb24SFAoFY29sb3IYByABKA'
    'lSBWNvbG9yEh4KCnZpc2liaWxpdHkYCCABKAlSCnZpc2liaWxpdHkSHwoLYXJjaGl2ZWRfYXQY'
    'CSABKAlSCmFyY2hpdmVkQXQSGAoHdmVyc2lvbhgKIAEoBVIHdmVyc2lvbhIhCgx0YXNrX2NvdW'
    '50ZXIYCyABKAVSC3Rhc2tDb3VudGVyEjQKCGZlYXR1cmVzGAwgAygLMhguY29uZmlnLnByb2pl'
    'Y3RzLkZlYXR1cmVSCGZlYXR1cmVzEh8KC2lzX2Zhdm9yaXRlGA0gASgIUgppc0Zhdm9yaXRlEi'
    'EKDG1lbWJlcl9jb3VudBgOIAEoBVILbWVtYmVyQ291bnQSGwoJaXNfbWVtYmVyGA8gASgIUghp'
    'c01lbWJlchIZCghjYW5fb3BlbhgQIAEoCFIHY2FuT3BlbhIdCgpjcmVhdGVkX2J5GBEgASgJUg'
    'ljcmVhdGVkQnk=');

@$core.Deprecated('Use projectAddMemberRequestDescriptor instead')
const ProjectAddMemberRequest$json = {
  '1': 'ProjectAddMemberRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'user_id', '3': 3, '4': 1, '5': 9, '10': 'userId'},
  ],
};

/// Descriptor for `ProjectAddMemberRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List projectAddMemberRequestDescriptor = $convert.base64Decode(
    'ChdQcm9qZWN0QWRkTWVtYmVyUmVxdWVzdBIhCgx3b3Jrc3BhY2VfaWQYASABKAlSC3dvcmtzcG'
    'FjZUlkEh0KCnByb2plY3RfaWQYAiABKAlSCXByb2plY3RJZBIXCgd1c2VyX2lkGAMgASgJUgZ1'
    'c2VySWQ=');

@$core.Deprecated('Use projectArchiveRequestDescriptor instead')
const ProjectArchiveRequest$json = {
  '1': 'ProjectArchiveRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'id', '3': 2, '4': 1, '5': 9, '10': 'id'},
    {'1': 'expected_version', '3': 3, '4': 1, '5': 5, '10': 'expectedVersion'},
  ],
};

/// Descriptor for `ProjectArchiveRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List projectArchiveRequestDescriptor = $convert.base64Decode(
    'ChVQcm9qZWN0QXJjaGl2ZVJlcXVlc3QSIQoMd29ya3NwYWNlX2lkGAEgASgJUgt3b3Jrc3BhY2'
    'VJZBIOCgJpZBgCIAEoCVICaWQSKQoQZXhwZWN0ZWRfdmVyc2lvbhgDIAEoBVIPZXhwZWN0ZWRW'
    'ZXJzaW9u');

@$core.Deprecated('Use projectCreateRequestDescriptor instead')
const ProjectCreateRequest$json = {
  '1': 'ProjectCreateRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'key', '3': 3, '4': 1, '5': 9, '10': 'key'},
    {'1': 'description', '3': 4, '4': 1, '5': 9, '10': 'description'},
    {'1': 'icon', '3': 5, '4': 1, '5': 9, '10': 'icon'},
    {'1': 'color', '3': 6, '4': 1, '5': 9, '10': 'color'},
    {'1': 'visibility', '3': 7, '4': 1, '5': 9, '10': 'visibility'},
  ],
};

/// Descriptor for `ProjectCreateRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List projectCreateRequestDescriptor = $convert.base64Decode(
    'ChRQcm9qZWN0Q3JlYXRlUmVxdWVzdBIhCgx3b3Jrc3BhY2VfaWQYASABKAlSC3dvcmtzcGFjZU'
    'lkEhIKBG5hbWUYAiABKAlSBG5hbWUSEAoDa2V5GAMgASgJUgNrZXkSIAoLZGVzY3JpcHRpb24Y'
    'BCABKAlSC2Rlc2NyaXB0aW9uEhIKBGljb24YBSABKAlSBGljb24SFAoFY29sb3IYBiABKAlSBW'
    'NvbG9yEh4KCnZpc2liaWxpdHkYByABKAlSCnZpc2liaWxpdHk=');

@$core.Deprecated('Use projectEmptyDescriptor instead')
const ProjectEmpty$json = {
  '1': 'ProjectEmpty',
};

/// Descriptor for `ProjectEmpty`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List projectEmptyDescriptor =
    $convert.base64Decode('CgxQcm9qZWN0RW1wdHk=');

@$core.Deprecated('Use projectFavoriteRequestDescriptor instead')
const ProjectFavoriteRequest$json = {
  '1': 'ProjectFavoriteRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'favorite', '3': 3, '4': 1, '5': 8, '10': 'favorite'},
  ],
};

/// Descriptor for `ProjectFavoriteRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List projectFavoriteRequestDescriptor = $convert.base64Decode(
    'ChZQcm9qZWN0RmF2b3JpdGVSZXF1ZXN0EiEKDHdvcmtzcGFjZV9pZBgBIAEoCVILd29ya3NwYW'
    'NlSWQSHQoKcHJvamVjdF9pZBgCIAEoCVIJcHJvamVjdElkEhoKCGZhdm9yaXRlGAMgASgIUghm'
    'YXZvcml0ZQ==');

@$core.Deprecated('Use projectGetRequestDescriptor instead')
const ProjectGetRequest$json = {
  '1': 'ProjectGetRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'id', '3': 2, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `ProjectGetRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List projectGetRequestDescriptor = $convert.base64Decode(
    'ChFQcm9qZWN0R2V0UmVxdWVzdBIhCgx3b3Jrc3BhY2VfaWQYASABKAlSC3dvcmtzcGFjZUlkEg'
    '4KAmlkGAIgASgJUgJpZA==');

@$core.Deprecated('Use projectListDescriptor instead')
const ProjectList$json = {
  '1': 'ProjectList',
  '2': [
    {
      '1': 'projects',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.config.projects.Project',
      '10': 'projects'
    },
    {
      '1': 'feature_info',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.config.projects.FeatureInfo',
      '10': 'featureInfo'
    },
  ],
};

/// Descriptor for `ProjectList`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List projectListDescriptor = $convert.base64Decode(
    'CgtQcm9qZWN0TGlzdBI0Cghwcm9qZWN0cxgBIAMoCzIYLmNvbmZpZy5wcm9qZWN0cy5Qcm9qZW'
    'N0Ughwcm9qZWN0cxI/CgxmZWF0dXJlX2luZm8YAiADKAsyHC5jb25maWcucHJvamVjdHMuRmVh'
    'dHVyZUluZm9SC2ZlYXR1cmVJbmZv');

@$core.Deprecated('Use projectListMembersRequestDescriptor instead')
const ProjectListMembersRequest$json = {
  '1': 'ProjectListMembersRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
  ],
};

/// Descriptor for `ProjectListMembersRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List projectListMembersRequestDescriptor =
    $convert.base64Decode(
        'ChlQcm9qZWN0TGlzdE1lbWJlcnNSZXF1ZXN0EiEKDHdvcmtzcGFjZV9pZBgBIAEoCVILd29ya3'
        'NwYWNlSWQSHQoKcHJvamVjdF9pZBgCIAEoCVIJcHJvamVjdElk');

@$core.Deprecated('Use projectListPrivateRequestDescriptor instead')
const ProjectListPrivateRequest$json = {
  '1': 'ProjectListPrivateRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
  ],
};

/// Descriptor for `ProjectListPrivateRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List projectListPrivateRequestDescriptor =
    $convert.base64Decode(
        'ChlQcm9qZWN0TGlzdFByaXZhdGVSZXF1ZXN0EiEKDHdvcmtzcGFjZV9pZBgBIAEoCVILd29ya3'
        'NwYWNlSWQ=');

@$core.Deprecated('Use projectListRequestDescriptor instead')
const ProjectListRequest$json = {
  '1': 'ProjectListRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'include_archived', '3': 2, '4': 1, '5': 8, '10': 'includeArchived'},
  ],
};

/// Descriptor for `ProjectListRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List projectListRequestDescriptor = $convert.base64Decode(
    'ChJQcm9qZWN0TGlzdFJlcXVlc3QSIQoMd29ya3NwYWNlX2lkGAEgASgJUgt3b3Jrc3BhY2VJZB'
    'IpChBpbmNsdWRlX2FyY2hpdmVkGAIgASgIUg9pbmNsdWRlQXJjaGl2ZWQ=');

@$core.Deprecated('Use projectMemberDescriptor instead')
const ProjectMember$json = {
  '1': 'ProjectMember',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'display_name', '3': 2, '4': 1, '5': 9, '10': 'displayName'},
    {'1': 'email', '3': 3, '4': 1, '5': 9, '10': 'email'},
    {'1': 'added_at', '3': 4, '4': 1, '5': 9, '10': 'addedAt'},
  ],
};

/// Descriptor for `ProjectMember`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List projectMemberDescriptor = $convert.base64Decode(
    'Cg1Qcm9qZWN0TWVtYmVyEhcKB3VzZXJfaWQYASABKAlSBnVzZXJJZBIhCgxkaXNwbGF5X25hbW'
    'UYAiABKAlSC2Rpc3BsYXlOYW1lEhQKBWVtYWlsGAMgASgJUgVlbWFpbBIZCghhZGRlZF9hdBgE'
    'IAEoCVIHYWRkZWRBdA==');

@$core.Deprecated('Use projectMemberListDescriptor instead')
const ProjectMemberList$json = {
  '1': 'ProjectMemberList',
  '2': [
    {
      '1': 'members',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.config.projects.ProjectMember',
      '10': 'members'
    },
  ],
};

/// Descriptor for `ProjectMemberList`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List projectMemberListDescriptor = $convert.base64Decode(
    'ChFQcm9qZWN0TWVtYmVyTGlzdBI4CgdtZW1iZXJzGAEgAygLMh4uY29uZmlnLnByb2plY3RzLl'
    'Byb2plY3RNZW1iZXJSB21lbWJlcnM=');

@$core.Deprecated('Use projectRemoveMemberRequestDescriptor instead')
const ProjectRemoveMemberRequest$json = {
  '1': 'ProjectRemoveMemberRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'user_id', '3': 3, '4': 1, '5': 9, '10': 'userId'},
  ],
};

/// Descriptor for `ProjectRemoveMemberRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List projectRemoveMemberRequestDescriptor =
    $convert.base64Decode(
        'ChpQcm9qZWN0UmVtb3ZlTWVtYmVyUmVxdWVzdBIhCgx3b3Jrc3BhY2VfaWQYASABKAlSC3dvcm'
        'tzcGFjZUlkEh0KCnByb2plY3RfaWQYAiABKAlSCXByb2plY3RJZBIXCgd1c2VyX2lkGAMgASgJ'
        'UgZ1c2VySWQ=');

@$core.Deprecated('Use projectRestoreRequestDescriptor instead')
const ProjectRestoreRequest$json = {
  '1': 'ProjectRestoreRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'id', '3': 2, '4': 1, '5': 9, '10': 'id'},
    {'1': 'expected_version', '3': 3, '4': 1, '5': 5, '10': 'expectedVersion'},
  ],
};

/// Descriptor for `ProjectRestoreRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List projectRestoreRequestDescriptor = $convert.base64Decode(
    'ChVQcm9qZWN0UmVzdG9yZVJlcXVlc3QSIQoMd29ya3NwYWNlX2lkGAEgASgJUgt3b3Jrc3BhY2'
    'VJZBIOCgJpZBgCIAEoCVICaWQSKQoQZXhwZWN0ZWRfdmVyc2lvbhgDIAEoBVIPZXhwZWN0ZWRW'
    'ZXJzaW9u');

@$core.Deprecated('Use projectSetFeaturesRequestDescriptor instead')
const ProjectSetFeaturesRequest$json = {
  '1': 'ProjectSetFeaturesRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'enabled_keys', '3': 3, '4': 3, '5': 9, '10': 'enabledKeys'},
    {'1': 'expected_version', '3': 4, '4': 1, '5': 5, '10': 'expectedVersion'},
  ],
};

/// Descriptor for `ProjectSetFeaturesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List projectSetFeaturesRequestDescriptor = $convert.base64Decode(
    'ChlQcm9qZWN0U2V0RmVhdHVyZXNSZXF1ZXN0EiEKDHdvcmtzcGFjZV9pZBgBIAEoCVILd29ya3'
    'NwYWNlSWQSHQoKcHJvamVjdF9pZBgCIAEoCVIJcHJvamVjdElkEiEKDGVuYWJsZWRfa2V5cxgD'
    'IAMoCVILZW5hYmxlZEtleXMSKQoQZXhwZWN0ZWRfdmVyc2lvbhgEIAEoBVIPZXhwZWN0ZWRWZX'
    'JzaW9u');

@$core.Deprecated('Use projectUpdateRequestDescriptor instead')
const ProjectUpdateRequest$json = {
  '1': 'ProjectUpdateRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'id', '3': 2, '4': 1, '5': 9, '10': 'id'},
    {'1': 'expected_version', '3': 3, '4': 1, '5': 5, '10': 'expectedVersion'},
    {'1': 'name', '3': 4, '4': 1, '5': 9, '9': 0, '10': 'name', '17': true},
    {'1': 'key', '3': 5, '4': 1, '5': 9, '9': 1, '10': 'key', '17': true},
    {
      '1': 'description',
      '3': 6,
      '4': 1,
      '5': 9,
      '9': 2,
      '10': 'description',
      '17': true
    },
    {'1': 'icon', '3': 7, '4': 1, '5': 9, '9': 3, '10': 'icon', '17': true},
    {'1': 'color', '3': 8, '4': 1, '5': 9, '9': 4, '10': 'color', '17': true},
    {
      '1': 'visibility',
      '3': 9,
      '4': 1,
      '5': 9,
      '9': 5,
      '10': 'visibility',
      '17': true
    },
  ],
  '8': [
    {'1': '_name'},
    {'1': '_key'},
    {'1': '_description'},
    {'1': '_icon'},
    {'1': '_color'},
    {'1': '_visibility'},
  ],
};

/// Descriptor for `ProjectUpdateRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List projectUpdateRequestDescriptor = $convert.base64Decode(
    'ChRQcm9qZWN0VXBkYXRlUmVxdWVzdBIhCgx3b3Jrc3BhY2VfaWQYASABKAlSC3dvcmtzcGFjZU'
    'lkEg4KAmlkGAIgASgJUgJpZBIpChBleHBlY3RlZF92ZXJzaW9uGAMgASgFUg9leHBlY3RlZFZl'
    'cnNpb24SFwoEbmFtZRgEIAEoCUgAUgRuYW1liAEBEhUKA2tleRgFIAEoCUgBUgNrZXmIAQESJQ'
    'oLZGVzY3JpcHRpb24YBiABKAlIAlILZGVzY3JpcHRpb26IAQESFwoEaWNvbhgHIAEoCUgDUgRp'
    'Y29uiAEBEhkKBWNvbG9yGAggASgJSARSBWNvbG9yiAEBEiMKCnZpc2liaWxpdHkYCSABKAlIBV'
    'IKdmlzaWJpbGl0eYgBAUIHCgVfbmFtZUIGCgRfa2V5Qg4KDF9kZXNjcmlwdGlvbkIHCgVfaWNv'
    'bkIICgZfY29sb3JCDQoLX3Zpc2liaWxpdHk=');
