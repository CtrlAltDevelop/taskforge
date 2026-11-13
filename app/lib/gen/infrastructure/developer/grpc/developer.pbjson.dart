// This is a generated file - do not edit.
//
// Generated from infrastructure/developer/grpc/developer.proto.

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

@$core.Deprecated('Use apiTokenDescriptor instead')
const ApiToken$json = {
  '1': 'ApiToken',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'prefix', '3': 3, '4': 1, '5': 9, '10': 'prefix'},
    {'1': 'scopes', '3': 4, '4': 3, '5': 9, '10': 'scopes'},
    {'1': 'status', '3': 5, '4': 1, '5': 9, '10': 'status'},
    {'1': 'expires_at', '3': 6, '4': 1, '5': 9, '10': 'expiresAt'},
    {'1': 'last_used_at', '3': 7, '4': 1, '5': 9, '10': 'lastUsedAt'},
    {'1': 'revoked_at', '3': 8, '4': 1, '5': 9, '10': 'revokedAt'},
    {'1': 'created_at', '3': 9, '4': 1, '5': 9, '10': 'createdAt'},
  ],
};

/// Descriptor for `ApiToken`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List apiTokenDescriptor = $convert.base64Decode(
    'CghBcGlUb2tlbhIOCgJpZBgBIAEoCVICaWQSEgoEbmFtZRgCIAEoCVIEbmFtZRIWCgZwcmVmaX'
    'gYAyABKAlSBnByZWZpeBIWCgZzY29wZXMYBCADKAlSBnNjb3BlcxIWCgZzdGF0dXMYBSABKAlS'
    'BnN0YXR1cxIdCgpleHBpcmVzX2F0GAYgASgJUglleHBpcmVzQXQSIAoMbGFzdF91c2VkX2F0GA'
    'cgASgJUgpsYXN0VXNlZEF0Eh0KCnJldm9rZWRfYXQYCCABKAlSCXJldm9rZWRBdBIdCgpjcmVh'
    'dGVkX2F0GAkgASgJUgljcmVhdGVkQXQ=');

@$core.Deprecated('Use apiTokenAnswerDescriptor instead')
const ApiTokenAnswer$json = {
  '1': 'ApiTokenAnswer',
  '2': [
    {
      '1': 'token',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.config.developer.ApiToken',
      '10': 'token'
    },
  ],
};

/// Descriptor for `ApiTokenAnswer`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List apiTokenAnswerDescriptor = $convert.base64Decode(
    'Cg5BcGlUb2tlbkFuc3dlchIwCgV0b2tlbhgBIAEoCzIaLmNvbmZpZy5kZXZlbG9wZXIuQXBpVG'
    '9rZW5SBXRva2Vu');

@$core.Deprecated('Use apiTokenCreateRequestDescriptor instead')
const ApiTokenCreateRequest$json = {
  '1': 'ApiTokenCreateRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'scopes', '3': 3, '4': 3, '5': 9, '10': 'scopes'},
    {'1': 'expires_in_days', '3': 4, '4': 1, '5': 5, '10': 'expiresInDays'},
  ],
};

/// Descriptor for `ApiTokenCreateRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List apiTokenCreateRequestDescriptor = $convert.base64Decode(
    'ChVBcGlUb2tlbkNyZWF0ZVJlcXVlc3QSIQoMd29ya3NwYWNlX2lkGAEgASgJUgt3b3Jrc3BhY2'
    'VJZBISCgRuYW1lGAIgASgJUgRuYW1lEhYKBnNjb3BlcxgDIAMoCVIGc2NvcGVzEiYKD2V4cGly'
    'ZXNfaW5fZGF5cxgEIAEoBVINZXhwaXJlc0luRGF5cw==');

@$core.Deprecated('Use apiTokenCreatedDescriptor instead')
const ApiTokenCreated$json = {
  '1': 'ApiTokenCreated',
  '2': [
    {
      '1': 'token',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.config.developer.ApiToken',
      '10': 'token'
    },
    {'1': 'secret', '3': 2, '4': 1, '5': 9, '10': 'secret'},
  ],
};

/// Descriptor for `ApiTokenCreated`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List apiTokenCreatedDescriptor = $convert.base64Decode(
    'Cg9BcGlUb2tlbkNyZWF0ZWQSMAoFdG9rZW4YASABKAsyGi5jb25maWcuZGV2ZWxvcGVyLkFwaV'
    'Rva2VuUgV0b2tlbhIWCgZzZWNyZXQYAiABKAlSBnNlY3JldA==');

@$core.Deprecated('Use apiTokenListDescriptor instead')
const ApiTokenList$json = {
  '1': 'ApiTokenList',
  '2': [
    {
      '1': 'tokens',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.config.developer.ApiToken',
      '10': 'tokens'
    },
  ],
};

/// Descriptor for `ApiTokenList`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List apiTokenListDescriptor = $convert.base64Decode(
    'CgxBcGlUb2tlbkxpc3QSMgoGdG9rZW5zGAEgAygLMhouY29uZmlnLmRldmVsb3Blci5BcGlUb2'
    'tlblIGdG9rZW5z');

@$core.Deprecated('Use apiTokenListRequestDescriptor instead')
const ApiTokenListRequest$json = {
  '1': 'ApiTokenListRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
  ],
};

/// Descriptor for `ApiTokenListRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List apiTokenListRequestDescriptor = $convert.base64Decode(
    'ChNBcGlUb2tlbkxpc3RSZXF1ZXN0EiEKDHdvcmtzcGFjZV9pZBgBIAEoCVILd29ya3NwYWNlSW'
    'Q=');

@$core.Deprecated('Use apiTokenRevokeRequestDescriptor instead')
const ApiTokenRevokeRequest$json = {
  '1': 'ApiTokenRevokeRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'token_id', '3': 2, '4': 1, '5': 9, '10': 'tokenId'},
  ],
};

/// Descriptor for `ApiTokenRevokeRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List apiTokenRevokeRequestDescriptor = $convert.base64Decode(
    'ChVBcGlUb2tlblJldm9rZVJlcXVlc3QSIQoMd29ya3NwYWNlX2lkGAEgASgJUgt3b3Jrc3BhY2'
    'VJZBIZCgh0b2tlbl9pZBgCIAEoCVIHdG9rZW5JZA==');

@$core.Deprecated('Use catalogAnswerDescriptor instead')
const CatalogAnswer$json = {
  '1': 'CatalogAnswer',
  '2': [
    {
      '1': 'scopes',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.config.developer.CatalogItem',
      '10': 'scopes'
    },
    {
      '1': 'events',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.config.developer.CatalogItem',
      '10': 'events'
    },
  ],
};

/// Descriptor for `CatalogAnswer`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List catalogAnswerDescriptor = $convert.base64Decode(
    'Cg1DYXRhbG9nQW5zd2VyEjUKBnNjb3BlcxgBIAMoCzIdLmNvbmZpZy5kZXZlbG9wZXIuQ2F0YW'
    'xvZ0l0ZW1SBnNjb3BlcxI1CgZldmVudHMYAiADKAsyHS5jb25maWcuZGV2ZWxvcGVyLkNhdGFs'
    'b2dJdGVtUgZldmVudHM=');

@$core.Deprecated('Use catalogItemDescriptor instead')
const CatalogItem$json = {
  '1': 'CatalogItem',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'label', '3': 2, '4': 1, '5': 9, '10': 'label'},
  ],
};

/// Descriptor for `CatalogItem`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List catalogItemDescriptor = $convert.base64Decode(
    'CgtDYXRhbG9nSXRlbRIQCgNrZXkYASABKAlSA2tleRIUCgVsYWJlbBgCIAEoCVIFbGFiZWw=');

@$core.Deprecated('Use catalogRequestDescriptor instead')
const CatalogRequest$json = {
  '1': 'CatalogRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
  ],
};

/// Descriptor for `CatalogRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List catalogRequestDescriptor = $convert.base64Decode(
    'Cg5DYXRhbG9nUmVxdWVzdBIhCgx3b3Jrc3BhY2VfaWQYASABKAlSC3dvcmtzcGFjZUlk');

@$core.Deprecated('Use deliveriesRequestDescriptor instead')
const DeliveriesRequest$json = {
  '1': 'DeliveriesRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'webhook_id', '3': 2, '4': 1, '5': 9, '10': 'webhookId'},
    {'1': 'before', '3': 3, '4': 1, '5': 9, '10': 'before'},
    {'1': 'limit', '3': 4, '4': 1, '5': 5, '10': 'limit'},
  ],
};

/// Descriptor for `DeliveriesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deliveriesRequestDescriptor = $convert.base64Decode(
    'ChFEZWxpdmVyaWVzUmVxdWVzdBIhCgx3b3Jrc3BhY2VfaWQYASABKAlSC3dvcmtzcGFjZUlkEh'
    '0KCndlYmhvb2tfaWQYAiABKAlSCXdlYmhvb2tJZBIWCgZiZWZvcmUYAyABKAlSBmJlZm9yZRIU'
    'CgVsaW1pdBgEIAEoBVIFbGltaXQ=');

@$core.Deprecated('Use deliveryDescriptor instead')
const Delivery$json = {
  '1': 'Delivery',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'webhook_id', '3': 2, '4': 1, '5': 9, '10': 'webhookId'},
    {'1': 'event', '3': 3, '4': 1, '5': 9, '10': 'event'},
    {'1': 'event_id', '3': 4, '4': 1, '5': 9, '10': 'eventId'},
    {'1': 'status', '3': 5, '4': 1, '5': 9, '10': 'status'},
    {'1': 'status_code', '3': 6, '4': 1, '5': 5, '10': 'statusCode'},
    {'1': 'attempt', '3': 7, '4': 1, '5': 5, '10': 'attempt'},
    {'1': 'error', '3': 8, '4': 1, '5': 9, '10': 'error'},
    {'1': 'response_snippet', '3': 9, '4': 1, '5': 9, '10': 'responseSnippet'},
    {'1': 'payload_json', '3': 10, '4': 1, '5': 9, '10': 'payloadJson'},
    {
      '1': 'request_headers_json',
      '3': 11,
      '4': 1,
      '5': 9,
      '10': 'requestHeadersJson'
    },
    {'1': 'next_retry_at', '3': 12, '4': 1, '5': 9, '10': 'nextRetryAt'},
    {'1': 'created_at', '3': 13, '4': 1, '5': 9, '10': 'createdAt'},
    {'1': 'at', '3': 14, '4': 1, '5': 9, '10': 'at'},
    {'1': 'duration_ms', '3': 15, '4': 1, '5': 5, '10': 'durationMs'},
    {'1': 'resend_of', '3': 16, '4': 1, '5': 9, '10': 'resendOf'},
  ],
};

/// Descriptor for `Delivery`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deliveryDescriptor = $convert.base64Decode(
    'CghEZWxpdmVyeRIOCgJpZBgBIAEoCVICaWQSHQoKd2ViaG9va19pZBgCIAEoCVIJd2ViaG9va0'
    'lkEhQKBWV2ZW50GAMgASgJUgVldmVudBIZCghldmVudF9pZBgEIAEoCVIHZXZlbnRJZBIWCgZz'
    'dGF0dXMYBSABKAlSBnN0YXR1cxIfCgtzdGF0dXNfY29kZRgGIAEoBVIKc3RhdHVzQ29kZRIYCg'
    'dhdHRlbXB0GAcgASgFUgdhdHRlbXB0EhQKBWVycm9yGAggASgJUgVlcnJvchIpChByZXNwb25z'
    'ZV9zbmlwcGV0GAkgASgJUg9yZXNwb25zZVNuaXBwZXQSIQoMcGF5bG9hZF9qc29uGAogASgJUg'
    'twYXlsb2FkSnNvbhIwChRyZXF1ZXN0X2hlYWRlcnNfanNvbhgLIAEoCVIScmVxdWVzdEhlYWRl'
    'cnNKc29uEiIKDW5leHRfcmV0cnlfYXQYDCABKAlSC25leHRSZXRyeUF0Eh0KCmNyZWF0ZWRfYX'
    'QYDSABKAlSCWNyZWF0ZWRBdBIOCgJhdBgOIAEoCVICYXQSHwoLZHVyYXRpb25fbXMYDyABKAVS'
    'CmR1cmF0aW9uTXMSGwoJcmVzZW5kX29mGBAgASgJUghyZXNlbmRPZg==');

@$core.Deprecated('Use deliveryAnswerDescriptor instead')
const DeliveryAnswer$json = {
  '1': 'DeliveryAnswer',
  '2': [
    {
      '1': 'delivery',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.config.developer.Delivery',
      '10': 'delivery'
    },
  ],
};

/// Descriptor for `DeliveryAnswer`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deliveryAnswerDescriptor = $convert.base64Decode(
    'Cg5EZWxpdmVyeUFuc3dlchI2CghkZWxpdmVyeRgBIAEoCzIaLmNvbmZpZy5kZXZlbG9wZXIuRG'
    'VsaXZlcnlSCGRlbGl2ZXJ5');

@$core.Deprecated('Use deliveryListDescriptor instead')
const DeliveryList$json = {
  '1': 'DeliveryList',
  '2': [
    {
      '1': 'deliveries',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.config.developer.Delivery',
      '10': 'deliveries'
    },
    {'1': 'cursor', '3': 2, '4': 1, '5': 9, '10': 'cursor'},
  ],
};

/// Descriptor for `DeliveryList`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deliveryListDescriptor = $convert.base64Decode(
    'CgxEZWxpdmVyeUxpc3QSOgoKZGVsaXZlcmllcxgBIAMoCzIaLmNvbmZpZy5kZXZlbG9wZXIuRG'
    'VsaXZlcnlSCmRlbGl2ZXJpZXMSFgoGY3Vyc29yGAIgASgJUgZjdXJzb3I=');

@$core.Deprecated('Use redeliverRequestDescriptor instead')
const RedeliverRequest$json = {
  '1': 'RedeliverRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'webhook_id', '3': 2, '4': 1, '5': 9, '10': 'webhookId'},
    {'1': 'delivery_id', '3': 3, '4': 1, '5': 9, '10': 'deliveryId'},
  ],
};

/// Descriptor for `RedeliverRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List redeliverRequestDescriptor = $convert.base64Decode(
    'ChBSZWRlbGl2ZXJSZXF1ZXN0EiEKDHdvcmtzcGFjZV9pZBgBIAEoCVILd29ya3NwYWNlSWQSHQ'
    'oKd2ViaG9va19pZBgCIAEoCVIJd2ViaG9va0lkEh8KC2RlbGl2ZXJ5X2lkGAMgASgJUgpkZWxp'
    'dmVyeUlk');

@$core.Deprecated('Use webhookDescriptor instead')
const Webhook$json = {
  '1': 'Webhook',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'workspace_id', '3': 2, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'project_id', '3': 3, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'name', '3': 4, '4': 1, '5': 9, '10': 'name'},
    {'1': 'url', '3': 5, '4': 1, '5': 9, '10': 'url'},
    {'1': 'secret', '3': 6, '4': 1, '5': 9, '10': 'secret'},
    {'1': 'events', '3': 7, '4': 3, '5': 9, '10': 'events'},
    {'1': 'active', '3': 8, '4': 1, '5': 8, '10': 'active'},
    {'1': 'disabled_reason', '3': 9, '4': 1, '5': 9, '10': 'disabledReason'},
    {'1': 'version', '3': 10, '4': 1, '5': 5, '10': 'version'},
    {'1': 'created_at', '3': 11, '4': 1, '5': 9, '10': 'createdAt'},
    {'1': 'last_status', '3': 12, '4': 1, '5': 9, '10': 'lastStatus'},
    {'1': 'last_at', '3': 13, '4': 1, '5': 9, '10': 'lastAt'},
  ],
};

/// Descriptor for `Webhook`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List webhookDescriptor = $convert.base64Decode(
    'CgdXZWJob29rEg4KAmlkGAEgASgJUgJpZBIhCgx3b3Jrc3BhY2VfaWQYAiABKAlSC3dvcmtzcG'
    'FjZUlkEh0KCnByb2plY3RfaWQYAyABKAlSCXByb2plY3RJZBISCgRuYW1lGAQgASgJUgRuYW1l'
    'EhAKA3VybBgFIAEoCVIDdXJsEhYKBnNlY3JldBgGIAEoCVIGc2VjcmV0EhYKBmV2ZW50cxgHIA'
    'MoCVIGZXZlbnRzEhYKBmFjdGl2ZRgIIAEoCFIGYWN0aXZlEicKD2Rpc2FibGVkX3JlYXNvbhgJ'
    'IAEoCVIOZGlzYWJsZWRSZWFzb24SGAoHdmVyc2lvbhgKIAEoBVIHdmVyc2lvbhIdCgpjcmVhdG'
    'VkX2F0GAsgASgJUgljcmVhdGVkQXQSHwoLbGFzdF9zdGF0dXMYDCABKAlSCmxhc3RTdGF0dXMS'
    'FwoHbGFzdF9hdBgNIAEoCVIGbGFzdEF0');

@$core.Deprecated('Use webhookAnswerDescriptor instead')
const WebhookAnswer$json = {
  '1': 'WebhookAnswer',
  '2': [
    {
      '1': 'webhook',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.config.developer.Webhook',
      '10': 'webhook'
    },
  ],
};

/// Descriptor for `WebhookAnswer`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List webhookAnswerDescriptor = $convert.base64Decode(
    'Cg1XZWJob29rQW5zd2VyEjMKB3dlYmhvb2sYASABKAsyGS5jb25maWcuZGV2ZWxvcGVyLldlYm'
    'hvb2tSB3dlYmhvb2s=');

@$core.Deprecated('Use webhookCreateRequestDescriptor instead')
const WebhookCreateRequest$json = {
  '1': 'WebhookCreateRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'url', '3': 3, '4': 1, '5': 9, '10': 'url'},
    {'1': 'events', '3': 4, '4': 3, '5': 9, '10': 'events'},
    {'1': 'project_id', '3': 5, '4': 1, '5': 9, '10': 'projectId'},
  ],
};

/// Descriptor for `WebhookCreateRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List webhookCreateRequestDescriptor = $convert.base64Decode(
    'ChRXZWJob29rQ3JlYXRlUmVxdWVzdBIhCgx3b3Jrc3BhY2VfaWQYASABKAlSC3dvcmtzcGFjZU'
    'lkEhIKBG5hbWUYAiABKAlSBG5hbWUSEAoDdXJsGAMgASgJUgN1cmwSFgoGZXZlbnRzGAQgAygJ'
    'UgZldmVudHMSHQoKcHJvamVjdF9pZBgFIAEoCVIJcHJvamVjdElk');

@$core.Deprecated('Use webhookDeleteRequestDescriptor instead')
const WebhookDeleteRequest$json = {
  '1': 'WebhookDeleteRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'webhook_id', '3': 2, '4': 1, '5': 9, '10': 'webhookId'},
  ],
};

/// Descriptor for `WebhookDeleteRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List webhookDeleteRequestDescriptor = $convert.base64Decode(
    'ChRXZWJob29rRGVsZXRlUmVxdWVzdBIhCgx3b3Jrc3BhY2VfaWQYASABKAlSC3dvcmtzcGFjZU'
    'lkEh0KCndlYmhvb2tfaWQYAiABKAlSCXdlYmhvb2tJZA==');

@$core.Deprecated('Use webhookDeletedDescriptor instead')
const WebhookDeleted$json = {
  '1': 'WebhookDeleted',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `WebhookDeleted`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List webhookDeletedDescriptor =
    $convert.base64Decode('Cg5XZWJob29rRGVsZXRlZBIOCgJpZBgBIAEoCVICaWQ=');

@$core.Deprecated('Use webhookListDescriptor instead')
const WebhookList$json = {
  '1': 'WebhookList',
  '2': [
    {
      '1': 'webhooks',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.config.developer.Webhook',
      '10': 'webhooks'
    },
  ],
};

/// Descriptor for `WebhookList`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List webhookListDescriptor = $convert.base64Decode(
    'CgtXZWJob29rTGlzdBI1Cgh3ZWJob29rcxgBIAMoCzIZLmNvbmZpZy5kZXZlbG9wZXIuV2ViaG'
    '9va1IId2ViaG9va3M=');

@$core.Deprecated('Use webhookListRequestDescriptor instead')
const WebhookListRequest$json = {
  '1': 'WebhookListRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
  ],
};

/// Descriptor for `WebhookListRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List webhookListRequestDescriptor = $convert.base64Decode(
    'ChJXZWJob29rTGlzdFJlcXVlc3QSIQoMd29ya3NwYWNlX2lkGAEgASgJUgt3b3Jrc3BhY2VJZA'
    '==');

@$core.Deprecated('Use webhookTestRequestDescriptor instead')
const WebhookTestRequest$json = {
  '1': 'WebhookTestRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'webhook_id', '3': 2, '4': 1, '5': 9, '10': 'webhookId'},
  ],
};

/// Descriptor for `WebhookTestRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List webhookTestRequestDescriptor = $convert.base64Decode(
    'ChJXZWJob29rVGVzdFJlcXVlc3QSIQoMd29ya3NwYWNlX2lkGAEgASgJUgt3b3Jrc3BhY2VJZB'
    'IdCgp3ZWJob29rX2lkGAIgASgJUgl3ZWJob29rSWQ=');

@$core.Deprecated('Use webhookUpdateRequestDescriptor instead')
const WebhookUpdateRequest$json = {
  '1': 'WebhookUpdateRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'webhook_id', '3': 2, '4': 1, '5': 9, '10': 'webhookId'},
    {'1': 'fields', '3': 3, '4': 3, '5': 9, '10': 'fields'},
    {'1': 'expected_version', '3': 4, '4': 1, '5': 5, '10': 'expectedVersion'},
    {'1': 'name', '3': 5, '4': 1, '5': 9, '10': 'name'},
    {'1': 'url', '3': 6, '4': 1, '5': 9, '10': 'url'},
    {'1': 'events', '3': 7, '4': 3, '5': 9, '10': 'events'},
    {'1': 'active', '3': 8, '4': 1, '5': 8, '10': 'active'},
    {'1': 'project_id', '3': 9, '4': 1, '5': 9, '10': 'projectId'},
  ],
};

/// Descriptor for `WebhookUpdateRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List webhookUpdateRequestDescriptor = $convert.base64Decode(
    'ChRXZWJob29rVXBkYXRlUmVxdWVzdBIhCgx3b3Jrc3BhY2VfaWQYASABKAlSC3dvcmtzcGFjZU'
    'lkEh0KCndlYmhvb2tfaWQYAiABKAlSCXdlYmhvb2tJZBIWCgZmaWVsZHMYAyADKAlSBmZpZWxk'
    'cxIpChBleHBlY3RlZF92ZXJzaW9uGAQgASgFUg9leHBlY3RlZFZlcnNpb24SEgoEbmFtZRgFIA'
    'EoCVIEbmFtZRIQCgN1cmwYBiABKAlSA3VybBIWCgZldmVudHMYByADKAlSBmV2ZW50cxIWCgZh'
    'Y3RpdmUYCCABKAhSBmFjdGl2ZRIdCgpwcm9qZWN0X2lkGAkgASgJUglwcm9qZWN0SWQ=');
