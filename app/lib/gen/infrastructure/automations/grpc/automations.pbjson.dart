// This is a generated file - do not edit.
//
// Generated from infrastructure/automations/grpc/automations.proto.

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

@$core.Deprecated('Use automationDescriptor instead')
const Automation$json = {
  '1': 'Automation',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'workspace_id', '3': 2, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'project_id', '3': 3, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'name', '3': 4, '4': 1, '5': 9, '10': 'name'},
    {'1': 'enabled', '3': 5, '4': 1, '5': 8, '10': 'enabled'},
    {'1': 'trigger_json', '3': 6, '4': 1, '5': 9, '10': 'triggerJson'},
    {'1': 'condition_tfql', '3': 7, '4': 1, '5': 9, '10': 'conditionTfql'},
    {'1': 'condition_json', '3': 8, '4': 1, '5': 9, '10': 'conditionJson'},
    {'1': 'actions_json', '3': 9, '4': 1, '5': 9, '10': 'actionsJson'},
    {'1': 'owner_id', '3': 10, '4': 1, '5': 9, '10': 'ownerId'},
    {'1': 'disabled_reason', '3': 11, '4': 1, '5': 9, '10': 'disabledReason'},
    {'1': 'version', '3': 12, '4': 1, '5': 5, '10': 'version'},
    {'1': 'created_at', '3': 13, '4': 1, '5': 9, '10': 'createdAt'},
    {'1': 'updated_at', '3': 14, '4': 1, '5': 9, '10': 'updatedAt'},
    {'1': 'last_run_at', '3': 15, '4': 1, '5': 9, '10': 'lastRunAt'},
    {'1': 'last_run_status', '3': 16, '4': 1, '5': 9, '10': 'lastRunStatus'},
  ],
};

/// Descriptor for `Automation`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List automationDescriptor = $convert.base64Decode(
    'CgpBdXRvbWF0aW9uEg4KAmlkGAEgASgJUgJpZBIhCgx3b3Jrc3BhY2VfaWQYAiABKAlSC3dvcm'
    'tzcGFjZUlkEh0KCnByb2plY3RfaWQYAyABKAlSCXByb2plY3RJZBISCgRuYW1lGAQgASgJUgRu'
    'YW1lEhgKB2VuYWJsZWQYBSABKAhSB2VuYWJsZWQSIQoMdHJpZ2dlcl9qc29uGAYgASgJUgt0cm'
    'lnZ2VySnNvbhIlCg5jb25kaXRpb25fdGZxbBgHIAEoCVINY29uZGl0aW9uVGZxbBIlCg5jb25k'
    'aXRpb25fanNvbhgIIAEoCVINY29uZGl0aW9uSnNvbhIhCgxhY3Rpb25zX2pzb24YCSABKAlSC2'
    'FjdGlvbnNKc29uEhkKCG93bmVyX2lkGAogASgJUgdvd25lcklkEicKD2Rpc2FibGVkX3JlYXNv'
    'bhgLIAEoCVIOZGlzYWJsZWRSZWFzb24SGAoHdmVyc2lvbhgMIAEoBVIHdmVyc2lvbhIdCgpjcm'
    'VhdGVkX2F0GA0gASgJUgljcmVhdGVkQXQSHQoKdXBkYXRlZF9hdBgOIAEoCVIJdXBkYXRlZEF0'
    'Eh4KC2xhc3RfcnVuX2F0GA8gASgJUglsYXN0UnVuQXQSJgoPbGFzdF9ydW5fc3RhdHVzGBAgAS'
    'gJUg1sYXN0UnVuU3RhdHVz');

@$core.Deprecated('Use automationAnswerDescriptor instead')
const AutomationAnswer$json = {
  '1': 'AutomationAnswer',
  '2': [
    {
      '1': 'automation',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.config.automations.Automation',
      '10': 'automation'
    },
  ],
};

/// Descriptor for `AutomationAnswer`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List automationAnswerDescriptor = $convert.base64Decode(
    'ChBBdXRvbWF0aW9uQW5zd2VyEj4KCmF1dG9tYXRpb24YASABKAsyHi5jb25maWcuYXV0b21hdG'
    'lvbnMuQXV0b21hdGlvblIKYXV0b21hdGlvbg==');

@$core.Deprecated('Use automationCreateRequestDescriptor instead')
const AutomationCreateRequest$json = {
  '1': 'AutomationCreateRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'name', '3': 3, '4': 1, '5': 9, '10': 'name'},
    {'1': 'trigger_json', '3': 4, '4': 1, '5': 9, '10': 'triggerJson'},
    {'1': 'condition_tfql', '3': 5, '4': 1, '5': 9, '10': 'conditionTfql'},
    {'1': 'actions_json', '3': 6, '4': 1, '5': 9, '10': 'actionsJson'},
    {'1': 'enabled', '3': 7, '4': 1, '5': 8, '10': 'enabled'},
  ],
};

/// Descriptor for `AutomationCreateRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List automationCreateRequestDescriptor = $convert.base64Decode(
    'ChdBdXRvbWF0aW9uQ3JlYXRlUmVxdWVzdBIhCgx3b3Jrc3BhY2VfaWQYASABKAlSC3dvcmtzcG'
    'FjZUlkEh0KCnByb2plY3RfaWQYAiABKAlSCXByb2plY3RJZBISCgRuYW1lGAMgASgJUgRuYW1l'
    'EiEKDHRyaWdnZXJfanNvbhgEIAEoCVILdHJpZ2dlckpzb24SJQoOY29uZGl0aW9uX3RmcWwYBS'
    'ABKAlSDWNvbmRpdGlvblRmcWwSIQoMYWN0aW9uc19qc29uGAYgASgJUgthY3Rpb25zSnNvbhIY'
    'CgdlbmFibGVkGAcgASgIUgdlbmFibGVk');

@$core.Deprecated('Use automationDeleteRequestDescriptor instead')
const AutomationDeleteRequest$json = {
  '1': 'AutomationDeleteRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'automation_id', '3': 3, '4': 1, '5': 9, '10': 'automationId'},
  ],
};

/// Descriptor for `AutomationDeleteRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List automationDeleteRequestDescriptor = $convert.base64Decode(
    'ChdBdXRvbWF0aW9uRGVsZXRlUmVxdWVzdBIhCgx3b3Jrc3BhY2VfaWQYASABKAlSC3dvcmtzcG'
    'FjZUlkEh0KCnByb2plY3RfaWQYAiABKAlSCXByb2plY3RJZBIjCg1hdXRvbWF0aW9uX2lkGAMg'
    'ASgJUgxhdXRvbWF0aW9uSWQ=');

@$core.Deprecated('Use automationDeletedDescriptor instead')
const AutomationDeleted$json = {
  '1': 'AutomationDeleted',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `AutomationDeleted`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List automationDeletedDescriptor =
    $convert.base64Decode('ChFBdXRvbWF0aW9uRGVsZXRlZBIOCgJpZBgBIAEoCVICaWQ=');

@$core.Deprecated('Use automationDryRunAnswerDescriptor instead')
const AutomationDryRunAnswer$json = {
  '1': 'AutomationDryRunAnswer',
  '2': [
    {'1': 'would_run', '3': 1, '4': 1, '5': 8, '10': 'wouldRun'},
    {'1': 'status', '3': 2, '4': 1, '5': 9, '10': 'status'},
    {'1': 'explanation', '3': 3, '4': 1, '5': 9, '10': 'explanation'},
    {'1': 'error', '3': 4, '4': 1, '5': 9, '10': 'error'},
    {'1': 'steps_json', '3': 5, '4': 1, '5': 9, '10': 'stepsJson'},
  ],
};

/// Descriptor for `AutomationDryRunAnswer`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List automationDryRunAnswerDescriptor = $convert.base64Decode(
    'ChZBdXRvbWF0aW9uRHJ5UnVuQW5zd2VyEhsKCXdvdWxkX3J1bhgBIAEoCFIId291bGRSdW4SFg'
    'oGc3RhdHVzGAIgASgJUgZzdGF0dXMSIAoLZXhwbGFuYXRpb24YAyABKAlSC2V4cGxhbmF0aW9u'
    'EhQKBWVycm9yGAQgASgJUgVlcnJvchIdCgpzdGVwc19qc29uGAUgASgJUglzdGVwc0pzb24=');

@$core.Deprecated('Use automationDryRunRequestDescriptor instead')
const AutomationDryRunRequest$json = {
  '1': 'AutomationDryRunRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'automation_id', '3': 3, '4': 1, '5': 9, '10': 'automationId'},
    {'1': 'task_id', '3': 4, '4': 1, '5': 9, '10': 'taskId'},
  ],
};

/// Descriptor for `AutomationDryRunRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List automationDryRunRequestDescriptor = $convert.base64Decode(
    'ChdBdXRvbWF0aW9uRHJ5UnVuUmVxdWVzdBIhCgx3b3Jrc3BhY2VfaWQYASABKAlSC3dvcmtzcG'
    'FjZUlkEh0KCnByb2plY3RfaWQYAiABKAlSCXByb2plY3RJZBIjCg1hdXRvbWF0aW9uX2lkGAMg'
    'ASgJUgxhdXRvbWF0aW9uSWQSFwoHdGFza19pZBgEIAEoCVIGdGFza0lk');

@$core.Deprecated('Use automationListDescriptor instead')
const AutomationList$json = {
  '1': 'AutomationList',
  '2': [
    {
      '1': 'automations',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.config.automations.Automation',
      '10': 'automations'
    },
  ],
};

/// Descriptor for `AutomationList`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List automationListDescriptor = $convert.base64Decode(
    'Cg5BdXRvbWF0aW9uTGlzdBJACgthdXRvbWF0aW9ucxgBIAMoCzIeLmNvbmZpZy5hdXRvbWF0aW'
    '9ucy5BdXRvbWF0aW9uUgthdXRvbWF0aW9ucw==');

@$core.Deprecated('Use automationListRequestDescriptor instead')
const AutomationListRequest$json = {
  '1': 'AutomationListRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
  ],
};

/// Descriptor for `AutomationListRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List automationListRequestDescriptor = $convert.base64Decode(
    'ChVBdXRvbWF0aW9uTGlzdFJlcXVlc3QSIQoMd29ya3NwYWNlX2lkGAEgASgJUgt3b3Jrc3BhY2'
    'VJZBIdCgpwcm9qZWN0X2lkGAIgASgJUglwcm9qZWN0SWQ=');

@$core.Deprecated('Use automationRunDescriptor instead')
const AutomationRun$json = {
  '1': 'AutomationRun',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'automation_id', '3': 2, '4': 1, '5': 9, '10': 'automationId'},
    {'1': 'automation_name', '3': 3, '4': 1, '5': 9, '10': 'automationName'},
    {'1': 'task_id', '3': 4, '4': 1, '5': 9, '10': 'taskId'},
    {'1': 'task_key', '3': 5, '4': 1, '5': 9, '10': 'taskKey'},
    {'1': 'status', '3': 6, '4': 1, '5': 9, '10': 'status'},
    {'1': 'depth', '3': 7, '4': 1, '5': 5, '10': 'depth'},
    {'1': 'event_key', '3': 8, '4': 1, '5': 9, '10': 'eventKey'},
    {'1': 'input_json', '3': 9, '4': 1, '5': 9, '10': 'inputJson'},
    {'1': 'steps_json', '3': 10, '4': 1, '5': 9, '10': 'stepsJson'},
    {'1': 'error', '3': 11, '4': 1, '5': 9, '10': 'error'},
    {'1': 'explanation', '3': 12, '4': 1, '5': 9, '10': 'explanation'},
    {'1': 'started_at', '3': 13, '4': 1, '5': 9, '10': 'startedAt'},
    {'1': 'finished_at', '3': 14, '4': 1, '5': 9, '10': 'finishedAt'},
  ],
};

/// Descriptor for `AutomationRun`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List automationRunDescriptor = $convert.base64Decode(
    'Cg1BdXRvbWF0aW9uUnVuEg4KAmlkGAEgASgJUgJpZBIjCg1hdXRvbWF0aW9uX2lkGAIgASgJUg'
    'xhdXRvbWF0aW9uSWQSJwoPYXV0b21hdGlvbl9uYW1lGAMgASgJUg5hdXRvbWF0aW9uTmFtZRIX'
    'Cgd0YXNrX2lkGAQgASgJUgZ0YXNrSWQSGQoIdGFza19rZXkYBSABKAlSB3Rhc2tLZXkSFgoGc3'
    'RhdHVzGAYgASgJUgZzdGF0dXMSFAoFZGVwdGgYByABKAVSBWRlcHRoEhsKCWV2ZW50X2tleRgI'
    'IAEoCVIIZXZlbnRLZXkSHQoKaW5wdXRfanNvbhgJIAEoCVIJaW5wdXRKc29uEh0KCnN0ZXBzX2'
    'pzb24YCiABKAlSCXN0ZXBzSnNvbhIUCgVlcnJvchgLIAEoCVIFZXJyb3ISIAoLZXhwbGFuYXRp'
    'b24YDCABKAlSC2V4cGxhbmF0aW9uEh0KCnN0YXJ0ZWRfYXQYDSABKAlSCXN0YXJ0ZWRBdBIfCg'
    'tmaW5pc2hlZF9hdBgOIAEoCVIKZmluaXNoZWRBdA==');

@$core.Deprecated('Use automationRunAnswerDescriptor instead')
const AutomationRunAnswer$json = {
  '1': 'AutomationRunAnswer',
  '2': [
    {
      '1': 'run',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.config.automations.AutomationRun',
      '10': 'run'
    },
  ],
};

/// Descriptor for `AutomationRunAnswer`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List automationRunAnswerDescriptor = $convert.base64Decode(
    'ChNBdXRvbWF0aW9uUnVuQW5zd2VyEjMKA3J1bhgBIAEoCzIhLmNvbmZpZy5hdXRvbWF0aW9ucy'
    '5BdXRvbWF0aW9uUnVuUgNydW4=');

@$core.Deprecated('Use automationRunGetRequestDescriptor instead')
const AutomationRunGetRequest$json = {
  '1': 'AutomationRunGetRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'run_id', '3': 3, '4': 1, '5': 9, '10': 'runId'},
  ],
};

/// Descriptor for `AutomationRunGetRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List automationRunGetRequestDescriptor = $convert.base64Decode(
    'ChdBdXRvbWF0aW9uUnVuR2V0UmVxdWVzdBIhCgx3b3Jrc3BhY2VfaWQYASABKAlSC3dvcmtzcG'
    'FjZUlkEh0KCnByb2plY3RfaWQYAiABKAlSCXByb2plY3RJZBIVCgZydW5faWQYAyABKAlSBXJ1'
    'bklk');

@$core.Deprecated('Use automationRunListDescriptor instead')
const AutomationRunList$json = {
  '1': 'AutomationRunList',
  '2': [
    {
      '1': 'runs',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.config.automations.AutomationRun',
      '10': 'runs'
    },
  ],
};

/// Descriptor for `AutomationRunList`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List automationRunListDescriptor = $convert.base64Decode(
    'ChFBdXRvbWF0aW9uUnVuTGlzdBI1CgRydW5zGAEgAygLMiEuY29uZmlnLmF1dG9tYXRpb25zLk'
    'F1dG9tYXRpb25SdW5SBHJ1bnM=');

@$core.Deprecated('Use automationRunListRequestDescriptor instead')
const AutomationRunListRequest$json = {
  '1': 'AutomationRunListRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'automation_id', '3': 3, '4': 1, '5': 9, '10': 'automationId'},
    {'1': 'task_id', '3': 4, '4': 1, '5': 9, '10': 'taskId'},
    {'1': 'status', '3': 5, '4': 1, '5': 9, '10': 'status'},
    {'1': 'before', '3': 6, '4': 1, '5': 9, '10': 'before'},
    {'1': 'limit', '3': 7, '4': 1, '5': 5, '10': 'limit'},
  ],
};

/// Descriptor for `AutomationRunListRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List automationRunListRequestDescriptor = $convert.base64Decode(
    'ChhBdXRvbWF0aW9uUnVuTGlzdFJlcXVlc3QSIQoMd29ya3NwYWNlX2lkGAEgASgJUgt3b3Jrc3'
    'BhY2VJZBIdCgpwcm9qZWN0X2lkGAIgASgJUglwcm9qZWN0SWQSIwoNYXV0b21hdGlvbl9pZBgD'
    'IAEoCVIMYXV0b21hdGlvbklkEhcKB3Rhc2tfaWQYBCABKAlSBnRhc2tJZBIWCgZzdGF0dXMYBS'
    'ABKAlSBnN0YXR1cxIWCgZiZWZvcmUYBiABKAlSBmJlZm9yZRIUCgVsaW1pdBgHIAEoBVIFbGlt'
    'aXQ=');

@$core.Deprecated('Use automationToggleRequestDescriptor instead')
const AutomationToggleRequest$json = {
  '1': 'AutomationToggleRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'automation_id', '3': 3, '4': 1, '5': 9, '10': 'automationId'},
    {'1': 'enabled', '3': 4, '4': 1, '5': 8, '10': 'enabled'},
  ],
};

/// Descriptor for `AutomationToggleRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List automationToggleRequestDescriptor = $convert.base64Decode(
    'ChdBdXRvbWF0aW9uVG9nZ2xlUmVxdWVzdBIhCgx3b3Jrc3BhY2VfaWQYASABKAlSC3dvcmtzcG'
    'FjZUlkEh0KCnByb2plY3RfaWQYAiABKAlSCXByb2plY3RJZBIjCg1hdXRvbWF0aW9uX2lkGAMg'
    'ASgJUgxhdXRvbWF0aW9uSWQSGAoHZW5hYmxlZBgEIAEoCFIHZW5hYmxlZA==');

@$core.Deprecated('Use automationUpdateRequestDescriptor instead')
const AutomationUpdateRequest$json = {
  '1': 'AutomationUpdateRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'automation_id', '3': 3, '4': 1, '5': 9, '10': 'automationId'},
    {'1': 'fields', '3': 4, '4': 3, '5': 9, '10': 'fields'},
    {'1': 'expected_version', '3': 5, '4': 1, '5': 5, '10': 'expectedVersion'},
    {'1': 'name', '3': 6, '4': 1, '5': 9, '10': 'name'},
    {'1': 'trigger_json', '3': 7, '4': 1, '5': 9, '10': 'triggerJson'},
    {'1': 'condition_tfql', '3': 8, '4': 1, '5': 9, '10': 'conditionTfql'},
    {'1': 'actions_json', '3': 9, '4': 1, '5': 9, '10': 'actionsJson'},
  ],
};

/// Descriptor for `AutomationUpdateRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List automationUpdateRequestDescriptor = $convert.base64Decode(
    'ChdBdXRvbWF0aW9uVXBkYXRlUmVxdWVzdBIhCgx3b3Jrc3BhY2VfaWQYASABKAlSC3dvcmtzcG'
    'FjZUlkEh0KCnByb2plY3RfaWQYAiABKAlSCXByb2plY3RJZBIjCg1hdXRvbWF0aW9uX2lkGAMg'
    'ASgJUgxhdXRvbWF0aW9uSWQSFgoGZmllbGRzGAQgAygJUgZmaWVsZHMSKQoQZXhwZWN0ZWRfdm'
    'Vyc2lvbhgFIAEoBVIPZXhwZWN0ZWRWZXJzaW9uEhIKBG5hbWUYBiABKAlSBG5hbWUSIQoMdHJp'
    'Z2dlcl9qc29uGAcgASgJUgt0cmlnZ2VySnNvbhIlCg5jb25kaXRpb25fdGZxbBgIIAEoCVINY2'
    '9uZGl0aW9uVGZxbBIhCgxhY3Rpb25zX2pzb24YCSABKAlSC2FjdGlvbnNKc29u');
