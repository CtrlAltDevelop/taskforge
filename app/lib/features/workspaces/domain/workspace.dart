import 'package:flutter/foundation.dart';

const workspaceNameMaxLength = 80;
const slugMinLength = 3;
const slugMaxLength = 40;

final _slugPattern = RegExp(r'^[a-z0-9]([a-z0-9-]*[a-z0-9])?$');

@immutable
class Workspace {
  const Workspace({
    required this.id,
    required this.name,
    required this.slug,
    required this.version,
    this.logo = '',
    this.isOwner = false,
  });

  final String id;
  final String name;
  final String slug;
  final String logo;
  final int version;
  final bool isOwner;

  @override
  bool operator ==(Object other) =>
      other is Workspace &&
      other.id == id &&
      other.name == name &&
      other.slug == slug &&
      other.logo == logo &&
      other.version == version &&
      other.isOwner == isOwner;

  @override
  int get hashCode => Object.hash(id, name, slug, logo, version, isOwner);
}

/// Mirrors the server rule (the server also refuses reserved words such as `api`).
String? validateSlug(String? value) {
  final slug = value ?? '';
  if (slug.length < slugMinLength || slug.length > slugMaxLength) {
    return 'Use $slugMinLength-$slugMaxLength characters.';
  }
  if (!_slugPattern.hasMatch(slug)) {
    return 'Use lowercase letters, numbers and hyphens, not starting or ending with a hyphen.';
  }
  return null;
}

String? validateWorkspaceName(String? value) {
  final name = (value ?? '').trim();
  if (name.isEmpty) return 'Enter a name.';
  if (name.length > workspaceNameMaxLength) {
    return 'Use at most $workspaceNameMaxLength characters.';
  }
  return null;
}

/// A URL slug suggested from a workspace name.
String slugify(String name) {
  final dashed = name
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');
  final cut = dashed.length > slugMaxLength
      ? dashed.substring(0, slugMaxLength)
      : dashed;
  return cut.replaceAll(RegExp(r'-+$'), '');
}

/// The server prefixes gRPC messages with their title (`UPLOAD_INVALID: ...`);
/// users should see only the message.
String? stripErrorTitle(String? message) =>
    message?.replaceFirst(RegExp(r'^[A-Z][A-Z0-9_]*: '), '');

enum WorkspaceFailure {
  slugTaken,
  forbidden,
  stale,
  invalid,
  notFound,
  network,
  other,
}

class WorkspaceException implements Exception {
  const WorkspaceException(this.failure, [this.detail]);

  final WorkspaceFailure failure;
  final String? detail;

  @override
  String toString() => 'WorkspaceException($failure, $detail)';
}

/// What to tell the user about a failed workspace call.
String workspaceErrorMessage(Object error) {
  if (error is! WorkspaceException) return 'Something went wrong. Try again.';
  return switch (error.failure) {
    WorkspaceFailure.slugTaken => 'That URL is taken',
    WorkspaceFailure.forbidden =>
      'You do not have permission to do that in this workspace.',
    WorkspaceFailure.stale => 'This workspace was changed elsewhere. Refresh to see the latest version.',
    WorkspaceFailure.invalid =>
      error.detail ?? 'Check the values and try again.',
    WorkspaceFailure.notFound => 'This workspace can no longer be restored.',
    WorkspaceFailure.network =>
      'Cannot reach the server. Check your connection and try again.',
    WorkspaceFailure.other => 'Something went wrong. Try again.',
  };
}
