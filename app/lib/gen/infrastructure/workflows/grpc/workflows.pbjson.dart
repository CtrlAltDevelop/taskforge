// This is a generated file - do not edit.
//
// Generated from infrastructure/workflows/grpc/workflows.proto.

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

@$core.Deprecated('Use migrationInputDescriptor instead')
const MigrationInput$json = {
  '1': 'MigrationInput',
  '2': [
    {'1': 'from_key', '3': 1, '4': 1, '5': 9, '10': 'fromKey'},
    {'1': 'to_key', '3': 2, '4': 1, '5': 9, '10': 'toKey'},
  ],
};

/// Descriptor for `MigrationInput`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List migrationInputDescriptor = $convert.base64Decode(
    'Cg5NaWdyYXRpb25JbnB1dBIZCghmcm9tX2tleRgBIAEoCVIHZnJvbUtleRIVCgZ0b19rZXkYAi'
    'ABKAlSBXRvS2V5');

@$core.Deprecated('Use statusInputDescriptor instead')
const StatusInput$json = {
  '1': 'StatusInput',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'color', '3': 3, '4': 1, '5': 9, '10': 'color'},
    {'1': 'category', '3': 4, '4': 1, '5': 9, '10': 'category'},
    {'1': 'is_default', '3': 5, '4': 1, '5': 8, '10': 'isDefault'},
  ],
};

/// Descriptor for `StatusInput`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List statusInputDescriptor = $convert.base64Decode(
    'CgtTdGF0dXNJbnB1dBIQCgNrZXkYASABKAlSA2tleRISCgRuYW1lGAIgASgJUgRuYW1lEhQKBW'
    'NvbG9yGAMgASgJUgVjb2xvchIaCghjYXRlZ29yeRgEIAEoCVIIY2F0ZWdvcnkSHQoKaXNfZGVm'
    'YXVsdBgFIAEoCFIJaXNEZWZhdWx0');

@$core.Deprecated('Use statusResponseDescriptor instead')
const StatusResponse$json = {
  '1': 'StatusResponse',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'color', '3': 3, '4': 1, '5': 9, '10': 'color'},
    {'1': 'category', '3': 4, '4': 1, '5': 9, '10': 'category'},
    {'1': 'position', '3': 5, '4': 1, '5': 5, '10': 'position'},
    {'1': 'is_default', '3': 6, '4': 1, '5': 8, '10': 'isDefault'},
    {'1': 'task_count', '3': 7, '4': 1, '5': 5, '10': 'taskCount'},
  ],
};

/// Descriptor for `StatusResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List statusResponseDescriptor = $convert.base64Decode(
    'Cg5TdGF0dXNSZXNwb25zZRIOCgJpZBgBIAEoCVICaWQSEgoEbmFtZRgCIAEoCVIEbmFtZRIUCg'
    'Vjb2xvchgDIAEoCVIFY29sb3ISGgoIY2F0ZWdvcnkYBCABKAlSCGNhdGVnb3J5EhoKCHBvc2l0'
    'aW9uGAUgASgFUghwb3NpdGlvbhIdCgppc19kZWZhdWx0GAYgASgIUglpc0RlZmF1bHQSHQoKdG'
    'Fza19jb3VudBgHIAEoBVIJdGFza0NvdW50');

@$core.Deprecated('Use transitionInputDescriptor instead')
const TransitionInput$json = {
  '1': 'TransitionInput',
  '2': [
    {'1': 'from_key', '3': 1, '4': 1, '5': 9, '10': 'fromKey'},
    {'1': 'to_key', '3': 2, '4': 1, '5': 9, '10': 'toKey'},
    {'1': 'required_role_id', '3': 3, '4': 1, '5': 9, '10': 'requiredRoleId'},
    {'1': 'require_assignee', '3': 4, '4': 1, '5': 8, '10': 'requireAssignee'},
    {
      '1': 'require_subtasks_done',
      '3': 5,
      '4': 1,
      '5': 8,
      '10': 'requireSubtasksDone'
    },
  ],
};

/// Descriptor for `TransitionInput`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List transitionInputDescriptor = $convert.base64Decode(
    'Cg9UcmFuc2l0aW9uSW5wdXQSGQoIZnJvbV9rZXkYASABKAlSB2Zyb21LZXkSFQoGdG9fa2V5GA'
    'IgASgJUgV0b0tleRIoChByZXF1aXJlZF9yb2xlX2lkGAMgASgJUg5yZXF1aXJlZFJvbGVJZBIp'
    'ChByZXF1aXJlX2Fzc2lnbmVlGAQgASgIUg9yZXF1aXJlQXNzaWduZWUSMgoVcmVxdWlyZV9zdW'
    'J0YXNrc19kb25lGAUgASgIUhNyZXF1aXJlU3VidGFza3NEb25l');

@$core.Deprecated('Use transitionResponseDescriptor instead')
const TransitionResponse$json = {
  '1': 'TransitionResponse',
  '2': [
    {'1': 'from_status', '3': 1, '4': 1, '5': 9, '10': 'fromStatus'},
    {'1': 'to_status', '3': 2, '4': 1, '5': 9, '10': 'toStatus'},
    {'1': 'required_role_id', '3': 3, '4': 1, '5': 9, '10': 'requiredRoleId'},
    {'1': 'require_assignee', '3': 4, '4': 1, '5': 8, '10': 'requireAssignee'},
    {
      '1': 'require_subtasks_done',
      '3': 5,
      '4': 1,
      '5': 8,
      '10': 'requireSubtasksDone'
    },
  ],
};

/// Descriptor for `TransitionResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List transitionResponseDescriptor = $convert.base64Decode(
    'ChJUcmFuc2l0aW9uUmVzcG9uc2USHwoLZnJvbV9zdGF0dXMYASABKAlSCmZyb21TdGF0dXMSGw'
    'oJdG9fc3RhdHVzGAIgASgJUgh0b1N0YXR1cxIoChByZXF1aXJlZF9yb2xlX2lkGAMgASgJUg5y'
    'ZXF1aXJlZFJvbGVJZBIpChByZXF1aXJlX2Fzc2lnbmVlGAQgASgIUg9yZXF1aXJlQXNzaWduZW'
    'USMgoVcmVxdWlyZV9zdWJ0YXNrc19kb25lGAUgASgIUhNyZXF1aXJlU3VidGFza3NEb25l');

@$core.Deprecated('Use workflowDescriptor instead')
const Workflow$json = {
  '1': 'Workflow',
  '2': [
    {'1': 'project_id', '3': 1, '4': 1, '5': 9, '10': 'projectId'},
    {
      '1': 'restrict_transitions',
      '3': 2,
      '4': 1,
      '5': 8,
      '10': 'restrictTransitions'
    },
    {'1': 'version', '3': 3, '4': 1, '5': 5, '10': 'version'},
    {
      '1': 'statuses',
      '3': 4,
      '4': 3,
      '5': 11,
      '6': '.config.workflows.StatusResponse',
      '10': 'statuses'
    },
    {
      '1': 'transitions',
      '3': 5,
      '4': 3,
      '5': 11,
      '6': '.config.workflows.TransitionResponse',
      '10': 'transitions'
    },
    {
      '1': 'restrict_creation',
      '3': 6,
      '4': 1,
      '5': 8,
      '10': 'restrictCreation'
    },
  ],
};

/// Descriptor for `Workflow`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List workflowDescriptor = $convert.base64Decode(
    'CghXb3JrZmxvdxIdCgpwcm9qZWN0X2lkGAEgASgJUglwcm9qZWN0SWQSMQoUcmVzdHJpY3RfdH'
    'JhbnNpdGlvbnMYAiABKAhSE3Jlc3RyaWN0VHJhbnNpdGlvbnMSGAoHdmVyc2lvbhgDIAEoBVIH'
    'dmVyc2lvbhI8CghzdGF0dXNlcxgEIAMoCzIgLmNvbmZpZy53b3JrZmxvd3MuU3RhdHVzUmVzcG'
    '9uc2VSCHN0YXR1c2VzEkYKC3RyYW5zaXRpb25zGAUgAygLMiQuY29uZmlnLndvcmtmbG93cy5U'
    'cmFuc2l0aW9uUmVzcG9uc2VSC3RyYW5zaXRpb25zEisKEXJlc3RyaWN0X2NyZWF0aW9uGAYgAS'
    'gIUhByZXN0cmljdENyZWF0aW9u');

@$core.Deprecated('Use workflowGetRequestDescriptor instead')
const WorkflowGetRequest$json = {
  '1': 'WorkflowGetRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
  ],
};

/// Descriptor for `WorkflowGetRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List workflowGetRequestDescriptor = $convert.base64Decode(
    'ChJXb3JrZmxvd0dldFJlcXVlc3QSIQoMd29ya3NwYWNlX2lkGAEgASgJUgt3b3Jrc3BhY2VJZB'
    'IdCgpwcm9qZWN0X2lkGAIgASgJUglwcm9qZWN0SWQ=');

@$core.Deprecated('Use workflowProblemDescriptor instead')
const WorkflowProblem$json = {
  '1': 'WorkflowProblem',
  '2': [
    {'1': 'code', '3': 1, '4': 1, '5': 9, '10': 'code'},
    {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
    {'1': 'status_key', '3': 3, '4': 1, '5': 9, '10': 'statusKey'},
  ],
};

/// Descriptor for `WorkflowProblem`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List workflowProblemDescriptor = $convert.base64Decode(
    'Cg9Xb3JrZmxvd1Byb2JsZW0SEgoEY29kZRgBIAEoCVIEY29kZRIYCgdtZXNzYWdlGAIgASgJUg'
    'dtZXNzYWdlEh0KCnN0YXR1c19rZXkYAyABKAlSCXN0YXR1c0tleQ==');

@$core.Deprecated('Use workflowProblemsDescriptor instead')
const WorkflowProblems$json = {
  '1': 'WorkflowProblems',
  '2': [
    {
      '1': 'problems',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.config.workflows.WorkflowProblem',
      '10': 'problems'
    },
  ],
};

/// Descriptor for `WorkflowProblems`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List workflowProblemsDescriptor = $convert.base64Decode(
    'ChBXb3JrZmxvd1Byb2JsZW1zEj0KCHByb2JsZW1zGAEgAygLMiEuY29uZmlnLndvcmtmbG93cy'
    '5Xb3JrZmxvd1Byb2JsZW1SCHByb2JsZW1z');

@$core.Deprecated('Use workflowUpdateRequestDescriptor instead')
const WorkflowUpdateRequest$json = {
  '1': 'WorkflowUpdateRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'expected_version', '3': 3, '4': 1, '5': 5, '10': 'expectedVersion'},
    {
      '1': 'restrict_transitions',
      '3': 4,
      '4': 1,
      '5': 8,
      '10': 'restrictTransitions'
    },
    {
      '1': 'statuses',
      '3': 5,
      '4': 3,
      '5': 11,
      '6': '.config.workflows.StatusInput',
      '10': 'statuses'
    },
    {
      '1': 'transitions',
      '3': 6,
      '4': 3,
      '5': 11,
      '6': '.config.workflows.TransitionInput',
      '10': 'transitions'
    },
    {
      '1': 'migrations',
      '3': 7,
      '4': 3,
      '5': 11,
      '6': '.config.workflows.MigrationInput',
      '10': 'migrations'
    },
    {
      '1': 'restrict_creation',
      '3': 8,
      '4': 1,
      '5': 8,
      '10': 'restrictCreation'
    },
  ],
};

/// Descriptor for `WorkflowUpdateRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List workflowUpdateRequestDescriptor = $convert.base64Decode(
    'ChVXb3JrZmxvd1VwZGF0ZVJlcXVlc3QSIQoMd29ya3NwYWNlX2lkGAEgASgJUgt3b3Jrc3BhY2'
    'VJZBIdCgpwcm9qZWN0X2lkGAIgASgJUglwcm9qZWN0SWQSKQoQZXhwZWN0ZWRfdmVyc2lvbhgD'
    'IAEoBVIPZXhwZWN0ZWRWZXJzaW9uEjEKFHJlc3RyaWN0X3RyYW5zaXRpb25zGAQgASgIUhNyZX'
    'N0cmljdFRyYW5zaXRpb25zEjkKCHN0YXR1c2VzGAUgAygLMh0uY29uZmlnLndvcmtmbG93cy5T'
    'dGF0dXNJbnB1dFIIc3RhdHVzZXMSQwoLdHJhbnNpdGlvbnMYBiADKAsyIS5jb25maWcud29ya2'
    'Zsb3dzLlRyYW5zaXRpb25JbnB1dFILdHJhbnNpdGlvbnMSQAoKbWlncmF0aW9ucxgHIAMoCzIg'
    'LmNvbmZpZy53b3JrZmxvd3MuTWlncmF0aW9uSW5wdXRSCm1pZ3JhdGlvbnMSKwoRcmVzdHJpY3'
    'RfY3JlYXRpb24YCCABKAhSEHJlc3RyaWN0Q3JlYXRpb24=');

@$core.Deprecated('Use workflowValidateRequestDescriptor instead')
const WorkflowValidateRequest$json = {
  '1': 'WorkflowValidateRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
    {
      '1': 'restrict_transitions',
      '3': 3,
      '4': 1,
      '5': 8,
      '10': 'restrictTransitions'
    },
    {
      '1': 'statuses',
      '3': 4,
      '4': 3,
      '5': 11,
      '6': '.config.workflows.StatusInput',
      '10': 'statuses'
    },
    {
      '1': 'transitions',
      '3': 5,
      '4': 3,
      '5': 11,
      '6': '.config.workflows.TransitionInput',
      '10': 'transitions'
    },
    {
      '1': 'migrations',
      '3': 6,
      '4': 3,
      '5': 11,
      '6': '.config.workflows.MigrationInput',
      '10': 'migrations'
    },
    {
      '1': 'restrict_creation',
      '3': 7,
      '4': 1,
      '5': 8,
      '10': 'restrictCreation'
    },
  ],
};

/// Descriptor for `WorkflowValidateRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List workflowValidateRequestDescriptor = $convert.base64Decode(
    'ChdXb3JrZmxvd1ZhbGlkYXRlUmVxdWVzdBIhCgx3b3Jrc3BhY2VfaWQYASABKAlSC3dvcmtzcG'
    'FjZUlkEh0KCnByb2plY3RfaWQYAiABKAlSCXByb2plY3RJZBIxChRyZXN0cmljdF90cmFuc2l0'
    'aW9ucxgDIAEoCFITcmVzdHJpY3RUcmFuc2l0aW9ucxI5CghzdGF0dXNlcxgEIAMoCzIdLmNvbm'
    'ZpZy53b3JrZmxvd3MuU3RhdHVzSW5wdXRSCHN0YXR1c2VzEkMKC3RyYW5zaXRpb25zGAUgAygL'
    'MiEuY29uZmlnLndvcmtmbG93cy5UcmFuc2l0aW9uSW5wdXRSC3RyYW5zaXRpb25zEkAKCm1pZ3'
    'JhdGlvbnMYBiADKAsyIC5jb25maWcud29ya2Zsb3dzLk1pZ3JhdGlvbklucHV0UgptaWdyYXRp'
    'b25zEisKEXJlc3RyaWN0X2NyZWF0aW9uGAcgASgIUhByZXN0cmljdENyZWF0aW9u');
